local QUIWidget = import("...widgets.QUIWidget")
local QUIWidgetPlayerRecallAwardCell = class("QUIWidgetPlayerRecallAwardCell", QUIWidget)

local QUIWidgetQlistviewItem = import(".QUIWidgetQlistviewItem")
local QUIWidgetItemsBox = import(".QUIWidgetItemsBox")
local QListView = import("...views.QListView")

function QUIWidgetPlayerRecallAwardCell:ctor(options)
	local ccbFile = "ccb/Widget_playerRecall_client.ccbi"
	QUIWidgetPlayerRecallAwardCell.super.ctor(self, ccbFile, callBack, options)
end

function QUIWidgetPlayerRecallAwardCell:getContentSize()
	return self._ccbOwner.sp_normal_banner:getContentSize()
end

function QUIWidgetPlayerRecallAwardCell:setInfo(info)
	if not info or next(info) == nil then return end

	local day = info.day
	self._ccbOwner.tf_name:setString("第"..day.."天")

	local playerRecallInfo = remote.playerRecall:getInfo()
	local isReady = info.day <= playerRecallInfo.login_days
	local curTaskInfo = playerRecallInfo[tostring(info.id)]
	local isComplete = info.complete_count <= (curTaskInfo and curTaskInfo.awardCount or 0)

	if isReady and not isComplete then
		self._ccbOwner.sp_is_ready:setVisible(true)
		self._ccbOwner.sp_normal_banner:setVisible(false)
	else
		self._ccbOwner.sp_is_ready:setVisible(false)
		self._ccbOwner.sp_normal_banner:setVisible(true)
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

	if isComplete then
		self._ccbOwner.sp_choose:setVisible(true)
		-- makeNodeOpacity(self._ccbOwner.node_client, 200)
		self._ccbOwner.sp_mask:setVisible(true)
		-- makeNodeFromNormalToGray(self._ccbOwner.node_client)
	else
		self._ccbOwner.sp_choose:setVisible(false)
		-- makeNodeOpacity(self._ccbOwner.node_client, 255)
		self._ccbOwner.sp_mask:setVisible(false)
		-- makeNodeFromGrayToNormal(self._ccbOwner.node_client)
	end
end

function QUIWidgetPlayerRecallAwardCell:_initListView()
	if self._listView == nil then
		local cfg = {
			renderItemCallBack = handler(self, self._renderItemCallBack),
			isVertical = true,
	        enableShadow = false,
	        spaceY = -15,
	        totalNumber = #self._data
		}
		self._listView = QListView.new(self._ccbOwner.itemsListView, cfg)
	else
		self._listView:reload({totalNumber = #self._data})
	end
end

function QUIWidgetPlayerRecallAwardCell:_renderItemCallBack(list, index, info)
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
		item._itemBox:setPosition(ccp(40,55))
		item._ccbOwner.parentNode:addChild(item._itemBox)
		item._ccbOwner.parentNode:setContentSize(CCSizeMake(90,90))
	end
	item._itemBox:setGoodsInfo(data.id, data.type, data.count)
    info.item = item
    info.size = item._ccbOwner.parentNode:getContentSize()
    list:registerItemBoxPrompt(index, 1, item._itemBox, nil, showItemInfo)

    return isCacheNode
end

function QUIWidgetPlayerRecallAwardCell:onTouchListView( event )
	if not event then
		return
	end

	if self._listView then
		self._listView:onTouch(event)
	end
end

return QUIWidgetPlayerRecallAwardCell