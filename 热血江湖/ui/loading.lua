-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------
wnd_loading = i3k_class("wnd_loading", ui.wnd_base)

local _TIME = 0
local _TIPS_LABEL = nil 
local TIME_SPACE = 3 --三秒刷新loading图

function wnd_loading:ctor()
	self._time = 0
	self._timer = nil 
	self._recordTime = 0 --记录时间
end

function wnd_loading:configure(...)
	self._loadProg = self._layout.vars.loadProg;
	self._loadInfo = self._layout.vars.loadInfo;
	self.bg_icon = self._layout.vars.bg_icon 
	self.big_bg_icon = self._layout.vars.big_bg_icon 
	self.perLabel = self._layout.vars.perLabel 
	_TIPS_LABEL = self._layout.vars.loadInfo
	
	--将loadingBar的位置动画绑定到loadingBar本身
	self._loadProg:setHeadAnis(self._layout.vars.loadChild)
end

function wnd_loading:onShow()
	self:updateLoadProg(0);
	
	self:updateLoadInfo(g_i3k_game_context:GetLoadingTips())
	local iconid,bigIconid = g_i3k_game_context:GetLoadingIcon()
	self:updateLoadIcon(iconid,bigIconid)
	
	self._timer = i3k_game_timer_loading.new()
	self._timer:onTest()
	g_i3k_ui_mgr:CloseUI(eUIID_RollNotice)
	self._recordTime = i3k_game_get_time()
end

function wnd_loading:onUpdate(dTime)
	if i3k_game_get_time() - self._recordTime >  TIME_SPACE then
		local _, bigIconid = g_i3k_game_context:GetLoadingFromMapID()
		if bigIconid then
			self:updateLoadIcon(iconid,bigIconid)
		end
		self._recordTime = i3k_game_get_time()
	end
end

function wnd_loading:refresh()

end 


function wnd_loading:updateLoadProg(prog)
	self._loadProg:setPercent(prog);
	local tmp_str = string.format("%s%%",prog)
	self.perLabel:setText(tmp_str)
	
end

function wnd_loading.updateTipsByTime()
	_TIME = _TIME + 1
	if _TIME >= i3k_db_loading_first.loading_time.value then
		_TIME = 0
		_TIPS_LABEL:setText(g_i3k_game_context:GetLoadingTips())
	end
end 

function wnd_loading:updateLoadInfo(info)
	self._loadInfo:setText(info);
end

function wnd_loading:updateLoadIcon(icon,bigIcon)
	--self.bg_icon:setImage(g_i3k_db.i3k_db_get_icon_path(icon))
	self.big_bg_icon:setImage(g_i3k_db.i3k_db_get_icon_path(bigIcon))
end 

function wnd_loading:onHide()
	self._timer:CancelTimer()
end 


function wnd_create(layout, ...)
	local wnd = wnd_loading.new()
		wnd:create(layout, ...)

	return wnd
end

local TIMER = require("i3k_timer");
i3k_game_timer_loading = i3k_class("i3k_game_timer_loading", TIMER.i3k_timer);

function i3k_game_timer_loading:Do(args)
	g_i3k_ui_mgr:InvokeUIFunction(eUIID_Loading,"updateTipsByTime")
end

function i3k_game_timer_loading:onTest()
	local logic = i3k_game_get_logic()
	if logic then
		self._timer = logic:RegisterTimer(i3k_game_timer_loading.new(1000));

	end
end

function i3k_game_timer_loading:CancelTimer()
	local logic = i3k_game_get_logic();
	if logic and self._timer then
		logic:UnregisterTimer(self._timer);
	end
end

