import { useEffect, useState } from 'react';
import { Button } from 'primereact/button';
import { InputText } from 'primereact/inputtext';
import { FloatLabel } from 'primereact/floatlabel';
import { getControlledCanisters } from './utils/icApiSwagger';
import Table from './components/Table';
import { useAuthClient } from './utils/hooks.';
import { Principal } from '@dfinity/principal';

// import { re_cycle } from '../../declarations/re-cycle';

// const subject = {
//   principalCaller: "acvcd-vgg3o-qftqn-7apsp-hm3gc-j5qza-u7kcz-2q6jn-3a5hu-iucqw-tae",
//   controlledCanisterList: [
//     {
//       canister_id: "2a2b2-xiaaa-aaaao-ajlkq-cai",
//       controllers: [
//         "fkvrp-syaaa-aaaao-aiajq-cai",
//         "acvcd-vgg3o-qftqn-7apsp-hm3gc-j5qza-u7kcz-2q6jn-3a5hu-iucqw-tae"
//       ],
//       enabled: true,
//       id: 89134,
//       module_hash: "db07e7e24f6f8ddf53c33a610713259a7c1eb71c270b819ebd311e2d223267f0",
//       name: "",
//       subnet_id: "o3ow2-2ipam-6fcjo-3j5vt-fzbge-2g7my-5fz2m-p4o2t-dwlc4-gt2q7-5ae",
//       updated_at: "2024-07-12T09:22:28.626783",
//       upgrades: null
//     },
//     {
//       canister_id: "2c2ea-6yaaa-aaaao-ajhgq-cai",
//       controllers: [
//         "fkvrp-syaaa-aaaao-aiajq-cai",
//         "acvcd-vgg3o-qftqn-7apsp-hm3gc-j5qza-u7kcz-2q6jn-3a5hu-iucqw-tae"
//       ],
//       enabled: true,
//       id: 77250,
//       module_hash: "c3445df9b29e39dc06bb3ed2a6f6dbeb549e0dade595f4e2d5cc191bfad65350",
//       name: "",
//       subnet_id: "o3ow2-2ipam-6fcjo-3j5vt-fzbge-2g7my-5fz2m-p4o2t-dwlc4-gt2q7-5ae",
//       updated_at: "2024-05-12T01:26:26.605217",
//       upgrades: null
//     },
//   ],


// }

function App() {
  const [requestedPrincipal, setRequestedPrincipal] = useState('');
  const [controlledCanisters, setControlledCanisters] = useState([]);
  const [globalCanistersTotal, setGlobalCanistersTotal] = useState(0);
  const { actor, signOut, signIn, userLogged } = useAuthClient();


  const handleLogClick = () => {
    if (userLogged) {
      signOut();
    } else {
      signIn();
    }
  };
  const handleClick = async () => {
    // const response = await re_cycle.greet("mate");
    const print = `The requested Principal id is: ${requestedPrincipal}`
    const response = await getControlledCanisters(requestedPrincipal);

    console.log(print);
    console.log(response);

    //MAKE BETTER handleing varius responses in batches. and concat them. 
    setControlledCanisters(response.data);
    setGlobalCanistersTotal(response.total_canisters)
  };



  return (
    <>
      <div className="justify-content-between mr-3 mt-2">
        {/* <img src="favicon.ico" alt="logo-dfinity" width={80} /> */}
        <Button label={`${userLogged ? "Sign Out" : "Sign In"}`} onClick={handleLogClick} className="btn-sign-in" severity="success" raised icon="pi pi-user" iconPos="right" />
      </div>
      <div className='card text-center'>
        <div className='card-title'>
          <img src='worldRecycle2.jpeg' width="20%" alt='re-cycle-logo' />
        </div>
        <div>
          <div className='card flex justify-content-center '>
            <FloatLabel className="mt-4 ">
              <InputText id="requestedPrincipal" value={requestedPrincipal} width="100%" onChange={(e) => setRequestedPrincipal(e.target.value)} />
              <label htmlFor="requestedPrincipal">Principal Identifier </label>
              <Button label="Submit" onClick={handleClick} className="btn-submit" severity="success" text raised icon="pi pi-check" iconPos="right" />
            </FloatLabel>
          </div>
          <small id="requestedPrincipal-info" >
            Enter the Principal ID to check its controlled canisters and list them.
          </small>
        </div>
        {controlledCanisters.length > 0
          && <Table controlledCanisters={controlledCanisters} globalCanistersTotal={globalCanistersTotal} />}
      </div >
    </>
  );
}

export default App;
