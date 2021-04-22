-- @Author: xurui
-- @Date:   2019-11-18 14:39:15
-- @Last Modified by:   liaoxianbo
-- @Last Modified time: 2019-11-30 20:53:54
local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogOneClickSparStrengthen = class("QUIDialogOneClickSparStrengthen", QUIDialog)

local QNavigationController = import("...controllers.QNavigationController")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QUIViewController = import("..QUIViewController")
local QUIWidgetMasterCell = import("..widgets.QUIWidgetMasterCell")

local QUIDialogHeroEquipmentDetail = import("..dialogs.QUIDialogHeroEquipmentDetail")
local QUIWidgetMasterPropClient = import("..widgets.QUIWidgetMasterPropClient")
local QQuickWay = import("...utils.QQuickWay")
local QUIWidgetAnimationPlayer = import("..widgets.QUIWidgetAnimationPlayer")
local QUIWidgetFcaAnimation = import("..widgets.actorDisplay.QUIWidgetFcaAnimation")

function QUIDialogOneClickSparStrengthen:ctor(options)
	local ccbFile = "ccb/Dialog_suit_equip_strengthen.ccbi"
    local callBacks = {
		{ccbCallbackName = "onTriggerClose", callback = handler(self, self._onTriggerClose)},
		{ccbCallbackName = "onTriggerSelect", callback = handler(self, self._onTriggerSelect)},
		{ccbCallbackName = "onTriggerStrengthen", callback = handler(self, self._onTriggerStrengthen)},
    }
    QUIDialogOneClickSparStrengthen.super.ctor(self, ccbFile, callBacks, options)
    self.isAnimation = true

	cc.GameObject.extend(self)
	self:addComponent("components.behavior.EventProtocol"):exportMethods()

	self._sparBox = {}
	self._currMasterInfo = {}
	self._nextMasterInfo = {}
	self.offersetLevel = 1
	self._isStrengthenMax = app:getUserOperateRecord():getSparOneClickStrengthen() or false
	self._ccbOwner.sp_select_2:setVisible(self._isStrengthenMax)
	self._ccbOwner.frame_tf_title:setString("外附魂骨强化")
	self._ccbOwner.tf_tips:setAnchorPoint(ccp(0.5, 1))
	self._ccbOwner.tf_tips:setPositionY(self._ccbOwner.tf_tips:getPositionY() + 10)

    if options then
    	self._callBack = options.callBack
		self._masterType = options.masterType
		self._actorId = options.actorId
		self._strengWidget = options.strengWidget
    end

    self.allWearNeedMoney = 0
    self.allSparEnergy = 0

    self.maxStrengthenLevel = remote.user.level * 2


    self:restAll()
end

function QUIDialogOneClickSparStrengthen:restAll()

	self._ccbOwner.node_master:removeAllChildren()
end

function QUIDialogOneClickSparStrengthen:viewDidAppear()
	QUIDialogOneClickSparStrengthen.super.viewDidAppear(self)

	self:addBackEvent(true)

	self:initInfo()
end

function QUIDialogOneClickSparStrengthen:countNeedExpItem(maxLevel, sparIndex)
	self._expItems = { 10000009, 10000008, 10000007}

	local needEnergy = function(sparIndex, level)
		local sparType = "jewelry_exp"..(sparIndex or 1)
		local sparEnergy = 0
		local sparInfo = self.heroUIModel:getSparInfoByPos(sparIndex).info
		local startLevel = sparInfo.level or 1
		local startExp = sparInfo.exp or 1
		for i = startLevel + 1, level do
			local expInfo = QStaticDatabase:sharedDatabase():getJewelryStrengthenInfoByLevel(i)
			if expInfo and expInfo[sparType] then
				if i == startLevel + 1 then
					sparEnergy = sparEnergy + tonumber(expInfo[sparType]) - startExp
				else
					sparEnergy = sparEnergy + tonumber(expInfo[sparType])
				end
			end
		end

		return sparEnergy
	end

	local allSparEnergy = 0
	for i = 1, 2 do
		allSparEnergy = allSparEnergy + needEnergy(i, maxLevel)
	end

	local sparEnergyList = {}
	if allSparEnergy > 0 then
		for i = #self._expItems, 1, -1 do
			local id = self._expItems[i]
			local count = remote.items:getItemsNumByID(id)
			local exp = 0
			local itemConfig = QStaticDatabase:sharedDatabase():getItemByID(id)
			if itemConfig ~= nil then
				local expStr = string.split(itemConfig.exp_num, "^")
				if tonumber(expStr[2]) ~= nil then
					exp = tonumber(expStr[2])
				end
			end

			if count > 0 then
				local itemExp = count * exp
				if itemExp <= allSparEnergy then
					allSparEnergy = allSparEnergy - itemExp
					table.insert(sparEnergyList, {id = id, count = count})
				else
					local realCount = math.ceil(allSparEnergy/exp)
					if realCount <= count then
						allSparEnergy = 0
						table.insert(sparEnergyList, {id = id, count = realCount})
					end
					break
				end
			end
		end
	end


	return sparEnergyList, allSparEnergy <= 0 
