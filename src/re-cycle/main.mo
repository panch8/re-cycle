import Debug "mo:base/Debug";
import Text "mo:base/Text";
import Principal "mo:base/Principal";
import Buffer "mo:base/Buffer";
import Error "mo:base/Error";



//Actor
actor {

  let _adminWhiteList : [Text] = [
    "peqgi-d5vlz-yq43p-iol25-vlp5p-bcvja-3taz3-tm45v-jzb4e-u4wlz-2qe",//fran.codino on mainnet candid UI
  ];

  public shared query ({caller})  func whoIsFrontEndCaller() : async Text {
    Principal.toText(caller);
  };


  public shared ({ caller }) func deleteMyCanister(canisterId: Principal, walletId: Principal) : async Text {

    assert( not Principal.isAnonymous(caller));
    //if the arguments are not equal then is assumed a walletID is being passed or a sort of orchestrator canister compliant with a certain, not defined, standard. with an updated interface including stopAndDeleteCanister(canisterID) methods. 
    if(not Principal.equal(canisterId, walletId)){
      
  
      // In this approach a wallet canister is assumed to be upgraded to a version that provides a stop_canister and delete_canister methods.

      let userWalletCanister = actor(Principal.toText(walletId)): actor{
        get_controllers: () -> async ([Principal]) ;
        stop_canister: (canisterId: Principal) -> async ();
        delete_canister: (canisterId: Principal) -> async ();
      };

      try{
        //in this call the Backend canister will be the caller so if it fails is because  the backend is not yet a controller of the wallet 1st control done:
        
        // is this(self) actor also controller of walletId? --implicitly checked by the call to the wallet actor

        let controllers = await userWalletCanister.get_controllers();
        let controllersBuffer = Buffer.fromArray<Principal>(controllers);

        

        //// is the caller a wallet controller?.... 
        assert (Buffer.contains<Principal>(controllersBuffer, caller, Principal.equal));

        var controllerString = "";

        Buffer.iterate<Principal>(controllersBuffer, func (x) {
          controllerString := Text.concat(controllerString, Principal.toText(x)); 
        
        });
        //stop and delete canister 
        await userWalletCanister.stop_canister(canisterId);

        await userWalletCanister.delete_canister(canisterId);

        return "Canister deleted" # controllerString;
      }
      catch (err) {
        
        return Error.message(err);
      };
    } else {
      ////////////////////////////////////////////////////////////
      ////////////////////////////////////////////////////////////
    

      //if the arguments are equal then is assumed that is an end canister to be deleted not an orchestrator such as a cycles wallet canister
      //the flow diverges a bit but this approach allows the Proof of concept feature to be implemented in a more general way.

      let ic = actor "aaaaa-aa": actor {
        stop_canister : shared { canister_id : Principal } -> async ();
        delete_canister : shared { canister_id : Principal } -> async ();
      };


      try {
        await ic.stop_canister({canister_id = canisterId});

        await ic.delete_canister({canister_id = canisterId});
        return "Canister stopped and deleted";
      } catch (err) {
        return Error.message(err);
    }};

  }; 







};