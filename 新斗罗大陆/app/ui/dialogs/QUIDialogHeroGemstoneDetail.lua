--
-- Author: Your Name
-- Date: 2014-06-06 14:40:59
--
local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogHeroGemstoneDetail = class("QUIDialogHeroGemstoneDetail", QUIDialog)

local QRemote = import("...models.QRemote")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QNavigationController = import("...controllers.QNavigationController")
local QUIWidgetHeroHead = import("..widgets.QUIWidgetHeroHead")
local QUIWidgetEquipmentBox = import("..widgets.QUIWidgetEquipmentBox")
local QUIWidgetEquipmentSpecialBox = import("..widgets.QUIWidgetEquipmentSpecialBox")
local QUIWidgetHeroEquipment = import("..widgets.QUIWidgetHeroEquipment")
local QUIWidgetHeroNormalEquipmentStrengthen = import("..widgets.QUIWidgetHeroNormalEquipmentStrengthen")
local QUIWidgetHeroJewelryEquipmentStrengthen = import("..widgets.QUIWidgetHeroJewelryEquipmentStrengthen")
local QUIWidgetHeroEquipmentEvolution = import("..widgets.QUIWidgetHeroEquipmentEvolution")
local QUIWidgetHeroEquipmentLock = import("..widgets.QUIWidgetHeroEquipmentLock")
local QUIWidgetHeroEquipmentEnchant = import("..widgets.QUIWidgetHeroEquipmentEnchant")
local QUIWidgetHeroEquipmentHeroBreakThrough = import("..widgets.QUIWidgetHeroEquipmentHeroBreakThrough")
local QNotificationCenter = import("...controllers.QNotificationCenter")
local QUIWidgetAnimationPlayer = import("..widgets.QUIWidgetAnimationPlayer")
local QUIViewController = import("..QUIViewController")
local QTips = import("...utils.QTips")
local QUIWidgetHeroInformation = import("..widgets.QUIWidgetHeroInformation")
local QTextFiledScrollUtils = import("...utils.QTextFiledScrollUtils")
local QUIHeroModel = import("...models.QUIHeroModel")
local QUIWidgetGemstonesBox = import("..widgets.QUIWidgetGemstonesBox")
local QGemstoneController = import("..controllers.QGemstoneController")
local QUIWidgetHeroGemstoneDetail = import("..widgets.QUIWidgetHeroGemstoneDetail")
local QUIWidgetHeroGemstoneEmpty = import("..widgets.QUIWidgetHeroGemstoneEmpty")
local QUIWidgetHeroGemstoneEvolution = import("..widgets.QUIWidgetHeroGemstoneEvolution")
local QUIWidgetHeroGemstoneStrength = import("..widgets.QUIWidgetHeroGemstoneStrength")
local QUIWidgetHeroGemstoneToGod = import("..widgets.QUIWidgetHeroGemstoneToGod")
local QUIWidgetHeroGemstoneAdvanced = import("..widgets.QUIWidgetHeroGemstoneAdvanced")
local QUIWidgetHeroGemstoneRefine = import("..widgets.QUIWidgetHeroGemstoneRefine")
local QUIWidgetHeroGemstoneMix = import("..widgets.QUIWidgetHeroGemstoneMix")
local QUIWidgetFcaAnimation = import("..widgets.actorDisplay.QUIWidgetFcaAnimation")
local QUIWidgetHeroHeadVibrate = import("..widgets.QUIWidgetHeroHeadVibrate")

-- QUIDialogHeroGemstoneDetail.TAB_INFO = "TAB_INFO"
QUIDialogHeroGemstoneDetail.TAB_STRONG = "TAB_STRONG"
QUIDialogHeroGemstoneDetail.TAB_EVOLUTION = "TAB_EVOLUTION"
QUIDialogHeroGemstoneDetail.TAB_DETAIL = "TAB_DETAIL"
QUIDialogHeroGemstoneDetail.TAB_ADVANCED = "TAB_ADVANCED"
QUIDialogHeroGemstoneDetail.TAB_TOGOD = "TAB_TOGOD"
QUIDialogHeroGemstoneDetail.TAB_FUSE = "TAB_FUSE"		-- 融合
QUIDialogHeroGemstoneDetail.TAB_REFINE = "TAB_REFINE"	-- 精炼
QUIDialogHeroGemstoneDetail.TAB_LINK = "TAB_LINK"
QUIDialogHeroGemstoneDetail.REFESH_BATTLE_FORCE = "REFESH_BATTLE_FORCE"
QUIDialogHeroGemstoneDetail.CLICK_STRENGTEN_MASTER = "CLICK_STRENGTEN_MASTER"

--onTriggerCompositeHandler onTriggerWearHandler
function QUIDialogHeroGemstoneDetail:ctor(options)
	local ccbFile = "ccb/Dialog_Baoshi.ccbi"
	local callBacks = {
		{ccbCallbackName = "onTriggerBack", 				callback = handler(self, self._onTriggerBack)},
		{ccbCallbackName = "onTriggerTabStrong", 		callback = handler(self, self._onTriggerTabStrong)},
		{ccbCallbackName = "onTriggerTabEvolution", 		callback = handler(self, self._onTriggerTabEvolution)},
        {ccbCallbackName = "onTriggerTabAdvanced", 		callback = handler(self, self._onTriggerTabAdvanced)},
        {ccbCallbackName = "onTriggerTabToGod", 			callback = handler(self, self._onTriggerTabToGod)},		
		{ccbCallbackName = "onTriggerTabDetail", 		callback = handler(self, self._onTriggerTabDetail)},
		{ccbCallbackName = "onTriggerTabFuse", 		callback = handler(self, self._onTriggerTabFuse)},
		{ccbCallbackName = "onTriggerTabRefine", 		callback = handler(self, self._onTriggerTabRefine)},
		{ccbCallbackName = "onTriggerLeft", 		callback = handler(self, self._onTriggerLeft)},
		{ccbCallbackName = "onTriggerRight", 		callback = handler(self, self._onTriggerRight)},
        {ccbCallbackName = "onTriggerBag",      callback = handler(self, self._onTriggerBag)}, 
        {ccbCallbackName = "onTriggerMaster", callback = handler(self, self._onTriggerMaster)},
        {ccbCallbackName = "onQuickStrengthen",		callback = handler(self, self._onQuickStrengthen)},
        {ccbCallbackName = "onQuickBreakThrough",		callback = handler(self, self._onQuickBreakThrough)},
	}
	QUIDialogHeroGemstoneDetail.super.ctor(self, ccbFile, callBacks, options)
	local page = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
	page:setManyUIVisible()
    page.topBar:showWithGemstone()
	
    self.click_lock4tips = false -- 弹出提示过程中屏蔽按钮点击
    
    ui.tabButton(self._ccbOwner.tab_detail, "详细")
    ui.tabButton(self._ccbOwner.tab_evolution, "突破")
    ui.tabButton(self._ccbOwner.tab_strong, "强化")
    ui.tabButton(self._ccbOwner.tab_advanced, "进阶")
	ui.tabButton(self._ccbOwner.tab_togod, "化神")
	ui.tabButton(self._ccbOwner.tab_fuse, "融合")
	ui.tabButton(self._ccbOwner.tab_refine, "精炼")
	self._btnNodes = {self._ccbOwner.node_btn_detail
	,self._ccbOwner.node_btn_evolution
	,self._ccbOwner.node_btn_string
	,self._ccbOwner.node_advanced
	,self._ccbOwner.node_togod
	,self._ccbOwner.node_fuse
	,self._ccbOwner.node_refine
	}
	
    self._tabManager = ui.tabManager({
		self._ccbOwner.tab_detail, 
		self._ccbOwner.tab_evolution, 
		self._ccbOwner.tab_strong,
		self._ccbOwner.tab_advanced,
		self._ccbOwner.tab_togod,
		self._ccbOwner.tab_fuse,
		self._ccbOwner.tab_refine
	})


	if options ~= nil then
		self._pos = options.pos or 1
		self._heros = options.heros or {}
		self._currentTab = options.initTab
		self._gemstonePos = options.gemstonePos
	end
	self._equipmentStrengthen = nil
	self._oldBattleForce = 0

	if #self._heros == 1 then
        self._ccbOwner.arrowLeft:setVisible(false)
        self._ccbOwner.arrowRight:setVisible(false)
    end
end

