module(...,package.seeall)

local require = require;
local ui = require("ui/base");

wnd_petDungeonEvent = i3k_class("wnd_petDungeonEvent", ui.wnd_base)
local REWARDITEM = "ui/widgets/chongwushilianxysjt"

function wnd_petDungeonEvent:ctor()

end

function wnd_petDungeonEvent:configure()
	self._layout.vars.close_btn:onClick(self, self.onCloseUI)
end

function wnd_petDungeonEvent:refresh()
	local weight = self._layout.vars
	local scoll = weight.scroll

	for k, v in ipairs(i3k_db_PetDungeonEvents) do
		local ui = require(REWARDITEM)()
		local weight = ui.vars
		weight.name:setText(v.name)
		weight.des:setText(v.des)	
		weight.count:setText(g_i3k_game_context:getPetDungeonBuffs(k))
		scoll:addItem(ui)
	end
end

function wnd_create(layout)
	local wnd = wnd_petDungeonEvent.new();
	wnd:create(layout);
	return wnd;
end
