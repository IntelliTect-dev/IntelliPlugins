# Vuetify Components & Patterns Plugin

Professional Vue 3 and Vuetify best practices for building enterprise-grade UI components with accessibility, responsive design, and UX consistency at the core.

## Overview

This plugin provides comprehensive guidance on leveraging Vuetify 3 and Vue 3's Composition API to create professional, accessible, and maintainable user interfaces. It combines real-world patterns with WCAG accessibility standards and enterprise UX principles.

## What This Plugin Covers

### Vue 3 & Composition API

- Modern reactive patterns using `ref()`, `reactive()`, and `computed()`
- Watch and watchers for side effects
- Custom composables for code reuse
- Lifecycle hooks in Composition API
- Performance optimization techniques

### Vuetify Component Library

- **Layout Components**: VContainer, VRow, VCol, VSheet, VNavigationDrawer, VAppBar
- **Data Display**: VDataTable, VList, VCard, VChip
- **Form Components**: VTextField, VSelect, VCheckbox, VRadio, VSwitch, VDatePicker
- **Dialog & Menu Patterns**: VDialog, VMenu, VBottomSheet
- **Typography & Icons**: Text hierarchy, icon usage, semantic HTML
- **Theming & Customization**: Light/dark modes, color palettes, custom themes

### Professional Component Development

- Component composition and nesting
- Prop design and slot patterns
- State management with `v-model`
- Error handling and validation
- Loading states and skeletons
- Responsive breakpoint strategies

### Accessibility & UX

- Web Accessibility (WCAG) standards
- Semantic HTML structure
- ARIA attributes and roles
- Keyboard navigation and focus management
- Color contrast and visual clarity
- Form accessibility with proper labels and error messages
- Screen reader support
- Testing accessibility with axe-core

## Why Professional Vuetify Matters

Using Vuetify properly ensures:

- **Consistent UX**: Material Design principles across your entire application
- **Accessibility**: WCAG compliance out of the box, extended with best practices
- **Maintainability**: Clear component patterns reduce technical debt
- **Productivity**: Pre-built components let you focus on business logic
- **Professionalism**: Enterprise-grade UI that builds customer confidence
- **Performance**: Optimized rendering with Vue 3 reactivity

## Quick Start

### Installation

Install this plugin to your Copilot CLI:

```bash
copilot plugin install vuetify-components@IntelliPlugins
```

### Common Component Patterns

#### Text Input with Validation

```vue
<template>
  <VTextField
    v-model="email"
    type="email"
    label="Email Address"
    :rules="[required, validEmail]"
    :error-messages="validationErrors"
    hint="We'll never share your email"
    persistent-hint
    outlined
    dense
  />
</template>

<script setup lang="ts">
import { ref } from "vue";

const email = ref("");
const validationErrors = ref<string[]>([]);

const required = (value: string) => !!value || "Email is required";
const validEmail = (value: string) =>
  !value || /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(value) || "Email must be valid";
</script>
```

#### Data Table with Sorting and Pagination

```vue
<template>
  <VDataTable
    :items="users"
    :headers="headers"
    :search="search"
    :loading="isLoading"
    item-key="id"
    class="elevation-1"
  >
    <template #top>
      <VToolbar flat>
        <VToolbarTitle>Users</VToolbarTitle>
        <VDivider class="mx-4" inset vertical />
        <VTextField
          v-model="search"
          label="Search"
          prepend-icon="mdi-magnify"
          single-line
          hide-details
        />
      </VToolbar>
    </template>

    <template #[`item.actions`]="{ item }">
      <VIconButton icon="mdi-pencil" @click="editUser(item)" />
      <VIconButton icon="mdi-delete" @click="deleteUser(item)" />
    </template>
  </VDataTable>
</template>

<script setup lang="ts">
import { ref } from "vue";

interface User {
  id: number;
  name: string;
  email: string;
}

const users = ref<User[]>([]);
const search = ref("");
const isLoading = ref(false);

const headers = [
  { title: "Name", value: "name" },
  { title: "Email", value: "email" },
  { title: "Actions", value: "actions", sortable: false },
];

const editUser = (user: User) => {
  // Handle edit
};

const deleteUser = (user: User) => {
  // Handle delete
};
</script>
```

