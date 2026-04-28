---
name: add-accessibility
description: Add WCAG-compliant accessibility and UX improvements to Vuetify components
---

# Add Accessibility Skill

Audit and improve Vuetify Vue 3 components for WCAG 2.1 AA compliance — ARIA labels, keyboard navigation, color contrast, and semantic HTML.

## When to Use

- Auditing a component for accessibility issues
- Adding ARIA labels, roles, or keyboard navigation
- Ensuring color contrast meets WCAG standards
- Improving UX consistency

## Key Requirements

### Semantic HTML

Use Vuetify's semantic props (`tag`) and HTML elements to convey meaning:

```vue
<v-main tag="main">
  <v-container tag="section" aria-labelledby="section-title">
    <h2 id="section-title">Results</h2>
  </v-container>
</v-main>
```

### ARIA Labels

Always label interactive elements that lack visible text:

```vue
<!-- Icon-only buttons MUST have aria-label -->
<v-btn icon="mdi-delete" aria-label="Delete item" @click="remove(item)" />

<!-- Tables need captions -->
<v-data-table aria-label="User list" />
```

### Keyboard Navigation

- Vuetify handles most keyboard nav automatically — do not override default focus behavior
- Modals must trap focus: use `v-dialog` (built-in) rather than custom overlays
- After closing a dialog, return focus to the trigger element

### Color Contrast

- Text on backgrounds must meet 4.5:1 ratio (WCAG AA)
- Never rely on color alone to convey state — pair with icon or text label

### Form Accessibility

```vue
<v-text-field
  label="Email"            <!-- label is the accessible name -->
  :error-messages="errors" <!-- surfaced to screen readers -->
  required
  aria-required="true"
/>
```

## Checklist

- [ ] All images have `alt` text (or `alt=""` if decorative)
- [ ] Icon-only buttons have `aria-label`
- [ ] Form fields have visible labels, not just placeholder
- [ ] Error messages are associated with their field
- [ ] Focus order is logical (matches visual order)
- [ ] No content is keyboard-inaccessible

## Reference

- [WCAG 2.1 Quick Reference](https://www.w3.org/WAI/WCAG21/quickref/)
- [ARIA Authoring Practices](https://www.w3.org/WAI/ARIA/apg/)
- [Vuetify Accessibility docs](https://vuetifyjs.com/en/features/accessibility/)
