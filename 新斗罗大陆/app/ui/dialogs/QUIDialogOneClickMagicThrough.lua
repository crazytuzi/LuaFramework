-- @Author: dsl
-- @Date:   2020-05-22

local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogOneClickMagicThrough = class("QUIDialogOneClickMagicThrough", QUIDialog)

local QNavigationController = import("...controllers.QNavigationController")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QUIViewController = import("..QUIViewController")
local QUIWidgetMasterCell = import("..widgets.QUIWidgetMasterCell")
local QUIDialogHeroEquipmentDetail = import("..dialogs.QUIDialogHeroEquipmentDetail")
local QUIWidgetMasterPropClient = import("..widgets.QUIWidgetMasterPropClient")
local QQuickWay = import("...utils.QQuickWay")
local QUIWidgetAnimationPlayer = import("..widgets.QUIWidgetAnimationPlayer")
local QUIWidgetFcaAnimation = import("..widgets.actorDisplay.QUIWidgetFcaAnimation")

function QUIDialogOneClickMagicThrough:ctor(options)
	local ccbFile = "ccb/Dialog_suit_equip_strengthen.ccbi"
    local callBacks = {
		{ccbCallbackName = "onTriggerClose", callback = handler(self, self._onTriggerClose)},
		{ccbCallbackName = "onTriggerSelect", callback = handler(self, self._onTriggerSelect)},
		{ccbCallbackName = "onTriggerStrengthen", callback = handler(self, self._onTriggerStrengthen)},
    }
    QUIDialogOneClickMagicThrough.super.ctor(self, ccbFile, callBacks, options)
    self.isAnimation = true

	-- cc.GameObject.extend(self)
	-- self:addComponent("components.behavior.EventProtocol"):exportMethods()

	if options then
		self._selectDefault = true
		self._masterType = options.masterType
		self._actorId = options.actorId
		self._isPopParentDialog = options.isPopParentDialog or false
	end

	self._ccbOwner.frame_tf_title:setString("仙品升级")

	self._equipBox = {}
	self._currMasterInfo = {}
	self._nextMasterInfo = {}
	self.offersetLevel = 1
	self._isStrengthenMax = app:getUserOperateRecord():getMagicOneClickStrengthen() or false

	self._ccbOwner.sp_select_2:setVisible(self._isStrengthenMax)
	
	self._canBeStrEngth = true
    if options then
    	self._callBack = options.callBack
    end 
    self.oneTimeStrengthenLevel = 0   --通知服务端强化到的最终等级

    self.heroUIModel = remote.herosUtil:getUIHeroByID(self._actorId)

	self.allWearNeedMoney = 0

	self:restAll()
end

function QUIDialogOneClickMagicThrough:restAll()

	self._ccbOwner.node_master:removeAllChildren()
end

function QUIDialogOneClickMagicThrough:viewDidAppear()
	QUIDialogOneClickMagicThrough.super.viewDidAppear(self)

	self:addBackEvent(true)
 	self:initInfo()
end

function QUIDialogOneClickMagicThrough:initInfo()

	self._masterType = self.heroUIModel.MAGICHERB_UPLEVEL_MASTER

    self.heroUIModel = remote.herosUtil:getUIHeroByID(self._actorId)
	self._masterLevel = self.heroUIModel:getMasterLevelByType(self._masterType)

	self.maxStrengthenLevel = remote.user.level * 2

	if self._isStrengthenMax then
		self.offersetLevel = math.floor(self.maxStrengthenLevel / 10) - self._masterLevel
		self.oneTimeStrengthenLevel = self.maxStrengthenLevel
	else
		self.offersetLevel = 1
		self.oneTimeStrengthenLevel = (self._masterLevel+1)*10
	end

	self:checkNeedMoney()

	self._currMasterInfo, self._nextMasterInfo, self._isMax = self.heroUIModel:getStrengthenMagicByMasterLevel(self.offersetLevel)
	if #self._nextMasterInfo == 0 then
		self._nextMasterInfo = self._currMasterInfo
	end

	self:setBoxInfos()
	self:setPropInfo()
end

function QUIDialogOneClickMagicThrough:viewWillDisappear()
  	QUIDialogOneClickMagicThrough.super.viewWillDisappear(self)

	self:removeBackEvent()

	if self._strengthenScheduler ~= nil then
		scheduler.unscheduleGlobal(self._strengthenScheduler)
		self._strengthenScheduler = nil
	end
end

