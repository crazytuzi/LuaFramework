-- @Author: xurui
-- @Date:   2019-11-21 16:46:44
-- @Last Modified by:   liaoxianbo
-- @Last Modified time: 2019-11-30 18:18:37
local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogJewelryStrengthOneClick = class("QUIDialogJewelryStrengthOneClick", QUIDialog)

local QNavigationController = import("...controllers.QNavigationController")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QUIViewController = import("..QUIViewController")
local QUIWidgetMasterCell = import("..widgets.QUIWidgetMasterCell")

local QUIDialogHeroEquipmentDetail = import("..dialogs.QUIDialogHeroEquipmentDetail")
local QUIWidgetMasterPropClient = import("..widgets.QUIWidgetMasterPropClient")
local QQuickWay = import("...utils.QQuickWay")
local QUIWidgetAnimationPlayer = import("..widgets.QUIWidgetAnimationPlayer")
local QUIWidgetFcaAnimation = import("..widgets.actorDisplay.QUIWidgetFcaAnimation")

function QUIDialogJewelryStrengthOneClick:ctor(options)
	local ccbFile = "ccb/Dialog_suit_equip_strengthen.ccbi"
    local callBacks = {
		{ccbCallbackName = "onTriggerClose", callback = handler(self, self._onTriggerClose)},
		{ccbCallbackName = "onTriggerSelect", callback = handler(self, self._onTriggerSelect)},
		{ccbCallbackName = "onTriggerStrengthen", callback = handler(self, self._onTriggerStrengthen)},
    }
    QUIDialogJewelryStrengthOneClick.super.ctor(self, ccbFile, callBacks, options)
    self.isAnimation = true

	cc.GameObject.extend(self)
	self:addComponent("components.behavior.EventProtocol"):exportMethods()

	self._jewelryBox = {}
	self._currMasterInfo = {}
	self._nextMasterInfo = {}
	self.offersetLevel = 1
	self._ccbOwner.tf_tips:setAnchorPoint(ccp(0.5, 1))
	self._ccbOwner.tf_tips:setPositionY(self._ccbOwner.tf_tips:getPositionY() + 10)

    if options then
    	self._callBack = options.callBack
		self._masterType = options.masterType
		self._actorId = options.actorId
		self._parentOptions = options.parentOptions
    end

    self._isStrengthenMax = false
    self._oneClickKey = "strength"
    self.maxStrengthenLevel = remote.user.level * 2
	self._ccbOwner.frame_tf_title:setString("饰品强化")
	
	self._isStrengthenMax = app:getUserOperateRecord():getJewelryOneClickStrengthen(self._oneClickKey) or false
	self._ccbOwner.sp_select_2:setVisible(self._isStrengthenMax)

	for i = 1, 2 do
		self._jewelryBox[i] = QUIWidgetMasterCell.new()
		self._ccbOwner["box_node"..i]:addChild(self._jewelryBox[i])
		self._jewelryBox[i]:addEventListener(QUIWidgetMasterCell.EVENT_CLICK_BOX, handler(self, self._eventClickBox))
	end
	self._jewelryBox[1]:setType(EQUIPMENT_TYPE.JEWELRY1)
	self._jewelryBox[2]:setType(EQUIPMENT_TYPE.JEWELRY2)

    self:restAll()
end

function QUIDialogJewelryStrengthOneClick:restAll()

	self._ccbOwner.node_master:removeAllChildren()
end

function QUIDialogJewelryStrengthOneClick:viewDidAppear()
	QUIDialogJewelryStrengthOneClick.super.viewDidAppear(self)

	self:addBackEvent(true)

	self:initInfo()
end

function QUIDialogJewelryStrengthOneClick:countNeedExpItem(jewelryInfo, maxLevel, jewelryIndex, needJewelryEnergyList)
	self._expItems = {33, 32, 31}
	if jewelryIndex == 2 then
		self._expItems = {38, 37, 36}
	end

	local jewelryType = "enhance_exp"..(jewelryIndex or 1) 
	local needJewelryEnergy = 0
	local startLevel = jewelryInfo.level or 1
	local startExp = jewelryInfo.enhance_exp or 1
	for i = startLevel + 1, maxLevel do
		local expInfo = QStaticDatabase:sharedDatabase():getJewelryStrengthenInfoByLevel(i)
		if expInfo and expInfo[jewelryType] then
			if i == startLevel + 1 then
				needJewelryEnergy = needJewelryEnergy + tonumber(expInfo[jewelryType]) - startExp
			else
				needJewelryEnergy = needJewelryEnergy + tonumber(expInfo[jewelryType])
			end
		end
	end

	if needJewelryEnergy > 0 then
		for i = #self._expItems, 1, -1 do
			local id = self._expItems[i]
			local count = remote.items:getItemsNumByID(id)
			local exp = 0
			local itemConfig = QStaticDatabase:sharedDatabase():getItemByID(id)
			if itemConfig ~= nil then
				exp = itemConfig["enhance_exp"..jewelryIndex] or 0
			end

			if count > 0 then
				local itemExp = count * exp
				if itemExp <= needJewelryEnergy then
					needJewelryEnergy = needJewelryEnergy - itemExp
					table.insert(needJewelryEnergyList, {id = id, count = count})
				else
					local realCount = math.ceil(needJewelryEnergy/exp)
					if realCount <= count then
						needJewelryEnergy = 0
						table.insert(needJewelryEnergyList, {id = id, count = realCount})
						break
					end
				end
			end
		end
	end


	return needJewelryEnergy <= 0 
