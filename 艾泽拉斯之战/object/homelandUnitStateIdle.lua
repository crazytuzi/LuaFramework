homelandUnitStateIdle = class("homelandUnitStateIdle", homelandUnitState);

function homelandUnitStateIdle:init()
	
	if self.unit then
		self.playTime = self.unit:PlaySkill("idle", false, false, 1.0, -1, -1, "", false);
	end
	
	self.playTime = 2 * self.playTime * 0.001;
	
	--print("self.playTime "..self.playTime);
end

function homelandUnitStateIdle:destroy()

end

function homelandUnitStateIdle:tick(dt)
	
	if self.playTime <= 0 then
		self.unit:setState(homelandUnitStateMove);
	else
		self.playTime = self.playTime - dt;
	end
end
