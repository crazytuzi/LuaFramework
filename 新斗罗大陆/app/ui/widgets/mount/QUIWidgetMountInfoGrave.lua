-- @Author: liaoxianbo
-- @Date:   2020-10-28 11:12:47
-- @Last Modified by:   liaoxianbo
-- @Last Modified time: 2020-11-02 18:10:28
local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetMountInfoGrave = class("QUIWidgetMountInfoGrave", QUIWidget)

local QNavigationController = import("...controllers.QNavigationController")
local QUIViewController = import("..QUIViewController")
local QUIWidgetActorDisplay = import("..actorDisplay.QUIWidgetActorDisplay")
local QActorProp = import("....models.QActorProp")
local QUIWidgetItemsBox = import("...widgets.QUIWidgetItemsBox")
local QUIWidgetAnimationPlayer = import("...widgets.QUIWidgetAnimationPlayer")
local QQuickWay = import("....utils.QQuickWay")
local QRichText = import("....utils.QRichText")

function QUIWidgetMountInfoGrave:ctor(options)
	local ccbFile = "ccb/Widget_mount_marble.ccbi"
    local callBacks = {
		{ccbCallbackName = "onTriggerReset", callback = handler(self, self._onTriggerReset)},
		{ccbCallbackName = "onTriggerGrave", callback = handler(self, self._onTriggerGrave)},
    }
    QUIWidgetMountInfoGrave.super.ctor(self, ccbFile, callBacks, options)
  
	cc.GameObject.extend(self)
	self:addComponent("components.behavior.EventProtocol"):exportMethods()

	self._isMax = false
	self._curExp = 0
	self._allCostExp = 0
	self._changeLevel = 0
	self._showAddLevel = 0
	
    q.setButtonEnableShadow(self._ccbOwner.btn_reset)
	q.setButtonEnableShadow(self._ccbOwner.btn_grave)

	self._materials = {} 
	self._graveMountList = remote.mount:getGraveItemConfig()
	self._graveMount ={}
	self._graveMountHaveNum ={}	--	data :  itemId - num  mark：store num
	self._attributeInfo = {}
	self._parent = options.parent

	self._iconPos = ccp(self._ccbOwner.node_mount:getPositionX(),self._ccbOwner.node_mount:getPositionY())

    self._progressWidth = self._ccbOwner.sp_grave_progress:getContentSize().width
	local progress = q.newPercentBarClippingNode(self._ccbOwner.sp_grave_pre_progress)
	self._preProgressStencil = progress:getStencil()
    local progress = q.newPercentBarClippingNode(self._ccbOwner.sp_grave_progress)
    self._progressStencil = progress:getStencil()
    self._richText = QRichText.new({}, 400, {autoCenter = true})
    self._richText:setAnchorPoint(ccp(0.5, 0.5))
    self._ccbOwner.node_exp:addChild(self._richText)
    self._ccbOwner.tf_progress:setVisible(false)

    self._richLevelText = QRichText.new({}, 200)
    self._richLevelText:setAnchorPoint(ccp(0, 0.5))
    self._ccbOwner.node_level:addChild(self._richLevelText)

end

function QUIWidgetMountInfoGrave:onEnter()
	self:initGraveMountList()
end

function QUIWidgetMountInfoGrave:onExit()
end

function QUIWidgetMountInfoGrave:updateData()
	--刷新存量数据
	self._graveMountHaveNum = {}
	self._materials = {} 
	self._isMax = false
	self._curExp = 0
	self._allCostExp = 0
	self._attributeInfo = {}
	self._addGraveLevel = 0
	self._changeLevel = 0
	self._showAddLevel = 0

	for i,v in ipairs(self._graveMountList) do
		local num = remote.items:getItemsNumByID(v.id) or 0
		self._graveMountHaveNum[v.id] = num
	end
end

function QUIWidgetMountInfoGrave:setInfo(actorId)
	self._actorId = actorId
	local heroInfo = remote.herosUtil:getHeroByID(self._actorId)
	local mountId = heroInfo.zuoqi.zuoqiId
	self:setMountId(mountId)
end


