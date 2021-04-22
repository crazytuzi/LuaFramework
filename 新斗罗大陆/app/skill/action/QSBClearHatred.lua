--[[
    Class name QSBClearHatred
    Create by julian 
--]]

local QSBAction = import(".QSBAction")
local QSBClearHatred = class("QSBClearHatred", QSBAction)

function QSBClearHatred:_execute(dt)
    local actor = self._attacker

    local enemies = app.battle:getMyEnemies(actor)
    for _, enemy in ipairs(enemies) do
        if enemy:getTarget() == actor then
            enemy:getHitLog():clearAll()
            enemy:setTarget(nil)
        end
    end

    self:finished()
end

function QSBClearHatred:_onCancel()

end

return QSBClearHatred