function QUIDialogHeroGemstoneDetail:viewDidAppear()
	QUIDialogHeroGemstoneDetail.super.viewDidAppear(self)

	self._remoteProxy = cc.EventProxy.new(remote)
	self._remoteProxy:addEventListener(remote.HERO_UPDATE_EVENT, handler(self, self.onEvent))
    self._gemstoneProxy = cc.EventProxy.new(remote.gemstone)
    self._gemstoneProxy:addEventListener(remote.gemstone.EVENT_WEAR, handler(self, self.gemstoneWearHandler))
    self._gemstoneProxy:addEventListener(remote.gemstone.EVENT_UNWEAR, handler(self, self.gemstoneUnwearHandler))
    self._gemstoneProxy:addEventListener(remote.gemstone.EVENT_ADVANCED, handler(self, self.gemstoneAdvancedHandler))
    self._gemstoneProxy:addEventListener(remote.gemstone.EVENT_TOGOD, handler(self, self.gemstoneAdvancedHandler))

    self._gemstoneProxy:addEventListener(remote.gemstone.EVENT_MIX_SUCCESS, handler(self, self.gemstoneMixSuccessHandler))

	self._heroProxy = cc.EventProxy.new(remote.herosUtil)
	self._heroProxy:addEventListener(remote.herosUtil.EVENT_REFESH_BATTLE_FORCE, handler(self, self.onEvent))

	self._itemsProxy = cc.EventProxy.new(remote.items)
	self._itemsProxy:addEventListener(remote.items.EVENT_ITEMS_UPDATE, handler(self, self.onEvent))

	self._userProxy = cc.EventProxy.new(remote.user)
	self._userProxy:addEventListener(remote.user.EVENT_USER_PROP_CHANGE, handler(self, self.onEvent))
	self:addBackEvent()

	QNotificationCenter.sharedNotificationCenter():addEventListener(QUIDialogHeroGemstoneDetail.TAB_TOGOD, self.msgOnToGod, self)
	QNotificationCenter.sharedNotificationCenter():addEventListener(remote.gemstone.EVENT_JUMP_MIX, self._jumpToMixTab, self)

	self:setInfo(self._heros[self._pos], self._gemstonePos)
end


function QUIDialogHeroGemstoneDetail:viewWillDisappear()
	QUIDialogHeroGemstoneDetail.super.viewWillDisappear(self)
	if self._gemstoneController ~= nil then
		self._gemstoneController:removeAllEventListeners()
	end
	self._remoteProxy:removeAllEventListeners()
	self._gemstoneProxy:removeAllEventListeners()
	self._itemsProxy:removeAllEventListeners()
	self._userProxy:removeAllEventListeners()
	self._heroProxy:removeAllEventListeners()

	QNotificationCenter.sharedNotificationCenter():removeEventListener(QUIDialogHeroGemstoneDetail.TAB_TOGOD, self.msgOnToGod, self)
	QNotificationCenter.sharedNotificationCenter():removeEventListener(remote.gemstone.EVENT_JUMP_MIX, self._jumpToMixTab, self)


	if self._textUpdate ~= nil then
		self._textUpdate:stopUpdate()
		self._textUpdate = nil
	end

	if self._schedulerHandler ~= nil then
		scheduler.unscheduleGlobal(self._schedulerHandler)
		self._schedulerHandler = nil
	end

	if self._masterDialog ~= nil then
		self._masterDialog:removeAllEventListeners()
		self._masterDialog = nil
	end
	
    if self._delayHandler then
        scheduler.unscheduleGlobal(self._delayHandler)
        self._delayHandler = nil
    end

	self:removeBackEvent()
	local page = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
    page.topBar:setAllSound(true)
end

function QUIDialogHeroGemstoneDetail:setInfo(actorId, gemstonePos,isShowAnimation)
	self._ccbOwner.tf_master_level:setString(0)
	self._actorId = actorId
	self._hero = remote.herosUtil:getHeroByID(actorId)
	self._gemstonePos = gemstonePos
	if self._gemstonePos == nil then
		self._gemstonePos = 1
	end
	self._heroUIModel = remote.herosUtil:getUIHeroByID(self._actorId)
    self:refreshPos()
	self:initHeroArea()
	self:tabSelectHandler(isShowAnimation)
	self:checkRedTips()
	self:refreshRightBtns()

	if self._currentTab == QUIDialogHeroGemstoneDetail.TAB_EVOLUTION then
		self:checkShowOneBreakBtn()
	end
end



function QUIDialogHeroGemstoneDetail:msgOnToGod(e)
	self:selectTab(QUIDialogHeroGemstoneDetail.TAB_ADVANCED, true)
end


-- 跳转到融合页
function QUIDialogHeroGemstoneDetail:_jumpToMixTab(e)
	self:selectTab(QUIDialogHeroGemstoneDetail.TAB_FUSE, true)
end

function QUIDialogHeroGemstoneDetail:refreshRightBtns()


	local gemEvolution = app.unlock:checkLock("GEMSTONE_EVOLUTION",false)
	local refineLock = app.unlock:checkLock("UNLOCK_GEMSTONE_REFINE",false)

  --   if not app.unlock:checkLock("GEMSTONE_EVOLUTION",false) then
		-- self._ccbOwner.node_advanced:setVisible(false)
		-- self._ccbOwner.node_togod:setVisible(false)
		-- return
  --   end

	local checkTab = function( )
		if self._currentTab == QUIDialogHeroGemstoneDetail.TAB_TOGOD or self._currentTab == QUIDialogHeroGemstoneDetail.TAB_ADVANCED  
			or self._currentTab == QUIDialogHeroGemstoneDetail.TAB_FUSE or self._currentTab == QUIDialogHeroGemstoneDetail.TAB_REFINE  then
			self:selectTab(QUIDialogHeroGemstoneDetail.TAB_DETAIL, true)
		end
	end 

	local gemstoneInfo = self._heroUIModel:getGemstoneInfoByPos(self._gemstonePos)
	if gemstoneInfo and gemstoneInfo.info then
		local gemstoneInfoBysid = remote.gemstone:getGemstoneById(gemstoneInfo.info.sid)
		local gemstoneConfig = QStaticDatabase:sharedDatabase():getItemByID(gemstoneInfo.info.itemId)

		if gemstoneInfoBysid then
			if gemstoneInfoBysid.mix_level and gemstoneInfoBysid.mix_level > 0 then
				makeNodeFromGrayToNormal(self._ccbOwner.tab_refine)
			else
				makeNodeFromNormalToGray(self._ccbOwner.tab_refine)
				if self._currentTab == QUIDialogHeroGemstoneDetail.TAB_REFINE then
					self:selectTab(QUIDialogHeroGemstoneDetail.TAB_DETAIL, true)
				end
			end
		end

		if gemstoneConfig then
			local quality = remote.gemstone:getSABC(gemstoneConfig.gemstone_quality).lower
			if quality == "s" then
				if gemEvolution then
					local advancedLevel = gemstoneInfoBysid.godLevel or remote.gemstone.GEMSTONE_GODLEVLE_TEST
					if advancedLevel >= GEMSTONE_MAXADVANCED_LEVEL then
						self._ccbOwner.node_advanced:setVisible(false)
						self._ccbOwner.node_togod:setVisible(true)					
					else
						self._ccbOwner.node_advanced:setVisible(true)
						self._ccbOwner.node_togod:setVisible(false)
					end
				else
						self._ccbOwner.node_advanced:setVisible(false)
						self._ccbOwner.node_togod:setVisible(false)

				end
				local mix_level = gemstoneInfoBysid.mix_level or 0
				self._ccbOwner.node_fuse:setVisible(true)	
				self._ccbOwner.node_refine:setVisible(mix_level > 0 and refineLock)	
			else
				self._ccbOwner.node_advanced:setVisible(false)
				self._ccbOwner.node_togod:setVisible(false)	
				self._ccbOwner.node_fuse:setVisible(false)	
				self._ccbOwner.node_refine:setVisible(false)	
				checkTab()			
			end
		else
			self._ccbOwner.node_advanced:setVisible(false)
			self._ccbOwner.node_togod:setVisible(false)
			self._ccbOwner.node_fuse:setVisible(false)
			self._ccbOwner.node_refine:setVisible(false)
			checkTab()
		end
	else
		self._ccbOwner.node_advanced:setVisible(false)
		self._ccbOwner.node_togod:setVisible(false)
		self._ccbOwner.node_fuse:setVisible(false)
		self._ccbOwner.node_refine:setVisible(false)
		checkTab()
	end

	local index = 0
	for i,v in ipairs(self._btnNodes) do
		if v:isVisible() then
			v:setPositionY(-3 - 75*index)
			index = index + 1
		end
	end
end
--初始化装备这块和头像
function QUIDialogHeroGemstoneDetail:initHeroArea()
	self._heroInfo = clone(remote.herosUtil:getHeroByID(self._actorId))
	local characher = QStaticDatabase:sharedDatabase():getCharacterByID(self._heroInfo.actorId)
	self._ccbOwner.tf_level:setString("LV."..(self._heroInfo.level or "0"))

	local fontColor = BREAKTHROUGH_COLOR_LIGHT["white"]
	local breakthroughLevel,color = remote.herosUtil:getBreakThrough(self._heroInfo.breakthrough)
	if color ~= nil then
		fontColor = BREAKTHROUGH_COLOR_LIGHT[color]
	end
	self._ccbOwner.tf_name:setColor(fontColor)
	self._ccbOwner.tf_name = setShadowByFontColor(self._ccbOwner.tf_name, fontColor)
	self._ccbOwner.tf_level:setColor(fontColor)
	self._ccbOwner.tf_level = setShadowByFontColor(self._ccbOwner.tf_level, fontColor)

	self._ccbOwner.tf_name:setString(characher.name..(breakthroughLevel == 0 and "" or (" +"..breakthroughLevel)))

	if self._information == nil then
		self._information = QUIWidgetHeroInformation.new()
		self._ccbOwner.node_avatar:addChild(self._information:getView())
	end
	self._information:setAvatar(self._heroInfo.actorId, 1.1)
	self._information:setNameVisible(false)
	self._information:setStarVisible(false)
	self._information:setBackgroundVisible(false)
	self._heroModel = remote.herosUtil:createHeroProp(self._heroInfo)
	local battleForce = self._heroModel:getBattleForce()
	if self._oldBattleForce == 0 or self._oldBattleForce == battleForce then
    	self._oldBattleForce = battleForce
		self:setBattleForceText(battleForce)
	end

	-- 装备部分
	if self._gemstoneController == nil then
		self._gemstoneBoxs = {}
	    for i = 1, 4 do
	        self._gemstoneBoxs[i] = QUIWidgetGemstonesBox.new()
	        self._gemstoneBoxs[i]:setPos(i)
	        self._ccbOwner["node"..i]:addChild(self._gemstoneBoxs[i])
	    end
	    self._gemstoneController = QGemstoneController.new()
	    self._gemstoneController:setBoxs(self._gemstoneBoxs)
		self._gemstoneController:addEventListener(QUIWidgetGemstonesBox.EVENT_CLICK, handler(self, self.onEvent))
	end
	self._gemstoneController:setHero(self._heroInfo.actorId) -- 装备显示
