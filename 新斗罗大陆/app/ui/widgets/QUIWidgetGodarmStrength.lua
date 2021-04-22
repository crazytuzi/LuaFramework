-- @Author: liaoxianbo
-- @Date:   2019-12-25 18:53:17
-- @Last Modified by:   liaoxianbo
-- @Last Modified time: 2020-01-14 21:30:10
local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetGodarmStrength = class("QUIWidgetGodarmStrength", QUIWidget)

local QNavigationController = import("...controllers.QNavigationController")
local QUIViewController = import("..QUIViewController")
local QUIWidgetAnimationPlayer = import("..widgets.QUIWidgetAnimationPlayer")
local QUIWidgetItemsBox = import("..widgets.QUIWidgetItemsBox")
local QQuickWay = import("...utils.QQuickWay")
local QActorProp = import("...models.QActorProp")

function QUIWidgetGodarmStrength:ctor(options)
	local ccbFile = "ccb/Widget_Godarm_Strength.ccbi"
    local callBacks = {
		{ccbCallbackName = "onTriggerOneGrade", callback = handler(self, self._onTriggerOneGrade)},
		{ccbCallbackName = "onTriggerFiveGrade", callback = handler(self, self._onTriggerFiveGrade)},
		{ccbCallbackName = "onTriggerClickItem1", callback = handler(self, self._onTriggerClickItem1)},
		{ccbCallbackName = "onTriggerClickItem2", callback = handler(self, self._onTriggerClickItem2)},
		{ccbCallbackName = "onTriggerClickItem3", callback = handler(self, self._onTriggerClickItem3)},		
    }
    QUIWidgetGodarmStrength.super.ctor(self, ccbFile, callBacks, options)
  
	cc.GameObject.extend(self)
	self:addComponent("components.behavior.EventProtocol"):exportMethods()

	self._materials = remote.godarm.EXP_ITEMS
	self._parent = options.parent
end

function QUIWidgetGodarmStrength:onEnter()
end

function QUIWidgetGodarmStrength:onExit()
	if self._timeHandler ~= nil then
		scheduler.unscheduleGlobal(self._timeHandler)
		self._timeHandler = nil
	end

end

function QUIWidgetGodarmStrength:resetAll( )
	for i=1,5 do
		self._ccbOwner["node_propview_"..i]:setVisible(false)
	end
end

function QUIWidgetGodarmStrength:updateProgress()

    self._ccbOwner.tf_curtentLevel:setString((self._godarmInfo.level or 1).."/"..remote.user.level * 2)
    -- local curtentConfig = db:getGodarmLevelConfigBylevel(self._godarmConfig.aptitude, (self._godarmInfo.level or 1) )
    local nextConfig = db:getGodarmLevelConfigBylevel(self._godarmConfig.aptitude, (self._godarmInfo.level or 1) + 1)
    local needExp = 0
    -- local curtentExp = curtentConfig and curtentConfig.strengthen_zuoqi or 0
    if nextConfig ~= nil then
        needExp = nextConfig.strengthen_zuoqi or 1
        local currentExp = (self._godarmInfo.exp or 0)
		local curProportion = currentExp/needExp
    	if currentExp > needExp then
    		curProportion = 1
    	end
    	self._ccbOwner.status_bar:setScaleX(curProportion)
        self._ccbOwner.status1_tf:setString(currentExp.."/"..needExp)
    else
    	 self._ccbOwner.status1_tf:setString("已升级至上限")
    	 self._ccbOwner.status_bar:setScaleX(1)
    end
end

