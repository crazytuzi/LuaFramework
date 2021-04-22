--
-- Author: Kumo.Wang
-- 仙品养成主界面
--
local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogMagicHerbDetail = class("QUIDialogMagicHerbDetail", QUIDialog)

local QUIViewController = import("..QUIViewController")
local QNavigationController = import("...controllers.QNavigationController")
local QTextFiledScrollUtils = import("...utils.QTextFiledScrollUtils")
local QUIWidgetAnimationPlayer = import("..widgets.QUIWidgetAnimationPlayer")
local QUIWidgetHeroInformation = import("..widgets.QUIWidgetHeroInformation")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QUIHeroModel = import("...models.QUIHeroModel")

local QUIWidgetHeroMagicHerbEmpty = import("..widgets.QUIWidgetHeroMagicHerbEmpty")
local QUIWidgetMagicHerbDetail = import("..widgets.QUIWidgetMagicHerbDetail")
local QUIWidgetMagicHerbAdvance = import("..widgets.QUIWidgetMagicHerbAdvance")
local QUIWidgetMagicHerbUpLevel = import("..widgets.QUIWidgetMagicHerbUpLevel")
local QUIWidgetMagicHerbRefine = import("..widgets.QUIWidgetMagicHerbRefine")
local QUIWidgetMagicHerbBreed = import("..widgets.QUIWidgetMagicHerbBreed")


local QUIWidgetMagicHerbBox = import("..widgets.QUIWidgetMagicHerbBox")

QUIDialogMagicHerbDetail.TAB_DETAIL = 1 -- 详细
QUIDialogMagicHerbDetail.TAB_ADVANCE = 2 -- 升星
QUIDialogMagicHerbDetail.TAB_UPLEVEL = 3 -- 升级
QUIDialogMagicHerbDetail.TAB_REFINE = 4 -- 转生
QUIDialogMagicHerbDetail.TAB_BREED = 5 -- 培育

function QUIDialogMagicHerbDetail:ctor(options)
    local ccbFile = "ccb/Dialog_MagicHerb.ccbi"
    local callBack = {
		{ccbCallbackName = "onTriggerBack", callback = handler(self, self._onTriggerBack)},
        {ccbCallbackName = "onTriggerDetail", callback = handler(self, self._onTriggerDetail)},
        {ccbCallbackName = "onTriggerAdvance", callback = handler(self, self._onTriggerAdvance)},
        {ccbCallbackName = "onTriggerUpLevel", callback = handler(self, self._onTriggerUpLevel)},
        {ccbCallbackName = "onTriggerRefine", callback = handler(self, self._onTriggerRefine)},
        {ccbCallbackName = "onTriggerBreed", callback = handler(self, self._onTriggerBreed)},
        {ccbCallbackName = "onTriggerLeft", callback = handler(self, self._onTriggerLeft)},
		{ccbCallbackName = "onTriggerRight", callback = handler(self, self._onTriggerRight)},
        {ccbCallbackName = "onTriggerMaster", callback = handler(self, self._onTriggerMaster)},
        {ccbCallbackName = "onTriggerBag", callback = handler(self, self._onTriggerBag)},
        {ccbCallbackName = "onQuickEvolution", callback = handler(self, self._onQuickEvolution)},
    }

    QUIDialogMagicHerbDetail.super.ctor(self, ccbFile, callBack, options)
    self._page = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
    self._page:setManyUIVisible()
    self._page.topBar:showWithMagicHerbUpLevel()

    ui.tabButton(self._ccbOwner.btn_detail, "详情")
    ui.tabButton(self._ccbOwner.btn_advance, "升星")
    ui.tabButton(self._ccbOwner.btn_upLevel, "升级")
    ui.tabButton(self._ccbOwner.btn_refine, "转生")
    ui.tabButton(self._ccbOwner.btn_breed, "培育")

    self._tabManager = ui.tabManager({ self._ccbOwner.btn_detail
    	, self._ccbOwner.btn_advance
    	, self._ccbOwner.btn_upLevel
    	, self._ccbOwner.btn_refine
    	, self._ccbOwner.btn_breed})

    if options ~= nil then
        self._tabType = options.tabType
        -- self._actorId = options.actorId
        self._pos = options.pos -- 仙品装备的位置
        self._sid = options.sid -- 仙品的sid
		self._heroList = options.heroList or {} -- 英雄列表
		self._heroPos = options.heroPos -- 英雄列表的位置
		self._actorId = self._heroList[self._heroPos]
    end
    self._tabType = self._tabType or QUIDialogMagicHerbDetail.TAB_DETAIL
    self._pos = self._pos or 1

    self:_init()
