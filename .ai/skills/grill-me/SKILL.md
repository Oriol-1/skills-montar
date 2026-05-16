# grill-me

<!-- Trazabilidad de origen, cambios y auditoría: ver meta.yml -->


## When to use
El usuario va a tomar una decisión de diseño, plan o arquitectura y quiere
que se la cuestionen a fondo antes de empezar a codear. Triggers léxicos:
"grill me", "stress-test este plan", "rómpeme esta idea", "valida esta
decisión", "¿qué se me escapa?".

No activar cuando ya hay un fallo concreto que depurar ni cuando se pide
auditoría de seguridad.

## What it does
Entrevista al usuario sobre cada aspecto del plan hasta alcanzar un
entendimiento compartido. Recorre el árbol de decisiones rama por rama,
resolviendo dependencias entre decisiones una a una.

## Inputs expected
- Un plan, diseño o decisión técnica que el usuario quiera validar.
- Acceso de lectura al repo para verificar suposiciones contra el código real.

## Process
1. Identificar las decisiones implícitas y explícitas en el plan.
2. Construir el árbol de dependencias entre esas decisiones.
3. Formular preguntas **una a una**, no en lote.
4. Para cada pregunta, proponer la respuesta recomendada con su razonamiento.
5. Si una pregunta puede responderse explorando el código del proyecto,
   explorarlo en lugar de preguntar al usuario.
6. Continuar hasta que todas las ramas relevantes estén resueltas y el plan
   final sea defendible.

## Output
- Lista de preguntas-respuestas resueltas (en la conversación).
- Plan final ajustado tras las respuestas, listo para implementar.

## Guardrails
- NUNCA pregunta en bloque: una pregunta por turno.
- NUNCA inventa suposiciones sobre el código sin verificarlas.
- NUNCA fuerza decisiones: propone, justifica y espera respuesta.
- NUNCA continúa hacia implementación sin "ok" explícito del usuario.

## Project context
Read `.ai/skills/CONTEXT.md` before applying this skill, to adapt questions
to the project's stack, conventions and constraints.