function QUIWidgetMountInfoGrave:setMountId(mountId)
	self._mountId = mountId
	self._mountConfig = db:getCharacterByID(self._mountId)
	self._mountInfo = remote.mount:getMountById(self._mountId)

	self:updateData()
	self:updateGraveMountList()

	self._graveLevel = self._mountInfo.grave_level or 0
	self._maxLevel = db:getConfigurationValue("MAX_GRAVE_LEVEL") or 40

    local nameStr = self._mountConfig.name or ""

    self._ccbOwner.tf_name:setString(nameStr)

	local fontColor = QIDEA_QUALITY_COLOR[remote.mount:getColorByMountId(self._mountId)] or COLORS.b
	self._ccbOwner.tf_name:setColor(fontColor)
	self._ccbOwner.tf_name = setShadowByFontColor(self._ccbOwner.tf_name, fontColor)
	
	self._ccbOwner.tf_level:setString("")
	self._richLevelText:setString({{oType = "font", content = self._graveLevel.."/"..self._maxLevel, size = 22, color = GAME_COLOR_SHADOW.stress}})
	
	if self._graveLevel >= self._maxLevel and self._graveLevel > 0 then
		self._ccbOwner.node_max:setVisible(true)
		self._isMax = true
		self:showMountMaxGraveInfo()
	else
		self._ccbOwner.node_normal:setVisible(true)
		self:showMountGraveInfo()
	end

	self._ccbOwner.node_mount:removeAllChildren()
	local avatar = QUIWidgetActorDisplay.new(self._mountId)
	self._ccbOwner.node_mount:addChild(avatar)
	if self._mountConfig.aptitude == APTITUDE.SSR then
		self._ccbOwner.node_mount:setScaleX(0.8)
	else
		self._ccbOwner.node_mount:setScaleX(-0.8)
	end


    local aptitudeInfo = db:getActorSABC(self._mountId)
    q.setAptitudeShow(self._ccbOwner, aptitudeInfo.lower)
end



function QUIWidgetMountInfoGrave:showMountMaxGraveInfo()
	self._ccbOwner.node_normal:setVisible(false)
	self._ccbOwner.node_max:setVisible(true)

	local graveMaxConfig = remote.mount:getGraveInfoByAptitudeLv(self._mountConfig.aptitude, self._graveLevel)
	local props = remote.mount:getUISinglePropInfo(graveMaxConfig)
	self._ccbOwner.node_max_prop_richText:removeAllChildren()
	local index = 1
	for i, prop in ipairs(props) do
        local value = prop.value 
        local tfNode = q.createPropTextNode(prop.name , value,nil,22,0)
        self._ccbOwner.node_max_prop_richText:addChild(tfNode)
		tfNode:setPosition(ccp(-40,-index*30))	
		index = index + 1
	end

	self:updateProgress()
end

function QUIWidgetMountInfoGrave:showMountGraveInfo()
	self._ccbOwner.node_normal:setVisible(true)
	self._ccbOwner.node_max:setVisible(false)

	local oldConfig = remote.mount:getGraveInfoByAptitudeLv(self._mountConfig.aptitude, self._graveLevel)
	self._ccbOwner.tf_cur_title:setString(self._graveLevel.."级属性")
	self._ccbOwner.node_cur_prop_richText:removeAllChildren()
	local props = remote.mount:getUISinglePropInfo(oldConfig)
	local index = 1
	for i, prop in ipairs(props or {}) do
        local value = prop.value 
        local tfNode = q.createPropTextNode(prop.name , value,nil,20,0)
        self._ccbOwner.node_cur_prop_richText:addChild(tfNode)
		tfNode:setPosition(ccp(0,30-index*30))	
		index = index + 1
	end

	local newConfig = remote.mount:getGraveInfoByAptitudeLv(self._mountConfig.aptitude, self._graveLevel + 1)
	self._consumeExp = 1
	self._ccbOwner.node_next_prop_richText:removeAllChildren()
	if newConfig ~= nil then
		self._ccbOwner.tf_next_title:setString((self._graveLevel+1).."级属性")
		local props = remote.mount:getUISinglePropInfo(newConfig)
		local index = 1
		for i, prop in ipairs(props) do
	        local value = prop.value 
	        local tfNode = q.createPropTextNode(prop.name , value,true,20,0)
	        self._ccbOwner.node_next_prop_richText:addChild(tfNode)
			tfNode:setPosition(ccp(0,30-index*30))	
			index = index + 1
		end

		self._consumeExp = newConfig.grave_exp or 1
	end
	self._allCostExp,self._curExp = remote.mount:getCostItemExp(self._mountId)

	self:updateProgress()
