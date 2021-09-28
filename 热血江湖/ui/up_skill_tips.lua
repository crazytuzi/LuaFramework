-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------
wnd_up_skill_tips = i3k_class("wnd_up_skill_tips", ui.wnd_base)

local LAYER_JNSJT1 = "ui/widgets/jnsjt1"

--标题图片
JINENGSJ_TITLE = 2078--186
UNIQUESKILL_TITLE = 2079
JINGJIESJ_TITLE = 187


function wnd_up_skill_tips:ctor()
	self._skillID = 0
	self._type = nil
	self.need_item = {}
end

function wnd_up_skill_tips:configure()
	local widgets = self._layout.vars
	self._layout.vars.close_btn:onClick(self,self.onCloseUI)
	
	self.up_btn = widgets.up_btn
	self.up_state = widgets.up_state
	self.auto_up = widgets.auto_up
	
	self.now_label = widgets.now_label
	self.next_label = widgets.next_label
	self.level_value = widgets.level_value
	self.next_level = widgets.next_level
	self.now_effect = widgets.now_effect
	self.next_effect = widgets.next_effect
	self.title_desc = widgets.title_desc
	self.use_item = widgets.use_item	
	self.desc1 = widgets.desc1
	self.desc2 = widgets.desc2
	self.scroll3 = widgets.scroll3
	self.c_jnsj = self._layout.anis.c_jnsj
end

function wnd_up_skill_tips:refresh(skillID, upLevleType,unique)
	self._skillID = skillID
	self._type = upLevleType
	self._unique = unique
	
	if self._type == eSkillCmd_UpLvl then
		self:onSkillTips(self._skillID,unique)
	elseif self._type == eSkillCmd_Bourn then
		self:onStateTips(self._skillID,unique)
	end
end

function wnd_up_skill_tips:onSkillTips(skillID,unique)
	self.up_state:hide()
	--local skill_cfg = g_i3k_game_context:GetRoleSkillsCfg(skillID)
	local skill_cfg 
	local skill_lv 
	
	
	local longYinSkills = g_i3k_game_context:GetLongYinSkills()--龙印加持等级
	local longYin_lv = 0
	for i,v in pairs(longYinSkills) do
		if skillID == i then
			longYin_lv = v 
		end
	end
	
	local level 
	if unique then--绝技
		skill_cfg = g_i3k_game_context:GetRoleUniqueSkillsCfg(skillID)
		skill_lv = skill_cfg.lvl
		level = skill_lv
		self.title_desc:setImage(g_i3k_db.i3k_db_get_icon_path(UNIQUESKILL_TITLE))
	else--武功
		skill_cfg = g_i3k_game_context:GetRoleSkillsCfg(skillID)
		assert(skill_cfg ~= nil, "skill id "..(skillID and skillID or "nil"))
		skill_lv = skill_cfg.lvl
		level = skill_lv+longYin_lv
		self.title_desc:setImage(g_i3k_db.i3k_db_get_icon_path(JINENGSJ_TITLE))
	end
	local _skill_data = i3k_db_skills[skillID]
	local skill_data = i3k_db_skill_datas[skillID]
	
	
	
	
	self.level_value:setText(i3k_get_string(929,level))---显示当前等级
	local nextLevel = i3k_get_string(929,level+1)
	self.next_level:setText(nextLevel)--下一等级
	self.now_label:show()
	self.next_label:show()
	self.now_effect:setText(i3k_get_string(15355))
	self.next_effect:setText(i3k_get_string(15356))
	local spArgs1 = skill_data[level].spArgs1
	local spArgs2 = skill_data[level].spArgs2
	local spArgs3 = skill_data[level].spArgs3
	local spArgs4 = skill_data[level].spArgs4
	local spArgs5 = skill_data[level].spArgs5
	local commonDesc = _skill_data.common_desc
	local tmp_str = string.format(commonDesc,spArgs1,spArgs2,spArgs3,spArgs4,spArgs5)
	self.desc1:setText(tmp_str)---当前效果
	
	local spArgs1 = skill_data[level + 1].spArgs1
	local spArgs2 = skill_data[level + 1].spArgs2
	local spArgs3 = skill_data[level + 1].spArgs3
	local spArgs4 = skill_data[level + 1].spArgs4
	local spArgs5 = skill_data[level + 1].spArgs5
	local commonDesc = _skill_data.common_desc
	local tmp_str = string.format(commonDesc,spArgs1,spArgs2,spArgs3,spArgs4,spArgs5)
	self.desc2:setText(tmp_str)--下级效果
	
	
	
	self.need_item = {}
	table.insert(self.need_item, {itemID = g_BASE_ITEM_COIN, itemCount = skill_data[skill_lv+1].needCoin})
	if skill_data[skill_lv+1].needItemID ~= 0 then
		table.insert(self.need_item, {itemID = skill_data[skill_lv+1].needItemID, itemCount = skill_data[skill_lv+1].needItemNum})
	end
	self:setScrollData()
	self.up_btn:onClick(self, self.onUpSkill, skillID)
	self.auto_up:onClick(self, self.onAutoUpSkill, skillID)
