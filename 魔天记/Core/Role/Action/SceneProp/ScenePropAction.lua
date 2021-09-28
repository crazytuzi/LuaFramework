local ScenePropAction = class("ScenePropAction", AbsAction)

function ScenePropAction:New()
    self = { };
    setmetatable(self, { __index = ScenePropAction });
    return self
end
function ScenePropAction:_InitTimer(duration, loop)
	if(self._timer == nil) then 
		self._timer = Timer.New(function(val) self:_OnTickHandler(val) end, duration, loop, false);
		self._timer:AddCompleteListener(function(val) self:_OnTimerCompleteHandler(val) end);
	end
	if not self._timer.running then self._timer:Start() end
end


return ScenePropAction