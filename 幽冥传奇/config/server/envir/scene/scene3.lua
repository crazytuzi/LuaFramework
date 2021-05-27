return {
{
	scenceid = 3,
	minlevel = 30,
	mincircle = 0,
	minvip = 0,
	--music = "2.mp3",
	--mapfilename = "02HeiLongCheng",
	sceneType = 0,
	area =
	{
		{
			name = Lang.SceneName.a00000, range = { 10,10,20,20,60,50 }, center = { 90,77 },
			attri =
			{
				{type=18,value = {}},
				{type=19,value = {}},
			}
		},
		{
			name = Lang.SceneName.a00001, range = { 84,76,99,61,114,76,99,91 }, center = { 90,77 },
			attri =
			{
				{type=18,value = {}},
				{type=19,value = {}},
				{type=1,value = {}},
				{type=46,value = {97,67,102,83}},	--安全复活区"，即复活点，无参数,如果是表示沙巴克战是复活，第五个参数表示复活的地图id
				{type=39,value = {}},	--//"城镇"，无参数,表示回城卷或者回城复活，就会回到这里
				{type=78,value = {}},
				{type=40,value = {}},	--关闭新手保护"，无参数，现低于40级（以下）是保护状态，免受攻击，进入该区域后，这个规则失效
				{type=59,value = {}},	--关闭保护"，无参数
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
				{type=97,value = {}},
			}
		},
		{
			name = Lang.SceneName.a00001, range = { 87,105,87,96,99,96,99,105 }, center = { 96,100 },
			attri =
			{
				{type=18,value = {}},
				{type=19,value = {}},
				{type=1,value = {}},
				--{type=46,value = {104,74,110,78}},	--安全复活区"，即复活点，无参数,如果是表示沙巴克战是复活，第五个参数表示复活的地图id
				{type=39,value = {}},	--//"城镇"，无参数,表示回城卷或者回城复活，就会回到这里
				{type=78,value = {}},
				{type=40,value = {}},	--关闭新手保护"，无参数，现低于40级（以下）是保护状态，免受攻击，进入该区域后，这个规则失效
				{type=59,value = {}},	--关闭保护"，无参数
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
				{type=97,value = {}},
			}
		},
	},
	refresh =
	{
--#include "refresh3.lua"
	},
	npc =
	{
			{id = 75, posx = 84, posy = 76},
			{id = 97, posx = 88, posy = 72},
			{id = 100, posx = 92, posy = 68},
			{id = 102, posx = 96, posy = 64},
			{id = 96, posx = 99, posy = 61},
			{id = 110, posx = 103, posy = 65},
			{id = 91, posx = 107, posy = 69},
			{id = 107, posx = 111, posy = 73},
			{id = 99, posx = 115, posy = 77},
			{id = 104, posx = 111, posy = 81},
			{id = 103, posx = 107, posy = 85},
			{id = 101, posx = 29, posy = 71},
			{id = 94, posx = 93, posy = 100},
			{id = 226, posx = 99, posy = 77},
			{id = 25, posx = 137, posy = 40},
			{id = 26, posx = 130, posy = 75},
			{id = 27, posx = 114, posy = 89},
			{id = 28, posx = 94, posy = 110},
			{id = 29, posx = 15, posy = 98},
			{id = 30, posx = 48, posy = 71},
			{id = 34, posx = 55, posy = 43},
			{id = 35, posx = 71, posy = 25},
			{id = 37, posx = 84, posy = 87},
			{id = 41, posx = 126, posy = 138},
			{id = 187, posx = 79, posy = 72},
			{id = 233, posx = 85, posy = 66},
			{id = 188, posx = 91, posy = 61},
			{id = 234, posx = 99, posy = 54},
			{id = 189, posx = 106, posy = 60},
			{id = 235, posx = 111, posy = 64},
			{id = 190, posx = 116, posy = 68},
			{id = 236, posx = 121, posy = 73},
	},
	teleport =
	{
			{ posx = 72, posy = 91,toSceneid =  12,toPosx = 116, toPosy = 41,effect_ui = 999,name = Lang.SceneName.s00012 },
			{ posx = 9, posy = 137,toSceneid =  10,toPosx = 24, toPosy = 45,effect_ui = 999,name = Lang.SceneName.s00010 },
			{ posx = 152, posy = 133,toSceneid = 4,toPosx = 110, toPosy = 7,effect_ui = 999,name = Lang.SceneName.s00004 },
	},
	landscape=
	{
	},
},
}