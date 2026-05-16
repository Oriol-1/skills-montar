# CONTEXT — Mejores Skills (template repo)

## Naturaleza del repo
Meta-template y catálogo curado de skills. No contiene código ejecutable
de producción: solo Markdown + bash de adaptador. Cumple dos roles:

1. **Catálogo curado listo para usar** en `.ai/skills/` (3 skills auditadas).
2. **Template reutilizable** para construir o instalar el catálogo en
   otros proyectos vía los slash commands `/audit-skills` y `/install-skills`.

## Stack

- Markdown como contenido principal.
- Bash puro (sin dependencias externas) para los adaptadores.
- Idioma del contenido: español.
- Sin gestor de paquetes, sin runtime, sin tests automáticos, sin CI.

## Estructura

- `.ai/skills/` — fuente de verdad (3 skills + CONTEXT + README).
- `.ai/adapters/claude-code/` — adaptador a `.claude/skills/`.
- `.ai/build-all.sh` — orquestador de adaptadores.
- `.claude/commands/audit-skills.md` — slash command para construir desde cero.
- `.claude/commands/install-skills.md` — slash command para copiar el catálogo.
- `prompts/audit-skills.prompt.md` — versión "prompt plano" de audit-skills.
- `prompts/install-skills.prompt.md` — versión "prompt plano" de install-skills.
- `.claude/skills/` — artefactos generados (gitignored).
- `.gitignore` — ignora artefactos generados por adaptadores.
- `README.md` — guía profunda de uso.

## Convenciones

- Markdown estricto: code fences con lenguaje, sin URLs desnudas, tablas alineadas.
- Un solo autor (Ori). Sin PRs ni revisión de pares formalizada.
- Repositorio en `main`, sin ramas activas.
- Los dos prompts maestros (`audit-skills`) y los dos de instalación
  (`install-skills`) llevan `SYNC NOTICE` cruzado: si editas uno, edita
  el otro.

## Flujo de trabajo

- Editar contenido **solo** en `.ai/skills/<name>/` y regenerar artefactos
  con `bash .ai/build-all.sh`.
- Nunca editar `.claude/skills/` directamente (se sobrescribe).
- Validación: lectura humana + markdownlint manual.

## Issue tracker
No declarado.

## Implicaciones para las skills

- `grill-me` y `diagnose` aplican principalmente a proyectos *descendentes*
  que adoptan el catálogo (este repo es texto, no código que depurar).
- `security-audit` sí aplica directamente: el repo es público potencial y
  podría contener URLs/credenciales filtradas en los prompts.
- Cualquier skill debe ser portable: el catálogo se copia/clona a otros
  proyectos vía `/install-skills`, que re-audita antes de copiar.
