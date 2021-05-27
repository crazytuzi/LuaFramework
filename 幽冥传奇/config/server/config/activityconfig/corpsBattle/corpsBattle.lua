
--#include "data\language\LangCode.txt"
corpsBattleConfig =
{
	nSceneId = 85,
	chinaRange = {78,84,15,15},
	outSceenId = 8,
	outRange = {150,180,2,2},
	nTime = 1800,
	nLevel = 45,
	AwardScore = 5,
	killActorScore = 1,
	lastTime = 5 * 60,
	Monsters =
	{
		{nMonsterID = 4830, posX1 = 78, posX2 = 84,  posY = 85, nCount = 1, nLiveTime = 1800,name = "",},
	},
	MonsterDie =
	{
		{nMonsterID = 4840, posX1 = 78, posX2 = 84,  posY = 85, nCount = 1, nLiveTime = 1800,name = "",},
	},
	buffConfig =
	{
		{buffType= 49, value=850, buffGroup= 10,times =1,interval= 300,needDelete =true,timeOverlay =true,buffName = "",},
		--{buffType= 91, value=1, buffGroup= 10,times =1,interval= 300,needDelete =true,timeOverlay =true,buffName = "",},
	},
	KillActorContinous =
	{
		{count=3,notice=Lang.Activity.c00017},
		{count=4,notice=Lang.Activity.c00018},
		{count=5,notice=Lang.Activity.c00024},
		{count=6,notice=Lang.Activity.c00025},
		{count=7,notice=Lang.Activity.c00026},
		{count=8,notice=Lang.Activity.c00027},
		{count=9,notice=Lang.Activity.c00028},
		{count=10,notice=Lang.Activity.c00029},
	},
	IntervalTime = 10,
	IntervalKillActor =
	{
		{count=2,notice=Lang.Activity.c00019},
		{count=3,notice=Lang.Activity.c00020},
		{count=4,notice=Lang.Activity.c00030},
		{count=5,notice=Lang.Activity.c00031},
	},
	awardConfig =
	{
		{ type = 0, id = 733, count = 1, strong = 0, quality = 0, bind = 1 },
	},
	corpsTitleId = 11,
	perTime = 15,
	givePerExp =
	{
		{ type = 20, id = 2, count = 20, strong = 0, quality = 0, bind = 0 },
	},
	giveBollExp =
	{
		{ type = 20, id = 2, count = 50, strong = 0, quality = 0, bind = 0 },
	},
}