end

function QUIDialogJewelryStrengthOneClick:checkNeedMoney()
	local strengthLevel = 0
	self._needJewelryEnergyList = {}
	if self._isStrengthenMax then
		strengthLevel = self.maxStrengthenLevel - self.maxStrengthenLevel % 10
	else
		strengthLevel = (self._masterLevel+1)*10
	end

	self._canBeStrEngth = 0  -- 0,可以强化;1,戒指强化道具不足;2,项链强化道具不足;
	if strengthLevel <= self.maxStrengthenLevel then
		for i = 1, 2 do
			if self._jewelryBox[i] then
				local index = self._jewelryBox[i]:getType()
				local jewelryInfo = self.heroUIModel:getEquipmentInfoByPos(index)
				if jewelryInfo.info then
					local canBeStrEngth = self:countNeedExpItem(jewelryInfo.info, strengthLevel, i, self._needJewelryEnergyList)
					if canBeStrEngth == false then
						self._canBeStrEngth = i
						break
					end
				end
			end
		end
	end

	if self._canBeStrEngth > 0 then
		local tip = "饰品强化所需戒指强化粉尘不足，快去获取吧"
		if self._canBeStrEngth == 2 then
			tip = "饰品强化所需项链强化粉尘不足，快去获取吧"
		end
		self._ccbOwner.tf_tips:setString(tip)
		self._ccbOwner.confirmText:setString("确 定")
	elseif q.isEmpty(self._needJewelryEnergyList) and self._canBeStrEngth == 0 then
		self._ccbOwner.tf_tips:setString("饰品等级达到上限，提升战队等级可提升上限")
		self:setButtonEnabled(false)
		self._ccbOwner.confirmText:setString("确 定")
		self._ccbOwner.confirmText:disableOutline()
	else
		local untilLevel = self.offersetLevel + self._masterLevel
		local str = ""
		for _, value in ipairs(self._needJewelryEnergyList) do
			if value.count > 0 then
				local itemConfig = QStaticDatabase:sharedDatabase():getItemByID(value.id)
				if str ~= "" then
					str = str.."，"..(value.count or 0)..(itemConfig.name or "")
				else
					str = str..(value.count or 0)..(itemConfig.name or "")
				end
			end
		end
		self._ccbOwner.tf_tips:setString("消耗"..str.."将所有饰品强化至"..untilLevel.."级效果")
		self._ccbOwner.confirmText:setString("强 化")
	end
end

function QUIDialogJewelryStrengthOneClick:setButtonEnabled(state)
	if state == false then
		makeNodeFromNormalToGray(self._ccbOwner.btn_buy)
		self._ccbOwner.confirmText:disableOutline()
		self._ccbOwner.bt_confirm:setEnabled(false)
	elseif state then
		makeNodeFromGrayToNormal(self._ccbOwner.btn_buy)
		self._ccbOwner.confirmText:enableOutline()
		self._ccbOwner.bt_confirm:setEnabled(true)
	end

end

function QUIDialogJewelryStrengthOneClick:initInfo( )
    self.heroUIModel = remote.herosUtil:getUIHeroByID(self._actorId)
	self._masterLevel = self.heroUIModel:getMasterLevelByType(self._masterType)

	if self._isStrengthenMax then
		self.offersetLevel = math.floor(self.maxStrengthenLevel / 10) - self._masterLevel
	else
		self.offersetLevel = 1
	end
	if self.offersetLevel == 0 then
		self.offersetLevel = 1
	end

	self._currMasterInfo, self._nextMasterInfo, self._isMax = QStaticDatabase:sharedDatabase():getStrengthenMasterByMasterLevel(self._masterType, self._masterLevel,self.offersetLevel)

	if self._isStrengthenMax then
		self.oneTimeStrengthenLevel = self.maxStrengthenLevel - self.maxStrengthenLevel % 10
	else
		self.oneTimeStrengthenLevel = (self._masterLevel+1)*10
	end

	self:setBoxInfos()
	self:setPropInfo()

	self:checkNeedMoney()