function QUIDialogOneClickMagicThrough:getMagicUpLevelById(magicHerbId, magicHerbLevel,needLevel)
	if needLevel <= 0 then
		return 0,nil
	end
	local startLevel = magicHerbLevel + 1
	local count,id = 0,nil
	for i = startLevel, magicHerbLevel + needLevel, 1 do
		local enchantConfig = remote.magicHerb:getMagicHerbUpLevelConfigByIdAndLevel(magicHerbId, i)
		if enchantConfig then
			local tbl = string.split(enchantConfig.consum, "^")
			count = count + tonumber(tbl[2])
			id = tonumber(tbl[1])
		end
	end
	return count,id
end

function QUIDialogOneClickMagicThrough:checkNeedMoney()

	self.allWearNeedMoney = 0
	local teamMaxLevel = remote.user.level * 2
	self.itemId = nil
	local untilLevel = 0

	local startMasterLevel,nextMasterLevel = self._masterLevel + 1, self._masterLevel + self.offersetLevel
	if nextMasterLevel > self.maxStrengthenLevel/10 then
		nextMasterLevel = self.maxStrengthenLevel/10
	end

	local canLevelUp,numLess = false,false
	local itemNum = 0
	local itemName = ""
	for index = startMasterLevel,nextMasterLevel do
		local magicToLevel = index * 10
		local canUp = false
		local levelMoney = 0
		for i = 1,3 do
			local wearedInfo = self.heroUIModel:getMagicHerbWearedInfoByPos(i)
	
			if not wearedInfo then break end
			local magicHerbItemInfo = remote.magicHerb:getMaigcHerbItemBySid(wearedInfo.sid)
			if magicHerbItemInfo then
				local magicHerbLevel = magicHerbItemInfo.level
				local magicHerbId = magicHerbItemInfo.itemId
				local needLevel = 1
				if magicHerbLevel < magicToLevel then
					needLevel = magicToLevel - magicHerbLevel
					if needLevel <= 0 then
						needLevel = 0
					end
					local curMoney,itemIdT = self:getMagicUpLevelById(magicHerbId, magicHerbLevel,needLevel)
					if itemIdT then
						self.itemId = itemIdT
					end
					levelMoney = levelMoney + curMoney
					canUp = true
				end
			end
		end

		if self.itemId then
			itemNum = remote.items:getItemsNumByID(self.itemId) or 0
	        local itemConfig = db:getItemByID(self.itemId)
	        if remote.items:getWalletByType(itemConfig.type) then
	            itemName = itemConfig.nativeName
	        else
	            itemName = itemConfig.name
	        end
		end
		if canUp then
			if levelMoney <= itemNum then
				canLevelUp = true
				self.offersetLevel = index - self._masterLevel
				self.oneTimeStrengthenLevel = magicToLevel
				self.allWearNeedMoney = levelMoney
			else
				numLess = true
				break
			end
		else
			break
		end
	end

	if canLevelUp then
		local num,unit = q.convertLargerNumber(self.allWearNeedMoney)
		local nextLevel = self.oneTimeStrengthenLevel / 10
		self._ccbOwner.tf_tips:setString("消耗"..num..(unit or "")..itemName.."将仙品升级到"..nextLevel.."级效果")
		self._canBeStrEngth = true
		self._ccbOwner.confirmText:setString("升 级")
	else
		self.offersetLevel = 1
		self.oneTimeStrengthenLevel = startMasterLevel * 10
		if numLess then
			local num,unit = q.convertLargerNumber(self.allWearNeedMoney-itemNum)
	    	-- local tfStr = "仙品升级所需" ..itemName.. "不足，还差" .. num..(unit or "") .. "，快去获取更多吧"
	    	local tfStr = "仙品升级所需" ..itemName.. "不足，快去获取更多仙草精华吧"
			self._ccbOwner.tf_tips:setString(tfStr)
			self._canBeStrEngth = false
			self._ccbOwner.confirmText:setString("确 定")
		else
			self._ccbOwner.tf_tips:setString("仙品等级达到上限，提升战队等级可提升上限")
			self._canBeStrEngth = false
			self:setButtonEnabled(false)
			self._ccbOwner.confirmText:disableOutline()
			self._ccbOwner.confirmText:setString("升 级")
		end
	end
end

