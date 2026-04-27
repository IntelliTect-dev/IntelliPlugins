---
name: scaffold-component
description: Scaffold a new Vuetify Vue 3 component using the Composition API with proper structure, props, emits, and accessibility
---

# Scaffold Component Skill

Generate a well-structured Vuetify Vue 3 single-file component (SFC) using the Composition API, following accessibility and UX best practices.

## When to Use

Invoke this skill when you need to:
- Create a new reusable UI component
- Add a page-level component that wraps Vuetify layout components
- Build a data display component (table, card, list)
- Create a modal or dialog component

## Required Information

Before scaffolding, provide:
1. **Component name** — PascalCase (e.g., `UserCard`, `InvoiceTable`, `ConfirmDialog`)
2. **Component purpose** — what data it displays or action it performs
3. **Props** — inputs from parent (names, types, whether required)
4. **Emits** — events the component raises to parent (e.g., `update:modelValue`, `confirm`)

## SFC Structure

```vue
<template>
  <v-card>
    <!-- Vuetify components here -->
    <v-card-title>{{ title }}</v-card-title>
    <v-card-text>
      <slot />
    </v-card-text>
  </v-card>
</template>

<script setup lang="ts">
// Props
const props = defineProps<{
  title: string
  loading?: boolean
}>()

// Emits
const emit = defineEmits<{
  close: []
  save: [value: string]
}>()

// Composables
const { t } = useI18n()  // if i18n is used

// Reactive state
const internalValue = ref('')

// Computed
const isValid = computed(() => internalValue.value.length > 0)

// Methods
function handleAction() {
  emit('save', internalValue.value)
}
</script>
```

## Accessibility Requirements

- Always use semantic Vuetify components (`v-btn` over `div` for buttons)
- Provide `aria-label` on icon-only buttons:
  ```html
  <v-btn icon="mdi-close" aria-label="Close dialog" @click="emit('close')" />
  ```
- Use `v-tooltip` to add tooltips for icon actions
- Ensure keyboard navigation works (Vuetify handles most of this automatically)
- Color alone must not convey meaning — pair with text or icon

## File Placement

Place the component in the appropriate directory:
- Reusable components → `src/components/`
- Page-level components → `src/views/`
- Domain-specific components → `src/components/{domain}/`

## Notes

- Use `<script setup lang="ts">` — not Options API
- Prefer `defineProps<T>()` with TypeScript generics over `withDefaults`
- Use `v-model` with `defineModel()` for two-way binding components (Vue 3.4+)
