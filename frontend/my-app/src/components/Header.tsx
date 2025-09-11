import React from "react";
import styles from "../../styles/Header.module.css";

const Header: React.FC = () => {
  return (
    <header className={styles.header}>
      <div className={styles.logo}>Micro Influencers</div>
      <nav className={styles.nav}>
        <ul>
          <li><a href="#">Home</a></li>
          <li><a href="#">About</a></li>
          <li><a href="#">Campaigns</a></li>
          <li><a href="#">Rewards</a></li>
          <li><a href="#">Sign Up</a></li>
          <li><a href="#">Sign In</a></li>
          <li><a href="#">Menu</a></li>
        </ul>
      </nav>
    </header>
  );
};

export default Header;
