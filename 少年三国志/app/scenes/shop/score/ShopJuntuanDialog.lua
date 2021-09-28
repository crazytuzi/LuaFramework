local ShopJuntuanDialog = class("ShopJuntuanDialog",UFCCSModelLayer)


require("app.cfg.corps_market_info")
function ShopJuntuanDialog.show(cropId)
	-- body
	local layer = ShopJuntuanDialog.new("ui_layout/shop_ShopJuntuanDialog.json",Colors.modelColor,cropId)
	uf_sceneManager:getCurScene():addChild(layer)
end


function ShopJuntuanDialog:ctor(_,_,cropId)
	self.super.ctor(self)
	self._info = corps_market_info.get(cropId)
	if self._info then
		self._item = G_Goods.convert(self._info.item_type,self._info.item_id,self._info.item_num)
		self:getLabelByName("Label_price"):setText(self._info.price)
	end
	if not self._item then
		self:getLabelByName("Label_content_desc"):setText("")
		self:getLabelByName("Label_item_amount"):setText("")
		self:getLabelByName("Label_price"):setText("")
	else
		self:getLabelByName("Label_content_desc"):setText(self._item.name)
		self:getLabelByName("Label_content_desc"):setColor(Colors.qualityColors[self._item.quality])
		self:getLabelByName("Label_item_amount"):setText("x" .. self._item.size)
		self:getImageViewByName("ImageView_headframe"):loadTexture(G_Path.getEquipColorImage(self._item.quality,self._item.type))
		self:getImageViewByName("ImageView_head"):loadTexture(self._item.icon)
		self:getImageViewByName("ImageView_bg"):loadTexture(G_Path.getEquipIconBack(self._item.quality))
		self:getLabelByName("Label_item_amount"):createStroke(Colors.strokeBrown,1)
		self:getLabelByName("Label_content_desc"):createStroke(Colors.strokeBrown,1)
	end
	self:showAtCenter(true)
	self:_initEvent()
end
function ShopJuntuanDialog:_initEvent()
	self:registerBtnClickEvent("Button_close",function()
		self:animationToClose()
		end)
	self:registerBtnClickEvent("Button_no",function()
		self:animationToClose()
		end)
	self:registerBtnClickEvent("Button_yes",function()
		if self._info then
			G_HandlersManager.shopHandler:sendCorpSpecialShopping(self._info.id)
		end
		self:animationToClose()
		end)
end

function ShopJuntuanDialog:onLayerEnter()
	self:closeAtReturn(true)
	require("app.common.effects.EffectSingleMoving").run(self, "smoving_bounce")
end

return ShopJuntuanDialog