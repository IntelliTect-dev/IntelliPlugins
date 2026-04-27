#!/usr/bin/env node
'use strict';

const fs = require('fs');
const path = require('path');
const { spawnSync } = require('child_process');
const { Octokit } = require('@octokit/rest');

const REPO_ROOT = process.cwd();
const STATE_FILE = path.posix.join('.github', 'upstream-sync-state.json');
const STATE_FILE_PATH = path.join(REPO_ROOT, STATE_FILE);

const parseArgs = (argv) => {
  const importPaths = [];

  for (let i = 0; i < argv.length; i += 1) {
    const arg = argv[i];

    if (arg === '--help' || arg === '-h') {
      console.log('Usage: node scripts/sync-upstream.js [--import <path> ...]');
      process.exit(0);
    }

    if (arg === '--import' || arg === '-i') {
      const value = argv[i + 1];
      if (!value || value.startsWith('-')) {
        throw new Error('Missing value for --import option.');
      }
      importPaths.push(value);
      i += 1;
      continue;
    }

    if (arg.startsWith('--import=')) {
      const value = arg.split('=')[1];
      if (!value) {
        throw new Error('Missing value for --import option.');
      }
      importPaths.push(value);
      continue;
    }

    // Treat any non-flag argument as an import path for simplicity
    if (!arg.startsWith('-')) {
      importPaths.push(arg);
      continue;
    }
  }

  return { importPaths };
};

const { importPaths: cliImportPaths } = parseArgs(process.argv.slice(2));
const IMPORT_PATHS = new Set(cliImportPaths);
const LOCAL_ONLY_MODE = IMPORT_PATHS.size > 0;

const runGit = (args, options = {}) => {
  const { allowFailure = false, input = undefined, trim = true } = options;
  const result = spawnSync('git', args, {
    cwd: process.cwd(),
    encoding: 'utf-8',
    input,
    stdio: ['pipe', 'pipe', 'pipe']
  });

  if (result.status !== 0) {
    if (allowFailure) {
      return null;
    }
    const stderr = result.stderr ? result.stderr.trim() : '';
    const stdout = result.stdout ? result.stdout.trim() : '';
    throw new Error(`git ${args.join(' ')} failed.\n${stderr || stdout}`);
  }

  if (!trim) {
    return result.stdout || '';
  }

  return (result.stdout || '').trim();
};

const ensureRemote = (name, url) => {
  const existing = runGit(['remote', 'get-url', name], { allowFailure: true });
  if (!existing) {
    console.log(`Adding remote ${name}: ${url}`);
    runGit(['remote', 'add', name, url]);
  }
};

const branchExists = (branch) => {
  const output = runGit(['ls-remote', '--heads', 'origin', branch], { allowFailure: true });
  return Boolean(output);
};

const readState = (ref) => {
  const blob = runGit(['show', `${ref}:${STATE_FILE}`], { allowFailure: true, trim: false });
  if (!blob) {
    return {};
  }

  try {
    return JSON.parse(blob);
  } catch (error) {
    throw new Error(`Failed to parse ${STATE_FILE} from ${ref}: ${error.message}`);
  }
};

const readLocalState = () => {
  if (!fs.existsSync(STATE_FILE_PATH)) {
    return {};
  }
  
  try {
    const raw = fs.readFileSync(STATE_FILE_PATH, 'utf-8');
    return raw ? JSON.parse(raw) : {};
  } catch (error) {
    throw new Error(`Failed to read ${STATE_FILE_PATH}: ${error.message}`);
  }
};

const writeState = (state) => {
  const sortedEntries = Object.keys(state)
    .sort()
    .reduce((ordered, key) => {
      ordered[key] = state[key];
      return ordered;
    }, {});
    
  const content = `${JSON.stringify(sortedEntries, null, 2)}\n`;
  fs.writeFileSync(STATE_FILE_PATH, content, 'utf-8');
};

const sanitizeBranchName = (filePath) => {
  return `sync/${filePath
    .toLowerCase()
    .replace(/[^a-z0-9]+/gi, '-')
    .replace(/^-+|-+$/g, '')
    .replace(/-{2,}/g, '-')}`;
};

const applyPatch = (patch) => {
  runGit(['apply', '--3way', '--allow-empty'], { input: patch });
};

const findOpenPull = async (octokit, owner, repo, branch) => {
  const { data } = await octokit.pulls.list({
    owner,
    repo,
    state: 'open',
    head: `${owner}:${branch}`,
    per_page: 1
  });
  return data.length ? data[0] : null;
};

const commentOnPull = async (octokit, owner, repo, number, body) => {
  await octokit.issues.createComment({
    owner,
    repo,
    issue_number: number,
    body
  });
};