end 

function wnd_up_skill_tips:onStateTips(skillID,unique)
	self.up_btn:hide()
	self.auto_up:hide()
	
	local skill_cfg
	if unique then--绝技
		skill_cfg = g_i3k_game_context:GetRoleUniqueSkillsCfg(skillID)
		
	else--武功
		skill_cfg = g_i3k_game_context:GetRoleSkillsCfg(skillID)
		
	end
	
	--local skill_cfg = g_i3k_game_context:GetRoleSkillsCfg(skillID)
	assert(skill_cfg ~= nil, "skill id "..(skillID or 0))
	local state_lv = skill_cfg.state
	local state_data = i3k_db_state[state_lv+1]
	if state_lv + 1 > #i3k_db_state then
		return
	end
	self.now_effect:setText(i3k_get_string(15357))
	self.next_effect:setText(i3k_get_string(15358))
	self.level_value:setText(i3k_db_state[state_lv].name)
	self.level_value:setTextColor(g_i3k_get_color_by_rank(state_lv + 1))
	
	self.next_level:setText(i3k_db_state[state_lv+1].name)
	self.next_level:setTextColor(g_i3k_get_color_by_rank(state_lv + 2))
	
	self.title_desc:setImage(g_i3k_db.i3k_db_get_icon_path(JINGJIESJ_TITLE))
	
	
	
	local stateData = i3k_db_skills[skillID].stateDesc
	state_lv = state_lv + 1
	self.desc1:setText(stateData[state_lv])
	self.desc2:setText(stateData[state_lv+1])
	
	self.need_item = {}
	for i=1,2 do
		local id = string.format("item%sID",i)
		local count = string.format("item%sCount",i)
		table.insert(self.need_item, {itemID = state_data[id], itemCount = state_data[count]})
	end
	self:setScrollData()
	self.up_state:onClick(self, self.onUpState, skillID)
end

function wnd_up_skill_tips:setScrollData()
	self.scroll3:removeAllChildren()
	local need_item = self.need_item
	for i=1, #self.need_item do
		local itemID = self.need_item[i].itemID
		local item_rank = g_i3k_db.i3k_db_get_common_item_rank(itemID)
		local _layer = require(LAYER_JNSJT1)()
		local widgets1 = _layer.vars
		widgets1.suo:setVisible(g_i3k_db.i3k_db_get_consume_lock_visible(itemID))
		widgets1.item_icon:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(itemID,i3k_game_context:IsFemaleRole()))
		widgets1.item_name:setText(g_i3k_db.i3k_db_get_common_item_name(itemID))
		widgets1.item_name:setTextColor(g_i3k_get_color_by_rank(item_rank))
		if itemID == g_BASE_ITEM_COIN then
			widgets1.item_count:setText(self.need_item[i].itemCount)
		else
			widgets1.item_count:setText(g_i3k_game_context:GetCommonItemCanUseCount(itemID).."/"..self.need_item[i].itemCount)
		end
		widgets1.item_count:setTextColor(g_i3k_get_cond_color(self.need_item[i].itemCount <= g_i3k_game_context:GetCommonItemCanUseCount(itemID)))
		widgets1.item_BgIcon:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(itemID))
		widgets1.tip_btn:onClick(self, self.itemTips, itemID)
		self.scroll3:addItem(_layer)
	end
