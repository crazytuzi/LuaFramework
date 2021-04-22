



local QUIWidget = import("...widgets.QUIWidget")
local QUIWidgetHeroSparAbsorb = class("QUIWidgetHeroSparAbsorb", QUIWidget)

local QNavigationController = import("....controllers.QNavigationController")
local QUIViewController = import("...QUIViewController")
local QStaticDatabase = import("....controllers.QStaticDatabase")
local QUIWidgetEquipmentAvatar = import("...widgets.QUIWidgetEquipmentAvatar")
local QUIWidgetItemsBox = import("...widgets.QUIWidgetItemsBox")
local QQuickWay = import("....utils.QQuickWay")
local QUIWidgetAnimationPlayer = import("...widgets.QUIWidgetAnimationPlayer")
local QUIWidgetSparBox = import("...widgets.spar.QUIWidgetSparBox")
local QRichText = import("....utils.QRichText")

-- 自动选择吸收的跳过列表，若其他都没得选择再选此列表中的内容
QUIWidgetHeroSparAbsorb._AUTOSELECT_KEEP_LIST = {
	2000002, 	-- 火焰八蛛矛前爪
	2010003 	-- 飓风八蛛矛后爪
}

function QUIWidgetHeroSparAbsorb:ctor(options)
	local ccbFile = "ccb/Widget_spar_absorb.ccbi"
	local callBack = {
		{ccbCallbackName = "onTriggerReset", callback = handler(self, self._onTriggerReset)},
		{ccbCallbackName = "onTriggerAbsorb", callback = handler(self, self._onTriggerAbsorb)},
		{ccbCallbackName = "onTriggerAutoAdd", callback = handler(self, self._onTriggerAutoAdd)},
	}
	QUIWidgetHeroSparAbsorb.super.ctor(self, ccbFile, callBack, options)

	cc.GameObject.extend(self)
	self:addComponent("components.behavior.EventProtocol"):exportMethods()
	self._isMax = false
    q.setButtonEnableShadow(self._ccbOwner.btn_reset)
	q.setButtonEnableShadow(self._ccbOwner.btn_absorb)
	q.setButtonEnableShadow(self._ccbOwner.btn_auto_add)

	self._materials = {} -- data : itemId - num
	-- self._sparItemList = {2000001 , 2000002 , 2000003 , 2010001 , 2010002 , 2010003}
	self._sparItemList = remote.spar:getSparItemIds(APTITUDE.S)
	self._sparItem ={}
	self._sparItemHaveNum ={}	--	data :  itemId - num  mark：store num
	self._sparItemHaveSpars ={}	--	data :  itemId - {spars}  mark：store spars table
	self._iconPos = ccp(self._ccbOwner.sp_spar_icon:getPositionX(),self._ccbOwner.sp_spar_icon:getPositionY())

    self._progressWidth = self._ccbOwner.sp_bar_progress:getContentSize().width
	local progress = q.newPercentBarClippingNode(self._ccbOwner.sp_bar_pre_progress)
	self._preProgressStencil = progress:getStencil()
    local progress = q.newPercentBarClippingNode(self._ccbOwner.sp_bar_progress)
    self._progressStencil = progress:getStencil()
    self._richText = QRichText.new({}, 400, {autoCenter = true})
    self._richText:setAnchorPoint(ccp(0.5, 0.5))
    self._ccbOwner.node_exp:addChild(self._richText)
    self._ccbOwner.tf_progress:setVisible(false)

end

function QUIWidgetHeroSparAbsorb:onEnter()
	self:initData()  
	self:initSparItemList()
	self:initAction() 

end

function QUIWidgetHeroSparAbsorb:onExit()
end

function QUIWidgetHeroSparAbsorb:initData()

end

function QUIWidgetHeroSparAbsorb:updateData()
	--刷新存量数据
	self._sparItemHaveNum = {} 
	self._sparItemHaveSpars = {} 
	self._materials = {} 
	self._isMax = false

	for i,v in ipairs(self._sparItemList) do
		local  spars , num = remote.spar:getCanAbsorbSparsByItemId(v)
		self._sparItemHaveSpars[v] = spars
		self._sparItemHaveNum[v] = num
	end
end

function QUIWidgetHeroSparAbsorb:initAction()
	local arr = CCArray:create()
	arr:addObject(CCMoveTo:create(1, ccp(self._iconPos.x,self._iconPos.y + 10)))
	arr:addObject(CCMoveTo:create(1, self._iconPos))
	self._ccbOwner.sp_spar_icon:runAction(CCRepeatForever:create(CCSequence:create(arr)))
