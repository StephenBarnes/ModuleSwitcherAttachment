local ent = table.deepcopy(data.raw["logistic-container"]["buffer-chest"])
ent.name = "module-attachment"
ent.type = "proxy-container"
ent.icon = "__ModuleSwitcherAttachment__/graphics/icon.png"
ent.minable.result = "module-attachment"
ent.animation = nil
ent.picture = {
	layers = {
		{
			filename = "__ModuleSwitcherAttachment__/graphics/ent.png",
			width = 66,
			height = 74,
			scale = 0.5,
			shift = util.by_pixel(0, -3),
		},
		{
			filename = "__base__/graphics/entity/logistic-chest/logistic-chest-shadow.png",
			priority = "extra-high",
			width = 112,
			height = 46,
			shift = util.by_pixel(12, 4.5),
			draw_as_shadow = true,
			scale = 0.5
		}
	},
}
ent.corpse = "module-attachment-remnants"
data:extend{ent}

local remnants = table.deepcopy(data.raw["corpse"]["buffer-chest-remnants"])
remnants.name = "module-attachment-remnants"
remnants.icon = "__ModuleSwitcherAttachment__/graphics/icon.png"
remnants.animation.filename = "__ModuleSwitcherAttachment__/graphics/remnants.png"
data:extend{remnants}

local item = table.deepcopy(data.raw.item["buffer-chest"])
item.name = "module-attachment"
item.place_result = "module-attachment"
item.icon = "__ModuleSwitcherAttachment__/graphics/icon.png"
item.subgroup = data.raw.item["steel-chest"].subgroup or "storage"
item.order = (data.raw.item["steel-chest"].order or "a[items]-c[steel-chest]") .. "-2"
---@diagnostic disable-next-line: assign-type-mismatch
data:extend{item}

local recipe = table.deepcopy(data.raw.recipe["buffer-chest"])
recipe.name = "module-attachment"
recipe.icon = nil
recipe.results = {{type = "item", name = "module-attachment", amount = 1}}
recipe.ingredients = {
	{type = "item", name = "iron-plate", amount = 8},
	{type = "item", name = "electronic-circuit", amount = 2},
}
recipe.subgroup = nil
---@diagnostic disable-next-line: assign-type-mismatch
data:extend{recipe}