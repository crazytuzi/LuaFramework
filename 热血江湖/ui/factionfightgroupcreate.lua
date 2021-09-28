-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------
wnd_factionFightGroupCreate = i3k_class("wnd_factionFightGroupCreate", ui.wnd_base)

function wnd_factionFightGroupCreate:ctor()
end

function wnd_factionFightGroupCreate:configure()
	self._layout.vars.close_btn:onClick(self, function ()
		if table.nums(g_i3k_game_context:getFactionFightGroupData()) < 1 then
			g_i3k_ui_mgr:CloseUI(eUIID_FactionFightGroup)
		end
		self.onClose()
	end )
	self._layout.vars.input_label:setMaxLength(i3k_db_common.inputlen.fightGrouplen)
	self._layout.vars.tips:setText(i3k_get_string(3080,  math.floor(i3k_db_faction_fightgroup.common.time/3600).."小时后"))
end

function wnd_factionFightGroupCreate:refresh(index)
	local config = i3k_db_faction_fightgroup.create[index]
	local vars = self._layout.vars
	vars.money_label:setText(config.costMoney)
	vars.gold_label:setText(config.costGold)
	vars.ingot_label:setText(config.costHuoyue)
	
	local isEnough = 0
	if g_i3k_game_context:GetMoneyCanUse(false) < config.costMoney then
		vars.money_label:setTextColor(g_i3k_get_cond_color(false))
		isEnough = 1
	else
		vars.money_label:setTextColor(g_i3k_get_cond_color(true))
	end
	
	if g_i3k_game_context:GetDiamondCanUse(false) < config.costGold then
		vars.gold_label:setTextColor(g_i3k_get_cond_color(false))
		isEnough = 2
	else
		vars.gold_label:setTextColor(g_i3k_get_cond_color(true))
	end
	
	if g_i3k_game_context:GetFactionVitality() < config.costHuoyue then
		vars.ingot_label:setTextColor(g_i3k_get_cond_color(false))
		isEnough = 3
	else
		vars.ingot_label:setTextColor(g_i3k_get_cond_color(true))
	end
	
	vars.createBtn:onClick(self,function ()
		local rolelvl = g_i3k_game_context:GetLevel()
		if rolelvl < i3k_db_faction_fightgroup.common.joinLevel then
			g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(3123, i3k_db_faction_fightgroup.common.joinLevel))
			return
		end
		
		if isEnough == 1 then
			g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(3088))
			return
		elseif isEnough == 2 then
			g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(3087))
			return
		elseif isEnough == 3 then
			g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(3089))
			return
		end
		
		local name = self._layout.vars.input_label:getText();
		local error_code,desc = g_i3k_fightgroup_name_rule(name)
		if error_code ~= 1 then
			g_i3k_ui_mgr:PopupTipMessage(desc)
			return 
		end
		
		i3k_sbean.request_sect_fight_group_create_req(name, index, function ()
			self:onClose();
			--扣除消耗
			g_i3k_game_context:UseFactionVitality(config.costHuoyue)
			g_i3k_game_context:UseDiamond(config.costGold, false, AT_CREATE_FIGHT_GROUP)
			g_i3k_game_context:UseMoney(config.costMoney, false, AT_CREATE_FIGHT_GROUP)
			--同步数据
			i3k_sbean.request_sect_fight_group_sync_req(function (data)
				g_i3k_ui_mgr:RefreshUI(eUIID_FactionFightGroup, data)
			end)
		end)
	end)
end

function wnd_factionFightGroupCreate:onClose()
	g_i3k_ui_mgr:CloseUI(eUIID_FactionFightGroupCreate)
end

function wnd_create(layout, ...)
	local wnd = wnd_factionFightGroupCreate.new()
		wnd:create(layout, ...)
	return wnd
end
