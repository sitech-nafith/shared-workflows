import { test, expect } from '@playwright/test';

// Minimal smoke test — validates the shared playwright.yml workflow mechanics,
// not any real application. Uses example.com (IANA-reserved, always 200).
test('page loads successfully', async ({ page }) => {
  const response = await page.goto('https://example.com');
  expect(response?.status()).toBeLessThan(400);
  await expect(page).toHaveTitle(/Example Domain/);
});
