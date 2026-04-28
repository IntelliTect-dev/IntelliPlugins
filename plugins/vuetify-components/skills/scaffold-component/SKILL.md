---
name: scaffold-component
description: Scaffold a new Vuetify Vue 3 component using the Composition API with proper structure, props, emits, and accessibility
---

# Scaffold Component Skill

Generate a well-structured Vuetify Vue 3 SFC using the Composition API.

## When to Use

- Create a new reusable UI component
- Add a page-level component wrapping Vuetify layout components
- Build a data display component (table, card, list)
- Create a modal or dialog component

## Required Information

1. **Component name** — PascalCase (e.g., `UserCard`, `InvoiceTable`, `ConfirmDialog`)
2. **Component purpose** — what data it displays or action it performs
3. **Props** — inputs from parent (names, types, required vs optional)
4. **Emits** — events raised to parent (e.g., `update:modelValue`, `confirm`)

## SFC Structure

```vue
<template>
  <v-card>
    <v-card-title>{{ title }}</v-card-title>
    <v-card-text>
      <slot />
    </v-card-text>
  </v-card>
</template>

<script setup lang="ts">
const props = defineProps<{
  title: string
  loading?: boolean
}>()

const emit = defineEmits<{
  close: []
  save: [value: string]
}>()

const internalValue = ref('')
const isValid = computed(() => internalValue.value.length > 0)

function handleAction() {
  emit('save', internalValue.value)
}
</script>
```

## Accessibility Requirements

- Use semantic Vuetify components (`v-btn` not `div` for buttons)
- Provide `aria-label` on icon-only buttons: `<v-btn icon="mdi-close" aria-label="Close dialog" />`
- Color alone must not convey meaning — pair with text or icon

## File Placement

- Reusable → `src/components/`
- Page-level → `src/views/`
- Domain-specific → `src/components/{domain}/`

## Notes

- Use `<script setup lang="ts">` — not Options API
- Prefer `defineProps<T>()` TypeScript generics over `withDefaults`
- Use `defineModel()` for two-way binding (Vue 3.4+)

## Reference

- [Vuetify Component API](https://vuetifyjs.com/en/components/all/) — full props, slots, events for all components
- [Vue 3 SFC docs](https://vuejs.org/guide/scaling-up/sfc.html)
