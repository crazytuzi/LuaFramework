-------------------------------------------------------
module(..., package.seeall)

local require = require

local ui = require("ui/base")

-------------------------------------------------------

wnd_marry_effects = i3k_class("wnd_marry_effects",ui.wnd_base)

function wnd_marry_effects:ctor()
	self.item_id = nil
end

function wnd_marry_effects:configure()
	
end

function wnd_marry_effects:refresh(grade)
	self:playEffect(grade)
end

function wnd_marry_effects:playEffect(grade)
	local effecfWidgetName = {self._layout.anis.c_xin01, self._layout.anis.c_xin2, self._layout.anis.c_xin03}
	effecfWidgetName[grade].play()
	local delay = cc.DelayTime:create(15)
	local seq =	cc.Sequence:create(delay, cc.CallFunc:create(function ()
		effecfWidgetName[grade].stop()
	end))
	self:runAction(seq)
end

function wnd_create(layout)
	local wnd = wnd_marry_effects.new()
	wnd:create(layout)
	return wnd
end
