------------------------------------------------------
module(...,package.seeall)

local require = require

local ui = require('ui/base')
------------------------------------------------------
wnd_lottery_posibility = i3k_class("wnd_lottery_posibility",ui.wnd_base)

local WIDGET = "ui/widgets/glgst"

function wnd_lottery_posibility:configure()
	self._layout.vars.close:onClick(self,self.onCloseUI)
end

function wnd_lottery_posibility:refresh(data)
	local scroll = self._layout.vars.scroll
	scroll:removeAllChildren()
	for i,v in ipairs(data) do
		local ui = require(WIDGET)()
		local vars = ui.vars
		vars.quality:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(v.id))
		vars.icon:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(v.id, g_i3k_game_context:IsFemaleRole()))
		vars.name:setText(g_i3k_db.i3k_db_get_common_item_name(v.id))
		vars.level:setText(string.format("%.2f%%", v.probability * 100))
		scroll:addItem(ui)
	end
end
---------------------------------------------------------
function wnd_create(layout,...)
	local wnd = wnd_lottery_posibility.new()
	wnd:create(layout,...)
	return wnd
end