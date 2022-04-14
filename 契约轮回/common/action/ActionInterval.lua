--[[
    @author LaoY
    @des    cocos2dx 自带的action放这里
--]]

cc = cc or {}

cc.ExtraAction = cc.ExtraAction or class("ExtraAction", cc.FiniteTimeAction)
function cc.ExtraAction:ctor()

end
function cc.ExtraAction:clone()
    return cc.ExtraAction:new()
end

function cc.ExtraAction:reverse()
    return cc.ExtraAction:new()
end

function cc.ExtraAction:update(time)
end

function cc.ExtraAction:step(dt)
end

cc.ActionInterval = cc.ActionInterval or class("ActionInterval", cc.FiniteTimeAction)

cc.ActionInterval.FLT_EPSILON = 1.192092896e-07

function cc.ActionInterval:ctor()
    self._classType = "ActionInterval"
end

function cc.ActionInterval:getElapsed()
    return self._elapsed
end

function cc.ActionInterval:setAmplitudeRate(amp)
    --Subclass should implement this method!
end

function cc.ActionInterval:getAmplitudeRate()
    --Subclass should implement this method!
    return 0
end

function cc.ActionInterval:isDone()
    return self._elapsed >= self._duration
end

--[[
    @author LaoY
    @des    获取action的进行进度
--]]
function cc.ActionInterval:getProgress()
    if not self._elapsed or not self._duration then
        return 0
    end
    return math.min(self._elapsed / self._duration, 1)
end

function cc.ActionInterval:sendUpdateEventToScript(dt, actionObject)
    return false;
end

function cc.ActionInterval:step(dt)
    if self._firstTick then
        self._firstTick = false
        self._elapsed = 0
    else
        self._elapsed = self._elapsed + dt
    end
    local updateDt = math.max(0, math.min(1, self._elapsed / math.max(self._duration, cc.ActionInterval.FLT_EPSILON)))

    self:update(updateDt)
end

function cc.ActionInterval:startWithTarget(target)
    cc.FiniteTimeAction.startWithTarget(self, self.real_target or target);
    self._originalTarget = target
    self._elapsed = 0
    self._firstTick = true
end

function cc.ActionInterval:reverse()
    print("Cat_Error:ActionInterval.lua [ActionInterval:reverse] should not exec this method!")
    return nil
end

function cc.ActionInterval:clone()
    print("Cat_Error:ActionInterval.lua [ActionInterval:clone] should not exec this method!")
    return nil
end

function cc.ActionInterval:initWithDuration(d, real_target)
    self._duration = d
    if self._duration == 0 then
        self._duration = cc.ActionInterval.FLT_EPSILON
    end
    self.real_target = real_target
    self._elapsed = 0
    self._firstTick = true

    return true
end

--MoveBy start
cc.MoveBy = cc.MoveBy or class("MoveBy", cc.ActionInterval)

function cc.MoveBy:ctor(duration, delta_x, delta_y, delta_z)
    self:initWithDuration(duration, delta_x, delta_y, delta_z)
end

function cc.MoveBy:clone()
    return cc.MoveBy(self._duration, self._positionDeltaX, self._positionDeltaY, self._positionDeltaZ)
end

function cc.MoveBy:reverse()
    return cc.MoveBy(self._duration, self._positionDeltaX and -self._positionDeltaX, self._positionDeltaY and -self._positionDeltaY, self._positionDeltaZ and -self._positionDeltaZ)
end

function cc.MoveBy:startWithTarget(target)
    cc.ActionInterval.startWithTarget(self, target)
    local x, y, z
    if type(target) ~= "userdata" and target.GetPosition then
        x, y, z = target:GetPosition()
        if type(x) == "table" then
            x, y, z = x.x, x.y, x.z
        end
    else
        x, y, z = cc.Wrapper.GetLocalPosition(target)
    end
    if type(target) ~= "userdata" and target.SetPosition then
        self.is_use_lua_function = true
    end
    self._previousPositionX, self._previousPositionY, self._previousPositionZ = x, y, z
    self._startPositionX, self._startPositionY, self._startPositionZ = self._previousPositionX, self._previousPositionY, self._previousPositionZ
end

function cc.MoveBy:update(t)
    if self._target then
        -- local currentPosX, currentPosY, currentPosZ = cc.Wrapper.GetLocalPosition(self._target)
        if self._positionDeltaX and self._positionDeltaX ~= 0 then
            self._previousPositionX = self._startPositionX + (self._positionDeltaX * t)
        end
        if self._positionDeltaY and self._positionDeltaY ~= 0 then
            self._previousPositionY = self._startPositionY + (self._positionDeltaY * t)
        end
        if self._positionDeltaZ and self._positionDeltaZ ~= 0 then
            self._previousPositionZ = self._startPositionZ + (self._positionDeltaZ * t)
        end
        if self.is_use_lua_function then
            self._target:SetPosition(self._previousPositionX, self._previousPositionY, self._previousPositionZ)
        else
            cc.Wrapper.SetLocalPosition(self._target, self._previousPositionX, self._previousPositionY, self._previousPositionZ)
        end
        -- self._target:Translate(Vector3.right * 2 * Time.deltaTime)
        -- Translate(self._target,-1,0,0,2)
    end