end 

function QUIWidgetHeroSparAbsorb:setInfo(actorId,sparId,sparPos)
	self._actorId = actorId
	self._sparId = sparId
	self._index = sparPos

	self:updateData()
	self:updateSparItemList()

	local heroModle = remote.herosUtil:getUIHeroByID(self._actorId)
	local sparInfo = heroModle:getSparInfoByPos(self._index).info or {}
	self._itemConfig = db:getItemByID(sparInfo.itemId)
 	q.setAptitudeShow(self._ccbOwner, nil , self._itemConfig.gemstone_quality)
	self._ccbOwner.tf_name:setString(self._itemConfig.name or "")
	local fontColor = EQUIPMENT_COLOR[self._itemConfig.colour]
	self._ccbOwner.tf_name:setColor(fontColor)
	self._ccbOwner.tf_name = setShadowByFontColor(self._ccbOwner.tf_name, fontColor)
    local frame =QSpriteFrameByPath(QResPath("ss_spar_icon")[tostring(sparInfo.itemId)])
    if frame then
    	self._ccbOwner.sp_spar_icon:setVisible(true)
        self._ccbOwner.sp_spar_icon:setDisplayFrame(frame)
    end

	self:updateAbsorbInfo()

end

function QUIWidgetHeroSparAbsorb:updateAbsorbInfo()

	local heroModle = remote.herosUtil:getUIHeroByID(self._actorId)
	self._sparInfo = heroModle:getSparInfoByPos(self._index).info or {}

	local absorbLv = self._sparInfo.inheritLv  or 0
	local color = math.ceil(absorbLv / 2) 
	color = color == 0 and 1 or color
	color = color + 1
	local fontColor = EQUIPMENT_COLOR[color]
	self._ccbOwner.tf_level:setString("吸收"..absorbLv.."阶")
	-- self._ccbOwner.tf_level:setColor(fontColor)
	-- self._ccbOwner.tf_level = setShadowByFontColor(self._ccbOwner.tf_level, fontColor)
	self._ccbOwner.node_normal:setVisible(false)
	self._ccbOwner.node_max:setVisible(false)

	local absorbConfig1 = db:getSparsAbsorbConfigBySparItemIdAndLv(self._sparInfo.itemId, absorbLv )
	local absorbConfig2 = db:getSparsAbsorbConfigBySparItemIdAndLv(self._sparInfo.itemId, absorbLv + 1)

	if absorbConfig2 == nil then
		self._ccbOwner.node_max:setVisible(true)
		self:setSparPropInfo("max",absorbConfig1)
		self._isMax = true
	else
		self._ccbOwner.node_normal:setVisible(true)
		if  absorbLv == 0 and absorbConfig2 then
			self:setSparPropInfo("cur",absorbConfig2 ,true)
		else
			self:setSparPropInfo("cur",absorbConfig1)
		end
		self:setSparPropInfo("next",absorbConfig2)

		local absorbConfig1 = db:getSparsAbsorbConfigBySparItemIdAndLv(self._sparInfo.itemId, absorbLv )
		local befNum = remote.spar:getSparAbsorbTotalNumByItemIdAndLv(self._sparInfo.itemId, absorbLv )
		local totleNum = 0
		for k,v in pairs(self._sparInfo.consumeItems or {}) do
			totleNum = totleNum + v.count
		end
		self._curExp = totleNum - befNum
		self._consumeExp = absorbConfig2.inherit_num or 1
	end

	self:_updateExpInfo()
end

function QUIWidgetHeroSparAbsorb:setSparPropInfo(typeStr,config , isZero)

	local propDesc = remote.spar:setPropInfo(config)
	if isZero then
		self._ccbOwner["tf_"..typeStr.."_title"]:setString("【吸收0阶】")
	elseif typeStr~= "max" then
		self._ccbOwner["tf_"..typeStr.."_title"]:setString("【吸收"..config.level.."阶】")
	end
	-- self:transferPropName(propDesc)
	for i=1,4 do
		local  prop = propDesc[i] or {}
		self._ccbOwner["tf_"..typeStr.."_name"..i]:setString((prop.name or "").."：")
		if isZero then
			self._ccbOwner["tf_"..typeStr.."_value"..i]:setString("+0")
		else
			self._ccbOwner["tf_"..typeStr.."_value"..i]:setString("+"..(prop.value or ""))
		end
	end
end

