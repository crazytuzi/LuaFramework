-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------
wnd_tournamentWeaponResult = i3k_class("wnd_tournamentWeaponResult", ui.wnd_base)

local WIDGET_SQLZZJT1 = "ui/widgets/sqlzzjt1"
local WIDGET_SQLZZJT2 = "ui/widgets/sqlzzjt2"

function wnd_tournamentWeaponResult:ctor()

end

function wnd_tournamentWeaponResult:configure()
	local widgets = self._layout.vars
	
	self.titleIcon = widgets.titleIcon
	self.scroll = widgets.scroll

	widgets.close_btn:onClick(self, self.onCloseUI)
end

function wnd_tournamentWeaponResult:refresh(win, resultTeams)
	local iconID = win == 1 and 6137 or 6138
	self.titleIcon:setImage(g_i3k_db.i3k_db_get_icon_path(iconID))
	self:loadScrollInfo(self:sortTeamsInfo(resultTeams))
end

function wnd_tournamentWeaponResult:loadScrollInfo(teamsInfo)
	self.scroll:removeAllChildren()
	for i, e in ipairs(teamsInfo) do
		local titleNode = require(WIDGET_SQLZZJT1)()
		local bgIconID = e.forceType == g_i3k_game_context:GetForceType() and 6136 or 6135
		titleNode.vars.bgIcon:setImage(g_i3k_db.i3k_db_get_icon_path(bgIconID))
		self.scroll:addItem(titleNode)
		for _, mInfo in ipairs(e.membersInfo) do
			local memberNode = require(WIDGET_SQLZZJT2)()
			memberNode.vars.nameLabel:setText(mInfo.name)
			memberNode.vars.killLabel:setText(mInfo.kills)
			memberNode.vars.deadLabel:setText(mInfo.dead)
			memberNode.vars.teamScoreLabel:setText(mInfo.teamScore) --灵能
			memberNode.vars.honorLabel:setText("+"..mInfo.addHonor)
			memberNode.vars.coinLabel:setText("+"..mInfo.addHonor)
			if mInfo.rid == g_i3k_game_context:GetRoleId() then
				local orangeColor = "FFF27C26 "
				memberNode.vars.nameLabel:setTextColor(orangeColor)
				memberNode.vars.killLabel:setTextColor(orangeColor)
				memberNode.vars.deadLabel:setTextColor(orangeColor)
				memberNode.vars.teamScoreLabel:setTextColor(orangeColor)
				memberNode.vars.honorLabel:setTextColor(orangeColor)
				memberNode.vars.coinLabel:setTextColor(orangeColor)
			end
			self.scroll:addItem(memberNode)
		end
	end
end

function wnd_tournamentWeaponResult:sortTeamsInfo(resultTeams)
	local selfForceType = g_i3k_game_context:GetForceType()
	local teamsInfo = {}
	for k, v in pairs(resultTeams) do
		local membersInfo = {}
		for _, t in pairs(v.members) do
			table.insert(membersInfo, t)
		end
		table.sort(membersInfo, function (a, b)
			return a.addHonor < b.addHonor
		end)
		local order = k == selfForceType and k * 100 or k * 10
		table.insert(teamsInfo, {order = order, forceType = k, membersInfo = membersInfo})
	end
	table.sort(teamsInfo, function (m, n)
		return m.order > n.order
	end)
	return teamsInfo
end

function wnd_create(layout, ...)
	local wnd = wnd_tournamentWeaponResult.new();
		wnd:create(layout, ...);
	return wnd;
end
