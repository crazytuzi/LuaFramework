--[[
    Class name QSBImmuneCharge
    Create by julian 
--]]

local QSBAction = import(".QSBAction")
local QSBImmuneCharge = class("QSBGhost", QSBAction)

function QSBImmuneCharge:_execute(dt)
    local actor = self._attacker

    if not IsServerSide then
        local view = app.scene:getActorViewFromModel(actor)
        if self._options.enter then
            view:setVisible(false)
        else
            view:setVisible(true)
        end
    end

    self:finished()
end

function QSBImmuneCharge:_onCancel()
    self:_onRevert()
end

function QSBImmuneCharge:_onRevert()
    local actor = self._attacker
    actor._immune_charge = false
    if not IsServerSide then
        local view = app.scene:getActorViewFromModel(actor)
        view:setVisible(true)
    end
end

return QSBImmuneCharge