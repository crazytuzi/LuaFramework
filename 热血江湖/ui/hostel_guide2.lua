-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------
wnd_hostel_guide2 = i3k_class("wnd_hostel_guide2", ui.wnd_base)

function wnd_hostel_guide2:ctor()
	
end

function wnd_hostel_guide2:configure()
	self._layout.vars.closeBtn:onClick(self, self.onCloseUI, function ()
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_Activity, "finishTreasureGuide")
	end)
	local widgets = self._layout.vars
	self._chipNodeTable = {}
	for i=1, 3 do
		local node = {}
		node.gradeIcon = widgets["gradeIcon"..i]
		node.icon = widgets["icon"..i]
		node.countLabel = widgets["countLabel"..i]
		self._chipNodeTable[i] = node
		node.gradeIcon:hide()
	end
end

function wnd_hostel_guide2:onShow()
	local chipsTable = i3k_clone(i3k_db_treasure_base.initChips)
	self._layout.vars.descLabel:setText(i3k_get_string(15157))
	for i,v in ipairs(chipsTable) do
		local node = self._chipNodeTable[i]
		local chipCfg = i3k_db_treasure_chip[v.id]
		node.gradeIcon:setImage(g_i3k_get_icon_frame_path_by_rank(chipCfg.rank))
		node.icon:setImage(g_i3k_db.i3k_db_get_icon_path(chipCfg.iconID))
		node.countLabel:setText("x"..v.count)
		node.gradeIcon:show()
	end
end

function wnd_hostel_guide2:refresh()
	
end

--[[function wnd_hostel_guide2:onClose(sender)
	g_i3k_ui_mgr:InvokeUIFunction(eUIID_Activity, "finishTreasureGuide")
	g_i3k_ui_mgr:CloseUI(eUIID_HostelGuide2)
end--]]

function wnd_create(layout, ...)
	local wnd = wnd_hostel_guide2.new()
	wnd:create(layout, ...)
	return wnd;
end