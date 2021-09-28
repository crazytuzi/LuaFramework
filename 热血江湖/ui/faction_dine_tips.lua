-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------
wnd_faction_dine_tips = i3k_class("wnd_faction_dine_tips", ui.wnd_base)

function wnd_faction_dine_tips:ctor()
	
end
function wnd_faction_dine_tips:configure(...)
	self._layout.vars.close_btn:onClick(self,self.onCloseUI)
	local start_btn = self._layout.vars.start_btn 
	start_btn:onTouchEvent(self,self.onStart)
	local join_btn = self._layout.vars.join_btn 
	join_btn:onTouchEvent(self,self.onJoin)
	self.add_dine_point = self._layout.vars.add_dine_point 
	self._layout.vars.desc:setText(i3k_get_string(5493))
end

function wnd_faction_dine_tips:onShow()
	
end

function wnd_faction_dine_tips:refresh()
	self:updateAddPoint()
end 

function wnd_faction_dine_tips:updateAddPoint()
	self.add_dine_point:setVisible(g_i3k_game_context:GetFactionDinePoint() > 0)
end 

function wnd_faction_dine_tips:onStart(sender,eventType)
	if eventType == ccui.TouchEventType.ended then
		
		local serverTime = i3k_game_get_time()
		serverTime = i3k_integer(serverTime) - g_i3k_game_context:getOffsetTime() * 3600
		local Y = os.date("%Y",serverTime)
		local M = os.date("%m",serverTime)
		local D = os.date("%d",serverTime) 
		
		local openTime = i3k_db_common.faction.dineOpenTime
		local endTime = i3k_db_common.faction.dineEndTime
	
		local h = string.sub(openTime,1,2)
		local m = string.sub(openTime,4,5)
		local s = string.sub(openTime,7,8)
		local _openTime = os.time{year = Y,month = M,day = D,hour = h,min = m,sec = s}
		
		local _h = string.sub(endTime,1,2)
		local _m = string.sub(endTime,4,5)
		local _s = string.sub(endTime,7,8)
		local _endTime = os.time{year = Y,month = M,day = D,hour = _h,min = _m,sec = _s}
		
		if serverTime < _openTime or serverTime > _endTime then
			g_i3k_ui_mgr:PopupTipMessage("不在宴席开启时间，不可开启")
			return 
		end
		g_i3k_ui_mgr:OpenUI(eUIID_FactionDine)
		g_i3k_ui_mgr:RefreshUI(eUIID_FactionDine)
		g_i3k_ui_mgr:CloseUI(eUIID_FactionDineTips)
	end
end

function wnd_faction_dine_tips:onJoin(sender,eventType)
	if eventType == ccui.TouchEventType.ended then
		local serverTime = i3k_game_get_time()
		serverTime = i3k_integer(serverTime) - g_i3k_game_context:getOffsetTime() * 3600
		local data = i3k_sbean.sect_listbanquet_req.new()
		i3k_game_send_str_cmd(data,i3k_sbean.sect_listbanquet_res.getName())
	end
end

--[[function wnd_faction_dine_tips:onClose(sender,eventType)
	if eventType == ccui.TouchEventType.ended then
		g_i3k_ui_mgr:CloseUI(eUIID_FactionDineTips)
	end
end--]]

function wnd_create(layout, ...)
	local wnd = wnd_faction_dine_tips.new();
		wnd:create(layout, ...);

	return wnd;
end

