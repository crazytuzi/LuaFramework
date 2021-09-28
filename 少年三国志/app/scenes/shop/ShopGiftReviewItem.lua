local ShopGiftReviewItem = class("ShopGiftReviewItem",function()
    return CCSItemCellBase:create("ui_layout/shop_ShopGiftReviewItem.json")
end)

function ShopGiftReviewItem:ctor(...)
	self._func = nil
	self._itemImage = self:getImageViewByName("ImageView_item")
	self._itemBgImage = self:getImageViewByName("ImageView_item_bg")
	self._nameLabel = self:getLabelByName("Label_name")
	self._descLabel = self:getLabelByName("Label_description")
	self._itemButton = self:getButtonByName("Button_item")
	self._numLabel = self:getLabelByName("Label_num")
	self._nameLabel:createStroke(Colors.strokeBrown,1)
	self._numLabel:createStroke(Colors.strokeBrown,1)
	self:registerBtnClickEvent("Button_item",function()
		if self._func ~= nil then
			self._func()
		end
		end)
end

function ShopGiftReviewItem:updateCell(goods)
	if goods == nil then
		return
	end
	self._numLabel:setText("x" .. G_GlobalFunc.ConvertNumToCharacter(goods.size))
	self._descLabel:setText(goods.desc)
	self._nameLabel:setColor(Colors.qualityColors[goods.quality])
	self._nameLabel:setText(goods.name)
	self._itemButton:loadTextureNormal(G_Path.getEquipColorImage(goods.quality,goods.type))
	self._itemButton:loadTexturePressed(G_Path.getEquipColorImage(goods.quality,goods.type))
	self._itemImage:loadTexture(goods.icon)
	self._itemBgImage:loadTexture(G_Path.getEquipIconBack(goods.quality))
end

function ShopGiftReviewItem:setClickIcon( func )
	self._func = func
end

return ShopGiftReviewItem