end

function QUIDialogMagicHerbDetail:_reset()
	self._ccbOwner.frame_tf_title:setVisible(true)
	self._ccbOwner.sp_advance_tip:setVisible(false)
	self._ccbOwner.sp_upLevel_tip:setVisible(false)
	self._ccbOwner.sp_refine_tip:setVisible(false)
	self._ccbOwner.sp_breed_tip:setVisible(false)
	self._ccbOwner.node_master:setVisible(true)
	self._ccbOwner.master_level:setVisible(false)
	self._ccbOwner.tf_name:setVisible(false)
	self._ccbOwner.tf_level:setVisible(false)

	self._ccbOwner.node_avatar:removeAllChildren()
	self._ccbOwner.node_battleForce_effect:removeAllChildren()
	self._ccbOwner.node_box_1:removeAllChildren()
	self._ccbOwner.node_box_2:removeAllChildren()
	self._ccbOwner.node_box_3:removeAllChildren()
	self._ccbOwner.node_right:removeAllChildren()
	self._ccbOwner.node_quick_evolution:setVisible(false)

	local isOnlyOneHero = #self._heroList <= 1
    self._ccbOwner.arrowLeft:setVisible(not isOnlyOneHero)
    self._ccbOwner.btn_left:setVisible(not isOnlyOneHero)
    self._ccbOwner.arrowRight:setVisible(not isOnlyOneHero)
    self._ccbOwner.btn_right:setVisible(not isOnlyOneHero)
end

function QUIDialogMagicHerbDetail:_init()
    self:_reset()

	self._oldBattleForce = 0
	self._magicHerbBoxlist = {}

	local pos = 1
    while true do
        local node = self._ccbOwner["node_box_"..pos]
        if node then
            node:removeAllChildren()
            local box = QUIWidgetMagicHerbBox.new({pos = pos})
            box:addEventListener(QUIWidgetMagicHerbBox.EVENT_CLICK, handler(self, self._onEvent))
            node:addChild(box)
            self._magicHerbBoxlist[pos] = box
            pos = pos + 1
        else
            break
        end
    end

    self:_initQuickLevelUpBtn()
end

function QUIDialogMagicHerbDetail:_initQuickLevelUpBtn()
	if not self._heroUIModel then return end
	
	local unlockKey = "UNLOCK_MAGIC_HERB_ONE_KEY"
	local unlock = app.unlock:checkLock(unlockKey, false)
	local isOpen = false
	if unlock and (self._tabType == QUIDialogMagicHerbDetail.TAB_UPLEVEL) then
		isOpen = true
		for i,v in pairs(self._magicHerbBoxlist) do
			local wearedInfo = self._heroUIModel:getMagicHerbWearedInfoByPos(i)
			if not wearedInfo then
				isOpen = false
				break
			end
		end
	end
	self._ccbOwner.node_quick_evolution:setVisible(isOpen)
end

