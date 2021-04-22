--
-- Author: Your Name
-- Date: 2014-06-06 14:40:59
--
local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogHeroEquipmentDetail = class("QUIDialogHeroEquipmentDetail", QUIDialog)

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
local QUIWidgetHeroEquipmentEvolutionMax = import("..widgets.QUIWidgetHeroEquipmentEvolutionMax")
local QUIWidgetHeroEquipmentEnchantMax = import("..widgets.QUIWidgetHeroEquipmentEnchantMax")
local QUIWidgetHeroEquipmentStrengthMax = import("..widgets.QUIWidgetHeroEquipmentStrengthMax")

-- QUIDialogHeroEquipmentDetail.TAB_INFO = "TAB_INFO"
QUIDialogHeroEquipmentDetail.TAB_STRONG = "TAB_STRONG"
QUIDialogHeroEquipmentDetail.TAB_EVOLUTION = "TAB_EVOLUTION"
QUIDialogHeroEquipmentDetail.TAB_MAGIC = "TAB_MAGIC"
QUIDialogHeroEquipmentDetail.TAB_LINK = "TAB_LINK"
QUIDialogHeroEquipmentDetail.REFESH_BATTLE_FORCE = "REFESH_BATTLE_FORCE"
QUIDialogHeroEquipmentDetail.CLICK_STRENGTEN_MASTER = "CLICK_STRENGTEN_MASTER"

--onTriggerCompositeHandler onTriggerWearHandler
function QUIDialogHeroEquipmentDetail:ctor(options)
	local ccbFile = "ccb/Dialog_HeroEquipment_info.ccbi"
	local callBacks = {
		{ccbCallbackName = "onTriggerBack", 				callback = handler(self, QUIDialogHeroEquipmentDetail._onTriggerBack)},
		{ccbCallbackName = "onTriggerTabStrong", 		callback = handler(self, QUIDialogHeroEquipmentDetail._onTriggerTabStrong)},
		{ccbCallbackName = "onTriggerTabEvolution", 		callback = handler(self, QUIDialogHeroEquipmentDetail._onTriggerTabEvolution)},
		{ccbCallbackName = "onTriggerTabMagic", 		callback = handler(self, QUIDialogHeroEquipmentDetail._onTriggerTabMagic)},
		{ccbCallbackName = "onTriggerLeft", 		callback = handler(self, QUIDialogHeroEquipmentDetail._onTriggerLeft)},
		{ccbCallbackName = "onTriggerRight", 		callback = handler(self, QUIDialogHeroEquipmentDetail._onTriggerRight)},
        {ccbCallbackName = "onTriggerMaster",      callback = handler(self, QUIDialogHeroEquipmentDetail._onTriggerMaster)}, 
        {ccbCallbackName = "onQuickEvolution",      callback = handler(self, QUIDialogHeroEquipmentDetail._onQuickEvolution)}, 
        {ccbCallbackName = "onQuickStrengthen",		callback = handler(self, QUIDialogHeroEquipmentDetail._onQuickStrengthen)},
	}
	QUIDialogHeroEquipmentDetail.super.ctor(self, ccbFile, callBacks, options)
	local page = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
	page:setManyUIVisible()
    -- page:setBattleForceBar(true)
    page.topBar:showWithHeroDetail()
    ui.tabButton(self._ccbOwner.tab_evolution, "突破")
    ui.tabButton(self._ccbOwner.tab_strong, "强化")
    ui.tabButton(self._ccbOwner.tab_magic, "觉醒")

    self._tabManager = ui.tabManager({self._ccbOwner.tab_evolution, self._ccbOwner.tab_strong, self._ccbOwner.tab_magic})

	if options ~= nil then
		self._pos = options.pos or 0
		self._heros = options.heros or {}
		self._currentTab = options.initTab
		self._isQuickWay = options.isQuickWay
		
        --检查魂师ID 是否存在了 不存在则删除掉
        local selectId = self._heros[self._pos]
        local herosId = {}
        self._pos = nil
        for _,heroId in ipairs(self._heros) do
            if remote.herosUtil:getHeroByID(heroId) ~= nil then
                table.insert(herosId, heroId)
                if heroId == selectId then
                    self._pos = #herosId
                end
            end
        end
        self._heros = herosId
        if self._pos == nil then
            self._pos = 1
        end
	end
	self._equipmentStrengthen = nil
	self._oldBattleForce = 0

	if #self._heros == 1 then
        self._ccbOwner.arrowLeft:setVisible(false)
        self._ccbOwner.arrowRight:setVisible(false)
    end

  	self._isReadyHeroTupo = false
  	self._isQUIDialogEquipmentBreakthroughSuccessEnd = false
end

function QUIDialogHeroEquipmentDetail:viewDidAppear()
	QUIDialogHeroEquipmentDetail.super.viewDidAppear(self)

	local options = self:getOptions()
	self:setInfo(self._heros[self._pos], options.equipmentPos)

	self._equipmentUtils:addEventListener(QUIWidgetEquipmentBox.EVENT_EQUIPMENT_BOX_CLICK, handler(self, self.onEvent))
	QNotificationCenter.sharedNotificationCenter():addEventListener(QTips.UNLOCK_EVENT, self._unlockHandler, self)

	self._remoteProxy = cc.EventProxy.new(remote)
	self._remoteProxy:addEventListener(remote.HERO_UPDATE_EVENT, handler(self, self.onEvent))
	self._heroProxy = cc.EventProxy.new(remote.herosUtil)
	self._heroProxy:addEventListener(remote.herosUtil.EVENT_HERO_PROP_UPDATE, handler(self, self.heroPropUpdateHandler))
	self._heroProxy:addEventListener(remote.herosUtil.EVENT_HERO_EQUIP_UPDATE, handler(self, self.heroEquipUpdateHandler))
    self._heroProxy:addEventListener(remote.herosUtil.EVENT_HERO_BREAK_BY_ONEKEY, handler(self, self._heroBreakByOneKeyHandler))

	self._itemsProxy = cc.EventProxy.new(remote.items)
	self._itemsProxy:addEventListener(remote.items.EVENT_ITEMS_UPDATE, handler(self, self.onEvent))

	self._userProxy = cc.EventProxy.new(remote.user)
	self._userProxy:addEventListener(remote.user.EVENT_USER_PROP_CHANGE, handler(self, self.onEvent))

	self:addBackEvent()
end

