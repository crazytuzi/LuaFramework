-- @Author: liaoxianbo
-- @Date:   2019-09-18 14:30:16
-- @Last Modified by:   xurui
-- @Last Modified time: 2019-11-27 18:44:45
local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogOneClickGemStoneStrengthen = class("QUIDialogOneClickGemStoneStrengthen", QUIDialog)

local QNavigationController = import("...controllers.QNavigationController")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QUIViewController = import("..QUIViewController")
local QUIWidgetMasterCell = import("..widgets.QUIWidgetMasterCell")

local QUIDialogHeroEquipmentDetail = import("..dialogs.QUIDialogHeroEquipmentDetail")
local QUIWidgetMasterPropClient = import("..widgets.QUIWidgetMasterPropClient")
local QQuickWay = import("...utils.QQuickWay")
local QUIWidgetAnimationPlayer = import("..widgets.QUIWidgetAnimationPlayer")
local QUIWidgetFcaAnimation = import("..widgets.actorDisplay.QUIWidgetFcaAnimation")

function QUIDialogOneClickGemStoneStrengthen:ctor(options)
	local ccbFile = "ccb/Dialog_suit_equip_strengthen.ccbi"
    local callBacks = {
		{ccbCallbackName = "onTriggerClose", callback = handler(self, self._onTriggerClose)},
		{ccbCallbackName = "onTriggerSelect", callback = handler(self, self._onTriggerSelect)},
		{ccbCallbackName = "onTriggerStrengthen", callback = handler(self, self._onTriggerStrengthen)},
    }
    QUIDialogOneClickGemStoneStrengthen.super.ctor(self, ccbFile, callBacks, options)
    self.isAnimation = true

	cc.GameObject.extend(self)
	self:addComponent("components.behavior.EventProtocol"):exportMethods()

	self._gemstoneBox = {}
	self._currMasterInfo = {}
	self._nextMasterInfo = {}
	self.offersetLevel = 1
	self._isStrengthenMax = app:getUserOperateRecord():getGemstoneOneClickStrengthen() or false
	self._ccbOwner.sp_select_2:setVisible(self._isStrengthenMax)
	self._ccbOwner.frame_tf_title:setString("魂骨强化")
    if options then
    	self._callBack = options.callBack
		self._masterType = options.masterType
		self._actorId = options.actorId
    end

    self.allWearNeedMoney = 0
    self.allGemstoneEnergy = 0

    self.maxStrengthenLevel = remote.user.level * 2

    self:restAll()
end

function QUIDialogOneClickGemStoneStrengthen:restAll()

	self._ccbOwner.node_master:removeAllChildren()
end

function QUIDialogOneClickGemStoneStrengthen:viewDidAppear()
	QUIDialogOneClickGemStoneStrengthen.super.viewDidAppear(self)

	self:addBackEvent(true)

	self:initInfo()
end

function QUIDialogOneClickGemStoneStrengthen:countNeedMoney(gemstoneQuality, startLevel, maxLevel)
	local configs = QStaticDatabase:sharedDatabase():getGemstoneStrengthByQuality(gemstoneQuality)
	local needResouce = {money = 0, gemstoneEnergy = 0}
	for _,config in ipairs(configs) do
		if config.enhance_level > startLevel and config.enhance_level <= maxLevel then
			needResouce.money = needResouce.money + config.money
			needResouce.gemstoneEnergy = needResouce.gemstoneEnergy + config.strengthen_stone
		end
	end
	return needResouce
end