function QUIWidgetHeroSparAbsorb:_updateExpInfo()
    if self._isMax then
        self._ccbOwner.tf_progress:setString("MAX")
        self._ccbOwner.tf_progress:setVisible(true)
        self._progressStencil:setPositionX(0)
        self._preProgressStencil:setPositionX(0)
        self._ccbOwner.btn_reset:setVisible(true)
        self._richText:setVisible(false)
        return
    end

    self._ccbOwner.tf_progress:setVisible(false)
	self._richText:setVisible(true)
	local exp = self:getTotalExp()
    self._addExp = exp
    local curValue = self._curExp/self._consumeExp
    local tempValue = (self._addExp+self._curExp)/self._consumeExp
    if tempValue >= 1 then
    	tempValue = 1
    else
    end

    self._ccbOwner.btn_reset:setVisible(false)
    if self._sparInfo and tempValue < 1 then

        if  (self._sparInfo.inheritLv or 0) > 0 or self._curExp > 0 then
            self._ccbOwner.btn_reset:setVisible(true)
        end
    end

    if exp > 0 then
        self._richText:setString({
                {oType = "font", content = self._curExp, size = 18, color = GAME_COLOR_SHADOW.stress, strokeColor = GAME_COLOR_LIGHT.normal},
                {oType = "font", content = "+"..exp, size = 18, color = GAME_COLOR_SHADOW.property, strokeColor = GAME_COLOR_LIGHT.normal},
                {oType = "font", content = "/"..self._consumeExp, size = 18, color = GAME_COLOR_SHADOW.stress, strokeColor = GAME_COLOR_LIGHT.normal},
            })
    else
        self._richText:setString({
                {oType = "font", content = self._curExp.."/"..self._consumeExp, size = 18, color = GAME_COLOR_SHADOW.stress, strokeColor = GAME_COLOR_LIGHT.normal},
            })
    end
    self._ccbOwner.tf_progress:setString((self._addExp+self._curExp).."/"..self._consumeExp)
    self._progressStencil:setPositionX(curValue*self._progressWidth - self._progressWidth)
    self._preProgressStencil:setPositionX(tempValue*self._progressWidth - self._progressWidth)
end

function QUIWidgetHeroSparAbsorb:initSparItemList()
	for i,v in ipairs(self._sparItemList) do
		self._sparItem[i] = QUIWidgetSparBox.new()
		self._ccbOwner.sheet_layout:addChild(self._sparItem[i])
		self._sparItem[i]:addEventListener(QUIWidgetSparBox.EVENT_CLICK, handler(self, self._itemClickHandler))
		self._sparItem[i]:addEventListener(QUIWidgetSparBox.EVENT_MINUS_CLICK, handler(self, self._itemMinusClickHandler))
		self._sparItem[i]:setScale(0.6)
		self._sparItem[i]:setPositionX(55 + 80 * (i - 1))
		self._sparItem[i]:setPositionY(52)
		-- self._sparItem[i]:setLongTouch(true)

		local  sparIdx = remote.spar:getSparsIndexByItemId(v)
		self._sparItem[i]:setGemstoneInfo({itemId = v, grade = 0, level = 1, content = ""}, sparIdx)
		self._sparItem[i]:setNamePositionOffset(0, 0)
		self._sparItem[i]:setStrengthVisible(false)
	end
end

function QUIWidgetHeroSparAbsorb:updateSparItemList()
	for i,v in ipairs(self._sparItemList) do
		local  item = self._sparItem[i]
		local haveNum = self._sparItemHaveNum[v]
		if haveNum == 0 then
			item:setName(haveNum, 1.2)
			makeNodeFromNormalToGray(item)
			item:showMinusButton(false)
		else
			makeNodeFromGrayToNormal(item)
			local usedNum = self._materials[v] or 0
			item:setName(usedNum.."/"..haveNum, 1.2)
			item:showMinusButton(usedNum > 0)
		end
	end
end 

function QUIWidgetHeroSparAbsorb:getTotalExp()
    local exp = 0
	for i, v in pairs(self._materials) do
		exp = exp + v
    end
    return exp
end