function QUIDialogHeroEquipmentDetail:viewWillDisappear()
	QUIDialogHeroEquipmentDetail.super.viewWillDisappear(self)
	QNotificationCenter.sharedNotificationCenter():removeEventListener(QTips.UNLOCK_EVENT, self._unlockHandler, self)
	self._equipmentUtils:removeAllEventListeners()
	-- self._heroHead:removeAllEventListeners()
	if self._enchant ~= nil then self._enchant:removeAllEventListeners() end
	if self._evolution ~= nil then self._evolution:removeAllEventListeners() end
		self._remoteProxy:removeAllEventListeners()
		self._itemsProxy:removeAllEventListeners()
		self._userProxy:removeAllEventListeners()
		self._heroProxy:removeAllEventListeners()
		self:removeBackEvent()
	if self._alertHandler ~= nil then
		scheduler.unscheduleGlobal(self._alertHandler)
		self._alertHandler = nil
	end
	if self._animationHandler ~= nil then
		scheduler.unscheduleGlobal(self._animationHandler)
		self._animationHandler = nil
	end
	if self._textUpdate ~= nil then
		self._textUpdate:stopUpdate()
		self._textUpdate = nil
	end

	if self._masterAnimation ~= nil then
		self._masterAnimation:disappear() 
		self._masterAnimation = nil
	end

	if self._strengthenScheduler ~= nil then
		scheduler.unscheduleGlobal(self._strengthenScheduler)
		self._strengthenScheduler = nil
	end
	if self._jewelEvolutionDialog then
		self._jewelEvolutionDialog:removeAllEventListeners()
	end
	if self._jewelStrengthDialog then
		self._jewelStrengthDialog:removeAllEventListeners()
	end
end

function QUIDialogHeroEquipmentDetail:setInfo(actorId, equipmentPos)
	self._actorId = actorId
	self._equipmentPos = equipmentPos
	if self._equipmentPos == nil then
		self._equipmentPos = EQUIPMENT_TYPE.CLOTHES
	end
	self._heroUIModel = remote.herosUtil:getUIHeroByID(self._actorId)
	self._itemId = nil
	local equipmentInfo = self._heroUIModel:getEquipmentInfoByPos(self._equipmentPos)
	if equipmentInfo ~= nil then
		self._itemId = equipmentInfo.info.itemId
	end

	self:initHeroArea()
	self:tabSelcted()
	self:checkRedTips()

	self._masterType = QUIHeroModel.JEWELRY_BREAK_MASTER
	self:setMasterType(self._currentTab or QUIDialogHeroEquipmentDetail.TAB_EVOLUTION)
	self:setMasterAnimation()

	-- Hide enchant tab before unlock level
	self._ccbOwner.tab_magic:setVisible(app.unlock:getUnlockEnchant())

	if self._equipmentPos == EQUIPMENT_TYPE.JEWELRY1 or self._equipmentPos == EQUIPMENT_TYPE.JEWELRY2 then
		self._ccbOwner.tab_strong:setVisible(app.unlock:getUnlockEnhanceAdvanced())
	else
  		self._ccbOwner.tab_strong:setVisible(app.unlock:getUnlockEnhance())
 	end
end

--初始化装备这块和头像
function QUIDialogHeroEquipmentDetail:initHeroArea()
	self._heroInfo = clone(remote.herosUtil:getHeroByID(self._actorId))
	local characher = QStaticDatabase:sharedDatabase():getCharacterByID(self._heroInfo.actorId)
	
	self._ccbOwner.tf_level:setString("LV."..(self._heroInfo.level or "0"))

	local breakthroughLevel,color = remote.herosUtil:getBreakThrough(self._heroInfo.breakthrough)
	local fontColor = nil
	if color ~= nil then
		fontColor = BREAKTHROUGH_COLOR_LIGHT[color]
		self._ccbOwner.tf_name:setColor(fontColor)
		self._ccbOwner.tf_level:setColor(fontColor)
	else
		fontColor = BREAKTHROUGH_COLOR_LIGHT["white"]
		self._ccbOwner.tf_name:setColor(fontColor)
		self._ccbOwner.tf_level:setColor(fontColor)
	end
	self._ccbOwner.tf_name = setShadowByFontColor(self._ccbOwner.tf_name, fontColor)
	self._ccbOwner.tf_level = setShadowByFontColor(self._ccbOwner.tf_level, fontColor)

	self._ccbOwner.tf_name:setString(characher.name..(breakthroughLevel == 0 and "" or ("+"..breakthroughLevel)))

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
	if self._equipmentUtils == nil then
		self._equipBox = {}
		if self._equipmentPos == EQUIPMENT_TYPE.JEWELRY1 or self._equipmentPos == EQUIPMENT_TYPE.JEWELRY2 then
			for i = 1, 2 do
				self._equipBox[i] = QUIWidgetEquipmentSpecialBox.new()
				self._ccbOwner["special_node"..i]:addChild(self._equipBox[i])
			end
			--纹章 徽章
			self._equipBox[1]:setType(EQUIPMENT_TYPE.JEWELRY1)
			self._equipBox[2]:setType(EQUIPMENT_TYPE.JEWELRY2)
   		else
			for i = 1, 4 do
				self._equipBox[i] = QUIWidgetEquipmentBox.new()
				self._ccbOwner["node"..i]:addChild(self._equipBox[i])
			end
			--武器 护手 衣服 脚  饰品1 饰品2
			self._equipBox[1]:setType(EQUIPMENT_TYPE.WEAPON)
			self._equipBox[2]:setType(EQUIPMENT_TYPE.BRACELET)
			self._equipBox[3]:setType(EQUIPMENT_TYPE.CLOTHES)
			self._equipBox[4]:setType(EQUIPMENT_TYPE.SHOES)
		end

		--装备控制器
		self._equipmentUtils = QUIWidgetHeroEquipment.new()
		self:getView():addChild(self._equipmentUtils) --此处添加至节点没有显示需求
		self._equipmentUtils:setUI(self._equipBox)
	end
	self._equipmentUtils:setHero(self._heroInfo.actorId) -- 装备显示
	self:checkHeroCanBreakthrough()
end

function QUIDialogHeroEquipmentDetail:selectTab(name, isforce)
	if self._itemId == nil then return end
	if self._currentTab ~= name or isforce == true then
		self._currentTab = name
		self:getOptions().initTab = name
		if self._infoWidget ~= nil then
			self._infoWidget:setVisible(false)
			self._infoWidget = nil
		end

		self._ccbOwner.node_quick_evolution:setVisible(false)
		self._ccbOwner.node_quick_strengthen:setVisible(false)

		self._ccbOwner.strong_tip:setPositionX(54)
		self._ccbOwner.evolution_tip:setPositionX(54)
		self._ccbOwner.magic_tip:setPositionX(54)
		self._equipmentUtils:refreshBox()
		if self._currentTab == QUIDialogHeroEquipmentDetail.TAB_STRONG then
			self._ccbOwner.strong_tip:setPositionX(68)
			self:selectedTabStrong()
		elseif self._currentTab == QUIDialogHeroEquipmentDetail.TAB_EVOLUTION then
			self._ccbOwner.evolution_tip:setPositionX(68)
			self:selectedTabEvolution()
		elseif self._currentTab == QUIDialogHeroEquipmentDetail.TAB_MAGIC then
			self._ccbOwner.magic_tip:setPositionX(68)
			self:selectedTabMagic()
		end
		if self._infoWidget ~= nil then
			self._infoWidget:setVisible(true)
		end
		self:hideEquipmentState(self._currentTab)
	end
end

function QUIDialogHeroEquipmentDetail:hideEquipmentState(tab)
	if tab == QUIDialogHeroEquipmentDetail.TAB_EVOLUTION then
		for _, box in pairs(self._equipBox) do
			box:setEffect(true)
			box:showCanEnchant(false)
		end
	elseif tab == QUIDialogHeroEquipmentDetail.TAB_STRONG then
		for _, box in pairs(self._equipBox) do
			box:setEffect(false)
			box:showCanEvolution(false)
			box:showCanEnchant(false)
		end
	elseif tab == QUIDialogHeroEquipmentDetail.TAB_MAGIC then
		for _, box in pairs(self._equipBox) do
			box:setEffect(false)
			box:showCanEvolution(false)
		end
	end
