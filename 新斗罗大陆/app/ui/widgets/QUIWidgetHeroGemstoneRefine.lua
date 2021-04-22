local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetHeroGemstoneRefine = class("QUIWidgetHeroGemstoneRefine", QUIWidget)

local QUIViewController = import("..QUIViewController")
local QUIHeroModel = import("...models.QUIHeroModel")
local QQuickWay = import("...utils.QQuickWay")
local QNotificationCenter = import("...controllers.QNotificationCenter")

local QUIWidgetEquipmentAvatar = import("..widgets.QUIWidgetEquipmentAvatar")
local QUIWidgetItemsBoxEnchant = import("..widgets.QUIWidgetItemsBoxEnchant")



-- 发生变化需要外部响应的更新数据
QUIWidgetHeroGemstoneRefine.GEMSTONE_REFINE_EVENT_UPDATA = "GEMSTONE_REFINE_EVENT_UPDATA"

-- 提示文本
-- 达到满级
QUIWidgetHeroGemstoneRefine.TIPS_REFINE_MAX = "已精炼至最大等级"
-- 未选择
QUIWidgetHeroGemstoneRefine.TIPS_NO_SELECTED = "尚未添加魂骨碎片"
-- 选择的经验已经可以精炼到下一等级
QUIWidgetHeroGemstoneRefine.TIPS_REFINE_TO_NEXT = "精炼经验已满"
-- 摘除时并没有历史消耗
QUIWidgetHeroGemstoneRefine.TIPS_NONE_HISTORY = "魂骨尚未精炼"

function QUIWidgetHeroGemstoneRefine:ctor(options)
	local ccbFile = "ccb/Widget_Baoshi_refine.ccbi"
	local callBacks = {
			{ccbCallbackName = "onTriggerReset", callback = handler(self, self._onTriggerReset)},
			{ccbCallbackName = "onTriggerAutoAdd", callback = handler(self, self._onTriggerAutoAdd)},
			{ccbCallbackName = "onTriggerRefine", callback = handler(self, self._onTriggerRefine)},
			{ccbCallbackName = "onTriggerSelect", callback = handler(self, self._onTriggerSelect)},
			{ccbCallbackName = "onTriggerTips", callback = handler(self, self._onTriggerTips)},
		}
	QUIWidgetHeroGemstoneRefine.super.ctor(self,ccbFile,callBacks,options)

	q.setButtonEnableShadow(self._ccbOwner.btn_reset)
	q.setButtonEnableShadow(self._ccbOwner.btn_auto_add)
	q.setButtonEnableShadow(self._ccbOwner.btn_refine)

	cc.GameObject.extend(self)
	self:addComponent("components.behavior.EventProtocol"):exportMethods()

	self._actorId = nil
	self._gemstoneSid = nil
	self._resetNeedNum = db:getConfigurationValue("GEMSTONE_REFINE_RETURN") or 50

	self:reset()
end

function QUIWidgetHeroGemstoneRefine:reset()
	self._gemstoneInfo = nil
	self._itemConfig = nil

	self._isMax = false				-- 是否满级
	self._canUplevel = false		-- 是否可以精炼升级
	self._itemsData = nil

	if not q.isEmpty(self._items) then
		for _, item in ipairs(self._items) do
			item:removeFromParentAndCleanup(true)
		end
	end 
	self._items = {}
end

-- 当选择碎片发生变化时调用
function QUIWidgetHeroGemstoneRefine:_onSelectedChanged()
	local levelInfo = remote.gemstone:getCurrentRefineInfoByItemList(self._gemstoneSid, self._itemsData)

	-- 更新widget显示
	for index, data in ipairs(self._itemsData) do
		self._items[index]:setInfo(data)
	end

	-- 更新经验条
	if self._levelInfo.level < levelInfo.level then
		levelInfo.exp = self._levelInfo.nextExp
		levelInfo.nextExp = self._levelInfo.nextExp
		self._canUplevel = true
	else
		self._canUplevel = false
	end
	self:_setExpBar(levelInfo.exp, levelInfo.nextExp, self._levelInfo.isMax)
end