function QUIWidgetHeroSparAbsorb:showSelectAnimation(itemId, index)
    local icon = QUIWidgetSparBox.new()
    local  sparIdx = remote.spar:getSparsIndexByItemId(itemId)
    icon:setGemstoneInfo({itemId = itemId, grade = 0, level = 1, content = ""}, sparIdx)
    icon:setNameVisible(false)
	icon:setScale(0.4)

    local itemWidget = self._sparItem[index]
    local p = itemWidget:convertToWorldSpace(ccp(0, 0))
    p = self._ccbOwner.node_effect:convertToNodeSpace(p)
    icon:setPosition(p.x, p.y)
    icon:setScale(0.8)
    self._ccbOwner.node_effect:addChild(icon)

    local effectPosX, effectPosY  = self._ccbOwner.node_effect:getPosition()
    local targetP = ccp(0, 10)
    local arr = CCArray:create()
    local bezierConfig = ccBezierConfig:new()
    bezierConfig.endPosition = targetP
    bezierConfig.controlPoint_1 = ccp(p.x + (targetP.x - p.x) * 0.333, p.y + (targetP.y- p.y) * 0.8)
    bezierConfig.controlPoint_2 = ccp(p.x + (targetP.x - p.x) * 0.667, p.y + (targetP.y- p.y) * 1)

    local bezierTo = CCBezierTo:create(0.4, bezierConfig)
    arr:addObject(CCSpawn:createWithTwoActions(bezierTo, CCDelayTime:create(0.2)))
    arr:addObject(CCCallFunc:create(function()
            icon:removeFromParent()
        end))
    local seq = CCSequence:create(arr)
    icon:runAction(seq)
end


function QUIWidgetHeroSparAbsorb:_itemClickHandler(event)
	app.sound:playSound("common_item")
	-- QPrintTable(event)
    if self._isMax then
        app.tip:floatTip("外附魂骨已经满吸收，无法再吸收增加经验")
        return
    end    
	local exp = self:getTotalExp()
	local needExp = self._consumeExp - self._curExp - exp
    if needExp <= 0 then
        app.tip:floatTip("当前经验已可以提升吸收等级")
        return
    end

	local itemId = event.itemID
	local curUseNum = self._materials[itemId] or 0
	local maxNum = self._sparItemHaveNum[itemId] or 0
	if maxNum <= 0 then return end
	if curUseNum + 1 > maxNum then
		app.tip:floatTip("所选道具数量已达上限")
		return
	end


	local addNum = 1
	--直接一次加到上限
	local notUse = maxNum - curUseNum
	if needExp > notUse then
		addNum = notUse
	else
		addNum = needExp
	end

	if self._materials[itemId] then
		self._materials[itemId] = self._materials[itemId] + addNum
	else
		self._materials[itemId] = addNum
	end

	for i,v in ipairs(self._sparItemList) do
		if v == itemId then
			self:showSelectAnimation(itemId,i)
			break
		end
	end

	self:updateSparItemList()
	self:_updateExpInfo()
end


function QUIWidgetHeroSparAbsorb:_itemMinusClickHandler(event)
	-- QPrintTable(event)
	local itemId = event.itemID
	if not self._materials[itemId] or self._materials[itemId] <= 0 then
		return
	end
	self._materials[itemId] = self._materials[itemId] - 1

	self:updateSparItemList()
	self:_updateExpInfo()
end



function QUIWidgetHeroSparAbsorb:_onTriggerReset()
    app.sound:playSound("common_small")
    local costValue = QStaticDatabase:sharedDatabase():getConfigurationValue("SS_JEWELRY_RETURN") or 0
    costValue = tonumber(costValue)
    if costValue > remote.user.token then
        QQuickWay:addQuickWay(QQuickWay.TOKEN_DROP_WAY, nil)
        return
    end
	local sparId = self._sparInfo.sparId
	local awards = {}
	for k,v in pairs(self._sparInfo.consumeItems or {}) do
		table.insert(awards, {id = v.type, value = v.count})
	end
	QPrintTable(awards)
    app:alert({content = "##n花费##e30钻石##n，可以将当前##eSS外骨##n的吸收等级重新重置到##e0级##n，并返还##e所消耗的S外骨##n，是否重置吸收等级？", title = "系统提示", 
        callback = function(callType)
            if callType == ALERT_TYPE.CONFIRM then
                -- 点击后吸收重置
                remote.spar:requestSparInheritCancel(sparId, function(data)
                    if data.items then remote.items:setItems(data.items) end
                    -- 展示奖励页面
                    app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogHeroRebornReturns", 
                        options = {compensations = awards, type = 13, subtitle = "重置吸收返还以下道具"}}, {isPopCurrentDialog = false})
                end)
            end
        end, isAnimation = true, colorful = true}, true, true)   
end

