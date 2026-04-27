---
name: add-accessibility
description: Add WCAG-compliant accessibility and UX improvements to Vuetify components
---

# Add Accessibility Skill

Audit and improve Vuetify Vue 3 components for WCAG compliance, keyboard navigation, ARIA labeling, color contrast, and overall UX quality.

## When to Use

Invoke this skill when you:
- Need to audit a component for accessibility issues
- Are adding ARIA labels, roles, or keyboard navigation support
- Want to ensure color contrast and visual accessibility standards
- Need to improve UX consistency and Vuetify component usage

# Accessibility & UX Best Practices

Build inclusive, professional user interfaces that work for everyone. Master WCAG accessibility standards, semantic HTML, keyboard navigation, and accessibility testing.

## Table of Contents

1. [Web Accessibility Fundamentals](#web-accessibility-fundamentals)
2. [Semantic HTML](#semantic-html)
3. [ARIA Attributes and Roles](#aria-attributes-and-roles)
4. [Keyboard Navigation](#keyboard-navigation)
5. [Color, Contrast, and Visual Clarity](#color-contrast-and-visual-clarity)
6. [Form Accessibility](#form-accessibility)
7. [Screen Reader Support](#screen-reader-support)
8. [Focus Management](#focus-management)
9. [Testing for Accessibility](#testing-for-accessibility)
10. [Accessible Components](#accessible-components)
11. [Common Patterns](#common-patterns)

---

## Web Accessibility Fundamentals

Web accessibility (a11y) ensures your application is usable by everyone, regardless of ability or device. This isn't optional — it's a legal requirement in many jurisdictions and a mark of professional quality.

### Why Accessibility Matters

- **Legal**: WCAG compliance is required by law in many countries
- **Business**: Accessible sites have better SEO and reach wider audiences
- **Ethical**: Everyone deserves access to digital services
- **Quality**: Accessibility practices improve design for everyone
- **Performance**: Accessible code is often better optimized

### WCAG Standards

The Web Content Accessibility Guidelines (WCAG) 2.1 are the gold standard. Compliance levels:

- **Level A**: Basic accessibility (minimum)
- **Level AA**: Enhanced accessibility (recommended for most sites)
- **Level AAA**: Expert accessibility (ambitious, some features conflict with AA)

Target **WCAG 2.1 Level AA** for professional applications.

### Four Principles: POUR

```
Perceivable   - Users can perceive content (not invisible)
Operable      - Users can navigate and use controls (keyboard friendly)
Understandable - Users understand content and how to use it
Robust        - Works with current and future technologies (valid HTML)
```

---

## Semantic HTML

Use HTML semantically to provide meaning to screen readers and browsers.

### Page Structure

```html
<!--  Bad: Non-semantic divs -->
<div class="header">
  <div class="nav">Navigation</div>
</div>
<div class="main">
  <div class="article">Content</div>
  <div class="sidebar">Sidebar</div>
</div>
<div class="footer">Footer</div>

<!--  Good: Semantic HTML -->
<header>
  <nav>Navigation</nav>
</header>
<main>
  <article>Content</article>
  <aside>Sidebar</aside>
</main>
<footer>Footer</footer>
```

### Semantic Elements

```html
<!-- Headers and footers -->
<header>Page or section header</header>
<footer>Page or section footer</footer>
<main>Main content (one per page)</main>

<!-- Navigation -->
<nav>Navigation links</nav>

<!-- Content sections -->
<section>Thematic grouping of content</section>
<article>Self-contained content (blog post, news article)</article>
<aside>Related content, sidebar</aside>

<!-- Headings (hierarchy matters) -->
<h1>Page title (only one per page)</h1>
<h2>Major section</h2>
<h3>Subsection</h3>
<!-- Never skip levels: h1 → h3 is bad -->

<!-- Lists -->
<ul>
  <li>Unordered list item</li>
</ul>

<!-- Text emphasis -->
<strong>Important text</strong>    <!-- Emphasis -->
<em>Emphasized text</em>           <!-- Emphasis -->
<mark>Highlighted text</mark>      <!-- Marked/highlighted -->
<code>Code snippet</code>           <!-- Code -->
```

### Headings Hierarchy

```vue
<!--  Bad: Skips h2, uses h3 for styling -->
<h1>Page Title</h1>
<h3>Section Title</h3>
<p>Content...</p>

<!--  Good: Proper hierarchy -->
<h1>Page Title</h1>
<h2>Section Title</h2>
<p>Content...</p>

<!-- Multiple sections at same level -->
<h1>Page Title</h1>
<h2>Section 1</h2>
<p>Content...</p>
<h2>Section 2</h2>
<p>Content...</p>
<h3>Subsection 2.1</h3>
<p>Content...</p>
```

### Buttons vs Links

```html
<!-- Use <button> for actions -->
<button @click="deleteUser">Delete</button>
<button type="submit">Submit</button>

<!-- Use <a> for navigation -->
<a href="/users">Users</a>
<a href="/settings">Settings</a>

<!--  Bad: Using link for action -->
<a href="#" @click="delete">Delete</a>

<!--  Bad: Using button for navigation -->
<button @click="navigateTo('/users')">Users</button>

<!--  Good: Use proper elements -->
<button @click="deleteUser">Delete</button>
<a href="/users">Users</a>
```

---

## ARIA Attributes and Roles

ARIA (Accessible Rich Internet Applications) adds semantic meaning to dynamic content.

### ARIA Roles

```html
<!-- Explicit role when semantic element doesn't exist -->
<div role="alert">
  An error has occurred
</div>

<!-- Navigation -->
<div role="navigation" aria-label="Main">
  <!-- Navigation items -->
</div>

<!-- Tab interface -->
<div role="tablist">
  <button role="tab" aria-selected="true">Tab 1</button>
  <button role="tab" aria-selected="false">Tab 2</button>
</div>

<!-- Search landmark -->
<div role="search">
  <!-- Search form -->
</div>

<!-- Dialog/Modal -->
<div role="dialog" aria-labelledby="dialogTitle">
  <h2 id="dialogTitle">Confirm Action</h2>
  <!-- Dialog content -->
</div>
```

### ARIA Properties

```html
<!-- aria-label: Accessible name for element -->
<button aria-label="Close menu"></button>

<!-- aria-labelledby: Reference heading that labels this element -->
<h2 id="tableTitle">Users</h2>
<table aria-labelledby="tableTitle">
  <!-- Table content -->
</table>

<!-- aria-describedby: Detailed description -->
<input id="password" type="password" aria-describedby="pwdHint" />
<div id="pwdHint">Password must be 8+ characters</div>

<!-- aria-hidden: Hide from accessibility tree -->
<span aria-hidden="true">→</span> <!-- Decorative icon -->

<!-- aria-live: Announce dynamic changes to screen readers -->
<div aria-live="polite">
  Loading... <!-- Screen reader announces when updated -->
</div>

<!-- aria-current: Indicate current page in navigation -->
<nav>
  <a href="/home">Home</a>
  <a href="/users" aria-current="page">Users</a>
  <a href="/settings">Settings</a>
</nav>

<!-- aria-invalid: Mark invalid fields -->
<input type="email" aria-invalid="true" aria-describedby="emailError" />
<span id="emailError">Invalid email format</span>
```

### ARIA States

```html
<!-- aria-disabled: Disabled but visible (use instead of disabled for custom controls) -->
<div role="button" aria-disabled="true">Disabled Action</div>

<!-- aria-selected: Selection state for tabs, menu items -->
<button role="tab" aria-selected="true">Active Tab</button>
<button role="tab" aria-selected="false">Inactive Tab</button>

<!-- aria-expanded: Expanded/collapsed state -->
<button aria-expanded="false" @click="toggle">
  Options
</button>
<div v-if="isOpen" aria-expanded="true">
  <!-- Options list -->
</div>

<!-- aria-checked: Checkbox-like state -->
<div role="checkbox" aria-checked="true" tabindex="0">Checked Item</div>

<!-- aria-pressed: Button state (on/off) -->
<button aria-pressed="true">Bold</button>
<button aria-pressed="false">Italic</button>
```

---

## Keyboard Navigation

All interactive elements must be accessible via keyboard alone.

### Tab Order

```html
<!-- Natural tab order (default) -->
<input type="text" />      <!-- Tab 1 -->
<button>Click me</button>  <!-- Tab 2 -->
<a href="/">Home</a>       <!-- Tab 3 -->

<!-- tabindex="0": Add to tab order (for non-focusable elements) -->
<div tabindex="0" role="button" @click="action">
  Clickable div
</div>

<!-- tabindex="-1": Remove from tab order (still focusable via JS) -->
<button tabindex="-1">Focus via JS only</button>

<!--  Avoid: tabindex > 0 (breaks natural tab order) -->
<button tabindex="1">First</button>
<button tabindex="2">Second</button>
```

### Keyboard Shortcuts

```vue
<!-- Keyboard modifiers for shortcuts -->
<input @keydown.enter="submit" placeholder="Press Enter to submit" />
<input @keydown.escape="cancel" placeholder="Press Escape to cancel" />
<button @keydown.space="activate">Press Space</button>

<!-- Custom keyboard handling -->
<template>
  <div
    role="button"
    tabindex="0"
    @click="handleAction"
    @keydown.enter="handleAction"
    @keydown.space="handleAction"
  >
    Keyboard accessible button
  </div>
</template>

<script setup lang="ts">
const handleAction = () => {
  console.log('Action triggered')
}
</script>
```

### Skip Links

Help keyboard users skip repetitive content.

```vue
<template>
  <!-- Skip to main content link (hidden by default) -->
  <a href="#main-content" class="skip-link">
    Skip to main content
  </a>

  <header>
    <nav>Navigation</nav>
  </header>

  <main id="main-content">
    Content
  </main>
</template>

<style>
/* Show skip link on focus */
.skip-link {
  position: absolute;
  top: -40px;
  left: 0;
  background: #000;
  color: #fff;
  padding: 8px;
  z-index: 100;
}

.skip-link:focus {
  top: 0;
}
</style>
```

---

## Color, Contrast, and Visual Clarity

Ensure sufficient color contrast and don't rely on color alone.

### Color Contrast

```html
<!-- WCAG AA requires 4.5:1 contrast for normal text -->
<!-- WCAG AA requires 3:1 contrast for large text (18pt+) -->

<!--  Bad: Insufficient contrast -->
<p style="color: #999; background: #fff;">
  Light gray on white - too low contrast
</p>

<!--  Good: Sufficient contrast -->
<p style="color: #333; background: #fff;">
  Dark gray on white - 7:1 contrast
</p>

<!-- Check contrast: https://webaim.org/resources/contrastchecker/ -->
```

### Don't Rely on Color Alone

```vue
<!--  Bad: Only color indicates status -->
<div style="color: green">Success</div>
<div style="color: red">Error</div>

<!--  Good: Color + icon + text -->
<div>
  <VIcon color="green" icon="mdi-check" />
  <span>Success</span>
</div>

<div>
  <VIcon color="red" icon="mdi-alert" />
  <span>Error</span>
</div>

<!-- In tables: Color + pattern/text -->
<table>
  <tr>
    <td style="background: #90EE90">Available</td>
    <td style="background: #FF9999">Booked</td>
  </tr>
</table>
```

### Focus Indicators

```css
/* Always provide visible focus indicators */
button:focus,
a:focus,
input:focus {
  outline: 2px solid #1976D2;
  outline-offset: 2px;
}

/* Don't remove outlines! */
button:focus {
  /*  Never do this: */
  /* outline: none; */
}

/* Custom focus style (keep it visible) */
button:focus-visible {
  outline: 3px solid #FFD700;
  outline-offset: 2px;
}
```

### Visual Hierarchy

```html
<!-- Clear visual hierarchy for scanning -->
<h1>Primary Heading (28px, bold)</h1>
<h2>Secondary Heading (24px, bold)</h2>
<p>Body text (16px, regular)</p>
<small>Caption text (14px, lighter)</small>

<!-- Spacing for readability -->
<p style="line-height: 1.5; margin-bottom: 1.5rem;">
  Adequate line height and paragraph spacing aid readability
</p>
```

---

## Form Accessibility

Forms are critical for accessibility. Proper labeling and error handling are essential.

### Proper Form Labels

```vue
<!--  Bad: No label -->
<input type="email" placeholder="Email" />

<!--  Good: Associated label -->
<label for="email">Email Address</label>
<input id="email" type="email" />

<!-- Vuetify: Use label prop -->
<VTextField
  id="email"
  v-model="email"
  label="Email Address"
  type="email"
  required
/>

<!-- Label with required indicator -->
<label for="name">
  Full Name <span aria-label="required">*</span>
</label>
<input id="name" type="text" required />
</script>
```

### Error Messages and Validation

```vue
<template>
  <div>
    <label for="password">Password</label>
    <input
      id="password"
      type="password"
      aria-invalid="false"
      aria-describedby="passwordHint"
    />
    <div id="passwordHint" class="text-caption">
      At least 8 characters, including uppercase, lowercase, and number
    </div>

    <!-- On error -->
    <input
      id="email"
      type="email"
      aria-invalid="true"
      aria-describedby="emailError"
    />
    <div id="emailError" role="alert" class="text-error">
      Invalid email format. Please check and try again.
    </div>
  </div>
</template>

<!-- Vuetify: Automatically handles error announcement -->
<VTextField
  v-model="email"
  label="Email"
  :rules="[required, validEmail]"
  :error="hasError"
  :error-messages="errorMessages"
  hint="Enter a valid email address"
  persistent-hint
/>
```

### Form Groups and Fieldsets

```html
<!-- Group related inputs with fieldset -->
<fieldset>
  <legend>Contact Preferences</legend>
  
  <label>
    <input type="checkbox" name="contact" value="email" />
    Email
  </label>
  
  <label>
    <input type="checkbox" name="contact" value="phone" />
    Phone
  </label>
</fieldset>

<!-- ARIA: Alternative for custom controls -->
<div role="group" aria-labelledby="contactTitle">
  <h3 id="contactTitle">Contact Preferences</h3>
  <!-- Custom radio buttons or checkboxes -->
</div>
```

### Form Submission

```vue
<template>
  <form @submit.prevent="submit" novalidate>
    <!-- Validation messages with role="alert" announce on change -->
    <div v-if="errors.email" id="emailError" role="alert" class="text-error">
      {{ errors.email }}
    </div>

    <VTextField
      v-model="formData.email"
      label="Email"
      aria-describedby="emailError"
      :error="!!errors.email"
    />

    <VBtn type="submit" :loading="isSubmitting" color="primary">
      Submit
    </VBtn>
  </form>
</template>

<script setup lang="ts">
import { ref } from 'vue'

const formData = ref({ email: '' })
const errors = ref<Record<string, string>>({})
const isSubmitting = ref(false)

const submit = async () => {
  errors.value = {}
  isSubmitting.value = true

  try {
    // Validate
    if (!formData.value.email) {
      errors.value.email = 'Email is required'
      return
    }

    // Submit
    await submitForm()
  } finally {
    isSubmitting.value = false
  }
}
</script>
```

---

## Screen Reader Support

Make your application understandable to screen reader users.

### Meaningful Link Text

```html
<!--  Bad: Generic link text -->
<a href="/user/123">Click here</a>
<a href="/download">Read more</a>

<!--  Good: Descriptive link text -->
<a href="/user/123">View John Doe's profile</a>
<a href="/download">Download accessibility guide (PDF)</a>

<!-- aria-label for icon-only links -->
<a href="/search" aria-label="Search">
  <i class="icon-search"></i>
</a>
```

### Image Alt Text

```html
<!-- Decorative image: empty alt -->
<img src="divider.svg" alt="" />

<!-- Informative image: describe content -->
<img 
  src="chart.svg" 
  alt="Sales chart showing 20% increase in Q4" 
/>

<!-- Linked image: describe link target -->
<a href="/products">
  <img src="logo.svg" alt="Company logo home" />
</a>

<!-- Long description for complex images -->
<img 
  src="complex-diagram.svg" 
  alt="System architecture diagram"
  aria-describedby="diagramDesc"
/>
<div id="diagramDesc">
  <!-- Detailed text description -->
</div>
```

### Tables

```html
<!-- Proper table markup -->
<table>
  <caption>Sales by Region (Q4 2023)</caption>
  
  <thead>
    <tr>
      <th scope="col">Region</th>
      <th scope="col">Sales</th>
      <th scope="col">Growth</th>
    </tr>
  </thead>
  
  <tbody>
    <tr>
      <th scope="row">North America</th>
      <td>$1.2M</td>
      <td>15%</td>
    </tr>
    <tr>
      <th scope="row">Europe</th>
      <td>$800K</td>
      <td>12%</td>
    </tr>
  </tbody>
</table>
```

### Lists

```html
<!-- Use semantic list elements -->
<ul>
  <li>First item</li>
  <li>Second item</li>
</ul>

<!-- NOT: Divs with role="listitem" -->
<div>
  <div role="listitem">First item</div>
  <div role="listitem">Second item</div>
</div>
```

---

## Focus Management

Manage focus for a smooth, predictable experience.

### Auto-Focus on Dialog

```vue
<template>
  <VDialog v-model="isOpen">
    <VCard>
      <VCardTitle>Dialog Title</VCardTitle>
      <VCardText>
        <!-- Autofocus the first input -->
        <VTextField
          ref="firstInput"
          autofocus
          label="First Name"
        />
      </VCardText>
      <VCardActions>
        <VBtn @click="isOpen = false">Cancel</VBtn>
        <VBtn color="primary">Save</VBtn>
      </VCardActions>
    </VCard>
  </VDialog>
</template>

<script setup lang="ts">
import { ref, watch } from 'vue'

const isOpen = ref(false)
const firstInput = ref<any>(null)

// Ensure focus moves to modal
watch(isOpen, (open) => {
  if (open) {
    // Vue automatically handles with autofocus
    firstInput.value?.focus()
  }
})
</script>
```

### Focus Trap in Modal

```typescript
// composables/useFocusTrap.ts
import { ref, onMounted, onUnmounted } from 'vue'

export const useFocusTrap = (containerRef: Ref<HTMLElement | null>) => {
  const handleKeyDown = (e: KeyboardEvent) => {
    if (e.key !== 'Tab' || !containerRef.value) return

    const focusable = containerRef.value.querySelectorAll(
      'button, [href], input, select, textarea, [tabindex]:not([tabindex="-1"])'
    )
    const first = focusable[0] as HTMLElement
    const last = focusable[focusable.length - 1] as HTMLElement

    if (e.shiftKey && document.activeElement === first) {
      e.preventDefault()
      last.focus()
    } else if (!e.shiftKey && document.activeElement === last) {
      e.preventDefault()
      first.focus()
    }
  }

  onMounted(() => {
    containerRef.value?.addEventListener('keydown', handleKeyDown)
  })

  onUnmounted(() => {
    containerRef.value?.removeEventListener('keydown', handleKeyDown)
  })
}

// Usage
const modalRef = ref<HTMLElement | null>(null)
useFocusTrap(modalRef)
```

---

## Testing for Accessibility

### Automated Testing with axe-core

```typescript
// Example: Cypress + axe-core
import { injectAxe, checkA11y } from 'axe-playwright'

test('Page should be accessible', async ({ page }) => {
  await page.goto('/')
  
  // Inject axe testing engine
  await injectAxe(page)
  
  // Run accessibility checks
  await checkA11y(page)
})
```

### Manual Testing Checklist

```markdown
## Accessibility Testing Checklist

### Keyboard Navigation
- [ ] All interactive elements are reachable via Tab
- [ ] Tab order is logical and matches visual order
- [ ] No keyboard traps (can't Tab out)
- [ ] Enter/Space/Escape work as expected

### Screen Reader (NVDA, JAWS, VoiceOver)
- [ ] Page structure makes sense when read aloud
- [ ] Form labels are announced with inputs
- [ ] Errors are announced as alerts
- [ ] Images have meaningful alt text
- [ ] Links have descriptive text

### Vision
- [ ] Text has sufficient contrast (4.5:1 minimum)
- [ ] Focus indicators are clearly visible
- [ ] Content doesn't rely on color alone
- [ ] Text is readable at 200% zoom

### Motor
- [ ] All interactions work via keyboard
- [ ] Click targets are large enough (44x44px minimum)
- [ ] No time-dependent interactions
- [ ] No flashing/blinking content (more than 3x per second)

### Cognition
- [ ] Language is clear and simple
- [ ] Navigation is consistent
- [ ] Error messages are helpful
- [ ] Instructions are clear
```

### WAVE Browser Extension

Use the WAVE (Web Accessibility Evaluation Tool) browser extension to identify accessibility issues:

1. Install WAVE from your browser's extension store
2. Click the WAVE icon on any page
3. Review errors, warnings, and features
4. Fix identified issues

### Lighthouse in Chrome DevTools

```
1. Open Chrome DevTools (F12)
2. Go to Lighthouse tab
3. Select "Accessibility" category
4. Run audit
5. Review findings and recommendations
```

---

## Accessible Components

### Accessible Alert

```vue
<template>
  <VAlert
    v-if="showAlert"
    :type="alertType"
    :title="alertTitle"
    role="alert"
    class="mb-4"
  >
    {{ alertMessage }}
  </VAlert>
</template>

<script setup lang="ts">
import { ref } from 'vue'

const showAlert = ref(false)
const alertType = ref<'success' | 'error' | 'warning'>('success')
const alertTitle = ref('')
const alertMessage = ref('')

// Announce important messages
const announce = (type: string, title: string, message: string) => {
  alertType.value = type as any
  alertTitle.value = title
  alertMessage.value = message
  showAlert.value = true
}
</script>
```

### Accessible Dialog

```vue
<template>
  <VDialog
    v-model="isOpen"
    role="dialog"
    aria-labelledby="dialogTitle"
    aria-modal="true"
  >
    <VCard>
      <VCardTitle id="dialogTitle">
        Confirm Action
      </VCardTitle>

      <VCardText>
        Are you sure you want to proceed?
      </VCardText>

      <VCardActions>
        <VSpacer />
        <VBtn @click="isOpen = false">
          Cancel
        </VBtn>
        <VBtn color="primary" @click="confirm">
          Confirm
        </VBtn>
      </VCardActions>
    </VCard>
  </VDialog>
</template>

<script setup lang="ts">
import { ref } from 'vue'

const isOpen = ref(false)

const confirm = () => {
  // Handle confirmation
  isOpen.value = false
}
</script>
```

### Accessible Form

```vue
<template>
  <form @submit.prevent="submit" novalidate>
    <!-- Validation summary for screen readers -->
    <VAlert
      v-if="Object.keys(errors).length > 0"
      type="error"
      title="Form has errors"
      role="region"
      aria-live="assertive"
    >
      <ul class="pl-4">
        <li v-for="(error, field) in errors" :key="field">
          {{ field }}: {{ error }}
        </li>
      </ul>
    </VAlert>

    <!-- Form fields -->
    <VTextField
      v-model="formData.name"
      label="Full Name"
      :error="!!errors.name"
      :error-messages="errors.name ? [errors.name] : []"
      required
    />

    <VTextField
      v-model="formData.email"
      label="Email Address"
      type="email"
      :error="!!errors.email"
      :error-messages="errors.email ? [errors.email] : []"
      required
    />

    <div class="mt-4">
      <VBtn type="submit" color="primary" :loading="isSubmitting">
        Submit
      </VBtn>
    </div>
  </form>
</template>

<script setup lang="ts">
import { ref } from 'vue'

const formData = ref({ name: '', email: '' })
const errors = ref<Record<string, string>>({})
const isSubmitting = ref(false)

const submit = async () => {
  errors.value = {}
  
  // Validate
  if (!formData.value.name) {
    errors.value.name = 'Name is required'
  }
  if (!formData.value.email) {
    errors.value.email = 'Email is required'
  }

  if (Object.keys(errors.value).length > 0) return

  isSubmitting.value = true
  try {
    // Submit to API
    console.log('Submitting:', formData.value)
  } finally {
    isSubmitting.value = false
  }
}
</script>
```

---

## Common Patterns

### Loading State with Accessible Feedback

```vue
<template>
  <div role="status" aria-live="polite" aria-busy="isLoading">
    <VProgressLinear
      v-if="isLoading"
      indeterminate
    />
    <p v-else-if="error" class="text-error">
      Failed to load. Please try again.
    </p>
    <div v-else>
      <!-- Content -->
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref } from 'vue'

const isLoading = ref(true)
const error = ref(false)
</script>
```

### Accessible Data Table

```vue
<template>
  <div>
    <!-- Table caption for screen readers -->
    <h2 id="tableCaption">User Directory</h2>

    <VDataTable
      :items="users"
      :headers="headers"
      item-key="id"
      role="table"
      aria-labelledby="tableCaption"
    >
      <!-- Status column with icon + text -->
      <template #[`item.status`]="{ item }">
        <VIcon
          :icon="item.status === 'active' ? 'mdi-check' : 'mdi-close'"
          :color="item.status === 'active' ? 'green' : 'red'"
        />
        <span class="ml-2">{{ item.status }}</span>
      </template>

      <!-- Actions with descriptive labels -->
      <template #[`item.actions`]="{ item }">
        <VIconButton
          icon="mdi-pencil"
          aria-label="Edit {{ item.name }}"
          @click="editUser(item)"
        />
        <VIconButton
          icon="mdi-delete"
          aria-label="Delete {{ item.name }}"
          @click="deleteUser(item)"
        />
      </template>
    </VDataTable>
  </div>
</template>
```

---

## Best Practices Summary

1. **Always use semantic HTML** — It's the foundation of accessibility
2. **Test with real assistive technology** — NVDA, JAWS, VoiceOver
3. **Provide alternative text** — For images, icons, and visual information
4. **Ensure color contrast** — Minimum 4.5:1 for normal text (WCAG AA)
5. **Make everything keyboard accessible** — Tab, Enter, Escape should work
6. **Use ARIA wisely** — It supplements, doesn't replace semantic HTML
7. **Test with axe-core** — Automated accessibility scanning
8. **Focus management** — Dialogs, modals, and single-page apps need careful focus handling
9. **Clear error messages** — Tell users what's wrong and how to fix it
10. **Include skip links** — Help keyboard users navigate efficiently

---

## Additional Resources

- **[WCAG 2.1 Guidelines](https://www.w3.org/WAI/WCAG21/quickref/)** — Official accessibility standards
- **[MDN Accessibility](https://developer.mozilla.org/en-US/docs/Web/Accessibility)** — Comprehensive web accessibility guide
- **[WebAIM](https://webaim.org/)** — Web accessibility articles and tools
- **[ARIA Authoring Practices](https://www.w3.org/WAI/ARIA/apg/)** — Official ARIA design patterns
- **[axe DevTools](https://www.deque.com/axe/devtools/)** — Browser extension for accessibility testing
- **[WAVE Tool](https://wave.webaim.org/)** — Website accessibility evaluation

---

**Congratulations!** You now have the knowledge to build professional, accessible Vue 3 applications with Vuetify. Remember: accessibility isn't a feature — it's a fundamental requirement for quality software.

**Next Steps:**
1. Review [Vuetify Components & Patterns](vuetify-components.md) for component-specific accessibility patterns
2. Check out the [Vue 3 Composition API](vue3-composition.md) guide for modern reactive patterns
3. Start building with accessibility in mind from day one
