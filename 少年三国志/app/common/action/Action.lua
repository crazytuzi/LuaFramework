-- CCFAction

-- to visit global function quickly we need to assign it to the local variable
local MIN = math.min
local MAX = math.max

local POINT = function(_x, _y)
    local _t = {_x, _y}
    setmetatable(_t, {__index = function(t, k)
        if k == "x" then return t[1]
        elseif k == "y" then return t[2]
        end
    end})
    return _t
end
local ADD = function(point1, point2)
    return POINT(point1.x+point2.x, point1.y+point2.y)
end
local SUB = function(point1, point2)
    return POINT(point1.x-point2.x, point1.y-point2.y)
end
local MULT = function(point, factor)
    return POINT(point.x*factor, point.y*factor)
end

local RECT = function(_x, _y, _w, _h)
    return {origin=POINT(_x, _y), size={width=_w, height=_h}}
end
local SIZE = function(_w, _h)
    return {width=_w, height=_h}
end

-- base class
-- CCFAction

local CCFAction = class "CCFAction"

function CCFAction:isDone() return true end
function CCFAction:isRunning() return self._isRunning end

function CCFAction:retain() end
function CCFAction:release() end

function CCFAction:startWithTarget(target)
    assert(target, "Target could not be nil !")
    self._target = target
    self._isRunning = true
end

function CCFAction:step(dt) end
function CCFAction:stop() self._isRunning = false end

function CCFAction:_update(dt) end

-- CCFActionInterval
local CCFActionInterval = class("CCFActionInterval", CCFAction)

function CCFActionInterval:ctor(totalFrame)
    CCFActionInterval.super.ctor(self)
    assert(totalFrame and totalFrame > 0, "Totalframe could not be nil or negative !")
    -- 当前帧数和总帧数
    self._curFrame = 0
    self._totalFrame = totalFrame
end

function CCFActionInterval:getTotalFrame() return self._totalFrame end

function CCFActionInterval:step(dt)
    self._isRunning = not self:isDone()
    self._curFrame = self._curFrame + dt
    self:_update(MIN(MAX(0, self._curFrame / self._totalFrame), 1))
end

function CCFActionInterval:isDone() return self._curFrame >= self._totalFrame end

function CCFActionInterval:stop()
    CCFActionInterval.super.stop(self)
    self._curFrame = 0
end

-- CCFMoveTo
local CCFMoveTo = class("CCFMoveTo", CCFActionInterval)

function CCFMoveTo:ctor(totalFrame, destination)
    CCFMoveTo.super.ctor(self, totalFrame)
    -- 预期目标
    self._destination = destination
end

function CCFMoveTo:startWithTarget(target)
    CCFMoveTo.super.startWithTarget(self, target)
    self._original = POINT(target:getPosition())
    -- 计算差值
    self._delta = SUB(self._destination, self._original)
end

function CCFMoveTo:_update(dt)
    CCFMoveTo.super._update(self, dt)
    self._target:setPositionXY(unpack(ADD(self._original, MULT(self._delta, dt))))
end

-- CCFMoveBy
local CCFMoveBy = class("CCFMoveBy", CCFMoveTo)

function CCFMoveBy:startWithTarget(target)
    CCFMoveBy.super.startWithTarget(self, target)
    self._delta = self._destination
    self._destination = ADD(self._original, self._delta)
end

-- CCFRotateTo

local CCFRotateTo = class("CCFRotateTo", CCFActionInterval)

function CCFRotateTo:ctor(totalFrame, destination)
    CCFRotateTo.super.ctor(self, totalFrame)
    self._destination = destination
end

function CCFRotateTo:startWithTarget(target)
    CCFRotateTo.super.startWithTarget(self, target)
    self._original = target:getRotation()
    self._delta = self._destination - self._original
end

function CCFRotateTo:_update(dt)
    CCFRotateTo.super._update(self, dt)
    self._target:setRotation(self._original + self._delta * dt)
end

-- CCFRotateBy

local CCFRotateBy = class("CCFRotateBy", CCFRotateTo)