end

function QUIDialogHeroEquipmentDetail:checkRedTips()
	self._ccbOwner.strong_tip:setVisible(false)
	self._ccbOwner.evolution_tip:setVisible(false)
	self._ccbOwner.magic_tip:setVisible(false)

	for _,box in pairs(self._equipBox) do 
		if box._isLock then
			break
		end
		
		local equipmentInfo = self._heroUIModel:getEquipmentInfoByPos(box:getType())
		local itemId = equipmentInfo.info.itemId

		-- 检查装备是否可以突破
		if equipmentInfo.nextBreakInfo ~= nil then
			local targetItem = QStaticDatabase:sharedDatabase():getItemByID(equipmentInfo.nextBreakInfo[equipmentInfo.pos])
			local itemCraftConfig = QStaticDatabase:sharedDatabase():getItemCraftByItemId(equipmentInfo.nextBreakInfo[equipmentInfo.pos])
			if equipmentInfo.state == QUIHeroModel.EQUIPMENT_STATE_BREAK and targetItem.level <= self._heroInfo.level and
				itemCraftConfig.price <= remote.user.money then
				
				self._ccbOwner.evolution_tip:setVisible(true)
			end
		end

		-- 检查装备是否可以觉醒
		if self._ccbOwner.magic_tip:isVisible() == false then
			if remote.herosUtil:checkEquipmentEnchantById(self._actorId, equipmentInfo.info.itemId) then
				self._ccbOwner.magic_tip:setVisible(true)
			end
		end
	end
	if app.unlock:getUnlockEnhance() == false then
		self._ccbOwner.strong_tip:setVisible(false)
	end
	if app.unlock:getUnlockEnchant() == false then
		self._ccbOwner.magic_tip:setVisible(false)
	end
end
 
function QUIDialogHeroEquipmentDetail:refreshItem(itemId)
	self._itemId = itemId
	self:getOptions().itemId = itemId
end

function QUIDialogHeroEquipmentDetail:tabSelcted()
	self:selectEquipmentBox()
	if self._itemId ~= nil then
		self._currentTab = self._currentTab or QUIDialogHeroEquipmentDetail.TAB_EVOLUTION
		self:selectTab(self._currentTab, true)
	else
		if self._infoWidget ~= nil then
			self._infoWidget:setVisible(false)
			self._infoWidget = nil
		end
		if self._lockWidget == nil then
			self._lockWidget = QUIWidgetHeroEquipmentLock.new()
			self._ccbOwner.node_right:addChild(self._lockWidget)
		end
		self._lockWidget:setInfo(self._actorId, nil, self._equipmentPos)
		self._infoWidget = self._lockWidget
		self._infoWidget:setVisible(true)
	end
end 

function QUIDialogHeroEquipmentDetail:selectEquipmentBox()
	for _,box in pairs(self._equipBox) do 
		if box:getType() == self._equipmentPos then
			box:setSelect(true)
		else
			box:setSelect(false)
		end
	end
end

function QUIDialogHeroEquipmentDetail:onEvent(event)
	if event.name == QUIWidgetEquipmentBox.EVENT_EQUIPMENT_BOX_CLICK then
        local itemId = nil
        if event.info ~= nil then
            itemId = event.info.id
        end
        if itemId == nil then
            if event.type == EQUIPMENT_TYPE.JEWELRY1 then
                app.tip:floatTip("饰品戒指战队" .. tostring(app.unlock:getConfigByKey("UNLOCK_BADGE").team_level) .. "级解锁")
            elseif event.type == EQUIPMENT_TYPE.JEWELRY2 then
                app.tip:floatTip("饰品项链战队" .. tostring(app.unlock:getConfigByKey("UNLOCK_GAD").team_level) .. "级解锁")
            end
            return
        end
		-- Kumo2 按装备图标进入突破界面
		app.sound:playSound("common_item")
		remote.herosUtil:dispatchEvent({name = remote.herosUtil.EVENT_SAVE_STRENGTHEN_EXP})
		self._equipmentPos = event.type
		if event.info ~= nil then
			self:refreshItem(event.info.id)
		else
			self:refreshItem(nil)
		end
		self:tabSelcted()
		--清除记录的item
		local option = self:getOptions()
		option.equipmentPos = self._equipmentPos
	elseif event.name == remote.HERO_UPDATE_EVENT or event.name == remote.user.EVENT_USER_PROP_CHANGE then
		self._equipmentUtils:setHero(self._actorId) -- 装备显示
		self:setMasterAnimation()
		local isFind = false
		-- if self._evolution ~= nil and self._evolution:isVisible() == true then
		for _,box in pairs(self._equipBox) do
			if box:getType() == self._equipmentPos then
				if box:getItemId() ~= self._itemId then
					self._equipmentPos = box:getType()
					self:refreshItem(box:getItemId())
					self:tabSelcted()
					isFind = true
				end
			end
		end
		-- end
		if isFind == false then
			-- 这2个bool控制了播放刷新特效的时机
			self._isQUIDialogEquipmentBreakthroughSuccessEnd = false
			self._isReadyHeroTupo = true
			self:tabSelcted()
		end
		self:checkRedTips()
	elseif event.name == remote.items.EVENT_ITEMS_UPDATE then
		self._equipmentUtils:refreshBox()
		self:tabSelcted()
		self:selectEquipmentBox()
		self:checkRedTips()
	elseif event.name == QUIWidgetHeroNormalEquipmentStrengthen.WEAR_STRENGTHEN_SUCCEED then
		self:strengthenSucceedEffect(event)
	elseif event.name == QUIWidgetHeroEquipmentEvolution.EVENT_EVOLUTION_SUCC then
		self:evolutionSucceedEffect()
	elseif event.name == QUIWidgetHeroEquipmentHeroBreakThrough.EVENT_BREAK_SUCC then
		self:_onBreakthroughEffect(event)
	end
end

