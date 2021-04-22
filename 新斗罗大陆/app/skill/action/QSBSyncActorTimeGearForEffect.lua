-- **************************************************
-- Author               : wanghai
-- FileName             : QSBSyncActorTimeGearForEffect.lua
-- Description          : 
-- Create time          : 2019-12-13 12:31
-- Last modified        : 2019-12-13 12:31
-- **************************************************


local QSBAction = import(".QSBAction")
local QSBSyncActorTimeGearForEffect = class("QSBSyncActorTimeGearForEffect", QSBAction)

function QSBSyncActorTimeGearForEffect:_execute(dt)
    if IsServerSide then
        self:finished()
        return
    end

    local view = app.scene:getActorViewFromModel(self._attacker)
    local scale = view:getSkeletonActor():getAnimationScale()
    view:setAnimationScale(scale, "bullet_time")

    self:finished()
end

return QSBSyncActorTimeGearForEffect