function QUIDialogOneClickGemStoneStrengthen:checkNeedMoney()
	local strengthLevel = 0
	self.allWearNeedMoney = 0
	self.allGemstoneEnergy = 0
	if self._isStrengthenMax then
		strengthLevel = self.maxStrengthenLevel - self.maxStrengthenLevel % 10
	else
		strengthLevel = (self._masterLevel+1)*10
	end

	for i = 1, 4 do
		local genstoneInfo = self.heroUIModel:getGemstoneInfoByPos(i)
		local itemConfig = QStaticDatabase:sharedDatabase():getItemByID(genstoneInfo.info.itemId)

		local needResouce = self:countNeedMoney(itemConfig.gemstone_quality, genstoneInfo.info.level, strengthLevel)
		self.allWearNeedMoney = self.allWearNeedMoney + needResouce.money or 0
		self.allGemstoneEnergy = self.allGemstoneEnergy + needResouce.gemstoneEnergy or 0
	end

	if self.allWearNeedMoney > remote.user.money then
		self._ccbOwner.tf_tips:setString("魂骨强化所需金魂币不足，快去获取更多金魂币吧")
		self._canBeStrEngth = false
		self._ccbOwner.confirmText:setString("确 定")
		self._needType = "money"
	elseif self.allGemstoneEnergy > remote.user.gemstoneEnergy then
		self._ccbOwner.tf_tips:setString("魂骨强化所需魂骨能量不足，快去获取更多魂骨能量吧")
		self._needType = "money"
		self._canBeStrEngth = false
		self._ccbOwner.confirmText:setString("确 定")
		self._needType = "gemstoneEnergy"		
	elseif self.allWearNeedMoney <= 0 then
		self._ccbOwner.tf_tips:setString("魂骨等级达到上限，提升战队等级可提升上限")
		self._canBeStrEngth = false
		self:setButtonEnabled(false)
		self._ccbOwner.confirmText:setString("确 定")
		self._ccbOwner.confirmText:disableOutline()
	else
		local untilLevel = self.offersetLevel + self._masterLevel
		local num,unit = q.convertLargerNumber(self.allWearNeedMoney)
		local num1,unit1 = q.convertLargerNumber(self.allGemstoneEnergy)
		self._ccbOwner.tf_tips:setString("最大消耗"..num..(unit or "").."金魂币,"..num1..(unit1 or "").."魂骨能量将魂骨强化到"..untilLevel.."级效果")
		self._canBeStrEngth = true
		self._ccbOwner.confirmText:setString("强 化")
	end
end

function QUIDialogOneClickGemStoneStrengthen:setButtonEnabled(state)
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

function QUIDialogOneClickGemStoneStrengthen:initInfo( )
    self.heroUIModel = remote.herosUtil:getUIHeroByID(self._actorId)
	self._masterLevel = self.heroUIModel:getMasterLevelByType(self._masterType)

	if self._isStrengthenMax then
		self.offersetLevel = math.floor(self.maxStrengthenLevel / 10) - self._masterLevel
	else
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


function QUIDialogOneClickGemStoneStrengthen:setBoxInfos()
	if next(self._gemstoneBox) then
		for i = 1, #self._gemstoneBox, 1 do
			self._gemstoneBox[i]:removeFromParent()
			self._gemstoneBox[i] = nil
		end
	end

	for i = 1, 4 do
		self._gemstoneBox[i] = QUIWidgetMasterCell.new()
		self._ccbOwner["box_node"..i]:addChild(self._gemstoneBox[i])
		local genstoneInfo = self.heroUIModel:getGemstoneInfoByPos(i)
		if genstoneInfo.info ~= nil then
			local itemInfo = QStaticDatabase:sharedDatabase():getItemByID(genstoneInfo.info.itemId)

			local canStrengthen = false 
			if genstoneInfo.info.level < self.oneTimeStrengthenLevel and genstoneInfo.info.level < self.maxStrengthenLevel then
				canStrengthen = true
			end

			self._gemstoneBox[i]:setType(i)
			self._gemstoneBox[i]:setItemInfo(itemInfo, genstoneInfo, self._nextMasterInfo, self._masterType,canStrengthen)
		else
			self._gemstoneBox[i]:showEmpty(self._nextMasterInfo)
		end
		self._gemstoneBox[i]:addEventListener(QUIWidgetMasterCell.EVENT_CLICK_BOX, handler(self, self._eventClickBox))
	end
end

function QUIDialogOneClickGemStoneStrengthen:setPropInfo()
	if self._propClient == nil then
		self._propClient = QUIWidgetMasterPropClient.new()
		self._ccbOwner.node_master:addChild(self._propClient)
	end
	self._propClient:setClientInfo(self._masterLevel, self._isMax, self._currMasterInfo, self._nextMasterInfo, self._masterType,true)

end 

function QUIDialogOneClickGemStoneStrengthen:viewWillDisappear()
  	QUIDialogOneClickGemStoneStrengthen.super.viewWillDisappear(self)

	self:removeBackEvent()
end

function QUIDialogOneClickGemStoneStrengthen:_onTriggerSelect()
	local btnState = self._ccbOwner.sp_select_2:isVisible()

	self._ccbOwner.sp_select_2:setVisible(not btnState)
	self._isStrengthenMax = not btnState
	app:getUserOperateRecord():setGemstoneOneClickStrengthen(not btnState)

	self:initInfo()
end