-- item被选中时的回调
function QUIWidgetHeroGemstoneRefine:itemClickHandler(event)
	if self._isMax then
		app.tip:floatTip(QUIWidgetHeroGemstoneRefine.TIPS_REFINE_MAX)
		return
	end

	if self._canUplevel then
		app.tip:floatTip(QUIWidgetHeroGemstoneRefine.TIPS_REFINE_TO_NEXT)
		return
	end

	local itemId = event.itemID
	for _, data in ipairs(self._itemsData) do
		if data.id == itemId then
			if data.selectedCount + 1 <= data.count then
				data.selectedCount = data.selectedCount + 1
				self:_showSelectAnimation(data, event.source, self._ccbOwner.exp_effect_target)
				self:_onSelectedChanged()
			end
		end
	end
end

-- item被减去时的回调
function QUIWidgetHeroGemstoneRefine:itemMinusClickHandler(event)
	local itemId = event.itemID
	for _, data in ipairs(self._itemsData) do
		if data.id == itemId then
			if data.selectedCount - 1 >= 0 then
				data.selectedCount = data.selectedCount - 1
				self:_onSelectedChanged()
			end
		end
	end
end


-- 开启级联的节点透明度
function QUIWidgetHeroGemstoneRefine:_setNodeCascadeOpacityEnabled( node )
    if node then
        node:setCascadeOpacityEnabled(true)
        local children = node:getChildren()
        if children then
            for index = 0, children:count()-1, 1 do
                local tempNode = children:objectAtIndex(index)
                local tempNode = tolua.cast(tempNode, "CCNode")
                if tempNode then
                    self:_setNodeCascadeOpacityEnabled(tempNode)
                end
            end
        end
    end
end

-- 展示选中item的移动动画
function QUIWidgetHeroGemstoneRefine:_showSelectAnimation(selectData, item, targetCcbNode)
    local icon = QUIWidgetItemsBoxEnchant.new()
    icon:setInfo(selectData)
    icon:setNumVisibility(false)
    icon:setNameVisibility(false)
    icon:showMinusButton(false)

    self:_setNodeCascadeOpacityEnabled(icon)

    local p = item:convertToWorldSpaceAR(ccp(0,0))
	icon:setPosition(p.x, p.y)
	
	local page = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
	local view = page:getView()
	
    view:addChild(icon)
    icon:setScale(0.8)
    local targetP = targetCcbNode:convertToWorldSpaceAR(ccp(0,0))
    local arr = CCArray:create()
    
    local bezierConfig = ccBezierConfig:new()
    bezierConfig.endPosition = targetP
    bezierConfig.controlPoint_1 = ccp(p.x + (targetP.x - p.x) * 0.333, p.y + (targetP.y- p.y) * 0.8)
    bezierConfig.controlPoint_2 = ccp(p.x + (targetP.x - p.x) * 0.667, p.y + (targetP.y- p.y) * 1)
    local bezierTo = CCBezierTo:create(0.4, bezierConfig)
    arr:addObject(CCSequence:createWithTwoActions(bezierTo, CCDelayTime:create(0.2)))
    arr:addObject(CCCallFunc:create(function()
            icon:removeFromParentAndCleanup(true)
        end))
    local seq = CCSequence:create(arr)
    icon:runAction(CCSpawn:createWithTwoActions(seq, CCFadeTo:create(0.6, 0)))
end

-- 使用缓存的信息快捷更新,若没有缓存应该先调用setInfo 此函数不做处理
function QUIWidgetHeroGemstoneRefine:updateInfo()
	if self._actorId == nil or self._gemstoneSid == nil then
		return
	end

	self:setInfo(self._actorId, self._gemstoneSid)
	self:dispatchEvent({ name = QUIWidgetHeroGemstoneRefine.GEMSTONE_REFINE_EVENT_UPDATA })
end