function QUIDialogMagicHerbDetail:viewDidAppear()
	QUIDialogMagicHerbDetail.super.viewDidAppear(self)

	-- self._remoteProxy = cc.EventProxy.new(remote)
	-- self._remoteProxy:addEventListener(remote.HERO_UPDATE_EVENT, handler(self, self._onEvent))

	self._magicHerbProxy = cc.EventProxy.new(remote.magicHerb)
    self._magicHerbProxy:addEventListener(remote.magicHerb.EVENT_REFRESH_MAGIC_HERB, handler(self, self._onEvent))
    self._magicHerbProxy:addEventListener(remote.magicHerb.EVENT_REFRESH_MAGIC_HERB_BREED_SUCCESS, handler(self, self._onEvent))

	self._heroProxy = cc.EventProxy.new(remote.herosUtil)
	self._heroProxy:addEventListener(remote.herosUtil.EVENT_REFESH_BATTLE_FORCE, handler(self, self._onEvent))
	
	self:_updateHeroInfo()
	self:addBackEvent()
end

function QUIDialogMagicHerbDetail:viewWillDisappear()
	QUIDialogMagicHerbDetail.super.viewWillDisappear(self)

	-- self._remoteProxy:removeAllEventListeners()
	self._heroProxy:removeAllEventListeners()
	self._magicHerbProxy:removeAllEventListeners()

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

	self:removeBackEvent()
end

function QUIDialogMagicHerbDetail:_onEvent(event)
	if event.name == QUIWidgetMagicHerbBox.EVENT_CLICK then
		app.sound:playSound("common_item")
		self._actorId = event.actorId
		self._pos = event.pos
    	self:getOptions().pos = self._pos
    	self:getOptions().sid = event.sid
		self:_updateSid()
		self:_switchTab()
		self:_updateBoxSelectedState()
		if not event.sid then
			self._oldMinAptitudeInSuit = self._heroUIModel:getMinAptitudeInSuit()
			self._oldMinBreedLvInSuit = self._heroUIModel:getMinBreedInSuit()
			app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogMagicHerbCheckroom", 
        		options = {actorId = event.actorId, pos = event.pos}})
		end
	elseif event.name == remote.herosUtil.EVENT_REFESH_BATTLE_FORCE then
		self:_refreshBatlleForce()
	elseif event.name == remote.magicHerb.EVENT_REFRESH_MAGIC_HERB then
		self:_updateSid()
		self:_updateBox()
		self:_switchTab()
		self:_checkRedTips()
		-- self:_refreshBatlleForce()
		print(" EVENT_REFRESH_MAGIC_HERB : ", event.isOnWear, self._oldMinAptitudeInSuit, self._heroUIModel:getMinAptitudeInSuit())
		if event.isOnWear  and self._oldMinAptitudeInSuit then
			self:enableTouchSwallowTop()
			local _minAptitudeInSuit = self._heroUIModel:getMinAptitudeInSuit()
			if self._oldMinAptitudeInSuit == 9999 and _minAptitudeInSuit ~= 9999 or self._oldMinAptitudeInSuit < _minAptitudeInSuit then
				local suitSkill,_minAptitudeInSuit,_minBreedLvInSuit , magicHerbSuitConfig = self._heroUIModel:getMagicHerbSuitSkill()
                if suitSkill then
                    -- 套装激活展示界面
                    app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogMagicHerbActivateSuit", 
                        options = {actorId = self._actorId, suitSkill = suitSkill , magicHerbSuitConfig = magicHerbSuitConfig , callback = handler(self, self._showMasterLevelUp)}})
					self:disableTouchSwallowTop()
				else
					self:_showMasterLevelUp()
					self:disableTouchSwallowTop()
                end
           	else
               	self:_refreshBatlleForce()
				self:_showMasterLevelUp()
               	self:disableTouchSwallowTop()
			end
			self._oldMinAptitudeInSuit = nil
			self._oldMinBreedLvInSuit = self._heroUIModel:getMinBreedInSuit()
		elseif self._oldMinAptitudeInSuit == nil then
			-- 卸下
			self:_refreshBatlleForce()
			self:_showMasterLevelUp()
		end
	elseif event.name == remote.magicHerb.EVENT_REFRESH_MAGIC_HERB_BREED_SUCCESS then
		self:_updateSid()
		self:_updateBox()
		self:_switchTab()
		self:_checkRedTips()
		
		local suitSkill,_minAptitudeInSuit,_minBreedLvInSuit , magicHerbSuitConfig = self._heroUIModel:getMagicHerbSuitSkill()
		print(remote.magicHerb.EVENT_REFRESH_MAGIC_HERB_BREED_SUCCESS	,  self._oldMinBreedLvInSuit, _minBreedLvInSuit )
		if suitSkill and self._oldMinBreedLvInSuit ~= _minBreedLvInSuit and magicHerbSuitConfig.breed > 0 and magicHerbSuitConfig.breed == _minBreedLvInSuit then
			self:enableTouchSwallowTop()
			app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogMagicHerbActivateSuit", 
                    options = {actorId = self._actorId, suitSkill = suitSkill, magicHerbSuitConfig = magicHerbSuitConfig }})
			self:disableTouchSwallowTop()
			self._oldMinBreedLvInSuit = _minBreedLvInSuit
		else
			self:_refreshBatlleForce()
			self:_showMasterLevelUp()
           	self:disableTouchSwallowTop()
		end		
	end
