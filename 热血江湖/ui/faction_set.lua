-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------
wnd_faction_set = i3k_class("wnd_faction_set", ui.wnd_base)


local LAYER_BPSZT = "ui/widgets/bpszt"

local LEVEL = i3k_db_common.faction.addLevel

function wnd_faction_set:ctor()
	
end

function wnd_faction_set:configure(...)
	self.btn_scroll = self._layout.vars.btn_scroll 
	self._layout.vars.close_btn:onClick(self,self.onCloseUI)
	
end

function wnd_faction_set:onShow()
	
	
end

function wnd_faction_set:refresh()
	self:updateData()
end 

function wnd_faction_set:updateData()
	self.btn_scroll:removeAllChildren()
	
	for i=1,5 do
		 
		local _layer = require(LAYER_BPSZT)()
		
		local btn = _layer.vars.btn 
		local btnName = _layer.vars.btnName 
		btn:setTag(i)
		btn:onTouchEvent(self,self.onChangeBtn)
		if i == 1 then
			btnName:setText("修改帮派名字")
		elseif i == 2 then
			btnName:setText("修改帮派图示")
		elseif i == 3 then
			btnName:setText("帮派招募")
		elseif i == 4 then
			btnName:setText("帮派群发信件")
		elseif i == 5 then
			btnName:setText("帮派申请设置")
		end
		
		self.btn_scroll:addItem(_layer)
	end
end

function wnd_faction_set:onChangeBtn(sender,eventType)
	if eventType == ccui.TouchEventType.ended then
		
		local myPos = g_i3k_game_context:GetSectPosition()
		local tag = sender:getTag()
		if tag == 1 then
			if i3k_db_faction_power[myPos] and i3k_db_faction_power[myPos].factionName == 1 then
				g_i3k_ui_mgr:OpenUI(eUIID_FactionChangeName)
			else
				g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(801))
			end 
		elseif tag == 2 then
			if i3k_db_faction_power[myPos] and i3k_db_faction_power[myPos].factionIcon == 1 then
				g_i3k_ui_mgr:OpenUI(eUIID_FactionNewChangeIcon)
				g_i3k_ui_mgr:RefreshUI(eUIID_FactionNewChangeIcon)
			else
				g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(801))
			end 
		elseif tag == 3 then
			if i3k_db_faction_power[myPos] and i3k_db_faction_power[myPos].factionLvl == 1 then
				g_i3k_ui_mgr:OpenUI(eUIID_FactionChangeLevel)
				g_i3k_ui_mgr:RefreshUI(eUIID_FactionChangeLevel)
			else
				g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(801))
			end 
		elseif tag == 4 then
			if i3k_db_faction_power[myPos] and i3k_db_faction_power[myPos].factionEmail == 1 then
				g_i3k_ui_mgr:OpenUI(eUIID_FactionEmail)
				g_i3k_ui_mgr:RefreshUI(eUIID_FactionEmail)
			else
				g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(801))
			end 
		elseif tag == 5 then
			if i3k_db_faction_power[myPos] and i3k_db_faction_power[myPos].factionApply == 1 then
				g_i3k_ui_mgr:OpenUI(eUIID_FactionAppilyNoticeSet)
				g_i3k_ui_mgr:RefreshUI(eUIID_FactionAppilyNoticeSet)
			else
				g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(801))
			end 
		end
		
	end
end



--[[function wnd_faction_set:onClose(sender,eventType)
	g_i3k_ui_mgr:CloseUI(eUIID_FactionSet)
end--]]

function wnd_create(layout, ...)
	local wnd = wnd_faction_set.new()
	wnd:create(layout, ...)

	return wnd
end

