import React, { useState, useEffect } from 'react';
import { connectWallet, disconnectWallet, getUserSession } from '../services/stacksAuth';
import { UserData } from '@stacks/connect';

// This component provides a button to connect and disconnect a Stacks wallet.
const WalletConnectButton: React.FC = () => {
  // State to hold user data.
  const [userData, setUserData] = useState<UserData | null>(null);
  // Get the user session object.
  const userSession = getUserSession();

  // On component mount, check if the user is signed in and load their data.
  useEffect(() => {
    if (userSession.isUserSignedIn()) {
      setUserData(userSession.loadUserData());
    }
  }, []);

  // Function to handle wallet connection.
  const handleConnect = () => {
    connectWallet();
  };

  // Function to handle wallet disconnection.
  const handleDisconnect = () => {
    disconnectWallet();
    setUserData(null);
  };

  // If the user is logged in, display their address and a disconnect button.
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
