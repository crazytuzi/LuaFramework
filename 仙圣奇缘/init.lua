-- --监控增加的package
-- g_tbPackage = {}
-- local mt = {
--     __index = function (tb, key)
--     		return g_tbPackage[key]
-- 		end,
--     __newindex = function (tb, key, value)
--             g_tbPackage[key] = value
--         end
-- }


-- setmetatable(package.loaded, mt)

-- --监控增加的全局变量
-- g_tbGobalValue = {}
-- local mt = {
--     __index = function (tb, key)
--     		return g_tbGobalValue[key]
-- 		end,
--     __newindex = function (tb, key, value)
--             g_tbGobalValue[key] = value
--         end
-- }
-- setmetatable(_G, mt)

--记录是否是被挤下线回到的此界面， 因为定时器还没启动。客户端消息模块不能用。只能用全局变量
g_PushOut = nil

g_LoadFile("Config/LoadConfigFile")
g_LoadFile("LuaScripts/GameLogic/ResourcePack")
--CCFileUtils:sharedFileUtils():addSearchPath(g_writepath.."Config/")

--网络层文件
local  Lua_ProtobufFile = 
{
	--框架
	-- "LuaScripts/FrameWork/functions", --直接在main 函数里面加载的。。
	"LuaScripts/FrameWork/ccs",
	--游戏数据
	"LuaScripts/GameLogic/Class_DbMgr",
	
	--protobuf 基础库
	"ProtobufLua/wire_format",
	"ProtobufLua/type_checkers",
	"ProtobufLua/encoder",
	"ProtobufLua/decoder",
	"ProtobufLua/listener",
	"ProtobufLua/containers",
	"ProtobufLua/descriptor",
	"ProtobufLua/text_format",
	"ProtobufLua/protobuf",

	--protobuf的消息文件
	"LuaScripts/LuaProto/macro_pb",
	"LuaScripts/LuaProto/msgid_pb",
	"LuaScripts/LuaProto/fixed_options_pb",
	"LuaScripts/LuaProto/common_pb",
	"LuaScripts/LuaProto/zone_pb",
	"LuaScripts/LuaProto/account_pb",
	"LuaScripts/LuaProto/xxz_msg_pb",
}