end


function QUIDialogOneClickSparStrengthen:checkNeedMoney()
	local strengthLevel = 0
	self._needSparEnergyList = {}
	self._canBeStrEngth  = false
	if self._isStrengthenMax then
		strengthLevel = self.maxStrengthenLevel - self.maxStrengthenLevel % 10
	else
		strengthLevel = (self._masterLevel+1)*10
	end

	if strengthLevel <= self.maxStrengthenLevel then
		self._needSparEnergyList, self._canBeStrEngth = self:countNeedExpItem(strengthLevel)
	end
	
	if q.isEmpty(self._needSparEnergyList) then
		self._ccbOwner.tf_tips:setString("外附魂骨等级达到上限，提升战队等级可提升上限")
		self:setButtonEnabled(false)
		self._ccbOwner.confirmText:setString("确 定")
		self._ccbOwner.confirmText:disableOutline()
	elseif not self._canBeStrEngth then
		self._ccbOwner.tf_tips:setString("外附魂骨强化所需外附魂骨强化能量不足，快去获取更多魂骨能量吧")
		self._ccbOwner.confirmText:setString("确 定")
	else
		local untilLevel = self.offersetLevel + self._masterLevel
		local str = ""
		for _, value in ipairs(self._needSparEnergyList) do
			if value.count > 0 then
				local itemConfig = QStaticDatabase:sharedDatabase():getItemByID(value.id)
				if str ~= "" then
					str = str.."，"..(value.count or 0)..(itemConfig.name or "")
				else
					str = str..(value.count or 0)..(itemConfig.name or "")
				end
			end
		end
		self._ccbOwner.tf_tips:setString("消耗"..str.."将所有外附魂骨强化至"..untilLevel.."级效果")
		self._ccbOwner.confirmText:setString("强 化")
	end
end

function QUIDialogOneClickSparStrengthen:setButtonEnabled(state)
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

function QUIDialogOneClickSparStrengthen:initInfo( )
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


function QUIDialogOneClickSparStrengthen:setBoxInfos()
	if next(self._sparBox) then
		for i = 1, #self._sparBox, 1 do
			self._sparBox[i]:removeFromParent()
			self._sparBox[i] = nil
		end
	end

	for i = 1, 2 do
		self._sparBox[i] = QUIWidgetMasterCell.new()
		self._ccbOwner["box_node"..(i + 2)]:addChild(self._sparBox[i])
		self._sparBox[i]:setPositionY(50)
		local sparInfo = self.heroUIModel:getSparInfoByPos(i)
		if sparInfo.info ~= nil then
			local itemInfo = QStaticDatabase:sharedDatabase():getItemByID(sparInfo.info.itemId)

			local canStrengthen = false 
			if sparInfo.info.level < self.oneTimeStrengthenLevel and sparInfo.info.level < self.maxStrengthenLevel then
				canStrengthen = true
			end

			self._sparBox[i]:setType(i)
			self._sparBox[i]:setItemInfo(itemInfo, sparInfo, self._nextMasterInfo, self._masterType,canStrengthen)
		else
			self._sparBox[i]:showEmpty(self._nextMasterInfo)
		end
		self._sparBox[i]:addEventListener(QUIWidgetMasterCell.EVENT_CLICK_BOX, handler(self, self._eventClickBox))
	end
end

function QUIDialogOneClickSparStrengthen:setPropInfo()
	if self._propClient == nil then
		self._propClient = QUIWidgetMasterPropClient.new()
		self._ccbOwner.node_master:addChild(self._propClient)
	end
	self._propClient:setClientInfo(self._masterLevel, self._isMax, self._currMasterInfo, self._nextMasterInfo, self._masterType,true)

end 

