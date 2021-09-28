-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------
wnd_fightTeamList = i3k_class("wnd_fightTeamList", ui.wnd_base)

function wnd_fightTeamList:ctor()

end

function wnd_fightTeamList:configure(...)

end

function wnd_fightTeamList:refresh(callbacks)
	self:setScroll(callbacks)
end

function wnd_fightTeamList:setScroll(callbacks)
    local widgets = self._layout.vars
    local scroll = widgets.scroll
	scroll:removeAllChildren()
	local children = scroll:addChildWithCount("ui/widgets/wudaohuifzt", 1, #i3k_db_fightTeam_group_name)
	for i, v in ipairs(children) do
		local db = i3k_db_fightTeam_group_name
		v.vars.btn:onClick(nil, callbacks[i])
		v.vars.label:setText(db[i].name)
	end

end



function wnd_create(layout, ...)
	local wnd = wnd_fightTeamList.new();
		wnd:create(layout, ...);
	return wnd;
end
