-- @Author: liaoxianbo
-- @Date:   2019-07-25 11:24:53
-- @Last Modified by:   xurui
-- @Last Modified time: 2019-11-27 18:44:02
local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogOneClickEquipStrengthen = class("QUIDialogOneClickEquipStrengthen", QUIDialog)

local QNavigationController = import("...controllers.QNavigationController")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QUIViewController = import("..QUIViewController")
local QUIWidgetMasterCell = import("..widgets.QUIWidgetMasterCell")
local QUIDialogHeroEquipmentDetail = import("..dialogs.QUIDialogHeroEquipmentDetail")
local QUIWidgetMasterPropClient = import("..widgets.QUIWidgetMasterPropClient")
local QQuickWay = import("...utils.QQuickWay")
local QUIWidgetAnimationPlayer = import("..widgets.QUIWidgetAnimationPlayer")
local QUIWidgetFcaAnimation = import("..widgets.actorDisplay.QUIWidgetFcaAnimation")

function QUIDialogOneClickEquipStrengthen:ctor(options)
	local ccbFile = "ccb/Dialog_suit_equip_strengthen.ccbi"
    local callBacks = {
		{ccbCallbackName = "onTriggerClose", callback = handler(self, self._onTriggerClose)},
		{ccbCallbackName = "onTriggerSelect", callback = handler(self, self._onTriggerSelect)},
		{ccbCallbackName = "onTriggerStrengthen", callback = handler(self, self._onTriggerStrengthen)},
    }
    QUIDialogOneClickEquipStrengthen.super.ctor(self, ccbFile, callBacks, options)
    self.isAnimation = true

	cc.GameObject.extend(self)
	self:addComponent("components.behavior.EventProtocol"):exportMethods()

	if options then
		self._selectDefault = true
		self._masterType = options.masterType
		self._actorId = options.actorId
		self._isPopParentDialog = options.isPopParentDialog or false
	end

	self._ccbOwner.frame_tf_title:setString("装备强化")

	self._equipBox = {}
	self._currMasterInfo = {}
	self._nextMasterInfo = {}
	self.offersetLevel = 1
	self._isStrengthenMax = app:getUserOperateRecord():getOneClickStrengthen() or false

	self._ccbOwner.sp_select_2:setVisible(self._isStrengthenMax)
	
	self._canBeStrEngth = true
    if options then
    	self._callBack = options.callBack
    end 
    self.oneTimeStrengthenLevel = 0   --通知服务端强化到的最终等级
    self.heroUIModel = remote.herosUtil:getUIHeroByID(self._actorId)
	self._masterLevel = self.heroUIModel:getMasterLevelByType(self._masterType)
	self.maxStrengthenLevel = remote.user.level * 2 --remote.herosUtil:getEquipmentStrengthenMaxLevel()

	self.allWearNeedMoney = 0

	self:restAll()
end

function QUIDialogOneClickEquipStrengthen:restAll()

	self._ccbOwner.node_master:removeAllChildren()
end

function QUIDialogOneClickEquipStrengthen:viewDidAppear()
	QUIDialogOneClickEquipStrengthen.super.viewDidAppear(self)

	self:addBackEvent(true)
    self:initInfo()
end

function QUIDialogOneClickEquipStrengthen:viewWillDisappear()
  	QUIDialogOneClickEquipStrengthen.super.viewWillDisappear(self)

	self:removeBackEvent()

	if self._strengthenScheduler ~= nil then
		scheduler.unscheduleGlobal(self._strengthenScheduler)
		self._strengthenScheduler = nil
	end
end

--计算一个装备强化到指定等级需要的钱
function QUIDialogOneClickEquipStrengthen:getOneWearNeedMoney(itemId, level)
	local result = 0
	local equipment = remote.herosUtil:getWearByItem(self._actorId, itemId)
	if equipment == nil then return end
	local maxlevel = level - equipment.level
	print("maxlevel=",maxlevel)
	local level = 0
	for i = equipment.level, (equipment.level + maxlevel - 1), 1 do
		local money = QStaticDatabase:sharedDatabase():getStrengthenInfoByEquLevel(i + 1)
		if money ~= nil and i <= (self.maxStrengthenLevel - 1) then
			result = result + money
			level = i
			-- if result > remote.user.money then
			-- 	if (result - money) == 0 then
			-- 		return result, level + 1	
			-- 	end
			-- 	return result - money, level
			-- end
		else
			return result, level + 1
		end
	end
	return result, level + 1
end

