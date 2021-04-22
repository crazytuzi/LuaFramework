
local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogSoulSpiritDevour = class("QUIDialogSoulSpiritDevour", QUIDialog)

local QUIViewController = import("..QUIViewController")
local QUIWidgetActorDisplay = import("..widgets.actorDisplay.QUIWidgetActorDisplay")
local QRichText = import("...utils.QRichText")
local QListView = import("...views.QListView")
local QQuickWay = import("...utils.QQuickWay")
local QUIWidgetHeroHead = import("..widgets.QUIWidgetHeroHead")
local QUIWidgetItemsBoxEnchant = import("..widgets.QUIWidgetItemsBoxEnchant")
local QNotificationCenter = import("...controllers.QNotificationCenter")
local QUIWidgetFcaAnimation = import("..widgets.actorDisplay.QUIWidgetFcaAnimation")
local QNavigationController = import("...controllers.QNavigationController")
local QScrollView = import("...views.QScrollView")
local QColorLabel = import("...utils.QColorLabel")

function QUIDialogSoulSpiritDevour:ctor(options)
	local ccbFile = "ccb/Dialog_SoulSpirit_Devour.ccbi"
    local callBacks = {
		{ccbCallbackName = "onTriggerClose", callback = handler(self, self._onTriggerClose)},
		{ccbCallbackName = "onTriggerAdvance", callback = handler(self, self._onTriggerAdvance)},
    }
    QUIDialogSoulSpiritDevour.super.ctor(self, ccbFile, callBacks, options)
    self.isAnimation = true
    q.setButtonEnableShadow(self._ccbOwner.btn_advance)

    

	cc.GameObject.extend(self)
	self:addComponent("components.behavior.EventProtocol"):exportMethods()
    self._isMax = false;
	self._id = options.id
    self:_initSkillScrollView()

    self._ccbOwner.frame_tf_title:setString("传 承")
    self._progressWidth = self._ccbOwner.sp_bar_progress:getContentSize().width
	local progress = q.newPercentBarClippingNode(self._ccbOwner.sp_bar_pre_progress)
	self._preProgressStencil = progress:getStencil()
    local progress = q.newPercentBarClippingNode(self._ccbOwner.sp_bar_progress)
    self._progressStencil = progress:getStencil()
    self._richText = QRichText.new({}, 400, {autoCenter = true})
    self._richText:setAnchorPoint(ccp(0.5, 0.5))
    self._ccbOwner.node_progress:addChild(self._richText)
    self._ccbOwner.tf_progress:setVisible(false)
	self:updateInfo()
    self._Devouring = false 
end

function QUIDialogSoulSpiritDevour:viewDidAppear()
	QUIDialogSoulSpiritDevour.super.viewDidAppear(self)
end

function QUIDialogSoulSpiritDevour:viewWillDisappear()
  	QUIDialogSoulSpiritDevour.super.viewWillDisappear(self)
end

function QUIDialogSoulSpiritDevour:updateInfo()
    self._soulSpiritInfo = remote.soulSpirit:getMySoulSpiritInfoById(self._id)
    if self._soulSpiritInfo == nil then
        return 
    end
    self.curInheritLv =  self._soulSpiritInfo.devour_level or 0
    self._nextInheritMod = remote.soulSpirit:getSoulSpiritInheritConfig(self.curInheritLv + 1,self._id)
    self._ccbOwner.node_avatar:removeAllChildren()
    local avatar = QUIWidgetActorDisplay.new(self._id)
    avatar:setScale(1.1)
    self._ccbOwner.node_avatar:addChild(avatar)
    self._ccbOwner.node_avatar:setScaleX(-1)   

    self._isMax = self._nextInheritMod == nil

    if not self._isMax then
        self._consumeExp = tonumber(self._nextInheritMod.exp)
    end
    self:setSABC()
	self:_updateDevourInfo()
	self:_handleListData()
	self:_updateListView()
    self:_updateSkillProp()
    self:_updateSkillDesc()
