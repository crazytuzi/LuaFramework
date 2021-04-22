--
-- Author: Your Name
-- Date: 2015-07-16 10:26:55
--
local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetActivityFundItem = class("QUIWidgetActivityFundItem", QUIWidget)

local QUIWidgetItemsBox = import("..widgets.QUIWidgetItemsBox")
local QUIViewController = import("...ui.QUIViewController")
local QNotificationCenter = import("...controllers.QNotificationCenter")
local QStaticDatabase = import("...controllers.QStaticDatabase")

function QUIWidgetActivityFundItem:ctor(options)
	local ccbFile = "ccb/Widget_Activity_client.ccbi"
  
	QUIWidgetActivityFundItem.super.ctor(self,ccbFile,callBacks,options)
end

function QUIWidgetActivityFundItem:getContentSize()
	return self._ccbOwner.cellSize:getContentSize()
end

function QUIWidgetActivityFundItem:setInfo(id, info, parent)
	self.awards = {}
	self._parent = parent
	self._index = nil
	self.id = id
	self.info = info
	self._ccbOwner.tf_name:setString(self.info.description or "")
	self._ccbOwner.node_item:removeAllChildren()
	self._itemBoxs = {}

	if info.value then
		if self._parent then
			if self._parent:isTAB_FUND() then
				local level = remote.user.level
				if level > info.value then
					level = info.value
				end
				self._ccbOwner.tf_num:setString(string.format("我的等级：%d/%d",level,info.value))
			else
				local buyNum = remote.user.fundBuyCount or 0
				if buyNum > info.value then
					buyNum = info.value
				end
				self._ccbOwner.tf_num:setString(string.format("购买人数：%d/%d",buyNum,info.value))
			end
		end
	end

	self._ccbOwner.node_btn2:setVisible(false)
	self._ccbOwner.node_btn_go:setVisible(false)
	self._ccbOwner.node_btn:setVisible(true)

	if self.info.completeNum == 2 then
		self._ccbOwner.tf_btn:enableOutline()
		makeNodeFromGrayToNormal(self._ccbOwner.node_btn)
	elseif self.info.completeNum == 1 then 
		self._ccbOwner.tf_btn:disableOutline()
		makeNodeFromNormalToGray(self._ccbOwner.node_btn)
	else
		self._ccbOwner.node_btn:setVisible(false)
	end
	self._ccbOwner.sp_ishave:setVisible(self.info.completeNum == 3)

	if self.info.awards ~= nil then
		local items = string.split(self.info.awards, ";") 
		local count = #items
		for i=1,count,1 do
			local  temp = string.split(items[i], "#")
			if #temp > 1 then
				self._isChooseOne = true
				self._awardStr = string.gsub(items[i], "#", ";")
				
				for _,v in pairs(temp) do
					local obj = string.split(v, "^")
		            if #obj == 2 then
		            	self:addItem(obj[1], obj[2])
		            end
				end
			else
				local obj = string.split(items[i], "^")
	            if #obj == 2 then
	            	self:addItem(obj[1], obj[2])
	            end
			end

          
		end
	end  
end

function QUIWidgetActivityFundItem:addItem(id, num)
	if id == nil or num == nil then
		return
	end
	local itemBox = QUIWidgetItemsBox.new()
    local itemType = remote.items:getItemType(id)
	id = tonumber(id)
	num = tonumber(num)
	if itemType ~= nil and itemType ~= ITEM_TYPE.ITEM then
		itemBox:setGoodsInfo(id, itemType, num)
    	table.insert(self.awards, {id = id, typeName = itemType, count = num})
	else
		itemBox:setGoodsInfo(id, ITEM_TYPE.ITEM, num)
    	table.insert(self.awards, {id = id, typeName = ITEM_TYPE.ITEM, count = num})
	end
	if self._index == nil then 
		self._index = 0
	else
		self._index = self._index + 1
	end
	itemBox:setScale(0.8)
	itemBox:setPositionX(self._index * 80) 
    itemBox:setPromptIsOpen(true)
	self._ccbOwner.node_item:addChild(itemBox)
	table.insert(self._itemBoxs, itemBox)
end

function QUIWidgetActivityFundItem.getRewards(activityId, activityTargetId, awards, params )
	app.sound:playSound("common_confirm")
	-- local awards = self.awards
	-- local info = self.info

	app:getClient():activityCompleteRequest(activityId, activityTargetId, params, nil, function ()
  		local dialog = app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogAwardsAlert",
    		options = {awards = awards}},{isPopCurrentDialog = false} )
    	dialog:setTitle("恭喜您获得开服基金奖励")
		remote.activity:setCompleteDataById(activityId ,activityTargetId)
	end)
	return true
end

function QUIWidgetActivityFundItem:_onTriggerConfirm(event)
	app.sound:playSound("common_confirm")
	
	if  self.info.completeNum == 3 then
		return
	end
	
	if  self.info.completeNum ~= 2 then
		if not remote.activity:checkIsActivity(self.info.activityId) then
			app.tip:floatTip("不在活动时间段内!")
			return
		else
			if remote.user.fundStatus ~= 1 then
				app.tip:floatTip("魂师大人，VIP等级2级并购买开服基金才能领取哟~！")
			else
				app.tip:floatTip("活动目标未达成！")
			end
		end
		return
	end

	if remote.activity:checkIsActivityAward(self.info.activityId) == false then
		app.tip:floatTip("活动领奖时间已过！下次请早！")
		return
	end

	local activityId = self.info.activityId
	local activityTargetId = self.info.activityTargetId
	local awards = self.awards

	if self._isChooseOne then
		app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogXuanzejiangli", 
                        options = {awards = self.awards, confirmText = "领  取", 
                            okCallback = function (chooseIndexs)
                          		if not chooseIndexs then
									chooseIndexs = {}
								end
								local chooseIndex = chooseIndexs[1]
								
                            	if not chooseIndex or chooseIndex == 0 then
                            		app.tip:floatTip("请选择")
                            		return false
                            	end
                            	local chooseAward = awards[chooseIndex]
                            	if type(chooseAward) == "table" then
	                            	local chooseAwardStr = chooseAward.id.."^"..chooseAward.count
	                            	local chooseAwards = {}
	                            	table.insert(chooseAwards, chooseAward)
	                            	return QUIWidgetActivityFundItem.getRewards(activityId, activityTargetId, chooseAwards,chooseAwardStr)
	                            end
	                            return true
                            end}})
	else
		QUIWidgetActivityFundItem.getRewards(activityId, activityTargetId, self.awards)
	end

end


function QUIWidgetActivityFundItem:registerItemBoxPrompt( index, list )
	-- body
	for k, v in pairs(self._itemBoxs) do
		list:registerItemBoxPrompt(index,k,v,nil, "showItemInfo")
	end
end

function QUIWidgetActivityFundItem:onEnter()
	--代码
	self._isExit = true
end

--describe：onExit 
function QUIWidgetActivityFundItem:onExit()
	--代码
	self._isExit = nil
end

function QUIWidgetActivityFundItem:showItemInfo(x, y, itemBox, listView)
	-- body
	app.tip:itemTip(itemBox._itemType, itemBox._itemID, true)
end

return QUIWidgetActivityFundItem