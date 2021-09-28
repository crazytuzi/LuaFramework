-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------
wnd_drift_bottle_extra = i3k_class("wnd_drift_bottle_extra", ui.wnd_base)



function wnd_drift_bottle_extra:ctor()
	
end

function wnd_drift_bottle_extra:configure()
	local widgets = self._layout.vars
	widgets.ok:onClick(self, self.onOk)
end

function wnd_drift_bottle_extra:refresh(item)
	local id = item[1].id
	local count = item[1].count
	local widgets = self._layout.vars
	widgets.item_bg1:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(id))
	widgets.item_icon1:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(id))
	widgets.item_icon1:onClick(self, self.onItem, id)
	widgets.suo:show()
	widgets.item_desc1:setText(g_i3k_db.i3k_db_get_common_item_name(id))
	widgets.item_count:setText("x"..count)
	local rnd = i3k_engine_get_rnd_u(1, #i3k_db_bottle_msg)
	widgets.desc:setText(i3k_db_bottle_msg[rnd])
end

function wnd_drift_bottle_extra:onItem(sender, id)
	g_i3k_ui_mgr:ShowCommonItemInfo(id)
end

function wnd_drift_bottle_extra:onOk(sender)
	g_i3k_ui_mgr:CloseUI(eUIID_DriftBottleExtra)
end

function wnd_create(layout, ...)
	local wnd = wnd_drift_bottle_extra.new();
		wnd:create(layout, ...);
	return wnd;
end

