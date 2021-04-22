-- @Author: xurui
-- @Date:   2017-04-05 14:33:43
-- @Last Modified by:   liaoxianbo
-- @Last Modified time: 2019-11-30 20:51:28
local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogHeroSparDetail = class("QUIDialogHeroSparDetail", QUIDialog)

local QNavigationController = import("...controllers.QNavigationController")
local QUIViewController = import("..QUIViewController")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QUIWidgetSparBox = import("..widgets.spar.QUIWidgetSparBox")
local QGemstoneController = import("..controllers.QGemstoneController")
local QUIWidgetHeroInformation = import("..widgets.QUIWidgetHeroInformation")
local QUIWidgetHeroSparEmpty = import("..widgets.spar.QUIWidgetHeroSparEmpty")
local QUIWidgetHeroSparStrength = import("..widgets.spar.QUIWidgetHeroSparStrength")
local QUIWidgetHeroSparGrade = import("..widgets.spar.QUIWidgetHeroSparGrade")
local QUIWidgetHeroSsSparGrade = import("..widgets.spar.QUIWidgetHeroSsSparGrade")
local QUIWidgetHeroSparDetail = import("..widgets.spar.QUIWidgetHeroSparDetail")
local QUIWidgetHeroSparAbsorb = import("..widgets.spar.QUIWidgetHeroSparAbsorb")
local QTextFiledScrollUtils = import("...utils.QTextFiledScrollUtils")
local QUIWidgetAnimationPlayer = import("..widgets.QUIWidgetAnimationPlayer")
local QUIHeroModel = import("...models.QUIHeroModel")
local QNotificationCenter = import("...controllers.QNotificationCenter")

QUIDialogHeroSparDetail.TAB_STRONG = "TAB_STRONG"
QUIDialogHeroSparDetail.TAB_GRADE = "TAB_GRADE"
QUIDialogHeroSparDetail.TAB_DETAIL = "TAB_DETAIL"
QUIDialogHeroSparDetail.TAB_ABSORB = "TAB_ABSORB"

function QUIDialogHeroSparDetail:ctor(options)
	local ccbFile = "ccb/Dialog_spar.ccbi"
	local callBack = {
		{ccbCallbackName = "onTriggerBack", 				callback = handler(self, self._onTriggerBack)},
		{ccbCallbackName = "onTriggerTabStrong", 		callback = handler(self, self._onTriggerTabStrong)},
		{ccbCallbackName = "onTriggerTabGrade", 		callback = handler(self, self._onTriggerTabGrade)},
		{ccbCallbackName = "onTriggerTabDetail", 		callback = handler(self, self._onTriggerTabDetail)},
		{ccbCallbackName = "onTriggerTabAbsorb", 		callback = handler(self, self._onTriggerTabAbsorb)},
		{ccbCallbackName = "onTriggerLeft", 		callback = handler(self, self._onTriggerLeft)},
		{ccbCallbackName = "onTriggerRight", 		callback = handler(self, self._onTriggerRight)},
        {ccbCallbackName = "onTriggerBag",      callback = handler(self, self._onTriggerBag)}, 
        {ccbCallbackName = "onTriggerMaster", callback = handler(self, self._onTriggerMaster)},
        {ccbCallbackName = "onQuickStrengthen",		callback = handler(self, self._onQuickStrengthen)},
	}
	QUIDialogHeroSparDetail.super.ctor(self, ccbFile, callBack, options)
	local page = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
	page:setManyUIVisible()
    page.topBar:showWithStyle({TOP_BAR_TYPE.MONEY, TOP_BAR_TYPE.TOKEN_MONEY, TOP_BAR_TYPE.BATTLE_FORCE})

	cc.GameObject.extend(self)
	self:addComponent("components.behavior.EventProtocol"):exportMethods()

    ui.tabButton(self._ccbOwner.tab_detail, "详细")
    ui.tabButton(self._ccbOwner.tab_strong, "强化")
    ui.tabButton(self._ccbOwner.tab_grade, "升星")
    ui.tabButton(self._ccbOwner.tab_absorb, "吸收")

	if options ~= nil then
		self._pos = options.pos or 0
		self._heros = options.heros or {}
		self._currentTab = options.initTab
		self._sparPos = options.sparPos
	end

    self._sparType = ITEM_CONFIG_TYPE.GARNET
    if self._sparPos and self._sparPos == 2 then
    	self._sparType = ITEM_CONFIG_TYPE.OBSIDIAN
    end
    self._oldBattleForce = 0


	if #self._heros == 1 then
        self._ccbOwner.arrowLeft:setVisible(false)
        self._ccbOwner.arrowRight:setVisible(false)
    end