function QUIDialogHeroEquipmentDetail:strengthenSucceedEffect(data)
	if data.state == nil then return end
	self._ccbOwner.strenAnimationNode:removeAllChildren()
	if data.critNum > 0 then
		local strengthenEffectShow = QUIWidgetAnimationPlayer.new()
		self._ccbOwner.strenAnimationNode:addChild(strengthenEffectShow)
		strengthenEffectShow:setPosition(ccp(0, 100))
		strengthenEffectShow:playAnimation("ccb/effects/Baoji.ccbi", function(ccbOwner)
			ccbOwner.level:setVisible(false)
			ccbOwner.tf_name1:setString("连续强化"..(data.changeLevel + data.critNum or 1).."次 （暴击 "..(data.critNum or 1).." 次）")
			if data.attributeInfo[1] ~= nil then
				local value = data.attributeInfo[1].value
				if value < 1 then
					value = value.."%"
				end
				self._strengthValue = value
				strengthenEffectShow._ccbOwner["tf_name"..2]:setString(data.attributeInfo[1].name .. "＋" .. value)
			else
				strengthenEffectShow._ccbOwner["node_"..2]:setVisible(false)
			end
		end, function()
			if strengthenEffectShow ~= nil then
				strengthenEffectShow:disappear()
				strengthenEffectShow = nil
			end
		end)	
	else
		local ccbFile = "ccb/effects/StrenghtSccess.ccbi"
		if data.changeLevel > 1 then
			ccbFile = "ccb/effects/StrenghtSccessBaoji.ccbi"
		end
		local strengthenEffectShow = QUIWidgetAnimationPlayer.new()
		self._ccbOwner.strenAnimationNode:addChild(strengthenEffectShow)
		strengthenEffectShow:setPosition(ccp(0, 100))
		strengthenEffectShow:playAnimation(ccbFile, function()
				if data.changeLevel > 1 then
					strengthenEffectShow._ccbOwner["level"]:setString(data.changeLevel + data.critNum or 1)
					strengthenEffectShow._ccbOwner["crit_num"]:setString(data.critNum or 0)
					if data.critNum == 0 then
						strengthenEffectShow._ccbOwner.node_baoji:setVisible(false)
						strengthenEffectShow._ccbOwner["node_"..1]:setPositionY(-49)
						strengthenEffectShow._ccbOwner["node_"..2]:setPositionY(-117)
					end
				else
					if data.critNum == 0 then
						strengthenEffectShow._ccbOwner.title_enchant:setVisible(false)
						strengthenEffectShow._ccbOwner.title_skill:setVisible(false)
					end
				end
				for i = 1, 2, 1 do
					if data.attributeInfo[i] ~= nil then
						local value = data.attributeInfo[i].value
						if value < 1 then
							value = value.."%"
						end
						self._strengthValue = value
						strengthenEffectShow._ccbOwner["tf_name"..i]:setString(data.attributeInfo[i].name .. "  ＋" .. value)
					else
						strengthenEffectShow._ccbOwner["node_"..i]:setVisible(false)
					end
				end
				if data.state ~= "0" then
					strengthenEffectShow._ccbOwner.title_strengthen:setString("升级至"..data.level.."级")
				end
			end, function()
				if strengthenEffectShow ~= nil then
					strengthenEffectShow:disappear()
					strengthenEffectShow = nil
				end
			end)	
	end

	if data.masterUpGrade ~= nil then
		app.master:createMasterLayer()
	end
		self._strengthenScheduler = scheduler.performWithDelayGlobal(function()
				if data.masterUpGrade then
					app.master:upGradeMaster(data.masterUpGrade, data.masterType, self._actorId)
					app.master:cleanMasterLayer()
				end
				if self._equipmentStrengthen:getClassName() ~= "QUIWidgetStrengthenMax" and self._currentTab == QUIDialogHeroEquipmentDetail.TAB_STRONG then
					self._equipmentStrengthen:_effectFinished()
				end
			end, 0.3)
end

function QUIDialogHeroEquipmentDetail:evolutionSucceedEffect()
	if self._evolutionEffect == nil then
		self._evolutionEffect = QUIWidgetAnimationPlayer.new()
		self:getView():addChild(self._evolutionEffect)
		self._evolutionEffect:setVisible(false)
	end
	self:checkHeroCanBreakthrough()
	for index, box in pairs(self._equipBox) do
		if box:getType() == self._equipmentPos then
			local pos = nil
			if self._equipmentPos == EQUIPMENT_TYPE.JEWELRY1 or self._equipmentPos == EQUIPMENT_TYPE.JEWELRY2 then
				pos = self._ccbOwner["special_node"..index]:convertToWorldSpaceAR(ccp(0,0))
			else
				pos = self._ccbOwner["node"..index]:convertToWorldSpaceAR(ccp(0,0))
			end
			pos = self:getView():convertToNodeSpaceAR(pos)
			self._evolutionEffect:setPosition(pos.x, pos.y)
			self._evolutionEffect:playAnimation("ccb/effects/EquipmentUpgarde.ccbi")
			self._evolutionEffect:setVisible(true)
			return
		end
	end
end

function QUIDialogHeroEquipmentDetail:selectedTabStrong()
	local unlockKey = "UNLOCK_TAOZHUANGQIANGHUA"
	if self._equipmentPos == EQUIPMENT_TYPE.JEWELRY1 or self._equipmentPos == EQUIPMENT_TYPE.JEWELRY2 then
		unlockKey = "UNLOCK_BADDGE_AND_GAD_STRENGTH_ONE_KEY"
		self._ccbOwner.frame_tf_title:setString("饰品强化")
	else
		self._ccbOwner.frame_tf_title:setString("装备强化")
	end
	local unlock = app.unlock:checkLock(unlockKey, false)
	self._ccbOwner.node_quick_strengthen:setVisible(unlock)
	if not app:getUserData():getValueForKey(unlockKey..remote.user.userId) and unlock then
        self._ccbOwner.node_quickstr_effect:setVisible(true)
    end  

	self._tabManager:selected(self._ccbOwner.tab_strong)
	local equipment = remote.herosUtil:getWearByItem(self._actorId, self._itemId)
	local widget = "QUIWidgetHeroNormalEquipmentStrengthen"
	local maxLevel = QStaticDatabase:sharedDatabase():getConfiguration().EQUIPMENT_MAX_LEVEL.value
	if self._equipmentPos == EQUIPMENT_TYPE.JEWELRY1 or self._equipmentPos == EQUIPMENT_TYPE.JEWELRY2 then
		maxLevel = QStaticDatabase:sharedDatabase():getConfiguration().JEWELRY_MAX_LEVEL.value
	end
	if equipment.level >= maxLevel then
	   	if self._equipmentStrengthenMax == nil then
			self._equipmentStrengthenMax = QUIWidgetHeroEquipmentStrengthMax.new()
			self._ccbOwner.node_right:addChild(self._equipmentStrengthenMax)
		end
	  	self._equipmentStrengthenMax:setInfo(self._actorId, self._itemId)
		self._infoWidget = self._equipmentStrengthenMax
	else
		if self._equipmentPos == EQUIPMENT_TYPE.JEWELRY1 or self._equipmentPos == EQUIPMENT_TYPE.JEWELRY2 then
			widget = "QUIWidgetHeroJewelryEquipmentStrengthen"
		end
		local widgetClass = import(app.packageRoot .. ".ui.widgets." .. widget)
	   	if self._equipmentStrengthen == nil or self._equipmentStrengthen:getClassName() ~= widget then
			self._equipmentStrengthen = widgetClass.new()
			self._ccbOwner.node_right:addChild(self._equipmentStrengthen)
			self._equipmentStrengthen:addEventListener(QUIDialogHeroEquipmentDetail.TAB_LINK, handler(self, self._onTabLink))
			self._equipmentStrengthen:addEventListener(QUIDialogHeroEquipmentDetail.REFESH_BATTLE_FORCE, handler(self, self._refreshBatlleForce))
			self._equipmentStrengthen:addEventListener(QUIWidgetHeroNormalEquipmentStrengthen.WEAR_STRENGTHEN_SUCCEED, handler(self, self.onEvent))
			self._equipmentStrengthen:addEventListener(QUIWidgetHeroJewelryEquipmentStrengthen.NO_EXP_ITEM, handler(self, self.strengthenExpItemIsNull))

		end
	  	self._equipmentStrengthen:setEquipmentPos(self._equipmentPos)
	  	self._equipmentStrengthen:setHeroInfo(self._actorId, self._itemId)
		self._infoWidget = self._equipmentStrengthen
	end

	if self._equipmentPos ~= EQUIPMENT_TYPE.JEWELRY1 and self._equipmentPos ~= EQUIPMENT_TYPE.JEWELRY2 then
		for i = 1, 4 do
			self._equipBox[i]:showEnchantIcon(false)
		end
	else
		for i = 1, 2 do
			self._equipBox[i]:showEnchantIcon(false)
		end
	end