end

function cc.MoveBy:initWithDuration(duration, delta_x, delta_y, delta_z)
    cc.ActionInterval.initWithDuration(self, duration)
    self._positionDeltaX = delta_x
    self._positionDeltaY = delta_y
    self._positionDeltaZ = delta_z
end

--MoveBy end

--MoveTo start
cc.MoveTo = cc.MoveTo or class("MoveTo", cc.MoveBy)
function cc.MoveTo:ctor(duration, x, y, z)
    self:initWithPos(duration, x, y, z)
end

function cc.MoveTo:initWithPos(duration, x, y, z)
    cc.ActionInterval.initWithDuration(self, duration)
    if AppConfig.Debug and (not x or not y) then
        Yzprint('--LaoY ActionInterval.lua,line 180--', data)
        traceback()
    end
    self._endPositionX = x
    self._endPositionY = y
    self._endPositionZ = z
end

function cc.MoveTo:clone()
    return cc.MoveTo:new(self._duration, self._endPositionX, self._endPositionY, self._endPositionZ)
end

function cc.MoveTo:startWithTarget(target)
    cc.MoveBy.startWithTarget(self, target)
    local oldX, oldY, oldZ
    if type(target) ~= "userdata" and target.GetPosition then
        oldX, oldY, oldZ = target:GetPosition()
        if type(oldX) == "table" then
            oldX, oldY, oldZ = oldX.x, oldX.y, oldX.z
        end
    else
        oldX, oldY, oldZ = cc.Wrapper.GetLocalPosition(target)
    end
    self._positionDeltaX = self._endPositionX - oldX
    self._positionDeltaY = self._endPositionY - oldY
    if self._endPositionZ then
        self._positionDeltaZ = self._endPositionZ - oldZ
    else
        self._positionDeltaZ = 0
    end
end

function cc.MoveTo:reverse()
    print("reverse() not supported in MoveTo")
    return nil
end
--MoveTo end


----GlobalMoveBy start
cc.GlobalMoveBy = cc.GlobalMoveBy or class("GlobalMoveBy", cc.ActionInterval)

function cc.GlobalMoveBy:ctor(duration, delta_x, delta_y, delta_z)
    self:initWithDuration(duration, delta_x, delta_y, delta_z)
end

function cc.GlobalMoveBy:clone()
    return cc.GlobalMoveBy(self._duration, self._positionDeltaX, self._positionDeltaY, self._positionDeltaZ)
end

function cc.GlobalMoveBy:reverse()
    return cc.GlobalMoveBy(self._duration, self._positionDeltaX and -self._positionDeltaX, self._positionDeltaY and -self._positionDeltaY, self._positionDeltaZ and -self._positionDeltaZ)
end

function cc.GlobalMoveBy:startWithTarget(target)
    cc.ActionInterval.startWithTarget(self, target)
    local x, y, z
    if type(target) ~= "userdata" and target.GetPosition then
        x, y, z = target:GetPosition()
        if type(x) == "table" then
            x, y, z = x.x, x.y, x.z
        end
    else
        x, y, z = cc.Wrapper.GetGlobalPosition(target)
    end
    if type(target) ~= "userdata" and target.GetPosition then
        self.is_use_lua_function = true
    end
    self._previousPositionX, self._previousPositionY, self._previousPositionZ = x, y, z
    self._startPositionX, self._startPositionY, self._startPositionZ = self._previousPositionX, self._previousPositionY, self._previousPositionZ
end

function cc.GlobalMoveBy:update(t)
    if self._target then
        -- local currentPosX, currentPosY, currentPosZ = cc.Wrapper.GetLocalPosition(self._target)
        if self._positionDeltaX and self._positionDeltaX ~= 0 then
            self._previousPositionX = self._startPositionX + (self._positionDeltaX * t)
        end
        if self._positionDeltaY and self._positionDeltaY ~= 0 then
            self._previousPositionY = self._startPositionY + (self._positionDeltaY * t)
        end
        if self._positionDeltaZ and self._positionDeltaZ ~= 0 then
            self._previousPositionZ = self._startPositionZ + (self._positionDeltaZ * t)
        end
        if self.is_use_lua_function then
            self._target:SetPosition(self._previousPositionX, self._previousPositionY, self._previousPositionZ)
        else
            cc.Wrapper.SetGlobalPosition(self._target, self._previousPositionX, self._previousPositionY, self._previousPositionZ)
        end
        -- self._target:Translate(Vector3.right * 2 * Time.deltaTime)
        -- Translate(self._target,-1,0,0,2)
    end
end

function cc.GlobalMoveBy:initWithDuration(duration, delta_x, delta_y, delta_z)
    cc.ActionInterval.initWithDuration(self, duration)
    self._positionDeltaX = delta_x
    self._positionDeltaY = delta_y
    self._positionDeltaZ = delta_z
end

--GlobalMoveBy end

--GlobalMoveTo start
cc.GlobalMoveTo = cc.GlobalMoveTo or class("GlobalMoveTo", cc.GlobalMoveBy)
function cc.GlobalMoveTo:ctor(duration, x, y, z)
    self:initWithPos(duration, x, y, z)
end

