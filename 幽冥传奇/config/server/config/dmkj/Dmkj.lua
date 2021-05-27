
--#include"..\..\language\LangCode.txt"once
DmkjConfig =
{
	openlimit = {
		circle = 0,
		level = 160,
		serverday = 0,
		},
	Treasure =
	{
		{count=1, item = {type = 0, id = 833, count = 1}, integral = 1,},
		{count=10, item = {type = 0, id = 833, count = 10}, integral = 10,},
		{count=50, item = {type = 0, id = 833, count = 50}, integral = 50,},
	},
	moneys = {type = 15, id = 0, count = 1000};
	fullSvrAwards =
	{
		[1] =
		{
			dmTimes = 100,
			addDmTimes = 100,
			awards = {{type = 0, id = 2057, count = 20, bind = 0},},
		},
		[2] =
		{
			dmTimes = 100,
			addDmTimes = 200,
			awards = {{type = 0, id = 2057, count = 40, bind = 0},},
		},
		[3] =
		{
			dmTimes = 300,
			addDmTimes = 500,
			awards = {{type = 0, id = 2057, count = 60, bind = 0},},
		},
		[4] =
		{
			dmTimes = 500,
			addDmTimes = 1000,
			awards = {{type = 0, id = 2057, count = 80, bind = 0},},
		},
		[5] =
		{
			dmTimes = 1000,
			addDmTimes = 2000,
			awards = {{type = 0, id = 2097, count = 1, bind = 0},},
		},
	},
	mailTips =
	{
		title = "全服探宝奖励",
		desc = "{color;ffffff00;伟大的勇士，恭喜您获得了}{color;ff0000ff;探宝-全服进度%d次}{color;ffffff00;的}{color;ffff0000;幸运玩家}{color;ffffff00;身份，并获得奖励； 请您查收！}",
	},
	blessing = {
		probability = 10000,
		point = 1,
	},
	TreasurePool =
	{
--#include "DmkjDayPool\openServrer1Day.lua"
--#include "DmkjDayPool\openServrer3Day.lua"
--#include "DmkjDayPool\openServrer8Day.lua"
--#include "DmkjDayPool\openServrer15Day.lua"
--#include "DmkjDayPool\openServrer30Day.lua"
	},
	blessingPool = {
--#include "BlessingDayPool\openServer1DayBlessing.lua"
--#include "BlessingDayPool\openServer3DayBlessing.lua"
--#include "BlessingDayPool\openServer8DayBlessing.lua"
--#include "BlessingDayPool\openServer15DayBlessing.lua"
	},
	xunbao_blessing_max = {100, 250, 500, 1500, 3000},
	individualCfg =
	{
		[1] = {dmTimes = 10, awards = {{type = 0, id = 2053, count = 10, bind = 1,},},},
        [2] = {dmTimes = 20, awards = {{type = 0, id = 2053, count = 15, bind = 1,},},},
        [3] = {dmTimes = 30, awards = {{type = 0, id = 2053, count = 20, bind = 1,},},},
        [4] = {dmTimes = 40, awards = {{type = 0, id = 2053, count = 25, bind = 1,},},},
        [5] = {dmTimes = 50, awards = {{type = 0, id = 2053, count = 30, bind = 1,},},},
        [6] = {dmTimes = 60, awards = {{type = 0, id = 2053, count = 35, bind = 1,},},},
        [7] = {dmTimes = 80, awards = {{type = 0, id = 2053, count = 45, bind = 1,},},},
        [8] = {dmTimes = 100, awards = {{type = 0, id = 2053, count = 55, bind = 1,},},},
        [9] = {dmTimes = 120, awards = {{type = 0, id = 2053, count = 65, bind = 1,},},},
        [10] = {dmTimes = 140, awards = {{type = 0, id = 2053, count = 75, bind = 1,},},},
        [11] = {dmTimes = 170, awards = {{type = 0, id = 2053, count = 90, bind = 1,},},},
        [12] = {dmTimes = 200, awards = {{type = 0, id = 2053, count = 105, bind = 1,},},},
        [13] = {dmTimes = 250, awards = {{type = 0, id = 2053, count = 120, bind = 1,},},},
        [14] = {dmTimes = 300, awards = {{type = 0, id = 2053, count = 135, bind = 1,},},},
        [15] = {dmTimes = 400, awards = {{type = 0, id = 2053, count = 160, bind = 1,},},},
        [16] = {dmTimes = 500, awards = {{type = 0, id = 2053, count = 200, bind = 1,},},},
	},
	LoongDmCfg =
	{
		maxDmTms = 200,
		maxRecordCount = 100,
		LoongDmPool =
		{
--#include "LoongDmPool\loongdmpool.lua"
		},
		LoongKingTreasureTroveCfg =
		{
			maxFreeTms = 3,
			maxBuyTms = 20,
			buyTmsConsumes =
			{
				{{type = 15, id = 0, count = 588,},},
				{{type = 15, id = 0, count = 688,},},
				{{type = 15, id = 0, count = 788,},},
				{{type = 15, id = 0, count = 888,},},
				{{type = 15, id = 0, count = 988,},},
				{{type = 15, id = 0, count = 988,},},
				{{type = 15, id = 0, count = 988,},},
				{{type = 15, id = 0, count = 988,},},
				{{type = 15, id = 0, count = 988,},},
				{{type = 15, id = 0, count = 988,},},
				{{type = 15, id = 0, count = 1088,},},
				{{type = 15, id = 0, count = 1088,},},
				{{type = 15, id = 0, count = 1088,},},
				{{type = 15, id = 0, count = 1088,},},
				{{type = 15, id = 0, count = 1088,},},
				{{type = 15, id = 0, count = 1088,},},
				{{type = 15, id = 0, count = 1088,},},
				{{type = 15, id = 0, count = 1088,},},
				{{type = 15, id = 0, count = 1088,},},
				{{type = 15, id = 0, count = 1088,},},
			},
			LoongSceneCfg =
			{
				--	boss_name = "秘境\n·\n冰皇圣守爆熊",
{ openDmTms =10,level = 300,circle = 0,costDmValue = 10,sceneId = 252,layer = 1,x = 26,y = 32,boss_name ="龙皇·魔龙教主",boss_level = 500,boss_id = 1845,awards ={{item_id = 1781, num = 0, is_bind = 1},{item_id = 1811, num = 0, is_bind = 0},{item_id = 2258, num = 0, is_bind = 0},{item_id = 2259, num = 0, is_bind = 0},{item_id = 2260, num = 0, is_bind = 0},{item_id = 2261, num = 0, is_bind = 0},},},
{ openDmTms =10,level = 300,circle = 0,costDmValue = 10,sceneId = 252,layer = 2,x = 26,y = 32,boss_name ="龙皇·魔龙教主",boss_level = 600,boss_id = 1846,awards ={{item_id = 1871, num = 0, is_bind = 1},{item_id = 1901, num = 0, is_bind = 0},{item_id = 2258, num = 0, is_bind = 0},{item_id = 2259, num = 0, is_bind = 0},{item_id = 2260, num = 0, is_bind = 0},{item_id = 2261, num = 0, is_bind = 0},},},
{ openDmTms =10,level = 300,circle = 0,costDmValue = 10,sceneId = 252,layer = 3,x = 26,y = 32,boss_name ="龙皇·魔龙教主",boss_level = 800,boss_id = 1847,awards ={{item_id = 1781, num = 0, is_bind = 1},{item_id = 1811, num = 0, is_bind = 0},{item_id = 2258, num = 0, is_bind = 0},{item_id = 2259, num = 0, is_bind = 0},{item_id = 2260, num = 0, is_bind = 0},{item_id = 2261, num = 0, is_bind = 0},},},
{ openDmTms =10,level = 300,circle = 0,costDmValue = 10,sceneId = 252,layer = 4,x = 26,y = 32,boss_name ="龙皇·魔龙教主",boss_level = 1000,boss_id = 1848,awards ={{item_id = 1871, num = 0, is_bind = 1},{item_id = 1901, num = 0, is_bind = 0},{item_id = 2258, num = 0, is_bind = 0},{item_id = 2259, num = 0, is_bind = 0},{item_id = 2260, num = 0, is_bind = 0},{item_id = 2261, num = 0, is_bind = 0},},},
{ openDmTms =10,level = 300,circle = 0,costDmValue = 10,sceneId = 252,layer = 5,x = 26,y = 32,boss_name ="龙皇·魔龙教主",boss_level = 1200,boss_id = 1849,awards ={{item_id = 1781, num = 0, is_bind = 1},{item_id = 1811, num = 0, is_bind = 0},{item_id = 2258, num = 0, is_bind = 0},{item_id = 2259, num = 0, is_bind = 0},{item_id = 2260, num = 0, is_bind = 0},{item_id = 2261, num = 0, is_bind = 0},},},
{ openDmTms =50,level = 300,circle = 0,costDmValue = 16,sceneId = 253,layer = 6,x = 26,y = 32,boss_name ="龙皇·雪域魔王",boss_level = 1500,boss_id = 263,awards ={{item_id = 1781, num = 0, is_bind = 1},{item_id = 1811, num = 0, is_bind = 0},{item_id = 2258, num = 0, is_bind = 0},{item_id = 2259, num = 0, is_bind = 0},{item_id = 2260, num = 0, is_bind = 0},{item_id = 2261, num = 0, is_bind = 0},},},
{ openDmTms =50,level = 300,circle = 0,costDmValue = 16,sceneId = 253,layer = 7,x = 26,y = 32,boss_name ="龙皇·雪域魔王",boss_level = 1600,boss_id = 264,awards ={{item_id = 1871, num = 0, is_bind = 1},{item_id = 1901, num = 0, is_bind = 0},{item_id = 2258, num = 0, is_bind = 0},{item_id = 2259, num = 0, is_bind = 0},{item_id = 2260, num = 0, is_bind = 0},{item_id = 2261, num = 0, is_bind = 0},},},
{ openDmTms =50,level = 300,circle = 0,costDmValue = 16,sceneId = 253,layer = 8,x = 26,y = 32,boss_name ="龙皇·雪域魔王",boss_level = 1700,boss_id = 265,awards ={{item_id = 1781, num = 0, is_bind = 1},{item_id = 1811, num = 0, is_bind = 0},{item_id = 2258, num = 0, is_bind = 0},{item_id = 2259, num = 0, is_bind = 0},{item_id = 2260, num = 0, is_bind = 0},{item_id = 2261, num = 0, is_bind = 0},},},
{ openDmTms =50,level = 300,circle = 0,costDmValue = 16,sceneId = 253,layer = 9,x = 26,y = 32,boss_name ="龙皇·雪域魔王",boss_level = 1800,boss_id = 266,awards ={{item_id = 1871, num = 0, is_bind = 1},{item_id = 1901, num = 0, is_bind = 0},{item_id = 2258, num = 0, is_bind = 0},{item_id = 2259, num = 0, is_bind = 0},{item_id = 2260, num = 0, is_bind = 0},{item_id = 2261, num = 0, is_bind = 0},},},
{ openDmTms =50,level = 300,circle = 0,costDmValue = 16,sceneId = 253,layer = 10,x = 26,y = 32,boss_name ="龙皇·雪域魔王",boss_level = 1900,boss_id = 267,awards ={{item_id = 1781, num = 0, is_bind = 1},{item_id = 1811, num = 0, is_bind = 0},{item_id = 2258, num = 0, is_bind = 0},{item_id = 2259, num = 0, is_bind = 0},{item_id = 2260, num = 0, is_bind = 0},{item_id = 2261, num = 0, is_bind = 0},},},
{ openDmTms =100,level = 300,circle = 0,costDmValue = 20,sceneId = 254,layer = 11,x = 137,y = 26,boss_name ="龙皇·千年魅狐王",boss_level = 2000,boss_id = 268,awards ={{item_id = 1782, num = 0, is_bind = 1},{item_id = 1812, num = 0, is_bind = 0},{item_id = 2258, num = 0, is_bind = 0},{item_id = 2259, num = 0, is_bind = 0},{item_id = 2260, num = 0, is_bind = 0},{item_id = 2261, num = 0, is_bind = 0},},},
{ openDmTms =100,level = 300,circle = 0,costDmValue = 20,sceneId = 254,layer = 12,x = 137,y = 26,boss_name ="龙皇·千年魅狐王",boss_level = 2100,boss_id = 269,awards ={{item_id = 1872, num = 0, is_bind = 1},{item_id = 1902, num = 0, is_bind = 0},{item_id = 2258, num = 0, is_bind = 0},{item_id = 2259, num = 0, is_bind = 0},{item_id = 2260, num = 0, is_bind = 0},{item_id = 2261, num = 0, is_bind = 0},},},
{ openDmTms =100,level = 300,circle = 0,costDmValue = 20,sceneId = 254,layer = 13,x = 137,y = 26,boss_name ="龙皇·千年魅狐王",boss_level = 2200,boss_id = 270,awards ={{item_id = 1782, num = 0, is_bind = 1},{item_id = 1812, num = 0, is_bind = 0},{item_id = 2258, num = 0, is_bind = 0},{item_id = 2259, num = 0, is_bind = 0},{item_id = 2260, num = 0, is_bind = 0},{item_id = 2261, num = 0, is_bind = 0},},},
{ openDmTms =100,level = 300,circle = 0,costDmValue = 20,sceneId = 254,layer = 14,x = 137,y = 26,boss_name ="龙皇·千年魅狐王",boss_level = 2300,boss_id = 271,awards ={{item_id = 1872, num = 0, is_bind = 1},{item_id = 1902, num = 0, is_bind = 0},{item_id = 2258, num = 0, is_bind = 0},{item_id = 2259, num = 0, is_bind = 0},{item_id = 2260, num = 0, is_bind = 0},{item_id = 2261, num = 0, is_bind = 0},},},
{ openDmTms =100,level = 300,circle = 0,costDmValue = 20,sceneId = 254,layer = 15,x = 137,y = 26,boss_name ="龙皇·千年魅狐王",boss_level = 2400,boss_id = 272,awards ={{item_id = 1782, num = 0, is_bind = 1},{item_id = 1812, num = 0, is_bind = 0},{item_id = 2258, num = 0, is_bind = 0},{item_id = 2259, num = 0, is_bind = 0},{item_id = 2260, num = 0, is_bind = 0},{item_id = 2261, num = 0, is_bind = 0},},},
{ openDmTms =200,level = 300,circle = 0,costDmValue = 30,sceneId = 255,layer = 16,x = 75,y = 24,boss_name ="龙皇·铁血蛮王",boss_level = 2600,boss_id = 273,awards ={{item_id = 1783, num = 0, is_bind = 1},{item_id = 1813, num = 0, is_bind = 0},{item_id = 2258, num = 0, is_bind = 0},{item_id = 2259, num = 0, is_bind = 0},{item_id = 2260, num = 0, is_bind = 0},{item_id = 2261, num = 0, is_bind = 0},},},
{ openDmTms =200,level = 300,circle = 0,costDmValue = 30,sceneId = 255,layer = 17,x = 75,y = 24,boss_name ="龙皇·铁血蛮王",boss_level = 2800,boss_id = 274,awards ={{item_id = 1873, num = 0, is_bind = 1},{item_id = 1903, num = 0, is_bind = 0},{item_id = 2258, num = 0, is_bind = 0},{item_id = 2259, num = 0, is_bind = 0},{item_id = 2260, num = 0, is_bind = 0},{item_id = 2261, num = 0, is_bind = 0},},},
{ openDmTms =200,level = 300,circle = 0,costDmValue = 30,sceneId = 255,layer = 18,x = 75,y = 24,boss_name ="龙皇·铁血蛮王",boss_level = 3000,boss_id = 275,awards ={{item_id = 1783, num = 0, is_bind = 1},{item_id = 1813, num = 0, is_bind = 0},{item_id = 2258, num = 0, is_bind = 0},{item_id = 2259, num = 0, is_bind = 0},{item_id = 2260, num = 0, is_bind = 0},{item_id = 2261, num = 0, is_bind = 0},},},
{ openDmTms =200,level = 300,circle = 0,costDmValue = 30,sceneId = 255,layer = 19,x = 75,y = 24,boss_name ="龙皇·铁血蛮王",boss_level = 3200,boss_id = 276,awards ={{item_id = 1873, num = 0, is_bind = 1},{item_id = 1903, num = 0, is_bind = 0},{item_id = 2258, num = 0, is_bind = 0},{item_id = 2259, num = 0, is_bind = 0},{item_id = 2260, num = 0, is_bind = 0},{item_id = 2261, num = 0, is_bind = 0},},},
{ openDmTms =200,level = 300,circle = 0,costDmValue = 30,sceneId = 255,layer = 20,x = 75,y = 24,boss_name ="龙皇·铁血蛮王",boss_level = 3400,boss_id = 277,awards ={{item_id = 1783, num = 0, is_bind = 1},{item_id = 1813, num = 0, is_bind = 0},{item_id = 2258, num = 0, is_bind = 0},{item_id = 2259, num = 0, is_bind = 0},{item_id = 2260, num = 0, is_bind = 0},{item_id = 2261, num = 0, is_bind = 0},},},
{ openDmTms =500,level = 300,circle = 0,costDmValue = 40,sceneId = 256,layer = 21,x = 97,y = 32,boss_name ="龙皇·地藏金身",boss_level = 3600,boss_id = 278,awards ={{item_id = 1784, num = 0, is_bind = 1},{item_id = 1814, num = 0, is_bind = 0},{item_id = 2258, num = 0, is_bind = 0},{item_id = 2259, num = 0, is_bind = 0},{item_id = 2260, num = 0, is_bind = 0},{item_id = 2261, num = 0, is_bind = 0},},},
{ openDmTms =500,level = 300,circle = 0,costDmValue = 40,sceneId = 256,layer = 22,x = 97,y = 32,boss_name ="龙皇·地藏金身",boss_level = 3800,boss_id = 279,awards ={{item_id = 1874, num = 0, is_bind = 1},{item_id = 1904, num = 0, is_bind = 0},{item_id = 2258, num = 0, is_bind = 0},{item_id = 2259, num = 0, is_bind = 0},{item_id = 2260, num = 0, is_bind = 0},{item_id = 2261, num = 0, is_bind = 0},},},
{ openDmTms =500,level = 300,circle = 0,costDmValue = 40,sceneId = 256,layer = 23,x = 97,y = 32,boss_name ="龙皇·地藏金身",boss_level = 4000,boss_id = 280,awards ={{item_id = 1784, num = 0, is_bind = 1},{item_id = 1814, num = 0, is_bind = 0},{item_id = 2258, num = 0, is_bind = 0},{item_id = 2259, num = 0, is_bind = 0},{item_id = 2260, num = 0, is_bind = 0},{item_id = 2261, num = 0, is_bind = 0},},},
{ openDmTms =500,level = 300,circle = 0,costDmValue = 40,sceneId = 256,layer = 24,x = 97,y = 32,boss_name ="龙皇·地藏金身",boss_level = 4200,boss_id = 281,awards ={{item_id = 1874, num = 0, is_bind = 1},{item_id = 1904, num = 0, is_bind = 0},{item_id = 2258, num = 0, is_bind = 0},{item_id = 2259, num = 0, is_bind = 0},{item_id = 2260, num = 0, is_bind = 0},{item_id = 2261, num = 0, is_bind = 0},},},
{ openDmTms =500,level = 300,circle = 0,costDmValue = 40,sceneId = 256,layer = 25,x = 97,y = 32,boss_name ="龙皇·地藏金身",boss_level = 4400,boss_id = 282,awards ={{item_id = 1784, num = 0, is_bind = 1},{item_id = 1814, num = 0, is_bind = 0},{item_id = 2258, num = 0, is_bind = 0},{item_id = 2259, num = 0, is_bind = 0},{item_id = 2260, num = 0, is_bind = 0},{item_id = 2261, num = 0, is_bind = 0},},},
{ openDmTms =1000,level = 300,circle = 0,costDmValue = 40,sceneId = 257,layer = 26,x = 36,y = 13,boss_name ="龙皇·上古魔牛皇",boss_level = 4600,boss_id = 283,awards ={{item_id = 1785, num = 0, is_bind = 1},{item_id = 1815, num = 0, is_bind = 0},{item_id = 2258, num = 0, is_bind = 0},{item_id = 2259, num = 0, is_bind = 0},{item_id = 2260, num = 0, is_bind = 0},{item_id = 2261, num = 0, is_bind = 0},},},
{ openDmTms =1000,level = 300,circle = 0,costDmValue = 40,sceneId = 257,layer = 27,x = 36,y = 13,boss_name ="龙皇·上古魔牛皇",boss_level = 4800,boss_id = 284,awards ={{item_id = 1875, num = 0, is_bind = 1},{item_id = 1905, num = 0, is_bind = 0},{item_id = 2258, num = 0, is_bind = 0},{item_id = 2259, num = 0, is_bind = 0},{item_id = 2260, num = 0, is_bind = 0},{item_id = 2261, num = 0, is_bind = 0},},},
{ openDmTms =1000,level = 300,circle = 0,costDmValue = 40,sceneId = 257,layer = 28,x = 36,y = 13,boss_name ="龙皇·上古魔牛皇",boss_level = 5000,boss_id = 285,awards ={{item_id = 1785, num = 0, is_bind = 1},{item_id = 1815, num = 0, is_bind = 0},{item_id = 2258, num = 0, is_bind = 0},{item_id = 2259, num = 0, is_bind = 0},{item_id = 2260, num = 0, is_bind = 0},{item_id = 2261, num = 0, is_bind = 0},},},
{ openDmTms =1000,level = 300,circle = 0,costDmValue = 40,sceneId = 257,layer = 29,x = 36,y = 13,boss_name ="龙皇·上古魔牛皇",boss_level = 5200,boss_id = 286,awards ={{item_id = 1875, num = 0, is_bind = 1},{item_id = 1905, num = 0, is_bind = 0},{item_id = 2258, num = 0, is_bind = 0},{item_id = 2259, num = 0, is_bind = 0},{item_id = 2260, num = 0, is_bind = 0},{item_id = 2261, num = 0, is_bind = 0},},},
{ openDmTms =1000,level = 300,circle = 0,costDmValue = 40,sceneId = 257,layer = 30,x = 36,y = 13,boss_name ="龙皇·上古魔牛皇",boss_level = 5400,boss_id = 287,awards ={{item_id = 1785, num = 0, is_bind = 1},{item_id = 1815, num = 0, is_bind = 0},{item_id = 2258, num = 0, is_bind = 0},{item_id = 2259, num = 0, is_bind = 0},{item_id = 2260, num = 0, is_bind = 0},{item_id = 2261, num = 0, is_bind = 0},},},
{ openDmTms =2000,level = 300,circle = 0,costDmValue = 40,sceneId = 287,layer = 31,x = 20,y = 16,boss_name ="龙皇·天空修罗教皇",boss_level = 5600,boss_id = 288,awards ={{item_id = 1786, num = 0, is_bind = 1},{item_id = 1816, num = 0, is_bind = 0},{item_id = 2258, num = 0, is_bind = 0},{item_id = 2259, num = 0, is_bind = 0},{item_id = 2260, num = 0, is_bind = 0},{item_id = 2261, num = 0, is_bind = 0},},},
{ openDmTms =2000,level = 300,circle = 0,costDmValue = 40,sceneId = 287,layer = 32,x = 20,y = 16,boss_name ="龙皇·天空修罗教皇",boss_level = 5800,boss_id = 289,awards ={{item_id = 1876, num = 0, is_bind = 1},{item_id = 1906, num = 0, is_bind = 0},{item_id = 2258, num = 0, is_bind = 0},{item_id = 2259, num = 0, is_bind = 0},{item_id = 2260, num = 0, is_bind = 0},{item_id = 2261, num = 0, is_bind = 0},},},
{ openDmTms =2000,level = 300,circle = 0,costDmValue = 40,sceneId = 287,layer = 33,x = 20,y = 16,boss_name ="龙皇·天空修罗教皇",boss_level = 6000,boss_id = 290,awards ={{item_id = 1786, num = 0, is_bind = 1},{item_id = 1816, num = 0, is_bind = 0},{item_id = 2258, num = 0, is_bind = 0},{item_id = 2259, num = 0, is_bind = 0},{item_id = 2260, num = 0, is_bind = 0},{item_id = 2261, num = 0, is_bind = 0},},},
{ openDmTms =2000,level = 300,circle = 0,costDmValue = 40,sceneId = 287,layer = 34,x = 20,y = 16,boss_name ="龙皇·天空修罗教皇",boss_level = 6200,boss_id = 291,awards ={{item_id = 1876, num = 0, is_bind = 1},{item_id = 1906, num = 0, is_bind = 0},{item_id = 2258, num = 0, is_bind = 0},{item_id = 2259, num = 0, is_bind = 0},{item_id = 2260, num = 0, is_bind = 0},{item_id = 2261, num = 0, is_bind = 0},},},
{ openDmTms =2000,level = 300,circle = 0,costDmValue = 40,sceneId = 287,layer = 35,x = 20,y = 16,boss_name ="龙皇·天空修罗教皇",boss_level = 6400,boss_id = 292,awards ={{item_id = 1876, num = 0, is_bind = 1},{item_id = 1906, num = 0, is_bind = 0},{item_id = 2258, num = 0, is_bind = 0},{item_id = 2259, num = 0, is_bind = 0},{item_id = 2260, num = 0, is_bind = 0},{item_id = 2261, num = 0, is_bind = 0},},},
{ openDmTms =3000,level = 300,circle = 0,costDmValue = 40,sceneId = 204,layer = 36,x = 20,y = 16,boss_name ="龙皇·卧龙教主",boss_level = 6600,boss_id = 1938,awards ={{item_id = 1787, num = 0, is_bind = 1},{item_id = 1817, num = 0, is_bind = 0},{item_id = 1719, num = 0, is_bind = 0},{item_id = 1727, num = 0, is_bind = 0},{item_id = 1735, num = 0, is_bind = 0},{item_id = 1743, num = 0, is_bind = 0},},},
{ openDmTms =3000,level = 300,circle = 0,costDmValue = 40,sceneId = 204,layer = 37,x = 20,y = 16,boss_name ="龙皇·卧龙教主",boss_level = 6800,boss_id = 1939,awards ={{item_id = 1877, num = 0, is_bind = 1},{item_id = 1907, num = 0, is_bind = 0},{item_id = 1719, num = 0, is_bind = 0},{item_id = 1727, num = 0, is_bind = 0},{item_id = 1735, num = 0, is_bind = 0},{item_id = 1743, num = 0, is_bind = 0},},},
{ openDmTms =3000,level = 300,circle = 0,costDmValue = 40,sceneId = 204,layer = 38,x = 20,y = 16,boss_name ="龙皇·卧龙教主",boss_level = 7000,boss_id = 1940,awards ={{item_id = 1787, num = 0, is_bind = 1},{item_id = 1817, num = 0, is_bind = 0},{item_id = 1719, num = 0, is_bind = 0},{item_id = 1727, num = 0, is_bind = 0},{item_id = 1735, num = 0, is_bind = 0},{item_id = 1743, num = 0, is_bind = 0},},},
{ openDmTms =3000,level = 300,circle = 0,costDmValue = 40,sceneId = 204,layer = 39,x = 20,y = 16,boss_name ="龙皇·卧龙教主",boss_level = 7200,boss_id = 1941,awards ={{item_id = 1877, num = 0, is_bind = 1},{item_id = 1907, num = 0, is_bind = 0},{item_id = 1719, num = 0, is_bind = 0},{item_id = 1727, num = 0, is_bind = 0},{item_id = 1735, num = 0, is_bind = 0},{item_id = 1743, num = 0, is_bind = 0},},},
{ openDmTms =3000,level = 300,circle = 0,costDmValue = 40,sceneId = 204,layer = 40,x = 20,y = 16,boss_name ="龙皇·卧龙教主",boss_level = 7400,boss_id = 1942,awards ={{item_id = 1787, num = 0, is_bind = 1},{item_id = 1817, num = 0, is_bind = 0},{item_id = 1719, num = 0, is_bind = 0},{item_id = 1727, num = 0, is_bind = 0},{item_id = 1735, num = 0, is_bind = 0},{item_id = 1743, num = 0, is_bind = 0},},},
{ openDmTms =5000,level = 300,circle = 0,costDmValue = 40,sceneId = 205,layer = 41,x = 20,y = 16,boss_name ="龙皇·黄金城主",boss_level = 7600,boss_id = 1943,awards ={{item_id = 1788, num = 0, is_bind = 1},{item_id = 1818, num = 0, is_bind = 0},{item_id = 1720, num = 0, is_bind = 0},{item_id = 1728, num = 0, is_bind = 0},{item_id = 1736, num = 0, is_bind = 0},{item_id = 1744, num = 0, is_bind = 0},},},
{ openDmTms =5000,level = 300,circle = 0,costDmValue = 40,sceneId = 205,layer = 42,x = 20,y = 16,boss_name ="龙皇·黄金城主",boss_level = 7800,boss_id = 1944,awards ={{item_id = 1878, num = 0, is_bind = 1},{item_id = 1908, num = 0, is_bind = 0},{item_id = 1720, num = 0, is_bind = 0},{item_id = 1728, num = 0, is_bind = 0},{item_id = 1736, num = 0, is_bind = 0},{item_id = 1744, num = 0, is_bind = 0},},},
{ openDmTms =5000,level = 300,circle = 0,costDmValue = 40,sceneId = 205,layer = 43,x = 20,y = 16,boss_name ="龙皇·黄金城主",boss_level = 8000,boss_id = 1945,awards ={{item_id = 1788, num = 0, is_bind = 1},{item_id = 1818, num = 0, is_bind = 0},{item_id = 1720, num = 0, is_bind = 0},{item_id = 1728, num = 0, is_bind = 0},{item_id = 1736, num = 0, is_bind = 0},{item_id = 1744, num = 0, is_bind = 0},},},
{ openDmTms =5000,level = 300,circle = 0,costDmValue = 40,sceneId = 205,layer = 44,x = 20,y = 16,boss_name ="龙皇·黄金城主",boss_level = 8200,boss_id = 1946,awards ={{item_id = 1878, num = 0, is_bind = 1},{item_id = 1908, num = 0, is_bind = 0},{item_id = 1720, num = 0, is_bind = 0},{item_id = 1728, num = 0, is_bind = 0},{item_id = 1736, num = 0, is_bind = 0},{item_id = 1744, num = 0, is_bind = 0},},},
{ openDmTms =5000,level = 300,circle = 0,costDmValue = 40,sceneId = 205,layer = 45,x = 20,y = 16,boss_name ="龙皇·黄金城主",boss_level = 8400,boss_id = 1947,awards ={{item_id = 1788, num = 0, is_bind = 1},{item_id = 1818, num = 0, is_bind = 0},{item_id = 1720, num = 0, is_bind = 0},{item_id = 1728, num = 0, is_bind = 0},{item_id = 1736, num = 0, is_bind = 0},{item_id = 1744, num = 0, is_bind = 0},},},
{ openDmTms =8000,level = 300,circle = 0,costDmValue = 40,sceneId = 206,layer = 46,x = 20,y = 16,boss_name ="龙皇·蚩尤魔帝",boss_level = 8600,boss_id = 1948,awards ={{item_id = 1789, num = 0, is_bind = 1},{item_id = 1819, num = 0, is_bind = 0},{item_id = 1721, num = 0, is_bind = 0},{item_id = 1729, num = 0, is_bind = 0},{item_id = 1737, num = 0, is_bind = 0},{item_id = 1745, num = 0, is_bind = 0},},},
{ openDmTms =8000,level = 300,circle = 0,costDmValue = 40,sceneId = 206,layer = 47,x = 20,y = 16,boss_name ="龙皇·蚩尤魔帝",boss_level = 8800,boss_id = 1949,awards ={{item_id = 1879, num = 0, is_bind = 1},{item_id = 1909, num = 0, is_bind = 0},{item_id = 1721, num = 0, is_bind = 0},{item_id = 1729, num = 0, is_bind = 0},{item_id = 1737, num = 0, is_bind = 0},{item_id = 1745, num = 0, is_bind = 0},},},
{ openDmTms =8000,level = 300,circle = 0,costDmValue = 40,sceneId = 206,layer = 48,x = 20,y = 16,boss_name ="龙皇·蚩尤魔帝",boss_level = 9000,boss_id = 1950,awards ={{item_id = 1789, num = 0, is_bind = 1},{item_id = 1819, num = 0, is_bind = 0},{item_id = 1721, num = 0, is_bind = 0},{item_id = 1729, num = 0, is_bind = 0},{item_id = 1737, num = 0, is_bind = 0},{item_id = 1745, num = 0, is_bind = 0},},},
{ openDmTms =8000,level = 300,circle = 0,costDmValue = 40,sceneId = 206,layer = 49,x = 20,y = 16,boss_name ="龙皇·蚩尤魔帝",boss_level = 9200,boss_id = 1951,awards ={{item_id = 1879, num = 0, is_bind = 1},{item_id = 1909, num = 0, is_bind = 0},{item_id = 1721, num = 0, is_bind = 0},{item_id = 1729, num = 0, is_bind = 0},{item_id = 1737, num = 0, is_bind = 0},{item_id = 1745, num = 0, is_bind = 0},},},
{ openDmTms =8000,level = 300,circle = 0,costDmValue = 40,sceneId = 206,layer = 50,x = 20,y = 16,boss_name ="龙皇·蚩尤魔帝",boss_level = 9400,boss_id = 1952,awards ={{item_id = 1789, num = 0, is_bind = 1},{item_id = 1819, num = 0, is_bind = 0},{item_id = 1721, num = 0, is_bind = 0},{item_id = 1729, num = 0, is_bind = 0},{item_id = 1737, num = 0, is_bind = 0},{item_id = 1745, num = 0, is_bind = 0},},},
			},
		},
	},
}