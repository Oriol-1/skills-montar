# skills-montar

Plantilla reutilizable de un **sistema de skills agnóstico de agente**: una
sola fuente de verdad en `.ai/skills/` + adaptadores ligeros que generan los
formatos nativos de Claude Code, Cursor, Codex, Copilot, Aider, etc.

El prompt incluye:

- **Diagnóstico previo del proyecto** (Fase 1) → `.ai/skills/CONTEXT.md`.
- **Auditoría de seguridad estricta** de las skills externas (Norma 0 innegociable).
- **Checkpoints humanos** entre cada fase: nada se escribe sin tu `ok, procede`.
- **Arquitectura agnóstica**: el contenido se escribe una vez en `.ai/skills/`
  y los adaptadores lo traducen a `.claude/skills/`, `.cursor/rules/`,
  `AGENTS.md`, `.github/copilot-instructions.md`, `CONVENTIONS.md`, etc.
- **Trazabilidad**: cada skill adaptada conserva el commit hash del origen,
  la fecha de auditoría y los cambios respecto al original.

## Cómo usarlo en cualquier proyecto

### Opción A — Slash command (recomendado para Claude Code)

1. Copia [`.claude/commands/audit-skills.md`](.claude/commands/audit-skills.md)
   a `.claude/commands/` del proyecto destino (créala si no existe).
2. En Claude Code, ejecuta:

   ```
   /audit-skills
   ```

   o con skills concretas:

   ```
   /audit-skills grill-me, diagnose
   ```

3. El comando ejecuta por fases:
   1. **Diagnóstico del proyecto** → `CONTEXT.md` 🛑
   2. **Reconocimiento del repo fuente** (`mattpocock/skills` clonado en `/tmp/`)
   3. **Auditoría de seguridad** (una skill a la vez)
   4. **Análisis de compatibilidad** 🛑
   5. **Skills neutrales en `.ai/skills/`** 🛑
   6. **Adaptadores en `.ai/adapters/<agente>/`** 🛑
   7. **Verificación final** (idempotencia, checklist de seguridad)

### Opción B — Pegar el prompt directamente

Si usas otro agente (Cursor, Codex, ChatGPT…) o no quieres instalar el slash
command, copia [`prompts/audit-skills.prompt.md`](prompts/audit-skills.prompt.md)
y pégalo como mensaje. Funciona igual de bien.

## Arquitectura objetivo que el prompt construye

```
.ai/
├── skills/                          ← FUENTE DE VERDAD (agnóstica)
│   ├── README.md
│   ├── CONTEXT.md                   ← diagnóstico del proyecto
│   ├── <skill-name>/
│   │   ├── SKILL.md                 ← contenido neutral
│   │   └── meta.yml
│   └── ...
├── adapters/
│   ├── claude-code/  (build.sh → .claude/skills/)
│   ├── cursor/       (build.sh → .cursor/rules/)
│   ├── codex/        (build.sh → AGENTS.md)
│   ├── copilot/      (build.sh → .github/copilot-instructions.md)
│   └── aider/        (build.sh → CONVENTIONS.md)
└── build-all.sh
```

Cambiar de Claude Code a Cursor (u otro) **no reescribe skills**: regeneras
los adaptadores con `.ai/build-all.sh`.

## Garantías de seguridad

- **Norma 0 innegociable**: ninguna skill se copia sin leer su `SKILL.md`
  completo y todos sus scripts.
- **Descarta automáticamente** skills con: `rm -rf`, `curl | sh`, `sudo`,
  modificaciones a `~/.ssh` / `~/.aws`, llamadas de red no documentadas,
  prompt injection, credenciales hardcodeadas, dependencias sin pinear o
  modificaciones fuera del repo.
- **Clona el repo fuente en una ruta temporal fuera de tu proyecto**.
- **Stop gates** entre fases — nada se escribe sin tu confirmación explícita.
- **Sin instalación de dependencias** ni commits/push automáticos.

## Estructura de este repo

```
.
├── .claude/
│   └── commands/
│       └── audit-skills.md      ← slash command /audit-skills
├── prompts/
│   └── audit-skills.prompt.md   ← versión "prompt plano" reutilizable
└── README.md
```
