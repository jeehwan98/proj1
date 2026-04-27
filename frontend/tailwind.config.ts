import type { Config } from "tailwindcss";

const config: Config = {
  content: ["./src/**/*.{js,ts,jsx,tsx,mdx}"],
  theme: {
    extend: {
      colors: {
        page: "var(--page)",
        surface: "var(--surface)",
        line: "var(--line)",
        "line-strong": "var(--line-strong)",
        "line-input": "var(--line-input)",
        ink: "var(--ink)",
        "ink-mid": "var(--ink-mid)",
        "ink-light": "var(--ink-light)",
        "ink-faint": "var(--ink-faint)",
        accent: "var(--accent)",
        "accent-hover": "var(--accent-hover)",
        "accent-fg": "var(--accent-fg)",
        ring: "var(--ring)",
      },
    },
  },
  plugins: [],
};

export default config;
