# Vue 3 Composition API Guide

Master modern Vue 3 patterns with the Composition API. Learn reactive programming, composables, and performance optimization for professional, maintainable applications.

## Table of Contents

1. [Composition API Fundamentals](#composition-api-fundamentals)
2. [Reactive State Management](#reactive-state-management)
3. [Computed Properties](#computed-properties)
4. [Watchers and Effects](#watchers-and-effects)
5. [Custom Composables](#custom-composables)
6. [Lifecycle Hooks](#lifecycle-hooks)
7. [Template Refs](#template-refs)
8. [Async Operations](#async-operations)
9. [Performance Optimization](#performance-optimization)
10. [Common Patterns](#common-patterns)

---

## Composition API Fundamentals

The Composition API is Vue 3's modern way to organize component logic. Instead of organizing by option (data, methods, computed), you organize by feature.

### Why Use Composition API?

- **Better Code Organization**: Group related logic together
- **Easier Code Reuse**: Extract logic into composables
- **Better TypeScript Support**: Full type inference
- **Cleaner Scaling**: Large components remain manageable
- **No Magic**: Explicit data flow and dependencies

### Setup Function

The `<script setup>` syntax is the recommended way to use Composition API.

```vue
<template>
  <div>
    <p>Count: {{ count }}</p>
    <button @click="increment">Increment</button>
  </div>
</template>

<script setup lang="ts">
import { ref } from 'vue'

// All top-level bindings are automatically exposed to template
const count = ref(0)

const increment = () => {
  count.value++
}
</script>
```

Compare with Options API:

```vue
<!-- Options API (older approach) -->
<script>
export default {
  data() {
    return { count: 0 }
  },
  methods: {
    increment() {
      this.count++
    },
  },
}
</script>
```

---

## Reactive State Management

### ref() — Primitive Values

Use `ref()` to make primitive values reactive.

```vue
<template>
  <div>
    <p>Message: {{ message }}</p>
    <input v-model="message" />
    <p>Email: {{ email }}</p>
    <button @click="email = 'new@example.com'">Update Email</button>
  </div>
</template>

<script setup lang="ts">
import { ref } from 'vue'

// Primitive values wrapped in ref
const message = ref('')
const email = ref('user@example.com')
const count = ref(0)
const isActive = ref(false)

// In script, access value with .value
console.log(email.value) // 'user@example.com'
email.value = 'updated@example.com'

// In template, .value is automatically unwrapped
// {{ email }} is equivalent to {{ email.value }}
</script>
```

### reactive() — Objects

Use `reactive()` for objects and complex state.

```vue
<template>
  <div>
    <p>User: {{ user.name }} ({{ user.email }})</p>
    <input v-model="user.name" placeholder="Name" />
    <input v-model="user.email" placeholder="Email" />
    <p>Address: {{ user.address.city }}, {{ user.address.country }}</p>
  </div>
</template>

<script setup lang="ts">
import { reactive } from 'vue'

// Object wrapped in reactive
const user = reactive({
  name: 'John Doe',
  email: 'john@example.com',
  address: {
    street: '123 Main St',
    city: 'Springfield',
    country: 'USA',
  },
})

// Nested reactivity: update nested properties
user.address.city = 'Portland'

// ALL properties are reactive (no need for .value)
console.log(user.name)
user.name = 'Jane Doe'
</script>
```

### ref() vs reactive()

```typescript
// ref() - for primitives, but also works for objects
const count = ref(0)           // Good: primitive
const user = ref({})           // Works, but...
console.log(user.value.name)   // Need .value everywhere

// reactive() - for objects, no .value needed
const user = reactive({})
console.log(user.name)         // Clean: no .value

// Best practice:
// - Use ref() for primitives and when you need reassignment
// - Use reactive() for objects with many properties
// - Combine them in a pattern called "composition"

const user = ref<User | null>(null)  // Might be null
const settings = reactive({           // Complex object
  theme: 'dark',
  notifications: true,
})
```

### Reactive Destructuring with toRefs()

```vue
<template>
  <div>
    <input v-model="name" />
    <input v-model="email" />
  </div>
</template>

<script setup lang="ts">
import { reactive, toRefs } from 'vue'

// Define object
const user = reactive({
  name: 'John',
  email: 'john@example.com',
})

// Destructure while maintaining reactivity
const { name, email } = toRefs(user)

// Without toRefs, destructuring loses reactivity
// const { name, email } = user  //  Not reactive anymore

// toRefs creates refs from reactive properties
// name.value and email.value are the actual values
</script>
```

---

## Computed Properties

Derived state that updates automatically when dependencies change.

### Basic Computed

```vue
<template>
  <div>
    <p>First Name: {{ firstName }}</p>
    <p>Last Name: {{ lastName }}</p>
    <p>Full Name: {{ fullName }}</p>
  </div>
</template>

<script setup lang="ts">
import { ref, computed } from 'vue'

const firstName = ref('John')
const lastName = ref('Doe')

// Computed is read-only by default
// Automatically recalculates when dependencies change
const fullName = computed(() => {
  console.log('Computing fullName...') // Logs only when firstName or lastName changes
  return `${firstName.value} ${lastName.value}`
})

// In template: {{ fullName }} automatically unwraps .value
console.log(fullName.value) // 'John Doe'
</script>
```

### Computed with Getter and Setter

```vue
<template>
  <div>
    <p>Full Name: {{ fullName }}</p>
    <input v-model="fullName" placeholder="Enter full name" />
    <p>First: {{ firstName }} | Last: {{ lastName }}</p>
  </div>
</template>

<script setup lang="ts">
import { ref, computed } from 'vue'

const firstName = ref('John')
const lastName = ref('Doe')

// Computed with explicit getter and setter
const fullName = computed({
  get() {
    return `${firstName.value} ${lastName.value}`
  },
  set(newValue: string) {
    const [first, last] = newValue.split(' ')
    firstName.value = first
    lastName.value = last
  },
})

// Now you can assign to computed
fullName.value = 'Jane Smith'  // Calls the setter
console.log(firstName.value)   // 'Jane'
console.log(lastName.value)    // 'Smith'
</script>
```

### Computed Performance

```vue
<script setup lang="ts">
import { ref, computed } from 'vue'

const items = ref([
  { id: 1, price: 10, quantity: 2 },
  { id: 2, price: 20, quantity: 3 },
  { id: 3, price: 15, quantity: 1 },
])

// Computed caches result
// Only recalculates when items reference changes
// If you mutate items (add/remove), it WILL recalculate
const total = computed(() => {
  console.log('Recalculating total...')
  return items.value.reduce((sum, item) => sum + item.price * item.quantity, 0)
})

// Good: dependency is clear
const itemCount = computed(() => items.value.length)

// Avoid: external dependencies
const timestamp = computed(() => Date.now()) //  Recalculates on every dependency change

// Use watchers for side effects instead
// See next section...
</script>
```

---

## Watchers and Effects

Monitor reactive state and react to changes.

### watch() — Track Specific Values

```vue
<script setup lang="ts">
import { ref, watch } from 'vue'

const searchQuery = ref('')
const results = ref<string[]>([])
const isSearching = ref(false)

// Watch a single ref
watch(searchQuery, async (newValue, oldValue) => {
  console.log(`Search changed from "${oldValue}" to "${newValue}"`)
  
  if (newValue.length < 2) {
    results.value = []
    return
  }

  isSearching.value = true
  try {
    const response = await fetch(`/api/search?q=${newValue}`)
    results.value = await response.json()
  } finally {
    isSearching.value = false
  }
})

// Watch multiple values (tuple)
const firstName = ref('John')
const lastName = ref('Doe')

watch(
  [firstName, lastName],
  ([newFirst, newLast], [oldFirst, oldLast]) => {
    console.log(`Name changed from ${oldFirst} ${oldLast} to ${newFirst} ${newLast}`)
  }
)
</script>
```

### watch() with Options

```typescript
import { ref, watch } from 'vue'

const user = ref({ name: 'John', age: 30 })

// Deep watch: track nested property changes
watch(
  user,
  (newUser) => {
    console.log('User changed:', newUser)
  },
  { deep: true } // Enable deep watching
)

// Modify nested property
user.value.age = 31 // This will trigger the watch

// Immediate: run callback on first setup
watch(
  user,
  (newUser) => {
    console.log('Initial and on change:', newUser)
  },
  { immediate: true } // Runs immediately with current value
)

// Flush timing
watch(
  user,
  () => {
    console.log('Callback executed')
  },
  { flush: 'post' } // After component update (default)
  // flush: 'pre'  // Before component update
  // flush: 'sync' // Synchronously (rarely needed)
)
```

### watchEffect() — Automatic Dependency Tracking

```vue
<script setup lang="ts">
import { ref, watchEffect } from 'vue'

const firstName = ref('John')
const lastName = ref('Doe')
const fullName = ref('')

// watchEffect: automatically tracks all dependencies
// No need to explicitly list dependencies
watchEffect(() => {
  // This runs whenever firstName or lastName changes
  fullName.value = `${firstName.value} ${lastName.value}`
  console.log(`Full name is now: ${fullName.value}`)
})

// Equivalent to watch, but more concise for simple cases
// watch(
//   [firstName, lastName],
//   () => {
//     fullName.value = `${firstName.value} ${lastName.value}`
//   }
// )

// Stop watching manually
const stop = watchEffect(() => {
  console.log('Still watching:', firstName.value)
})

// Later, stop watching
stop()
</script>
```

### Cleanup in Watchers

```typescript
import { ref, watch } from 'vue'

const query = ref('')

watch(query, async (newQuery, oldQuery, onCleanup) => {
  let isActive = true

  // Register cleanup callback
  onCleanup(() => {
    isActive = false
    console.log('Previous request cancelled')
  })

  // Simulate API call
  const response = await fetch(`/api/search?q=${newQuery}`)
  
  // Only use response if not cleaned up
  if (isActive) {
    console.log('Using response:', response)
  }
})

// When query changes again, cleanup runs before new callback
// This prevents race conditions with async operations
```

---

## Custom Composables

Extract reusable logic into composable functions.

### Basic Composable Pattern

```typescript
// composables/useCounter.ts
import { ref, computed } from 'vue'

export const useCounter = (initialValue: number = 0) => {
  const count = ref(initialValue)

  const increment = () => count.value++
  const decrement = () => count.value--
  const reset = () => count.value = initialValue

  const isPositive = computed(() => count.value > 0)

  return {
    count,
    increment,
    decrement,
    reset,
    isPositive,
  }
}

// Usage in component
import { useCounter } from '@/composables/useCounter'

export default {
  setup() {
    const { count, increment, decrement } = useCounter(10)
    return { count, increment, decrement }
  },
}
```

### Composable with Lifecycle

```typescript
// composables/useFetch.ts
import { ref, readonly, onMounted } from 'vue'

export const useFetch = (url: string) => {
  const data = ref<any>(null)
  const error = ref<Error | null>(null)
  const isLoading = ref(false)

  const fetch = async () => {
    isLoading.value = true
    error.value = null
    try {
      const response = await window.fetch(url)
      if (!response.ok) throw new Error(`HTTP ${response.status}`)
      data.value = await response.json()
    } catch (err) {
      error.value = err instanceof Error ? err : new Error(String(err))
    } finally {
      isLoading.value = false
    }
  }

  // Auto-fetch on mount (optional)
  onMounted(() => fetch())

  return {
    data: readonly(data),
    error: readonly(error),
    isLoading: readonly(isLoading),
    fetch,
  }
}

// Usage
const { data: users, isLoading, error, fetch } = useFetch('/api/users')

// Manually trigger fetch
await fetch()
```

### Composable for Forms

```typescript
// composables/useForm.ts
import { ref, reactive, computed } from 'vue'

export interface FormOptions<T> {
  initialValues: T
  onSubmit: (values: T) => Promise<void>
}

export const useForm = <T extends Record<string, any>>({
  initialValues,
  onSubmit,
}: FormOptions<T>) => {
  const values = reactive<T>({ ...initialValues })
  const errors = reactive<Record<string, string>>({})
  const touched = reactive<Record<string, boolean>>({})
  const isSubmitting = ref(false)

  const isDirty = computed(() => {
    return Object.entries(values).some(
      ([key, value]) => value !== initialValues[key as keyof T]
    )
  })

  const isValid = computed(() => Object.keys(errors).length === 0)

  const setFieldError = (field: keyof T, message: string) => {
    errors[field as string] = message
  }

  const clearFieldError = (field: keyof T) => {
    delete errors[field as string]
  }

  const setFieldTouched = (field: keyof T) => {
    touched[field as string] = true
  }

  const setValues = (newValues: Partial<T>) => {
    Object.assign(values, newValues)
  }

  const reset = () => {
    Object.assign(values, initialValues)
    Object.keys(errors).forEach(key => delete errors[key])
    Object.keys(touched).forEach(key => delete touched[key])
  }

  const submit = async () => {
    isSubmitting.value = true
    try {
      await onSubmit(values)
    } finally {
      isSubmitting.value = false
    }
  }

  return {
    values,
    errors,
    touched,
    isDirty,
    isValid,
    isSubmitting,
    setFieldError,
    clearFieldError,
    setFieldTouched,
    setValues,
    reset,
    submit,
  }
}

// Usage
const { values, errors, submit, reset } = useForm({
  initialValues: { email: '', password: '' },
  async onSubmit(values) {
    await api.login(values)
  },
})
```

### Composable with Local Storage

```typescript
// composables/useLocalStorage.ts
import { ref, watch, Ref } from 'vue'

export const useLocalStorage = <T>(key: string, initialValue: T): Ref<T> => {
  // Try to load from localStorage
  const stored = localStorage.getItem(key)
  const data = ref<T>(stored ? JSON.parse(stored) : initialValue)

  // Watch for changes and update localStorage
  watch(
    data,
    (newValue) => {
      localStorage.setItem(key, JSON.stringify(newValue))
    },
    { deep: true }
  )

  return data
}

// Usage
const theme = useLocalStorage('theme', 'light')
theme.value = 'dark' // Automatically saved to localStorage
```

---

## Lifecycle Hooks

Execute code at specific points in component lifecycle.

### Common Lifecycle Hooks

```vue
<script setup lang="ts">
import {
  onBeforeMount,
  onMounted,
  onBeforeUpdate,
  onUpdated,
  onBeforeUnmount,
  onUnmounted,
} from 'vue'

// Before component is mounted to DOM
onBeforeMount(() => {
  console.log('Component about to be mounted')
})

// After component is mounted to DOM
onMounted(() => {
  console.log('Component mounted')
  // Fetch data, start timers, etc.
})

// Before re-render due to reactive state change
onBeforeUpdate(() => {
  console.log('Component about to update')
})

// After re-render
onUpdated(() => {
  console.log('Component updated')
})

// Before component is removed from DOM
onBeforeUnmount(() => {
  console.log('Component about to unmount')
})

// After component is removed from DOM
onUnmounted(() => {
  console.log('Component unmounted')
  // Clean up timers, listeners, etc.
})
</script>
```

### Lifecycle Example: Timer

```vue
<template>
  <div>
    <p>Elapsed: {{ elapsed }}s</p>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted, onUnmounted } from 'vue'

const elapsed = ref(0)
let intervalId: number | null = null

onMounted(() => {
  intervalId = window.setInterval(() => {
    elapsed.value++
  }, 1000)
  console.log('Timer started')
})

onUnmounted(() => {
  if (intervalId) {
    clearInterval(intervalId)
    intervalId = null
  }
  console.log('Timer stopped')
})
</script>
```

### Lifecycle Example: Event Listeners

```typescript
import { onMounted, onUnmounted } from 'vue'

const handleResize = () => {
  console.log('Window resized:', window.innerWidth)
}

onMounted(() => {
  window.addEventListener('resize', handleResize)
})

onUnmounted(() => {
  window.removeEventListener('resize', handleResize)
})
```

---

## Template Refs

Access DOM elements directly.

### Basic Template Ref

```vue
<template>
  <div>
    <input ref="inputElement" type="text" />
    <button @click="focusInput">Focus Input</button>
    <button @click="getInputValue">Get Value</button>
  </div>
</template>

<script setup lang="ts">
import { ref } from 'vue'

// Create ref to access DOM element
const inputElement = ref<HTMLInputElement | null>(null)

const focusInput = () => {
  // Access DOM element via .value
  inputElement.value?.focus()
}

const getInputValue = () => {
  if (inputElement.value) {
    console.log('Input value:', inputElement.value.value)
  }
}
</script>
```

### Component Refs

```vue
<!-- Child component: Counter.vue -->
<template>
  <div>
    <p>Count: {{ count }}</p>
  </div>
</template>

<script setup lang="ts">
import { ref } from 'vue'

const count = ref(0)

const increment = () => count.value++
const reset = () => count.value = 0

// Expose methods for parent to call
defineExpose({ increment, reset, count })
</script>

<!-- Parent component -->
<template>
  <div>
    <Counter ref="counterRef" />
    <button @click="callChildMethod">Call Child Method</button>
  </div>
</template>

<script setup lang="ts">
import { ref } from 'vue'
import Counter from './Counter.vue'

const counterRef = ref<InstanceType<typeof Counter> | null>(null)

const callChildMethod = () => {
  counterRef.value?.increment()
}
</script>
```

### Multiple Element Refs

```vue
<template>
  <div>
    <input v-for="i in 3" :key="i" ref="inputs" type="text" />
    <button @click="focusAll">Focus All</button>
  </div>
</template>

<script setup lang="ts">
import { ref } from 'vue'

// Ref bound in loop collects all elements into an array
const inputs = ref<HTMLInputElement[]>([])

const focusAll = () => {
  inputs.value.forEach(input => input.focus())
}
</script>
```

---

## Async Operations

Handling promises and API calls in Composition API.

### Basic Async in Composable

```typescript
import { ref } from 'vue'

export const useFetchUser = (userId: number) => {
  const user = ref<any>(null)
  const loading = ref(false)
  const error = ref<string | null>(null)

  const fetchUser = async () => {
    loading.value = true
    error.value = null
    try {
      const response = await fetch(`/api/users/${userId}`)
      if (!response.ok) throw new Error('Failed to fetch user')
      user.value = await response.json()
    } catch (err) {
      error.value = err instanceof Error ? err.message : 'Unknown error'
    } finally {
      loading.value = false
    }
  }

  return { user, loading, error, fetchUser }
}
```

### Async in Component

```vue
<template>
  <div>
    <p v-if="loading">Loading...</p>
    <p v-else-if="error" class="error">{{ error }}</p>
    <div v-else>
      <h2>{{ user?.name }}</h2>
      <p>{{ user?.email }}</p>
    </div>
  </div>
</template>

<script setup lang="ts">
import { useFetchUser } from '@/composables/useFetchUser'
import { onMounted } from 'vue'

const { user, loading, error, fetchUser } = useFetchUser(1)

onMounted(() => {
  fetchUser()
})
</script>
```

### Handling Race Conditions

```typescript
import { ref, watch } from 'vue'

export const useSearch = () => {
  const query = ref('')
  const results = ref<any[]>([])
  const loading = ref(false)

  watch(query, async (newQuery, oldQuery, onCleanup) => {
    if (!newQuery) {
      results.value = []
      return
    }

    loading.value = true
    let isActive = true

    // Cleanup: mark as inactive if component unmounts or query changes
    onCleanup(() => {
      isActive = false
    })

    try {
      const response = await fetch(`/api/search?q=${newQuery}`)
      const data = await response.json()

      // Only use result if request is still active
      if (isActive) {
        results.value = data
      }
    } finally {
      if (isActive) {
        loading.value = false
      }
    }
  })

  return { query, results, loading }
}
```

---

## Performance Optimization

### Lazy Load Composables

```typescript
// Don't import all composables at top
import { ref } from 'vue'

export const useLazyData = async () => {
  // Heavy computation or import happens on-demand
  const { complexCalculation } = await import('./heavyModule')
  return {
    result: ref(complexCalculation()),
  }
}

// Usage
const { result } = await useLazyData()
```

### Memoization with Computed

```typescript
import { ref, computed } from 'vue'

const items = ref([1, 2, 3, 4, 5])

// Expensive computation
const doubled = computed(() => {
  console.log('Computing doubled...')
  return items.value.map(n => n * 2)
})

// Memoized: only recalculates when items changes
doubled.value // Logs "Computing doubled..."
doubled.value // Uses cached result (no log)
items.value = [1, 2, 3, 4, 5] // Same content, same reference
doubled.value // Uses cached result (no log)
```

### Shallow Refs for Large Objects

```typescript
import { shallowRef } from 'vue'

const largeObject = shallowRef({
  data: /* huge data structure */
})

// Vue only tracks reference change, not nested changes
// Efficient for large objects that don't change frequently
largeObject.value = { data: newData } // Triggers update
largeObject.value.data.prop = 'new' // Does NOT trigger update
```

### Unref for Flexible Parameters

```typescript
import { ref, unref, isRef } from 'vue'

export const useDoubleValue = (value: any) => {
  // unref extracts value from ref or returns as-is
  const resolved = unref(value)
  return resolved * 2
}

useDoubleValue(5)        // 10
useDoubleValue(ref(5))   // 10 (unref extracts the 5)
```

---

## Common Patterns

### Modal/Dialog Composable

```typescript
// composables/useModal.ts
import { ref } from 'vue'

export const useModal = () => {
  const isOpen = ref(false)

  const open = () => {
    isOpen.value = true
  }

  const close = () => {
    isOpen.value = false
  }

  return { isOpen, open, close }
}

// Usage
const { isOpen, open, close } = useModal()
```

### Toggle Composable

```typescript
// composables/useToggle.ts
import { ref } from 'vue'

export const useToggle = (initialValue: boolean = false) => {
  const value = ref(initialValue)

  const toggle = () => {
    value.value = !value.value
  }

  const setTrue = () => {
    value.value = true
  }

  const setFalse = () => {
    value.value = false
  }

  return { value, toggle, setTrue, setFalse }
}

// Usage
const { value: isDarkMode, toggle: toggleDarkMode } = useToggle()
```

### Throttle/Debounce

```typescript
// composables/useDebounce.ts
import { ref, watch } from 'vue'

export const useDebounce = <T>(value: Ref<T>, delay: number = 300): Ref<T> => {
  const debouncedValue = ref<T>(value.value)
  let timeout: NodeJS.Timeout

  watch(value, (newValue) => {
    clearTimeout(timeout)
    timeout = setTimeout(() => {
      debouncedValue.value = newValue
    }, delay)
  })

  return debouncedValue
}

// Usage
const searchQuery = ref('')
const debouncedQuery = useDebounce(searchQuery, 500)

watch(debouncedQuery, (query) => {
  // API call with debounced query
})
```

### Keyboard Shortcuts

```typescript
// composables/useKeyboard.ts
import { onMounted, onUnmounted } from 'vue'

export const useKeyboard = (key: string, callback: () => void) => {
  const handler = (event: KeyboardEvent) => {
    if (event.key === key) {
      callback()
    }
  }

  onMounted(() => {
    window.addEventListener('keydown', handler)
  })

  onUnmounted(() => {
    window.removeEventListener('keydown', handler)
  })
}

// Usage
useKeyboard('Escape', () => closeModal())
useKeyboard('Enter', () => submit())
```

### Responsive/Breakpoint Detection

```typescript
// composables/useBreakpoint.ts
import { ref, onMounted, onUnmounted } from 'vue'

export const useBreakpoint = () => {
  const width = ref(0)
  const isMobile = ref(false)
  const isTablet = ref(false)
  const isDesktop = ref(false)

  const updateBreakpoint = () => {
    width.value = window.innerWidth
    isMobile.value = width.value < 600
    isTablet.value = width.value >= 600 && width.value < 1024
    isDesktop.value = width.value >= 1024
  }

  onMounted(() => {
    updateBreakpoint()
    window.addEventListener('resize', updateBreakpoint)
  })

  onUnmounted(() => {
    window.removeEventListener('resize', updateBreakpoint)
  })

  return { width, isMobile, isTablet, isDesktop }
}

// Usage
const { isMobile, isTablet, isDesktop } = useBreakpoint()
```

---

## Type-Safe Composables

### Generic Composable

```typescript
// composables/useList.ts
export const useList = <T extends { id: string | number }>(
  initialItems: T[] = []
) => {
  const items = ref<T[]>(initialItems)

  const add = (item: T) => {
    items.value.push(item)
  }

  const remove = (id: T['id']) => {
    const index = items.value.findIndex(item => item.id === id)
    if (index > -1) {
      items.value.splice(index, 1)
    }
  }

  const update = (id: T['id'], updates: Partial<T>) => {
    const item = items.value.find(item => item.id === id)
    if (item) {
      Object.assign(item, updates)
    }
  }

  return { items, add, remove, update }
}

// Usage with type
interface User {
  id: number
  name: string
  email: string
}

const { items: users, add, remove } = useList<User>([
  { id: 1, name: 'John', email: 'john@example.com' },
])
```

---

## Best Practices

1. **Use `<script setup>`** — Simpler, cleaner syntax
2. **Extract composables** — Keep components focused
3. **Type everything** — Leverage TypeScript for safety
4. **Use readonly()** — Prevent accidental mutations
5. **Clean up in lifecycle** — Remove listeners and timers
6. **Avoid deep watches** — Use specific refs instead
7. **Combine with Vuetify** — Use composables with Vuetify components
8. **Test composables** — They're just functions, easy to test

---

**Next:** Learn [Accessibility & UX Best Practices](accessibility-ux.md) to build inclusive, professional interfaces.
