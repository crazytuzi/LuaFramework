local Items = {
	{mountId = 101,max_level = 1,q_max_hp = 420,q_attack_min = 34,q_attack_max = 62,q_magic_attack_min = 34,q_magic_attack_max = 62,q_sc_attack_min = 34,q_sc_attack_max = 62,q_defence_min = 7,q_defence_max = 14,q_magic_defence_min = 7,q_magic_defence_max = 14,highest_count = 0,free_give_item = 7,free_give_item2 = 8,speed = 1,isold = 1,},
	{mountId = 201,max_level = 1,q_max_hp = 420,q_attack_min = 34,q_attack_max = 62,q_magic_attack_min = 34,q_magic_attack_max = 62,q_sc_attack_min = 34,q_sc_attack_max = 62,q_defence_min = 7,q_defence_max = 14,q_magic_defence_min = 7,q_magic_defence_max = 14,highest_count = 0,free_give_item = 7,free_give_item2 = 8,speed = 1,isold = 1,},
	{mountId = 301,max_level = 1,q_max_hp = 420,q_attack_min = 34,q_attack_max = 62,q_magic_attack_min = 34,q_magic_attack_max = 62,q_sc_attack_min = 34,q_sc_attack_max = 62,q_defence_min = 7,q_defence_max = 14,q_magic_defence_min = 7,q_magic_defence_max = 14,highest_count = 0,free_give_item = 7,free_give_item2 = 8,speed = 1,isold = 1,},
	{mountId = 102,max_level = 1,q_max_hp = 420,q_attack_min = 34,q_attack_max = 62,q_magic_attack_min = 34,q_magic_attack_max = 62,q_sc_attack_min = 34,q_sc_attack_max = 62,q_defence_min = 7,q_defence_max = 14,q_magic_defence_min = 7,q_magic_defence_max = 14,highest_count = 0,free_give_item = 7,free_give_item2 = 8,speed = 1,isold = 1,},
	{mountId = 202,max_level = 1,q_max_hp = 420,q_attack_min = 34,q_attack_max = 62,q_magic_attack_min = 34,q_magic_attack_max = 62,q_sc_attack_min = 34,q_sc_attack_max = 62,q_defence_min = 7,q_defence_max = 14,q_magic_defence_min = 7,q_magic_defence_max = 14,highest_count = 0,free_give_item = 7,free_give_item2 = 8,speed = 1,isold = 1,},
	{mountId = 302,max_level = 1,q_max_hp = 420,q_attack_min = 34,q_attack_max = 62,q_magic_attack_min = 34,q_magic_attack_max = 62,q_sc_attack_min = 34,q_sc_attack_max = 62,q_defence_min = 7,q_defence_max = 14,q_magic_defence_min = 7,q_magic_defence_max = 14,highest_count = 0,free_give_item = 7,free_give_item2 = 8,speed = 1,isold = 1,},
	{mountId = 103,max_level = 20,q_max_hp = 420,q_attack_min = 34,q_attack_max = 62,q_defence_min = 7,q_defence_max = 14,q_magic_defence_min = 7,q_magic_defence_max = 14,highest_count = 2,free_give_item = 7,free_give_item2 = 8,speed = 1,isold = 0,},
	{mountId = 203,max_level = 20,q_max_hp = 420,q_magic_attack_min = 34,q_magic_attack_max = 62,q_defence_min = 7,q_defence_max = 14,q_magic_defence_min = 7,q_magic_defence_max = 14,highest_count = 2,free_give_item = 7,free_give_item2 = 8,speed = 1,isold = 0,},
	{mountId = 303,max_level = 20,q_max_hp = 420,q_sc_attack_min = 34,q_sc_attack_max = 62,q_defence_min = 7,q_defence_max = 14,q_magic_defence_min = 7,q_magic_defence_max = 14,highest_count = 2,free_give_item = 7,free_give_item2 = 8,speed = 1,isold = 0,},
	{mountId = 104,max_level = 20,q_max_hp = 420,q_attack_min = 40,q_attack_max = 70,q_defence_min = 10,q_defence_max = 20,q_magic_defence_min = 10,q_magic_defence_max = 20,highest_count = 2,free_give_item = 7,free_give_item2 = 8,speed = 1,isold = 0,},
	{mountId = 204,max_level = 20,q_max_hp = 420,q_magic_attack_min = 40,q_magic_attack_max = 70,q_defence_min = 10,q_defence_max = 20,q_magic_defence_min = 10,q_magic_defence_max = 20,highest_count = 2,free_give_item = 7,free_give_item2 = 8,speed = 1,isold = 0,},
	{mountId = 304,max_level = 20,q_max_hp = 420,q_sc_attack_min = 40,q_sc_attack_max = 70,q_defence_min = 10,q_defence_max = 20,q_magic_defence_min = 10,q_magic_defence_max = 20,highest_count = 2,free_give_item = 7,free_give_item2 = 8,speed = 1,isold = 0,},
	{mountId = 105,max_level = 20,q_max_hp = 420,q_attack_min = 40,q_attack_max = 70,q_defence_min = 10,q_defence_max = 20,q_magic_defence_min = 10,q_magic_defence_max = 20,highest_count = 2,free_give_item = 7,free_give_item2 = 8,speed = 1,isold = 0,},
	{mountId = 205,max_level = 20,q_max_hp = 420,q_magic_attack_min = 40,q_magic_attack_max = 70,q_defence_min = 10,q_defence_max = 20,q_magic_defence_min = 10,q_magic_defence_max = 20,highest_count = 2,free_give_item = 7,free_give_item2 = 8,speed = 1,isold = 0,},
	{mountId = 305,max_level = 20,q_max_hp = 420,q_sc_attack_min = 40,q_sc_attack_max = 70,q_defence_min = 10,q_defence_max = 20,q_magic_defence_min = 10,q_magic_defence_max = 20,highest_count = 2,free_give_item = 7,free_give_item2 = 8,speed = 1,isold = 0,},
	{mountId = 106,max_level = 20,q_max_hp = 420,q_attack_min = 40,q_attack_max = 70,q_defence_min = 10,q_defence_max = 20,q_magic_defence_min = 10,q_magic_defence_max = 20,highest_count = 2,free_give_item = 7,free_give_item2 = 8,speed = 1,isold = 0,},
	{mountId = 206,max_level = 20,q_max_hp = 420,q_magic_attack_min = 40,q_magic_attack_max = 70,q_defence_min = 10,q_defence_max = 20,q_magic_defence_min = 10,q_magic_defence_max = 20,highest_count = 2,free_give_item = 7,free_give_item2 = 8,speed = 1,isold = 0,},
	{mountId = 306,max_level = 20,q_max_hp = 420,q_sc_attack_min = 40,q_sc_attack_max = 70,q_defence_min = 10,q_defence_max = 20,q_magic_defence_min = 10,q_magic_defence_max = 20,highest_count = 2,free_give_item = 7,free_give_item2 = 8,speed = 1,isold = 0,},
};
return Items
