import { Principal } from '@dfinity/principal';


const domain = "https://ic-api.internetcomputer.org/api/v3/"



/**
 * 
 * @param {*} principal as its text representations 
 * @returns axios response.data
 */
async function getControlledCanisters(principal) {
  let endpoint = "canisters"
  let queryString = `?controller_id=${principal}`

  const checkPoint = Principal.fromText(principal);

  if (!checkPoint._isPrincipal) throw new Error('Principal is not valid');
  if (!checkPoint.isAnonymous() === false) throw new Error('Principal is anonymous');

  const url = domain + endpoint + queryString;


  try {
    const response = await fetch(url);
    const data = await response.json();
    return data;
  } catch (error) {
    console.error(error);
    return error;
  }


};





export { getControlledCanisters };