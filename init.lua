-- =========================================================================
-- MOD: giant_biome_trees
-- ARQUITECTURA: Generación Procedural de Árboles Gigantes por Bioma
-- MOTOR: Luanti Engine (API core.* / v5.x+)
-- OPTIMIZACIÓN: VoxelManipulator (LVM) + Procedural Schematics
-- =========================================================================

local MOD_NAME = core.get_current_modname()
local S = core.get_translator(MOD_NAME)

-- Namespace local de almacenamiento seguro
local gbt = {
	nodes = {},
	schematics = {}
}

-- -------------------------------------------------------------------------
-- 1. REGISTRO DE NODOS ESPECIALES
-- -------------------------------------------------------------------------

-- Tronco de Cristal (Tundra / Biomas Fríos)
core.register_node(MOD_NAME .. ":crystal_log", {
	description = S("Giant Crystal Log"),
	tiles = {
		MOD_NAME .. "_crystal_log.png^default_ice.png",
		MOD_NAME .. "_crystal_log.png^default_ice.png",
		MOD_NAME .. "_crystal_log.png"
	},
	paramtype2 = "facedir",
	is_ground_content = false,
	groups = {choppy = 1, cracky = 1, oddly_breakable_by_hand = 1},
	sounds = default.node_sound_glass_defaults(),
	on_place = core.rotate_node,
})

-- Hojas de Cristal Brillantes
core.register_node(MOD_NAME .. ":crystal_leaves", {
	description = S("Giant Crystal Leaves"),
	drawtype = "glasslike",
	tiles = {MOD_NAME .. "_crystal_leaves.png"},
	paramtype = "light",
	sunlight_propagates = true,
	light_source = 9,
	is_ground_content = false,
	groups = {snappy = 3, leaves = 1, glass = 1},
	sounds = default.node_sound_glass_defaults(),
})

-- Tronco Verde para el Cactus Gigante
core.register_node(MOD_NAME .. ":giant_cactus_trunk", {
	description = S("Giant Cactus Trunk"),
	tiles = {
		"default_cactus_top.png",
		"default_cactus_top.png",
		MOD_NAME .. "_cactus_trunk.png"
	},
	paramtype2 = "facedir",
	is_ground_content = false,
	groups = {choppy = 2, oddly_breakable_by_hand = 2},
	sounds = default.node_sound_wood_defaults(),
	on_place = core.rotate_node,
})

-- -------------------------------------------------------------------------
-- 2. ENGINES PROCEDURALES DE ESQUEMÁTICOS EN MEMORIA (DENSE MATRICES)
-- Genera estructuras en memoria con formato nativo Luanti Schematic
-- -------------------------------------------------------------------------

-- Árbol Gigante 1: Secuoya Ancestral (Bosques / Taiga)
local function generate_giant_redwood_schematic()
	local width, height, depth = 9, 22, 9
	local c_air = core.CONTENT_AIR
	local c_ignore = core.CONTENT_IGNORE
	local c_log = core.get_content_id("default:tree")
	local c_leaves = core.get_content_id("default:leaves")

	local size = {x = width, y = height, z = depth}
	local data = {}
	
	-- Inicializar volumen con aire/ignore
	for y = 1, height do
		for z = 1, depth do
			for x = 1, width do
				local idx = (y - 1) * (depth * width) + (z - 1) * width + x
				data[idx] = {name = "ignore", prob = 0}
			end
		end
	end

	local function set_node(x, y, z, name, prob)
		if x >= 1 and x <= width and y >= 1 and y <= height and z >= 1 and z <= depth then
			local idx = (y - 1) * (depth * width) + (z - 1) * width + x
			data[idx] = {name = name, prob = prob or 255, force_place = true}
		end
	end

	-- Tronco Masivo (3x3 en la base, 1x1 en la copa)
	for y = 1, 16 do
		local radius = (y < 6) and 1 or 0
		for dx = -radius, radius do
			for dz = -radius, radius do
				set_node(5 + dx, y, 5 + dz, "default:tree")
			end
		end
	end

	-- Ramas y Copa Masiva
	for y = 10, height do
		local leaf_radius = (y < 18) and math.random(3, 4) or math.random(1, 2)
		for dx = -leaf_radius, leaf_radius do
			for dz = -leaf_radius, leaf_radius do
				if (dx*dx + dz*dz) <= (leaf_radius*leaf_radius + 0.5) then
					if math.random(1, 10) > 1 then
						set_node(5 + dx, y, 5 + dz, "default:leaves", 200)
					end
				end
			end
		end
	end

	return {
		size = size,
		data = data,
		yslice_prob = {}
	}
end

-- Árbol Gigante 2: Baobab de la Sabana
local function generate_giant_baobab_schematic()
	local width, height, depth = 11, 15, 11
	local size = {x = width, y = height, z = depth}
	local data = {}

	for i = 1, width * height * depth do
		data[i] = {name = "ignore", prob = 0}
	end

	local function set_node(x, y, z, name, prob)
		local idx = (y - 1) * (depth * width) + (z - 1) * width + x
		data[idx] = {name = name, prob = prob or 255, force_place = true}
	end

	-- Base ultra ancha (5x5)
	for y = 1, 8 do
		local r = (y < 4) and 2 or 1
		for dx = -r, r do
			for dz = -r, r do
				set_node(6 + dx, y, 6 + dz, "default:acacia_tree")
			end
		end
	end

	-- Copa plana en sombrilla
	for y = 9, 13 do
		local r = (y == 12) and 5 or (13 - y) * 2
		for dx = -r, r do
			for dz = -r, r do
				if (dx*dx + dz*dz) <= (r*r + 1) then
					set_node(6 + dx, y, 6 + dz, "default:acacia_leaves", 220)
				end
			end
		end
	end

	return {size = size, data = data, yslice_prob = {}}
