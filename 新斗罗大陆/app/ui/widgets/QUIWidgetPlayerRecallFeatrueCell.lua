local QUIWidget = import("...widgets.QUIWidget")
local QUIWidgetPlayerRecallFeatrueCell = class("QUIWidgetPlayerRecallFeatrueCell", QUIWidget)

local QUIWidgetQlistviewItem = import(".QUIWidgetQlistviewItem")
local QUIWidgetItemsBox = import("...widgets.QUIWidgetItemsBox")
local QUIViewController = import("...ui.QUIViewController")
local QListView = import("...views.QListView")

function QUIWidgetPlayerRecallFeatrueCell:ctor(options)
	local ccbFile = "ccb/Widget_playerRecall_feature.ccbi"
	local callBacks = {
		-- {ccbCallbackName = "onTriggerOK", callback = handler(self, self._onTriggerOK)},
		-- {ccbCallbackName = "onTriggerGo", callback = handler(self, self._onTriggerGo)},
    }
	QUIWidgetPlayerRecallFeatrueCell.super.ctor(self, ccbFile, callBack, options)
end

function QUIWidgetPlayerRecallFeatrueCell:getContentSize()
	return self._ccbOwner.cellSize:getContentSize()
end

function QUIWidgetPlayerRecallFeatrueCell:setInfo(info)
	if not info or next(info) == nil then return end
	self._info = info
	
	local nameStr = ""
	local numStr = ""
	if info.type == 2 then
		nameStr = "单笔充值"
		numStr = "次数："
	elseif info.type == 3 then
		-- 目前沒有這個類型的配置，預留type
		nameStr = "累计充值"
		numStr = "进度："
	end
	self._ccbOwner.tf_name:setString(nameStr.."满"..info.chongzhi_jine.."元获得")

	self._ccbOwner.node_info:setVisible(true)
	self._ccbOwner.node_btn_ok:setVisible(false)
	self._ccbOwner.node_btn_go:setVisible(false)
	self._ccbOwner.sp_ishave:setVisible(false)
	self._ccbOwner.tf_btn_go:setString("充  值")

	local playerRecallInfo = remote.playerRecall:getInfo()
	local curTaskInfo = playerRecallInfo[tostring(info.id)]
	local isReady = (curTaskInfo and curTaskInfo.completeCount or 0) > 0
	local isComplete = info.complete_count <= (curTaskInfo and curTaskInfo.awardCount or 0)

	-- self._ccbOwner.tf_num:setString("领奖次数："..(curTaskInfo and curTaskInfo.awardCount or 0).."/"..info.complete_count)
	self._ccbOwner.tf_num:setString(isReady and "1/1" or "0/1")

	if isComplete then
		self._ccbOwner.sp_ishave:setVisible(true)
	else
		if isReady then
			self._ccbOwner.node_btn_ok:setVisible(true)
		else
			self._ccbOwner.node_btn_go:setVisible(true)
		end
	end

	self._data = {}
	local luckyDrawConfig = remote.playerRecall:getLuckyDrawListByLuckyDrawId(info.lucky_draw)
	if not luckyDrawConfig or next(luckyDrawConfig) == nil then return end

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

	self:_initListView()
end

function QUIWidgetPlayerRecallFeatrueCell:_initListView()
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

function QUIWidgetPlayerRecallFeatrueCell:_renderItemCallBack(list, index, info)
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
		item._itemBox:setPosition(ccp(45,55))
		item._ccbOwner.parentNode:addChild(item._itemBox)
		item._ccbOwner.parentNode:setContentSize(CCSizeMake(90,90))
	end
	item._itemBox:setGoodsInfo(data.id, data.type, data.count)
    info.item = item
    info.size = item._ccbOwner.parentNode:getContentSize()
    list:registerItemBoxPrompt(index, 1, item._itemBox, nil, showItemInfo)

    return isCacheNode
end

function QUIWidgetPlayerRecallFeatrueCell:onTouchListView( event )
	if not event then
		return
	end
	
	if self._listView then
		self._listView:onTouch(event)
	end
end

function QUIWidgetPlayerRecallFeatrueCell:onTriggerOK()
	remote.playerRecall:playerComeBackCompleteRequest(self._info.type, self._info.id)
end

function QUIWidgetPlayerRecallFeatrueCell:onTriggerGo()
    app.sound:playSound("common_small")
	if ENABLE_CHARGE() then
		app:getNavigationManager():pushViewController(app.mainUILayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogVIPRecharge"})
	end
end

return QUIWidgetPlayerRecallFeatrueCell