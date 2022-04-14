cc = cc or {}

M_PI_X_2 = math.pi * 2.0
M_PI_2 = math.pi / 2.0
M_PI = math.pi

cc.ActionEase = cc.ActionEase or class("ActionEase",cc.ActionInterval)

function cc.ActionEase:ctor(action)
    -- self:initWithAction(action)
end

function cc.ActionEase:initWithAction(action)
    cc.ActionInterval.initWithDuration(self, action:getDuration())
    self._inner = action
    -- print("Cat:CCActionEase.lua [initWithAction] self._inner: ",self._inner)
end

function cc.ActionEase:clone()
    print("Cat_Error:CCActionEase.lua [reverse] cannot clone ease action!")
    return nil;
end
    
function cc.ActionEase:reverse()
    print("Cat_Error:CCActionEase.lua [reverse] cannot reverse ease action!")
    return nil;
end

-- function cc.ActionEase:step(time)
--     cc.ActionInterval.step(self, time)
-- end

function cc.ActionEase:startWithTarget(target)
	-- print("Cat:CCActionEase.lua [startWithTarget]")
    cc.ActionInterval.startWithTarget(self, target);
    self._inner:startWithTarget(self._target);
end

function cc.ActionEase:stop(void)
    self._inner:stop();
    cc.ActionInterval.stop(self)
end

function cc.ActionEase:update(time)
    self._inner:update(time)
end

function cc.ActionEase:getInnerAction()
    return self._inner
end

------------------------EaseRateAction start---------------------------
cc.EaseRateAction = cc.EaseRateAction or class("EaseRateAction",cc.ActionEase)

function cc.EaseRateAction:ctor(action, rate)
    self:initWithAction(action, rate)
end

function cc.EaseRateAction:initWithAction(action, rate)
    cc.ActionEase.initWithAction(self, action)
    self._rate = rate
end

function cc.EaseRateAction:setRate(rate) 
    self._rate = rate
end
    
function cc.EaseRateAction:getRate() 
    return self._rate
end

--in
cc.EaseIn = cc.EaseIn or class("EaseIn",cc.EaseRateAction)

function cc.EaseIn:ctor(action, rate)
    self:initWithAction(action, rate)
end

function cc.EaseIn:clone()
    return EaseIn:new(self._inner:clone(), self._rate)
end

function cc.EaseIn:update(time)
    self._inner:update(cc.tweenfunc.easeIn(time, self._rate))
end

function cc.EaseIn:reverse()
    return cc.EaseIn:new(self._inner:reverse(), 1/self._rate)
end

--out
cc.EaseOut = cc.EaseOut or class("EaseOut",cc.EaseRateAction)

function cc.EaseOut:ctor(action, rate)
    self:initWithAction(action, rate)
end

function cc.EaseOut:clone()
    return EaseOut:new(self._inner:clone(), self._rate)
end

function cc.EaseOut:update(time)
    self._inner:update(cc.tweenfunc.easeOut(time, self._rate))
end

function cc.EaseOut:reverse()
    return cc.EaseOut:new(self._inner:reverse(), 1/self._rate)
end

--in out
cc.EaseInOut = cc.EaseInOut or class("EaseInOut",cc.EaseRateAction)

function cc.EaseInOut:ctor(action, rate)
    self:initWithAction(action, rate)
end

function cc.EaseInOut:clone()
    return EaseInOut:new(self._inner:clone(), self._rate)
end

function cc.EaseInOut:update(time)
    self._inner:update(cc.tweenfunc.easeInOut(time, self._rate))
end

function cc.EaseInOut:reverse()
    return cc.EaseInOut:new(self._inner:reverse(), self._rate)
end
------------------------EaseRateAction end---------------------------

------------------------EaseExponential start---------------------------
--in
cc.EaseExponentialIn = cc.EaseExponentialIn or class("EaseExponentialIn",cc.ActionEase)

function cc.EaseExponentialIn:ctor(action)
    self:initWithAction(action)
end

function cc.EaseExponentialIn:clone()
    return EaseExponentialIn:new(self._inner:clone())
end

function cc.EaseExponentialIn:update(time)
    self._inner:update(cc.tweenfunc.expoEaseIn(time))
end

function cc.EaseExponentialIn:reverse()
    return cc.EaseExponentialIn:new(self._inner:reverse())
end

--out
cc.EaseExponentialOut = cc.EaseExponentialOut or class("EaseExponentialOut",cc.ActionEase)

function cc.EaseExponentialOut:ctor(action)
    self:initWithAction(action)
end

function cc.EaseExponentialOut:clone()
    return EaseExponentialOut:new(self._inner:clone())
