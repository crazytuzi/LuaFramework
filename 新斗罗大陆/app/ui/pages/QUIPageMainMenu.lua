
local QUIPage = import(".QUIPage")
local QUIPageMainMenu = class("QUIPageMainMenu", QUIPage)

local QNotificationCenter = import("...controllers.QNotificationCenter")
local QUIViewController = import("..QUIViewController")
local QRemote = import("...models.QRemote")
local QUIWidgetHead = import("..widgets.QUIWidgetHead")
local QUIWidgetTopStatusShow = import("..widgets.QUIWidgetTopStatusShow")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QUIWidgetScaling = import("..widgets.QUIWidgetScaling")
local QUIDialogMail = import("..dialogs.QUIDialogMail")
local QUIDialogStore = import("..dialogs.QUIDialogStore")
local QTutorialDirector = import("...tutorial.QTutorialDirector")
local QNavigationController = import("...controllers.QNavigationController")
local QTips = import("...utils.QTips")
local QShop = import("...utils.QShop")
local QUserProp = import("...utils.QUserProp")
local QSkeletonViewController = import("...controllers.QSkeletonViewController")
local QUIGestureRecognizer = import("..QUIGestureRecognizer")
local QTutorialDefeatedGuide = import("...tutorial.defeated.QTutorialDefeatedGuide")
local QVIPUtil = import("...utils.QVIPUtil")
local QUIWidgetChat = import("..widgets.QUIWidgetChat")
local QChatData = import("...models.chatdata.QChatData")
local QBulletinData = import("...models.chatdata.QBulletinData")
local QUIDialogHeroReborn = import("..dialogs.QUIDialogHeroReborn")
local QUIWidgetSystemNotice = import("..widgets.QUIWidgetSystemNotice")
local QUIDialogInvasion = import("..dialogs.QUIDialogInvasion")
local QUIWidgetTopBar = import("..widgets.QUIWidgetTopBar")
local QUIDialogTimeMachine = import("..dialogs.QUIDialogTimeMachine")
local QUIWidgetMainPageAvatar = import("..widgets.QUIWidgetMainPageAvatar")
local QUIDialogVIPRecharge = import("..dialogs.QUIDialogVIPRecharge")
local QUIWidgetTutorialHandTouch = import("...ui.widgets.QUIWidgetTutorialHandTouch")
local QUIWidgetAnimationPlayer = import("...ui.widgets.QUIWidgetAnimationPlayer")
local QUIWidgetNormalTheme = import("...ui.widgets.QUIWidgetNormalTheme")
local QUIWidgetActivityTheme = import("...ui.widgets.QUIWidgetActivityTheme")
local QUIWidgetMainMenuTouchMoveController = import("..widgets.mainPage.QUIWidgetMainMenuTouchMoveController")
local QUIWidgetMainMenuLightController = import("..widgets.mainPage.QUIWidgetMainMenuLightController")
local QUIWidgetHeroInformation = import("..widgets.QUIWidgetHeroInformation")
local QChatDialog = import("...utils.QChatDialog")

local QUIDialogHelp = import("..dialogs.QUIDialogHelp")
local QUIDialogVip = import("..dialogs.QUIDialogVip")

local QReplayUtil = import("...utils.QReplayUtil")
local QPageMainMenuUtil = import("...utils.QPageMainMenuUtil")
local QPageMainMenuIcon = import("...utils.QPageMainMenuIcon")


local unlockVisibleLevelGap = 5
local unlockTable = {
    sunwell = {config = "UNLOCK_SUNWELL", button = "btn_sunwell", animations = {sunwell_animation1 = "light"}, enable = "sunwell_enable", disable = "sunwell_disable", effectNodes = {"node_sunwell_effect"}},
    metalcity = {config = "UNLOCK_METALCITY", button = "btn_metalcity", animations = {}, enable = "metalcity_enable", disable = "metalcity_disable"},
    arena = {config = "UNLOCK_ARENA", button = "btn_arena", animations = {}, enable = "node_battletext", disable = "arena_close", effectNodes = {"node_arena_effect"}},
    timeMachine = {config = "UNLOCK_BPPTY_BAY", button = "btn_time_machine", animations = {}, enable = "timeMachine_open", disable = "timeMachine_close", effectNodes = {"node_machine_effect"}},
    gloryTower = {config = "UNLOCK_TOWER_OF_GLORY", button = "btn_glory", animations = {gloryTower_animation1 = "light", gloryTower_animation2 = "light"}, enable = "node_tower_name", disable = "node_tower_name_close", effectNodes = {"node_tower_effect"}},
    union = {config = "UNLOCK_UNION", button = "btn_union", animations = {union_animation1 = "flag", union_animation2 = "flag"}, enable = "union_open", disable = "union_close", effectNodes = {"node_union_effect"}},
    thunder = {config = "UNLOCK_THUNDER", button = "btn_thunder", animations = {}, enable = "thunder_open", disable = "thunder_close", effectNodes = {"node_thunder_effect"}},
    archaeology = {config = "UNLOCK_ARCHAEOLOGY", button = "btn_archaeology", animations = {}, enable = "archaeology_open", disable = "archaeology_close", effectNodes = {"node_archaeology_effect"}},
    invasion = {config = "UNLOCK_FORTRESS", button = "btn_invasion", animations = {}, enable = "invasion_open", disable = "invasion_close", effectNodes = {"node_invasion_effect"}},
    silverMine = {config = "UNLOCK_SILVERMINE", button = "btn_silvermine", animations = {}, enable = "silvermine_open", disable = "silvermine_close", effectNodes = {"node_silvermine_effect"}},
    stormArena = {config = "UNLOCK_STORM_ARENA", button = "btn_stormArena", animations = {}, enable = "stormArena_open", disable = "stormArena_close", effectNodes = {"node_storm_effect"}},
    maritime = {config = "UNLOCK_MARITIME", button = "btn_maritime", animations = {}, enable = "maritime_enable", disable = "maritime_disable", effectNodes = {"node_maritime_effect", ""}}, 
    blackrock = {config = "UNLOCK_BLACKROCK", button = "btn_blackRock", animations = {}, enable = "node_blackRock_enable", disable = "node_blackRock_disable"},
    soulTrial = {config = "SOUL_TRIAL_UNLOCK", button = "btn_soulTrial", animations = {}, enable = "soulTrial_open", disable = "soulTrial_close", effectNodes = {"node_soulTiral_effect"}},
    metalCity = {config = "UNLOCK_METALCITY", button = "btn_metalcity", animations = {}, enable = "metalcity_enable", disable = "metalcity_disable", effectNodes = {"node_metal_effect"}},
    fightClub = {config = "UNLOCK_FIGHT_CLUB", button = "btn_fight_club", animations = {}, enable = "fight_club_open", disable = "fight_club_close", effectNodes = {"node_fight_club_effect"}},
    monopoly = {config = "UNLOCK_BINGHUOLIANGYIYAN", button = "btn_monopoly", animations = {}, enable = "monopoly_enable", disable = "monopoly_disable"},
    sanctuary = {config = "UNLOCK_SANCTRUARY", button = "btn_sanctuary", animations = {}, enable = "sanctuary_open", disable = "sanctuary_close"},
    collegeTrain = {config = "UNLOCK_COLLEGE_TRAIN", button = "btn_collegeTrain", animations = {}, enable = "node_collegeTrain_enable", disable = "node_collegeTrain_disable"},
}

function QUIPageMainMenu:ctor(options)
	local ccbFile = "ccb/Page_Mainmenu.ccbi"
	local callbacks = {
		{ccbCallbackName = "onMilitaryRank", callback = handler(self, QUIPageMainMenu._onMilitaryRank)},
		{ccbCallbackName = "onArena", callback = handler(self, QUIPageMainMenu._onArena)},
		{ccbCallbackName = "onSunwell", callback = handler(self, QUIPageMainMenu._onSunwell)},
		{ccbCallbackName = "onRank", callback = handler(self, QUIPageMainMenu._onRank)},
		{ccbCallbackName = "onCheast", callback = handler(self, QUIPageMainMenu._onCheast)},
		{ccbCallbackName = "onInstance", callback = handler(self, QUIPageMainMenu._onInstance)},
		{ccbCallbackName = "onChatButtonClick", callback = handler(self, QUIPageMainMenu._onChatButtonClick)},
		{ccbCallbackName = "onUnion", callback = handler(self, QUIPageMainMenu._onUnion)},
		{ccbCallbackName = "onSilverMine", callback = handler(self, QUIPageMainMenu._onSilverMine)},
		{ccbCallbackName = "onTriggerAssistOK", callback = handler(self, QUIPageMainMenu._onTriggerAssistOK)},
		{ccbCallbackName = "onTimeMachine", callback = handler(self, QUIPageMainMenu._onTimeMachine)},
		{ccbCallbackName = "onInvasion", callback = handler(self, QUIPageMainMenu._onInvasion)},
		{ccbCallbackName = "onFightClub", callback = handler(self, QUIPageMainMenu._onFightClub)},
		{ccbCallbackName = "onSanctuary", callback = handler(self, QUIPageMainMenu._onSanctuary)},
		{ccbCallbackName = "onYingxiong", callback = handler(self, QUIPageMainMenu._onYingxiong)},
		{ccbCallbackName = "onTriggerStormArena", callback = handler(self, QUIPageMainMenu._onStormArena)},
		-- {ccbCallbackName = "onGeneralShop", callback = handler(self, QUIPageMainMenu._onGeneralShop)},
		{ccbCallbackName = "onShenmi", callback = handler(self, QUIPageMainMenu._onGoblinShop)},
		-- {ccbCallbackName = "onBlackMarketShop", callback = handler(self, QUIPageMainMenu._onBlackMarketShop)},
		{ccbCallbackName = "onGoldBattle", callback = handler(self, QUIPageMainMenu._onGoldBattle)},
		{ccbCallbackName = "onTriggerBack", callback = handler(self, QUIPageMainMenu._onTriggerBack)},
		{ccbCallbackName = "onTriggerHome", callback = handler(self, QUIPageMainMenu._onTriggerHome)},
		{ccbCallbackName = "onTriggerActivity", callback = handler(self, QUIPageMainMenu._onTriggerActivityJingcai)},

		-- {ccbCallbackName = "onTriggerSoulShop", callback = handler(self, QUIPageMainMenu._onTriggerSoulShop)},
		{ccbCallbackName = "onTriggerThunder", callback = handler(self, QUIPageMainMenu._onTriggerThunder)},
		{ccbCallbackName = "onTriggerVerify", callback = handler(self, QUIPageMainMenu._onTriggerVerify)},
		{ccbCallbackName = "onArchaeology", callback = handler(self, QUIPageMainMenu._onArchaeology)},
		{ccbCallbackName = "onTriggerShops", callback = handler(self, QUIPageMainMenu._onTriggerShops)},
		{ccbCallbackName = "onTriggerHelp", callback = handler(self, QUIPageMainMenu._onTriggerHelp)},
		{ccbCallbackName = "onTriggerLevelGuide", callback = handler(self, QUIPageMainMenu._onTriggerLevelGuide)},
		{ccbCallbackName = "onTriggerBlackRock", callback = handler(self, QUIPageMainMenu._onTriggerBlackRock)},
		{ccbCallbackName = "onTriggerMaritime", callback = handler(self, QUIPageMainMenu._onTriggerMaritime)},
		{ccbCallbackName = "onSoulTrial", callback = handler(self, self._onSoulTrial)},
		{ccbCallbackName = "onTriggerMetalCity", callback = handler(self, self._onTriggerMetalCity)},
		{ccbCallbackName = "onTriggerMonopoly", callback = handler(self, self._onTriggerMonopoly)},
		{ccbCallbackName = "onTriggerCollegeTrain", callback = handler(self, self._onTriggerCollegeTrain)},
	}

	QUIPageMainMenu.super.ctor(self, ccbFile, callbacks, options)
	self._iconWidgets = {}
	self.tips = nil
	local max_width = display.width - BATTLE_SCREEN_WIDTH
	max_width = max_width 
	max_width = 3000 - max_width
	local rightMaxSizeOffset = 0
	local leftMaxSizeOffset = 0

	self._pageSilder = QUIWidgetMainMenuTouchMoveController.new({ccbOwner = self._ccbOwner, maxSize = CCSize(max_width, 0), 
		rightMaxSizeOffset = rightMaxSizeOffset, leftMaxSizeOffset = leftMaxSizeOffset})
	self:getView():addChild(self._pageSilder)
	self._lightController = QUIWidgetMainMenuLightController.new({ccbOwner = self._ccbOwner})
	self:getView():addChild(self._lightController, 1024)
	
	self._levelGoalAnimationManager = tolua.cast(self._ccbOwner.ccb_levelGoal_bg:getUserObject(), "CCBAnimationManager")

	--xurui: QUIPageMainMenu数据逻辑类
	self._pageMainMenuUtil = QPageMainMenuUtil.new()

	--Kumo：QPageMainMenuIcon主界面Icon管理类
	self._pageMainMenuIcon = QPageMainMenuIcon.new(self)

	--xurui: 倍率活动动画
	self._rateActivityEffect = {}

	-- add energy prompt @qinyuanji
	self._energyPrompt = app:promptTips()

	-- handle menu info
	self._ccbOwner.btn_home:setVisible(false)
	self._ccbOwner.btn_back:setVisible(false)
	self._ccbOwner.btn_back:setAlphaTouchEnable(true)
	self._ccbOwner.arena_tips:setVisible(false)
	self._ccbOwner.timeMachine_tips:setVisible(false) 
	self._ccbOwner.btn_fight_club:setAlphaTouchEnable(true)
	self._ccbOwner.btn_sanctuary:setAlphaTouchEnable(true)
	self._ccbOwner.btn_metalcity:setAlphaTouchEnable(true)
	
	--数据更新监听
	self._mailsEventProxy = cc.EventProxy.new(remote.mails)
	self._shopEventProxy = cc.EventProxy.new(remote.stores)
	self._activityEventProxy = cc.EventProxy.new(remote.activity)
	self._activityRoundsEventProxy = cc.EventProxy.new(remote.activityRounds)

	self._invasionProxy = cc.EventProxy.new(remote.invasion)
	self._chatDataProxy = cc.EventProxy.new(app:getServerChatData())
	self._friendProxy = cc.EventProxy.new(remote.friend)
	self._markProxy = cc.EventProxy.new(remote.mark)

	self.topBar = QUIWidgetTopBar.new()
	self.topBar:showWithMainPage()
	self._ccbOwner.topbar:addChild(self.topBar)

	local headInfo = QUIWidgetHead.new()
    headInfo:setBattleForce()

	self._headInfo = headInfo
	self._headInfo:setPositionX(170)	

	self._ccbOwner.node_tophead:addChild(headInfo:getView())

	self:setHeadInfo(remote.user)

	--打开侧边栏显示的遮罩层
	self._layer = CCLayerColor:create(ccc4(0, 0, 0, 0.7 * 255), display.width * 2, display.height)
	self._layer:setAnchorPoint(0.5,0.5)
	local scalingMaskPosition = ccp(-display.ui_width* 0.5,0)
	scalingMaskPosition = self._ccbOwner.node_scaling:convertToNodeSpaceAR(scalingMaskPosition)
	scalingMaskPosition.x = scalingMaskPosition.x 
	self._layer:setPosition(scalingMaskPosition )
	CalculateBattleUIPosition(self._layer)
	--侧边栏 传入主界面聊天界面节点, 和遮罩
	self._scaling = QUIWidgetScaling.new({stencil = self._layer, parent = self})
	self._ccbOwner.node_scaling:addChild(self._layer)
	self._ccbOwner.node_scaling:addChild(self._scaling:getView())
	--设置zorder使侧边栏一直保持在界面最上层 
	self._ccbOwner.node_left_top:setZOrder(10000)
	self._ccbOwner.node_right_top:setZOrder(10000)
	
	--左下角聊天室按钮
	self.widgetChat = QUIWidgetChat.new({isMain = true, inChannelState = CHAT_CHANNEL_INTYPE.CHANNEL_IN_SILVES})
	self.widgetChat:setPosition(54, 44)
	self.widgetChat:retain()

	self:checkHelpNodeCanShow()

	app.sound:playMusic("main_interface")

	self._instanceAnimationManager = tolua.cast(self._ccbOwner.ccb_instance:getUserObject(), "CCBAnimationManager")
    self._instanceAnimationManager:connectScriptHandler(handler(self, self.viewInstanceAnimationEndHandler))
    self._instanceAnimationManager:runAnimationsForSequenceNamed("2")

    self:_initRedPoiontAndMenuIcon()

	self:getScheduler().performWithDelayGlobal(function()
		self:checkAddHero()
	end, 0)

	self:_onMailDataUpdate()
	--默认显示等级提示
	self._levelGuideStated = true

	self:_checkQuestionnaire()
	self:_checkLockBuilding()
	self:_redTipsChange()
	self:_checkRedTip()
	self:_checkUnlockTutorial()
	self:_checkVerifyWechatAndPhoneNumber()
	self:setActivityRoundVisible()
	self:_activityUpdateHander()
	self:_checkShopRedTips()
	self:_checkTimeMachineRedTips()
	self:_checkInvasionRedTips()
	self:checkFriendTips()
	self:checkLevelGuide()

	-- 本地跑马灯
	app.notice:checkNativeNotice()

	if DEBUG > 0 then
		self:_addDebugButton()
	end

	self.defeatedGuide = QTutorialDefeatedGuide.new()

	-- 使得小红点大小不受上层scale影响
	self:_unifyTipScale()

	-- 创建角色走动层
	--self._actorLayer = QUIWidgetMainPageAvatar.new()
	-- self._actorLayer = display.newNode()
	--self._actorLayer:setPositionX(display.cx / 0.9)
	--self._actorLayer:setPositionY(0 - UI_DESIGN_HEIGHT / UI_DESIGN_WIDTH * display.width / 2)
	--self._ccbOwner.node_mid:addChild(self._actorLayer)

	--xurui: 强制移动第一屏位置
	self._farPositionX = self._ccbOwner.node_far:getPositionX()
	self._farPosition2X = self._ccbOwner.node_far2:getPositionX()
	self._farPosition3X = self._ccbOwner.node_far3:getPositionX()
	self._midPositionX = self._ccbOwner.node_font:getPositionX()
	self._farNearPositionX = self._ccbOwner.node_far_near:getPositionX()
	self:screenMove(0, false)

	self._ccbOwner.btn_time_machine:setAlphaTouchEnable(true)
	self._ccbOwner.btn_arena:setAlphaTouchEnable(true)
	self._ccbOwner.node_achieve_ani:setVisible(false)
	self._ccbOwner.node_task_Ani:setVisible(false)

	-- 弹脸结束
	local endCallback = function()
		-- 检测玩法 邀请函
		self:checkYaoqing()
	end

	-- 弹脸开始
	local startCallback = function()
		-- 仙品超量通知
		self._pageMainMenuUtil:checkMaigcHerbPrompt(function()
			-- 主题曲正式活动弹脸
			self._pageMainMenuUtil:checkZhangbichenFormalPrompt(function()
				-- 老玩家回歸老服版
				self._pageMainMenuUtil:checkPlayerRecallPoster(function()
					-- 七日登录活动
					self:checkSevenDayEntryLogin(function()	
						-- 新首充
						self._pageMainMenuUtil:checkFirstRechargeNew(function()
							-- 前世唐三活动
							self._pageMainMenuUtil:checkMysteryStorePrompt(function()
								-- 检查版本公告
								self._pageMainMenuUtil:checkVersionPost(function()	
									-- 西尔维斯大斗魂场
									self._pageMainMenuUtil:checkSilvesArenaPoster(function()
										--xurui: 检查活动公告
										self._pageMainMenuUtil:checkActivityPost(function()
											-- 嘉年华
											self._pageMainMenuUtil:checkActivityJianianhua(function()
												-- 福利追回
												self:checkRewardRecover(function()
													-- vip认证
													self._pageMainMenuUtil:checkVIPPrerogative(function()
														-- 动漫联动邮件
														self._pageMainMenuUtil:checkAnimationLinkage(function()
															-- 异形屏设置回归
															self._pageMainMenuUtil:checkShowFullScreenSettings(function()
																-- 老玩家回归
																self._pageMainMenuUtil:checkUserComeBack(endCallback)
															end)
														end)
													end)
												end)
											end)
										end)
									end)
								end)
							end)
						end)
				
					end)
				end)
			end)
		end)
	end

	if not (FinalSDK.isHXShenhe()) then
		self:buildLayer()
		self:getScheduler().performWithDelayGlobal(function()
			if self:checkGuiad() then
				startCallback()
			end
		end, 0)
	end
	
	--xurui:设置白天黑夜背景
	self._isDay = self._pageMainMenuUtil:checkBackground(self)

	self._snow = self._pageMainMenuUtil:checksnow(self)
	
	self._pageMainMenuUtil:checkAnniversaryTime(self)

	--首次登陆游戏是需要对主界面截图
	self:_updateBgSprite()

	remote.user.currentLoginTime = q.serverTime()

	self:_updateUIView()
