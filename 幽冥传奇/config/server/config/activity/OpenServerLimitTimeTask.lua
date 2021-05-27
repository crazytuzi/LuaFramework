
OpenServerLimitTimeTaskCfg =
{
	openlimitLevel = 61,
	limitTimes = 259200,
	runeRewardTxt = "{image;res/xui/common/orn_100.png;25,20}{colorandsize;FF0000;20;集齐3块符文}\n必杀技能对玩家伤害提高到{colorandsize;1eff00;20;140%}\n{image;res/xui/common/orn_100.png;25,20}{colorandsize;FF0000;20;集齐5块符文}\n必杀技能对怪物伤害提高到{colorandsize;1eff00;20;700%}\n{image;res/xui/common/orn_100.png;25,20}{colorandsize;FF0000;20;集齐8块符文}\n怒气恢复速度{colorandsize;1eff00;20;+5%}",
	task =
	{
		{
			limitTimes = 5,
			isStart = 0,
			award = {{type=0, id=2836, count=1,bind=1},},
			taskDesc = "击杀野外boss",
			btnClickParam = {viewLink = "Boss"}
		},
		{
			limitTimes = 10,
			isStart = 1,
			award = {{type=0, id=2837, count=1,bind=1},},
			taskDesc = "参与寻宝",
			btnClickParam = {viewLink = "Explore"}
		},
		{
			limitTimes = 12,
			isStart = 0,
			award = {{type=0, id=2838, count=1,bind=1},},
			taskDesc = "材料副本",
			btnClickParam = {viewLink = "Dungeon"}
		},
		{
			limitTimes = 20,
			isStart = 0,
			award = {{type=0, id=2839, count=1,bind=1},},
			taskDesc = "闯关卡20关",
			btnClickParam = {viewLink = "ShiLian"}
		},
		{
			limitTimes = 10,
			isStart = 1,
			award = {{type=0, id=2840, count=1,bind=1},},
			taskDesc = "击杀个人boss",
			btnClickParam = {viewLink = "Boss"}
		},
		{
			limitTimes = 3,
			isStart = 0,
			award = {{type=0, id=2841, count=1,bind=1},},
			taskDesc = "翅膀升至3阶",
			btnClickParam = {viewLink = "Wing"}
		},
		{
			limitTimes = 10,
			isStart = 1,
			award = {{type=0, id=2842, count=1,bind=1},},
			taskDesc = "击杀玩家(10个)",
			btnClickParam = {moveto = "2"}
		},
		{
			limitTimes = 1,
			isStart = 0,
			award = {{type=0, id=2843, count=1,bind=1},},
			taskDesc = "首充或者次日登陆",
			btnClickParam = {viewLink = "ChargeFirst"}
		},
	},
}