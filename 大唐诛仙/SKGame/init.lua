-- 临时的请求lua数据 local 不是 全局的lua数据
function GetLocalData( localPath )
	return require (StringFormat("SKGame/Modules/{0}", localPath))
end
-- 注册lua文件
function RegistModules( path ) 
	require (StringFormat("SKGame/Modules/{0}", path))
end
-- 请求基础配置数据 local 不是 全局的lua数据
function GetCfgData( name )
	return require (StringFormat("SKGame/Config/cfg_{0}", name))
end
-- 加载pb结构协议
function GetPBData( name )
	require (StringFormat("SKGame/Proto/{0}_pb", name))
end
-- 框架的东西  其他未加入功能 protobuf, lpeg, cjson, sproto, util, print_r, sproto
	--require "Common/define"
	--require "Common/protocal"
	JSON = require "Common/JSON"
	require "Common/functions"

-- base
	require "SKGame/Common/GameConst"
	require "SKGame/Common/EventName"
	require "SKGame/Common/StringUtils"
	require "SKGame/Common/TableTool"
	require "SKGame/Common/NumberTool"
	require "SKGame/Common/TimeTool"
	require "SKGame/Common/FairyGUI"
	require "SKGame/Common/MapUtil"
	require "SKGame/Common/EffectTool"
	require "SKGame/Common/PoolMgr"
	require "SKGame/Common/SkillTipsConst"
	require "SKGame/Base/BaseClass"
	require "SkGame/Base/GEvent"
	require "SkGame/Base/InnerEvent"
	require "SkGame/Base/AppEvent"
	GlobalDispatcher = AppEvent:GetInstance()
	require "SKGame/Base/LuaModel" -- 基本模型
	require "SKGame/Base/LuaUI" -- 基本LuaUI
	require "SkGame/Base/BaseView" -- 基本弹出组件
	require "SKGame/Base/LuaController" -- 基本控制器

	require "SkGame/Common/CommonBackGround" -- 公共弹出背景组件
-- protobuff
ProtoModules = {
	"message",
	"common",
	"exception",
	"tower",
	"player",
	"equipment",
	"bag",
	"instance",
	"collect",
	"buff",
	"wakan",
	"furnace",--熔炉
	"scene",
	"skill",
	"fashion",
	"mail",
	"task",
	"sign",
	"activity",
	"rank",
	"wing",
	"login",
	"test",
	"battle",
	"chat",
	"team",
	"trading",
	"family",
	"tianti",
	"market",
	"rank",
	"wing",
	"weekactivity",
	"vip",
	"friend",
	"guild",
	"enemy",   --仇敌
}
for i,v in ipairs(ProtoModules) do
	GetPBData(v)
	if v == "message" then
		MessageEnum = message_pb.MessageEnum -- 协议消息中心
	end
end
GameModules = {
	"Sys/DebugMgr", -- 调试工具管理器
	"Sys/DataMgr",  --本地数据管理器
	"UIMgr", 			-- UI管理类
	"MainTip/MW_Alter",	-- 确认窗体
	"MainTip/ConfirmNum",	-- 询问数量窗体
	"MainTip/MW_Confirm",	-- 询问窗体
	"MainTip/MW_FloatTip",	-- 询问窗体

	"Common/UI/CustomProgess", -- 进度条(不是公用的)
	"Common/UI/CustomRadio",

	"Common/UI/Accordion/Accordion", -- 二级树组件
	"Common/UI/Accordion/AccordionBtn",
	"Common/UI/Accordion/AccordionCellItem",
	"Common/UI/Accordion/AccordionCellItems",


	"Common/UI/NumberBar", -- 数字组件
	"Common/UI/NumberBarType",

	"Common/CommonController", --通用
	"Main/MainUIController",   --主界面
	
	"GongGao/GgController", --公告
	"Login/LoginController", 	-- 登录
	"Map/SceneController",		-- 场景
	
	"ServerSelect/ServerSelectController",
}

for i=1,#GameModules do -- 立即载入
	RegistModules(GameModules[i])
end