function cc.GlobalMoveTo:initWithPos(duration, x, y, z)
    cc.ActionInterval.initWithDuration(self, duration)
    if AppConfig.Debug and (not x or not y) then
        Yzprint('--LaoY ActionInterval.lua,line 180--', data)
        traceback()
    end
    self._endPositionX = x
    self._endPositionY = y
    self._endPositionZ = z
end

function cc.GlobalMoveTo:clone()
    return cc.GlobalMoveTo:new(self._duration, self._endPositionX, self._endPositionY, self._endPositionZ)
end

function cc.GlobalMoveTo:startWithTarget(target)
    cc.GlobalMoveBy.startWithTarget(self, target)
    local oldX, oldY, oldZ
    if type(target) ~= "userdata" and target.GetGlobalPosition then
        oldX, oldY, oldZ = target:GetPosition()
        if type(oldX) == "table" then
            oldX, oldY, oldZ = oldX.x, oldX.y, oldX.z
        end
    else
        oldX, oldY, oldZ = cc.Wrapper.GetGlobalPosition(target)
    end
    self._positionDeltaX = self._endPositionX - oldX
    self._positionDeltaY = self._endPositionY - oldY
    if self._endPositionZ then
        self._positionDeltaZ = self._endPositionZ - oldZ
    else
        self._positionDeltaZ = 0
    end
end

function cc.GlobalMoveTo:reverse()
    print("reverse() not supported in MoveTo")
    return nil
end
--GlobalMoveTo end

--Sequence start
cc.Sequence = cc.Sequence or class("Sequence", cc.ActionInterval)

function cc.Sequence:ctor(...)
    self._actions = {}
    self:initWithTable({ ... })
end

function cc.Sequence.createWithTwoActions(actionOne, actionTwo)
    local sequence = cc.Sequence:new()
    sequence:initWithTwoActions(actionOne, actionTwo);
    return sequence;
end

function cc.Sequence:initWithTable(actions)
    local count = #actions
    if (count == 0) then
        --进入这里也是正常的
        return
    end

    if (count == 1) then
        return self:initWithTwoActions(actions[1], cc.ExtraAction:new());
    end

    local prev = actions[1]
    for i = 2, #actions - 1 do
        prev = cc.Sequence.createWithTwoActions(prev, actions[i])
    end

    self:initWithTwoActions(prev, actions[count]);
end

function cc.Sequence:initWithTwoActions(actionOne, actionTwo)
    local d = actionOne:getDuration() + actionTwo:getDuration()
    cc.ActionInterval.initWithDuration(self, d)
    self._actions[0] = actionOne
    self._actions[1] = actionTwo
    return true
end

function cc.Sequence:clone()
    local a = cc.Sequence:new()
    a:initWithTwoActions(self._actions[0]:clone(), self._actions[1]:clone())
    return a
end

function cc.Sequence:startWithTarget(target)
    cc.ActionInterval.startWithTarget(self, target)
    self._split = self._actions[0]:getDuration() / self._duration
    self._last = -1
end

function cc.Sequence:stop()
    -- Issue #1305
    if (self._last ~= -1) then
        self._actions[self._last]:stop()
    end

    cc.ActionInterval.stop(self)
end

function cc.Sequence:update(t)
    local found = 0
    local new_t = 0.0

    if (t < self._split) then
        found = 0
        if (self._split ~= 0) then
            new_t = t / self._split
        else
            new_t = 1
        end
    else
        found = 1;
        if (self._split == 1) then
            new_t = 1;
        else
            new_t = (t - self._split) / (1 - self._split);
        end
    end

    if (found == 1) then
        if (self._last == -1) then
            -- action[0] was skipped, execute it.
            self._actions[0]:startWithTarget(self._target);
            self._actions[0]:update(1.0)
            self._actions[0]:stop()
        elseif (self._last == 0) then
            -- switching to action 1. stop action 0.
            self._actions[0]:update(1.0)
            self._actions[0]:stop()
        end
    elseif (found == 0 and self._last == 1) then
        self._actions[1]:update(0);
        self._actions[1]:stop();
    end
    -- Last action found and it is done.
    if (found == self._last and self._actions[found]:isDone()) then
        return
    end

    -- Last action found and it is done
    if (found ~= self._last) then
        self._actions[found]:startWithTarget(self._target);
    end
    self._actions[found]:update(new_t);
    self._last = found;
end

function cc.Sequence:reverse()
    return cc.Sequence.createWithTwoActions(self._actions[1]:reverse(), self._actions[0]:reverse())
end

--Sequence end

--Fade start
cc.FadeTo = cc.FadeTo or class("FadeTo", cc.ActionInterval)

function cc.FadeTo:ctor(duration, opacity, real_target)
    self:initWithDuration(duration, opacity, real_target)
end

function cc.FadeTo:initWithDuration(duration, opacity, real_target)
    cc.ActionInterval.initWithDuration(self, duration, real_target)
    self._toOpacity = opacity;
end

function cc.FadeTo:clone()
    return FadeTo:new(self._duration, self._toOpacity, self.real_target)
end

function cc.FadeTo:reverse()
    print("reverse() not supported in FadeTo");
    return nil;
end

