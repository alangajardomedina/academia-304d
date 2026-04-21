import { useEffect, useState } from "react";
import { getAsistenciaPorUsuario, crearAsistencia, eliminarAsistencia} from "../api/api";
import "../styles/modal.css";

export default function AsistenciaModal({ usuario, onClose }) {
  const [asistencias, setAsistencias] = useState([]);

  useEffect(() => {
    load();
  }, []);

  async function load() {
    const data = await getAsistenciaPorUsuario(usuario.id);
    setAsistencias(data);
  }

  async function crear() {
    await crearAsistencia(usuario.id, {
      fecha: new Date().toISOString().split("T")[0],
      presente: true
    });
    load();
  }

  async function eliminar(id) {
    await eliminarAsistencia(id);
    load();
  }

  return (
    <div className="modal-overlay" onClick={onClose}>
      <div className="modal" onClick={(e) => e.stopPropagation()}>
        <h2>Asistencia - {usuario.nombre}</h2>

        <button className="primary" onClick={crear}>
          Agregar asistencia hoy
        </button>

        <ul className="lista">
          {asistencias.map((a) => (
            <li key={a.id}>
              <span>
                {a.fecha} - {a.presente ? "Presente" : "Ausente"}
              </span>

              <button
                className="danger"
                onClick={() => eliminar(a.id)}
              >
                borrar
              </button>
            </li>
          ))}
        </ul>

        <button onClick={onClose}>Cerrar</button>
      </div>
    </div>
  );
}