function CCFRotateBy:startWithTarget(target)
    CCFRotateBy.super.startWithTarget(self, target)
    self._delta = self._destination
    self._destination = self._original + self._delta
end

-- CCFScaleTo

local CCFScaleTo = class("CCFScaleTo", CCFActionInterval)

function CCFScaleTo:ctor(totalFrame, destination, destination1)
    CCFScaleTo.super.ctor(self, totalFrame)
    self._destination = destination
    self._destination1 = destination1
end

function CCFScaleTo:startWithTarget(target)
    CCFScaleTo.super.startWithTarget(self, target)
    if self._destination1 then
        self._original = target:getScaleX()
        self._original1 = target:getScaleY()
        self._delta = self._destination - self._original
        self._delta1 = self._destination1 - self._original1
    else
        self._original = target:getScale()
        self._delta = self._destination - self._original
    end
end

function CCFScaleTo:_update(dt)
    CCFScaleTo.super._update(self, dt)
    if self._destination1 then
        self._target:setScaleX(self._original + self._delta * dt)
        self._target:setScaleY(self._original1 + self._delta1 * dt)
    else
        self._target:setScale(self._original + self._delta * dt)
    end
end

-- CCFScaleBy

local CCFScaleBy = class("CCFScaleBy", CCFScaleTo)

function CCFScaleBy:startWithTarget(target)
    CCFScaleBy.super.startWithTarget(self, target)
    self._delta = self._destination
    self._delta1 = self._destination1
    self._destination = self._original + self._delta
    if self._destination1 then
        self._destination1 = self._original1 + self._delta1
    end
end

-- CCFSkewTo
local CCFSkewTo = class("CCFSkewTo", CCFActionInterval)

function CCFSkewTo:ctor(totalFrame, destination, destination1)
    CCFSkewTo.super.ctor(self, totalFrame)
    self._skewX = destination
    self._skewY = destination1
end

function CCFSkewTo:startWithTarget(target)
    CCFSkewTo.super.startWithTarget(self, target)
    self._originalSkewX = target:getSkewX()

    if self._originalSkewX > 0 then
        self._originalSkewX = math.fmod(self._originalSkewX, 180)
    else
        self._originalSkewX = math.fmod(self._originalSkewX, -180)
    end

    self._skewDeltaX = self._skewX - self._originalSkewX

    if self._skewDeltaX > 180 then
        self._skewDeltaX = self._skewDeltaX - 360
    end
    if self._skewDeltaX < -180 then
        self._skewDeltaX = self._skewDeltaX + 360
    end

    self._originalSkewY = target:getSkewY()

    if self._originalSkewY > 0 then
        self._originalSkewY = math.fmod(self._originalSkewY, 360)
    else
        self._originalSkewY = math.fmod(self._originalSkewY, -360)
    end

    self._skewDeltaY = self._skewY - self._originalSkewY

    if self._skewDeltaY > 180 then
        self._skewDeltaY = self._skewDeltaY - 360
    end
    if self._skewDeltaY < -180 then
        self._skewDeltaY = self._skewDeltaY + 360
    end
end

function CCFSkewTo:_update(dt)
    CCFSkewTo.super._update(self, dt)
    self._target:setSkewX(self._originalSkewX + self._skewDeltaX * dt);
    self._target:setSkewY(self._originalSkewY + self._skewDeltaY * dt);
end

-- CCFFadeTo

local CCFFadeTo = class("CCFFadeTo", CCFActionInterval)

function CCFFadeTo:ctor(totalFrame, destination)
    CCFFadeTo.super.ctor(self, totalFrame)
    self._destination = destination
end

function CCFFadeTo:startWithTarget(target)
    CCFFadeTo.super.startWithTarget(self, target)
    self._original = target:getOpacity()
    self._delta = self._destination - self._original
end

function CCFFadeTo:_update(dt)
    CCFFadeTo.super._update(self, dt)
    self._target:setOpacity(self._original + self._delta * dt)
end

-- CCFColorTo

local CCFColorTo = class("CCFColorTo", CCFActionInterval)

