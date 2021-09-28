-- 家园事件 2018/06/05
-------------------------------------------------------
module(..., package.seeall)

-------------------------------------------------------
local require = require

require("ui/ui_funcs")
local ui = require("ui/base")

-------------------------------------------------------

wnd_homeLandEvent = i3k_class("wnd_homeLandEvent", ui.wnd_base)


local WIDGETS_JIAYUANSJT = "ui/widgets/jiayuansjt"

function wnd_homeLandEvent:ctor()

end

function wnd_homeLandEvent:configure()
	local widgets = self._layout.vars
	self.scroll = widgets.scroll
	widgets.homeLandHistorys:stateToPressed()
	widgets.homeLandProp:onClick(self, self.onHomeLandProp)
	widgets.homeLandEquip:onClick(self, self.onHomeLandEquip)
	widgets.homeLandBuild:onClick(self, self.onHomeLandBulid)
	widgets.close_btn:onClick(self, self.onCloseUI)
end

function wnd_homeLandEvent:refresh(historys)
	self:loadScrollInfo(historys)
end

function wnd_homeLandEvent:loadScrollInfo(historys)
	self.scroll:removeAllChildren()
	table.sort(historys, function (a,b)
		return a.time > b.time
	end)
	for _, e in ipairs(historys) do
		local node = require(WIDGETS_JIAYUANSJT)()
		node.vars.desc_label:setText(g_i3k_db.i3k_db_get_home_land_event_desc(e))
		node.vars.time_label:setText(g_i3k_get_show_time(e.time))
		self.scroll:addItem(node)
	end
end

function wnd_homeLandEvent:onHomeLandProp(sender)
	i3k_sbean.homeland_sync(1)
end

function wnd_homeLandEvent:onHomeLandBulid(sender)
	g_i3k_logic:openHomelandStructureUI(nil, eUIID_HomeLandEvent)
end

function wnd_homeLandEvent:onHomeLandEquip(sender)
	g_i3k_logic:OpenHomeLandEquipUI()
end

function wnd_create(layout)
	local wnd = wnd_homeLandEvent.new()
	wnd:create(layout)
	return wnd
end
