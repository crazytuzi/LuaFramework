-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------
wnd_faction_skill = i3k_class("wnd_faction_skill", ui.wnd_base)

local LAYER_BPJNT = "ui/widgets/bpjnt"
local LAYER_BPJNT2 = "ui/widgets/bpjnt2"

local item_skill_point = {65620,65621,65622,65623}

local faction_skill_bg = {706,707}

function wnd_faction_skill:ctor()
	self._id = nil
	self._data = {}
	self._skill_bg = nil 
end


function wnd_faction_skill:configure(...)
	self._layout.vars.close_btn:onClick(self,self.onCloseUI)
	self.item_scroll = self._layout.vars.item_scroll 
	self.skill_icon = self._layout.vars.skill_icon 
	self.skill_name = self._layout.vars.skill_name 
	self.skill_level = self._layout.vars.skill_level 
	self.skill_desc = self._layout.vars.skill_desc 
	self.current_att = self._layout.vars.current_att 
	self.next_att = self._layout.vars.next_att 
	self.current_value = self._layout.vars.current_value 
	self.next_value = self._layout.vars.next_value 
	self.add_desc = self._layout.vars.add_desc 
	self.add_value = self._layout.vars.add_value 
	self.full_skill_root = self._layout.vars.full_skill_root 
	self.full_skill_root:hide()
	self.item_scroll2 = self._layout.vars.item_scroll2 
	self.value_bg = self._layout.vars.value_bg
	self.full_skill_desc = self._layout.vars.full_skill_desc
end

function wnd_faction_skill:onShow()
	
end

function wnd_faction_skill:updateAllSkill()
	self.item_scroll:removeAllChildren()
	self._data = {}
	local level = g_i3k_game_context:GetFactionLevel()
	local skills_data = g_i3k_game_context:GetFactionSkillData()
	local skills = i3k_db_faction_uplvl[level].skills
	local count = 0
	for k,v in pairs(skills) do
		if v ~= 0 then
			count = count + 1
			local skillLvl =  0
			if skills_data[v] and skills_data[v].level then
				skillLvl = skills_data[v].level
			end
			if count == 1 then
				if not self._id then
					self._id = v
				end
			end
			local _layer = require(LAYER_BPJNT)()
			local skill_btn = _layer.vars.skill_btn 
			local skill_bg = _layer.vars.skill_bg 
			local skill_icon = _layer.vars.skill_icon 
			local skill_name = _layer.vars.skill_name 
			local skill_lvl = _layer.vars.skill_lvl 
			
			local tmp_str = string.format("%s级",skillLvl)
			skill_lvl:setText(tmp_str)
			if self._id == v then
				self._skill_bg  = skill_bg
				skill_bg:setImage(g_i3k_db.i3k_db_get_icon_path(faction_skill_bg[1]))
			end
			local skill_data = i3k_db_faction_skill[v][skillLvl]
			skill_btn:setTag(v)
			skill_btn:onClick(self,self.onSelect,skill_bg)
			skill_icon:setImage(i3k_db_icons[skill_data.icon].path)
			skill_name:setText(skill_data.name)
			self.item_scroll:addItem(_layer)
			
		end
	end
	self:updateSkillData()
end

function wnd_faction_skill:showMaxDesc()
	self.full_skill_root:show()
	self.item_scroll2:hide()
	self.value_bg:hide()
	self.next_att:hide()
	self.next_value:hide()
end

function wnd_faction_skill:hideMaxDesc()
	self.full_skill_root:hide()
	self.item_scroll2:show()
	self.value_bg:show()
	self.next_att:show()
	self.next_value:show()
end

function wnd_faction_skill:onSelect(sender,skill_bg)
	
	local id = sender:getTag()
	self._id = id
	if self._skill_bg then
		self._skill_bg:setImage(g_i3k_db.i3k_db_get_icon_path(faction_skill_bg[2]))
	end
	self._skill_bg = skill_bg
	self._skill_bg:setImage(g_i3k_db.i3k_db_get_icon_path(faction_skill_bg[1]))
	self:updateSkillData()
	
end

