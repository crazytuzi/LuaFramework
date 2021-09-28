
-------------------------------------------------------
module(..., package.seeall)
local require = require;
local ui = require("ui/base");
-------------------------------------------------------
wnd_fuBen_Skill = i3k_class("wnd_fuBen_Skill",ui.wnd_base)

function wnd_fuBen_Skill:ctor()
	self.skillUseTime = nil

	self.timeTick = 0
	self.skillItems = {}
	self.shareTime = nil
end

function wnd_fuBen_Skill:configure()

end

function wnd_fuBen_Skill:refresh(skillUseTime, skillCommonUseTime, skillLastUseTime, skillGroup)
	
	local cfg = i3k_db_dungeonSkill[skillGroup]
	local widgets = self._layout.vars
	widgets.descBtn:onClick(self, self.onDetail, cfg)

	self.shareTime = cfg.shareTime
	self.skillUseTime = skillUseTime

	self:InitSkillUseTime(skillCommonUseTime, skillLastUseTime, cfg.skill)
	local scroll = widgets.scroll

	local sk_size = nil
	for _, v in pairs(cfg.skill) do
		local item = require("ui/widgets/zdxjnt")()
		
		local _skill_data = i3k_db_skills[v.id]
		item.skill = v
		item.vars.itemIcon:setImage(g_i3k_db.i3k_db_get_icon_path(_skill_data.icon))
		item.vars.lockImg:hide()
		item.vars.onClickBtn:onClick(self, self.onSkillClick, v)
		
		if v.count < 0 then
			item.vars.itemCD:setPercent(0)
			item.vars.itemCount:hide()
		else
			local count = v.count - self.skillUseTime[v.id]
			item.vars.itemCount:setText(count)
			if count == 0 then
				item.vars.onClickBtn:disable()
				item.vars.itemCD:setPercent(100)
			else
				item.vars.itemCD:setPercent(0)
			end
		end
		sk_size = item.rootVar:getSize()
		table.insert(self.skillItems, item)
		scroll:addItem(item)
	end
	if sk_size then
		local s_width = scroll:getContentSize().width
		s_width = s_width - sk_size.width* #cfg.skill
		widgets.rootBg:setContentSize(widgets.rootBg:getContentSize().width - s_width, widgets.rootBg:getContentSize().height)
		scroll:setContainerSize(sk_size.width* #cfg.skill, sk_size.height)
		scroll:setContentSize(sk_size.width* #cfg.skill, sk_size.height)
		scroll:update()
	end
end

function wnd_fuBen_Skill:InitSkillUseTime(skillCommonUseTime, skillLastUseTime, oriSkill)
	local hero = i3k_game_get_player_hero()

	for i , v in ipairs(oriSkill) do
		if not self.skillUseTime[v.id] then
			self.skillUseTime[v.id] = 0
		end
		
		if hero then
			local coolTime
			if skillCommonUseTime > 0 then
				coolTime = (i3k_game_get_time() - skillCommonUseTime)*1000
			else
				local coolTime = skillLastUseTime[v.id]
				if coolTime then
					coolTime = (i3k_game_get_time() - coolTime)*1000
				end
			end
			hero:CreateGameInstanceSkill(v.id, v.level, coolTime)
		end
	end
end

function wnd_fuBen_Skill:onUpdate(dTime)
	--self.timeTick = self.timeTick + dTime
	--if self.timeTick >= 0.2 then 
		--self.timeTick = 0
		for k,v in pairs(self.skillItems) do
			local skill = v.skill
			if skill.count < 0 or skill.count - self.skillUseTime[skill.id] > 0 then
				local hero = i3k_game_get_player_hero()
				local totalTime, cdTime = 0, 0
				if hero then
					totalTime, cdTime = hero:GetGameInstanceSkillCoolTime(skill.id)
				end
				if cdTime > 0 then
					local percent = cdTime == 0 and 0 or (1-(cdTime / totalTime)) * 100
					v.vars.itemCD:setPercent(percent)
				end
			end
		end
	--end
end

function wnd_fuBen_Skill:onSkillClick(sender, skillCfg)
	if g_i3k_game_context:IsInSuperMode() then
		return g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(975))
	end
	local hero = i3k_game_get_player_hero()
	if hero then
		hero:UseGameInstanceSkill(skillCfg.id)
	end
end

function wnd_fuBen_Skill:ChangeSkillCount(skillId, success)
	local hero = i3k_game_get_player_hero()
	if not hero then
		return
	end
	if success == 0 then
		hero:ResetDungeonSkillCoolTime(skillId, i3k_game_get_time())
		return
	end

	local useT = self.skillUseTime[skillId] + 1
	self.skillUseTime[skillId] = useT
	for i,item in ipairs(self.skillItems) do
		local skill = item.skill
		if skillId == skill.id then
			local count = skill.count - useT
			item.vars.itemCount:setText(count)
			if count == 0 then
				item.vars.onClickBtn:disable()
				item.vars.itemCD:setPercent(100)
			end
			break
		end
	end
	if self.shareTime > 0 then
		hero:setDungeonSkillShareTime(skillId, self.shareTime)
	end
end

function wnd_fuBen_Skill:onDetail(sender, cfg)
	g_i3k_ui_mgr:OpenUI(eUIID_FuBen_SkillDetail)
	g_i3k_ui_mgr:RefreshUI(eUIID_FuBen_SkillDetail, cfg, g_FUBEN_SKILL_NORMAL)
end

function wnd_create(layout, ...)
	local wnd = wnd_fuBen_Skill.new()
	wnd:create(layout, ...)
	return wnd;
end