#### Dialog with Form Submission

```vue
<template>
  <VDialog v-model="isOpen" max-width="500">
    <template #activator="{ props }">
      <VBtn v-bind="props" color="primary">Create Item</VBtn>
    </template>

    <VCard>
      <VCardTitle>Create New Item</VCardTitle>

      <VCardText>
        <VForm ref="form" @submit.prevent="submit">
          <VTextField
            v-model="formData.title"
            label="Title"
            :rules="[required]"
            required
          />
          <VTextarea
            v-model="formData.description"
            label="Description"
            :rules="[required]"
            required
          />
        </VForm>
      </VCardText>

      <VCardActions>
        <VSpacer />
        <VBtn @click="isOpen = false">Cancel</VBtn>
        <VBtn color="primary" @click="submit">Create</VBtn>
      </VCardActions>
    </VCard>
  </VDialog>
</template>

<script setup lang="ts">
import { ref } from "vue";

interface FormData {
  title: string;
  description: string;
}

const isOpen = ref(false);
const form = ref<any>();
const formData = ref<FormData>({ title: "", description: "" });

const required = (value: string) => !!value || "This field is required";

const submit = async () => {
  const { valid } = await form.value?.validate();
  if (!valid) return;

  try {
    // Submit to API
    console.log("Submitting:", formData.value);
    isOpen.value = false;
    // Reset form
    formData.value = { title: "", description: "" };
  } catch (error) {
    console.error("Submission failed:", error);
  }
};
</script>
```

#### Responsive Layout with Navigation

```vue
<template>
  <VApp>
    <VAppBar color="primary" dark>
      <VAppBarNavIcon @click="drawer = !drawer" />
      <VAppBarTitle>My App</VAppBarTitle>
    </VAppBar>

    <VNavigationDrawer v-model="drawer" rail>
      <VNavigation>
        <VListItem v-for="item in menuItems" :key="item.title" :to="item.path">
          <template #prepend>
            <VIcon :icon="item.icon" />
          </template>
          <VListItemTitle>{{ item.title }}</VListItemTitle>
        </VListItem>
      </VNavigation>
    </VNavigationDrawer>

    <VMain>
      <RouterView />
    </VMain>
  </VApp>
</template>

<script setup lang="ts">
import { ref } from "vue";

const drawer = ref(false);

const menuItems = [
  { title: "Dashboard", path: "/", icon: "mdi-home" },
  { title: "Users", path: "/users", icon: "mdi-account-multiple" },
  { title: "Settings", path: "/settings", icon: "mdi-cog" },
];
</script>
```

#### Composable for API Calls

```typescript
import { ref, readonly } from "vue";

export const useFetch = (url: string) => {
  const data = ref<any>(null);
  const isLoading = ref(false);
  const error = ref<Error | null>(null);

  const fetch = async () => {
    isLoading.value = true;
    error.value = null;
    try {
      const response = await window.fetch(url);
      if (!response.ok) throw new Error(`HTTP ${response.status}`);
      data.value = await response.json();
    } catch (err) {
      error.value = err instanceof Error ? err : new Error(String(err));
    } finally {
      isLoading.value = false;
    }
  };

  return {
    data: readonly(data),
    isLoading: readonly(isLoading),
    error: readonly(error),
    fetch,
  };
};

// Usage in component:
// const { data: users, isLoading, error, fetch } = useFetch('/api/users')
// onMounted(() => fetch())
```

## Key Documentation Files

### [Vuetify Components & Patterns](instructions/vuetify-components.md)

Detailed reference for all major Vuetify components, layout systems, theming, and composition strategies. This is your go-to guide for component-specific patterns and best practices.

### [Vue 3 Composition API](instructions/vue3-composition.md)

