# skills-montar

Plantilla reutilizable para auditar, adaptar e instalar **skills de Claude Code**
desde repos públicos (por defecto [`mattpocock/skills`](https://github.com/mattpocock/skills))
en cualquier proyecto, con auditoría de seguridad estricta y aprobación humana
antes de instalar nada.

## Cómo usarlo en cualquier proyecto

### Opción A — Slash command (recomendado)

1. Copia el archivo [`.claude/commands/audit-skills.md`](.claude/commands/audit-skills.md)
   a la carpeta `.claude/commands/` del proyecto destino (créala si no existe).
2. Abre Claude Code en ese proyecto y ejecuta:
   ```
   /audit-skills
   ```
   o, si quieres analizar skills concretas:
   ```
   /audit-skills grill-me, diagnose, plan
   ```
3. El comando ejecutará por fases: reconocimiento → auditoría de seguridad →
   análisis de compatibilidad → **se detendrá pidiendo confirmación** → instalación
   en `.claude/skills/` → verificación final.

### Opción B — Pegar el prompt directamente

Si prefieres no instalar el slash command, copia el contenido de
[`prompts/audit-skills.prompt.md`](prompts/audit-skills.prompt.md) y pégalo
como mensaje en cualquier chat de Claude Code (o adáptalo a otro agente).

## Garantías de seguridad del prompt

- **NORMA 0 innegociable**: ninguna skill se copia sin leer su `SKILL.md`
  completo y todos sus scripts asociados.
- **Descarta automáticamente** skills con: `rm -rf`, `curl | sh`, `sudo`,
  modificaciones a `~/.ssh` / `~/.aws`, llamadas de red no documentadas,
  prompt injection, credenciales hardcodeadas, dependencias sin pinear o
  modificaciones fuera del repo.
- **Clona el repo fuente en una ruta temporal fuera de tu proyecto** —
  nunca contamina el árbol del proyecto destino.
- **Stop gate humano** entre la fase de análisis y la de instalación: nada
  se escribe en `.claude/skills/` sin un `ok, procede` explícito.
- **Sin instalación de dependencias** ni commits/push automáticos.

## Estructura

```
.
├── .claude/
│   └── commands/
│       └── audit-skills.md      ← slash command /audit-skills
├── prompts/
│   └── audit-skills.prompt.md   ← versión "prompt plano" reutilizable
└── README.md
```
