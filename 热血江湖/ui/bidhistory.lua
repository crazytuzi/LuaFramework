-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------
wnd_bidHistory = i3k_class("wnd_bidHistory", ui.wnd_base)

function wnd_bidHistory:ctor()

end

function wnd_bidHistory:configure()
	local widgets = self._layout.vars
	widgets.close_btn:onClick(self, self.onCloseUI)
end

function wnd_bidHistory:onShow()

end

--self.gid:		int32
--self.buyPrice:		int32
--self.buyRole:		int32
--self.buyRoleName:		string
--self.buyRoleGsid:		int32
--self.buyTime:		int32

function wnd_bidHistory:refresh(info)
	self:updateScroll(info)
end

function wnd_bidHistory:updateScroll(items)
	local widgets = self._layout.vars
	widgets.item_scroll:removeAllChildren()
	table.sort(items, function(a, b)
		return a.buyTime > b.buyTime
	end)
	for k, v in ipairs(items) do
		local ui = require("ui/widgets/paimaijlt")()
		local cfg = g_i3k_db.i3k_db_get_bid_item_cfg(v.gid)
		if cfg then
			local itemID = cfg.itemID
			local itemCfg = g_i3k_db.i3k_db_get_common_item_cfg(itemID)
			local itemName = g_i3k_db.i3k_db_get_common_item_name(itemID)
			ui.vars.itemBg:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(itemID) )
			ui.vars.itemIcon:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(itemID, g_i3k_game_context:IsFemaleRole()))
			ui.vars.itemCount:setText(cfg.count)
			ui.vars.name_label:setText(itemName)
			ui.vars.itemBtn:onClick(self, self.onItemInfo, itemID)
			ui.vars.buyerName:setText(v.buyRoleName == "" and "匿名玩家" or v.buyRoleName)
			ui.vars.count:setText(v.buyPrice)
			ui.vars.diamond:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(g_BASE_ITEM_DRAGON_COIN, i3k_game_context:IsFemaleRole()))
			ui.vars.gsid:setText(g_i3k_get_show_time(v.buyTime))
			widgets.item_scroll:addItem(ui)
		end
	end
end

function wnd_bidHistory:onItemInfo(sender, itemID)
	g_i3k_ui_mgr:ShowCommonItemInfo(itemID)
end

function wnd_create(layout, ...)
	local wnd = wnd_bidHistory.new()
	wnd:create(layout, ...)
	return wnd;
end