Modern Vue 3 reactive patterns, composables, lifecycle hooks, and performance optimization. Master the Composition API for cleaner, more reusable component code.

### [Accessibility & UX Best Practices](instructions/accessibility-ux.md)

WCAG compliance, semantic HTML, ARIA attributes, keyboard navigation, and inclusive design. Build UIs that work for everyone.

## Related Plugins

- **[SOLID Principles & Architecture](https://upgraded-dollop-mvkkwvo.pages.github.io/plugins/solid-principles)** — Enterprise code quality and design patterns to structure your Vue applications professionally
- **[Coalesce Accelerator](https://upgraded-dollop-mvkkwvo.pages.github.io/plugins/coalesce-accelerator)** — Full-stack data access patterns that complement your Vue UI

## Vuetify Documentation

For the authoritative Vuetify reference:

- **[Vuetify 3 Official Docs](https://vuetifyjs.com/)** — Complete component API reference
- **[Material Design Guidelines](https://material.io/design)** — Design principles behind Vuetify components
- **[Vue 3 Official Docs](https://vuejs.org/)** — Comprehensive Vue 3 guide

## Component Categories

### Layout & Structure

- VApp, VAppBar, VNavigationDrawer, VContainer, VRow, VCol
- VSheet, VMain, VFooter
- Grid system and responsive breakpoints

### Data Display

- VDataTable, VDataTableVirtual (large datasets)
- VList, VListItem, VListGroup
- VCard, VCardText, VCardActions
- VChip, VAvatar, VProgressLinear

### User Input

- VTextField, VTextarea, VSelect, VAutocomplete
- VCheckbox, VSwitch, VRadio, VRadioGroup
- VSlider, VRangeSlider, VCombobox
- VDatePicker, VTimePicker, VColorPicker

### Dialogs & Overlays

- VDialog, VMenu, VBottomSheet
- VTooltip, VPopover
- VSnackbar for notifications

### Navigation

- VTabs, VBreadcrumbs, VPagination
- VPaginationGroup

### Feedback

- VAlert, VBanner
- VProgressLinear, VProgressCircular
- VSkeletonLoader
- VSnackbar, VSpeedDial

## Best Practices Summary

1. **Always prioritize accessibility** — WCAG compliance isn't optional
2. **Use Composition API** — Modern, cleaner, more maintainable code
3. **Extract custom composables** — Reuse logic across components
4. **Validate early and often** — User input should be validated with clear feedback
5. **Design for responsive** — Mobile-first approach with proper breakpoints
6. **Test accessibility** — Use axe-core for automated accessibility testing
7. **Keep components focused** — Single responsibility makes them easier to maintain
8. **Document your components** — Props, slots, and events should be clear
9. **Manage state consistently** — Use `v-model`, `ref()`, and `computed()` appropriately
10. **Consider performance** — Use lazy loading, virtual scrolling for large datasets

## Example Project Structure

```
src/
├── components/
│   ├── common/
│   │   ├── AppBar.vue
│   │   ├── NavigationDrawer.vue
│   │   └── Dialogs.vue
│   ├── features/
│   │   ├── UserTable.vue
│   │   ├── UserForm.vue
│   │   └── UserDialog.vue
│   └── shared/
│       ├── LoadingSpinner.vue
│       ├── ErrorAlert.vue
│       └── ConfirmDialog.vue
├── composables/
│   ├── useFetch.ts
│   ├── useForm.ts
│   ├── useDialog.ts
│   └── useLocalStorage.ts
├── types/
│   ├── user.ts
│   ├── api.ts
│   └── form.ts
└── styles/
    ├── variables.ts
    ├── theme.ts
    └── breakpoints.ts
```

## Contributing

This plugin is part of the IntelliPlugins marketplace. For updates and improvements, visit the [GitHub repository](https://github.com/IntelliTect-dev/IntelliPlugins).

## License

MIT License — See LICENSE file in repository

---

**Ready to build accessible, professional Vue 3 applications?** Start with the [Vuetify Components & Patterns guide](instructions/vuetify-components.md).
