-- ActionEase

local POW = math.pow
local SIN = math.sin
local COS = math.cos

local PI = math.pi
local PI_2 = math.pi / 2
local PI_X2 = PI * 2

-- CCFActionEase

local CCFActionEase = class("CCFActionEase", require("app.common.action.Action").CCFActionInterval)

function CCFActionEase:ctor(action)
    assert(action, "action could not be nil !")
    CCFActionEase.super.ctor(self, action:getTotalFrame())
    self._innerAction = action
end

function CCFActionEase:startWithTarget(target)
    CCFActionEase.super.startWithTarget(self, target)
    self._innerAction:startWithTarget(target)
end

function CCFActionEase:_update(dt)
    CCFActionEase.super._update(self, dt)
    self._innerAction:_update(dt)
end

-- CCFEaseIn

local CCFEaseIn = class("CCFEaseIn", CCFActionEase)

function CCFEaseIn:ctor(action, rate)
    CCFEaseIn.super.ctor(self, action)
    self._rate = rate
end

function CCFEaseIn:_update(dt)
    self._innerAction:_update(POW(dt, self._rate))
end

-- CCFEaseOut

local CCFEaseOut = class("CCFEaseOut", CCFActionEase)

function CCFEaseOut:ctor(action, rate)
    CCFEaseOut.super.ctor(self, action)
    self._rate = rate
end

function CCFEaseOut:_update(dt)
    self._innerAction:_update(POW(dt, 1 / self._rate))
end

-- CCFEaseInOut

local CCFEaseInOut = class("CCFEaseInOut", CCFActionEase)

function CCFEaseInOut:ctor(action, rate)
    CCFEaseInOut.super.ctor(self, action)
    self._rate = rate
end

function CCFEaseInOut:_update(dt)
    dt = dt * 2
    if dt < 1 then
        self._innerAction:_update(0.5 * POW(dt, self._rate))
    else
        self._innerAction:_update(1 - 0.5 * POW(2-dt, self._rate))
    end
end

-- CCFEaseExponentialIn

local CCFEaseExponentialIn = class("CCFEaseExponentialIn", CCFActionEase)

function CCFEaseExponentialIn:_update(dt)
    self._innerAction:_update(dt == 0 and 0 or POW(2, 10 * (dt/1 - 1)) - 1 * 0.001)
end

-- CCFEaseExponentialOut

local CCFEaseExponentialOut = class("CCFEaseExponentialOut", CCFActionEase)

function CCFEaseExponentialOut:_update(dt)
    self._innerAction:_update(dt == 1 and 1 or (-POW(2, -10 * dt / 1) + 1))
end

-- CCFEaseExponentialInOut

local CCFEaseExponentialInOut = class("CCFEaseExponentialInOut", CCFActionEase)

function CCFEaseExponentialInOut:_update(dt)
    dt = dt / 0.5
    if dt < 1 then
        dt = 0.5 * POW(2, 10 * (dt - 1))
    else
        dt = 0.5 * (-POW(2, -10 * (dt - 1)) + 2)
    end
    self._innerAction:_update(dt)
end

-- CCFEaseSineIn

local CCFEaseSineIn = class("CCFEaseSineIn", CCFActionEase)

function CCFEaseSineIn:_update(dt)
    self._innerAction:_update(-1 * COS(dt * PI_2) + 1)
end

-- CCFEaseSineOut

local CCFEaseSineOut = class("CCFEaseSineOut", CCFActionEase)

function CCFEaseSineOut:_update(dt)
    self._innerAction:_update(SIN(dt * PI_2))
end

-- CCFEaseSineInOut

local CCFEaseSineInOut = class("CCFEaseSineInOut", CCFActionEase)

function CCFEaseSineInOut:_update(dt)
    self._innerAction:_update(-0.5 * (COS(PI * dt) - 1))
end

-- CCFEaseElasticIn

local CCFEaseElasticIn = class("CCFEaseElasticIn", CCFActionEase)

function CCFEaseElasticIn:ctor(action, period)
    CCFEaseElasticIn.super.ctor(self, action)
    self._period = period or 0.3
end

function CCFEaseElasticIn:_update(dt)
    local newT = 0;
    if dt == 0 or dt == 1 then
        newT = dt;
    else
        local s = self._period / 4;
        dt = dt - 1;
        newT = -POW(2, 10 * dt) * SIN((dt - s) * PI_X2 / self._period);
    end

    self._innerAction:_update(newT);
end

