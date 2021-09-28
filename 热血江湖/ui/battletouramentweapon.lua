-------------------------------------------------------
module(..., package.seeall)

local require = require

local ui = require("ui/base")

-------------------------------------------------------

wnd_battleTouramentWeapon = i3k_class("wnd_battleTouramentWeapon",ui.wnd_base)

function wnd_battleTouramentWeapon:ctor()

end

function wnd_battleTouramentWeapon:configure()
	local widgets = self._layout.vars
	self.selfScoreIcon = widgets.selfScoreIcon
	self.selfScoreLabel = widgets.selfScoreLabel
	self._weaponsWidgets = {} --神兵widgets
	for i = 1, 3 do
		local weaponWidget = {}
		weaponWidget.root = widgets["weaponRoot"..i]
		weaponWidget.times = widgets["weaponTimes"..i]
		weaponWidget.btn = widgets["weaponBtn"..i]
		weaponWidget.icon = widgets["weaponIcon"..i]
		weaponWidget.maskIcon = widgets["weaponMaskIcon"..i]
		weaponWidget.isSelect = widgets["isSelect"..i]
		table.insert(self._weaponsWidgets, weaponWidget)
	end
	self._teamWidgets = {} -- 队伍widgets
	for i = 1, 2 do
		local teamWidget = {}
		teamWidget.icon = widgets["teamScoreIcon"..i]
		teamWidget.teamScoreLabel = widgets["teamScoreLabel"..i]
		teamWidget.teamNameLabel = widgets["teamNameLabel"..i]
		table.insert(self._teamWidgets, teamWidget)
	end
	self._skillWidgets = {} --技能
	for i = 1, 3 do
		local skillWidget = {}
		skillWidget.rootBtn = widgets["skill"..i]
		skillWidget.gradeImage = widgets["skill"..i.."k"]
		skillWidget.icon = widgets["image"..i]
		skillWidget.cool = widgets["timer"..i]
		skillWidget.skillNum = widgets["skill"..i.."Num"]
		skillWidget.anisImage = widgets["cool"..i]
		-- skillWidget.cool:hide()
		-- skillWidget.anisImage:hide()
		table.insert(self._skillWidgets, skillWidget)
	end
end

function wnd_battleTouramentWeapon:refresh()
	self:loadScoreIconsAndName()
	self:loadScoresInfo(g_i3k_game_context:GetTournamentWeaponScores())
	self:loadWeaponInfo(g_i3k_game_context:GetTournamentWeaponsInfo())
	self:loadSkillInfo(g_i3k_game_context:GetTournamentWeaponSkillInfo())
end

function wnd_battleTouramentWeapon:loadScoreIconsAndName()
	local icon = g_i3k_db.i3k_db_get_icon_path(i3k_db_tournament_base.weaponWarScoreIcon) 
	self.selfScoreIcon:setImage(icon)
	self.selfScoreLabel:setText("x0")
	for i, e in ipairs(self._teamWidgets) do
		e.icon:setImage(icon)
		e.teamScoreLabel:setText("x0")
	end
end

function wnd_battleTouramentWeapon:loadScoresInfo(scores)
	local teamScores = {}
	for k, v in pairs(scores) do
		if k == g_i3k_game_context:GetForceType() then
			self.selfScoreLabel:setText("x"..v)
		else
			table.insert(teamScores, {forceType = k, score = v})
		end
	end
	table.sort(teamScores, function (a,b)
		return a.forceType > b.forceType
	end)

	for i, e in ipairs(self._teamWidgets) do
		if teamScores[i] then
			e.teamScoreLabel:setText("x"..teamScores[i].score)
		end
	end
end

function wnd_battleTouramentWeapon:loadWeaponInfo(weaponInfo)
	for i, e in ipairs(self._weaponsWidgets) do
		local weapon = weaponInfo[i]
		e.root:setVisible(weapon ~= nil)
		if weapon then
			local id = weapon.id
			e.icon:setImage(g_i3k_db.i3k_db_get_icon_path(i3k_db_shen_bing[id].icon))
			e.times:setText(weapon.changeTimes > 0 and weapon.changeTimes or 0)
			e.maskIcon:setVisible(weapon.changeTimes <= 0)
			e.isSelect:setVisible(id == g_i3k_game_context:GetSelectWeapon())
			if weapon.changeTimes ~= 0 then
				e.btn:onClick(self, self.onChangeWeapon, i)
			end
		end
	end
end

function wnd_battleTouramentWeapon:onChangeWeapon(sender, idx)
	if not self:canUseWeaponAndSkills() then
		return
	end

	local hero = i3k_game_get_player_hero()
	if hero then
		if hero:IsDead() then
			return g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(17179))
		end
	end
	i3k_sbean.superarena_changeweapon_beg(idx)
end

function wnd_battleTouramentWeapon:loadSkillInfo(skillInfo)
	local skillsTb = {}
	for k, v in pairs(skillInfo) do
		table.insert(skillsTb, {skillID = k, times = v})
	end
	table.sort(skillsTb, function (a,b)
		return a.skillID > b.skillID
	end)
	for i, e in ipairs(self._skillWidgets) do
		if skillsTb[i] then
			local skillID = skillsTb[i].skillID
			local times = skillsTb[i].times
			e.icon:setImage(g_i3k_db.i3k_db_get_skill_icon_path(skillID))
			e.skillNum:setText(times)
			e.rootBtn:setTag(skillID)
			if times > 0 then
				e.rootBtn:onClick(self, self.onUseTournamentSkill, skillID)
			else
				e.rootBtn:disableWithChildren()
			end
		end
	end
end

function wnd_battleTouramentWeapon:onUseTournamentSkill(sender, skillID)
	if not self:canUseWeaponAndSkills() then
		return
	end
	local hero = i3k_game_get_player_hero()
	if hero then
		if hero:GetTournamentSkillIsCanUse(skillID) then
			hero:CreateTournamentSkill(skillID)
			hero:UseTournamentSkill(skillID)
		else
			g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(17180))
		end
	end
end

function wnd_battleTouramentWeapon:canUseWeaponAndSkills()
	if g_i3k_ui_mgr:GetUI(eUIID_ArenaSwallow) then
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_ArenaSwallow, "toTips")
		return false
	end
	return true
end

function wnd_battleTouramentWeapon:onUpdate(dTime)
	self:updateCDTime(dTime)
end

function wnd_battleTouramentWeapon:updateCDTime(dTime)
	local hero = i3k_game_get_player_hero()
	if hero then
		for _, e in pairs(self._skillWidgets) do
			local skillID = e.rootBtn:getTag()
			if not hero:GetTournamentSkillIsCanUse(skillID) then
				e.cool:show()
				local totalTime, hasCoolTime = hero:GetTournamentSkillCoolLeftTime(skillID)
				local coolLeftTime = math.abs((totalTime - hasCoolTime)/1000)
				local percent = 100*coolLeftTime/(totalTime/1000)
				local progressAction = e.cool:createProgressAction(coolLeftTime, percent, 0)
				e.cool:runAction(progressAction)
			else
				e.cool:hide()
				e.anisImage:setOpacity(0)
				e.anisImage:show()
			end
		end
	end
end

function wnd_create(layout)
	local wnd = wnd_battleTouramentWeapon.new()
	wnd:create(layout)
	return wnd
end
