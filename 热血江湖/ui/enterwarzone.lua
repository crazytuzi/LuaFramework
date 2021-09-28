-------------------------------------------------------
module(..., package.seeall)

local require = require

local ui = require("ui/base")

-------------------------------------------------------

wnd_enterWarZone = i3k_class("wnd_enterWarZone",ui.wnd_base)

function wnd_enterWarZone:ctor()

end

function wnd_enterWarZone:configure()
	local widgets = self._layout.vars
	widgets.closeBtn:onClick(self, self.onCloseUI)
end

function wnd_enterWarZone:refresh()
	local widgets = self._layout.vars
	widgets.desc:setText(i3k_get_string(5789))
	for i, e in ipairs(i3k_db_war_zone_map_type) do
		widgets["icon"..i]:setImage(g_i3k_db.i3k_db_get_icon_path(e.lineIconID))
		widgets["desc"..i]:setText(i3k_get_string(e.mapDesc))
		widgets["enterBtn"..i]:onClick(self, self.onEnterBtn, e.mapID)
	end
end

function wnd_enterWarZone:onEnterBtn(sender, mapID)
	g_i3k_game_context:IntoWarZone(mapID)
end

function wnd_create(layout)
	local wnd = wnd_enterWarZone.new()
	wnd:create(layout)
	return wnd
end