function CCFColorTo:ctor(totalFrame, destination)
    CCFColorTo.super.ctor(self, totalFrame)
    self._destination = destination
end

function CCFColorTo:startWithTarget(target)
    CCFColorTo.super.startWithTarget(self, target)
    local color = {target:getColorRGB()}
    self._original = {r=color[1], g=color[2], b=color[3]}
    self._delta = {r=self._destination.r - self._original.r, g=self._destination.g - self._original.g, b=self._destination.b - self._original.b}
end

function CCFColorTo:_update(dt)
    CCFColorTo.super._update(self, dt)
--    local color = ccc3(self._original.r + self._delta.r * dt, self._original.g + self._delta.g * dt, self._original.b + self._delta.b * dt)
    self._target:setColorRGB(self._original.r + self._delta.r * dt, self._original.g + self._delta.g * dt, self._original.b + self._delta.b * dt)
end

-- CCFColorOffsetTo

local CCFColorOffsetTo = class("CCFColorOffsetTo", CCFActionInterval)

function CCFColorOffsetTo:ctor(totalFrame, destination)
    CCFColorOffsetTo.super.ctor(self, totalFrame)
    self._destination = destination
end

function CCFColorOffsetTo:startWithTarget(target)
    CCFColorOffsetTo.super.startWithTarget(self, target)
    local colorOffset = {target:getColorRGBA()}
    colorOffset = {r=colorOffset[1], g=colorOffset[2], b=colorOffset[3], a=colorOffset[4]}
    self._original = {r=colorOffset.r, g=colorOffset.g, b=colorOffset.b, a=colorOffset.a}
    self._delta = {r=self._destination.r - self._original.r, g=self._destination.g - self._original.g, b=self._destination.b - self._original.b, a=self._destination.a - self._original.a}
end

function CCFColorOffsetTo:_update(dt)
    CCFColorOffsetTo.super._update(self, dt)
--    local color = ccc4f(self._original.r + self._delta.r * dt, self._original.g + self._delta.g * dt, self._original.b + self._delta.b * dt, self._original.a + self._delta.a * dt)
    self._target:setColorOffsetRGBA(self._original.r + self._delta.r * dt, self._original.g + self._delta.g * dt, self._original.b + self._delta.b * dt, self._original.a + self._delta.a * dt)
end

-- CCFSpawn

local CCFSpawn = class("CCFSpawn", CCFActionInterval)

function CCFSpawn:ctor(actions)
    local totalFrame = 1
    for i=1, #actions do
        if actions[i] and actions[i]:getTotalFrame() > totalFrame then
            totalFrame = actions[i]:getTotalFrame()
        end
    end
    self._actions = actions
    CCFSpawn.super.ctor(self, totalFrame)
end

function CCFSpawn:startWithTarget(target)
    CCFSpawn.super.startWithTarget(self, target)
    
    for i=1, #self._actions do
        if self._actions[i] then
            self._actions[i]:startWithTarget(target)
        end
    end
end

function CCFSpawn:_update(dt)
    CCFSpawn.super._update(self, dt)
    
    for i=1, #self._actions do
        if self._actions[i] then
            self._actions[i]:_update(dt)
        end
    end
end

-- CCFShake

local CCFShake = class("CCFShake", CCFActionInterval)

function CCFShake:ctor(totalFrame, strengthX, strengthY)
    self._strengthX = strengthX
    self._strengthY = strengthY
    CCFShake.super.ctor(self, totalFrame)
end

local function fgRangeRand(_min, _max)
    local rnd = math.random(0, 1)
    return rnd * (_max - _min) + _min
end

function CCFShake:startWithTarget(target)
    CCFShake.super.startWithTarget(self, target)
    self._originalX, self._originalY = target:getPosition()
end

function CCFShake:_update(dt)
    CCFShake.super._update(self, dt)
    local randX = fgRangeRand(-self._strengthX, self._strengthX) * dt
    local randY = fgRangeRand(-self._strengthY, self._strengthY) * dt
    self._target:setPositionXY(unpack(ADD(POINT(self._originalX, self._originalY), POINT(randX, randY))))
