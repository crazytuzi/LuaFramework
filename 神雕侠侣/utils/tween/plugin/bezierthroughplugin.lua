--*************************************************
-- how to use:
-- TweenNano.to(TweenTarget:new(self.m_pDownView, TweenTarget.Window),
--                    1.5, {ease = {type=TweenCirc.type, fun = TweenBack.easeInOut},
--                    plugin = BezierThroughPlugin.type, value={{x=-800, y=-80}, {x=-900, y=-680}, {x=-1000, y=-80}}})
--**************************************************
BezierThroughPlugin = {}
setmetatable(BezierThroughPlugin, BezierPlugin)
BezierThroughPlugin.__index = BezierThroughPlugin

BezierThroughPlugin.type = "bezierThroughPlugin"

function BezierThroughPlugin:initTween(target, value, tween)
	self:init(tween, value, true)
end


------//////////
return BezierThroughPlugin