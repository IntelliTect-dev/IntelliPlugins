---
name: use-composition-api
description: Build Vue 3 components using the Composition API with TypeScript and Vuetify
---

# Use Composition API Skill

Build Vue 3 SFCs using the Composition API with TypeScript — reactive state, composables, lifecycle hooks.

## When to Use

- Building a new Vue 3 component
- Refactoring an Options API component to Composition API
- Implementing custom composables for shared logic

## Core Patterns

### ref() vs reactive()

```typescript
const count = ref(0)           // primitives, nullable refs
const settings = reactive({    // objects with many properties
  theme: 'dark',
  notifications: true,
})
```

### computed()

```typescript
const fullName = computed(() => `${firstName.value} ${lastName.value}`)
```

### watch()

```typescript
watch(searchQuery, async (newVal) => {
  results.value = await fetchResults(newVal)
})
```

### Custom Composable

```typescript
export function useItems() {
  const items = ref<Item[]>([])
  const isLoading = ref(false)
  const error = ref<Error | null>(null)

  async function load() {
    isLoading.value = true
    try {
      items.value = await api.getItems()
    } catch (e) {
      error.value = e instanceof Error ? e : new Error(String(e))
    } finally {
      isLoading.value = false
    }
  }

  return { items: readonly(items), isLoading: readonly(isLoading), error: readonly(error), load }
}
```

### Lifecycle Hooks

```typescript
onMounted(() => load())
onUnmounted(() => cleanup())
```

## Guidelines

- Prefer `ref()` for primitives; `reactive()` for complex objects
- Expose readonly state from composables to prevent external mutation
- Clean up watchers and listeners in `onUnmounted`
- Name composables `useXxx`

## Reference

- [Vue 3 Composition API docs](https://vuejs.org/guide/extras/composition-api-faq.html)
- [Composables guide](https://vuejs.org/guide/reusability/composables.html)
