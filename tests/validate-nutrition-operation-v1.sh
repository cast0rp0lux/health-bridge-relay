#!/usr/bin/env bash
set -euo pipefail

file="$1"
uuid='^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$'
decimal='^(0|[0-9]+)(\.[0-9]+)?$'

jq -e \
  --arg uuid "$uuid" \
  --arg decimal "$decimal" '
  def uuid: type == "string" and test($uuid);
  def decimal: type == "string" and test($decimal);
  def meal: ["breakfast", "desayuno", "lunch", "comida", "almuerzo", "dinner", "cena", "snack"] | index(.) != null;
  def create:
    (keys | sort) as $keys |
    (["schemaVersion","operationId","operationType","type","id","name","kcal","protein","carbs","fat","meal","ts","fiber","sugar","sodium_mg"] | sort) as $allowed |
    ($keys - $allowed | length == 0) and
    .schemaVersion == "1" and .operationType == "create" and .type == "nutrition" and
    (.operationId | uuid) and (.id | type == "string" and length > 0 and length <= 128) and
    (.name | type == "string" and length > 0 and length <= 250) and
    (.kcal | decimal) and (.protein | decimal) and (.carbs | decimal) and (.fat | decimal) and
    (.ts | type == "string" and test("^[0-9]+$")) and
    (.meal as $meal | ["breakfast", "desayuno", "lunch", "comida", "almuerzo", "dinner", "cena", "snack"] | index($meal) != null) and
    ([.fiber?, .sugar?, .sodium_mg?] | all(. == null or decimal));
  def delete:
    (keys | sort) == ["operationId","operationType","schemaVersion","targetOperationId","type"] and
    .schemaVersion == "1" and .operationType == "delete" and .type == "nutrition" and
    (.operationId | uuid) and (.targetOperationId | uuid);
  if type == "object" and (create or delete) then . else error("invalid nutrition operation v1") end
' "$file" >/dev/null
