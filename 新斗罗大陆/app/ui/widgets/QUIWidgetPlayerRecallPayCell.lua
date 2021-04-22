local QUIWidget = import("...widgets.QUIWidget")
local QUIWidgetPlayerRecallPayCell = class("QUIWidgetPlayerRecallPayCell", QUIWidget)

local QUIWidgetQlistviewItem = import(".QUIWidgetQlistviewItem")
local QUIWidgetItemsBox = import("...widgets.QUIWidgetItemsBox")
local QUIViewController = import("...ui.QUIViewController")
local QListView = import("...views.QListView")

function QUIWidgetPlayerRecallPayCell:ctor(options)
	local ccbFile = "ccb/Widget_playerRecall_pay.ccbi"
	local callBacks = {
		-- {ccbCallbackName = "onTriggerOK", callback = handler(self, self._onTriggerOK)},
		-- {ccbCallbackName = "onTriggerGo", callback = handler(self, self._onTriggerGo)},
    }
	QUIWidgetPlayerRecallPayCell.super.ctor(self, ccbFile, callBack, options)
end

function QUIWidgetPlayerRecallPayCell:getContentSize()
	return self._ccbOwner.cellSize:getContentSize()
end

function QUIWidgetPlayerRecallPayCell:setInfo(info)
	if not info or next(info) == nil then return end
	self._info = info

	self._ccbOwner.tf_name:setString(info.desc)

	self._ccbOwner.node_info:setVisible(true)
	self._ccbOwner.node_btn_ok:setVisible(true)
	self._ccbOwner.tf_btn_ok:setString("购 买")

	local playerRecallInfo = remote.playerRecall:getInfo()
	local curTaskInfo = playerRecallInfo[tostring(info.id)]
	self._isComplete = info.complete_count <= (curTaskInfo and curTaskInfo.awardCount or 0)

	self._ccbOwner.tf_num:setString((curTaskInfo and curTaskInfo.awardCount or 0).."/"..info.complete_count)
	self._ccbOwner.tf_num_desc:setString("今日购买次数：")
	self._ccbOwner.tf_num_desc:setPositionX(self._ccbOwner.tf_num:getPositionX() - self._ccbOwner.tf_num:getContentSize().width - 5)
	if self._isComplete then
		self._ccbOwner.node_btn_ok:setVisible(false)
		self._ccbOwner.sp_ishave:setVisible(true)
		-- makeNodeFromNormalToGray(self._ccbOwner.node_btn_ok)
	else
		self._ccbOwner.node_btn_ok:setVisible(true)
		self._ccbOwner.sp_ishave:setVisible(false)
		-- makeNodeFromGrayToNormal(self._ccbOwner.node_btn_ok)
	end

	if self._ccbOwner.node_dazhe then
		self._ccbOwner.node_dazhe:removeAllChildren()
		if info.show_discount then
			local ccbProxy = CCBProxy:create()
	        local ccbOwner = {}
	        local dazheWidget = CCBuilderReaderLoad("Widget_dazhe.ccbi", ccbProxy, ccbOwner)
	        ccbOwner.chengDisCountBg:setVisible(false)
	        ccbOwner.lanDisCountBg:setVisible(false)
	        ccbOwner.ziDisCountBg:setVisible(false)
	        ccbOwner.hongDisCountBg:setVisible(true)
	        if info.show_discount >= 1 and info.show_discount < 10 then
	        	ccbOwner.discountStr:setString(info.show_discount.."折")
	    	elseif info.show_discount == 11 then
	        	ccbOwner.discountStr:setString("限时")
	        elseif info.show_discount == 12 then
	        	ccbOwner.discountStr:setString("火热")
	        elseif info.show_discount == 13 then
	        	ccbOwner.discountStr:setString("推荐")
	        end
	        self._ccbOwner.node_dazhe:addChild(dazheWidget)
		end
	end

	self._data = {}
	local luckyDrawConfig = remote.playerRecall:getLuckyDrawListByLuckyDrawId(info.lucky_draw)
	if not luckyDrawConfig or next(luckyDrawConfig) == nil then return end

	self._ccbOwner.node_item:removeAllChildren()
	local tbl = string.split(info.exchange_much, "^")
	local itemBox = QUIWidgetItemsBox.new()
	itemBox:setScale(0.7)
	itemBox:setGoodsInfo(nil, tbl[1], tonumber(tbl[2]))
	itemBox:setPromptIsOpen(true)
	self._ccbOwner.node_item:addChild(itemBox)

	local index = 1
	while true do
		local id = luckyDrawConfig["id_"..index]
		local type = luckyDrawConfig["type_"..index]
		local num = luckyDrawConfig["num_"..index]
		if type and num then
			table.insert(self._data, {id = id, type = type, count = num})
			index = index + 1
		else
			break
		end
	end

	self._buyMoreOptions = {
		maxNum = info.complete_count - (curTaskInfo and curTaskInfo.awardCount or 0),
		callback = handler(self, self.onBuyHandler),
		itemInfo = {
			itemId = luckyDrawConfig.id_1,
			itemType = luckyDrawConfig.type_1,
			itemCount = luckyDrawConfig.num_1,
			resource_1 = tbl[1],
			resource_number_1 = tonumber(tbl[2]),
		}
	}

	self:_initListView()
end

function QUIWidgetPlayerRecallPayCell:_initListView()
	if self._listView == nil then
		local cfg = {
			renderItemCallBack = handler(self, self._renderItemCallBack),
			isVertical = false,
	        enableShadow = false,
	        spaceX = -15,
	        totalNumber = #self._data
		}
		self._listView = QListView.new(self._ccbOwner.itemsListView, cfg)
	else
		self._listView:reload({totalNumber = #self._data})
	end
end

function QUIWidgetPlayerRecallPayCell:_renderItemCallBack(list, index, info)
	local function showItemInfo(x, y, itemBox, listView)
		app.tip:itemTip(itemBox._itemType, itemBox._itemID, true)
	end

    local isCacheNode = true
  	local data = self._data[index]
    local item = list:getItemFromCache()
    if not item then	       	
    	item = QUIWidgetQlistviewItem.new()
        isCacheNode = false
    end

    if not item._itemBox then
		item._itemBox = QUIWidgetItemsBox.new()
		item._itemBox:setScale(0.7)
		item._itemBox:setPosition(ccp(45,65))
		item._ccbOwner.parentNode:addChild(item._itemBox)
		item._ccbOwner.parentNode:setContentSize(CCSizeMake(100,100))
	end
	item._itemBox:setGoodsInfo(data.id, data.type, data.count)
    info.item = item
    info.size = item._ccbOwner.parentNode:getContentSize()
    list:registerItemBoxPrompt(index, 1, item._itemBox, nil, showItemInfo)

    return isCacheNode
end

function QUIWidgetPlayerRecallPayCell:onTouchListView( event )
	if not event then
		return
	end

	if self._listView then
		self._listView:onTouch(event)
	end
end

function QUIWidgetPlayerRecallPayCell:onTriggerOK()
	if self._isComplete then return end
    app.sound:playSound("common_small")
    app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogBuyMore", 
  		options = self._buyMoreOptions})
end

function QUIWidgetPlayerRecallPayCell:onBuyHandler(nums)
	if self._ccbView then
		remote.playerRecall:playerComeBackCompleteRequest(self._info.type, self._info.id, nums)
	end
end

function QUIWidgetPlayerRecallPayCell:onTriggerPrompt()
	app.tip:itemTip("token", nil, true)
end

return QUIWidgetPlayerRecallPayCell