-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------
wnd_pre_name = i3k_class("wnd_pre_name", ui.wnd_base)

local l_nameLen_skill_min= 2
local l_nameLen_skill_max = i3k_db_common.inputlen.prelen

local l_num_preSkill = 4

local l_nameLen_spirits_min= 2
local l_nameLen_spirits_max = i3k_db_common.inputlen.prelen

local l_num_preSpirits = 4

local name_rule_desc = {
	[-1] = i3k_get_string(727), --名字格式错误
	[-2] = i3k_get_string(728), --名字不能为空
	[-3] = i3k_get_string(729), --名字长度不符合规则
}

function wnd_pre_name:ctor()
	self.typeNum = 1
	self.index = 1
end

function wnd_pre_name:configure(typeNum)
	local widgets = self._layout.vars
	widgets.cancel_btn:onClick(self, self.onCloseUI)
	widgets.sure_btn:onClick(self,self.onSureClick)
	self.inputLabel = widgets.input_label
	self.inputLabel:setMaxLength(i3k_db_common.inputlen.prelen)
end

function wnd_pre_name:refresh(typeNum)
	self.typeNum = typeNum
	if typeNum == g_PRE_NAME_SKILL then
		local skillPresetData = g_i3k_game_context:getSkillPresetData()
		self.index = #skillPresetData + 1
		self.inputLabel:setText(i3k_get_string(730,self.index)) --技能预设%s
		self.inputLabel:setMaxLength(l_nameLen_skill_max)
	else
		local spiritsPresetData = g_i3k_game_context:getSpiritsPresetData()
		self.index = #spiritsPresetData + 1
		self.inputLabel:setText(i3k_get_string(731,self.index)) --气功预设%s
		self.inputLabel:setMaxLength(l_nameLen_skill_max)
	end
end

function wnd_pre_name:checkName(name_str,minLen,maxLen)
	local len = string.len(name_str)

	if len == 0 then
		return -2,name_rule_desc[-2]
	end

	if tonumber(name_str) then
		return -1,name_rule_desc[-1]
	end

	local namecount = i3k_get_utf8_len(name_str)
	if namecount > maxLen or namecount < minLen  then
		return -3,name_rule_desc[-3]
	end

	return 1
end

function wnd_pre_name:updateTopBtnState()
	-- body
	for k,v in ipairs(self.topBtn) do
		if k ~= self.topNum then
			v:stateToNormal()
		else
			v:stateToPressed()
		end
	end
	self:updateListSkill()
end

function wnd_pre_name:onSureClick(sender)
	local name = self.inputLabel:getText()
	local error_code,desc
	if self.typeNum == g_PRE_NAME_SKILL then
		error_code,desc = self:checkName(name,l_nameLen_skill_min,l_nameLen_skill_max)
		local skillPresetData = g_i3k_game_context:getSkillPresetData()
		if error_code ~= 1 then
			g_i3k_ui_mgr:PopupTipMessage(desc)
			return
		elseif #skillPresetData >= l_num_preSkill then
			g_i3k_ui_mgr:CloseUI(eUIID_PreName)
			g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(732)) --预设位已满，无法存储
			return
		end
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_SkillSet,"sendSaveBean",name)
	else
		error_code,desc = self:checkName(name,l_nameLen_spirits_min,l_nameLen_spirits_max)
		local spiritsPresetData = g_i3k_game_context:getSpiritsPresetData()
		if error_code ~= 1 then
			g_i3k_ui_mgr:PopupTipMessage(desc)
			return
		elseif #spiritsPresetData >= l_num_preSpirits then
			g_i3k_ui_mgr:CloseUI(eUIID_PreName)
			g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(732)) --预设位已满，无法存储
			return
		end
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_SpiritsSet,"sendSaveBean",name)
	end
end

function wnd_create(layout,...)
	local wnd = wnd_pre_name.new();
		wnd:create(layout,...)
	return wnd;
end