end

function QUIDialogMagicHerbDetail:_refreshBatlleForce()
	if self._oldBattleForce == nil or self._oldBattleForce == 0 then return end

	local heroProp = remote.herosUtil:createHeroPropById(self._actorId)
	local battleForce = heroProp:getBattleForce()
	if self._textUpdate == nil then
		self._textUpdate = QTextFiledScrollUtils.new()
	end
	local forceChange = math.floor(battleForce - self._oldBattleForce)
	self._newBattle = battleForce
	self._ccbOwner.tf_battleForce:runAction(CCScaleTo:create(0.2, 1.5))
	self._textUpdate:addUpdate(self._oldBattleForce, battleForce, handler(self, self._setBattleForceText), 1)
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
      	self._ccbOwner.node_battleForce_effect:addChild(numEffect)
      	numEffect:playAnimation(effectName, function(ccbOwner)
            if forceChange < 0 then
              ccbOwner.content:setString(" -" .. math.abs(forceChange))
            else
              ccbOwner.content:setString(" +" .. math.abs(forceChange))
            end
        end, function()
    		-- self:_showMasterLevelUp()
    	end)
    end
end 

function QUIDialogMagicHerbDetail:_showMasterLevelUp()
    local newMasterLevel = self._heroUIModel:getMasterLevelByType(QUIHeroModel.MAGICHERB_UPLEVEL_MASTER)
    print("QUIDialogMagicHerbDetail:_showMasterLevelUp()  ", newMasterLevel, self._curMasterLevel, self._actorId)
	if newMasterLevel > self._curMasterLevel then
		-- app.master:createMasterLayer()
		app.master:upGradeMagicHerbMaster(self._curMasterLevel, newMasterLevel, QUIHeroModel.MAGICHERB_UPLEVEL_MASTER, self._actorId)
		self._curMasterLevel = newMasterLevel
		-- app.master:cleanMasterLayer()
		remote.herosUtil:dispatchEvent({name = remote.herosUtil.EVENT_REFESH_BATTLE_FORCE})
	end
	self:_updateMasterInfo()
end

function QUIDialogMagicHerbDetail:_updateMasterInfo()
	if not self._heroUIModel then return end

	self._curMasterLevel = self._heroUIModel:getMasterLevelByType(QUIHeroModel.MAGICHERB_UPLEVEL_MASTER)
	if self._curMasterLevel > 0 then
		self._ccbOwner.master_level:setString("LV."..self._curMasterLevel)
		self._ccbOwner.master_level:setVisible(true)
	else
		self._ccbOwner.master_level:setVisible(false)
	end
end

function QUIDialogMagicHerbDetail:_setBattleForceText(battleForce)
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

function QUIDialogMagicHerbDetail:_updateHeroInfo()
	self._heroList = self._heroList or {}
	self._heroPos = self._heroPos or 1
	self._actorId = self._heroList[self._heroPos]
	self._heroUtil = remote.herosUtil:getHeroByID(self._actorId)
	self._heroUIModel = remote.herosUtil:getUIHeroByID(self._actorId)

	self:_updateMasterInfo()
    self:_updateSid()
	self:_initHeroArea()
	self:_switchTab()
	self:_checkRedTips()
