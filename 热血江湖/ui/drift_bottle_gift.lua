-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------
wnd_drift_bottle_gift = i3k_class("wnd_drift_bottle_gift", ui.wnd_base)



function wnd_drift_bottle_gift:ctor()
	
end

function wnd_drift_bottle_gift:configure()
	local widgets = self._layout.vars
	widgets.ok:onClick(self, self.onOk)
end

function wnd_drift_bottle_gift:refresh(data, callback)
	self.callback = callback
	local id = data.bottle.item
	local count = data.bottle.count
	local widgets = self._layout.vars
	widgets.item_bg1:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(id))
	widgets.item_icon1:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(id))
	widgets.item_icon1:onClick(self, self.onItem, id)
	widgets.suo:show()
	widgets.item_desc1:setText(g_i3k_db.i3k_db_get_common_item_name(id))
	widgets.item_count:setText("x"..count)
	widgets.exp1:setText("+"..data.exp)
	widgets.desc:setText(data.bottle.msg)
end

function wnd_drift_bottle_gift:onItem(sender, id)
	g_i3k_ui_mgr:ShowCommonItemInfo(id)
end

function wnd_drift_bottle_gift:onOk(sender)
	if self.callback then
		self.callback()
	end
end

function wnd_create(layout, ...)
	local wnd = wnd_drift_bottle_gift.new();
		wnd:create(layout, ...);
	return wnd;
end