end

function QUIDialogHeroEquipmentDetail:strengthenExpItemIsNull()
	self:checkRedTips()
	self._equipmentUtils:refreshBox()
end 

function QUIDialogHeroEquipmentDetail:_onTriggerMaster()
	local openFunc = function(value)
		app:getNavigationManager():pushViewController(app.mainUILayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogMaster",
			options = {actorId=self._actorId, masterType=self._masterType, pos = self._pos, parentOptions = self:getOptions().parentOptions,
			 heros = self._heros, isPopParentDialog = true, isQuickWay = self._isQuickWay}},{isPopCurrentDialog = true})
	end
	local openMaster = false
	if self._masterType == QUIHeroModel.JEWELRY_MASTER or self._masterType == QUIHeroModel.JEWELRY_ENCHANT_MASTER or self._masterType == QUIHeroModel.JEWELRY_BREAK_MASTER then
		if self._heroUIModel:getEquipmentInfoByPos(EQUIPMENT_TYPE.JEWELRY1) and self._heroUIModel:getEquipmentInfoByPos(EQUIPMENT_TYPE.JEWELRY2) then 
			openFunc(data)
		else
			app.tip:floatTip("饰品全部解锁开启饰品成长大师")
		end
	else
		openFunc(data)
	end
end

function QUIDialogHeroEquipmentDetail:_onQuickEvolution()
	app.sound:playSound("common_small")

	local unlockKey = "UNLOCK_YIJIANTUPO"
	if self._equipmentPos == EQUIPMENT_TYPE.JEWELRY1 or self._equipmentPos == EQUIPMENT_TYPE.JEWELRY2 then
		unlockKey = "UNLOCK_BADDGE_AND_GAD_BREAKTHROUGH_ONE_KEY"
	end
    if not app:getUserData():getValueForKey(unlockKey..remote.user.userId) then
        app:getUserData():setValueForKey(unlockKey..remote.user.userId, "true")
        self._ccbOwner.node_quick_effect:setVisible(false)
    end   	

    local actorId = self._actorId
    local characterInfo = QStaticDatabase:sharedDatabase():getCharacterByID(actorId)
    local heroModel = remote.herosUtil:getUIHeroByID(actorId)


	if self._equipmentPos == EQUIPMENT_TYPE.JEWELRY1 or self._equipmentPos == EQUIPMENT_TYPE.JEWELRY2 then
		local jewelryInfo1 = heroModel:getEquipmentInfoByPos(EQUIPMENT_TYPE.JEWELRY1)
		local jewelryInfo2 = heroModel:getEquipmentInfoByPos(EQUIPMENT_TYPE.JEWELRY1)
		local masterType = QUIHeroModel.JEWELRY_BREAK_MASTER 
		if jewelryInfo1.nextBreakInfo ~= nil and jewelryInfo2.nextBreakInfo ~= nil then
			self._jewelEvolutionDialog = app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogJewelryEvolutionOneClick", 
			    options = {actorId = actorId, masterType = masterType, parentOptions = self:getOptions()}}) 
			self._jewelEvolutionDialog:addEventListener(QUIDialogHeroEquipmentDetail.REFESH_BATTLE_FORCE, handler(self, self._refreshBatlleForce))
	    else
	        app.tip:floatTip("已经突破到顶级")
    	end
	else
	    local breakthroughInfo = QStaticDatabase:sharedDatabase():getBreakthroughByTalentLevel(characterInfo.talent, remote.herosUtil:getHeroByID(actorId).breakthrough + 1)
	    if breakthroughInfo ~= nil then
	        local items, needItems, canBreak, breakLevel = heroModel:getHeroMaxBreakLevelNeedItems()
	        if breakLevel <= 0 and table.nums(needItems) <= 0 and not canBreak then
	            app.tip:floatTip("战队等级不足，无法突破到下一级")
	            return
	        else
	            app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogBreakthroughQuick", 
	                options = {actorId = self._actorId, items = items, needItems = needItems, canBreak = canBreak, breakLevel = breakLevel}}) 
	        end
	    else
	        app.tip:floatTip("已经突破到顶级")
    	end
	end
end

function QUIDialogHeroEquipmentDetail:_onQuickStrengthen( event )
	if q.buttonEventShadow(event, self._ccbOwner.btn_oneclick_strengthen) == false then return end
	app.sound:playSound("common_small")

	local unlockKey = "UNLOCK_TAOZHUANGQIANGHUA"
	if self._equipmentPos == EQUIPMENT_TYPE.JEWELRY1 or self._equipmentPos == EQUIPMENT_TYPE.JEWELRY2 then	
		unlockKey = "UNLOCK_BADDGE_AND_GAD_STRENGTH_ONE_KEY"
	end

    if not app:getUserData():getValueForKey(unlockKey..remote.user.userId) then
        app:getUserData():setValueForKey(unlockKey..remote.user.userId, "true")
        self._ccbOwner.node_quickstr_effect:setVisible(false)
    end   		
    local actorId = self._actorId
    local characterInfo = QStaticDatabase:sharedDatabase():getCharacterByID(actorId)
    local heroModel = remote.herosUtil:getUIHeroByID(actorId)
    local masterType = QUIHeroModel.EQUIPMENT_MASTER
	if self._equipmentPos == EQUIPMENT_TYPE.JEWELRY1 or self._equipmentPos == EQUIPMENT_TYPE.JEWELRY2 then
		masterType = QUIHeroModel.JEWELRY_MASTER 
	end
	
	local masterLevel = heroModel:getMasterLevelByType(masterType)
    local currMasterInfo, nextMasterInfo, isMax = QStaticDatabase:sharedDatabase():getStrengthenMasterByMasterLevel(masterType, masterLevel)
    if not isMax then
		if self._equipmentPos == EQUIPMENT_TYPE.JEWELRY1 or self._equipmentPos == EQUIPMENT_TYPE.JEWELRY2 then
			self._jewelStrengthDialog = app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogJewelryStrengthOneClick", 
	            options = {actorId = actorId, masterType = masterType, parentOptions = self:getOptions()}}) 
			self._jewelStrengthDialog:addEventListener(QUIDialogHeroEquipmentDetail.REFESH_BATTLE_FORCE, handler(self, self._refreshBatlleForce))
		else
			app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogOneClickEquipStrengthen", 
	                options = {actorId = actorId, masterType = masterType, parentOptions = self:getOptions()}}) 
		end
	else
		 app.tip:floatTip("已经全部强化到顶级")
	end
end

