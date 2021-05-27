
QuestType =
{
	qtMain = 0,
	qtSub1 = 1,
	qtFuben = 2,
	qtDay = 3,
	qtGuild = 4,
	qtChallenge = 5,
	qtRnd = 6,
	qtRecommended = 7,
	qtZyQuest = 8,
	qtEquip = 9,
	qtExp = 10,
	qtCoin = 11,
	qtBook = 12,
	qtRich = 13,
	qtSpecial = 14,
	qtSub2 = 15,
	qtMaxQuestType = 16,
}
branch_open_list = {3000,3007,}
branch_cfg =
{
	[3000] = --"穿戴6件65级以上装备"
	{
		ntype = 1,
		needLevel = 78,
	},
	[3007] = --"加入行会"
	{
		ntype = 15,
		needLevel = 78,
	},
}
everyday_open_list = {4000,4001,4002,4003,4004,4005,4006,4007,4008,4009,4010,4011,}
everyday_cfg =
{
[4000] = {
	ntype = 3,
	name = "除魔",
	needLevel = 51,
	tipLevel = 51,
	main_task_id = {53,62,75,79,82,85,89,},
	role_level =  {51,60,69,71,73,75,77,},
	maxCount = 20,
	maxFreedCount = 15,
	maxBuyCont = 5,
	npc = { id = 83, name = "除魔大师", scene_id = 2, x = 43, y = 87 },
	chuansongPointId = 13,
	scene_targets = {
		[9] = { x = 21, y = 25, entityName = "任意打怪" },
		[13] = { x = 21, y = 25, entityName = "任意打怪" },
		[11] = { x = 21, y = 25, entityName = "任意打怪" },
		[17] = { x = 21, y = 25, entityName = "任意打怪" },
	},
},
[4001] = {
	ntype = 3,
	name = "封魔岭",
	needLevel = 76,
	tipLevel = 76,
	leftCount = 2,
	npc = { id = 79, name = "封魔岭", scene_id = 2, x = 43, y = 68 },
	chuansongPointId = 9,
},
[4002] = {
	ntype = 3,
	name = "押镖",
	needLevel = 78,
	tipLevel = 78,
	npc1 = { id = 81, name = "军需官", scene_id = 218, x = 11, y = 38 },
	chuansongPointId = 21,
	npc2  = { id = 82, name = "总镖头", scene_id = 219, x = 20, y = 46 },
	target = { { type = 3, id = 0, count = 1, scene_id = 219, x = 20, y = 46, entityName = "总镖头" }, },
	awards = {
			{ type = 2, id = 0, count = 1000000, job = 0, sex = -1, },
			{ type = 0, id = 534, count = 2000, job = 0, sex = -1, },
		},
},
[4003] = {
	ntype = 3,
	name = "材料副本",
	needLevel = 60,
	tipLevel = 77,
	npc = { id = 80, name = "副本总管", scene_id = 2, x = 46, y = 65 },
	chuansongPointId = 10,
	fubens = {
		{
			target = { { type = 0, id = 0, count = 13, scene_id = 82, x = 21, y = 26, entityName = "任意怪" }, },
			awards = {
				{ type = 2, id = 0, count = 1000000, job = 0, sex = -1, },
				{ type = 0, id = 534, count = 2000, job = 0, sex = -1, },
			},
		},
		{
			target = { { type = 0, id = 0, count = 13, scene_id = 83, x = 21, y = 26, entityName = "任意怪" }, },
			awards = {
				{ type = 2, id = 0, count = 1000000, job = 0, sex = -1, },
				{ type = 0, id = 839, count = 2000, job = 0, sex = -1, },
			},
		},
		{
			target = { { type = 0, id = 0, count = 13, scene_id = 84, x = 21, y = 26, entityName = "任意怪" }, },
			awards = {
				{ type = 2, id = 0, count = 1000000, job = 0, sex = -1, },
				{ type = 0, id = 534, count = 2000, job = 0, sex = -1, },
			},
		},
		{
			target = { { type = 0, id = 0, count = 13, scene_id = 85, x = 21, y = 26, entityName = "任意怪" }, },
			awards = {
				{ type = 2, id = 0, count = 1000000, job = 0, sex = -1, },
				{ type = 0, id = 534, count = 2000, job = 0, sex = -1, },
			},
		},
		{
			target = { { type = 0, id = 0, count = 13, scene_id = 86, x = 21, y = 26, entityName = "任意怪" }, },
			awards = {
				{ type = 2, id = 0, count = 1000000, job = 0, sex = -1, },
				{ type = 0, id = 534, count = 2000, job = 0, sex = -1, },
			},
		},
		{
			target = { { type = 0, id = 0, count = 13, scene_id = 87, x = 21, y = 26, entityName = "任意怪" }, },
			awards = {
				{ type = 2, id = 0, count = 1000000, job = 0, sex = -1, },
				{ type = 0, id = 534, count = 2000, job = 0, sex = -1, },
			},
		},
	},
},
[4004] = {
	ntype = 3,
	name = "闯天关",
	needLevel = 70,
	tipLevel = 70,
	npc = { id = 93, name = "闯天关", scene_id = 2, x = 49, y = 62 },
	chuansongPointId = 24,
},
[4005] = {
	ntype = 3,
	name = "未知暗殿",
	needLevel = 60,
	tipLevel = 60,
	npc = { id = 84, name = "未知暗殿", scene_id = 2, x = 59, y = 52 },
	chuansongPointId = 1,
},
[4006] = {
	ntype = 3,
	name = "BOSS之家",
	needLevel = 74,
	tipLevel = 74,
	npc = { id = 85, name = "BOSS之家", scene_id = 2, x = 62, y = 53 },
	chuansongPointId = 2,
},
[4007] = {
	ntype = 3,
	name = "挑战BOSS",
	needLevel = 76,
	tipLevel = 76,
	target = { { type = 45, id = 210, count = 1, scene_id = 0, x = 0, y = 0, entityName = "" }, },
},
[4008] = {
	ntype = 3,
	name = "休闲挂机",
	needLevel = 70,
	tipLevel = 70,
	npc = { id = 90, name = "休闲挂机", scene_id = 2, x = 64, y = 82 },
	chuansongPointId = 11,
},
[4009] = {
	ntype = 3,
	name = "如何变强",
	needLevel = 80,
	tipLevel = 80,
	target = { { type = 45, id = 291, count = 1, scene_id = 0, x = 0, y = 0, entityName = "", }, },
},
[4010] = {
	ntype = 3,
	name = "多人副本",
	needLevel = 80,
	tipLevel = 80,
	npc = { id = 179, name = "多人副本", scene_id = 2, x = 53, y = 58 },
	chuansongPointId = 37,
},
[4011] = {
	ntype = 3,
	name = "战魂兑换",
	needLevel = 80,
	tipLevel = 80,
	target = { { type = 45, id = 38, count = 1, scene_id = 0, x = 0, y = 0, entityName = "", }, },
},
}
