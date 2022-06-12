import React, { createContext, useState } from 'react';
import { backend } from "../declarations/backend";

const IdentityContext = createContext();

const IdentityContextProvider = (props) => {
  const [identity, setIdentity] = useState(null);
  const [actor, setActor] = useState(backend);
  return (
    <IdentityContext.Provider value={{ identity, setIdentity, actor, setActor }}>
      {props.children}
    </IdentityContext.Provider>
  )
}

export { IdentityContext, IdentityContextProvider }