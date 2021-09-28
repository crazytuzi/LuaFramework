-- ShakeEntry

local ShakeEntry = class("ShakeEntry", require "app.scenes.battle.entry.Entry")

function ShakeEntry:ctor(totalFrame, strengthX, strengthY, battleField)
    self._totalFrame = totalFrame
    self._strengthX = strengthX
    self._strengthY = strengthY
    ShakeEntry.super.ctor(self, nil, nil, battleField)
end

function ShakeEntry:initEntry()
    ShakeEntry.super.initEntry(self)
    
    if self._shakeAction then
        self._shakeAction:stop()
        self._shakeAction:release()
    end
    
    local ActionFactory = require "app.common.action.Action"
    self._shakeAction = ActionFactory.newShake(self._totalFrame, self._strengthX, self._strengthY)
    
    self._shakeAction:retain()
    self._shakeAction:startWithTarget(self._battleField)
    
    self:addEntryToQueue(self, self._update)
end

function ShakeEntry:_update(frameIndex)
    
    if self._shakeAction then
        self._shakeAction:step(1)
    end
    
    if self._shakeAction:isDone() then
        self._shakeAction:stop()
        return true
    end
    
    return false
    
end

function ShakeEntry:destroyEntry()
    ShakeEntry.super.destroyEntry(self)
    if self._shakeAction then
        self._shakeAction:stop()
        self._shakeAction:release()
    end
end

return ShakeEntry