end

function QUIDialogSoulSpiritDevour:_updateDevourInfo()
	--名称
    self._characterConfig = db:getCharacterByID(self._id)
    -- if self.curInheritLv > 0 then   
    --     self._ccbOwner.tf_name:setString(self._characterConfig.name.."+"..self.curInheritLv)
    -- else
    -- end
    self._ccbOwner.tf_name:setString(self._characterConfig.name)

    local fontColor = QIDEA_QUALITY_COLOR[remote.soulSpirit:getColorByCharacherId(self._id)] or COLORS.b
    self._ccbOwner.tf_name:setColor(fontColor)
    self._ccbOwner.tf_name = setShadowByFontColor(self._ccbOwner.tf_name, fontColor)

    local NUMBERS = {"一","二","三","四","五","六"}
    self._ccbOwner.tf_d_name:setString("【传承"..NUMBERS[tonumber(self.curInheritLv+ 1)].."重】")

end

function QUIDialogSoulSpiritDevour:_updateExpInfo()


    if self._isMax then

        self._ccbOwner.tf_progress:setString("MAX")
        self._ccbOwner.tf_progress:setVisible(true)

        self._progressStencil:setPositionX(0)
        self._preProgressStencil:setPositionX(0)
        self._ccbOwner.tf_money:setVisible(false)
        self._ccbOwner.icon_money:setVisible(false)
        return
    end

    self._curExp = self._soulSpiritInfo.devour_exp or 0


    self._ccbOwner.tf_progress:setVisible(false)

    local exp = self:getTotalExp()
    self._addExp = self:getTotalExp()
    local curValue = self._curExp/self._consumeExp
    local tempValue = (self._addExp+self._curExp)/self._consumeExp
    tempValue = math.min(tempValue , 1)

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


function QUIDialogSoulSpiritDevour:_updateSkillProp()
    local propDesc = remote.soulSpirit:getPropStrList(self._nextInheritMod)

    local propDescIndex = {}
    table.insert(propDescIndex, {fieldName = "attack_value", name = "攻     击："})
    table.insert(propDescIndex, {fieldName = "hp_value", name = "生     命："})
    table.insert(propDescIndex, {fieldName = "attack_percent", name = "攻     击："})
    table.insert(propDescIndex, {fieldName = "hp_percent", name = "生     命："})
    table.insert(propDescIndex, {fieldName = "armor_magic", name = "法术防御："})
    table.insert(propDescIndex, {fieldName = "armor_physical", name = "物理防御："})
    table.insert(propDescIndex, {fieldName = "armor_magic_percent", name = "法术防御："})
    table.insert(propDescIndex, {fieldName = "armor_physical_percent", name = "物理防御："})
    for i,v in ipairs(propDescIndex) do
        local isVisible = false
        self._ccbOwner["tf_name"..i]:setString(v.name)
        for k,prop in pairs(propDesc) do
            if prop.fieldName == v.fieldName then
                isVisible = true
                self._ccbOwner["tf_value"..i]:setString("+"..prop.value)

                break
            end
        end
        self._ccbOwner["tf_name"..i]:setVisible(isVisible)
        self._ccbOwner["tf_value"..i]:setVisible(isVisible)
    end
end


function QUIDialogSoulSpiritDevour:setSABC()
    local aptitudeInfo = db:getActorSABC(self._id)
    q.setAptitudeShow(self._ccbOwner, aptitudeInfo.lower)

    self._ccbOwner["node_blue"]:setVisible(false)
    self._ccbOwner["node_purple"]:setVisible(false)
    self._ccbOwner["node_orange"]:setVisible(false)
    self._ccbOwner["node_red"]:setVisible(false)

    self._ccbOwner["node_"..aptitudeInfo.color]:setVisible(true)
end

