--
-- Kumo.Wang
-- 成长基金列表元素
--
local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetActivityGrowthFundCell = class("QUIWidgetActivityGrowthFundCell", QUIWidget)

local QUIWidgetItemsBox = import("..widgets.QUIWidgetItemsBox")
local QUIViewController = import("...ui.QUIViewController")
local QNotificationCenter = import("...controllers.QNotificationCenter")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QQuickWay = import("...utils.QQuickWay")

function QUIWidgetActivityGrowthFundCell:ctor(options)
	local ccbFile = "ccb/Widget_GrowthFund_Cell.ccbi"
  
	QUIWidgetActivityGrowthFundCell.super.ctor(self,ccbFile,callBacks,options)
end

function QUIWidgetActivityGrowthFundCell:getContentSize()
	return self._ccbOwner.node_size:getContentSize()
end

function QUIWidgetActivityGrowthFundCell:setInfo(info, parent)
	self._info = info

	self._itemBoxs = {}
	self._awards = {}
	self._funAwards = {}
	self._parent = parent
	self._index = nil
	self._ccbOwner.tf_name:setString(self._info.description or "")
	self._ccbOwner.node_item:removeAllChildren()
	self._ccbOwner.node_fund_item:removeAllChildren()
	self._ccbOwner.node_fund_award:setVisible(false)

	if info.value and info.type then
		if info.type == remote.growthFund.TYPE_FUND then
			local level = remote.user.level
			if level > tonumber(info.value) then
				level = info.value
			end
			self._ccbOwner.tf_num:setString(string.format("我的等级：%d/%d",level,info.value))
			self._ccbOwner.node_fund_award:setVisible(true)
		elseif info.type == remote.growthFund.TYPE_WELFARE then
			local buyNum = remote.user.fundBuyCount or 0
			if buyNum > tonumber(info.value) then
				buyNum = info.value
			end
			self._ccbOwner.tf_num:setString(string.format("购买人数：%d/%d",buyNum,info.value))
		end
	end

	self._ccbOwner.node_btn:setVisible(true)
	self._state, self._isGotFunAward = remote.growthFund:getStateById(self._info.id)
	if self._state == remote.growthFund.STATE_AWARD_HALF then
		-- 特权领取
		self._ccbOwner.tf_btn:enableOutline()
		makeNodeFromGrayToNormal(self._ccbOwner.node_btn)
		self._ccbOwner.tf_btn:setString("特权领取")
	elseif self._state == remote.growthFund.STATE_COMPLETE then 
		self._ccbOwner.tf_btn:enableOutline()
		makeNodeFromGrayToNormal(self._ccbOwner.node_btn)
		self._ccbOwner.tf_btn:setString("领 取")
	elseif self._state == remote.growthFund.STATE_NONE then 
		self._ccbOwner.tf_btn:disableOutline()
		makeNodeFromNormalToGray(self._ccbOwner.node_btn)
		self._ccbOwner.tf_btn:setString("领 取")
	elseif self._state == remote.growthFund.STATE_DONE then 
		self._ccbOwner.node_btn:setVisible(false)
	end
	self._ccbOwner.sp_ishave:setVisible(self._state == remote.growthFund.STATE_DONE)

	if self._info.awards_1 ~= nil then
		-- 目前ccb最多支持7个itembox
		local items = string.split(self._info.awards_1, ";") 
		local count = #items
		for i=1,count,1 do
			local obj = string.split(items[i], "^")
            if #obj == 2 then
            	self:_addItem(obj[1], obj[2])
            end
		end
	end  
	if self._info.awards_2 ~= nil then
		-- 目前ccb最多支持1个itembox
		local items = string.split(self._info.awards_2, ";") 
		local count = #items
		for i=1,count,1 do
			local obj = string.split(items[i], "^")
            if #obj == 2 then
            	self:_addFundItem(obj[1], obj[2])
            end
		end
	end  
end

function QUIWidgetActivityGrowthFundCell:_addItem(id, num)
	if id == nil or num == nil then
		return
	end
	local itemBox = QUIWidgetItemsBox.new()
    local itemType = remote.items:getItemType(id)
	id = tonumber(id)
	num = tonumber(num)
	if itemType ~= nil and itemType ~= ITEM_TYPE.ITEM then
		itemBox:setGoodsInfo(id, itemType, num)
    	table.insert(self._awards, {id = id, typeName = itemType, count = num})
	else
		itemBox:setGoodsInfo(id, ITEM_TYPE.ITEM, num)
    	table.insert(self._awards, {id = id, typeName = ITEM_TYPE.ITEM, count = num})
	end
	if self._index == nil then 
		self._index = 0
	else
		self._index = self._index + 1
	end
	itemBox:setScale(0.8)
	itemBox:setPositionX(self._index * 80) 
    itemBox:setPromptIsOpen(true)
    itemBox._ccbOwner.tf_noWear:setColor(COLORS.c)
    if self._state == remote.growthFund.STATE_AWARD_HALF then
		itemBox:setNodeVisible(itemBox._ccbOwner.node_mask, true)
		itemBox:setTFText(itemBox._ccbOwner.tf_noWear, "已领取")
	elseif self._state == remote.growthFund.STATE_COMPLETE then 
		itemBox:setNodeVisible(itemBox._ccbOwner.node_mask, false)
		itemBox:setTFText(itemBox._ccbOwner.tf_noWear, "")
	elseif self._state == remote.growthFund.STATE_NONE then 
		itemBox:setNodeVisible(itemBox._ccbOwner.node_mask, false)
		itemBox:setTFText(itemBox._ccbOwner.tf_noWear, "")
	elseif self._state == remote.growthFund.STATE_DONE then 
		itemBox:setNodeVisible(itemBox._ccbOwner.node_mask, true)
		itemBox:setTFText(itemBox._ccbOwner.tf_noWear, "已领取")
	end
	self._ccbOwner.node_item:addChild(itemBox)
	table.insert(self._itemBoxs, itemBox)