--基础业务层文件
local Lua_BaseFile =
{
	
	

	"LuaScripts/GameLogic/Class_Timer",
	
    "LuaScripts/GameLogic/WB_DictionarySys",
	"LuaScripts/GameLogic/WB_LanguageVersion",
	"LuaScripts/GameLogic/GlobalFunc/GFunc_ResrouceFunc",
	"LuaScripts/GameLogic/Class_DataMgr",
	
	"LuaScripts/GameLogic/Class_Hero",
	"LuaScripts/GameLogic/Class_Hero_BaseInfo",
	"LuaScripts/GameLogic/Class_Hero_QiShu",
	"LuaScripts/GameLogic/Class_Hero_Equip",
	"LuaScripts/GameLogic/Class_Hero_Card",
	"LuaScripts/GameLogic/Class_Hero_Formula",
	"LuaScripts/GameLogic/Class_Hero_Item",
	"LuaScripts/GameLogic/Class_Hero_HunPo",
	"LuaScripts/GameLogic/Class_Hero_Soul",
	"LuaScripts/GameLogic/Class_Hero_Logic",
	
	"LuaScripts/GameLogic/GlobalFunc/GFunc_ConstTable",
	"LuaScripts/GameLogic/GlobalFunc/GFunc_ConstFunc",
	"LuaScripts/GameLogic/Class_GameObj",
	"LuaScripts/GameLogic/Class_Card",
	"LuaScripts/GameLogic/Class_Card_Equip",
	"LuaScripts/GameLogic/Class_Card_Evolute",
	"LuaScripts/GameLogic/Class_Card_Fate",
	"LuaScripts/GameLogic/Class_Card_Formula",
	"LuaScripts/GameLogic/Class_Card_Realm",
	"LuaScripts/GameLogic/Class_Card_Skill",
	"LuaScripts/GameLogic/Class_Card_HunPo",
	
	"LuaScripts/GameLogic/Class_Item",
	"LuaScripts/GameLogic/Class_Soul",
	"LuaScripts/GameLogic/Class_Fate",
	"LuaScripts/GameLogic/GlobalConfig/Config_CityMgr",
	"LuaScripts/GameLogic/GlobalFunc/GFunc_Function",
	"LuaScripts/GameLogic/GlobalFunc/GFunc_Animation",
	"LuaScripts/GameLogic/GlobalFunc/GFunc_Button",
	"LuaScripts/GameLogic/Class_WndMgr",
	"LuaScripts/GameLogic/GlobalFunc/GFunc_Glittering",
	"LuaScripts/GameLogic/Class_LuaPageView",
	"LuaScripts/GameLogic/Class_LuaListView",
	"LuaScripts/GameLogic/GlobalConfig/Config_Notice",
	"LuaScripts/GameLogic/GlobalConfig/Config_Notice_Vietnam",
	"LuaScripts/GameLogic/GlobalConfig/Config_Notice_Taiwan",
	
	"LuaScripts/GameLogic/GlobalFunc/GFunc_NewLabelTTF",
	"LuaScripts/GameLogic/Class_ShangXiang",
	"LuaScripts/GameLogic/ItemDropGuildFunc",
	
	
	
	
	"LuaScripts/GameLogic/Class_Spine", --初始化骨骼动画
	"LuaScripts/GameLogic/ChargeIncreaseBase", 
	
	--基础文件
	"LuaScripts/VisibleRect",
	"Shaders/ShaderConst",

	--NetWorkWarning定义到此处时 因为它依赖性强 要首先创建
	"LuaScripts/UILogic/CommonUI/NetWorkWarning",
	
	--消息
	"LuaScripts/NetWork/Class_MsgMgr",
	"LuaScripts/NetWork/MsgProccess",
	"LuaScripts/NetWork/ClientPing",
	"LuaScripts/NetWork/ErrorMsg",
	
		--跨服战数据
    "LuaScripts/GameLogic/ArenaKuaFuData",
	
	"LuaScripts/GameLogic/Class_Guild", --帮派数据
	--formMsg
	"LuaScripts/UILogic/FormMsg/FormMsgSystem",
	
	"LuaScripts/GameLogic/Class_FarmData", --农田数据
	"LuaScripts/GameLogic/Class_XianMaiInfo", --农田数据
	"LuaScripts/GameLogic/Class_TurnTableInfo", --爱心转盘数据
	"LuaScripts/GameLogic/Class_AssistantData",--成就数据

	--游戏平台数据
	"LuaScripts/GamePlatform/GamePlatformSystem",
	"LuaScripts/GameLogic/Class_MapInfo", --保存 地图id 星星

	
	"LuaScripts/GameLogic/FateData", --猎命
	"LuaScripts/GameLogic/VIPBase", --Vip 

	"LuaScripts/GameLogic/GameNoticeSystem", --游戏公告数据
	--神像数据
	"LuaScripts/GameLogic/Class_BaXianPary", 
	-- 装备精炼升级
	"LuaScripts/GameLogic/EquipRefineStarUpData", 
	
	"LuaScripts/GameLogic/Class_Equip",

	--CD控件管理
	"LuaScripts/GameLogic/Class_CDBar",
	
	--八仙过海逻辑
    "LuaScripts/UILogic/BaXianGuoHai/WB_Logic_BaXianGuoHaiSystem",
	
	--感悟
	"LuaScripts/UILogic/Eliminate/EliminateLog",
	"LuaScripts/UILogic/Eliminate/InspireSkillShow",
	"LuaScripts/UILogic/Eliminate/InspireShow",
	"LuaScripts/UILogic/Eliminate/EliminateNode",
	"LuaScripts/UILogic/Eliminate/EliminateElement",
	"LuaScripts/UILogic/Eliminate/EliminateSkill",
	"LuaScripts/UILogic/Eliminate/EliminateSystem",

    --世界BOSS-2逻辑
    "LuaScripts/UILogic/MovementUI/ZGJ_WorldBoss_System",

    --开服活动逻辑
	"LuaScripts/UILogic/ZGJ_Game_ServerOpenTask_System",
	
	"LuaScripts/UILogic/EctypeSelectUI/LX_GameEctypeListSystem", --副本数据层
	"LuaScripts/GameLogic/CardRealmData", --渡劫数据


	"LuaScripts/GameLogic/Lable_Text", 


    --facebook邀请好友奖励
    "LuaScripts/UILogic/FBInviteAndShare/WB_FBInviteAndShareSys",
	

 
	    --奖励选择
	"LuaScripts/UILogic/RewardSelect/WB_RewardSelectSys",
	
	
}