end

function wnd_up_skill_tips:onUpSkill(sender, skillID)
	--local skill_cfg = g_i3k_game_context:GetRoleSkillsCfg(skillID)
	local skill_cfg
	if self._unique then--绝技
		skill_cfg = g_i3k_game_context:GetRoleUniqueSkillsCfg(skillID)
	else
		skill_cfg = g_i3k_game_context:GetRoleSkillsCfg(skillID)
	end
	
	local skill_lv = 0
	if skill_cfg then
		skill_lv = skill_cfg.lvl
	end
	if g_i3k_game_context:isSkillCanUpdateLevel(skillID) and not self._unique then
		i3k_sbean.goto_skill_levelup(skillID, skill_lv+1, self.need_item , false,self._unique)
		
	elseif self._unique and g_i3k_game_context:isUniqueSkillCanUpdateLevel(skillID) then
		i3k_sbean.goto_skill_levelup(skillID, skill_lv+1, self.need_item , false,self._unique)
	else
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(924))
	end
end

function wnd_up_skill_tips:onUpState(sender, skillID)
	--local skill_cfg = g_i3k_game_context:GetRoleSkillsCfg(skillID)
	local skill_cfg
	if self._unique then--绝技
		skill_cfg = g_i3k_game_context:GetRoleUniqueSkillsCfg(skillID)
	else
		skill_cfg = g_i3k_game_context:GetRoleSkillsCfg(skillID)
	end
	local state_lv = 0 
	if skill_cfg then
		state_lv = skill_cfg.state
	end
	if g_i3k_game_context:isUpStateEnough(state_lv) then
		i3k_sbean.goto_skill_enhance(skillID, state_lv+1, self.need_item,self._unique)
	
	else
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(924))
	end
end

function wnd_up_skill_tips:onAutoUpSkill(sender, skillID)
	local skill_cfg
	if self._unique then--绝技
		skill_cfg = g_i3k_game_context:GetRoleUniqueSkillsCfg(skillID)
	else
		skill_cfg = g_i3k_game_context:GetRoleSkillsCfg(skillID)
	end
	
	local skill_lv = 0
	if skill_cfg then
		skill_lv = skill_cfg.lvl
	end
	local skillsList = {[1] = {info = skill_cfg}}
	local levelUpSkills, need_item = g_i3k_game_context:upgradeAllSkill(skillsList)
	if table.nums(levelUpSkills) > 0 then
		i3k_sbean.goto_skill_levelup(skillID, levelUpSkills[skillID], need_item, true,self._unique)
	else
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(924))
	end


end

function wnd_up_skill_tips:playUpLevelEffect(skillId)
	
	local delay = cc.DelayTime:create(0.4)
	local seq = cc.Sequence:create(cc.CallFunc:create(function ()
	self.c_jnsj.play() 
	end),delay,cc.CallFunc:create(function ()
	self:onSkillTips(skillId)
	end))
	self:runAction(seq)
end

--[[function wnd_up_skill_tips:onClose(sender)
	g_i3k_ui_mgr:CloseUI(eUIID_UpSkillTips)
end--]]

function wnd_up_skill_tips:itemTips(sender, itemid)
	g_i3k_ui_mgr:ShowCommonItemInfo(itemid)
end

function wnd_create(layout)
	local wnd = wnd_up_skill_tips.new()
	wnd:create(layout)
	return wnd
end