end

function cc.EaseExponentialOut:update(time)
    self._inner:update(cc.tweenfunc.expoEaseOut(time))
end

function cc.EaseExponentialOut:reverse()
    return cc.EaseExponentialOut:new(self._inner:reverse())
end

--in out
cc.EaseExponentialInOut = cc.EaseExponentialInOut or class("EaseExponentialInOut",cc.ActionEase)

function cc.EaseExponentialInOut:ctor(action)
    self:initWithAction(action)
end

function cc.EaseExponentialInOut:clone()
    return EaseExponentialInOut:new(self._inner:clone())
end

function cc.EaseExponentialInOut:update(time)
    self._inner:update(cc.tweenfunc.expoEaseInOut(time))
end

function cc.EaseExponentialInOut:reverse()
    return cc.EaseExponentialInOut:new(self._inner:reverse())
end
------------------------EaseExponential end---------------------------

------------------------EaseSine start---------------------------
--in
cc.EaseSineIn = cc.EaseSineIn or class("EaseSineIn",cc.ActionEase)

function cc.EaseSineIn:ctor(action)
    self:initWithAction(action)
end

function cc.EaseSineIn:clone()
    return EaseSineIn:new(self._inner:clone())
end

function cc.EaseSineIn:update(time)
    self._inner:update(cc.tweenfunc.sineEaseIn(time))
end

function cc.EaseSineIn:reverse()
    return cc.EaseSineIn:new(self._inner:reverse())
end

--out
cc.EaseSineOut = cc.EaseSineOut or class("EaseSineOut",cc.ActionEase)

function cc.EaseSineOut:ctor(action)
    self:initWithAction(action)
end

function cc.EaseSineOut:clone()
    return EaseSineOut:new(self._inner:clone())
end

function cc.EaseSineOut:update(time)
    self._inner:update(cc.tweenfunc.sineEaseOut(time))
end

function cc.EaseSineOut:reverse()
    return cc.EaseSineOut:new(self._inner:reverse())
end

--in out
cc.EaseSineInOut = cc.EaseSineInOut or class("EaseSineInOut",cc.ActionEase)

function cc.EaseSineInOut:ctor(action)
    self:initWithAction(action)
end

function cc.EaseSineInOut:clone()
    return EaseSineInOut:new(self._inner:clone())
end

function cc.EaseSineInOut:update(time)
    self._inner:update(cc.tweenfunc.sineEaseInOut(time))
end

function cc.EaseSineInOut:reverse()
    return cc.EaseSineInOut:new(self._inner:reverse())
end
------------------------EaseSine end---------------------------

------------------------EaseElastic start---------------------------
cc.EaseElastic = cc.EaseElastic or class("EaseElastic",cc.ActionEase)

function cc.EaseElastic:ctor(action, period)
    --抽象类所以不能直接New本类
    -- self:initWithAction(action, period)
end

function cc.EaseElastic:initWithAction(action, period)
    -- print("Cat:CCActionEase.lua [54] action,period: ",action,period)
    cc.ActionEase.initWithAction(self, action)
    period = period or 0.3
    self._period = period
end

function cc.EaseElastic:getPeriod()
    return self._period
end

function cc.EaseElastic:setPeriod(fPeriod)
    self._period = fPeriod 
end

cc.EaseElasticOut = cc.EaseElasticOut or class("EaseElasticOut",cc.EaseElastic)

function cc.EaseElasticOut:ctor(action, period)
    self:initWithAction(action, period)
end

function cc.EaseElasticOut:clone()
    return EaseElasticOut:new(self._inner:clone(), self._period)
end

function cc.EaseElasticOut:update(time)
    self._inner:update(cc.tweenfunc.elasticEaseOut(time, self._period));
end

function cc.EaseElasticOut:reverse()
    return cc.EaseElasticIn:new(self._inner:reverse(), self._period);
end

--
cc.EaseElasticIn = cc.EaseElasticIn or class("EaseElasticIn",cc.EaseElastic)

function cc.EaseElasticIn:ctor(action, period)
    self:initWithAction(action, period)
end

function cc.EaseElasticIn:clone()
    return cc.EaseElasticIn:new(self._inner:clone(), self._period)
end

function cc.EaseElasticIn:update(time)
    self._inner:update(cc.tweenfunc.elasticEaseIn(time, self._period));
end

function cc.EaseElasticIn:reverse()
    return cc.EaseElasticOut:new(self._inner:reverse(), self._period);
end

cc.EaseElasticInOut = cc.EaseElasticInOut or class("EaseElasticInOut",cc.EaseElastic)

