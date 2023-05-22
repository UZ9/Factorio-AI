--item.lua

local aiArmor = table.deepcopy(data.raw.armor["light-armor"])

aiArmor.name = "ai-armor"
-- aiArmor.icon= aiArmordww

aiArmor.resistances = {
   {
      type = "physical",
      decrease = 6,
      percent = 10
   },
   {
      type = "explosion",
      decrease = 10,
      percent = 30
   },
   {
      type = "acid",
      decrease = 5,
      percent = 30
   },
   {
      type = "fire",
      decrease = 0,
      percent = 100
   },
}

local recipe = table.deepcopy(data.raw.recipe["light-armor"])
recipe.enabled = true
recipe.name = "ai-armor"
recipe.ingredients = {{"iron-plate",1}}
recipe.result = "ai-armor"

data:extend{aiArmor,recipe}
