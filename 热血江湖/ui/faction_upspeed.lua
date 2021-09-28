-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------
wnd_faction_upspeed = i3k_class("wnd_faction_upspeed", ui.wnd_base)

local ingot_root = nil
local time_root = nil

function wnd_faction_upspeed:ctor()
	
end

function wnd_faction_upspeed:configure(...)
	local cancel_btn = self._layout.vars.cancel_btn 
	cancel_btn:onTouchEvent(self,self.onCancel)
	local ok_btn = self._layout.vars.ok_btn 
	ok_btn:onTouchEvent(self,self.onOK)
	self.ingot_label = self._layout.vars.ingot_label 
	time_root = self._layout.vars.show_time 
	local suo_icon = self._layout.vars.suo_icon 
	suo_icon:hide()
end

function wnd_faction_upspeed:onShow()
	
end

function wnd_faction_upspeed:refresh()
	self:updateBaseData(g_i3k_game_context:GetFactionLevel(),g_i3k_game_context:GetFactionUpGradeTime())
end 

function wnd_faction_upspeed:updateBaseData(level,lastTime)
	local need_ingot = i3k_db_faction_uplvl[level + 1].consumeIngot
	local serverTime = i3k_game_get_time()
	serverTime = i3k_integer(serverTime)
	local needTime = i3k_db_faction_uplvl[level + 1].upTime
	local needIngot = i3k_db_faction_uplvl[level + 1].consumeIngot
	
	local show_time = needTime - (serverTime - lastTime)
	if show_time <= 0 then
		show_time = 0
	end
	local count = show_time * needIngot/10000
	
	count = math.ceil(count)
	ingot_root = self.ingot_label
	self.ingot_label:setText(count)

	time_root:setText(self:getTimeStr(show_time))
	self._timer = i3k_game_timer_upspeed.new()
	self._timer:onTest()
end 

function wnd_faction_upspeed:getTimeStr(show_time)
	local d = math.modf(show_time/(3600*24))
	
	local h = math.modf((show_time - d* 3600*24)/3600)
	local m = math.modf((show_time - h*3600)/60)
	if string.len(h) == 1 then
		h = string.format("%s%s",0,h)
	end
	if string.len(m) == 1 then
		m = string.format("%s%s",0,m)
	end
	
	return string.format("%s天%s时%s分",d,h,m)
end 

function wnd_faction_upspeed:SetTime(level,lastTime)
	local serverTime = i3k_game_get_time()
	serverTime = i3k_integer(serverTime)
	local needTime = i3k_db_faction_uplvl[level + 1].upTime
	local needIngot = i3k_db_faction_uplvl[level + 1].consumeIngot
	
	local show_time = needTime - (serverTime - lastTime)
	if show_time <= 0 then
		show_time = 0
	end
	local count = show_time * needIngot /10000
	
	count = math.ceil(count)
	ingot_root:setText(count)
	time_root:setText(self:getTimeStr(show_time))
end

function wnd_faction_upspeed:onCancel(sender,eventType)
	if eventType == ccui.TouchEventType.ended then
		g_i3k_ui_mgr:CloseUI(eUIID_FactionUpSpeed)
	end
end

function wnd_faction_upspeed:onOK(sender,eventType)
	if eventType == ccui.TouchEventType.ended then
		local lastTime = g_i3k_game_context:GetFactionUpGradeTime()
		local level = g_i3k_game_context:GetFactionLevel()
		local need_ingot = i3k_db_faction_uplvl[level + 1].consumeIngot
		local serverTime = i3k_game_get_time()
		serverTime = i3k_integer(serverTime)
		local needTime = i3k_db_faction_uplvl[level + 1].upTime
		local needIngot = i3k_db_faction_uplvl[level + 1].consumeIngot

		local show_time = needTime - (serverTime - lastTime)
		if show_time <= 0 then
			show_time = 0
		end
		local need_money = math.ceil(needIngot * show_time/10000)
		
		local fun = (function(ok) 
				if ok then
					local have_count = g_i3k_game_context:GetDiamond(true)
					if need_money > have_count then
						g_i3k_ui_mgr:PopupTipMessage("元宝不足无法加速")
						return 
					end
					
					local data = i3k_sbean.sect_accelerate_req.new()
					data.accTime = show_time
					i3k_game_send_str_cmd(data,i3k_sbean.sect_accelerate_res.getName())
				end 
			end)
	
		local desc = i3k_get_string(10033,need_money)
			
		
		g_i3k_ui_mgr:ShowMessageBox2(desc,fun)
		
		g_i3k_ui_mgr:CloseUI(eUIID_FactionUpSpeed)
		
		
	end
end

function wnd_faction_upspeed:onHide()
	self._timer:CancelTimer()
end 

function wnd_faction_upspeed:onClose(sender,eventType)
	if eventType == ccui.TouchEventType.ended then
		g_i3k_ui_mgr:CloseUI(eUIID_FactionUpSpeed)
	end
end

function wnd_create(layout, ...)
	local wnd = wnd_faction_upspeed.new();
		wnd:create(layout, ...);

	return wnd;
end

local TIMER = require("i3k_timer");
i3k_game_timer_upspeed = i3k_class("i3k_game_timer_upspeed", TIMER.i3k_timer);

function i3k_game_timer_upspeed:Do(args)
	
	g_i3k_ui_mgr:InvokeUIFunction(eUIID_FactionUpSpeed,"SetTime",g_i3k_game_context:GetFactionLevel(),g_i3k_game_context:GetFactionUpGradeTime())
end

function i3k_game_timer_upspeed:onTest()
	local logic = i3k_game_get_logic()
	if logic then
		self._timer = logic:RegisterTimer(i3k_game_timer_upspeed.new(1000));

	end
end

function i3k_game_timer_upspeed:CancelTimer()
	local logic = i3k_game_get_logic();
	if logic and self._timer then
		logic:UnregisterTimer(self._timer);
	end
end