end

function QUIWidgetMountInfoGrave:updateProgress()
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
    if self._mountInfo and tempValue < 1 and self._graveLevel == 0 then
		self._ccbOwner.btn_reset:setVisible(self._curExp > 0)
    else
    	self._ccbOwner.btn_reset:setVisible(self._graveLevel > 0)
    end

    if self._addExp > 0 then
    	local strTbl = {
                {oType = "font", content = self._curExp, size = 18, color = GAME_COLOR_SHADOW.stress, strokeColor = GAME_COLOR_LIGHT.normal},
                {oType = "font", content = "+"..self._addExp, size = 18, color = GAME_COLOR_SHADOW.property, strokeColor = GAME_COLOR_LIGHT.normal},
                {oType = "font", content = "/"..self._consumeExp, size = 18, color = GAME_COLOR_SHADOW.stress, strokeColor = GAME_COLOR_LIGHT.normal},
            }
        self._richText:setString(strTbl)
        self._showAddLevel = self:getAddGraveLevelByExp()
        if self._showAddLevel > 0 then
	        self._richLevelText:setString({
	            {oType = "font", content = self._graveLevel, size = 22, color = GAME_COLOR_SHADOW.stress},
	            {oType = "font", content = "+"..self._showAddLevel, size = 22, color = GAME_COLOR_SHADOW.property},
	            {oType = "font", content = "/"..self._maxLevel, size = 22, color = GAME_COLOR_SHADOW.stress},        	
	        })   
	    else
	    	self._richLevelText:setString({{oType = "font", content = self._graveLevel.."/"..self._maxLevel, size = 22, color = GAME_COLOR_SHADOW.stress}})
	   	end   
    else
        self._richText:setString({
                {oType = "font", content = self._curExp.."/"..self._consumeExp, size = 18, color = GAME_COLOR_SHADOW.stress, strokeColor = GAME_COLOR_LIGHT.normal},
            })
    end
    self._ccbOwner.tf_progress:setString((self._addExp+self._curExp).."/"..self._consumeExp)
    self._progressStencil:setPositionX(curValue*self._progressWidth - self._progressWidth)
    self._preProgressStencil:setPositionX(tempValue*self._progressWidth - self._progressWidth)
end

function QUIWidgetMountInfoGrave:initGraveMountList()
	for i,v in ipairs(self._graveMountList) do
		self._graveMount[i] = QUIWidgetItemsBox.new()
		self._ccbOwner.sheet_layout:addChild(self._graveMount[i])
		self._graveMount[i]:addEventListener(QUIWidgetItemsBox.EVENT_CLICK, handler(self, self._itemClickHandler))
		self._graveMount[i]:addEventListener(QUIWidgetItemsBox.EVENT_MINUS_CLICK, handler(self, self._itemMinusClickHandler))
		self._graveMount[i]:setPositionX(186 + 160 * (i - 1))
		self._graveMount[i]:setPositionY(41)
		local itemNums = remote.items:getItemsNumByID(v.id)
		self._graveMount[i]:setGoodsInfoByID(v.id, itemNums)
	end
end

function QUIWidgetMountInfoGrave:updateGraveMountList()
	for i,v in ipairs(self._graveMountList) do
		local  item = self._graveMount[i]
		local haveNum = self._graveMountHaveNum[v.id] or 0
		local costNum = 0
		if self._materials[v.id] then
			costNum = self._materials[v.id].num or 0
		end
		if haveNum == 0 then
			makeNodeFromNormalToGray(item)
			item:showMustMinusButton(false)
		else
			makeNodeFromGrayToNormal(item)
			item:showMustMinusButton(costNum > 0)
		end
		local showCount = haveNum
		if costNum > 0 then
			showCount = costNum.."/"..haveNum
		end
		item:setItemCount(showCount)
	end