end

function QUIDialogHeroSparDetail:viewDidAppear()
	QUIDialogHeroSparDetail.super.viewDidAppear(self)

	self._remoteProxy = cc.EventProxy.new(remote)
	self._remoteProxy:addEventListener(remote.HERO_UPDATE_EVENT, handler(self, self.onEvent))

    self._sparProxy = cc.EventProxy.new(remote.spar)
    self._sparProxy:addEventListener(remote.spar.EVENT_WEAR_SPAR_SUCCESS, handler(self, self.sparWearHandler))
    self._sparProxy:addEventListener(remote.spar.EVENT_UNWEAR_SPAR_SUCCESS, handler(self, self.sparUnwearHandler))
    self._sparProxy:addEventListener(remote.spar.EVENT_INHERIT_SPAR_SUCCESS, handler(self, self.onEvent))
    self._sparProxy:addEventListener(remote.spar.EVENT_INHERIT_SPAR_CANCEL_SUCCESS, handler(self, self.onEvent))

	self._heroProxy = cc.EventProxy.new(remote.herosUtil)
	self._heroProxy:addEventListener(remote.herosUtil.EVENT_REFESH_BATTLE_FORCE, handler(self, self.onEvent))
	-- self._heroProxy:addEventListener(remote.herosUtil.EVENT_HERO_EQUIP_UPDATE, handler(self, self.onEvent))
	self._heroProxy:addEventListener(remote.herosUtil.EVENT_HERO_SPAR_INFO_UPDATE, handler(self, self.onEvent))

	self._itemsProxy = cc.EventProxy.new(remote.items)
	self._itemsProxy:addEventListener(remote.items.EVENT_ITEMS_UPDATE, handler(self, self.onEvent))

	self._userProxy = cc.EventProxy.new(remote.user)
	self._userProxy:addEventListener(remote.user.EVENT_USER_PROP_CHANGE, handler(self, self.onEvent))
	QNotificationCenter.sharedNotificationCenter():addEventListener(QUIWidgetHeroSsSparGrade.EVENT_SS_SPAR_GRADE_NOT_STAR, self._onHandleGradeUpSuccess, self)


	self:setInfo(self._heros[self._pos], self._sparPos)


	self:addBackEvent()
end

function QUIDialogHeroSparDetail:viewWillDisappear()
	QUIDialogHeroSparDetail.super.viewWillDisappear(self)
	QNotificationCenter.sharedNotificationCenter():removeEventListener(QUIWidgetHeroSsSparGrade.EVENT_SS_SPAR_GRADE_NOT_STAR, self._onHandleGradeUpSuccess, self)

	self._remoteProxy:removeAllEventListeners()
	self._sparProxy:removeAllEventListeners()
	self._itemsProxy:removeAllEventListeners()
	self._userProxy:removeAllEventListeners()
	self._heroProxy:removeAllEventListeners()

	self:removeBackEvent()

    if self.advancedEffectShow ~= nil then
        self.advancedEffectShow:disappear()
        self.advancedEffectShow = nil
    end	
	
	if self._textUpdate ~= nil then
		self._textUpdate:stopUpdate()
		self._textUpdate = nil
	end

	local page = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
    page.topBar:setAllSound(true)
end

function QUIDialogHeroSparDetail:setInfo(actorId, sparPos)
	self._actorId = actorId
	self._hero = remote.herosUtil:getHeroByID(actorId)
	self._sparPos = sparPos
	if self._sparPos == nil then
		self._sparPos = 1
	end
	self._heroUIModel = remote.herosUtil:getUIHeroByID(self._actorId)
    self:refreshPos()
	self:initHeroArea()
	self:tabSelectHandler()
	self:checkRedTips()

end

