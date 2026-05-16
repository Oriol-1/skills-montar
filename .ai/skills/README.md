# `.ai/skills/` — Catálogo curado (fuente de verdad)

Tres skills, una por fase del ciclo de trabajo. Mutua exclusión estricta:
una skill no se activa en el dominio de otra.

| Skill            | Propósito                                                      | Cuándo dispara                          | Tags                  | Versión |
|------------------|----------------------------------------------------------------|------------------------------------------|------------------------|---------|
| `grill-me`       | Validar plan/decisión interrogando una pregunta a la vez.       | Antes de codear, ante decisiones.        | planning, design       | 1.0.0   |
| `diagnose`       | Bucle disciplinado: reproducir → hipótesis → fix → regression.  | Cuando algo falla / hay bug o regresión. | debugging, performance | 1.0.0   |
| `security-audit` | Auditoría read-only del repo orquestando herramientas locales.  | Antes de release / repo público.         | security, read-only    | 1.0.0   |

## Procedencia y auditoría

| Skill            | Origen                          | Commit auditado                            | Veredicto |
|------------------|---------------------------------|---------------------------------------------|-----------|
| `grill-me`       | mattpocock/skills (productivity)| `e74f0061bb67222181640effa98c675bdb2fdaa7`  | ✅ Segura |
| `diagnose`       | mattpocock/skills (engineering) | `e74f0061bb67222181640effa98c675bdb2fdaa7`  | ✅ Segura (adaptación menor: ref a otra skill eliminada) |
| `security-audit` | Propia                          | n/a                                         | ✅ Auto-auditada (Fase 3.B) |

## Cómo usar

1. Editar contenido **solo aquí** (`.ai/skills/<name>/SKILL.md` + `meta.yml`).
2. Regenerar artefactos por agente con `.ai/build-all.sh`.
3. Nunca editar los artefactos generados (`.claude/skills/`, etc.) — se sobrescriben.

## Aviso

> **Ninguna skill, incluida `security-audit`, es 100% fiable sin revisión
> humana previa.** Las herramientas que orquesta tienen falsos negativos;
> la triaje y la decisión final corresponden al usuario.
