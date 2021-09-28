	-------------------------------------------------------
module(..., package.seeall)
local require = require;
local ui = require("ui/base");
-------------------------------------------------------
wnd_homeland_guard_skill = i3k_class("wnd_homeland_guard_skill", ui.wnd_base)

local SHARE_TIME = g_i3k_db.i3k_db_get_homeland_guard_shareTotalCool()    --公CD时间

function wnd_homeland_guard_skill:ctor()
	self.skillItems = {}												 --技能控件列表
	self.skillCanUseTimes = nil 										 --拥有技能次数信息
	self.skillCommonUseTime = 0
end

function wnd_homeland_guard_skill:configure()
	self.widgets = self._layout.vars
	self.scroll = self.widgets.scroll
	--预配置全部技能详情
	local mapID = g_i3k_game_context:GetWorldMapID()
	local cfg = i3k_db_homeland_guard_base[mapID].skillIDs
	self.widgets.descBtn:onClick(self, self.onDetail, cfg)
	self.scroll:setAlignMode(g_UIScrollList_HORZ_ALIGN_RIGHT)
end

function wnd_homeland_guard_skill:refresh(skillCommonUseTime, skillCanUseTimes)
	if skillCommonUseTime > 0 and self.skillCommonUseTime == 0 then
		self.skillCommonUseTime = skillCommonUseTime
	end
	self.skillItems = {}
	self.skillCanUseTimes = skillCanUseTimes
	self:InitSkillUseTime(self.skillCommonUseTime, self.skillCanUseTimes)

	self.scroll:removeAllChildren()
	for k,v in pairs(self.skillCanUseTimes) do
		local item = require("ui/widgets/zdxjntf")()

		local _skill_data = i3k_db_skills[k]
		item.vars.itemIcon:setImage(g_i3k_db.i3k_db_get_icon_path(_skill_data.icon))
		item.vars.lockImg:hide()
		item.vars.itemCount:setText(v)
		item.vars.itemCD:setPercent(0)
		item.times = v
		item.id = k

		item.vars.onClickBtn:onClick(self, self.onSkillClick, k)

		table.insert(self.skillItems, item)
		self.scroll:addItem(item)
	end
end

function wnd_homeland_guard_skill:onUpdate(dTime)
	for k,v in ipairs(self.skillItems) do
		if v.times > 0 then
			local hero = i3k_game_get_player_hero()

			local totalTime, cdTime = 0, 0
			if hero then
				totalTime, cdTime = hero:GetGameInstanceSkillCoolTime(v.id)
			end
			if cdTime > 0 then
				local percent = (1 - (cdTime / SHARE_TIME)) * 100
				v.vars.itemCD:setPercent(percent)
			end
		end
	end
end
	
function wnd_homeland_guard_skill:onSkillClick(sender, skillID)
	if g_i3k_game_context:IsInSuperMode() then
		return g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(975))
	end
	local hero = i3k_game_get_player_hero()
	if hero then
		hero:UseGameInstanceSkill(skillID)
	end
end


function wnd_homeland_guard_skill:InitSkillUseTime(skillCommonUseTime, skills)
	local hero = i3k_game_get_player_hero()

	for id,_ in pairs(skills) do
		if hero then
			local coolTime
			if skillCommonUseTime > 0 then
				coolTime = (i3k_game_get_time() - skillCommonUseTime) * 1000
			else
				coolTime = SHARE_TIME
			end
			hero:CreateGameInstanceSkill(id, 1, coolTime, SHARE_TIME)
		end
	end
end

function wnd_homeland_guard_skill:ChangeSkillCount(skillId, success)
	local hero = i3k_game_get_player_hero()
	if not hero then
		return
	end
	for i,item in ipairs(self.skillItems) do
		if item.id == skillId then
			local count = item.times - 1
			if count == 0 then
				self.skillCanUseTimes[skillId] = nil
			else
				self.skillCanUseTimes[skillId] = count
			end
		end
	end
	self.skillCommonUseTime = i3k_game_get_time()
	self:refresh(self.skillCommonUseTime, self.skillCanUseTimes)
end

function wnd_homeland_guard_skill:onDetail(sender, cfg)
	g_i3k_ui_mgr:OpenUI(eUIID_FuBen_SkillDetail)
	g_i3k_ui_mgr:RefreshUI(eUIID_FuBen_SkillDetail, cfg, g_FUBEN_SKILL_HOMELAND)
end

function wnd_create(layout, ...)
	local wnd = wnd_homeland_guard_skill.new()
	wnd:create(layout, ...)
	return wnd;
end