-- 设置信息
function QUIWidgetHeroGemstoneRefine:setInfo(actorId, gemstoneSid, gemstonePos)
	self:reset()

	self._actorId = actorId
	self._gemstoneSid = gemstoneSid
	self._gemstoneInfo = remote.gemstone:getGemstoneById(self._gemstoneSid)
	self._itemConfig = db:getItemByID(self._gemstoneInfo.itemId)
	self._itemsData = remote.gemstone:getStonePieceByTypeAndQuality(self._itemConfig.gemstone_type)

	self:_initGemstoneAvatar()
	self:_initTitle()
	self:_initItems()
	self:_initOtherShow()
end

-- 创建魂骨碎片框
function QUIWidgetHeroGemstoneRefine:_createItem()
	local item = QUIWidgetItemsBoxEnchant.new()
	item:addEventListener(QUIWidgetItemsBoxEnchant.EVENT_CLICK, handler(self, self.itemClickHandler))
	item:addEventListener(QUIWidgetItemsBoxEnchant.EVENT_MINUS_CLICK, handler(self, self.itemMinusClickHandler))
	item:setScale(0.9)
	item:setNameVisibility(false)

	return item
end

-- 初始化展示魂骨item
function QUIWidgetHeroGemstoneRefine:_initGemstoneAvatar()
	if self._gemStoneWidget ~= nil then
		self._gemStoneWidget:removeFromParentAndCleanup(true)
		self._gemStoneWidget = nil
	end

	self._gemStoneWidget = QUIWidgetEquipmentAvatar.new()
	self._ccbOwner.node_icon:addChild(self._gemStoneWidget)

	local craftLevel = self._gemstoneInfo.craftLevel or 0
	local godLevel = self._gemstoneInfo.godLevel or 0
	local mixLevel = self._gemstoneInfo.mix_level or 0
	local refineLevel = self._gemstoneInfo.refine_level or 0

	self._gemStoneWidget:setGemstonInfo(self._itemConfig, craftLevel, 1.0, godLevel, mixLevel, refineLevel)
	self._gemStoneWidget:hideAllColor()
end

-- 初始化魂骨标题
function QUIWidgetHeroGemstoneRefine:_initTitle()
    local level,color = remote.herosUtil:getBreakThrough(self._gemstoneInfo.craftLevel) 
    local name = self._itemConfig.name
	local advancedLevel = self._gemstoneInfo.godLevel
	local mixLevel = self._gemstoneInfo.mix_level or 0
	name = remote.gemstone:getGemstoneNameByData(name,advancedLevel,mixLevel)

    if level > 0 then
    	name = name .. "＋".. level
	end
	
	local gemstoneType = remote.gemstone:getTypeDesc(self._itemConfig.gemstone_type)
	local title = string.format("LV.%d  %s 【%s】", self._gemstoneInfo.level, name, gemstoneType)
	self._ccbOwner.tf_item_name:setString(title)

	local fontColor = BREAKTHROUGH_COLOR_LIGHT[color]
	self._ccbOwner.tf_item_name:setColor(fontColor)
	self._ccbOwner.tf_item_name = setShadowByFontColor(self._ccbOwner.tf_item_name, fontColor)
end

-- 初始化消耗items
function QUIWidgetHeroGemstoneRefine:_initItems()
	for index, data in ipairs(self._itemsData) do
		local item = self:_createItem()

		item:setInfo(data)
		self._ccbOwner["node_item_" .. index]:addChild(item)
		self._ccbOwner["tf_exp_" .. index]:setString("经验+" .. remote.gemstone:getRefinePieceExp(data.id))
		table.insert(self._items, item)
	end
end

-- 更新tips
function QUIWidgetHeroGemstoneRefine:_updataLimit(refineInfo)
	local needMixLevel = 0
	if refineInfo and refineInfo.mix_limit then
		needMixLevel = refineInfo.mix_limit
	end

	local mixLevel = self._gemstoneInfo.mix_level or 0
	local tipText = string.format("融合至%d星", needMixLevel)
	local showTip = false

	if mixLevel < needMixLevel then
		showTip = true
	end

	self._ccbOwner.tf_force:setString(tipText)
	local width = self._ccbOwner.tf_force:getContentSize().width

	local lineHeight = self._ccbOwner.ly_line:getContentSize().height
	self._ccbOwner.ly_line:setContentSize(width, lineHeight)
	self._ccbOwner.tf_normal_2:setPositionX(self._ccbOwner.tf_force:getPositionX() + width + 2)

	self._isMax = self._levelInfo.isMax
	self._ccbOwner.sp_max:setVisible(self._levelInfo.isMax)
	self._ccbOwner.node_tips:setVisible(showTip)
	self._ccbOwner.node_items:setVisible(not self._levelInfo.isMax)
	self._ccbOwner.node_buttom:setVisible(not showTip and not self._levelInfo.isMax)
