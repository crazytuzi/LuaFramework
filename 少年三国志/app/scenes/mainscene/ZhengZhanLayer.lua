--ZhengZhanLayer.lua
require("app.const.ShopType")

local CrossPVPCommon = require("app.scenes.crosspvp.CrossPVPCommon")
local CrusadeCommon = require("app.scenes.crusade.CrusadeCommon")

local FunctionLevelConst = require("app.const.FunctionLevelConst")

local ZhengZhanLayer = class("ZhengZhanLayer", UFCCSNormalLayer)

local CrusadeMainLayer = require("app.scenes.crusade.CrusadeMainLayer")

ZhengZhanLayer.FIGHT_TYPE = {
	FIGHT_ARENA = 1,
	FIGHT_TREASURE = 2,
	FIGHT_KNIGHT = 3,
	FIGHT_MOSHENG = 4,
}

ZhengZhanLayer.RAPID_BTNS = {
	[1] = { 
		-- 竞技奖励:竞技场有奖励可领取时
		icon = "ui/play/icon-jingjichang.png",
		tipIcon = "ui/text/txt/wf_jiangli.png",
		jumpScene = "ShopScoreScene",
		param = {SCORE_TYPE.JING_JI_CHANG},
		descId = "LANG_RAPID_BTN_TEXT_ARENA",
		check = function ( ... )
			return G_Me.shopData:checkAwardTipsByType(SCORE_TYPE.JING_JI_CHANG)
		end
	},
	[2] = { 
		-- 夺宝合成:当前有宝物可合成时
		icon = "ui/play/icon-duobao.png",
		jumpScene = "TreasureComposeScene",
		param = {},
		descId = "LANG_RAPID_BTN_TEXT_COMPOSE",
		check = function ( ... )
			return G_Me.bagData:CheckTreasureFragmentCompose()
		end
	},
	[3] = { 
		-- 无双奖励:三国无双商店中有奖励可领取时出现，领完奖励后消失
		icon = "ui/play/icon-sanguowushuang.png",
		tipIcon = "ui/text/txt/wf_jiangli.png",
		jumpScene = "ShopScoreScene",
		param = {SCORE_TYPE.CHUANG_GUAN},
		descId = "LANG_RAPID_BTN_TEXT_WUSH_AWARD",
		check = function ( ... )
			return G_Me.shopData:checkAwardTipsByType(SCORE_TYPE.CHUANG_GUAN)
		end
	},
	[4] = { 
		-- 无双重置:当天有免费重置次数时
		icon = "ui/play/icon-sanguowushuang.png",
		jumpScene = "WushScene",
		param = {},
		descId = "LANG_RAPID_BTN_TEXT_WUSH_RESET",
		check = function ( ... )
			return G_moduleUnlock:isModuleUnlock(FunctionLevelConst.TOWER_SCENE) and (G_Me.wushData:getResetCount() < G_Me.wushData:getResetFreeCount())
		end
	},
	[5] = { 
		-- 巡逻奖励:当前城池完成巡逻尚未领取奖励时
		icon = "ui/play/icon-lingditaofa.png",
		tipIcon = "ui/text/txt/wf_jiangli.png",
		jumpScene = "CityScene",
		param = {},
		descId = "LANG_RAPID_BTN_TEXT_CITY_AWARD",
		check = function ( ... )
			return G_moduleUnlock:isModuleUnlock(FunctionLevelConst.CITY_PLUNDER) and G_Me.cityData:needHarvest()
		end
	},
	[6] = { 
		-- 领地巡逻:当前有城池可以添加巡逻武将时
		icon = "ui/play/icon-lingditaofa.png",
		jumpScene = "CityScene",
		param = {},
		descId = "LANG_RAPID_BTN_TEXT_CITY_ACTIVITY",
		check = function ( ... )
			return G_moduleUnlock:isModuleUnlock(FunctionLevelConst.CITY_PLUNDER) and G_Me.cityData:needPatrol()
		end
	},
	[7] = { 
		-- 叛军奖励:叛军中有未领取奖励时
		icon = "ui/play/icon-panjun.png",
		tipIcon = "ui/text/txt/wf_jiangli.png",
		jumpScene = "MoShenScene",
		param = {nil, nil, nil, nil, nil, true},
		descId = "LANG_RAPID_BTN_TEXT_MOSHEN_AWARD",
		check = function ( ... )
			return G_moduleUnlock:isModuleUnlock(FunctionLevelConst.MOSHENG_SCENE) and G_Me.moshenData:checkAwardSignEnabled()
		end
	},
	[8] = { 
		-- 征讨令减半:中午12:00~14:00显示。
		icon = "ui/play/icon-panjun.png",
		tipIcon = "ui/text/txt/wf_xianshi.png",
		jumpScene = "MoShenScene",
		param = {},
		descId = "LANG_RAPID_BTN_TEXT_MOSHEN_ACTIVITY",
		check = function ( ... )
			return G_moduleUnlock:isModuleUnlock(FunctionLevelConst.MOSHENG_SCENE) and G_Me.moshenData:checkEventActive(1)
		end
	},
	[9] = { 
		-- 功勋翻倍:下午18:00~20:00显示。
		icon = "ui/play/icon-panjun.png",
		tipIcon = "ui/text/txt/wf_xianshi.png",
		jumpScene = "MoShenScene",
		param = {},
		descId = "LANG_RAPID_BTN_TEXT_GONGXUN_DOUBLE",
		check = function ( ... )
			return G_moduleUnlock:isModuleUnlock(FunctionLevelConst.MOSHENG_SCENE) and G_Me.moshenData:checkEventActive(3)
		end
	},
	[10] = { 
		-- 积分赛:积分赛里面有获胜奖励尚未领取时显示
		icon = "ui/play/icon-kuafuyanwu.png",
		tipIcon = "ui/text/txt/wf_jiangli.png",
		jumpScene = "CrossWarScene",
		param = {false, true, false, false, false},
		descId = "LANG_RAPID_BTN_TEXT_CROSS_AWARD",
		check = function ( ... )
			return G_moduleUnlock:isModuleUnlock(FunctionLevelConst.CROSS_WAR) and G_Me.crossWarData:canEnterScoreMatch() and G_Me.crossWarData:checkCanGetAward()
		end
	},
	[11] = { 
		-- 积分赛:当前已开赛但未报名，或者已参赛还有免费挑战次数尚未使用时显示
		icon = "ui/play/icon-kuafuyanwu.png",
		tipIcon = "ui/text/txt/wf_xianshi.png",
		jumpScene = "CrossWarScene",
		param = {true, false, false, false, false},
		descId = "LANG_CROSS_WAR_MODE_1",
		check = function ( ... )
			return G_moduleUnlock:isModuleUnlock(FunctionLevelConst.CROSS_WAR) and G_Me.crossWarData:canChooseGroup() or G_Me.crossWarData:canChallenge()
		end
	},
	[12] = { 
		-- 限时挑战:通关后消失。
		icon = "ui/play/icon-xianshitiaozhan.png",
		tipIcon = "ui/text/txt/wf_xianshi.png",
		jumpScene = "TimeDungeonMainScene",
		param = {nil, true},
		descId = "LANG_RAPID_BTN_TEXT_LIMIT_CHALLENGE",
		check = function ( ... )
			return false
		end
	},
	[13] = {
		-- 争粮战
		icon = "ui/play/icon-zhengliangtuncao.png",
		tipIcon = "ui/text/txt/wf_xianshi.png",
		jumpScene = "ArenaRobRiceScene",
		param = {},
		descId = "LANG_ROB_RICE_NAME",
		check = function ( ... )
			return G_moduleUnlock:isModuleUnlock(FunctionLevelConst.ROB_RICE) and G_Me.arenaRobRiceData:isRobNowOpen()
		end
	},
	[14] = {
		-- 争粮战奖励
		icon = "ui/play/icon-zhengliangtuncao.png",
		tipIcon = "ui/text/txt/wf_jiangli.png",
		jumpScene = "ArenaRobRiceScene",
		param = {},
		descId = "LANG_ROB_RICE_AWARD",
		check = function ( ... )
			return G_moduleUnlock:isModuleUnlock(FunctionLevelConst.ROB_RICE) and G_Me.arenaRobRiceData:isGetPriceOpen()  and G_Me.arenaRobRiceData:hasRankAwardToRecieve()
		end
	},	 
	[15] = {
		-- 世界Boss有奖励
		icon = "ui/play/icon-panjunBOSS.png",
		tipIcon = "ui/text/txt/wf_jiangli.png",
		jumpScene = "RebelBossMainScene",
		param = {true},
		descId = "LANG_REBEL_BOSS_NAME1",
		check = function ( ... )
			if not G_moduleUnlock:isModuleUnlock(FunctionLevelConst.REBEL_BOSS) then
				return false
			end
			local hasAward = false
			for i=1, 3 do
				if G_Me.moshenData:hasRebelBossAward(i) then
					hasAward = true
					break
				end
			end
			return hasAward
		end
	},	 
	[16] = {
		-- 世界Boss有挑战次数
		icon = "ui/play/icon-panjunBOSS.png",
		tipIcon = "ui/text/txt/wf_xianshi.png",
		jumpScene = "RebelBossMainScene",
		param = {},
		descId = "LANG_REBEL_BOSS_NAME",
		check = function ( ... )
			return G_moduleUnlock:isModuleUnlock(FunctionLevelConst.REBEL_BOSS) and G_Me.moshenData:isOnActivity()
		end
	},	 
	[17] = { 
		-- 争霸赛:当前已开赛，并且有资格还有免费挑战次数尚未使用时显示
		icon = "ui/play/icon-kuafuyanwu.png",
		tipIcon = "ui/text/txt/wf_xianshi.png",
		jumpScene = "CrossWarScene",
		param = {false, false, true, false, false},
		descId = "LANG_CROSS_WAR_MODE_2",
		check = function ( ... )
			return G_moduleUnlock:isModuleUnlock(FunctionLevelConst.CROSS_WAR) and G_Me.crossWarData:checkCanChallengeChampion()
		end
	},
	[18] = { 
		-- 争霸赛:有全服奖励可领
		icon = "ui/play/icon-kuafuyanwu.png",
		tipIcon = "ui/text/txt/wf_jiangli.png",
		jumpScene = "CrossWarScene",
		param = {false, false, false, true, false},
		descId = "LANG_RAPID_BTN_TEXT_SERVER_AWARD",
		check = function ( ... )
			return G_moduleUnlock:isModuleUnlock(FunctionLevelConst.CROSS_WAR) and G_Me.crossWarData:checkCanGetServerAward()
		end
	},
	[19] = { 
		-- 争霸赛:有押注奖励可领
		icon = "ui/play/icon-kuafuyanwu.png",
		tipIcon = "ui/text/txt/wf_jiangli.png",
		jumpScene = "CrossWarScene",
		param = {false, false, false, false, true},
		descId = "LANG_RAPID_BTN_TEXT_BET_AWARD",
		check = function ( ... )
			-- NOTE:现在暂时关闭押注功能
			return false --G_moduleUnlock:isModuleUnlock(FunctionLevelConst.CROSS_WAR) and G_Me.crossWarData:checkCanGetBetAward()
		end
	},
	[20] = { 
		-- 争霸赛:在押注阶段
		icon = "ui/play/icon-yazhu.png",
		tipIcon = "ui/text/txt/wf_xianshi.png",
		jumpScene = "CrossWarScene",
		param = {false, false, false, false, false},
		descId = "LANG_RAPID_BTN_TEXT_BET",
		check = function ( ... )
			-- NOTE:现在暂时关闭押注功能
			return false --G_moduleUnlock:isModuleUnlock(FunctionLevelConst.CROSS_WAR) and G_Me.crossWarData:canBet()
		end
	},

	--百战沙场 临时资源 FIXME
	[21] = { 
		-- 百战沙场 有挑战次数
		icon = "ui/play/icon-baizhanshachang.png",
		--tipIcon = "ui/text/txt/wf_jiangli.png",
		jumpScene = "CrusadeScene",
		param = {},
		descId = "LANG_CRUSADE_LABLE_NAME",
		check = function ( ... )
			return G_moduleUnlock:isModuleUnlock(FunctionLevelConst.CRUSADE) and (G_Me.crusadeData:getLeftChallengeTimes() > 0)
		end
	},
	[22] = { 
		-- 沙场重置:当天有免费重置次数时
		icon = "ui/play/icon-baizhanshachang.png",
		jumpScene = "CrusadeScene",
		param = {},
		descId = "LANG_CRUSADE_RESET_NAME",
		check = function ( ... )
			return G_moduleUnlock:isModuleUnlock(FunctionLevelConst.CRUSADE) and 
				(G_Me.crusadeData:getLeftChallengeTimes() == 0 and G_Me.crusadeData:getFreeResetCount() > 0 and not G_Me.crusadeData:canOpenTreasureFree())
		end
	},
	[23] = { 
		-- 百战沙场奖励
		icon = "ui/play/icon-junkumizang.png",
		tipIcon = "ui/text/txt/wf_jiangli.png",
		jumpScene = "CrusadeScene",
		param = {nil, nil, nil, nil, nil, false, true},
		descId = "LANG_CRUSADE_TREASURE_TITLE",
		check = function ( ... )
			return G_moduleUnlock:isModuleUnlock(FunctionLevelConst.CRUSADE) and G_Me.crusadeData:canOpenTreasureFree()
		end
	},
	[24] = { 
		-- 决战赤壁是否在报名阶段
		icon = "ui/play/icon-juezhanchibi.png",
		tipIcon = "ui/text/txt/wf_xianshi.png",
		jumpScene = "CrossPVPScene",
		param = {},
		descId = "LANG_CROSS_PVP_APPLY_BEGIN_2",
		check = function ( ... )
			return G_moduleUnlock:isModuleUnlock(FunctionLevelConst.CROSS_PVP) and G_Me.crossPVPData:isApplying()
		end
	},
	[25] = { 
		-- 决战赤壁是否在投注阶段
		icon = "ui/play/icon-yazhu.png",
		tipIcon = "ui/text/txt/wf_xianshi.png",
		jumpScene = "CrossPVPScene",
		param = {},
		descId = "LANG_CROSS_PVP_BET_BEGIN",
		check = function ( ... )
			return G_moduleUnlock:isModuleUnlock(FunctionLevelConst.CROSS_PVP) and G_Me.crossPVPData:isBetting()
		end
	},
	[26] = { 
		-- 决战赤壁是否在开战阶段
		icon = "ui/play/icon-juezhanchibi.png",
		tipIcon = "ui/text/txt/wf_huore.png",
		jumpScene = "CrossPVPScene",
		param = {},
		descId = "",
		check = function ( ... )
			return G_moduleUnlock:isModuleUnlock(FunctionLevelConst.CROSS_PVP) and G_Me.crossPVPData:isInBattle()
		end
	},
	[27] = { 
		-- 决战赤壁是否有比赛奖励
		icon = "ui/play/icon-juezhanchibi.png",
		tipIcon = "ui/text/txt/wf_jiangli.png",
		jumpScene = "CrossPVPScene",
		param = {},
		descId = "",
		check = function ( ... )
			return G_moduleUnlock:isModuleUnlock(FunctionLevelConst.CROSS_PVP) and G_Me.crossPVPData:canGetMatchAward()
		end
	},
	[28] = { 
		-- 决战赤壁是否有投注奖励
		icon = "ui/play/icon-juezhanchibi.png",
		tipIcon = "ui/text/txt/wf_jiangli.png",
		jumpScene = "CrossPVPScene",
		param = {},
		descId = "LANG_RAPID_BTN_TEXT_BET_AWARD",
		check = function ( ... )
			return G_moduleUnlock:isModuleUnlock(FunctionLevelConst.CROSS_PVP) and G_Me.crossPVPData:canGetBetAward()
		end
	},
	[29] = { 
		-- 组队pvp 有人邀请时
		icon = "ui/play/icon-haoyouyaoqing.png",
		jumpScene = "DailyPvpMainScene",
		param = {true},
		descId = "LANG_RAPID_BTN_TEXT_FRIEND_INVITE",
		check = function ( ... )
			return G_moduleUnlock:isModuleUnlock(FunctionLevelConst.DAILY_PVP) and G_Me.dailyPvpData:needTips()
		end
	},
	[30] = { 
		-- 组队pvp 有剩余次数
		icon = "ui/play/icon-jizhanhulaoguan.png",
		jumpScene = "DailyPvpMainScene",
		param = {},
		descId = "LANG_RAPID_BTN_TEXT_DAILY_CANFIGHT",
		check = function ( ... )
			return G_moduleUnlock:isModuleUnlock(FunctionLevelConst.DAILY_PVP) and G_Me.dailyPvpData:getAwardCountLeft() > 0
		end
	},
}