end

function QUIDialogHeroGemstoneDetail:_refreshBatlleForce()
	if self._oldBattleForce == nil or self._oldBattleForce == 0 then return end

	local heroProp = remote.herosUtil:createHeroPropById(self._actorId)
	local battleForce = heroProp:getBattleForce()
	if self._textUpdate == nil then
		self._textUpdate = QTextFiledScrollUtils.new()
	end
	local forceChange = math.floor(battleForce - self._oldBattleForce)
	self._newBattle = battleForce
	self._ccbOwner.tf_battleForce:runAction(CCScaleTo:create(0.2, 1.5))
	self._textUpdate:addUpdate(self._oldBattleForce, battleForce, handler(self, self.setBattleForceText), 1)
	self._oldBattleForce = battleForce
	if forceChange ~= 0 then 
		local effectName
      	if forceChange > 0 then
        	effectName = "effects/Tips_add.ccbi"
        	app.sound:playSound("force_add")
      	elseif forceChange < 0 then 
        	effectName = "effects/Tips_Decrease.ccbi"
      	end
      	local numEffect = QUIWidgetAnimationPlayer.new()
      	self._ccbOwner.battleForceNode:addChild(numEffect)
      	numEffect:playAnimation(effectName, function(ccbOwner)
      		if ccbOwner and ccbOwner.content then
	            if forceChange < 0 then
	              	ccbOwner.content:setString(" -" .. math.abs(forceChange))
	            else
	              	ccbOwner.content:setString(" +" .. math.abs(forceChange))
	            end
	        end
        end)
    end
end 

function QUIDialogHeroGemstoneDetail:setBattleForceText(battleForce)
    local word = nil
    if battleForce >= 1000000 then
      word = tostring(math.floor(battleForce/10000)).."万"
    else
      word = math.floor(battleForce)
    end
    self._ccbOwner.tf_battleForce:setString(word)
    local fontInfo = QStaticDatabase:sharedDatabase():getForceColorByForce(battleForce)
    if fontInfo ~= nil then
		local color = string.split(fontInfo.force_color, ";")
		self._ccbOwner.tf_battleForce:setColor(ccc3(color[1], color[2], color[3]))
    end

	if battleForce == self._newBattle then
		self._ccbOwner.tf_battleForce:runAction(CCScaleTo:create(0.2, 1))
	end
end 

function QUIDialogHeroGemstoneDetail:selectTab(name, isforce)
	if self._gemstoneSid == nil then return end
	if self._currentTab ~= name or isforce == true then
		self._currentTab = name
		self:getOptions().initTab = name
		self:removeAllTabState()
		if self._infoWidget ~= nil then
			self._infoWidget:setVisible(false)
			self._infoWidget = nil
		end
		self._ccbOwner.node_quick_strengthen:setVisible(false)
		self._ccbOwner.node_quick_break_through:setVisible(false)
		self._gemstoneController:refreshBox()
		local titleStr = "魂骨详细"
		if self._currentTab == QUIDialogHeroGemstoneDetail.TAB_STRONG then
			titleStr = "魂骨强化"
			self:selectedTabStrong()
		elseif self._currentTab == QUIDialogHeroGemstoneDetail.TAB_EVOLUTION then
			titleStr = "魂骨突破"
			self:selectedTabEvolution()
		elseif self._currentTab == QUIDialogHeroGemstoneDetail.TAB_ADVANCED then
			titleStr = "魂骨进阶"
			self:selectedTabAdvanced()
		elseif self._currentTab == QUIDialogHeroGemstoneDetail.TAB_TOGOD then
			titleStr = "魂骨化神"
			self:selectedTabToGod()
		elseif self._currentTab == QUIDialogHeroGemstoneDetail.TAB_FUSE then
			titleStr = "魂骨融合"
			self:selectedTabFuse()
		elseif self._currentTab == QUIDialogHeroGemstoneDetail.TAB_REFINE then
			titleStr = "魂骨精炼"
			self:selectedTabRefine()
		elseif self._currentTab == QUIDialogHeroGemstoneDetail.TAB_DETAIL then
			self:selectedTabDetail()
		end
		self._ccbOwner.frame_tf_title:setString(titleStr)

		if self._infoWidget ~= nil then
			self._infoWidget:setVisible(true)
		end
	end
end
 
function QUIDialogHeroGemstoneDetail:refreshItem(itemId)
	self._gemstoneSid = itemId
	self:getOptions().itemId = itemId
end

function QUIDialogHeroGemstoneDetail:tabSelectHandler(isShowAnimation)
	self:selectEquipmentBox()
	if self._gemstoneSid ~= nil then
		self._currentTab = self._currentTab or QUIDialogHeroGemstoneDetail.TAB_DETAIL
		local gemstone = remote.gemstone:getGemstoneById(self._gemstoneSid)
		local godLevel = gemstone.godLevel
		if self._currentTab == QUIDialogHeroGemstoneDetail.TAB_TOGOD or self._currentTab == QUIDialogHeroGemstoneDetail.TAB_ADVANCED then
			if godLevel >= GEMSTONE_MAXADVANCED_LEVEL then
				self._currentTab = QUIDialogHeroGemstoneDetail.TAB_TOGOD
			else
				self._currentTab = QUIDialogHeroGemstoneDetail.TAB_ADVANCED
			end
		end
		if isShowAnimation and self._lastAdvancedType == remote.gemstone.EVENT_ADVANCED and godLevel == GEMSTONE_MAXADVANCED_LEVEL then
	        if self._delayHandler then
	            scheduler.unscheduleGlobal(self._delayHandler)
	            self._delayHandler = nil
	        end
			self._delayHandler = scheduler.performWithDelayGlobal(function()
				local ccbFile = "ccb/effects/tupo.ccbi"
				local effectShow = QUIWidgetAnimationPlayer.new()
				self._ccbOwner.node_right:addChild( effectShow )
				effectShow:setPosition(ccp(-180, -50))

				effectShow:playAnimation(ccbFile, function()
				end, function()  
					self:refreshRightBtns()
					self:selectTab(self._currentTab, true)
					effectShow:disappear()
					self._lastAdvancedType = nil
				end)
			end, 1)
		else
			self:refreshRightBtns()
			self:selectTab(self._currentTab, true)
		end
	else
		--没有装宝石
		if self._infoWidget ~= nil then
			self._infoWidget:setVisible(false)
			self._infoWidget = nil
		end
		self:removeAllTabState()
		if self._emptyWidget == nil then
			self._emptyWidget = QUIWidgetHeroGemstoneEmpty.new()
			self._ccbOwner.node_right:addChild(self._emptyWidget)
		end
		self._emptyWidget:setInfo(self._actorId, nil, self._gemstonePos)
		self._infoWidget = self._emptyWidget
		self._infoWidget:setVisible(true)
	end
end 

function QUIDialogHeroGemstoneDetail:selectEquipmentBox()
	for _,box in pairs(self._gemstoneBoxs) do 
		if box:getIndex() == self._gemstonePos then
			box:selected(true)
		else
			box:selected(false)
		end
	end
end

function QUIDialogHeroGemstoneDetail:refreshPos()
	local gemstoneInfo = self._heroUIModel:getGemstoneInfoByPos(self._gemstonePos)
	self._gemstoneSid = nil
	if gemstoneInfo ~= nil and gemstoneInfo.info ~= nil then
		self._gemstoneSid = gemstoneInfo.info.sid
	end
end

function QUIDialogHeroGemstoneDetail:checkRedTips()
	self._ccbOwner.strong_tip:setVisible(false)
	self._ccbOwner.evolution_tip:setVisible(false)
	self._ccbOwner.detail_tip:setVisible(false)
	self._ccbOwner.advanced_tip:setVisible(false)
	self._ccbOwner.togod_tip:setVisible(false)
	self._ccbOwner.fuse_tip:setVisible(false)
	self._ccbOwner.fuse_refine:setVisible(false)
	local gemstoneInfo = self._heroUIModel:getGemstoneInfoByPos(self._gemstonePos)
	self._ccbOwner.evolution_tip:setVisible(self._heroUIModel:getGemstoneCanBreak())
	self._ccbOwner.detail_tip:setVisible(self._heroUIModel:getGemstoneCanBetter())
	self._ccbOwner.advanced_tip:setVisible(self._heroUIModel:getGemstoneCanAdvanced())
	self._ccbOwner.fuse_tip:setVisible(self._heroUIModel:getGemstoneCanMix())
	self._ccbOwner.fuse_refine:setVisible(self._heroUIModel:getGemstoneCanRefine())