function QUIDialogSoulSpiritDevour:_initSkillScrollView()
    if not self._scrollView then
        local itemContentSize = self._ccbOwner.sheet_skill_desc_layout:getContentSize()
        self._scrollView = QScrollView.new(self._ccbOwner.sheet_skill_desc, itemContentSize, {bufferMode = 1})
        self._scrollView:setVerticalBounce(true)
    end
end

function QUIDialogSoulSpiritDevour:_updateSkillDesc()
    self._scrollView:clear()

    local totalHeight = 0
    local skillId1 = {}
    local rnumSkillLevel = 1

    skillId1 = string.split(self._nextInheritMod.skill, ":")
    local skillConfig1 = db:getSkillByID(tonumber(skillId1[1]))
    local describe
    rnumSkillLevel = q.getRomanNumberalsByInt(self._nextInheritMod.level)

    if skillConfig1 ~= nil then
        describe = "##e"..skillConfig1.name..rnumSkillLevel.."：##n"..skillConfig1.description
    end

    local strArr  = string.split(describe,"\n") or {}
    for i, v in pairs(strArr) do
        local describe = QColorLabel.replaceColorSign(v or "", false)
        local richText = QRichText.new(describe, 380, {stringType = 1, defaultColor = GAME_COLOR_LIGHT.normal, defaultSize = 20, fontName = global.font_default})
        richText:setAnchorPoint(ccp(0, 1))
        richText:setPositionY(-totalHeight)
        self._scrollView:addItemBox(richText)
        totalHeight = totalHeight + richText:getContentSize().height
    end
    self._scrollView:setRect(0, -totalHeight, 0, 0)
end


function QUIDialogSoulSpiritDevour:_handleListData()
	self._data = {}
    local dataPiece= remote.items:getItemsByCategory(ITEM_CONFIG_CATEGORY.SOULSPIRIT_PIECE) -- 获取魂灵碎片 需要过滤出s魂灵的碎片
    for i,v in ipairs(dataPiece or {}) do
        local itemInfo = db:getItemByID(v.type)
        if itemInfo.devour_exp and itemInfo.devour_exp > 0 then 
            local order = 2
            if tonumber(ITEM_TYPE.INHERIT_PIECE) == tonumber(v.type) then
                order = 1
            else
                local soulSpiritId = remote.soulSpirit:getSoulSpiritIdByFragmentId(v.type)
                if soulSpiritId then
                    local mySoulSpiritInfo = remote.soulSpirit:getMySoulSpiritInfoById(soulSpiritId)
                    if mySoulSpiritInfo then
                        order = 2
                    else
                        order = 3
                    end
                end
            end


            local value = {id = v.type, count = v.count, order = order, selectedCount = 0, color = itemInfo.colour, aptitude = 20, exp = itemInfo.devour_exp or 0}
            table.insert(self._data, value)
        end

    end

    -- local expItem = db:getItemByID(ITEM_TYPE.INHERIT_PIECE) -- 传承碎片
    -- if expItem then
    --     local soulNum = remote.items:getItemsNumByID(expItem.id)
    --     if soulNum > 0 then
    --         local value = {id = expItem.id, count = soulNum, order = 1, selectedCount = 0, color = expItem.colour, aptitude = 20, exp = expItem.devour_exp or 0}
    --         table.insert(self._data, value)
    --     end
    -- end

    table.sort(self._data, function (x, y) 
        if x.order == y.order then
            return x.id < y.id
        else
            return x.order < y.order
        end
    end)

    --需要传承碎片的数量
end

