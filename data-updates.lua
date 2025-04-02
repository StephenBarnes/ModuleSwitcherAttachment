-- Add attachment's recipe to modules tech if it exists.
-- Doing this in data-updates since other mods might disable the tech in data.lua.
local recipe = data.raw.recipe["module-attachment"]
local tech = data.raw.technology["modules"]
if tech == nil or tech.hidden or tech.enabled == false then
	recipe.enabled = true
else
	recipe.enabled = false
	if tech.effects == nil then tech.effects = {} end
	table.insert(tech.effects, {type = "unlock-recipe", recipe = "module-attachment"})
end