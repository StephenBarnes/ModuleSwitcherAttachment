local typeToModuleInventory = {
	["assembling-machine"] = defines.inventory.assembling_machine_modules,
	["furnace"] = defines.inventory.furnace_modules,
	["rocket-silo"] = defines.inventory.rocket_silo_modules,
	["lab"] = defines.inventory.lab_modules,
	["beacon"] = defines.inventory.beacon_modules,
	["mining-drill"] = defines.inventory.mining_drill_modules,
} --[[@type {[string]: defines.inventory}]]

---@param ent LuaEntity
---@return {[1]: number, [2]: number}[]
local function getNeighboringTiles(ent)
	local results = {}
	local centerX = ent.position.x
	local centerY = ent.position.y
	local sizeX = ent.tile_width
	local sizeY = ent.tile_height
	-- Get tiles on top and bottom of entity.
	-- If sizeX = 3, sizeY = 3, then top tiles are {centerX-1, centerY-2}, {centerX, centerY-2}, {centerX+1, centerY-2}
	-- And then bottom tiles are {centerX-1, centerY+2}, {centerX, centerY+2}, {centerX+1, centerY+2}
	-- If sizeX = 1 and sizeY = 1, then top tile is {centerX, centerY-1}.
	for x = (centerX - (sizeX-1) / 2), (centerX + (sizeX-1) / 2) do
		table.insert(results, {x, centerY - (sizeY+1) / 2})
		table.insert(results, {x, centerY + (sizeY+1) / 2})
	end
	-- Get tiles on left and right of entity.
	for y = (centerY - (sizeY-1) / 2), (centerY + (sizeY-1) / 2) do
		table.insert(results, {centerX - (sizeX+1) / 2, y})
		table.insert(results, {centerX + (sizeX+1) / 2, y})
	end
	return results
end

---@param ent LuaEntity
---@return LuaEntity[]
local function getNeighboringEnts(ent)
	-- Once ent has been built, check all entities in neighboring tiles, excluding diagonals.
	local results = {}
	local surface = ent.surface
	for _, tile in ipairs(getNeighboringTiles(ent)) do
		local foundEnts = surface.find_entities_filtered{position = tile}
		for _, foundEnt in ipairs(foundEnts) do
			if foundEnt.valid then
				table.insert(results, foundEnt)
			end
		end
	end
	return results
end

---@param ent LuaEntity
local function handleAttachmentBuilt(ent)
	local neighboringEnts = getNeighboringEnts(ent)
	for _, neighboringEnt in ipairs(neighboringEnts) do
		local inventoryId = typeToModuleInventory[neighboringEnt.type]
		if inventoryId ~= nil then
			-- Only link to entities that have a module inventory.
			local moduleInventory = neighboringEnt.get_module_inventory()
			if moduleInventory then
				ent.proxy_target_entity = neighboringEnt
				ent.proxy_target_inventory = inventoryId
				return -- Return here, since each attachment can only link to one entity.
			end
		end
	end
end

---@param ent LuaEntity
local function handleMachineBuilt(ent)
	local moduleInventory = ent.get_module_inventory()
	if not moduleInventory then return end
	local inventoryId = typeToModuleInventory[ent.type]
	if inventoryId == nil then
		log("ERROR: " .. ent.name .. " has a module inventory, but is not in the typeToModuleInventory dict.")
		return
	end
	local neighboringEnts = getNeighboringEnts(ent)
	for _, neighboringEnt in ipairs(neighboringEnts) do
		if neighboringEnt.name == "module-attachment" and neighboringEnt.type == "proxy-container" then
			if neighboringEnt.proxy_target_entity == nil then -- If the attachment is already linked to a different entity, don't overwrite.
				neighboringEnt.proxy_target_entity = ent
				neighboringEnt.proxy_target_inventory = inventoryId
				-- Don't return, so we can link with other attachments too.
			end
		end
	end
end

---@param event EventData.on_built_entity|EventData.on_robot_built_entity|EventData.on_space_platform_built_entity|EventData.script_raised_built|EventData.script_raised_revive|EventData.on_entity_cloned
local function onBuilt(event)
	local ent = event.entity or event.destination
	if not ent or not ent.valid then
		return
	end
	-- Need to handle 2 cases: if attachment was built, or if machine next to attachment was built.
	if ent.name == "module-attachment" and ent.type == "proxy-container" then
		handleAttachmentBuilt(ent)
	else
		handleMachineBuilt(ent)
	end
end

for _, event in ipairs({
	defines.events.on_built_entity,
	defines.events.on_robot_built_entity,
	defines.events.on_space_platform_built_entity,
	defines.events.script_raised_built,
	defines.events.script_raised_revive,
	defines.events.on_entity_cloned,
}) do
	script.on_event(event, onBuilt)
end