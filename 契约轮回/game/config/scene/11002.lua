Config = Config or  {  } 
Config.Scenes = Config.Scenes or {}
Config.Scenes[11002]= {
	id = 11002,
	name = "11002",
	scene_type = 1,
	logic_type = 1,
	is_forbid_pk = 0,
	player_level = 30,
	SceneMap= { 
		scene_width = 8100,
		scene_height = 6000,
		window_minimap_width = 0,
		window_minimap_height = 0,
	},
	Npcs= {
		[1200] = { id = 1200, x = 6009, y = 596, },
		[1201] = { id = 1201, x = 3180, y = 839, },
		[1202] = { id = 1202, x = 1725, y = 1561, },
		[1205] = { id = 1205, x = 5643, y = 2740, },
		[1206] = { id = 1206, x = 6601, y = 2905, },
		[1207] = { id = 1207, x = 5161, y = 4593, },
		[1203] = { id = 1203, x = 1052, y = 3343, },
		[1208] = { id = 1208, x = 2907, y = 4720, },
		[1204] = { id = 1204, x = 3345, y = 2881, },
	},
	Doors= {
		[110023] = { id = 110023, x = 2244, y = 5018, scene = 11003, target_x = 9122, target_y = 2139, },
		[110021] = { id = 110021, x = 6595, y = 569, scene = 11001, target_x = 8940, target_y = 1340, },
	},
	JumpPoints={
		[1] = { id = 1, x = 6926, y = 3247, targetId = 2, target_x = 6672, target_y = 4104, },
		[2] = { id = 2, x = 6916, y = 4095, targetId = 0, target_x = 6930, target_y = 3176, },
		[3] = { id = 3, x = 2528, y = 3014, targetId = 4, target_x = 3079, target_y = 2654, },
		[4] = { id = 4, x = 2953, y = 2710, targetId = 0, target_x = 2480, target_y = 3067, },
	},
	Bords={
		
		[0] = {x = 6320, y = 740,},
		
		[1] = {x = 6340, y = 740,},
		
		[2] = {x = 6360, y = 740,},
		
		[3] = {x = 6320, y = 759,},
		
		[4] = {x = 6340, y = 759,},
		
		[5] = {x = 6360, y = 759,},
		
		[6] = {x = 6320, y = 780,},
		
		[7] = {x = 6340, y = 780,},
	},
	Monsters= { 
		[1100204]= {
			id = 1100204,
			pos_list= {
				{ x = 6258, y = 4233, },
			},
		},
		[1100205]= {
			id = 1100205,
			pos_list= {
				{ x = 6106, y = 3130, },
				{ x = 6100, y = 3120, },
			},
		},
		[1100207]= {
			id = 1100207,
			pos_list= {
				{ x = 3000, y = 4554, },
			},
		},
		[1100201]= {
			id = 1100201,
			pos_list= {
				{ x = 2086, y = 1053, },
			},
		},
		[1100210]= {
			id = 1100210,
			pos_list= {
				{ x = 2248, y = 1065, },
			},
		},
		[1100211]= {
			id = 1100211,
			pos_list= {
				{ x = 2251, y = 961, },
			},
		},
		[1100209]= {
			id = 1100209,
			pos_list= {
				{ x = 1569, y = 3908, },
			},
		},
		[1100203]= {
			id = 1100203,
			pos_list= {
				{ x = 3765, y = 2852, },
				{ x = 3775, y = 2555, },
				{ x = 3800, y = 2307, },
				{ x = 4043, y = 2704, },
				{ x = 4052, y = 2482, },
				{ x = 4290, y = 2909, },
				{ x = 4288, y = 2615, },
				{ x = 4329, y = 2415, },
				{ x = 4481, y = 2781, },
			},
		},
		[1100208]= {
			id = 1100208,
			pos_list= {
				{ x = 3963, y = 5397, },
				{ x = 4327, y = 5377, },
				{ x = 3815, y = 5584, },
				{ x = 3636, y = 5418, },
				{ x = 3813, y = 5231, },
				{ x = 4152, y = 5608, },
				{ x = 4174, y = 5225, },
				{ x = 4565, y = 5234, },
				{ x = 4486, y = 5600, },
			},
		},
		[1100200]= {
			id = 1100200,
			pos_list= {
				{ x = 4977, y = 1202, },
				{ x = 5165, y = 1414, },
				{ x = 5413, y = 1146, },
				{ x = 5233, y = 994, },
				{ x = 4815, y = 1367, },
				{ x = 5545, y = 1401, },
				{ x = 5593, y = 1044, },
				{ x = 4818, y = 1047, },
				{ x = 4633, y = 1210, },
			},
		},
		[1100202]= {
			id = 1100202,
			pos_list= {
				{ x = 1215, y = 2364, },
				{ x = 1234, y = 2120, },
				{ x = 950, y = 2110, },
				{ x = 921, y = 2354, },
				{ x = 907, y = 2593, },
				{ x = 1193, y = 2609, },
				{ x = 1476, y = 2613, },
				{ x = 1497, y = 2378, },
				{ x = 1505, y = 2130, },
			},
		},
		
	},
	Elements= {
	 },
}