function QUIDialogHeroSparDetail:selectTab(name, isforce)
	if self._sparId == nil then return end
	print("selectTab 	"..name)
	if self._currentTab ~= name or isforce == true then
		self._currentTab = name
		self:getOptions().initTab = name
		self:removeAllTabState()
		if self._infoWidget ~= nil then
			self._infoWidget:setVisible(false)
			self._infoWidget = nil
		end

		self._ccbOwner.node_quick_strengthen:setVisible(false)
		self._ccbOwner.grade_tip:setPositionX(54)
		self._ccbOwner.detail_tip:setPositionX(54)
		self._ccbOwner.absorb_tip:setPositionX(54)
		self._gemstoneController:refreshBox()
		local titleStr = "外附魂骨详情"
		if self._currentTab == QUIDialogHeroSparDetail.TAB_STRONG then
			titleStr = "外附魂骨强化"
			self:selectedTabStrong()
		elseif self._currentTab == QUIDialogHeroSparDetail.TAB_GRADE then
			titleStr = "外附魂骨升星"
			self:selectedTabGrade()
			self._ccbOwner.grade_tip:setPositionX(70)
		elseif self._currentTab == QUIDialogHeroSparDetail.TAB_DETAIL then
			self:selectedTabDetail()
			self._ccbOwner.detail_tip:setPositionX(70)
		elseif self._currentTab == QUIDialogHeroSparDetail.TAB_ABSORB then
			titleStr = "外附魂骨吸收"
			self:selectedTabAbsorb()
			self._ccbOwner.absorb_tip:setPositionX(70)	
		end
		if self._infoWidget ~= nil then
			self._infoWidget:setVisible(true)
		end

		self._ccbOwner.frame_tf_title:setString(titleStr)
	end

	self:checkRedTips()
end

--初始化装备这块和头像
function QUIDialogHeroSparDetail:initHeroArea()
	self._ccbOwner.node_master:setVisible(false)
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
		self._sparBoxs = {}
	     for i = 1, 2 do
            self._sparBoxs[i] = QUIWidgetSparBox.new()
            self._ccbOwner["node"..i]:addChild(self._sparBoxs[i])
            self._sparBoxs[i]:setNameVisible(false)
        end
	    self._gemstoneController = QGemstoneController.new()
	    self._gemstoneController:setBoxs({}, self._sparBoxs)
		self._gemstoneController:addEventListener(QUIWidgetSparBox.EVENT_CLICK, handler(self, self.onEvent))
	end
	self._gemstoneController:setHero(self._heroInfo.actorId) -- 装备显示
end

function QUIDialogHeroSparDetail:_refreshBatlleForce()
	if self:safeCheck() == false then return end
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
            if forceChange < 0 then
              	ccbOwner.content:setString(" -" .. math.abs(forceChange))
            else
              	ccbOwner.content:setString(" +" .. math.abs(forceChange))
            end
        end)
    end
end 

function QUIDialogHeroSparDetail:setBattleForceText(battleForce)
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

function QUIDialogHeroSparDetail:refreshPos()
	local sparInfo = self._heroUIModel:getSparInfoByPos(self._sparPos)
	self._sparId = nil
	if sparInfo ~= nil and sparInfo.info ~= nil then
		self._sparId = sparInfo.info.sparId
	end

end

function QUIDialogHeroSparDetail:tabSelectHandler()
	self:selectEquipmentBox()
	if self._sparId ~= nil then
		print("有装宝石")
		local sparInfo = self._heroUIModel:getSparInfoByPos(self._sparPos)
		local itemInfo = db:getItemByID(sparInfo.info.itemId)
		local showAbsorb = itemInfo and itemInfo.gemstone_quality and itemInfo.gemstone_quality >= APTITUDE.SS
		self._ccbOwner.node_absorb:setVisible(showAbsorb)
		if self._currentTab == QUIDialogHeroSparDetail.TAB_ABSORB and not showAbsorb then
			self._currentTab =  QUIDialogHeroSparDetail.TAB_DETAIL
		else
			self._currentTab = self._currentTab or QUIDialogHeroSparDetail.TAB_DETAIL
		end

		self:selectTab(self._currentTab, true)
	else
		print("没有装宝石")
		--没有装宝石
		if self._infoWidget ~= nil then
			self._infoWidget:setVisible(false)
			self._infoWidget = nil
		end
		self:removeAllTabState()
		if self._emptyWidget == nil then
			self._emptyWidget = QUIWidgetHeroSparEmpty.new()
			self._ccbOwner.node_right:addChild(self._emptyWidget)
		end
		self._emptyWidget:setInfo(self._actorId, nil, self._sparPos)
		self._infoWidget = self._emptyWidget
		self._infoWidget:setVisible(true)
	end
end 

