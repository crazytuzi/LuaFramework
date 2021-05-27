return {
{
	scenceid = 21,
	minlevel = 525,
	mincircle = 0,
	minvip = 0,
	--music = "2.mp3",
	--mapfilename = "02HeiLongCheng",
	angerRate = 9000,
	sceneType = 4,
	area =
	{
		{
			name = Lang.SceneName.a00000, range = { 10,10,20,20,60,50 }, center = { 12,12 },
			attri =
			{
				{type=18,value = {}},
				{type=19,value = {}},
				--{type=46,value = {47,14,50,24}},	--安全复活区"，即复活点，无参数,如果是表示沙巴克战是复活，第五个参数表示复活的地图id
				--{type=39,value = {}},	--//"城镇"，无参数,表示回城卷或者回城复活，就会回到这里
				--{type=40,value = {}},	--关闭新手保护"，无参数，现低于40级（以下）是保护状态，免受攻击，进入该区域后，这个规则失效
				--{type=59,value = {}},	--关闭保护"，无参数
--				{type=30,value = {1,2,3,4}},--禁止被行会拉传"，参数：【召唤1，行会集结令2，行会回城卷3,队伍集结4】
--				{type=23,value = {1,2,3,4}},--禁止使用行会拉传"，参数：【召唤1，行会集结令2，行会回城卷3,队伍集结4】
--				{type=50,value = {}},	--强制攻击模式",[PK模式]，注意：只接受一个参数。0和平模式，1团队模式，2帮派模式，3阵营模式，4杀戮模式，5联盟模式
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
	},
	refresh =
	{
--#include "refresh21.lua"
	},
	npc =
	{
	},
	teleport =
	{
	        { posx = 9, posy = 9,toSceneid =  2,toPosx = 111, toPosy = 93,effect_ui = 999,name = Lang.SceneName.s00002 },
	},
	landscape=
	{
	},
},
}