--UI表现层文件
local Lua_WndFile = 
{

	"Login/HJW_LoadingCity",
	
	"GameLogic/Class_HeadBar",
	"GameLogic/GlobalFunc/GFunc_UpgadeCheck",
	"GameLogic/GlobalFunc/GFunc_CheckList",
	
	
	--登陆
	"Login/LYP_StartGame",
	"Login/HF_LoginOrRegister",
	"Login/LKA_CreateRole",
	"Login/HF_SelectServer",
	"Login/ServerListInfo",
	    --saysorry
    "Login/WB_EmergencyNotice",
	
	--主界面
	"UILogic/LKA_Home",
	
	"UILogic/ButtonGroup",
	"UILogic/CheckBoxGroup",
	"UILogic/LYP_MainWnd",
	"UILogic/EctypeSelectUI/LYP_MapWorld",
	
	"UILogic/EctypeSelectUI/LYP_GameEctypeList", --副本选择
	"UILogic/EctypeSelectUI/LYP_GameSelectGameLevel1",
	"UILogic/EctypeSelectUI/LYP_GameSelectGameLevel2", 
	"UILogic/EctypeSelectUI/LYP_GameSelectGameLevel3", 
	"UILogic/EctypeSelectUI/HJW_GameSaoDang", --扫荡
	"UILogic/EctypeSelectUI/HJW_SaoDangData", --扫荡数据逻辑 （体力是否足够等）

	--精英副本
	"UILogic/EctypeSelectUI/ZGJ_GameEctypeJY_Form",
	"UILogic/EctypeSelectUI/ZGJ_GameEctypeJYDetail_Form",
	"UILogic/EctypeSelectUI/ZGJ_GameEctypeJY_System",
	
	"UILogic/ArenaUI/LKA_Game_Arena",	--竞技场相关UI逻辑
	"UILogic/ArenaUI/LKA_Game_ArenaReward",	--竞技场相关UI逻辑
	"UILogic/ArenaUI/LKA_Game_ArenaRankClass",	--竞技场相关UI逻辑
	"UILogic/ArenaUI/LKA_Game_ArenaReport",	--竞技场相关UI逻辑
	"UILogic/ArenaUI/LKA_Game_ArenaHistory",	--竞技场相关UI逻辑
	"UILogic/ArenaUI/LKA_Game_ArenaRank",	--竞技场相关UI逻辑
	
	"UILogic/LYP_CardWnd",
	"UILogic/WJQ_CardSelect",
	"UILogic/WJQ_ReChargeWnd",
	
	"UILogic/LYP_MainPackage",
	"UILogic/SocialDict",
	"UILogic/WorldBossWnd",
	"UILogic/WorldBossWnd_Guild",
	
	"UILogic/HF_CardFateWnd",
	
	"UILogic/HF_TipEquip",
	"UILogic/HF_EquipStrengthen",
	"UILogic/HF_EquipRefine",
	"UILogic/HF_EquipChongZhu",
	"UILogic/HF_TipFate",
	--装备
	"UILogic/LYP_EquipWnd",
	-- "UILogic/Equip/LYP_EquipWnd",
	
	"UILogic/WJQ_TaskFinishedAnimation",
	"UILogic/WJQ_UpgradeAnimation",
	"UILogic/WJQ_HeroLevelUpAnimation",
	"UILogic/WJQ_RankLevelUpAnimation",
	"UILogic/WJQ_StrengthenAnimation",
	"UILogic/WJQ_SummonAnimation",
	"UILogic/WJQ_RewardMsgConfirm",
	"UILogic/WJQ_Guiding",
	"UILogic/LYP_FunctionOpenNotice",
	"UILogic/WJQ_TipsConfig",
	"UILogic/WJQ_RewardBox",
	"UILogic/WJQ_StrengthenAni",
	"UILogic/WJQ_ZhenRong",
	"UILogic/WJQ_YaoShouBook",
	
	 --猎命
	"UILogic/FateUI/HJW_HuntFate",

	"UILogic/LKA_CNoticeWnd",
	"UILogic/LKA_MailBox",
	"UILogic/LKA_Social1Wnd",
	"UILogic/LKA_SociaMag",
	"UILogic/LKA_ActivityRegister",

	"UILogic/LKA_System",
	"UILogic/LYP_WorldBossWndRank",
	
	"UILogic/LKA_ActivityFuLuDao",
	"UILogic/LKA_ActivityFuLuDaoSub",
	"UILogic/LKA_BattleBuZhen",
    "UILogic/LYP_VipWnd",
	
    "UILogic/MH_ZhaoCaiFuWnd",
	
	"UILogic/LKA_ChatCenterWnd",
	
	"UILogic/LKA_ChatCenteFriendChatPNL",
	"UILogic/MH_ViewPlayer",
	"UILogic/LYP_CardDetailOtherWnd",
	
	
    "UILogic/MH_ViewProfile", 
	
	"UILogic/AssistantUI/LKA_Assistant",	--助手
	"UILogic/AssistantUI/LKA_AchievementWnd",--助手
	
	"UILogic/FarmUI/LYP_FarmPray",
	"UILogic/FarmUI/HJW_GameFarm", --药园
	"UILogic/FarmUI/HJW_GameFarmSelectPlant", --种植
	"UILogic/FarmUI/HJW_GameFarmReward", --药园收获后的抽奖
	
	"UILogic/AwakeningUI/GameXianMai", --仙脉系统
	"UILogic/AwakeningUI/LKA_XiaoChu",
	
    "UILogic/LYP_TipTuDiGong",
	"UILogic/LKA_HomeFunctionList", --
	
	"UILogic/SummonUI/SummonLogData",
	"UILogic/SummonUI/HJW_GameSummon",--十连抽奖励
	"UILogic/SummonUI/HJW_SummonTenTimes",
	"UILogic/SummonUI/HJW_GameSummonLog",
	
	"UILogic/HJW_CardLevelUp", --给伙伴使用道具
	"UILogic/HJW_Turntable", --转盘奖励
	
	"UILogic/ZhenFaQiShuUI/LKA_TipZhenXin",
	"UILogic/ZhenFaQiShuUI/LKA_ZhenXin",
	"UILogic/ZhenFaQiShuUI/HJW_GameQiShu",
	"UILogic/ZhenFaQiShuUI/HJW_GameTipYuanSu", --阵法奇术tip界面
	"UILogic/ZhenFaQiShuUI/HJW_GameTipQiShu", --阵法和秘法 tip 界面	--战斗
	"UILogic/ZhenFaQiShuUI/HJW_GameZhenFaSelect",
	
	"UILogic/LKA_SendLoveAnimation", 
	"UILogic/WJQ_GMConsole",
	"UILogic/HJW_GameShangXiang", --伙伴上香系统
	
	"UILogic/ComposeUI/HJW_GameCompose",
	"UILogic/ComposeUI/HJW_ComposeData", --技能（丹药）数据逻辑
	
	"UILogic/GroupUI/LKA_GroupUpgrade",
    "UILogic/GroupUI/LKA_GroupMail", 
	"UILogic/GroupUI/LKA_GroupManage", --
	"UILogic/GroupUI/LKA_GroupRequest", --
	"UILogic/GroupUI/LKA_GroupSetting", --
	"UILogic/GroupUI/LKA_GroupChangeNotice", --
	"UILogic/GroupUI/HJW_GameGroupCreate", --创建帮派与申请帮派，帮派查询
	"UILogic/GroupUI/HJW_GameGroup", --帮派界面
	"UILogic/GroupUI/HJW_GameGroupMemberView", --帮众信息界面
	-- "UILogic/GroupUI/HJW_GameGroupInfo", --帮派排名
	-- "UILogic/GroupUI/HJW_GroupViewShow", --帮派入口 区分是打开帮派申请还是帮派主界面
	--帮派功能
	"UILogic/GroupUI/HJW_GroupPNL_View", --
	"UILogic/GroupUI/HJW_GroupActivityPNL_View", --
	"UILogic/GroupUI/HJW_GroupBuildingPNL_View", -- 
	"UILogic/GroupUI/HJW_GroupLogPNL_View", --
	"UILogic/GroupUI/HJW_GroupRankPNL_View", --
	"UILogic/GroupUI/HJW_GameGroupView", -- 帮派查看信息
	"UILogic/GroupUI/ZGJ_GroupChat",
	
	"UILogic/GroupUI/HJW_BuildingElement", --
	"UILogic/GroupUI/HJW_GroupBuildingBank", --万宝楼
	"UILogic/GroupUI/HJW_GroupBuildingSchool", -- 书画院
	"UILogic/GroupUI/HJW_GroupBuildingSkill", --炼神塔
	
	
	
	"UILogic/HJW_GameItemDropGuide", --背包 材料合成，掉落
	
	"UILogic/CardRealmUI/LYP_CardRealmWnd",--渡劫UI
	"UILogic/CardRealmUI/HJW_DuJieSelectHelper", --选择协助渡劫伙伴	
	"UILogic/CardRealmUI/HJW_BattleBuZhenDuJie", --
	
	"UILogic/LYP_LoadingBattle", --战斗loading界面
	
	"UILogic/DialogueUI/HJW_Dialogue", --对话
	"UILogic/DialogueUI/HJW_DialogueData", --对话
	
	"UILogic/CardUpgradeUI/HJW_CardLevelUpSingle", --卡牌道具经验升级
	"UILogic/HJW_Game_CardHandBook", --未解锁的卡牌信息
	
	"Battle/Effect/HJW_EffectData",
	"Battle/Effect/EffectStealMana",
	"Battle/Effect/EffectRemoveMana",
	"Battle/Effect/HF_EffectHeated",
	"Battle/Effect/HF_EffectCalm",
	"Battle/Effect/HF_EffectBase",
	"Battle/Effect/HF_EffectBleed",
	"Battle/Effect/HF_EffectMacro",
	"Battle/Effect/HF_EffectModifyAbs",
	"Battle/Effect/HF_EffectModifyHP",
	"Battle/Effect/HF_EffectModifyMana",
	"Battle/Effect/HF_EffectSuckBlood",
	"Battle/Effect/HF_EffectMgr",
	"Battle/Effect/EffectDefend",
	
	"Battle/BattleMgr/HF_BattleMgr",
	"Battle/BattleMgr/HF_BattleMagic",		
	"Battle/BattleMgr/HF_BattlePB",	
	"Battle/BattleMgr/HF_BattleAPI",	
	

	"Battle/BattleResouce",
	"Battle/LYP_BattleProcess",
	"Battle/LYP_BattleWnd",
	"Battle/LYP_BattleResult",
	"Battle/LYP_BattleData",
	"Battle/WJQ_BattleWin1",
	
	"Battle/HF_BattleCard",
	
	"Battle/HF_BattleFit",

	"Battle/CSkillMgr",
	"Battle/CSkillDamge",
    "Battle/LYP_BattleDrop",
	"Battle/LYP_BattleSetting",
	"Battle/BattleDamage",
	
	"Battle/Player/Player",	
	"Battle/Player/CCardPlayer",	
	"Battle/Player/PlayerAction",
	"Battle/Player/CMonsterPlayer",		
	

		
	--客户端提示界面
	"UILogic/CommonUI/CClientMsgTips",
	"UILogic/CommonUI/CNewPlayerGuid",
	"UILogic/CommonUI/CTipDropItem",
	"UILogic/CommonUI/WJQ_TipDropReward",
	"UILogic/CommonUI/CGuidTips",

	"UILogic/CommonUI/CoverLayer",

	--声望商店
	"UILogic/LX_ShopPrestigeForm",
	"UILogic/LX_ShopPrestige",
	
	--神秘商店
	"UILogic/ZGJ_ShopSecretForm",
	"UILogic/ZGJ_ShopSecret",
	
	--聚宝阁
	"UILogic/WJQ_JuBaoGe",
	
	--试炼山
	"UILogic/WJQ_ShiLianShan",
	--聚仙阁
	"UILogic/WJQ_JuXianGe",

	--运营活动(Template放在最前)
	"UILogic/ActivityCenterUI/ZGJ_Act_Template",
	"UILogic/ActivityCenterUI/ZGJ_Act_Template2",
	"UILogic/ActivityCenterUI/ZGJ_Act_ContinueLogin",
	"UILogic/ActivityCenterUI/ZGJ_Act_OnlineTime",
	"UILogic/ActivityCenterUI/ZGJ_Act_Active",
	"UILogic/ActivityCenterUI/ZGJ_Act_RechargeTime",
	"UILogic/ActivityCenterUI/ZGJ_Act_RechargeValue",
	"UILogic/ActivityCenterUI/HJW_Act_ExchangeKey",
	"UILogic/ActivityCenterUI/ZGJ_Act_DailyCharge",
	"UILogic/ActivityCenterUI/ZGJ_Act_DailyCharge_JR",
	"UILogic/ActivityCenterUI/ZGJ_Act_KaiFuJiJin",
	"UILogic/ActivityCenterUI/ZGJ_Act_TianJiangYB",
	"UILogic/ActivityCenterUI/ZGJ_Act_QuanMinFuLi",
	"UILogic/ActivityCenterUI/ZGJ_Act_VIPPack",
	"UILogic/ActivityCenterUI/ZGJ_Act_VIPPack_JR",
	"UILogic/ActivityCenterUI/ZGJ_ActivityCenter_Form",
	"UILogic/ActivityCenterUI/ZGJ_ActivityCenter_System",
	"UILogic/ActivityCenterUI/ZGJ_FirstCharge",
	"UILogic/ActivityCenterUI/ZGJ_Act_ContinueLogin_Guoqing",
	"UILogic/ActivityCenterUI/ZGJ_Act_ChaoZhiYueKa",
	"UILogic/ActivityCenterUI/ZGJ_Act_TotalCharge_JR",
	"UILogic/ActivityCenterUI/ZGJ_Act_DailyVIPPack_JR",
	"UILogic/ActivityCenterUI/ZGJ_Act_DailyPack_JR",
	"UILogic/ActivityCenterUI/ZGJ_Act_SummonTotal_JR",
	"UILogic/ActivityCenterUI/ZGJ_Act_SummonCount_JR",
    "UILogic/ActivityCenterUI/ZQ_Act_BatRankReward",
    "UILogic/ActivityCenterUI/ZQ_Act_EveryDayCharge",
    "UILogic/ActivityCenterUI/ZQ_Act_EveryDayCharge_JR",
    "UILogic/ActivityCenterUI/ZQ_Act_SummonTotal",
    "UILogic/ActivityCenterUI/ZQ_Act_TianJiangYB_JR",
    "UILogic/ActivityCenterUI/ZQ_Act_TotalCharge",
    "UILogic/ActivityCenterUI/ZQ_Act_TotalCost",
    "UILogic/ActivityCenterUI/ZQ_Act_TotalCost_JR",
    "UILogic/ActivityCenterUI/ZQ_Act_ItemExchange",

	--战斗教学
	"UILogic/BattleTeachSystem",

	--感悟
	"UILogic/Eliminate/InspireLogForm",
	"UILogic/Eliminate/InspireForm",


	--人物移动
	"UILogic/MovementUI/ZGJ_Role",
	"UILogic/MovementUI/ZGJ_Role_System",
	--世界BOSS 2
	"UILogic/MovementUI/ZGJ_WorldBoss_Form",
	--集会所
	"UILogic/MovementUI/ZGJ_JiHuiSuo_Form",
	"UILogic/MovementUI/ZGJ_JiHuiSuo_System",

	--帮派场景BOSS
	"UILogic/MovementUI/ZGJ_SceneBossGuild_Form",
	

	--游戏内滚屏公告
	"UILogic/GameNoticeForm",


	"UILogic/HJW_BaXianPray",
    --八仙过海
    "UILogic/BaXianGuoHai/WB_UI_BaXianGuoHai",
    "UILogic/BaXianGuoHai/WB_UI_BaXianDaJie",
    "UILogic/BaXianGuoHai/WB_UI_BaXianRefresh",
    "UILogic/BaXianGuoHai/WB_UI_BaXianFilter",
    "UILogic/BaXianGuoHai/WB_UI_TipBaXianView",
    "UILogic/BaXianGuoHai/WB_UI_PublicBuZhen",

	--神龙上供
	"UILogic/ZGJ_DragonPray_Form",
	"UILogic/ZGJ_DragonPray_System",
	"UILogic/ZGJ_DragonPrayGuild_Form",
	"UILogic/ZGJ_DragonPrayGuild_System",
	
	--装备升星
	"UILogic/HJW_EquipRefineStarUp",

	--教学过度
	"UILogic/StoryScene",

	--开服活动
	"UILogic/ZGJ_Game_ServerOpenReward_Form",
	"UILogic/ZGJ_Game_ServerOpenTask_Form",
	
	"UILogic/ChuanCheng/HJW_ChuanCheng", --传承
	"UILogic/ChuanCheng/HJW_ChuanChengData", --传承
	"UILogic/WJQ_BattleFighterInfo", --战斗对象信息
	

	--facebook邀请好友奖励
    "UILogic/FBInviteAndShare/WB_UI_FacebookReward",
    "UILogic/FBInviteAndShare/WB_UI_FacebookShare",
	
	--跨服战
	"UILogic/ArenaKuaFu/HJW_ArenaKuaFu",
	--跨服战报
	"UILogic/ArenaKuaFu/HJW_ArenaReortKuaFu",
	"UILogic/ArenaKuaFu/HJW_ArenaKuaFuRank",

	--关于我们
	"UILogic/WJQ_AboutUs",

    --奖励选择
	"UILogic/RewardSelect/WB_UI_RewardSelect",
}