function ZhengZhanLayer.create( fightType )
	return ZhengZhanLayer.new("ui_layout/mainscene_zhengzhan.json")
end

function ZhengZhanLayer:ctor( ... )
	self._touchStartY = 0
	self._initTopY = 0
	self._totalMoveDist = 0
	self._clickValid = true
	self._moveEnable = true

	self._rapidList = nil
	self._rapidBtns = {}
	self._shouldStopMove = false

	self._timer = nil -- 这个timer用来更新决战赤壁报名时间

	self._winSize = CCDirector:sharedDirector():getWinSize()
	self.super.ctor(self, ...)

end

function ZhengZhanLayer:onLayerLoad( jsonFile, func, fightType, ... )
    self:registerTouchEvent(false,true,0)

    self:registerBtnClickEvent("Button_arena", handler(self, self._onArenaClick))
    self:registerBtnClickEvent("Button_duobao", handler(self, self._onDuobaoClick))
    self:registerBtnClickEvent("Button_mingjiang", handler(self, self._onChuanguanClick))
    self:registerBtnClickEvent("Button_mosheng", handler(self, self._onMoshengClick))
    self:registerBtnClickEvent("Button_guaji", handler(self, self._onGuajiClick))
    self:registerBtnClickEvent("Button_crosswar", handler(self, self._onCrossWarClick))
    self:registerBtnClickEvent("Button_crusade", handler(self, self._onCrusadeClick))
    self:registerBtnClickEvent("Button_crosspvp", handler(self, self._onCrossPVPClick))
    self:registerBtnClickEvent("Button_dailypvp", handler(self, self._onDailyPVPClick))

    local widget = self:getWidgetByName("Panel_btns")
	self._initTopY = widget:getPosition()
	-- copy from CityScene:onSceneUnload()
    if not G_Me.cityData:isMyCity() then
        G_Me.cityData:resetMyCity()
    end

	local level = G_Me.userData.level 
	self:showWidgetByName("Button_mosheng", 	level >= G_moduleUnlock:getModuleUnlockLevel(FunctionLevelConst.CITY_PLUNDER))
	self:showWidgetByName("Button_guaji", 		level >= G_moduleUnlock:getModuleUnlockLevel(FunctionLevelConst.TOWER_SCENE))
	self:showWidgetByName("Button_crosswar", 	level >= G_moduleUnlock:getModuleUnlockLevel(FunctionLevelConst.MOSHENG_SCENE))
	self:showWidgetByName("Button_dailypvp", 	level >= G_moduleUnlock:getModuleUnlockLevel(FunctionLevelConst.CROSS_WAR))
	self:showWidgetByName("Button_crusade", 	level >= G_moduleUnlock:getModuleUnlockLevel(FunctionLevelConst.DAILY_PVP))
	self:showWidgetByName("Button_crosspvp", 	level >= G_moduleUnlock:getModuleUnlockLevel(FunctionLevelConst.CRUSADE))

	self:_initRapidList()	
