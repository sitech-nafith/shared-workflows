import { defineConfig, devices } from '@playwright/test';

export default defineConfig({
  testDir: 'tests',
  testMatch: '**/*.spec.ts',
  fullyParallel: true,
  forbidOnly: !!process.env.CI,
  retries: 0,
  workers: 1,
  reporter: [['html', { outputFolder: 'playwright-report/chromium' }]],
  use: {
    // BASE_URL is injected by the shared workflow at runtime.
    // Falls back to example.com so the smoke test always has a reachable target.
    baseURL: process.env.BASE_URL || 'https://example.com',
    screenshot: 'only-on-failure',
    trace: 'on-first-retry',
  },
  timeout: 30000,
  projects: [
    {
      name: 'chromium',
      use: { ...devices['Desktop Chrome'] },
    },
  ],
});