function QUIDialogHeroSparDetail:selectedTabStrong()
	self._ccbOwner.tab_strong:setEnabled(false)
	self._ccbOwner.tab_strong:setHighlighted(true)
	self._ccbOwner.node_btn_bag:setVisible(false)
	self:checkShowOneStrongBtn()

	-- 显示装备突破界面并刷新
	if self._strong == nil then
		self._strong = QUIWidgetHeroSparStrength.new()
		self._ccbOwner.node_right:addChild(self._strong)
		self._strong:setPosition(-187, -40)
	end
	self._strong:setInfo(self._actorId, self._sparId, self._sparPos)
	self._infoWidget = self._strong

	for _,box in ipairs(self._sparBoxs) do
		box:setStrengthVisible(true)
		box:showTipsByState("strength")
		box:setName("")
	end
	self:changeMasterByType(QUIHeroModel.SPAR_STRENGTHEN_MASTER)
end

function QUIDialogHeroSparDetail:checkShowOneStrongBtn( )
	if not app.unlock:checkLock("UNLOCK_GEMSTONE_ONE_KEY", false) then
       self._ccbOwner.node_quick_strengthen:setVisible(false)
       return
    end
    if self._heroInfo and self._heroInfo.spar and #self._heroInfo.spar < 2 then
    	self._ccbOwner.node_quick_strengthen:setVisible(false)
    else
        self._ccbOwner.node_quick_str_effect:setVisible(not app:getUserData():getValueForKey("UNLOCK_ZHUBAO_ONE_KEY"..remote.user.userId))
    	self._ccbOwner.node_quick_strengthen:setVisible(true)
    end
end

function QUIDialogHeroSparDetail:selectedTabGrade()
	self._ccbOwner.tab_grade:setEnabled(false)
	self._ccbOwner.tab_grade:setHighlighted(true)
	self._ccbOwner.node_btn_bag:setVisible(false)
	-- 显示装备突破界面并刷新

	local sparInfo = self._heroUIModel:getSparInfoByPos(self._sparPos)
	local itemInfo = db:getItemByID(sparInfo.info.itemId)
	local showAbsorb = itemInfo and itemInfo.gemstone_quality and itemInfo.gemstone_quality >= APTITUDE.SS
	if showAbsorb then
		if self._ssGrade == nil then
			self._ssGrade = QUIWidgetHeroSsSparGrade.new()
			self._ccbOwner.node_right:addChild(self._ssGrade)
		end
		self._ssGrade:setInfo(self._actorId, self._sparId, self._sparPos)
		self._infoWidget = self._ssGrade
		if self._grade then
			self._grade:setVisible(false)
		end
		print("SS外骨")
	else
		if self._grade == nil then
			self._grade = QUIWidgetHeroSparGrade.new()
			self._ccbOwner.node_right:addChild(self._grade)
		end
		self._grade:setInfo(self._actorId, self._sparId, self._sparPos)
		self._infoWidget = self._grade
		if self._ssGrade then
			self._ssGrade:setVisible(false)
		end		
		print("S外骨")
	end

	for _,box in ipairs(self._sparBoxs) do
		box:setStrengthVisible(false)
		box:showTipsByState("grade")
		box:setName("")
	end
	self:changeMasterByType(nil)
end

function QUIDialogHeroSparDetail:selectedTabDetail()
	self._ccbOwner.tab_detail:setEnabled(false)
	self._ccbOwner.tab_detail:setHighlighted(true)
	self._ccbOwner.node_btn_bag:setVisible(true)
	if self._detailWidget == nil then
		self._detailWidget = QUIWidgetHeroSparDetail.new()
		self._ccbOwner.node_right:addChild(self._detailWidget)
	end
	self._detailWidget:setInfo(self._actorId, self._sparId, self._sparPos)
	self._infoWidget = self._detailWidget

	for _,box in ipairs(self._sparBoxs) do
		box:setStrengthVisible(true)
		box:showTipsByState("detail")
		box:setName("")
	end
	self:changeMasterByType(nil)
end

function QUIDialogHeroSparDetail:selectedTabAbsorb()
	self._ccbOwner.tab_absorb:setEnabled(false)
	self._ccbOwner.tab_absorb:setHighlighted(true)
	self._ccbOwner.node_btn_bag:setVisible(false)

	if self._absorbWidget == nil then
		self._absorbWidget = QUIWidgetHeroSparAbsorb.new()
		self._ccbOwner.node_right:addChild(self._absorbWidget)
	end
	self._absorbWidget:setInfo(self._actorId, self._sparId, self._sparPos)
	self._infoWidget = self._absorbWidget

	for _,box in ipairs(self._sparBoxs) do
		box:setStrengthVisible(false)
		box:showTipsByState("inherit")
		box:setName("")
	end
	self:changeMasterByType(nil)
