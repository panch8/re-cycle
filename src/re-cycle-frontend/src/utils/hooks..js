import { useState, useEffect } from 'react';
import { AuthClient } from '@dfinity/auth-client';

import { canisterId, createActor } from '../../../declarations/re-cycle';




export function useAuthClient() {
  const [authClient, setAuthClient] = useState();
  const [actor, setActor] = useState();
  const [userLogged, setUserLogged] = useState(false);

  async function signIn() {
    if (!authClient) return;
    console.log('signing in');
    try {

      await new Promise((resolve) => {
        authClient.login({
          identityProvider:
            process.env.DFX_NETWORK === 'ic'
              ? 'https://identity.ic0.app'
              : `http://${process.env.CANISTER_ID_INTERNET_IDENTITY}.localhost:4943`,
          onSuccess: () => {
            initActor();
            // setIsAuthenticated(true);
            resolve;
          },
        });
      });
    } catch (error) {
      setIsLoading(false);
      console.log('Error logging in', error);
    }
  }

  const initActor = () => {
    const identity = authClient.getIdentity();
    const actor = createActor(canisterId, {
      agentOptions: {
        identity,
      },
    });

    setActor(actor);
  };

  const signOut = () => {
    authClient?.logout();
    // setIsAuthenticated(false);
    setUserLogged(false);
    setActor(undefined);
  };

  //set authClient
  useEffect(() => {
    async function init() {

      try {
        const authClient = await AuthClient.create();
        console.log(
          'setting authclient',
          authClient.getIdentity().getPrincipal().toText()
        );
        setAuthClient(authClient);


      } catch (error) {

        console.log('Error creating AuthClient', error);
      }
    }
    init();
  }, []);

  // init ACtor
  useEffect(() => {
    if (!authClient) return setUserLogged(false);
    initActor();
    authClient.isAuthenticated().then((isAuthenticated) => {
      setUserLogged(isAuthenticated);
    });

  }, [authClient]);


  return {
    actor,
    signOut,
    signIn,
    userLogged
  };
}