# Treasure Gatherer App (TG Market)

A Flutter-based secondary market platform built around a sustainable electronics lifestyle. The application provides a structured marketplace where one person's decommissioned or defective hardware becomes another person's valuable core components.

---

## Project Concept

The platform is designed around a single core philosophy:
> **"Other's Trash is My Treasure, and My Trash is Other's Treasure"**

### The Core Mission
1. **Reduce E-Waste:** Offer an alternative to disposal by giving users a platform to pass down hardware they no longer need.
2. **Transparent Pre-Loved Hardware:** Provide budget-conscious buyers with functional goods backed by crystal-clear, transparent condition logging.
3. **The Engineer's Component Haven:** Serve as an active repository for developers, hardware engineers, and builders looking to harvest microcomponents, ICs, or casings from non-functional hardware.

---
UI Design from Figma:
> https://www.figma.com/design/gJwOnh2ps3oXtUV8AVgIlN/Mobile-Design?node-id=221-1864&t=3aGtP82ANGyWBgWs-1
---

## UX Principles Applied: User Authentication

The `features/landing/` and `features/auth/` modules utilize specific UX design principles to ensure a seamless, high-retention onboarding experience.

### 1. The Landing Page Flow (Onboarding)
* **Progressive Concept Disclosure:** Uses a 3-page interactive onboarding carousel (`smooth_page_indicator` with a `WormEffect`) to tell the app's story sequentially (Concept $\rightarrow$ Transparency $\rightarrow$ Component Harvesting) rather than overwhelming users on a single screen.
* **Persistent Friction Reduction:** A permanent `SKIP` action lets returning users bypass onboarding instantly, while contextual action changes (`LANJUT` dynamically switching to `MULAI` on the final panel) guide the user smoothly through completion.
* **State Persistence:** Integrated with `shared_preferences`. The onboarding screen is marked as completed (`isFirstTime = false`) upon reaching the login gate, saving device memory and keeping future entry flows direct.

### 2. Login Page Architecture
* **Unified Identifier Input:** The input field allows either an **Email** or **Username**, reducing cognitive load by removing the need for separate fields.
* **Inline Form Validation:** Employs Flutter’s reactive form validation state (`_formKey.currentState!.validate()`). Errors are caught locally before sending authentication data downstream, preventing unnecessary loading cycles.

### 3. Register Page Architecture & Password Defense-in-Depth
* **Real-time Local Constraint Mapping:** Password criteria are listed explicitly within the visual hierarchy rather than hidden behind an info tool-tip.
* **RegEx Validation Hooks:** Employs multiple regular expressions (`RegExp`) checking for:
  * Minimum 8 characters
  * Uppercase letter matching (`[A-Z]`)
  * Lowercase letter matching (`[a-z]`)
  * Numeric digit matching (`[0-9]`)
  * Special character structural scanning (`[!@#$%^&*(),.?":{}|<>]`)
* **Contextual Error Handlers:** If validation checks fail, a highly visible system alert dialog flashes the exact missing requirement to the user.
* **Localized Input Filters:** The phone input handles automated structural formatting, utilizing `FilteringTextInputFormatter.digitsOnly` alongside a persistent prefix (`+62`) to enforce region-locked inputs directly.

---

## Technical Architecture & Current Progress

### Folder Structure
```text
lib/
├── main.dart             # Core initialization & Shared Preferences router
├── core/
│   ├── constants/        # Style guides, text themes, and color definitions
│   └── shared_widgets/   # Reusable UI elements (custom buttons, cards)
└── features/
    ├── landing/          # Onboarding carousel with smooth indicators
    ├── auth/             # Login & Account Registration logic with JSON serialization
    ├── home/             # Unified item grid layout featuring announcement banners
    └── item_detail/      # Specific item metrics and systemic star reduction engine