end

function ZhengZhanLayer:onLayerEnter( ... )
	self:_initLockStatus()
    self:_initModelDesc()

	G_SoundManager:playBackgroundMusic(require("app.const.SoundConst").BackGroundMusic.MAIN)
	--有宝物可合成,也显示玩法的提示
	self:_showPlayTips()
	self:_showMoshenTips()
	self:_showCrusadeTip(false)

	uf_eventManager:addEventListener(G_EVENTMSGID.EVNET_BAG_HAS_CHANGED, self._showPlayTips, self)

    self:callAfterFrameCount(1, function ( ... )
    	if not self then 
    		return 
    	end

		self:_moveCloud()

		G_GlobalFunc.flyIntoScreenLR({self:getWidgetByName("Button_arena"), 
			self:getWidgetByName("Button_mingjiang"), 
			self:getWidgetByName("Button_mosheng")}, true, 0.2, 2, 50, nil)
    	G_GlobalFunc.flyIntoScreenLR({self:getWidgetByName("Button_duobao"), 
    		self:getWidgetByName("Button_guaji")}, false, 0.2, 2, 50, nil)
	end)

    -- 发送获取竞技场信息，以初始化其奖励相关数据
    local arenaUnlockFlag = G_moduleUnlock:isModuleUnlock(FunctionLevelConst.ARENA_SCENE)
    if not (G_GuideMgr and G_GuideMgr:isCurrentGuiding() ) and arenaUnlockFlag and (not G_Me.shopData:checkAwardTipsByType(SCORE_TYPE.JING_JI_CHANG)) then
    	uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_ARENA_LIST, self._onArenaTipsInfo, self)
		G_HandlersManager.arenaHandler:sendGetArenaInfo()
	end

	-- 发送获取粮草信息，以初始化奖励相关数据
	if G_moduleUnlock:isModuleUnlock(FunctionLevelConst.ROB_RICE) and G_Me.arenaRobRiceData:isGetPriceOpen() and (not G_Me.arenaRobRiceData:hasRankAwardToRecieve()) then
		uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_ROB_RICT_NOT_ATTENT, self._onRiceInfo, self)
		uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_ROB_RICE_UPDATE_USER_RICE, self._onRiceInfo, self)		
		G_HandlersManager.arenaHandler:sendGetUserRice()
	end

	-- 获取跨服战状态
	if G_moduleUnlock:isModuleUnlock(FunctionLevelConst.CROSS_WAR) then
		uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_CROSS_WAR_GET_BATTLE_INFO, self._onCrossWarInfo, self)
		G_HandlersManager.crossWarHandler:sendGetBattleInfo()
	end

	
	-- 获取世界Boss信息
    unlockFlag = G_moduleUnlock:isModuleUnlock(FunctionLevelConst.REBEL_BOSS)
    if unlockFlag then
    	uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_REBEL_BOSS_SHOW_QUICK_ENTER, self._onRebelBossQuickEnter, self)
        G_HandlersManager.moshenHandler:sendEnterRebelBossUI()
        G_HandlersManager.moshenHandler:sendRebelBossAwardInfo(1)
        G_HandlersManager.moshenHandler:sendRebelBossAwardInfo(2)
        G_HandlersManager.moshenHandler:sendRebelBossCorpAwardInfo()
    end

    -- 获取百战沙场数据
    local unlockFlag = G_moduleUnlock:isModuleUnlock(FunctionLevelConst.CRUSADE)
    if unlockFlag then
		uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_CRUSADE_UPDATE_BATTLEFIELD_INFO, self._onGetCrusadeInfo, self)
		uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_CRUSADE_UPDATE_AWARD_INFO, self._onGetCrusadeAwardInfo, self)
	    G_HandlersManager.crusadeHandler:sendGetBattleFieldInfo(CrusadeCommon.GET_BF_TYPE_INIT)
	    
	end

	-- 启动决战赤壁逻辑
	if G_moduleUnlock:isModuleUnlock(FunctionLevelConst.CROSS_PVP) then
		require("app.scenes.crosspvp.CrossPVP").launchWithoutScene(self)
	end

	self:_showDailyPvpTips()