function QUIDialogOneClickGemStoneStrengthen:_onTriggerStrengthen(event)
	if q.buttonEventShadow(event, self._ccbOwner.bt_confirm) == false then return end

	if not self._canBeStrEngth then 
		if self._needType == "money" then
			QQuickWay:addQuickWay(QQuickWay.RESOUCE_DROP_WAY, ITEM_TYPE.MONEY)
		else
			QQuickWay:addQuickWay(QQuickWay.RESOUCE_DROP_WAY, ITEM_TYPE.GEMSTONE_ENERGY)
		end
		return
	end

	local gemstonePosition = {}
	local oldAllLevel = 0
	local oldEquipConfig = {}
	for i = 1,4 do
		local genstoneInfo = self.heroUIModel:getGemstoneInfoByPos(i)
		if genstoneInfo.info.level < self.oneTimeStrengthenLevel then
			table.insert(gemstonePosition,genstoneInfo.info.position)
			oldAllLevel = oldAllLevel + genstoneInfo.info.level
			local itemConfig = QStaticDatabase:sharedDatabase():getItemByID(genstoneInfo.info.itemId)
			local oldConfig = QStaticDatabase:sharedDatabase():getTotalEnhancePropByLevel(itemConfig.enhance_data, genstoneInfo.info.level)
			table.insert(oldEquipConfig,{oldConfig=oldConfig,itemId = genstoneInfo.info.itemId})
		end
	end
	local oldMasterLevel = self._masterLevel
	self._animationEnded = false
	self:setButtonEnabled(false)

	remote.gemstone:gemstoneOneKeyEnhanceRequest(self._actorId, self._isStrengthenMax,function(data)
		if self.class ~= nil then
			local critNum = data.enhanceEquipmentCritCount --暴击
			-- local enhanceEquipmentTotalCount = data.enhanceEquipmentTotalCount or 0

			local newLevel = 0
			local attributeInfo = {}
			local index = 1
			for _,v in pairs(gemstonePosition)  do
				local equipment = self.heroUIModel:getGemstoneInfoByPos(v)
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
			local masterUpGrade = nowMasterLevel > self._masterLevel and nowMasterLevel or nil 
			local showData = {critNum = critNum,changeLevel = newLevel - oldAllLevel - critNum ,masterUpGrade = masterUpGrade,masterType = self._masterType,attributeInfo=attributeInfo}
			self:strengthenSucceedEffect(showData)

			self:showStrengThenEffect()

		end
	end, function()
		self:setButtonEnabled(true)
	end)

end

function QUIDialogOneClickGemStoneStrengthen:showStrengThenEffect()
	for i = 1, 4 do
		local fcaAnimation = QUIWidgetFcaAnimation.new("fca/yijianqianghua_1", "res")
		fcaAnimation:playAnimation("animation", false)
		fcaAnimation:setEndCallback(function( )
			fcaAnimation:removeFromParent()
		end)
		fcaAnimation:setScale(1/0.78)
		self._ccbOwner["box_node"..i]:addChild(fcaAnimation)
	end
end

function QUIDialogOneClickGemStoneStrengthen:strengthenSucceedEffect(data)
	self._ccbOwner.strenAnimationNode:removeAllChildren()
	local strengthenEffectShow = QUIWidgetAnimationPlayer.new()
	self._ccbOwner.strenAnimationNode:addChild(strengthenEffectShow)
	strengthenEffectShow:setPosition(ccp(0, 100))
	strengthenEffectShow:playAnimation("ccb/effects/BaojiOneTime.ccbi", function(ccbOwner)
		ccbOwner.level:setVisible(false)
		ccbOwner.tf_name:setString("连续强化"..(data.changeLevel + data.critNum or 1).."次 （暴击 "..(data.critNum or 1).." 次）")
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
					app.master:upGradeMaster(data.masterUpGrade, data.masterType, self._actorId)
					app.master:cleanMasterLayer()
				end
			end, 0.3)
end

function QUIDialogOneClickGemStoneStrengthen:_eventClickBox(event)

	self:viewAnimationOutHandler()

	if self._isPopParentDialog then
		app:getNavigationManager():popViewController(app.mainUILayer, QNavigationController.POP_TOP_CONTROLLER)
	end

	local initTab = QUIDialogHeroEquipmentDetail.TAB_STRONG
  	app:getNavigationManager():pushViewController(app.mainUILayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogHeroGemstoneDetail", 
        options = {itemId= event.itemId, equipmentPos = event.euqipPos, heros = self._heros, pos = self._pos, parentOptions = self._parentOptions,
         initTab = initTab, isQuickWay = self._isQuickWay}})
end

function QUIDialogOneClickGemStoneStrengthen:_backClickHandler()
  	app.sound:playSound("common_close")
	self:playEffectOut()
end

function QUIDialogOneClickGemStoneStrengthen:_onTriggerClose(event)
	if q.buttonEventShadow(event,self._ccbOwner.btn_close) == false then return end
  	app.sound:playSound("common_close")
	self:playEffectOut()
end

function QUIDialogOneClickGemStoneStrengthen:viewAnimationOutHandler()
	local callback = self._callBack

	self:popSelf()

	if callback then
		callback()
	end
end

return QUIDialogOneClickGemStoneStrengthen
