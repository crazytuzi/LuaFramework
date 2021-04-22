--
-- Author: wkwang
-- Date: 2015-03-20 17:07:03
-- 活动面板的活动内容条目
--
local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetActivitySevenDisCountItem = class("QUIWidgetActivitySevenDisCountItem", QUIWidget)

local QUIWidgetItemsBox = import("..widgets.QUIWidgetItemsBox")
local QUIViewController = import("...ui.QUIViewController")

local itemBoxGap = 134

function QUIWidgetActivitySevenDisCountItem:ctor(options)
	local ccbFile = "ccb/Widget_SevenDayAcitivity_HalfBuy.ccbi"
	if options and options.ccbFile then
		ccbFile = options.ccbFile
	end
  	local callBacks = {
  		{ccbCallbackName = "onTriggerConfirm", callback = handler(self, QUIWidgetActivitySevenDisCountItem._onTriggerConfirm)},
  	}
	QUIWidgetActivitySevenDisCountItem.super.ctor(self,ccbFile,callBacks,options)

	self._itemBox = {}
	self._effect = {}

	q.setButtonEnableShadow(self._ccbOwner.btn_ok)
end

function QUIWidgetActivitySevenDisCountItem:setInfo(id, info, maxCount)
	self.id = id
	self.info = info
	self._maxCount = maxCount
	self.awards = {}
	self._index = nil
	self.haveNum = remote.activity:getTypeNum(info) or 0
	self._ccbOwner.tf_discount:setString(self.info.value2 or 0)
	self._ccbOwner.tf_price:setString((self.info.value3 or 0))

	self._ccbOwner.node_btn:setVisible(true)
	if self.info.completeNum == 2 then
		self._ccbOwner.btn_ok:setEnabled(true)
		makeNodeFromGrayToNormal(self._ccbOwner.node_btn)
	elseif self.info.completeNum == 1 then 
		self._ccbOwner.btn_ok:setEnabled(false)
		makeNodeFromNormalToGray(self._ccbOwner.node_btn)
	else
		self._ccbOwner.node_btn:setVisible(false)
	end
	self._ccbOwner.sp_ishave:setVisible(remote.activity:checkCompleteByTargetId(self.info))
	self._itemName = self.info.description or ""
	local count
	if self.info.awards ~= nil then
		local items = string.split(self.info.awards, ";")
		count = #items
		for i = 1, count,1 do
            local obj = string.split(items[i], "^")
            if #obj == 2 then
            	self:addItem(obj[1], obj[2], i)
            end
		end
	end  
	self._ccbOwner.tf_name:setString(self._itemName)
	if count ~= nil then 
		self._ccbOwner.node_item:setPositionX( -130 + (3 - count)/2 * itemBoxGap )
	end
end

function QUIWidgetActivitySevenDisCountItem:addItem(id, num, index)
	if id == nil or num == nil then
		return
	end
	if self._effect[index] == nil then
       	self._effect[index] = CCBuilderReaderLoad("Widget_TreasureChestDtraw_lightlv2_1.ccbi", CCBProxy:create(), {})
		self._ccbOwner.node_item:addChild(self._effect[index])
	end

	if self._itemBox[index] == nil then
		self._itemBox[index] = QUIWidgetItemsBox.new()
		self._ccbOwner.node_item:addChild(self._itemBox[index])
   	 	self._itemBox[index]:setPromptIsOpen(true)
	end
    local itemType = remote.items:getItemType(id)
	id = tonumber(id)
	num = tonumber(num)
	self._itemBox[index]:setPositionX((index-1) * itemBoxGap)
	self._effect[index]:setPositionX((index-1) * itemBoxGap)
	if itemType ~= nil and itemType ~= ITEM_TYPE.ITEM then
		self._itemBox[index]:setGoodsInfo(id, itemType, num)
    	table.insert(self.awards, {id = id, typeName = itemType, count = num})
	else
		self._itemBox[index]:setGoodsInfo(id, ITEM_TYPE.ITEM, num)
    	table.insert(self.awards, {id = id, typeName = ITEM_TYPE.ITEM, count = num})
	end
end

function QUIWidgetActivitySevenDisCountItem:setPreviewStated(stated)
	if stated == nil then stated = false end

	if stated then
		self._ccbOwner.tf_one:setString("明日开启")
	else
		self._ccbOwner.tf_one:setString("抢 购")
	end
	self._ccbOwner.btn_ok:setEnabled(not stated)
end

--请求完成
function QUIWidgetActivitySevenDisCountItem:_onTriggerConfirm()
    app.sound:playSound("common_small")
	if remote.activity:checkIsActivityAward(self.info.activityId) == false then
		app.tip:floatTip("不在活动时间段内!")
		return
	end
	local awards = self.awards
	local info = self.info
	app:getClient():activityCompleteRequest(self.id, self.info.activityTargetId, nil, nil, function ()
  		local dialog = app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogAwardsAlert",
    		options = {awards = awards}},{isPopCurrentDialog = false} )
    	dialog:setTitle("恭喜您获得活动奖励")
		remote.activity:setCompleteDataById(info.activityId, info.activityTargetId)
		remote.activity:addHalfActivity(info.activityTargetId)
	end)
end



return QUIWidgetActivitySevenDisCountItem