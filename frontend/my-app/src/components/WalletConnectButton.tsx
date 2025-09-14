import React, { useState, useEffect } from 'react';
import { connectWallet, disconnectWallet, getUserSession } from '../services/stacksAuth';
import { UserData } from '@stacks/connect';

/**
 * A React component that provides a button to connect and disconnect a Stacks wallet.
 * It displays the user's address when connected and a "Connect Wallet" button when disconnected.
 * @returns {JSX.Element} The rendered WalletConnectButton component.
 */
const WalletConnectButton: React.FC = () => {
  /**
   * State to hold the user's data, or null if not logged in.
   * @type {[UserData | null, React.Dispatch<React.SetStateAction<UserData | null>>]}
   */
  const [userData, setUserData] = useState<UserData | null>(null);
  const userSession = getUserSession();

  useEffect(() => {
    if (userSession.isUserSignedIn()) {
      setUserData(userSession.loadUserData());
    }
  }, []);

  /**
   * Handles the wallet connection process.
   */
  const handleConnect = () => {
    connectWallet();
  };

  /**
   * Handles the wallet disconnection process.
   */
  const handleDisconnect = () => {
    disconnectWallet();
    setUserData(null);
  };

  if (userData) {
    // User is logged in
    const userAddress = userData.profile?.stxAddress?.testnet ?? userData.profile?.stxAddress?.mainnet;
    return (
      <div>
        <span>Connected as: {userAddress}</span>
        <button onClick={handleDisconnect} style={{ marginLeft: '10px' }}>
          Disconnect
        </button>
      </div>
    );
  }

  // If the user is logged out, display a connect button.
  return (
    <button onClick={handleConnect}>
      Connect Wallet
    </button>
  );
};

export default WalletConnectButton;
