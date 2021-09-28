-------------------------------------------------------
module(..., package.seeall)
local require = require;
local ui = require("ui/base");
-------------------------------------------------------
wnd_auctionSearching = i3k_class("wnd_auctionSearching", ui.wnd_base)

function wnd_auctionSearching:ctor()

end

function wnd_auctionSearching:configure()
	self._layout.vars.cancelBtn:onClick(self, self.onCancel)
end


function wnd_auctionSearching:refresh()

end

function wnd_auctionSearching:onCancel(sender)
	g_i3k_ui_mgr:InvokeUIFunction(eUIID_Auction, "cancelSearch")
	g_i3k_ui_mgr:CloseUI(eUIID_AuctionSearching)
end


function wnd_create(layout)
	local wnd = wnd_auctionSearching.new()
	wnd:create(layout)
	return wnd;
end