end

function ZhengZhanLayer:onLayerExit()
	if self._timer then
		G_GlobalFunc.removeTimer(self._timer)
		self._timer = nil
	end
end

function ZhengZhanLayer:onLayerUnload()
	-- 退出决战赤壁逻辑
	require("app.scenes.crosspvp.CrossPVP").exit()
end

function ZhengZhanLayer:_initRapidList( ... )
	if G_GuideMgr and G_GuideMgr:isCurrentGuiding() then 
		return 
	end

	local isFirstCreate = (self._rapidList == nil)
	if not self._rapidList then 
		local panel = self:getPanelByName("Panel_rapid_list")
		if panel == nil then
			return 
		end

		self._rapidList = CCSListViewEx:createWithPanel(panel, LISTVIEW_DIR_HORIZONTAL)
    	self._rapidList:setCreateCellHandler(function ( list, index)
    	    return require("app.scenes.mainscene.RapidBtnCell").new(list, index)
    	end)
    	self._rapidList:setUpdateCellHandler(function ( list, index, cell)
    		if cell then 
    			cell:updateItem(self._rapidBtns[index + 1])
    		end
    	end)
	end
	
	self._rapidBtns = {}
	for key, value in ipairs(ZhengZhanLayer.RAPID_BTNS) do
		if value.check and value.check() then 
			table.insert(self._rapidBtns, #self._rapidBtns + 1, value)
		end
	end

    self._rapidList:reloadWithLength(#self._rapidBtns)
    self._rapidList:setVisible(#self._rapidBtns > 0)

    local isNewEmpty = (#self._rapidBtns == 0)

    if isNewEmpty then 
    	self:_resetInitOffset(100)
    else
    	self:_resetInitOffset(-100)
    end
end

function ZhengZhanLayer:_onArenaTipsInfo( ... )
	if G_Me.shopData:checkAwardTipsByType(SCORE_TYPE.JING_JI_CHANG) then
    	self:_initRapidList()
    	-- 竞技场入口红点
    	self:showWidgetByName("Image_Arena_Tips", G_Me.shopData:checkAwardTipsByType(SCORE_TYPE.JING_JI_CHANG))
	end
end

function ZhengZhanLayer:_onRiceInfo( ... )
	if G_Me.arenaRobRiceData:hasRankAwardToRecieve() then
		self:_initRapidList()
	end
end

function ZhengZhanLayer:_onCrossWarInfo()
	if G_moduleUnlock:isModuleUnlock(FunctionLevelConst.CROSS_WAR) then
		if G_Me.crossWarData:isInChampionship() then
			if G_Me.crossWarData:isChampionshipEnabled() then
				uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_CROSS_WAR_GET_ARENA_INFO, self._onChampionshipInfo, self)
				G_HandlersManager.crossWarHandler:sendGetChampionshipInfo()
			end

		elseif G_Me.crossWarData:isChampionshipEnd() then
			if G_Me.crossWarData:isChampionshipEnabled() then
				-- NOTE:现在暂时关闭押注功能
				uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_CROSS_WAR_GET_TOP_RANKS, self._onChampionshipInfo, self)
				--uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_CROSS_WAR_GET_BET_AWARD, self._onChampionshipInfo, self)
				uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_CROSS_WAR_GET_SERVER_AWARD_INFO, self._onChampionshipInfo, self)

				--G_HandlersManager.crossWarHandler:sendGetBetAward()
				G_HandlersManager.crossWarHandler:sendGetServerAwardInfo()
				G_HandlersManager.crossWarHandler:sendGetTopRanks()
			end
		else
			self:_initRapidList()
			self:_showCrossWarTips()
    	end
	end
