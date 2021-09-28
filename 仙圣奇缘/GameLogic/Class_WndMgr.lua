
--需用窗口管理器要注意以下几点
--必须自己创建一个对象，必须要有initWnd、openWnd、closeWnd三个函数
--初始化窗口 加载资源调用 initWnd 该函数只会调用一次，一般是json文件加载，控件初始化
--打开窗口	调用openWnd会多次调用，一般做一些窗口数据的更新
	--如果需要数据的刷新可以在该函数里面处理
--关闭窗口	closeWnd 关闭窗口的事件，一般清理该窗口的数据
-- 窗口表 配置szJson则以szJson为json文件名 否则就以key 配置szClickWidget表示改控件接受点击事件 主要为点击屏幕外用
-- 窗口对应的 plist 文件
-- plistUserDel = true 关闭wnd的时候不释放
-- local tbWndJson =
tbWndJson = 
{ 
	Game_Home 					= {Class="MainScene", bCache = false}, --主界面
	Game_MainUI 				= {Class="Game_MainUI"},			                --主界面之布阵界面

    Game_WorldBossRank 			= {Class="Game_WorldBossRank", szClickWidget ="Image_WorldBossRankPNL", bLVEx = true},--伙伴显示
	Game_Card 					= {Class="Game_Card", szClickWidget ="ImageView_CardPNL", bLVEx = true} ,	     
	Game_CardSelect				= {Class="Game_CardSelect", szClickWidget ="Image_CardSelectPNL", bLVEx = true},	     
	Game_VIP 					= {Class="Game_VIP", szClickWidget ="Image_VIPPNL", bLVEx = true},	    
    Game_Ectype 				= {Class="Game_Ectype", bLVEx = true, szClickWidget ="ImageView_NewEctypeListPNL"}, 	     --地图
	Game_Package1 				= {Class="Game_Package1", szClickWidget ="ImageView_PackagePNL", bLVEx = true},         --背包
	Game_HuntFate1 				= {Class="Game_HuntFate1"},   --猎命
	Game_Farm 					= {Class="Game_Farm"},                            --药园
	Game_Assistant				= {Class="Game_Assistant", szClickWidget ="ImageView_AssistantPNL", bLVEx=true},           --助手
	Game_Registration1			= {Class="Game_Registration1", szClickWidget ="Image_RegistrationPNL", bLVEx = true},--签到
	Game_Summon					= {Class="Game_Summon"},                          --十连抽
	Game_ZhaoCaiFu				= {Class="Game_ZhaoCaiFu", szClickWidget ="Image_ZhaoCaiFuPNL"},                              --招财符
	Game_ReCharge				= {Class="Game_ReCharge", szClickWidget ="Image_ReChargePNL", bLVEx=true}, --商城
	-- Game_ReCharge				= {Class="Game_ReCharge", szClickWidget ="Image_ReChargePNL", bLVEx=true}, --商城
	Game_BatFailed				= {Class="Game_BatFailed"},                            --战斗失败 
	Game_BatWin1				= {Class="Game_BatWin1", szClickWidget ="Image_BatResultPNL", bLVEx=true, bIsClickWidgetEnableFalse = true},	--副本结算
	Game_Equip1					= {Class="Game_Equip1"},                               --装备
	Game_FarmPray				= {Class="Game_FarmPray", szClickWidget ="Image_PrayPNL", bLVEx=true},--土地升级
	Game_CardDuJie				= {Class="Game_CardDuJie", bLVEx = true},          --伙伴境界
	Game_CardFate1				= {Class="Game_CardFate1", bLVEx = true},          --伙伴异兽
	Game_Battle					= {Class="Game_Battle", bCache = false},                              --战斗
	Game_WorldBoss1				= {Class="Game_WorldBoss1"},                            --挑战世界boss
	Game_Arena					= {Class="Game_Arena", bLVEx = true},          --竞技场
	Game_ArenaRankClass			= {Class="Game_ArenaRankClass", szClickWidget ="Image_ArenaRankClassPNL"}, --竞技场官阶
	Game_ArenaReward			= {Class="Game_ArenaReward", szClickWidget ="Image_ArenaRewardPNL"},--竞技场奖励
	Game_CardDetailViewOther1	= {Class="Game_CardDetailViewOther1"},
	Game_ViewPlayer				= {Class="Game_ViewPlayer"},                             --查看其它玩家详细资料
	Game_ViewProfile1			= {Class="Game_ViewProfile1", szClickWidget ="Image_ViewProfilePNL"},
	Game_Social1				= {Class="Game_Social1", bLVEx = false},
	Game_System1				= {Class="Game_System1", szClickWidget ="Image_SystemPNL"}, --系统
	Game_EquipStrengthen		= {Class="Game_EquipStrengthen", szClickWidget ="ImageView_EquipStrengthenPNL"},--装备强化
	Game_EquipRefine			= {Class="Game_EquipRefine", szClickWidget ="ImageView_EquipRefinePNL"},--装备合成
	Game_EquipChongZhu   		= {Class="Game_EquipChongZhu", szClickWidget ="ImageView_EquipChongZhuPNL"},--装备重铸
	Game_Notice 				= {Class="Game_Notice", szClickWidget ="Image_NoticePNL"},--公告
	Game_MailBox 				= {Class="Game_MailBox", szJson="Game_MailBox", bLVEx = true},          --邮件
	Game_TipFate				= {Class="Game_TipFate", szClickWidget ="Image_TipFatePNL", bCache = false},--异兽tip
	Game_ArenaRank				= {Class="Game_ArenaRank", szClickWidget ="Image_ArenaRankPNL", bLVEx = true},--排行榜
	Game_ArenaReport			= {Class="Game_ArenaReport", szClickWidget ="Image_ArenaReportPNL",bLVEx = true},--挑战历史
	Game_ArenaHistory			= {Class="Game_ArenaHistory", szClickWidget ="Image_ArenaHistoryPNL"},--竞技场信息
	Game_RewardBox				= {Class="Game_RewardBox", szClickWidget ="Image_RewardBoxPNL", bLVEx = true},
	Game_ActivityFuLuDao		= {Class="Game_ActivityFuLuDao", szClickWidget ="Image_ActivityFuLuDaoPNL"}, --其他试练
	Game_ActivityFuLuDaoSub 	= {Class="Game_ActivityFuLuDaoSub", szClickWidget ="Image_ActivityFuLuDaoSubPNL", bLVEx = true},--其他试练
	Game_QiShu					= {Class="Game_QiShu", szClickWidget ="Image_QiShuPNL", bLVEx = true}, --奇术：包括 阵法和秘法
	Game_ZhenXin				= {Class="Game_ZhenXin", szClickWidget ="Image_ZhenXinPNL", bLVEx = true},--阵法
	Game_ZhenFaSelect			= {Class="Game_ZhenFaSelect", szClickWidget ="Image_ZhenFaSelectPNL"},--选择阵法
	Game_ChatCenter				= {Class="Game_ChatCenter", szClickWidget ="Image_ChatCenterPNL"},--世界聊天
	Game_FarmSelectPlant		= {Class="Game_FarmSelectPlant", szClickWidget ="Image_FarmSelectPlantPNL"},--种植
	Game_FarmReward				= {Class="Game_FarmReward", szClickWidget ="Image_FarmRewardPNL"}, --药园收获后的抽奖
    Game_CardLevelUp 			= {Class="Game_CardLevelUp", szClickWidget ="ImageView_CardLevelUpPNL", bLVEx = true},            --给伙伴使用道具
    Game_XianMai 				= {Class="Game_XianMai", szClickWidget ="Image_Background"},            --仙脉系统
	Game_BattleSetting 		    = {Class="Game_BattleSetting", szClickWidget ="Image_BattleSettingPNL", bCache = false},     --
    Game_BattleDrop 			= {Class="Game_BattleDrop", szClickWidget ="Image_BattleDropPNL", bLVEx = true, bCache = false},     --
    Game_SaoDang 				= {Class="Game_SaoDang", szClickWidget ="Image_SaoDangPNL", bLVEx = true},	--扫荡
	Game_SummonTenTimes			= {Class="Game_SummonTenTimes"},	--十连抽动画
	Game_TipDropItemCard 		= {Class="Game_TipDropItemCard", szClickWidget ="Image_TipDropItemCardPNL", bIsClickWidgetEnableFalse = true, bCache = false},     --伙伴Tip
	Game_TipDropReward			= {Class="Game_TipDropReward", szClickWidget ="Image_TipDropRewardPNL", bIsClickWidgetEnableFalse = true, bCache = false},     --伙伴Tip
	Game_TipDropItemEquip 		= {Class="Game_TipDropItemEquip", szClickWidget ="Image_TipDropItemEquipPNL", bIsClickWidgetEnableFalse = true, bCache = false},     --装备Tip
	Game_TipDropItemFate 		= {Class="Game_TipDropItemFate", szClickWidget ="Image_TipDropItemFatePNL", bIsClickWidgetEnableFalse = true, bCache = false},     --异兽Tip
	Game_TipDropItemHunPo 		= {Class="Game_TipDropItemHunPo", szClickWidget ="Image_TipDropItemHunPoPNL", bIsClickWidgetEnableFalse = true, bCache = false},     --魂魄Tip
	Game_TipDropItemMaterial 	= {Class="Game_TipDropItemMaterial", szClickWidget ="Image_TipDropItemMaterialPNL", bIsClickWidgetEnableFalse = true, bCache = false},     --材料Tip
	Game_TipDropItemFrag 		= {Class="Game_TipDropItemFrag", szClickWidget ="Image_TipDropItemFragPNL", bIsClickWidgetEnableFalse = true, bCache = false},     --技能碎片Tip
	Game_TipDropItemUseItem 	= {Class="Game_TipDropItemUseItem", szClickWidget ="Image_TipDropItemUseItemPNL", bIsClickWidgetEnableFalse = true, bCache = false},     --可使用道具Tip
	Game_TipDropItemFormula 	= {Class="Game_TipDropItemFormula", szClickWidget ="Image_TipDropItemFormulaPNL", bIsClickWidgetEnableFalse = true, bCache = false},     --配方Tip
	Game_TipDropItemEquipPack 	= {Class="Game_TipDropItemEquipPack", szClickWidget ="Image_TipDropItemEquipPackPNL", bIsClickWidgetEnableFalse = true, bCache = false},     --装备材料包Tip
	Game_TipDropItemSoul 		= {Class="Game_TipDropItemSoul", szClickWidget ="Image_TipDropItemSoulPNL", bIsClickWidgetEnableFalse = true, bCache = false},     --元神Tip
	--资源Tip
	Game_TipDropItemResource 	= {Class="Game_TipDropItemResource", szClickWidget ="Image_TipDropItemResourcePNL", bIsClickWidgetEnableFalse = true, bCache = false},     
	--元素Tip
	Game_TipYuanSu 				= {Class="Game_TipYuanSu", szClickWidget ="Image_TipYuanSuPNL", bIsClickWidgetEnableFalse = true, bCache = false},
	--消除技能Tip
	Game_TipXiaoChuSkill		= {Class="Game_TipXiaoChuSkill", szClickWidget ="Image_TipXiaoChuSkillPNL", bIsClickWidgetEnableFalse = true, bCache = false},
	--土地公tip界面
	Game_TipTuDiGong 		    = {Class="Game_TipTuDiGong", szClickWidget ="Image_TipTuDiGongPNL", bIsClickWidgetEnableFalse = true, bCache = false},     
	Game_TipZhenXin			    = {Class="Game_TipZhenXin", szClickWidget ="Image_TipZhenXinPNL", bIsClickWidgetEnableFalse = true, bCache = false},
	Game_TipQiShu				= {Class="Game_TipQiShu", szClickWidget ="Image_TipQiShuPNL", bIsClickWidgetEnableFalse = true, bCache = false},		--阵法和秘法Tip界面
	Game_TipEquip				= {Class="Game_TipEquip", szClickWidget ="Image_TipEquipPNL", bIsClickWidgetEnableFalse = true}, --装备tip
	Game_TipEquipView			= {Class="Game_TipEquipView", szClickWidget ="Image_TipEquipViewPNL", bIsClickWidgetEnableFalse = true}, bCache = false, --装备tip
	Game_HomeFunctionList 		= {Class="Game_HomeFunctionList", szClickWidget ="Image_HomeFunctionListPNL"},
	Game_Turntable 				= {Class="Game_Turntable"},										--转盘奖励
	Game_Compose 				= {Class="Game_Compose",szClickWidget = "Image_ComposePNL",bLVEx = true},		--技能（丹药）合成界面
	Game_SendLoveAnimation		= {Class="Game_SendLoveAnimation"},
	Game_GMConsole 				= {Class="Game_GMConsole", szClickWidget ="ImageView_GMConsolePNL", bCache = false},
	Game_EctypeList 		    = {Class="Game_EctypeList", szClickWidget ="ImageView_EctypeListPNL",bLVEx = true},
	
	Game_SelectGameLevel1		= {Class="Game_SelectGameLevel1", szClickWidget ="ImageView_SelectGameLevelPNL", bLVEx = true},
	Game_SelectGameLevel2		= {Class="Game_SelectGameLevel2", szClickWidget ="ImageView_SelectGameLevelPNL", bLVEx = true},
	Game_SelectGameLevel3		= {Class="Game_SelectGameLevel3", szClickWidget ="ImageView_SelectGameLevelPNL", bLVEx = true},
	
	Game_FunctionOpenNotice		= {Class="Game_FunctionOpenNotice", szClickWidget ="Image_AnimationContentPNL", bLVEx=true, bIsClickWidgetEnableFalse = true, bCache = false},--副本结算
	Game_UpgradeAnimation		= {Class="Game_UpgradeAnimation"},--升级动画
	Game_HeroLevelUpAnimation	= {Class="Game_HeroLevelUpAnimation"},--升级动画
	Game_RankLevelUpAnimation	= {Class="Game_RankLevelUpAnimation"},--竞技场升级动画
	Game_TaskFinishedAnimation	= {Class="Game_TaskFinishedAnimation"},--升级动画
	Game_SummonAnimation		= {Class="Game_SummonAnimation"},--召唤动画
	Game_EquipStrengthenAni		= {Class="Game_EquipStrengthenAni"},--升级动画
	Game_Guiding				= {Class="Game_Guiding", bCache = false},
	Game_BattleBuZhen       	= {Class="Game_BattleBuZhen",szClickWidget ="ImageView_BattleBuZhenPNL",bLVEx = true },--布阵
	Game_BattleBuZhenDuJie      = {Class="Game_BattleBuZhenDuJie",szClickWidget ="ImageView_BattleBuZhenPNL",bLVEx = true,szJson="Game_BattleBuZhen"},--布阵
	Game_ShangXiang1       		= {Class="Game_ShangXiang1"},					--伙伴上香系统
	Game_GroupCreate 			= {Class="Game_GroupCreate", szClickWidget ="Image_GroupCreatePNL", bLVEx = true},--创建帮派与申请帮派，帮派查询
	Game_GroupManage       		= {Class="Game_GroupManage",szClickWidget ="Image_GroupManagePNL"},  --帮派管理
	Game_GroupRequest  			 = {Class="Game_GroupRequest",szClickWidget ="Image_GroupRequestPNL", bLVEx = true},  --帮派申请

	Game_Group					= {Class="Game_Group", bLVEx = true},  --帮派界面
	Game_GroupMemberView		= {Class="Game_GroupMemberView",szClickWidget = "Image_GroupMemberViewPNL"},--帮众信息界面
	Game_GroupSetting			= {Class="Game_GroupSetting",szClickWidget ="Image_GroupSettingPNL", bLVEx = true},  --帮派
	Game_GroupChangeNotice		= {Class="Game_GroupChangeNotice",szClickWidget ="Image_GroupChangeNoticePNL"},  --帮派公告

	Game_LoadingBattle       	= {Class="Game_LoadingBattle", bCache = false, bClearCache = true},  --战斗loading界面
	Game_GroupUpgrade       	= {Class="Game_GroupUpgrade",szClickWidget ="Image_UpgradePNL"},  --帮众升级
	Game_GroupMail       		= {Class="Game_GroupMail",szClickWidget ="Image_GroupMailPNL"},  --帮众邮件
	Game_Confirm				= {Class="Game_Confirm",szClickWidget ="Image_ConfirmPNL",bLVEx = true, bCache = false},
	Game_ConfirmInputNumber		= {Class="Game_ConfirmInputNumber",szClickWidget ="Image_ConfirmPNL",bLVEx = true, bCache = false},
	Game_RewardMsgConfirm		= {Class="Game_RewardMsgConfirm"},
	Game_ItemDropGuide			= {Class="Game_ItemDropGuide",szClickWidget ="ImageView_ItemDropGuidePNL",bLVEx = true},--物品使用

	Game_ShopPrestige			= {Class="Game_ShopPrestige", bLVEx=true}, --声望商店
	Game_ShopSecret			    = {Class="Game_ShopSecret", bLVEx=true}, --神秘商店
	Game_JuBaoGe				= {Class="Game_JuBaoGe", szClickWidget ="Image_JuBaoGePNL"},
	Game_ActivityShiLianShan	= {Class="Game_ActivityShiLianShan", szClickWidget ="Image_ActivityShiLianShanPNL"},
	Game_ActivityJuXianGe		= {Class="Game_ActivityJuXianGe", szClickWidget ="Image_ActivityJuXianGePNL"},
	Game_FirstCharge			= {Class="Game_FirstCharge", szClickWidget ="Image_FirstChargePNL",},
	Game_DuJieSelectHelper		= {Class="Game_DuJieSelectHelper", szClickWidget="Image_DuJieSelectHelperPNL", bLVEx=true}, --渡劫伙伴 选择协助伙伴
	Game_Dialogue				= {Class="Game_Dialogue"}, --对话场景
	Game_GanWu					= {Class="Game_GanWu", szJson="Game_GanWu", bLVEx = true},  --感悟

	Game_ActivityCenter			= {Class="Game_ActivityCenter", szClickWidget="Image_ActivityCenterPNL", bLVEx=true}, --运营活动
	Game_CardLevelUpSingle		= {Class="Game_CardLevelUpSingle",szClickWidget ="Image_CardLevelUpSinglePNL",bLVEx=true}, --卡牌道具经验升级
	Game_EctypeJY				= {Class="Game_EctypeJY",bLVEx=true}, --精英副本
	Game_EctypeJYDetail			= {Class="Game_EctypeJYDetail",szClickWidget ="Image_EctypeJingYingDetailPNL", bLVEx=true}, --精英副本
	
	Game_WorldBoss2				= {Class="Game_WorldBoss2",}, --世界BOSS2
	Game_JiHuiSuo				= {Class="Game_JiHuiSuo",}, --集会所

    Game_BaXianPray				= {Class="Game_BaXianPray",szClickWidget ="Image_BaXianPrayPNL",bLVEx=true}, --祭拜上香

    --八仙过海
    Game_BaXuanGuoHai           = {Class="Game_BaXuanGuoHai"} ,
    Game_BaXianDaJie            = {Class="Game_BaXianDaJie", szClickWidget ="Image_BaXianDaJiePNL", bLVEx = true} ,
    Game_BaXianRefresh          = {Class="Game_BaXianRefresh", szClickWidget ="Image_BaXianRefreshPNL"} ,
    Game_BaXianFilter           = {Class="Game_BaXianFilter", szClickWidget = "Image_BaXianFilterPNL", bCache = false} ,
    Game_TipBaXianView          = {Class="Game_TipBaXianView", szClickWidget = "Image_TipBaXianViewPNL", bCache = false} ,
    Game_PublicBuZhen           = {Class="Game_PublicBuZhen", szClickWidget ="ImageView_BattleBuZhenPNL",bLVEx = true,szJson="Game_BattleBuZhen"} ,
	Game_DragonPray				= {Class="Game_DragonPray" }, --神龙上供
	Game_EquipRefineStarUp		= {Class="Game_EquipRefineStarUp", szClickWidget ="Image_EquipRefineStarUpPNL"}, --装备升星
	Game_ServerOpenTask			= {Class="Game_ServerOpenTask", szClickWidget ="Image_ServerOpenTaskPNL" , bLVEx=true}, --开服活动
	Game_ServerOpenReward		= {Class="Game_ServerOpenReward", szClickWidget ="Image_ServerOpenRewardPNL", bLVEx=true}, 
	--未召唤卡牌的信息界面
	Game_CardHandBook      		= {Class="Game_CardHandBook"},
	--传承
	Game_ChuanCheng      		= {Class="Game_ChuanCheng",szClickWidget ="Image_ChuanChengPNL",bLVEx=true},
	Game_BattleFighterInfo 		= {Class="Game_BattleFighterInfo", szClickWidget ="Image_BattleFighterInfoPNL", bIsClickWidgetEnableFalse = true, bCache = false},
	Game_GroupView 				= {Class="Game_GroupView", szClickWidget ="Image_GroupViewPNL"},
	--万宝楼
	Game_GuildBank 				= {Class="Game_GuildBank", szClickWidget ="Image_GuildBankPNL",bLVEx=true},
	--书画院
	Game_GuildSchool 			= {Class="Game_GuildSchool", szClickWidget ="Image_GuildSchoolPNL",bLVEx=true},
	--炼神塔
	Game_GuildSkill 			= {Class="Game_GuildSkill", szClickWidget ="Image_GuildSkillPNL",bLVEx=true},


	Game_DragonPrayGuild		= {Class="Game_DragonPrayGuild" },
	Game_SceneBossGuild			= {Class="Game_SceneBossGuild",},
	Game_WorldBossGuild			= {Class="Game_WorldBossGuild",},
    --facebook邀请好友奖励界面
    Game_FacebookReward         = {Class="Game_FacebookReward",szClickWidget ="Image_FacebookRewardPNL",bLVEx=true},
    --facebook分享奖励界面
    Game_FacebookShare         	= {Class="Game_FacebookShare",szClickWidget ="Image_FacebookSharePNL",bLVEx=true},
	Game_ConfirmHunPo			= {Class="Game_ConfirmHunPo",szClickWidget ="Image_ConfirmHunPoPNL", bCache = false},
	--召喚日誌
	Game_SummonLog				= {Class="Game_SummonLog",szClickWidget ="Image_SummonLogPNL", bLVEx = true},
	
	--跨服
	Game_ArenaKuaFu				= {Class="Game_ArenaKuaFu", szClickWidget ="Image_Background", bLVEx = true},
	--跨服战报
	Game_ArenaReortKuaFu		= {Class="Game_ArenaReortKuaFu",szClickWidget ="Image_ArenaReportPNL",bLVEx = true, szJson="Game_ArenaReport"},
	--跨服战报排行榜
	Game_ArenaKuaFuRank			= {Class="Game_ArenaKuaFuRank", szClickWidget ="Image_ArenaRankPNL", bLVEx = true, szJson="Game_ArenaRank"},
	--关于我们
	Game_AboutUs				= {Class="Game_AboutUs",szClickWidget ="Image_AboutUsPNL"},  --关于我们
    --可选奖励窗口
    Game_RewardSelectBox        = {Class="Game_RewardSelectBox", szClickWidget ="Image_RewardSelectBoxPNL", bLVEx = true },  
	--推荐阵容
	Game_ZhenRong				= {Class="Game_ZhenRong",szClickWidget ="Image_ZhenRongPNL", bLVEx = true},
	--妖兽图鉴
	Game_YaoShouBook			= {Class="Game_YaoShouBook",szClickWidget ="Image_YaoShouBookPNL", bLVEx = true},
}