end


function QUIDialogHeroSparDetail:changeMasterByType(masterType)
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
	if masterType == QUIHeroModel.SPAR_STRENGTHEN_MASTER and app.master:checkSparStrengthMasterUnlock() then
		self._ccbOwner.node_master:setVisible(true)
	end
end

function QUIDialogHeroSparDetail:onEvent(event)
	if self:safeCheck() == false then return end
	print( event.name)
	if event.name == QUIWidgetSparBox.EVENT_CLICK then
		app.sound:playSound("common_item")
        self._sparPos = event.sparPos
        self:refreshPos()
		self:tabSelectHandler()
		self:getOptions().sparPos = self._sparPos
		self:checkRedTips()
	elseif event.name == remote.HERO_UPDATE_EVENT or event.name == remote.user.EVENT_USER_PROP_CHANGE then
		self._gemstoneController:refreshBox() -- 装备显示
        self:refreshPos()
		self:tabSelectHandler()
		self:checkRedTips()
		self:setInfo(self._actorId, self._sparPos)
	elseif event.name == remote.herosUtil.EVENT_REFESH_BATTLE_FORCE then
		self:_refreshBatlleForce()
	elseif event.name == remote.items.EVENT_ITEMS_UPDATE then
        self:refreshPos()
		self:tabSelectHandler()
		self:checkRedTips()
	elseif event.name == remote.spar.EVENT_INHERIT_SPAR_SUCCESS or event.name == remote.spar.EVENT_INHERIT_SPAR_CANCEL_SUCCESS  then
		self._gemstoneController:refreshBox()
        self:refreshPos()
		self:tabSelectHandler()
		self:checkRedTips()
		self:setInfo(self._actorId, self._sparPos)
	elseif event.name == remote.herosUtil.EVENT_HERO_SPAR_INFO_UPDATE then
		self:refreshPos()
		self:tabSelectHandler()
		self:checkRedTips()
	-- elseif event.name == remote.herosUtil.EVENT_HERO_EQUIP_UPDATE and (event.actorId and event.actorId == self._actorId)  then
 --        self:refreshPos()
	-- 	self:tabSelectHandler()
	-- 	self:checkRedTips()
	end
end