end


function ZhengZhanLayer:_showCrusadeTip( visible )
	self:showWidgetByName("Image_tips_crusade",visible)
end

function ZhengZhanLayer:_onGetCrusadeInfo( ... )

	if G_moduleUnlock:isModuleUnlock(FunctionLevelConst.CRUSADE) then

		if G_Me.crusadeData:hasPassStage() then
	    	G_HandlersManager.crusadeHandler:sendGetAwardInfo()
	    end

    	self:_showCrusadeTip(G_Me.crusadeData:showMainEntryTip())
		self:_initRapidList()
		
	else
    	self:_showCrusadeTip(false)
	end
end

function ZhengZhanLayer:_onGetCrusadeAwardInfo( ... )
   
    self:_showCrusadeTip(G_Me.crusadeData:showMainEntryTip())
	self:_initRapidList()
	
end

function ZhengZhanLayer:_onChampionshipInfo(param)
	if G_moduleUnlock:isModuleUnlock(FunctionLevelConst.CROSS_WAR) then
		local data = G_Me.crossWarData
		local ready = false

		if data:isInChampionship() then
			if param == true then
				ready = true
			end
		elseif data:isChampionshipEnd() then
			-- NOTE:现在暂时关闭押注功能
			if data:hasFinalTopRanks() and --[[data:hasPulledBetAward() and]] data:hasPulledServerAward() then
				ready = true
			end
		end

		if ready then
			self:_initRapidList()
			self:_showCrossWarTips()
		end
	end
end

-- @desc 夺宝合成提示
function ZhengZhanLayer:_showPlayTips()
    --先检查夺宝等级
    local FunctionLevelConst = require("app.const.FunctionLevelConst")
    local CheckFunc = require("app.scenes.common.CheckFunc")
    if G_moduleUnlock:isModuleUnlock(FunctionLevelConst.TREASURE_COMPOSE) == true then
        local visible = CheckFunc.checkTreasureComposeEnabled()
        self:showWidgetByName("Image_duobaoTips",visible)
    else
    	self:showWidgetByName("Image_duobaoTips",false)
    end
    
    -- 竞技场入口红点
    self:showWidgetByName("Image_Arena_Tips", G_moduleUnlock:isModuleUnlock(FunctionLevelConst.ARENA_SCENE) and G_Me.shopData:checkAwardTipsByType(SCORE_TYPE.JING_JI_CHANG))
            
    -- 挂机，检查是否有符合要求的情况，决定是否冒红点
    self:showWidgetByName("Image_guajiTips", G_Me.cityData:needPatrol() or G_Me.cityData:needHarvest())
    
    self:showWidgetByName("Image_wushTips", G_moduleUnlock:isModuleUnlock(FunctionLevelConst.TOWER_SCENE) and G_Me.wushData:showTips())
end

function ZhengZhanLayer:_showMoshenTips()
	-- 叛军
	-- 世界Boss
	local FunctionLevelConst = require("app.const.FunctionLevelConst")
    if not G_moduleUnlock:isModuleUnlock(FunctionLevelConst.REBEL_BOSS) then
        self:showWidgetByName("Image_MoshenTip", false)
    else
        local hasAward = false
        local hasChallengeTime = false
        for i=1, 3 do
            if G_Me.moshenData:hasRebelBossAward(i) then
                hasAward = true
                break
            end
        end
        if G_Me.moshenData:hasRebelBossChallengeTime() then
            hasChallengeTime = true
        end
        if hasAward or hasChallengeTime then
            self:showWidgetByName("Image_MoshenTip", true)
        else
            self:showWidgetByName("Image_MoshenTip", false)
        end
    end
end

function ZhengZhanLayer:_showCrossWarTips()
	local isModuleUnlock =  G_moduleUnlock:isModuleUnlock(FunctionLevelConst.CROSS_WAR)
	local data = G_Me.crossWarData

	if isModuleUnlock then
		-- 积分赛，如果有连胜奖励可领，或者还有免费挑战次数，就显示红点
    	local needShow = data:checkCanGetAward() or data:canChooseGroup() or data:canChallenge()

    	-- 如果有必要，再检查一下争霸赛的红点提示
    	if not needShow then
    		if data:isInChampionship() then
    			needShow = data:checkCanChallengeChampion()
    		elseif data:isChampionshipEnd() then
    			needShow = data:checkCanGetBetAward() or data:checkCanGetServerAward()
    		end
    	end

    	self:showWidgetByName("Image_tips_cross", needShow)
    else
    	self:showWidgetByName("Image_tips_cross", false)
    end
end

-- 这个接口会由CrossPVP来决定何时调用，不要在这里调用
function ZhengZhanLayer:updateCrossPVPTips()
	-- 决战赤壁有一些快捷按钮，需要根据不同的赛程显示不同的文字（海选，复赛。。等等）
	if G_Me.crossPVPData:isInBattle() then
		local course = G_Me.crossPVPData:getCourse()
		local courseName = require("app.scenes.crosspvp.CrossPVPCommon").getCourseDesc(course, true)
		ZhengZhanLayer.RAPID_BTNS[26].descId = courseName
	end

	if G_Me.crossPVPData:canGetMatchAward() then
		local isPromoted = G_Me.crossPVPData:isApplied()
		ZhengZhanLayer.RAPID_BTNS[27].descId = G_lang:get(isPromoted and "LANG_CROSS_PVP_PROMOTED_AWARD" or "LANG_CROSS_PVP_JOIN_AWARD")
	end
	self:_initRapidList()
end

function ZhengZhanLayer:_showDailyPvpTips()
	self:showWidgetByName("Image_tips_dailypvp", G_Me.dailyPvpData:needTips() or  G_Me.dailyPvpData:getAwardCountLeft() > 0 or G_Me.shopData:checkAwardTipsByType(SCORE_TYPE.DAILY_PVP))
end

-- 这个接口会由CrossPVP来决定何时调用，不要在这里调用
function ZhengZhanLayer:createCrossPVPApplyTimer()
	if not self._timer then
		self:showWidgetByName("Panel_apply_time", true)
		self:showTextWithLabel("Label_apply_desc", G_lang:get("LANG_CROSS_PVP_APPLY_BEGIN_3"))
		self:enableLabelStroke("Label_apply_time", Colors.strokeBrown, 1)
		self:enableLabelStroke("Label_apply_desc", Colors.strokeBrown, 1)

		self._timer = G_GlobalFunc.addTimer(1, handler(self, self._updateCrossPVPApplyTime))

		self:_updateCrossPVPApplyTime()
	end
end