function QUIWidgetGodarmStrength:setGodarmStrengthInfo( godarmId)
	self:resetAll()
	if godarmId == nil or godarmId == "" then return end
    self._godarmId = godarmId
    
    self._godarmConfig = db:getCharacterByID(self._godarmId)
    self._godarmInfo = remote.godarm:getGodarmById(self._godarmId)
	self._oldLevel = self._godarmInfo.level
	
    self:updateProgress()
		--强化属性
	local refromProp = db:getGodarmLevelConfigBylevel(self._godarmConfig.aptitude, self._godarmInfo.level) or {}
    local props = remote.godarm:getPropDicByConfig(refromProp)
	local index = 1
    for key, value in pairs(props) do
        if value > 0 then
            local name = QActorProp._field[key].uiName or QActorProp._field[key].name
            local isPercent = QActorProp._field[key].isPercent
            local str = q.getFilteredNumberToString(tonumber(value), isPercent, 2)  
            self._ccbOwner["node_propview_"..index]:setVisible(true)
            self._ccbOwner["tf_team_name_"..index]:setString(name.."：+"..str)
            self._ccbOwner["tf_team_value_"..index]:setVisible(false)
            index = index+1
        end
    end
	local nextRefromProp = db:getGodarmLevelConfigBylevel(self._godarmConfig.aptitude, self._godarmInfo.level+1) or {}
    local nextProps = remote.godarm:getPropDicByConfig(nextRefromProp)
	index = 1
	if next(nextProps) ~= nil then
	    for key, value in pairs(nextProps) do
	        if value > 0 then
	            local name = QActorProp._field[key].uiName or QActorProp._field[key].name
	            local isPercent = QActorProp._field[key].isPercent
	            local str = q.getFilteredNumberToString(tonumber(value), isPercent, 2)  
	            self._ccbOwner["tf_team_add_value_"..index]:setString("+"..str)
	            self._ccbOwner["tf_team_add_value_"..index]:setVisible(true)
				self._ccbOwner["tf_team_value_"..index]:setPositionX(-72)
				self._ccbOwner["tf_team_name_"..index]:setPositionX(-171)	            
	            index = index+1
	        end
	    end
	    self._ccbOwner.sp_dircen:setVisible(true)
	else
		self._ccbOwner.sp_dircen:setVisible(false)
		for i=1,5 do
			self._ccbOwner["tf_team_add_value_"..i]:setVisible(false)
			self._ccbOwner["tf_team_value_"..i]:setPositionX(8)
			self._ccbOwner["tf_team_name_"..i]:setPositionX(-91)
		end
	end
	self:showCostItems() 
end

function QUIWidgetGodarmStrength:showCostItems()
	local expItems = remote.godarm.EXP_ITEMS
	-- self._items = {}
	for index, value in ipairs(expItems) do
		self._ccbOwner["node_item"..index]:removeAllChildren()
		local items = QUIWidgetItemsBox.new()
		items:setScale(0.8)
		local itemsInfo = db:getItemByID(value)
		local haveNum = remote.items:getItemsNumByID(itemsInfo.id)
		items:setGoodsInfo(itemsInfo.id, ITEM_TYPE.ITEM, haveNum)
		-- items:setPromptIsOpen(true)
		self._ccbOwner["tf_exp_add"..index]:setString("经验+"..(itemsInfo.exp or 0))
		self._ccbOwner["node_item"..index]:addChild(items)
		self._ccbOwner["item_layer"..index]:setPosition(self._ccbOwner["node_item"..index]:getPosition())
		self._ccbOwner["item_layer"..index]:setVisible(haveNum<=0)		
	end  
end

function QUIWidgetGodarmStrength:upGrade()
	-- body
	if self._eatNum > 0 then
		local eatNum = self._eatNum
		self._eatNum = 0
		local itemId = self._materials[self._itemIndex]

		remote.godarm:godarmLevelUpRequest(self._godarmId, {{type = itemId, count = eatNum}}, function ()
			remote.herosUtil:dispatchEvent({name = remote.herosUtil.EVENT_REFESH_BATTLE_FORCE})
		end)
	end
end

