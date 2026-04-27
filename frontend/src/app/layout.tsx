import type { Metadata } from "next";
import type { ReactNode } from "react";
import { ThemeProvider } from "@/context/ThemeContext";
import { Toaster } from "sonner";
import "./globals.css";

export const metadata: Metadata = {
  title: "Authentication24",
};

export default function RootLayout({ children }: { children: ReactNode }) {
  return (
    <html lang="en" data-theme="light" suppressHydrationWarning>
      <head>
        <script dangerouslySetInnerHTML={{ __html: `try{document.documentElement.setAttribute('data-theme',localStorage.getItem('theme')||'light')}catch(e){}` }} />
      </head>
      <body className="antialiased bg-page text-ink">
        <ThemeProvider>
          {children}
          <Toaster position="top-right" richColors />
        </ThemeProvider>
      </body>
    </html>
  );
}