end

function QUIDialogMagicHerbDetail:_updateSid()
	local magicHerbWearedInfo = self._heroUIModel:getMagicHerbWearedInfoByPos(self._pos)
	self._sid = nil
	if magicHerbWearedInfo then
		self._sid = magicHerbWearedInfo.sid
	end

	self:updateButton()
end

function QUIDialogMagicHerbDetail:updateButton()

    if not self._sid or self._sid == 0 then
    	self._ccbOwner.node_btn_breed:setVisible(false)
        self._tabType = QUIDialogMagicHerbDetail.TAB_DETAIL
        return
    end
	local magicHerbInfo = remote.magicHerb:getMaigcHerbItemBySid(self._sid)
	local magicHerbConfig = remote.magicHerb:getMagicHerbConfigByid(magicHerbInfo.itemId)
	local quality = magicHerbConfig.aptitude or 0
	local unlockBreed = quality >= APTITUDE.S 
	self._ccbOwner.node_btn_breed:setVisible(unlockBreed)

	if self._tabType == QUIDialogMagicHerbDetail.TAB_BREED and not unlockBreed then
        self._tabType = QUIDialogMagicHerbDetail.TAB_DETAIL
    end
end


function QUIDialogMagicHerbDetail:_initHeroArea()
	if not self._heroUtil then return end

	-- 名字和等级
	local characherDisplayConfig = db:getCharacterByID(self._actorId)
	local breakthroughLevel, color = remote.herosUtil:getBreakThrough(self._heroUtil.breakthrough)
	local fontColor = color and BREAKTHROUGH_COLOR_LIGHT[color] or BREAKTHROUGH_COLOR_LIGHT["white"]
	self._ccbOwner.tf_name:setColor(fontColor)
	self._ccbOwner.tf_name = setShadowByFontColor(self._ccbOwner.tf_name, fontColor)
	self._ccbOwner.tf_level:setColor(fontColor)
	self._ccbOwner.tf_level = setShadowByFontColor(self._ccbOwner.tf_level, fontColor)
	self._ccbOwner.tf_level:setString("LV."..(self._heroUtil.level or "0"))
	self._ccbOwner.tf_name:setString(characherDisplayConfig.name..(breakthroughLevel == 0 and "" or (" +"..breakthroughLevel)))
	self._ccbOwner.tf_level:setVisible(true)
	self._ccbOwner.tf_name:setVisible(true)

	-- avatar
	if self._information == nil then
		self._information = QUIWidgetHeroInformation.new()
		self._ccbOwner.node_avatar:addChild(self._information:getView())
	end
	self._information:setAvatar(self._actorId, 1.1)
	self._information:setNameVisible(false)
	self._information:setStarVisible(false)
	self._information:setBackgroundVisible(false)

	-- 战力
	local heroProp = remote.herosUtil:createHeroPropById(self._actorId)
	local battleForce = heroProp:getBattleForce()
	if self._oldBattleForce == 0 or self._oldBattleForce == battleForce then
    	self._oldBattleForce = battleForce
		self:_setBattleForceText(battleForce)
	end

	self:_updateBox()
end

function QUIDialogMagicHerbDetail:_updateBox()
	for pos, box in ipairs(self._magicHerbBoxlist) do
        box:setHeroId(self._actorId)
        local magicHerbWearedInfo = self._heroUIModel:getMagicHerbWearedInfoByPos(pos)
        -- QPrintTable(magicHerbWearedInfo)
        if magicHerbWearedInfo and magicHerbWearedInfo.sid then
            box:setInfo(magicHerbWearedInfo.sid)
        else
            box:setInfo()
        end
        local redTips = self._heroUIModel:checkHeroMagicHerbRedTipsByPos(pos)
        box:setRedTipStatus(redTips)
		box:selected(pos == self._pos)
    end