function ZhengZhanLayer:_updateCrossPVPApplyTime()
	local leftTime = CrossPVPCommon.getLeftApplyTime()
	if leftTime then
		self:showTextWithLabel("Label_apply_time", leftTime)
		G_GlobalFunc.centerContent(self:getPanelByName("Panel_apply_time"))
	else
		self:showWidgetByName("Panel_apply_time", false)
		G_GlobalFunc.removeTimer(self._timer)
		self._timer = nil
	end
end

function ZhengZhanLayer:_onRebelBossQuickEnter()
	self:_initRapidList()
	self:_showMoshenTips()
end

function ZhengZhanLayer:__prepareDataForGuide__( prepareModuleId )
	if not prepareModuleId then 
		return 
	end

	self._moveEnable = false
	if prepareModuleId > 2 then 
		self:_scrollWithOffset(300)
	end
end

function ZhengZhanLayer:_moveCloud( ... )
	if not require("app.scenes.mainscene.SettingLayer").showEffectEnable() then 
		self:showWidgetByName("Panel_cloud", false)
		self:showWidgetByName("Image_cloud", false)
		self:showWidgetByName("Image_cloud_copy", false)
		return 
	end
	
	local panel = self:getWidgetByName("Panel_cloud")
	local cloud1 = self:getWidgetByName("Image_cloud")
	local cloud2 = self:getWidgetByName("Image_cloud_copy")
	if not panel or not cloud1 or not cloud2 then 
		return 
	end

	local size = cloud1:getSize()
	local pos2_x, pos2_y = cloud2:getPosition()

	

	cloud1:runAction(CCSequence:createWithTwoActions(
		CCMoveBy:create(size.height/8, ccp(0, size.height)),
		CCCallFunc:create(function (  )
        cloud1:setPosition(ccp(pos2_x, pos2_y))

        local repeatAction = CCRepeatForever:create(CCSequence:createWithTwoActions(
			CCMoveBy:create(size.height/4, ccp(0, size.height*2)),
			CCCallFunc:create(function (  )
        	cloud1:setPosition(ccp(pos2_x, pos2_y))
    	end)))

        cloud1:runAction(repeatAction)
    end)))

    cloud2:runAction(CCRepeatForever:create(CCSequence:createWithTwoActions(
		CCMoveBy:create(size.height/4, ccp(0, size.height*2)),
		CCCallFunc:create(function (  )
        cloud2:setPosition(ccp(pos2_x, pos2_y))
    end))))


	--panel:runAction(CCRepeatForever:create(CCSequence:create(arr)))
end

function ZhengZhanLayer:_initModelDesc( ... )
	local showDesc = function ( panelName, descName )
		if type(panelName) ~= "string" or type(descName) ~= "string" then 
			return 
		end

		local panel = self:getWidgetByName(panelName)
		if not panel then 
			return 
		end

		local richText = GlobalFunc.createGameRichtext(G_lang:get(descName), 30, Colors.darkColors.DESCRIPTION, Colors.strokeBrown)
		if richText then 
			local textSize = richText:getSize()
			panel:addChild(richText)
			--richText:setClippingEnabled(false)
			richText:setPosition(ccp(textSize.width/2, textSize.height/2))
		else 
			__LogError("create rich text failed!")
		end
	end

	showDesc("Panel_desc_arena", "LANG_PLAY_ARENA_DESC")
	showDesc("Panel_desc_duobao", "LANG_PLAY_PLUNDER_DESC")
	showDesc("Panel_desc_mingjiang", "LANG_PLAY_MISSION_DESC")
	showDesc("Panel_desc_mosheng", "LANG_PLAY_REBELAMRY_DESC")
	showDesc("Panel_desc_guaji", "LANG_PLAY_CITY_DESC")
	showDesc("Panel_desc_cross", "LANG_PLAY_CROSSSERVERWAR_DESC")
	showDesc("Panel_desc_crusade", "LANG_PLAY_CRUSADE_DESC")
	showDesc("Panel_desc_crosspvp", "LANG_PLAY_CROSS_PVP_DESC")
	showDesc("Panel_desc_dailypvp", "LANG_PLAY_DAILY_PVP_DESC")
end

