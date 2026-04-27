# Vuetify Components & Patterns Guide

Comprehensive reference for building professional user interfaces with Vuetify 3 and Vue 3. This guide covers component patterns, layout systems, theming, and composition strategies.

## Table of Contents

1. [Component Overview](#component-overview)
2. [Layout System](#layout-system)
3. [Data Display Components](#data-display-components)
4. [Form Components](#form-components)
5. [Dialog & Menu Patterns](#dialog--menu-patterns)
6. [Typography & Icons](#typography--icons)
7. [Theming & Customization](#theming--customization)
8. [Component Composition](#component-composition)
9. [Props & Slots](#props--slots)
10. [Advanced Patterns](#advanced-patterns)

---

## Component Overview

Vuetify provides a comprehensive Material Design component library. All components follow Material Design 3 specifications and integrate seamlessly with Vue 3.

### Component Principles

- **Material Design**: All components follow Google's Material Design guidelines
- **Accessibility**: Built with WCAG accessibility in mind (extend with best practices)
- **Responsive**: Mobile-first, responsive by default across all breakpoints
- **Customizable**: Props, slots, and CSS for deep customization
- **Performant**: Optimized rendering and lifecycle management

### Core Imports

```typescript
import { VApp, VAppBar, VContainer, VRow, VCol } from 'vuetify/components'
import { computed, ref } from 'vue'
```

---

## Layout System

### Container & Grid

The Vuetify grid system is based on CSS Grid and provides a responsive 12-column layout.

#### VContainer

Wraps your layout in a responsive container with consistent margins.

```vue
<template>
  <VContainer>
    <!-- Your content -->
  </VContainer>
</template>

<!-- Props -->
<VContainer
  :fluid="false"          <!-- Full width on all breakpoints -->
  tag="section"           <!-- HTML tag to render -->
  class="py-8"            <!-- Custom spacing classes -->
>
  <!-- Content -->
</VContainer>
```

**Usage Guidelines**:
- Use `VContainer` at the top level to establish page boundaries
- Set `fluid` for full-width layouts
- Combine with spacing utilities (py-8, px-4) for consistent padding

#### VRow & VCol

Build responsive grids with VRow (flex row) and VCol (flex column).

```vue
<template>
  <!-- Two equal columns on desktop, stacked on mobile -->
  <VRow>
    <VCol cols="12" md="6">
      <VCard>Left Column</VCard>
    </VCol>
    <VCol cols="12" md="6">
      <VCard>Right Column</VCard>
    </VCol>
  </VRow>

  <!-- Responsive grid with gaps -->
  <VRow dense>
    <VCol v-for="item in items" :key="item.id" cols="12" sm="6" lg="3">
      <VCard>{{ item.name }}</VCard>
    </VCol>
  </VRow>
</template>

<script setup lang="ts">
const items = [
  { id: 1, name: 'Item 1' },
  { id: 2, name: 'Item 2' },
  { id: 3, name: 'Item 3' },
  { id: 4, name: 'Item 4' },
]
</script>
```

**Responsive Breakpoints**:
```
xs: 0px   (extra small)
sm: 600px (small)
md: 960px (medium)
lg: 1264px (large)
xl: 1904px (extra large)
```

**VCol Props**:
- `cols`: Default columns (1-12) at xs breakpoint
- `sm`, `md`, `lg`, `xl`: Columns at specific breakpoints
- `offset-*`: Offset columns at each breakpoint
- `order-*`: Reorder columns with flexbox

### VSheet

Flexible container for grouping content with consistent elevation and styling.

```vue
<template>
  <VSheet
    :elevation="4"
    class="pa-6"
    rounded="lg"
    color="surface"
  >
    <h2>Card-like Container</h2>
    <p>Flexible alternative to VCard when you need more control.</p>
  </VSheet>
</template>

<!-- Props -->
<VSheet
  elevation="0"          <!-- 0-24, or "flat" -->
  rounded                <!-- Boolean or size: true, 'sm', 'md', 'lg', 'xl' -->
  color="primary"        <!-- Background color -->
  class="pa-4 ma-2"      <!-- Padding/margin utilities -->
/>
```

**Usage Guidelines**:
- Use `VSheet` as a flexible container when `VCard` is overkill
- Elevation (shadow) for depth and visual hierarchy
- Combine with Vuetify spacing utilities (pa-*, ma-*, py-*, px-*)

### VNavigationDrawer

Persistent or temporary navigation sidebar.

```vue
<template>
  <VNavigationDrawer
    v-model="drawer"
    :rail="railMode"
    :permanent="isPermanent"
    app
  >
    <VList>
      <VListItem
        v-for="item in navItems"
        :key="item.title"
        :to="item.path"
        :prepend-icon="item.icon"
      >
        <VListItemTitle>{{ item.title }}</VListItemTitle>
      </VListItem>
    </VList>
  </VNavigationDrawer>
</template>

<script setup lang="ts">
import { ref, computed } from 'vue'
import { useDisplay } from 'vuetify'

const drawer = ref(true)
const railMode = ref(false)
const { mdAndUp } = useDisplay()

const isPermanent = computed(() => mdAndUp.value)

const navItems = [
  { title: 'Dashboard', path: '/', icon: 'mdi-home' },
  { title: 'Users', path: '/users', icon: 'mdi-account-multiple' },
  { title: 'Settings', path: '/settings', icon: 'mdi-cog' },
]
</script>
```

**Props**:
- `v-model`: Control open/closed state
- `rail`: Collapse to icon-only mode
- `permanent`: Always visible (on large screens)
- `app`: Take full height including AppBar
- `width`: Custom drawer width (default 256px)

### VAppBar

Top application bar with title, actions, and navigation.

```vue
<template>
  <VAppBar
    color="primary"
    dark
    app
  >
    <VAppBarNavIcon @click="drawer = !drawer" />
    <VAppBarTitle>My Application</VAppBarTitle>
    <VSpacer />
    
    <VBtn icon="mdi-bell" />
    <VBtn icon="mdi-account-circle" />
  </VAppBar>
</template>

<script setup lang="ts">
import { ref } from 'vue'

const drawer = ref(false)
</script>
```

**Props**:
- `app`: Fix to top of screen
- `color`: Background color
- `dark`/`light`: Text color scheme
- `flat`: Remove elevation shadow
- `border`: Add bottom border instead of shadow

---

## Data Display Components

### VDataTable

Powerful table component with sorting, filtering, and pagination.

```vue
<template>
  <VDataTable
    :items="items"
    :headers="headers"
    :search="search"
    :loading="isLoading"
    :page.sync="page"
    :items-per-page.sync="itemsPerPage"
    item-key="id"
    class="elevation-1"
  >
    <!-- Custom header toolbar -->
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
        <VSpacer />
        <VBtn color="primary" @click="createNew">New User</VBtn>
      </VToolbar>
    </template>

    <!-- Custom cell rendering -->
    <template #[`item.status`]="{ item }">
      <VChip :color="getStatusColor(item.status)">
        {{ item.status }}
      </VChip>
    </template>

    <!-- Actions column -->
    <template #[`item.actions`]="{ item }">
      <VIconButton
        icon="mdi-pencil"
        size="small"
        @click="editItem(item)"
      />
      <VIconButton
        icon="mdi-delete"
        size="small"
        @click="deleteItem(item)"
      />
    </template>

    <!-- No data slot -->
    <template #no-data>
      <VAlert type="info" title="No users found" />
    </template>
  </VDataTable>
</template>

<script setup lang="ts">
import { ref, computed } from 'vue'

interface User {
  id: number
  name: string
  email: string
  status: 'active' | 'inactive'
}

const items = ref<User[]>([
  { id: 1, name: 'John Doe', email: 'john@example.com', status: 'active' },
  { id: 2, name: 'Jane Smith', email: 'jane@example.com', status: 'active' },
])

const headers = [
  { title: 'Name', value: 'name' },
  { title: 'Email', value: 'email' },
  { title: 'Status', value: 'status' },
  { title: 'Actions', value: 'actions', sortable: false },
]

const search = ref('')
const isLoading = ref(false)
const page = ref(1)
const itemsPerPage = ref(10)

const getStatusColor = (status: string) => status === 'active' ? 'green' : 'red'

const editItem = (item: User) => console.log('Edit:', item)
const deleteItem = (item: User) => console.log('Delete:', item)
const createNew = () => console.log('Create new user')
</script>
```

**Key Features**:
- Two-way binding with `v-model:page` and `v-model:items-per-page`
- Search filtering across all columns
- Sortable columns (customize per column)
- Custom item rendering with scoped slots
- Loading state with spinner overlay

### VList

Flexible list component with items, groups, and avatars.

```vue
<template>
  <!-- Simple list -->
  <VList>
    <VListItem
      v-for="item in items"
      :key="item.id"
      :title="item.title"
      :subtitle="item.subtitle"
      :prepend-avatar="item.avatar"
      @click="selectItem(item)"
    />
  </VList>

  <!-- Grouped list -->
  <VList>
    <VListGroup v-for="group in groups" :key="group.title">
      <template #activator="{ props }">
        <VListItem v-bind="props" :title="group.title" />
      </template>

      <VListItem
        v-for="item in group.items"
        :key="item.id"
        :title="item.title"
      />
    </VListGroup>
  </VList>

  <!-- Custom list items -->
  <VList>
    <VListItem v-for="item in items" :key="item.id">
      <template #prepend>
        <VIcon :icon="item.icon" />
      </template>
      <VListItemTitle>{{ item.title }}</VListItemTitle>
      <template #append>
        <VChip>{{ item.badge }}</VChip>
      </template>
    </VListItem>
  </VList>
</template>

<script setup lang="ts">
interface Item {
  id: number
  title: string
  subtitle?: string
  avatar?: string
  icon?: string
  badge?: string
}

const items = ref<Item[]>([
  {
    id: 1,
    title: 'Alice Johnson',
    subtitle: 'Admin',
    avatar: 'https://cdn.vuetifyjs.com/images/avatars/1.jpg',
  },
  {
    id: 2,
    title: 'Bob Smith',
    subtitle: 'User',
    avatar: 'https://cdn.vuetifyjs.com/images/avatars/2.jpg',
  },
])

const selectItem = (item: Item) => console.log('Selected:', item)
</script>
```

### VCard

Container for content with header, text, and actions.

```vue
<template>
  <!-- Basic card -->
  <VCard>
    <VCardTitle>Card Title</VCardTitle>
    <VCardSubtitle>Subtitle</VCardSubtitle>
    <VCardText>Card content goes here</VCardText>
    <VCardActions>
      <VSpacer />
      <VBtn color="primary">Action</VBtn>
    </VCardActions>
  </VCard>

  <!-- Card with image -->
  <VCard max-width="400">
    <VImg
      src="https://cdn.vuetifyjs.com/images/cards/halcyon.png"
      height="250"
    />
    <VCardTitle>Halcyon</VCardTitle>
    <VCardSubtitle>by John Doe</VCardSubtitle>
    <VCardText>
      Beautiful landscape photography with stunning colors.
    </VCardText>
    <VCardActions>
      <VBtn text>Learn More</VBtn>
    </VCardActions>
  </VCard>

  <!-- Card with overlay -->
  <VCard class="mx-auto" max-width="400">
    <VOverlay absolute contained>
      <VProgressCircular indeterminate />
    </VOverlay>
    <VImg
      src="https://cdn.vuetifyjs.com/images/cards/kitchen.jpg"
      height="250"
    />
    <VCardText>
      Loading content...
    </VCardText>
  </VCard>
</template>
```

**Card Structure**:
- `VCardTitle`: Card heading
- `VCardSubtitle`: Optional subtitle
- `VCardText`: Main content area
- `VCardActions`: Footer with buttons
- Combine with `VImg`, `VDivider` for complex layouts

### VChip

Small, compact component for tags, categories, or selections.

```vue
<template>
  <!-- Basic chip -->
  <VChip>Default Chip</VChip>

  <!-- Colored chips -->
  <VChip color="primary">Primary</VChip>
  <VChip color="success">Success</VChip>
  <VChip color="error">Error</VChip>

  <!-- Chip with avatar -->
  <VChip avatar prepend-avatar="https://cdn.vuetifyjs.com/images/avatars/1.jpg">
    John Doe
  </VChip>

  <!-- Closeable chips -->
  <VChip
    v-for="tag in tags"
    :key="tag"
    closable
    @click:close="removeTag(tag)"
  >
    {{ tag }}
  </VChip>

  <!-- Chip group (single or multiple selection) -->
  <VChipGroup v-model="selectedTags" multiple>
    <VChip v-for="tag in allTags" :key="tag" :value="tag">
      {{ tag }}
    </VChip>
  </VChipGroup>
</template>

<script setup lang="ts">
import { ref } from 'vue'

const tags = ref(['Vue', 'Vuetify', 'JavaScript'])
const selectedTags = ref<string[]>([])
const allTags = ['Vue', 'React', 'Angular', 'Svelte']

const removeTag = (tag: string) => {
  tags.value = tags.value.filter(t => t !== tag)
}
</script>
```

---

## Form Components

### VTextField

Single-line text input with validation and icons.

```vue
<template>
  <!-- Basic text field -->
  <VTextField
    v-model="email"
    label="Email"
    type="email"
    outlined
  />

  <!-- With validation -->
  <VTextField
    v-model="password"
    label="Password"
    type="password"
    :rules="[required, minLength]"
    :error="hasError"
    :error-messages="errorMessages"
    outlined
  />

  <!-- With icons and hints -->
  <VTextField
    v-model="search"
    label="Search"
    prepend-icon="mdi-magnify"
    append-icon="mdi-close"
    hint="Type to search"
    persistent-hint
    clearable
    outlined
    @click:append="search = ''"
  />

  <!-- Disabled and readonly -->
  <VTextField
    v-model="id"
    label="ID"
    readonly
    outlined
  />

  <!-- Custom styling -->
  <VTextField
    v-model="name"
    label="Full Name"
    placeholder="Enter your full name"
    solo
    dense
    rounded
  />
</template>

<script setup lang="ts">
import { ref } from 'vue'

const email = ref('')
const password = ref('')
const search = ref('')
const id = ref('12345')
const name = ref('')
const hasError = ref(false)
const errorMessages = ref<string[]>([])

const required = (value: string) => !!value || 'This field is required'
const minLength = (value: string) => value.length >= 8 || 'Must be at least 8 characters'
</script>
```

**Props**:
- `type`: 'text', 'email', 'password', 'number', 'search', 'url', 'tel'
- `label`: Field label (floats on focus)
- `placeholder`: Input placeholder text
- `prepend-icon`/`append-icon`: Icons before/after input
- `clearable`: Show clear button when value exists
- `rules`: Array of validation functions
- `error-messages`: Display validation errors
- `hint`: Helper text below field
- `persistent-hint`: Always show hint (not just on focus)
- `readonly`: Prevent user input
- `disabled`: Disable field completely
- `variant`: 'outlined', 'filled', 'underlined', 'plain'
- `dense`: Smaller height
- `rounded`: Rounded corners

### VSelect

Dropdown selection with multiple choices.

```vue
<template>
  <!-- Basic select -->
  <VSelect
    v-model="selectedCountry"
    label="Country"
    :items="countries"
    outlined
  />

  <!-- Multiple selection -->
  <VSelect
    v-model="selectedTags"
    label="Tags"
    :items="availableTags"
    multiple
    chips
    outlined
  />

  <!-- With search and custom display -->
  <VSelect
    v-model="selectedUser"
    label="Select User"
    :items="users"
    item-title="name"
    item-value="id"
    search
    outlined
  >
    <template #selection="{ item }">
      <VChip>{{ item.props.title }}</VChip>
    </template>
    <template #item="{ props, item }">
      <VListItem v-bind="props">
        <template #prepend>
          <VAvatar :image="item.raw.avatar" />
        </template>
        <VListItemTitle>{{ item.raw.name }}</VListItemTitle>
        <VListItemSubtitle>{{ item.raw.email }}</VListItemSubtitle>
      </VListItem>
    </template>
  </VSelect>

  <!-- With validation -->
  <VSelect
    v-model="selectedOption"
    label="Required Field"
    :items="options"
    :rules="[required]"
    outlined
  />
</template>

<script setup lang="ts">
import { ref } from 'vue'

const selectedCountry = ref('usa')
const selectedTags = ref<string[]>([])
const selectedUser = ref<number | null>(null)
const selectedOption = ref<string | null>(null)

const countries = ['USA', 'Canada', 'Mexico', 'Brazil']
const availableTags = ['Vue', 'React', 'Angular', 'Svelte']
const options = ['Option 1', 'Option 2', 'Option 3']

interface User {
  id: number
  name: string
  email: string
  avatar: string
}

const users = ref<User[]>([
  {
    id: 1,
    name: 'John Doe',
    email: 'john@example.com',
    avatar: 'https://cdn.vuetifyjs.com/images/avatars/1.jpg',
  },
])

const required = (value: any) => !!value || 'This field is required'
</script>
```

**Props**:
- `multiple`: Allow multiple selections
- `chips`: Display selections as chips
- `search`: Enable search/filter
- `item-title`: Property name for display text
- `item-value`: Property name for actual value
- `clearable`: Show clear button
- `disabled`: Disable field

### VCheckbox

Checkbox for boolean input.

```vue
<template>
  <!-- Basic checkbox -->
  <VCheckbox v-model="agreeToTerms" label="I agree to the terms" />

  <!-- Multiple checkboxes -->
  <div>
    <VCheckbox
      v-for="option in options"
      :key="option"
      :model-value="selectedOptions.includes(option)"
      :label="option"
      @update:model-value="toggleOption(option)"
    />
  </div>

  <!-- Checkbox with description -->
  <VCheckbox
    v-model="enableNotifications"
    label="Enable Notifications"
  >
    <template #append-slot>
      <VIcon small>mdi-help-circle</VIcon>
    </template>
  </VCheckbox>

  <!-- Indeterminate (partially checked) -->
  <VCheckbox
    :model-value="isIndeterminate"
    :indeterminate="isIndeterminate"
    @update:model-value="toggleAll"
  />
  <VCheckbox
    v-for="item in items"
    :key="item"
    :model-value="selectedItems.includes(item)"
    :label="item"
    @update:model-value="toggleItem(item)"
  />
</template>

<script setup lang="ts">
import { ref, computed } from 'vue'

const agreeToTerms = ref(false)
const enableNotifications = ref(true)
const options = ['Email', 'SMS', 'Push']
const selectedOptions = ref<string[]>(['Email'])
const items = ['Item 1', 'Item 2', 'Item 3']
const selectedItems = ref<string[]>([])

const isIndeterminate = computed(() => 
  selectedItems.value.length > 0 && selectedItems.value.length < items.length
)

const toggleOption = (option: string) => {
  const index = selectedOptions.value.indexOf(option)
  if (index > -1) {
    selectedOptions.value.splice(index, 1)
  } else {
    selectedOptions.value.push(option)
  }
}

const toggleAll = () => {
  if (selectedItems.value.length === items.length) {
    selectedItems.value = []
  } else {
    selectedItems.value = [...items]
  }
}

const toggleItem = (item: string) => {
  const index = selectedItems.value.indexOf(item)
  if (index > -1) {
    selectedItems.value.splice(index, 1)
  } else {
    selectedItems.value.push(item)
  }
}
</script>
```

### VRadio & VRadioGroup

Radio buttons for single selection from multiple options.

```vue
<template>
  <!-- Radio group -->
  <VRadioGroup v-model="selectedOption" label="Choose one">
    <VRadio value="option1" label="Option 1" />
    <VRadio value="option2" label="Option 2" />
    <VRadio value="option3" label="Option 3" />
  </VRadioGroup>

  <!-- Inline radio buttons -->
  <VRadioGroup v-model="selectedOption" inline>
    <VRadio value="yes" label="Yes" />
    <VRadio value="no" label="No" />
  </VRadioGroup>

  <!-- Radio with custom content -->
  <VRadioGroup v-model="selectedPlan">
    <VRadio
      v-for="plan in plans"
      :key="plan.id"
      :value="plan.id"
    >
      <template #label>
        <div class="ml-2">
          <div class="font-weight-bold">{{ plan.name }}</div>
          <div class="text-caption">{{ plan.price }}/month</div>
        </div>
      </template>
    </VRadio>
  </VRadioGroup>
</template>

<script setup lang="ts">
import { ref } from 'vue'

const selectedOption = ref('option1')
const selectedPlan = ref<number | null>(null)

interface Plan {
  id: number
  name: string
  price: number
}

const plans: Plan[] = [
  { id: 1, name: 'Starter', price: 9 },
  { id: 2, name: 'Professional', price: 29 },
  { id: 3, name: 'Enterprise', price: 99 },
]
</script>
```

### VSwitch

Toggle switch for boolean values.

```vue
<template>
  <!-- Basic switch -->
  <VSwitch v-model="isDarkMode" label="Dark Mode" />

  <!-- Switch with description -->
  <VSwitch
    v-model="isEnabled"
    label="Feature Enabled"
    hint="Enable this feature for all users"
    persistent-hint
  />

  <!-- Loading switch -->
  <VSwitch
    v-model="isLoading"
    :loading="isSaving"
    label="Active"
  />

  <!-- Custom colors -->
  <VSwitch
    v-model="isActive"
    color="success"
    label="Active"
  />
</template>

<script setup lang="ts">
import { ref } from 'vue'

const isDarkMode = ref(false)
const isEnabled = ref(true)
const isActive = ref(true)
const isLoading = ref(false)
const isSaving = ref(false)
</script>
```

---

## Dialog & Menu Patterns

### VDialog

Modal dialog for forms, confirmations, or detailed content.

```vue
<template>
  <!-- Basic dialog -->
  <div>
    <VBtn color="primary" @click="isOpen = true">
      Open Dialog
    </VBtn>

    <VDialog v-model="isOpen" max-width="500">
      <VCard>
        <VCardTitle>Dialog Title</VCardTitle>
        <VCardText>
          Dialog content goes here
        </VCardText>
        <VCardActions>
          <VSpacer />
          <VBtn text @click="isOpen = false">Cancel</VBtn>
          <VBtn color="primary" @click="confirm">Confirm</VBtn>
        </VCardActions>
      </VCard>
    </VDialog>
  </div>

  <!-- Dialog with form -->
  <div>
    <VBtn color="primary" @click="formDialogOpen = true">
      Create Item
    </VBtn>

    <VDialog v-model="formDialogOpen" max-width="600">
      <VCard>
        <VCardTitle>Create New Item</VCardTitle>
        <VCardText>
          <VForm ref="form" @submit.prevent="submitForm">
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
            <VSelect
              v-model="formData.category"
              label="Category"
              :items="categories"
              :rules="[required]"
              required
            />
          </VForm>
        </VCardText>
        <VCardActions>
          <VSpacer />
          <VBtn @click="formDialogOpen = false">Cancel</VBtn>
          <VBtn color="primary" @click="submitForm">Create</VBtn>
        </VCardActions>
      </VCard>
    </VDialog>
  </div>

  <!-- Confirmation dialog -->
  <div>
    <VBtn color="error" @click="showDeleteConfirm = true">
      Delete
    </VBtn>

    <VDialog v-model="showDeleteConfirm" max-width="400">
      <VCard>
        <VCardTitle>Confirm Deletion</VCardTitle>
        <VCardText>
          Are you sure you want to delete this item? This action cannot be undone.
        </VCardText>
        <VCardActions>
          <VSpacer />
          <VBtn @click="showDeleteConfirm = false">Cancel</VBtn>
          <VBtn color="error" @click="deleteItem">Delete</VBtn>
        </VCardActions>
      </VCard>
    </VDialog>
  </div>
</template>

<script setup lang="ts">
import { ref } from 'vue'

const isOpen = ref(false)
const formDialogOpen = ref(false)
const showDeleteConfirm = ref(false)
const form = ref<any>()

const formData = ref({
  title: '',
  description: '',
  category: '',
})

const categories = ['Category 1', 'Category 2', 'Category 3']

const required = (value: string) => !!value || 'This field is required'

const confirm = () => {
  console.log('Confirmed')
  isOpen.value = false
}

const submitForm = async () => {
  const { valid } = await form.value?.validate()
  if (!valid) return

  try {
    console.log('Submitting:', formData.value)
    formDialogOpen.value = false
    // Reset form
    formData.value = { title: '', description: '', category: '' }
  } catch (error) {
    console.error('Error:', error)
  }
}

const deleteItem = () => {
  console.log('Item deleted')
  showDeleteConfirm.value = false
}
</script>
```

**Props**:
- `max-width`: Maximum width (e.g., '500', '600', 'lg')
- `width`: Explicit width
- `fullscreen`: Full screen dialog
- `scrollable`: Scrollable content area
- `persistent`: Clicking outside doesn't close
- `transition`: Animation type

### VMenu

Context menu or dropdown menu.

```vue
<template>
  <!-- Basic menu -->
  <VMenu>
    <template #activator="{ props }">
      <VBtn v-bind="props" icon="mdi-dots-vertical" />
    </template>

    <VList>
      <VListItem @click="editItem">
        <template #prepend>
          <VIcon>mdi-pencil</VIcon>
        </template>
        <VListItemTitle>Edit</VListItemTitle>
      </VListItem>
      <VListItem @click="duplicateItem">
        <template #prepend>
          <VIcon>mdi-content-copy</VIcon>
        </template>
        <VListItemTitle>Duplicate</VListItemTitle>
      </VListItem>
      <VDivider />
      <VListItem @click="deleteItem" class="text-red">
        <template #prepend>
          <VIcon>mdi-delete</VIcon>
        </template>
        <VListItemTitle>Delete</VListItemTitle>
      </VListItem>
    </VList>
  </VMenu>

  <!-- Menu with positioning -->
  <VMenu
    v-model="showMenu"
    :close-on-content-click="false"
    location="start"
  >
    <template #activator="{ props }">
      <VBtn v-bind="props">Settings</VBtn>
    </template>

    <VCard min-width="200">
      <VCardText>
        <VSwitch v-model="isDarkMode" label="Dark Mode" />
        <VDivider class="my-2" />
        <VBtn text small @click="showMenu = false">Close</VBtn>
      </VCardText>
    </VCard>
  </VMenu>
</template>

<script setup lang="ts">
import { ref } from 'vue'

const showMenu = ref(false)
const isDarkMode = ref(false)

const editItem = () => console.log('Edit')
const duplicateItem = () => console.log('Duplicate')
const deleteItem = () => console.log('Delete')
</script>
```

---

## Typography & Icons

### Text Hierarchy

Use text classes for consistent typography.

```vue
<template>
  <!-- Display sizes (headings) -->
  <h1 class="text-h1">Display 1</h1>
  <h2 class="text-h2">Display 2</h2>
  <h3 class="text-h3">Headline 1</h3>
  <h4 class="text-h4">Headline 2</h4>
  <h5 class="text-h5">Title</h5>
  <h6 class="text-h6">Subtitle</h6>

  <!-- Body text -->
  <p class="text-body-1">Body text large</p>
  <p class="text-body-2">Body text regular</p>

  <!-- Caption -->
  <span class="text-caption">Small caption text</span>

  <!-- Overline -->
  <span class="text-overline">SECTION TITLE</span>

  <!-- Text colors -->
  <p class="text-primary">Primary color</p>
  <p class="text-error">Error color</p>
  <p class="text-disabled">Disabled text</p>

  <!-- Text weight -->
  <p class="font-weight-thin">Thin (100)</p>
  <p class="font-weight-light">Light (300)</p>
  <p class="font-weight-regular">Regular (400)</p>
  <p class="font-weight-medium">Medium (500)</p>
  <p class="font-weight-bold">Bold (700)</p>

  <!-- Text decoration -->
  <p class="text-decoration-underline">Underlined</p>
  <p class="text-decoration-line-through">Strikethrough</p>
  <p class="text-uppercase">uppercase text</p>
  <p class="text-lowercase">LOWERCASE TEXT</p>
</template>
```

### Icons with VIcon

Material Design Icons integration.

```vue
<template>
  <!-- Basic icon -->
  <VIcon>mdi-home</VIcon>

  <!-- Sized icons -->
  <VIcon size="x-small">mdi-star</VIcon>
  <VIcon size="small">mdi-star</VIcon>
  <VIcon>mdi-star</VIcon>
  <VIcon size="large">mdi-star</VIcon>
  <VIcon size="x-large">mdi-star</VIcon>

  <!-- Colored icons -->
  <VIcon color="primary">mdi-home</VIcon>
  <VIcon color="success">mdi-check</VIcon>
  <VIcon color="error">mdi-alert</VIcon>
  <VIcon color="warning">mdi-exclamation</VIcon>

  <!-- Icon with button -->
  <VBtn icon="mdi-home" size="small" />
  <VBtn icon="mdi-pencil" color="primary" />
  <VBtn icon="mdi-delete" color="error" variant="text" />

  <!-- Icon button -->
  <VIconButton icon="mdi-menu" @click="toggleMenu" />
  <VIconButton icon="mdi-close" @click="close" />

  <!-- Animated icon -->
  <VIcon :class="{ 'animate-spin': isLoading }">mdi-loading</VIcon>
</template>

<script setup lang="ts">
import { ref } from 'vue'

const isLoading = ref(false)
</script>

<!-- Icon names: mdi-{name}, e.g., mdi-home, mdi-heart, mdi-star -->
<!-- Find icons at: https://materialdesignicons.com -->
```

---

## Theming & Customization

### Vuetify Theme Setup

```typescript
// vuetify.ts
import { createVuetify } from 'vuetify'
import * as components from 'vuetify/components'
import * as directives from 'vuetify/directives'
import { aliases, mdi } from 'vuetify/iconsets/mdi-svg'
import '@mdi/js'

export default createVuetify({
  components,
  directives,
  icons: {
    defaultSet: 'mdi',
    aliases,
    sets: { mdi },
  },
  theme: {
    defaultTheme: 'light',
    themes: {
      light: {
        colors: {
          primary: '#1976D2',
          secondary: '#424242',
          success: '#4CAF50',
          warning: '#FFC107',
          error: '#F44336',
          info: '#2196F3',
        },
      },
      dark: {
        colors: {
          primary: '#BB86FC',
          secondary: '#03DAC6',
          success: '#66BB6A',
          warning: '#FFA726',
          error: '#EF5350',
          info: '#42A5F5',
        },
      },
    },
  },
})
```

### Custom Color Palette

```vue
<template>
  <!-- Using theme colors -->
  <VCard color="primary">Primary card</VCard>
  <VCard color="secondary">Secondary card</VCard>
  <VCard color="surface">Surface card</VCard>

  <!-- Surface variants -->
  <VSheet color="surface-bright">Bright surface</VSheet>
  <VSheet color="surface-dim">Dim surface</VSheet>
</template>
```

### Responsive Breakpoints

```typescript
// Access breakpoints in components
import { useDisplay } from 'vuetify'

const { xs, sm, md, lg, xl, mdAndUp, smAndUp } = useDisplay()

// In template
v-if="mdAndUp"  // Show on md and larger
v-if="smAndDown" // Show on sm and smaller
```

---

## Component Composition

### Composite Components

Create reusable component combinations.

```vue
<!-- FormCard.vue -->
<template>
  <VCard :title="title" :subtitle="subtitle">
    <VCardText>
      <VForm ref="form" @submit.prevent="submit">
        <slot />
      </VForm>
    </VCardText>
    <VCardActions>
      <VSpacer />
      <VBtn @click="cancel">Cancel</VBtn>
      <VBtn color="primary" @click="submit">Submit</VBtn>
    </VCardActions>
  </VCard>
</template>

<script setup lang="ts">
import { ref } from 'vue'

defineProps<{
  title: string
  subtitle?: string
}>()

const emit = defineEmits<{
  submit: []
  cancel: []
}>()

const form = ref<any>()

const submit = async () => {
  const { valid } = await form.value?.validate()
  if (valid) emit('submit')
}

const cancel = () => emit('cancel')
</script>

<!-- Usage -->
<template>
  <FormCard title="Create User" @submit="createUser" @cancel="close">
    <VTextField v-model="user.name" label="Name" required />
    <VTextField v-model="user.email" label="Email" type="email" required />
  </FormCard>
</template>
```

### Wrapper Components

Wrap Vuetify components with custom styling and behavior.

```vue
<!-- CustomButton.vue -->
<template>
  <VBtn
    :color="color"
    :variant="variant"
    :disabled="disabled || isLoading"
    :loading="isLoading"
    v-bind="$attrs"
  >
    <slot />
  </VBtn>
</template>

<script setup lang="ts">
defineProps<{
  color?: string
  variant?: 'flat' | 'outlined' | 'elevated' | 'tonal' | 'text'
  disabled?: boolean
  isLoading?: boolean
}>()
</script>

<!-- PrimaryButton.vue (specialized wrapper) -->
<template>
  <CustomButton color="primary" variant="elevated" v-bind="$attrs">
    <slot />
  </CustomButton>
</template>
```

---

## Props & Slots

### Working with Props

```vue
<template>
  <!-- Pass props as objects -->
  <VBtn
    :color="buttonColor"
    :icon="buttonIcon"
    :disabled="isDisabled"
    v-bind="extraProps"
  >
    Click Me
  </VBtn>
</template>

<script setup lang="ts">
import { ref, computed } from 'vue'

const buttonColor = ref('primary')
const buttonIcon = ref('mdi-check')
const isDisabled = computed(() => !isFormValid.value)
const extraProps = {
  size: 'large',
  rounded: true,
}
const isFormValid = ref(true)
</script>
```

### Named Slots

Most Vuetify components support multiple slots for customization.

```vue
<template>
  <!-- VTextField slots -->
  <VTextField label="Email">
    <template #prepend-inner>
      <VIcon>mdi-email</VIcon>
    </template>
    <template #append>
      <VIcon @click="toggle">mdi-eye</VIcon>
    </template>
  </VTextField>

  <!-- VDataTable slots -->
  <VDataTable :items="users" :headers="headers">
    <template #top>
      <VToolbar flat>
        <VToolbarTitle>Users</VToolbarTitle>
      </VToolbar>
    </template>
    <template #[`item.name`]="{ item }">
      <strong>{{ item.name }}</strong>
    </template>
    <template #no-data>
      <VAlert type="info">No users found</VAlert>
    </template>
  </VDataTable>
</template>
```

---

## Advanced Patterns

### Infinite Scroll with VList

```vue
<template>
  <VInfiniteScroll @load="loadMore">
    <VList>
      <VListItem
        v-for="item in items"
        :key="item.id"
        :title="item.title"
      />
    </VList>
  </VInfiniteScroll>
</template>

<script setup lang="ts">
import { ref } from 'vue'

const items = ref<any[]>([])
const page = ref(1)

const loadMore = async ({ side }: { side: 'end' }) => {
  if (side === 'end') {
    const response = await fetch(`/api/items?page=${page.value}`)
    const newItems = await response.json()
    items.value.push(...newItems)
    page.value++
  }
}
</script>
```

### Expandable Rows in DataTable

```vue
<template>
  <VDataTable :items="items" :headers="headers" item-key="id">
    <template #expanded-row="{ item }">
      <VCard class="mt-4">
        <VCardText>
          <div>Description: {{ item.description }}</div>
          <div>Details: {{ item.details }}</div>
        </VCardText>
      </VCard>
    </template>

    <template #[`item.expand`]="{ item, internalItem }">
      <VIcon @click="internalItem.isExpanded = !internalItem.isExpanded">
        {{ internalItem.isExpanded ? 'mdi-chevron-up' : 'mdi-chevron-down' }}
      </VIcon>
    </template>
  </VDataTable>
</template>
```

### Modal with Scrollable Content

```vue
<template>
  <VDialog scrollable max-width="600">
    <VCard>
      <VCardTitle>Long Content</VCardTitle>
      <VDivider />
      <VCardText style="height: 300px" class="overflow-y-auto">
        <!-- Long content here -->
        <p v-for="i in 20" :key="i">
          Paragraph {{ i }}
        </p>
      </VCardText>
      <VDivider />
      <VCardActions>
        <VSpacer />
        <VBtn text>Close</VBtn>
        <VBtn color="primary">Save</VBtn>
      </VCardActions>
    </VCard>
  </VDialog>
</template>
```

---

## Key Takeaways

1. **Use responsive props** (cols, sm, md, lg) for mobile-first design
2. **Leverage slots** for customization without overriding components
3. **Combine validation** with clear error messages
4. **Use theming** for consistent visual design
5. **Extract composables** for reusable logic
6. **Test accessibility** from the start (next guide covers this in depth)
7. **Follow Material Design** principles for consistency
8. **Consider performance** with virtual scrolling and lazy loading

**Next:** Explore [Vue 3 Composition API patterns](vue3-composition.md) for modern, maintainable components.
