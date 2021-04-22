--
-- Kumo.Wang
-- 积分奖励Cell
--
local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetJifenAward = class("QUIWidgetJifenAward", QUIWidget)
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QUIWidgetItemsBox = import("..widgets.QUIWidgetItemsBox")
local QUIWidgetQlistviewItem = import("..widgets.QUIWidgetQlistviewItem")
local QListView = import("...views.QListView")

QUIWidgetJifenAward.EVENT_CLICK = "EVENT_CLICK"

function QUIWidgetJifenAward:ctor(options)
 	local ccbFile = "ccb/Widget_Base_Jifen_Award.ccbi"
    local callBacks = {
        {ccbCallbackName = "onTriggerClickAwards", callback = handler(self, QUIWidgetJifenAward._onTriggerClickAwards)},
    }
    QUIWidgetJifenAward.super.ctor(self, ccbFile, callBacks, options)
    cc.GameObject.extend(self)
    self:addComponent("components.behavior.EventProtocol"):exportMethods()
end

function QUIWidgetJifenAward:getContentSize()
	return self._ccbOwner.node_size:getContentSize()
end

function QUIWidgetJifenAward:onEnter()
	QUIWidgetJifenAward.super.onEnter(self)
    self.prompt = app:promptTips()
    self.prompt:addItemEventListener(self)
end

function QUIWidgetJifenAward:onExit()
	QUIWidgetJifenAward.super.onExit(self)
	if self.prompt ~= nil then
    	self.prompt:removeItemEventListener(self)
    	self.prompt = nil
    end
end

function QUIWidgetJifenAward:setInfo(info, score)
	self._info = info
	if info.widgetTitleStr then
		self._ccbOwner.tf_name:setString(string.format(info.widgetTitleStr, info.condition))
	else
		self._ccbOwner.tf_name:setString(string.format("今日达到%d积分", info.condition))
	end
	
	self._ccbOwner.tf_progress:setString(score.."/"..info.condition)
	local progressW = self._ccbOwner.tf_progress:getContentSize().width
	self._ccbOwner.tf_progress_title:setPositionX(self._ccbOwner.tf_progress:getPositionX() - progressW)

	self._data = {}
	self._awards = info.awardList or QStaticDatabase.sharedDatabase():getluckyDrawById(info.reward_id)
	for index,value in ipairs(self._awards) do
		table.insert(self._data, {id = value.id, type = value.typeName, count = value.count})
	end
	self:_initListView()

	local isGet = info.isGet --remote.arena:dailyRewardInfoIsGet(info.ID)
	self._ccbOwner.node_yilingqu:setVisible(isGet)
	if isGet == false then
		self._ccbOwner.done_banner:setVisible(score>=info.condition)
		self._ccbOwner.sp_title_done:setVisible(score>=info.condition)
		self._ccbOwner.normal_banner:setVisible(score<info.condition)
		self._ccbOwner.sp_title_normal:setVisible(score<info.condition)
		self._ccbOwner.node_done:setVisible(score>=info.condition)
		self._ccbOwner.node_weiwancheng:setVisible(score<info.condition)
	else
		self._ccbOwner.done_banner:setVisible(false)
		self._ccbOwner.sp_title_done:setVisible(false)
		self._ccbOwner.normal_banner:setVisible(true)
		self._ccbOwner.sp_title_normal:setVisible(true)
		self._ccbOwner.node_done:setVisible(false)
		self._ccbOwner.node_weiwancheng:setVisible(false)
	end
	self._isComplete = (isGet == false) and (score>=info.condition)
end


function QUIWidgetJifenAward:_initListView()
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

function QUIWidgetJifenAward:_renderItemCallBack(list, index, info)
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

function QUIWidgetJifenAward:onTouchListView( event )
	if not event then
		return
	end

	if self._listView then
		self._listView:onTouch(event)
	end
end


function QUIWidgetJifenAward:_onTriggerClickAwards(event)
	if self._isComplete == true then
		self:dispatchEvent({name = QUIWidgetJifenAward.EVENT_CLICK, info = self._info, awards = self._awards})
	end
end

return QUIWidgetJifenAward