local Items = {
	{q_id = 1,q_copy_id = 112,q_name = '颜岭卫',q_mon_id = 7001,q_dir = 2,q_x = 70,q_y = 66,q_dig_mine = 1,q_probability = 10,q_level = 20,q_sex = 1,q_hp = 2000,q_weapon = 3010102,q_cloth = 3010502,q_attack_min = 100,q_attack_max = 150,q_sc_attack_min = 100,q_sc_attack_max = 150,q_magic_attack_min = 100,q_magic_attack_max = 150,q_defense_min = 1,q_defense_max = 10,q_magic_defence_min = 1,q_magic_defence_max = 10,q_hit = 0,q_dodge = 0,},
	{q_id = 2,q_copy_id = 112,q_name = '卢国源',q_mon_id = 7002,q_dir = 0,q_x = 77,q_y = 58,q_dig_mine = 1,q_probability = 10,q_level = 20,q_sex = 2,q_hp = 2000,q_weapon = 3020102,q_cloth = 3021502,q_attack_min = 100,q_attack_max = 150,q_sc_attack_min = 100,q_sc_attack_max = 150,q_magic_attack_min = 100,q_magic_attack_max = 150,q_defense_min = 1,q_defense_max = 10,q_magic_defence_min = 1,q_magic_defence_max = 10,q_hit = 0,q_dodge = 0,},
	{q_id = 3,q_copy_id = 112,q_name = '薛长望',q_mon_id = 7003,q_dir = 4,q_x = 90,q_y = 64,q_dig_mine = 1,q_probability = 10,q_level = 20,q_sex = 1,q_hp = 2000,q_weapon = 3030102,q_cloth = 3030502,q_attack_min = 100,q_attack_max = 150,q_sc_attack_min = 100,q_sc_attack_max = 150,q_magic_attack_min = 100,q_magic_attack_max = 150,q_defense_min = 1,q_defense_max = 10,q_magic_defence_min = 1,q_magic_defence_max = 10,q_hit = 0,q_dodge = 0,},
	{q_id = 4,q_copy_id = 112,q_name = '赫连永贞',q_mon_id = 7001,q_dir = 3,q_x = 92,q_y = 72,q_dig_mine = 0,q_probability = 10,q_level = 20,q_sex = 2,q_hp = 2000,q_weapon = 3010102,q_cloth = 3011502,q_attack_min = 100,q_attack_max = 150,q_sc_attack_min = 100,q_sc_attack_max = 150,q_magic_attack_min = 100,q_magic_attack_max = 150,q_defense_min = 1,q_defense_max = 10,q_magic_defence_min = 1,q_magic_defence_max = 10,q_hit = 0,q_dodge = 0,},
	{q_id = 5,q_copy_id = 112,q_name = '王紫文',q_mon_id = 7003,q_dir = 3,q_x = 88,q_y = 73,q_dig_mine = 0,q_probability = 10,q_level = 20,q_sex = 1,q_hp = 2000,q_weapon = 3020102,q_cloth = 3020502,q_attack_min = 100,q_attack_max = 150,q_sc_attack_min = 100,q_sc_attack_max = 150,q_magic_attack_min = 100,q_magic_attack_max = 150,q_defense_min = 1,q_defense_max = 10,q_magic_defence_min = 1,q_magic_defence_max = 10,q_hit = 0,q_dodge = 0,},
	{q_id = 6,q_copy_id = 16,q_name = '孔盼曼',q_mon_id = 7001,q_dir = 2,q_x = 70,q_y = 66,q_dig_mine = 1,q_probability = 20,q_level = 30,q_sex = 2,q_hp = 3500,q_weapon = 4010103,q_cloth = 4010503,q_attack_min = 200,q_attack_max = 300,q_sc_attack_min = 200,q_sc_attack_max = 300,q_magic_attack_min = 200,q_magic_attack_max = 300,q_defense_min = 10,q_defense_max = 50,q_magic_defence_min = 10,q_magic_defence_max = 50,q_hit = 0,q_dodge = 0,},
	{q_id = 7,q_copy_id = 16,q_name = '陈学真',q_mon_id = 7002,q_dir = 0,q_x = 77,q_y = 58,q_dig_mine = 1,q_probability = 20,q_level = 30,q_sex = 1,q_hp = 3500,q_weapon = 4020103,q_cloth = 4021503,q_attack_min = 200,q_attack_max = 300,q_sc_attack_min = 200,q_sc_attack_max = 300,q_magic_attack_min = 200,q_magic_attack_max = 300,q_defense_min = 10,q_defense_max = 50,q_magic_defence_min = 10,q_magic_defence_max = 50,q_hit = 0,q_dodge = 0,},
	{q_id = 8,q_copy_id = 16,q_name = '唐碧菡',q_mon_id = 7003,q_dir = 4,q_x = 90,q_y = 64,q_dig_mine = 1,q_probability = 20,q_level = 30,q_sex = 2,q_hp = 3500,q_weapon = 4030103,q_cloth = 4030503,q_attack_min = 200,q_attack_max = 300,q_sc_attack_min = 200,q_sc_attack_max = 300,q_magic_attack_min = 200,q_magic_attack_max = 300,q_defense_min = 10,q_defense_max = 50,q_magic_defence_min = 10,q_magic_defence_max = 50,q_hit = 0,q_dodge = 0,},
	{q_id = 9,q_copy_id = 16,q_name = '钱炎彬',q_mon_id = 7001,q_dir = 3,q_x = 92,q_y = 72,q_dig_mine = 0,q_probability = 20,q_level = 30,q_sex = 1,q_hp = 3500,q_weapon = 4010103,q_cloth = 4011503,q_attack_min = 200,q_attack_max = 300,q_sc_attack_min = 200,q_sc_attack_max = 300,q_magic_attack_min = 200,q_magic_attack_max = 300,q_defense_min = 10,q_defense_max = 50,q_magic_defence_min = 10,q_magic_defence_max = 50,q_hit = 0,q_dodge = 0,},
	{q_id = 10,q_copy_id = 16,q_name = '金自怡',q_mon_id = 7003,q_dir = 3,q_x = 88,q_y = 73,q_dig_mine = 0,q_probability = 20,q_level = 30,q_sex = 2,q_hp = 3500,q_weapon = 4020103,q_cloth = 4020503,q_attack_min = 200,q_attack_max = 300,q_sc_attack_min = 200,q_sc_attack_max = 300,q_magic_attack_min = 200,q_magic_attack_max = 300,q_defense_min = 10,q_defense_max = 50,q_magic_defence_min = 10,q_magic_defence_max = 50,q_hit = 0,q_dodge = 0,},
	{q_id = 11,q_copy_id = 17,q_name = '夏侯祺温',q_mon_id = 7001,q_dir = 2,q_x = 70,q_y = 66,q_dig_mine = 1,q_probability = 30,q_level = 40,q_sex = 1,q_hp = 6000,q_weapon = 4010111,q_cloth = 4010510,q_wing = 1,q_attack_min = 400,q_attack_max = 600,q_sc_attack_min = 400,q_sc_attack_max = 600,q_magic_attack_min = 400,q_magic_attack_max = 600,q_defense_min = 50,q_defense_max = 100,q_magic_defence_min = 50,q_magic_defence_max = 100,q_hit = 0,q_dodge = 0,},
	{q_id = 12,q_copy_id = 17,q_name = '罗睿渊',q_mon_id = 7002,q_dir = 0,q_x = 77,q_y = 58,q_dig_mine = 1,q_probability = 30,q_level = 40,q_sex = 2,q_hp = 6000,q_weapon = 4020111,q_cloth = 4021510,q_wing = 1,q_attack_min = 400,q_attack_max = 600,q_sc_attack_min = 400,q_sc_attack_max = 600,q_magic_attack_min = 400,q_magic_attack_max = 600,q_defense_min = 50,q_defense_max = 100,q_magic_defence_min = 50,q_magic_defence_max = 100,q_hit = 0,q_dodge = 0,},
	{q_id = 13,q_copy_id = 17,q_name = '冯弘博',q_mon_id = 7003,q_dir = 4,q_x = 90,q_y = 64,q_dig_mine = 1,q_probability = 30,q_level = 40,q_sex = 1,q_hp = 6000,q_weapon = 4030111,q_cloth = 4030510,q_wing = 1,q_attack_min = 400,q_attack_max = 600,q_sc_attack_min = 400,q_sc_attack_max = 600,q_magic_attack_min = 400,q_magic_attack_max = 600,q_defense_min = 50,q_defense_max = 100,q_magic_defence_min = 50,q_magic_defence_max = 100,q_hit = 0,q_dodge = 0,},
	{q_id = 14,q_copy_id = 17,q_name = '熊祺温',q_mon_id = 7001,q_dir = 3,q_x = 92,q_y = 72,q_dig_mine = 0,q_probability = 30,q_level = 40,q_sex = 2,q_hp = 6000,q_weapon = 4010111,q_cloth = 4011510,q_wing = 1,q_attack_min = 400,q_attack_max = 600,q_sc_attack_min = 400,q_sc_attack_max = 600,q_magic_attack_min = 400,q_magic_attack_max = 600,q_defense_min = 50,q_defense_max = 100,q_magic_defence_min = 50,q_magic_defence_max = 100,q_hit = 0,q_dodge = 0,},
	{q_id = 15,q_copy_id = 17,q_name = '南门梦露',q_mon_id = 7003,q_dir = 3,q_x = 88,q_y = 73,q_dig_mine = 0,q_probability = 30,q_level = 40,q_sex = 1,q_hp = 6000,q_weapon = 4020111,q_cloth = 4020510,q_wing = 1,q_attack_min = 400,q_attack_max = 600,q_sc_attack_min = 400,q_sc_attack_max = 600,q_magic_attack_min = 400,q_magic_attack_max = 600,q_defense_min = 50,q_defense_max = 100,q_magic_defence_min = 50,q_magic_defence_max = 100,q_hit = 0,q_dodge = 0,},
	{q_id = 16,q_copy_id = 18,q_name = '谵台奕伟',q_mon_id = 7001,q_dir = 2,q_x = 70,q_y = 66,q_dig_mine = 1,q_probability = 40,q_level = 50,q_sex = 2,q_hp = 12000,q_weapon = 4010112,q_cloth = 4010511,q_wing = 3,q_attack_min = 600,q_attack_max = 900,q_sc_attack_min = 600,q_sc_attack_max = 900,q_magic_attack_min = 600,q_magic_attack_max = 900,q_defense_min = 100,q_defense_max = 200,q_magic_defence_min = 100,q_magic_defence_max = 200,q_hit = 0,q_dodge = 0,},
	{q_id = 17,q_copy_id = 18,q_name = '令狐旭尧',q_mon_id = 7002,q_dir = 0,q_x = 77,q_y = 58,q_dig_mine = 1,q_probability = 40,q_level = 50,q_sex = 1,q_hp = 12000,q_weapon = 4020112,q_cloth = 4021511,q_wing = 3,q_attack_min = 600,q_attack_max = 900,q_sc_attack_min = 600,q_sc_attack_max = 900,q_magic_attack_min = 600,q_magic_attack_max = 900,q_defense_min = 100,q_defense_max = 200,q_magic_defence_min = 100,q_magic_defence_max = 200,q_hit = 0,q_dodge = 0,},
	{q_id = 18,q_copy_id = 18,q_name = '蒋智宸',q_mon_id = 7003,q_dir = 4,q_x = 90,q_y = 64,q_dig_mine = 1,q_probability = 40,q_level = 50,q_sex = 2,q_hp = 12000,q_weapon = 4030112,q_cloth = 4030511,q_wing = 3,q_attack_min = 600,q_attack_max = 900,q_sc_attack_min = 600,q_sc_attack_max = 900,q_magic_attack_min = 600,q_magic_attack_max = 900,q_defense_min = 100,q_defense_max = 200,q_magic_defence_min = 100,q_magic_defence_max = 200,q_hit = 0,q_dodge = 0,},
	{q_id = 19,q_copy_id = 18,q_name = '卢和安',q_mon_id = 7001,q_dir = 3,q_x = 92,q_y = 72,q_dig_mine = 0,q_probability = 40,q_level = 50,q_sex = 1,q_hp = 12000,q_weapon = 4010112,q_cloth = 4011511,q_wing = 3,q_attack_min = 600,q_attack_max = 900,q_sc_attack_min = 600,q_sc_attack_max = 900,q_magic_attack_min = 600,q_magic_attack_max = 900,q_defense_min = 100,q_defense_max = 200,q_magic_defence_min = 100,q_magic_defence_max = 200,q_hit = 0,q_dodge = 0,},
	{q_id = 20,q_copy_id = 18,q_name = '潘彭泽',q_mon_id = 7003,q_dir = 3,q_x = 88,q_y = 73,q_dig_mine = 0,q_probability = 40,q_level = 50,q_sex = 2,q_hp = 12000,q_weapon = 4020112,q_cloth = 4020511,q_wing = 3,q_attack_min = 600,q_attack_max = 900,q_sc_attack_min = 600,q_sc_attack_max = 900,q_magic_attack_min = 600,q_magic_attack_max = 900,q_defense_min = 100,q_defense_max = 200,q_magic_defence_min = 100,q_magic_defence_max = 200,q_hit = 0,q_dodge = 0,},
	{q_id = 21,q_copy_id = 103,q_name = '姜含烟',q_mon_id = 7001,q_dir = 2,q_x = 70,q_y = 66,q_dig_mine = 1,q_probability = 45,q_level = 60,q_sex = 1,q_hp = 18000,q_weapon = 5110106,q_cloth = 5110505,q_wing = 4,q_attack_min = 800,q_attack_max = 1200,q_sc_attack_min = 800,q_sc_attack_max = 1200,q_magic_attack_min = 800,q_magic_attack_max = 1200,q_defense_min = 200,q_defense_max = 300,q_magic_defence_min = 200,q_magic_defence_max = 300,q_hit = 0,q_dodge = 0,},
	{q_id = 22,q_copy_id = 103,q_name = '吕梦露',q_mon_id = 7002,q_dir = 0,q_x = 77,q_y = 58,q_dig_mine = 1,q_probability = 45,q_level = 60,q_sex = 2,q_hp = 18000,q_weapon = 5120105,q_cloth = 5121505,q_wing = 4,q_attack_min = 800,q_attack_max = 1200,q_sc_attack_min = 800,q_sc_attack_max = 1200,q_magic_attack_min = 800,q_magic_attack_max = 1200,q_defense_min = 200,q_defense_max = 300,q_magic_defence_min = 200,q_magic_defence_max = 300,q_hit = 0,q_dodge = 0,},
	{q_id = 23,q_copy_id = 103,q_name = '宇文子轩',q_mon_id = 7003,q_dir = 4,q_x = 90,q_y = 64,q_dig_mine = 1,q_probability = 45,q_level = 60,q_sex = 1,q_hp = 18000,q_weapon = 5130106,q_cloth = 5130505,q_wing = 4,q_attack_min = 800,q_attack_max = 1200,q_sc_attack_min = 800,q_sc_attack_max = 1200,q_magic_attack_min = 800,q_magic_attack_max = 1200,q_defense_min = 200,q_defense_max = 300,q_magic_defence_min = 200,q_magic_defence_max = 300,q_hit = 0,q_dodge = 0,},
	{q_id = 24,q_copy_id = 103,q_name = '毛正志',q_mon_id = 7001,q_dir = 3,q_x = 92,q_y = 72,q_dig_mine = 0,q_probability = 45,q_level = 60,q_sex = 2,q_hp = 18000,q_weapon = 5110106,q_cloth = 5111505,q_wing = 4,q_attack_min = 800,q_attack_max = 1200,q_sc_attack_min = 800,q_sc_attack_max = 1200,q_magic_attack_min = 800,q_magic_attack_max = 1200,q_defense_min = 200,q_defense_max = 300,q_magic_defence_min = 200,q_magic_defence_max = 300,q_hit = 0,q_dodge = 0,},
	{q_id = 25,q_copy_id = 103,q_name = '邱初瑶',q_mon_id = 7003,q_dir = 3,q_x = 88,q_y = 73,q_dig_mine = 0,q_probability = 45,q_level = 60,q_sex = 2,q_hp = 18000,q_weapon = 5120105,q_cloth = 5120505,q_wing = 4,q_attack_min = 800,q_attack_max = 1200,q_sc_attack_min = 800,q_sc_attack_max = 1200,q_magic_attack_min = 800,q_magic_attack_max = 1200,q_defense_min = 200,q_defense_max = 300,q_magic_defence_min = 200,q_magic_defence_max = 300,q_hit = 0,q_dodge = 0,},
	{q_id = 201,q_copy_id = 0,q_mon_id = 21,q_x = 70,q_y = 64,},
	{q_id = 202,q_copy_id = 0,q_mon_id = 23,q_x = 78,q_y = 58,},
	{q_id = 203,q_copy_id = 0,q_mon_id = 31,q_x = 81,q_y = 69,},
	{q_id = 204,q_copy_id = 0,q_mon_id = 21,q_x = 88,q_y = 63,},
};
return Items
