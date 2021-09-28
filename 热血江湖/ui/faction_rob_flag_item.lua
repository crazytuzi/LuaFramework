-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------
wnd_faction_rob_flag_item = i3k_class("wnd_faction_rob_flag_item", ui.wnd_base)

local FLAGAWARD = "ui/widgets/dqtipst"

function wnd_faction_rob_flag_item:ctor()
	
end

function wnd_faction_rob_flag_item:configure()
	local widgets = self._layout.vars
	self._scroll1 = widgets.scroll1
	self._scroll2 = widgets.scroll2
	widgets.imgBK:onClick(self, self.close)
end

function wnd_faction_rob_flag_item:refresh(mapId)
	local robItems = i3k_db_faction_map_flag[mapId].robItems
	local normalItems = i3k_db_faction_map_flag[mapId].normalItems
	for k, v in ipairs(robItems) do
		if v[1] ~= 0 and v[2] ~= 0 then
			local layer = require(FLAGAWARD)()
			layer.vars.item_bg:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(v[1]))
			layer.vars.item_icon:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(v[1]))
			layer.vars.btn:onClick(self, self.onItem, v[1])
			layer.vars.count:setText("x"..v[2])
			layer.vars.lockImg:setVisible(v[1] > 0)
			self._scroll1:addItem(layer)
		end
	end
	for k, v in ipairs(normalItems) do
		if v[1] ~= 0 and v[2] ~= 0 then
			local layer = require(FLAGAWARD)()
			layer.vars.item_bg:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(v[1]))
			layer.vars.item_icon:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(v[1]))
			layer.vars.btn:onClick(self, self.onItem, v[1])
			layer.vars.count:setText("x"..v[2])
			layer.vars.lockImg:setVisible(v[1] > 0)
			self._scroll2:addItem(layer)
		end
	end
end

function wnd_faction_rob_flag_item:onItem(sender, id)
	g_i3k_ui_mgr:ShowCommonItemInfo(id)
end

function wnd_faction_rob_flag_item:close(sender)
	g_i3k_ui_mgr:CloseUI(eUIID_FactionRobFlagItem)
end

function wnd_create(layout, ...)
	local wnd = wnd_faction_rob_flag_item.new()
		wnd:create(layout, ...)
	return wnd
end