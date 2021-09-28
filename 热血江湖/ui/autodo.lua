module(..., package.seeall)
local require = require;
local ui = require("ui/base");
-------------------------------------------------------
wnd_autoDo = i3k_class("wnd_autoDo", ui.wnd_base)

function wnd_autoDo:ctor()
	self._callBack = nil
	self._actionTime = 0
	self._mineactiontime = 0
	self._activeFlag = true
end

function wnd_autoDo:configure()
	local widget = self._layout.vars
	self._loadingbar = widget.Digloadingbar
end

function wnd_autoDo:refresh(cancel)
	local time = g_i3k_game_context:getAutoTime()
	time = time or 0
	self._actionTime = time == 0 and 1 or time
	self._callBack = g_i3k_game_context:getAutoCallBack()
	self:onShowTransUI(cancel)
end

function wnd_autoDo:onUpdate(dTime)
	if self._activeFlag then
		self:onUpdateTrans(dTime)
	end
end

function wnd_autoDo:onShowTransUI(cancel)
	local widget = self._layout.vars
	
	if not cancel then
		widget.Digcancel:hide()
	else
		widget.Digcancel:onClick(self, self.onCancelClick)
	end
	
	widget.Digtipstext:setText(g_i3k_game_context:getAutoTxt())
end

function wnd_autoDo:onUpdateTrans(dTime)
	self._mineactiontime = self._mineactiontime + dTime * 1000
		
	if self._mineactiontime < self._actionTime then
		self._loadingbar:setPercent((self._mineactiontime / self._actionTime) * 100)
	else
		self._loadingbar:setPercent(100)
		local fun = self._callBack

		if fun then
			fun()
		end
		
		self:complete()
	end
end

function wnd_autoDo:complete()
	self._activeFlag = false
	local widget = self._layout.vars
	widget.DigingPanel:hide()
	widget.Digloadingbar:setPercent(0)
	self._mineactiontime = 0
end

function wnd_autoDo:revert()
	self._activeFlag = true
	self._layout.vars.DigingPanel:show()
end

function wnd_autoDo:onCancelClick(sender)
	g_i3k_game_context:stopDoWork()
end


function wnd_create(layout)
	local wnd = wnd_autoDo.new();
	wnd:create(layout);
	return wnd;
end
