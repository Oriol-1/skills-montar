# CONTEXT — Mejores Skills (template repo)

## Naturaleza del repo
Meta-template de prompts y skills. No contiene código ejecutable: solo Markdown.
Su output (el slash command `/audit-skills` y el prompt plano equivalente)
genera sistemas de skills en proyectos descendentes.

## Stack
- Solo Markdown. Sin gestor de paquetes, sin runtime, sin tests, sin CI.
- Idioma del contenido: español.

## Estructura
- `.claude/commands/audit-skills.md` — slash command para Claude Code.
- `prompts/audit-skills.prompt.md` — versión "prompt plano" portable.
- `README.md` — guía de uso.
- `.ai/skills/` — fuente de verdad de las skills curadas (este archivo y hermanos).

## Convenciones
- Markdown estricto: code fences con lenguaje, sin URLs desnudas, tablas alineadas.
- Un solo autor (Ori). Sin PRs ni revisión de pares formalizada.
- Repositorio en `main`, sin ramas activas.

## Flujo de trabajo
- Edición directa de Markdown.
- Sin build, sin tests automáticos.
- Validación: lectura humana + markdownlint manual.

## Issue tracker
No declarado.

## Implicaciones para las skills
- `diagnose` y `grill-me` aplican a proyectos *descendentes*, no a este repo.
- `security-audit` sí aplica directamente: el repo es público potencial y
  podría contener URLs/credenciales filtradas en los prompts.
- Cualquier skill debe ser portable: este repo se copia/clona a otros proyectos.