function QUIWidgetGodarmStrength:upGradeByLevel(addLevel)
	local info = remote.godarm:strengthToLevel(self._godarmId, addLevel)
	if info.statusCode ~= nil then
		if info.statusCode == 1 then
			app.tip:floatTip("已经达到等级上限")
		elseif info.statusCode == 2 and info.dropItemId ~= nil then
    		QQuickWay:addQuickWay(QQuickWay.ITEM_DROP_WAY, info.dropItemId, nil, nil, nil, "神器升级材料不足，请查看获取途径~")
		end
		return
	end
	local eatItems = info.eatItems

	local oldLevel = self._godarmInfo.level
	self._oldMasterLevel = db:getGodarmMasterByAptitudeAndLevel(self._godarmConfig.aptitude,oldLevel).level
	remote.godarm:godarmLevelUpRequest(self._godarmId, eatItems, function ()
		remote.herosUtil:dispatchEvent({name = remote.herosUtil.EVENT_REFESH_BATTLE_FORCE})
		local newInfo = remote.godarm:getGodarmById(self._godarmId)
		local oldProp = db:getGodarmLevelConfigBylevel(self._godarmConfig.aptitude, oldLevel) or {}
		local newProp = db:getGodarmLevelConfigBylevel(self._godarmConfig.aptitude, newInfo.level) or {}
		local addProps = remote.godarm:getDelPropDicByConfig(oldProp,newProp)
		if self.class then
			local talentConfig = db:getGodarmMasterByAptitudeAndLevel(self._godarmConfig.aptitude,newInfo.level)
			if talentConfig.level > self._oldMasterLevel then
				self._parent:enableTouchSwallowTop()
			end		
			local showTalent = 	talentConfig.level - self._oldMasterLevel
			self:_showSucceedEffect(newInfo.level, info.addLevel,addProps,showTalent)
		end
	end)
end

function QUIWidgetGodarmStrength:_showSucceedEffect(newlevel,addLevel,addProps,showTalent)
	self._ccbOwner.node_animation:removeAllChildren()
	local ccbFile = "ccb/effects/mountstrenghtSccess.ccbi"
	local strengthenEffectShow = QUIWidgetAnimationPlayer.new()
	self._ccbOwner.node_animation:addChild(strengthenEffectShow)
	strengthenEffectShow:setPosition(ccp(0, 200))
	strengthenEffectShow:playAnimation(ccbFile, function()
			for i=1,4 do
				strengthenEffectShow._ccbOwner["node_"..i]:setVisible(false)
			end
			strengthenEffectShow._ccbOwner.title_enchant:setVisible(false)
			strengthenEffectShow._ccbOwner.title_skill:setVisible(false)
			strengthenEffectShow._ccbOwner.title_strengthen:setString("等级  ＋"..addLevel)
			if addProps ~= nil then
				local index = 1
				strengthenEffectShow._ccbOwner.node_1:setVisible(false)
				strengthenEffectShow._ccbOwner.node_2:setVisible(false)
				for key,value in pairs(addProps) do
					if value > 0 then
			            local name = QActorProp._field[key].uiName or QActorProp._field[key].name
			            local isPercent = QActorProp._field[key].isPercent
			            local str = q.getFilteredNumberToString(tonumber(value), isPercent, 2)  						
						strengthenEffectShow._ccbOwner["tf_name"..index]:setString(name .. "  ＋" .. str)
						strengthenEffectShow._ccbOwner["node_"..index]:setVisible(true)
						index = index + 1
						if index > 4 then
							break
						end
			        end
				end
			end
		end, function()
			if showTalent > 0 then
				if self._parent ~= nil then 
					self._parent:disableTouchSwallowTop()
				end
				local successTip = app.master.GODARM_MASTER_TIP
				if app.master:getMasterShowState(successTip) then
					app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogGodarmTalentSuccess",
						options = { godarmId = self._godarmId, successTip = successTip}},{isPopCurrentDialog = false})
				end
			end
		end)
end

function QUIWidgetGodarmStrength:_onDownHandler(index)
	if self._timeHandler ~= nil then
		scheduler.unscheduleGlobal(self._timeHandler)
		self._timeHandler = nil
	end
	self._oldLevel = self._godarmInfo.level
	self._selectIndex = index
	self._itemIndex = index
	self._itemId = self._materials[index]
	self._isUp = false
	self._isEating = false
	self._addNum = 1
	self._changeLevel = 0
	self._eatNum = 0

	self._delayTime = 0.2
	-- 延时一秒 如果一秒内未up或者移动则连续吃经验
	self._timeHandler = scheduler.performWithDelayGlobal(handler(self, self._eatExpItemsForEach), self._delayTime)