function cc.EaseElasticInOut:ctor(action, period)
    self:initWithAction(action, period)
end

function cc.EaseElasticInOut:clone()
    return cc.EaseElasticInOut:new(self._inner:clone(), self._period)
end

function cc.EaseElasticInOut:update(time)
    self._inner:update(cc.tweenfunc.elasticEaseInOut(time, self._period));
end

function cc.EaseElasticInOut:reverse()
    return cc.EaseElasticInOut:new(self._inner:reverse(), self._period);
end

------------------------EaseElastic end---------------------------

------------------------EaseBounce start---------------------------
--in
cc.EaseBounceIn = cc.EaseBounceIn or class("EaseBounceIn",cc.ActionEase)

function cc.EaseBounceIn:ctor(action)
    self:initWithAction(action)
end

function cc.EaseBounceIn:clone()
    return EaseBounceIn:new(self._inner:clone())
end

function cc.EaseBounceIn:update(time)
    self._inner:update(cc.tweenfunc.bounceEaseIn(time))
end

function cc.EaseBounceIn:reverse()
    return cc.EaseBounceIn:new(self._inner:reverse())
end

--out
cc.EaseBounceOut = cc.EaseBounceOut or class("EaseBounceOut",cc.ActionEase)

function cc.EaseBounceOut:ctor(action)
    self:initWithAction(action)
end

function cc.EaseBounceOut:clone()
    return EaseBounceOut:new(self._inner:clone())
end

function cc.EaseBounceOut:update(time)
    self._inner:update(cc.tweenfunc.bounceEaseOut(time))
end

function cc.EaseBounceOut:reverse()
    return cc.EaseBounceOut:new(self._inner:reverse())
end

--in out
cc.EaseBounceInOut = cc.EaseBounceInOut or class("EaseBounceInOut",cc.ActionEase)

function cc.EaseBounceInOut:ctor(action)
    self:initWithAction(action)
end

function cc.EaseBounceInOut:clone()
    return EaseBounceInOut:new(self._inner:clone())
end

function cc.EaseBounceInOut:update(time)
    self._inner:update(cc.tweenfunc.bounceEaseInOut(time))
end

function cc.EaseBounceInOut:reverse()
    return cc.EaseBounceInOut:new(self._inner:reverse())
end
------------------------EaseBounce end---------------------------

------------------------EaseBack start---------------------------
--in
cc.EaseBackIn = cc.EaseBackIn or class("EaseBackIn",cc.ActionEase)

function cc.EaseBackIn:ctor(action)
    self:initWithAction(action)
end

function cc.EaseBackIn:clone()
    return EaseBackIn:new(self._inner:clone())
end

function cc.EaseBackIn:update(time)
    self._inner:update(cc.tweenfunc.backEaseIn(time))
end

function cc.EaseBackIn:reverse()
    return cc.EaseBackIn:new(self._inner:reverse())
end

--out
cc.EaseBackOut = cc.EaseBackOut or class("EaseBackOut",cc.ActionEase)

function cc.EaseBackOut:ctor(action)
    self:initWithAction(action)
end

function cc.EaseBackOut:clone()
    return EaseBackOut:new(self._inner:clone())
end

function cc.EaseBackOut:update(time)
    self._inner:update(cc.tweenfunc.backEaseOut(time))
end

function cc.EaseBackOut:reverse()
    return cc.EaseBackOut:new(self._inner:reverse())
end

--in out
cc.EaseBackInOut = cc.EaseBackInOut or class("EaseBackInOut",cc.ActionEase)

function cc.EaseBackInOut:ctor(action)
    self:initWithAction(action)
end

function cc.EaseBackInOut:clone()
    return EaseBackInOut:new(self._inner:clone())
end

function cc.EaseBackInOut:update(time)
    self._inner:update(cc.tweenfunc.backEaseInOut(time))
end

function cc.EaseBackInOut:reverse()
    return cc.EaseBackInOut:new(self._inner:reverse())
end
------------------------EaseBack end---------------------------

------------------------EaseQuadraticAction start---------------------------
--in
cc.EaseQuadraticActionIn = cc.EaseQuadraticActionIn or class("EaseQuadraticActionIn",cc.ActionEase)

function cc.EaseQuadraticActionIn:ctor(action)
    self:initWithAction(action)
end

function cc.EaseQuadraticActionIn:clone()
    return EaseQuadraticActionIn:new(self._inner:clone())
end

function cc.EaseQuadraticActionIn:update(time)
    self._inner:update(cc.tweenfunc.quadraticIn(time))
end

