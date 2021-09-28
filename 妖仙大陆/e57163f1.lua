local Util = require "Zeus.Logic.Util"
local SliderExt = {}
Util.WrapOOPSelf(SliderExt)

function SliderExt.New(gauge, thumb, value, onChangeCallback, isHorizontal, onLastChangeCallback)
    local o = {}
    setmetatable(o, SliderExt)
    o:_init(gauge, thumb, value, onChangeCallback, isHorizontal, onLastChangeCallback)
    return o
end

function SliderExt:getValue()
    return self._gauge.Value
end

function SliderExt:setValue(v)
    self._gauge.Value = v
    v = self._gauge.Value
    local min = self._gauge.GaugeMinValue
    local max = self._gauge.GaugeMaxValue
    v = (v - min) / (max - min)
    v = (self._right - self._left) * v + self._left
    local p = Vector2.New(0, 0)
    if self._isHorizontal then
        p.x, p.y = v - self._thumbHelf, self._thumbFix
    else
        p.x, p.y = self._thumbFix, v - self._thumbHelf
    end
    self._thumb.Position2D = p
end

function SliderExt:_init(gauge, thumb, value, onChangeCallback, isHorizontal, onLastChangeCallback)
    self._gauge = gauge
    self._gauge.UnityObject:AddComponent(typeof(InvalidDrag))
    self._thumb = thumb
    self._callback = onChangeCallback
    self._lastChangeCallback = onLastChangeCallback
    self._isHorizontal = isHorizontal
    local thumbSize = self._thumb.Size2D
    self._thumbHelf = ((isHorizontal and thumbSize.x) or thumbSize.y) * 0.5
    self._thumbFix = (isHorizontal and thumb.Position2D.y) or thumb.Position2D.x
    self._left = (isHorizontal and gauge.Position2D.x) or gauge.Position2D.y
    self._right = self._left + ((isHorizontal and gauge.Size2D.x) or gauge.Size2D.y)
    self:setValue(value or self._gauge.GaugeMinValue)
    thumb.Enable = true
    gauge.Enable = false
    
    
    
    
    
    

    thumb.EnableChildren = true
    thumb.IsInteractive = true
    thumb.EnableOutMove = true
    thumb.event_PointerUp = self._self_onTouchUp
    thumb.event_PointerDown = self._self_onTouchMove
    thumb.event_PointerMove = self._self_onTouchMove
end

function SliderExt:onTouchUp(sender, pointerEventData)
    self:onTouchMove(sender, pointerEventData)
    if self._lastChangeCallback then
        self._lastChangeCallback(self._value)
    end
end

function SliderExt:onTouchMove(sender,pointerEventData)
    print("pointerEventData")
    local p = self._thumb.Parent:ScreenToLocalPoint2D(pointerEventData)
    local x = (self._isHorizontal and p.x) or p.y
    if x < self._left then
        x = self._left
    elseif x > self._right then
        x = self._right
    end
    if self._isHorizontal then
        p.x, p.y = x - self._thumbHelf, self._thumbFix
    else
        p.x, p.y = self._thumbFix, x - self._thumbHelf
    end

    self._thumb.Position2D = p
    self._value = (x - self._left) / (self._right - self._left) * 100
    self._gauge.ValuePercent = self._value
    if self._callback then
        self._callback(self._value)
    end
end

return SliderExt