AfterLoginModules = {
	"Common/View/Message/Message", -- 消息
	"Common/View/Message/MsgUI",
	"Common/View/Message/RollMsgUI",
	"Common/View/Message/TipsMsgUI",
	"Common/View/Message/TipsMsgItem",
	"Common/View/Message/TrumpetMsgUI",

	"Common/UI/CustomJoystick", -- 手柄组件
	"Common/View/MultyHitItem",
	"Common/View/MultyHit",

	"PlayerInfo/PlayerInfoController",   --玩家属性界面
	
	"Team/ZD/ZDCtrl", -------------------------组队
	"Bag/PkgCtrl", -- 背包
	"Trading/TradingController",	--交易行
	"Mail/EmailController", -- 邮件
	"Skill/SkillController", 	--技能
	"Tianti/TiantiController", 	--天梯
	"DamageCue/DamageCueUiEdition",
	"NewbieGuide/NewbieGuideController", --新手引导
	"Task/TaskController", --任务系统
	"FB/FBController",  --副本
	"NPCDialog/NPCDialogController", --npc对话系统
	"WorldMap/WorldMapController", --世界地图
	"GodFightRune/GodFightRuneController", --斗神印系统（优化升级版铭文系统）
	"Tower/TowerController", --大荒塔
	"ShenJing/ShenJingController", --神镜
	"Mall/MallController", --商城
	"Pay/PayCtrl", -- 充值
	"Rank/RankController", --排行榜 
	"Activity/ActivityController", --活动
	"Wing/WingController", --羽翼
	"Wakan/WakanController", --注灵
	"Style/StyleController", --时装

	"Function/FunctionController", -- 功能控制
	"Welfare/WelfareController", -- 福利
	"DailyTask/DailyTaskController", -- 日常任务
	"Decomposition/DecompositionController", -- 分解
	"Composition/CompositionController", -- 合成
	"Sign/SignController", --签到
	"Guide/GuideController", --引导
	"Setting/SettingCtrl", --设置
	"Vip/VipController",  --VIP
	"ChatNew/ChatNewController", --聊天
	"Family/FamilyCtrl", -- 家族
	"Gay/FriendController",  --好友
	"ChouDi/ChouDiController", --仇敌
	"Account/AccountController", --账号
	--"MonthCard/MonthCardController", -- 月卡
	"Recharge1/RechargeController", --充值---------------------------------------------
	"FirstRecharge/FirstRechargeCtrl", -- 首充
	"TotalRecharge/TotalRechargeController",
	"AccConsum/ConsumController", -- 累计消费
	"SevenLogin/SevenLoginController", --七天
	"OpenGift/OpenGiftCtrl", --开服特惠
	"EquipmentStoreTips/EquipmentStoreTipsController" , --装备行弹窗
	"Furnace/FurnaceCtrl",--熔炉功能系统
	"Clan/ClanCtrl",--氏族系统
	"Strong/StrongCtr" ,       --提升
}

function AfterLoginRequire() -- 登录后的加载模块
	for i=1,#AfterLoginModules do
		RegistModules( AfterLoginModules[i] )
	end

	PkgCtrl:GetInstance()
	EmailController:GetInstance()
	TradingController:GetInstance()

	CommonController:GetInstance()
	DamageCueUiEdition:GetInstance()
	
	ZDCtrl:GetInstance()
	SkillController:GetInstance()
	NewbieGuideController:GetInstance()
	TaskController:GetInstance()
	GodFightRuneController:GetInstance()
	
	NPCDialogController:GetInstance()
	FBController:GetInstance()
	WorldMapController:GetInstance()
	GodFightRuneController:GetInstance()
	TowerController:GetInstance()
	ShenJingController:GetInstance()
	MallController:GetInstance()
	PayCtrl:GetInstance()
	RankController:GetInstance() 
	ActivityController:GetInstance() 
	WingController:GetInstance()
	WakanController:GetInstance()
	StyleController:GetInstance()

	FunctionController:GetInstance()
	WelfareController:GetInstance()
	DailyTaskController:GetInstance()

	DecompositionController:GetInstance()
	CompositionController:GetInstance()
	PlayerInfoController:GetInstance()
	SignController:GetInstance()
	GuideController:GetInstance()
	
	PowerLevelCtr:GetInstance() --冲级
	RewardCodeCtrl:GetInstance() --兑奖码

	SettingCtrl:GetInstance()
	ChatNewController:GetInstance()
	VipController:GetInstance()
	FriendController:GetInstance()   --好友
	FamilyCtrl:GetInstance() -- 家族
	ChouDiController:GetInstance()   --仇敌
	AccountController:GetInstance()   --账号
	--MonthCardController:GetInstance() --月卡
	TiantiController:GetInstance()
	RechargeController:GetInstance() --chongzhi====================================
	FirstRechargeCtrl:GetInstance() -- 首充
	TotalRechargeController:GetInstance()
	ConsumController:GetInstance() -- 累计消费
	SevenLoginController:GetInstance() --七天
	OpenGiftCtrl:GetInstance() -- 开服特惠
	EquipmentStoreTipsController:GetInstance() --装备行弹窗
	FurnaceCtrl:GetInstance() -- 熔炉功能系统
	ClanCtrl:GetInstance() -- 氏族系统
	StrongCtr:GetInstance() --提升
end