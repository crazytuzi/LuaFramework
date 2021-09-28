local Util = require "Zeus.Logic.Util"


local FlickHVExt = {}
Util.WrapOOPSelf(FlickHVExt)

function FlickHVExt.New(canvas, hFunc, vFunc)
    local o = {}
    setmetatable(o, FlickHVExt)
    o:_init(canvas, hFunc, vFunc)
end

function FlickHVExt:_init(canvas, hFunc, vFunc)
    self._canvas = canvas
    self._hFunc = hFunc
    self._vFunc = vFunc
    self._canvas.event_PointerDown = self._self__onTouchDown
    self._canvas.event_PointerUp = self._self__onTouchUp
    self._beginPos = Vector2.New()
    self._beginTime = 0
end

function FlickHVExt:_onTouchDown(sender, e)
    self._beginTime = os.clock()
    self._beginPos = e.position
end

function FlickHVExt:_onTouchUp(sender, e)
    if os.clock() - self._beginTime > 1 then return end

    local dir = e.position - self._beginPos
    if dir:SqrMagnitude() < 25 then return end

    local degrees = math.atan2(dir.y, dir.x)
    local angle = (degrees / math.pi * 180 + 360) % 360
    if self._hFunc then
        if angle < 30 or angle > 330 then
            
            self._hFunc(false)
        elseif angle > 150 and angle < 210 then
            
            self._hFunc(true)
        end
    end
    if self._vFunc then
        if angle > 60 and angle < 120 then
            
            self._vFunc(true)
        elseif angle > 240 and angle < 300 then
            
            self._vFunc(false)
        end
    end
end

return FlickHVExt
