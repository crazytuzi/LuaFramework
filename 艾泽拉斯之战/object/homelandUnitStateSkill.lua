homelandUnitStateSkill = class("homelandUnitStateSkill", homelandUnitState);

function homelandUnitStateSkill:init(skillname)
	
	if self.unit then
		self.playTime = self.unit:PlaySkill(skillname, false, false, 1.0, -1, -1, "", false);
	end
	
	self.playTime = self.playTime * 0.001;
	
end

function homelandUnitStateSkill:destroy()

end

function homelandUnitStateSkill:tick(dt)

	if self.playTime <= 0 then
		self.unit:setState(homelandUnitStateMove);
	else
		self.playTime = self.playTime - dt;
	end
	
end
