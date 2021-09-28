-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------
wnd_createFaction = i3k_class("wnd_createFaction", ui.wnd_base)

local MONEY_TYPE = 2
local INGOT_TYPE = 1

function wnd_createFaction:ctor()
	
end

function wnd_createFaction:configure(...)
	self._layout.vars.close_btn:onClick(self,self.onCloseUI)
	
	local moneyCreate_btn = self._layout.vars.moneyCreate_btn 
	moneyCreate_btn:onTouchEvent(self,self.onMoenyCreate)
	local ingotCreate_btn = self._layout.vars.ingotCreate_btn
	ingotCreate_btn:onTouchEvent(self,self.onIngotCreate)
	local money_label = self._layout.vars.money_label 
	local tmp_str = string.format("×%s",i3k_db_common.faction.createMoney)
	money_label:setText(tmp_str)
	local ingot_label = self._layout.vars.ingot_label
	local tmp_str = string.format("×%s",i3k_db_common.faction.createIngot) 
	ingot_label:setText(tmp_str)
	self.input_label = self._layout.vars.input_label 
	self.input_label:setMaxLength(i3k_db_common.inputlen.namelen)
	local chang_icon_btn = self._layout.vars.chang_icon_btn 
	chang_icon_btn:onTouchEvent(self,self.onChangeIcon)
	local suo_icon = self._layout.vars.suo_icon 
	suo_icon:hide()
	self.faction_icon = self._layout.vars.faction_icon 
	local money_suo_icon = self._layout.vars.money_suo_icon 
	money_suo_icon:show()
	local days = math.modf(i3k_db_common.faction.leave_time /(60*60*24))
	self.tips = self._layout.vars.tips 
	self.tips:setText(i3k_get_string(757,days))
end

function wnd_createFaction:onShow()
	
end

function wnd_createFaction:updatefactionIcon()
	local iconid = g_i3k_game_context:getFactionSelectIcon()
	if iconid ~= 0 then
		self.faction_icon:setImage(g_i3k_db.i3k_db_get_icon_path(i3k_db_faction_icons[iconid].iconid))
	else
		self.faction_icon:setImage(g_i3k_db.i3k_db_get_icon_path(i3k_db_faction_icons[g_i3k_db.i3k_db_get_faction_auto_icon()].iconid))
	end
end 

function wnd_createFaction:refresh()
	self:updatefactionIcon()
end 

function wnd_createFaction:onHide()
	
end

function wnd_createFaction:onChangeIcon(sender,eventType)
	if eventType == ccui.TouchEventType.ended then
		g_i3k_ui_mgr:OpenUI(eUIID_ChangeSkillIcon)
		g_i3k_ui_mgr:RefreshUI(eUIID_ChangeSkillIcon,2)
	end
end


function wnd_createFaction:onMoenyCreate(sender,eventType)
	if eventType == ccui.TouchEventType.ended then
		local hero_lvl = g_i3k_game_context:GetLevel()
		if hero_lvl < i3k_db_common.faction.createLevel then
			g_i3k_ui_mgr:PopupTipMessage("您需要达到20级方可建立帮派")
			return 
		end
		local name = self.input_label:getText()
		local error_code,desc = g_i3k_name_rule(name)
		if error_code ~= 1 then
			g_i3k_ui_mgr:PopupTipMessage(desc)
			return 
		end 
		
		local fun = (function(ok) 
			if ok then
				local need_money = i3k_db_common.faction.createMoney
				
				if g_i3k_game_context:GetMoneyCanUse(false) < need_money then
					g_i3k_ui_mgr:PopupTipMessage("铜钱不足无法创建帮派")
					return 
				end
					local data = i3k_sbean.sect_create_req.new()
					data.name = name
					data.useStone = MONEY_TYPE
					data.icon = 0
					local iconid = g_i3k_game_context:getFactionSelectIcon()
					
					if iconid ~= 0 then
						data.icon = iconid
					else
						data.icon = g_i3k_db.i3k_db_get_faction_auto_icon()
					end
					
					i3k_game_send_str_cmd(data,i3k_sbean.sect_create_res.getName())
				end 
			end)
		local desc = i3k_get_string(10024,i3k_db_common.faction.createMoney)
		g_i3k_ui_mgr:ShowMessageBox2(desc,fun)
		
	end
end

function wnd_createFaction:onIngotCreate(sender,eventType)
	if eventType == ccui.TouchEventType.ended then
		local hero_lvl = g_i3k_game_context:GetLevel()
		if hero_lvl < i3k_db_common.faction.createLevel then
			g_i3k_ui_mgr:PopupTipMessage("您需要达到20级方可建立帮派")
			return 
		end
		local name = self.input_label:getText()
		local error_code,desc = g_i3k_name_rule(name)
		if error_code ~= 1 then
			g_i3k_ui_mgr:PopupTipMessage(desc)
			return 
		end 
		
		local fun = (function(ok) 
			if ok then
				local need_money = i3k_db_common.faction.createIngot
				
				if g_i3k_game_context:GetDiamondCanUse(true) < need_money then
					g_i3k_ui_mgr:PopupTipMessage("元宝不足无法创建帮派")
					return 
				end
					
					local data = i3k_sbean.sect_create_req.new()
					data.name = name
					data.useStone = INGOT_TYPE
					data.icon = 0
					local iconid = g_i3k_game_context:getFactionSelectIcon()
					
					if iconid ~= 0 then
						data.icon = iconid
					else
						data.icon = g_i3k_db.i3k_db_get_faction_auto_icon()
					end
					i3k_game_send_str_cmd(data,i3k_sbean.sect_create_res.getName())
			end 
			end)
		local desc = i3k_get_string(10025,i3k_db_common.faction.createIngot)
			
		g_i3k_ui_mgr:ShowMessageBox2(desc,fun)
	end
end


--[[function wnd_createFaction:onCloseLayer(sender,eventType)
	if eventType == ccui.TouchEventType.ended then
		g_i3k_ui_mgr:CloseUI(eUIID_CreateFaction)
	end
end--]]

function wnd_create(layout, ...)
	local wnd = wnd_createFaction.new();
		wnd:create(layout, ...);

	return wnd;
end
