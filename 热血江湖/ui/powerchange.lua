-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");
-------------------------------------------------------
powerchange = i3k_class("powerchange",ui.wnd_base)
function powerchange:ctor()
	self._poptick = 0
	self._base = 0
	self._target = 0
	self._pathnumber = {}
end

function powerchange:refresh(value1,value2)
	self._poptick = 0
	self._base = value1
	self._target = value1 + value2
	
	local text = ""
	if value2 > 0 then
		self.powericon:setImage(g_i3k_db.i3k_db_get_icon_path(174))
		--self.tipWord:setTextColor("FFA1FF26")
		self.changeWord:setTextColor("FFA1FF26")
		self.changeWord:setText("+"..value2)
	else
		self.powericon:setImage(g_i3k_db.i3k_db_get_icon_path(175))
		--self.tipWord:setTextColor("FFED2122")
		self.changeWord:setTextColor("FFED2122")
		self.changeWord:setText(value2)
	end
	self.tipWord:setText(value1)
end

function powerchange:configure(...)
	self.screenSize = cc.Director:getInstance():getWinSize();
	self.frameSize = cc.Director:getInstance():getOpenGLView():getFrameSize()
	local rootSize = self._layout.root:getContentSize();
	local widget = self._layout.vars
	self.tipWord = widget.tipWord
	self.changeWord = widget.changeWord
	self.powericon = widget.powericon
	self.powerpanel = widget.powerpanel
end

function powerchange:onUpdate(dTime)
	self._poptick = self._poptick + dTime;
	if self._poptick < 1 then
		local text = self._base + math.floor((self._target - self._base)*self._poptick)
		self.tipWord:setText(text)
	elseif self._poptick >= 1 and self._poptick < 2 then
		self.tipWord:setText(self._target)
	elseif self._poptick > 2 then
		g_i3k_ui_mgr:CloseUI(eUIID_PowerChange)
	end
end

function powerchange:onClose()
	g_i3k_ui_mgr:CloseUI(eUIID_PowerChange)
end

function powerchange:onShow()

end

function powerchange:onHide()

end

function wnd_create(layout, ...)
	local wnd = powerchange.new()
	wnd:create(layout, ...)
	return wnd
end