local function checkspine()
	local total = 0
	local tbtest = {}


	for k, v in pairs(ConfigMgr["CardBase"]) do

		for j, l in pairs(v) do
			-- if "NvFeiZei1" ~= v.SpineAnimation and
			-- "ZhiZHuHuang" ~= v.SpineAnimation and
			-- "ZhiZHuLv" ~= v.SpineAnimation and
			-- "LinFuJiaDing" ~= v.SpineAnimation and
			-- "LinFuDaShou" ~= v.SpineAnimation and
			-- "JiangShiNv2" ~= v.SpineAnimation and
			-- "JiangShiNv1" ~= v.SpineAnimation and
			-- "ZhiZHuHei" ~= v.SpineAnimation and
		 --   "NvFeiZei2" ~= v.SpineAnimation and
		 --  	not tbtest[l.SpineAnimation] then
		 if not tbtest[v.SpineAnimation] then

				total = total + 1
			   	local szJson = string.format("SpineCharacter/%s.json", v.SpineAnimation)
				local szAtlas = string.format("SpineCharacter/%s.atlas", v.SpineAnimation)
					local skeletonNode = SkeletonAnimation:createWithFile(szJson, szAtlas, 1)
					cclog("=====CardBase===== spine name ="..v.SpineAnimation.." num ="..total)
					-- skeletonNode:retain()
					-- skeletonNode:release()

					tbtest[v.SpineAnimation] = 1
				
			end
		end
	end

	cclog(" SpineAnimation CardBase bOver")


	for k, v in pairs(ConfigMgr["MonsterBase"]) do
		
		-- if "NvFeiZei1" ~= v.SpineAnimation and
		-- 	"ZhiZHuHuang" ~= v.SpineAnimation and
		-- 	"ZhiZHuLv" ~= v.SpineAnimation and
		-- 	"LinFuJiaDing" ~= v.SpineAnimation and
		-- 	"LinFuDaShou" ~= v.SpineAnimation and
		-- 	"JiangShiNv2" ~= v.SpineAnimation and
		-- 	"JiangShiNv1" ~= v.SpineAnimation and
		-- 	"ZhiZHuHei" ~= v.SpineAnimation and
		--    "NvFeiZei2" ~= v.SpineAnimation and
		--   	not tbtest[v.SpineAnimation] then

		if not tbtest[v.SpineAnimation] then
			

		  	total = total + 1
		   	local szJson = string.format("SpineCharacter/%s.json", v.SpineAnimation)
			local szAtlas = string.format("SpineCharacter/%s.atlas", v.SpineAnimation)
				local skeletonNode = SkeletonAnimation:createWithFile(szJson, szAtlas, 1)
				cclog("====MonsterBase====== spine name ="..v.SpineAnimation.." num ="..total)
				-- skeletonNode:retain()
				-- skeletonNode:release()

				tbtest[v.SpineAnimation] = 1
			
		end
		
	end

	cclog(" SpineAnimation MonsterBase bOver")