--创建CWndMgr类
Class_WndMgr = class("Class_WndMgr")
Class_WndMgr.__index = Class_WndMgr

-- 用来记录lua堆栈的缓存
g_LuaMemoryCount = 0

function Class_WndMgr:ctor()
    self.tbAllWnd = {}
	self.tbOpenWnd = {}
	self.tbRootWidget= {}--缓存窗口
end

function Class_WndMgr:create()
	return Class_WndMgr.new()
end

function Class_WndMgr:registerCloseEvent(rootWidget, szWnd, bfunc)
	local Button_Return = tolua.cast(rootWidget:getChildAllByName("Button_Return"), "Button")

	if Button_Return then
		local function onClickButton_Return(pSender, nTag)
			if bfunc then
				classWnd:onClickButton_Return()
			else
				self:closeWnd(szWnd)
			end
		end
		g_SetBtnWithGuideCheck(Button_Return, nil, onClickButton_Return, true, true, nil, nil)
	else
	--
	end

    if tbWndJson and tbWndJson[szWnd] and tbWndJson[szWnd].szClickWidget then
        local widgetClick = rootWidget:getChildAllByName(tbWndJson[szWnd].szClickWidget)
        if widgetClick then
			if tbWndJson[szWnd].bIsClickWidgetEnableFalse then	--有些像弹出动画需要直接点击屏幕就关闭
				widgetClick:setTouchEnabled(false)
			else
				widgetClick:setTouchEnabled(true)
			end
            
		    local function onTouchScreen(pSender, eventType)
				if Button_Return and not Button_Return:isTouchEnabled() then return end
			    if eventType == ccs.TouchEventType.began then
				    if Button_Return then
                        Button_Return:setBrightStyle(BRIGHT_HIGHLIGHT)
                    end
                elseif eventType == ccs.TouchEventType.canceled then
                    if Button_Return then
                        Button_Return:setBrightStyle(BRIGHT_NORMAL)
                    end
                elseif eventType == ccs.TouchEventType.ended then
                    if Button_Return then
                        Button_Return:setBrightStyle(BRIGHT_NORMAL)
                    end
                    self:closeWnd(szWnd)
                    g_playSoundEffect("Sound/ButtonClick.mp3")
			    end
		    end
		    rootWidget:addTouchEventListener(onTouchScreen)
        end
    end
