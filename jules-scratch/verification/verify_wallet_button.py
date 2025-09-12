from playwright.sync_api import sync_playwright, expect

def run_verification():
    with sync_playwright() as p:
        browser = p.chromium.launch(headless=True)
        page = browser.new_page()

        try:
            # Navigate to the running application
            page.goto("http://localhost:5173")

            # Find the "Connect Wallet" button
            connect_button = page.get_by_role("button", name="Connect Wallet")

            # Assert that the button is visible
            expect(connect_button).to_be_visible()

            # Take a screenshot to visually confirm
            page.screenshot(path="jules-scratch/verification/wallet-button-visible.png")

            print("Verification successful: 'Connect Wallet' button is visible.")

        except Exception as e:
            print(f"An error occurred during verification: {e}")
            page.screenshot(path="jules-scratch/verification/verification-error.png")

        finally:
            browser.close()

if __name__ == "__main__":
    run_verification()
