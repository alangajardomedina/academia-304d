import { useState } from "react";
import { crearUsuario } from "../api/api";

export default function UsuarioForm({ onCreated }) {
  const [nombre, setNombre] = useState("");
  const [email, setEmail] = useState("");

  async function handleSubmit() {
    await crearUsuario({ nombre, email });
    setNombre("");
    setEmail("");
    onCreated();
  }

  return (
    <div className="form">
      <input
        placeholder="Nombre"
        value={nombre}
        onChange={(e) => setNombre(e.target.value)}
      />

      <input
        placeholder="Email"
        value={email}
        onChange={(e) => setEmail(e.target.value)}
      />

      <button onClick={handleSubmit}>Crear</button>
    </div>
  );
}