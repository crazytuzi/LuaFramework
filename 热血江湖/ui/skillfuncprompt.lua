module(..., package.seeall)
local require = require;
local ui = require("ui/base");
-------------------------------------------------------
wnd_skillfuncPrompt = i3k_class("wnd_skillfuncPrompt", ui.wnd_base)

function wnd_skillfuncPrompt:ctor()
	
end

function wnd_skillfuncPrompt:configure()
	local widgets = self._layout.vars
	self._layout.vars.okBtn:onClick(self, self.onCloseUI)
end

function wnd_skillfuncPrompt:refresh(id)
	self:InitUI(id)
end

function wnd_skillfuncPrompt:InitUI(id)
	local info = i3k_db_skills[id]
	local icon = i3k_db_icons[info.icon]
	local widgets = self._layout.vars

	widgets.percentLabel:setText(info.name)--技能名称
	widgets.descLabel:setText(info.desc)--技能描述
	widgets.skill2_bg:setImage(g_i3k_db.i3k_db_get_icon_path(info.icon))
	self:onOpenUI()
end


function wnd_skillfuncPrompt:onOpenUI()
	--g_i3k_game_context:setFuncOpenTime(i3k_game_get_time())--os.time())
	self._layout.anis.c_dakai.play()
end

--[[function wnd_skillfuncPrompt:onCloseUI(sender)
	
	g_i3k_ui_mgr:CloseUI(eUIID_SkillFuncPrompt)
end--]]


function wnd_create(layout)
	local wnd = wnd_skillfuncPrompt.new();
		wnd:create(layout);
	return wnd;
end