end


function QUIDialogJewelryStrengthOneClick:setBoxInfos()
	for i = 1, 2 do
		self._jewelryBox[i]:setPositionY(-50)
		local jewelryInfo = self.heroUIModel:getEquipmentInfoByPos(self._jewelryBox[i]:getType())
		if jewelryInfo.info ~= nil then
			local itemInfo = QStaticDatabase:sharedDatabase():getItemByID(jewelryInfo.info.itemId)
			local canStrengthen = false 
			if jewelryInfo.info.level < self.oneTimeStrengthenLevel and jewelryInfo.info.level < self.maxStrengthenLevel then
				canStrengthen = true
			end
			self._jewelryBox[i]:setItemInfo(itemInfo, jewelryInfo, self._nextMasterInfo, self._masterType, canStrengthen)
		else
			self._jewelryBox[i]:showEmpty(self._nextMasterInfo)
		end
	end
end

function QUIDialogJewelryStrengthOneClick:setPropInfo()
	if self._propClient == nil then
		self._propClient = QUIWidgetMasterPropClient.new()
		self._ccbOwner.node_master:addChild(self._propClient)
	end
	self._propClient:setClientInfo(self._masterLevel, self._isMax, self._currMasterInfo, self._nextMasterInfo, self._masterType,true)

end 

function QUIDialogJewelryStrengthOneClick:viewWillDisappear()
  	QUIDialogJewelryStrengthOneClick.super.viewWillDisappear(self)

	self:removeBackEvent()
end

function QUIDialogJewelryStrengthOneClick:_onTriggerSelect()
	local btnState = self._ccbOwner.sp_select_2:isVisible()

	self._ccbOwner.sp_select_2:setVisible(not btnState)
	self._isStrengthenMax = not btnState
	app:getUserOperateRecord():setSparOneClickStrengthen(not btnState)

	self:initInfo()
end

function QUIDialogJewelryStrengthOneClick:_onTriggerStrengthen(event)
	if q.buttonEventShadow(event, self._ccbOwner.bt_confirm) == false then return end

	if self._canBeStrEngth > 0 then 
    	QQuickWay:addQuickWay(QQuickWay.ITEM_DROP_WAY, self._expItems[1])
		return
	end

	local jewelryPos = {}
	local oldAllLevel = 0
	local oldEquipConfig = {}
	for i = 1, 2 do
		local jewelryIndex = self._jewelryBox[i]:getType(i)
		local jewelryInfo = self.heroUIModel:getEquipmentInfoByPos(jewelryIndex)
		if jewelryInfo.info.level < self.oneTimeStrengthenLevel then
			table.insert(jewelryPos, jewelryIndex)
			oldAllLevel = oldAllLevel + jewelryInfo.info.level
			local itemConfig = QStaticDatabase:sharedDatabase():getItemByID(jewelryInfo.info.itemId)
			local oldConfig = QStaticDatabase:sharedDatabase():getTotalEnhancePropByLevel(itemConfig.enhance_data, jewelryInfo.info.level)
			table.insert(oldEquipConfig, {oldConfig = oldConfig, itemId = jewelryInfo.info.itemId})
		end
	end
	local oldMasterLevel = self._masterLevel
	self._animationEnded = false
	self:setButtonEnabled(false)
	local untilLevel = self.offersetLevel + self._masterLevel

	app:getClient():jewelryEnchanceOneClickRequest(self._actorId, untilLevel*10, function(data)
		if self.class ~= nil then
			local critNum = data.enhanceEquipmentCritCount --暴击

			local newLevel = 0
			local attributeInfo = {}
			local index = 1
			for _,v in pairs(jewelryPos)  do
				local equipment = self.heroUIModel:getEquipmentInfoByPos(v)
				local equipLevel = 0
				if equipment then
					equipLevel = equipment.info.level or 0
				end
				newLevel = newLevel + equipLevel

				for _,v in pairs(oldEquipConfig) do
					if v.itemId == equipment.info.itemId then
						local itemConfig = QStaticDatabase:sharedDatabase():getItemByID(equipment.info.itemId)
						local newConfig = QStaticDatabase:sharedDatabase():getTotalEnhancePropByLevel(itemConfig.enhance_data, equipLevel)
						if newConfig.hp_value then
							attributeInfo[index] = {name = "生   命",value = newConfig.hp_value - (v.oldConfig.hp_value or 0)}
							index = index + 1
						end
						if newConfig.attack_value then
							attributeInfo[index] = {name = "攻   击",value = newConfig.attack_value - (v.oldConfig.attack_value or 0 )}
							index = index + 1
						end
						if newConfig.armor_physical then
							attributeInfo[index] = {name = "物理防御",value = newConfig.armor_physical - (v.oldConfig.armor_physical or 0)}
							index = index + 1
						end
						if newConfig.armor_magic then
							attributeInfo[index] = {name = "法术防御",value = newConfig.armor_magic - (v.oldConfig.armor_magic or 0 )}
							index = index + 1
						end																		
					end
				end
			end
			local nowMasterLevel = self.heroUIModel:getMasterLevelByType(self._masterType)
			local masterUpGrade = nowMasterLevel > self._masterLevel and nowMasterLevel or 1 
			local upLevel = masterUpGrade - self._masterLevel
			local showData = {critNum = 0, changeLevel = newLevel - oldAllLevel, masterUpGrade = masterUpGrade,  upLevel = upLevel, masterType = self._masterType,attributeInfo=attributeInfo}
			self:strengthenSucceedEffect(showData)

			self:showStrengThenEffect()
			remote.user:addPropNumForKey("todayAdvancedEnhanceCount", newLevel - oldAllLevel)
			
			self:dispatchEvent({name = QUIDialogHeroEquipmentDetail.REFESH_BATTLE_FORCE})
		end
	end, function()
		self:setButtonEnabled(true)
	end)

