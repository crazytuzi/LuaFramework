-- GroupBuyGoodsInfoPanel.lua

local GroupBuyCommon = require("app.scenes.groupbuy.GroupBuyCommon")
local GroupBuyConst  = require("app.const.GroupBuyConst")
local GroupBuyConfirmLayer = require("app.scenes.groupbuy.GroupBuyConfirmLayer")

local string = string
local math = math

local GroupBuyGoodsInfoPanel = class("GroupBuyGoodsInfoPanel", UFCCSNormalLayer)


function GroupBuyGoodsInfoPanel.create( ... )
	return GroupBuyGoodsInfoPanel.new("ui_layout/groupbuy_GoodsInfoPanel.json", ...)
end

function GroupBuyGoodsInfoPanel:ctor( ... )
	self.super.ctor(self, ...)

	self._scoreProgressbar  = self:getLoadingBarByName("ProgressBar_Score")
	self._nowBuyNumLabel    = self:getLabelByName("Label_Now_Buy_Number")
	self._item1Node         = self:getImageViewByName("Image_Item_1")
	self._item2Node         = self:getImageViewByName("Image_Item_2")
	self._maxBuyTimesLabel  = self:getLabelByName("Label_Max_Buy_Times")
	self._maxBuyTimes0Label = self:getLabelByName("Label_Max_Buy_Times_0")
	self._maxBuyTimes1Label = self:getLabelByName("Label_Max_Buy_Times_1")
	self._priceLabel        = self:getLabelByName("Label_Price")
	self._goldImage         = self:getImageViewByName("Image_Gold")
	self._priceNumLabel     = self:getLabelByName("Label_Price_Num")
	self._couponUseLabel    = self:getLabelByName("Label_Coupon_Use")
	self._couponImage       = self:getImageViewByName("Image_Coupon")
	self._couponNumLabel    = self:getLabelByName("Label_Coupon_Num")
	self._buyButton         = self:getButtonByName("Button_Buy")		

	self._tickNodes = {
		self:getImageViewByName("Image_tick_1"),
		self:getImageViewByName("Image_tick_2"),
		self:getImageViewByName("Image_tick_3"),
		self:getImageViewByName("Image_tick_4"),
	}

	self._id = 0
	self._giveCouponNum = 0
	self._data = GroupBuyCommon.getData()

	self:attachImageTextForBtn("Button_Buy", "Image_Buy")
end

function GroupBuyGoodsInfoPanel:_setItemData(itemNode, goods, i)
	local iconImage = UIHelper:seekWidgetByName(itemNode, "Image_Icon")
    iconImage = tolua.cast(iconImage,"ImageView")
    iconImage:loadTexture(goods.icon)

    local bgImage = UIHelper:seekWidgetByName(itemNode,"Image_Icon_BG")
    bgImage = tolua.cast(bgImage,"ImageView")
    bgImage:loadTexture(G_Path.getEquipIconBack(goods.quality))

    local rareImage = UIHelper:seekWidgetByName(itemNode,string.format("Image_Rare%d", i))
    -- rareImage:setZOrder(2)
    rareImage = tolua.cast(rareImage,"ImageView")
    rareImage:loadTexture(G_Path.getEquipColorImage(goods.quality, goods.type))

    local numLabel = UIHelper:seekWidgetByName(itemNode,"Label_Num")
    -- numLabel:setZOrder(3)
    numLabel = tolua.cast(numLabel,"Label")
    numLabel:setText(goods.size > 1 and goods.size or "")
    numLabel:createStroke(Colors.strokeBlack, 1)

    self:registerWidgetClickEvent(string.format("Image_Rare%d", i), function()
    	if goods then
    		require("app.scenes.common.dropinfo.DropInfo").show(goods.type, goods.info.id)
    	end
    end)
end

