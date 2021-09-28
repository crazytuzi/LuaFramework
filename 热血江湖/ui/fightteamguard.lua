-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------
wnd_fightTeamGuard = i3k_class("wnd_fightTeamGuard", ui.wnd_base)

local ZDWDHT = "ui/widgets/zdwdht"

function wnd_fightTeamGuard:ctor()

end

function wnd_fightTeamGuard:configure(...)
	local widgets = self._layout.vars
	self._widgets = {}
	self._widgets.scroll1 = widgets.scroll1
	self._widgets.scroll2 = widgets.scroll2
	self._widgets.teamName1 = widgets.teamName1
	self._widgets.teamName2 = widgets.teamName2
end

function wnd_fightTeamGuard:refresh()
	self:reladTeamName()
	self:reloadTeamScroll()
end

function wnd_fightTeamGuard:reladTeamName()
	local name1, name2 = g_i3k_game_context:GetFightTeamGuardTeamName()
	if name1 and name2 then
		self._widgets.teamName1:setText(name1)
		self._widgets.teamName2:setText(name2)
	end
end

function wnd_fightTeamGuard:reloadTeamScroll()
	local team1, team2 = g_i3k_game_context:GetFightTeamGuardData()
	self:laodTeamScroll(self._widgets.scroll1, team1)
	self:laodTeamScroll(self._widgets.scroll2, team2)
end

function wnd_fightTeamGuard:laodTeamScroll(scroll, info)
	if info and #info > 0 then
		scroll:removeAllChildren()
		local membersInfo = g_i3k_db.i3k_db_sort_fightteam_member(info, 0, 2) -- 队长id参数0 按照职业排序
		local allWidget = scroll:addChildWithCount(ZDWDHT, 5, #membersInfo)
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
		scroll:stateToNoSlip()
	end
end

function wnd_fightTeamGuard:onLivesChanged(roleId)
	local widget = self:getWidget(roleId)
	if widget then
		local lives = g_i3k_game_context:getGuardMemberLives(roleId)
		widget.vars.livesTxt:setText(lives)
		if lives == 0 then
			widget.vars.typeImg:disableWithChildren()
		end
	end
end

function wnd_fightTeamGuard:onHpChanged(roleId, curHp, maxHp)
	local widget = self:getWidget(roleId)
	if widget then
		widget.vars.blood:setPercent(curHp/maxHp*100)
	end
end

function wnd_fightTeamGuard:getWidget(roleId)
	for i=1, 2 do
		local scroll = self._widgets["scroll"..i]
		local allChild = scroll:getAllChildren()
		for _, e in ipairs(allChild) do
			if e.vars.root:getTag() == roleId then
				return e
			end
		end
	end
	return nil
end

function wnd_create(layout, ...)
	local wnd = wnd_fightTeamGuard.new();
		wnd:create(layout, ...);
	return wnd;
end
