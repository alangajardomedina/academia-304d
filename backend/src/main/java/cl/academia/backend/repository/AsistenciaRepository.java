package cl.academia.backend.repository;

import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;

import cl.academia.backend.model.Asistencia;

public interface AsistenciaRepository extends JpaRepository<Asistencia, Long> {
    List<Asistencia> findByUsuarioId(Long usuarioId);
}