-- CCFEaseElasticOut

local CCFEaseElasticOut = class("CCFEaseElasticOut", CCFActionEase)

function CCFEaseElasticOut:ctor(action, period)
    CCFEaseElasticOut.super.ctor(self, action)
    self._period = period or 0.3
end

function CCFEaseElasticOut:_update(dt)
    local newT = 0
    if dt == 0 or dt == 1 then
        newT = dt;
    else
        local s = self._period / 4;
        newT = POW(2, -10 * dt) * SIN((dt - s) * PI_X2 / self._period) + 1;
    end

    self._innerAction:_update(newT);
end

-- CCFEaseElasticInOut

local CCFEaseElasticInOut = class("CCFEaseElasticInOut", CCFActionEase)

function CCFEaseElasticInOut:ctor(action, period)
    CCFEaseElasticInOut.super.ctor(self, action)
    self._period = period or 0.3
end

function CCFEaseElasticInOut:_update(dt)
    local newT = 0;
    if dt == 0 or dt == 1 then
        newT = dt;
    else
        dt = dt * 2;
        if not self._period then
            self._period = 0.3 * 1.5
        end

        local s = self._period / 4;

        dt = dt - 1;
        if dt < 0 then
            newT = -0.5 * POW(2, 10 * dt) * SIN((dt -s) * PI_X2 / self._period);
        else
            newT = POW(2, -10 * dt) * SIN((dt - s) * PI_X2 / self._period) * 0.5 + 1;
        end
    end

    self._innerAction:_update(newT);
end

-- bounceTime

local function bounceTime(dt)
    
    if dt < 1 / 2.75 then
        return 7.5625 * dt * dt;
    elseif dt < 2 / 2.75 then
        dt = dt - 1.5 / 2.75;
        return 7.5625 * dt * dt + 0.75;
    elseif dt < 2.5 / 2.75 then
        dt = dt - 2.25 / 2.75;
        return 7.5625 * dt * dt + 0.9375;
    end

    dt = dt - 2.625 / 2.75;
    return 7.5625 * dt * dt + 0.984375;
    
end

-- CCFEaseBounceIn

local CCFEaseBounceIn = class("CCFEaseBounceIn", CCFActionEase)

function CCFEaseBounceIn:_update(dt)
    local newT = 1 - bounceTime(1 - dt)
    self._innerAction:_update(newT);
end

-- CCFEaseBounceOut

local CCFEaseBounceOut = class("CCFEaseBounceOut", CCFActionEase)

function CCFEaseBounceOut:_update(dt)
    local newT = bounceTime(dt)
    self._innerAction:_update(newT);
end

-- CCFEaseBounceInOut

local CCFEaseBounceInOut = class("CCFEaseBounceInOut", CCFActionEase)

function CCFEaseBounceInOut:_update(dt)
    local newT = 0;
    if dt < 0.5 then
        dt = dt * 2;
        newT = (1 - bounceTime(1 - dt)) * 0.5;
    else
        newT = bounceTime(dt * 2 - 1) * 0.5 + 0.5;
    end
    self._innerAction:_update(newT);
end

-- CCFEaseBackIn

local CCFEaseBackIn = class("CCFEaseBackIn", CCFActionEase)

function CCFEaseBackIn:_update(dt)
    local overshoot = 1.70158;
    self._innerAction:_update(dt * dt * ((overshoot + 1) * dt - overshoot));
end

-- CCFEaseBackOut

local CCFEaseBackOut = class("CCFEaseBackOut", CCFActionEase)

function CCFEaseBackOut:_update(dt)
    local overshoot = 1.70158;

    dt = dt - 1;
    self._innerAction:_update(dt * dt * ((overshoot + 1) * dt + overshoot) + 1);
end

-- CCFEaseBackInOut

local CCFEaseBackInOut = class("CCFEaseBackInOut", CCFActionEase)

function CCFEaseBackInOut:_update(dt)
    local overshoot = 1.70158 * 1.525;

    dt = dt * 2;
    if dt < 1 then
        self._innerAction:_update((dt * dt * ((overshoot + 1) * dt - overshoot)) / 2);
    else
        dt = dt - 2;
        self._innerAction:_update((dt * dt * ((overshoot + 1) * dt + overshoot)) / 2 + 1);
    end
end


-- ActionEaseFactory

local ActionEaseFactory = {}

function ActionEaseFactory.newEaseIn(...) return CCFEaseIn.new(...) end

return ActionEaseFactory
