import { AppConfig, UserSession, showConnect } from '@stacks/connect';

// Create a new AppConfig object. This is used to configure the application.
const appConfig = new AppConfig(['publish_data']);
// Create a new UserSession object. This is used to manage the user's session.
const userSession = new UserSession({ appConfig });

/**
 * Shows the Stacks connect pop-up to initiate wallet connection.
 */
export function connectWallet() {
  showConnect({
    appDetails: {
      name: 'My Stacks App',
      icon: window.location.origin + '/vite.svg', // Specify an icon for the wallet pop-up
    },
    redirectTo: '/',
    onFinish: () => {
      // Reload the page to update the UI after connection
      window.location.reload();
    },
    userSession,
  });
}

/**
 * Signs the user out and redirects to the homepage.
 */
export function disconnectWallet() {
  userSession.signUserOut('/');
}

/**
 * Retrieves the current user session object.
 * @returns {UserSession} The UserSession object for managing the user's session.
 */
export function getUserSession() {
  return userSession;
}