end

function QUIPageMainMenu:_initRedPoiontAndMenuIcon()
	if not self._mapConfig then
		self._mapConfig = QStaticDatabase.sharedDatabase():getMaps()
	end
	local normalInstance = remote.instance:getInstancesWithUnlockAndType(DUNGEON_TYPE.NORMAL)
	if #normalInstance == 0 then
		return
	end
	local lastMap = normalInstance[#normalInstance].data
	local lastDungeon = {}
	for _, dungeon in ipairs(lastMap) do
		if dungeon.info then
			lastDungeon = dungeon
		end
	end
	if #lastDungeon == 0 and #normalInstance > 1 then
		lastMap = normalInstance[#normalInstance - 1].data
		for _, dungeon in ipairs(lastMap) do
			if dungeon.info then
				lastDungeon = dungeon
			end
		end
	end
	local lastDungeonId = lastDungeon.dungeon_id
	if not lastDungeonId then 
		self:setTutorialModel(false)
		return
	end
	local nextPassId = remote.instance:getNextIDForDungeonID(lastDungeonId, DUNGEON_TYPE.NORMAL)

	if nextPassId then
		local nextConfig
		for _, map in pairs(self._mapConfig) do
			if nextPassId == map.dungeon_id then
				nextConfig = map
			end
		end

		if nextConfig and nextConfig.id < 6 then
			self:setTutorialModel(false)
			return
		end
	end

	self:setTutorialModel(true)
end

function QUIPageMainMenu:viewInstanceAnimationEndHandler()
	local needRemind = false
	if not self._mapConfig then
		self._mapConfig = QStaticDatabase.sharedDatabase():getMaps()
	end
	local normalInstance = remote.instance:getInstancesWithUnlockAndType(DUNGEON_TYPE.NORMAL)
	if #normalInstance == 0 then
		return
	end
	local lastMap = normalInstance[#normalInstance].data
	local lastDungeon = {}
	for _, dungeon in ipairs(lastMap) do
		if dungeon.info then
			lastDungeon = dungeon
		end
	end
	if #lastDungeon == 0 and #normalInstance > 1 then
		lastMap = normalInstance[#normalInstance - 1].data
		for _, dungeon in ipairs(lastMap) do
			if dungeon.info then
				lastDungeon = dungeon
			end
		end
	end
	local lastDungeonId = lastDungeon.dungeon_id
	if not lastDungeonId then 
		self._instanceAnimationManager:runAnimationsForSequenceNamed("2")
		return
	end
	local nextPassId = remote.instance:getNextIDForDungeonID(lastDungeonId, DUNGEON_TYPE.NORMAL)
	if nextPassId then
		local nextConfig
		for _, map in pairs(self._mapConfig) do
			if nextPassId == map.dungeon_id then
				nextConfig = map
			end
		end
		-- 3-1的id是25
		if nextConfig and nextConfig.id < 25 then
			local dungeonConfig = QStaticDatabase.sharedDatabase():getDungeonConfigByID(nextConfig.dungeon_id)
			if remote.herosUtil:getMostHeroBattleForce() >= (dungeonConfig.thunder_force or 0) then
				needRemind = true
			end
		end
	end
	if needRemind then
		self._instanceAnimationManager:runAnimationsForSequenceNamed("1")
	else
		self._instanceAnimationManager:runAnimationsForSequenceNamed("2")
	end
end

function QUIPageMainMenu:viewDidAppear()

	if app._hasEnterMainPageBefore then
		-- nothing to do
	else
		if remote.user.nickname and remote.user.nickname ~= "" then 
			-- app:sendGameEvent(GAME_EVENTS.GAME_EVENT_ENTER_MAIN_PAGE, true)
		end
		app._hasEnterMainPageBefore = true
	end
	
	QUIPageMainMenu.super.viewDidAppear(self)

	-- self._shopEventProxy:addEventListener(remote.stores.MYSTORY_SHOP_UPDATE_EVENT, handler(self, self._checkMystoryStores))

    self._chatDataProxy:addEventListener(QChatData.NEW_MESSAGE_RECEIVED, handler(self, self._onMessageReceived))
    self._chatDataProxy:addEventListener(QChatData.NEW_MESSAGE_SENT, handler(self, self._onMessageSent))
	self._mailsEventProxy:addEventListener(remote.mails.MAILS_UPDATE_EVENT, handler(self, self._onMailDataUpdate))
	self._activityEventProxy:addEventListener(remote.activity.EVENT_COMPLETE_UPDATE, handler(self, self._activityUpdateHander))
	self._activityEventProxy:addEventListener(remote.activity.EVENT_CHANGE, handler(self, self._activityUpdateHander))
	self._activityEventProxy:addEventListener(remote.activity.EVENT_RECIVED_QUESTIONNAIRE, handler(self, self._checkQuestionnaire))
	self._invasionProxy:addEventListener(remote.invasion.BOSSAPPLICABLE, handler(self, self._checkInvasionRedTips))
	self._invasionProxy:addEventListener(remote.invasion.BOSSNOTAPPLICABLE, handler(self, self._checkInvasionRedTips))
	self._invasionProxy:addEventListener(remote.invasion.REWARDACCEPTED, handler(self, self._checkInvasionRedTips))
	self._friendProxy:addEventListener(remote.friend.EVENT_UPDATE_FRIEND, handler(self, self.checkFriendTips))
	self._friendProxy:addEventListener(remote.friend.EVENT_UPDATE_BLACK_FRIEND, handler(self, self.checkFriendTips))
	self._friendProxy:addEventListener(remote.friend.EVENT_UPDATE_APPLY_FRIEND, handler(self, self.checkFriendTips))
	self._markProxy:addEventListener(remote.mark.EVENT_UPDATE, handler(self, self.markUpdate))

	QNotificationCenter.sharedNotificationCenter():addEventListener(QUIWidgetSystemNotice.SHOW_NOTICE_ON_CHAT, self._onBulletinMessageReceived, self)
	QNotificationCenter.sharedNotificationCenter():addEventListener(QUIWidgetSystemNotice.NO_MORE_NOTICE, self._onNoMoreNotice, self)

	QNotificationCenter.sharedNotificationCenter():addEventListener(QNotificationCenter.EVENT_UI_VIEW_SIZE_CAHNGE, self._updateUIView, self)

	-- self._touchLayer:enable()
	-- self._touchLayer:addEventListener(QUIGestureRecognizer.EVENT_SLIDE_GESTURE, handler(self, self._onTouch))

	self._headInfo:addEventListener(QUIWidgetHead.EVENT_HERO_HEAD_CLICK, handler(self, self._onUserHeadClickHandler))

	-- for _,topRegionCCBLayer in pairs(self._topRegion) do
	-- 	topRegionCCBLayer:addEventListener(QUIWidgetTopStatusShow.EVENT_CLICK, handler(self, QUIPageMainMenu._onTopRegionCCBLayerClick))
	-- end

	QNotificationCenter.sharedNotificationCenter():addEventListener(QUIDialogTimeMachine.CD_TIMEOUT, QUIPageMainMenu._timeMachineTimeout,self)
	QNotificationCenter.sharedNotificationCenter():addEventListener(QUserProp.CHEST_IS_FREE, QUIPageMainMenu._chestIsFree,self)
	QNotificationCenter.sharedNotificationCenter():addEventListener(QNotificationCenter.EVENT_DIALOG_DID_APPEAR, QUIPageMainMenu._onDialogPopup, self)
	QNotificationCenter.sharedNotificationCenter():addEventListener(QNotificationCenter.EVENT_DIALOG_WILL_DISAPPEAR, QUIPageMainMenu._onDialogClosed, self)
	QNotificationCenter.sharedNotificationCenter():addEventListener(QNotificationCenter.EVENT_EXIT_FROM_BATTLE, QUIPageMainMenu._exitFromBattle, self)
	QNotificationCenter.sharedNotificationCenter():addEventListener(QNotificationCenter.EVENT_CHANGE_GLVIEW_SIZE, QUIPageMainMenu._reloadCCB, self)

	QNotificationCenter.sharedNotificationCenter():addEventListener(QNotificationCenter.VIP_RECHARGED, self._checkFirstRechargeState, self)

	
	--QNotificationCenter.sharedNotificationCenter():addEventListener(QUIDialogHelp.HELP_ICON_DISAPPEAR, self._helpIconDisappear, self)

	QNotificationCenter.sharedNotificationCenter():addEventListener(QNotificationCenter.VIP_LEVELUP, self._onVipLevelUp, self)
	QNotificationCenter.sharedNotificationCenter():addEventListener(QVIPUtil.AWARD_PURCHASED, self._checkRechargeAward, self)

	--监听 副本数据变化  第二章通过后  显示帮助图标

	self._arenaEventProxy = cc.EventProxy.new(remote.arena)
	self._arenaEventProxy:addEventListener(remote.arena.EVENT_COUNT_UPDATE, handler(self, self._checkArenaTips))
	self._arenaEventProxy:addEventListener(remote.arena.EVENT_SELF_RANK, handler(self, self._checkArenaTips))
	self._arenaEventProxy:addEventListener(remote.arena.EVENT_SCORE_CHANGE, handler(self, self._checkArenaTips))

	self._userEventProxy = cc.EventProxy.new(remote.user)
	self._userEventProxy:addEventListener(remote.user.EVENT_USER_PROP_CHANGE, handler(self, self._onUserDataUpdate))
	self._userEventProxy:addEventListener(remote.user.EVENT_TIME_REFRESH, handler(self, self._onTimeRefreshHandler))

    self._remoteProxy = cc.EventProxy.new(remote)
    self._remoteProxy:addEventListener(QRemote.HERO_UPDATE_EVENT, handler(self, self._onHeroDataUpdate))
   	self._remoteProxy:addEventListener(QRemote.DUNGEON_UPDATE_EVENT, handler(self, self._onDungeonDataUpdate))



    self._towerEventProxy = cc.EventProxy.new(remote.tower)
    self._towerEventProxy:addEventListener(remote.tower.EVENT_TOWER_GLORY_ARENA_YAOQING, handler(self, self._onTowerGloryArenaYaoqing))
    self._towerEventProxy:addEventListener(remote.tower.EVENT_TOWER_STATE_CHANGE, handler(self, self._onTowerStateChange))
    self._towerEventProxy:addEventListener(remote.tower.GLORY_ARENA_REDTIPS_CHANGE, handler(self, self._checkTowerTips))
  	
  	self._fightClubEventProxy = cc.EventProxy.new(remote.fightClub)
    self._fightClubEventProxy:addEventListener(remote.fightClub.FIGHT_CLUB_REDTIPS_CHANGE, handler(self, self._checkFightClubTips))

    self._redTipsEventProxy = cc.EventProxy.new(remote.redTips)
    self._redTipsEventProxy:addEventListener(remote.redTips.TIPS_STATE_CHANGE, handler(self, self._redTipsChange))

   	self._activityRoundsEventProxy:addEventListener(remote.activityRounds.RESOURCE_TREASURES_OFF_LINE, handler(self, self.quickButtonAutoLayout))

	self._activityRoundsEventProxy:addEventListener(remote.activityRounds.GROUPBUY_UPDATE, handler(self, self._activityGroupBuyUpdateHander))
	self._activityRoundsEventProxy:addEventListener(remote.activityRounds.RUSHBUY_UPDATE, handler(self, self._activityRushBuyUpdateHander))
	self._activityRoundsEventProxy:addEventListener(remote.activityRounds.SOUL_LETTER_END, handler(self, self._activitySoulLetterEndHander))
	self._activityRoundsEventProxy:addEventListener(remote.activityRounds.PRIZA_WHEEL_UPDATE, handler(self, self._activityTurntableUpdateHander))
	self._activityRoundsEventProxy:addEventListener(remote.activityRounds.SKY_FALL_UPDATE, handler(self,self._activitySkyFallUpdateHander))

	self._blackrockProxy = cc.EventProxy.new(remote.blackrock)
	self._blackrockProxy:addEventListener(remote.blackrock.EVENT_SEND_INVITE, handler(self, self._blackrockSendInviteHandler))
	
	self._silverMineProxy = cc.EventProxy.new(remote.silverMine)
	self._silverMineProxy:addEventListener(remote.silverMine.SILVER_ASSIST_UPDATE, handler(self, self._onSilverMineAssistUpdate))

	self._globalMessage = self:getScheduler().scheduleGlobal(handler(self, self._onGlobalMessage), 1)

	self._silvesArenaProxy = cc.EventProxy.new(remote.silvesArena)
	self._silvesArenaProxy:addEventListener(remote.silvesArena.EVENT_SEND_INVITE, handler(self, self._silvesArenaSendInviteHandler))

	-- self._actorScheduleHandle = scheduler.scheduleGlobal(handler(self, self._updateActors), 0.5)
	--self._actorLayer:init()

	QDeliveryWrapper:setToolBarVisible(true)

	self._energyPrompt:addEnergyEventListener()

	self._farPositionX = self._ccbOwner.node_far:getPositionX()
	self._farPosition2X = self._ccbOwner.node_far2:getPositionX()
	self._farPosition3X = self._ccbOwner.node_far3:getPositionX()
	self._midPositionX = self._ccbOwner.node_font:getPositionX()
	self._farNearPositionX = self._ccbOwner.node_far_near:getPositionX()

	self:_checkUnlock()

	self._isPrepareToRemove = false

	-- clean texture cache
	app:cleanTextureCache()

	self._ccbOwner.node_chat:addChild(self.widgetChat)
	self.widgetChat:release()
	self._pageMainMenuUtil:viewDidAppear()
end

function QUIPageMainMenu:viewWillDisappear()
	if self._dragonDelayHandler ~= nil then
		self:getScheduler().unscheduleGlobal(self._dragonDelayHandler)
		self._dragonDelayHandler = nil
	end

	-- self._touchLayer:removeAllEventListeners()
	-- self._touchLayer:disable()
	-- self._touchLayer:detach()

	self._activityEventProxy:removeAllEventListeners()
	self._activityEventProxy = nil

	self._mailsEventProxy:removeAllEventListeners()
	self._mailsEventProxy = nil

	self._invasionProxy:removeAllEventListeners()
	self._invasionProxy = nil

	self._shopEventProxy:removeAllEventListeners()
	self._shopEventProxy = nil

	self._arenaEventProxy:removeAllEventListeners()
	self._arenaEventProxy = nil

	self._remoteProxy:removeAllEventListeners()
	self._remoteProxy = nil

	self._chatDataProxy:removeAllEventListeners()
	self._chatDataProxy = nil

	self._friendProxy:removeAllEventListeners()
	self._friendProxy = nil

	self._markProxy:removeAllEventListeners()
	self._markProxy = nil

	self._towerEventProxy:removeAllEventListeners()
	self._towerEventProxy = nil

	self._activityRoundsEventProxy:removeAllEventListeners()
	self._activityRoundsEventProxy = nil

	self._redTipsEventProxy:removeAllEventListeners()
	self._redTipsEventProxy = nil

	if self._blackrockProxy ~= nil then
		self._blackrockProxy:removeAllEventListeners()
		self._blackrockProxy = nil
	end

	self._silvesArenaProxy:removeAllEventListeners()
	self._silvesArenaProxy = nil

	self._fightClubEventProxy:removeAllEventListeners()
	self._fightClubEventProxy = nil

	self._silverMineProxy:removeAllEventListeners()
	self._silverMineProxy = nil

	if self._globalMessage then
		self:getScheduler().unscheduleGlobal(self._globalMessage)
		self._globalMessage = nil
	end

    if self._timeHandler ~= nil then
        self:getScheduler().unscheduleGlobal(self._timeHandler)
        self._timeHandler = nil
    end

    if self._dialogCloseSchedulerHander ~= nil then
    	self:getScheduler().unscheduleGlobal(self._dialogCloseSchedulerHander)
    	self._dialogCloseSchedulerHander = nil
    end

	if self._schedulerPrompt then
		scheduler.unscheduleGlobal(self._schedulerPrompt)
		self._schedulerPrompt = nil
	end

    -- if self._actorScheduleHandle then
    -- 	scheduler.unscheduleGlobal(self._actorScheduleHandle)
    -- end

	self._headInfo:removeEventListener(QUIWidgetHead.EVENT_HERO_HEAD_CLICK, handler(self, self._onUserHeadClickHandler))
	QNotificationCenter.sharedNotificationCenter():removeEventListener(QUIDialogTimeMachine.CD_TIMEOUT, QUIPageMainMenu._timeMachineTimeout,self)
	QNotificationCenter.sharedNotificationCenter():removeEventListener(QUserProp.CHEST_IS_FREE, QUIPageMainMenu._chestIsFree,self)
	QNotificationCenter.sharedNotificationCenter():removeEventListener(QUIWidgetSystemNotice.SHOW_NOTICE_ON_CHAT, self._onBulletinMessageReceived, self)
	QNotificationCenter.sharedNotificationCenter():removeEventListener(QUIWidgetSystemNotice.NO_MORE_NOTICE, self._onNoMoreNotice, self)
	QNotificationCenter.sharedNotificationCenter():removeEventListener(QNotificationCenter.EVENT_DIALOG_DID_APPEAR, QUIPageMainMenu._onDialogPopup, self)
	QNotificationCenter.sharedNotificationCenter():removeEventListener(QNotificationCenter.EVENT_DIALOG_WILL_DISAPPEAR, QUIPageMainMenu._onDialogClosed, self)
	QNotificationCenter.sharedNotificationCenter():removeEventListener(QNotificationCenter.EVENT_EXIT_FROM_BATTLE, QUIPageMainMenu._exitFromBattle, self)
	QNotificationCenter.sharedNotificationCenter():removeEventListener(QNotificationCenter.VIP_RECHARGED, self._checkFirstRechargeState, self)

	--QNotificationCenter.sharedNotificationCenter():removeEventListener(QUIDialogHelp.HELP_ICON_DISAPPEAR, self._helpIconDisappear, self)

	QNotificationCenter.sharedNotificationCenter():removeEventListener(QNotificationCenter.VIP_LEVELUP, self._onVipLevelUp, self)
	QNotificationCenter.sharedNotificationCenter():removeEventListener(QVIPUtil.AWARD_PURCHASED, self._checkRechargeAward, self)
	
	QNotificationCenter.sharedNotificationCenter():removeEventListener(QNotificationCenter.EVENT_UI_VIEW_SIZE_CAHNGE, self._updateUIView, self)
	QNotificationCenter.sharedNotificationCenter():removeEventListener(QNotificationCenter.EVENT_CHANGE_GLVIEW_SIZE, self._reloadCCB, self)

	self._userEventProxy:removeAllEventListeners()

	self._energyPrompt:removeEnergyEventListener()

	self.defeatedGuide:detach()

	audio.stopBackgroundMusic()

	self._isPrepareToRemove = true

	for i = 1, 4 do
		if self._rateActivityEffect[i] ~= nil then
			self._rateActivityEffect[i]:stopAnimation()
			self._rateActivityEffect[i]:removeFromParent()
			self._rateActivityEffect[i] = nil
		end
	end

	if self._invasionEffect then
		self._invasionEffect:stopAnimation()
		self._invasionEffect:removeFromParent()
		self._invasionEffect = nil
	end
	
	self._pageMainMenuUtil:viewWillDisappear()

	self:cleanBuildLayer()

	if self._schedulerFuli then
		scheduler.unscheduleGlobal(self._schedulerFuli)
		self._schedulerFuli = nil
	end

	if self._schedulerUnLockTime then
		scheduler.unscheduleGlobal(self._schedulerUnLockTime)
		self._schedulerUnLockTime = nil
	end
	if self._schedulerPrompt then
		scheduler.unscheduleGlobal(self._schedulerPrompt)
		self._schedulerPrompt = nil
	end
	if self._schedulerGradePackage then
		scheduler.unscheduleGlobal(self._schedulerGradePackage)
		self._schedulerGradePackage = nil
	end	

	if self._schedulerSevenDayTime then
		scheduler.unscheduleGlobal(self._schedulerSevenDayTime)
		self._schedulerSevenDayTime = nil
	end

end

function QUIPageMainMenu:_reloadCCB()
	-- makeNodeRefreshCCBPos(self:getView())
	self._ccbOwner.node_background:setPositionX(display.width/2)
	self._ccbOwner.node_background:setPositionY(display.height/2)

	if self._pageSilder then
		local max_width = display.width - BATTLE_SCREEN_WIDTH
		max_width = max_width 
		max_width = 3000 - max_width
		self._pageSilder:refreshUISize(CCSize(max_width, 0))
	end
end

function QUIPageMainMenu:addSubViewController(controller)
	QUIPageMainMenu.super.addSubViewController(self,controller)
end

function QUIPageMainMenu:removeSubViewController(controller)
	QUIPageMainMenu.super.removeSubViewController(self,controller)

end

function QUIPageMainMenu:hideScaling()
	self:setManyUIVisible()
	self._scalingStatus = self._scaling:getScalingStatus()
	if self._scalingStatus then
		self._scaling:willPlayHide()
	end
end

function QUIPageMainMenu:setBackBtnVisible(b)
	self._ccbOwner.btn_back:setVisible(b)
end

function QUIPageMainMenu:setHomeBtnVisible(b)
	self._ccbOwner.btn_home:setVisible(b)
end

function QUIPageMainMenu:setBackBtnEnable(b)
	self._ccbOwner.btn_back:setEnabled(b)
	self._ccbOwner.btn_home:setEnabled(b)
end
function QUIPageMainMenu:setBackHomeBtnVisible(b)
	self._ccbOwner.btn_back:setVisible(b)
	self._ccbOwner.btn_home:setVisible(b)
end
function QUIPageMainMenu:setScalingVisible(b)
	if self._scaling ~= nil then
		self._scaling:setVisible(b)
	end
end
function QUIPageMainMenu:getScalingVisible()
	if self._scaling ~= nil then
		return self._scaling:isVisible()
	end
end
function QUIPageMainMenu:setAllUIVisible(b)
	self._ccbOwner.node_tophead:setVisible(b)
	if self:getPageMainMenuIcon() then
		self:getPageMainMenuIcon():setIconNodeVisible("node_recharge", b and ENABLE_CHARGE(true))
		self:getPageMainMenuIcon():setIconNodeVisible("node_active", b)
	end

	if self._scaling:isVisible() == false then
		self._scaling:setVisible(true)
	end
	if b == true then 
		self.topBar:showWithMainPage()
	else
		self.topBar:hideAll()
	end
end

function QUIPageMainMenu:setManyUIVisible()
	self._ccbOwner.node_tophead:setVisible(false)
	if self:getPageMainMenuIcon() then
		self:getPageMainMenuIcon():setIconNodeVisible("node_recharge", false)
		self:getPageMainMenuIcon():setIconNodeVisible("node_active", false)
	end
	self.topBar:showWithMainPage()
	self:setBattleForceBar(false)
	if self._scaling:isVisible() == false then
		self._scaling:setVisible(true)
	end
end

function QUIPageMainMenu:setManyTopBar(state)
	-- self._ccbOwner.CCNode_TopRunestone:setVisible(state)
	-- self._ccbOwner.CCNode_TopGameCurrency:setVisible(state)
	-- self._ccbOwner.topEffect:setVisible(state)
end

function QUIPageMainMenu:setTopBar(state)
	self._ccbOwner.CCNode_TopEnergy:setVisible(state)
	self._ccbOwner.CCNode_TopRunestone:setVisible(state)
	self._ccbOwner.CCNode_TopGameCurrency:setVisible(state)
end

function QUIPageMainMenu:setBattleForceBar(state)
	-- self._topRegion[3]:setVisible(not state)
	-- self._topRegion[4]:setVisible(state)
end

function QUIPageMainMenu:setChatButtonZOrder(zOrder)
	local oldZOrder = self._ccbOwner.node_chat:getZOrder()
	self._ccbOwner.node_chat:setZOrder(zOrder)

	return oldZOrder
end

function QUIPageMainMenu:getChatButtonZOrder( ... )
	return self.widgetChat:getZOrder()
end

function QUIPageMainMenu:setChatInUnion(boo)
	self.widgetChat:setChatInUnion(boo)
end

function QUIPageMainMenu:setChatButton(visible)
	self.widgetChat:setVisible(visible)
end

function QUIPageMainMenu:setLevelGuidButton(visible)
	self._ccbOwner.level_guide_node:setVisible(visible)
end

function QUIPageMainMenu:getChatButton()
	return self.widgetChat
end

function QUIPageMainMenu:setHeadInfo(userData)
	if nil ~= userData then
		self._headInfo:setInfo(userData)
	end
end

function QUIPageMainMenu:backPageMainMenu()
	--返回主场景的时候清理一次贴图
	app:setIsClearSkeletonData(true)
    app:cleanTextureCache()
    collectgarbageCollect()
	-- CCTextureCache:sharedTextureCache():dumpCachedTextureInfo()
    -- print(string.format("LUA VM MEMORY USED BEFORE Load Database: %0.2f KB, %0.3f MB", collectgarbage("count"), collectgarbage("count")/1024))

	if app.tip ~= nil then
		app.tip:checkMainMenuMove()
	end
	self:_checkRedTip()
	self:_checkShopRedTips()
	self:_checkInvasionRedTips()
	self:_checkTimeMachineRedTips()
	self:checkActivitySevenTip()

	if self._headInfo ~= nil and self._headInfo.setBattleForce then
		self._headInfo:setBattleForce()
		self._headInfo:checkRedTips()
		self:setBattleForceBar(false)
	end

	-- 检查等级目标
	self:checkLevelGuide()

	--xurui: 检查倍率活动
	self:checkRateActivity()
	-- 等级开启
	self:checkActivityUnlock()
	self:setLevelGuideStated(true)

	self:_checkQuestionnaire()
	self:_activityTurntableUpdateHander()
	self:_activitySkyFallUpdateHander()
	
	-- 在线提示功能
	self._pageMainMenuUtil:checkPrompt(self)

	-- 老玩家回归
	self._ccbOwner.node_comeback:setVisible(remote.userComeBack:checkComeBackStated())

	self:quickButtonAutoLayout()

	local oldDay = self._isDay
	self._isDay = self._pageMainMenuUtil:checkBackground(self)
	if oldDay ~= self._isDay then
		self:_updateBgSprite()
		self:quickButtonAutoLayout()
	end

	local oldsnow = self._snow
	self._snow = self._pageMainMenuUtil:checksnow(self)
	if oldsnow ~= self._snow then
		self:_updateBgSprite()
	end

	self._pageMainMenuUtil:checkVIPPrerogative()

	self._pageMainMenuUtil:checkAnniversaryTime(self)
end

function QUIPageMainMenu:_exitFromBattle()
	self:buildLayer()
	self:getScheduler().performWithDelayGlobal(function()
		self:checkAddHero()
		self:checkGuiad()
		self:_checkUnlockTutorial()
		self:_checkUnlock()

		self:_onMailDataUpdate()
		self:_checkLockBuilding()
		-- self:_checkMystoryStores()
		self:_checkRedTip()
		self:_checkVerifyWechatAndPhoneNumber()
		self:_activityUpdateHander()
		self:_checkShopRedTips()
		self:_checkTimeMachineRedTips()

		local mainUILayerController = app:getNavigationManager():getController(app.mainUILayer)
		local middleLayerController = app:getNavigationManager():getController(app.middleLayer)

		if mainUILayerController:getTopDialog() ~= nil or middleLayerController:getTopDialog() ~= nil then
			self._scaling:willPlayHide()
		end

		app.sound:playMusic("main_interface")
	end, 0)

end

--新建一个新手引导遮罩
function QUIPageMainMenu:buildLayer()
	if self.tutorialLayer == nil then
		self.tutorialLayer = CCLayerColor:create(ccc4(0, 0, 0, 0), display.width, display.height)
		self.tutorialLayer:setPosition(-display.width/2, -display.height/2)
		self.tutorialLayer:setTouchEnabled(true)
		app._uiScene:addChild(self.tutorialLayer)
	end
end

--清除新手引导遮罩
function QUIPageMainMenu:cleanBuildLayer()
	if self.tutorialLayer ~= nil then
		self.tutorialLayer:removeFromParent()
		self.tutorialLayer = nil
	end
end

function QUIPageMainMenu:checkGuiad()
	if not self:safeCheck() then
		return true
	end
	
	if app.tutorial and app.tutorial:isTutorialFinished() == false then
		local state = app.tutorial:checkTutorialStage()
		if state == false then
			self:cleanBuildLayer()
			self._ccbOwner.ccb_instance:setVisible(true)
			return true
		else
			self._ccbOwner.ccb_instance:setVisible(false)
			return false
		end
	else
		self:cleanBuildLayer()
		self._ccbOwner.ccb_instance:setVisible(true)
		return true
	end
end

function QUIPageMainMenu:checkAddHero()
	local hero, fragment = remote.teamManager:getJoinHero()
	local dungeonId = nil
	if hero ~= nil and fragment == 1 then
		local isCall = false
		for i = 1, 2, 1 do
			local dungeonHero = QStaticDatabase:sharedDatabase():getDungeonHeroByIndex(i)
			if dungeonHero.hero_actor_id == hero[1] then
				if remote.instance:checkIsPassByDungeonId(dungeonHero.dungeon_id) then
					dungeonId = dungeonHero.dungeon_id
					isCall = true
					break
				end
			end
		end

		if isCall then
	    	local heroInfo = QStaticDatabase:sharedDatabase():getCharacterByID(hero[1])
	    	local config = QStaticDatabase:sharedDatabase():getGradeByHeroActorLevel(hero[1], heroInfo.grade or 0)

			local dungeonConfig = QStaticDatabase:sharedDatabase():getDungeonConfigByID(dungeonId)
			local dropItems = string.split(dungeonConfig.fd_item or {}, ";")
			local count = 0

			for k, v in ipairs(dropItems or {}) do
				local itemId = string.split(v, "^")
				if itemId[2] and tonumber(itemId[1]) == tonumber(config.soul_gem) then
					count = tonumber(itemId[2])
					break
				end
			end
			
			if count > 0 then
		    	local awards = {{id = config.soul_gem, typeName = "item", count = count or 0}}
				app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogAwardsAlert",
					options = {awards = awards}},{isPopCurrentDialog = true} )
			end
		end
	end
	remote.teamManager:initJoinHero()

end

--检查是否有解锁提示
function QUIPageMainMenu:_checkUnlock()
	app.tip:checkUnlockByPassDungeon()
	
	if app.tip.unLockTipsNum ~= 0 then
		app.tip:showNextTip()
	end
	local dialog = app:getNavigationManager():getController(app.mainUILayer):getTopDialog()
	if dialog ~= nil and dialog.class.__cname == "QUIPageMainMenu" then
		app.tip:checkMainMenuMove()
	end
end

--检查是否有解锁引导
function QUIPageMainMenu:_checkUnlockTutorial()
	if app.tip:isUnlockTutorialFinished() == false then
		local unlockTutorial = app.tip:getUnlockTutorial()
		for key, value in pairs(unlockTutorial) do
			if (value == QTips.UNLOCK_TUTORIAL_OPEN or value == QTips.UNLOCK_TUTORIAL_TIP) and self[key.."HandTouch"] == nil then
				self[key.."HandTouch"] = app.tip:createUnlockTutorialTip(key, self)
			end
		end
	end
end

--关闭解锁引导
function QUIPageMainMenu:_closeUnlockTutorial(data)
	local unlockTutorialInfo = app.tip:getUnlockTutorialInfo()
	local unlockTutorial = app.tip:getUnlockTutorial()

	if unlockTutorial[data.type] ~= nil and self[data.type.."HandTouch"] ~= nil then
		self[data.type.."HandTouch"] = app.tip:removeUnlockTips(self[data.type.."HandTouch"])
		local callBacks = self._ccbOwner[unlockTutorialInfo[data.type].callFunc]
		if type(callBacks) == "function" then
			callBacks()
		elseif type(callBacks) == "table" then
			callBacks.callback()
		end
	end

	app.tip:removeouchNode()
end

function QUIPageMainMenu:_checkRedTip(event)
	self._ccbOwner.chest_tip:setVisible(false)
	self._ccbOwner.silvermine_tips:setVisible(false)
	self._ccbOwner.archaeology_tips:setVisible(false)
	self._ccbOwner.instance_tips:setVisible(false)
	self._ccbOwner.stormArena_tips:setVisible(false)
	self._ccbOwner.sanctuary_tips:setVisible(false)
	self._ccbOwner.soulTrial_tips:setVisible(false)
	self._ccbOwner.sp_fight_club_tips:setVisible(false)
	self._ccbOwner.monopoly_tips:setVisible(false)
	self._ccbOwner.maritime_tips:setVisible(false)
	
	self._pageMainMenuUtil:checkChestTip(self._ccbOwner.chest_tip)

	self:_checkSunwarTips()

	if app.unlock:getUnlockArchaeology() and self:checkArchaeologyTips() then
		self._ccbOwner.archaeology_tips:setVisible(true)
	end

	if app.unlock:getUnlockSoulTrial() and self:checkSoulTrialTips() then
		self._ccbOwner.soulTrial_tips:setVisible(true)
	end

	self:_checkThunderTips()

	self:_checkTowerTips()


	self._pageMainMenuUtil:checkUnionTip(self._ccbOwner.union_tips, self._ccbOwner.union_special_tip)
	self:_checkPlunderBattleState()

	self._pageMainMenuUtil:checkSilvermineTip(self._ccbOwner.silvermine_tips, self._ccbOwner.silvermine_special_tip)

	-- 副本小红点
	if remote.instance:isShowRedPoint() or remote.welfareInstance:isShowRedPoint() or remote.nightmare:getDungeonRedPoint() then
		self._ccbOwner.instance_tips:setVisible(true)
	end

	self._pageMainMenuUtil:checkMaritimeRedTip(self._ccbOwner.maritime_tips, self._ccbOwner.maritime_special_tip)

	self:_checkStormArenaTips()
	self:_checkSanctuaryTips()
	self:_checkFightClubTips()
	self:_checkArenaTips()
	self:_checkInstanceTips()

	self._pageMainMenuUtil:checkMetalCityTip(self._ccbOwner.metalcity_tips, self._ccbOwner.metalcity_special_tip)

	self._pageMainMenuUtil:checkCollegeTrainTip(self._ccbOwner.collegeTrain_tips, self._ccbOwner.collegeTrain_special_tip)

	self.widgetChat:checkPrivateChannelRedTips()

	-- self._ccbOwner.blackRock_tips:setVisible(remote.blackrock:checkRedTip() or remote.soultower:checkRedTip())
	self._pageMainMenuUtil:checkBlackSoulTowerTip(self._ccbOwner.blackRock_tips, self._ccbOwner.blackRock_special_tip)

	self._ccbOwner.monopoly_tips:setVisible(remote.monopoly:checkRedTips())
	self:_checkRankTips()

	-- self:getPageMainMenuIcon():setIconWidgetRedTips("node_achieve", false)
	self:getPageMainMenuIcon():setIconWidgetRedTips("node_master", false)
	self:getPageMainMenuIcon():setIconWidgetRedTips("node_reborn", false)
	self:getPageMainMenuIcon():setIconWidgetRedTips("node_comeback", remote.userComeBack:checkAllRedTips())
	self:getPageMainMenuIcon():setIconWidgetRedTips("node_player_recall", remote.playerRecall:isShowRedTips())
	self:getPageMainMenuIcon():setIconWidgetRedTips("node_sign", remote.daily:checkRedTips())
	self:getPageMainMenuIcon():setIconWidgetRedTips("node_mall", remote.stores:checkMallRedTips())
	self:getPageMainMenuIcon():setIconWidgetRedTips("node_fuli", remote.rewardRecover:getIsShowRedTips())
	self:getPageMainMenuIcon():setIconWidgetRedTips("node_gradePackage", remote.gradePackage:checkGradePakgePageMainRedTips())

	self:_checkFirstRechargeState()
	self:_checkRechargeAward()
	self:_onMailDataUpdate()
end

function QUIPageMainMenu:markUpdate( event )
	-- body
	
	--宗门5点刷新  小红点
	if event.markTbl and event.markTbl[remote.mark.MARK_TIME_FIVE] then
		self:getScheduler().performWithDelayGlobal(function ( )
			-- body
			remote.mark:analysisMark(remote.mark.MARK_CONSORTIA_SACRIFICE)
		end, 0)
	end

	if event.markTbl  and (event.markTbl[remote.mark.MARK_CONSORTIA_APPLY] or event.markTbl[remote.mark.MARK_CONSORTIA_SACRIFICE] ) then
		if app.unlock:checkLock("UNLOCK_UNION") and remote.union:checkUnionRedTip() then
			self._ccbOwner.union_tips:setVisible(true)
			self:_checkPlunderBattleState()
		else
			self._ccbOwner.union_tips:setVisible(false)
		end
	end
end

function QUIPageMainMenu:_checkPlunderBattleState()
	self:_checkThunderTips()
end

--斗魂场小红点
function QUIPageMainMenu:_checkArenaTips()
	self._pageMainMenuUtil:checkArenaTip(self._ccbOwner.arena_tips, self._ccbOwner.arena_special_tip)
end

function QUIPageMainMenu:_checkInstanceTips()
	self._pageMainMenuUtil:checkInstanceTip(self._ccbOwner.instance_tips, self._ccbOwner.instance_special_tip)
end

function QUIPageMainMenu:_checkTowerTips()
	self._pageMainMenuUtil:checkGloryTowerTip(self._ccbOwner.glory_tips, self._ccbOwner.tower_special_tip)
end

function QUIPageMainMenu:_checkSunwarTips()
	self._pageMainMenuUtil:checkSunWarTip(self._ccbOwner.sunwell_tips, self._ccbOwner.sunwell_special_tip)
end

function QUIPageMainMenu:_checkThunderTips()
	self._pageMainMenuUtil:checkThunderTip(self._ccbOwner.thunder_tips, self._ccbOwner.thunder_special_tip)
end

function QUIPageMainMenu:_checkStormArenaTips()
	self._pageMainMenuUtil:checkStormArenaTip(self._ccbOwner.stormArena_tips, self._ccbOwner.storm_special_tip)
end

function QUIPageMainMenu:_checkSanctuaryTips()
	self._pageMainMenuUtil:checkSanctuaryTip(self._ccbOwner.sanctuary_tips, self._ccbOwner.sanctuary_special_tip)
end

function QUIPageMainMenu:_checkFightClubTips()
	self._pageMainMenuUtil:checkFightClubTips(self._ccbOwner.sp_fight_club_tips, self._ccbOwner.fight_club_special_tip)
end

function QUIPageMainMenu:_checkRankTips()
	self._pageMainMenuUtil:checkRankTip(self._ccbOwner.sp_rank_tips, self._ccbOwner.rank_special_tip)
end

function QUIPageMainMenu:checkSoulTrialTips()
	return remote.soulTrial:redTips()
end

function QUIPageMainMenu:checkFriendTips()
	if self:getPageMainMenuIcon() then
		self:getPageMainMenuIcon():setIconWidgetRedTips("node_friend", remote.friend:checkFriendCanGetEnergy() or remote.friend:checkFriendHasApply())
	end
end

function QUIPageMainMenu:getPageMainMenuIcon()
	return self._pageMainMenuIcon
end

function QUIPageMainMenu:setTutorialModel(boo)
	if self:getPageMainMenuIcon() then
		self:getPageMainMenuIcon():setTutorialModel(boo)
	end
end

function QUIPageMainMenu:checkArchaeologyTips()
	local archaeologyInfos = QStaticDatabase:sharedDatabase():getArcharologyConfig()
	if not remote.user.archaeologyInfo then 
		-- wow-10672
		local info = archaeologyInfos["1001"]
		return info.cost <= (remote.user.archaeologyMoney or 0)
		-- return true 
	end
	
	local archaeologyId = remote.user.archaeologyInfo.last_enable_fragment_id
	local info = nil
	if archaeologyId then
		local luckyDrawMask = remote.user.archaeologyInfo.lucky_draw_mark
		for key, value in pairs(archaeologyInfos) do
			if value.id <= archaeologyId then
				if value.reward_index and not string.find(luckyDrawMask, tostring(value.id)) then
					return true
				end
			end
		end

		if archaeologyId == (1000 + table.nums(archaeologyInfos)) then return false end -- add by kumo 考古全部点亮了之后，不显示小红点
		if archaeologyId == 0 then
			info = archaeologyInfos["1001"]
		elseif archaeologyInfos[tostring(archaeologyId+1)] ~= nil then
			info = archaeologyInfos[tostring(archaeologyId+1)]
		else
			info = archaeologyInfos[tostring(archaeologyId)]
		end
	else
		-- wow-10672
		info = archaeologyInfos["1001"]
		return info.cost <= (remote.user.archaeologyMoney or 0)
		-- return true
	end

	if next(info) then
		return info.cost <= (remote.user.archaeologyMoney or 0)
	end
	return false
end

function QUIPageMainMenu:_checkShopRedTips()
	self._ccbOwner.shop_tips:setVisible(false)
	
	if remote.stores:checkShopRedTips() then 
		self._ccbOwner.shop_tips:setVisible(true)
	end
end

function QUIPageMainMenu:_checkInvasionRedTips()
	self._pageMainMenuUtil:checkInvasionRedTips(self._ccbOwner.invasion_tips, self._ccbOwner.invasion_sepcial_tip)
end

function QUIPageMainMenu:_checkFirstRechargeState()
	if not self:getPageMainMenuIcon() then return end

	self:getPageMainMenuIcon():setIconNodeVisible("node_firstRecharge", false)
	self:getPageMainMenuIcon():setIconWidgetRedTips("node_firstRecharge", false)
	if ENABLE_FIRST_RECHARGE then
		local isVisible, index, tipVisible = self._pageMainMenuUtil:checkFirstRechargeStated("node_firstRecharge")
		self:getPageMainMenuIcon():setIconNodeVisible("node_firstRecharge", isVisible)
		self:getPageMainMenuIcon():setIconWidgetRedTips("node_firstRecharge", tipVisible)
		if isVisible and index ~= self._firstRechargeType then 
			self._firstRechargeType = index
			self:getPageMainMenuIcon():updateIconWidget("node_firstRecharge", self._firstRechargeType)
		end
	end
end

function QUIPageMainMenu:_checkRechargeAward()
	if self:getPageMainMenuIcon() then
		self:getPageMainMenuIcon():setIconWidgetRedTips("node_recharge", remote.stores:checkVipAwardRedTips())
	end
end

function QUIPageMainMenu:_onVipLevelUp()
	self:_checkRechargeAward()
	self:_activityUpdateHander()

	remote.stores:getBlackShopIsUnlock(QVIPUtil:VIPLevel(), true)
end

function QUIPageMainMenu:_checkTimeMachineRedTips()
	self._ccbOwner.timeMachine_tips:setVisible(false)

	if not app.unlock:getUnlockTimeTransmitter(false) then
		return 
	end

	local weekday = tonumber(q.date("%w", q.serverTime()-(remote.user.c_systemRefreshTime*3600)))
	local aList = {}
	if weekday == 0 then
		aList = {app.unlock:checkLock("UNLOCK_BPPTY_BAY") and 1 or nil, 
					app.unlock:checkLock("UNLOCK_DWARF_CELLAR") and 2 or nil, 
					app.unlock:checkLock("UNLOCK_STRENGTH_TRIAL") and 3 or nil, 
					app.unlock:checkLock("UNLOCK_SAPIENTIAL_TRIAL") and 4 or nil}
	elseif weekday == 1 or weekday == 3 or weekday == 5 then
		aList = {app.unlock:checkLock("UNLOCK_BPPTY_BAY") and 1 or nil, 
					app.unlock:checkLock("UNLOCK_DWARF_CELLAR") and 2 or nil,
					app.unlock:checkLock("UNLOCK_STRENGTH_TRIAL") and 3 or nil,}
	else
		aList = {app.unlock:checkLock("UNLOCK_BPPTY_BAY") and 1 or nil, 
					app.unlock:checkLock("UNLOCK_DWARF_CELLAR") and 2 or nil,
					app.unlock:checkLock("UNLOCK_SAPIENTIAL_TRIAL") and 4 or nil}
	end

	for k, v in pairs(aList) do
		if QUIDialogTimeMachine:_freeFightAvailable(v) then
			self._ccbOwner.timeMachine_tips:setVisible(true)
			return 
		end
	end
end

function QUIPageMainMenu:_onMailDataUpdate(event)
	if self:getPageMainMenuIcon() then
		self:getPageMainMenuIcon():setIconWidgetRedTips("node_mail", remote.mails:checkMailRedTips())
	end
end

function QUIPageMainMenu:checkActivityUnlock()	
	if not self:getPageMainMenuIcon() then return end
	-- 嘉年华
	if app.unlock:checkLock("UNLOCK_CARNIVAL") then 
		self:getPageMainMenuIcon():setIconNodeVisible("node_active_qiri", remote.activity:checkIsAllComplete(remote.activity.TYPE_ACTIVITY_FOR_SEVEN))
		self:getPageMainMenuIcon():setIconNodeVisible("node_active_banyue", remote.activity:checkIsAllComplete(remote.activity.TYPE_ACTIVITY_FOR_SEVEN_2))
	else
		self:getPageMainMenuIcon():setIconNodeVisible("node_active_qiri", false)
		self:getPageMainMenuIcon():setIconNodeVisible("node_active_banyue", false)
	end
	
	--7日登录活动
	if app.unlock:checkLock("UNLOCK_SEVEN_ENTRY") then 
		-- self:getPageMainMenuIcon():setIconNodeVisible("node_sevenday", remote.activity:checkSevenEntryAllComplete(remote.activity.TYPE_SEVEN_ENTRY1))
		-- self:getPageMainMenuIcon():setIconNodeVisible("node_fourteenday", remote.activity:checkSevenEntryAllComplete(remote.activity.TYPE_FOURTEEN_ENTRY1))
		self:getPageMainMenuIcon():setIconNodeVisible("node_sevenday", remote.activity:checkSevenEntryAllCompleteNew(remote.activity.TYPE_ACTIVITY_TYPE_1_7_DAY_NEW))
		local isCompleteFourteenday = remote.activity:checkSevenEntryAllCompleteNew(remote.activity.TYPE_ACTIVITY_TYPE_8_14_DAY_NEW)
		local loginDaysCount = remote.user.loginDaysCount or 0
		local isShowFourteenday = isCompleteFourteenday and loginDaysCount > 7
		self:getPageMainMenuIcon():setIconNodeVisible("node_fourteenday", isShowFourteenday)		

		local index, isShowTime ,day = remote.activity:checkSevenEntryPageMainViewIcon(remote.activity.TYPE_ACTIVITY_TYPE_1_7_DAY_NEW)
		if index then
			if day== 2 then
				self:getPageMainMenuIcon():updateIconWidget("node_sevenday", 1)
			else
				self:getPageMainMenuIcon():updateIconWidget("node_sevenday", 2)
			end
		else
			self:getPageMainMenuIcon():updateIconWidget("node_sevenday", 3)
		end

		if isShowTime then
			if self._schedulerSevenDayTime then
				scheduler.unscheduleGlobal(self._schedulerSevenDayTime)
				self._schedulerSevenDayTime = nil
			end
			self:_updateSevenDyaTime()
			self._schedulerSevenDayTime = scheduler.scheduleGlobal(function ()
				self:_updateSevenDyaTime()
			end, 1)
			self:getPageMainMenuIcon():isIconWidgetShowCountDown("node_sevenday", true)
		else
			self:getPageMainMenuIcon():isIconWidgetShowCountDown("node_sevenday", false)
		end

		--7日活动提示
		self:getPageMainMenuIcon():setIconWidgetRedTips("node_sevenday", remote.activity:checkActivitySevenEntryAwrdsTip(remote.activity.TYPE_ACTIVITY_TYPE_1_7_DAY_NEW))
		self:getPageMainMenuIcon():setIconWidgetRedTips("node_fourteenday", remote.activity:checkActivitySevenEntryAwrdsTip(remote.activity.TYPE_ACTIVITY_TYPE_8_14_DAY_NEW))
	else
		self:getPageMainMenuIcon():setIconNodeVisible("node_sevenday", false)
		self:getPageMainMenuIcon():setIconNodeVisible("node_fourteenday", false)
	end

	-- 月度签到
	if remote.monthSignIn:checkMonthSignInIsOpen() then
		self:getPageMainMenuIcon():setIconNodeVisible("node_month_signin", true)
		self:getPageMainMenuIcon():setIconWidgetRedTips("node_month_signin", remote.monthSignIn:checkMonthSignInRedTips())
	else
		self:getPageMainMenuIcon():setIconNodeVisible("node_month_signin", false)
	end

	-- 玩法日历
	if remote.calendar:checkCalendarInIsOpen() then
		self:getPageMainMenuIcon():setIconNodeVisible("node_calendar", true)
		self:getPageMainMenuIcon():setIconWidgetRedTips("node_calendar", remote.calendar:checkCalendarRedTips())
	else
		self:getPageMainMenuIcon():setIconNodeVisible("node_calendar", false)
	end

	if app.unlock:checkLock("UNLOCK_SECRETARY") then 
		self:getPageMainMenuIcon():setIconNodeVisible("node_secretary", true)
		self:getPageMainMenuIcon():setIconNodeVisible("node_calendar", false)
		self:getPageMainMenuIcon():setIconWidgetRedTips("node_secretary", remote.secretary:checkSecretaryRedTip())
		if app.tutorial and app.tutorial:isTutorialFinished() == false and app.tutorial:getRuningStageId() == QTutorialDirector.Stage_Secretary then
			self:getPageMainMenuIcon():setIconNodeVisible("node_calendar", true)
		end
	else
		self:getPageMainMenuIcon():setIconNodeVisible("node_secretary", false)
	end

	-- 成就icon
	self:getPageMainMenuIcon():setIconNodeVisible("node_achieve", false)
	if remote.soulSpirit:checkSoulSpiritUnlock() then
		self:getPageMainMenuIcon():setIconNodeVisible("node_achieve", true)
		self:getPageMainMenuIcon():setIconWidgetRedTips("node_achieve", remote.achieve.achieveDone)
		if app.tutorial and app.tutorial:isTutorialFinished() == false and app.tutorial:getRuningStageId() == QTutorialDirector.Stage_SoulSpirit then
			self:getPageMainMenuIcon():setIconNodeVisible("node_achieve", false)
		end
	end

	-- 任务icon
	self:getPageMainMenuIcon():setIconNodeVisible("node_task", false)
	if remote.godarm:checkGodArmUnlock() then
		self:getPageMainMenuIcon():setIconNodeVisible("node_task", true)
		self:getPageMainMenuIcon():setIconWidgetRedTips("node_task", remote.task:checkAllTask())
		-- if app.tutorial and app.tutorial:isTutorialFinished() == false and app.tutorial:getRuningStageId() == QTutorialDirector.Stage_SoulSpirit then
		-- 	self:getPageMainMenuIcon():setIconNodeVisible("node_task", false)
		-- end
	end	

	--天降福袋活动icon
	self:getPageMainMenuIcon():setIconNodeVisible("node_activite_skyfall",false)
	if remote.activityRounds:getSkyFall() and remote.activityRounds:getSkyFall():checkSkyFallIsOpen() then
		self:getPageMainMenuIcon():setIconNodeVisible("node_activite_skyfall",true)
		self:getPageMainMenuIcon():setIconWidgetRedTips("node_activite_skyfall",remote.activityRounds:getSkyFall():checkRedTips())
	end


	--游戏中心 现在只针对Vivo平台的游戏中心链接
	self:getPageMainMenuIcon():setIconNodeVisible("node_game_center",false)
	if remote.activity:checkHaveChannelGameCenterAty() then
		local redTip = remote.activity:checkGameCenterRedTip()
		self:getPageMainMenuIcon():setIconNodeVisible("node_game_center",true)
		self:getPageMainMenuIcon():setIconWidgetRedTips("node_game_center", redTip)
	end	


	self:getPageMainMenuIcon():setIconNodeVisible("node_master",true)
	if FinalSDK.getChannelID() == "14" and app:getOpgameID() == "3003" then
		self:getPageMainMenuIcon():setIconNodeVisible("node_master",false)
	end	


	self:getPageMainMenuIcon():setIconNodeVisible("node_yingyongbao",false)
	local isShow , config = remote.activity:checkHaveYingyongbaoBafu()
	if isShow then
		self:getPageMainMenuIcon():setIconNodeVisible("node_yingyongbao",true)
	end	

end

function QUIPageMainMenu:_activityUpdateHander(event)
	if self:getPageMainMenuIcon() then
		-- 精彩活动
		self:getPageMainMenuIcon():setIconNodeVisible("node_activity", remote.activity:checkIsAllThemeComplete(remote.activity.THEME_ACTIVITY_NORMAL))
		self:getPageMainMenuIcon():setIconWidgetRedTips("node_activity", remote.activity:checkIsThemeComplete(remote.activity.THEME_ACTIVITY_NORMAL))

		-- 限时活动
		self:getPageMainMenuIcon():setIconNodeVisible("node_active_limit", remote.activity:checkIsAllThemeComplete(remote.activity.THEME_ACTIVITY_LIMIT))
		self:getPageMainMenuIcon():setIconWidgetRedTips("node_active_limit", remote.activity:checkIsThemeComplete(remote.activity.THEME_ACTIVITY_LIMIT))

		self:getPageMainMenuIcon():setIconNodeVisible("node_comeback", remote.userComeBack:checkComeBackStated())
	end

	self:_checkRedTip()

	-- 双周活动
	self:checkActivitySevenTip()

	--xurui: 检查倍率活动
	self:checkRateActivity()

	-- 等级开启活动
	self:checkActivityUnlock()

	-- 节日狂欢活动
	self._pageMainMenuUtil:checkCarnivalActivity(self)

	-- 在线提示功能
	self._pageMainMenuUtil:checkPrompt(self)

	self:quickButtonAutoLayout()
end

function QUIPageMainMenu:checkActivitySevenTip()
	if not self:getPageMainMenuIcon() then return end

	self:getPageMainMenuIcon():setIconWidgetRedTips("node_active_qiri", false)
	if remote.activity:checkIsComplete(remote.activity.TYPE_ACTIVITY_FOR_SEVEN) or remote.activity:checkActivitySevenAwrdsTip(1) then
		self:getPageMainMenuIcon():setIconWidgetRedTips("node_active_qiri", true)
	end

	self:getPageMainMenuIcon():setIconWidgetRedTips("node_active_banyue", false)
	if remote.activity:checkIsComplete(remote.activity.TYPE_ACTIVITY_FOR_SEVEN_2) or remote.activity:checkActivitySevenAwrdsTip(2) then
		self:getPageMainMenuIcon():setIconWidgetRedTips("node_active_banyue", true)
	end
end

-- 转盘，团购，幸运夺宝、铸造
function QUIPageMainMenu:setActivityRoundVisible(  )
	if not self:getPageMainMenuIcon() then return end

	local isTurntableOpen = false
	local isGroupBuyOpen = false
	local isRushBuyOpen = false
	if remote.activityRounds:getPrizaWheel() and remote.activityRounds:getPrizaWheel().isOpen then
		isTurntableOpen = true
		if remote.activityRounds:getPrizaWheel():checkRedTips() then
			self:getPageMainMenuIcon():setIconWidgetRedTips("node_active_turntable", true)
		else
			self:getPageMainMenuIcon():setIconWidgetRedTips("node_active_turntable", false)
		end
	end
	if remote.activityRounds:getGroupBuy() and remote.activityRounds:getGroupBuy().isOpen then
		isGroupBuyOpen = true
		if remote.activityRounds:getGroupBuy():checkRedTips() then
			self:getPageMainMenuIcon():setIconWidgetRedTips("node_active_groupbuy", true)
		else
			self:getPageMainMenuIcon():setIconWidgetRedTips("node_active_groupbuy", false)
		end
	end

	if remote.activityRounds:getRushBuy() and remote.activityRounds:getRushBuy().isOpen then
		isRushBuyOpen = true
	end

	self:getPageMainMenuIcon():setIconNodeVisible("node_active_turntable", isTurntableOpen)
	self:getPageMainMenuIcon():setIconNodeVisible("node_active_groupbuy", isGroupBuyOpen)
	self:getPageMainMenuIcon():setIconNodeVisible("node_active_rushBuy", isRushBuyOpen)
end

function QUIPageMainMenu:_activityTurntableUpdateHander(event)
	if not self:getPageMainMenuIcon() then return end

    local prizeWheelRound = remote.activityRounds:getPrizaWheel()
    if prizeWheelRound then
    	local isChange = self:getPageMainMenuIcon():setIconNodeVisible("node_active_turntable", prizeWheelRound.isOpen)
		if isChange then
			self:quickButtonAutoLayout()
		end
		self:getPageMainMenuIcon():setIconWidgetRedTips("node_active_turntable", prizeWheelRound:checkRedTips())
	end
end

function QUIPageMainMenu:_activitySkyFallUpdateHander( event )
	if not self:getPageMainMenuIcon() then return end
	local skyFallRound = remote.activityRounds:getSkyFall()
	if skyFallRound then
		local isChange = self:getPageMainMenuIcon():setIconNodeVisible("node_activite_skyfall", skyFallRound:checkSkyFallIsOpen())
		if isChange then
			self:quickButtonAutoLayout()
		end
		self:getPageMainMenuIcon():setIconWidgetRedTips("node_activite_skyfall", skyFallRound:checkRedTips())
	end
end
function QUIPageMainMenu:_activityGroupBuyUpdateHander(event)
	if not self:getPageMainMenuIcon() then return end

	local isChange = self:getPageMainMenuIcon():setIconNodeVisible("node_active_groupbuy", remote.activityRounds:getGroupBuy().isOpen)
	local data = event and event.data
	self:getPageMainMenuIcon():setIconWidgetRedTips("node_active_groupbuy", remote.activityRounds:getGroupBuy():checkRedTips(data))
	if isChange then
		self:quickButtonAutoLayout()
	end
end

function QUIPageMainMenu:_activityRushBuyUpdateHander(event)
	if not self:getPageMainMenuIcon() then return end

	local isChange = self:getPageMainMenuIcon():setIconNodeVisible("node_active_rushBuy", remote.activityRounds:getRushBuy().isOpen)
	if isChange then
		self:quickButtonAutoLayout()
	end
end

function QUIPageMainMenu:_activitySoulLetterEndHander(event)
	self:quickButtonAutoLayout()
end

function QUIPageMainMenu:_blackrockSendInviteHandler(e)
	if self._pageMainMenuUtil:canNotShowInvite() then
		return
	end
	local sendInfo = e.sendInfo
    app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogBlackRockInviteAlert",
        options = {sendInfo = sendInfo}}, {isPopCurrentDialog = false})
