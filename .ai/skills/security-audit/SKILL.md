# security-audit

<!-- Trazabilidad de origen, cambios y auditoría: ver meta.yml -->


## When to use
El usuario pide auditar la seguridad del proyecto: buscar secrets o
credenciales expuestas, vulnerabilidades en código o dependencias,
configuraciones inseguras; revisar el repo antes de un release o antes
de hacerlo público.

No activar para bugs funcionales (eso es `diagnose`) ni para decisiones
de diseño (eso es `grill-me`).

## What it does
Orquesta herramientas locales de análisis estático (gitleaks, semgrep,
audits de dependencias del stack, trivy si aplica) para producir un
informe consolidado y priorizado de hallazgos. **No** modifica archivos.
**No** envía datos del proyecto fuera del entorno local.

## Inputs expected
- Acceso de **solo lectura** al repo.
- `.ai/skills/CONTEXT.md` para conocer el stack del proyecto.
- Permiso explícito del usuario antes de instalar herramientas que falten.
- **Conexión a internet** para que las herramientas consulten sus bases
  de datos de vulnerabilidades (npm/PyPI advisories, semgrep registry,
  trivy DB). Es red saliente esperada y documentada. En entornos
  air-gapped, el usuario lo indica y se saltan esas herramientas.

## Process
Lista **cerrada**. No se ejecutan comandos fuera de esta lista.

1. **Preflight**: leer `CONTEXT.md`. Determinar stack (Node, Python,
   Rust, Go, etc.) y si hay Dockerfile / IaC.
2. **Inventario de herramientas**: comprobar cuáles están instaladas
   (`which gitleaks`, `which semgrep`, `which trivy`, etc.). Listar
   las que faltan.
3. **Solicitar permiso** al usuario para instalar las faltantes, con
   el comando exacto y gestor sugerido (`brew`, `apt`, `pipx`, `cargo`,
   según OS). No instalar nada sin un "sí" explícito.
4. **Ejecutar herramientas instaladas**, en este orden, capturando
   output en `/tmp/security-audit-<timestamp>/`:
   a. `gitleaks detect --no-banner --redact --report-format json --report-path /tmp/.../gitleaks.json`
   b. `semgrep --config=auto --severity ERROR --severity WARNING --json --output /tmp/.../semgrep.json` (o `--config=p/ci` si el usuario pide set fijo sin descarga)
   c. Auditoría de dependencias según stack (`npm audit --json`, `pip-audit -f json`, `cargo audit --json`, `govulncheck ./...`).
   d. `trivy fs --scanners vuln,config,secret .` si aplica.
5. **Checks manuales adicionales** (sin ejecutar nada destructivo):
   - ¿`.gitignore` cubre `.env*`, `*.pem`, `*.key`, `id_rsa*`, `credentials*`?
   - ¿Hay archivos sensibles versionados? (`git ls-files | grep -iE '\.env|secret|credential|\.pem$|\.key$'`)
   - ¿Permisos de archivos sensibles si existen? (`ls -la`, sin abrir el contenido).
   - ¿`README` u otros docs filtran URLs internas, IPs, hostnames?
6. **Consolidar** todos los hallazgos en un informe único.
7. **Priorizar** por severidad: 🔴 CRÍTICO (secret expuesto, RCE, CVE
   crítico) / 🟠 ALTO / 🟡 MEDIO / 🔵 INFO.
8. **Filtrar false positives** evidentes con criterio (secrets dummy
   en tests, vulnerabilidades en dev dependencies que no llegan a
   producción). Justificar cada descarte.
9. **Proponer fixes** concretos por hallazgo, sin aplicarlos. Cada fix
   incluye: archivo, línea, cambio sugerido, comando de verificación.
10. **Limpiar**: borrar `/tmp/security-audit-<timestamp>/` o avisar al
    usuario de dónde está.

## Output
Informe Markdown entregado **en la conversación** (no escrito en el
repo salvo petición explícita). Estructura mínima:

- Encabezado: fecha + commit hash.
- Resumen por severidad: 🔴 críticos / 🟠 altos / 🟡 medios / 🔵 info.
- Tabla de herramientas ejecutadas (nombre · versión · estado · hallazgos).
- Bloque por hallazgo: severidad, `archivo:línea`, herramienta, regla,
  descripción de una frase, fix propuesto, comando de verificación.
- Lista de false positives descartados con justificación.
- Lista de herramientas no ejecutadas y motivo.
- 3-5 próximos pasos recomendados.

## Guardrails
- **NUNCA** modifica archivos del proyecto.
- **NUNCA** ejecuta comandos fuera de la lista cerrada del `Process`.
- **NUNCA** instala herramientas sin "sí" explícito del usuario en
  esta activación concreta.
- **NUNCA** abre el contenido de archivos identificados como sensibles
  (`.env`, claves, certificados). Solo verifica existencia y permisos.
- **NUNCA** envía resultados a servicios externos, ni los publica en
  gists, ni los sube a la nube.
- **NUNCA** cita el valor literal de un secret detectado en el informe.
  Solo archivo, línea y tipo. Usa placeholder `<redacted>` siempre.
- **NUNCA** confía en heurísticas propias del modelo para "detectar
  vulnerabilidades" sin que una herramienta determinista lo respalde.
  Si una herramienta no lo detectó, no se reporta como hallazgo (sí
  puede mencionarse como "consideración manual" en sección aparte).
- **NUNCA** hace `git push`, `git commit`, ni reescribe historial
  (`git filter-repo`, `git rebase`, etc.).
- Si una herramienta falla, lo reporta; no la sustituye por "análisis
  del modelo".
- **Recordatorio**: ninguna skill, incluida `security-audit`, es 100%
  fiable sin revisión humana previa. Las herramientas tienen falsos
  negativos; la triaje y la decisión final corresponden al usuario.

## Project context
Read `.ai/skills/CONTEXT.md` before running. Si el proyecto declara
restricciones específicas (p.ej. "no instalar binarios globales",
"entorno air-gapped"), respétalas.