function cc.EaseQuadraticActionIn:reverse()
    return cc.EaseQuadraticActionIn:new(self._inner:reverse())
end

--out
cc.EaseQuadraticActionOut = cc.EaseQuadraticActionOut or class("EaseQuadraticActionOut",cc.ActionEase)

function cc.EaseQuadraticActionOut:ctor(action)
    self:initWithAction(action)
end

function cc.EaseQuadraticActionOut:clone()
    return EaseQuadraticActionOut:new(self._inner:clone())
end

function cc.EaseQuadraticActionOut:update(time)
    self._inner:update(cc.tweenfunc.quadraticOut(time))
end

function cc.EaseQuadraticActionOut:reverse()
    return cc.EaseQuadraticActionOut:new(self._inner:reverse())
end

--in out
cc.EaseQuadraticActionInOut = cc.EaseQuadraticActionInOut or class("EaseQuadraticActionInOut",cc.ActionEase)

function cc.EaseQuadraticActionInOut:ctor(action)
    self:initWithAction(action)
end

function cc.EaseQuadraticActionInOut:clone()
    return EaseQuadraticActionInOut:new(self._inner:clone())
end

function cc.EaseQuadraticActionInOut:update(time)
    self._inner:update(cc.tweenfunc.quadraticInOut(time))
end

function cc.EaseQuadraticActionInOut:reverse()
    return cc.EaseQuadraticActionInOut:new(self._inner:reverse())
end
------------------------EaseQuadraticAction end---------------------------

------------------------EaseQuarticAction start---------------------------
--in
cc.EaseQuarticActionIn = cc.EaseQuarticActionIn or class("EaseQuarticActionIn",cc.ActionEase)

function cc.EaseQuarticActionIn:ctor(action)
    self:initWithAction(action)
end

function cc.EaseQuarticActionIn:clone()
    return EaseQuarticActionIn:new(self._inner:clone())
end

function cc.EaseQuarticActionIn:update(time)
    self._inner:update(cc.tweenfunc.quartEaseIn(time))
end

function cc.EaseQuarticActionIn:reverse()
    return cc.EaseQuarticActionIn:new(self._inner:reverse())
end

--out
cc.EaseQuarticActionOut = cc.EaseQuarticActionOut or class("EaseQuarticActionOut",cc.ActionEase)

function cc.EaseQuarticActionOut:ctor(action)
    self:initWithAction(action)
end

function cc.EaseQuarticActionOut:clone()
    return EaseQuarticActionOut:new(self._inner:clone())
end

function cc.EaseQuarticActionOut:update(time)
    self._inner:update(cc.tweenfunc.quartEaseOut(time))
end

function cc.EaseQuarticActionOut:reverse()
    return cc.EaseQuarticActionOut:new(self._inner:reverse())
end

--in out
cc.EaseQuarticActionInOut = cc.EaseQuarticActionInOut or class("EaseQuarticActionInOut",cc.ActionEase)

function cc.EaseQuarticActionInOut:ctor(action)
    self:initWithAction(action)
end

function cc.EaseQuarticActionInOut:clone()
    return EaseQuarticActionInOut:new(self._inner:clone())
end

function cc.EaseQuarticActionInOut:update(time)
    self._inner:update(cc.tweenfunc.quartEaseInOut(time))
end

function cc.EaseQuarticActionInOut:reverse()
    return cc.EaseQuarticActionInOut:new(self._inner:reverse())
end
------------------------EaseQuarticAction end---------------------------

------------------------EaseQuinticAction start---------------------------
--in
cc.EaseQuinticActionIn = cc.EaseQuinticActionIn or class("EaseQuinticActionIn",cc.ActionEase)

function cc.EaseQuinticActionIn:ctor(action)
    self:initWithAction(action)
end

function cc.EaseQuinticActionIn:clone()
    return EaseQuinticActionIn:new(self._inner:clone())
end

function cc.EaseQuinticActionIn:update(time)
    self._inner:update(cc.tweenfunc.quintEaseIn(time))
end

function cc.EaseQuinticActionIn:reverse()
    return cc.EaseQuinticActionIn:new(self._inner:reverse())
end

--out
cc.EaseQuinticActionOut = cc.EaseQuinticActionOut or class("EaseQuinticActionOut",cc.ActionEase)

function cc.EaseQuinticActionOut:ctor(action)
    self:initWithAction(action)
end

function cc.EaseQuinticActionOut:clone()
    return EaseQuinticActionOut:new(self._inner:clone())
end

function cc.EaseQuinticActionOut:update(time)
    self._inner:update(cc.tweenfunc.quintEaseOut(time))
end

