-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------
wnd_shen_bing_upskill = i3k_class("wnd_shen_bing_upskill", ui.wnd_base)

local JNSJT = "ui/widgets/jnsjt1"

function wnd_shen_bing_upskill:ctor( )
	self.shenbingId = 1
	self.skillId = 1
	self.toLevel = 1
	self.descId = 1
	self.useIdTbl = {}
	self.useCountTbl = {}
	self.shenbing_lvl = 1
	self.requireShenBingLvl = 1
end

function wnd_shen_bing_upskill:configure( )
	local widgets = self._layout.vars
	self.skill_lvl_now = widgets.skill_lvl_now
	self.skill_lvl_next = widgets.skill_lvl_next
	self.skill_desc_now = widgets.skill_desc_now
	self.skill_desc_next = widgets.skill_desc_next

	self.skill_cost_scroll = widgets.skill_cost_scroll
	self.skill_name = widgets.skill_name
	self.close_btn = widgets.close_btn
	self.close_btn:onClick(self, self.onCloseUI)	
	self.up_btn = widgets.up_btn
	--self.up_btn:onClick(self,self.onTouchUp,{shenbingId = self.shenbingId,skillId = self.skillId,toLevel = self.toLevel})
	self.yijian_up_btn = widgets.yijian_up_btn
	--self.yijian_up_btn:onClick(self,self.onTouchYiJianUp)
	self.require_shenbing_lvl = widgets.require_shenbing_lvl
end

function wnd_shen_bing_upskill:refresh(shenbingId,skillId,tag)
	self.shenbingId = shenbingId 
	self.skillId = tag 
	self.descId = skillId

	self:SetShenBingUpSkillData(shenbingId,skillId,tag)
	self:updateShenBingUpSkillItems()
end

function wnd_shen_bing_upskill:SetShenBingUpSkillData(shenbingId,skillId,tag)
	local skillUpData = g_i3k_game_context:GetShenBingUpSkillData()

	self.skill_name:setText(i3k_db_skills[skillId].name)
	local skill_lvl_now = skillUpData[shenbingId][tag]
	local skill_lvl_next = skill_lvl_now + 1
	self.toLevel = skill_lvl_next
    self.shenbing_lvl = g_i3k_game_context:GetShenBingQlvl(shenbingId)
	self.requireShenBingLvl = i3k_db_shen_bing_upskill[shenbingId][tag][skill_lvl_now+1].upSkill_lvl
	self.skill_lvl_now:setText(skill_lvl_now.."级")
	self.skill_lvl_next:setText(skill_lvl_next.."级")
			
	local spArgs1 = i3k_db_skill_datas[skillId][skill_lvl_now].spArgs1
	local spArgs2 = i3k_db_skill_datas[skillId][skill_lvl_now].spArgs2
	local spArgs3 = i3k_db_skill_datas[skillId][skill_lvl_now].spArgs3
	local spArgs4 = i3k_db_skill_datas[skillId][skill_lvl_now].spArgs4
	local spArgs5 = i3k_db_skill_datas[skillId][skill_lvl_now].spArgs5
	local commonDesc = i3k_db_skills[skillId].common_desc
	local tmp_str_now = string.format(commonDesc,spArgs1,spArgs2,spArgs3,spArgs4,spArgs5)
	self.skill_desc_now:setText(tmp_str_now)

	local spArgs11 = i3k_db_skill_datas[skillId][skill_lvl_next].spArgs1
	local spArgs21 = i3k_db_skill_datas[skillId][skill_lvl_next].spArgs2
	local spArgs31 = i3k_db_skill_datas[skillId][skill_lvl_next].spArgs3
	local spArgs41 = i3k_db_skill_datas[skillId][skill_lvl_next].spArgs4
	local spArgs51 = i3k_db_skill_datas[skillId][skill_lvl_next].spArgs5
	local commonDesc = i3k_db_skills[skillId].common_desc
	local tmp_str_next = string.format(commonDesc,spArgs11,spArgs21,spArgs31,spArgs41,spArgs51)
	self.skill_desc_next:setText(tmp_str_next)
	
	self.up_btn:onClick(self,self.onTouchUp,{shenbingId = self.shenbingId,skillId = self.skillId,toLevel = self.toLevel,descId = self.descId})
	self.yijian_up_btn:onClick(self,self.onTouchYiJianUp,{shenbingId = self.shenbingId,skillId = self.skillId,skill_lvl_now = skill_lvl_now,descId = self.descId})

	local upSkillDataTbl = i3k_db_shen_bing_upskill[shenbingId][tag][skill_lvl_next]
	self.useIdTbl = {
	[1] = upSkillDataTbl.use_id1,
	[2] = upSkillDataTbl.use_id2
}
	self.useCountTbl = {
	[1] = upSkillDataTbl.use_count1,
	[2] = upSkillDataTbl.use_count2
}
end
function wnd_shen_bing_upskill:updateShenBingUpSkillItems()
	self.skill_cost_scroll:removeAllChildren()
	for k,v in ipairs(self.useIdTbl) do
		if v ~= 0 then 
			local _layer = require(JNSJT)()
			local widgets1 = _layer.vars
			local itemId = self.useIdTbl[k]
			local item_rank = g_i3k_db.i3k_db_get_common_item_rank(itemId)
			local item_count = self.useCountTbl[k]

			widgets1.suo:setVisible(g_i3k_db.i3k_db_get_consume_lock_visible(itemId))
			widgets1.item_icon:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(itemId,i3k_game_context:IsFemaleRole()))
			widgets1.item_name:setText(g_i3k_db.i3k_db_get_common_item_name(itemId))
			widgets1.item_name:setTextColor(g_i3k_get_color_by_rank(item_rank))
			if itemId == g_BASE_ITEM_COIN then
				widgets1.item_count:setText(item_count)
			else
				widgets1.item_count:setText(g_i3k_game_context:GetCommonItemCanUseCount(itemId).."/"..item_count)
			end
			widgets1.item_count:setTextColor(g_i3k_get_cond_color(item_count <= g_i3k_game_context:GetCommonItemCanUseCount(itemId)))
			widgets1.item_BgIcon:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(itemId))
			widgets1.tip_btn:onClick(self, self.itemTips, itemId)
			self.skill_cost_scroll:addItem(_layer)
		end
	end

	local ji = ""
	local num = ""
	if self.shenbing_lvl >= self.requireShenBingLvl then
		num = string.format("<c=green>%d</c>", self.requireShenBingLvl) 
		ji = string.format("<c=green>%s</c>", "阶") 
		self.require_shenbing_lvl:setText(string.format("神兵%s%s%s",num,ji,"后可升级"))
	else
		num = string.format("<c=red>%d</c>", self.requireShenBingLvl) 
		ji = string.format("<c=red>%s</c>", "阶") 
		self.require_shenbing_lvl:setText(string.format("神兵%s%s%s",num,ji,"后可升级"))
	end

	local bag_count1 = g_i3k_game_context:GetCommonItemCanUseCount(self.useIdTbl[1])
	local bag_count2 = g_i3k_game_context:GetCommonItemCanUseCount(self.useIdTbl[2])
	if self.shenbing_lvl >= self.requireShenBingLvl then		
		if bag_count1 >= self.useCountTbl[1] then
			if self.useIdTbl[2] == 0 then
				self:judgeDisableOrEnable(true)
			else
				if bag_count2 >= self.useCountTbl[2] then 
					self:judgeDisableOrEnable(true)
				else
					self:judgeDisableOrEnable(false)
				end
			end
		else
			self:judgeDisableOrEnable(false)
		end	
	else
		self:judgeDisableOrEnable(false)
	end
