-- Giant Biome Trees
-- Estructuras grandes, válidas y muy poco frecuentes para el mapgen de Luanti.

local MOD_NAME = core.get_current_modname()
local S = core.get_translator(MOD_NAME)

-- Los datos de un schematic deben estar indexados como X + Z * width +
-- Y * width * depth. Mantener esta función aquí evita los desbordamientos
-- que provocaban bloques fuera de sitio en las versiones anteriores.
local function new_schematic(width, height, depth)
	local data = {}

	for i = 1, width * height * depth do
		-- prob = 0 deja el volumen vacío y no borra el terreno.
		data[i] = {
			name = "air",
			prob = 0
		}
	end

	local function put(x, y, z, name, prob)
		if x < 1 or x > width
		or y < 1 or y > height
		or z < 1 or z > depth then
			return
		end

		local index =
			(y - 1) * width * depth +
			(z - 1) * width +
			x

		data[index] = {
			name = name,
			prob = prob or 255
		}
	end

	return data, put
end

local function schematic(width, height, depth, data)
	return {
		size = {
			x = width,
			y = height,
			z = depth
		},
		data = data,
		yslice_prob = {}
	}
end

-- =========================================================
-- NODOS PROPIOS DEL MOD
-- =========================================================

core.register_node(MOD_NAME .. ":crystal_log", {
	description = S("Giant Crystal Log"),

	tiles = {
		MOD_NAME .. "_crystal_log.png^default_ice.png",
		MOD_NAME .. "_crystal_log.png^default_ice.png",
		MOD_NAME .. "_crystal_log.png"
	},

	paramtype2 = "facedir",
	is_ground_content = false,

	groups = {
		choppy = 1,
		cracky = 1,
		oddly_breakable_by_hand = 1
	},

	sounds = default.node_sound_glass_defaults(),
	on_place = core.rotate_node
})

core.register_node(MOD_NAME .. ":crystal_leaves", {
	description = S("Giant Crystal Leaves"),

	drawtype = "glasslike",
	tiles = {
		MOD_NAME .. "_crystal_leaves.png"
	},

	paramtype = "light",
	sunlight_propagates = true,
	light_source = 9,
	is_ground_content = false,

	groups = {
		snappy = 3,
		leaves = 1,
		glass = 1
	},

	sounds = default.node_sound_glass_defaults()
})

core.register_node(MOD_NAME .. ":giant_cactus_trunk", {
	description = S("Giant Cactus Trunk"),

	tiles = {
		"default_cactus_top.png",
		"default_cactus_top.png",
		MOD_NAME .. "_cactus_trunk.png"
	},

	paramtype2 = "facedir",
	is_ground_content = false,

	groups = {
		choppy = 2,
		oddly_breakable_by_hand = 2
	},

	sounds = default.node_sound_wood_defaults(),
	on_place = core.rotate_node
})

-- =========================================================
-- SECUOYA GIGANTE
-- =========================================================

local function redwood()
	local width = 13
	local height = 27
	local depth = 13

	local data, put = new_schematic(width, height, depth)

	local log = "default:tree"
	local leaves = "default:leaves"

	-- Tronco principal continuo.
	for y = 1, 19 do
		local radius

		if y <= 6 then
			radius = 2
		elseif y <= 12 then
			radius = 1
		else
			radius = 0
		end

		for dx = -radius, radius do
			for dz = -radius, radius do
				put(7 + dx, y, 7 + dz, log)
			end
		end
	end

	-- Ramas conectadas al tronco.
	for x = 3, 6 do
		put(x, 12, 7, log)
	end

	for x = 8, 11 do
		put(x, 15, 7, log)
	end

	for z = 3, 6 do
		put(7, 14, z, log)
	end

	for z = 8, 11 do
		put(7, 17, z, log)
	end

	-- Copa redondeada.
	for y = 11, height do
		local radius

		if y <= 17 then
			radius = 5
		elseif y <= 22 then
			radius = 4
		else
			radius = 2
		end

		for dx = -radius, radius do
			for dz = -radius, radius do
				if dx * dx + dz * dz <= radius * radius + 1 then
					-- No tapa completamente el tronco.
					if not (
						math.abs(dx) <= 1
						and math.abs(dz) <= 1
						and y <= 19
					) then
						put(
							7 + dx,
							y,
							7 + dz,
							leaves,
							y < 24 and 235 or 255
						)
					end
				end
			end
		end
	end

	return schematic(width, height, depth, data)
end

-- =========================================================
-- BAOBAB GIGANTE
-- =========================================================