function QUIDialogOneClickEquipStrengthen:checkNeedMoney()
	local strengthLevel = 0
	self.allWearNeedMoney = 0

	if self._isStrengthenMax then
		strengthLevel = self.maxStrengthenLevel
	else
		strengthLevel = (self._masterLevel+1)*10
	end

	for i = 1, #self._equipBox, 1 do
		local equipmentInfo = self.heroUIModel:getEquipmentInfoByPos(self._equipBox[i]:getType())
		-- local itemInfo = QStaticDatabase:sharedDatabase():getItemByID(equipmentInfo.info.itemId)
		local wearNeedMoney, onWearLevel = self:getOneWearNeedMoney(equipmentInfo.info.itemId, strengthLevel)
		print("消耗金币统计")
		print("onWearLevel=",onWearLevel)
		print("wearNeedMoney=",wearNeedMoney)
		self.allWearNeedMoney = self.allWearNeedMoney + wearNeedMoney
	end	


	if self.allWearNeedMoney > remote.user.money then
		self._ccbOwner.tf_tips:setString("装备强化所需金魂币不足，快去获取更多金魂币吧")
		self._canBeStrEngth = false
		self._ccbOwner.confirmText:setString("确 定")
	elseif self.allWearNeedMoney <= 0 then
		self._ccbOwner.tf_tips:setString("装备等级达到上限，提升战队等级可提升上限")
		self._canBeStrEngth = false
		self:setButtonEnabled(false)
		self._ccbOwner.confirmText:disableOutline()
	else
		local untilLevel = self.offersetLevel + self._masterLevel
		local num,unit = q.convertLargerNumber(self.allWearNeedMoney)
		self._ccbOwner.tf_tips:setString("最大消耗"..num..(unit or "").."金魂币将装备强化到"..untilLevel.."级效果")
		self._canBeStrEngth = true
	end
end
function QUIDialogOneClickEquipStrengthen:initInfo()

    self.heroUIModel = remote.herosUtil:getUIHeroByID(self._actorId)
	self._masterLevel = self.heroUIModel:getMasterLevelByType(self._masterType)

	if self._isStrengthenMax then
		self.offersetLevel = math.floor(self.maxStrengthenLevel / 10) - self._masterLevel
	else
		self.offersetLevel = 1
	end

	self._currMasterInfo, self._nextMasterInfo, self._isMax = QStaticDatabase:sharedDatabase():getStrengthenMasterByMasterLevel(self._masterType, self._masterLevel,self.offersetLevel)

	if self._isStrengthenMax then
		self.oneTimeStrengthenLevel = self.maxStrengthenLevel
	else
		self.oneTimeStrengthenLevel = (self._masterLevel+1)*10
	end

	self:setBoxInfos()
	self:setPropInfo()

	self:checkNeedMoney()
end

function QUIDialogOneClickEquipStrengthen:setBoxInfos()
	if next(self._equipBox) then
		for i = 1, #self._equipBox, 1 do
			self._equipBox[i]:removeFromParent()
			self._equipBox[i] = nil
		end
	end

	for i = 1, 4 do
		self._equipBox[i] = QUIWidgetMasterCell.new()
		self._ccbOwner["box_node"..i]:removeAllChildren()
		self._ccbOwner["box_node"..i]:addChild(self._equipBox[i])
	end

	self._equipBox[1]:setType(EQUIPMENT_TYPE.WEAPON)
	self._equipBox[2]:setType(EQUIPMENT_TYPE.BRACELET)
	self._equipBox[3]:setType(EQUIPMENT_TYPE.CLOTHES)
	self._equipBox[4]:setType(EQUIPMENT_TYPE.SHOES)

	for i = 1, #self._equipBox, 1 do
		local equipmentInfo = self.heroUIModel:getEquipmentInfoByPos(self._equipBox[i]:getType())
		local itemInfo = QStaticDatabase:sharedDatabase():getItemByID(equipmentInfo.info.itemId)
		local canStrengthen = false 
		if equipmentInfo.info.level < self.oneTimeStrengthenLevel and equipmentInfo.info.level < self.maxStrengthenLevel then
			canStrengthen = true
		end
		self._equipBox[i]:setItemInfo(itemInfo, equipmentInfo, self._nextMasterInfo, self._masterType,canStrengthen)
		self._equipBox[i]:addEventListener(QUIWidgetMasterCell.EVENT_CLICK_BOX, handler(self, self._eventClickBox))
	end

end


function QUIDialogOneClickEquipStrengthen:setPropInfo()
	if self._propClient == nil then
		self._propClient = QUIWidgetMasterPropClient.new()
		self._ccbOwner.node_master:addChild(self._propClient)
	end
	self._propClient:setClientInfo(self._masterLevel, self._isMax, self._currMasterInfo, self._nextMasterInfo, self._masterType,true)

end 

