import { AppConfig, UserSession, showConnect } from '@stacks/connect';

// Create a new AppConfig object. This is used to configure the application.
const appConfig = new AppConfig(['publish_data']);
// Create a new UserSession object. This is used to manage the user's session.
const userSession = new UserSession({ appConfig });

// This function shows the Stacks connect pop-up.
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

// This function signs the user out.
export function disconnectWallet() {
  userSession.signUserOut('/');
}

// This function returns the UserSession object.
export function getUserSession() {
  return userSession;
}

