local QSBAction = import(".QSBAction")
local QSBPlayGodSkillAnimation = class("QSBPlayGodSkillAnimation", QSBAction)

function QSBPlayGodSkillAnimation:_execute(dt)
	local actor = self._skill:getDamager() or self._attacker
	if not IsServerSide then 
        if self._options.is_god_arm then
            app.scene:playGodArmAnimation(actor, self._skill, self._options.is_ss)
        else
    		app.scene:playGodSkillAnimation(actor, self._skill)
        end
	end
	self:finished()
end

return QSBPlayGodSkillAnimation