module(..., package.seeall)
local require = require;
local ui = require("ui/base");

-------------------------------------------------------
wnd_worldLineProcessBar = i3k_class("wnd_worldLineProcessBar", ui.wnd_base)

local CHANGE_LINE_TIME = i3k_db_common.change_line.changeLineTime
function wnd_worldLineProcessBar:ctor()
end

function wnd_worldLineProcessBar:configure()
	self._recordTime = 0 --计时
	self._layout.vars.Digcancel:onClick(self, self.onCloseUI)
end

function wnd_worldLineProcessBar:refresh(callback, line)
	self._line = line
	self._callBack = callback
	self._layout.vars.DigingPanel:show()
	self._layout.vars.Digtipstext:setText("切换中... ...")
end

function wnd_worldLineProcessBar:onUpdate(dTime)
	self._recordTime = self._recordTime + dTime
	if self._recordTime < CHANGE_LINE_TIME then
		self._layout.vars.Digloadingbar:setPercent(self._recordTime / CHANGE_LINE_TIME * 100)
		else
		self._layout.vars.Digloadingbar:setPercent(100)
			self._layout.vars.Digcancel:hide()
		if self._line then
			i3k_sbean.change_worldline(self._line)
		end
		if self._callBack then
			self._callBack()
	end
		self:onCloseUI()
end

end

function wnd_create(layout)
	local wnd = wnd_worldLineProcessBar.new();
		wnd:create(layout);
	return wnd;
end
