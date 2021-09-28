-------------------------------------------------------
module(..., package.seeall)

local require = require

local ui = require("ui/base")

-------------------------------------------------------

wnd_combat_team_list = i3k_class("wnd_combat_team_list", ui.wnd_base)

local NODE_GUANZHANT = "ui/widgets/guanzhant"

function wnd_combat_team_list:ctor()
	
end

function wnd_combat_team_list:configure()
	local widgets = self._layout.vars	
	widgets.sureBtn:onClick(self, self.onCloseUI)
	
	self.scroll = widgets.scroll
end

function wnd_combat_team_list:refresh(briefs)
	self.scroll:removeAllChildren()
	for _, e in ipairs(briefs) do
		local node = require(NODE_GUANZHANT)()
		node.vars.leaderName1:setText(e.leader1.name)
		node.vars.leaderName2:setText(e.leader2.name)
		node.vars.enterBtn:onClick(self, self.onEnter, e)
		self.scroll:addItem(node)
	end
end

function wnd_combat_team_list:onEnter(sender, data)
	if data.guards >= i3k_db_forcewar_base.channelData.guardNum then
		g_i3k_ui_mgr:PopupTipMessage("观战人数已满")
		return
	end
	i3k_sbean.forcewar_guard(data.mapID, data.mapInstance)
end

function wnd_create(layout)
	local wnd = wnd_combat_team_list.new()
	wnd:create(layout)
	return wnd
end
