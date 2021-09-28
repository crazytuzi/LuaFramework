------------------------------------------------------
module(...,package.seeall)

local require = require

require("ui/ui_funcs")

local ui = require('ui/base')
------------------------------------------------------
wnd_yilueByPoint = i3k_class("wnd_yilueByPoint",ui.wnd_base)

function wnd_yilueByPoint:configure()
	self.ui = self._layout.vars
	self.ui.close_btn:onClick(self, self.onCloseUI)
	self.buyTimes = 0
	self.ui.buyBtn:onClick(self, self.onBuyClick)
	self.isEnough = true
end

function wnd_yilueByPoint:refresh(buyTimes)
	self.buyTimes = buyTimes
	local maxPoint = i3k_db_bagua_yilue_pointCfg[#i3k_db_bagua_yilue_pointCfg].point
	local curPoint = i3k_db_bagua_yilue_pointCfg[self.buyTimes] and i3k_db_bagua_yilue_pointCfg[buyTimes].point or 0
	self.ui.des1:setText(i3k_get_string(18247, curPoint, maxPoint))
	self.ui.des2:setText(i3k_get_string(18264))
	local newCount = i3k_db_bagua_yilue_pointCfg[self.buyTimes + 1].point - curPoint
	self.ui.des4:setText(i3k_get_string(18248, newCount))
	self:refreshNeedItem()
end

function wnd_yilueByPoint:refreshNeedItem()
	self.isEnough = true
	self.ui.scroll:removeAllChildren()
	for k,v in pairs(i3k_db_bagua_yilue_pointCfg[self.buyTimes + 1].buyCfg) do
		local item = require("ui/widgets/baguaysdgmt")()
		item.vars.item_icon:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(k, g_i3k_game_context:IsFemaleRole()))
		item.vars.item_bg:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(k))
		if math.abs(k) == g_BASE_ITEM_DIAMOND or math.abs(k) == g_BASE_ITEM_COIN then
			item.vars.item_count:setText(v)
		else
			item.vars.item_count:setText(g_i3k_game_context:GetCommonItemCanUseCount(k).."/"..v)
		end
		item.vars.item_count:setTextColor(g_i3k_get_cond_color(v <= g_i3k_game_context:GetCommonItemCanUseCount(k)))
		if self.isEnough then
			self.isEnough = v <= g_i3k_game_context:GetCommonItemCanUseCount(k)
		end
		item.vars.btn:onClick(self, self.onItemTips, k)
		item.vars.suo:setVisible(g_i3k_db.i3k_db_get_consume_lock_visible(k))
		self.ui.scroll:addItem(item)
	end
end

function wnd_yilueByPoint:onItemTips(sender, itemID)
	g_i3k_ui_mgr:ShowCommonItemInfo(itemID)
end

function wnd_yilueByPoint:onBuyClick(sender)
	if self.isEnough then
		i3k_sbean.buyYiluePoint(self.buyTimes + 1)
	else
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(18246))
	end
end

---------------------------------------------------------
function wnd_create(layout,...)
	local wnd = wnd_yilueByPoint.new()
	wnd:create(layout,...)
	return wnd
end
