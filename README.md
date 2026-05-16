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

### Opción A (recomendada) — Slash command `/install-skills`

1. Copia [`.claude/commands/install-skills.md`](.claude/commands/install-skills.md)
   al `.claude/commands/` del proyecto destino.
2. En Claude Code dentro del destino:

   ```text
   /install-skills
   ```

   o con subset:

   ```text
   /install-skills grill-me, diagnose
   ```

3. El comando ejecuta 8 fases con checkpoints humanos:
   1. Diagnóstico del proyecto destino → `.ai/skills/CONTEXT.md` local 🛑
   2. Clonar este repo a ruta temporal.
   3. Filtrar + escanear conflictos (sin sobrescribir nada sin permiso).
   4. Re-auditar cada skill candidata en contexto local 🛑
   5. Copiar `meta.yml` + `SKILL.md` al destino (no copia `CONTEXT.md` ni README del fuente).
   6. Append idempotente a `.gitignore` (preguntando antes).
   7. Build + verificación de idempotencia.
   8. Reporte final.

   Garantías: no toca nada fuera de `.ai/`, `.claude/skills/` y `.gitignore`;
   no instala dependencias; no hace `git commit`/`git push`.

### Opción B — Pegar el prompt plano

Si usas otro agente o no quieres instalar el slash command, copia
[`prompts/install-skills.prompt.md`](prompts/install-skills.prompt.md) y
pégalo como mensaje. Hace lo mismo.

### Opción C — Construir un catálogo nuevo desde cero

Para empezar con un catálogo distinto al curado, usa el prompt maestro:
[`.claude/commands/audit-skills.md`](.claude/commands/audit-skills.md) o
[`prompts/audit-skills.prompt.md`](prompts/audit-skills.prompt.md). Audita,
propone y construye con checkpoints. Más pesado que `install-skills` pero
útil si quieres meter skills nuevas.

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
