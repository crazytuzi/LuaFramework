-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------
wnd_fulingReset = i3k_class("wnd_fulingReset", ui.wnd_base)

function wnd_fulingReset:ctor()

end

function wnd_fulingReset:configure()
	local widgets = self._layout.vars
	widgets.cancel:onClick(self, self.onCloseUI)
	widgets.ok:onClick(self, self.onResetBtn)
	widgets.desc:setText(i3k_get_string(17211))
end

function wnd_fulingReset:refresh()
	local times = g_i3k_game_context:getFulingResetTimes()
	local consumes
	if i3k_db_longyin_sprite_reset[times + 1] then
		consumes = i3k_db_longyin_sprite_reset[times + 1].consumes
	else
		consumes = i3k_db_longyin_sprite_reset[#i3k_db_longyin_sprite_reset].consumes
	end
	self:setScroll(consumes)
	self._consumes = consumes
end

function wnd_fulingReset:setScroll(items)
	local widgets = self._layout.vars
	local scroll = widgets.scroll
	scroll:removeAllChildren()
	self._itemsEnough = true
	for k, v in ipairs(items) do
		local ui = require("ui/widgets/lyflczt")()
		local itemID = v.id
		ui.vars.item_bg:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(itemID))
		ui.vars.item_icon:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(itemID))
		ui.vars.lock:setVisible(itemID > 0)
		ui.vars.btn:onClick(self, self.onItemTips, itemID)
		local haveCount = g_i3k_game_context:GetCommonItemCanUseCount(v.id)
		if math.abs(itemID) == g_BASE_ITEM_COIN then
			ui.vars.num:setText((v.count))
		else
			ui.vars.num:setText((haveCount).."/"..(v.count))
		end

		ui.vars.num:setTextColor(g_i3k_get_cond_color(haveCount >= v.count))
		if haveCount < v.count then
			self._itemsEnough = false
		end
		scroll:addItem(ui)
	end
end

function wnd_fulingReset:onResetBtn(sender)
	if not self._itemsEnough then
		g_i3k_ui_mgr:PopupTipMessage("道具不足")
		return
	end
	local items = g_i3k_game_context:getFulingResetGetItems()
	i3k_sbean.fulingResetPoint(self._consumes, items)
end

function wnd_fulingReset:onItemTips(sender, itemID)
	g_i3k_ui_mgr:ShowCommonItemInfo(itemID)
end

function wnd_create(layout, ...)
	local wnd = wnd_fulingReset.new()
	wnd:create(layout, ...)
	return wnd;
end