end 

function QUIWidgetMountInfoGrave:getTotalExp()
    local exp = 0
	for i, v in pairs(self._materials) do
		local itemConfig = db:getItemByID(v.itemId)
		local itemNum = v.num or 0
		if q.isEmpty(itemConfig) == false and itemConfig.exp_num then
			exp = exp + itemConfig.exp_num*itemNum
		end
    end
    return exp
end

function QUIWidgetMountInfoGrave:getAddGraveLevelByExp( )
	local exp = self:getTotalExp()
	local showAddLevel = 0
    for ii = self._graveLevel+1,self._maxLevel do
        local graveConfig = remote.mount:getGraveInfoByAptitudeLv(self._mountConfig.aptitude, ii)
        if q.isEmpty(graveConfig) == false then
            if exp >= graveConfig.grave_exp then
            	exp = exp - graveConfig.grave_exp
            	showAddLevel = showAddLevel + 1
            else
            	if (self._curExp + exp) >= graveConfig.grave_exp then
            		showAddLevel = showAddLevel + 1
            	end
            	break
            end
        end
    end
    return showAddLevel
end

function QUIWidgetMountInfoGrave:showSelectAnimation(itemId, index)
    local icon = QUIWidgetItemsBox.new()
    icon:setGoodsInfoByID(itemId, 0)
	icon:setScale(0.4)

    local itemWidget = self._graveMount[index]
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


function QUIWidgetMountInfoGrave:_itemClickHandler(event)
	app.sound:playSound("common_item")
    if self._isMax then
        app.tip:floatTip("雕刻经验已满，无法再增加经验")
        return
    end    
	local exp = self:getTotalExp()
	local costExp = 0
	local needExp = self._consumeExp - self._curExp - exp
    if needExp <= 0 then
    	if self._graveLevel + self._showAddLevel >= self._maxLevel then
    		app.tip:floatTip("雕刻经验已满，无法再增加经验")
    		return
    	end
    
    	for ii = 1,self._showAddLevel+1 do
	    	local newConfig = remote.mount:getGraveInfoByAptitudeLv(self._mountConfig.aptitude, self._graveLevel + ii)
			if newConfig ~= nil then
				costExp = costExp + newConfig.grave_exp or 1
			end
		end
        needExp = costExp - self._curExp - exp
    end

	local itemId = event.itemID or 0
	local itemConfig = db:getItemByID(itemId)
	local maxNum = self._graveMountHaveNum[itemId]

	if maxNum <= 0 then
		QQuickWay:addQuickWay(QQuickWay.ITEM_DROP_WAY, itemId, 1)
		return
	end
	local curUseNum = 0
	if not self._materials[itemId] then
		self._materials[itemId] = {}
	end
	curUseNum = (self._materials[itemId].num or 0)
	self._materials[itemId].itemId = itemId
	
	if curUseNum >= maxNum then
		app.tip:floatTip("雕刻材料不足")
		return		
	end
	local addNum = 1
	if q.isEmpty(itemConfig) == false and itemConfig.exp_num then
		if needExp > maxNum*itemConfig.exp_num then
			addNum = maxNum
		else
			addNum = math.max(1,math.ceil(math.abs(needExp)/itemConfig.exp_num))
		end
	end
	self._materials[itemId].num = (self._materials[itemId].num or 0) + addNum

	if self._materials[itemId].num > maxNum then
		-- app.tip:floatTip("所选道具数量已达上限")
		self._materials[itemId].num = maxNum
	end

	for i,v in ipairs(self._graveMountList) do
		if v.id == itemId then
			self:showSelectAnimation(itemId,i)
			break
		end
	end
	
	self:updateGraveMountList()
	self:updateProgress()
end


function QUIWidgetMountInfoGrave:_itemMinusClickHandler(event)
	local itemId = event.itemID
	if not self._materials[itemId] then
		return
	end
	if self._materials[itemId].num and self._materials[itemId].num > 0 then
		self._materials[itemId].num = self._materials[itemId].num - 1

		self:updateGraveMountList()
		self:updateProgress()
	end
end