function cc.FadeTo:startWithTarget(target)
    cc.ActionInterval.startWithTarget(self, target);
    self._fromOpacity = cc.Wrapper.GetAlpha(self._target)
end

function cc.FadeTo:update(time)
    if self._target then
        local newOpacity = (self._fromOpacity + (self._toOpacity - self._fromOpacity) * time)
        cc.Wrapper.SetAlpha(self._target, newOpacity)
    end
end

cc.FadeIn = cc.FadeIn or class("FadeIn", cc.FadeTo)

function cc.FadeIn:ctor(d, real_target)
    self:initWithDuration(d, 1.0, real_target);
end

function cc.FadeIn:clone()
    return cc.FadeIn:new(self._duration, self._target)
end

function cc.FadeIn:reverse()
    return cc.FadeOut:new(self._duration, self._target)
end

cc.FadeOut = cc.FadeOut or class("FadeOut", cc.FadeTo)

function cc.FadeOut:ctor(d, real_target)
    self:initWithDuration(d, 0.0, real_target)
end

function cc.FadeOut:clone()
    return cc.FadeOut:new(self._duration, 0.0);
end

function cc.FadeOut:reverse()
    return cc.FadeIn:new(self._duration, self._target)
end

--Fade end

--Rotate start
cc.RotateTo = cc.RotateTo or class("RotateTo", cc.ActionInterval)

function cc.RotateTo:ctor(duration, dstAngle, real_target)
    self.is_3d = type(dstAngle) == "table"
    self._dstAngle = self.is_3d and { x = 0, y = 0, z = 0 } or 0
    self._startAngle = self.is_3d and { x = 0, y = 0, z = 0 } or 0
    self._diffAngle = self.is_3d and { x = 0, y = 0, z = 0 } or 0
    self:initWithDuration(duration, dstAngle, real_target)
end

function cc.RotateTo:initWithDuration(duration, dstAngle, real_target)
    cc.ActionInterval.initWithDuration(self, duration, real_target)
    self._dstAngle = dstAngle
end

function cc.RotateTo:clone()
    return cc.RotateTo:new(self._duration, self._dstAngle, self.real_target)
end

function cc.RotateTo:calculateAngles(startAngle, diffAngle, dstAngle)
    if (startAngle > 0) then
        startAngle = math.fmod(startAngle, 360.0)
    else
        startAngle = math.fmod(startAngle, -360.0)
    end
    diffAngle = dstAngle - startAngle
    if (diffAngle > 180) and diffAngle < 360 then
        diffAngle = diffAngle - 360
    end
    if (diffAngle < -180) and diffAngle > -360 then
        diffAngle = diffAngle + 360
    end
    return startAngle, diffAngle
end

function cc.RotateTo:startWithTarget(target)
    cc.ActionInterval.startWithTarget(self, target)

    if self.is_3d then
        local x, y, z = GetLocalRotation(self._target)
        self._startAngle.x = x
        self._startAngle.y = y
        self._startAngle.z = z
        self._startAngle.x, self._diffAngle.x = self:calculateAngles(self._startAngle.x, self._diffAngle.x, self._dstAngle.x)
        self._startAngle.y, self._diffAngle.y = self:calculateAngles(self._startAngle.y, self._diffAngle.y, self._dstAngle.y)
        self._startAngle.z, self._diffAngle.z = self:calculateAngles(self._startAngle.z, self._diffAngle.z, self._dstAngle.z)
    else
        self._startAngle = cc.Wrapper.GetLocalRotation(self._target)
        self._startAngle, self._diffAngle = self:calculateAngles(self._startAngle, self._diffAngle, self._dstAngle)
    end
end

function cc.RotateTo:update(time)
    if (self._target) then
        if self.is_3d then
            local newRotationx = self._startAngle.x + self._diffAngle.x * time
            local newRotationy = self._startAngle.y + self._diffAngle.y * time
            local newRotationz = self._startAngle.z + self._diffAngle.z * time
            cc.Wrapper.SetLocalRotation(self._target, newRotationx, newRotationy, newRotationz)
        else
            local newRotation = self._startAngle + self._diffAngle * time
            cc.Wrapper.SetLocalRotation(self._target, 0, 0, newRotation)
        end
    end
end

function cc.RotateTo:reverse()
    print("RotateTo doesn't support the 'reverse' method")
    return nil
end

cc.RotateBy = cc.RotateBy or class("RotateBy", cc.ActionInterval)

function cc.RotateBy:ctor(duration, deltaAngle)
    self._deltaAngle = 0
    self._startAngle = 0
    self:initWithDuration(duration, deltaAngle)
end

function cc.RotateBy:initWithDuration(duration, deltaAngle)
    cc.ActionInterval.initWithDuration(self, duration)
    self._deltaAngle = deltaAngle
end

function cc.RotateBy:clone()
    return cc.RotateBy:new(self._duration, self._deltaAngle)
end

function cc.RotateBy:startWithTarget(target)
    cc.ActionInterval.startWithTarget(self, target)
    self._startAngle = self._target:GetFloat(ImageBoxProperty.Rotation)
end

function cc.RotateBy:update(time)
    if (self._target) then
        local newRotation = self._startAngle + self._deltaAngle * time
        self._target:SetFloat(ImageBoxProperty.Rotation, newRotation)
    end
