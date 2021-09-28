-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------
wnd_fightTeamSummary = i3k_class("wnd_fightTeamSummary", ui.wnd_base)

local ZDWDHT = "ui/widgets/zdwdht"

function wnd_fightTeamSummary:ctor()

end

function wnd_fightTeamSummary:configure(...)
	local widgets = self._layout.vars
	self.scroll = widgets.scroll
	self.ownLives = widgets.ownLives -- 自己的
	self.selfLives = widgets.selfLives -- 战队
	self.enemyLives = widgets.enemyLives -- 敌方
	self.selfHonor = widgets.selfHonor
end

function wnd_fightTeamSummary:refresh()
	self:reloadTeamScroll()
	self:reloadLivesInfo()
	self:reloadSelfHonor()
	self:reloadOwnLives()
end

function wnd_fightTeamSummary:reloadTeamScroll()
	self.scroll:removeAllChildren()
	local info = g_i3k_game_context:getFightTeaemMapInfo()
	local membersInfo = g_i3k_db.i3k_db_sort_fightteam_member(info, g_i3k_game_context:getFightTeamLeaderID(), 2)
	local allWidget = self.scroll:addChildWithCount(ZDWDHT, 4, #membersInfo)
	for i, e in ipairs(allWidget) do
		local node = e.vars
		if membersInfo[i] then
			local details = membersInfo[i].details
			local overview = details.profile.overview
			local curHp = details.profile.curHp
			local maxHp = details.profile.maxHp
			node.typeImg:setImage(g_i3k_db.i3k_db_get_icon_path(i3k_db_generals[overview.type].classImg))
			node.livesTxt:setText(details.lives)
			node.blood:setPercent(curHp/maxHp*100)
			if details.lives == 0 then
				node.typeImg:disableWithChildren()
			end
			node.root:setTag(overview.id)
		end
	end
	self.scroll:stateToNoSlip()
end

function wnd_fightTeamSummary:reloadOwnLives()
	local lives = g_i3k_game_context:getFightTeamMemberLives(g_i3k_game_context:GetRoleId())
	self.ownLives:setText(lives)
end

function wnd_fightTeamSummary:onLivesChanged(roleId)
	local widget = self:getWidget(roleId)
	if widget then
		local lives = g_i3k_game_context:getFightTeamMemberLives(roleId)
		widget.vars.livesTxt:setText(lives)
		if lives == 0 then
			widget.vars.typeImg:disableWithChildren()
		end
	end
end

function wnd_fightTeamSummary:onHpChanged(roleId, curHp, maxHp)
	local widget = self:getWidget(roleId)
	if widget then
		widget.vars.blood:setPercent(curHp/maxHp*100)
	end
end

function wnd_fightTeamSummary:getWidget(roleId)
	local allChild = self.scroll:getAllChildren()
	for i,v in ipairs(allChild) do
		if v.vars.root:getTag() == roleId then
			return v
		end
	end
	return nil
end

function wnd_fightTeamSummary:reloadLivesInfo()
	local livesInfo = g_i3k_game_context:getFightTeamLives()
	if livesInfo.self then 
		self.selfLives:setText(i3k_get_string(1235, livesInfo.self))
		self.enemyLives:setText(i3k_get_string(1236, livesInfo.enemy))
	end
end

function wnd_fightTeamSummary:reloadSelfHonor()
	self.selfHonor:setText(i3k_get_string(1237, g_i3k_game_context:getFightTeamHonor()))
end

function wnd_create(layout, ...)
	local wnd = wnd_fightTeamSummary.new();
		wnd:create(layout, ...);
	return wnd;
end
