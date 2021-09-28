--GameSwitchConstant.lua
--/*-----------------------------------------------------------------
 --* Module:  GameSwitchConstant.lua
 --* Author:  seezon
 --* Modified: 2016年3月21日
 --* Purpose: 系统开关常量定义
 -------------------------------------------------------------------*/


--定义设置的配置ID
GAME_SWITCH_ID_TRADE = 1			--交易
GAME_SWITCH_ID_ACTIVENESS = 2		--活跃度
GAME_SWITCH_ID_CHAT = 3				--聊天
GAME_SWITCH_ID_BOSSDIG = 4			--boss挖掘
GAME_SWITCH_ID_GAMESET = 5			--游戏设置
GAME_SWITCH_ID_COMPOUND = 6			--装备合成
GAME_SWITCH_ID_SINPVP = 7			--竞技场
GAME_SWITCH_ID_SMELTER = 8			--熔炉
GAME_SWITCH_ID_FLOWER = 9			--送花
GAME_SWITCH_ID_TEAM = 10			--组队
GAME_SWITCH_ID_WORLDBOSS = 11		--世界BOSS
GAME_SWITCH_ID_XUNBAO = 12			--新宝
GAME_SWITCH_ID_ACHIEVE = 13			--成就称号
GAME_SWITCH_ID_ACTIVEITY = 14		--活动
GAME_SWITCH_ID_DIGMINE = 15			--挖矿
GAME_SWITCH_ID_MASTER = 16			--师徒
GAME_SWITCH_ID_RANK = 17			--排行榜
GAME_SWITCH_ID_UNDEFINE = 18		--未知暗殿
GAME_SWITCH_ID_DART = 19			--镖车
GAME_SWITCH_ID_ADORE = 20			--膜拜
GAME_SWITCH_ID_COMPETITION = 21		--拼战
GAME_SWITCH_ID_GIVEWINE = 22		--仙翁赐酒
GAME_SWITCH_ID_COPY = 23			--副本
GAME_SWITCH_ID_ENVOY = 24			--勇闯炼狱
GAME_SWITCH_ID_FACTIONCOPY = 25		--帮会副本
GAME_SWITCH_ID_LUOXIA = 26			--落霞夺宝
GAME_SWITCH_ID_MANOR = 27			--领地战中州战
GAME_SWITCH_ID_RELATION = 28		--好友仇敌黑名单
GAME_SWITCH_ID_RIDE = 29			--坐骑
GAME_SWITCH_ID_SHAWAR = 30			--沙巴克
GAME_SWITCH_ID_TASK = 31			--任务
GAME_SWITCH_ID_WING = 32			--光翼
GAME_SWITCH_ID_YANHUO = 33			--焰火屠魔
GAME_SWITCH_ID_FACTION = 34			--帮会
GAME_SWITCH_ID_MONATTACK = 35 		--怪物攻城
GAME_SWITCH_ID_ARROW = 36 			--穿云箭
GAME_SWITCH_MALL = 37				--商城(元宝 绑元 红包 药品)
GAME_SWITCH_MYSTERYSHOP = 38 		--神秘商城
GAME_SWITCH_MERITORIOUS = 39    	--竞技场商城
GAME_SWITCH_FACTIONSHOP = 40		--行会商店
GAME_SWITCH_TOWERCOPY = 41          --通天塔副本
GAME_SWITCH_SINGLECOPY = 42         --屠龙传说副本


--定义系统开关
DefaultGameSwitch = {
--[GAME_SWITCH_ID_TRADE] = TradeServlet.getInstance(),
[GAME_SWITCH_ID_CHAT] = ChatSystem.getInstance(),
[GAME_SWITCH_ID_BOSSDIG] = DigBossServlet.getInstance(),
[GAME_SWITCH_ID_GAMESET] = GameSetServlet.getInstance(),
--[GAME_SWITCH_ID_COMPOUND] = CompoundServlet.getInstance(),
--[GAME_SWITCH_ID_SINPVP] = SinpvpServlet.getInstance(),
--[GAME_SWITCH_ID_SMELTER] = SmelterServlet.getInstance(),
--[GAME_SWITCH_ID_FLOWER] = SpillFlowerServlet.getInstance(),
--[GAME_SWITCH_ID_TEAM] = TeamServlet.getInstance(),
[GAME_SWITCH_ID_WORLDBOSS] = WorldBossServlet.getInstance(),
--[GAME_SWITCH_ID_XUNBAO] = XunBaoServlet.getInstance(),
[GAME_SWITCH_ID_ACHIEVE] = AchieveServlet.getInstance(),
[GAME_SWITCH_ID_ACTIVEITY] = ActivityServlet.getInstance(),
[GAME_SWITCH_ID_DIGMINE] = DigMineServlet.getInstance(),
[GAME_SWITCH_ID_MASTER] = MasterServlet.getInstance(),
[GAME_SWITCH_ID_RANK] = RankServlet.getInstance(),
[GAME_SWITCH_ID_UNDEFINE] = UndefinedServlet.getInstance(),
[GAME_SWITCH_ID_DART] = CommonServlet.getInstance(),
[GAME_SWITCH_ID_ADORE] = AdoreServlet.getInstance(),
[GAME_SWITCH_ID_COMPETITION] = CompetitionServlet.getInstance(),
[GAME_SWITCH_ID_GIVEWINE] = GiveWineServlet.getInstance(),
[GAME_SWITCH_ID_COPY] = CopySystem.getInstance(),
[GAME_SWITCH_ID_ENVOY] = EnvoyServlet.getInstance(),
[GAME_SWITCH_ID_FACTIONCOPY] = FactionCopyServlet.getInstance(),
[GAME_SWITCH_ID_LUOXIA] = LuoxiaServlet.getInstance(),
[GAME_SWITCH_ID_MANOR] = ManorWarServlet.getInstance(),
[GAME_SWITCH_ID_RELATION] = RelationServlet.getInstance(),
[GAME_SWITCH_ID_RIDE] = RideServlet.getInstance(),
[GAME_SWITCH_ID_SHAWAR] = ShaWarServlet.getInstance(),
[GAME_SWITCH_ID_TASK] = TaskServlet.getInstance(),
[GAME_SWITCH_ID_WING] = WingServlet.getInstance(),
[GAME_SWITCH_ID_FACTION] = FactionServlet.getInstance(),
}


BASICK_FUNC = 
{
	GAME_SWITCH_ID_MONATTACK,
	GAME_SWITCH_ID_TRADE,
	GAME_SWITCH_MALL,
	GAME_SWITCH_MYSTERYSHOP,
	GAME_SWITCH_MERITORIOUS,
	GAME_SWITCH_FACTIONSHOP,
	GAME_SWITCH_ID_FLOWER,
	GAME_SWITCH_ID_ARROW,
	GAME_SWITCH_ID_TEAM,
	GAME_SWITCH_TOWERCOPY,
	GAME_SWITCH_SINGLECOPY,
}