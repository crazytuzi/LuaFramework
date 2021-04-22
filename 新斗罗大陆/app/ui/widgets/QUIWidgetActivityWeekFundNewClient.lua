-- 
-- zxs
-- 武魂基金奖励
-- 
local QUIWidget = import(".QUIWidget")
local QUIWidgetActivityWeekFundNewClient = class("QUIWidgetActivityWeekFundNewClient", QUIWidget)
local QUIWidgetItemsBox = import("..widgets.QUIWidgetItemsBox")

QUIWidgetActivityWeekFundNewClient.EVENT_CLICK = "EVENT_CLICK"

QUIWidgetActivityWeekFundNewClient.SHOW_TYPE_DONE = "SHOW_TYPE_DONE"				-- 已领取
QUIWidgetActivityWeekFundNewClient.SHOW_TYPE_AVAILABLE = "SHOW_TYPE_AVAILABLE"		-- 可领取
QUIWidgetActivityWeekFundNewClient.SHOW_TYPE_NORMAL = "SHOW_TYPE_NORMAL"			-- 未到时间

function QUIWidgetActivityWeekFundNewClient:ctor(options)
    local ccbFile = "ccb/Widget_zhoujijin_new_client.ccbi"
    local callBacks = {
    	{ccbCallbackName = "onTriggerClick", callback = handler(self, self._onTriggerClick)}
    }
    QUIWidgetActivityWeekFundNewClient.super.ctor(self, ccbFile, callBacks, options)

    cc.GameObject.extend(self)
    self:addComponent("components.behavior.EventProtocol"):exportMethods()

    self._isReady = false
	self._itemBox = {}
	
	-- 调用显示函数的一个table
	self._showFuncTable = {
		[QUIWidgetActivityWeekFundNewClient.SHOW_TYPE_DONE] = handler(self, self._showDone),
		[QUIWidgetActivityWeekFundNewClient.SHOW_TYPE_AVAILABLE] = handler(self, self._showAvailable),
		[QUIWidgetActivityWeekFundNewClient.SHOW_TYPE_NORMAL] = handler(self, self._showNormal),
	}
end

-- 设置信息
function QUIWidgetActivityWeekFundNewClient:setInfo(param, index)
	self._info = param.info
	self._index = index or 1

	local showtype = QUIWidgetActivityWeekFundNewClient.SHOW_TYPE_NORMAL
	if param.isReady then
		showtype = QUIWidgetActivityWeekFundNewClient.SHOW_TYPE_AVAILABLE
	elseif param.isDone then
		showtype = QUIWidgetActivityWeekFundNewClient.SHOW_TYPE_DONE
	end
	
	self:setShowType(showtype)
	self:_setItems(self._info.award or {})

	self._ccbOwner.tf_day:setString(string.format("第%d天", self._index))
end

-- 设置显示状态
function QUIWidgetActivityWeekFundNewClient:setShowType(showType)
	showType = showType or QUIWidgetActivityWeekFundNewClient.SHOW_TYPE_NORMAL
	local showFunc = self._showFuncTable[showType]

	if showFunc then
		self:_reset()
		showFunc()

		for _, itemBox in ipairs(self._itemBox) do
			itemBox:setPromptIsOpen(not self._isReady)
		end
	end
end

-- 注册item点击弹窗
function QUIWidgetActivityWeekFundNewClient:registerItemBoxPrompt( index, list )
	for i, itemBox in ipairs(self._itemBox) do
		if self._itemBox[i] ~= nil then
			list:registerItemBoxPrompt(index, i, self._itemBox[i])
		end
	end
end

-- 获取内容尺寸
function QUIWidgetActivityWeekFundNewClient:getContentSize()
	local size = self._ccbOwner.content_size:getContentSize()
	size.width = size.width + 10
    return size
end





--------------------------------------
-- 以下为私有内容

-- 设置items
function QUIWidgetActivityWeekFundNewClient:_setItems(itemList)
	for _, itemBox in ipairs(self._itemBox) do
		itemBox:removeFromParentAndCleanup(true)
		itemBox = nil
	end
	self._itemBox = {}

	for i, itemInfo in ipairs(itemList) do
		local itemBox = QUIWidgetItemsBox.new()
		itemBox:addEventListener(QUIWidgetItemsBox.EVENT_CLICK, handler(self, self._clickAwardItemBox))
		self._ccbOwner["node_icon_" .. tostring(i)]:addChild(itemBox)

		local typeName = itemInfo.type
        if typeName == nil then
            typeName = itemInfo.typeName
		end
		
		itemBox:setGoodsInfo(itemInfo.id, typeName, itemInfo.count)
		itemBox:setPromptIsOpen(not self._isReady)
		
		table.insert(self._itemBox, itemBox)
	end
end

-- 重置ccb内容
function QUIWidgetActivityWeekFundNewClient:_reset()
	self._ccbOwner.sp_normal:setVisible(false)
	self._ccbOwner.sp_isDone:setVisible(false)
	self._ccbOwner.node_is_ready:setVisible(false)
	self._ccbOwner.tf_day:setString("")
	self._ccbOwner.node_done:setVisible(false)
end

-- 将界面设置为已领取
function QUIWidgetActivityWeekFundNewClient:_showDone()
	self._isReady = false

	self._ccbOwner.sp_isDone:setVisible(true)
	self._ccbOwner.node_done:setVisible(true)
end

-- 将界面设置为可领取
function QUIWidgetActivityWeekFundNewClient:_showAvailable()
	self._isReady = true

	self._ccbOwner.node_is_ready:setVisible(true)
end

-- 将界面设置为正常（没到时间 没解锁）
function QUIWidgetActivityWeekFundNewClient:_showNormal()
	self._isReady = false

	self._ccbOwner.sp_normal:setVisible(true)
end

-- 点击item时候的处理
function QUIWidgetActivityWeekFundNewClient:_clickAwardItemBox(event)
	if self._isReady then
		self:_onTriggerClick()
	else
		app.tip:itemTip(nil, event.itemID)
	end
end

-- 整个widget被点击时的处理
function QUIWidgetActivityWeekFundNewClient:_onTriggerClick()
	if self._isReady then
		self:dispatchEvent({name = QUIWidgetActivityWeekFundNewClient.EVENT_CLICK, info = self._info})
	end
end

return QUIWidgetActivityWeekFundNewClient