end

function wnd_shen_bing_upskill:judgeDisableOrEnable(isTrue)
	if isTrue then
		self.up_btn:enableWithChildren()		
		self.yijian_up_btn:enableWithChildren()
	else
		self.up_btn:disableWithChildren()		
		self.yijian_up_btn:disableWithChildren()
	end
end
function wnd_shen_bing_upskill:onTouchUp(sender,upskillData)
	i3k_sbean.shen_bing_upSkill(upskillData.shenbingId,upskillData.skillId,upskillData.toLevel,upskillData.descId)
	g_i3k_ui_mgr:PopupTipMessage("恭喜您成功升级")
end

function wnd_shen_bing_upskill:onTouchYiJianUp(sender,yijianUpSkillData)
	local shenbingId = yijianUpSkillData.shenbingId
	local skillId = yijianUpSkillData.skillId 
	local skill_lvl_now = yijianUpSkillData.skill_lvl_now 
	local descId = yijianUpSkillData.descId
	local toLevel = self:SetUpSkillMaxLvl(shenbingId,skillId,skill_lvl_now)
	i3k_sbean.shen_bing_upSkill(shenbingId,skillId,toLevel,descId)
	g_i3k_ui_mgr:PopupTipMessage("恭喜您成功升级")
end

function wnd_shen_bing_upskill:itemTips(sender,itemId)
	g_i3k_ui_mgr:ShowCommonItemInfo(itemId)
end

function wnd_shen_bing_upskill:upSkillUseCommonItem(shenbingId,skillId,skillLvl)	
	for k,v in ipairs(self.useIdTbl) do
		if v ~= 0 then 
			local itemId = self.useIdTbl[k]
			local item_count = self.useCountTbl[k]
			g_i3k_game_context:UseCommonItem(itemId,item_count,AT_WEAPON_SKILL_LEVEL_UP)
		end
	end
end

function wnd_shen_bing_upskill:SetUpSkillMaxLvl(shenbingId,skillId,skill_lvl_now)
	local upSkillMaxLvl = 1
	for i = skill_lvl_now,#i3k_db_shen_bing_upskill[shenbingId][skillId] - 1 do
		if self.shenbing_lvl >= i3k_db_shen_bing_upskill[shenbingId][skillId][i+1].upSkill_lvl then
			local id1 = i3k_db_shen_bing_upskill[shenbingId][skillId][i + 1].use_id1
			local count1 = i3k_db_shen_bing_upskill[shenbingId][skillId][i + 1].use_count1
			local bag_count1 = g_i3k_game_context:GetCommonItemCanUseCount(id1)
			if bag_count1 >= count1 then
				local id2 = i3k_db_shen_bing_upskill[shenbingId][skillId][i + 1].use_id2
				local count2 = i3k_db_shen_bing_upskill[shenbingId][skillId][i + 1].use_count2
				local bag_count2 = g_i3k_game_context:GetCommonItemCanUseCount(id2)
				if id2 ~= 0 then
					if bag_count2 >= count2 then
						upSkillMaxLvl = i + 1
					else
						upSkillMaxLvl = i 
						return upSkillMaxLvl
					end
				else
					upSkillMaxLvl = i + 1
				end;
			else
				upSkillMaxLvl = i 
				return upSkillMaxLvl
			end
		else
			upSkillMaxLvl = i
			return upSkillMaxLvl
		end
	end
	return upSkillMaxLvl	
end

function wnd_create(layout)
	local wnd = wnd_shen_bing_upskill.new()
	wnd:create(layout)
	return wnd
end


	
