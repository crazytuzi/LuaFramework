local Items = {
	{q_id = 1,q_skillID = 10049,q_Name = '传送',q_cost = 1,q_icon = 1001,q_description = '可传送至结义好友的身侧，冷却时间30分钟',},
	{q_id = 2,q_skillID = 10050,q_Name = '召唤',q_cost = 1,q_icon = 1002,q_description = '可召唤结义好友，冷却时间30分钟',},
	{q_id = 3,q_Name = '物防一段',q_cost = 1,q_PreSkillID = 1,q_icon = 1003,q_description = '自身物理防御增加7-11',q_defense_min = 7,q_defense_max = 11,add_zdl = 54,},
	{q_id = 4,q_Name = '韧性',q_cost = 1,q_PreSkillID = 1,q_icon = 1004,q_description = '自身韧性增加15',q_tenacity = 15,add_zdl = 150,},
	{q_id = 5,q_Name = '攻击一段',q_cost = 1,q_PreSkillID = 2,q_icon = 1005,q_description = '三职业攻击力增加15-22',q_attack_min = 15,q_attack_max = 22,q_magic_attack_min = 15,q_magic_attack_max = 22,q_dc_attack_min = 15,q_dc_attack_max = 22,add_zdl = 111,},
	{q_id = 6,q_Name = '命中',q_cost = 1,q_PreSkillID = 2,q_icon = 1006,q_description = '自身命中增加15',q_hit = 15,add_zdl = 150,},
	{q_id = 7,q_Name = '闪避',q_cost = 1,q_PreSkillID = '3,4',q_icon = 1007,q_description = '自身闪避增加15',q_dodge = 15,add_zdl = 150,},
	{q_id = 8,q_Name = '魔防一段',q_cost = 1,q_PreSkillID = '4,5',q_icon = 1008,q_description = '自身魔法防御增加7-11',q_magic_defence_min = 7,q_magic_defence_max = 11,add_zdl = 54,},
	{q_id = 9,q_Name = '暴击',q_cost = 1,q_PreSkillID = '5,6',q_icon = 1009,q_description = '自身暴击增加15',q_crit = 15,add_zdl = 150,},
	{q_id = 10,q_Name = '物防二段',q_cost = 1,q_PreSkillID = '7,8',q_icon = 1003,q_description = '自身物理防御增加17-26',q_defense_min = 16,q_defense_max = 24,add_zdl = 120,},
	{q_id = 11,q_Name = '魔防二段',q_cost = 1,q_PreSkillID = '8,9',q_icon = 1008,q_description = '自身魔法防御增加17-26',q_magic_defence_min = 16,q_magic_defence_max = 24,add_zdl = 120,},
	{q_id = 12,q_Name = '攻击二段',q_cost = 1,q_PreSkillID = '10,11',q_icon = 1005,q_description = '三职业攻击力增加27-42',q_attack_min = 27,q_attack_max = 42,q_magic_attack_min = 27,q_magic_attack_max = 42,q_dc_attack_min = 27,q_dc_attack_max = 42,add_zdl = 207,},
};
return Items
