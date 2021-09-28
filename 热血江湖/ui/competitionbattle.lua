-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------
wnd_competitionBattle = i3k_class("wnd_competitionBattle", ui.wnd_base)

function wnd_competitionBattle:ctor()
	self._life = i3k_db_dual_meet.battleCfg.resurgenceTimes + 1
end

function wnd_competitionBattle:configure()
	self._layout.vars.record:onClick(self, self.onRecodBt)
end

function wnd_competitionBattle:refresh(info)
	local widgets = self._layout.vars
	local roleId = g_i3k_game_context:GetRoleId()
	--self.guard:		bool	
	--self.guardNumber:		int32	
	--self.teams:		vector[CompetitionTeamOverview]	

	if info then
		if info.guard then
			widgets.life:setVisible(false)
		else
			for i, v in ipairs(info.teams) do
				for k, j in ipairs(v.ranks) do
					if j.id == roleId then
						self._life = self._life - j.deadTotal
						break
					end
				end
			end
			widgets.life:setVisible(true)
			widgets.lifeNum:setText(self._life)
		end
		
		widgets.blueScore:setText(info.teams[g_COMPETITION_BLUE].scoreTotal)
		widgets.redScore:setText(info.teams[g_COMPETITION_RED].scoreTotal)
	end
end

function wnd_competitionBattle:onRecodBt()
	i3k_sbean.competition_record_query()
end

function wnd_competitionBattle:refreshGuard()
	self._layout.vars.life:setVisible(false)
end

function wnd_competitionBattle:refreshScore(info)
	local wid = self._layout.vars
	if info.force == g_COMPETITION_BLUE then
		wid.blueScore:setText(info.scoreTotal)
	else
		wid.redScore:setText(info.scoreTotal)
	end
end

function wnd_competitionBattle:onDead()
	local widgets = self._layout.vars
	self._life = self._life > 1 and self._life - 1 or 0
	widgets.lifeNum:setText(self._life)
	if self._life == 0 then
		widgets.life:setVisible(false)
	end
end

function wnd_create(layout)
	local wnd = wnd_competitionBattle.new()
	wnd:create(layout)
	return wnd
end