end

function QUIPageMainMenu:_silvesArenaSendInviteHandler(e)
	if self._pageMainMenuUtil:canNotShowInvite() then
		return
	end	
	local sendInfo = e.sendInfo
    app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogSilvesArenaInvitePoster",
        options = {sendInfo = sendInfo}}, {isPopCurrentDialog = false})
end

function QUIPageMainMenu:checkRateActivity()
	self:_checkArenaTips()

	self:_checkThunderTips()

	self:_checkSunwarTips()

	self:_checkTowerTips()

	self:_onSilverMineAssistUpdate()

	self:_checkInstanceTips()
end

-- 魂兽森林援助刷新
function QUIPageMainMenu:_onSilverMineAssistUpdate()
	self._pageMainMenuUtil:checkSilvermineTip(self._ccbOwner.silvermine_tips, self._ccbOwner.silvermine_special_tip)
end

--整点 5点 时 刷新一下主界面  （主要解决 8-14日活动 整点不刷新出来问题）
function QUIPageMainMenu:_onTimeRefreshHandler( event )
	self:_activityUpdateHander(event)
	
end

function QUIPageMainMenu:_checkVerifyWechatAndPhoneNumber()
	local unlockLevel = QStaticDatabase:sharedDatabase():getConfigurationValue("VERIFY_UNLOCK_LEVEL")
	if unlockLevel == nil then 
		unlockLevel = 0 
	else
		unlockLevel = tonumber(unlockLevel)
	end

	self._ccbOwner.verify_node:setVisible(false)

	if ENABLE_WECHAT_VERIFY then
		if remote.user.level >= unlockLevel and (remote.user.mobileAuth ~= true or remote.user.mobileAward ~= true or ((remote.user.wechatAward ~= true) and ENABLE_WECHAT_VERIFY)) then
			self._ccbOwner.verify_node:setVisible(true)
		end
	end