function QUIDialogHeroSparDetail:sparWearHandler(event)
    local sparId = event.sparId
    local sparInfo, sparPos = remote.spar:getSparsIndexBySparId(sparId)
    print("sparWearHandler")
    local ccbFile = "ccb/effects/Baoshi_tips.ccbi"
    if self._strengthenEffectShow ~= nil then
        self._strengthenEffectShow:disappear()
        self._strengthenEffectShow = nil
    end
    
    self._sparPos = sparPos
    self:refreshPos()
	self:tabSelectHandler()
	self:getOptions().sparPos = self._sparPos
	self:checkRedTips()

    app.sound:playSound("sound_num")

	local effect = QUIWidgetAnimationPlayer.new()
	self._ccbOwner["node"..sparPos]:addChild(effect)
	effect:playAnimation("ccb/effects/Baoshizhuangbei.ccbi")

    local arr = CCArray:create()
    arr:addObject(CCScaleTo:create(0.1,1.2,1.2))
    arr:addObject(CCScaleTo:create(0.05,1.4,1.4))
    arr:addObject(CCScaleTo:create(0.05,1.2,1.2))
    arr:addObject(CCScaleTo:create(0.1,1,1))
    self._sparBoxs[sparPos]:runAction(CCSequence:create(arr))

    self:enableTouchSwallowTop()
    self._schedulerHandler = scheduler.performWithDelayGlobal(function ()
    	self._schedulerHandler = nil

	    local suits = {}
		local sparInfo1 = self._heroUIModel:getSparInfoByPos(1).info
		local sparInfo2 = self._heroUIModel:getSparInfoByPos(2).info
		local minGrade = self._heroUIModel:getHeroSparMinGrade()
		if sparInfo1 ~= nil and sparInfo2 ~= nil then
	   	 	suits = QStaticDatabase:sharedDatabase():getActiveSparSuitInfoBySparId(sparInfo1.itemId, sparInfo2.itemId, minGrade)
	   	 end
	    if #suits > 1 then
	        -- self:enableTouchSwallowTop()
	    else
            -- self:disableTouchSwallowTop()
	    end
	    self._strengthenEffectShow = QUIWidgetAnimationPlayer.new()
	    self:getView():addChild(self._strengthenEffectShow)
	    self._strengthenEffectShow:setPosition(ccp(0, 100))
	    self._strengthenEffectShow:playAnimation(ccbFile, function(ccbOwner)
	    	ccbOwner.node_green:setVisible(true)
	    	ccbOwner.node_red:setVisible(false)
       		ccbOwner.tf_title1:setString("装备外附魂骨成功")
	        for i=1,4 do
	            ccbOwner["node_"..i]:setVisible(false)
	        end
	        local index = 1
	        local addPropText = function(name,value, isPercent)
	            if index > 4 then return end
	            value = value or 0
	            if value > 0 then
	                ccbOwner["node_"..index]:setVisible(true)
	                if isPercent then
	                	ccbOwner["tf_name"..index]:setString(name.."＋"..(value*100).."%")
	                else
	                	ccbOwner["tf_name"..index]:setString(name.."＋"..value)
	            	end
	                index = index + 1
	            end
	        end
	        addPropText("攻击", sparInfo.prop.attack_value)
	        addPropText("生命", sparInfo.prop.hp_value)
	        addPropText("物理防御", sparInfo.prop.armor_physical)
	        addPropText("法术防御", sparInfo.prop.armor_magic)
	        addPropText("生命百分比", sparInfo.prop.hp_percent, true)
	        addPropText("攻击百分比", sparInfo.prop.attack_percent, true)
	        addPropText("物防百分比", sparInfo.prop.armor_physical_percent, true)
	        addPropText("法防百分比", sparInfo.prop.armor_magic_percent, true)
	        end, function()
	            if self._strengthenEffectShow ~= nil then
	                self._strengthenEffectShow:disappear()
	                self._strengthenEffectShow = nil
	            end
                self:disableTouchSwallowTop()
                local successTip = app.master.SPAR_SUIT_TIP
                if #suits > 1 and app.master:getMasterShowState(successTip) then
	                app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogSparSuitActiveSuccess", 
	                    options = {suitInfo = suits, successTip = successTip, actorId = self._actorId, callback = function ()
	                    	self:checkTriggerStrengthMaster()
	                    end}}, {isPopCurrentDialog = false})
	            else
                	self:checkTriggerStrengthMaster()
	            end
	        end)    
	end,0.2)
end

--检查是否触发突破大师
function QUIDialogHeroSparDetail:checkTriggerStrengthMaster()
	local masterLevel = remote.herosUtil:getUIHeroByID(self._actorId):getMasterLevelByType(QUIHeroModel.SPAR_STRENGTHEN_MASTER)
	if masterLevel > 0 then
		self._masterDialog = app.master:upGradeGemstoneMaster(0, masterLevel, QUIHeroModel.SPAR_STRENGTHEN_MASTER, self._actorId)
		if self._masterDialog then
			self._masterDialog:addEventListener(self._masterDialog.EVENT_CLOSE, function (e)
		    		self._masterDialog:removeAllEventListeners()
		    		self._masterDialog = nil
					self:_refreshBatlleForce()
				end)
		else
			self:_refreshBatlleForce()
		end
	else
		self:_refreshBatlleForce()
	end
end

function QUIDialogHeroSparDetail:sparUnwearHandler(event)
    local sparId = event.sparId
    local sparInfo, sparPos = remote.spar:getSparsIndexBySparId(sparId)

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
        ccbOwner.tf_title2:setString("卸下外附魂骨成功")
        for i=5,8 do
            ccbOwner["node_"..i]:setVisible(false)
        end
        local index = 1
        local addPropText = function(name,value, isPercent)
            if index > 4 then return end
            value = value or 0
            if value > 0 then
                ccbOwner["node_"..(index+4)]:setVisible(true)
                if isPercent then
                	ccbOwner["tf_name"..(index+4)]:setString(name.."-"..(value*100).."%")
                else
                	ccbOwner["tf_name"..(index+4)]:setString(name.."-"..value)
            	end
                index = index + 1
            end
        end
        addPropText("攻击", sparInfo.prop.attack_value)
        addPropText("生命", sparInfo.prop.hp_value)
        addPropText("物理防御", sparInfo.prop.armor_physical)
        addPropText("法术防御", sparInfo.prop.armor_magic)
        addPropText("生命百分比", sparInfo.prop.hp_percent, true)
        addPropText("攻击百分比", sparInfo.prop.attack_percent, true)
        addPropText("物防百分比", sparInfo.prop.armor_physical_percent, true)
        addPropText("法防百分比", sparInfo.prop.armor_magic_percent, true)
        end, function()
            if self._strengthenEffectShow ~= nil then
                self._strengthenEffectShow:disappear()
                self._strengthenEffectShow = nil
            end
			-- remote.herosUtil:dispatchEvent({name = remote.herosUtil.EVENT_REFESH_BATTLE_FORCE})
			self:_refreshBatlleForce()
        end)    