end

function QUIDialogHeroGemstoneDetail:onEvent(event)

	print("QUIDialogHeroGemstoneDetail:onEvent event.name == "..tostring(event.name))
	if event.name == QUIWidgetGemstonesBox.EVENT_CLICK then
		if self.click_lock4tips then return end --屏蔽点击魂骨
		if self._advancedWidget and self._advancedWidget:isOnekeyPlaying() then return end

		app.sound:playSound("common_item")
        self._gemstonePos = event.pos
        self:refreshPos()
		self:tabSelectHandler()
		self:getOptions().gemstonePos = self._gemstonePos
		self:checkRedTips()
	elseif event.name == remote.HERO_UPDATE_EVENT or event.name == remote.user.EVENT_USER_PROP_CHANGE then 
		self._gemstoneController:refreshBox() -- 装备显示
        self:refreshPos()
		-- self:tabSelectHandler()
		self:checkRedTips()
		if not self._advancedWidget or not self._advancedWidget:isOnekeyPlaying() then
			self:setInfo(self._actorId, self._gemstonePos,true)
		end
	elseif event.name == remote.herosUtil.EVENT_REFESH_BATTLE_FORCE then
		self:_refreshBatlleForce()
	elseif event.name == remote.items.EVENT_ITEMS_UPDATE then
		if self._advancedWidget and self._advancedWidget:isOnekeyPlaying() then
			self:checkRedTips()
		else
			self:tabSelectHandler()
			self:checkRedTips()
		end
	end
end
-- 魂骨进阶
function QUIDialogHeroGemstoneDetail:gemstoneAdvancedHandler( event )

	if self._advancedWidget and not self._advancedWidget:isOnekeyPlaying() and self._advancedWidget:isUpdateParentView() then
		self:setInfo(self._actorId, self._gemstonePos, true)
	end

    local sid = event.sid
    local gemstone = remote.gemstone:getGemstoneById(sid)
    local advancedType = event.name
    self._lastAdvancedType = advancedType
    local advancedLevel = gemstone.godLevel or remote.gemstone.GEMSTONE_GODLEVLE_TEST

    if self.advancedEffectShow ~= nil then
        self.advancedEffectShow:disappear()
        self.advancedEffectShow = nil
    end

    local ccbFile = "ccb/effects/Baoshi_tips.ccbi"
    self.advancedEffectShow = QUIWidgetAnimationPlayer.new()
    self.advancedEffectShow:setPositionY(-30)
    self:getView():addChild(self.advancedEffectShow)

    local gemStonelevelInfo = db:getGemstoneEvolutionBygodLevel(gemstone.itemId, advancedLevel)
    local successTip = app.master.GEMSTONE_GOD_ADVANCED_TIP
    if gemStonelevelInfo and gemStonelevelInfo.gem_evolution_skill and app.master:getMasterShowState(successTip) then
    	self.click_lock4tips = true
		app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogGemStoneAdvancedSucess", 
	    	options = {gemstoneSid = sid, itemId = gemstone.itemId, advancedLevel=advancedLevel, successTip = successTip, advancedType = advancedType,callBack = function()
	    		-- 多判定一次是否激活化神套装
	    		local godskill = db:getGemstoneGodSkillByGemstones(self._hero.gemstones,true,advancedLevel)
	    		if godskill ~= nil then
	    			local suits = {}
					for _,v in ipairs(self._hero.gemstones) do
	                	table.insert(suits, v)
	            	end
					self:getScheduler().performWithDelayGlobal(function()
							app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogGodGemstoneActivitySuit", 
								options = {suits = suits ,only_skill = successTip, suitstype = true,suitstype = "godsuit",callback = function ()
										remote.herosUtil:dispatchEvent({name = remote.herosUtil.EVENT_REFESH_BATTLE_FORCE})
	    								self.click_lock4tips = false
									end}}, {isPopCurrentDialog = false})	  
						end, 0.5)
	    		else
	    			remote.herosUtil:dispatchEvent({name = remote.herosUtil.EVENT_REFESH_BATTLE_FORCE})
	    			self.click_lock4tips = false
	    		end
	    	end}}, {isPopCurrentDialog = false})
    else
    	local addPropVlue = {}
    	if event.oldLevel then
    		addPropVlue = remote.gemstone:getAllAdvancedProp(gemstone.itemId, event.oldLevel + 1, advancedLevel)
    	end
    	if q.isEmpty(addPropVlue) then
    		addPropVlue = gemStonelevelInfo
    	end
    	print(" event.oldLevel  = ",  event.oldLevel, advancedLevel)
    	QKumo(addPropVlue)
	    self.advancedEffectShow:playAnimation(ccbFile, function(ccbOwner)
	    	ccbOwner.node_red:setVisible(true)
	    	ccbOwner.node_green:setVisible(false)
	    	if advancedType == remote.gemstone.EVENT_ADVANCED then
	    		ccbOwner.tf_title2:setString("进阶成功")
	    	else
	    		ccbOwner.tf_title2:setString("化神成功")
	    	end
	        for i=5,8 do
	            ccbOwner["node_"..i]:setVisible(false)
	        end
	        local index = 1
	        local function addPropText(name,value)
	            if index > 4 then return end
	            value = value or 0
	            if value > 0 then
	                ccbOwner["node_"..(index+4)]:setVisible(true)
	                ccbOwner["tf_name"..(index+4)]:setString(name.."+"..value)
	                index = index + 1
	            end
	        end
	        addPropText("攻击", addPropVlue.attack_value)
	        addPropText("生命", addPropVlue.hp_value)
	        addPropText("物理防御", addPropVlue.armor_physical)
	        addPropText("法术防御", addPropVlue.armor_magic)
	        end, function()
	            if self.advancedEffectShow ~= nil then
	                self.advancedEffectShow:disappear()
	                self.advancedEffectShow = nil
	            end
				remote.herosUtil:dispatchEvent({name = remote.herosUtil.EVENT_REFESH_BATTLE_FORCE})
	        end) 
    end

    app.sound:playSound("gem_drop")
end

--卸载宝石
function QUIDialogHeroGemstoneDetail:gemstoneUnwearHandler(event)
    local sid = event.sid
    local gemstone = remote.gemstone:getGemstoneById(sid)
    local ccbFile = "ccb/effects/Baoshi_tips.ccbi"
    if self._strengthenEffectShow ~= nil then
        self._strengthenEffectShow:disappear()
        self._strengthenEffectShow = nil
    end
    self._strengthenEffectShow = QUIWidgetAnimationPlayer.new()
    self:getView():addChild(self._strengthenEffectShow)
    self._strengthenEffectShow:setPosition(ccp(0, 100))
    self._strengthenEffectShow:playAnimation(ccbFile, function(ccbOwner)
    	ccbOwner.node_red:setVisible(true)
    	ccbOwner.node_green:setVisible(false)
        for i=5,8 do
            ccbOwner["node_"..i]:setVisible(false)
        end
        local index = 1
        local function addPropText(name,value)
            if index > 4 then return end
            value = value or 0
            if value > 0 then
                ccbOwner["node_"..(index+4)]:setVisible(true)
                ccbOwner["tf_name"..(index+4)]:setString(name.."－"..value)
                index = index + 1
            end
        end
        addPropText("攻击", gemstone.prop.attack_value)
        addPropText("生命", gemstone.prop.hp_value)
        addPropText("物理防御", gemstone.prop.armor_physical)
        addPropText("法术防御", gemstone.prop.armor_magic)
        end, function()
            if self._strengthenEffectShow ~= nil then
                self._strengthenEffectShow:disappear()
                self._strengthenEffectShow = nil
            end
			remote.herosUtil:dispatchEvent({name = remote.herosUtil.EVENT_REFESH_BATTLE_FORCE})
        end)    
end

