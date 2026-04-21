import { useEffect, useState } from "react";
import UsuarioCard from "./components/UsuarioCard"
import UsuarioForm from "./components/UsuarioForm";
import AsistenciaModal from "./components/AsistenciaModal";
import { eliminarUsuario, getUsuarios } from "./api/api";

export default function App() {
  const [usuarios, setUsuarios] = useState([]);
  const [selected, setSelected] = useState(null);

  useEffect(() => {
    loadUsuarios();
  }, []);

  async function loadUsuarios() {
    const data = await getUsuarios();
    setUsuarios(data);
  }

  async function handleEliminar(id) {
    await eliminarUsuario(id);
    loadUsuarios();
  }

  return (
    <div className="container">
      <h1>Gestión de Usuarios</h1>

      <UsuarioForm onCreated={loadUsuarios} />

      <div className="grid">
        {usuarios.map((u) => (
          <UsuarioCard
            key={u.id}
            usuario={u}
            onDelete={handleEliminar}
            onOpen={setSelected}
          />
        ))}
      </div>

      {selected && (
        <AsistenciaModal
          usuario={selected}
          onClose={() => setSelected(null)}
        />
      )}
    </div>
  );
}