end

function QUIDialogHeroSparDetail:selectEquipmentBox()
	for _,box in pairs(self._sparBoxs) do 
		if box:getSparPos() == self._sparPos then
			box:selected(true)
		else
			box:selected(false)
		end
	end
end

function QUIDialogHeroSparDetail:checkRedTips()
	self._ccbOwner.strong_tip:setVisible(false)
	self._ccbOwner.grade_tip:setVisible(false)
	self._ccbOwner.absorb_tip:setVisible(false)
	self._ccbOwner.detail_tip:setVisible(false)
	local sparInfo = self._heroUIModel:getSparInfoByPos(self._sparPos)

	self._ccbOwner.grade_tip:setVisible(sparInfo.isCanGrade)
	self._ccbOwner.detail_tip:setVisible(sparInfo.isBetter)
	self._ccbOwner.absorb_tip:setVisible(sparInfo.isCanAbsorb)

	
end

function QUIDialogHeroSparDetail:removeAllTabState()
	self._ccbOwner.tab_strong:setEnabled(true)
	self._ccbOwner.tab_strong:setHighlighted(false)
	self._ccbOwner.tab_grade:setEnabled(true)
	self._ccbOwner.tab_grade:setHighlighted(false)
	self._ccbOwner.tab_detail:setEnabled(true)
	self._ccbOwner.tab_detail:setHighlighted(false)
	self._ccbOwner.tab_absorb:setEnabled(true)
	self._ccbOwner.tab_absorb:setHighlighted(false)
	
end

function QUIDialogHeroSparDetail:_onHandleGradeUpSuccess(event)

	local itemId = event.options.itemId
	local grade = event.options.grade
	if not itemId or not grade then
		return
	end

	local gradeConfig = db:getGradeByHeroActorLevel(itemId, grade)
	local gradeConfigOld = db:getGradeByHeroActorLevel(itemId, grade - 1)
	if not gradeConfig or not gradeConfigOld then return end 

    if self.advancedEffectShow ~= nil then
        self.advancedEffectShow:disappear()
        self.advancedEffectShow = nil
    end

	if self._ssGrade then
		self._ssGrade:playEffectAction(grade)
	end		

    local ccbFile = "ccb/effects/Baoshi_tips.ccbi"
    self.advancedEffectShow = QUIWidgetAnimationPlayer.new()
    self.advancedEffectShow:setPositionY(30)
    self:getView():addChild(self.advancedEffectShow)

    self.advancedEffectShow:playAnimation(ccbFile, function(ccbOwner)
    	ccbOwner.node_red:setVisible(true)
    	ccbOwner.node_green:setVisible(false)
    	ccbOwner.tf_title2:setString("升星成功")
        for i=5,8 do
            ccbOwner["node_"..i]:setVisible(false)
        end
        local index = 1
        local function addPropText(name,value)
            if index > 4 then return end
            ccbOwner["node_"..(index+4)]:setVisible(true)
            ccbOwner["tf_name"..(index+4)]:setString(name.."+"..value)
            index = index + 1
        end

        local propDesc = remote.spar:setDivPropInfo(gradeConfigOld,gradeConfig)
        -- QPrintTable(propDesc)
        for i,v in ipairs(propDesc) do
        	addPropText(v.name, v.value)
        end

        end, function()
            if self.advancedEffectShow ~= nil then
                self.advancedEffectShow:disappear()
                self.advancedEffectShow = nil
            end
			remote.herosUtil:dispatchEvent({name = remote.herosUtil.EVENT_REFESH_BATTLE_FORCE})
        end) 
end



function QUIDialogHeroSparDetail:_onTriggerTabStrong()
	app.sound:playSound("common_menu")
	self:selectTab(QUIDialogHeroSparDetail.TAB_STRONG)
end

