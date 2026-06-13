import type { Config } from 'tailwindcss'

export default {
  darkMode: "class",
  content: ['./index.html', './src/**/*.{vue,js,ts,jsx,tsx}'],
  theme: {
    extend: {
      colors: {
        "primary-fixed-dim": "var(--color-primary-fixed-dim)",
        "secondary-fixed": "var(--color-secondary-fixed)",
        "on-primary": "var(--color-on-primary)",
        "inverse-surface": "var(--color-inverse-surface)",
        "on-primary-container": "var(--color-on-primary-container)",
        "on-tertiary-fixed": "var(--color-on-tertiary-fixed)",
        "primary-fixed": "var(--color-primary-fixed)",
        "outline-variant": "var(--color-outline-variant)",
        "on-tertiary-fixed-variant": "var(--color-on-tertiary-fixed-variant)",
        "surface-tint": "var(--color-surface-tint)",
        "on-surface-variant": "var(--color-on-surface-variant)",
        "on-primary-fixed-variant": "var(--color-on-primary-fixed-variant)",
        "surface-container": "var(--color-surface-container)",
        "tertiary-fixed": "var(--color-tertiary-fixed)",
        "on-secondary-fixed": "var(--color-on-secondary-fixed)",
        "error-container": "var(--color-error-container)",
        "surface-soft": "var(--color-surface-soft)",
        "tertiary": "var(--color-tertiary)",
        "on-secondary-container": "var(--color-on-secondary-container)",
        "inverse-on-surface": "var(--color-inverse-on-surface)",
        "inverse-primary": "var(--color-inverse-primary)",
        "on-primary-fixed": "var(--color-on-primary-fixed)",
        "on-background": "var(--color-on-background)",
        "border-subtle": "var(--color-border-subtle)",
        "primary": "var(--color-primary)",
        "success-muted": "var(--color-success-muted)",
        "error": "var(--color-error)",
        "tertiary-fixed-dim": "var(--color-tertiary-fixed-dim)",
        "surface-container-lowest": "var(--color-surface-container-lowest)",
        "outline": "var(--color-outline)",
        "on-secondary": "var(--color-on-secondary)",
        "on-surface": "var(--color-on-surface)",
        "tertiary-container": "var(--color-tertiary-container)",
        "surface-container-low": "var(--color-surface-container-low)",
        "on-secondary-fixed-variant": "var(--color-on-secondary-fixed-variant)",
        "surface-bright": "var(--color-surface-bright)",
        "surface": "var(--color-surface)",
        "secondary": "var(--color-secondary)",
        "secondary-container": "var(--color-secondary-container)",
        "on-tertiary": "var(--color-on-tertiary)",
        "on-tertiary-container": "var(--color-on-tertiary-container)",
        "surface-container-highest": "var(--color-surface-container-highest)",
        "secondary-fixed-dim": "var(--color-secondary-fixed-dim)",
        "primary-container": "var(--color-primary-container)",
        "on-error": "var(--color-on-error)",
        "surface-container-high": "var(--color-surface-container-high)",
        "surface-dim": "var(--color-surface-dim)",
        "surface-variant": "var(--color-surface-variant)",
        "background": "var(--color-background)",
        "on-error-container": "var(--color-on-error-container)"
      },
      borderRadius: {
        "sm": "0.25rem",
        "DEFAULT": "0.5rem",
        "md": "0.75rem",
        "lg": "1rem",
        "xl": "1.5rem",
        "full": "9999px"
      },
      spacing: {
        "base": "8px",
        "container-max": "1280px",
        "gutter": "24px",
        "margin-desktop": "64px",
        "margin-tablet": "32px",
        "margin-mobile": "16px"
      },
      boxShadow: {
        "level-1": "0px 4px 20px rgba(0,0,0,0.04)",
        "level-2": "0px 8px 30px rgba(0,0,0,0.08)",
      },
      fontFamily: {
        "headline-xl": ["Hanken Grotesk", "sans-serif"],
        "headline-lg": ["Hanken Grotesk", "sans-serif"],
        "headline-lg-mobile": ["Hanken Grotesk", "sans-serif"],
        "headline-md": ["Hanken Grotesk", "sans-serif"],
        "body-lg": ["Inter", "sans-serif"],
        "body-md": ["Inter", "sans-serif"],
        "body-sm": ["Inter", "sans-serif"],
        "label-md": ["Inter", "sans-serif"],
        "label-sm": ["Inter", "sans-serif"]
      },
      fontSize: {
        "headline-xl": ["3rem", { lineHeight: "3.5rem", letterSpacing: "-0.02em", fontWeight: "700" }],
        "headline-lg": ["2rem", { lineHeight: "2.5rem", letterSpacing: "-0.01em", fontWeight: "600" }],
        "headline-lg-mobile": ["1.75rem", { lineHeight: "2.25rem", fontWeight: "600" }],
        "headline-md": ["1.5rem", { lineHeight: "2rem", fontWeight: "600" }],
        "body-lg": ["1.125rem", { lineHeight: "1.75rem", fontWeight: "400" }],
        "body-md": ["1rem", { lineHeight: "1.5rem", fontWeight: "400" }],
        "body-sm": ["0.875rem", { lineHeight: "1.25rem", fontWeight: "400" }],
        "label-md": ["0.875rem", { lineHeight: "1rem", letterSpacing: "0.05em", fontWeight: "600" }],
        "label-sm": ["0.75rem", { lineHeight: "1rem", fontWeight: "500" }]
      }
    }
  },
  plugins: [
    require('@tailwindcss/container-queries'),
    require('@tailwindcss/forms')
  ]
} satisfies Config