const buildPrBody = ({ file, upstreamRepo, upstreamSha, directories }) => {
  const shortSha = upstreamSha.slice(0, 7);
  const directoryList = directories.map((dir) => `- ${dir}`).join('\n');

  return [
    '## Summary',
    `- Sync \`${file}\` with ${upstreamRepo}@${shortSha}`,
    '',
    '## Details',
    `- Tracking directories:\n${directoryList}`,
    `- State updated in \`${STATE_FILE}\``
  ].join('\n');
};

const ensureCleanBase = (baseBranch) => {
  runGit(['checkout', baseBranch]);
  runGit(['reset', '--hard', `origin/${baseBranch}`]);
  runGit(['clean', '-fd']);
};

const processFile = async ({
  file,
  baseBranch,
  upstreamRepo,
  upstreamSha,
  directories,
  octokit,
  owner,
  repo,
  baseState,
  localOnly
}) => {
  console.log(`\n➡️  Processing ${file}`);

  const stateEntry = baseState[file] || {};
  let branch = stateEntry.branch || sanitizeBranchName(file);
  const fileExists = fs.existsSync(path.join(REPO_ROOT, file));
  
  if (!fileExists && IMPORT_PATHS.has(file)) {
    // For new upstream files, copy directly instead of applying a patch
    console.log('Copying new upstream file directly...');
    try {
      const fileContent = runGit(['show', `upstream/main:${file}`], { trim: false });
      const filePath = path.join(REPO_ROOT, file);
      const fileDir = path.dirname(filePath);
      
      // Ensure directory exists
      if (!fs.existsSync(fileDir)) {
        fs.mkdirSync(fileDir, { recursive: true });
      }
      
      fs.writeFileSync(filePath, fileContent);
      console.log(`Successfully copied ${file} from upstream.`);
    } catch (error) {
      console.error(`Failed to copy upstream file ${file}: ${error.message}`);
      return { status: 'failed', file, message: error.message };
    }
  } else {
    // For existing files, apply patch as usual
    const localPatch = runGit(
      ['diff', `origin/${baseBranch}..upstream/main`, '--', file],
      { trim: false }
    );

    if (!localPatch.trim()) {
      console.log('No patch content detected, skipping.');
      return { status: 'skipped', file };
    }

    try {
      applyPatch(localPatch);
    } catch (error) {
      console.error(`Patch failed for ${file}: ${error.message}`);
      if (!localOnly) {
        ensureCleanBase(baseBranch);
      }
      return { status: 'conflict', file, message: error.message };
    }
  }

  let branchState = null;
  if (!localOnly) {
    const remoteBranchExists = branchExists(branch);
    if (remoteBranchExists) {
      runGit(['fetch', 'origin', branch]);
      branchState = readState(`origin/${branch}`);
      
      // Use branch-specific branch name if available
      const branchEntry = branchState[file];
      if (!stateEntry.branch && branchEntry?.branch) {
        branch = branchEntry.branch;
        if (branchExists(branch)) {
          runGit(['fetch', 'origin', branch]);
          branchState = readState(`origin/${branch}`);
        }
      }
    }
  }

  const previousEntry = (branchState && branchState[file]) || stateEntry;
  const previousSha = previousEntry ? previousEntry.upstreamSha : null;

  if (!localOnly && previousSha && previousSha === upstreamSha && branchState) {
    console.log('Upstream commit already recorded for branch; refreshing with latest main baseline.');
  }

  const updatedState = { ...baseState, [file]: { branch, upstreamSha } };

  if (!localOnly) {
    ensureCleanBase(baseBranch);
    runGit(['checkout', '-B', branch, `origin/${baseBranch}`]);
  }

  writeState(updatedState);
  baseState[file] = { branch, upstreamSha };

  if (localOnly) {
    console.log('Imported upstream changes locally. Review the file and `.github/upstream-sync-state.json`, then commit when ready.');
    return { status: 'local-update', file };
  }

  runGit(['add', file, STATE_FILE]);

  const stagedDiff = runGit(['diff', '--cached'], { trim: false });
  if (!stagedDiff.trim()) {
    console.log('No staged changes after applying patch; branch already matches desired state.');
    ensureCleanBase(baseBranch);
    return { status: 'unchanged', file };
  }

  const shortSha = upstreamSha.slice(0, 7);
  const commitMessage = `Sync ${file} @ ${upstreamRepo}#${shortSha}`;

  try {
    runGit(['commit', '-m', commitMessage]);
  } catch (error) {
    console.error(`Commit failed for ${file}: ${error.message}`);
    ensureCleanBase(baseBranch);
    return { status: 'failed', file, message: error.message };
  }

  try {
    runGit(['push', 'origin', `${branch}:${branch}`, '--force-with-lease']);
  } catch (error) {
    console.error(`Push failed for ${file}: ${error.message}`);
    ensureCleanBase(baseBranch);
    return { status: 'failed', file, message: error.message };
  }

  let pull = await findOpenPull(octokit, owner, repo, branch);

  if (!pull) {
    const title = `chore: Sync ${file} from ${upstreamRepo}`;
    const body = buildPrBody({ file, upstreamRepo, upstreamSha, directories });
    pull = (
      await octokit.pulls.create({
        owner,
        repo,
        head: branch,
        base: baseBranch,
        title,
        body
      })
    ).data;
    console.log(`Opened PR #${pull.number} for ${file}.`);
  } else {
    await commentOnPull(
      octokit,
      owner,
      repo,
      pull.number,
      `Synced with upstream commit ${upstreamRepo}@${shortSha}.`
    );
    console.log(`Updated PR #${pull.number} for ${file}.`);
  }

  ensureCleanBase(baseBranch);
  return { status: 'updated', file, pullNumber: pull.number };
};