--装载宝石
function QUIDialogHeroGemstoneDetail:gemstoneWearHandler(event)
    local sid = event.sid
    local actorId = event.actorId
    if actorId ~= self._actorId then
    	return
    end
    local gemstone = remote.gemstone:getGemstoneById(sid)

    local ccbFile = "ccb/effects/Baoshi_tips.ccbi"
    if self._strengthenEffectShow ~= nil then
        self._strengthenEffectShow:disappear()
        self._strengthenEffectShow = nil
    end
    
    self._gemstonePos = gemstone.position
    self:refreshPos()
	self:tabSelectHandler()
	self:getOptions().gemstonePos = self._gemstonePos
	self:checkRedTips()

    app.sound:playSound("sound_num")

	local effect = QUIWidgetAnimationPlayer.new()
	self._ccbOwner["node"..gemstone.position]:addChild(effect)
	effect:playAnimation("ccb/effects/Baoshizhuangbei.ccbi")

    local arr = CCArray:create()
    arr:addObject(CCScaleTo:create(0.1,1.2,1.2))
    arr:addObject(CCScaleTo:create(0.05,1.4,1.4))
    arr:addObject(CCScaleTo:create(0.05,1.2,1.2))
    arr:addObject(CCScaleTo:create(0.1,1,1))
    self._gemstoneBoxs[gemstone.position]:runAction(CCSequence:create(arr))

    local suitCallBack = function ()
        if self:safeCheck() then
        	self.click_lock4tips = false
        	self:checkTriggerBreakMaster()
        end
    end

    self:enableTouchSwallowTop()
    self._schedulerHandler = scheduler.performWithDelayGlobal(function ()
    	self._schedulerHandler = nil
	    local gemstoneSuits = remote.gemstone:getSuitByItemId(gemstone.itemId)
	    local suits = {}
	    local godsuits = {}
        local mixsuits = {}
        local mixskillId = nil	    
	    for index,gemstoneConfig in ipairs(gemstoneSuits) do
	        if index > 4 then
	            break
	        end
	        if self._hero.gemstones ~= nil then
	            for _,v in ipairs(self._hero.gemstones) do
	                if v.itemId == gemstoneConfig.id then
	                    table.insert(suits, v)
	                    break
	                end
	            end
	        end
	    end
	    local isSs = remote.gemstone:checkGemstoneIsSsAptitude(gemstone)
	    if isSs then
	    	local gemstoneSuitsSS = db:getGemstoneEvolutionBygodLevel(gemstone.itemId,GEMSTONE_MAXADVANCED_LEVEL)
	    	local gemstoneSuits_ss = remote.gemstone:getSuitByItemId(gemstoneSuitsSS.gem_evolution_new_id)
		    for index,godGemstoneConfig in pairs(gemstoneSuits_ss) do
		    	if index > 4 then
		    		break
		    	end
		    	if self._hero.gemstones ~= nil then
		    		for _,v in ipairs(self._hero.gemstones) do
		    			local visSs = remote.gemstone:checkGemstoneIsSsAptitude(v)
		    			local gemInfo = db:getGemstoneEvolutionBygodLevel(v.itemId,GEMSTONE_MAXADVANCED_LEVEL)
		    			if gemInfo then
			    			if visSs then 
			    				if gemInfo.gem_evolution_new_id and gemInfo.gem_evolution_new_id == godGemstoneConfig.id then
			    					table.insert(godsuits, v)
			    					break
			    				end
			    			end
			    		else
			    			break
			    		end
		    		end
		    	end	        	    	
		    end
		end
        local mixLevel = gemstone.mix_level or 0
        if mixLevel > 0 then
            local showLv = 999
            for i,v in ipairs(suits) do
                if v.mix_level and  v.mix_level > 0 then
                    table.insert(mixsuits, v)
                    showLv = math.min(showLv , v.mix_level)
                end
            end
            local mixConfig = remote.gemstone:getGemstoneMixConfigAndNextByIdAndLv(gemstone.itemId,mixLevel)
            if mixConfig then
                local num = #mixsuits
                local suitSkill = remote.gemstone:getGemstoneMixSuitConfigByData(mixConfig.gem_suit, num ,showLv)
                if suitSkill and suitSkill.suit_skill then
                    local skillIdTbl = string.split(suitSkill.suit_skill , ";")
                    if skillIdTbl and not q.isEmpty(skillIdTbl) then
                        mixskillId = skillIdTbl[1]
                    end
                end
            end
        end

	    self._strengthenEffectShow = QUIWidgetAnimationPlayer.new()
	    self:getView():addChild(self._strengthenEffectShow)
	    self._strengthenEffectShow:setPosition(ccp(0, 100))
	    self._strengthenEffectShow:playAnimation(ccbFile, function(ccbOwner)
	    	ccbOwner.node_green:setVisible(true)
	    	ccbOwner.node_red:setVisible(false)
	        for i=1,4 do
	            ccbOwner["node_"..i]:setVisible(false)
	        end
	        local index = 1
	        local function addPropText(name,value)
	            if index > 4 then return end
	            value = value or 0
	            if value > 0 then
	                ccbOwner["node_"..index]:setVisible(true)
	                ccbOwner["tf_name"..index]:setString(name.."＋"..value)
	                index = index + 1
	            end
	        end
	        addPropText("攻击", gemstone.prop.attack_value)
	        addPropText("生命", gemstone.prop.hp_value)
	        addPropText("物理防御", gemstone.prop.armor_physical)
	        addPropText("法术防御", gemstone.prop.armor_magic)
	        end, function()
	            if self._strengthenEffectShow ~= nil then
	                self._strengthenEffectShow:disappear()
	                self._strengthenEffectShow = nil
	            end
                self:disableTouchSwallowTop()
				local successTip = app.master.GEMSTONE_SUIT_TIP
	            if #suits > 1 and app.master:getMasterShowState(successTip) then
	            	self.click_lock4tips = true
	                app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogGemstoneActivitySuit", 
	                    options = {suits = suits,successTip = successTip, callback = function ()
	                    	if next(godsuits) ~= nil and #godsuits > 1 then
                				self:getScheduler().performWithDelayGlobal(function()
					                app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogGodGemstoneActivitySuit", 
					                    options = {suits = godsuits,successTip = successTip, suitstype = "godsuit",callback = function ()
					                    	if mixsuits and next(mixsuits) ~= nil and #mixsuits > 1 then
					                    		self:getScheduler().performWithDelayGlobal(function()
	                                                app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogGemstoneSsPlusMixSuit", 
	                                                    options = {suits = mixsuits , successTip = successTip,skillId = mixskillId, suitstype = "mixsuit",callback = function ()
	                                                            suitCallBack()
	                                                     end}}, {isPopCurrentDialog = false})    
												end, 0.5)                  		
                                            else
                                                suitCallBack()
                                            end
					                    end}}, {isPopCurrentDialog = false})	  
								end, 0.5)                  		
	                    	else
	                    		suitCallBack()
	                    	end
	                    end}}, {isPopCurrentDialog = false})
	            else
                	suitCallBack()
	            end
	        end)    
	end,0.2)
end



function QUIDialogHeroGemstoneDetail:gemstoneMixSuccess(sid)

    local gemstone = remote.gemstone:getGemstoneById(sid)
    local ccbFile = "ccb/effects/Baoshi_tips.ccbi"
    if self._strengthenEffectShow ~= nil then
        self._strengthenEffectShow:disappear()
        self._strengthenEffectShow = nil
    end
    
    self._gemstonePos = gemstone.position
    self:refreshPos()
	self:tabSelectHandler()
	self:getOptions().gemstonePos = self._gemstonePos
	self:checkRedTips()

    app.sound:playSound("sound_num")


    local arr = CCArray:create()
    arr:addObject(CCScaleTo:create(0.1,1.2,1.2))
    arr:addObject(CCScaleTo:create(0.05,1.4,1.4))
    arr:addObject(CCScaleTo:create(0.05,1.2,1.2))
    arr:addObject(CCScaleTo:create(0.1,1,1))
    self._gemstoneBoxs[gemstone.position]:runAction(CCSequence:create(arr))

    local suitCallBack = function ()
        if self:safeCheck() then
        	remote.herosUtil:dispatchEvent({name = remote.herosUtil.EVENT_REFESH_BATTLE_FORCE})
            self.click_lock4tips = false
        end
    end

    self:enableTouchSwallowTop()
    self._schedulerHandler = scheduler.performWithDelayGlobal(function ()
    	self._schedulerHandler = nil
	    local gemstoneSuits = remote.gemstone:getSuitByItemId(gemstone.itemId)
	    local suits = {}
	    local godsuits = {}
        local mixsuits = {}
        local mixskillId = nil	  
        local mixLevel = gemstone.mix_level or 0
        local godLevel = gemstone.godLevel or 0
        local onlySkill = mixLevel > 1
        local skillChange = false
		local showLv = 999
		local propDesc = {}
	    for index,gemstoneConfig in ipairs(gemstoneSuits) do
	        if index > 4 then
	            break
	        end
        	if self._hero.gemstones ~= nil then
	            for _,v in ipairs(self._hero.gemstones) do
	                if v.itemId == gemstoneConfig.id and v.mix_level and  v.mix_level > 0 then
						table.insert(mixsuits, v)
                    	showLv = math.min(showLv , v.mix_level)
	                    break
	                end
	            end
	        end
	    end
	    if showLv == mixLevel then
	    	skillChange = true
	    end

        local mixConfig = remote.gemstone:getGemstoneMixConfigAndNextByIdAndLv(gemstone.itemId,mixLevel)
        if mixConfig then
            local num = #mixsuits
            local suitSkill = remote.gemstone:getGemstoneMixSuitConfigByData(mixConfig.gem_suit, num ,showLv)
            if suitSkill and suitSkill.suit_skill then
                local skillIdTbl = string.split(suitSkill.suit_skill , ";")
                if skillIdTbl and not q.isEmpty(skillIdTbl) then
                    mixskillId = tonumber(skillIdTbl[1])
                end
            end
        end
	
	    if mixLevel == 1 and GEMSTONE_MAXADVANCED_LEVEL > godLevel then
	    	local gemstoneSuitsSS = db:getGemstoneEvolutionBygodLevel(gemstone.itemId,GEMSTONE_MAXADVANCED_LEVEL)
	    	local gemstoneSuits_ss = remote.gemstone:getSuitByItemId(gemstoneSuitsSS.gem_evolution_new_id)
		    for index,godGemstoneConfig in pairs(gemstoneSuits_ss) do
		    	if index > 4 then
		    		break
		    	end
		    	if self._hero.gemstones ~= nil then
		    		for _,v in ipairs(self._hero.gemstones) do
		    			local visSs = remote.gemstone:checkGemstoneIsSsAptitude(v)
		    			local gemInfo = db:getGemstoneEvolutionBygodLevel(v.itemId,GEMSTONE_MAXADVANCED_LEVEL)
		    			if gemInfo then
			    			if visSs then 
			    				if gemInfo.gem_evolution_new_id and gemInfo.gem_evolution_new_id == godGemstoneConfig.id then
			    					table.insert(godsuits, v)
			    					break
			    				end
			    			end
			    		else
			    			break
			    		end
		    		end
		    	end	        	    	
		    end
		end
     	local skillCheck = skillChange
     	if mixskillId == nil and onlySkill then
     		skillCheck = false
     	end


        if self._strengthenEffectShow ~= nil then
            self._strengthenEffectShow:disappear()
            self._strengthenEffectShow = nil
        end
        self:disableTouchSwallowTop()
        self.click_lock4tips = true
		app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogHeroGemstoneMixSuccess", 
    		options = {sid = sid,callback = function()
				local successTip = app.master.GEMSTONE_SUIT_TIP
				if app.master:getMasterShowState(successTip) then
					if #godsuits > 1 then
						self:getScheduler().performWithDelayGlobal(function()
							app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogGodGemstoneActivitySuit", 
			                    options = {suits = godsuits,successTip = successTip, suitstype = "godsuit",callback = function ()
			                    	if mixsuits and next(mixsuits) ~= nil and #mixsuits > 1 and skillCheck then
			                    		self:getScheduler().performWithDelayGlobal(function()
		                                    app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogGemstoneSsPlusMixSuit", 
		                                        options = {suits = mixsuits , successTip = successTip,skillId = mixskillId, suitstype = "mixsuit", onlySkill = onlySkill ,callback = function ()
		                                                suitCallBack()
		                                         end}}, {isPopCurrentDialog = false})    
	                                    end, 0.5)
	                                else
	                                    suitCallBack()
	                                end
			                    end}}, {isPopCurrentDialog = false})
						end, 0.5)                  		

					elseif mixsuits and next(mixsuits) ~= nil and #mixsuits > 1 and skillCheck  then
						self:getScheduler().performWithDelayGlobal(function()
	                        app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogGemstoneSsPlusMixSuit", 
	                            options = {suits = mixsuits , successTip = successTip,skillId = mixskillId, suitstype = "mixsuit" , onlySkill = onlySkill ,callback = function ()
	                                    suitCallBack()
	                             end}}, {isPopCurrentDialog = false})  
						end, 0.5)                  		
					else
	            		suitCallBack()
					end	    
				else		
					suitCallBack()
				end	    		
    	end}}, {isPopCurrentDialog = false})
	end,0.2)