function QUIDialogOneClickSparStrengthen:viewWillDisappear()
  	QUIDialogOneClickSparStrengthen.super.viewWillDisappear(self)

	self:removeBackEvent()
end

function QUIDialogOneClickSparStrengthen:_onTriggerSelect()
	local btnState = self._ccbOwner.sp_select_2:isVisible()

	self._ccbOwner.sp_select_2:setVisible(not btnState)
	self._isStrengthenMax = not btnState
	app:getUserOperateRecord():setSparOneClickStrengthen(not btnState)

	self:initInfo()
end

function QUIDialogOneClickSparStrengthen:_onTriggerStrengthen(event)
	if q.buttonEventShadow(event, self._ccbOwner.bt_confirm) == false then return end

	if not self._canBeStrEngth then 
    	QQuickWay:addQuickWay(QQuickWay.ITEM_DROP_WAY, self._expItems[1])
		return
	end

	local sparPosition = {}
	local oldAllLevel = 0
	local oldEquipConfig = {}
	for i = 1, 2 do
		local sparInfo = self.heroUIModel:getSparInfoByPos(i)
		if sparInfo.info.level < self.oneTimeStrengthenLevel then
			table.insert(sparPosition, i)
			oldAllLevel = oldAllLevel + sparInfo.info.level
			local itemConfig = QStaticDatabase:sharedDatabase():getItemByID(sparInfo.info.itemId)
			local oldConfig = QStaticDatabase:sharedDatabase():getTotalEnhancePropByLevel(itemConfig.enhance_data, sparInfo.info.level)
			table.insert(oldEquipConfig, {oldConfig = oldConfig, itemId = sparInfo.info.itemId})
		end
	end

	local oldMasterLevel = self._masterLevel
	self._animationEnded = false
	self:setButtonEnabled(false)
	local untilLevel = self.offersetLevel + self._masterLevel

	remote.spar:requestSparOneKeyEnhanceRequest(self._actorId, untilLevel * 10, function(data)
		if self.class ~= nil then
			local newLevel = 0
			local attributeInfo = {}
			local index = 1
			for _,v in pairs(sparPosition)  do
				local equipment = self.heroUIModel:getSparInfoByPos(v)
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
			local masterUpGrade = nowMasterLevel > self._masterLevel and nowMasterLevel or 0 
			local upLevel = masterUpGrade - self._masterLevel
			local showData = {critNum = 0, changeLevel = newLevel - oldAllLevel, masterUpGrade = masterUpGrade, upLevel = upLevel, masterType = self._masterType, attributeInfo=attributeInfo}
			self:strengthenSucceedEffect(showData)

			self:showStrengThenEffect()

			if self._strengWidget and self._strengWidget.setExpBar then
				self._strengWidget:setExpBar(newLevel)
			end
			
			remote.herosUtil:dispatchEvent({name = remote.herosUtil.EVENT_REFESH_BATTLE_FORCE})
		end
	end, function()
		self:setButtonEnabled(true)
	end)

end

function QUIDialogOneClickSparStrengthen:showStrengThenEffect()
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

function QUIDialogOneClickSparStrengthen:strengthenSucceedEffect(data)
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
		end, 1.5)

end

function QUIDialogOneClickSparStrengthen:_eventClickBox(event)

	self:viewAnimationOutHandler()

	if self._isPopParentDialog then
		app:getNavigationManager():popViewController(app.mainUILayer, QNavigationController.POP_TOP_CONTROLLER)
	end

	local initTab = "TAB_STRONG"
  	app:getNavigationManager():pushViewController(app.mainUILayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogHeroSparDetail", 
        options = {itemId= event.itemId, sparPos = event.euqipPos, heros = self._heros, pos = self._pos, parentOptions = self._parentOptions,
         initTab = initTab, isQuickWay = self._isQuickWay}})
end

function QUIDialogOneClickSparStrengthen:_backClickHandler()
  	app.sound:playSound("common_close")
	self:playEffectOut()
end

function QUIDialogOneClickSparStrengthen:_onTriggerClose(event)
	if q.buttonEventShadow(event,self._ccbOwner.btn_close) == false then return end
  	app.sound:playSound("common_close")
	self:playEffectOut()
end

function QUIDialogOneClickSparStrengthen:viewAnimationOutHandler()
	local callback = self._callBack

	self:popSelf()

	if callback then
		callback()
	end
end

return QUIDialogOneClickSparStrengthen