end

-- 初始化其他显示内容
function QUIWidgetHeroGemstoneRefine:_initOtherShow()
	self._levelInfo = remote.gemstone:getCurrentRefineInfoByItemList(self._gemstoneSid, self._itemsData, true)
	local curRefineInfo = remote.gemstone:getRefineConfigByIdAndLevel(self._gemstoneInfo.itemId, self._levelInfo.level)
	local nextRefineInfo = remote.gemstone:getRefineConfigByIdAndLevel(self._gemstoneInfo.itemId, self._levelInfo.level + 1)
	if not curRefineInfo then
		self._attribute = remote.gemstone:convertRefineAttribute(nextRefineInfo, true)
	else
		self._attribute = remote.gemstone:convertRefineAttribute(curRefineInfo)
	end

	self:_updataLimit(nextRefineInfo)

	local attributes = self._attribute
	self._ccbOwner.tf_name:setString(attributes.valueName .. "：")
	self._ccbOwner.tf_value:setString("+" .. attributes.value)
	self._ccbOwner.tf_name_percent:setString(attributes.percentName .. "：")
	self._ccbOwner.tf_value_percent:setString("+" .. attributes.percent)

	if nextRefineInfo then
		self._needMoney = nextRefineInfo.cost_money
		self:_setNeedMoney(self._needMoney)
	end
	
	self:_setExpBar(self._levelInfo.exp, self._levelInfo.nextExp, self._levelInfo.isMax)
	self._ccbOwner.tf_value_level:setString(tostring(self._levelInfo.level))

	self:_setSelect(remote.gemstone:getRefineFilterEnable())
end

-- 设置所需金币
function QUIWidgetHeroGemstoneRefine:_setNeedMoney(need)
	local color = UNITY_COLOR.red
	if need <= remote.user.money then
		color = UNITY_COLOR.green
	end

	self._ccbOwner.tf_money:setString(need)
	self._ccbOwner.tf_money:setColor(color)
end

-- 设置经验条,未做范围判断
function QUIWidgetHeroGemstoneRefine:_setExpBar(expNow, expMax, isShowMax)
	local scaleX = 1.0
	local showStr = "MAX"

	if not isShowMax then
		scaleX = expNow / expMax
		showStr = string.format("%d/%d", expNow, expMax)
	end

	self._ccbOwner.exp_bar:setScaleX(scaleX)
	self._ccbOwner.exp:setString(showStr)
end

-- 设置是否选中“不添加海神碎片”
function QUIWidgetHeroGemstoneRefine:_setSelect(isSelect)
	self._isSelect = isSelect
	remote.gemstone:setRefineFilterEnable(isSelect)
	self._ccbOwner.sp_select:setVisible(isSelect)
end

-- 精炼
function QUIWidgetHeroGemstoneRefine:_onRefine()
	local oldAttributes = clone(self._attribute)
	local oldGemstoneInfo = clone(self._gemstoneInfo)
	local oldLevelInfo = clone(self._levelInfo)

	local requestData = {}
	for _, itemInfo in ipairs(self._itemsData) do
		if itemInfo.selectedCount > 0 then
			table.insert(requestData, { type = itemInfo.id, count = itemInfo.selectedCount })
		end
	end

	remote.gemstone:gemstoneRefineRequest(self._gemstoneSid, requestData, function(data)
		-- 精炼成功
		self:updateInfo()

		local newAttributes = self._attribute
		local newGemstoneInfo = self._gemstoneInfo

		-- 升级成功
		if oldLevelInfo.level ~= self._levelInfo.level then
			if self._canUplevel then
				self._canUplevel = false
			end

			local options = {
				itemConfig = self._itemConfig,
				oldGemstoneInfo = oldGemstoneInfo,
				newGemstoneInfo = newGemstoneInfo,
				
				newAttributes = newAttributes,
				oldAttributes = oldAttributes
			}
			
			app:getNavigationManager():pushViewController(app.middleLayer, {
					uiType=QUIViewController.TYPE_DIALOG, 
					uiClass="QUIDialogGemstoneRefineSuccess",
					options = options
				},{
					isPopCurrentDialog = false
				})
		else
			app.tip:floatTip("精炼成功")
		end
	end)