function QUIDialogOneClickEquipStrengthen:_eventClickBox(event)

	self:viewAnimationOutHandler()

	if self._isPopParentDialog then
		app:getNavigationManager():popViewController(app.mainUILayer, QNavigationController.POP_TOP_CONTROLLER)
	end

	local initTab = QUIDialogHeroEquipmentDetail.TAB_STRONG
  	app:getNavigationManager():pushViewController(app.mainUILayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogHeroEquipmentDetail", 
        options = {itemId= event.itemId, equipmentPos = event.euqipPos, heros = self._heros, pos = self._pos, parentOptions = self._parentOptions,
         initTab = initTab, isQuickWay = self._isQuickWay}})
end

function QUIDialogOneClickEquipStrengthen:_onTriggerSelect()
	local btnState = self._ccbOwner.sp_select_2:isVisible()

	self._ccbOwner.sp_select_2:setVisible(not btnState)
	self._isStrengthenMax = not btnState
	app:getUserOperateRecord():setOneClickStrengthen(not btnState)

	self:initInfo()
end

function QUIDialogOneClickEquipStrengthen:_onTriggerStrengthen(event)
	if q.buttonEventShadow(event, self._ccbOwner.bt_confirm) == false then return end

	if not self._canBeStrEngth then 
		QQuickWay:addQuickWay(QQuickWay.RESOUCE_DROP_WAY, ITEM_TYPE.MONEY)
		return
	end
	local itemIds = {}
	local oldAllLevel = 0
	local oldEquipConfig = {}
	for i = 1, #self._equipBox, 1 do
		local equipmentInfo = self.heroUIModel:getEquipmentInfoByPos(self._equipBox[i]:getType())
		if equipmentInfo.info.level < self.oneTimeStrengthenLevel then
			table.insert(itemIds,equipmentInfo.info.itemId)
			oldAllLevel = oldAllLevel + equipmentInfo.info.level
			local itemConfig = QStaticDatabase:sharedDatabase():getItemByID(equipmentInfo.info.itemId)
			local oldConfig = QStaticDatabase:sharedDatabase():getTotalEnhancePropByLevel(itemConfig.enhance_data, equipmentInfo.info.level)
			table.insert(oldEquipConfig,{oldConfig=oldConfig,itemId = equipmentInfo.info.itemId})
		end
	end

	local oldMasterLevel = self._masterLevel
	self._animationEnded = false
	self:setButtonEnabled(false)
	app:getClient():heroEquipmentStrengthenRequest(self._actorId, itemIds, self.oneTimeStrengthenLevel,true,function(data)
		if self.class ~= nil then
			local critNum = data.enhanceEquipmentCritCount --暴击
			local enhanceEquipmentTotalCount = data.enhanceEquipmentTotalCount or 0
			local newLevel = 0
			local attributeInfo = {}
			local index = 1
			for i,itemId in pairs(itemIds) do
				local equipment = remote.herosUtil:getWearByItem(self._actorId, itemId)
				local equipLevel = 0
				if equipment then
					equipLevel = equipment.level or 0
				end
				newLevel = newLevel + equipLevel

				for _,v in pairs(oldEquipConfig) do
					if v.itemId == itemId then
						local itemConfig = QStaticDatabase:sharedDatabase():getItemByID(itemId)
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
			local showData = {critNum = critNum,changeLevel = newLevel - oldAllLevel - critNum ,masterUpGrade = masterUpGrade,masterType = "enhance_master_",attributeInfo=attributeInfo}
			self:strengthenSucceedEffect(showData)

			self:showStrengThenEffect()

			remote.user:addPropNumForKey("todayEquipEnhanceCount", enhanceEquipmentTotalCount)
		end
	end, function()
		self:setButtonEnabled(true)
	end)

end

function QUIDialogOneClickEquipStrengthen:showStrengThenEffect()
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

function QUIDialogOneClickEquipStrengthen:strengthenSucceedEffect(data)
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

function QUIDialogOneClickEquipStrengthen:setButtonEnabled(state)
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

function QUIDialogOneClickEquipStrengthen:setLabelScale(node, scale)
	local ccArray = CCArray:create()
	ccArray:addObject(CCScaleTo:create(0.1, 1.2))
	ccArray:addObject(CCScaleTo:create(0.1, 1))
	node:runAction(CCSequence:create(ccArray))
end 

function QUIDialogOneClickEquipStrengthen:_backClickHandler()
  	app.sound:playSound("common_close")
	self:playEffectOut()
end

function QUIDialogOneClickEquipStrengthen:_onTriggerClose(event)
	if q.buttonEventShadow(event,self._ccbOwner.btn_close) == false then return end
  	app.sound:playSound("common_close")
	self:playEffectOut()
end

function QUIDialogOneClickEquipStrengthen:viewAnimationOutHandler()
	local callback = self._callBack

	self:popSelf()

	if callback then
		callback()
	end
end

return QUIDialogOneClickEquipStrengthen