function cc.EaseQuinticActionOut:reverse()
    return cc.EaseQuinticActionOut:new(self._inner:reverse())
end

--in out
cc.EaseQuinticActionInOut = cc.EaseQuinticActionInOut or class("EaseQuinticActionInOut",cc.ActionEase)

function cc.EaseQuinticActionInOut:ctor(action)
    self:initWithAction(action)
end

function cc.EaseQuinticActionInOut:clone()
    return EaseQuinticActionInOut:new(self._inner:clone())
end

function cc.EaseQuinticActionInOut:update(time)
    self._inner:update(cc.tweenfunc.quintEaseInOut(time))
end

function cc.EaseQuinticActionInOut:reverse()
    return cc.EaseQuinticActionInOut:new(self._inner:reverse())
end
------------------------EaseQuinticAction end---------------------------

------------------------EaseCircleAction start---------------------------
--in
cc.EaseCircleActionIn = cc.EaseCircleActionIn or class("EaseCircleActionIn",cc.ActionEase)

function cc.EaseCircleActionIn:ctor(action)
    self:initWithAction(action)
end

function cc.EaseCircleActionIn:clone()
    return EaseCircleActionIn:new(self._inner:clone())
end

function cc.EaseCircleActionIn:update(time)
    self._inner:update(cc.tweenfunc.circEaseIn(time))
end

function cc.EaseCircleActionIn:reverse()
    return cc.EaseCircleActionIn:new(self._inner:reverse())
end

--out
cc.EaseCircleActionOut = cc.EaseCircleActionOut or class("EaseCircleActionOut",cc.ActionEase)

function cc.EaseCircleActionOut:ctor(action)
    self:initWithAction(action)
end

function cc.EaseCircleActionOut:clone()
    return EaseCircleActionOut:new(self._inner:clone())
end

function cc.EaseCircleActionOut:update(time)
    self._inner:update(cc.tweenfunc.circEaseOut(time))
end

function cc.EaseCircleActionOut:reverse()
    return cc.EaseCircleActionOut:new(self._inner:reverse())
end

--in out
cc.EaseCircleActionInOut = cc.EaseCircleActionInOut or class("EaseCircleActionInOut",cc.ActionEase)

function cc.EaseCircleActionInOut:ctor(action)
    self:initWithAction(action)
end

function cc.EaseCircleActionInOut:clone()
    return EaseCircleActionInOut:new(self._inner:clone())
end

function cc.EaseCircleActionInOut:update(time)
    self._inner:update(cc.tweenfunc.circEaseInOut(time))
end

function cc.EaseCircleActionInOut:reverse()
    return cc.EaseCircleActionInOut:new(self._inner:reverse())
end
------------------------EaseCircleAction end---------------------------

------------------------EaseCubicAction start---------------------------
--in
cc.EaseCubicActionIn = cc.EaseCubicActionIn or class("EaseCubicActionIn",cc.ActionEase)

function cc.EaseCubicActionIn:ctor(action)
    self:initWithAction(action)
end

function cc.EaseCubicActionIn:clone()
    return EaseCubicActionIn:new(self._inner:clone())
end

function cc.EaseCubicActionIn:update(time)
    self._inner:update(cc.tweenfunc.cubicEaseIn(time))
end

function cc.EaseCubicActionIn:reverse()
    return cc.EaseCubicActionIn:new(self._inner:reverse())
end

--out
cc.EaseCubicActionOut = cc.EaseCubicActionOut or class("EaseCubicActionOut",cc.ActionEase)

function cc.EaseCubicActionOut:ctor(action)
    self:initWithAction(action)
end

function cc.EaseCubicActionOut:clone()
    return EaseCubicActionOut:new(self._inner:clone())
end

function cc.EaseCubicActionOut:update(time)
    self._inner:update(cc.tweenfunc.cubicEaseOut(time))
end

function cc.EaseCubicActionOut:reverse()
    return cc.EaseCubicActionOut:new(self._inner:reverse())
end

--in out
cc.EaseCubicActionInOut = cc.EaseCubicActionInOut or class("EaseCubicActionInOut",cc.ActionEase)

function cc.EaseCubicActionInOut:ctor(action)
    self:initWithAction(action)
end

function cc.EaseCubicActionInOut:clone()
    return EaseCubicActionInOut:new(self._inner:clone())
end

function cc.EaseCubicActionInOut:update(time)
    self._inner:update(cc.tweenfunc.cubicEaseInOut(time))
end

function cc.EaseCubicActionInOut:reverse()
    return cc.EaseCubicActionInOut:new(self._inner:reverse())
end
------------------------EaseQuinticAction end---------------------------
