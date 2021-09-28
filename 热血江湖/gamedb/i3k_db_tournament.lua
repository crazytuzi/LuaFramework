i3k_db_tournament =
{
	[1] = { id = 1, name = '龙虎乱斗', mapId = 25000, openDay = { 1, 2, 3, 4, 5, 6, 0, }, startTime = {'19:00:00', }, lifeTime = 14400, needLvl = 40, maxTime = 600, iconId = 6139, roomMemberCount = 4, sortID = 2, canUseDrugs = 1, sceneSkill = 0, isFightPets = 1 },
	[2] = { id = 2, name = '猛龙过江', mapId = 25001, openDay = { }, startTime = {'19:00:00', }, lifeTime = 14400, needLvl = 35, maxTime = 300, iconId = 6140, roomMemberCount = 2, sortID = 4, canUseDrugs = 1, sceneSkill = 0, isFightPets = 1 },
	[3] = { id = 3, name = '神兵乱战', mapId = 25002, openDay = { 1, 2, 3, 4, 5, 6, 0, }, startTime = {'19:00:00', }, lifeTime = 14400, needLvl = 40, maxTime = 480, iconId = 6141, roomMemberCount = 4, sortID = 3, canUseDrugs = 0, sceneSkill = 1, isFightPets = 0 },
	[4] = { id = 4, name = '楚汉之争', mapId = 25003, openDay = { 1, 2, 3, 4, 5, 6, 0, }, startTime = {'19:00:00', }, lifeTime = 10800, needLvl = 40, maxTime = 300, iconId = 8542, roomMemberCount = 4, sortID = 1, canUseDrugs = 0, sceneSkill = 0, isFightPets = 0 },
};
i3k_db_tournament_weapon_skills =
{
	[1] = { skillID = 91014, skillIcon = 5893, useTimes = 10, skillDesc = '111.0' },
	[2] = { skillID = 91015, skillIcon = 5894, useTimes = 10, skillDesc = '111.0' },
	[3] = { skillID = 91016, skillIcon = 5895, useTimes = 10, skillDesc = '111.0' },
};
i3k_db_chess_generals =
{
	[1] = { id = 1, camp = 1, arms = 1, maleModelID = 801, girlModelID = 802, name = '楚-将', desc = '“将军”，军中王者，举手投足之间令敌军丢盔弃甲。\n职业定位：群体回血，增加己方阵营攻击力，并拥有群体控制技能。', classImg = 365, modelID = 4030, chessProperties = {{ id = 1001, value = 280500.0},{ id = 1002, value = 18000.0},{ id = 1003, value = 9000.0},{ id = 1004, value = 3500.0},{ id = 1005, value = 3675.0},{ id = 1006, value = 3150.0},{ id = 1007, value = 2100.0},}, chuhanImg = 419 },
	[2] = { id = 2, camp = 1, arms = 2, maleModelID = 803, girlModelID = 804, name = '楚-卒', desc = '“重甲兵”，战场排头兵，正面战场的无冕王者。\n职业定位：坦克，为自身增加防御，为自身回复气血，拥有强大的生存能力。', classImg = 366, modelID = 4031, chessProperties = {{ id = 1001, value = 250113.0},{ id = 1002, value = 18000.0},{ id = 1003, value = 11000.0},{ id = 1004, value = 3500.0},{ id = 1005, value = 3675.0},{ id = 1006, value = 3325.0},{ id = 1007, value = 2100.0},}, chuhanImg = 423 },
	[3] = { id = 3, camp = 1, arms = 3, maleModelID = 805, girlModelID = 806, name = '楚-车', desc = '“战车”，攻击力巨大，所过之处寸草不留。\n职业定位：高攻击，可临时提升自身攻击属性，战斗中可沉默对手。', classImg = 367, modelID = 4032, chessProperties = {{ id = 1001, value = 222063.0},{ id = 1002, value = 22000.0},{ id = 1003, value = 9500.0},{ id = 1004, value = 3150.0},{ id = 1005, value = 3500.0},{ id = 1006, value = 3150.0},{ id = 1007, value = 2000.0},}, chuhanImg = 420 },
	[4] = { id = 4, camp = 1, arms = 4, maleModelID = 807, girlModelID = 808, name = '楚-炮', desc = '“炮兵”，攻坚利器，对目标造成巨额伤害。\n职业定位：高暴击，可临时提升自身暴击属性，战斗中可定身对手。', classImg = 368, modelID = 4034, chessProperties = {{ id = 1001, value = 222063.0},{ id = 1002, value = 20000.0},{ id = 1003, value = 9500.0},{ id = 1004, value = 3500.0},{ id = 1005, value = 3500.0},{ id = 1006, value = 4200.0},{ id = 1007, value = 2000.0},}, chuhanImg = 422 },
	[5] = { id = 5, camp = 1, arms = 5, maleModelID = 809, girlModelID = 810, name = '楚-马', desc = '“骑兵”，轻捷迅速，擅奇兵，入战场而奠定胜局。\n职业定位：高躲闪，可临时提升自身躲闪，战斗中可减速对手。', classImg = 369, modelID = 4033, chessProperties = {{ id = 1001, value = 222063.0},{ id = 1002, value = 21000.0},{ id = 1003, value = 9500.0},{ id = 1004, value = 3325.0},{ id = 1005, value = 3850.0},{ id = 1006, value = 3500.0},{ id = 1007, value = 2000.0},}, chuhanImg = 421 },
	[6] = { id = 6, camp = 2, arms = 1, maleModelID = 811, girlModelID = 812, name = '汉-帅', desc = '“将军”，军中王者，举手投足之间令敌军丢盔弃甲。\n职业定位：群体回血，增加己方阵营攻击力，并拥有群体控制技能。', classImg = 370, modelID = 4025, chessProperties = {{ id = 1001, value = 280500.0},{ id = 1002, value = 18000.0},{ id = 1003, value = 9000.0},{ id = 1004, value = 3500.0},{ id = 1005, value = 3675.0},{ id = 1006, value = 3150.0},{ id = 1007, value = 2100.0},}, chuhanImg = 450 },
	[7] = { id = 7, camp = 2, arms = 2, maleModelID = 813, girlModelID = 814, name = '汉-兵', desc = '“重甲兵”，战场排头兵，正面战场的无冕王者。\n职业定位：坦克，为自身增加防御，为自身回复气血，拥有强大的生存能力。', classImg = 371, modelID = 4026, chessProperties = {{ id = 1001, value = 250113.0},{ id = 1002, value = 18000.0},{ id = 1003, value = 11000.0},{ id = 1004, value = 3500.0},{ id = 1005, value = 3675.0},{ id = 1006, value = 3325.0},{ id = 1007, value = 2100.0},}, chuhanImg = 446 },
	[8] = { id = 8, camp = 2, arms = 3, maleModelID = 815, girlModelID = 816, name = '汉-车', desc = '“战车”，攻击力巨大，所过之处寸草不留。\n职业定位：高攻击，可临时提升自身攻击属性，战斗中可沉默对手。', classImg = 372, modelID = 4027, chessProperties = {{ id = 1001, value = 222063.0},{ id = 1002, value = 22000.0},{ id = 1003, value = 9500.0},{ id = 1004, value = 3150.0},{ id = 1005, value = 3500.0},{ id = 1006, value = 3150.0},{ id = 1007, value = 2000.0},}, chuhanImg = 447 },
	[9] = { id = 9, camp = 2, arms = 4, maleModelID = 817, girlModelID = 818, name = '汉-炮', desc = '“炮兵”，攻坚利器，对目标造成巨额伤害。\n职业定位：高暴击，可临时提升自身暴击属性，战斗中可定身对手。', classImg = 373, modelID = 4029, chessProperties = {{ id = 1001, value = 222063.0},{ id = 1002, value = 20000.0},{ id = 1003, value = 9500.0},{ id = 1004, value = 3500.0},{ id = 1005, value = 3500.0},{ id = 1006, value = 4200.0},{ id = 1007, value = 2000.0},}, chuhanImg = 449 },
	[10] = { id = 10, camp = 2, arms = 5, maleModelID = 819, girlModelID = 820, name = '汉-马', desc = '“骑兵”，轻捷迅速，擅奇兵，入战场而奠定胜局。\n职业定位：高躲闪，可临时提升自身躲闪，战斗中可减速对手。', classImg = 374, modelID = 4028, chessProperties = {{ id = 1001, value = 222063.0},{ id = 1002, value = 21000.0},{ id = 1003, value = 9500.0},{ id = 1004, value = 3325.0},{ id = 1005, value = 3850.0},{ id = 1006, value = 3500.0},{ id = 1007, value = 2000.0},}, chuhanImg = 448 },
};
i3k_db_tournament_week_reward =
{
	[1] = { id = 1, needTimes = 1, desc = '参与任意会武%s场(%s/%s)', itemId = 5, itemCount = 500, title = '一马当先' },
	[2] = { id = 2, needTimes = 3, desc = '参与任意会武%s场(%s/%s)', itemId = 5, itemCount = 1200, title = '破釜沉舟' },
	[3] = { id = 3, needTimes = 5, desc = '参与任意会武%s场(%s/%s)', itemId = 5, itemCount = 1800, title = '势如破竹' },
	[4] = { id = 4, needTimes = 7, desc = '参与任意会武%s场(%s/%s)', itemId = 5, itemCount = 2000, title = '战无不胜' },
	[5] = { id = 5, needTimes = 15, desc = '参与任意会武%s场(%s/%s)', itemId = 5, itemCount = 4500, title = '攻无不克' },
};
