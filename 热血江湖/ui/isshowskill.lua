-------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");
------------------------------------------
local LAYER_SKILL = "ui/widgets/bsjnmst"
wnd_IsShowSkill = i3k_class("wnd_IsShowSkill", ui.wnd_base)
function wnd_IsShowSkill:ctor()
	
end

function wnd_IsShowSkill:configure()
	local widgets = self._layout.vars
	self.item_count =widgets.item_count
	widgets.close_btn:onClick(self,self.onCloseUI)
	self.scroll = widgets.bsjnsm;
	self.bosstx = widgets.bosstx;
end

function wnd_IsShowSkill:refresh()
	self:IsShowSkill()
end

function wnd_IsShowSkill:IsShowSkill()
	self.item_count:setText(i3k_db_string[15526])
	local mapID = g_i3k_game_context:GetWorldMapID()
	local cfg = i3k_db_defend_cfg[mapID]
	local iconID = 0
	if cfg and cfg.explainHeadID ~= 0 then
		iconID = cfg.explainHeadID
	else
		local _, headIcon = g_i3k_game_context:GetRoleNameHeadIcon()
		iconID = headIcon
	end
	local gender = g_i3k_game_context:GetRoleGender()
	if i3k_game_get_map_type() == g_DOOR_XIULIAN then
		if gender == 1 then
			iconID = i3k_db_practice_door_common.maleHeadIcon
		else
			iconID = i3k_db_practice_door_common.femaleHeadIcon
		end
	end
	self.bosstx:setImage(g_i3k_db.i3k_db_get_head_icon_path(iconID,false))
    local id = g_i3k_game_context:getMissionId()
	local shapeshift = i3k_db_missionmode_cfg[id]
	local count = 0
	for i,v in  ipairs(shapeshift.skills) do
		if i and  shapeshift.skills[i].skillid~=0 then
			count = count +1
		end  
	end
	local children = self.scroll:addChildWithCount(LAYER_SKILL, 1 ,count)
	for i,v in ipairs (children) do
		local skill = i3k_db_skills[shapeshift.skills[i].skillid];
		local iconId = g_i3k_db.i3k_db_get_skill_icon_path(shapeshift.skills[i].skillid)
		v.vars.skill_icon:setImage(iconId)
		v.vars.skill_name:setText(skill.name)
		v.vars.skill_desc:setText(skill.desc)
	end
end

function wnd_create(layout)
	local wnd = wnd_IsShowSkill.new()
	wnd:create(layout)
	return wnd
end