import { AppConfig, UserSession, showConnect } from '@stacks/connect';

const appConfig = new AppConfig(['publish_data']);
const userSession = new UserSession({ appConfig });

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

export function disconnectWallet() {
  userSession.signUserOut('/');
}

export function getUserSession() {
  return userSession;
}
