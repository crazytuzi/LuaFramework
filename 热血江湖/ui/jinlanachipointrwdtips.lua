-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------

wnd_JAPRT = i3k_class("wnd_JAPRT",ui.wnd_base)

function wnd_JAPRT:ctor()
	
end

function wnd_JAPRT:configure()
	local widgets = self._layout.vars
	self.ui = {}
	self.ui.close = widgets.closeBtn
	self.ui.desc = widgets.itemDesc_label  --描述
    self.ui.name = widgets.itemName_label   --道具名称*N
	self.ui.bg = widgets.item_bg					--bg
	self.ui.icon = widgets.item_icon				--icon
	widgets.extra_text:setText("")
	self.ui.close:onClick(self, self.onCloseUI)
end

function wnd_JAPRT:refresh(id, count, objective)
	self.ui.desc:setText(i3k_get_string(5517, objective))
	self.ui.bg:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(id))
	self.ui.name:setText(g_i3k_db.i3k_db_get_common_item_name(id)..'*'..count)
	local color = g_i3k_get_color_by_rank(g_i3k_db.i3k_db_get_common_item_rank(id))
	self.ui.name:setTextColor(color)
	self.ui.icon:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(id, i3k_game_context:IsFemaleRole()))
end

function wnd_create(layout)
	local wnd = wnd_JAPRT.new()
		wnd:create(layout)
	return wnd
end