end

function cc.RotateBy:reverse()
    return cc.RotateBy:new(self._duration, -self._deltaAngle)
end
--Rotate end

--Repeat start
cc.Repeat = cc.Repeat or class("Repeat", cc.ActionInterval)

function cc.Repeat:ctor(action, times)
    self:initWithAction(action, times)
end

function cc.Repeat:initWithAction(action, times)
    local d = action:getDuration() * times
    cc.ActionInterval.initWithDuration(self, d)
    self._times = times;
    self._innerAction = action;

    self._actionInstant = action._classType and action._classType == "ActionInstant" or false

    self._total = 0;
end

function cc.Repeat:clone()
    -- no copy constructor
    return cc.Repeat:new(self._innerAction:clone(), self._times)
end

function cc.Repeat:startWithTarget(target)
    self._total = 0
    self._nextDt = self._innerAction:getDuration() / self._duration
    cc.ActionInterval.startWithTarget(self, target)
    self._innerAction:startWithTarget(target)
end

function cc.Repeat:stop()
    self._innerAction:stop()
    cc.ActionInterval.stop(self)
end

-- issue #80. Instead of hooking step:, hook update: since it can be called by any 
-- container action like Repeat, Sequence, Ease, etc..
function cc.Repeat:update(dt)
    if (dt >= self._nextDt) then
        while (dt >= self._nextDt and self._total < self._times) do
            self._innerAction:update(1.0)
            self._total = self._total + 1

            self._innerAction:stop();
            self._innerAction:startWithTarget(self._target)
            self._nextDt = self._innerAction:getDuration() / self._duration * (self._total + 1)
        end

        -- fix for issue #1288, incorrect end value of repeat
        if (math.abs(dt - 1.0) < cc.ActionInterval.FLT_EPSILON and self._total < self._times) then
            self._innerAction:update(1.0);
            self._total = self._total + 1
        end

        -- don't set an instant action back or update it, it has no use because it has no duration
        if (not self._actionInstant) then
            if (self._total == self._times) then
                -- minggo: inner action update is invoked above, don't have to invoke it here
                -- self._innerAction:update(1);
                self._innerAction:stop()
            else
                -- issue #390 prevent jerk, use right update
                self._innerAction:update(dt - (self._nextDt - self._innerAction:getDuration() / self._duration))
            end
        end
    else
        self._innerAction:update(math.fmod(dt * self._times, 1.0))
    end
end

function cc.Repeat:isDone()
    return self._total == self._times
end

function cc.Repeat:reverse()
    return cc.Repeat:new(self._innerAction:reverse(), self._times)
end

cc.RepeatForever = cc.RepeatForever or class("RepeatForever", cc.ActionInterval)

function cc.RepeatForever:ctor(action)
    self:initWithAction(action)
end

function cc.RepeatForever:initWithAction(action)
    self._innerAction = action
end

function cc.RepeatForever:clone()
    return cc.RepeatForever:new(self._innerAction:clone())
end

function cc.RepeatForever:startWithTarget(target)
    cc.ActionInterval.startWithTarget(self, target)
    self._innerAction:startWithTarget(target)
end

function cc.RepeatForever:step(dt)
    self._innerAction:step(dt);
    if (self._innerAction:isDone()) then
        local diff = self._innerAction:getElapsed() - self._innerAction:getDuration()
        if (diff > self._innerAction:getDuration()) then
            diff = math.fmod(diff, self._innerAction:getDuration())
        end
        self._innerAction:startWithTarget(self._target)
        -- to prevent jerk. issue #390, 1247
        self._innerAction:step(0.0);
        self._innerAction:step(diff);
    end
end

function cc.RepeatForever:isDone()
    return false
end

function cc.RepeatForever:reverse()
    return cc.RepeatForever:new(self._innerAction:reverse())
end
--Repeat end

--Spawn start
cc.Spawn = cc.Spawn or class("Spawn", cc.ActionInterval)

function cc.Spawn:ctor(...)
    self._actions = {}
    self:initWithTable({ ... })
end

function cc.Spawn.createWithTwoActions(actionOne, actionTwo)
    local Spawn = cc.Spawn:new()
    Spawn:initWithTwoActions(actionOne, actionTwo);
    return Spawn
end

function cc.Spawn:initWithTable(actions)
    local count = #actions
    if (count == 0) then
        --进入这里也是正常的
        return
    end

    if (count == 1) then
        return initWithTwoActions(actions[1], cc.ExtraAction:new());
    end

    local prev = actions[1]
    for i = 2, #actions - 1 do
        prev = cc.Spawn.createWithTwoActions(prev, actions[i])
    end

    self:initWithTwoActions(prev, actions[count]);
end

function cc.Spawn:initWithTwoActions(actionOne, actionTwo)
    local d1 = actionOne:getDuration()
    local d2 = actionTwo:getDuration()
    local d = math.max(d1, d2)
    cc.ActionInterval.initWithDuration(self, d)
    self._one = actionOne
    self._two = actionTwo
    if (d1 > d2) then
        self._two = cc.Sequence:new(actionTwo, cc.DelayTime:new(d1 - d2));
    elseif (d1 < d2) then
        self._one = cc.Sequence:new(actionOne, cc.DelayTime:new(d2 - d1));
    end