function wnd_faction_skill:updateSkillData()
	local id = self._id
	if id == 0 or not id then
		return 
	end
	local skills = g_i3k_game_context:GetFactionSkillData()
	local level = 0
	if skills[id] and skills[id].level then
		level = skills[id].level
	end
	local now_skill_point = 0
	local skill_data = i3k_db_faction_skill[id][level]
	self.skill_icon:setImage(i3k_db_icons[skill_data.icon].path)
	self.skill_name:setText(skill_data.name)
	local tmp_str = string.format("%s级",level)
	self.skill_level:setText(tmp_str)
	self.skill_desc:setText(skill_data.desc)
	local attribute = skill_data.attribute
	local value = skill_data.value
	local factionLvl = skill_data.factionLvl 
	local factionCarSkillID = i3k_db_defenceWar_cfg.carFactionSkillID
	local factionTowerSkillID = i3k_db_defenceWar_cfg.towerFactionSkillID
	
	if id == factionCarSkillID or id == factionTowerSkillID then--城战建筑技能
		local skillId, str, towerStr, value = self:getDefenceWarStr(id)
		local curskillData = g_i3k_db.i3k_db_get_defence_war_ShowID(skillId, level)
		self.current_att:setText(str)
		local currValue = value and curskillData.carExplain or curskillData.towerExplain
		local percent = math.floor(currValue / 100)
		local tmp_str = string.format("%s%%", percent)
		self.current_value:setText(tmp_str)
		local nextskillData = g_i3k_db.i3k_db_get_defence_war_ShowID(skillId, level + 1)
		
		if nextskillData then
			self.next_att:setText(towerStr)
			local nextValue = value and nextskillData.carExplain or nextskillData.towerExplain
			local nextpercent = math.floor(nextValue / 100)
			local nextstr = string.format("%s%%", nextpercent)
			self.next_value:setText(nextstr)
		else
			self.next_att:setText("已达最大等级")
			self.next_value:setText("")
		end 
	elseif i3k_db_prop_id[attribute] then
		local att_desc = i3k_db_prop_id[attribute].desc
		self.current_att:setText(i3k_get_string(10006,att_desc))
		self.current_value:setText(value)
		if i3k_db_faction_skill[id][level + 1] then
			local next_attribute = i3k_db_faction_skill[id][level + 1].attribute
			local _value = i3k_db_faction_skill[id][level + 1].value
			local att_desc = i3k_db_prop_id[next_attribute].desc
			self.next_att:setText(i3k_get_string(10007,att_desc))
			self.next_value:setText(_value)
			self.add_desc:setText(i3k_get_string(10008,att_desc))
			self.add_value:setText(_value - value)
		end
	elseif id == 11 then--参悟技能
		self.current_att:setText("本级获取参悟经验：")
		local currValue = math.abs(skill_data.canwuRate)
		local needValue = math.floor(currValue/100)
		local tmp_str = string.format("%s%%",needValue)
		self.current_value:setText(tmp_str)
		if i3k_db_faction_skill[id][level + 1] then
			self.next_att:setText("下级获取参悟经验：")
			local currValue = math.abs(i3k_db_faction_skill[id][level + 1].canwuRate)
			local needValue = math.floor(currValue/100)
			local tmp_str = string.format("%s%%",needValue)
			self.next_value:setText(tmp_str)
		else
			self.next_att:setText("已达最大等级")
			self.next_value:setText("")
		end 	
	else
		self.current_att:setText("本级提升获取历练速度：")
		local currValue = math.abs(skill_data.experValue)
		local needValue = currValue/i3k_db_experience_args.args.needExp*100
		local tmp_str = string.format("%s%%",needValue)
		self.current_value:setText(tmp_str)
		if i3k_db_faction_skill[id][level + 1] then
			self.next_att:setText("下级提升获取历练速度：")
			local currValue = math.abs(i3k_db_faction_skill[id][level + 1].experValue)
			local needValue = currValue/i3k_db_experience_args.args.needExp*100
			local tmp_str = string.format("%s%%",needValue)
			self.next_value:setText(tmp_str)
		else
			self.next_att:setText("已达最大等级")
			self.next_value:setText("")
		end 
	end 
	if not i3k_db_faction_skill[id][level+1] then
		self:showMaxDesc()
		return
	else
		self:hideMaxDesc()
	end
	self:updateItemData()
end

