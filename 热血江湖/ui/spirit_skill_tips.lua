-------------------------------------------------------
module(..., package.seeall)
local require = require;

local ui = require("ui/base");

-------------------------------------------------------
wnd_spirit_skill_tips = i3k_class("wnd_spirit_skill_tips", ui.wnd_base)

function wnd_spirit_skill_tips:ctor()
end

function wnd_spirit_skill_tips:configure()
	local ok = self._layout.vars.ok
	ok:onClick(self, self.onCloseUI)


end

function wnd_spirit_skill_tips:onShow()
end

function wnd_spirit_skill_tips:onHide()
end


function wnd_spirit_skill_tips:refresh(msgText)
	local desc = self._layout.vars.desc
	desc:setText(msgText.desc)
	local name = self._layout.vars.name
	name:setText(msgText.name)
	
end

function wnd_spirit_skill_tips:onUpdate(dTime)
end

function wnd_create(layout)
	local wnd = wnd_spirit_skill_tips.new()
	wnd:create(layout)
	return wnd
end