end

function cc.Spawn:clone()
    local a = cc.Spawn:new()
    a:initWithTwoActions(self._one:clone(), self._two:clone())
    return a
end

function cc.Spawn:startWithTarget(target)
    cc.ActionInterval.startWithTarget(self, target)
    self._one:startWithTarget(target)
    self._two:startWithTarget(target)
end

function cc.Spawn:stop()
    self._one:stop()
    self._two:stop()
    cc.ActionInterval.stop(self)
end

function cc.Spawn:update(time)
    if (self._one) then
        self._one:update(time)
    end
    if (self._two) then
        self._two:update(time)
    end
end

function cc.Spawn:reverse()
    return cc.Spawn:new(self._one:reverse(), self._two:reverse())
end
--Spawn end

--DelayTime start

cc.DelayTime = cc.DelayTime or class("DelayTime", cc.ActionInterval)

function cc.DelayTime:ctor(d)
    self:initWithDuration(d);
end

function cc.DelayTime:clone()
    return cc.DelayTime:new(self._duration)
end

function cc.DelayTime:update(time)
    --什么都不干
end

function cc.DelayTime:reverse()
    return cc.DelayTime:new(self._duration)
end

--DelayTime end
--SizeBy start
cc.SizeBy = cc.SizeBy or class("SizeBy", cc.ActionInterval)

function cc.SizeBy:ctor(duration, delta_w, delta_h)
    self:initWithDuration(duration, delta_w, delta_h)
end

function cc.SizeBy:clone()
    return cc.SizeBy:new(self._duration, self._SizeDeltaW, self._SizeDeltaH)
end

function cc.SizeBy:reverse()
    return cc.SizeBy:new(self._duration, -self._SizeDeltaW, -self._SizeDeltaH)
end

function cc.SizeBy:startWithTarget(target)
    cc.ActionInterval.startWithTarget(self, target)

    self._previousSizeWidht, self._previousSizeHeight = cc.Wrapper.GetSize(target)
    self._startSizeX, self._startSizeY = self._previousSizeWidht, self._previousSizeHeight
end

function cc.SizeBy:update(t)
    if self._target then
        local currentW, currentH = cc.Wrapper.GetSize(self._target)
        local diffX = currentW - self._previousSizeWidht
        local diffY = currentH - self._previousSizeHeight
        local newSizeW = self._startSizeX + (self._SizeDeltaW * t)
        local newSizeH = self._startSizeY + (self._SizeDeltaH * t)
        -- self._target:SetVectorValue(WidgetProperty.Size,newSizeW,newSizeH)
        cc.Wrapper.SetSize(self._target, newSizeW, newSizeH)
        self._previousSizeWidht = newSizeW
        self._previousSizeHeight = newSizeH
    end
end

function cc.SizeBy:initWithDuration(duration, delta_w, delta_h)
    cc.ActionInterval.initWithDuration(self, duration)
    self._SizeDeltaW = delta_w
    self._SizeDeltaH = delta_h
end

--SizeBy end

--SizeTo start
cc.SizeTo = cc.SizeTo or class("SizeTo", cc.SizeBy)
function cc.SizeTo:ctor(duration, w, h)
    self:initWithSize(duration, w, h)
end

function cc.SizeTo:initWithSize(duration, w, h)
    cc.ActionInterval.initWithDuration(self, duration)
    self._endSizeW = w
    self._endSizeH = h
end

function cc.SizeTo:clone()
    return cc.SizeTo:new(self._duration, self._endSizeW, self._endSizeH)
end

function cc.SizeTo:startWithTarget(target)
    cc.SizeBy.startWithTarget(self, target)
    local oldW, oldH = cc.Wrapper.GetSize(target)
    self._SizeDeltaW = self._endSizeW - oldW
    self._SizeDeltaH = self._endSizeH - oldH
end

function cc.SizeTo:reverse()
    print("reverse() not supported in SizeTo")
    return nil
end
--SizeTo end


-- Bezier cubic formula:
--    ((1 - t) + t)3 = 1 
-- Expands to ...
--   (1 - t)3 + 3t(1-t)2 + 3t2(1 - t) + t3 = 1 
function cc.bezierat(a, b, c, d, t)
    return (math.pow(1 - t, 3) * a +
            3 * t * (math.pow(1 - t, 2)) * b +
            3 * math.pow(t, 2) * (1 - t) * c +
            math.pow(t, 3) * d)
end

-- BezierBy start
cc.BezierBy = cc.BezierBy or class("BezierBy", cc.ActionInterval)

--t为动作时间，c为控制点信息，比如 {end_pos={x=0,y=0},control_1={x=1,y=1},control_2={x=2,y=2}}
function cc.BezierBy:ctor(t, c)
    self:initWithDuration(t, c)
end

function cc.BezierBy:initWithDuration(t, c)
    cc.ActionInterval.initWithDuration(self, t)
    self._config = c
end