end

function Class_WndMgr:createWnd(szWnd, tbData)
	-- 本来是打算放在destroyWnd里面的，但是会影响动画到节奏所以就放在这里了
	local nLuaMemoryCount = collectgarbage("count") / 1024
    -- cclog("====================进入游戏的LUA堆栈的缓存==================="..g_LuaMemoryCount.."MB")
    -- cclog("====================当前的LUA堆栈的缓存==================="..nLuaMemoryCount.."MB")
    -- Lua缓存增量超过5MB点时候就清理一遍
    if (nLuaMemoryCount > g_LuaMemoryCount) and (nLuaMemoryCount - g_LuaMemoryCount) > 25 then
		cclog("====================清理的LUA堆栈的缓存==================="..nLuaMemoryCount.."MB")
		collectgarbage("collect")
	end

	local nOld = API_GetCurrentTime()
	local rootWidget = nil

	if not tbWndJson[szWnd] then
		cclog("游戏窗口没配置或找不到szJson")
		return nil, false
	end

    local widgetName = tbWndJson[szWnd].szJson or szWnd
    local plistname = tbWndJson[szWnd].plist
    if plistname ~= nil then
    	for k, v in pairs(plistname) do
    		g_ResourcePack:LoaderResource(v)
    	end
    end
	
    -- if self.tbRootWidget ~= nil then
   		-- rootWidget = self.tbRootWidget[szWnd]
	-- end
	
    -- if rootWidget == nil then
		-- if(tbWndJson[szWnd].bLVEx)then
			-- rootWidget = GUIReader:shareReader():widgetFromJsonFileEx(widgetName..".json")
		-- else
			-- rootWidget = GUIReader:shareReader():widgetFromJsonFile(widgetName..".json")
		-- end
	-- end

	rootWidget = self:getFormtbRootWidget(szWnd)

	local Class = tbWndJson[szWnd].Class
	if not Class or not _G[Class] then
		cclog("游戏窗口没配置或找不到 Class 没有此全局变量")
		return nil, false
	end
	classWnd = _G[Class].new()
	classWnd.rootWidget = rootWidget

	local bDelay = classWnd:initWnd(rootWidget, tbData)
	self.tbAllWnd[szWnd] = classWnd

	if classWnd.onClickButton_Return then

	else
		self:registerCloseEvent(rootWidget, szWnd)
	end

	local nCur = API_GetCurrentTime()
	local nCostTime = nCur - nOld
	cclog("****************Load【"..szWnd.."】 cost time **********"..nCostTime )
	if(nCostTime > 1)then
		cclog("****************建议：本窗口加载时间太长 需要优化**************")
	end

	if not self.rootWndMgrLayer then
        self.rootWndMgrLayer  = TouchGroup:create()
	    self.rootWndMgrLayer:setTouchPriority(1)
	    
	    if g_OnExitGame then
	    	if mainWnd   then
		    	if mainWnd:isExsit() then
		    	 	mainWnd:addChild(self.rootWndMgrLayer)
		    	else 
		    		mainWnd = nil
		    	end
		    end
	    else
	    	if mainWnd then
		    	 mainWnd:addChild(self.rootWndMgrLayer)
		    end
	    end
    end

    self.rootWndMgrLayer:addWidget(rootWidget)

	return classWnd, bDelay
