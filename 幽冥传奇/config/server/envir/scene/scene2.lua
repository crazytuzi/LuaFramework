return {
{
	scenceid = 2,
	minlevel = 10,
	mincircle = 0,
	minvip = 0,
	--music = "2.mp3",
	--mapfilename = "02HeiLongCheng",
	sceneType = 0,
	area =
	{
		{
			name = Lang.SceneName.a00000, range = { 10,10,20,20,60,50 }, center = { 108,87 },
			attri =
			{
				{type=18,value = {}},
				{type=19,value = {}},
				{type=87,value = {}},
			}
		},
		{
			name = Lang.SceneName.a00001, range = { 88,87,103,74,118,86,103,100 }, center = { 108,87 },
			attri =
			{
				{type=18,value = {}},
				{type=19,value = {}},
				{type=1,value = {}},
				{type=46,value = {99,80,106,93}},	--安全复活区"，即复活点，无参数,如果是表示沙巴克战是复活，第五个参数表示复活的地图id
				{type=39,value = {}},	--//"城镇"，无参数,表示回城卷或者回城复活，就会回到这里
				{type=97,value = {}},
				--{type=40,value = {}},	--关闭新手保护"，无参数，现低于40级（以下）是保护状态，免受攻击，进入该区域后，这个规则失效
				--{type=59,value = {}},	--关闭保护"，无参数
				{type=87,value = {}},
--				{type=30,value = {1,2,3,4}},--禁止被行会拉传"，参数：【召唤1，行会集结令2，行会回城卷3,队伍集结4】
--				{type=23,value = {1,2,3,4}},--禁止使用行会拉传"，参数：【召唤1，行会集结令2，行会回城卷3,队伍集结4】
--				{type=50,value = {}},	--强制攻击模式",[PK模式]，注意：只接受一个参数。0和平模式，1团队模式，2帮派模式，3阵营模式，4杀戮模式，5联盟模式
				{type=60,value = {}},
				{type=83,value = {}},
--				{type=33,value = {}},	--限制技能使用"，[技能1，技能2，技能3...],技能id
--				{type=34,value = {}},	--限制物品使用"[物品1，物品2，物品3...]，都是指物品id
--				{type=43,value = {}},	--限制骑乘宝物"	，无参数，骑乘宝物,注：
--				{type=73,value = {}},	--//"无法查看其他玩家信息"
--				{type=74,value = {}},	--//"无法聊天频道发言"
--				{type=75,value = {}},	--//"无法看到周围玩家名字"
--				{type=28,value = {}},	--阵营保护区域",【被保护的阵营id】，如果有2个阵营被保护，则2个参数。
--				{type=41,value = {}},	--自动加经验"，[经验的数量]，注：执行的周期是1秒
--				{type=42,value = {}},	--自动减经验"，[经验的数量]，注：
--				{type=47,value = {}},	--按千分比减少HP"[每次减少的千分比]，注：可能取消
--				{type=48,value = {}},	--按千分比增加HP"[每次增加的千分比]，注：可能取消
--				{type=49,value = {}},	--PK死亡允许原地复活"，无参数,注：暂未实现
			}
		},
		{
			name = Lang.SceneName.a00001, range = { 125,113,160,144,170,136,134,105 }, center = { 108,87 },
			attri =
			{
				{type=18,value = {}},
				{type=19,value = {}},
				{type=1,value = {}},
				{type=87,value = {}},
				{type=60,value = {}},
				{type=83,value = {}},
			}
		},
	},
	refresh =
	{
--#include "refresh2.lua"
	},
	npc =
	{
			{id = 75, posx = 103, posy = 101},
			{id = 226, posx = 103, posy = 88},
			{id = 101, posx = 176, posy = 117},
			{id = 80, posx = 129, posy = 71},
			{id = 115, posx = 126, posy = 114},
			{id = 91, posx = 100, posy = 105},
			{id = 83, posx = 65, posy = 129},
			{id = 90, posx = 91, posy = 91},
			{id = 221, posx = 87, posy = 84},
			{id = 230, posx = 92, posy = 80},
			{id = 222, posx = 97, posy = 76},
			{id = 231, posx = 103, posy = 72},
			{id = 186, posx = 110, posy = 77},
			{id = 232, posx = 116, posy = 82},
			{id = 249, posx = 77, posy = 122},
			{id = 6, posx = 162, posy = 35},
			{id = 7, posx = 121, posy = 40},
			{id = 8, posx = 79, posy = 40},
			{id = 9, posx = 108, posy = 100},
			{id = 10, posx = 37, posy = 148},
			{id = 11, posx = 59, posy = 58},
            {id = 12, posx = 23, posy = 23},
			{id = 18, posx = 117, posy = 148},
			{id = 19, posx = 82, posy = 120},
            {id = 23, posx = 141, posy = 62},
            {id = 24, posx = 147, posy = 103},
            {id = 36, posx = 97, posy = 134},
	},
	teleport =
	{
			{ posx = 199, posy = 8,toSceneid =  1,toPosx = 8, toPosy = 58,effect_ui = 999,name = Lang.SceneName.s00001 },
			{ posx = 6, posy = 6,toSceneid =  6,toPosx = 15, toPosy = 27,effect_ui = 999,name = Lang.SceneName.s00006 },
			{ posx = 7, posy = 176,toSceneid =  8,toPosx = 76, toPosy = 178,effect_ui = 999,name = Lang.SceneName.s00008 },
			{ posx = 201, posy = 180,toSceneid =  3,toPosx = 137, toPosy = 9,effect_ui = 999,name = Lang.SceneName.s00003 },
	},
	landscape=
	{
	},
},
}