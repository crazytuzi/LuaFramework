-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------
wnd_suicong_breakskill_tips = i3k_class("wnd_suicong_breakskill_tips", ui.wnd_base)


--突破技能属性
local _attribute = {
[1] = "伤害加深",
[2] = "伤害减免",
[3] = "气功继承",
[4] = "神兵继承",
}

function wnd_suicong_breakskill_tips:ctor()
	self._skillID = nil
	self._id = nil
	self._isChange = false
	self._poptick = 0
end

function wnd_suicong_breakskill_tips:configure()
	local widgets = self._layout.vars
	self._layout.vars.close_btn:onClick(self,self.onCloseUI)
	self.up_btn = self._layout.vars.up_btn
	self.up_btn:onClick(self, self.onUpSKill)
	
	self.attribute = self._layout.vars.attribute
	self.level = self._layout.vars.level
	self.desc1 = self._layout.vars.desc1
	self.desc2 = self._layout.vars.desc2
	self.item_icon = self._layout.vars.item_icon
	self.item_name = self._layout.vars.item_name
	self.item_count = self._layout.vars.item_count
	self.replace_name = self._layout.vars.replace_name
	self.replace_count = self._layout.vars.replace_count
	self.replace_icon = self._layout.vars.replace_icon
	
	self.item_bg = self._layout.vars.item_bg
	self.replace_bg = self._layout.vars.replace_bg
	self.item_btn1 = widgets.item_btn1
	self.item_btn2 = widgets.item_btn2
	
	self.battle_power = widgets.battle_power
	self.addIcon = widgets.addIcon
	self.powerValue = widgets.powerValue
end

function wnd_suicong_breakskill_tips:updateData(petId, skillId)
	self._id = petId
	self._skillID = skillId
	
	local skillLvl = g_i3k_game_context:getPetBreakSkillLvl(petId,skillId)
	if not i3k_db_suicong_breakdata[skillId][skillLvl + 1] then
		return
	end
	self.up_btn:setTag(skillLvl)
	local itemid = i3k_db_suicong_breakdata[skillId][skillLvl + 1].itemid
	local needCount =  i3k_db_suicong_breakdata[skillId][skillLvl + 1].itemCount
	local replaceid = i3k_db_suicong_breakdata[skillId][skillLvl + 1].replaceItem
	local skillType = i3k_db_suicong_breakdata[skillId][skillLvl + 1].skillType
	local increaseVal = i3k_db_suicong_breakdata[skillId][skillLvl].increaseCount
	local nextIncreaseVal = increaseVal
	if i3k_db_suicong_breakdata[skillId][skillLvl + 1] then
		nextIncreaseVal = i3k_db_suicong_breakdata[skillId][skillLvl + 1].increaseCount
	end
	
	local count1 = g_i3k_game_context:GetCommonItemCanUseCount(itemid)
	local count2 = g_i3k_game_context:GetCommonItemCanUseCount(replaceid)
	
	self.item_icon:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(itemid,i3k_game_context:IsFemaleRole()))
	self.replace_icon:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(replaceid,i3k_game_context:IsFemaleRole()))
	self.item_name:setText(g_i3k_db.i3k_db_get_common_item_name(itemid))
	self.item_name:setTextColor(g_i3k_get_color_by_rank(g_i3k_db.i3k_db_get_common_item_rank(itemid)))
	self.replace_name:setText(g_i3k_db.i3k_db_get_common_item_name(replaceid))
	self.replace_name:setTextColor(g_i3k_get_color_by_rank(g_i3k_db.i3k_db_get_common_item_rank(replaceid)))
	self.item_bg:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(itemid))
	self.replace_bg:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(replaceid))
	self.item_btn1:onClick(self, self.onItemTips, itemid)
	self.item_btn2:onClick(self, self.onItemTips, replaceid)
	
	local tmp_str = string.format("%s/%s", count1, needCount)
	self.item_count:setText(tmp_str)
	local color = g_i3k_get_cond_color(count1 + count2 >= needCount)
	self.item_count:setTextColor(color)
	self.replace_count:setText(count2)
	self.replace_count:setTextColor(color)
	self.attribute:setText(_attribute[skillType])
	local tmp_str = string.format("%s级",skillLvl)
	self.level:setText(tmp_str)
	if skillType == 1 or skillType == 2 then
		self.desc1:setText(string.format("%d%%",increaseVal/100));
	else
		self.desc1:setText(string.format("%d%%",increaseVal*100));
	end
	
	if skillType == 1 or skillType == 2 then
		self.desc2:setText(string.format("%d%%",nextIncreaseVal/100));
	else
		self.desc2:setText(string.format("%d%%",nextIncreaseVal*100));
	end
	
	if not self._isChange then
		self.battle_power:setText(math.modf(g_i3k_game_context:getBattlePower(petId)))
		self.addIcon:hide()
		self.powerValue:hide()
	end
end

function wnd_suicong_breakskill_tips:refresh(petId,skillId)
	self:updateData(petId,skillId)
end

function wnd_suicong_breakskill_tips:changeBattlePower(newBattlePower, oldBattlePower)
	self._isChange = true
	self._poptick = 0
	self._target = newBattlePower
	self._base = oldBattlePower
end

function wnd_suicong_breakskill_tips:onUpdate(dTime)--随从战力变化时动画
	if self._isChange then
		self._poptick = self._poptick + dTime
		if self._poptick < 1 then
			local text = self._base + math.floor((self._target - self._base)*self._poptick)
			self.battle_power:setText(text)
			self.addIcon:show()
			self.powerValue:show()
			self.powerValue:setText("+"..self._target - self._base)
		elseif self._poptick >= 1 and self._poptick < 2 then
			self.battle_power:setText(self._target)
			self.addIcon:hide()
			self.powerValue:hide()
		elseif self._poptick > 2 then
			self.addIcon:hide()
			self.powerValue:hide()
			self._isChange = false
		end
	end
end

function wnd_suicong_breakskill_tips:onUpSKill(sender)
	local skillLvl = sender:getTag()
	local itemid = i3k_db_suicong_breakdata[self._skillID][skillLvl + 1].itemid
	local needCount =  i3k_db_suicong_breakdata[self._skillID][skillLvl + 1].itemCount
	local replaceid = i3k_db_suicong_breakdata[self._skillID][skillLvl + 1].replaceItem
	local count1 = g_i3k_game_context:GetCommonItemCanUseCount(itemid)
	local count2 = g_i3k_game_context:GetCommonItemCanUseCount(replaceid)
	if count1 >= needCount then
		i3k_sbean.goto_pet_breakskilllvlup(self._id, self._skillID, skillLvl+1, needCount, 0)
	else
		i3k_sbean.goto_pet_breakskilllvlup(self._id, self._skillID, skillLvl+1, count1, needCount - count1)
	end
end

function wnd_suicong_breakskill_tips:onItemTips(sender, itemid)
	g_i3k_ui_mgr:ShowCommonItemInfo(itemid)
end

--[[function wnd_suicong_breakskill_tips:onClose(sender)
	g_i3k_ui_mgr:CloseUI(eUIID_SuicongBreakTips)
end--]]

function wnd_create(layout)
	local wnd = wnd_suicong_breakskill_tips.new()
	wnd:create(layout)
	return wnd
end