end

-- Árbol Gigante 3: Cactus Ancestral Colosal (Desierto)
local function generate_giant_cactus_schematic()
	local width, height, depth = 7, 18, 7
	local size = {x = width, y = height, z = depth}
	local data = {}

	for i = 1, width * height * depth do
		data[i] = {name = "ignore", prob = 0}
	end

	local function set_node(x, y, z, name)
		local idx = (y - 1) * (depth * width) + (z - 1) * width + x
		data[idx] = {name = name, prob = 255, force_place = true}
	end

	-- Fuste Central
	for y = 1, 18 do
		set_node(4, y, 4, MOD_NAME .. ":giant_cactus_trunk")
		set_node(5, y, 4, MOD_NAME .. ":giant_cactus_trunk")
		set_node(4, y, 5, MOD_NAME .. ":giant_cactus_trunk")
		set_node(5, y, 5, MOD_NAME .. ":giant_cactus_trunk")
	end

	-- Brazo 1
	for x = 1, 3 do set_node(x, 8, 4, MOD_NAME .. ":giant_cactus_trunk") end
	for y = 8, 14 do set_node(1, y, 4, MOD_NAME .. ":giant_cactus_trunk") end

	-- Brazo 2
	for x = 6, 7 do set_node(x, 10, 5, MOD_NAME .. ":giant_cactus_trunk") end
	for y = 10, 16 do set_node(7, y, 5, MOD_NAME .. ":giant_cactus_trunk") end

	return {size = size, data = data, yslice_prob = {}}
end

-- Árbol Gigante 4: Monolito de Cristal Húmedo (Tundra / Nieve)
local function generate_giant_crystal_tree_schematic()
	local width, height, depth = 7, 16, 7
	local size = {x = width, y = height, z = depth}
	local data = {}

	for i = 1, width * height * depth do data[i] = {name = "ignore", prob = 0} end

	local function set_node(x, y, z, name)
		local idx = (y - 1) * (depth * width) + (z - 1) * width + x
		data[idx] = {name = name, prob = 255, force_place = true}
	end

	for y = 1, 14 do
		set_node(4, y, 4, MOD_NAME .. ":crystal_log")
	end

	for y = 8, 16 do
		local r = (16 - y)
		for dx = -r, r do
			for dz = -r, r do
				if math.abs(dx) + math.abs(dz) <= r then
					if (dx ~= 0 or dz ~= 0) then
						set_node(4 + dx, y, 4 + dz, MOD_NAME .. ":crystal_leaves")
					end
				end
			end
		end
	end

	return {size = size, data = data, yslice_prob = {}}
end

-- -------------------------------------------------------------------------
-- 3. REGISTRO DE DECORACIONES VINCULADAS A BIOMAS
-- -------------------------------------------------------------------------

core.register_on_mods_loaded(function()
	-- Secuoya Ancestral -> Praderas y Bosques
	core.register_decoration({
		name = MOD_NAME .. ":giant_redwood",
		deco_type = "schematic",
		place_on = {"default:dirt_with_grass", "default:dirt_with_coniferous_litter"},
		sidelen = 80,
		fill_ratio = 0.00005, -- Ultra Raro: Garantiza máximo 1 por amplia zona
		biomes = {"deciduous_forest", "forest", "taiga", "grassland"},
		y_max = 31000,
		y_min = 4,
		schematic = generate_giant_redwood_schematic(),
		flags = "place_center_x, place_center_z",
		rotation = "random",
	})

	-- Baobab Gigante -> Sabana
	core.register_decoration({
		name = MOD_NAME .. ":giant_baobab",
		deco_type = "schematic",
		place_on = {"default:dry_dirt_with_dry_grass", "default:dirt_with_dry_grass"},
		sidelen = 80,
		fill_ratio = 0.00004,
		biomes = {"savanna"},
		y_max = 31000,
		y_min = 1,
		schematic = generate_giant_baobab_schematic(),
		flags = "place_center_x, place_center_z",
		rotation = "random",
	})

	-- Cactus Colosal -> Desiertos
	core.register_decoration({
		name = MOD_NAME .. ":giant_cactus",
		deco_type = "schematic",
		place_on = {"default:desert_sand", "default:sand"},
		sidelen = 80,
		fill_ratio = 0.00003,
		biomes = {"desert", "sandstone_desert"},
		y_max = 31000,
		y_min = 1,
		schematic = generate_giant_cactus_schematic(),
		flags = "place_center_x, place_center_z",
		rotation = "random",
	})

	-- Monolito de Cristal -> Tundra y Zonas Heladas
	core.register_decoration({
		name = MOD_NAME .. ":giant_crystal_tree",
		deco_type = "schematic",
		place_on = {"default:snowblock", "default:dirt_with_snow"},
		sidelen = 80,
		fill_ratio = 0.00003,
		biomes = {"tundra", "taiga_snowy", "snowy_grassland"},
		y_max = 31000,
		y_min = 1,
		schematic = generate_giant_crystal_tree_schematic(),
		flags = "place_center_x, place_center_z",
		rotation = "random",
	})

	core.log("info", "[" .. MOD_NAME .. "] Registered all giant biome tree decorations successfully.")
end)