function QUIDialogHeroEquipmentDetail:selectedTabEvolution()
	local unlockKey = "UNLOCK_YIJIANTUPO"
	if self._equipmentPos == EQUIPMENT_TYPE.JEWELRY1 or self._equipmentPos == EQUIPMENT_TYPE.JEWELRY2 then
		self._ccbOwner.frame_tf_title:setString("饰品突破")
		self._ccbOwner.node_quick_evolution:setPosition(ccp(-168, 56))
		self._ccbOwner.node_quick_evolution:setScale(0.8)
		unlockKey = "UNLOCK_BADDGE_AND_GAD_BREAKTHROUGH_ONE_KEY"
	else
		self._ccbOwner.frame_tf_title:setString("装备突破")
	end
	local unlock = app.unlock:checkLock(unlockKey, false)
	self._ccbOwner.node_quick_evolution:setVisible(unlock)
    if not app:getUserData():getValueForKey(unlockKey..remote.user.userId) and unlock then
        self._ccbOwner.node_quick_effect:setVisible(true)
    end    

	self._tabManager:selected(self._ccbOwner.tab_evolution)

	self._equipmentInfo = self._heroUIModel:getEquipmentInfoByPos(self._equipmentPos)

	local breakPanelFun = function ()
		if self._equipmentInfo.nextBreakInfo == nil then
			-- 显示装备突破界面并刷新
			if self._evolutionMax == nil then
				self._evolutionMax = QUIWidgetHeroEquipmentEvolutionMax.new()
				self._ccbOwner.node_right:addChild(self._evolutionMax)
			end
			self._evolutionMax:resetAll()
			self._evolutionMax:setInfo(self._actorId, self._itemId, self._equipmentPos)
			self._infoWidget = self._evolutionMax
		else
			-- 显示装备突破界面并刷新
			if self._evolution == nil then
				self._evolution = QUIWidgetHeroEquipmentEvolution.new()
				self._evolution:addEventListener(QUIWidgetHeroEquipmentEvolution.EVENT_EVOLUTION_SUCC, handler(self, self.onEvent))
				self._evolution:addEventListener(QUIDialogHeroEquipmentDetail.REFESH_BATTLE_FORCE, handler(self, self._refreshBatlleForce))
				self._ccbOwner.node_right:addChild(self._evolution)
			end
			self._evolution:resetAll()
			self._evolution:setInfo(self._actorId, self._itemId, self._equipmentPos)
			self._infoWidget = self._evolution
		end
	end
	
	if self._equipmentPos ~= EQUIPMENT_TYPE.JEWELRY1 and self._equipmentPos ~= EQUIPMENT_TYPE.JEWELRY2 and remote.herosUtil:checkHerosBreakthroughByID(self._actorId) == true then
		if self._breakThrough == nil then
			if self._isReadyHeroTupo == true and self._isQUIDialogEquipmentBreakthroughSuccessEnd == true then
				self._isHeroTupoing = true
				-- 可播放刷新特效，并由装备突破界面切换到魂师突破界面
				local ccbFile = "ccb/effects/tupo.ccbi"
				local effectShow = QUIWidgetAnimationPlayer.new()
				self._ccbOwner.node_right:addChild( effectShow )
				effectShow:setPosition(ccp(0, 0))

				self._breakThrough = QUIWidgetHeroEquipmentHeroBreakThrough.new()
				self._breakThrough:addEventListener(QUIWidgetHeroEquipmentHeroBreakThrough.EVENT_BREAK_SUCC, handler(self, self.onEvent))
	  			self._breakThrough:addEventListener(QUIDialogHeroEquipmentDetail.REFESH_BATTLE_FORCE, handler(self, self._refreshBatlleForce))
				self._ccbOwner.node_right:addChild(self._breakThrough)
				self._breakThrough:resetAll()
				self._breakThrough:setInfo(self._actorId)
				self._breakThrough:setVisible(false)
				
				local effectFun = function()
					effectShow:playAnimation(ccbFile, function()
						end, function()  
							if self._infoWidget ~= nil then
								self._infoWidget:setVisible(false)
								self._infoWidget = nil
							end
							self._infoWidget = self._breakThrough
							self._breakThrough:setVisible(true)
							self._isReadyHeroTupo = false
							self._isQUIDialogEquipmentBreakthroughSuccessEnd = false
							scheduler.performWithDelayGlobal(function()
								self._isHeroTupoing = false
							end, 1)
							effectShow:disappear()
						end)
					end
				effectFun()
			elseif self._isReadyHeroTupo ~= true then
				-- 不播放刷新特效，直接展示魂师突破界面
				self._breakThrough = QUIWidgetHeroEquipmentHeroBreakThrough.new()
				self._breakThrough:addEventListener(QUIWidgetHeroEquipmentHeroBreakThrough.EVENT_BREAK_SUCC, handler(self, self.onEvent))
	  			self._breakThrough:addEventListener(QUIDialogHeroEquipmentDetail.REFESH_BATTLE_FORCE, handler(self, self._refreshBatlleForce))
				self._ccbOwner.node_right:addChild(self._breakThrough)
				self._breakThrough:resetAll()
				self._breakThrough:setInfo(self._actorId)
				self._infoWidget = self._breakThrough
				self._isHeroTupoing = false
			else 
				-- 再刷新特效播放前，依然停留在装备突破的界面上，等恭喜信息点掉之后，再回到上面的播放特效逻辑
				breakPanelFun()
			end
		else
			-- 保留当前装备突破或魂师突破不变，仅因为魂师切换而相应切换
			self._breakThrough:resetAll()
			self._breakThrough:setInfo(self._actorId)
			self._infoWidget = self._breakThrough
			self._isHeroTupoing = false
		end	
	else
		breakPanelFun()
	end

	if self._equipmentPos ~= EQUIPMENT_TYPE.JEWELRY1 and self._equipmentPos ~= EQUIPMENT_TYPE.JEWELRY2 then
		for i = 1, 4 do
			self._equipBox[i]:showEnchantIcon(false)
			-- self._equipBox[i]:showStrengthenLevelIcon(false)
		end
	else
		for i = 1, 2 do
			self._equipBox[i]:showEnchantIcon(false)
			-- self._equipBox[i]:showStrengthenLevelIcon(false)
		end
	end
end

