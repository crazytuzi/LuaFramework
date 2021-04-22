--[[
    Class name QSBLaser
    Create by julian 
--]]

local QSBAction = import(".QSBAction")
local QSBLaser = class("QSBLaser", QSBAction)

local QSkill = import("...models.QSkill")
local QLaser = import("...models.QLaser")

function QSBLaser:_execute(dt)
	if self._skill:getBulletEffectID() == nil and self._options.effect_id == nil then
		self:finished()
        return
	end

    -- get targets
    if self._skill:getRangeType() == QSkill.MULTIPLE then
        self._targets = self._attacker:getMultipleTargetWithSkill(self._skill, self._target)
        if #self._targets == 0 then
            self:finished()
            return
        end
    else
        self._targets = {self._target}
    end

    -- create bullet
    local laser = QLaser.new(self._attacker, self._targets, self._skill, self._options)
    app.battle:addLaser(laser)
    self:finished()
end

function QSBLaser:_onCancel()

end

return QSBLaser