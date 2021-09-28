------------------------------------------------------
local require = require

require("logic/entity/i3k_entity_behavior");
require("logic/entity/i3k_entity_property");


------------------------------------------------------
-- 这里定义其他Entity的起始id
ePropID_entity		= 0;	-- 通用属性开始id
ePropID_hero		= 1000; -- 英雄属性开始id
ePropID_monster		= 2000; -- 怪物属性开始id
ePropID_mercenary	= 3000; -- 佣兵属性开始id
ePropID_trap		= 4000; -- 机关属性开始id


-- 属性ID
ePropID_lvl			= ePropID_entity + 1; -- 等级
ePropID_speed		= ePropID_entity + 2; -- 移动速度


-- group type
eGroupType_U = 0;	-- 无效
eGroupType_O = 1;	-- 己方
eGroupType_E = 2;	-- 敌方
eGroupType_N = 4;	-- 中立

-- control type
eCtrlType_AI		= 0; -- ai 控制
eCtrlType_Player	= 1; -- 玩家控制
eCtrlType_Network	= 2; -- 服务器控制

-- entity type
eET_Unknown			=  0; -- 无效
eET_Player			=  1; -- 玩家
eET_Monster			=  2; -- 怪物
eET_Trap			=  3; -- 机关
eET_Pet				=  4; -- 残影
eET_Mercenary		=  5; -- 佣兵
eET_NPC				=  6; -- 友善NPC
eET_ResourcePoint	=  7; -- 采集点（矿等）
eET_TransferPoint	=  8; -- 传送点
eET_MapBuff			=  9; -- 场景buff
eET_Skill			= 10; -- 技能
eET_ItemDrop		= 11; -- 掉落
eET_Ghost			= 12; -- 幽灵特殊
eET_Car				= 13; -- 镖车
eET_MarryCruise		= 14; -- 结婚巡游
eET_PetRace         = 15; -- 宠物赛跑
eET_ShowLoveItem    = 16; -- 示爱道具类型
eET_PlayerStatue    = 17; -- 荣耀殿堂雕像
eET_Diglett			= 18; -- 地鼠
eET_Summoned		= 19; -- 唤灵卫
eET_Crop			= 20; -- 家园作物
eET_HomePet			= 21; -- 家园宠物
eET_DisposableNPC	= 22; -- 周年庆跑动npc


-- 服务器未用到
eET_Mount			= 1000; -- 挂载entity
eET_Common			= 1001; -- 通用模型 entity
eET_Floor			= 1002; -- 房屋地板
eET_Furniture		= 1003; -- 房屋地面家具
eET_WallFurniture	= 1004; -- 墙面家具
eET_HouseSkin		= 1005; -- 房屋皮肤
eET_CarpetFurniture	= 1006; -- 地毯家具
eET_Capture			= 1007; -- 合照
eET_CatchSpirit		= 1008; -- 驭灵雕像
eET_GhostFragment	= 1009; -- 驭灵碎片
eET_Simple			= 1010; -- 简单模型


eMoveByVelocity = 1;
eMoveByTarget	= 2;

eExpTreeId = 60007;--经验果树id