function QUIDialogOneClickMagicThrough:setBoxInfos()
	if next(self._equipBox) then
		for i = 1, #self._equipBox, 1 do
			self._equipBox[i]:removeFromParent()
			self._equipBox[i] = nil
		end
	end

	for i = 1, #self._equipBox, 1 do
		local equipmentInfo = self.heroUIModel:getEquipmentInfoByPos(self._equipBox[i]:getType())
		local itemInfo = QStaticDatabase:sharedDatabase():getItemByID(equipmentInfo.info.itemId)
		self._equipBox[i]:setItemInfo(itemInfo, equipmentInfo, self._nextMasterInfo, self._masterType)
		self._equipBox[i]:addEventListener(QUIWidgetMasterCell.EVENT_CLICK_BOX, handler(self, self._eventClickBox))
	end

	for i = 1, 3 do
		self._equipBox[i] = QUIWidgetMasterCell.new()
		self._ccbOwner["box_node"..i]:addChild(self._equipBox[i])
		local magicHerbWearedInfo = self.heroUIModel:getMagicHerbWearedInfoByPos(i)
		if magicHerbWearedInfo then
			local itemInfo = remote.magicHerb:getMaigcHerbItemBySid(magicHerbWearedInfo.sid)
			local itemConfig = db:getItemByID(itemInfo.itemId)
			self._equipBox[i]:setType(i)
			local canStrengthen = false 
			if magicHerbWearedInfo.level < self.oneTimeStrengthenLevel and magicHerbWearedInfo.level < self.maxStrengthenLevel then
				canStrengthen = true
			end			
			self._equipBox[i]:setItemInfo(itemConfig, magicHerbWearedInfo, self._nextMasterInfo, self._masterType ,canStrengthen)
		else
			self._equipBox[i]:showEmpty(self._nextMasterInfo, self._masterType)
		end
		self._equipBox[i]:addEventListener(QUIWidgetMasterCell.EVENT_CLICK_BOX, handler(self, self._eventClickBox))
	end

end


function QUIDialogOneClickMagicThrough:setPropInfo()

	if self._propClient == nil then
		self._propClient = QUIWidgetMasterPropClient.new()
		self._ccbOwner.node_master:addChild(self._propClient)
	end

	self._propClient:setClientInfo(self._masterLevel, self._isMax, self._currMasterInfo, self._nextMasterInfo, self._masterType,true)
end 

function QUIDialogOneClickMagicThrough:_eventClickBox(event)

	if event.itemId == nil then
		app.tip:floatTip("请先携带仙品")
		return
	end
	self:playEffectOut()
	-- self:viewAnimationOutHandler()

	if self._isPopParentDialog then
		app:getNavigationManager():popViewController(app.mainUILayer, QNavigationController.POP_TOP_CONTROLLER)
	end

	-- app:getNavigationManager():pushViewController(app.mainUILayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogMagicHerbDetail", 
 --        options = {heroList = self._heros, heroPos = self._pos, pos = event.euqipPos, parentOptions = self._parentOptions, tabType = QUIDialogMagicHerbDetail.TAB_UPLEVEL}})

end

function QUIDialogOneClickMagicThrough:_onTriggerSelect()
	local btnState = self._ccbOwner.sp_select_2:isVisible()

	self._ccbOwner.sp_select_2:setVisible(not btnState)
	self._isStrengthenMax = not btnState
	app:getUserOperateRecord():setMagicOneClickStrengthen(not btnState)

	self:initInfo()
end

