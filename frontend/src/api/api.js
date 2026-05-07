const API = "/api";

export async function getUsuarios() {
  const res = await fetch(`${API}/usuarios`);
  return res.json();
}

export async function crearUsuario(usuario) {
  const res = await fetch(`${API}/usuarios`, {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify(usuario),
  });
  return res.json();
}

export async function eliminarUsuario(id) {
  console.log(id)
  await fetch(`${API}/usuarios/${id}`, { method: "DELETE" });
}

export async function getAsistenciaPorUsuario(usuarioId) {
  const res = await fetch(`${API}/usuarios/${usuarioId}/asistencias`);
  return res.json();
}

export async function crearAsistencia(usuarioId, asistencia) {
  const res = await fetch(`${API}/usuarios/${usuarioId}/asistencias`, {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify(asistencia),
  });
  return res.json();
}

export async function eliminarAsistencia(id) {
  await fetch(`${API}/asistencias/${id}`, { method: "DELETE" });
}