function QUIDialogHeroSparDetail:_onTriggerTabGrade()
	app.sound:playSound("common_menu")
	self:selectTab(QUIDialogHeroSparDetail.TAB_GRADE)
end

function QUIDialogHeroSparDetail:_onTriggerTabDetail()
	app.sound:playSound("common_menu")
	self:selectTab(QUIDialogHeroSparDetail.TAB_DETAIL)
end

function QUIDialogHeroSparDetail:_onTriggerTabAbsorb()
	app.sound:playSound("common_menu")
	self:selectTab(QUIDialogHeroSparDetail.TAB_ABSORB)
end

function QUIDialogHeroSparDetail:_onTriggerBag(e)
	if e ~= nil then
		app.sound:playSound("common_common")
	end
    return app:getNavigationManager():pushViewController(app.mainUILayer, 
                    {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogGemstoneBackpack", options = {tab = "TAB_SPAR"}})
end

function QUIDialogHeroSparDetail:_onTriggerMaster(e)
	if self._currentTab == QUIDialogHeroSparDetail.TAB_STRONG then
		app:getNavigationManager():pushViewController(app.mainUILayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogMaster",
        options = {actorId = self._actorId, masterType = QUIHeroModel.SPAR_STRENGTHEN_MASTER, isPopParentDialog = true, pos = self._pos, parentOptions = self:getOptions(), heros = self._heros}})
	end
end

function QUIDialogHeroSparDetail:_onQuickStrengthen( event )
	if q.buttonEventShadow(event, self._ccbOwner.btn_oneclick_strengthen) == false then return end

	app.sound:playSound("common_small")
    if not app:getUserData():getValueForKey("UNLOCK_ZHUBAO_ONE_KEY"..remote.user.userId) then
        app:getUserData():setValueForKey("UNLOCK_ZHUBAO_ONE_KEY"..remote.user.userId, "true")
        self._ccbOwner.node_quick_str_effect:setVisible(false)
    end 	
    local actorId = self._actorId
    local characterInfo = QStaticDatabase:sharedDatabase():getCharacterByID(actorId)
    local heroModel = remote.herosUtil:getUIHeroByID(actorId)
    local masterType = QUIHeroModel.SPAR_STRENGTHEN_MASTER

	local masterLevel = heroModel:getMasterLevelByType(masterType)

    local currMasterInfo, nextMasterInfo, isMax = QStaticDatabase:sharedDatabase():getStrengthenMasterByMasterLevel(masterType, masterLevel)

    if self._heroInfo.spar and self._heroInfo.spar and #self._heroInfo.spar == 2 then
	    if not isMax then
			app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogOneClickSparStrengthen", 
	                options = {actorId = actorId, masterType=masterType, strengWidget = self._strong,parentOptions = self:getOptions()}}) 
		else
			 app.tip:floatTip("已经到达外附魂骨强化大师最高等级")
		end
	else
		app.tip:floatTip("请先装备2件外附魂骨～")
	end
end

function QUIDialogHeroSparDetail:_onTriggerRight()
    app.sound:playSound("common_change")
    remote.herosUtil:dispatchEvent({name = remote.herosUtil.EVENT_SAVE_STRENGTHEN_EXP})
    self._ccbOwner.node_quick_strengthen:setVisible(false)
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
		self:setInfo(self._heros[self._pos], self._sparPos)
	end
end

function QUIDialogHeroSparDetail:_onTriggerLeft()
    app.sound:playSound("common_change")
    remote.herosUtil:dispatchEvent({name = remote.herosUtil.EVENT_SAVE_STRENGTHEN_EXP})
    self._ccbOwner.node_quick_strengthen:setVisible(false)
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
		self:setInfo(self._heros[self._pos], self._sparPos)		
	end

end

-- 对话框退出
function QUIDialogHeroSparDetail:_onTriggerBack(tag, menuItem)
    self:enableTouchSwallowTop()
	app:getNavigationManager():popViewController(app.mainUILayer, QNavigationController.POP_TOP_CONTROLLER)
end

function QUIDialogHeroSparDetail:onTriggerBackHandler(tag)
    app:getNavigationManager():popViewController(app.mainUILayer, QNavigationController.POP_TOP_CONTROLLER)
end

function QUIDialogHeroSparDetail:onTriggerHomeHandler(tag)
	app:getNavigationManager():popViewController(app.mainUILayer, QNavigationController.POP_TO_CURRENT_PAGE)
end

return QUIDialogHeroSparDetail