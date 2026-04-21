import "../styles/card.css";

export default function UsuarioCard({ usuario, onDelete, onOpen }) {
  return (
    <div className="card">
      <h3>{usuario.nombre}</h3>
      <p>{usuario.email}</p>

      <div className="card-actions">
        <button onClick={() => onOpen(usuario)}>Ver</button>

        <button
          className="danger"
          onClick={() => onDelete(usuario.id)}
        >
          Eliminar
        </button>
      </div>
    </div>
  );
}