---
name: add-form
description: Add a Vuetify form with validation to a Vue 3 component using VeeValidate or Vuetify's built-in validation
---

# Add Form Skill

Add a validated Vuetify form to an existing or new Vue 3 component, including field definitions, validation rules, submission handling, and error display.

## When to Use

Invoke this skill when you need to:
- Add a create/edit form for a domain entity
- Add a search or filter form
- Add a settings or preferences form with validation
- Convert an unvalidated form to one with proper error handling

## Required Information

Provide:
1. **Fields** — names, types (`text`, `number`, `date`, `select`, `checkbox`), and validation rules
2. **Submit action** — what happens on successful submission (API call, event emit, navigation)
3. **Validation approach** — Vuetify built-in rules or VeeValidate

## Vuetify Built-In Validation Pattern

```vue
<template>
  <v-form ref="form" @submit.prevent="handleSubmit">
    <v-text-field
      v-model="formData.name"
      label="Name"
      :rules="[rules.required, rules.maxLength(255)]"
      required
    />

    <v-select
      v-model="formData.status"
      label="Status"
      :items="statusOptions"
      :rules="[rules.required]"
    />

    <v-btn type="submit" color="primary" :loading="isSubmitting">
      Save
    </v-btn>
    <v-btn variant="text" @click="handleCancel">Cancel</v-btn>
  </v-form>
</template>

<script setup lang="ts">
import { ref, reactive } from 'vue'
import type { VForm } from 'vuetify/components'

const form = ref<InstanceType<typeof VForm>>()
const isSubmitting = ref(false)

const formData = reactive({
  name: '',
  status: null as string | null,
})

const rules = {
  required: (v: unknown) => !!v || 'This field is required',
  maxLength: (max: number) => (v: string) =>
    (v?.length ?? 0) <= max || `Must be ${max} characters or fewer`,
  email: (v: string) => /.+@.+\..+/.test(v) || 'Must be a valid email',
}

const statusOptions = ['Active', 'Inactive', 'Pending']

async function handleSubmit() {
  const { valid } = await form.value!.validate()
  if (!valid) return

  isSubmitting.value = true
  try {
    // TODO: call API or emit event
    emit('saved', formData)
  } finally {
    isSubmitting.value = false
  }
}

function handleCancel() {
  form.value?.reset()
  emit('cancelled')
}

const emit = defineEmits<{
  saved: [data: typeof formData]
  cancelled: []
}>()
</script>
```

## Validation Rules Reference

| Rule | Pattern |
|------|---------|
| Required | `v => !!v \|\| 'Required'` |
| Min length | `v => v.length >= n \|\| 'Min n chars'` |
| Max length | `v => v.length <= n \|\| 'Max n chars'` |
| Email | `v => /.+@.+\..+/.test(v) \|\| 'Invalid email'` |
| Numeric range | `v => (v >= min && v <= max) \|\| 'Out of range'` |

## UX Guidelines

- Show validation errors only after the user has interacted with a field (`validate-on="blur"`)
- Disable the submit button only while submitting (`loading` prop), not while the form is invalid
- Display a top-level error alert for server-side errors
- Reset the form on cancel with `form.value?.reset()`
- Use `v-btn type="submit"` to enable native form submission (Enter key support)