end

function QUIWidgetActivityGrowthFundCell:_addFundItem(id, num)
	if id == nil or num == nil then
		return
	end
	local itemBox = QUIWidgetItemsBox.new()
    local itemType = remote.items:getItemType(id)
	id = tonumber(id)
	num = tonumber(num)
	if itemType ~= nil and itemType ~= ITEM_TYPE.ITEM then
		itemBox:setGoodsInfo(id, itemType, num)
    	table.insert(self._funAwards, {id = id, typeName = itemType, count = num})
	else
		itemBox:setGoodsInfo(id, ITEM_TYPE.ITEM, num)
    	table.insert(self._funAwards, {id = id, typeName = ITEM_TYPE.ITEM, count = num})
	end
	itemBox:setScale(0.8)
    itemBox:setPromptIsOpen(true)
    itemBox:showLock(remote.user.fundStatus ~= 1)
    itemBox:showSpecial(true)

    itemBox._ccbOwner.tf_noWear:setColor(COLORS.c)
    if self._isGotFunAward then
		itemBox:setNodeVisible(itemBox._ccbOwner.node_mask, true)
		itemBox:setTFText(itemBox._ccbOwner.tf_noWear, "已领取")
	else
		itemBox:setNodeVisible(itemBox._ccbOwner.node_mask, false)
		itemBox:setTFText(itemBox._ccbOwner.tf_noWear, "")
	end

	self._ccbOwner.node_fund_item:addChild(itemBox)
	table.insert(self._itemBoxs, itemBox)
end

function QUIWidgetActivityGrowthFundCell:_onTriggerOK(event)
	if event then
		app.sound:playSound("common_confirm")
	end
	if self._state == remote.growthFund.STATE_DONE then
		return
	end
	
	if self._state == remote.growthFund.STATE_NONE then
		app.tip:floatTip("活动目标未达成！")
		return
	end

	if self._state == remote.growthFund.STATE_AWARD_HALF then
		if remote.user.fundStatus ~= 1 then
			local needVip, payMoney = remote.growthFund:getBuyFundCondition()
			local curVip = app.vipUtil:VIPLevel()
			if curVip < needVip then
				app:vipAlert({content = "VIP等级"..needVip.."级可购买基金特权，领取特权奖励，是否前往充值提升VIP等级？"}, false)
			else
				app:alert({content = "魂师大人，购买基金特权才能继续领取哟～！", title = "购  买", btns={ALERT_BTN.BTN_OK, ALERT_BTN.BTN_CANCEL}, btnDesc={"立即购买", "再想想"},
                    callback = function(state)
                        if state == ALERT_TYPE.CONFIRM then
                            if remote.user.token < payMoney then
								QQuickWay:addQuickWay(QQuickWay.TOKEN_DROP_WAY, nil)
								return
							end
							app:getClient():buyFundRequest(function (data)
								remote.activity:dispatchEvent({name = remote.activity.EVENT_CHANGE})
								remote.user:update({fundBuyCount = remote.user.fundBuyCount + 1})
								if self._ccbView then
									self:_onTriggerOK()
								end
							end)
                        end
                    end, isAnimation = false}, true, true)          
			end
			return
		end
	end

	local awards = {}
	if self._state == remote.growthFund.STATE_COMPLETE then
		for _, value in ipairs(self._awards) do
			table.insert(awards, value)
		end
		if remote.user.fundStatus == 1 and not self._isGotFunAward then
			for _, value in ipairs(self._funAwards) do
				table.insert(awards, value)
			end
		end
	else
		for _, value in ipairs(self._funAwards) do
			table.insert(awards, value)
		end
	end

	remote.growthFund:growthFundGetAwardRequest(self._info.id, function()
  		local dialog = app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogAwardsAlert",
    		options = {awards = awards}},{isPopCurrentDialog = false} )
    	dialog:setTitle("恭喜您获得成长基金奖励")
	end)
end

function QUIWidgetActivityGrowthFundCell:registerItemBoxPrompt( index, list )
	for k, v in pairs(self._itemBoxs) do
		list:registerItemBoxPrompt(index,k,v,nil, "showItemInfo")
	end
end

function QUIWidgetActivityGrowthFundCell:showItemInfo(x, y, itemBox, listView)
	app.tip:itemTip(itemBox._itemType, itemBox._itemID, true)
end


return QUIWidgetActivityGrowthFundCell