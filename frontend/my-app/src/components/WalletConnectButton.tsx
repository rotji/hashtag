import React, { useState, useEffect } from 'react';
import { connectWallet, disconnectWallet, getUserSession } from '../services/stacksAuth';
import { UserData } from '@stacks/connect';

const WalletConnectButton: React.FC = () => {
  const [userData, setUserData] = useState<UserData | null>(null);
  const userSession = getUserSession();

  useEffect(() => {
    if (userSession.isUserSignedIn()) {
      setUserData(userSession.loadUserData());
    }
  }, []);

  const handleConnect = () => {
    connectWallet();
  };

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

  // User is logged out
  return (
    <button onClick={handleConnect}>
      Connect Wallet
    </button>
  );
};

export default WalletConnectButton;