end




function LoadGamWndFile()
	--加载所有的脚本
	for index=1, #Lua_WndFile do
		local filename = "LuaScripts/"..Lua_WndFile[index]
		cclog(index.." Loading "..filename)
		g_LoadFile(filename)
	end
end

function loadGameFiles(funcCallBack)
	--加载所有的游戏配置脚本
	local nProtobuf = #Lua_ProtobufFile
	local nBase = #Lua_BaseFile
	local nWnd = #Lua_WndFile
	local nConfig = #Lua_ConfigFile
	local nMaxCount =  nProtobuf + nConfig + nBase +  nWnd 
	local ScheduleID = nil
	local nCurCount = 0
	--计数回调函数
	local function calcCountCallBack()
		for i =1, 10 do
			nCurCount = nCurCount + 1
			local filename = nil
			if(nCurCount <= nProtobuf)then
				filename = Lua_ProtobufFile[nCurCount]
			elseif(nCurCount <= nProtobuf + nConfig)then
				filename =  Lua_ConfigFile[nCurCount - nProtobuf]
                if g_LResPath ~= nil then
                    filename = g_LResPath[LResType].cfg ..string.sub(filename, string.find(filename,"/"),-1)
                end

			elseif(nCurCount <= nProtobuf + nConfig + nBase)then
				filename = Lua_BaseFile[nCurCount - nProtobuf - nConfig]
			else
				filename = "LuaScripts/"..Lua_WndFile[nCurCount - nProtobuf - nConfig - nBase]
			end
			
			cclog(string.format("【%d/%d】Loading: %s", nCurCount, nMaxCount, filename))
			g_LoadFile(filename)

			--local fullfilename = CCFileUtils:sharedFileUtils():fullPathForFilename(filename..".lua")
		--	cclog(string.format("【%d/%d】Loading LoadGamFile: %s", nCurCount, nMaxCount, fullfilename))
			if(nCurCount == nMaxCount)then --最后一个了
				g_LoadFile("LuaScripts/OverloadingFunc")
				CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(ScheduleID)
				funcCallBack(math.floor(nCurCount*100/nMaxCount), filename, true)
				-- checkspine()
				-- CCTextureCache:sharedTextureCache():removeAllTextures()
				break
			else
				funcCallBack(math.floor(nCurCount*100/nMaxCount), filename)
			end
		end
	end	

	ScheduleID =  CCDirector:sharedDirector():getScheduler():scheduleScriptFunc(calcCountCallBack, 0, false)	
