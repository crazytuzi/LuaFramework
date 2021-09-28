local Items = {
	{q_id = 1,q_lmin = 1,q_lmax = 99,q_itemID = 1449,F5 = '普通武器碎片',q_shop = 3,q_type = 4,hzjl = 150,q_num = 1,q_countNum = 1,hz = 1400,Is_bd = 1,},
	{q_id = 2,q_lmin = 1,q_lmax = 99,q_itemID = 1452,F5 = '普通防具碎片',q_shop = 3,q_type = 4,hzjl = 150,q_num = 1,q_countNum = 1,hz = 700,Is_bd = 1,},
	{q_id = 3,q_lmin = 1,q_lmax = 99,q_itemID = 1450,F5 = '精良武器碎片',q_shop = 3,q_type = 4,hzjl = 80,q_num = 1,q_countNum = 1,hz = 3400,Is_bd = 1,},
	{q_id = 4,q_lmin = 1,q_lmax = 99,q_itemID = 1453,F5 = '精良防具碎片',q_shop = 3,q_type = 4,hzjl = 80,q_num = 1,q_countNum = 1,hz = 1700,Is_bd = 1,},
	{q_id = 5,q_lmin = 1,q_lmax = 99,q_itemID = 1449,F5 = '普通武器碎片',q_shop = 3,q_type = 4,hzjl = 100,q_num = 2,q_countNum = 2,hz = 2800,Is_bd = 1,},
	{q_id = 6,q_lmin = 1,q_lmax = 99,q_itemID = 1452,F5 = '普通防具碎片',q_shop = 3,q_type = 4,hzjl = 100,q_num = 2,q_countNum = 2,hz = 1400,Is_bd = 1,},
	{q_id = 7,q_lmin = 1,q_lmax = 99,q_itemID = 1450,F5 = '精良武器碎片',q_shop = 3,q_type = 4,hzjl = 50,q_num = 2,q_countNum = 2,hz = 6800,Is_bd = 1,},
	{q_id = 8,q_lmin = 1,q_lmax = 99,q_itemID = 1453,F5 = '精良防具碎片',q_shop = 3,q_type = 4,hzjl = 50,q_num = 2,q_countNum = 2,hz = 3400,Is_bd = 1,},
	{q_id = 9,q_lmin = 1,q_lmax = 99,q_itemID = 1001,F5 = '飞行靴',q_shop = 3,q_type = 4,hzjl = 100,q_num = 5,q_countNum = 5,hz = 500,Is_bd = 1,},
	{q_id = 10,q_lmin = 1,q_lmax = 99,q_itemID = 1001,F5 = '飞行靴',q_shop = 3,q_type = 4,hzjl = 100,q_num = 10,q_countNum = 10,hz = 1000,Is_bd = 1,},
	{q_id = 11,q_lmin = 1,q_lmax = 99,q_itemID = 1001,F5 = '飞行靴',q_shop = 3,q_type = 4,hzjl = 100,q_num = 20,q_countNum = 20,hz = 2000,Is_bd = 1,},
	{q_id = 12,q_lmin = 1,q_lmax = 99,q_itemID = 1002,F5 = '还魂石',q_shop = 3,q_type = 4,hzjl = 100,q_num = 1,q_countNum = 1,hz = 1000,Is_bd = 1,},
	{q_id = 13,q_lmin = 1,q_lmax = 99,q_itemID = 1002,F5 = '还魂石',q_shop = 3,q_type = 4,hzjl = 100,q_num = 2,q_countNum = 2,hz = 2000,Is_bd = 1,},
	{q_id = 14,q_lmin = 1,q_lmax = 99,q_itemID = 1034,F5 = '消红药水',q_shop = 3,q_type = 4,hzjl = 100,q_num = 1,q_countNum = 1,hz = 2000,Is_bd = 1,},
	{q_id = 15,q_lmin = 1,q_lmax = 99,q_itemID = 6200029,F5 = '铁血炼狱凭证',q_shop = 3,q_type = 4,hzjl = 100,q_num = 1,q_countNum = 1,hz = 1000,Is_bd = 1,},
	{q_id = 16,q_lmin = 1,q_lmax = 99,q_itemID = 6200030,F5 = '通天炼狱凭证',q_shop = 3,q_type = 4,hzjl = 50,q_num = 1,q_countNum = 1,hz = 5000,Is_bd = 1,},
	{q_id = 17,q_lmin = 1,q_lmax = 99,q_itemID = 1301,F5 = '铁矿(纯度1)',q_shop = 3,q_type = 4,hzjl = 150,q_num = 5,q_countNum = 5,hz = 500,Is_bd = 1,},
	{q_id = 18,q_lmin = 1,q_lmax = 99,q_itemID = 1301,F5 = '铁矿(纯度1)',q_shop = 3,q_type = 4,hzjl = 100,q_num = 10,q_countNum = 10,hz = 1000,Is_bd = 1,},
	{q_id = 19,q_lmin = 1,q_lmax = 99,q_itemID = 1301,F5 = '铁矿(纯度1)',q_shop = 3,q_type = 4,hzjl = 20,q_num = 20,q_countNum = 20,hz = 2000,Is_bd = 1,},
	{q_id = 20,q_lmin = 1,q_lmax = 99,q_itemID = 1303,F5 = '铁矿(纯度3)',q_shop = 3,q_type = 4,hzjl = 20,q_num = 2,q_countNum = 2,hz = 800,Is_bd = 1,},
	{q_id = 21,q_lmin = 1,q_lmax = 99,q_itemID = 1303,F5 = '铁矿(纯度3)',q_shop = 3,q_type = 4,hzjl = 10,q_num = 5,q_countNum = 5,hz = 2000,Is_bd = 1,},
	{q_id = 22,q_lmin = 1,q_lmax = 99,q_itemID = 20037,F5 = '治疗神水',q_shop = 3,q_type = 4,hzjl = 100,q_num = 1,q_countNum = 1,hz = 800,Is_bd = 1,},
	{q_id = 23,q_lmin = 1,q_lmax = 99,q_itemID = 20023,F5 = '天山雪莲',q_shop = 3,q_type = 4,hzjl = 100,q_num = 1,q_countNum = 1,hz = 3000,Is_bd = 1,},
	{q_id = 24,q_lmin = 1,q_lmax = 99,q_itemID = 20036,F5 = '强效太阳神水',q_shop = 3,q_type = 4,hzjl = 100,q_num = 99,q_countNum = 99,hz = 2000,Is_bd = 1,},
	{q_id = 25,q_lmin = 1,q_lmax = 99,q_itemID = 1219,F5 = '七彩石',q_shop = 4,q_type = 1,q_ingotprob = 100000,q_ingot = 1000,q_all_limit = 200,q_role_limit = 20,Is_bd = 1,},
	{q_id = 26,q_lmin = 1,q_lmax = 99,q_itemID = 1417,F5 = '中级羽毛',q_shop = 4,q_type = 1,q_ingotprob = 200,q_ingot = 100,q_all_limit = 50,q_role_limit = 10,Is_bd = 0,},
	{q_id = 27,q_lmin = 1,q_lmax = 99,q_itemID = 1418,F5 = '高级羽毛',q_shop = 4,q_type = 1,q_ingotprob = 100,q_ingot = 1000,q_all_limit = 20,q_role_limit = 4,Is_bd = 0,},
	{q_id = 28,q_lmin = 1,q_lmax = 99,q_itemID = 1456,F5 = '天仙之羽',q_shop = 4,q_type = 1,q_ingotprob = 200,q_ingot = 500,q_all_limit = 10,q_role_limit = 4,Is_bd = 0,},
	{q_id = 29,q_lmin = 1,q_lmax = 99,q_itemID = 1457,F5 = '天神之羽',q_shop = 4,q_type = 1,q_ingotprob = 100,q_ingot = 5000,q_all_limit = 5,q_role_limit = 2,Is_bd = 0,},
	{q_id = 30,q_lmin = 1,q_lmax = 99,q_itemID = 5018,F5 = '点金石',q_shop = 4,q_type = 1,q_ingotprob = 500,q_ingot = 1000,q_all_limit = 50,q_role_limit = 10,Is_bd = 0,},
	{q_id = 31,q_lmin = 1,q_lmax = 99,q_itemID = 1403,F5 = '黑铁矿(纯度3)',q_shop = 4,q_type = 1,q_ingotprob = 500,q_ingot = 120,q_all_limit = 100,q_role_limit = 20,Is_bd = 0,},
	{q_id = 32,q_lmin = 1,q_lmax = 99,q_itemID = 1306,F5 = '铁矿(纯度6)',q_shop = 4,q_type = 1,q_ingotprob = 500,q_ingot = 20,q_all_limit = 100,q_role_limit = 20,Is_bd = 0,},
	{q_id = 33,q_lmin = 1,q_lmax = 99,q_itemID = 6200091,F5 = '仙翼技能灵丹',q_shop = 4,q_type = 1,q_ingotprob = 500,q_ingot = 100,q_all_limit = 20,q_role_limit = 5,Is_bd = 0,},
	{q_id = 34,q_lmin = 1,q_lmax = 99,q_itemID = 1510,F5 = '炽焰麒麟',q_shop = 4,q_type = 1,q_ingotprob = 1000,q_ingot = 88000,q_all_limit = 1,q_role_limit = 1,Is_bd = 0,q_special = 3102,},
	{q_id = 35,q_lmin = 1,q_lmax = 99,q_itemID = 6200010,F5 = '破盾斩',q_shop = 4,q_type = 1,q_ingotprob = 50,q_ingot = 10000,q_all_limit = 1,q_role_limit = 1,Is_bd = 0,},
	{q_id = 36,q_lmin = 1,q_lmax = 99,q_itemID = 6200015,F5 = '狂龙紫电',q_shop = 4,q_type = 1,q_ingotprob = 50,q_ingot = 10000,q_all_limit = 1,q_role_limit = 1,Is_bd = 0,},
	{q_id = 37,q_lmin = 1,q_lmax = 99,q_itemID = 6200022,F5 = '幽冥火咒',q_shop = 4,q_type = 1,q_ingotprob = 50,q_ingot = 10000,q_all_limit = 1,q_role_limit = 1,Is_bd = 0,},
	{q_id = 38,q_lmin = 1,q_lmax = 99,q_itemID = 6200009,F5 = '突斩',q_shop = 4,q_type = 1,q_ingotprob = 50,q_ingot = 20000,q_all_limit = 1,q_role_limit = 1,Is_bd = 0,},
	{q_id = 39,q_lmin = 1,q_lmax = 99,q_itemID = 6200016,F5 = '流星火雨',q_shop = 4,q_type = 1,q_ingotprob = 50,q_ingot = 20000,q_all_limit = 1,q_role_limit = 1,Is_bd = 0,},
	{q_id = 40,q_lmin = 1,q_lmax = 99,q_itemID = 6200023,F5 = '强化骷髅',q_shop = 4,q_type = 1,q_ingotprob = 50,q_ingot = 20000,q_all_limit = 1,q_role_limit = 1,Is_bd = 0,},
	{q_id = 41,q_lmin = 1,q_lmax = 99,q_itemID = 6009,F5 = '金刚护体',q_shop = 4,q_type = 1,q_ingotprob = 50,q_ingot = 30000,q_all_limit = 1,q_role_limit = 1,Is_bd = 0,},
	{q_id = 42,q_lmin = 1,q_lmax = 99,q_itemID = 6007,F5 = '风影盾',q_shop = 4,q_type = 1,q_ingotprob = 50,q_ingot = 30000,q_all_limit = 1,q_role_limit = 1,Is_bd = 0,},
	{q_id = 43,q_lmin = 1,q_lmax = 99,q_itemID = 6008,F5 = '斗转星移',q_shop = 4,q_type = 1,q_ingotprob = 50,q_ingot = 30000,q_all_limit = 1,q_role_limit = 1,Is_bd = 0,},
	{q_id = 44,q_lmin = 1,q_lmax = 99,q_itemID = 6200088,F5 = '强化攻杀(专家)',q_shop = 4,q_type = 1,q_ingotprob = 10,q_ingot = 10000,q_all_limit = 1,q_role_limit = 1,Is_bd = 0,},
	{q_id = 45,q_lmin = 1,q_lmax = 99,q_itemID = 6200089,F5 = '强化火球(专家)',q_shop = 4,q_type = 1,q_ingotprob = 10,q_ingot = 10000,q_all_limit = 1,q_role_limit = 1,Is_bd = 0,},
	{q_id = 46,q_lmin = 1,q_lmax = 99,q_itemID = 6200090,F5 = '强化施毒(专家)',q_shop = 4,q_type = 1,q_ingotprob = 10,q_ingot = 10000,q_all_limit = 1,q_role_limit = 1,Is_bd = 0,},
	{q_id = 47,q_lmin = 1,q_lmax = 99,q_itemID = 6200065,F5 = '破盾斩(专家)',q_shop = 4,q_type = 1,q_ingotprob = 2,q_ingot = 20000,q_all_limit = 1,q_role_limit = 1,Is_bd = 0,},
	{q_id = 48,q_lmin = 1,q_lmax = 99,q_itemID = 6200075,F5 = '狂龙紫电(专家)',q_shop = 4,q_type = 1,q_ingotprob = 2,q_ingot = 20000,q_all_limit = 1,q_role_limit = 1,Is_bd = 0,},
	{q_id = 49,q_lmin = 1,q_lmax = 99,q_itemID = 6200086,F5 = '幽冥火咒(专家)',q_shop = 4,q_type = 1,q_ingotprob = 2,q_ingot = 20000,q_all_limit = 1,q_role_limit = 1,Is_bd = 0,},
	{q_id = 50,q_lmin = 1,q_lmax = 99,q_itemID = 6200066,F5 = '突斩(专家)',q_shop = 4,q_type = 1,q_ingotprob = 2,q_ingot = 40000,q_all_limit = 1,q_role_limit = 1,Is_bd = 0,},
	{q_id = 51,q_lmin = 1,q_lmax = 99,q_itemID = 6200076,F5 = '流星火雨(专家)',q_shop = 4,q_type = 1,q_ingotprob = 2,q_ingot = 40000,q_all_limit = 1,q_role_limit = 1,Is_bd = 0,},
	{q_id = 52,q_lmin = 1,q_lmax = 99,q_itemID = 6200087,F5 = '强化骷髅(专家)',q_shop = 4,q_type = 1,q_ingotprob = 2,q_ingot = 40000,q_all_limit = 1,q_role_limit = 1,Is_bd = 0,},
	{q_id = 53,q_lmin = 1,q_lmax = 99,q_itemID = 6200064,F5 = '金刚护体(专家)',q_shop = 4,q_type = 1,q_ingotprob = 2,q_ingot = 60000,q_all_limit = 1,q_role_limit = 1,Is_bd = 0,},
	{q_id = 54,q_lmin = 1,q_lmax = 99,q_itemID = 6200074,F5 = '风影盾(专家)',q_shop = 4,q_type = 1,q_ingotprob = 2,q_ingot = 60000,q_all_limit = 1,q_role_limit = 1,Is_bd = 0,},
	{q_id = 55,q_lmin = 1,q_lmax = 99,q_itemID = 6200085,F5 = '斗转星移(专家)',q_shop = 4,q_type = 1,q_ingotprob = 2,q_ingot = 60000,q_all_limit = 1,q_role_limit = 1,Is_bd = 0,},
	{q_id = 56,q_lmin = 1,q_lmax = 99,q_itemID = 1043,F5 = '祝福油',q_shop = 4,q_type = 1,q_ingotprob = 500,q_ingot = 50,q_all_limit = 500,q_role_limit = 50,Is_bd = 0,},
	{q_id = 57,q_lmin = 1,q_lmax = 99,q_itemID = 1081,F5 = '魔神雕像',q_shop = 4,q_type = 1,q_ingotprob = 1000,q_ingot = 50,q_all_limit = 500,q_role_limit = 50,Is_bd = 0,},
	{q_id = 58,q_lmin = 1,q_lmax = 99,q_itemID = 1419,F5 = '不屈(专家)',q_shop = 4,q_type = 1,q_ingotprob = 50,q_ingot = 3000,q_all_limit = 1,q_role_limit = 1,Is_bd = 0,},
	{q_id = 59,q_lmin = 1,q_lmax = 99,q_itemID = 1420,F5 = '秘技(专家)',q_shop = 4,q_type = 1,q_ingotprob = 50,q_ingot = 1000,q_all_limit = 1,q_role_limit = 1,Is_bd = 0,},
	{q_id = 60,q_lmin = 1,q_lmax = 99,q_itemID = 1421,F5 = '免伤(专家)',q_shop = 4,q_type = 1,q_ingotprob = 50,q_ingot = 5000,q_all_limit = 1,q_role_limit = 1,Is_bd = 0,},
	{q_id = 61,q_lmin = 1,q_lmax = 99,q_itemID = 1422,F5 = '穿透(专家)',q_shop = 4,q_type = 1,q_ingotprob = 50,q_ingot = 6000,q_all_limit = 1,q_role_limit = 1,Is_bd = 0,},
	{q_id = 62,q_lmin = 1,q_lmax = 99,q_itemID = 6200008,F5 = '强化攻杀',q_shop = 4,q_type = 1,q_ingotprob = 50,q_ingot = 5000,q_all_limit = 2,q_role_limit = 1,Is_bd = 0,},
	{q_id = 63,q_lmin = 1,q_lmax = 99,q_itemID = 6200014,F5 = '强化火球',q_shop = 4,q_type = 1,q_ingotprob = 50,q_ingot = 5000,q_all_limit = 2,q_role_limit = 1,Is_bd = 0,},
	{q_id = 64,q_lmin = 1,q_lmax = 99,q_itemID = 6200021,F5 = '强化施毒',q_shop = 4,q_type = 1,q_ingotprob = 50,q_ingot = 5000,q_all_limit = 2,q_role_limit = 1,Is_bd = 0,},
	{q_id = 65,q_lmin = 1,q_lmax = 99,q_itemID = 6200059,F5 = '攻杀剑术(专家)',q_shop = 5,q_type = 3,q_num = 1,q_countNum = -1,q_money = 200000,Is_bd = 1,},
	{q_id = 66,q_lmin = 1,q_lmax = 99,q_itemID = 6200060,F5 = '刺杀剑术(专家)',q_shop = 5,q_type = 3,q_num = 1,q_countNum = -1,q_money = 400000,Is_bd = 1,},
	{q_id = 67,q_lmin = 1,q_lmax = 99,q_itemID = 6200061,F5 = '抱月刀(专家)',q_shop = 5,q_type = 3,q_num = 1,q_countNum = -1,q_money = 400000,Is_bd = 1,},
	{q_id = 68,q_lmin = 1,q_lmax = 99,q_itemID = 6200068,F5 = '雷电术(专家)',q_shop = 5,q_type = 3,q_num = 1,q_countNum = -1,q_money = 250000,Is_bd = 1,},
	{q_id = 69,q_lmin = 1,q_lmax = 99,q_itemID = 6200069,F5 = '地狱雷光(专家)',q_shop = 5,q_type = 3,q_num = 1,q_countNum = -1,q_money = 250000,Is_bd = 1,},
	{q_id = 70,q_lmin = 1,q_lmax = 99,q_itemID = 6200070,F5 = '魔法盾(专家)',q_shop = 5,q_type = 3,q_num = 1,q_countNum = -1,q_money = 300000,Is_bd = 1,},
	{q_id = 71,q_lmin = 1,q_lmax = 99,q_itemID = 6200071,F5 = '抗拒火环(专家)',q_shop = 5,q_type = 3,q_num = 1,q_countNum = -1,q_money = 200000,Is_bd = 1,},
	{q_id = 72,q_lmin = 1,q_lmax = 99,q_itemID = 6200077,F5 = '集体隐身术(专家)',q_shop = 5,q_type = 3,q_num = 1,q_countNum = -1,q_money = 100000,Is_bd = 1,},
	{q_id = 73,q_lmin = 1,q_lmax = 99,q_itemID = 6200078,F5 = '灵魂道符(专家)',q_shop = 5,q_type = 3,q_num = 1,q_countNum = -1,q_money = 200000,Is_bd = 1,},
	{q_id = 74,q_lmin = 1,q_lmax = 99,q_itemID = 6200080,F5 = '施毒术(专家)',q_shop = 5,q_type = 3,q_num = 1,q_countNum = -1,q_money = 200000,Is_bd = 1,},
	{q_id = 75,q_lmin = 1,q_lmax = 99,q_itemID = 6200081,F5 = '神圣战甲术(专家)',q_shop = 5,q_type = 3,q_num = 1,q_countNum = -1,q_money = 200000,Is_bd = 1,},
	{q_id = 76,q_lmin = 1,q_lmax = 99,q_itemID = 6200084,F5 = '狮子吼(专家)',q_shop = 5,q_type = 3,q_num = 1,q_countNum = -1,q_money = 100000,Is_bd = 1,},
	{q_id = 77,q_lmin = 1,q_lmax = 99,q_itemID = 6200083,F5 = '骷髅召唤术(专家)',q_shop = 5,q_type = 3,q_num = 1,q_countNum = -1,q_money = 200000,Is_bd = 1,},
};
return Items