function QUIWidgetMountInfoGrave:_onTriggerReset()
    app.sound:playSound("common_small")
    local costValue = db:getConfigurationValue("GRAVE_RETURN_COST") or 0
    costValue = tonumber(costValue)
    if costValue > remote.user.token then
        QQuickWay:addQuickWay(QQuickWay.TOKEN_DROP_WAY, nil)
        return
    end

	local awards = {}
    local tblCusume = string.split(self._mountInfo.grave_consume,";")
    for k,v in pairs(tblCusume or {}) do
        local tbl = string.split(v,"^")
        local itemId = tbl[1]
        local itemCount = tonumber(tbl[2] or 0)
        local itemConfig = db:getItemByID(itemId)
        if itemCount > 0  then
            table.insert(awards, {id = itemId,typeName=ITEM_TYPE.ITEM,count = itemCount})
        end
    end
    local tipStr = string.format("##n花费##e%s钻石##n，可以将##e%s##n的雕刻等级重置到##e0级##n，并返还所消耗的材料，是否重置雕刻等级?",costValue, self._mountConfig.name)
    app:alert({content = tipStr, title = "系统提示", 
        callback = function(callType)
            if callType == ALERT_TYPE.CONFIRM then
                remote.mount:zuoqiCancelGraveRequest(self._mountId, function(data)
			  		local dialog = app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogAwardsAlert",
		    			options = {awards = awards, callBack = function ()
		    				
			    		end}},{isPopCurrentDialog = false} )
			    	dialog:setTitle("恭喜您获得返还材料")
                end)
            end
        end, isAnimation = true, colorful = true}, true, true)   
end

function QUIWidgetMountInfoGrave:_onTriggerGrave()
	local eatItems = {}
	for _,v in pairs(self._materials) do
		if v.num > 0 then
			table.insert(eatItems, {type = v.itemId, count = v.num})
		end
	end
    if q.isEmpty(eatItems) then
    	app.tip:floatTip("需要先添加雕刻材料")
    	return
    end

    oldmountInfo = clone(self._mountInfo)
    self._masterProp, self._oldmasterLevel = remote.mount:getGraveTalantMasterInfo(self._mountConfig.aptitude, oldmountInfo.grave_level)
	remote.mount:zuoqiGraveRequest(self._mountId, eatItems, function(data)
			if data.items then remote.items:setItems(data.items) end
			if self:safeCheck() then
				self:setMountId(self._mountId)
			end
			local newMountInfo = remote.mount:getMountById(self._mountId)
			if oldmountInfo.grave_level ~= newMountInfo.grave_level then
				-- app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogMountGraveSuccess", 
				-- 	options = {oldmountInfo = oldmountInfo, newMountInfo = newMountInfo, mountID = self._mountId , callback = handler(self, self._checkMountGraveLevelUp)}}, {isPopCurrentDialog = false})
				self:_checkMountGraveLevelUp(newMountInfo,oldmountInfo)
			else	
	    		app.tip:floatTip("雕刻成功")
			end
		end, 
		function (data)
		end)
   
end

function QUIWidgetMountInfoGrave:_checkMountGraveLevelUp(newMountInfo,oldmountInfo)
	local masterProp, masterLevel = remote.mount:getGraveTalantMasterInfo(self._mountConfig.aptitude, self._mountInfo.grave_level)
	self:graveUpSucceed(newMountInfo,oldmountInfo,masterLevel)

	remote.herosUtil:dispatchEvent({name = remote.herosUtil.EVENT_REFESH_BATTLE_FORCE})
end

function QUIWidgetMountInfoGrave:graveUpSucceed(newMountInfo,oldmountInfo,masterLevel)
	local effectShow = QUIWidgetAnimationPlayer.new()
	effectShow:setPositionY(45)
	self._ccbOwner.node_mount:addChild(effectShow,999)
	effectShow:playAnimation("ccb/effects/qianghua_effect_g.ccbi",nil,function ()
		effectShow:removeFromParent()
	end)
	app.sound:playSound("equipment_enhance")
	self._changeLevel = (newMountInfo.grave_level or 0) - (oldmountInfo.grave_level or 0)
	self:showUpdateEffect(self._changeLevel, masterLevel)
end

