module(..., package.seeall)

local require = require;

local ui = require("ui/base");

local wnd_feishengRMQ = i3k_class("wnd_feishengRMQ", ui.wnd_base)
function wnd_feishengRMQ:ctor()
	
end

function wnd_feishengRMQ:configure()
	self.ui = self._layout.vars
	self.ui.close:onClick(self, self.onCloseUI)
end

function wnd_feishengRMQ:refresh(msg, needDiamond, cb)
	self.ui.desc:setText(msg)
	self.ui.count:setText('x'..tostring(needDiamond))
	self.ui.ok:onClick(self, function()
		cb(true)
		self:onCloseUI()
	end)
	
	self.ui.go:onClick(self, function()
		cb(false)
		self:onCloseUI()
	end)
end


function wnd_create(layout)
	local wnd = wnd_feishengRMQ.new()
	wnd:create(layout)
	return wnd
end