local QUIWidget = import(".QUIWidget")
local QUIWidgetHighTeaReward = class("QUIWidgetHighTeaReward", QUIWidget)
local QUIWidgetItemsBox = import("..widgets.QUIWidgetItemsBox")
local QUIWidgetQlistviewItem = import("..widgets.QUIWidgetQlistviewItem")
local QListView = import("...views.QListView")


function QUIWidgetHighTeaReward:ctor(options)
	local ccbFile = "ccb/Widget_HighTea_Reward.ccbi"
	local callBacks = {
    }
	QUIWidgetHighTeaReward.super.ctor(self, ccbFile, callBacks, options)

	cc.GameObject.extend(self)
    self:addComponent("components.behavior.EventProtocol"):exportMethods()
  
end

function QUIWidgetHighTeaReward:onEnter()
	QUIWidgetHighTeaReward.super.onEnter(self)
    -- self.prompt = app:promptTips()
    -- self.prompt:addItemEventListener(self)
end

function QUIWidgetHighTeaReward:onExit()
	QUIWidgetHighTeaReward.super.onExit(self)
	-- if self.prompt ~= nil then
 --    	self.prompt:removeItemEventListener(self)
 --    	self.prompt = nil
 --    end
end

function QUIWidgetHighTeaReward:setInfo(info,myLevel)
	local canGet = info.canGet 
	local isGetten = info.isGetten 
	local showbtn = info.showbtn  == 1


	self._data = {}
	self._ccbOwner.tf_progress:setString(myLevel)
	self._awards = info.awardList or db:getluckyDrawById(info.reward_id)
	for index,value in ipairs(self._awards) do
		table.insert(self._data, {id = value.id, type = value.itemType, count = value.count})
	end

	self:_initListView()

	self._ccbOwner.tf_progress_title:setVisible(not canGet and not isGetten)
	self._ccbOwner.tf_progress:setVisible(not canGet and not isGetten)

	self._ccbOwner.node_weiwancheng:setVisible(not canGet and not isGetten)
	self._ccbOwner.node_yilingqu:setVisible(isGetten)
	self._ccbOwner.node_yidacheng:setVisible(canGet and not isGetten and not showbtn)
	self._ccbOwner.node_done:setVisible(canGet and not isGetten and  showbtn)


	if showbtn then
		self._ccbOwner.tf_name:setString(string.format("好感度达到%d级", info.level))
		self._ccbOwner.node_auto_sent:setVisible(false)
	else
		self._ccbOwner.tf_name:setString("每升1级额外获得以下奖励之一")
		self._ccbOwner.tf_progress_title:setVisible(false)
		self._ccbOwner.tf_progress:setVisible(false)	
		self._ccbOwner.node_weiwancheng:setVisible(false)
		self._ccbOwner.node_yilingqu:setVisible(false)
		self._ccbOwner.node_yidacheng:setVisible(false)
		self._ccbOwner.node_done:setVisible(false)
		self._ccbOwner.node_auto_sent:setVisible(true)
	end

end

function QUIWidgetHighTeaReward:_initListView()
	if self._listView == nil then
		local cfg = {
			renderItemCallBack = handler(self, self._renderItemCallBack),
			isVertical = false,
	        enableShadow = false,
	        spaceY = 0,
	        spaceX = 10,
	        totalNumber = #self._data
		}
		self._listView = QListView.new(self._ccbOwner.itemsListView, cfg)
	else
		self._listView:reload({totalNumber = #self._data})
	end
end

function QUIWidgetHighTeaReward:_renderItemCallBack(list, index, info)
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
		item._itemBox:setPosition(ccp(29, 45))
		item._ccbOwner.parentNode:addChild(item._itemBox)
		item._ccbOwner.parentNode:setContentSize(CCSizeMake(60, 80))
	end
	item._itemBox:setGoodsInfo(data.id, data.type, data.count)
    info.item = item
    info.size = item._ccbOwner.parentNode:getContentSize()
    list:registerItemBoxPrompt(index, 1, item._itemBox, nil, showItemInfo)

    return isCacheNode
end

function QUIWidgetHighTeaReward:onTouchListView( event )
	if not event then
		return
	end

	if self._listView then
		self._listView:onTouch(event)
	end
end

function QUIWidgetHighTeaReward:getContentSize()
	local size = self._ccbOwner.node_size:getContentSize()
	return CCSize(size.width, size.height)
end

return QUIWidgetHighTeaReward