end

function QUIWidgetGodarmStrength:_onUpHandler()
	if self._isUp == true then return end
	if self._timeHandler ~= nil then
		scheduler.unscheduleGlobal(self._timeHandler)
		self._timeHandler = nil
	end
	self._isUp = true
	if self._isEating == false then
		self:_eatExpItem()
	else
		self._isEating = false
	end
	self:upGrade()
end

function QUIWidgetGodarmStrength:godarmEatExp(exp)
	local nextExp = db:getGodarmLevelConfigBylevel(self._godarmConfig.aptitude, self._godarmInfo.level + 1)
	if nextExp == nil then
		return false
	end
	if nextExp.level > remote.user.level *2 then
		return false, 0, 0
	end
	local addLevel = 0
	local currentExp = self._godarmInfo.exp + exp
	while true do
		if currentExp >= nextExp.strengthen_zuoqi then
			addLevel = addLevel + 1
			currentExp = currentExp - nextExp.strengthen_zuoqi
			nextExp = db:getGodarmLevelConfigBylevel(self._godarmConfig.aptitude, self._godarmInfo.level + addLevel)
			if nextExp == nil then
				return true, addLevel, 0
			end
		else
			break
		end
	end
	return true, addLevel, currentExp
end

function QUIWidgetGodarmStrength:_eatExpItemsForEach(index)
	if self._timeHandler ~= nil then
		scheduler.unscheduleGlobal(self._timeHandler)
		self._timeHandler = nil
	end
	self._isEating = true
	self._timeHandler = scheduler.performWithDelayGlobal(handler(self, self._eatExpItem), self._delayTime)
end

function QUIWidgetGodarmStrength:_eatExpItem()
	local itemNum = remote.items:getItemsNumByID(self._itemId) or 0
	if itemNum > 0 then
		if itemNum < self._addNum then
			self._addNum = itemNum or 0
		end
		local itemConfig = db:getItemByID(self._itemId)
		local exp = itemConfig.exp or 0 
		exp = exp * self._addNum

		local isSucc, addLevel, currExp = self:godarmEatExp(exp) --检查是否能吃，吃完了能升级吗
		print("单个道具升级----isSucc，addLevel, currExp",isSucc, addLevel, currExp)
		if isSucc then
			self:addEatNum() --累加吃经验道具
			-- self:_showEatNum(exp) --在经验条上显示经验飘动数据
			-- self:setExpItems() --设置经验道具的数量
			self:_showEffect() --显示吃经验飞动的效果

			--更新经验条
			self._godarmInfo.exp = currExp
			self:updateProgress()
			
			self._oldMasterLevel = db:getGodarmMasterByAptitudeAndLevel(self._godarmConfig.aptitude,self._godarmInfo.level).level

			self._godarmInfo.level = self._godarmInfo.level + addLevel

			
			if addLevel > 0 then
				self:showUpGradeEffect(addLevel)
			end

			if self._isEating == true then --如果在吃经验中则加快吃的速度 
				self._delayTime = self._delayTime - 0.02
				self._delayTime = self._delayTime > 0.05 and self._delayTime or 0.05
				self._addNum = self._addNum + 2 
				self._addNum = self._addNum >= 10 and 10 or self._addNum
				self._timeHandler = scheduler.performWithDelayGlobal(handler(self, self._eatExpItem), self._delayTime)
			end
		else
			self:_onUpHandler()
			return
		end
	else
		self:_onUpHandler()
		local dropType = QQuickWay.ITEM_DROP_WAY
    	QQuickWay:addQuickWay(dropType, self._itemId, nil, nil, nil, "神器强化材料不足，请查看获取途径~")
	end
end

function QUIWidgetGodarmStrength:addEatNum()
	if remote.items:removeItemsByID(self._itemId, self._addNum, false) == false then
		return
	end
	self._eatNum = self._eatNum + self._addNum
end

