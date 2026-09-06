-- Giant Biome Trees
-- Árboles gigantes, orgánicos y poco frecuentes para Luanti.

local MOD_NAME = core.get_current_modname()
local S = core.get_translator(MOD_NAME)

-- Índice correcto del schematic:
-- X + Y * width + Z * width * height
local function new_schematic(width, height, depth)
	local data = {}

	for i = 1, width * height * depth do
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
			(z - 1) * width * height +
			(y - 1) * width +
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
-- NODOS PROPIOS
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
-- ÁRBOL MONUMENTAL
-- =========================================================

local function redwood()
	local width = 45
	local height = 62
	local depth = 45
	local center = 23

	local data, put = new_schematic(width, height, depth)
	local leaves = "default:leaves"

	-- Variación de madera para crear vetas y relieve.
	local function bark(x, y, z)
		local pattern = (x * 3 + y * 5 + z * 7) % 11

		if pattern == 0 or pattern == 1 then
			return "default:jungletree"
		elseif pattern == 2 then
			return "default:acacia_tree"
		end

		return "default:tree"
	end

	-- =====================================================
	-- RAÍCES EXPUESTAS Y SERPENTEANTES
	-- =====================================================

	local root_directions = {
		{1, 0},
		{-1, 0},
		{0, 1},
		{0, -1},
		{1, 1},
		{1, -1},
		{-1, 1},
		{-1, -1}
	}

	for direction, vector in ipairs(root_directions) do
		for step = 2, 19 do
			local wave =
				math.floor(
					math.sin(step * 1.35 + direction) * 1.5
				)

			local x =
				center +
				vector[1] * step +
				(vector[2] ~= 0 and wave or 0)

			local z =
				center +
				vector[2] * step +
				(vector[1] ~= 0 and wave or 0)

			-- Las raíces bajan hacia el exterior.
			local y = math.max(
				1,
				4 - math.floor(step / 4)
			)

			local radius

			if step < 7 then
				radius = 3
			elseif step < 13 then
				radius = 2
			else
				radius = 1
			end

			for dx = -radius, radius do
				for dz = -radius, radius do
					if dx * dx + dz * dz <= radius * radius + 1 then
						put(
							x + dx,
							y,
							z + dz,
							bark(x + dx, y, z + dz)
						)

						if step < 15 and y > 1 then
							put(
								x + dx,
								y - 1,
								z + dz,
								bark(x + dx, y - 1, z + dz)
							)
						end
					end
				end
			end
		end
	end

	-- =====================================================
	-- TRONCO ROBUSTO Y AFINADO
	-- =====================================================

	for y = 1, 39 do
		local radius

		if y <= 7 then
			radius = 6
		elseif y <= 15 then
			radius = 5
		elseif y <= 24 then
			radius = 4
		elseif y <= 31 then
			radius = 3
		elseif y <= 36 then
			radius = 2
		else
			radius = 1
		end

		for dx = -radius, radius do
			for dz = -radius, radius do
				if dx * dx + dz * dz <= radius * radius + 1 then
					put(
						center + dx,
						y,
						center + dz,
						bark(center + dx, y, center + dz)
					)
				end
			end
		end
	end

	-- =====================================================
	-- RAMAS PRINCIPALES
	-- =====================================================

	local branches = {
		{1, 0, 25, 17},
		{-1, 0, 27, 18},
		{0, 1, 29, 18},
		{0, -1, 31, 18},
		{1, 1, 34, 16},
		{-1, -1, 35, 15},
		{1, -1, 33, 15},
		{-1, 1, 36, 15}
	}

	for _, branch in ipairs(branches) do
		local vx = branch[1]
		local vz = branch[2]
		local start_y = branch[3]
		local length = branch[4]

		for step = 1, length do
			local x = center + vx * step
			local z = center + vz * step
			local y = start_y + math.floor(step / 5)

			put(
				x,
				y,
				z,
				bark(x, y, z)
			)

			put(
				x,
				y + 1,
				z,
				bark(x, y + 1, z)
			)
		end
	end

	-- =====================================================
	-- COPA DENSA Y ORGÁNICA
	-- =====================================================

	for y = 20, height do
		local radius

		if y <= 29 then
			radius = 16
		elseif y <= 38 then
			radius = 19
		elseif y <= 47 then
			radius = 17
		elseif y <= 55 then
			radius = 12
		elseif y <= 59 then
			radius = 7
		else
			radius = 3
		end

		local offset_x =
			math.floor(math.sin(y * 0.55) * 2)

		local offset_z =
			math.floor(math.cos(y * 0.43) * 2)

		for dx = -radius, radius do
			for dz = -radius, radius do
				local organic_edge =
					math.sin((dx + y) * 0.8) +
					math.cos((dz - y) * 0.65)

				if dx * dx + dz * dz
					<= radius * radius + organic_edge * 3 then

					if not (
						math.abs(dx) <= 3
						and math.abs(dz) <= 3
						and y <= 39
					) then
						put(
							center + offset_x + dx,
							y,
							center + offset_z + dz,
							leaves,
							250
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

	for x = 3, 5 do
		put(x, 10, 6, trunk)
	end

	for y = 10, 17 do
		put(3, y, 6, trunk)
	end

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

		-- Las celdas grandes mantienen separados los árboles.
		sidelen = 320,

		-- Pocos árboles, pero más fáciles de encontrar.
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
	-- Bosques, taiga y praderas.
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

		0.000020,
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

		0.000015,
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

		0.000012,
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

		0.000012,
		crystal_tree()
	)

	core.log(
		"action",
		"[" .. MOD_NAME ..
		"] Árboles gigantes registrados correctamente."
	)
end)