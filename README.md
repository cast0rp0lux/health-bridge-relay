# Health Bridge Relay

Relay privado para enviar operaciones nutricionales versionadas desde GitHub a Health Bridge en Android mediante Firebase Cloud Messaging.

Flujo: ChatGPT → GitHub `inbox` → GitHub Actions → FCM → Health Bridge → Health Connect.

## Contrato v1

Cada archivo nuevo en `inbox/*.json` debe cumplir [el esquema v1](schema/nutrition-operation-v1.schema.json). El workflow lo valida antes de enviarlo y Android repite la validación antes de escribir.

Una creación exige `schemaVersion: "1"`, `operationType: "create"`, `operationId` UUID estable, `type: "nutrition"`, `id`, `name`, `kcal`, `protein`, `carbs`, `fat`, `meal` y `ts`. FCM transporta todos los valores como cadenas. Los macros son decimales no negativos; `fiber`, `sugar` y `sodium_mg` son opcionales. Los valores de `meal` incluyen `desayuno`, `comida` o `almuerzo`, `cena` y `snack`, además de sus equivalentes ingleses.

`ts` es Unix epoch en milisegundos. Para una orden que solo indique día y comida, el productor debe resolverla explícitamente en `Europe/Madrid` antes de crear el JSON; no se permite que Android invente fechas ni valores faltantes.

Una eliminación exige `operationType: "delete"`, su propio `operationId` y el `targetOperationId` de una creación anterior. Android solo borra un registro de nutrición que haya quedado registrado localmente por esta aplicación; no admite borrados por fecha, texto libre ni un identificador arbitrario.

Los JSON heredados sin `schemaVersion` u `operationId` son rechazados deliberadamente. Los secretos de Firebase nunca se guardan en este repositorio.
