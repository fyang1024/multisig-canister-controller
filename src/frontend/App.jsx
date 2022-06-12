import React from 'react';
import Owners from './Owners';
import Canisters from './Canisters';
import { IdentityContextProvider } from './IdentityContext';
import LoginLogout from './LoginLogout';

function App() {
  return (
    <IdentityContextProvider>
      <LoginLogout />
      <Owners />
      <Canisters />
    </IdentityContextProvider>
  );
}

export default App;