end


function QUIDialogHeroGemstoneDetail:gemstoneMixSuccessHandler(e)
	if not (e and e.gemstone) then
		return
	end
	local gemstone = e.gemstone
	self.click_lock4tips = true
	local mixLv = gemstone.mix_level or 0
	local sid = gemstone.sid or 0
	local endFunc = function ( )
		self._ccbOwner.node_effect:setVisible(false)
		self._ccbOwner.node_action:removeAllChildren()
		self:gemstoneMixSuccess(sid)
	end

	self._ccbOwner.node_effect:setVisible(true)

	self._ccbOwner.node_action:removeAllChildren()
	self._ccbOwner.node_action:setScale(1.5)
	local gemBox = QUIWidgetGemstonesBox.new()
	gemBox:setGemstoneInfo(gemstone)
	gemBox:setPosition(-50,100)
	gemBox:setScale(0.1)
	gemBox:setMixLevel(0)
	
    local dur = q.flashFrameTransferDur(5)
    local dur2 = q.flashFrameTransferDur(3)

	-- self._ccbOwner.node_action:addChild(gemBox)

	local newHeadVibrate = QUIWidgetHeroHeadVibrate.new({star = mixLv, head = gemBox, scale = 0.8})
	newHeadVibrate:setStarPosition(0, 6)
	self._ccbOwner.node_action:addChild(newHeadVibrate)

	local arrMoveAndScale = CCArray:create()
	arrMoveAndScale:addObject(CCMoveTo:create(dur, ccp(0, 0)))
	arrMoveAndScale:addObject(CCScaleTo:create(dur, 1))

    local arr = CCArray:create()
    arr:addObject(CCSpawn:create(arrMoveAndScale))
    arr:addObject(CCScaleTo:create(dur2, 1.2))
    arr:addObject(CCScaleTo:create(dur2, 1))
    arr:addObject(CCCallFunc:create(function()

		app.sound:playSound("gemstone_mix")

		local resAni = QResPath("gemstone_mix_ani")
	    local fcaAnimation = QUIWidgetFcaAnimation.new(resAni, "res")
	    self._ccbOwner.node_action:addChild(fcaAnimation)
	    fcaAnimation:playAnimation("animation", false)
		fcaAnimation:setEndCallback(function( )
			fcaAnimation:removeFromParent()
			newHeadVibrate:playStarAnimation(endFunc)
		end)
    end)) 
    gemBox:runAction(CCSequence:create(arr))

end


--检查是否触发突破大师
function QUIDialogHeroGemstoneDetail:checkTriggerBreakMaster()
	local masterLevel = remote.herosUtil:getUIHeroByID(self._actorId):getMasterLevelByType(QUIHeroModel.GEMSTONE_BREAK_MASTER)
	if masterLevel > 0 then
		self._masterDialog = app.master:upGradeGemstoneMaster(0, masterLevel, QUIHeroModel.GEMSTONE_BREAK_MASTER, self._actorId)
		if self._masterDialog then
			self._masterDialog:addEventListener(self._masterDialog.EVENT_CLOSE, function (e)
	    		self._masterDialog:removeAllEventListeners()
	    		self._masterDialog = nil
	    		self:checkTriggerStrengthMaster()
				end)
		else
			self:checkTriggerStrengthMaster()
		end
	else
		self:checkTriggerStrengthMaster()
	end
end

--检查是否触发突破大师
function QUIDialogHeroGemstoneDetail:checkTriggerStrengthMaster()
	local masterLevel = remote.herosUtil:getUIHeroByID(self._actorId):getMasterLevelByType(QUIHeroModel.GEMSTONE_MASTER)
	if masterLevel > 0 then
		self._masterDialog = app.master:upGradeGemstoneMaster(0, masterLevel, QUIHeroModel.GEMSTONE_MASTER, self._actorId)
		if self._masterDialog then
			self._masterDialog:addEventListener(self._masterDialog.EVENT_CLOSE, function (e)
	    		self._masterDialog:removeAllEventListeners()
	    		self._masterDialog = nil
	    		self.click_lock4tips = false
					remote.herosUtil:dispatchEvent({name = remote.herosUtil.EVENT_REFESH_BATTLE_FORCE})
				end)
		else
			self.click_lock4tips = false
			remote.herosUtil:dispatchEvent({name = remote.herosUtil.EVENT_REFESH_BATTLE_FORCE})
		end
	else
		self.click_lock4tips = false
		remote.herosUtil:dispatchEvent({name = remote.herosUtil.EVENT_REFESH_BATTLE_FORCE})
	end
end

function QUIDialogHeroGemstoneDetail:removeAllTabState()
	self._ccbOwner.tab_strong:setEnabled(true)
	self._ccbOwner.tab_strong:setHighlighted(false)
	self._ccbOwner.tab_evolution:setEnabled(true)
	self._ccbOwner.tab_evolution:setHighlighted(false)
	self._ccbOwner.tab_detail:setEnabled(true)
	self._ccbOwner.tab_detail:setHighlighted(false)
	self._ccbOwner.tab_advanced:setEnabled(true)
	self._ccbOwner.tab_advanced:setHighlighted(false)
	self._ccbOwner.tab_togod:setEnabled(true)
	self._ccbOwner.tab_togod:setHighlighted(false)
end

function QUIDialogHeroGemstoneDetail:checkShowOneStrongBtn( )
	if not app.unlock:checkLock("UNLOCK_GEMSTONE_ONE_KEY", false) then
       self._ccbOwner.node_quick_strengthen:setVisible(false)
       return
    end
    if #self._hero.gemstones < 4 then
    	self._ccbOwner.node_quick_strengthen:setVisible(false)
    else
        self._ccbOwner.node_quick_str_effect:setVisible(not app:getUserData():getValueForKey("UNLOCK_GEMSTONE_ONE_KEY"..remote.user.userId))
    	self._ccbOwner.node_quick_strengthen:setVisible(true)
    end
end

function QUIDialogHeroGemstoneDetail:checkShowOneBreakBtn( )
	if not app.unlock:checkLock("UNLOCK_GEMSTONE_BREAKTHROUGH_ONE_KEY", false) then
       self._ccbOwner.node_quick_break_through:setVisible(false)
       return
    end
    if #(self._hero.gemstones or {}) < 4 then
    	self._ccbOwner.node_quick_break_through:setVisible(false)
    else
    	self._ccbOwner.node_quick_break_through:setVisible(true)
		self._ccbOwner.node_oneclick_effect:setVisible(not app:getUserData():getValueForKey("UNLOCK_GEMSTONE_BREAKTHROUGH_ONE_KEY"..remote.user.userId) )
    end
