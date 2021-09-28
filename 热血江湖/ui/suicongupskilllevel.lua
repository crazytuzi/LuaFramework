-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------
wnd_suicongUpSkillLevel = i3k_class("wnd_suicongUpSkillLevel", ui.wnd_base)

local LAYER = "ui/widgets/jnsjt1"

function wnd_suicongUpSkillLevel:ctor()
	self.allItem = {}
	self._petId = nil
	self._index = nil
end

function wnd_suicongUpSkillLevel:configure()
	local widgets = self._layout.vars
	self._layout.vars.close_btn:onClick(self,self.onCloseUI)
end

function wnd_suicongUpSkillLevel:refresh(skillId, petId, index)
	self._petId = petId
	self._index = index
	self.allItem = {}
	local str = index ~= 4 and "在战斗中自动施放" or "奥义需要手动释放"
	self._layout.vars.tips:setText(str)
	self._layout.vars.skill_name:setText(i3k_db_skills[skillId].name)
	local skillLevel = g_i3k_game_context:GetMercenarySkillLevelForIndex(petId, index)
	local needLvl, needItemId, needItemCount = g_i3k_game_context:GetPetSkillData(petId, index, skillLevel+1)
	if not needLvl then
		g_i3k_ui_mgr:CloseUI(eUIID_SuicongUpSkillLevel)
		g_i3k_ui_mgr:OpenUI(eUIID_SuicongMaxSkillLevel)
		g_i3k_ui_mgr:RefreshUI(eUIID_SuicongMaxSkillLevel,skillId, petId, index)
		return
	end
	local nowLvl = g_i3k_game_context:getPetLevel(petId)
	for i=1, 2 do
		local tmp_str = self:getSkillTips(skillId, skillLevel+i-1)
		self._layout.vars["skill_lvl" .. i]:setText(skillLevel+i-1 .. "级")
		self._layout.vars["skill_desc" .. i]:setText(tmp_str)
		if nowLvl >= needLvl then
			self._layout.vars["up_btn" .. i]:enableWithChildren()
		else
			self._layout.vars["up_btn" .. i]:disableWithChildren()
		end
		self._layout.vars["up_btn" .. i]:onClick(self, self.upSkillLevelBtn, {tag = i, petId = petId, index = index, skillLevel = skillLevel, aCount = #needItemId})
	end
	local desc = string.format("宠物%s级后可升级", needLvl)
	self._layout.vars.upTips:setText(desc)
	self._layout.vars.upTips:setTextColor(g_i3k_get_cond_color(nowLvl >= needLvl))
	self:refreshScrollData()
end

function wnd_suicongUpSkillLevel:refreshScrollData()
	local petId = self._petId
	local index = self._index
	self._layout.vars.skill_cost_scroll:removeAllChildren()
	local skillLevel = g_i3k_game_context:GetMercenarySkillLevelForIndex(petId, index)
	local needLvl, needItemId, needItemCount = g_i3k_game_context:GetPetSkillData(petId, index, skillLevel+1)
	for i=1, #needItemId do
		if needItemId[i] ~= 0 then
			local _layer = require(LAYER)()
			local widget = _layer.vars
			widget.suo:setVisible(g_i3k_db.i3k_db_get_consume_lock_visible(needItemId[i]))
			widget.item_icon:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(needItemId[i],i3k_game_context:IsFemaleRole()))
			widget.item_BgIcon:setImage(g_i3k_get_icon_frame_path_by_rank(g_i3k_db.i3k_db_get_common_item_rank(needItemId[i])))
			widget.item_name:setText(g_i3k_db.i3k_db_get_common_item_name(needItemId[i]))
			widget.item_name:setTextColor(g_i3k_get_color_by_rank(g_i3k_db.i3k_db_get_common_item_rank(needItemId[i])))
			if needItemId[i] == g_BASE_ITEM_COIN then
				widget.item_count:setText(needItemCount[i])
			else
				widget.item_count:setText(g_i3k_game_context:GetCommonItemCanUseCount(needItemId[i]).."/"..needItemCount[i])
			end
			widget.item_count:setTextColor(g_i3k_get_cond_color(needItemCount[i] <= g_i3k_game_context:GetCommonItemCanUseCount(needItemId[i])))
			widget.tip_btn:onClick(self, self.itemTips, needItemId[i])
			self._layout.vars.skill_cost_scroll:addItem(_layer)
		end
	end
end

function wnd_suicongUpSkillLevel:upSkillLevelBtn(sender, data)
	local nowLvl = g_i3k_game_context:getPetLevel(data.petId)
	local skillLevel = data.skillLevel
	local aCount = data.tag == 1 and skillLevel or #i3k_db_suicong_skillUplvl[data.petId] / 4
	for i=skillLevel, aCount do
		local needLvl, needItemId, needItemCount = g_i3k_game_context:GetPetSkillData(data.petId, data.index, i+1)
		local isenough = self:isEnoughUpPetSkillLevel(needItemId, needItemCount, nowLvl, needLvl)
		skillLevel = i + 1
		if (data.tag == 2 and not isenough) or (data.tag == 1 and isenough) then
			if not isenough then
				skillLevel = skillLevel -1
			end
			if skillLevel > data.skillLevel then
				local fun = function ()
					for k,v in pairs(self.allItem) do
						g_i3k_game_context:UseCommonItem(k, v,AT_PET_SKILL_LEVEL_UP)
					end
				end
				i3k_sbean.pet_skill_level_up(data.petId, data.index, skillLevel, self.allItem)
			else
				g_i3k_ui_mgr:PopupTipMessage("您不满足该条件")
			end
			break
		else
			if data.tag == 1 then
				g_i3k_ui_mgr:PopupTipMessage("您不满足该条件")
				break
			end
		end
	end
end

function wnd_suicongUpSkillLevel:isEnoughUpPetSkillLevel(needItemId, needItemCount, nowLvl, needLvl)
	if not needLvl or nowLvl < needLvl then
		return false
	end
	for i=1,2 do
		if needItemId[i] ~= 0 then
			if (self.allItem[needItemId[i]] or 0) + needItemCount[i] > g_i3k_game_context:GetCommonItemCanUseCount(needItemId[i]) then
				return false
			end
			self.allItem[needItemId[i]] = (self.allItem[needItemId[i]] or 0) + needItemCount[i]
		end
	end
	return true
end

function wnd_suicongUpSkillLevel:itemTips(sender, itemId)
	g_i3k_ui_mgr:ShowCommonItemInfo(itemId)
end

function wnd_suicongUpSkillLevel:getSkillTips(skillId, level)
	local spArgs1 = i3k_db_skill_datas[skillId][level].spArgs1
	local spArgs2 = i3k_db_skill_datas[skillId][level].spArgs2
	local spArgs3 = i3k_db_skill_datas[skillId][level].spArgs3
	local spArgs4 = i3k_db_skill_datas[skillId][level].spArgs4
	local spArgs5 = i3k_db_skill_datas[skillId][level].spArgs5
	local commonDesc = i3k_db_skills[skillId].common_desc
	return string.format(commonDesc,spArgs1,spArgs2,spArgs3,spArgs4,spArgs5)
end

function wnd_create(layout)
	local wnd = wnd_suicongUpSkillLevel.new()
	wnd:create(layout)
	return wnd
end

