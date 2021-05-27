
CuttingConfig =
{
	opendays = 1,
	openLevel = 300,
	opencircle = 0,
	openviplv = 0,
	effectCount = 3,
	quest = {nQId = 72, targetType = 20, id = 3, count = 1,},
	upgradeCfg =
	{
--#include "CuttingUpgradeConfig.lua"
	},
	mailcfg =
	{
		title = "切割系统提示",
		desc = "您好, 您的切割系统——%s效果所获得的物品已达到最大上限, 无法继续凝结新的物品, 为了避免您的损失, 请及时前往领取！",
	},
	effectCfg =
	{
		[1] =
		{
			id = 1,
			name = "锋锐石",
			cuttinglevel = 1,
			bossType = 1,
			killCount = 1,
			maxAwardsCount = 50000000,
			desc = "可凝结1个锋锐石,可前往[激战BOSS-野外]击杀获得",
			condition = "每击杀1只野外BOSS",
			awards = {{type = 0, id = 1480, count = 1, bind = 1,},},
		},
		[2] =
		{
			id = 2,
			name = "魔血丹",
			cuttinglevel = 1,
			bossType = 2,
			killCount = 3,
			maxAwardsCount = 50000000,
			desc = "可凝结1个魔血丹,可前往[激战BOSS-稀有]击杀获得",
			condition = "每击杀3只稀有BOSS",
			awards = {{type = 0, id = 1481, count = 1, bind = 1,},},
		},
		[3] =
		{
			id = 3,
			name = "妖骨骸",
			cuttinglevel = 1,
			bossType = 3,
			killCount = 1,
			maxAwardsCount = 50000000,
			desc = "可凝结3个妖骨骸,可前往[激战BOSS-稀有-运势BOSS]击杀获得",
			condition = "每击杀1只运势BOSS",
			awards = {{type = 0, id = 1482, count = 3, bind = 1,},},
		},
	},
	daytasks =
	{
[1] ={bossType = 1,name = "激战BOSS-野外",killCount = 2,awards = {{type = 0, id = 1480, count = 5, bind = 1,},},},
[2] ={bossType = 1,name = "激战BOSS-野外",killCount = 4,awards = {{type = 0, id = 1480, count = 10, bind = 1,},},},
[3] ={bossType = 1,name = "激战BOSS-野外",killCount = 8,awards = {{type = 0, id = 1480, count = 15, bind = 1,},},},
[4] ={bossType = 1,name = "激战BOSS-野外",killCount = 12,awards = {{type = 0, id = 1480, count = 20, bind = 1,},},},
[5] ={bossType = 1,name = "激战BOSS-野外",killCount = 20,awards = {{type = 0, id = 1480, count = 30, bind = 1,},},},
[6] ={bossType = 2,name = "激战BOSS-稀有",killCount = 2,awards = {{type = 0, id = 1480, count = 5, bind = 1,},},},
[7] ={bossType = 2,name = "激战BOSS-稀有",killCount = 4,awards = {{type = 0, id = 1480, count = 10, bind = 1,},},},
[8] ={bossType = 2,name = "激战BOSS-稀有",killCount = 6,awards = {{type = 0, id = 1480, count = 15, bind = 1,},},},
[9] ={bossType = 2,name = "激战BOSS-稀有",killCount = 8,awards = {{type = 0, id = 1480, count = 20, bind = 1,},},},
[10] ={bossType = 2,name = "激战BOSS-稀有",killCount = 12,awards = {{type = 0, id = 1480, count = 30, bind = 1,},},},
[11] ={bossType = 2,name = "激战BOSS-稀有",killCount = 15,awards = {{type = 0, id = 1480, count = 40, bind = 1,},},},
[12] ={bossType = 2,name = "激战BOSS-稀有",killCount = 18,awards = {{type = 0, id = 1480, count = 50, bind = 1,},},},
[13] ={bossType = 2,name = "激战BOSS-稀有",killCount = 20,awards = {{type = 0, id = 1480, count = 60, bind = 1,},},},
[14] ={bossType = 3,name = "运势BOSS",killCount = 2,awards = {{type = 0, id = 1480, count = 10, bind = 1,},},},
[15] ={bossType = 3,name = "运势BOSS",killCount = 4,awards = {{type = 0, id = 1480, count = 30, bind = 1,},},},
[16] ={bossType = 3,name = "运势BOSS",killCount = 8,awards = {{type = 0, id = 1480, count = 50, bind = 1,},},},
[17] ={bossType = 3,name = "运势BOSS",killCount = 12,awards = {{type = 0, id = 1480, count = 100, bind = 1,},},},
	},
}