end

function QUIDialogHeroGemstoneDetail:selectedTabStrong()
	-- self._ccbOwner.tab_strong:setEnabled(false)
	-- self._ccbOwner.tab_strong:setHighlighted(true)
	--self._ccbOwner.btn_bag:setVisible(false)
	self._tabManager:selected(self._ccbOwner.tab_strong)
	self:checkShowOneStrongBtn()
	-- 显示装备突破界面并刷新
	if self._strong == nil then
		self._strong = QUIWidgetHeroGemstoneStrength.new()
		self._strong:setTopAnimationNode(self._ccbOwner.strenAnimationNode)
		self._strong:setParentDailog(self)
		self._ccbOwner.node_right:addChild(self._strong)
	end
	self._strong:resetAll()
	self._strong:setInfo(self._actorId, self._gemstoneSid, self._gemstonePos)
	self._infoWidget = self._strong

	for _,box in ipairs(self._gemstoneBoxs) do
		box:setStrengthVisible(true)
		box:showTipsByState("strength")
		-- box:setBreakTips(false)
		-- box:setStrengthTips(true)
	end
	self:changeMasterByType(QUIHeroModel.GEMSTONE_MASTER)
end

function QUIDialogHeroGemstoneDetail:selectedTabEvolution()
	-- self._ccbOwner.tab_evolution:setEnabled(false)
	-- self._ccbOwner.tab_evolution:setHighlighted(true)
	--self._ccbOwner.btn_bag:setVisible(false)
	self._tabManager:selected(self._ccbOwner.tab_evolution)
	self:checkShowOneBreakBtn()
	-- 显示装备突破界面并刷新
	if self._evolution == nil then
		self._evolution = QUIWidgetHeroGemstoneEvolution.new()
		self._ccbOwner.node_right:addChild(self._evolution)
	end
	self._evolution:resetAll()
	self._evolution:setInfo(self._actorId, self._gemstoneSid, self._gemstonePos)
	self._infoWidget = self._evolution

	for _,box in ipairs(self._gemstoneBoxs) do
		box:setStrengthVisible(false)
		box:showTipsByState("evolution")
		-- box:setBreakTips(true)
		-- box:setStrengthTips(false)
	end
	self:changeMasterByType(QUIHeroModel.GEMSTONE_BREAK_MASTER)
end

function QUIDialogHeroGemstoneDetail:selectedTabDetail()
	self._tabManager:selected(self._ccbOwner.tab_detail)
	-- self._ccbOwner.tab_detail:setEnabled(false)
	-- self._ccbOwner.tab_detail:setHighlighted(true)
	self._ccbOwner.btn_bag:setVisible(true)
	if self._detailWidget == nil then
		self._detailWidget = QUIWidgetHeroGemstoneDetail.new({actorId=self._actorId, gemstoneSid=self._gemstoneSid, gemstonePos=self._gemstonePos , callback = handler(self, self.getClickLock)})
		self._ccbOwner.node_right:addChild(self._detailWidget)
	end
	self._detailWidget:setInfo(self._actorId, self._gemstoneSid, self._gemstonePos)
	-- self._detailWidget:setInfo()
	self._infoWidget = self._detailWidget

	for _,box in ipairs(self._gemstoneBoxs) do
		box:setStrengthVisible(true)
		box:showTipsByState("detail")
	end
	self:changeMasterByType(nil)
end

function QUIDialogHeroGemstoneDetail:getClickLock()
	return self.click_lock4tips
end


function QUIDialogHeroGemstoneDetail:selectedTabAdvanced()
	self._tabManager:selected(self._ccbOwner.tab_advanced)
	-- self._ccbOwner.tab_advanced:setEnabled(false)
	-- self._ccbOwner.tab_advanced:setHighlighted(true)
	self._ccbOwner.btn_bag:setVisible(true)
	if self._advancedWidget == nil then
		self._advancedWidget = QUIWidgetHeroGemstoneAdvanced.new()
		self._ccbOwner.node_right:addChild(self._advancedWidget)
	end

	self._advancedWidget:setInfo(self._actorId, self._gemstoneSid, self._gemstonePos)
	self._infoWidget = self._advancedWidget

	self:changeMasterByType(nil)
end

function QUIDialogHeroGemstoneDetail:selectedTabToGod( )
	self._tabManager:selected(self._ccbOwner.tab_togod)
	-- self._ccbOwner.tab_togod:setEnabled(false)
	-- self._ccbOwner.tab_togod:setHighlighted(true)	
	self._ccbOwner.btn_bag:setVisible(true)
	if self._toGodWidget == nil then
		self._toGodWidget = QUIWidgetHeroGemstoneToGod.new()
		self._ccbOwner.node_right:addChild(self._toGodWidget)
	end
	self._toGodWidget:setInfo(self._actorId, self._gemstoneSid, self._gemstonePos)
	self._infoWidget = self._toGodWidget
		
	self:changeMasterByType(nil)
	

	-- if self._lastAdvancedType == remote.gemstone.EVENT_ADVANCED then 
	-- 	local ccbFile = "ccb/effects/tupo.ccbi"
	-- 	local effectShow = QUIWidgetAnimationPlayer.new()
	-- 	self._ccbOwner.node_right:addChild( effectShow )
	-- 	effectShow:setPosition(ccp(0, 0))

	-- 	effectShow:playAnimation(ccbFile, function()
	-- 	end, function()  
	-- 		print("动画播放结束-------")
	-- 		godFunction()
	-- 		effectShow:setVisible(false)
	-- 		effectShow:disappear()
	-- 	end)
	-- else
	-- 	godFunction()
	-- end
end

function QUIDialogHeroGemstoneDetail:selectedTabFuse()
	self._tabManager:selected(self._ccbOwner.tab_fuse)
	self._ccbOwner.btn_bag:setVisible(true)
	if self._mixWidget == nil then
		self._mixWidget = QUIWidgetHeroGemstoneMix.new({callback = handler(self, self.getClickLock)})
		self._ccbOwner.node_right:addChild(self._mixWidget)
	end
	self._mixWidget:setInfo(self._actorId, self._gemstoneSid, self._gemstonePos )
	self._infoWidget = self._mixWidget
	for _,box in ipairs(self._gemstoneBoxs) do
		box:setStrengthVisible(true)
		box:showTipsByState("mix")
	end	
	self:changeMasterByType(nil)

end

function QUIDialogHeroGemstoneDetail:selectedTabRefine()
	self._tabManager:selected(self._ccbOwner.tab_refine)
	-- self._ccbOwner.tab_togod:setEnabled(false)
	-- self._ccbOwner.tab_togod:setHighlighted(true)	
	self._ccbOwner.btn_bag:setVisible(true)
	if self._refineWidget == nil then
		self._refineWidget = QUIWidgetHeroGemstoneRefine.new()
		self._ccbOwner.node_right:addChild(self._refineWidget)
	end
	self._refineWidget:setInfo(self._actorId, self._gemstoneSid, self._gemstonePos)
	self._infoWidget = self._refineWidget
	for _,box in ipairs(self._gemstoneBoxs) do
		box:setStrengthVisible(true)
		box:showTipsByState("refine")
	end		
	self:changeMasterByType(nil)
end

function QUIDialogHeroGemstoneDetail:changeMasterByType(masterType)
	if masterType == nil then 
		self._ccbOwner.node_master:setVisible(false)
		return
	end
	local masterLevel = self._heroUIModel:getMasterLevelByType(masterType)
	masterLevel = masterLevel or 0
	if masterLevel == 0 then
		self._ccbOwner.node_master_level:setVisible(false)
	else
		self._ccbOwner.node_master_level:setVisible(true)
		self._ccbOwner.tf_master_level:setString(masterLevel)
	end
	if masterType == QUIHeroModel.GEMSTONE_BREAK_MASTER and app.master:checkGemstoneBreakMasterUnlock() then
		self._ccbOwner.node_master:setVisible(true)
	elseif masterType == QUIHeroModel.GEMSTONE_MASTER and app.master:checkGemstoneStrengthMasterUnlock() then
		self._ccbOwner.node_master:setVisible(true)
	end
end

function QUIDialogHeroGemstoneDetail:_onTriggerTabAdvanced()
	app.sound:playSound("common_menu")
	if self._advancedWidget and self._advancedWidget:isOnekeyPlaying() then return end
	self:selectTab(QUIDialogHeroGemstoneDetail.TAB_ADVANCED)
end

function QUIDialogHeroGemstoneDetail:_onTriggerTabToGod()
	app.sound:playSound("common_menu")
	if self._advancedWidget and self._advancedWidget:isOnekeyPlaying() then return end
	self:selectTab(QUIDialogHeroGemstoneDetail.TAB_TOGOD)
end

function QUIDialogHeroGemstoneDetail:_onTriggerTabStrong()
	app.sound:playSound("common_menu")
	if self._advancedWidget and self._advancedWidget:isOnekeyPlaying() then return end
	self:selectTab(QUIDialogHeroGemstoneDetail.TAB_STRONG)