end

-- 精炼摘除
function QUIWidgetHeroGemstoneRefine:_onReset()
	local awards = remote.gemstone:getRefineHistoryItems(self._gemstoneSid)
	remote.gemstone:gemstoneCancelRefineRequest(self._gemstoneSid, function(data)
		self:updateInfo()

		-- 展示奖励页面
		local dialog = app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogEnchantResetAwardsAlert",
			options = {awards = awards, callBack = function()
			end}}, {isPopCurrentDialog = false} )
		dialog:setTitle("魂骨精炼摘除返还以下道具")
	end)
end

-- 点击精炼摘除按钮
function QUIWidgetHeroGemstoneRefine:_onTriggerReset(e)
	local history = remote.gemstone:getRefineHistoryItems(self._gemstoneSid)
	if q.isEmpty(history) then
		app.tip:floatTip(QUIWidgetHeroGemstoneRefine.TIPS_NONE_HISTORY)
		return
	end

	local resetCallback = function(callType)
		if callType == ALERT_TYPE.CONFIRM then
			if remote.user.token < self._resetNeedNum then
				QQuickWay:addQuickWay(QQuickWay.TOKEN_DROP_WAY, nil)
			else
				self:_onReset()
			end
		end
	end

	local content = string.format("##n是否花费##e%d钻石##n，摘除这件魂骨上的##e所有精炼材料##n？摘除后，返还##e全部精炼材料##n。", self._resetNeedNum)
	app:alert({content = content, title = "系统提示", callback = resetCallback, isAnimation = true, colorful = true}, true, true)
	
end

-- 点击自动添加按钮
function QUIWidgetHeroGemstoneRefine:_onTriggerAutoAdd(e)
	app.sound:playSound("common_small")

	if self._isMax then
		app.tip:floatTip(QUIWidgetHeroGemstoneRefine.TIPS_REFINE_MAX)
		return
	end

	if self._canUplevel then
		app.tip:floatTip(QUIWidgetHeroGemstoneRefine.TIPS_REFINE_TO_NEXT)
		return
	end

	local info = remote.gemstone:getCurrentRefineInfoByItemList(self._gemstoneSid, self._itemsData)
	remote.gemstone:autoSelectRefineList(info.exp, info.nextExp, self._itemsData)
	self:_onSelectedChanged()
end

-- 点击精炼按钮
function QUIWidgetHeroGemstoneRefine:_onTriggerRefine(e)
	app.sound:playSound("common_small")
	local isSelected = remote.gemstone:checkRefineSelectList(self._itemsData)

	if self._isMax then
		app.tip:floatTip(QUIWidgetHeroGemstoneRefine.TIPS_REFINE_MAX)
		return
	end

	if isSelected then
		-- 有选中

		if self._needMoney and remote.user.money < self._needMoney then
			QQuickWay:moneyQuickWay()
		else
			self:_onRefine()
		end
	else
		-- 没有任何选中
		app.tip:floatTip(QUIWidgetHeroGemstoneRefine.TIPS_NO_SELECTED)
	end
end

-- 点击复选按钮
function QUIWidgetHeroGemstoneRefine:_onTriggerSelect()
	app.sound:playSound("common_small")
	self:_setSelect(not self._isSelect)
end

-- 点击前往
function QUIWidgetHeroGemstoneRefine:_onTriggerTips()
	QNotificationCenter.sharedNotificationCenter():dispatchEvent({ name = remote.gemstone.EVENT_JUMP_MIX })
end


return QUIWidgetHeroGemstoneRefine