
-------------------------------------------------------
module(..., package.seeall)
local require = require;
local ui = require("ui/base");
-------------------------------------------------------
wnd_hideWeaponActiveSkill = i3k_class("wnd_hideWeaponActiveSkill",ui.wnd_base)

local JNSJT = "ui/widgets/jnsjt1"

function wnd_hideWeaponActiveSkill:ctor()
	self._cost = {}
end

function wnd_hideWeaponActiveSkill:configure()
	local widgets = self._layout.vars
	widgets.close_btn:onClick(self, self.onCloseUI)

	self.ui = widgets
end

function wnd_hideWeaponActiveSkill:refresh(wid)
	self:updateUI(wid)
end

function wnd_hideWeaponActiveSkill:updateUI(wid)
	local skillID = i3k_db_anqi_base[wid].skillID
	local skillLvl = g_i3k_game_context:GetHideWeaponActiveSkillLvl(wid)
	local finalSkillLvl = g_i3k_game_context:GetHideWeaponFinalActiveSkillLvl(wid)

	self:setNowSkillData(wid, skillID, skillLvl, finalSkillLvl)
	self:setNextSkillData(wid, skillID, skillLvl, finalSkillLvl)
	self:updateUpSkillItems()
end

function wnd_hideWeaponActiveSkill:setNowSkillData(wid, skillID, skillLvl, finalSkillLvl)
	self.ui.skill_name:setText(i3k_db_skills[skillID].name)

	local skillNowDesc = self:getSkillDesc(skillID, finalSkillLvl)
	self.ui.skill_desc_now:setText(skillNowDesc)
	if skillLvl ~= finalSkillLvl then
		self._layout.vars.now_label:setTextColor(g_COLOR_VALUE_GREEN)
		self.ui.skill_lvl_now:setTextColor(g_COLOR_VALUE_GREEN)
		self.ui.skill_lvl_now:setText(finalSkillLvl .. "级(+"..(finalSkillLvl - skillLvl)..")")
	else
		self.ui.skill_lvl_now:setText(finalSkillLvl .. "级")
	end
end

function wnd_hideWeaponActiveSkill:setNextSkillData(wid, skillID, skillLvl, finalSkillLvl)
	--需要获取加成之后的技能等级
	local finalSkillNextLvl = finalSkillLvl + 1

	local skillNextDesc = self:getSkillDesc(skillID, finalSkillNextLvl)
	self.ui.skill_desc_next:setText(skillNextDesc)
	-- self.ui.skill_lvl_next:setText(finalSkillNextLvl .. "级")
	if skillLvl ~= finalSkillLvl then
		self._layout.vars.next_label:setTextColor(g_COLOR_VALUE_GREEN)
		self.ui.skill_lvl_next:setTextColor(g_COLOR_VALUE_GREEN)
		self.ui.skill_lvl_next:setText(finalSkillNextLvl .. "级(+"..(finalSkillLvl - skillLvl)..")")
	else
		self.ui.skill_lvl_next:setText(finalSkillNextLvl .. "级")
	end
	--升级消耗
	local skillData = i3k_db_skill_datas[skillID][skillLvl + 1]
	local cost = {}
	table.insert(cost, {id = g_BASE_ITEM_COIN, count = skillData.needCoin})
	table.insert(cost, {id = skillData.needItemID, count = skillData.needItemNum})
	self._cost = cost

	local nowAnqiLvl = g_i3k_game_context:GetHideWeaponLvl(wid)
	local needAnqiLvl = g_i3k_db.i3k_db_get_one_anqi_active_skill_level_limit(skillLvl)
	local colorStr = nowAnqiLvl >= needAnqiLvl and "<c=green>前提：</c>暗器等级达到<c=green>%d</c>级" or "<c=red>前提：</c>暗器等级达到<c=red>%d</c>级"
	local str = string.format(colorStr, needAnqiLvl)
	self.ui.require_shenbing_lvl:setText(str)

	self.ui.up_btn:onClick(self, self.onUpSkillLvl, {wid = wid, needAnqiLvl = needAnqiLvl, nowAnqiLvl = nowAnqiLvl, cost = cost})
end

function wnd_hideWeaponActiveSkill:getSkillDesc(skillID, skillLvl)
	local spArgs1 = i3k_db_skill_datas[skillID][skillLvl].spArgs1
	local spArgs2 = i3k_db_skill_datas[skillID][skillLvl].spArgs2
	local spArgs3 = i3k_db_skill_datas[skillID][skillLvl].spArgs3
	local spArgs4 = i3k_db_skill_datas[skillID][skillLvl].spArgs4
	local spArgs5 = i3k_db_skill_datas[skillID][skillLvl].spArgs5
	local commonDesc = i3k_db_skills[skillID].common_desc
	local skillDesc = string.format(commonDesc, spArgs1, spArgs2, spArgs3, spArgs4, spArgs5)
	return skillDesc
end

function wnd_hideWeaponActiveSkill:updateUpSkillItems()
	self.ui.skill_cost_scroll:removeAllChildren()

	for _, v in ipairs(self._cost) do
		if v.id ~= 0 and v.count > 0 then
			local ui = require(JNSJT)()
			local item_rank = g_i3k_db.i3k_db_get_common_item_rank(v.id)
			local haveCount = g_i3k_game_context:GetCommonItemCanUseCount(v.id)

			ui.vars.suo:setVisible(g_i3k_db.i3k_db_get_consume_lock_visible(v.id))
			ui.vars.item_icon:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(v.id, g_i3k_game_context:IsFemaleRole()))
			ui.vars.item_name:setText(g_i3k_db.i3k_db_get_common_item_name(v.id))
			ui.vars.item_name:setTextColor(g_i3k_get_color_by_rank(item_rank))
			if math.abs(v.id) == g_BASE_ITEM_COIN or math.abs(v.id) == g_BASE_ITEM_DIAMOND then
				ui.vars.item_count:setText(v.count)
			else
				ui.vars.item_count:setText(haveCount .. "/" .. v.count)
			end
			ui.vars.item_count:setTextColor(g_i3k_get_cond_color(v.count <= haveCount))
			ui.vars.item_BgIcon:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(v.id))
			ui.vars.tip_btn:onClick(self, function()
				g_i3k_ui_mgr:ShowCommonItemInfo(v.id)
			end)
			self.ui.skill_cost_scroll:addItem(ui)
		end
	end
end

function wnd_hideWeaponActiveSkill:onUpSkillLvl(sender, data)
	local needAnqiLvl = data.needAnqiLvl
	local nowAnqiLvl = data.nowAnqiLvl
	if nowAnqiLvl < needAnqiLvl then
		g_i3k_ui_mgr:PopupTipMessage("暗器等级不足")
		return
	end

	for _, v in ipairs(data.cost) do
		if g_i3k_game_context:GetCommonItemCanUseCount(v.id) < v.count then
			g_i3k_ui_mgr:PopupTipMessage("升级所需道具不足")
			return
		end
	end

	i3k_sbean.hideweapon_askill_levelup(data.wid, data.cost)
end

function wnd_create(layout, ...)
	local wnd = wnd_hideWeaponActiveSkill.new()
	wnd:create(layout, ...)
	return wnd;
end
