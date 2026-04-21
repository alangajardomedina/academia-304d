package cl.academia.backend.repository;

import org.springframework.data.jpa.repository.JpaRepository;

import cl.academia.backend.model.Usuario;

public interface UsuarioRepository extends JpaRepository<Usuario, Long> {}
