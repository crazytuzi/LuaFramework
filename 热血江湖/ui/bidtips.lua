-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------
wnd_bidTips = i3k_class("wnd_bidTips", ui.wnd_base)

function wnd_bidTips:ctor()

end

function wnd_bidTips:configure()
	local widgets = self._layout.vars
	widgets.cancel:onClick(self, self.onCloseUI)
	widgets.ok:onClick(self, self.onOkBtn)
	widgets.markBtn:onClick(self, self.onMarkBtn)
	-- widgets.desc:setText(i3k_get_string(16863))
end

function wnd_bidTips:onShow()

end

function wnd_bidTips:refresh(info)
	self._info = info
	local itemID = info.itemID
	local itemName = g_i3k_db.i3k_db_get_common_item_name(itemID)
	local widgets = self._layout.vars
	widgets.desc:setText(i3k_get_string(16863, itemName))
end

function wnd_bidTips:onMarkBtn(sender)
	local widgets = self._layout.vars
	widgets.markImg:setVisible(not widgets.markImg:isVisible())
end

function wnd_bidTips:onOkBtn(sender)
	local widgets = self._layout.vars
	local displayName = widgets.markImg:isVisible()
	local info = self._info
	local needItem = info.needCoinID
	local count = g_i3k_game_context:GetCommonItemCount(needItem)
	if count < info.finalPrice then
		g_i3k_ui_mgr:PopupTipMessage("道具不足")
		return
	end

	i3k_sbean.bidForPrice(info.gid, info.finalPrice, true, displayName, info)
end

function wnd_create(layout, ...)
	local wnd = wnd_bidTips.new()
	wnd:create(layout, ...)
	return wnd;
end
