---
name: Konvert Obsidian
colors:
  surface: '#0b1326'
  surface-dim: '#0b1326'
  surface-bright: '#31394d'
  surface-container-lowest: '#060e20'
  surface-container-low: '#131b2e'
  surface-container: '#171f33'
  surface-container-high: '#222a3d'
  surface-container-highest: '#2d3449'
  on-surface: '#dae2fd'
  on-surface-variant: '#cbc3d7'
  inverse-surface: '#dae2fd'
  inverse-on-surface: '#283044'
  outline: '#958ea0'
  outline-variant: '#494454'
  surface-tint: '#d0bcff'
  primary: '#d0bcff'
  on-primary: '#3c0091'
  primary-container: '#a078ff'
  on-primary-container: '#340080'
  inverse-primary: '#6d3bd7'
  secondary: '#c0c1ff'
  on-secondary: '#1000a9'
  secondary-container: '#3131c0'
  on-secondary-container: '#b0b2ff'
  tertiary: '#cebdff'
  on-tertiary: '#381385'
  tertiary-container: '#9b7fed'
  on-tertiary-container: '#31057e'
  error: '#ffb4ab'
  on-error: '#690005'
  error-container: '#93000a'
  on-error-container: '#ffdad6'
  primary-fixed: '#e9ddff'
  primary-fixed-dim: '#d0bcff'
  on-primary-fixed: '#23005c'
  on-primary-fixed-variant: '#5516be'
  secondary-fixed: '#e1e0ff'
  secondary-fixed-dim: '#c0c1ff'
  on-secondary-fixed: '#07006c'
  on-secondary-fixed-variant: '#2f2ebe'
  tertiary-fixed: '#e8ddff'
  tertiary-fixed-dim: '#cebdff'
  on-tertiary-fixed: '#21005e'
  on-tertiary-fixed-variant: '#4f319c'
  background: '#0b1326'
  on-background: '#dae2fd'
  surface-variant: '#2d3449'
typography:
  headline-xl:
    fontFamily: Inter
    fontSize: 32px
    fontWeight: '700'
    lineHeight: '1.2'
    letterSpacing: -0.02em
  headline-md:
    fontFamily: Inter
    fontSize: 20px
    fontWeight: '600'
    lineHeight: '1.4'
    letterSpacing: -0.01em
  body-lg:
    fontFamily: Inter
    fontSize: 16px
    fontWeight: '400'
    lineHeight: '1.6'
    letterSpacing: '0'
  body-sm:
    fontFamily: Inter
    fontSize: 14px
    fontWeight: '400'
    lineHeight: '1.5'
    letterSpacing: '0'
  label-caps:
    fontFamily: Inter
    fontSize: 12px
    fontWeight: '700'
    lineHeight: '1'
    letterSpacing: 0.05em
rounded:
  sm: 0.25rem
  DEFAULT: 0.5rem
  md: 0.75rem
  lg: 1rem
  xl: 1.5rem
  full: 9999px
spacing:
  base: 8px
  container-padding: 20px
  element-gap: 12px
  section-margin: 32px
  bento-gutter: 16px
---

## Brand & Style

The design system is centered on the concept of "Digital Precision." It targets power users and professionals who require high-performance document utility tools that feel like premium hardware. The aesthetic blends **Minimalism** with sophisticated **Glassmorphism**, creating an interface that feels both spacious and technically advanced. 

The emotional goal is to instill a sense of calm efficiency through deep, light-absorbing backgrounds contrasted by "glowing" interactive elements. By utilizing a Bento box layout, the design system organizes complex utility functions into digestible, high-contrast visual clusters, mimicking the high-end feel of modern productivity dashboards.

## Colors

This design system utilizes a "Deep Obsidian" foundation to maximize visual depth and reduce eye strain. The palette is strictly dark-first, using layers of charcoal and navy-tinted grays to define hierarchy.

- **Primary Accent:** A vibrant gradient spanning Electric Violet (#8B5CF6) to Indigo (#6366F1). This is reserved for primary actions and critical status indicators.
- **Surface Palette:** Backgrounds use a true obsidian black, while cards and containers use a semi-transparent charcoal to allow for background blur effects.
- **Functional Colors:** Success and error states are handled with desaturated versions of green and red, ensuring they do not compete with the primary violet brand color.

## Typography

The typography relies on **Inter** for its technical precision and exceptional legibility in dark mode. The hierarchy is established through extreme weight contrast rather than size alone. 

Headlines use bold weights and tight letter spacing to feel "locked in" and professional. Body text remains medium-to-light weight with generous line heights to ensure readability against dark, blurred backgrounds. Small labels utilize uppercase styling with increased letter spacing to differentiate metadata from primary content.

## Layout & Spacing

The layout follows a **Bento Box** philosophy, utilizing a 4-column fluid grid that breaks down into modular tiles. Each tile acts as an independent container, allowing for a flexible "utility dashboard" feel.

Margins and gutters are generous to prevent the dark UI from feeling cramped. Elements within a Bento tile should follow a strict 8px base unit for internal padding, while the tiles themselves are separated by 16px gutters. This creates a rhythmic, structured appearance that feels engineered and precise.

## Elevation & Depth

Depth is conveyed through **Glassmorphism** and light-based signifiers rather than traditional shadows. 

1.  **Base Layer:** Solid obsidian (#020617).
2.  **Mantle Layer:** Bento tiles with a 40% opacity charcoal fill and a 20px background blur.
3.  **Accent Layer:** Subtle "inner glow" borders (1px width, 10-15% white or violet opacity) define the edges of containers, making them appear to float above the base.
4.  **Active State:** Elements in focus or active use should feature an outer bloom—a soft, low-opacity glow using the Electric Violet primary color to simulate light emission.

## Shapes

The shape language is "Soft-Tech." The standard radius for Bento tiles and main containers is 24px (`rounded-xl`), creating a sophisticated, friendly-yet-professional look. 

Smaller elements like buttons and input fields use a 12px-16px radius (`rounded-lg`) to maintain a consistent visual rhythm. The high roundedness helps soften the "technical" nature of the obsidian and violet color palette, making the app feel premium and approachable.

## Components

### Buttons
Primary CTAs use a linear gradient (#8B5CF6 to #6366F1) with white text. They should have a subtle outer glow that matches the gradient. Secondary buttons use a "ghost" style with a 1px glass border and semi-transparent fill.

### Bento Cards
The core of the UI. Each card must have a `backdrop-filter: blur(20px)` and a subtle 1px border. Titles within cards are always `label-caps` to provide a clear, technical header.

### Input Fields
Sleek, dark fields with a background 5% lighter than the base obsidian. On focus, the border transitions to a 1px Electric Violet glow. Placeholder text should be high-contrast but desaturated (e.g., 40% white).

### Bottom Navigation
A floating glass bar with high blur. Icons should be minimal line-art. The active state is indicated by a small violet dot beneath the icon and a change in icon stroke color to the primary gradient.

### Lists & Sliders
Lists utilize horizontal separators with 5% white opacity. Sliders feature a thick track and a prominent violet thumb that glows slightly, ensuring easy touch-targets and high visibility.