end

function QUIPageMainMenu:_onUserDataUpdate(event)
	self._userData = remote.user
	local userleveltext = self._ccbOwner.CCLabelTFF_CharacterLevel
	if nil ~= userleveltext then
	end

	-- self._topRegion[3]:update(2, tostring(remote.user.energy), global.config.max_energy)

	--设置人物头像信息
	self:setHeadInfo(self._userData)

	self:_checkLockBuilding()
	-- self:_checkMystoryStores()
	self:_checkTimeMachineRedTips()
end

function QUIPageMainMenu:_timeMachineTimeout()
	self:_checkTimeMachineRedTips()
end

function QUIPageMainMenu:_onHeroDataUpdate(event)
	if table.nums(self._subViewControllers) == 0 then
		self._headInfo:setBattleForce()
	end
end

function QUIPageMainMenu:quickButtonAutoLayout()
	self:getPageMainMenuIcon():refreshIcon()
	self:_initRedPoiontAndMenuIcon()
end

--设置建筑是否解锁
function QUIPageMainMenu:_checkLockBuilding()
	for k, v in pairs(unlockTable) do
		local config = app.unlock:getConfigByKey(v.config)
		if config ~= nil then
			if remote.user.level >= config.team_level then
				if self._ccbOwner[v.enable] then self._ccbOwner[v.enable]:setVisible(true) end
				if self._ccbOwner[v.disable] then self._ccbOwner[v.disable]:setVisible(false) end
				if self._ccbOwner[v.button] then self._ccbOwner[v.button]:setEnabled(true) end
				for animation, timeLine in pairs(v.animations) do
					if self._ccbOwner[animation] then
						local animationManager = tolua.cast(self._ccbOwner[animation]:getUserObject(), "CCBAnimationManager")
					    if animationManager ~= nil then 
		    				animationManager:runAnimationsForSequenceNamed(timeLine)
					    end
					end
				end

				if v.effectNodes then
					for _, effectNode in ipairs(v.effectNodes) do
						if self._ccbOwner[effectNode] then
							self._ccbOwner[effectNode]:setVisible(true)
						end
					end
				end
			else
				if self._ccbOwner[v.enable] then self._ccbOwner[v.enable]:setVisible(false) end
				if self._ccbOwner[v.disable] then self._ccbOwner[v.disable]:setVisible(true) end
				if self._ccbOwner[v.button] then self._ccbOwner[v.button]:setEnabled(true) end
				if remote.user.level + unlockVisibleLevelGap < config.team_level then
					if self._ccbOwner[v.disable] then
						self._ccbOwner[v.disable]:setVisible(false)
					end
					if self._ccbOwner[v.button] then
						self._ccbOwner[v.button]:setEnabled(false)
					end
				end

				if v.effectNodes then
					for _, effectNode in ipairs(v.effectNodes) do
						if self._ccbOwner[effectNode] then
							self._ccbOwner[effectNode]:setVisible(false)
						end
					end
				end
			end
		else
			if self._ccbOwner[v.disable] then
				self._ccbOwner[v.disable]:setVisible(false)
			end
			if self._ccbOwner[v.button] then
				self._ccbOwner[v.button]:setEnabled(false)
			end
		end
	end

	--检查好友
	self._ccbOwner.node_friend:setVisible(app.unlock:getUnlockFriend())

	-- 老玩家回归
	self._ccbOwner.node_comeback:setVisible(remote.userComeBack:checkComeBackStated())

	-- 老玩家回歸老服版
	self._ccbOwner.node_player_recall:setVisible(remote.playerRecall:isOpen())

	self:_checkFuli()

	self:_checkGradePackage()

	self:quickButtonAutoLayout()