const main = async () => {
  const token = process.env.GITHUB_TOKEN;
  if (!token && !LOCAL_ONLY_MODE) {
    throw new Error('GITHUB_TOKEN is required for authentication.');
  }

  const repository = process.env.GITHUB_REPOSITORY;
  if (!repository && !LOCAL_ONLY_MODE) {
    throw new Error('GITHUB_REPOSITORY is required.');
  }

  const [owner, repo] = repository ? repository.split('/') : [null, null];
  const upstreamRepo = process.env.UPSTREAM_REPO || 'github/awesome-copilot';
  const baseBranch = process.env.BASE_BRANCH || 'main';
  const directories = (process.env.SYNC_DIRECTORIES || 'prompts instructions chatmodes')
    .split(/\s+/)
    .filter(Boolean);

  const octokit = LOCAL_ONLY_MODE ? null : new Octokit({ auth: token });

  ensureRemote('upstream', `https://github.com/${upstreamRepo}.git`);
  runGit(['fetch', 'upstream', 'main']);
  runGit(['fetch', 'origin', baseBranch]);
  if (!LOCAL_ONLY_MODE) {
    ensureCleanBase(baseBranch);
  }

  const diffArgs = ['diff', `origin/${baseBranch}..upstream/main`, '--name-only', '--', ...directories];
  const diffOutput = runGit(diffArgs, { trim: true });
  const diffFiles = diffOutput ? diffOutput.split('\n').map((file) => file.trim()).filter(Boolean) : [];
  
  // Use import paths if specified, otherwise use diff files
  const candidateSet = IMPORT_PATHS.size > 0 ? new Set(IMPORT_PATHS) : new Set(diffFiles);

  const trackedFiles = Array.from(candidateSet).filter((file) => {
    const absolutePath = path.join(REPO_ROOT, file);
    const fileExists = fs.existsSync(absolutePath);
    const isImportRequest = IMPORT_PATHS.has(file);
    
    if (fileExists || isImportRequest) {
      if (isImportRequest && !fileExists) {
        console.log(`Importing upstream file via --import: ${file}`);
      }
      return true;
    }
    
    console.log(`Skipping new upstream file: ${file}`);
    return false;
  });

  if (trackedFiles.length === 0) {
    console.log('No upstream changes detected within target directories.');
    return;
  }

  const label = LOCAL_ONLY_MODE ? 'file(s) selected for local import.' : 'existing file(s) with upstream changes.';
  console.log(`Detected ${trackedFiles.length} ${label}`);

  // Load state from working tree (local-only) or remote branch
  const baseState = LOCAL_ONLY_MODE ? readLocalState() : readState(`origin/${baseBranch}`);
  const results = [];

  for (const file of trackedFiles) {
    const upstreamSha = runGit(['log', '-n', '1', '--pretty=format:%H', 'upstream/main', '--', file]);
    if (!upstreamSha) {
      console.log(`Unable to determine upstream commit for ${file}, skipping.`);
      continue;
    }

    const result = await processFile({
      file,
      baseBranch,
      upstreamRepo,
      upstreamSha,
      directories,
      octokit,
      owner,
      repo,
      baseState,
      localOnly: LOCAL_ONLY_MODE
    });

    results.push(result);
  }

  const conflicts = results.filter((item) => item.status === 'conflict' || item.status === 'failed');
  if (conflicts.length > 0) {
    console.error('\nConflicts encountered during sync:');
    for (const conflict of conflicts) {
      console.error(`- ${conflict.file}: ${conflict.message}`);
    }
    process.exitCode = 1;
  } else {
    console.log('\nSync completed without conflicts.');
  }
};

main().catch((error) => {
  console.error(error.message);
  process.exitCode = 1;
});
