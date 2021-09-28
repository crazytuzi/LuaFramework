module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------
pk_attacked_tooltip = i3k_class("pk_attacked_tooltip", ui.wnd_base)

function pk_attacked_tooltip:ctor()
	
end

function pk_attacked_tooltip:configure()
	local widgets = self._layout.vars
	widgets.attackBtn:onClick(self,self.OnAttack);
end

function pk_attacked_tooltip:OnAttack()
	local hero = i3k_game_get_player_hero();
	if hero then
		if hero._PVPStatus ~= g_GoodAvilMode then
			i3k_sbean.set_attackmode(g_GoodAvilMode)---2:善恶
		end
	end
end

function pk_attacked_tooltip:refresh()
	
end

function wnd_create(layout)
	local wnd = pk_attacked_tooltip.new();
		wnd:create(layout);
	return wnd;
end