end

function QUIDialogJewelryStrengthOneClick:showStrengThenEffect()
	for i = 1, 2 do
		local fcaAnimation = QUIWidgetFcaAnimation.new("fca/yijianqianghua_1", "res")
		fcaAnimation:playAnimation("animation", false)
		fcaAnimation:setEndCallback(function( )
			fcaAnimation:removeFromParent()
		end)
		fcaAnimation:setScale(1/0.78)
		fcaAnimation:setPositionY(-43)
		self._ccbOwner["box_node"..i]:addChild(fcaAnimation)
	end
end

function QUIDialogJewelryStrengthOneClick:strengthenSucceedEffect(data)
	self._ccbOwner.strenAnimationNode:removeAllChildren()
	local strengthenEffectShow = QUIWidgetAnimationPlayer.new()
	self._ccbOwner.strenAnimationNode:addChild(strengthenEffectShow)
	strengthenEffectShow:setPosition(ccp(0, 100))
	strengthenEffectShow:playAnimation("ccb/effects/BaojiOneTime.ccbi", function(ccbOwner)
		ccbOwner.level:setVisible(false)
		ccbOwner.node_critcrit:setVisible(false)
		ccbOwner.tf_name:setString("连续强化"..(data.changeLevel).."次")
		if data.attributeInfo then
			for i = 1, 4 do
				if data.attributeInfo[i] then
					local value = data.attributeInfo[i].value
					if value < 1 then
						value = value.."%"
					end
					self._strengthValue = value
					strengthenEffectShow._ccbOwner["tf_name"..i]:setString(data.attributeInfo[i].name .. "＋" .. value)
				else
					strengthenEffectShow._ccbOwner["node_"..i]:setVisible(false)
				end
			end
		end
	end, function()
		if strengthenEffectShow ~= nil then
			strengthenEffectShow:disappear()
			strengthenEffectShow = nil
			self:setButtonEnabled(true)
			self:initInfo()
		end
	end)

	if data.masterUpGrade ~= nil then
		app.master:createMasterLayer()
	end
		self._strengthenScheduler = scheduler.performWithDelayGlobal(function()
				if data.masterUpGrade then
					app.master:upGradeMaster(data.masterUpGrade, data.masterType, self._actorId, nil, data.upLevel)
					app.master:cleanMasterLayer()
				end
			end, 1.3)
end

function QUIDialogJewelryStrengthOneClick:_eventClickBox(event)

	self:viewAnimationOutHandler()

	if self._isPopParentDialog then
		app:getNavigationManager():popViewController(app.mainUILayer, QNavigationController.POP_TOP_CONTROLLER)
	end

	local initTab = "TAB_STRONG"
  	app:getNavigationManager():pushViewController(app.mainUILayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogHeroEquipmentDetail", 
        options = {itemId = event.itemId, pos = event.euqipPos, heros = self._parentOptions.heros, parentOptions = self._parentOptions,
         initTab = initTab, isQuickWay = self._isQuickWay}})
end

function QUIDialogJewelryStrengthOneClick:_backClickHandler()
  	app.sound:playSound("common_close")
	self:playEffectOut()
end

function QUIDialogJewelryStrengthOneClick:_onTriggerClose(event)
	if q.buttonEventShadow(event,self._ccbOwner.btn_close) == false then return end
  	app.sound:playSound("common_close")
	self:playEffectOut()
end

function QUIDialogJewelryStrengthOneClick:viewAnimationOutHandler()
	local callback = self._callBack

	self:popSelf()

	if callback then
		callback()
	end
end

return QUIDialogJewelryStrengthOneClick