function QUIWidgetGodarmStrength:_showEatNum(exp)
	if self._numEffect == nil then
		self._numEffect = QUIWidgetAnimationPlayer.new()
		self._ccbOwner.node_exp:addChild(self._numEffect)
	end
	self._numEffect:playAnimation("effects/Tips_add.ccbi", function(ccbOwner)
				ccbOwner.content:setString(" ＋"..exp)
            end)
end

function QUIWidgetGodarmStrength:showUpGradeEffect(addLevel )
	local oldProp = db:getGodarmLevelConfigBylevel(self._godarmConfig.aptitude, self._oldLevel) or {}
	local newProp = db:getGodarmLevelConfigBylevel(self._godarmConfig.aptitude, self._godarmInfo.level) or {}
	local addProps = remote.godarm:getDelPropDicByConfig(oldProp,newProp)			
	local talentConfig = db:getGodarmMasterByAptitudeAndLevel(self._godarmConfig.aptitude,self._godarmInfo.level)
	local showTalent = 	talentConfig.level - self._oldMasterLevel
	print("单个物品强化 showTalent==",showTalent)
	if showTalent > 0  then
		self:_onUpHandler()
	end
	self:_showSucceedEffect(self._godarmInfo.level, addLevel,addProps,showTalent)		
end

function QUIWidgetGodarmStrength:_showEffect()
	local effectFun1 = function ()
		local actionHandler = nil
		local item = QUIWidgetItemsBox.new()
		item:setGoodsInfo(self._itemId, "item", 0)
		self._ccbOwner["node_item"..self._itemIndex]:addChild(item)

		local position1 = self._ccbOwner.node_exp:convertToWorldSpaceAR(ccp(0, 0))
		local position2 = self._ccbOwner["node_item"..self._itemIndex]:convertToWorldSpaceAR(ccp(0, 0))

		local targetPosition = ccp(position1.x - position2.x , position1.y - position2.y + 40)

		local moveTo = CCMoveTo:create(0.1, targetPosition)
		local scale = CCScaleTo:create(0.1, 0)
		local func = CCCallFunc:create(function()
				item:removeFromParent()
				item = nil
				actionHandler = nil
			end)
		local array1 = CCArray:create()
		array1:addObject(moveTo)
		array1:addObject(scale)
		local ccspawn = CCSpawn:create(array1)

		local array2 = CCArray:create()
		array2:addObject(ccspawn)
		array2:addObject(func)
		local ccsequence = CCSequence:create(array2)
		actionHandler = item:runAction(ccsequence)
	end
	local effectFun2 = function ()
    	local effect = QUIWidgetAnimationPlayer.new()
    	self._ccbOwner["node_item"..self._itemIndex]:addChild(effect)
    	effect:playAnimation("ccb/effects/UseItem2.ccbi", nil, function()
                effect:disappear()
                effect = nil
            end)
	end
	effectFun1()
	scheduler.performWithDelayGlobal(effectFun2, 0.1)
end

function QUIWidgetGodarmStrength:_onTriggerOneGrade(event)
    if q.buttonEventShadow(event, self._ccbOwner.btn_oneGrade) == false then return end
	app.sound:playSound("common_small")

	self:upGradeByLevel(1)
end

function QUIWidgetGodarmStrength:_onTriggerFiveGrade(event)
    if q.buttonEventShadow(event, self._ccbOwner.btn_fiveGrade) == false then return end
	app.sound:playSound("common_small")

	self:upGradeByLevel(5)
end

function QUIWidgetGodarmStrength:_onTriggerClickItem1(event)
	if tonumber(event) == CCControlEventTouchDown then
		self:_onDownHandler(1)
	else
		self:_onUpHandler(1)
	end
end

function QUIWidgetGodarmStrength:_onTriggerClickItem2(event)
	if tonumber(event) == CCControlEventTouchDown then
		self:_onDownHandler(2)
	else
		self:_onUpHandler(2)
	end
end

function QUIWidgetGodarmStrength:_onTriggerClickItem3(event)
	if tonumber(event) == CCControlEventTouchDown then
		self:_onDownHandler(3)
	else
		self:_onUpHandler(3)
	end
end

function QUIWidgetGodarmStrength:getContentSize()
end

return QUIWidgetGodarmStrength