end

function CCFShake:stop()
    CCFShake.super.stop(self)
    if self._target then self._target:setPositionXY(unpack(POINT(self._originalX, self._originalY))) end
end

-- CCFFocusOn

local CCFFocusOn = class("CCFFocusOn", CCFActionInterval)

function CCFFocusOn:ctor(totalFrame, destination)
    CCFFocusOn.super.ctor(self, totalFrame)
    self._focusRect = destination
end

function CCFFocusOn:startWithTarget(target)
    
    CCFFocusOn.super.startWithTarget(self, target)
    
    -- 原始的缩放比
    self._originalScale = target:getScale()
    -- 计算需要缩放的比例
    local size = target:getContentSize();
    self._scaleFactor = MIN(size.width / self._focusRect.size.width, size.height / self._focusRect.size.height) - self._originalScale;
    
    -- 原始位置
    self._originalPosition = POINT(target:getPosition());

    -- 计算需要移动的距离，我们认为被关注的区域会自动对齐屏幕的显示(居中显示)
    self._original = SUB(target:convertToWorldSpaceXY(unpack(ADD(self._focusRect.origin, POINT(self._focusRect.size.width/2, self._focusRect.size.height/2))), POINT(display.width/2, display.height/2)));

--    print("original: "..self._original.x.." "..self._original.y);

    -- 移动位置正相反
    self._positionMove = MULT(self._original, -1);
    
    -- 反转的窗口
    self._reverseRect = RECT(0, 0, 0, 0)
    self._reverseRect.origin = target:convertToWorldSpaceXY(unpack(self._reverseRect.origin))
    
    self._reverseRect.size = CCDirector:sharedDirector():getWinSize();
    self._reverseRect.size = CCSize(target:convertToNodeSpaceXY(unpack(SUB(POINT(self._reverseRect.size.width, self._reverseRect.size.height)), self._reverseRect.origin)));
    
end

function CCFFocusOn:_update(dt)
    CCFFocusOn.super._update(self, dt)
    
    self._target:setScale(self._originalScale + dt * self._scaleFactor)

    -- 缩放过后实际显示位置会偏移，这里需要重新校准初始位置，把其移动到默认初始位置（以左下角坐标为基准）
    self._target:setPositionXY(unpack(self._originalPosition));
    local offset = SUB(SUB(self._target:convertToWorldSpaceXY(unpack(ADD(self._focusRect.origin, POINT(self._focusRect.size.width/2, self._focusRect.size.height/2))), POINT(display.width/2, display.height/2)), self._original));

    -- print("original: {%f, %f}, offset: {%f, %f}, m_positionMove * t : {%f, %f}", self._originalPosition.x, self._originalPosition.y, offset.x, offset.y, (self._positionMove * t).x, (self._positionMove * t).y);
    self._target:setPositionXY(unpack(ADD(SUB(self._originalPosition, offset), POINT(self._positionMove.x * dt, self._positionMove.y * dt))))
    
end

function CCFFocusOn:reverse()
--    return CCFFocusOn.new(self._totalFrame, RECT(0, 0, display.width, display.height));
    return CCFFocusOn.new(self._totalFrame, self._reverseRect);
end

function CCFFocusOn:stop()
    CCFFocusOn.super.stop(self)
    self._target:setPositionXY(unpack(self._originalPosition))
    self._target:setScale(self._originalScale)
end

-- CCFDelayTime

local CCFDelayTime = class("CCFDelayTime", CCFActionInterval)

-- CCFSequence

local CCFSequence = class("CCFSequence", CCFActionInterval)