function wnd_faction_skill:updateItemData()
	local id = self._id
	local skills = g_i3k_game_context:GetFactionSkillData()
	local level = 0
	if skills[id] and skills[id].level then
		level = skills[id].level
	end
	if not i3k_db_faction_skill[id][level+1] then
		return
	end
	self.item_scroll2:setBounceEnabled(false)
	self.item_scroll2:show()
	self.item_scroll2:removeAllChildren(true)
	local RowitemCount = 0
	for i=1,4 do
		local tmp_item = string.format("item%s",i)
		local tmp_need_count = string.format("item%sCount",i)
		
		local itemid = i3k_db_faction_skill[id][level+1][tmp_item]
		local need_count = i3k_db_faction_skill[id][level+1][tmp_need_count]
		if itemid ~= 0 then
			RowitemCount = RowitemCount + 1
		end
	end
	
	for i=1, RowitemCount do
		local node = require(LAYER_BPJNT2)()
		local tmp_item = string.format("item%s",i)
		local tmp_need_count = string.format("item%sCount",i)
		local itemid = i3k_db_faction_skill[id][level+1][tmp_item]
		local need_count = i3k_db_faction_skill[id][level+1][tmp_need_count]
		
		local have_count = 0
		if skills[id] and skills[id].item  and skills[id].item[itemid] then
			have_count = skills[id].item[itemid]
		end
		local tmp_cfg = g_i3k_db.i3k_db_get_common_item_cfg(itemid)
		local args = tmp_cfg.args1
		local self_count = g_i3k_game_context:GetCommonItemCanUseCount(itemid)
		node.vars.item_bg:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(itemid))
		node.vars.item_icon:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(itemid,i3k_game_context:IsFemaleRole()))
		local isEnough = false
		if self_count > 0 and have_count < need_count then
			isEnough = true
			node.vars.item_point:show()
		else
			node.vars.item_point:hide()
		end
		
		node.vars.itemName:setText(g_i3k_db.i3k_db_get_common_item_name(itemid))
		node.vars.itemName:setTextColor(g_i3k_get_color_by_rank(g_i3k_db.i3k_db_get_common_item_rank(itemid)))
		local item_count = node.vars.item_count 
		local tmp_str = string.format("%s/%s",have_count,need_count)
		item_count:setText(tmp_str)
		if have_count >= need_count then
			item_count:setTextColor(g_i3k_get_green_color())
		else
			item_count:setTextColor(g_i3k_get_red_color())
		end	
		node.vars.item_btn:setTag(itemid)
		node.vars.item_btn:onClick(self,self.onContri, {isEnough = isEnough, ishave = have_count >= need_count})
		self.item_scroll2:addItem(node)
	end
end 

function wnd_faction_skill:onContri(sender, data)
	if data.ishave then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(10034))
		return
	end
	if data.isEnough then
		local itemid = sender:getTag()
		local skills = g_i3k_game_context:GetFactionSkillData()
		local have_count = 0
		local id = self._id
		if skills[id] and skills[id].item  and skills[id].item[itemid] then
			have_count = skills[id].item[itemid]
		end
		local level =1
		if skills[id] and skills[id].level then
			level = skills[id].level
		end
		
		local factionLvl = g_i3k_game_context:GetFactionLevel()
		local needFactionLvl = i3k_db_faction_skill[id][level].factionLvl
		if factionLvl < needFactionLvl then
			local str = string.format("%s", "请先提升帮派等级")
			g_i3k_ui_mgr:PopupTipMessage(str)
			return 
		end
		local need_count = 0
		local contri_count = 0
		for i=1,4 do
			local tmp_item = string.format("item%s",i)
			local tmp_need_count = string.format("item%sCount",i)
			local tmp_contri = string.format("contribution%s",i)
			local _itemid = i3k_db_faction_skill[id][level+1][tmp_item]
			if itemid == _itemid then
				need_count = i3k_db_faction_skill[id][level+1][tmp_need_count]
				contri_count = i3k_db_faction_skill[id][level+1][tmp_contri] 
			end
		end
		
		local contriCount = need_count - have_count
		
		local my_count = g_i3k_game_context:GetCommonItemCanUseCount(itemid)
		if my_count > 0 then
			g_i3k_ui_mgr:OpenUI(eUIID_FactionContribution)
			g_i3k_ui_mgr:RefreshUI(eUIID_FactionContribution,itemid,self._id,contriCount,contri_count)
		end
	else
		--local str = string.format("%s", "材料不足，无法捐献")
		--g_i3k_ui_mgr:PopupTipMessage(str)
		
		g_i3k_ui_mgr:ShowCommonItemInfo(sender:getTag())
	end
end



function wnd_faction_skill:refresh()
	self:updateAllSkill()
end 

function wnd_faction_skill:onTips(sender,eventType)
	if eventType == ccui.TouchEventType.ended then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(10027))
	end
end

function wnd_faction_skill:onUpLvl(sender,eventType)
	if eventType == ccui.TouchEventType.ended then
		local data = i3k_sbean.sect_auralvlup_req.new()
		data.auraId = self._id
		i3k_game_send_str_cmd(data,i3k_sbean.sect_auralvlup_res.getName())
	end
end

function wnd_faction_skill:getDefenceWarStr(id)		
	if id == i3k_db_defenceWar_cfg.carFactionSkillID then
		local str = i3k_get_string(5328)
		local towerStr = i3k_get_string(5329)
		return i3k_db_defenceWar_cfg.carFactionSkillID, str, towerStr, true
	elseif id == i3k_db_defenceWar_cfg.towerFactionSkillID then
		local str = i3k_get_string(5299)
		local towerStr = i3k_get_string(5300)
		return i3k_db_defenceWar_cfg.towerFactionSkillID, str, towerStr, false
	end	
end

--[[function wnd_faction_skill:onClose(sender,eventType)
	if eventType ==ccui.TouchEventType.ended then
		g_i3k_ui_mgr:CloseUI(eUIID_FactionSKill)
	end
end--]]

function wnd_create(layout, ...)
	local wnd = wnd_faction_skill.new();
		wnd:create(layout, ...);

	return wnd;
end

