# diagnose

<!-- Trazabilidad de origen, cambios y auditoría: ver meta.yml -->


## When to use
El usuario reporta un bug, regresión, comportamiento incorrecto o problema
de rendimiento. Triggers léxicos: "no funciona", "está roto", "falla",
"diagnostica esto", "debuggea", "lanza error", "más lento que antes".

No activar cuando se planifica una decisión nueva (ahí va `grill-me`) ni
cuando se pide auditoría de seguridad (ahí va `security-audit`).

## What it does
Aplica una disciplina por fases para resolver bugs difíciles:
reproducir → minimizar → hipotetizar → instrumentar → arreglar →
regression-test. Saltarse una fase requiere justificación explícita.

## Inputs expected
- Descripción del síntoma (error, output incorrecto, lentitud).
- Acceso de lectura al repo y, si existe, al entorno donde se reproduce.
- Permiso del usuario antes de aplicar cualquier fix.

## Process

### Fase 1 — Construir un bucle de feedback
**Esto es la skill.** Sin un bucle determinista y rápido que diga
pass/fail, el resto es adivinanza. Probar en este orden aproximado:

1. Test fallido en el seam que más se acerca al bug (unit/integration/e2e).
2. Script curl/HTTP contra un servidor dev en local.
3. Invocación CLI con fixture, diff de stdout contra snapshot conocido.
4. Script de navegador headless que dirige UI y verifica DOM/consola/red.
5. Replay de una traza capturada (HAR, payload, log).
6. Harness desechable: subset mínimo del sistema que invoca el bug.
7. Loop de propiedades/fuzz si el bug es "a veces da mal".
8. Harness de bisección para `git bisect run`.
9. Loop diferencial: misma entrada en versión antigua vs nueva.
10. Script human-in-the-loop como último recurso, estructurado.

Iterar sobre el bucle: hacerlo más rápido, más determinista, con señal
más afilada. Un bucle de 2s determinista vale más que uno de 30s flaky.

Para bugs no deterministas, el objetivo es **subir la tasa de reproducción**
hasta hacerla debuggeable (>50%), no lograr 100% al primer intento.

Si genuinamente no hay forma de construir un bucle: parar, decirlo,
listar lo intentado, y pedir al usuario acceso al entorno, una captura
(HAR, dump, grabación con timestamps) o permiso para instrumentar.
No proceder a hipotetizar sin bucle.

### Fase 2 — Reproducir
Correr el bucle, ver el bug. Confirmar:
- [ ] Reproduce el síntoma que describió el usuario, no uno cercano.
- [ ] Es reproducible en múltiples runs (o a tasa suficiente).
- [ ] Capturar la huella exacta (mensaje, output, timing).

### Fase 3 — Hipotetizar
Generar **3–5 hipótesis ranked** antes de probar ninguna. Cada hipótesis
debe ser **falsable**: "si X es la causa, cambiar Y hará desaparecer el
bug / cambiar Z lo empeorará". Si no se puede formular la predicción,
descartar la hipótesis o afinarla.

Mostrar la lista al usuario antes de probar: a menudo tiene contexto
("acabamos de deployar un cambio que toca eso") que reordena al instante.

### Fase 4 — Instrumentar
Cada probe mapea a una predicción concreta de la Fase 3. **Cambiar una
sola variable a la vez.**

Preferencia de herramientas:
1. Debugger / REPL si el entorno lo soporta — un breakpoint vale por 10 logs.
2. Logs dirigidos en los límites que distinguen hipótesis.
3. Nunca "loguear todo y filtrar".

**Tag obligatorio**: cada log debe llevar prefijo único, p.ej.
`[DEBUG-a4f2]`, para borrarlos todos en la limpieza con un solo grep.

Para regresiones de rendimiento, los logs son casi siempre la
herramienta equivocada: establecer baseline con harness de timing o
profiler, y bisecar. Medir primero, arreglar después.

### Fase 5 — Fix + regression test
Escribir el test **antes** del fix, **solo si existe un seam correcto**.

Un seam correcto ejercita el patrón real del bug en su sitio de llamada.
Si el único seam disponible es demasiado superficial, anotar la ausencia
de seam como hallazgo arquitectónico (no inventar un test que dé falsa
confianza).

Si hay seam correcto: failing test → fix → passing test → re-correr el
bucle de Fase 1 sobre el escenario original sin minimizar.

### Fase 6 — Cleanup + post-mortem
Antes de declarar terminado:
- [ ] El bucle de Fase 1 ya no reproduce.
- [ ] Regression test pasa (o ausencia de seam documentada).
- [ ] Toda instrumentación `[DEBUG-...]` eliminada (un grep del prefijo).
- [ ] Prototipos desechables borrados o aislados.
- [ ] La hipótesis ganadora citada en commit/PR — para el próximo que depure.

Preguntarse: **¿qué habría prevenido este bug?** Si la respuesta es
arquitectónica (sin seam, callers enredados, acoplamiento oculto),
recomendarlo al usuario tras el fix, no antes.

## Output
- Bug reproducido, fix aplicado, regression test (o ausencia documentada).
- Cleanup completo de instrumentación temporal.
- Hipótesis ganadora citada en el commit/PR.
- Recomendación arquitectónica si procede.

## Guardrails
- NUNCA proceder a hipotetizar sin un bucle de reproducción.
- NUNCA "loguear todo y filtrar": solo probes dirigidos a hipótesis.
- NUNCA escribir un regression test en un seam incorrecto: dar falsa
  confianza es peor que no tener test.
- NUNCA dejar logs `[DEBUG-...]` o prototipos sin borrar al cerrar.
- NUNCA cambiar más de una variable a la vez durante instrumentación.

## Project context
Read `.ai/skills/CONTEXT.md` before applying this skill. Adapt the feedback
loop construction to the project's stack (test runner, dev server, CLI),
and respect any debugging conventions documented there.
