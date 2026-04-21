package cl.academia.backend.service;
import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import cl.academia.backend.model.Asistencia;
import cl.academia.backend.model.Usuario;
import cl.academia.backend.repository.AsistenciaRepository;
import cl.academia.backend.repository.UsuarioRepository;

@Service
public class AsistenciaService {

    @Autowired
    private AsistenciaRepository asistenciaRepository;

    @Autowired
    private UsuarioRepository usuarioRepository;

    public List<Asistencia> listar() {
        return asistenciaRepository.findAll();
    }

    public List<Asistencia> listarPorUsuario(Long usuarioId) {
        return asistenciaRepository.findByUsuarioId(usuarioId);
    }

    public Asistencia guardar(Long usuarioId, Asistencia asistencia) {
        Usuario usuario = usuarioRepository.findById(usuarioId)
            .orElseThrow(() -> new RuntimeException("Usuario no encontrado"));
        asistencia.setUsuario(usuario);
        return asistenciaRepository.save(asistencia);
    }

    public void eliminar(Long id) {
        asistenciaRepository.deleteById(id);
    }
}