end

function QUIDialogMagicHerbDetail:_updateBoxSelectedState()
	for pos, box in ipairs(self._magicHerbBoxlist) do
		box:selected(pos == self._pos)
    end
end

function QUIDialogMagicHerbDetail:_switchTab()
	if self._currentWidget then
        self._currentWidget:setVisible(false)
    end

	if self._sid ~= nil then
		-- 已经携带了仙品
		self:getOptions().tabType = self._tabType
		self._ccbOwner.sp_breed_tip:setPositionX(54)
	    if self._tabType == QUIDialogMagicHerbDetail.TAB_DETAIL then
	    	self._tabManager:selected(self._ccbOwner.btn_detail)
	        self:_initDetailWidget()
	        self._currentWidget = self._detailWidget
	        self._currentWidget:setVisible(true)
	    elseif self._tabType == QUIDialogMagicHerbDetail.TAB_ADVANCE then
	    	self._tabManager:selected(self._ccbOwner.btn_advance)
	        self:_initAdvanceWidget()
	        self._currentWidget = self._advanceWidget
	        self._currentWidget:setVisible(true)
        elseif self._tabType == QUIDialogMagicHerbDetail.TAB_UPLEVEL then
        	self._tabManager:selected(self._ccbOwner.btn_upLevel)
	        self:_initUpLevelWidget()
	        self._currentWidget = self._upLevelWidget
	        self._upLevelWidget:setParentDailog(self)
	        self._currentWidget:setVisible(true)
	    elseif self._tabType == QUIDialogMagicHerbDetail.TAB_REFINE then
	        self:_initRefineWidget()
	        self._tabManager:selected(self._ccbOwner.btn_refine)
	        self._currentWidget = self._refineWidget
	        self._currentWidget:setVisible(true)
	    elseif self._tabType == QUIDialogMagicHerbDetail.TAB_BREED then
			self._ccbOwner.sp_breed_tip:setPositionX(70)
	        self:_initBreedWidget()
	        self._tabManager:selected(self._ccbOwner.btn_breed)
	        self._currentWidget = self._breedWidget
	        self._currentWidget:setVisible(true)
	    end
	else
		-- 没有携带仙品
		self:_initEmptyWidget()
		self._currentWidget = self._emptyWidget
		self._currentWidget:setVisible(true)
	end

	self:_updateWidget()
    self:_initQuickLevelUpBtn()
end

function QUIDialogMagicHerbDetail:_updateWidget()
	if self._currentWidget and self._actorId and self._pos then
		self._currentWidget:setInfo(self._actorId, self._pos)
	end
end

function QUIDialogMagicHerbDetail:_initEmptyWidget()
	self._ccbOwner.frame_tf_title:setString("仙品携带")
    -- self._page.topBar:showWithHeroOverView()

    if self._emptyWidget == nil then
        self._emptyWidget = QUIWidgetHeroMagicHerbEmpty.new()
        self._ccbOwner.node_right:addChild(self._emptyWidget)
    end
end

function QUIDialogMagicHerbDetail:_initDetailWidget()
	self._ccbOwner.frame_tf_title:setString("仙品详情")
	-- self._page.topBar:showWithHeroOverView()

    if self._detailWidget == nil then
        self._detailWidget = QUIWidgetMagicHerbDetail.new()
        self._detailWidget:addEventListener(QUIWidgetMagicHerbDetail.EVENT_UNWEAR, handler(self, self._magicHerbUnwearHandler))
        self._detailWidget:addEventListener(QUIWidgetMagicHerbDetail.EVENT_WEAR, handler(self, self._magicHerbwearHandler))
        self._ccbOwner.node_right:addChild(self._detailWidget)
    end
end

function QUIDialogMagicHerbDetail:_initAdvanceWidget()
	self._ccbOwner.frame_tf_title:setString("仙品升星")
	-- self._page.topBar:showWithHeroOverView()

    if self._advanceWidget == nil then
        self._advanceWidget = QUIWidgetMagicHerbAdvance.new()
        self._ccbOwner.node_right:addChild(self._advanceWidget)
    end
