-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------
-- 师徒商店购买界面

master_store_buy = i3k_class("master_store_buy", ui.wnd_base)
function master_store_buy:ctor()
	self._id = nil
end

function master_store_buy:configure(...)
	local widgets = self._layout.vars
	widgets.close_btn:onClick(self,self.onCloseUI)
	widgets.buy_btn:onClick(self,self.onClickBuy)
end

function wnd_create(layout, ...)
	local wnd = master_store_buy.new()
	wnd:create(layout, ...)

	return wnd
end
-- 商品在购买列表里的索引
function master_store_buy:refresh(idx)
	if idx==nil then
		return
	end
	self.idx = idx
	local shopinfo = g_i3k_game_context:GetMasterShopInfo()
	if shopinfo==nil then
		return
	end
	local itemCfg = i3k_db_master_store.item_data[shopinfo.goods[self.idx].id]
	if itemCfg==nil then
		return
	end
	
	local widgets = self._layout.vars
	widgets.money_icon:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(itemCfg.moneyType,i3k_game_context:IsFemaleRole()))
	widgets.money_count:setText(itemCfg.moneyCount)
	widgets.item_bg:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(itemCfg.itemID))		
	widgets.item_icon:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(itemCfg.itemID,i3k_game_context:IsFemaleRole()))
	local tmp_str = string.format("%s*%s",g_i3k_db.i3k_db_get_common_item_name(itemCfg.itemID),itemCfg.itemCount)				
	widgets.item_name:setText(tmp_str)
	widgets.item_name:setTextColor(g_i3k_get_color_by_rank(g_i3k_db.i3k_db_get_common_item_rank(itemCfg.itemID)))
	widgets.item_desc:setText(g_i3k_db.i3k_db_get_common_item_desc(itemCfg.itemID))
end 
----------------------------------------------------------

function master_store_buy:onClickBuy()
	if self.idx==nil then
		return
	end
	-- 购买物品
	local shopinfo = g_i3k_game_context:GetMasterShopInfo()
	local itemCfg = i3k_db_master_store.item_data[shopinfo.goods[self.idx].id]

	local buyTimes = shopinfo.goods[self.idx].buyTimes
	if buyTimes==1 then
		g_i3k_ui_mgr:PopupTipMessage("商品已经售完")
		return
	end
	local point = g_i3k_game_context:GetBaseItemCanUseCount(itemCfg.moneyType)	
	if point < itemCfg.moneyCount then
		g_i3k_ui_mgr:PopupTipMessage("所需货币不足，购买失败")
		return 
	end

	
	local t = {[itemCfg.itemID] = itemCfg.itemCount,}
	local bEnough = g_i3k_game_context:IsBagEnough(t)
	if not bEnough then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(123))
		return 
	end
	-- 发送购买协议
	local tmp_str = string.format("成功购买了%s*%s",itemCfg.itemName,itemCfg.itemCount)
	i3k_sbean.master_shop_buy_item(self.idx,tmp_str)

	self:onCloseUI()
end
