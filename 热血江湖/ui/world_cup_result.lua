------------------------------------------------------
module(...,package.seeall)

local require = require

local ui = require('ui/base')
------------------------------------------------------
wnd_world_cup_result = i3k_class("wnd_world_cup_result",ui.wnd_base)

local des2 = {	1416, 1417, 1418}

function wnd_world_cup_result:configure()
	self._layout.vars.close:onClick(self,self.onCloseUI)
end

function wnd_world_cup_result:refresh(countryId)
	if not countryId then return; end
	local info = g_i3k_game_context:getWorldCupCountry(countryId)
	local cfg
	for i = 1,#i3k_db_world_cup_wager do
		if i3k_db_world_cup_wager[i].rank == info.record then
			cfg = i3k_db_world_cup_wager[i]
			break
		end
	end
	local widgets = self._layout.vars
	widgets.country:setText(string.format(i3k_db_string[1409], i3k_db_world_cup_team[countryId].name))
	widgets.des:setText(string.format(i3k_db_string[1419], i3k_db_world_cup_other.wagerCoin,i3k_db_world_cup_team[countryId].name,cfg.des))
	widgets.rank:setText(cfg.des)
	widgets.date:setText(cfg.data)
	widgets.coin:setText('x'..cfg.reward)
	widgets.des2:setText(i3k_db_string[des2[info.guessInfo + 1]])
end
---------------------------------------------------------
function wnd_create(layout,...)
	local wnd = wnd_world_cup_result.new()
	wnd:create(layout,...)
	return wnd
end