end

function QUIPageMainMenu:_checkFuli()
	-- 检查福利追回
	if remote.rewardRecover:isShowFuliIcon() then
		self._ccbOwner.node_fuli:setVisible(true)
		-- 和时间有关的数据
		self:_updateTime()
		if self._schedulerFuli then
			scheduler.unscheduleGlobal(self._schedulerFuli)
			self._schedulerFuli = nil
		end
		self._schedulerFuli = scheduler.scheduleGlobal(function ()
			self:_updateTime()
		end, 1)
	else
		if self._schedulerFuli then
			scheduler.unscheduleGlobal(self._schedulerFuli)
			self._schedulerFuli = nil
		end
		self._ccbOwner.node_fuli:setVisible(false)
	end
end

function QUIPageMainMenu:_updateTime()
	local isOvertime, timeStr, color = remote.rewardRecover:updateTime()
	if not isOvertime then
		self:getPageMainMenuIcon():setIconWidgetCountDown("node_fuli", timeStr)
	else
		self:getPageMainMenuIcon():setIconWidgetCountDown("node_fuli", "00:00:00")
		if self._schedulerFuli then
			scheduler.unscheduleGlobal(self._schedulerFuli)
			self._schedulerFuli = nil
		end
		self._ccbOwner.node_fuli:setVisible(false)
		self:quickButtonAutoLayout()
	end
	self:getPageMainMenuIcon():isIconWidgetShowCountDown("node_fuli", true)
	-- self._ccbOwner.tf_fuli_countdown:setColor( color )
