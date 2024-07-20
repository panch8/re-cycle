import { DataTable } from "primereact/datatable"
import { Column } from "primereact/column"
import { useEffect, useState, useRef } from "react"
import { FilterMatchMode } from "primereact/api"
import { InputText } from "primereact/inputtext"
import { IconField } from "primereact/iconfield"
import { InputIcon } from "primereact/inputicon"
import { Dialog } from "primereact/dialog"
import { Button } from "primereact/button"
import { Toast } from "primereact/toast"


const columns = [
  { field: "canister_id", header: "Canister ID" },
  { field: "controllers", header: "Controllers", body: (elem) => elem.controllers.join("  : :   :  :  ") },
  { field: "enabled", header: "Enabled", rmSort: true },
  { field: "id", header: "ID" },
  { field: "module_hash", header: "Module Hash" },
  { field: "name", header: "Name" },
  { field: "subnet_id", header: "Subnet ID" },
  { field: "updated_at", header: "Updated At", body: (elem) => new Date(elem.updated_at).toLocaleString() },
  { field: "upgrades", header: "Upgrades" },
]

function createCommand(canisterId, action, network = '--ic') {
  switch (action) {
    case "start":
      return `dfx canister start ${canisterId} ${network === 'local' ? '' : network}`;
    case "stop":
      return `dfx canister stop ${canisterId} ${network === 'local' ? '' : network}`;
    case "delete":
      return `dfx canister delete ${canisterId} ${network === 'local' ? '' : network}`;
    default:
      return `dfx canister status ${canisterId} ${network === 'local' ? '' : network}`;
  }
};

function Table({ controlledCanisters, globalCanistersTotal }) {
  const [filters, setFilters] = useState({
    global: { value: null, matchMode: FilterMatchMode.CONTAINS },
    // name: { value: null, matchMode: FilterMatchMode.STARTS_WITH },
  });
  const [loading, setLoading] = useState(false);
  const [globalFilterValue, setGlobalFilterValue] = useState('');
  const [selectedCanister, setSelectedCanister] = useState(null);
  const [showDialog, setShowDialog] = useState(false);
  const toast = useRef(null);

  const onGlobalFilterChange = (e) => {
    const value = e.target.value;
    let _filters = { ...filters };

    _filters['global'].value = value;

    setFilters(_filters);
    setGlobalFilterValue(value);
  };

  const handleActionClick = async (e) => {
    const action = e.target.closest('button').id;
    const command = createCommand(selectedCanister.canister_id, action);
    try {
      await navigator.clipboard.writeText(command);
      toast.current.show({ severity: 'success', summary: 'Success', detail: 'Command copied to clipboard, Utilice this command in your CLI where you run the provided controller ID and execute requested action.\n Note: only stopped canisters can be deleted ', life: 3000 });
    } catch (error) {
      console.error('Failed to copy: ', error);
    }
    console.log(action);
  };

  const renderHeader = () => {
    return (
      <div className="flex justify-content-between">
        <h3>Controlled canisters found globaly on IC mainnet: <span>{globalCanistersTotal}</span></h3>
        <IconField iconPosition="left">
          <InputIcon className="pi pi-search" />
          <InputText value={globalFilterValue} onChange={onGlobalFilterChange} placeholder="Keyword Search" />
        </IconField>
      </div>
    );
  };

  return (
    <div className="mt-3">
      <Toast ref={toast} />
      <DataTable header={renderHeader()} value={controlledCanisters}
        removableSort
        size='small'
        paginator
        rows={10} stripedRows
        sortMode="multiple"
        filters={filters}
        filterDisplay="row"
        globalFilterFields={['canister_id', 'id', 'module_hash', 'subnet_id', 'updated_at', "controllers"]}
        selectionMode="single"
        selection={selectedCanister}
        onSelectionChange={(e) => setSelectedCanister(e.value)}
        dataKey="canister_id"
        onRowSelect={() => setShowDialog(true)}
        loading={loading}
        emptyMessage="No canisters found.">

        {columns.map((col, i) => (
          <Column key={col.field} field={col.field} header={col.header} className="datatable-cell" filter={false} filterElement={true} sortable={!col.rmSort} body={elem => {
            if (col.body) return col.body(elem);
            return elem[col.field];
          }} showFilterMenu={true} />
        ))}

      </DataTable>
      <Dialog visible={showDialog} style={{ width: '60vw' }} onHide={() => setShowDialog(false)} >
        <div className="flex justify-content-between">
          <h1>Canister Details</h1>
          <Button label="Start" id="start" size="small" className="p-button-success" onClick={(e => handleActionClick(e))} />
          <Button label="Stop" id="stop" size="small" className="p-button-warning" onClick={(e => handleActionClick(e))} />
          <Button label="Delete" id="delete" size="small" className="p-button-danger" onClick={(e => handleActionClick(e))} />
          <Button label="Status" id="status" size="small" className="p-button-info" onClick={(e => handleActionClick(e))} />

        </div>
        <p>Canister ID: {selectedCanister?.canister_id}</p>
        <p>Controllers: {selectedCanister?.controllers.join("  : :   :  :  ")}</p>
        <p>Enabled: {selectedCanister?.enabled}</p>
        <p>ID: {selectedCanister?.id}</p>
        <p>Module Hash: {selectedCanister?.module_hash}</p>
        <p>Name: {selectedCanister?.name}</p>
        <p>Subnet ID: {selectedCanister?.subnet_id}</p>
        <p>Updated At: {new Date(selectedCanister?.updated_at).toLocaleString()}</p>
        <p>Upgrades: {selectedCanister?.upgrades}</p>
      </Dialog>
    </div>
  )
}

export default Table