function QUIWidgetMountInfoGrave:showUpdateEffect(addLevel, masterLevel)
	if addLevel > 0 then
		local oldConfig = remote.mount:getGraveInfoByAptitudeLv(self._mountConfig.aptitude, self._graveLevel - addLevel)
		local newConfig = remote.mount:getGraveInfoByAptitudeLv(self._mountConfig.aptitude, self._graveLevel)

        self.attributeNum = 1
		self:_setAttributeInfo("全队攻击：", string.format("%0.3f",(oldConfig.team_attack_percent or 0) * 100), string.format("%0.3f",(newConfig.team_attack_percent or 0) * 100))
		self:_setAttributeInfo("全队生命：", string.format("%0.3f",(oldConfig.team_hp_percent or 0) * 100), string.format("%0.3f",(newConfig.team_hp_percent or 0) * 100))
		self:_setAttributeInfo("全队物防：", string.format("%0.3f",(oldConfig.team_armor_physical_percent or 0) * 100), string.format("%0.3f",(newConfig.team_armor_physical_percent or 0) * 100))
		self:_setAttributeInfo("全队法防：", string.format("%0.3f",(oldConfig.team_armor_magic_percent or 0) * 100), string.format("%0.3f",(newConfig.team_armor_magic_percent or 0) * 100))
		self:_setAttributeInfo("全队攻击：", oldConfig.team_attack_value, newConfig.team_attack_value)
		self:_setAttributeInfo("全队生命：", oldConfig.team_hp_value, newConfig.team_hp_value)
		self:_setAttributeInfo("全队物防：", oldConfig.team_armor_physical, newConfig.team_armor_physical)
		self:_setAttributeInfo("全队法防：", oldConfig.team_armor_magic, newConfig.team_armor_magic)
	end
	if masterLevel > self._oldmasterLevel then
		self._parent:enableTouchSwallowTop()
	end
	self:_showSucceedEffect(masterLevel)
end

function QUIWidgetMountInfoGrave:_setAttributeInfo(str, oldValue, newValue)
	local value = tonumber(string.format("%0.3f",(newValue or 0) - (oldValue or 0)))
	if self.attributeNum <= 4 and value ~= 0 then
		table.insert(self._attributeInfo, {name = str, value = value})
        self.attributeNum = self.attributeNum + 1
	end
end

function QUIWidgetMountInfoGrave:_showSucceedEffect(masterLevel)
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
			strengthenEffectShow._ccbOwner.title_strengthen:setString("等级  ＋"..self._changeLevel)
			if self._attributeInfo ~= nil then
				local index = 1
				strengthenEffectShow._ccbOwner.node_1:setVisible(false)
				strengthenEffectShow._ccbOwner.node_2:setVisible(false)
				for _,propInfo in ipairs(self._attributeInfo) do
					strengthenEffectShow._ccbOwner["tf_name"..index]:setString(propInfo.name .. "  ＋" .. propInfo.value)
					strengthenEffectShow._ccbOwner["node_"..index]:setVisible(true)
					index = index + 1
					if index > 4 then
						break
					end
				end
			end

			self._changeLevel = 0
			self._attributeInfo = {}
		end, function()
			if masterLevel > self._oldmasterLevel then --天赋激活
				if self._parent ~= nil then 
					self._parent:disableTouchSwallowTop()
				end
	
				local successTip = app.master.MOUNT_GRAVE_MASTER_TIP
				if app.master:getMasterShowState(successTip) then
					local mountConfig = db:getCharacterByID(self._mountId)
					masterProp, masterLevel = remote.mount:getGraveTalantMasterInfo(mountConfig.aptitude, self._mountInfo.grave_level)
					local newMasterInfo = remote.mount:getGraveTalantMasterInfoByLevel(mountConfig.aptitude, masterLevel)

					app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogMountTalentSuccess",
						options = { mountId = self._mountId, successTip = successTip,mountConfig = mountConfig,newMasterInfo = newMasterInfo,titilePath = QResPath("grave_moun_titile_path")[2],
						mountInfo = self._mountInfo,talentDes = "雕刻等级提升激活雕刻法阵:"}},{isPopCurrentDialog = false})
				end		
			end
		end)
end

return QUIWidgetMountInfoGrave