end

function QUIPageMainMenu:_updateSevenDyaTime()
	local sec = q.getLeftTimeOfDay(q.serverTime(), 0)

	local h = math.floor((sec/3600)%24)
	local m = math.floor((sec/60)%60)
	local s = math.floor(sec%60)

	local timeStr = string.format("%02d:%02d:%02d", h, m, s)
	local color = COLORS.A
	if h>0 then
		timeStr = string.format("%dh后可领",h)
	elseif m > 0 then
		timeStr = string.format("%dm后可领",m)
	else
		timeStr = string.format("%ds后可领",s)
		color = COLORS.m
	end

	self:getPageMainMenuIcon():setIconWidgetCountDown("node_sevenday", timeStr, color)
end

function QUIPageMainMenu:_checkGradePackage()
	-- 检查等级礼包
	local isShow,unlockTime = remote.gradePackage:checkGradePakgeShowToPageMain()
	if isShow then
		self._ccbOwner.node_gradePackage:setVisible(true)
		-- 和时间有关的数据
		self._gradePackageTime = unlockTime
		self:_updateGradePackageTime()
		if self._schedulerGradePackage then
			scheduler.unscheduleGlobal(self._schedulerGradePackage)
			self._schedulerGradePackage = nil
		end
		self._schedulerGradePackage = scheduler.scheduleGlobal(function ()
			self:_updateGradePackageTime()
		end, 1)
	else
		if self._schedulerGradePackage then
			scheduler.unscheduleGlobal(self._schedulerGradePackage)
			self._schedulerGradePackage = nil
		end
		self._ccbOwner.node_gradePackage:setVisible(false)
	end
end

function QUIPageMainMenu:_updateGradePackageTime()
	local isOvertime, timeStr, color = remote.gradePackage:updateTime(self._gradePackageTime)
	if not isOvertime then
		self:getPageMainMenuIcon():setIconWidgetCountDown("node_gradePackage", timeStr)
	else
		self:getPageMainMenuIcon():setIconWidgetCountDown("node_gradePackage", "00:00:00")
		if self._schedulerUnLockTime then
			scheduler.unscheduleGlobal(self._schedulerUnLockTime)
			self._schedulerUnLockTime = nil
		end
		self._ccbOwner.node_gradePackage:setVisible(false)
	end
	self:getPageMainMenuIcon():isIconWidgetShowCountDown("node_gradePackage", true)
end

function QUIPageMainMenu:_onTowerGloryArenaYaoqing()
	local firstDialog = app:getNavigationManager():getController(app.mainUILayer):getTopDialog()
	local firstPage = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
	if firstDialog == nil and firstPage.class.__cname == "QUIPageMainMenu" then
		remote.tower:showYaoqing()
	end
end


function QUIPageMainMenu:_onTowerStateChange( ... )
	self:_checkRedTip()
end

--滑动距离，是否有惯性
function QUIPageMainMenu:screenMove(distance, isSlider)
	self._pageSilder:moveToPos(ccp(distance, 0), isSlider)
end


--回退到主界面
function QUIPageMainMenu:onBackPage()
	self:setAllUIVisible(true)
	self:setScalingVisible(true)
	self:setBackBtnVisible(false)
	self:setHomeBtnVisible(false)
	self:setChatButton(true)

	-- 检查小娜娜提醒
	self:checkHelpNodeCanShow()
	
	self:_enableBackImage(false)

    QDeliveryWrapper:setBuglyTag(88171)

	self:getScheduler().performWithDelayGlobal(self:safeHandler(function()
		if app.tutorial and app.tutorial:isInTutorial() then
		elseif self:checkGuiad() then
			-- 动漫联动邮件
			self._pageMainMenuUtil:checkAnimationLinkage(function()
				-- 主题曲正式活动弹脸
				self._pageMainMenuUtil:checkZhangbichenFormalPrompt(function()
					self:checkYaoqing()
				end)
			end)
		end
	end), 0)
end

--检测玩法 邀请函
function QUIPageMainMenu:checkYaoqing()
	if self:checkSanctuary() then
	elseif self:checkConsortiaWar() then
	elseif self:checkUnionPlunder() then
	elseif self:checkWorldBoss() then
	elseif self:checkGloryArenaYaoqing() then
	end
end

--检测斗魂场 邀请函
function QUIPageMainMenu:checkGloryArenaYaoqing(  )
	-- body
	if remote.tower:isNeedShowYaoqing() then
		remote.tower:showYaoqing()
		return true
	end
	return false
end

-- 检测宗门战 邀请函
function QUIPageMainMenu:checkUnionPlunder(isOpenPrompt)
	local _, _, isActive, isOpen = remote.plunder:updateTime()
	local isClick = app:getUserOperateRecord():compareCurrentTimeWithRecordeTime(DAILY_TIME_TYPE.UNION_PLUNDER, 5)
	local isHaveUnion = remote.user.userConsortia.consortiaId ~= nil and remote.user.userConsortia.consortiaId ~= ""
	
	if isOpenPrompt then
		if app.unlock:checkLock("UNLOCK_UNION") and isHaveUnion and remote.plunder:checkPlunderUnlock() and isOpen and isClick then
			app:getUserOperateRecord():recordeCurrentTime(DAILY_TIME_TYPE.UNION_PLUNDER)
			app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogUnionPlunderInvitation"})
			return true
		end
	else
		if app.unlock:checkLock("UNLOCK_UNION") and isHaveUnion and remote.plunder:checkPlunderUnlock() and isActive and isClick then
			app:getUserOperateRecord():recordeCurrentTime(DAILY_TIME_TYPE.UNION_PLUNDER)
			app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogUnionPlunderInvitation"})
			return true
		end
	end
	return false
end

-- 检测世界boss 邀请函
function QUIPageMainMenu:checkWorldBoss()
	local isUnlock = remote.worldBoss:checkWorldBossIsUnlock()
	local isClick = app:getUserOperateRecord():compareCurrentTimeWithRecordeTime(DAILY_TIME_TYPE.WORLDBOSS, 12)

	if app.unlock:getUnlockWorldBoss() and isUnlock and isClick then
		app:getUserOperateRecord():recordeCurrentTime(DAILY_TIME_TYPE.WORLDBOSS)
		app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogWorldBossInvitation"})
		return true
	end
	return false
end

-- 检测全大陆精英赛 邀请函
function QUIPageMainMenu:checkSanctuary()
	if not remote.sanctuary:checkSanctuaryIsOpen() then
		return false
	end

	local showNum, isAllEnd = remote.sanctuary:checkGameShowTips()
	local lastShowNum = app:getUserOperateRecord():getSanctuaryShowAnnouce(1) or 4 --默认4避免新玩家休赛期弹出
	if showNum ~= 0 and showNum ~= lastShowNum then
		app:getUserOperateRecord():setSanctuaryShowAnnouce(1, showNum)
		if isAllEnd then
			app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogSanctuaryAnnounce", options = {isResult = true}}, {isPopCurrentDialog = false})
		else
			app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogSanctuaryInvitation"})
		end
		return true
	end
	return false
end

-- 宗门战 邀请函
function QUIPageMainMenu:checkConsortiaWar()
	local isHaveUnion = remote.user.userConsortia.consortiaId ~= nil and remote.user.userConsortia.consortiaId ~= ""
	if not isHaveUnion or not app.unlock:checkLock("UNLOCK_CONSORTIA_WAR") then
		return false
	end

	local isShow = remote.consortiaWar:checkGameShowTips()
	local lastShowNum = app:getUserOperateRecord():getRecordByType("consortia_war_annouce") or 0
	if isShow then
		if lastShowNum == 0 then
			app:getUserOperateRecord():setRecordByType("consortia_war_annouce", 1)
			app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogConsortiaWarInvitation"})
			return true
		end
	else
		app:getUserOperateRecord():setRecordByType("consortia_war_annouce", 0)
	end
	return false
end

-- 检测是不是需要弹出玩家福利追回
function QUIPageMainMenu:checkRewardRecover(callBack)
	if remote.rewardRecover:IsFirstOpen() then
		remote.rewardRecover:setIsAutoOpened(true)
		app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogRewardRecover", options = {callBack = callBack}})
	else
		if callBack ~= nil then
			callBack()
		end
	end
end

--我的信息 @qinyuanji
function QUIPageMainMenu:_onUserHeadClickHandler()
	app.sound:playSound("common_small")
	return app:getNavigationManager():pushViewController(app.mainUILayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogMyInformation",
		options = {avatar = remote.user.avatar, nickName = remote.user.nickname, exp = remote.user.exp, level = remote.user.level,
			expToNextLevel = db:getExperienceByTeamLevel(remote.user.level),
			heroMaxLevel = db:getTeamConfigByTeamLevel(remote.user.level).hero_limit}})
end

