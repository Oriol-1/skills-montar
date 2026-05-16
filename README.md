# skills-montar

Plantilla reutilizable de un **sistema de skills agnóstico de agente**: una
sola fuente de verdad en `.ai/skills/` + adaptadores ligeros que generan los
formatos nativos de Claude Code, Cursor, Codex, Copilot, Aider, etc.

## Qué incluye este repo

1. **Catálogo curado listo para usar** (`.ai/skills/`): 3 skills auditadas,
   una por cada fase del ciclo de trabajo:

   | Skill            | Cuándo dispara                           | Origen            |
   |------------------|------------------------------------------|-------------------|
   | `grill-me`       | Antes de codear, validar decisiones      | mattpocock/skills |
   | `diagnose`       | Algo falla, hay bug o regresión          | mattpocock/skills |
   | `security-audit` | Antes de release / hacer público el repo | propia (Anexo A)  |

2. **Adaptador Claude Code** (`.ai/adapters/claude-code/`) que genera
   `.claude/skills/<name>/SKILL.md`.

3. **Plantilla para nuevos proyectos** (`prompts/audit-skills.prompt.md` y
   `.claude/commands/audit-skills.md`): el prompt maestro que construye este
   sistema desde cero en cualquier repo, con auditoría de seguridad estricta
   y checkpoints humanos.

## Instalar las skills en este repo

```bash
bash .ai/build-all.sh
```

Genera `.claude/skills/{grill-me,diagnose,security-audit}/SKILL.md`. Los
artefactos están ignorados en `.gitignore`: la fuente de verdad es `.ai/`.

## Usar en otro proyecto

### Opción A — Copiar el catálogo curado tal cual

```bash
cp -r .ai/ /ruta/al/otro/proyecto/
cd /ruta/al/otro/proyecto
bash .ai/build-all.sh
```

Las 3 skills aparecen disponibles en el nuevo repo.

### Opción B — Construir un catálogo nuevo con el prompt maestro

1. Copia [`.claude/commands/audit-skills.md`](.claude/commands/audit-skills.md)
   al `.claude/commands/` del proyecto destino.
2. En Claude Code: `/audit-skills` (o `/audit-skills grill-me, diagnose`).
3. El comando audita, propone y construye con checkpoints humanos.

Alternativa sin slash command: pegar [`prompts/audit-skills.prompt.md`](prompts/audit-skills.prompt.md)
como mensaje en cualquier agente.

## Arquitectura

```text
.ai/
├── skills/                          ← FUENTE DE VERDAD (agnóstica)
│   ├── README.md
│   ├── CONTEXT.md                   ← diagnóstico del proyecto
│   ├── grill-me/        (SKILL.md + meta.yml)
│   ├── diagnose/        (SKILL.md + meta.yml)
│   └── security-audit/  (SKILL.md + meta.yml)
├── adapters/
│   └── claude-code/  (build.sh → .claude/skills/, clean.sh)
└── build-all.sh
```

Cambiar de Claude Code a Cursor (u otro) **no reescribe skills**: se añade
un nuevo adaptador en `.ai/adapters/`.

## Garantías de seguridad

- **Norma 0 innegociable**: ninguna skill se copia sin leer su `SKILL.md`
  completo y todos sus scripts.
- **Descarta automáticamente** skills con: `rm -rf`, `curl | sh`, `sudo`,
  modificaciones a `~/.ssh` / `~/.aws`, llamadas de red no documentadas,
  prompt injection, credenciales hardcodeadas, dependencias sin pinear o
  modificaciones fuera del repo.
- **Auditoría obligatoria** previa: Fase 3 para skills externas, Fase 3.B
  para skills propias con checkpoint de integridad del anexo.
- **Trazabilidad**: cada skill conserva el commit hash del origen, la fecha
  de adaptación y los cambios respecto al original (en `meta.yml`).
- **Stop gates** entre fases: nada se escribe sin confirmación explícita.
- **Sin instalación de dependencias** ni commits/push automáticos.

> **Ninguna skill, incluida `security-audit`, es 100% fiable sin revisión
> humana previa.** Las herramientas que orquesta tienen falsos negativos;
> la triaje y la decisión final corresponden al usuario.

## Mantenimiento

- Para añadir/modificar una skill: editar **solo** dentro de `.ai/skills/` y
  regenerar con `bash .ai/build-all.sh`.
- Para añadir un nuevo agente: crear `.ai/adapters/<agente>/build.sh` siguiendo
  el patrón de `claude-code/`. No tocar los artefactos generados.
- Los dos prompts maestros (`.claude/commands/audit-skills.md` y
  `prompts/audit-skills.prompt.md`) deben mantenerse en sync: si editas uno,
  edita el otro. Llevan un `SYNC NOTICE` en la cabecera como recordatorio.
