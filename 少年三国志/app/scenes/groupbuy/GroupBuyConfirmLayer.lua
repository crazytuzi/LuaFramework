-- GroupBuyConfirmLayer.lua

local GroupBuyConfirmLayer = class("GroupBuyConfirmLayer", UFCCSModelLayer)
local GroupBuyCommon = require("app.scenes.groupbuy.GroupBuyCommon")

function GroupBuyConfirmLayer.show(item_id, ...)
	local layer = GroupBuyConfirmLayer.new("ui_layout/groupbuy_ConfirmLayer.json", Colors.modelColor, item_id,  ...)
	if layer then 
		uf_sceneManager:getCurScene():addChild(layer)
	end
end

function GroupBuyConfirmLayer:ctor( json, param, item_id, ... )

	self._item_id = item_id or 1

	self._goldLabel = self:getLabelByName("Label_gold")
	self._coupon1Label = self:getLabelByName("Label_coupon1")
	self._coupon2Label = self:getLabelByName("Label_coupon2")

	self.super.ctor(self, json, param, ...)

end

function GroupBuyConfirmLayer:onLayerEnter()
	self:showAtCenter(true)
	self:closeAtReturn(true)

	self:_initWidgets()

	self:registerBtnClickEvent("Button_no", handler(self, self._onCancelClick))
	self:registerBtnClickEvent("Button_yes", handler(self, self._onConfirmClick))

	require("app.common.effects.EffectSingleMoving").run(self:getWidgetByName("ImageView_145"), "smoving_bounce")
end

function GroupBuyConfirmLayer:_initWidgets()

	local item = G_Me.groupBuyData:getGoodsItemById(self._item_id)
	if item == nil then return end
	local goods = G_Goods.convert(item.type, item.value, item.size)
	if goods == nil then return end

	local buyTimesData = G_Me.groupBuyData:getItemBuyTimesInfoById(self._item_id) or {}
 
	local nowBuyNum = buyTimesData.server_count or 0

	local pre = GroupBuyCommon.calProgressRatio(item, nowBuyNum)

	local offLevel      = math.floor(pre / 25)
	local nowPrice      = offLevel == 0 and math.floor(item.initial_price * item.initial_off / 1000) or math.floor(item.initial_price * item[string.format("off_price_%d", offLevel)] / 1000)
	local needCoupon    = math.min(math.floor(nowPrice * item.coupon_use_percent / 1000), G_Me.groupBuyData:getCoupon())
	local needGold      = nowPrice - needCoupon
	local giveCouponNum = math.floor(nowPrice * item.coupon_give_percent / 1000)

	self._goldLabel:setText(needGold)
	self._coupon1Label:setText(needCoupon)
	self._coupon2Label:setText(giveCouponNum .. ")")

	if needCoupon == 0 then
		self:showWidgetByName("Image_coupon1", false)
		self._coupon1Label:setVisible(false)
		self:getLabelByName("Label_content2_2"):setPositionX(self._goldLabel:getPositionX() + self._goldLabel:getContentSize().width + 1)
	end

	if self._richText == nil then
		local label = self:getLabelByName("Label_richtext")
		local size = label:getSize()
		print(size.width .. " " .. size.height)
		self._richText = CCSRichText:create(size.width + 150, size.height)
		self._richText:setFontName(label:getFontName())
		self._richText:setFontSize(label:getFontSize())
		local x, y = label:getPosition()
		self._richText:setPosition(ccp(x, y+ 5))
		self._richText:setVisible(true)
		self._richText:setTextAlignment(ui.TEXT_ALIGN_CENTER)
		self:getPanelByName("Panel_root"):addChild(self._richText, 7)
	end
	local content1 = G_lang:get("LANG_GROUP_BUY_CONFIRM1", {gold = needGold, need_coupon = needCoupon, give_coupon = giveCouponNum})
	local content2 = G_lang:get("LANG_GROUP_BUY_CONFIRM2", {gold = needGold, give_coupon = giveCouponNum})
	self._richText:clearRichElement()
	if needCoupon == 0 then
		self._richText:appendXmlContent(content2)
	else
		self._richText:appendXmlContent(content1)
	end
	self._richText:reloadData()

end

function GroupBuyConfirmLayer:_onConfirmClick()
	GroupBuyCommon.getHandler():sendGroupBuyPurchaseGoods(self._item_id)
	self:animationToClose()
end

function GroupBuyConfirmLayer:_onCancelClick()
	self:animationToClose()
end

function GroupBuyConfirmLayer:onLayerExit()
	
end

return GroupBuyConfirmLayer