end

function QUIDialogMagicHerbDetail:_initUpLevelWidget()
	self._ccbOwner.frame_tf_title:setString("仙品升级")
    -- self._page.topBar:showWithMagicHerbUpLevel()
	
    if self._upLevelWidget == nil then
        self._upLevelWidget = QUIWidgetMagicHerbUpLevel.new()
        self._ccbOwner.node_right:addChild(self._upLevelWidget)
    end
end

function QUIDialogMagicHerbDetail:_initRefineWidget()
	self._ccbOwner.frame_tf_title:setString("仙品转生")
	-- self._page.topBar:showWithHeroOverView()

    if self._refineWidget == nil then
        self._refineWidget = QUIWidgetMagicHerbRefine.new()
        self._ccbOwner.node_right:addChild(self._refineWidget)
    end
end


function QUIDialogMagicHerbDetail:_initBreedWidget()
	self._ccbOwner.frame_tf_title:setString("仙品培育")
	-- self._page.topBar:showWithHeroOverView()

    if self._breedWidget == nil then
        self._breedWidget = QUIWidgetMagicHerbBreed.new()
        self._ccbOwner.node_right:addChild(self._breedWidget)
    end
end

function QUIDialogMagicHerbDetail:_checkRedTips()
	if self._sid then
		self._ccbOwner.sp_breed_tip:setVisible(remote.magicHerb:isBreedUpRedTipsBySid(self._sid))
	end
end

function QUIDialogMagicHerbDetail:_magicHerbUnwearHandler()
    remote.magicHerb:magicHerbLoadRequest(self._sid, 2, self._actorId, self._pos, self:safeHandler(function()
    	remote.magicHerb:dispatchEvent({name = remote.magicHerb.EVENT_REFRESH_MAGIC_HERB})
    end))
end

function QUIDialogMagicHerbDetail:_magicHerbwearHandler()
	self._oldMinAptitudeInSuit = self._heroUIModel:getMinAptitudeInSuit()
    app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogMagicHerbCheckroom", 
        options = {actorId = self._actorId, pos = self._pos}})
end

function QUIDialogMagicHerbDetail:_onTriggerDetail()
    if self._tabType ~= QUIDialogMagicHerbDetail.TAB_DETAIL then
        app.sound:playSound("common_switch")
        self._tabType = QUIDialogMagicHerbDetail.TAB_DETAIL
        self:_switchTab()
    end 
end

function QUIDialogMagicHerbDetail:_onTriggerAdvance()
    if self._tabType ~= QUIDialogMagicHerbDetail.TAB_ADVANCE then
        app.sound:playSound("common_switch")
        self._tabType = QUIDialogMagicHerbDetail.TAB_ADVANCE
        self:_switchTab() 
    end 
end

function QUIDialogMagicHerbDetail:_onTriggerUpLevel()
    if self._tabType ~= QUIDialogMagicHerbDetail.TAB_UPLEVEL then
        app.sound:playSound("common_switch")
        self._tabType = QUIDialogMagicHerbDetail.TAB_UPLEVEL
        self:_switchTab()
    end 
end

function QUIDialogMagicHerbDetail:_onTriggerRefine()
    if self._tabType ~= QUIDialogMagicHerbDetail.TAB_REFINE then
        app.sound:playSound("common_switch")
        self._tabType = QUIDialogMagicHerbDetail.TAB_REFINE
        self:_switchTab()
    end 
end


function QUIDialogMagicHerbDetail:_onTriggerBreed()
    if self._tabType ~= QUIDialogMagicHerbDetail.TAB_BREED then
        app.sound:playSound("common_switch")
        self._tabType = QUIDialogMagicHerbDetail.TAB_BREED
        self:_switchTab()
    end 
end