end

--[[
math.random 如果不带参数则返回[0,1]范围内的随机数
		如果带一个参数n，将产生1<=X<=n范围内的随机数X
		如果带两个参数a和b，则将产生a<=X<=b范围内的随机数X
		
函数名	 描述	 示例	 结果
pi	 圆周率	 math.pi	 3.1415926535898
abs	 取绝对值	 math.abs(-2012)	 2012
ceil	 向上取整	 math.ceil(9.1)	 10
floor	 向下取整	 math.floor(9.9)	 9
max	 取参数最大值	 math.max(2,4,6,8)	 8
min	 取参数最小值	 math.min(2,4,6,8)	 2
pow	 计算x的y次幂	 math.pow(2,16)	 65536
sqrt	 开平方	 math.sqrt(65536)	 256
mod	 取模	 math.mod(65535,2)	 1
modf	 取整数和小数部分	 math.modf(20.12)	 20   0.12
randomseed	 设随机数种子	 math.randomseed(os.time())	  
random	 取随机数	 math.random(5,90)	 5~90
rad	 角度转弧度	 math.rad(180)	 3.1415926535898
deg	 弧度转角度	 math.deg(math.pi)	 180
exp	 e的x次方	 math.exp(4)	 54.598150033144
log	 计算x的自然对数	 math.log(54.598150033144)	 4
log10	 计算10为底，x的对数	 math.log10(1000)	 3
frexp	 将参数拆成x * (2 ^ y)的形式	 math.frexp(160)	 0.625    8
ldexp	 计算x * (2 ^ y)	 math.ldexp(0.625,8)	 160
sin	 正弦	 math.sin(math.rad(30))	 0.5
cos	 余弦	 math.cos(math.rad(60))	 0.5
tan	 正切	 math.tan(math.rad(45))	 1
asin	 反正弦	 math.deg(math.asin(0.5))	 30
acos	 反余弦	 math.deg(math.acos(0.5))	 60
atan	 反正切	 math.deg(math.atan(1))	 45
]]
