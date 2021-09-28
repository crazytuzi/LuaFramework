------------------------------------------------------
module(...,package.seeall)

local require = require

require("ui/ui_funcs")

local ui = require('ui/base')
------------------------------------------------------
wnd_yilueResetPoint = i3k_class("wnd_yilueResetPoint",ui.wnd_base)

function wnd_yilueResetPoint:configure()
	self.ui = self._layout.vars
	self.ui.cancel:onClick(self, self.onCloseUI)
	self.ui.ok:onClick(self, self.onResetClick)
	self.id = 0
	self.isEnough = true
end

function wnd_yilueResetPoint:refresh(id)
	self.id = id
	self.ui.desc:setText(i3k_get_string(18245))
	self:refreshNeedItem()
end

function wnd_yilueResetPoint:refreshNeedItem()
	self.ui.scroll:removeAllChildren()
	self.isEnough = true
	for k,v in pairs(i3k_db_bagua_cfg.yilueResetPointNeed) do
		local item = require("ui/widgets/baguaysdczt")()
		item.vars.item_icon:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(k, g_i3k_game_context:IsFemaleRole()))
		item.vars.item_bg:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(k))
		if g_i3k_db.i3k_db_check_item_haveCount_isShow(k) then
			item.vars.num:setText(g_i3k_game_context:GetCommonItemCanUseCount(k).."/"..v.count)
		else
			item.vars.num:setText(v.count)
		end
		item.vars.num:setTextColor(g_i3k_get_cond_color(v.count <= g_i3k_game_context:GetCommonItemCanUseCount(k)))
		if self.isEnough then
			self.isEnough = g_i3k_game_context:GetCommonItemCanUseCount(k) >= v.count
		end 
		item.vars.btn:onClick(self, self.onItemTips, k)
		item.vars.lock:setVisible(g_i3k_db.i3k_db_get_consume_lock_visible(k))
		self.ui.scroll:addItem(item)
	end
end

function wnd_yilueResetPoint:onItemTips(sender, itemID)
	g_i3k_ui_mgr:ShowCommonItemInfo(itemID)
end

function wnd_yilueResetPoint:onResetClick(sender)
	if self.isEnough then
		i3k_sbean.ResetAddPoint(self.id)
	else
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(18246))
	end
end

---------------------------------------------------------
function wnd_create(layout,...)
	local wnd = wnd_yilueResetPoint.new()
	wnd:create(layout,...)
	return wnd
end
