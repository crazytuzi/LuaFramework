module(...)

ANIM_MAP_COMMON = {
	
}

ANIM_MAP_FLY = {
	["run"] = "idleCity",
}

DEFALUT = {
	[405] = 405,
	[700] = 700,
	[315] = 315,
	[604] = 604,
	[608] = 608,
	[719] = 719,
}

DATA = {
	[1] = {shape=5120, anim_map = ANIM_MAP_COMMON},
	[2] = {shape=5122, anim_map = ANIM_MAP_FLY, 
			height_info={
				fly_height =0.5,
				head_height=2.8, 
				foot_height=0.8, 
				collider_height=2,}
	},
	[405] = {shape=406, anim_map = ANIM_MAP_COMMON, fixed_pos = true},
	[700] = {shape=701, anim_map = ANIM_MAP_COMMON, fixed_pos = true},
	[315] = {shape=317, anim_map = ANIM_MAP_COMMON, fixed_pos = false},
	[604] = {shape=605, anim_map = ANIM_MAP_COMMON, fixed_pos = false},
	[608] = {shape=609, anim_map = ANIM_MAP_COMMON, fixed_pos = false},
	[719] = {shape=720, anim_map = ANIM_MAP_COMMON, fixed_pos = false},
}

