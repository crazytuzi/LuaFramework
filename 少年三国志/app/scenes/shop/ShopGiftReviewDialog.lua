local ShopGiftReviewDialog = class("ShopGiftReviewDialog",UFCCSModelLayer)
require("app.cfg.item_info")
require("app.cfg.drop_info")
function ShopGiftReviewDialog.create(...)
	return ShopGiftReviewDialog.new("ui_layout/shop_ShopGiftReviewDialog.json",Colors.modelColor,...)
end

function ShopGiftReviewDialog:ctor(json,color,item,...)
	self._listData = {}
	self.super.ctor(self,...)
	self:_initListData(item)
	self:showAtCenter(true)
	self:getLabelByName("Label_tips"):createStroke(Colors.strokeBrown,1)
	self:registerBtnClickEvent("Button_close",function()
		self:animationToClose()
		end)
	local panel = self:getPanelByName("Panel_listview")
	self._listView =  CCSListViewEx:createWithPanel(panel,LISTVIEW_DIR_VERTICAL)
	self._listView:setCreateCellHandler(function(list,index)
		return require("app.scenes.shop.ShopGiftReviewItem").new()
	end)
	
	self._listView:setUpdateCellHandler(function(list,index,cell)
		local data = self._listData[index+1]
		cell:updateCell(data)
		cell:setClickIcon(function()
			require("app.scenes.common.dropinfo.DropInfo").show(data.type,data.info.id) 
			end)
	end)
	self._listView:reloadWithLength(#self._listData,0)
end

function ShopGiftReviewDialog:_initListData(item)
	if item ~= nil and item.item_type == 1 then
		local goods = G_Drops.convert(item.item_value)
		self._listData = goods and goods.goodsArray or {}
	end
end

function ShopGiftReviewDialog:onLayerEnter()
	require("app.common.effects.EffectSingleMoving").run(self, "smoving_bounce")
	self:closeAtReturn(true)
end

return ShopGiftReviewDialog