function QUIDialogHeroEquipmentDetail:selectedTabMagic()
	if self._equipmentPos == EQUIPMENT_TYPE.JEWELRY1 or self._equipmentPos == EQUIPMENT_TYPE.JEWELRY2 then
		self._ccbOwner.frame_tf_title:setString("饰品觉醒")
	else
		self._ccbOwner.frame_tf_title:setString("装备觉醒")
	end

	self._tabManager:selected(self._ccbOwner.tab_magic)

	local enchant = remote.herosUtil:getWearByItem(self._actorId, self._itemId)

	if (enchant.enchants or 0) < QStaticDatabase:sharedDatabase():getMaxEnchantLevel(self._itemId, self._actorId) then
		if self._enchant == nil then
			self._enchant = QUIWidgetHeroEquipmentEnchant.new()
			self._ccbOwner.node_right:addChild(self._enchant)
			self._enchant:addEventListener(QUIWidgetHeroEquipmentEnchant.ENCHANT, handler(self, self.onEnchant))
			self._enchant:addEventListener(QUIDialogHeroEquipmentDetail.REFESH_BATTLE_FORCE, handler(self, self._refreshBatlleForce))
			self._enchant:addEventListener(QUIWidgetHeroEquipmentEnchant.ENCHANT_SUCCESS_EVENT, handler(self, self._onEnchantSuccess))
			self._enchant:addEventListener(QUIWidgetHeroEquipmentEnchant.ENCHANT_RESET_EVENT, handler(self, self._onEnchantReset))
		end
	  	self._enchant:setEquipmentPos(self._equipmentPos)
		self._enchant:setInfo(self._actorId, self._itemId)
		self._infoWidget = self._enchant
	else
		if self._enchantMax == nil then
			self._enchantMax = QUIWidgetHeroEquipmentEnchantMax.new()
			self._enchantMax:addEventListener(QUIWidgetHeroEquipmentEnchantMax.ENCHANT_RESET_EVENT, handler(self, self._onEnchantReset))
			self._ccbOwner.node_right:addChild(self._enchantMax)
		end
		self._enchantMax:setInfo(self._actorId, self._itemId)
		self._infoWidget = self._enchantMax
	end

	if self._equipmentPos ~= EQUIPMENT_TYPE.JEWELRY1 and self._equipmentPos ~= EQUIPMENT_TYPE.JEWELRY2 then
		for i = 1, 4 do
			self._equipBox[i]:showStrengthenLevelIcon(false)
		end
	else
		for i = 1, 2 do
			self._equipBox[i]:showStrengthenLevelIcon(false)
		end
	end
end

function QUIDialogHeroEquipmentDetail:onEnchant(event)
	if event.masterUpGrade == nil then return end

	if event.isShowMaster == false then
		app.master:createMasterLayer() 
	elseif event.isShowMaster then
		app.master:upGradeMaster(event.masterUpGrade, event.masterType, self._actorId)
		app.master:cleanMasterLayer()
	end
end

function QUIDialogHeroEquipmentDetail:_onEnchantSuccess(event)
	if self._equipmentPos == EQUIPMENT_TYPE.WEAPON then
		if math.fmod(event.enchantLevel + 1, 2) == 1 then
			self._information:setAvatar(self._heroInfo.actorId, 1.1)
			self._information:getAvatar():playEnchantSuccessAnimation()
			self._information:setStarVisible(false)
		end
	end
end

function QUIDialogHeroEquipmentDetail:_onEnchantReset(event)
	if not event.actorId or not event.itemId then return end

	app:getClient():heroEquipmentEnchantRecoverRequest(event.actorId, event.itemId, function(data)
		-- 更新背包
		local wallet = {}
		wallet.money = data.money
		wallet.token = data.token
		remote.user:update( wallet )
		if data.items then remote.items:setItems(data.items) end

		if self:safeCheck() then
			self:_refreshBatlleForce()	
		end

		-- 展示奖励页面
		if data.heroEquipmentEnchantRecoverResponse then
			local awards = {}
			local tbl = string.split(data.heroEquipmentEnchantRecoverResponse.recoverItemInfo or "", ";")
			for _, awardStr in pairs(tbl or {}) do
				local id, typeName, count = remote.rewardRecover:getItemBoxParaMetet(awardStr)
				table.insert(awards, {id = id, count = count, typeName = typeName})
			end
			app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogEnchantResetAwardsAlert",
        		options = {awards = awards, callBack = function()
        			self:_onTriggerTabMagic(true)
        		end}}, {isPopCurrentDialog = false} )
		end
	end)
end

function QUIDialogHeroEquipmentDetail:checkHeroCanBreakthrough()
	local canBreakthrough = remote.herosUtil:checkHerosBreakthroughByID(self._actorId)
	-- self._heroHead:setCanBreakthrough(canBreakthrough)
end

function QUIDialogHeroEquipmentDetail:_onTriggerTabStrong()
	app.sound:playSound("common_menu")

	if self._isHeroTupoing then return end
	self:selectTab(QUIDialogHeroEquipmentDetail.TAB_STRONG)
	self:setMasterType(QUIDialogHeroEquipmentDetail.TAB_STRONG)
	self:setMasterAnimation()
end

function QUIDialogHeroEquipmentDetail:_onTriggerTabEvolution()
	app.sound:playSound("common_menu")

	-- Kumo1 按突破按钮切换到突破界面的时候
	remote.herosUtil:dispatchEvent({name = remote.herosUtil.EVENT_SAVE_STRENGTHEN_EXP})
	self:selectTab(QUIDialogHeroEquipmentDetail.TAB_EVOLUTION)
	self:setMasterType(QUIDialogHeroEquipmentDetail.TAB_EVOLUTION)
	self:setMasterAnimation()
end

function QUIDialogHeroEquipmentDetail:_onTriggerTabMagic(isforce)
	app.sound:playSound("common_menu")

	if self._isHeroTupoing then return end
	remote.herosUtil:dispatchEvent({name = remote.herosUtil.EVENT_SAVE_STRENGTHEN_EXP})
	self:selectTab(QUIDialogHeroEquipmentDetail.TAB_MAGIC, isforce)
	self:setMasterType(QUIDialogHeroEquipmentDetail.TAB_MAGIC)
	self:setMasterAnimation()
end

function QUIDialogHeroEquipmentDetail:setMasterType(tab)
	self._ccbOwner.master:setVisible(true)
	if tab == QUIDialogHeroEquipmentDetail.TAB_STRONG then
		if self._equipmentPos ~= EQUIPMENT_TYPE.JEWELRY1 and self._equipmentPos ~= EQUIPMENT_TYPE.JEWELRY2 then
			self._masterType = QUIHeroModel.EQUIPMENT_MASTER
			if app.master:checkEquipStrengMasterUnlock(self._actorId) == false then
				self._ccbOwner.master:setVisible(false)
			end
		else
			self._masterType = QUIHeroModel.JEWELRY_MASTER
			if app.master:checkJewelryStrengMasterUnlock(self._actorId) == false then
				self._ccbOwner.master:setVisible(false)
			end
		end
		self._tabManager:selected(self._ccbOwner.tab_strong)
	elseif tab == QUIDialogHeroEquipmentDetail.TAB_EVOLUTION then
		if self._equipmentPos ~= EQUIPMENT_TYPE.JEWELRY1 and self._equipmentPos ~= EQUIPMENT_TYPE.JEWELRY2 then
			self._ccbOwner.master:setVisible(false)
		else
			self._masterType = QUIHeroModel.JEWELRY_BREAK_MASTER
			if app.master:checkJewelryBreakMasterUnlock(self._actorId) == false then
				self._ccbOwner.master:setVisible(false)
			end
		end
	elseif tab == QUIDialogHeroEquipmentDetail.TAB_MAGIC then
		if self._equipmentPos ~= EQUIPMENT_TYPE.JEWELRY1 and self._equipmentPos ~= EQUIPMENT_TYPE.JEWELRY2 then
			self._masterType = QUIHeroModel.EQUIPMENT_ENCHANT_MASTER
			if app.master:checkEquipEnchantMasterUnlock(self._actorId) == false then
				self._ccbOwner.master:setVisible(false)
			end
		else
			self._masterType = QUIHeroModel.JEWELRY_ENCHANT_MASTER
			if app.master:checkJewelryEnchantMasterUnlock(self._actorId) == false then
				self._ccbOwner.master:setVisible(false)
			end
		end
	end