function cc.BezierBy:startWithTarget(target)
    cc.ActionInterval.startWithTarget(self, target)
    local x, y, z
    if type(target) ~= "userdata" and target.GetPosition then
        x, y, z = target:GetPosition()
        if type(x) == "table" then
            x, y, z = x.x, x.y, x.z
        end
    else
        x, y, z = cc.Wrapper.GetLocalPosition(target)
    end
    if type(target) ~= "userdata" and target.SetPosition then
        self.is_use_lua_function = true
    end
    self._startPosition = { x = x, y = y }
    self._previousPosition = { x = x, y = y }
end

function cc.BezierBy:clone()
    return cc.BezierBy:new(self._duration, self._config)
end

function cc.BezierBy:update(time)
    if (self._target) then
        local xa = 0;
        local xb = self._config.control_1.x;
        local xc = self._config.control_2.x;
        local xd = self._config.end_pos.x;

        local ya = 0;
        local yb = self._config.control_1.y;
        local yc = self._config.control_2.y;
        local yd = self._config.end_pos.y;

        local x = cc.bezierat(xa, xb, xc, xd, time);
        local y = cc.bezierat(ya, yb, yc, yd, time);

        -- #if CC_ENABLE_STACKABLE_ACTIONS
        --         Vec2 currentPos = _target->getPosition();
        --         Vec2 diff = currentPos - _previousPosition;
        --         _startPosition = _startPosition + diff;

        --         Vec2 newPos = _startPosition + Vec2(x,y);
        --         _target->setPosition(newPos);

        --         _previousPosition = newPos;
        -- #else

        if self.is_use_lua_function then
            self._target:SetPosition(self._startPosition.x + x, self._startPosition.y + y, 0)
        else
            cc.Wrapper.SetLocalPosition(self._target, self._startPosition.x + x, self._startPosition.y + y)
        end
        -- #endif // !CC_ENABLE_STACKABLE_ACTIONS
    end
end

function cc.BezierBy:reverse()
    local r = {}
    r.end_pos = { x = -self._config.end_pos.x, y = -self._config.end_pos.y }
    r.control_1 = { x = 0, y = 0 }
    r.control_1.x = self._config.control_2.x - self._config.end_pos.x
    r.control_1.y = self._config.control_2.y - self._config.end_pos.y

    r.control_2 = { x = 0, y = 0 }
    r.control_2.x = self._config.control_1.x - self._config.end_pos.x
    r.control_2.y = self._config.control_1.y - self._config.end_pos.y

    return cc.BezierBy:new(self._duration, r)
end

-- BezierTo start
cc.BezierTo = cc.BezierTo or class("BezierBy", cc.BezierBy)

function cc.BezierTo:ctor(t, c)
    self:initWithDuration(t, c)
end

function cc.BezierTo:initWithDuration(t, c)
    cc.ActionInterval.initWithDuration(self, t)
    self._toConfig = c
end

function cc.BezierTo:clone()
    return cc.BezierTo:new(self._duration, self._toConfig)
end

function cc.BezierTo:startWithTarget(target)
    cc.BezierBy.startWithTarget(self, target)
    self:InitConfig()
end

function cc.BezierTo:InitConfig()
    if not self._startPosition then
        return
    end
    self._config = self._config or {}
    self._config.control_1 = self._config.control_1 or { x = 0, y = 0 }
    self._config.control_1.x = self._toConfig.control_1.x - self._startPosition.x
    self._config.control_1.y = self._toConfig.control_1.y - self._startPosition.y

    self._config.control_2 = self._config.control_2 or { x = 0, y = 0 }
    self._config.control_2.x = self._toConfig.control_2.x - self._startPosition.x
    self._config.control_2.y = self._toConfig.control_2.y - self._startPosition.y

    self._config.end_pos = self._config.end_pos or { x = 0, y = 0 }
    self._config.end_pos.x = self._toConfig.end_pos.x - self._startPosition.x
    self._config.end_pos.y = self._toConfig.end_pos.y - self._startPosition.y
end

function cc.BezierTo:reverse()
    return nil
end

--DelayTime end

-- Animate start
cc.Animate = cc.Animate or class("Animate", cc.ActionInterval)
function cc.Animate:ctor(array, time, image, last_sprite_index, delayperunit, loop_count)
    self.array = array
    self.time = time
    self.image = image
    self.last_sprite_index = last_sprite_index
    self.cur_index = 0
    self.pass_time = 0
    self.delayperunit = delayperunit or 0
    self.loop_count = loop_count or #self.array
    Yzprint('--LaoY ActionInterval.lua,line 975--', self.delayperunit)
    cc.ActionInterval.initWithDuration(self, time, image)
end

function cc.Animate:isDone()
    if self.time == 0 then
        return false
    else
        return self._elapsed >= self._duration
    end
end

function cc.Animate:stop()
    if self._target and self.last_sprite_index and self.array[self.last_sprite_index] then
        self._target.sprite = self.array[self.last_sprite_index]
    end
    cc.Animate.super.stop(self)
end