function CCFSequence:ctor(actions)
    -- 动作列表
    local totalFrame = 1
	self._actions = {}
    for i=1, #actions do
        if actions[i] then
            totalFrame = totalFrame + actions[i]:getTotalFrame()
            self._actions[#self._actions+1] = actions[i]
        end
    end

    CCFSequence.super.ctor(self, totalFrame)
end

function CCFSequence:_update(dt)
    CCFSequence.super._update(self, dt)

    if not self._actions[1]:isRunning() then
        self._actions[1]:startWithTarget(self._target)
    end
    self._actions[1]:_update(dt)
    if self._actions[1]:isDone() then
        table.remove(self._actions, 1)
    end
end

-- CCFActionInstance

local CCFActionInstance = class("CCFActionInstance", CCFAction)

function CCFActionInstance:ctor()
    CCFActionInstance.super.ctor(self)
    -- 当前帧数和总帧数
    self._curFrame = 0
    self._totalFrame = 1
end

function CCFActionInstance:step(dt)
    self._isRunning = not self:isDone()
    self._curFrame = 1
    self:_update(self._curFrame / self._totalFrame)
end

function CCFActionInstance:isDone() return self._curFrame >= self._totalFrame end

-- CCFRemoveSelf

local CCFRemoveSelf = class("CCFRemoveSelf", CCFActionInstance)
function CCFRemoveSelf:_update(dt) self._target:removeFromParent() end

-- CCFHide

local CCFHide = class("CCFHide", CCFActionInstance)
function CCFHide:_update(dt) self._target:setVisible(false) end

-- CCFShow

local CCFShow = class("CCFShow", CCFActionInstance)
function CCFShow:_update(dt) self._target:setVisible(true) end

-- CCFCallFunc

local CCFCallFunc = class("CCFCallFunc", CCFActionInstance)

function CCFCallFunc:ctor(func, target)
    CCFCallFunc.super.ctor(self)
    assert(func, "Function could not be nil !")
    -- 目标函数
    self._func = func
    self._funcTarget = target
end

function CCFCallFunc:_update(dt) self._func(self._funcTarget) end

-- CCFCallFuncN

local CCFCallFuncN = class("CCFCallFuncN", CCFActionInstance)

function CCFCallFuncN:ctor(func, target)
    CCFCallFuncN.super.ctor(self)
    assert(func, "Function could not be nil !")
    self._func = func
    self._funcTarget = target
end

function CCFCallFuncN:_update(dt) self._func(self._funcTarget, self._target) end

-- factory method
local ActionFactory = {}

-- CCFActionInterval
ActionFactory.CCFActionInterval = CCFActionInterval

-- move
function ActionFactory.newMoveTo(...) return CCFMoveTo.new(...) end
function ActionFactory.newMoveBy(...) return CCFMoveBy.new(...) end

-- rotation
function ActionFactory.newRotateTo(...) return CCFRotateTo.new(...) end
function ActionFactory.newRotateBy(...) return CCFRotateBy.new(...) end

-- scale
function ActionFactory.newScaleTo(...) return CCFScaleTo.new(...) end
function ActionFactory.newScaleBy(...) return CCFScaleBy.new(...) end

-- skew
function ActionFactory.newSkewTo(...) return CCFSkewTo.new(...) end

-- opacity
function ActionFactory.newFadeTo(...) return CCFFadeTo.new(...) end

-- delay
function ActionFactory.newDelayTime(...) return CCFDelayTime.new(...) end

-- sequence
function ActionFactory.newSequence(...) return CCFSequence.new(...) end

-- spawn
function ActionFactory.newSpawn(...) return CCFSpawn.new(...) end

-- ColorOffset
function ActionFactory.newColorOffset(...) return CCFColorOffsetTo.new(...) end

-- Color
function ActionFactory.newColor(...) return CCFColorTo.new(...) end

-- shake
function ActionFactory.newShake(...) return CCFShake.new(...) end

-- focus
function ActionFactory.newFocusOn(...) return CCFFocusOn.new(...) end

-- removeself
function ActionFactory.newRemoveSelf(...) return CCFRemoveSelf.new(...) end

-- hide/show
function ActionFactory.newHide(...) return CCFHide.new(...) end
function ActionFactory.newShow(...) return CCFShow.new(...) end

-- callfunc
function ActionFactory.newCallFuncN(...) return CCFCallFuncN.new(...) end
function ActionFactory.newCallFunc(...) return CCFCallFunc.new(...) end


return ActionFactory