function QUIWidgetHeroSparAbsorb:_onTriggerAbsorb()

	local sparId = self._sparInfo.sparId
	local consumeSpars = {}
	local exp = 0

	for k, v in pairs(self._materials) do
		if v > 0 then
			local remainingNum = v
			if self._sparItemHaveSpars[k] then
				for i,spars in ipairs( self._sparItemHaveSpars[k] or {}) do
					if remainingNum <= 0 then break end
					local sparData = {}
					sparData.level = spars.level
					sparData.actorId = spars.actorId
					sparData.grade = spars.grade
					sparData.sparId = spars.sparId
					sparData.exp = spars.exp
					sparData.itemId = spars.itemId
					if remainingNum > spars.count then
						sparData.count = spars.count
						remainingNum = remainingNum - spars.count
					else
						sparData.count = remainingNum
						remainingNum = 0
					end
					table.insert( consumeSpars , sparData)
				end
			end
		end
    end
    if q.isEmpty(consumeSpars) then
    	app.tip:floatTip("没有吸收的道具")
    	return
    end

    local oldSparInfo = self._sparInfo
	remote.spar:requestSparInherit(sparId, consumeSpars, function(data)
		if data.items then remote.items:setItems(data.items) end
		local newUIModel = remote.herosUtil:getUIHeroByID(self._actorId)
		local newSparInfo = newUIModel:getSparInfoByPos(self._index).info
		if oldSparInfo.inheritLv ~= newSparInfo.inheritLv then
			app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogSparAbsorbSuccess", 
				options = {oldSparInfo = oldSparInfo, newSparInfo = newSparInfo, pos = self._index, actorId = self._actorId , callback = handler(self, self._checkSparAbsorbUp)}}, {isPopCurrentDialog = false})
		else	
    		app.tip:floatTip("吸收成功")
		end
		end, function (data)
	end)
   
end

-- 获取一个可以自动选择魂骨的列表，把保留的排在后面。并返回当前所有魂骨总数
function QUIWidgetHeroSparAbsorb:_getAutoSelectList()
	local selectList = {}
	local lastList = {}
	local total = 0

	local function checkKeep(itemId)
		for _, v in ipairs(QUIWidgetHeroSparAbsorb._AUTOSELECT_KEEP_LIST) do
			if itemId == v then
				return true
			end
		end
		return false
	end

	for i, v in ipairs(self._sparItemList) do
		if checkKeep(v) then
			table.insert(lastList, { itemId = v, index = i})
		else
			table.insert(selectList, { itemId = v, index = i})
		end
		total = total + (self._sparItemHaveNum[v] or 0)
	end

	for _, v in ipairs(lastList) do
		table.insert(selectList, v)
	end

	return selectList, total
end

function QUIWidgetHeroSparAbsorb:_onTriggerAutoAdd()
	app.sound:playSound("common_small")

	if self._isMax then
        app.tip:floatTip("外附魂骨已经满吸收，无法再吸收增加经验")
        return
    end    
	local exp = self:getTotalExp()
	local needExp = self._consumeExp - self._curExp - exp
    if needExp <= 0 then
        app.tip:floatTip("当前经验已可以提升吸收等级")
        return
	end

	local addNum = 0
	local itemCount = 0
	local itemId = 0
	local selectList, total = self:_getAutoSelectList()
	local material = 0
	local surplus = 0

	if total <= 0 then
		app.tip:floatTip("当前没有可用的外附魂骨")
        return
	end

	for _,v in ipairs(selectList) do
		if needExp <= 0 then
			break
		end

		addNum = 0
		itemId = v.itemId
		itemCount = self._sparItemHaveNum[itemId] or 0
		material = self._materials[itemId] or 0

		if itemCount > 0 and material < itemCount then
			surplus = itemCount - material
			if needExp - surplus >= 0 then
				needExp = needExp - surplus
				addNum = surplus
			else
				addNum = needExp
				needExp = 0
			end
			if addNum > 0 and material + addNum <= itemCount then
				if self._materials[itemId] then
					self._materials[itemId] = self._materials[itemId] + addNum
				else
					self._materials[itemId] = addNum
				end
				self:showSelectAnimation(itemId, v.index)
			end
		end
	end

	self:updateSparItemList()
	self:_updateExpInfo()
end

function QUIWidgetHeroSparAbsorb:_checkSparAbsorbUp()
	remote.herosUtil:dispatchEvent({name = remote.herosUtil.EVENT_REFESH_BATTLE_FORCE})
end


return QUIWidgetHeroSparAbsorb