local function baobab()
	local width = 15
	local height = 19
	local depth = 15

	local data, put = new_schematic(width, height, depth)

	-- Tronco muy ancho.
	for y = 1, 12 do
		local radius

		if y <= 5 then
			radius = 3
		elseif y <= 9 then
			radius = 2
		else
			radius = 1
		end

		for dx = -radius, radius do
			for dz = -radius, radius do
				if dx * dx + dz * dz <= radius * radius + 1 then
					put(
						8 + dx,
						y,
						8 + dz,
						"default:acacia_tree"
					)
				end
			end
		end
	end

	-- Ramas inferiores.
	for x = 3, 7 do
		put(x, 11, 8, "default:acacia_tree")
	end

	for x = 9, 13 do
		put(x, 11, 8, "default:acacia_tree")
	end

	for z = 3, 7 do
		put(8, 11, z, "default:acacia_tree")
	end

	for z = 9, 13 do
		put(8, 11, z, "default:acacia_tree")
	end

	-- Copa tipo sombrilla.
	for y = 11, 16 do
		local radius

		if y == 13 or y == 14 then
			radius = 6
		elseif y == 12 then
			radius = 4
		else
			radius = 3
		end

		for dx = -radius, radius do
			for dz = -radius, radius do
				if dx * dx + dz * dz <= radius * radius + 2 then
					if not (
						math.abs(dx) <= 1
						and math.abs(dz) <= 1
						and y <= 12
					) then
						put(
							8 + dx,
							y,
							8 + dz,
							"default:acacia_leaves"
						)
					end
				end
			end
		end
	end

	return schematic(width, height, depth, data)
end

-- =========================================================
-- CACTUS GIGANTE
-- =========================================================

local function cactus()
	local width = 11
	local height = 24
	local depth = 11

	local data, put = new_schematic(width, height, depth)

	local trunk = MOD_NAME .. ":giant_cactus_trunk"

	-- Fuste principal.
	for y = 1, height do
		local radius

		if y <= 3 then
			radius = 1
		else
			radius = 0
		end

		for dx = -radius, radius do
			for dz = -radius, radius do
				put(6 + dx, y, 6 + dz, trunk)
			end
		end
	end

	-- Brazo izquierdo.
	for x = 3, 5 do
		put(x, 10, 6, trunk)
	end

	for y = 10, 17 do
		put(3, y, 6, trunk)
	end

	-- Brazo derecho.
	for x = 7, 9 do
		put(x, 13, 6, trunk)
	end

	for y = 13, 20 do
		put(9, y, 6, trunk)
	end

	return schematic(width, height, depth, data)
end

-- =========================================================
-- ÁRBOL DE CRISTAL
-- =========================================================

local function crystal_tree()
	local width = 15
	local height = 22
	local depth = 15

	local data, put = new_schematic(width, height, depth)

	local log = MOD_NAME .. ":crystal_log"
	local leaves = MOD_NAME .. ":crystal_leaves"

	-- Tronco de cristal.
	for y = 1, 16 do
		local radius

		if y <= 4 then
			radius = 1
		else
			radius = 0
		end

		for dx = -radius, radius do
			for dz = -radius, radius do
				put(8 + dx, y, 8 + dz, log)
			end
		end
	end

	-- Copa de cristal.
	for y = 8, height do
		local radius = math.min(
			6,
			math.floor((y - 7) / 2)
		)

		if y >= 18 then
			radius = math.max(
				1,
				7 - math.floor((y - 18) / 2)
			)
		end

		for dx = -radius, radius do
			for dz = -radius, radius do
				if math.abs(dx) + math.abs(dz) <= radius then
					if not (
						dx == 0
						and dz == 0
						and y <= 16
					) then
						put(
							8 + dx,
							y,
							8 + dz,
							leaves
						)
					end
				end
			end
		end
	end

	return schematic(width, height, depth, data)
end

-- =========================================================
-- REGISTRO DE DECORACIONES
-- =========================================================

local function register_tree(
	name,
	place_on,
	biomes,
	ratio,
	tree_schematic,
	min_y
)
	core.register_decoration({
		name = MOD_NAME .. ":" .. name,
		deco_type = "schematic",

		place_on = place_on,

		-- Celda de comprobación relativamente grande.
		sidelen = 80,

		-- Valores bajos para que aparezcan pocos por bioma.
		fill_ratio = ratio,

		biomes = biomes,

		y_min = min_y or 1,
		y_max = 31000,

		schematic = tree_schematic,

		flags = "place_center_x, place_center_z",
		rotation = "random"
	})
end

core.register_on_mods_loaded(function()
	-- Bosques y praderas.
	register_tree(
		"giant_redwood",

		{
			"default:dirt_with_grass",
			"default:dirt_with_coniferous_litter"
		},

		{
			"deciduous_forest",
			"forest",
			"coniferous_forest",
			"taiga",
			"grassland"
		},

		0.000012,
		redwood()
	)

	-- Sabana.
	register_tree(
		"giant_baobab",

		{
			"default:dry_dirt_with_dry_grass",
			"default:dirt_with_dry_grass"
		},

		{
			"savanna"
		},

		0.000010,
		baobab()
	)

	-- Desierto.
	register_tree(
		"giant_cactus",

		{
			"default:desert_sand",
			"default:sand"
		},

		{
			"desert",
			"sandstone_desert"
		},

		0.000008,
		cactus()
	)

	-- Tundra y zonas nevadas.
	register_tree(
		"giant_crystal_tree",

		{
			"default:snowblock",
			"default:dirt_with_snow"
		},

		{
			"tundra",
			"taiga_snowy",
			"snowy_grassland"
		},

		0.000008,
		crystal_tree()
	)

	core.log(
		"action",
		"[" .. MOD_NAME ..
		"] Árboles gigantes registrados correctamente."
	)
end)