end

function QUIDialogHeroGemstoneDetail:_onTriggerTabEvolution()
	app.sound:playSound("common_menu")
	if self._advancedWidget and self._advancedWidget:isOnekeyPlaying() then return end
	self:selectTab(QUIDialogHeroGemstoneDetail.TAB_EVOLUTION)
end

function QUIDialogHeroGemstoneDetail:_onTriggerTabDetail()
	app.sound:playSound("common_menu")
	if self._advancedWidget and self._advancedWidget:isOnekeyPlaying() then return end
	self:selectTab(QUIDialogHeroGemstoneDetail.TAB_DETAIL)
end

function QUIDialogHeroGemstoneDetail:_onTriggerTabFuse()
	app.sound:playSound("common_menu")
	if self._advancedWidget and self._advancedWidget:isOnekeyPlaying() then return end
	self:selectTab(QUIDialogHeroGemstoneDetail.TAB_FUSE)
end

function QUIDialogHeroGemstoneDetail:_onTriggerTabRefine()
	app.sound:playSound("common_menu")
	if self._advancedWidget and self._advancedWidget:isOnekeyPlaying() then return end
	if self._gemstoneSid then
		local gemstone = remote.gemstone:getGemstoneById(self._gemstoneSid)
		if gemstone.mix_level and gemstone.mix_level > 0 then 
			self:selectTab(QUIDialogHeroGemstoneDetail.TAB_REFINE)
		else
			app.tip:floatTip("融合至SS+后开启魂骨精炼！")
			return 
		end
	end
end

function QUIDialogHeroGemstoneDetail:_onTriggerBag(e)
	if e ~= nil then
		app.sound:playSound("common_common")
	end
	if self._advancedWidget and self._advancedWidget:isOnekeyPlaying() then return end
    return app:getNavigationManager():pushViewController(app.mainUILayer, 
                    {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogGemstoneBackpack"})
end

function QUIDialogHeroGemstoneDetail:_onTriggerMaster(e)
	if self._advancedWidget and self._advancedWidget:isOnekeyPlaying() then return end
	if self._currentTab == QUIDialogHeroGemstoneDetail.TAB_STRONG then
		app:getNavigationManager():pushViewController(app.mainUILayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogMaster",
        options = {actorId=self._actorId, masterType=QUIHeroModel.GEMSTONE_MASTER, isPopParentDialog = true, pos = self._pos, parentOptions = self:getOptions(), heros = self._heros}})
	elseif self._currentTab == QUIDialogHeroGemstoneDetail.TAB_EVOLUTION then
		app:getNavigationManager():pushViewController(app.mainUILayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogMaster",
        options = {actorId=self._actorId, masterType=QUIHeroModel.GEMSTONE_BREAK_MASTER, isPopParentDialog = true, pos = self._pos, parentOptions = self:getOptions(), heros = self._heros}})
	end
end


function QUIDialogHeroGemstoneDetail:_onQuickStrengthen( event )
	if q.buttonEventShadow(event, self._ccbOwner.btn_oneclick_strengthen) == false then return end
	app.sound:playSound("common_small")
	if self._advancedWidget and self._advancedWidget:isOnekeyPlaying() then return end
    if not app:getUserData():getValueForKey("UNLOCK_GEMSTONE_ONE_KEY"..remote.user.userId) then
        app:getUserData():setValueForKey("UNLOCK_GEMSTONE_ONE_KEY"..remote.user.userId, "true")
        self._ccbOwner.node_quick_str_effect:setVisible(false)
    end 	
    local actorId = self._actorId
    local characterInfo = QStaticDatabase:sharedDatabase():getCharacterByID(actorId)
    local heroModel = remote.herosUtil:getUIHeroByID(actorId)
    local masterType = QUIHeroModel.GEMSTONE_MASTER

	local masterLevel = heroModel:getMasterLevelByType(masterType)

    local currMasterInfo, nextMasterInfo, isMax = QStaticDatabase:sharedDatabase():getStrengthenMasterByMasterLevel(masterType, masterLevel)

    if self._hero.gemstones and #self._hero.gemstones == 4 then
	    if not isMax then
			app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogOneClickGemStoneStrengthen", 
	                options = {actorId=actorId, masterType=masterType, parentOptions = self:getOptions()}}) 
		else
			 app.tip:floatTip("已经到达最高魂骨强化大师等级")
		end
	else
		app.tip:floatTip("请先装备4件魂骨～")
	end
end

function QUIDialogHeroGemstoneDetail:_onQuickBreakThrough( event )
	if q.buttonEventShadow(event, self._ccbOwner.btn_oneclick_break_through) == false then return end
	app.sound:playSound("common_small")
	if self._advancedWidget and self._advancedWidget:isOnekeyPlaying() then return end
    if not app:getUserData():getValueForKey("UNLOCK_GEMSTONE_BREAKTHROUGH_ONE_KEY"..remote.user.userId) then
        app:getUserData():setValueForKey("UNLOCK_GEMSTONE_BREAKTHROUGH_ONE_KEY"..remote.user.userId, "true")
        self._ccbOwner.node_oneclick_effect:setVisible(false)
    end 	
    local actorId = self._actorId
    local characterInfo = QStaticDatabase:sharedDatabase():getCharacterByID(actorId)
    local heroModel = remote.herosUtil:getUIHeroByID(actorId)
    local masterType = QUIHeroModel.GEMSTONE_BREAK_MASTER
	local masterLevel = heroModel:getMasterLevelByType(masterType)

    local currMasterInfo, nextMasterInfo, isMax = db:getStrengthenMasterByMasterLevel(masterType, masterLevel)
    if not isMax then
		app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogOneClickGemStoneBreakThrough", 
            options = {actorId=actorId, masterType=masterType}}) 
	else
		 app.tip:floatTip("已经到达最高魂骨突破大师等级")
	end
end

function QUIDialogHeroGemstoneDetail:_onTriggerRight()
	if self._infoWidget and self._infoWidget.isAnimation then
		if self._infoWidget:isAnimation() then
			return
		end
	end

	if self.click_lock4tips then
		return
	end

    app.sound:playSound("common_change")
    if self._advancedWidget and self._advancedWidget:isOnekeyPlaying() then return end
    
    remote.herosUtil:dispatchEvent({name = remote.herosUtil.EVENT_SAVE_STRENGTHEN_EXP})
    local n = table.nums(self._heros)
    if nil ~= self._pos and n > 1 then
        self._pos = self._pos + 1
        if self._pos > n then
            self._pos = 1
        end
        local options = self:getOptions()
        options.pos = self._pos
        if options.parentOptions ~= nil then
        	options.parentOptions.pos = options.pos
        end
        self._oldBattleForce = 0
	    if self._textUpdate ~= nil then
			self._textUpdate:stopUpdate()
			self._textUpdate = nil
		end
		self:setInfo(self._heros[self._pos], self._equipmentPos)
	end
end

function QUIDialogHeroGemstoneDetail:_onTriggerLeft()
	if self._infoWidget and self._infoWidget.isAnimation then
		if self._infoWidget:isAnimation() then
			return
		end
	end
	if self.click_lock4tips then
		return
	end
	
    app.sound:playSound("common_change")
	if self._advancedWidget and self._advancedWidget:isOnekeyPlaying() then return end

    remote.herosUtil:dispatchEvent({name = remote.herosUtil.EVENT_SAVE_STRENGTHEN_EXP})
    local n = table.nums(self._heros)
    if nil ~= self._pos and n > 1 then
        self._pos = self._pos - 1
        if self._pos < 1 then
            self._pos = n
        end
        local options = self:getOptions()
        options.pos = self._pos
        if options.parentOptions ~= nil then
        	options.parentOptions.pos = options.pos
        end
        self._oldBattleForce = 0
	    if self._textUpdate ~= nil then
			self._textUpdate:stopUpdate()
			self._textUpdate = nil
		end
		self:setInfo(self._heros[self._pos], self._equipmentPos)
	end
end

function QUIDialogHeroGemstoneDetail:onTriggerBackHandler(tag)
	if self._topTouchLayer ~= nil then return end
	self:_onTriggerBack()
end

function QUIDialogHeroGemstoneDetail:onTriggerHomeHandler(tag)
	if self._topTouchLayer ~= nil then return end
	self:_onTriggerHome()
end
 
-- 对话框退出
function QUIDialogHeroGemstoneDetail:_onTriggerBack(tag, menuItem)
	if self._advancedWidget and self._advancedWidget:isOnekeyPlaying() then return end
    self:enableTouchSwallowTop()
	app:getNavigationManager():popViewController(app.mainUILayer, QNavigationController.POP_TOP_CONTROLLER)
end

-- 对话框退出
function QUIDialogHeroGemstoneDetail:_onTriggerHome(tag, menuItem)
	if self._advancedWidget and self._advancedWidget:isOnekeyPlaying() then return end
    self:enableTouchSwallowTop()
	app:getNavigationManager():popViewController(app.mainUILayer, QNavigationController.POP_TO_CURRENT_PAGE)
end


function  QUIDialogHeroGemstoneDetail:detailMoveTo( top_,callBack )
	-- body
	if self._detailWidget then
		self._detailWidget:runAni(top_,callBack)
	end
end


return QUIDialogHeroGemstoneDetail