--宝箱
function QUIPageMainMenu:_onCheast(event)
	-- if q.buttonEvent(event, self._ccbOwner.btn_chest) == false then return end
	if q.buttonEvent(event, self._ccbOwner.node_chest) == false then return end
	if self._pageSilder:getIsMoveing() then return end
	-- app.sound:playSound("map_tavern")
	self:hideScaling()
	return app:getNavigationManager():pushViewController(app.mainUILayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogTreasureChestDraw"})
end

function QUIPageMainMenu:_onTriggerCollegeTrain( event )
	if q.buttonEvent(event, self._ccbOwner.sp_collegeTrain_1) == false then return end
	if self._pageSilder:getIsMoveing() then return end
	app.sound:playSound("common_small")

	remote.collegetrain:openMainDialog()
end
function QUIPageMainMenu:_onChatButtonClick()
end

function QUIPageMainMenu:_onInstance(event)
	if q.buttonEvent(event, self._ccbOwner.btn_instance) == false then return end
	if self._pageSilder:getIsMoveing() then return end
	app.sound:playSound("map_dungeon")
	self:hideScaling()
	app:showCloudInterlude(function( cloudInterludeCallBack )
			app:getNavigationManager():pushViewController(app.mainUILayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogMap", options = {cloudInterludeCallBack = cloudInterludeCallBack}})
		end)
end

-- add by Kumo Archaeology
function QUIPageMainMenu:_onArchaeology(event)
	if q.buttonEvent(event, self._ccbOwner.btn_archaeology) == false then return end
	if self._pageSilder:getIsMoveing() then return end
	if app.unlock:getUnlockArchaeology(true) == false then
		return
	end
	app.sound:playSound("map_dungeon")
	self:hideScaling()
	return app:getNavigationManager():pushViewController(app.mainUILayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogArchaeologyClient"})
end

function QUIPageMainMenu:_onArena(event)
	if q.buttonEvent(event, self._ccbOwner.arena_animation) == false then return end
	if self._pageSilder:getIsMoveing() then return end
	self._scaling:willPlayHide()
	app.sound:playSound("map_arena")

	if app.unlock:getUnlockSotoTeam() or remote.silvesArena:checkUnlock() then
		app:getNavigationManager():pushViewController(app.mainUILayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogArenaSubModluesChoose"})
		-- app:getNavigationManager():pushViewController(app.mainUILayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogSotoEntrance"})
	elseif app.unlock:getUnlockArena(true) then
		remote.arena:openArena()
  	end
end

function QUIPageMainMenu:_onStormArena(event)
	if q.buttonEvent(event, self._ccbOwner.node_stormArena) == false then return end
	if self._pageSilder:getIsMoveing() then return end
	self._scaling:willPlayHide()
	app.sound:playSound("map_arena")
	
	remote.stormArena:openDialog()
end


function QUIPageMainMenu:_onMilitaryRank(event)
	if q.buttonEvent(event, self._ccbOwner.btn_glory) == false then return end
	if self._pageSilder:getIsMoveing() then return end
	app.sound:playSound("map_building")
	if app.unlock:getUnlockGloryTower(true) == false then
		return 
	else
		remote.tower:openGloryTower()	
	end
end

function QUIPageMainMenu:_onTriggerBack(event)
    if q.buttonEventShadow(event, self._ccbOwner.btn_back) == false then return end
	app.sound:playSound("common_return")
	self._scaling:willPlayHide()
	QNotificationCenter.sharedNotificationCenter():triggerMainPageEvent(QNotificationCenter.EVENT_TRIGGER_BACK)
end

function QUIPageMainMenu:_onTriggerHome(event)
    if q.buttonEventShadow(event, self._ccbOwner.btn_home) == false then return end
	app.sound:playSound("common_home")
	self._scaling:willPlayHide()
	QNotificationCenter.sharedNotificationCenter():triggerMainPageEvent(QNotificationCenter.EVENT_TRIGGER_HOME)
end

function QUIPageMainMenu:_onBlackMarketShop()
	if self._pageSilder:getIsMoveing() then return end
  		app.sound:playSound("map_building")
  		local unlockVlaue = QStaticDatabase:sharedDatabase():getConfiguration()
  		if app.unlock:getUnlockShop2(true) then
	    	if self.blackMarketShop == false then
	      		app.tip:floatTip("尚未营业，通关副本有几率开启")
	    	else
				self:hideScaling()
	      		app:getNavigationManager():pushViewController(app.mainUILayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogStore", options = {type = SHOP_ID.blackShop}})
	   	 	end
	  end
end

function QUIPageMainMenu:_onGoblinShop()
	if self._pageSilder:getIsMoveing() then return end
	app.sound:playSound("map_building")
end

function QUIPageMainMenu:_onGeneralShop()
	if self._pageSilder:getIsMoveing() then return end
	app.sound:playSound("map_building")

	local unlockVlaue = QStaticDatabase:sharedDatabase():getConfiguration()
	if app.unlock:getUnlockShop(true) then
		self:hideScaling()
		app:getNavigationManager():pushViewController(app.mainUILayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogStore", options = {type = SHOP_ID.generalShop}})
	end
end

function QUIPageMainMenu:_onGoldBattle()
	if self._pageSilder:getIsMoveing() then return end
	app.sound:playSound("map_building")
	local unlockVlaue = QStaticDatabase:sharedDatabase():getConfiguration()
	if app.unlock:getUnlockGoldChallenge(true) then
		self:hideScaling()
		return app:getNavigationManager():pushViewController(app.mainUILayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogGoldBattle"})
	end
end

function QUIPageMainMenu:_onTimeMachine(event)
	if q.buttonEvent(event, self._ccbOwner.btn_time_machine) == false then return end
	if self._pageSilder:getIsMoveing() then return end
	app.sound:playSound("map_building")
	local unlockVlaue = QStaticDatabase:sharedDatabase():getConfiguration()
	if app.unlock:getUnlockTimeTransmitter(true) then
		self:hideScaling()
		return app:getNavigationManager():pushViewController(app.mainUILayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogTimeMachine", options = {initPage = 1}})
	end
end

function QUIPageMainMenu:_onInvasion(event)
	local isEffect = tonumber(event) ~= CCControlEventTouchDown
	self._ccbOwner.sp_invasion_btn:setVisible(not isEffect)
	self._ccbOwner.node_invasion_effect:setVisible(isEffect)
	if q.buttonEvent(event, self._ccbOwner.sp_invasion_btn) == false then return end
	if self._pageSilder:getIsMoveing() then return end
	app.sound:playSound("map_building")
	if app.unlock:getUnlockInvasion(true) then
	    remote.invasion:getInvasionRequest(function(data)
	    	self:hideScaling()
    		remote.stores:getShopInfoFromServerById(SHOP_ID.invasionShop)
	    	return app:getNavigationManager():pushViewController(app.mainUILayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogInvasion", options = {}})
    	end)
	end
end

function QUIPageMainMenu:_onFightClub(event)
	if q.buttonEvent(event, self._ccbOwner.btn_fight_club) == false then return end
	if self._pageSilder:getIsMoveing() then return end
	app.sound:playSound("map_building")
	remote.fightClub:openDialog()
end

function QUIPageMainMenu:_onSanctuary(event)
	if q.buttonEvent(event, self._ccbOwner.btn_sanctuary) == false then return end
	if self._pageSilder:getIsMoveing() then return end
	app.sound:playSound("map_building")
	remote.sanctuary:openDialog()
end

function QUIPageMainMenu:_onSilverMine(event)
	if q.buttonEvent(event, self._ccbOwner.btn_silvermine) == false then return end
	if self._pageSilder:getIsMoveing() then return end
	app.sound:playSound("map_building")
	if ENABLE_SILVER_MINE and app.unlock:getUnlockSilverMine(true) then
		self:hideScaling()
		remote.silverMine:setCurCaveType( SILVERMINEWAR_TYPE.SENIOR )
		app:getNavigationManager():pushViewController(app.mainUILayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogSilverMineMap"})
	end
end

function QUIPageMainMenu:_onTriggerAssistOK(event)
	if self._pageSilder:getIsMoveing() then return end
	app.sound:playSound("map_building")
	if ENABLE_SILVER_MINE and app.unlock:getUnlockSilverMine(true) then
		self:hideScaling()
		remote.silverMine:setCurCaveType( SILVERMINEWAR_TYPE.SENIOR )
		app:getNavigationManager():pushViewController(app.mainUILayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogSilverMineMap"})
	end
end

function QUIPageMainMenu:_onUnion(event)
	if q.buttonEvent(event, self._ccbOwner.btn_union) == false then return end
	if self._pageSilder:getIsMoveing() then return end
	app.sound:playSound("map_building")
	local unlockValue = QStaticDatabase:sharedDatabase():getConfiguration()
	if app.unlock:checkLock("UNLOCK_UNION", true) then
		self._scaling:willPlayHide()
		remote.union:openDialog()
	end
end

function QUIPageMainMenu:_onTriggerMetalCity(event)
	if q.buttonEvent(event, self._ccbOwner.btn_metalcity) == false then return end

	if self._pageSilder:getIsMoveing() then return end
	app.sound:playSound("common_small")
	app:getNavigationManager():pushViewController(app.mainUILayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogMetalCityEntrance"})
	-- remote.metalCity:openDialog()
end

function QUIPageMainMenu:_onTriggerMonopoly(event)
	if q.buttonEvent(event, self._ccbOwner.btn_monopoly) == false then return end

	if self._pageSilder:getIsMoveing() then return end
	app.sound:playSound("common_small")

	remote.monopoly:openDialog()
end


function QUIPageMainMenu:_onTriggerVerify()
	app.sound:playSound("common_small")
	app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogVerify"})
end

function QUIPageMainMenu:_onTriggerThunder(event)
	if q.buttonEvent(event, self._ccbOwner.btn_thunder) == false then return end
	if self._pageSilder:getIsMoveing() then return end
	if app.unlock:getUnlockThunder(true) == false then
		return
	end
	self:hideScaling()
	app.sound:playSound("common_small")
	remote.thunder:openDilaog()
end

function QUIPageMainMenu:_onSunwell(event)
	if q.buttonEvent(event, self._ccbOwner.btn_sunwell) == false then return end
	if self._pageSilder:getIsMoveing() then return end
	app.sound:playSound("common_small")

	if remote.totemChallenge:checkTotemChallengeUnlock() then
		app:getNavigationManager():pushViewController(app.mainUILayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogSunwarEntrance"})
	else
		remote.sunWar:openDialog()
	end

end

function QUIPageMainMenu:_onRank(event)
	if q.buttonEvent(event, self._ccbOwner.btn_Rank) == false then return end
	if self._pageSilder:getIsMoveing() then return end
	app.sound:playSound("common_small")
	app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogRank",
		options = {callbacks = {common = function ( ... ) print("common") end,
				dailyArenaRankCallBack = function ( ... ) print("dailyArenaRankCallBack") end,
				allFightCapacityCallBack = function ( ... ) print("allFightCapacityCallBack") end,
				teamFightCapacityCallBack = function ( ... ) print("teamFightCapacityCallBack") end,
				heroStarCallBack = function ( ... ) print("heroStarCallBack") end,
				allStarCallBack = function ( ... ) print("allStarCallBack") end,
				normalStarCallBack = function ( ... ) print("normalStarCallBack") end,
				eliteStarCallBack = function ( ... ) print("eliteStarCallBack") end,
				achievementPointCallBack = function ( ... ) print("achievementPointCallBack") end,
				realtimeThunderCallBack = function ( ... ) print("realtimeThunderCallBack") end,
				levelCallBack = function ( ... ) print("levelCallBack") end,
				combinationRankCallBack = function ( ... ) print("combinationRankCallBack") end,
				realtimeTowerRankCallBack = function ( ... ) print("realtimeTowerRankCallBack") end,
				dailyTowerRankCallBack = function ( ... ) print("dailyTowerRankCallBack") end,
				realtimeAreaTowerRankCallBack = function ( ... ) print("realtimeAreaTowerRankCallBack") end,
				dailyAreaTowerRankCallBack = function ( ... ) print("dailyAreaTowerRankCallBack") end,
				}
			}
		},
	{isPopCurrentDialog = false})
end

function QUIPageMainMenu:_onTriggerLevelGuide()
	if self._scaling:getScalingStatus() then return end
	app.sound:playSound("common_small")
	-- app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogLevelGuide", 
	-- 	options = {level = remote.user.level, guideType = LEVEL_GOAL.MAIN_MENU}})
	app:getNavigationManager():pushViewController(app.mainUILayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogTrailer", 
		options = {guideType = LEVEL_GOAL.MAIN_MENU}})
end

--点击黑石山
function QUIPageMainMenu:_onTriggerBlackRock(event)
	if q.buttonEvent(event, self._ccbOwner.sp_blackRock_1) == false then return end
	if self._pageSilder:getIsMoveing() then return end
	app.sound:playSound("common_small")
	if remote.soultower:soulTowerIsOpen(false) then
		app:getNavigationManager():pushViewController(app.mainUILayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogSoulTowerEntrance"})
	else
		remote.blackrock:openDialog()
	end
end

-- 海商
function QUIPageMainMenu:_onTriggerMaritime(event)
	if q.buttonEvent(event, self._ccbOwner.btn_maritime) == false then return end
	if self._pageSilder:getIsMoveing() then return end
	app.sound:playSound("common_small")
	remote.maritime:openDialog()
end

function QUIPageMainMenu:_onSoulTrial(event)
	if q.buttonEvent(event, self._ccbOwner.btn_soulTrial) == false then return end
	if self._pageSilder:getIsMoveing() then return end
	if app.unlock:checkLock("SOUL_TRIAL_UNLOCK", true) == false then
        return
    end
	self:hideScaling()
	app.sound:playSound("common_small")
	remote.soulTrial:openSoulTrial()
end


function QUIPageMainMenu:_addDebugButton()
	local menu = CCMenu:create()
	menu:setPosition(0, 0)
	self:getView():addChild(menu)

	self._reLuaButton = ui.newTTFLabelMenuItem( {
		text = "ResetLua",
		font = global.font_monaco,
		size = 30,
		listener = handler(self, QUIPageMainMenu._resetLua),
	} )
	menu:addChild(self._reLuaButton)
	self._reLuaButton:setPosition(80, 229)

	self._gmButton = ui.newTTFLabelMenuItem( {
		text = "Replay",
		font = global.font_monaco,
		size = 30,
		listener = handler(self, QUIPageMainMenu._onLastReplay),
	} )
	menu:addChild(self._gmButton)
	self._gmButton:setPosition(80, 200)

    local debugAppProxy = cc.EventProxy.new(app)
    debugAppProxy:addEventListener(app.APPLICATION_OPEN_URL, function(event)
    	local url = event.url
        if string.sub(url, 1, 7) == "file://" then
            url = string.sub(url, 8)
        end

        local fileutil = CCFileUtils:sharedFileUtils()
        if fileutil:isFileExist(url) then
            local content = nil
            if url and url:sub(-7) == ".reptxt" then
            	local rfile = io.open(url, "r")
            	content = rfile:read("*a")
		        content = crypto.decodeBase64(content)
		        -- writeToBinaryFile("reptxt_out.reppb", content)
		    else
		    	local rfile = io.open(url, "rb")
	            assert(rfile) 
		        content = rfile:read("*a")
		    end
            app:parseBinaryBattleRecord(content)
            if app.battle then
            	if app.scene.curModalDialog then
            		app.scene.curModalDialog:close()
            	end
            	if not app.scene:isEnded() then
            		app.scene:_onAbort()
            	end
            	QReplayUtil:playRecord()
            else
            	QReplayUtil:playRecord()
            end
        end
    end)

	self._gmButton = ui.newTTFLabelMenuItem( {
		text = "GM Tools",
		font = global.font_monaco,
		size = 30,
		listener = handler(self, QUIPageMainMenu._onOpenGMTools),
	} )
	menu:addChild(self._gmButton)
	self._gmButton:setPosition(80, 176)

	self._relaunchButton = ui.newTTFLabelMenuItem( {
		text = "Relaunch",
		font = global.font_monaco,
		size = 30,
		listener = handler(self, QUIPageMainMenu._onRelaunchGame),
	} )
	menu:addChild(self._relaunchButton)
	self._relaunchButton:setPosition(80, 152)

	self._dumpButton = ui.newTTFLabelMenuItem( {
		text = "Dump Texture",
		font = global.font_monaco,
		size = 30,
		listener = handler(self, QUIPageMainMenu._onDumpTexture),
	} )
	menu:addChild(self._dumpButton)
	self._dumpButton:setPosition(116, 128)

	self._serverDBVersion = ui.newTTFLabel( {
		text = "svdb: " .. tostring(remote.dic_version),
		font = global.font_monaco,
		color = display.COLOR_WHITE,
		size = 16 } )
	self:getView():addChild(self._serverDBVersion)
	self._serverDBVersion:setPosition(125, 105)

	self._clientDBVersion = ui.newTTFLabel( {
		text = "cldb: " .. tostring(QStaticDatabase:sharedDatabase():getDicVersion()),
		font = global.font_monaco,
		color = display.COLOR_WHITE,
		size = 16 } )
	self:getView():addChild(self._clientDBVersion)
	self._clientDBVersion:setPosition(125, 80)
end

function QUIPageMainMenu:_onLastReplay()
	local fileutil = CCFileUtils:sharedFileUtils()
	if fileutil:isFileExist(fileutil:getWritablePath() .. "last.reppb") then
		QReplayUtil:play("last.reppb")
	end
end

function QUIPageMainMenu:_onOpenGMTools()
	QUtility:openURL("http://gm.joybest.com.cn")
end

function QUIPageMainMenu:_onRelaunchGame()
	app:relaunchGame(false)
end

function QUIPageMainMenu:_onDumpTexture()
	CCTextureCache:sharedTextureCache():dumpCachedTextureInfo()
	if QUtility.dumpObjectInfos then
		app.ccbNodeCache:purgeCCBNodeCache()
		app:setIsClearSkeletonData(true)
		app:cleanTextureCache();
		QUtility:dumpObjectInfos()
	end
end

-- If receiving new message when dialog is on, scroll the screen at the top position
function QUIPageMainMenu:_onMessageReceived(event)
	if not app.battle and event.channelId and event.channelId ~= app:getServerChatData():teamChannelId() then
		if event.misc.type ~= "blackrock" then
			self._lastChatMsg = {from = event.from, message = event.message, delayed = event.delayed, misc = event.misc, channelId = event.channelId}
		end	
	end
end

function QUIPageMainMenu:_onMessageSent(event)
	if not app.battle and event.channelId and event.channelId ~= app:getServerChatData():teamChannelId() then
		self._lastChatMsg = {from = remote.user.userId, message = event.message, delayed = false, misc = event.misc, channelId = event.channelId}
	end
end

-- When bulletin message is received, hide widget chat 
function QUIPageMainMenu:_onBulletinMessageReceived(event)
	self.widgetChat:setChatAreaVisible(false)
	self._hideWidgetChat = true
end

function QUIPageMainMenu:_onNoMoreNotice()
	self.widgetChat:setChatAreaVisible(true)
	self._hideWidgetChat = false
	self:_onGlobalMessage()
end

function QUIPageMainMenu:_onGlobalMessage()
	if self._lastChatMsg and not self._hideWidgetChat then
		self.widgetChat:updatePage(self._lastChatMsg)
		self._lastChatMsg = nil
	end
end

function QUIPageMainMenu:_chestIsFree()
	self:_checkRedTip()
end

function QUIPageMainMenu:_enableBackImage(enable)
	if self._isPrepareToRemove == false then
		if enable then
			self._ccbOwner.node_bj1:setVisible(true)

			self:_updateBgSprite()

			self._ccbOwner.node_bj1:setVisible(false)
			self._ccbOwner.node_bj2:setVisible(true)
		else
			self._ccbOwner.node_bj1:setVisible(true)
			self._ccbOwner.node_bj2:setVisible(false)
		end
	end
end

function QUIPageMainMenu:_onDialogPopup()
	local mainUILayerController = app:getNavigationManager():getController(app.mainUILayer)
	local middleLayerController = app:getNavigationManager():getController(app.middleLayer)

	if mainUILayerController:getTopDialog() ~= nil 
		or middleLayerController:getTopDialog() ~= nil then
		self:_enableBackImage(true)
	end
end

function QUIPageMainMenu:_onDialogClosed()
	self._dialogCloseSchedulerHander = self:getScheduler().performWithDelayGlobal(function()
		self._dialogCloseSchedulerHander = nil
		local mainUILayerController = app:getNavigationManager():getController(app.mainUILayer)
		local middleLayerController = app:getNavigationManager():getController(app.middleLayer)

		if mainUILayerController:getTopPage() ~= nil and mainUILayerController:getTopPage().__cname == "QUIPageMainMenu"
			and mainUILayerController:getTopDialog() == nil 
			and middleLayerController:getTopDialog() == nil then
			self:_enableBackImage(false)
			self:backPageMainMenu()
		end
	end, 0)
	
end

function QUIPageMainMenu:_onTriggerShops(event)
	if q.buttonEvent(event, self._ccbOwner.btn_shop) == false then return end
	if self._pageSilder:getIsMoveing() then return end
    app.sound:playSound("common_small")
	app:getNavigationManager():pushViewController(app.mainUILayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogShopList", options = {position = position}})
end

function QUIPageMainMenu:_unifyTipScale()
	local function _unify(tip)
		q.setScreenScale(tip, tip:getScale())
	end
	local ccbOwner = self._ccbOwner
	_unify(ccbOwner.arena_tips)
	_unify(ccbOwner.chest_tip)
	_unify(ccbOwner.union_tips)
	_unify(ccbOwner.silvermine_tips)
	_unify(ccbOwner.sunwell_tips)
	_unify(ccbOwner.archaeology_tips)
	_unify(ccbOwner.soulTrial_tips)
	_unify(ccbOwner.thunder_tips)
	_unify(ccbOwner.glory_tips)
	_unify(ccbOwner.instance_tips)
	_unify(ccbOwner.shop_tips)
	_unify(ccbOwner.invasion_tips)
	_unify(ccbOwner.timeMachine_tips)
	_unify(ccbOwner.verify_tips)
	_unify(ccbOwner.stormArena_tips)
	_unify(ccbOwner.sanctuary_tips)
end

function QUIPageMainMenu:_onTriggerHelp()
   	app:getNavigationManager():pushViewController(app.mainUILayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogStrongerHelp"})
end

function QUIPageMainMenu:checkHelpNodeCanShow(  )
	if remote.instance:checkIsPassByDungeonId("wailing_caverns_5") and remote.strongerUtil then
		local hasNew = remote.strongerUtil:checkStrongerStandard()
		self._ccbOwner.help_tips:setVisible(hasNew)
		self._ccbOwner.help_node:setVisible(true)
	else
		self._ccbOwner.help_node:setVisible(false)
	end
end

function QUIPageMainMenu:_helpIconDisappear(  )
	-- body
	local arr =  CCArray:create()
    arr:addObject(CCSpawn:createWithTwoActions(CCScaleTo:create(0.3,0.1), CCFadeOut:create(0.3)))
    arr:addObject(CCCallFunc:create(function( )
    		self._ccbOwner.help_node:setVisible(false)
    	end))
    arr:addObject(CCDelayTime:create(60))
    arr:addObject(CCCallFunc:create(function( )
			self._ccbOwner.help_node:setVisible(true)
			self._ccbOwner.help_node:setScale(0.1)

		    local arr1 =  CCArray:create()
		    arr1:addObject(CCSpawn:createWithTwoActions(CCScaleTo:create(0.3,1), CCFadeIn:create(0.3)))
		    arr1:addObject(CCRepeat:create(CCSequence:createWithTwoActions(CCScaleTo:create(0.1,1.1),CCScaleTo:create(0.1,1)),3))
		    local action1 = CCSequence:create(arr1)
		    self._ccbOwner.help_node:runAction(action1)
    	end))
    local action = CCSequence:create(arr)

    self._ccbOwner.help_node:stopAllActions()
    self._ccbOwner.help_node:runAction(action)
end

function QUIPageMainMenu:_onDungeonDataUpdate(  )
	-- body
	--self:checkHelpNodeCanShow()
end

function QUIPageMainMenu:checkLevelGuide()
	if ENABLE_LEVEL_GUIDE == false then return end

	local levelInfos = QStaticDatabase:sharedDatabase():getLevelGuideInfosByType(LEVEL_GOAL.MAIN_MENU)
	local isHave = false
	local guideInfo = nil
	local lastGuideInfo = nil
	for _, value in pairs(levelInfos) do
		if not lastGuideInfo or (lastGuideInfo.closing_condition or 120) < (value.closing_condition or 120) then
			lastGuideInfo = value
		end
		if remote.user.level >= (value.trigger_condition or 0) and remote.user.level < (value.closing_condition or 120) then
			isHave = true
			guideInfo = value
			break
		end
	end
	if not isHave then
		isHave = true
		guideInfo = lastGuideInfo
	end
	self._ccbOwner.level_guide_node:setVisible(isHave and self._levelGuideStated)
	if isHave == false then 
		return 
	end

	if guideInfo then
		self._ccbOwner.tf_open_level:setString((guideInfo.closing_condition or 120).."级开启")
		self._ccbOwner.level_name:setString(guideInfo.name or "")

		QSetDisplayFrameByPath(self._ccbOwner.level_icon, "ui/"..guideInfo.icon)

		local trailerConfigIdList = app:getUserOperateRecord():getRecordByType("TRAILER_LEVEL_GOAL_ID") or {}
		local isNew = true
		for _, id in ipairs(trailerConfigIdList) do
			if id == guideInfo.id then
				isNew = false
			end
		end
		-- QPrintTable(trailerConfigIdList)
		if isNew then
			self._ccbOwner.fca_playerRecall_new_1:setVisible(true)
			self._ccbOwner.fca_playerRecall_new_2:setVisible(true)
		    self._levelGoalAnimationManager:runAnimationsForSequenceNamed("1")
		else
			self._ccbOwner.fca_playerRecall_new_1:setVisible(false)
			self._ccbOwner.fca_playerRecall_new_2:setVisible(false)
			self._levelGoalAnimationManager:runAnimationsForSequenceNamed("2")
		end
	end
	self._ccbOwner.sp_playerRecall_tips:setVisible(remote.trailer:checkRedTips())

end

function QUIPageMainMenu:setLevelGuideStated(stated)
	if stated == nil then return end
	self._levelGuideStated = stated

	self:checkLevelGuide()
end

function QUIPageMainMenu:_redTipsChange()
	if self:getPageMainMenuIcon() then
		self:getPageMainMenuIcon():setIconWidgetRedTips("node_active_rushBuy", remote.redTips:getTipsStateByName("QUIPageMainMenu_RushBuyTips"))
	end
end

function QUIPageMainMenu:checkSevenDayEntryLogin(callback)
	if not app.unlock:checkLock("UNLOCK_SEVEN_ENTRY") then 
		if callback then
			callback()
		end
		return
	end

	if app:getUserOperateRecord():compareCurrentTimeWithRecordeTime(DAILY_TIME_TYPE.ACTIVITY_SEVENDAY_ENTRY) then
		app:getUserOperateRecord():recordeCurrentTime(DAILY_TIME_TYPE.ACTIVITY_SEVENDAY_ENTRY)

		local loginDaysCount = remote.user.loginDaysCount or 0
		if 7 < loginDaysCount and loginDaysCount < 14 then
			local dayConfig = remote.activity:getEntryRewardConfig(remote.activity.TYPE_ACTIVITY_TYPE_8_14_DAY_NEW)
			if q.isEmpty(dayConfig) == false then
				app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogActivitySevenDay", options = {loginType = 2, callback = callback}})
			else
				if callback then
					callback()
				end
			end
		elseif loginDaysCount <= 7 then
			local dayConfig = remote.activity:getEntryRewardConfig(remote.activity.TYPE_ACTIVITY_TYPE_1_7_DAY_NEW)
			if q.isEmpty(dayConfig) == false then
				app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogActivitySevenDay", options = {callback = callback}})
			else
				if callback then
					callback()
				end
			end
		else
			if callback then
				callback()
			end
		end
	else
		if callback then
			callback()
		end
	end
end

function QUIPageMainMenu:_resetLua()
	local QAutoReloadChangeCodeFile = require("app.developTools.QAutoReloadChangeCodeFile")
    QAutoReloadChangeCodeFile.new()
    QAutoReloadChangeCodeFile:doAutoReLoad()
end


function QUIPageMainMenu:_updateBgSprite()
	self._ccbOwner.node_bj2:removeAllChildren()
	local sprite = q.screenShot(self._ccbOwner.node_background, nil, true)
	sprite:setShaderProgram(qShader.Q_ProgramPositionTextureShadowBlur)
	sprite:setColor(ccc3(155, 155, 155))
	sprite:setAnchorPoint(ccp(0, 0))
	self._ccbOwner.node_bj2:addChild(sprite)
end

function QUIPageMainMenu:updatePromptTime( promptType )
	-- 和时间有关的数据
	self:_updatePromptTime(promptType)
	if self._schedulerPrompt then
		scheduler.unscheduleGlobal(self._schedulerPrompt)
		self._schedulerPrompt = nil
	end
	self._schedulerPrompt = scheduler.scheduleGlobal(function ()
		self:_updatePromptTime(promptType)
	end, 1)
end

function QUIPageMainMenu:_updatePromptTime( promptType )
	if promptType == 1 then
		-- 世界BOSS
		self:_updateWorldBossTime()
	elseif promptType == 2 then
		-- 极北之地
		self:_updatePlunderTime()
	end
end

function QUIPageMainMenu:_updatePlunderTime()
	local timeStr, color, isActive = remote.plunder:updateTime()
	if isActive then
		self:getPageMainMenuIcon():setIconWidgetCountDown("node_prompt", timeStr)
	else
		self:getPageMainMenuIcon():setIconWidgetCountDown("node_prompt", "00:00:00")
		if self._schedulerPrompt then
			scheduler.unscheduleGlobal(self._schedulerPrompt)
			self._schedulerPrompt = nil
		end
		-- 在线提示功能
		self._pageMainMenuUtil:checkPrompt(self)
	end
	self:getPageMainMenuIcon():isIconWidgetShowCountDown("node_prompt", true)
end

function QUIPageMainMenu:_updateWorldBossTime()
	local isOvertime, timeStr, color = remote.worldBoss:updateTime()
	if not isOvertime then
		self:getPageMainMenuIcon():setIconWidgetCountDown("node_prompt", timeStr)
	else
		self:getPageMainMenuIcon():setIconWidgetCountDown("node_prompt", "00:00:00")
		if self._schedulerPrompt then
			scheduler.unscheduleGlobal(self._schedulerPrompt)
			self._schedulerPrompt = nil
		end
		
		-- 在线提示功能
		self._pageMainMenuUtil:checkPrompt(self)
	end
	self:getPageMainMenuIcon():isIconWidgetShowCountDown("node_prompt", true)
end

function QUIPageMainMenu:showSecretaryAni(callback)
	local curNode = self._ccbOwner.node_calendar
	local targetNode = self._ccbOwner.node_secretary 
	local posX, posY = targetNode:getPosition()
	curNode:setVisible(true)

	local arr = CCArray:create()
    arr:addObject(CCMoveTo:create(0.5, ccp(posX, posY)))
	arr:addObject(CCCallFunc:create(function()
		local effect = QUIWidgetAnimationPlayer.new()
    	curNode:addChild(effect)
    	effect:playAnimation("ccb/effects/UseItem2.ccbi", nil, function()
            effect:removeFromParent()
            curNode:setVisible(false)
			self:quickButtonAutoLayout()
			if callback then
				callback()
			end
        end)
	end))
	local action = CCSequence:create(arr)
    curNode:runAction(action)
end

function QUIPageMainMenu:showSoulSpiritAni(callback)
	app:getUserOperateRecord():setRecordByType("soul_spirit_guide_ani", 1)
	self._ccbOwner.node_achieve:setVisible(true)
	self:quickButtonAutoLayout()
	self._ccbOwner.node_achieve:setVisible(false)

	local achieveAni = function()
		local achievePos = self._scaling:getSoulSpiritNodeWorldPos()
	    self._ccbOwner.node_achieve_ani:setPosition(ccp(achievePos.x, achievePos.y))
	    self._ccbOwner.node_achieve_ani:setVisible(true)

		local achieveEndPos = self._ccbOwner.node_achieve:convertToWorldSpace(ccp(0, 0))
		local array = CCArray:create()
	    array:addObject(CCMoveTo:create(0.5, ccp(achieveEndPos.x, achieveEndPos.y)))
	    array:addObject(CCCallFunc:create(function()
			self._scaling:showSoulSpiritAni(function()
				self._ccbOwner.node_achieve:setVisible(true)
	    		self._ccbOwner.node_achieve_ani:setVisible(false)
				self:quickButtonAutoLayout()
				if callback then
					callback()
				end
		    end)
		end))
	    local sequence = CCSequence:create(array)
	    self._ccbOwner.node_achieve_ani:runAction(sequence)
	end

	local posX, posY = self._ccbOwner.node_master:getPosition()
	local achievePosX, achievePosY = self._ccbOwner.node_achieve:getPosition()
	self._ccbOwner.node_master:setPosition(ccp(achievePosX, achievePosY))

	local arr = CCArray:create()
    arr:addObject(CCMoveTo:create(0.5, ccp(posX, posY)))
	arr:addObject(CCCallFunc:create(achieveAni))
	local action = CCSequence:create(arr)
    self._ccbOwner.node_master:runAction(action)
end

function QUIPageMainMenu:showGodarmAni(callback)
	app:getUserOperateRecord():setRecordByType("godarm_guide_ani", 1)
	self._ccbOwner.node_task:setVisible(true)
	self:quickButtonAutoLayout()
	self._ccbOwner.node_task:setVisible(false)

	local achieveAni = function()
		local achievePos = self._scaling:getGodarmNodeWorldPos()
	    self._ccbOwner.node_task_Ani:setPosition(ccp(achievePos.x, achievePos.y))
	    self._ccbOwner.node_task_Ani:setVisible(true)

		local achieveEndPos = self._ccbOwner.node_task:convertToWorldSpace(ccp(0, 0))
		local array = CCArray:create()
	    array:addObject(CCMoveTo:create(0.5, ccp(achieveEndPos.x, achieveEndPos.y)))
	    array:addObject(CCCallFunc:create(function()
			self._scaling:showGodarmAni(function()
				self._ccbOwner.node_task:setVisible(true)
	    		self._ccbOwner.node_task_Ani:setVisible(false)
				self:quickButtonAutoLayout()
				if callback then
					callback()
				end
		    end)
		end))
	    local sequence = CCSequence:create(array)
	    self._ccbOwner.node_task_Ani:runAction(sequence)
	end

	local posX, posY = self._ccbOwner.node_secretary:getPosition()
	local achievePosX, achievePosY = self._ccbOwner.node_task:getPosition()
	self._ccbOwner.node_secretary:setPosition(ccp(achievePosX, achievePosY))

	local arr = CCArray:create()
    arr:addObject(CCMoveTo:create(0.5, ccp(posX, posY)))
	arr:addObject(CCCallFunc:create(achieveAni))
	local action = CCSequence:create(arr)
    self._ccbOwner.node_secretary:runAction(action)
end

function QUIPageMainMenu:_checkQuestionnaire()
	local showQuestionnaire = self._pageMainMenuUtil:checkQuestionnaire()
	self:getPageMainMenuIcon():setIconNodeVisible("node_questionnaire", showQuestionnaire)
end

function QUIPageMainMenu:_updateUIView()
	local gapWidth = display.width - display.ui_width
	local gapHeight = display.height - display.ui_height
	self._ccbOwner.node_left_top:setPosition(ccp(gapWidth/2, display.ui_height + gapHeight/2)) 
	self._ccbOwner.node_left_bottom:setPosition(ccp(gapWidth/2, gapHeight/2))
	self._ccbOwner.node_chat:setPosition(ccp(gapWidth/2, gapHeight/2))
	self._ccbOwner.node_right_top:setPosition(ccp(display.ui_width + gapWidth/2, display.ui_height + gapHeight/2))
	self._ccbOwner.node_right_bottom:setPosition(ccp(display.ui_width + gapWidth/2, gapHeight/2))

end

return QUIPageMainMenu
