package cl.academia.backend.controller;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.CrossOrigin;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import cl.academia.backend.model.Asistencia;
import cl.academia.backend.model.Usuario;
import cl.academia.backend.service.AsistenciaService;
import cl.academia.backend.service.UsuarioService;

@CrossOrigin(origins="*")
@RestController
@RequestMapping("/api")
public class AsistenciaController {

    @Autowired private UsuarioService usuarioService;
    @Autowired private AsistenciaService asistenciaService;

    // -- Usuarios --
    @GetMapping("/usuarios")
    public List<Usuario> listarUsuarios() {
        return usuarioService.listar();
    }

    @PostMapping("/usuarios")
    public Usuario crearUsuario(@RequestBody Usuario usuario) {
        return usuarioService.guardar(usuario);
    }

    @DeleteMapping("/usuarios/{id}")
    public void eliminarUsuario(@PathVariable Long id) {
        usuarioService.eliminar(id);
    }

    // -- Asistencias --
    @GetMapping("/asistencias")
    public List<Asistencia> listarAsistencias() {
        return asistenciaService.listar();
    }

    @GetMapping("/usuarios/{usuarioId}/asistencias")
    public List<Asistencia> listarPorUsuario(@PathVariable Long usuarioId) {
        return asistenciaService.listarPorUsuario(usuarioId);
    }

    @PostMapping("/usuarios/{usuarioId}/asistencias")
    public Asistencia crearAsistencia(@PathVariable Long usuarioId,
                                      @RequestBody Asistencia asistencia) {
        return asistenciaService.guardar(usuarioId, asistencia);
    }

    @DeleteMapping("/asistencias/{id}")
    public void eliminarAsistencia(@PathVariable Long id) {
        asistenciaService.eliminar(id);
    }
}