--
-- zxs
-- 团购信息
--
local QUIWidget = import(".QUIWidget")
local QUIWidgetActivityGroupBuy = class("QUIWidgetActivityGroupBuy", QUIWidget)
local QUIWidgetItemsBox = import(".QUIWidgetItemsBox")
local QNavigationController = import("...controllers.QNavigationController")
local QUIViewController = import("..QUIViewController")

function QUIWidgetActivityGroupBuy:ctor(options)
	local ccbFile = "Widget_Groupbuy_Client.ccbi"
	local callBacks = {
		{ccbCallbackName = "onTriggerBuy", callback = handler(self, QUIWidgetActivityGroupBuy._onTriggerBuy)},
	}
	QUIWidgetActivityGroupBuy.super.ctor(self,ccbFile,callBacks,options)

	local scoreBar = q.newPercentBarClippingNode(self._ccbOwner.sp_bar_progress)
    self._stencil = scoreBar:getStencil()
	self._groupBuy = remote.activityRounds:getGroupBuy()
	
	self._defaultPosX = self._ccbOwner.sp_cursor:getPositionX()
	self._barWidth = self._ccbOwner.sp_bar_progress:getContentSize().width
end

function QUIWidgetActivityGroupBuy:setInfo(info)
	self._info = info
	self._ccbOwner.sp_cursor:setPositionX(self._defaultPosX)

	if not self._itembox then
		self._itembox = QUIWidgetItemsBox.new()
		self._ccbOwner.node_icon:removeAllChildren()
		self._ccbOwner.node_icon:addChild(self._itembox)
	end
	self._itembox:setGoodsInfoByID(info.id, info.count)
	self._itembox:setPromptIsOpen(true)

	local curPrice = math.floor((info.price * info.curDiscount)/100)
	local curDiscount = (info.curDiscount/10).."折"
	self._ccbOwner.tf_cur_cost:setString(curPrice)
	self._ccbOwner.tf_old_cost:setString(info.price)
	self._ccbOwner.tf_cur_discount:setString(curDiscount)
	self._ccbOwner.tf_buy_count:setString("已购买"..info.totalBuyCount.."件，当前折扣：")
	self._ccbOwner.tf_left_count:setString(info.maxBuyCount-info.alreadyBuyCount)

	local function getDiscountString( discount )
		if discount >= 10 then
			return "原价"
		else
			return string.format("%s折",discount)
		end
	end
	for i = 1, 5 do
		local discount = getDiscountString(info.discountArr[i]/10)
		self._ccbOwner["tf_discount_"..i]:setString( discount )
		if i > 1 then
			self._ccbOwner["tf_num_"..i]:setString(info.buyNumArr[i])
		else
			self._ccbOwner["tf_num_"..i]:setVisible(false)
		end
	end
	self:setProgressBar(info)

	if remote.user.level < info.levelLimit then
		makeNodeFromNormalToGray(self._ccbOwner.btn_buy)
		self._ccbOwner.tf_level_limit:setString(info.levelLimit)
		self._ccbOwner.node_today_buy:setVisible(false)
		self._ccbOwner.node_limit:setVisible(true)
	else
		makeNodeFromGrayToNormal(self._ccbOwner.btn_buy)
		self._ccbOwner.node_today_buy:setVisible(true)
		self._ccbOwner.node_limit:setVisible(false)
	end

	self._ccbOwner.buy_tips:setVisible(false)
	if self._groupBuy.isOpen == true and self._groupBuy.isActivityNotEnd == true then 
		if remote.user.level >= info.levelLimit and info.maxBuyCount - info.alreadyBuyCount > 0 then
			self._ccbOwner.buy_tips:setVisible(true)
		end
	end

	if info.maxBuyCount - info.alreadyBuyCount <= 0 then
		self._ccbOwner.node_buy:setVisible(false)
		self._ccbOwner.node_done:setVisible(true)
	else
		self._ccbOwner.node_buy:setVisible(true)
		self._ccbOwner.node_done:setVisible(false)
	end
end

function QUIWidgetActivityGroupBuy:setProgressBar( info )
	local totalBuyCount = (info.totalBuyCount or 0)
	local progress = 0
	for i, num in pairs(info.buyNumArr) do
		local lastCount = tonumber(info.buyNumArr[i-1] or -1)
		local curCount = tonumber(info.buyNumArr[i])
		if totalBuyCount <= curCount then
			if totalBuyCount > 0 then
				progress = progress + 0.25 * (totalBuyCount-lastCount)/(curCount-lastCount)
			end
			break		
		end
		if i > 1 then 
			progress = progress + 0.25
		end
	end
	if progress > 1 then
		progress = 1
	end

	self._ccbOwner.sp_cursor:setPositionX(self._defaultPosX + self._barWidth * progress)
	self._stencil:setScaleX(progress)
end

function QUIWidgetActivityGroupBuy:_onTriggerBuy(event)
	if q.buttonEventShadow(event, self._ccbOwner.btn_buy) == false then return end
	
	if self._groupBuy.isOpen == false or self._groupBuy.isActivityNotEnd == false then
		app.tip:floatTip("活动购买已结束")
		return
	end
	if remote.user.level <  self._info.levelLimit then
		app.tip:floatTip(string.format("%s级可购买",self._info.levelLimit))
		return 
	end
	if self._info.maxBuyCount - self._info.alreadyBuyCount <= 0 then
		app.tip:floatTip("今日购买次数已用完")
		return 
	end

	local awards = {}
	local itemType = remote.items:getItemType(self._info.id)
	if itemType == nil then
		itemType = ITEM_TYPE.ITEM
	end
	table.insert( awards, {id = self._info.id, count = self._info.count, typeName = itemType} )

	remote.activityRounds:getGroupBuy():buyGoods(self._info.goodsID, self._info.curDiscount, function()
		local dialog = app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogAwardsAlert",
    		options = {awards = awards}},{isPopCurrentDialog = false} )
		dialog:setTitle("恭喜您获得活动奖励")
	end)
end

return QUIWidgetActivityGroupBuy