function cc.Animate:step(dt)
    if self._firstTick then
        self._firstTick = false
        self._elapsed = 0
    else
        self._elapsed = self._elapsed + dt
    end
    self.pass_time = self.pass_time + dt
    local is_change = false
    if self.pass_time - self.delayperunit >= 0 then
        -- if self.delayperunit ~= 0 then
        --     self.pass_time = self.pass_time%self.delayperunit
        -- else
        -- end
        self.pass_time = self.pass_time - self.delayperunit
        is_change = true
    end
    if not is_change then
        return
    end
    self.cur_index = self.cur_index + 1
    -- print('--LaoY ActionInterval.lua,line 1008--',self.cur_index,#self.array,self.pass_time,self._elapsed,self.delayperunit)
    if self.cur_index > self.loop_count then
        self.cur_index = 1
    end
    local sprite = self.array[self.cur_index]
    self._target.sprite = sprite
end
-- Animate end

--ScaleBy start
cc.ScaleBy = cc.ScaleBy or class("ScaleBy", cc.ActionInterval)

function cc.ScaleBy:ctor(duration, delta_x, delta_y, delta_z)
    delta_y = delta_y or delta_x
    delta_z = delta_z or delta_x
    self:initWithDuration(duration, delta_x, delta_y, delta_z)
end

function cc.ScaleBy:clone()
    return cc.ScaleBy(self._duration, self._positionDeltaX, self._positionDeltaY, self._positionDeltaZ)
end

function cc.ScaleBy:reverse()
    return cc.ScaleBy(self._duration, self._positionDeltaX and -self._positionDeltaX, self._positionDeltaY and -self._positionDeltaY, self._positionDeltaZ and -self._positionDeltaZ)
end

function cc.ScaleBy:startWithTarget(target)
    cc.ActionInterval.startWithTarget(self, target)
    local x, y, z
    if type(target) ~= "userdata" and target.GetScale then
        x, y, z = target:GetScale()
        y = y or x
        z = z or x
        if type(x) == "table" then
            x, y, z = x.x, x.y, x.z
        end
    else
        x, y, z = cc.Wrapper.GetLocalScale(target)
    end
    if type(target) ~= "userdata" and target.SetScale then
        self.is_use_lua_function = true
    end
    self._previousPositionX, self._previousPositionY, self._previousPositionZ = x, y, z
    self._startPositionX, self._startPositionY, self._startPositionZ = self._previousPositionX, self._previousPositionY, self._previousPositionZ
end

function cc.ScaleBy:update(t)
    if self._target then
        -- local currentPosX, currentPosY, currentPosZ = cc.Wrapper.GetLocalScale(self._target)
        if self._positionDeltaX and self._positionDeltaX ~= 0 then
            self._previousPositionX = self._startPositionX + (self._positionDeltaX * t)
        end
        if self._positionDeltaY and self._positionDeltaY ~= 0 then
            self._previousPositionY = self._startPositionY + (self._positionDeltaY * t)
        end
        if self._positionDeltaZ and self._positionDeltaZ ~= 0 then
            self._previousPositionZ = self._startPositionZ + (self._positionDeltaZ * t)
        end
        if self.is_use_lua_function then
            self._target:SetScale(self._previousPositionX, self._previousPositionY, self._previousPositionZ)
        else
            cc.Wrapper.SetLocalScale(self._target, self._previousPositionX, self._previousPositionY, self._previousPositionZ)
        end
    end
end

function cc.ScaleBy:initWithDuration(duration, delta_x, delta_y, delta_z)
    delta_y = delta_y or delta_x
    delta_z = delta_z or delta_x
    cc.ActionInterval.initWithDuration(self, duration)
    self._positionDeltaX = delta_x
    self._positionDeltaY = delta_y
    self._positionDeltaZ = delta_z
end

--ScaleBy end

--ScaleTo start
cc.ScaleTo = cc.ScaleTo or class("ScaleTo", cc.ScaleBy)
function cc.ScaleTo:ctor(duration, x, y, z)
    y = y or x
    z = z or x
    self:initWithPos(duration, x, y, z)
end

function cc.ScaleTo:initWithPos(duration, x, y, z)
    cc.ActionInterval.initWithDuration(self, duration)
    if AppConfig.Debug and (not x or not y) then
        Yzprint('--LaoY ActionInterval.lua,line 180--', data)
        traceback()
    end
    self._endPositionX = x
    self._endPositionY = y
    self._endPositionZ = z
end

function cc.ScaleTo:clone()
    return cc.ScaleTo:new(self._duration, self._endPositionX, self._endPositionY, self._endPositionZ)
end

function cc.ScaleTo:startWithTarget(target)
    cc.ScaleBy.startWithTarget(self, target)
    local oldX, oldY, oldZ
    if type(target) ~= "userdata" and target.GetScale then
        oldX, oldY, oldZ = target:GetScale()
        oldY = oldY or oldX
        oldZ = oldZ or oldX
        if type(oldX) == "table" then
            oldX, oldY, oldZ = oldX.x, oldX.y, oldX.z
        end
    else
        oldX, oldY, oldZ = cc.Wrapper.GetLocalScale(target)
    end
    self._positionDeltaX = self._endPositionX - oldX
    self._positionDeltaY = self._endPositionY - oldY
    if self._endPositionZ then
        self._positionDeltaZ = self._endPositionZ - oldZ
    else
        self._positionDeltaZ = 0
    end
end

function cc.ScaleTo:reverse()
    print("reverse() not supported in ScaleTo")
    return nil
end
--ScaleTo end