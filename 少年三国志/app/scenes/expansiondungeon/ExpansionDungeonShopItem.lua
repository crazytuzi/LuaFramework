local ExpansionDungeonShopItem = class("ExpansionDungeonShopItem", function()
	return CCSItemCellBase:create("ui_layout/expansiondungeon_ShopItem.json")
end)

function ExpansionDungeonShopItem:ctor(nChapterId, buyCallback)
	self._nChapterId = nChapterId
	self._buyCallback = buyCallback
end

function ExpansionDungeonShopItem:update(tItemTmpl)
	if not tItemTmpl then
		return
	end

	local tGoods = G_Goods.convert(tItemTmpl["item_type"], tItemTmpl["item_value"], tItemTmpl["item_size"])
	if not tGoods then
		return
	end

	-- 商品名称
	G_GlobalFunc.updateLabel(self, "Label_Name", {text=tGoods.name, color=Colors.qualityColors[tGoods.quality], stroke=Colors.strokeBrown})
	-- 折扣
	G_GlobalFunc.updateLabel(self, "Label_Discount", {text=tItemTmpl.discount..G_lang:get("LANG_GROUP_BUY_AWARD_OFF"), stroke=Colors.strokeBrown, visible=tItemTmpl.discount ~= 0})
	-- 商品icon
	self:_updateIcon(tGoods)

	-- 可购买次数
	local nCouldBuyCount = tItemTmpl.time
	local nAlreadyBuyCount = G_Me.expansionDungeonData:getItemAlreadyBuyCount(self._nChapterId, tItemTmpl.id)
	nCouldBuyCount = math.max(0, nCouldBuyCount - nAlreadyBuyCount) 

	local szDesc = (nCouldBuyCount == 0) and G_lang:get("LANG_PURCHASE_REACHED_MAXINUM") or G_lang:get("LANG_EX_DUNGEON_COULD_BUY_COUNT", {num=nCouldBuyCount})
	G_GlobalFunc.updateLabel(self, "Label_BuyDesc", {text=szDesc})

	local btnBuy = self:getButtonByName("Button_Buy")
	if btnBuy then
		btnBuy:showAsGray(nCouldBuyCount == 0)
	end
	local imgBuy = self:getImageViewByName("Image_buy")
	if imgBuy then
		imgBuy:loadTexture(self:_getBuyOrNotBuyImage(nCouldBuyCount == 0))
	end

	-- 折扣后的价格
	G_GlobalFunc.updateLabel(self, "Label_DisPriceValue", {text=tItemTmpl.discount_price})
	-- 原价
	G_GlobalFunc.updateLabel(self, "Label_OrigPriceValue", {text=tItemTmpl.price})
	-- 原价划线
	local labelLine = self:getLabelByName("Label_Line")
	if labelLine then
		local nLen = string.len(tostring(math.floor(tItemTmpl.price)))
		local nScaleX = self:_getOrigPriceLineScaleX(nLen)
		labelLine:setScaleX(nScaleX)
	end

	self:showWidgetByName("Label_OrigPriceDesc", tItemTmpl.discount ~= 0)
	self:showWidgetByName("Label_OrigPriceValue", tItemTmpl.discount ~= 0)
	self:showWidgetByName("Label_Line", tItemTmpl.discount ~= 0)

	-- 购买按钮
	self:registerBtnClickEvent("Button_Buy", function()
		if nCouldBuyCount == 0 then
			G_MovingTip:showMovingTip(G_lang:get("LANG_PURCHASE_REACHED_MAXINUM"))
			return
		end
		if self._buyCallback then
			self._buyCallback(tItemTmpl.id, nAlreadyBuyCount)
		end
	end)

	-- 折扣角标
	if tItemTmpl.discount_path ~= "0" then
		self:showWidgetByName("Image_Mark", true)
		G_GlobalFunc.updateImageView(self, "Image_Mark", {texture="ui/text/txt/"..tItemTmpl.discount_path..".png", texType=UI_TEX_TYPE_LOCAL})
	else
		self:showWidgetByName("Image_Mark", false)
	end
end

function ExpansionDungeonShopItem:_updateIcon(tGoods)
	local imgQualityFrame = self:getImageViewByName("Image_QualityFrame")
	local nQuality = tGoods.quality
	local nType = tGoods.type
	local nValue = tGoods.value
	local szName = tGoods.name 
	local nItemNum = tGoods.size 
	local szIcon = tGoods.icon

	-- 物品品质框
	if imgQualityFrame then
		imgQualityFrame:loadTexture(G_Path.getEquipColorImage(nQuality, nType))
	end
	-- 物品图片
	local imgIcon = self:getImageViewByName("Image_Icon")
	if imgIcon then
		imgIcon:loadTexture(szIcon)
	end
	-- 物品数量
	local labelNum = self:getLabelByName("Label_Num")
	if labelNum then
		labelNum:setText("x" .. G_GlobalFunc.ConvertNumToCharacter2(nItemNum))
		labelNum:createStroke(Colors.strokeBrown, 1)
	end

	self:registerWidgetClickEvent("Image_QualityFrame", function()
		if type(nType) == "number" and type(nValue) == "number" then
	    	require("app.scenes.common.dropinfo.DropInfo").show(nType, nValue)
		end
	end)
end

function ExpansionDungeonShopItem:_getOrigPriceLineScaleX(nLen)
	local tList = {
		1.4, 2.1, 2.6, 3.2, 3.8
	}
	return tList[nLen] or tList[5]
end

function ExpansionDungeonShopItem:_getBuyOrNotBuyImage(bBuy)
	bBuy = bBuy or false
	if bBuy then
		return "ui/text/txt-small-btn/yigoumai.png"
	else
		return "ui/text/txt-small-btn/goumai.png"
	end
end

return ExpansionDungeonShopItem