end

function QUIDialogHeroEquipmentDetail:setMasterAnimation()
	local ccbFile = "ccb/effects/Hero_Master_Shipingqianghua.ccbi"
	if self._masterType == QUIHeroModel.JEWELRY_MASTER then
		ccbFile = "ccb/effects/Hero_Master_Shipingqianghua.ccbi"
	elseif self._masterType == QUIHeroModel.EQUIPMENT_MASTER then
		ccbFile = "ccb/effects/Hero_Master_Zhuangbeiqianghua.ccbi"
	elseif self._masterType == QUIHeroModel.EQUIPMENT_ENCHANT_MASTER then
		ccbFile = "ccb/effects/Hero_Master_Zhuangbeifumo.ccbi"
	elseif self._masterType == QUIHeroModel.JEWELRY_ENCHANT_MASTER then
		ccbFile = "ccb/effects/Hero_Master_Shipingfumo.ccbi"
	elseif self._masterType == QUIHeroModel.JEWELRY_BREAK_MASTER then
		ccbFile = "ccb/effects/Hero_Master_Shipingtupo.ccbi"
	end

	self._ccbOwner.word_node:removeAllChildren()

	local level = self._heroUIModel:getMasterLevelByType(self._masterType)
	self._ccbOwner.master_level:setString("LV"..(level or 0))
	self._ccbOwner.level:setVisible(true)
	if level == 0 then
		self._ccbOwner.level:setVisible(false)
	end

	self._animationFunc = function()
		if self._masterAnimation ~= nil then
			self._masterAnimation:disappear()
			self._masterAnimation = nil
		end
		self._masterAnimation = QUIWidgetAnimationPlayer.new()
		self._ccbOwner.master_icon:addChild(self._masterAnimation)
		self._masterAnimation:playAnimation(ccbFile, nil, function()
				self._animationFunc()
			end)
	end
	self._animationFunc()
end 

function QUIDialogHeroEquipmentDetail:_onTabLink(data)
	-- Kumo3 从快捷途径进入，可能是突破界面
	if data ~= nil and data.tab ~= nil then
		self:selectTab(data.tab)
	end
end

function QUIDialogHeroEquipmentDetail:locking()
	if remote.herosUtil:checkHerosBreakthroughByID(self._actorId) then
		self._isHeroTupoing = true
	end
end

function QUIDialogHeroEquipmentDetail:_refreshBatlleForce( isQUIDialogEquipmentBreakthroughSuccessEnd )
	self._isQUIDialogEquipmentBreakthroughSuccessEnd = isQUIDialogEquipmentBreakthroughSuccessEnd

	if isQUIDialogEquipmentBreakthroughSuccessEnd == true then
		-- 界面优化
		self:selectedTabEvolution()
	end
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

function QUIDialogHeroEquipmentDetail:setBattleForceText(battleForce)
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
		local fontColor = ccc3(color[1], color[2], color[3])
		self._ccbOwner.tf_battleForce:setColor(fontColor)
    end

	if battleForce == self._newBattle then
		self._ccbOwner.tf_battleForce:runAction(CCScaleTo:create(0.2, 1))
	end
end 

function QUIDialogHeroEquipmentDetail:_heroBreakByOneKeyHandler(event)
	self:_onBreakthroughEffect(event)
	self:_refreshBatlleForce()
end

function QUIDialogHeroEquipmentDetail:_onBreakthroughEffect(event)
	app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogBreakthrough", 
		options = { actorId = self._actorId, oldHeroInfo = event.oldHeroInfo}}, {isPopCurrentDialog = false})
end

function QUIDialogHeroEquipmentDetail:heroPropUpdateHandler(event)
	if event.actorId == self._actorId then
		if event.name == remote.herosUtil.EVENT_HERO_PROP_UPDATE then 
			self._information:playPropEffect(event.value)
		end
	end
end

function QUIDialogHeroEquipmentDetail:heroEquipUpdateHandler(event)
	if event.actorId == self._actorId then
		if event.name == remote.herosUtil.EVENT_HERO_EQUIP_UPDATE then 
			-- self._equipmentUtils:refreshBox()
			-- self:checkRedTips()
			-- self:hideEquipmentState(self._currentTab)
			
			if self:safeCheck() == true then
				self:setInfo(self._actorId, self._equipmentPos)
			end
		end
	end
end

function QUIDialogHeroEquipmentDetail:_onTriggerRight()
    app.sound:playSound("common_change")
    if self._isHeroTupoing then return end
    remote.herosUtil:dispatchEvent({name = remote.herosUtil.EVENT_SAVE_STRENGTHEN_EXP})
    local n = table.nums(self._heros)
    if nil ~= self._pos and n > 1 then
        self._pos = self._pos + 1
        if self._pos > n then
            self._pos = 1
        end
        local options = self:getOptions()
        options.pos = self._pos
        options.parentOptions.pos = options.pos
        self._oldBattleForce = 0
	    if self._textUpdate ~= nil then
			self._textUpdate:stopUpdate()
			self._textUpdate = nil
		end
		self:setInfo(self._heros[self._pos], self._equipmentPos)
	end
end

function QUIDialogHeroEquipmentDetail:_onTriggerLeft()
    app.sound:playSound("common_change")
    if self._isHeroTupoing then return end
    remote.herosUtil:dispatchEvent({name = remote.herosUtil.EVENT_SAVE_STRENGTHEN_EXP})
    local n = table.nums(self._heros)
    if nil ~= self._pos and n > 1 then
        self._pos = self._pos - 1
        if self._pos < 1 then
            self._pos = n
        end
        local options = self:getOptions()
        options.pos = self._pos
        options.parentOptions.pos = options.pos
        self._oldBattleForce = 0
	    if self._textUpdate ~= nil then
			self._textUpdate:stopUpdate()
			self._textUpdate = nil
		end
		self:setInfo(self._heros[self._pos], self._equipmentPos)
	end
end

function QUIDialogHeroEquipmentDetail:_unlockHandler(event)
	self._ccbOwner.tab_magic:setVisible(app.unlock:getUnlockEnchant())
end

function QUIDialogHeroEquipmentDetail:onTriggerBackHandler(tag)
	if self._topTouchLayer ~= nil then return end
	self:_onTriggerBack()
end

function QUIDialogHeroEquipmentDetail:onTriggerHomeHandler(tag)
	if self._topTouchLayer ~= nil then return end
	self:_onTriggerHome()
end
 
-- 对话框退出
function QUIDialogHeroEquipmentDetail:_onTriggerBack(tag, menuItem)
	app:getNavigationManager():popViewController(app.mainUILayer, QNavigationController.POP_TOP_CONTROLLER)
end

-- 对话框退出
function QUIDialogHeroEquipmentDetail:_onTriggerHome(tag, menuItem)
	app:getNavigationManager():popViewController(app.mainUILayer, QNavigationController.POP_TO_CURRENT_PAGE)
end

return QUIDialogHeroEquipmentDetail