function QUIDialogMagicHerbDetail:_onQuickEvolution()
	app.sound:playSound("common_small")

 -- local unlockKey = "UNLOCK_MAGIC_HERB_ONE_KEY"
 --    if not app:getUserData():getValueForKey(unlockKey..remote.user.userId) then
 --        app:getUserData():setValueForKey(unlockKey..remote.user.userId, "true")
 --        self._ccbOwner.node_quick_effect:setVisible(false)
 --    end

    local actorId = self._actorId
    local characterInfo = QStaticDatabase:sharedDatabase():getCharacterByID(actorId)
    local heroModel = remote.herosUtil:getUIHeroByID(actorId)

	local currMasterInfo, nextMasterInfo, isMax = self._heroUIModel:getStrengthenMagicByMasterLevel(1)
	if not isMax then
		self._jewelEvolutionDialog = app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogOneClickMagicThrough", 
		    options = {actorId = actorId, masterType = masterType, parentOptions = self:getOptions()}}) 
	else
		app.tip:floatTip("已经升级到顶级")
	end
end

function QUIDialogMagicHerbDetail:_onTriggerMaster(e)
	if e ~= nil then
		app.sound:playSound("common_common")
	end
	app:getNavigationManager():pushViewController(app.mainUILayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogMaster",
        options = {actorId = self._actorId, masterType = QUIHeroModel.MAGICHERB_UPLEVEL_MASTER, isPopParentDialog = true, pos = self._heroPos, parentOptions = self:getOptions(), heros = self._heroList}})
end

function QUIDialogMagicHerbDetail:_onTriggerBag(event)
	if q.buttonEventShadow(event, self._ccbOwner.btn_bag) == false then return end

	app.sound:playSound("common_common")
	return app:getNavigationManager():pushViewController(app.mainUILayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogMagicHerbBackpack"})
end

function QUIDialogMagicHerbDetail:_onTriggerRight()
    app.sound:playSound("common_change")
    local n = #self._heroList
    if nil ~= self._heroPos and n > 1 then
        self._heroPos = self._heroPos + 1
        if self._heroPos > n then
            self._heroPos = 1
        end
        local options = self:getOptions()
        options.heroPos = self._heroPos
        if options.parentOptions ~= nil then
        	options.parentOptions.pos = options.heroPos
        end
        self._oldBattleForce = 0
	    if self._textUpdate ~= nil then
			self._textUpdate:stopUpdate()
			self._textUpdate = nil
		end
		self:_updateHeroInfo()
	end
end

function QUIDialogMagicHerbDetail:_onTriggerLeft()
    app.sound:playSound("common_change")
    local n = #self._heroList
    if nil ~= self._heroPos and n > 1 then
        self._heroPos = self._heroPos - 1
        if self._heroPos < 1 then
            self._heroPos = n
        end
        local options = self:getOptions()
        options.heroPos = self._heroPos
        if options.parentOptions ~= nil then
        	options.parentOptions.pos = options.heroPos
        end
        self._oldBattleForce = 0
	    if self._textUpdate ~= nil then
			self._textUpdate:stopUpdate()
			self._textUpdate = nil
		end
		self:_updateHeroInfo()
	end
end

function QUIDialogMagicHerbDetail:onTriggerBackHandler(tag)
	if self._topTouchLayer ~= nil then return end
	self:_onTriggerBack()
end

function QUIDialogMagicHerbDetail:onTriggerHomeHandler(tag)
	if self._topTouchLayer ~= nil then return end
	self:_onTriggerHome()
end
 
function QUIDialogMagicHerbDetail:_onTriggerBack(tag, menuItem)
    self:enableTouchSwallowTop()
	app:getNavigationManager():popViewController(app.mainUILayer, QNavigationController.POP_TOP_CONTROLLER)
end

function QUIDialogMagicHerbDetail:_onTriggerHome(tag, menuItem)
    self:enableTouchSwallowTop()
	app:getNavigationManager():popViewController(app.mainUILayer, QNavigationController.POP_TO_CURRENT_PAGE)
end
return QUIDialogMagicHerbDetail