function ZhengZhanLayer:_initLockStatus( ... )
	self:enableLabelStroke("Label_arena", Colors.strokeBrown, 1 )
    self:enableLabelStroke("Label_duobao", Colors.strokeBrown, 1 )
    self:enableLabelStroke("Label_mingjiang", Colors.strokeBrown, 1 )
    self:enableLabelStroke("Label_mosheng", Colors.strokeBrown, 1 )
    self:enableLabelStroke("Label_guaji", Colors.strokeBrown, 1 )
    self:enableLabelStroke("Label_cross", Colors.strokeBrown, 1 )
    self:enableLabelStroke("Label_challenge", Colors.strokeBrown, 1 )
    self:enableLabelStroke("Label_crusade", Colors.strokeBrown, 1 )
    self:enableLabelStroke("Label_crosspvp", Colors.strokeBrown, 1 )
    self:enableLabelStroke("Label_dailypvp", Colors.strokeBrown, 1 )

    local unGrayCtrl = function ( ctrlName )
    	if type(ctrlName) ~= "string" then 
    		return 
    	end

    	local ctrl = self:getWidgetByName(ctrlName)
    	if ctrl then 
    		ctrl:setCascadeColorEnabled(false)
    	end
    end

    local unlockFlag = G_moduleUnlock:isModuleUnlock(FunctionLevelConst.ARENA_SCENE)
    self:showWidgetByName("Image_lock_arena", not unlockFlag)
    if not unlockFlag then 
    	unGrayCtrl("Image_lock_arena")
    	--unGrayCtrl("Image_7")
    	self:showTextWithLabel("Label_arena", 
    		G_lang:get("LANG_PLAY_OPENLEVEL")..G_moduleUnlock:getModuleUnlockLevel(FunctionLevelConst.ARENA_SCENE))
    	local btn = self:getButtonByName("Button_arena")
    	if btn then 
    		GlobalFunc.setDark(btn, true)
    		--btn:loadTextureNormal("ui/play/arena_unable.png")
    	end
    end

    unlockFlag = G_moduleUnlock:isModuleUnlock(FunctionLevelConst.TREASURE_COMPOSE)
    self:showWidgetByName("Image_lock_duobao", not unlockFlag)
    if not unlockFlag then 
    	unGrayCtrl("Image_lock_duobao")
    	--unGrayCtrl("Image_8")
    	self:showTextWithLabel("Label_duobao", 
    		G_lang:get("LANG_PLAY_OPENLEVEL")..G_moduleUnlock:getModuleUnlockLevel(FunctionLevelConst.TREASURE_COMPOSE))
    	local btn = self:getButtonByName("Button_duobao")
    	if btn then 
    		GlobalFunc.setDark(btn, true)
    		--btn:loadTextureNormal("ui/play/duobao1_unable.png")
    	end
    end

    unlockFlag = G_moduleUnlock:isModuleUnlock(FunctionLevelConst.TOWER_SCENE)
    self:showWidgetByName("Image_lock_mingjiang", not unlockFlag)
    if not unlockFlag then 
    	unGrayCtrl("Image_lock_mingjiang")
    	--unGrayCtrl("Image_9")
    	self:showTextWithLabel("Label_mingjiang", 
    		G_lang:get("LANG_PLAY_OPENLEVEL")..G_moduleUnlock:getModuleUnlockLevel(FunctionLevelConst.TOWER_SCENE))
    	local btn = self:getButtonByName("Button_mingjiang")
    	if btn then 
    		GlobalFunc.setDark(btn, true)
    		--btn:loadTextureNormal("ui/play/mingjiang_unable.png")
    	end
    end

    unlockFlag = G_moduleUnlock:isModuleUnlock(FunctionLevelConst.CITY_PLUNDER)
    self:showWidgetByName("Image_lock_guaji", not unlockFlag)
    if not unlockFlag then 
    	unGrayCtrl("Image_lock_guaji")
    	--unGrayCtrl("Image_9")
    	self:showTextWithLabel("Label_guaji", 
    		G_lang:get("LANG_PLAY_OPENLEVEL")..G_moduleUnlock:getModuleUnlockLevel(FunctionLevelConst.CITY_PLUNDER))
    	local btn = self:getButtonByName("Button_guaji")
    	if btn then 
    		GlobalFunc.setDark(btn, true)
    		--btn:loadTextureNormal("ui/play/mingjiang_unable.png")
    	end
    end

    unlockFlag = G_moduleUnlock:isModuleUnlock(FunctionLevelConst.MOSHENG_SCENE)
    self:showWidgetByName("Image_lock_mosheng", not unlockFlag)
    if not unlockFlag then 
    	unGrayCtrl("Image_lock_mosheng")
    	--unGrayCtrl("Image_10")
    	self:showTextWithLabel("Label_mosheng", 
    		G_lang:get("LANG_PLAY_OPENLEVEL")..G_moduleUnlock:getModuleUnlockLevel(FunctionLevelConst.MOSHENG_SCENE))
    	local btn = self:getButtonByName("Button_mosheng")
    	if btn then 
    		GlobalFunc.setDark(btn, true)
    		--btn:loadTextureNormal("ui/play/mosheng_unable.png")
    	end
    end

    unlockFlag = G_moduleUnlock:isModuleUnlock(FunctionLevelConst.CROSS_WAR)
    self:showWidgetByName("Image_lock_cross", not unlockFlag)
    if not unlockFlag then
    	unGrayCtrl("Image_lock_cross")
    	self:showTextWithLabel("Label_cross",
    		G_lang:get("LANG_PLAY_OPENLEVEL")..G_moduleUnlock:getModuleUnlockLevel(FunctionLevelConst.CROSS_WAR))
    		local btn = self:getButtonByName("Button_crosswar")
    		if btn then
    			GlobalFunc.setDark(btn, true)
    		end
    end

    --百战沙场
    unlockFlag = G_moduleUnlock:isModuleUnlock(FunctionLevelConst.CRUSADE)
    self:showWidgetByName("Image_lock_crusade", not unlockFlag)
    if not unlockFlag then
    	unGrayCtrl("Image_lock_crusade")
    	self:showTextWithLabel("Label_crusade",
    		G_lang:get("LANG_PLAY_OPENLEVEL")..G_moduleUnlock:getModuleUnlockLevel(FunctionLevelConst.CRUSADE))
    		local btn = self:getButtonByName("Button_crusade")
    		if btn then
    			GlobalFunc.setDark(btn, true)
    		end
    end

    -- 跨服夺帅
    unlockFlag = G_moduleUnlock:isModuleUnlock(FunctionLevelConst.CROSS_PVP)
    self:showWidgetByName("Image_lock_crosspvp", not unlockFlag)
    if not unlockFlag then
    	unGrayCtrl("Image_lock_crosspvp")
    	self:showTextWithLabel("Label_crosspvp",
    		G_lang:get("LANG_PLAY_OPENLEVEL")..G_moduleUnlock:getModuleUnlockLevel(FunctionLevelConst.CROSS_PVP))
    		local btn = self:getButtonByName("Button_crosspvp")
    		if btn then
    			GlobalFunc.setDark(btn, true)
    		end
    end

    --组队pvp
    unlockFlag = G_moduleUnlock:isModuleUnlock(FunctionLevelConst.DAILY_PVP)
    self:showWidgetByName("Image_lock_dailypvp", not unlockFlag)
    if not unlockFlag then
    	unGrayCtrl("Image_lock_dailypvp")
    	self:showTextWithLabel("Label_dailypvp",
    		G_lang:get("LANG_PLAY_OPENLEVEL")..G_moduleUnlock:getModuleUnlockLevel(FunctionLevelConst.DAILY_PVP))
    		local btn = self:getButtonByName("Button_dailypvp")
    		if btn then
    			GlobalFunc.setDark(btn, true)
    		end
    end
end

function ZhengZhanLayer:_onArenaClick( ... )
	if not self._clickValid then 
		return 
	end

	if G_moduleUnlock:checkModuleUnlockStatus(FunctionLevelConst.ARENA_SCENE) then
        uf_sceneManager:replaceScene(require("app.scenes.arena.ArenaScene").new()) 
    end
end

function ZhengZhanLayer:_onDuobaoClick( ... )
	if not self._clickValid then 
		return 
	end
	if G_moduleUnlock:checkModuleUnlockStatus(FunctionLevelConst.TREASURE_COMPOSE) == true then
        uf_sceneManager:replaceScene(require("app.scenes.treasure.TreasureComposeScene").new(nil,nil,nil,nil, 
        	GlobalFunc.sceneToPack("app.scenes.mainscene.PlayingScene",{})))
    end
end

function ZhengZhanLayer:_onChuanguanClick( ... )
	if not self._clickValid then 
		return 
	end

    if G_moduleUnlock:checkModuleUnlockStatus(FunctionLevelConst.TOWER_SCENE) then
        -- uf_sceneManager:replaceScene(require("app.scenes.tower.TowerScene").new())
        uf_sceneManager:replaceScene(require("app.scenes.wush.WushScene").new())
    end
end

function ZhengZhanLayer:_onMoshengClick( ... )
	if not self._clickValid then 
		return 
	end

	if G_moduleUnlock:checkModuleUnlockStatus(FunctionLevelConst.MOSHENG_SCENE) then 
		uf_sceneManager:replaceScene(require("app.scenes.moshen.MoShenScene").new())
    end    
end

function ZhengZhanLayer:_onGuajiClick( ... )
	if not self._clickValid then 
		return 
	end

	if G_moduleUnlock:checkModuleUnlockStatus(FunctionLevelConst.CITY_PLUNDER) then 
            G_Loading:showLoading(function()
                uf_sceneManager:replaceScene(require("app.scenes.city.CityScene").new())
            end)
        end        