function QUIDialogOneClickMagicThrough:_onTriggerStrengthen(event)
	if q.buttonEventShadow(event, self._ccbOwner.bt_confirm) == false then return end

	if not self._canBeStrEngth then
		if self.itemId then
			QQuickWay:addQuickWay(QQuickWay.ITEM_DROP_WAY, self.itemId)
		else
			print("配置出错！！！")
		end
		return
	end

	local itemIds = {}
	local oldAllLevel = 0
	local oldEquipConfig = {}

	for i = 1, #self._equipBox, 1 do
		local wearedInfo = self.heroUIModel:getMagicHerbWearedInfoByPos(i)
		local magicHerbItemInfo = nil
		if wearedInfo then
			magicHerbItemInfo = remote.magicHerb:getMaigcHerbItemBySid(wearedInfo.sid)
		end
		if magicHerbItemInfo then
			if magicHerbItemInfo.level < self.oneTimeStrengthenLevel then

				local _curEnchantConfig = remote.magicHerb:getMagicHerbUpLevelConfigByIdAndLevel( magicHerbItemInfo.itemId, magicHerbItemInfo.level )
				oldAllLevel = oldAllLevel + magicHerbItemInfo.level
				table.insert(oldEquipConfig,{oldConfig=_curEnchantConfig,sid = wearedInfo.sid})
			end
		end
	end

	local oldMasterLevel = self._masterLevel
	self._animationEnded = false
	self:setButtonEnabled(false)
	remote.magicHerb:magicHerbQuickEnhanceRequest(self._actorId, self._isStrengthenMax,function(data)
		if self.class ~= nil then
			local critNum = data.enhanceEquipmentCritCount or 0--暴击

			local enhanceEquipmentTotalCount = data.enhanceEquipmentTotalCount or 0
			local newLevel = 0
			local attributeInfo = {}
			local index = 1

			for _,v in pairs(oldEquipConfig) do
				local oldEnchantConfig = v.oldConfig
				local sid = v.sid

				local magicHerbItemInfo = remote.magicHerb:getMaigcHerbItemBySid(sid)
				if magicHerbItemInfo then
					local curEnchantConfig = remote.magicHerb:getMagicHerbUpLevelConfigByIdAndLevel( magicHerbItemInfo.itemId, magicHerbItemInfo.level )
					newLevel = newLevel + magicHerbItemInfo.level

					if curEnchantConfig.hp_value then -- hp_percent
						attributeInfo[index] = {name = "生   命",value = curEnchantConfig.hp_value - (oldEnchantConfig.hp_value or 0)}
						index = index + 1
					end
					if curEnchantConfig.attack_value then  -- attack_percent
						attributeInfo[index] = {name = "攻   击",value = curEnchantConfig.attack_value - (oldEnchantConfig.attack_value or 0 )}
						index = index + 1
					end
					if curEnchantConfig.armor_physical then  -- armor_physical_percent
						attributeInfo[index] = {name = "物理防御",value = curEnchantConfig.armor_physical - (oldEnchantConfig.armor_physical or 0)}
						index = index + 1
					end
					if curEnchantConfig.armor_magic then -- armor_magic_percent
						attributeInfo[index] = {name = "法术防御",value = curEnchantConfig.armor_magic - (oldEnchantConfig.armor_magic or 0 )}
						index = index + 1
					end	
				end
			end

			local nowMasterLevel = self.heroUIModel:getMasterLevelByType(self._masterType)
			local masterUpGrade = nowMasterLevel > self._masterLevel and nowMasterLevel or nil 
			local showData = {critNum = critNum,changeLevel = newLevel - oldAllLevel - critNum ,masterUpGrade = masterUpGrade,masterType = "enhance_master_",attributeInfo=attributeInfo}
			self:strengthenSucceedEffect(showData)

			self:showStrengThenEffect()
			-- remote.user:addPropNumForKey("todayEquipEnhanceCount", enhanceEquipmentTotalCount)
		end
	end, function()
		if self.class ~= nil then
			self:setButtonEnabled(true)
		end
	end)

end

function QUIDialogOneClickMagicThrough:showStrengThenEffect()
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

function QUIDialogOneClickMagicThrough:strengthenSucceedEffect(data)
	self._ccbOwner.strenAnimationNode:removeAllChildren()
	local strengthenEffectShow = QUIWidgetAnimationPlayer.new()
	self._ccbOwner.strenAnimationNode:addChild(strengthenEffectShow)
	strengthenEffectShow:setPosition(ccp(0, 100))
	strengthenEffectShow:playAnimation("ccb/effects/BaojiOneTime.ccbi", function(ccbOwner)
		ccbOwner.level:setVisible(false)
		ccbOwner.node_critcrit:setVisible(false)
		
		ccbOwner.tf_name:setString("升级成功")
		-- ccbOwner.tf_name:setString("连续升级"..(data.changeLevel + data.critNum or 1).."次")
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
	-- if data.masterUpGrade ~= nil then
	-- 	app.master:createMasterLayer()
	-- end
	-- self._strengthenScheduler = scheduler.performWithDelayGlobal(function()
	-- 		if data.masterUpGrade then
	-- 			app.master:upGradeMaster(data.masterUpGrade, data.masterType, self._actorId)
	-- 			app.master:cleanMasterLayer()
	-- 		end
	-- 	end, 0.3)
end

function QUIDialogOneClickMagicThrough:setButtonEnabled(state)
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

function QUIDialogOneClickMagicThrough:setLabelScale(node, scale)
	local ccArray = CCArray:create()
	ccArray:addObject(CCScaleTo:create(0.1, 1.2))
	ccArray:addObject(CCScaleTo:create(0.1, 1))
	node:runAction(CCSequence:create(ccArray))
end 

function QUIDialogOneClickMagicThrough:_backClickHandler()
  	app.sound:playSound("common_close")
	self:playEffectOut()
end

function QUIDialogOneClickMagicThrough:_onTriggerClose(event)
	if q.buttonEventShadow(event,self._ccbOwner.btn_close) == false then return end
  	app.sound:playSound("common_close")
	self:playEffectOut()
end

function QUIDialogOneClickMagicThrough:viewAnimationOutHandler()
	local callback = self._callBack

	self:popSelf()

	if callback then
		callback()
	end
end

return QUIDialogOneClickMagicThrough