function QUIDialogSoulSpiritDevour:_updateListView(isRefresh)
	if self._listView == nil then
		local cfg = {
			renderItemCallBack = handler(self, self.renderItemCallBack),
	     	ignoreCanDrag = true,
	     	enableShadow = false,
	     	isVertical = false,
	        spaceX = 10,
	        totalNumber = #self._data
		}
		self._listView = QListView.new(self._ccbOwner.sheet_layout,cfg)
	elseif isRefresh then
        self._listView:refreshData()
    else
        self._listView:reload({totalNumber = #self._data})
	end
	self:_updateExpInfo()
end

-- 刷新item和进度条
function QUIDialogSoulSpiritDevour:_updateItemInfo(isAll)
    if isAll then
        for index = 1, #self._data do
            local item = self._listView:getItemByIndex(index)
            if item then
                item:setInfo(self._data[index])
            end
        end
    else
        local curIndex = self._listView:getCurTouchIndex()
        if curIndex and curIndex <= #self._data then
            local curItem = self._listView:getItemByIndex(curIndex)
            if curItem then
                curItem:setInfo(self._data[curIndex])
            end
        end
    end

    self:_updateExpInfo()
end


function QUIDialogSoulSpiritDevour:renderItemCallBack(list, index, info)
    -- body
    local scale = 0.9

    local isCacheNode = true
  	local data = self._data[index]
    local item = list:getItemFromCache()
    if not item then	       	
    	item = QUIWidgetItemsBoxEnchant.new()
    	item:addEventListener(QUIWidgetItemsBoxEnchant.EVENT_CLICK, handler(self, self.itemClickHandler))
    	item:addEventListener(QUIWidgetItemsBoxEnchant.EVENT_CLICK_END, handler(self, self.itemClickEndHandler))
    	item:addEventListener(QUIWidgetItemsBoxEnchant.EVENT_MINUS_CLICK, handler(self, self.itemMinusClickHandler))
    	item:addEventListener(QUIWidgetItemsBoxEnchant.EVENT_MINUS_CLICK_END, handler(self, self.itemMinusClickEndHandler))
        isCacheNode = false
    end
    item:setInfo(data)
    item:checkNeedItem()
    item:setScale(scale)
    item:setNameVisibility(false)
    info.item = item
    info.size = CCSize(item:getContentSize().width*scale,item:getContentSize().height*scale)
    info.offsetPos = ccp(52, -47)
    list:registerTouchHandler(index, "onTouchListView")

    return isCacheNode
end

function QUIDialogSoulSpiritDevour:showSelectAnimation(itemId, itemWidget)
    local icon = QUIWidgetItemsBoxEnchant.new(true)
    icon:setGoodsInfo(itemId, ITEM_TYPE.ITEM, 0, false)
    icon:setNameVisibility(false)

    local p = itemWidget:convertToWorldSpaceAR(ccp(-display.width/2, -display.height/2))
    icon:setPosition(p.x, p.y)
    icon:setScale(0.8)
    self._ccbOwner.node_effect:removeAllChildren()
    self._ccbOwner.node_effect:addChild(icon)

    local effectPosX, effectPosY  = self._ccbOwner.node_effect:getPosition()
    local targetP = ccp(effectPosX, effectPosY+80)
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

function QUIDialogSoulSpiritDevour:levelUpAni()
    app.sound:playSound("equipment_enhance")
    local fcaAnimation = QUIWidgetFcaAnimation.new("fca/hunling_tsbao1", "res")
    self._ccbOwner.node_effect:removeAllChildren()
    self._ccbOwner.node_effect:addChild(fcaAnimation)
    fcaAnimation:playAnimation("animation", false)
    fcaAnimation:setScaleX(1.5)
    fcaAnimation:setPositionY(-10)
end

function QUIDialogSoulSpiritDevour:getCurItem(itemId)
    for i, item in pairs(self._data) do
        if item.id == itemId then
            return item
        end
    end
end


function QUIDialogSoulSpiritDevour:itemClickHandler(event)

    if self._isMax then
        app.tip:floatTip("魂师已满传承，无法吞噬增加经验")
        return
    end     
    local exp = self:getTotalExp()
    local needExp = self._consumeExp - self._curExp - exp
    if needExp <= 0 then
        app.tip:floatTip("当前经验已可以传承")
        return
    end

    local curItem = self:getCurItem(event.itemID)
    if curItem.selectedCount >= curItem.count then
        app.tip:floatTip("所选道具数量已达上限")
        return
    end

    local count = 0
    for i = curItem.selectedCount, curItem.count do
        local addNum = i - curItem.selectedCount
        if addNum*curItem.exp > needExp then
            break
        end
        count = addNum
    end

    if curItem.id == tonumber(ITEM_TYPE.INHERIT_PIECE) then
        -- count = math.floor(count/5)*5
        count = count
    end
    if count == 0 then
        app.tip:floatTip("所选道具数量不足")
        return
    end

    curItem.selectedCount = curItem.selectedCount + count
    if curItem.selectedCount > curItem.count then
        curItem.selectedCount = curItem.count
    end
    self:showSelectAnimation(event.itemID, event.source)
    
    --self:_updateListView(true)
    self:_updateItemInfo()
end

function QUIDialogSoulSpiritDevour:itemClickEndHandler(event)

end

function QUIDialogSoulSpiritDevour:itemMinusClickHandler(event)

	local curItem = self:getCurItem(event.itemID)
    if curItem and curItem.selectedCount > 0 then
        if curItem.id == tonumber(ITEM_TYPE.INHERIT_PIECE) then
            curItem.selectedCount = curItem.selectedCount - 1
        else
            curItem.selectedCount = curItem.selectedCount - 1
        end
        local itemWidget = event.source
        itemWidget:setGoodsInfo(event.itemID, ITEM_TYPE.ITEM, curItem.selectedCount.."/"..curItem.count, true)
		self:_updateExpInfo()
    end
end

function QUIDialogSoulSpiritDevour:itemMinusClickEndHandler(event)
	local curItem = self:getCurItem(event.itemID)
    if curItem then
        local itemWidget = event.source
        itemWidget:setGoodsInfo(event.itemID, ITEM_TYPE.ITEM, curItem.selectedCount.."/"..curItem.count, true)
        itemWidget:showMinusButton(curItem.selectedCount > 0)
    end
	self:_updateListView(true)
end

function QUIDialogSoulSpiritDevour:getTotalExp()
    local exp = 0
    for i, item in pairs(self._data) do
        if item.selectedCount > 0 then
            exp = exp + item.selectedCount * (item.exp or 0)
        end
    end
    return exp
end
function QUIDialogSoulSpiritDevour:_backClickHandler()
    self:_onTriggerClose()
end

function QUIDialogSoulSpiritDevour:_onTriggerClose(event)
    if q.buttonEventShadow(event, self._ccbOwner.frame_btn_close) == false then return end
	if event then
  		app.sound:playSound("common_close")
  	end
	self:playEffectOut()
end

function QUIDialogSoulSpiritDevour:_onTriggerAdvance(event)
    if self._Devouring then return end

    app.sound:playSound("common_small")
    if self._isMax then
        app.tip:floatTip("魂师已满传承，无法继续传承")
        return
    end

    if self._addExp <= 0 then
        app.tip:floatTip("所选道具数量不能为空")
        return
    end

    self._items = {}
    for i, item in pairs(self._data) do
        if item.selectedCount > 0 then
            table.insert(self._items, {type = item.id, count = item.selectedCount})
        end
    end
    local soulSpiritId = self._id
    if self._addExp > 0 and self._addExp + self._curExp < self._consumeExp then
        remote.soulSpirit:soulSpiritDevourRequest(soulSpiritId,self._items, function(data)

            if self:safeCheck() then
                self:updateInfo()
                self:levelUpAni()
            end
            end, function(data)
        end)

        return
    end
    self._isUpGrade = true
    self:_onTriggerClose()
end


function QUIDialogSoulSpiritDevour:viewAnimationOutHandler()
  	app:getNavigationManager():popViewController(app.middleLayer, QNavigationController.POP_TOP_CONTROLLER)

  	if self._isUpGrade then
    	QNotificationCenter.sharedNotificationCenter():dispatchEvent({name =remote.soulSpirit.EVENT_INHERIT_SUCCESS, items = self._items})
  	end
end 


return QUIDialogSoulSpiritDevour