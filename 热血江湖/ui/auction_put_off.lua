-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------
wnd_auction_put_off = i3k_class("wnd_auction_put_off", ui.wnd_base)

function wnd_auction_put_off:ctor()

end

function wnd_auction_put_off:configure()
	self._layout.vars.cancel:onClick(self, function ()
		g_i3k_ui_mgr:CloseUI(eUIID_AuctionPutOff)
	end)
end

function wnd_auction_put_off:onShow()

end

function wnd_auction_put_off:refresh(item)
	local id = item.id
	self._layout.vars.nameLabel:setText(g_i3k_db.i3k_db_get_common_item_name(id))
	local rank = g_i3k_db.i3k_db_get_common_item_rank(id)
	self._layout.vars.nameLabel:setTextColor(g_i3k_db.g_i3k_get_color_by_rank(rank))
	self._layout.vars.descLabel:setText(g_i3k_db.i3k_db_get_common_item_desc(id))
	self._layout.vars.gradeIcon:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(id))
	self._layout.vars.icon:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(id,i3k_game_context:IsFemaleRole()))
	self._layout.vars.priceLabel:setText(item.price)
	self._layout.vars.countLabel:setText("x"..item.count)

	local typeId = g_i3k_db.i3k_db_get_auction_item_type(id)
	local itemType = i3k_db_auction_type[typeId]
	self._layout.vars.typeLabel:setText(itemType and itemType.name or i3k_db_auction_type[100].name)

	self._layout.vars.ok:onClick(self, self.putOff, item)
end

function wnd_auction_put_off:putOff(sender, item)
	i3k_log("交易Id ="..item.dealId)
	local isEnough = g_i3k_game_context:IsBagEnough({[item.id] = item.count})
	if isEnough then
		local message = i3k_get_string(246, g_i3k_db.i3k_db_get_common_item_name(item.id))
		local callback = function (isOk)
			if isOk then
				i3k_sbean.putOffItem(item)
			end
		end
		g_i3k_ui_mgr:ShowMessageBox2(message, callback)
	else
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(252))
	end
end

function wnd_create(layout, ...)
	local wnd = wnd_auction_put_off.new()
	wnd:create(layout, ...)
	return wnd;
end
