--SpecialActivitySaleListItem.lua
require("app.cfg.special_holiday_info")
local FunctionLevelConst = require("app.const.FunctionLevelConst")

local SpecialActivitySaleListItem = class("SpecialActivitySaleListItem", function ( ... )
	return CCSItemCellBase:create("ui_layout/specialActivity_SellListItem.json")
end)

function SpecialActivitySaleListItem:ctor( ... )
	self:attachImageTextForBtn("Button_buy", "Image_34")

	self:enableLabelStroke("Label_title", Colors.strokeBrown, 1 )
	self:enableLabelStroke("Label_name", Colors.strokeBrown, 1 )

	self._titleLabel = self:getLabelByName("Label_title")
	self._miniIcon = self:getImageViewByName("Image_miniIcon")
	self._sizeLabel = self:getLabelByName("Label_size")
	self._timesLabel = self:getLabelByName("Label_times")
	self._discountImg = self:getImageViewByName("Image_discount")

	self._getButton = self:getButtonByName("Button_buy")
	self:registerBtnClickEvent("Button_buy", function (  )
		self:buyFunc()
		end)
end

function SpecialActivitySaleListItem:buyFunc( )
	local arr1 = G_ServerTime:getLeftSeconds(self._data.start_time)
	local arr2 = G_ServerTime:getLeftSeconds(self._data.end_time)
	if arr1 > 0 then
		G_MovingTip:showMovingTip(G_lang:get("LANG_SPECIAL_ACTIVITY_BUYTIME_AFTER"))
		return
	end
	if arr2 < 0 then
		G_MovingTip:showMovingTip(G_lang:get("LANG_SPECIAL_ACTIVITY_BUYTIME_BEFORE"))
		return
	end
	local awardCount = self._curInfo and self._curInfo.count or 0
	if G_Me.userData.gold < self._data.price then
	    require("app.scenes.shop.GoldNotEnoughDialog").show()
	    return
	end
	local leftCount = self._data.time_self-awardCount
	local buyCount = math.floor(G_Me.userData.gold/self._data.price)
	buyCount = self._data.time_self > 0 and math.min(leftCount,buyCount) or buyCount
	local RichShopItemSellLayer = require "app.scenes.dafuweng.RichShopItemSellLayer"
	local layer = RichShopItemSellLayer.create(
	    self._data.type, 
	    self._data.value,
	    self._data.size,
	    self._data.price_type, 
	    self._data.price, 
	    buyCount, 
	    function(count, layer)
	        G_HandlersManager.specialActivityHandler:sendBuySpecialHolidaySale(self._data.id,count)
	        layer:animationToClose()                            
	    end)
	uf_sceneManager:getCurScene():addChild(layer)
end

function SpecialActivitySaleListItem:updateData( data )
	self._data = data
	self._curInfo = G_Me.specialActivityData:getCurShop(data.id)
	local awardCount = self._curInfo and self._curInfo.count or 0
	local g = G_Goods.convert(data.type, data.value)
	self._titleLabel:setText(g.name)
	self._titleLabel:setColor(Colors.getColor(g.quality))
	self._timesLabel:setVisible(data.time_self>0)
	self._timesLabel:setText(G_lang:get("LANG_SPECIAL_ACTIVITY_BUYTIMES",{times=data.time_self-awardCount}))
	self._getButton:setTouchEnabled(data.time_self == 0 or data.time_self-awardCount>0)
	self._sizeLabel:setText(data.price)
	if data.discount > 0 then
		self._discountImg:setVisible(true)
		self._discountImg:loadTexture(G_Path.getDiscountImage(data.discount))
	else
		self._discountImg:setVisible(false)
	end

	self:getImageViewByName("Image_icon"):loadTexture(g.icon)
	self:getImageViewByName("Image_pingji"):loadTexture(G_Path.getEquipColorImage(g.quality,data.type))
	self:getImageViewByName("Image_back"):loadTexture(G_Path.getEquipIconBack(g.quality))
	self:getLabelByName("Label_name"):setText("x"..GlobalFunc.ConvertNumToCharacter4(data.size))
	self:registerWidgetClickEvent("Image_icon",function (  )
		require("app.scenes.common.dropinfo.DropInfo").show(data.type,data.value) 
	end)
end

return SpecialActivitySaleListItem