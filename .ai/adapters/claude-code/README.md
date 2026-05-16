# Adapter: Claude Code

Genera `.claude/skills/<name>/SKILL.md` a partir de `.ai/skills/`.

## Instalar

```bash
bash .ai/adapters/claude-code/build.sh
```

Tras correr, las skills aparecen en `.claude/skills/` y Claude Code las
detecta automáticamente.

## Formato de salida

Cada `.claude/skills/<name>/SKILL.md` lleva:

1. Línea de cabecera obligatoria:
   `<!-- GENERATED FROM .ai/skills/<name> — DO NOT EDIT MANUALLY -->`
2. Frontmatter YAML con `name` y `description` extraídos de `meta.yml`.
3. Cuerpo: el contenido literal del `SKILL.md` neutral.

## Limpiar

```bash
bash .ai/adapters/claude-code/clean.sh
```

Solo borra archivos que llevan la cabecera `GENERATED`. No toca `.ai/`.

## Idempotencia

`build.sh` se puede correr múltiples veces sin efectos secundarios:
sobrescribe los mismos archivos con el mismo contenido.

## Requisitos

- bash 4+ (macOS/Linux nativos; Windows vía git-bash o WSL).
- coreutils estándar (`awk`, `cat`, `mkdir`, `head`, `grep`).
- Sin dependencias externas.
