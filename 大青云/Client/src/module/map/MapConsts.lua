--[[
Map常量
haohu
2014年8月14日18:17:00
]]

_G.MapConsts = {}

----------------map type----------------------
MapConsts.Type_Curr  = "Type_Curr"; -- 当前地图
MapConsts.Type_Local = "Type_Local";  -- 非当前地域地图

----------------map name----------------------
MapConsts.MapName_Curr         = "MapName_Curr"; -- 大地图当前地图
MapConsts.MapName_Small        = "MapName_Small"; -- 小地图
MapConsts.MapName_Local        = "MapName_Local";  -- 大地图非当前地域地图
MapConsts.MapName_UnionWar     = "MapName_UnionWar";  -- 帮派战地图
MapConsts.MapName_UnionCityWar = "MapName_UnionCityWar";  -- 帮派战地图
MapConsts.MapName_Zhanchang    = "MapName_Zhanchang";  -- 战场地图
MapConsts.MapName_UnionDiGongWar= "MapName_UnionDiGongWar";  -- 帮派地宫争夺战地图
----------------map type----------------------
MapConsts.MapType_YeWai			= 1;
MapConsts.MapType_ZhuCheng		= 2;
MapConsts.MapType_Dungeon		= 3;

--------------------------------大地图--------------------------------
--刷新地图间隔时间 ms
MapConsts.RefreshMapTime = 500;
--大地图宽
MapConsts.UIBigMapW = 667;
--大地图高
MapConsts.UIBigMapH = 659;
--寻路点间距
MapConsts.PathPointDis = 14;

--------------------------------传送类型--------------------------------
MapConsts.Teleport_Map        = 1; -- 大地图传送
MapConsts.Teleport_DailyQuest = 2; -- 日环传送
MapConsts.Teleport_Story      = 3; -- 剧情传送 (免费)
MapConsts.Teleport_FengYao    = 4; -- 悬赏传送
MapConsts.Teleport_WorldBoss  = 5; -- 世界Boss传送
MapConsts.Teleport_TrunkQuest = 6; -- 主线传送
MapConsts.Teleport_QuestFree  = 7; -- 远距离主线任务免费传送 (免费)
MapConsts.Teleport_RandomQuest = 8; -- 奇遇传送
MapConsts.Teleport_Wabao	  = 9; -- 挖宝传送
MapConsts.Teleport_QuestWabao = 10; -- 一键挖宝传送
MapConsts.Teleport_TaoFa 	  = 11; -- 讨伐
MapConsts.Teleport_FieldBoss  = 12  --野外BOSS
MapConsts.Teleport_Agora	  = 13; -- 集会所 新屠魔 新悬赏
MapConsts.Teleport_Recommend_Hang	  = 14; -- 推荐挂机
MapConsts.Teleport_LieMo 		= 15; -- 猎魔
MapConsts.Teleport_Hang 		= 16; -- 挂机
----------------------------------------------------------------------

MapConsts.Red    = "#cc0000";
MapConsts.Green  = "#29cc00";
MapConsts.Blue   = "#47c0ff";
MapConsts.Yellow = "#ffcc33";
MapConsts.Orange = "#ff8f43";
MapConsts.Brown  = "#838383";
MapConsts.White  = "#ffffff";

--地图上物体类型
MapConsts.Type_MainPlayer       = "Type_MainPlayer";
MapConsts.Type_Player           = "Type_Player";    --其他玩家
MapConsts.Type_Npc              = "Type_Npc";
MapConsts.Type_NpcS             = "Type_NpcS";
MapConsts.Type_Monster          = "Type_Monster";
MapConsts.Type_MonsterArea      = "Type_MonsterArea";
MapConsts.Type_Special          = "Type_Special";
MapConsts.Type_Path             = "Type_Path";
MapConsts.Type_Portal           = "Type_Portal";
MapConsts.Type_Hang             = "Type_Hang";
MapConsts.Type_UnionWarBuilding = "Type_UnionWarBuilding";
MapConsts.Type_UnionCityUnits   = "Type_UnionCityUnits";
MapConsts.Type_ZhanchangUnits   = "Type_ZhanchangUnits";
MapConsts.Type_UnionDiGongFlag  = "Type_UnionDiGongFlag";

-- 世界地图对应表：地图id = swf中地图btn名字
MapConsts.mapWorldMap = {
	[10100001] = "btnBLY", -- 北灵院
	[10100002] = "btnBLQ", -- 白龙丘
	[10100003] = "btnSLS", -- 圣灵山
	[10100004] = "btnYJDL", -- 遗迹大陆
	[10100005] = "btnDLTY", -- 大罗天域
	[10100006] = "btnLFT", -- 龙凤天
	[10100007] = "btnYLZC", -- 陨落战场
	[10100008] = "btnDXTJ", -- 大西天界
	[10100009] = "btnWJHY", -- 无尽火域
	[10100010] = "btnZZWJ", -- 至尊武境
	-- [10100011] = "btnBSZD", -- 不死之地
	-- [10100012] = "btnJSJY", -- 绝世剑域
	[10200001] = "btnBCC", -- 北苍城

	-- 大青云  新地图  adder:houxudong date:2016年11月24日 16:31:25
	[11000001] = "btnNWG",  --女娲宫
	[11000006] = "btnSLD",  --死灵都
	[11000017] = "btnSGYJ", --上古遗迹
	[11000008] = "btnWYG",  --万妖谷
	[11000009] = "btnHSD",  --海神殿
	[11000010] = "btnXQZC", --西岐主城
	[11000002] = "btnJLL",  --绝龙岭
	[11000003] = "btnKL",   --昆仑
	[11000004] = "btnJXL",  --九仙林
	[11000005] = "btnQYS",  --乾元山
	[11000011] = "btnXYF",  --轩辕坟
}

--传送费 5元宝
local teleportFee -- 元宝花费
local teleportItem -- 传送道具id
local teleportFreeVip -- 是否免费传送的vip
function MapConsts:GetTeleportCostInfo()
	if not teleportFee then
		teleportFee = t_consts[49].val1
	end
	if not teleportItem then
		teleportItem = t_consts[49].val2
	end
	teleportFreeVip = VipController:GetFreeTeleport()
	return teleportFee, teleportItem, teleportFreeVip
end

local maxRegainFreeTime -- 传送免费恢复次数上限
function MapConsts:GetTeleportMaxRegainFreeTime()
	if not maxRegainFreeTime then
		maxRegainFreeTime = t_consts[80].val2
	end
	return maxRegainFreeTime
end

-- 距离远/近临界点，用于传送时的距离判断
MapConsts.CriticalDistance = 150

--远古战场
MapConsts.FirstMap = 10100000;