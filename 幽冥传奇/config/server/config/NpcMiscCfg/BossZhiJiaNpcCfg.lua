BossZhiJiaNpcCfg =
{
	level = 60,
	viplv = 0,
	money = 0,
	maxlayer = 4,
	enterCond =
	{
		"进入条件: {color;ff00ff00;300级以上}\n",
		"进入条件: {color;ff00ff00;300级以上}\n",
		"进入条件: {color;ff00ff00;300级以上}\n",
		"进入条件: {color;ff00ff00;300级以上}\n",
	},
	enterConsume =
	{
		"进入消耗: {color;ffff0000;无}",
		"进入消耗: {color;ffff0000;(每次进去仙宫东阁消耗100000元宝)}",
		"进入消耗: {color;ffff0000;(每次进去仙宫西阁消耗300000元宝)}",
		"进入消耗: {color;ffff0000;(每次进去仙宫后阁消耗500000元宝)}",
	},
	maplayer = "{flag;0}地图层数: {color;ff00ff00;3层}\n",
	sbossCount = "{flag;0}BOSS数量: \n   仙宫东阁：{color;ff00ff00;灵级BOSS-帝级BOSS}\n   仙宫西阁：{color;ff00ff00;尊级BOSS-嗜魔级BOSS}\n   仙宫东阁：{color;ff00ff00;尊级BOSS-主宰级BOSS}\n",
	refresh = "{flag;0}刷新时间: {color;ff00ff00;5-180分钟}\n",
	dropt = "{flag;0}掉落预览: {reward;0;687;1}{reward;0;688;1}{reward;0;689;1}{reward;0;690;1}",
	enterBtn = "{btn;0;进入地图;%s;%s}",
	payBtn = "",
	layer =
	{
		{viplv = 0, plv = 300, consumeyb = 0, sceneId = 56, name = "真云仙宫", x = 61, y = 13},
		{viplv = 0, plv = 300, consumeyb = 100000, sceneId = 58, name = "仙宫东阁", x = 124, y = 8},
		{viplv = 0, plv = 300, consumeyb = 300000, sceneId = 59, name = "仙宫西阁", x = 71, y = 102},
		{viplv = 0, plv = 300, consumeyb = 500000, sceneId = 57, name = "仙宫后阁", x = 60, y = 102},
	},
	RwData = {"比奇城", "{moveto;%d;[我也要进入]}"},
}