end

function ZhengZhanLayer:_onCrossWarClick(...)
	if not self._clickValid then 
		return 
	end

	if G_moduleUnlock:checkModuleUnlockStatus(FunctionLevelConst.CROSS_WAR) then 
            G_Loading:showLoading(function()
                uf_sceneManager:replaceScene(require("app.scenes.crosswar.CrossWarScene").new())
            end)
        end  
end

function ZhengZhanLayer:_onCrossPVPClick()
	if not self._clickValid then
		return
	end
	
	if G_moduleUnlock:checkModuleUnlockStatus(FunctionLevelConst.CROSS_PVP) then 
        require("app.scenes.crosspvp.CrossPVP").launch()
    end
end

function ZhengZhanLayer:_onCrusadeClick(...)
	if not self._clickValid then 
		return 
	end

	if G_moduleUnlock:checkModuleUnlockStatus(FunctionLevelConst.CRUSADE) then 
            G_Loading:showLoading(function()
                uf_sceneManager:replaceScene(require("app.scenes.crusade.CrusadeScene").new())
            end)
        end  
end


function ZhengZhanLayer:_onDailyPVPClick()
	if not self._clickValid then
		return
	end
	
	if G_moduleUnlock:checkModuleUnlockStatus(FunctionLevelConst.DAILY_PVP) then 
        		uf_sceneManager:replaceScene(require("app.scenes.dailypvp.DailyPvpMainScene").new())
    	end
end

function ZhengZhanLayer:onTouchBegin( xpos, ypos )
	self._touchStartY = ypos
	self._clickValid = true
	self._totalMoveDist = 0

	if self._rapidList and self._rapidList:getDataLength() > 0 then 
		local x, y = self._rapidList:convertToNodeSpaceXY(xpos, ypos)
		if x < 0 or y < 0 then 
			self._shouldStopMove = false
		else
			self._shouldStopMove = true
		end
	else
		self._shouldStopMove = false
	end

	return true
end

function ZhengZhanLayer:onTouchMove( xpos, ypos )
	if not self._moveEnable or self._shouldStopMove then 
		return 
	end

	local moveOffset = ypos - self._touchStartY
	self:_scrollWithOffset(moveOffset)
	self._touchStartY = ypos

	if self._clickValid then
		self._totalMoveDist = self._totalMoveDist + moveOffset
		if math.abs(self._totalMoveDist) >= 10 then 
			self._clickValid = false
		end
	end
end

function ZhengZhanLayer:_getBottomButton( ... )
	local widgetName = "Button_crusade"
	local level = G_Me.userData.level 
	if level < G_moduleUnlock:getModuleUnlockLevel(FunctionLevelConst.TOWER_SCENE) then
		widgetName = "Button_mingjiang"
	elseif level < G_moduleUnlock:getModuleUnlockLevel(FunctionLevelConst.CITY_PLUNDER) then
		widgetName = "Button_guaji"
	elseif level < G_moduleUnlock:getModuleUnlockLevel(FunctionLevelConst.MOSHENG_SCENE) then
		widgetName = "Button_mosheng"
	elseif level < G_moduleUnlock:getModuleUnlockLevel(FunctionLevelConst.CROSS_WAR) then
		widgetName = "Button_crosswar"
	elseif level < G_moduleUnlock:getModuleUnlockLevel(FunctionLevelConst.DAILY_PVP) then
		widgetName = "Button_dailypvp"
	elseif level < G_moduleUnlock:getModuleUnlockLevel(FunctionLevelConst.CRUSADE) then
		widgetName = "Button_crusade"
	elseif level < G_moduleUnlock:getModuleUnlockLevel(FunctionLevelConst.CROSS_PVP) then
		widgetName = "Button_crosspvp"
	else 
		widgetName = "Button_crosspvp"
	end

	return self:getWidgetByName(widgetName)
end

function ZhengZhanLayer:_scrollWithOffset( offset )
	local bottomWidget = self:_getBottomButton()
	offset = offset or 0
	local maxOffset = (type(self._rapidBtns) == "table" and #self._rapidBtns > 0) and 200 or 100
	local effectMoveOffset = function ( offset )
		local btnPanel = self:getWidgetByName("Panel_btns")
		local posx, posy = btnPanel:getPosition()
		if posy <= 0 then 
			if offset < 0 then
				local topWidget = self:getWidgetByName("Button_arena")
				if topWidget then 
					local posx, posy = topWidget:convertToWorldSpaceXY(0, 0)
					local size = topWidget:getSize()
					local widgetTop = posy + size.height/2
					if widgetTop + offset < self._winSize.height - maxOffset then 
						offset = self._winSize.height - maxOffset - widgetTop
					end
				end
				return offset
			else
				if bottomWidget then 
					local posx, posy = bottomWidget:convertToWorldSpaceXY(0, 0)
					local size = bottomWidget:getSize()
					local widgetBottom = posy - size.height/2
					if widgetBottom + offset > 150 then 
						offset = 150 - widgetBottom
					end
				end
				return offset
			end
		elseif offset + posy <= -100 then 
			return -100 -posy
		else
			if bottomWidget then 
				local posx, posy = bottomWidget:convertToWorldSpaceXY(0, 0)
				local size = bottomWidget:getSize()
				local widgetBottom = posy - size.height/2

				if widgetBottom + offset > 150 then 
					offset = 150 - widgetBottom
				end
			end
			return offset
		end
	end

	local effectOffset = effectMoveOffset(offset)

	if effectOffset ~= 0 then
		self:_doScrollWithOffset("Panel_btns", effectOffset)
		self:_doScrollWithOffset("Panel_cloud", effectOffset/2)
		self:_doScrollWithOffset("Panel_back", effectOffset/5)
	end
end

function ZhengZhanLayer:_doScrollWithOffset( name, offset, animation )
	if type(name) ~= "string" or not offset or offset == 0 then 
		return 
	end

	animation = animation or false
	local widget = self:getWidgetByName(name)
	if not widget then 
		return 
	end

	local posx, posy = widget:getPosition()
	widget:setPosition(ccp(posx, posy + offset))
end

function ZhengZhanLayer:_resetInitOffset( offset )
	if type(offset) ~= "number" or offset == 0 then 
		return 
	end

	local widget = self:getWidgetByName("Panel_btns")
	if widget then 
		local x, y = widget:getPosition()
		widget:setPositionXY(x, self._initTopY + offset)
	end
	widget = self:getWidgetByName("Panel_cloud")
	if widget then 
		local x, y = widget:getPosition()
		widget:setPositionXY(x, self._initTopY + offset/2)
	end
	widget = self:getWidgetByName("Panel_back")
	if widget then 
		local x, y = widget:getPosition()
		widget:setPositionXY(x, self._initTopY + offset/4)
	end
end

return ZhengZhanLayer