end

function Class_WndMgr:pushWnd(szWnd)
	if self.tbOpenWnd[#self.tbOpenWnd] ~= szWnd then
		table.insert(self.tbOpenWnd,szWnd)
	end
end

function Class_WndMgr:popWnd(szWnd)
    for i=#self.tbOpenWnd,  1, -1 do
        if self.tbOpenWnd[i] == szWnd then
            table.remove(self.tbOpenWnd, i)
            return
        end
    end
end

--打开某个窗口 并且隐藏前一个
function Class_WndMgr:openWnd(szWnd, tbData, funcCallBack)
	--判断当前窗口是不是 需要网络消息之后才打开，如果createWnd返回假则不打开只初始化
	local classWnd = self.tbAllWnd[szWnd]
	if(not classWnd)then
		local bRetDelay = nil
		classWnd, bRetDelay = self:createWnd(szWnd, tbData)
		if not classWnd or not classWnd.rootWidget then return end

		if(bRetDelay == false)then
			if classWnd then
				classWnd.rootWidget:setVisible(false)
			end
			return
		end
	end
	
	if not classWnd or not classWnd.rootWidget then return end

	if(not classWnd or (classWnd.checkData and classWnd:checkData(tbData) == false) )then
        classWnd.rootWidget:setVisible(false)
		return
	end

	g_HeadBar:addHeadBar(classWnd.rootWidget, szWnd)
	--先隐藏当前显示的
	local nCount = #self.tbOpenWnd
	if(nCount > 0)then
		local szWndName = self.tbOpenWnd[nCount]
		if(szWndName == szWnd)then--当前窗口再次打开
            g_LggV:ModifyWnd(classWnd)
            if classWnd.openWnd  then
                classWnd:openWnd(tbData)
            end

			return
		end
		self.tbAllWnd[szWndName].rootWidget:setVisible(false)
	end

	--打开窗口
	classWnd.rootWidget:setVisible(true)
    classWnd.rootWidget:setZOrder(INT_MAX)
    self:popWnd(szWnd)
	table.insert(self.tbOpenWnd, szWnd)
    g_LggV:ModifyWnd(classWnd)  
	if(classWnd.openWnd)then
		classWnd:openWnd(tbData)
	end
	if(classWnd.setBubbleNotify)then
		classWnd:setBubbleNotify()
	end
	
	if g_PlayerGuide:checkCurrentGuideSequenceNode("OpenWnd", szWnd) then
		g_PlayerGuide:showCurrentGuideSequenceNode()
	end
	
	local function funcWndOpenAniCall()
		if funcCallBack then
			funcCallBack()
		end
		if classWnd.rootWidget then
			classWnd.rootWidget:setTouchEnabled(true)
		end
	end
	
	--窗口打开动画
	if(classWnd.showWndOpenAnimation)then
		classWnd:showWndOpenAnimation(funcWndOpenAniCall)
	else
		funcWndOpenAniCall()
	end
end

function Class_WndMgr:dumpAnimationResouce()
	CCAnimationCache:purgeSharedAnimationCache();  
	CCTextureCache:sharedTextureCache():removeAllTextures()
end

function Class_WndMgr:getProWnd(szWnd)
    local nIndex = 1
    for i=1, #self.tbOpenWnd do
        if(szWnd == self.tbOpenWnd[i] )then
            nIndex =  i
        end
    end 

    if nIndex == 1 then     
       nIndex = 2
    end

	local szWnd = self.tbOpenWnd[nIndex-1]
	return self.tbAllWnd[szWnd], szWnd
end

function Class_WndMgr:closeWndEndUpAction(szWnd, funcCallBack)
	--关闭当前的
	local classWnd = self.tbAllWnd[szWnd]
	
	local bRet = nil
	if(classWnd.closeWnd)then
		if funcCallBack then
			funcCallBack()
		end
		-- if g_PlayerGuide.lastArmature then
		-- 	g_PlayerGuide.lastArmature:removeFromParentAndCleanup(true)
		-- 	g_PlayerGuide.lastArmature = nil
		-- end
		g_PlayerGuide:RemoveLastArmature()

		if g_PlayerGuide.Image_NPCGuideTipPNL then
			g_PlayerGuide.Image_NPCGuideTipPNL:removeFromParentAndCleanup(true)
			g_PlayerGuide.Image_NPCGuideTipPNL = nil
		end
		if g_PlayerGuide:checkCurrentGuideSequenceNode("CloseWnd", szWnd) then
			g_PlayerGuide:showCurrentGuideSequenceNode()
		end
		bRet = classWnd:closeWnd()
	else
		if funcCallBack then
			funcCallBack()
		end
		-- if g_PlayerGuide.lastArmature then
		-- 	g_PlayerGuide.lastArmature:removeFromParentAndCleanup(true)
		-- 	g_PlayerGuide.lastArmature = nil
		-- end
		g_PlayerGuide:RemoveLastArmature()
		
		if g_PlayerGuide.Image_NPCGuideTipPNL then
			g_PlayerGuide.Image_NPCGuideTipPNL:removeFromParentAndCleanup(true)
			g_PlayerGuide.Image_NPCGuideTipPNL = nil
		end
		if g_PlayerGuide:checkCurrentGuideSequenceNode("CloseWnd", szWnd) then
			g_PlayerGuide:showCurrentGuideSequenceNode()
		end
	end
	--
	classWnd.rootWidget:setVisible(false)
	
	--打开前一个窗口
    local szProWndName = nil
	classWnd, szProWndName = self:getProWnd(szWnd)
    if not classWnd then --只要为了副本那边返回
        classWnd = self:createWnd(szWnd)
        if not classWnd then return end
		g_HeadBar:addHeadBar(classWnd.rootWidget, szProWndName)
        g_LggV:ModifyWnd(classWnd)
        classWnd:openWnd(bRet)
        self:popWnd(szWnd)
		
		if g_PlayerGuide:checkCurrentGuideSequenceNode("OpenWnd", szProWndName) then
			g_PlayerGuide:showCurrentGuideSequenceNode()
		end		
        return
    end
	classWnd.rootWidget:setVisible(true)
    g_LggV:ModifyWnd(classWnd)
	if(classWnd.openWnd)then
		g_bReturn = true
		g_HeadBar:addHeadBar(classWnd.rootWidget, szProWndName)
		classWnd:openWnd(bRet)
		if g_PlayerGuide:checkCurrentGuideSequenceNode("OpenWnd", szProWndName) then
			g_PlayerGuide:showCurrentGuideSequenceNode()
		end
		g_bReturn = nil
	end
	
    self:popWnd(szWnd)
	
	--释放隐藏窗口
	if szWnd == "Game_Home" then
		--主界面不释放
	else
		self:destroyWnd(szWnd)
	end
end

function Class_WndMgr:closeWnd(szWnd, funcCallBack)
	local classWnd = self.tbAllWnd[szWnd]
	if( not classWnd)then
		return
	end
	
	if classWnd.showWndCloseAnimation then
		local function funcWndCloseAniCall()
			self:closeWndEndUpAction(szWnd, funcCallBack)
		end
		classWnd:showWndCloseAnimation(funcWndCloseAniCall)
	else
		self:closeWndEndUpAction(szWnd, funcCallBack)
	end
end

function Class_WndMgr:closeWndWithoutAnimation(szWnd, funcCallBack)
	local classWnd = self.tbAllWnd[szWnd]
	if( not classWnd)then
		return
	end

	self:closeWndEndUpAction(szWnd, funcCallBack)
end

function Class_WndMgr:showMainWnd(funcCallBack)
    if( self.tbEffectWidget) then
        for i =1, #self.tbEffectWidget do
            self.tbEffectWidget[i]:removeFromParentAndCleanup(true)
        end
        self.tbEffectWidget = nil
    end

    for i=2, #self.tbOpenWnd do
        self:setVisible(self.tbOpenWnd[i], false)
    end
	self.tbOpenWnd = {}

	self:openWnd("Game_Home")
	
	if funcCallBack then
		funcCallBack()
	end
end

function Class_WndMgr:destroyWnd(szWnd)
	if not self.tbAllWnd[szWnd] then
		return
	end

	local plistname = tbWndJson[szWnd].plist
	if plistname ~= nil and not tbWndJson[szWnd].plistUserDel then
		for k, v in pairs(plistname) do
    		g_ResourcePack:DeleteResource(v)
    	end
	end
    if self.tbAllWnd[szWnd].releaseWnd then
        self.tbAllWnd[szWnd]:releaseWnd()
    end
	
	self.tbAllWnd[szWnd].rootWidget:removeFromParent()
	
	--释放引用计数为1的纹理，即未使用的纹理，窗口缓存的不会被释放
	CCTextureCache:sharedTextureCache():removeUnusedTextures()
	
	self.tbAllWnd[szWnd].rootWidget = nil
	self.tbAllWnd[szWnd] 			= nil
	self.tbOpenWnd[szWnd]			= nil
end

--纯粹的打开一个窗口，前一个窗口不隐藏, tbData是打开某个窗口并传递参数 tbData可以为空
function Class_WndMgr:showWnd(szWnd, tbData, funcCallBack)
	local classWnd = self.tbAllWnd[szWnd]
	if(not classWnd)then
		local bRetDelay = nil
		classWnd, bRetDelay = self:createWnd(szWnd, tbData)--如果返回false则等待网络消息
		if(bRetDelay == false)then
			if classWnd then
				classWnd.rootWidget:setVisible(false)
			end
			
			return
		end
	end

    if(not classWnd or (classWnd.checkData and classWnd:checkData(tbData) == false) )then
    	if  classWnd.rootWidget and classWnd.rootWidget:isExsit() then
        	classWnd.rootWidget:setVisible(false)
    	end
		return
	end

	classWnd.rootWidget:setVisible(true)
    classWnd.rootWidget:setZOrder(INT_MAX)
	
	local nCount = #self.tbOpenWnd
	local szWndName = self.tbOpenWnd[nCount]
	if szWndName ~= szWnd then
        self:popWnd(szWnd)
		table.insert(self.tbOpenWnd, szWnd)
	end

    g_HeadBar:addHeadBar(classWnd.rootWidget,szWnd)
    g_LggV:ModifyWnd(classWnd)
	if(classWnd.openWnd)then
		classWnd:openWnd(tbData)
	end
	
	if g_PlayerGuide:checkCurrentGuideSequenceNode("OpenWnd", szWnd) then
		g_PlayerGuide:showCurrentGuideSequenceNode()
	end
		
	local function funcWndOpenAniCall()
		if funcCallBack then
			funcCallBack()
		end
		classWnd.rootWidget:setTouchEnabled(true)
	end
	
	--窗口打开动画
	if(classWnd.showWndOpenAnimation)then
		classWnd:showWndOpenAnimation(funcWndOpenAniCall)
	else
		funcWndOpenAniCall()
	end
end

--隐藏自己 并且把自己从队列里面删除
function Class_WndMgr:hideWnd(szWnd)
	local classWnd = self.tbAllWnd[szWnd]
	if not classWnd then return end

	self:popWnd(szWnd)
	--关闭当前的
	local bRet = nil
	if(classWnd.closeWnd)then
		bRet = classWnd:closeWnd()
	end
	classWnd.rootWidget:setVisible(false)
	if g_PlayerGuide:checkCurrentGuideSequenceNode("HideWnd", szWnd) then
		cclog("=================HideWnd====================")
		g_PlayerGuide:showCurrentGuideSequenceNode()
	end
end

function Class_WndMgr:reLoadWnd(szWnd)
	 self.tbAllWnd[szWnd] = nil
	 if self.tbOpenWnd[#self.tbOpenWnd] == szWnd then
		table.remove(self.tbOpenWnd)
	end
end

function Class_WndMgr:getCurWnd()
	return self:getWnd(self.tbOpenWnd[#self.tbOpenWnd])
end

function Class_WndMgr:popAllWnd(tbNewWnd)
	self.tbOpenWnd = {}
    for i =1, #tbNewWnd do
        table.insert(self.tbOpenWnd, tbNewWnd[i])
    end
end

function Class_WndMgr:getTopWndName()
	return self.tbOpenWnd[#self.tbOpenWnd]
end

function Class_WndMgr:getWnd(szWnd)
	return self.tbAllWnd[szWnd]
end

function Class_WndMgr:getRootWidget()
	return self.rootWndMgrLayer
end

function Class_WndMgr:addChild(widget)
	self.rootWndMgrLayer:addChild(widget)
end

function Class_WndMgr:removeChild(widget, cleanup)
	self.rootWndMgrLayer:removeChild(widget, cleanup)
end

function Class_WndMgr:setVisible(szWnd, bVisible)
	local classWnd = self.tbAllWnd[szWnd]
	if not classWnd then return end
	classWnd.rootWidget:setVisible(bVisible)
end

function Class_WndMgr:isVisible(szWnd)
	local classWnd = self.tbAllWnd[szWnd]
	if not classWnd then return false end
	return classWnd.rootWidget:isVisible()
end

function Class_WndMgr:reset(bRefresh)
    g_bReturn = nil
	--定时器清理一下
    g_ClearSpineAnimation(true)
	g_Timer:clearAllTimer()
	for k, v in pairs(self.tbAllWnd)  do

        local plistname = tbWndJson[k].plist
        if plistname ~= nil and not tbWndJson[szWnd].plistUserDel then
            for k1, v1 in pairs(plistname) do
                g_ResourcePack:DeleteResource(v1)
            end
        end
        if v.releaseWnd then v:releaseWnd() end
        v.rootWidget:removeFromParent()

		if(v.destroyWnd)then
			v:destroyWnd()
		end
		--v.rootWidget:removeFromParent()
	end

    self:ReleasebtAllRootWidget()

    --引导的动画添加到对应的窗口上了， 所以这里如果在引导的过程中调用 Class_WndMgr:reset 会出现bug  （destroyGuide 会release ， 窗口释放会 release。）
    -- g_PlayerGuide:destroyGuide()
	g_WndMgr = nil
	g_WndMgr = Class_WndMgr:create()
    if not bRefresh then--如果是刷新脚本不需要重新创建
        for k, value in pairs(g_Hero) do
			g_Hero[k] = nil			
		end
    end
end

function Class_WndMgr:ResetWndEx()
	g_bReturn = nil
    g_ClearSpineAnimation(true)
	for k, v in pairs(self.tbAllWnd)  do

        local plistname = tbWndJson[k].plist
        if plistname ~= nil and not tbWndJson[szWnd].plistUserDel then
            for k1, v1 in pairs(plistname) do
                g_ResourcePack:DeleteResource(v1)
            end
        end
        if v.releaseWnd then v:releaseWnd() end
        v.rootWidget:removeFromParent()

		if(v.destroyWnd)then
			v:destroyWnd()
		end
	end
    self:ReleasebtAllRootWidget()
    g_PlayerGuide:destroyGuide()
	g_WndMgr = nil
	g_WndMgr = Class_WndMgr:create()
end

--隐藏前一个窗口
function Class_WndMgr:hideProWnd()
	local nCount = #self.tbOpenWnd
	local szWndName = self.tbOpenWnd[nCount]
	if(szWndName )then
		self:hideWnd(szWndName)
	end
end

---------add by wb
rootWidgetItem = class("rootWidgetItem")
rootWidgetItem.__index = rootWidgetItem

gRootIndex = 0--混存窗口的增量基数

function rootWidgetItem:ctor()
    self.szWnd = ""
	self.root = nil
	self.index  = 0
end

function Class_WndMgr:getWidgetFormJson(szWnd)
    if  tbWndJson[szWnd] == nil then return nil end

	local widgetName = tbWndJson[szWnd].szJson or szWnd
	if(tbWndJson[szWnd].bLVEx)then
		root = GUIReader:shareReader():widgetFromJsonFileEx(widgetName..".json")
	else
		root = GUIReader:shareReader():widgetFromJsonFile(widgetName..".json")
	end
	return root
end

function Class_WndMgr:ReleasebtAllRootWidget()
    for k, v in pairs(self.tbRootWidget) do
        v.root:release()
    end
    self.tbRootWidget = {}
end

--删除指定个数的，旧的缓存窗口,并清理一次文理缓存
function Class_WndMgr:ReleasebtRootWidgetByOldCnt(OldCnt)
    local OldMax =0
    local tmpcnt = OldCnt
    local releaseTB = {}
    for k, v in pairs(self.tbRootWidget) do
        if tmpcnt <= 0 then
            if v.index < OldMax then
                releaseTB[OldMax] = nil
                releaseTB[v.index] = v
            end      
        else 
            releaseTB[v.index] = v
            tmpcnt = tmpcnt - 1
        end
        OldMax = 0
        for k, v in pairs(releaseTB) do
            if v.index > OldMax then OldMax = v.index end
        end
    end

    for k, v in pairs(releaseTB) do
        self.tbRootWidget[v.szWnd].root:release()
        self.tbRootWidget[v.szWnd] = nil
    end
	
	--释放引用计数为1的纹理，即未使用的纹理，窗口缓存的不会被释放
	CCTextureCache:sharedTextureCache():removeUnusedTextures()
end

--释放所有未打开的窗口和纹理，进战斗之前要用到
function Class_WndMgr:releaseAllUnOpenRootWidget()
	echoj(self.tbOpenWnd)
    for k, v in pairs(self.tbRootWidget) do
		if not self.tbOpenWnd[k] then
			self.tbRootWidget[k].root:release()
			self.tbRootWidget[k] = nil
		end
	end
	--释放所有纹理
	self:dumpAnimationResouce()
end

function Class_WndMgr:getFormtbRootWidget(szWnd)
	local root = nil

	if tbWndJson[szWnd].bClearCache ~= nil and tbWndJson[szWnd].bClearCache == true then 
		self:releaseAllUnOpenRootWidget()
	end

	--战斗界面、主界面、小窗口不用加入缓存
	if tbWndJson[szWnd].bCache ~= nil and tbWndJson[szWnd].bCache == false then
		return self:getWidgetFormJson(szWnd)
	end

	if self.tbRootWidget[szWnd] and self.tbRootWidget[szWnd].root then
		root = self.tbRootWidget[szWnd].root
	end
	
	if root == nil then
        root = self:getWidgetFormJson(szWnd)

		if root ~= nil then
			root:retain()
			local rootItem = rootWidgetItem.new()
			rootItem.root = root
            rootItem.szWnd = szWnd
			gRootIndex = gRootIndex+1
			rootItem.index = gRootIndex
			self.tbRootWidget[szWnd] = rootItem

            local wCnt = 0
			for k, v in pairs(self.tbRootWidget) do wCnt = wCnt + 1 end
            if wCnt >= 10 then self:ReleasebtRootWidgetByOldCnt(5) end
		end
	end

	return root
end

g_WndMgr = Class_WndMgr:create()