function GroupBuyGoodsInfoPanel:updateItemInfo(id)
	self._id = id or self._id
	self._id = self._id or 1
	local item = self._data:getGoodsItemById(self._id)
	if item == nil then return end
	local goods = G_Goods.convert(item.type, item.value, item.size)
	if goods == nil then return end

	local buyTimesData = self._data:getItemBuyTimesInfoById(self._id) or {}
 
	local nowBuyNum = buyTimesData.server_count or 0

	local pre = GroupBuyCommon.calProgressRatio(item, nowBuyNum)
	self._scoreProgressbar:setPercent(pre or 0)

	for i = 1, #self._tickNodes do
		local tickNode = self._tickNodes[i]
		local scoreLabel = tickNode:getChildByName("Label_Progress_Score")
		scoreLabel = tolua.cast(scoreLabel, "Label")
		scoreLabel:setText(item[string.format("buyer_num_%d", i)])
		scoreLabel:createStroke(Colors.strokeBlack, 1)
		local offLabel = tickNode:getChildByName("Label_Off")
		offLabel = tolua.cast(offLabel, "Label")
		local off = item[string.format("off_price_%d", i)] / 100
		offLabel:setText(off .. G_lang:get("LANG_GROUP_BUY_AWARD_OFF"))
		if off >= 7 then
			offLabel:setColor(Colors.qualityColors[3])
		else
			offLabel:setColor(Colors.qualityColors[7])
		end
		offLabel:createStroke(Colors.strokeBlack, 1)
		-- local discountImage = tickNode:getChildByName("Image_Discount")
		-- discountImage = tolua.cast(discountImage, "ImageView")
		-- discountImage:setVisible(false)
		-- discountImage:loadTexture(string.format(GroupBuyConst.DISCOUNT_IMAGE_PATH, math.floor(item[string.format("off_price_%d", i)] / 100)))
	end
	local off0Label = self:getLabelByName("Label_Off_0")
	off0Label:setText(item.initial_off / 100 .. G_lang:get("LANG_GROUP_BUY_AWARD_OFF"))
	if item.initial_off / 100 >= 7 then
		off0Label:setColor(Colors.qualityColors[3])
	else
		off0Label:setColor(Colors.qualityColors[7])
	end
	off0Label:createStroke(Colors.strokeBlack, 1)

	local maxTimes = item.buy_max_day - (buyTimesData.self_count or 0)

	
	self._maxBuyTimesLabel:setText(G_lang:get("LANG_GROUP_BUY_BUY_TIMES_1"))
	self._maxBuyTimes0Label:setText(maxTimes)
	self._maxBuyTimes0Label:setPositionX(-self._maxBuyTimesLabel:getContentSize().width)
	self._maxBuyTimes1Label:setText(G_lang:get("LANG_GROUP_BUY_BUY_TIMES"))
	self._maxBuyTimes1Label:setPositionX(-self._maxBuyTimesLabel:getContentSize().width - self._maxBuyTimes0Label:getContentSize().width)
	local offLevel      = math.floor(pre / 25)
	local nowPrice      = offLevel == 0 and math.floor(item.initial_price * item.initial_off / 1000) or math.floor(item.initial_price * item[string.format("off_price_%d", offLevel)] / 1000)
	local needCoupon    = math.min(math.floor(nowPrice * item.coupon_use_percent / 1000), self._data:getCoupon())
	local needGold      = nowPrice - needCoupon
	self._giveCouponNum = math.floor(nowPrice * item.coupon_give_percent / 1000)

	-- 当前已购买
	local off = item.initial_off / 100
    if offLevel > 0 then
        off = item[string.format("off_price_%d", offLevel)] / 100
    end
	self._nowBuyNumLabel:setText(G_lang:get("LANG_GROUP_BUY_BUY_NUM", {num = nowBuyNum, discount = off}))

	self._priceLabel:setText(G_lang:get("LANG_GROUP_BUY_PRICE"))
	self._goldImage:setPositionX(self._priceLabel:getContentSize().width)
	self._priceNumLabel:setText(string.format("%d", nowPrice))
	self._priceNumLabel:setPositionX(self._priceLabel:getContentSize().width + 46)
	self._couponUseLabel:setText(G_lang:get("LANG_GROUP_BUY_USE_COUPON"))
	self._couponImage:setPositionX(self._couponUseLabel:getPositionX() + self._couponUseLabel:getContentSize().width)
	self._couponNumLabel:setText(string.format("%d)", needCoupon))
	self._couponNumLabel:setPositionX(self._couponImage:getPositionX() + self._couponImage:getContentSize().width)

	self:_setItemData(self._item1Node, goods, 1)
	self:_setItemData(self._item2Node, G_Goods.convert(G_Goods.TYPE_COUPON, 0, giveCouponNum), 2)

	self:registerBtnClickEvent("Button_Buy", function()
		if self._data:getTimeStatusType() ~= GroupBuyConst.TIME_STATUS_TYPE.RUNNING then
			G_MovingTip:showMovingTip(G_lang:get("LANG_GROUP_BUY_END_OVER"))
			return
		end
		if item.buy_max_day - (buyTimesData.self_count or 0) <= 0 then
			G_MovingTip:showMovingTip(G_lang:get("LANG_GROUP_BUY_TIMES_OVER"))
			return
		end
		if G_Me.userData.vip < item.vip_level then
			G_MovingTip:showMovingTip(G_lang:get("LANG_VIP_LEVEL_SMALL"))
			return
		end
		if G_Me.userData.level < item.level then
			G_MovingTip:showMovingTip(G_lang:get("LANG_GROUP_BUY_LEVEL"))
			return
		end
		if GroupBuyCommon.checkBagisFull(item.type, item.size) then
			return
		end
		local coupon = self._data:getCoupon()
		if G_Me.userData.gold + coupon < nowPrice then
			require("app.scenes.shop.GoldNotEnoughDialog").show()
			return
		end

		GroupBuyConfirmLayer.show(self._id)
		-- GroupBuyCommon.getHandler():sendGroupBuyPurchaseGoods(self._id)
	end)

	local timeType = self._data:getTimeStatusType()
	if timeType == GroupBuyConst.TIME_STATUS_TYPE.RUNNING and maxTimes > 0 then
		self._buyButton:setTouchEnabled(true)
	else
		self._buyButton:setTouchEnabled(false)
	end
end

function GroupBuyGoodsInfoPanel:getGiveCouponNnum()
	return self._giveCouponNum
end

return GroupBuyGoodsInfoPanel