-- **************************************************
-- Author               : wanghai
-- FileName             : QSBShowStorage.lua
-- Description          : 
-- Create time          : 2019-12-05 16:26
-- Last modified        : 2019-12-05 16:26
-- **************************************************

local QSBAction = import(".QSBAction")
local QSBShowStorage = class("QSBShowStorage", QSBAction)

function QSBShowStorage:_execute(dt)
    if IsServerSide then self:finished() return end
    


    local actor = self._attacker
    if self._options.is_target == true then
        actor = self._target
    end

    local view = app.scene:getActorViewFromModel(actor)
    if view == nil then
        self:finished()
        return
    end

    
    if self._options.enter == true then
        view:showStorage(self._options.limit, self._options.offset, self._options.scale, self._options.buff_id)
    elseif self._options.exit == true then
        view:hideStorage()
    end

    self:finished()

    return
end

function QSBShowStorage:_onCancel()
    self:_onRevert()
end

function QSBShowStorage:_onRevert()
    if IsServerSide then return end

    local actor = self._attacker
    if self._options.is_target == true then
        actor = self._target
    end

    local view = app.scene:getActorViewFromModel(actor)
    if view == nil then
        self:finished()
        return
    end

    view:hideStorage()
end

return QSBShowStorage

