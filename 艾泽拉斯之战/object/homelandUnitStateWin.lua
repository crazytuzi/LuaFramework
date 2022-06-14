homelandUnitStateWin = class("homelandUnitStateWin", homelandUnitState);

function homelandUnitStateWin:init()
	
	self.playTime = 0;
	
	--print("homelandUnitStateWin");
	if self.unit then
		self.playTime = self.unit:PlaySkill("win", false, false, 1.0, -1, -1, "", false);
	end
	
	-- play twice
	self.playTime = self.playTime * 2 * 0.001;
end

function homelandUnitStateWin:destroy()

end

function homelandUnitStateWin:tick(dt)
	
	--print("homelandUnitStateWin "..dt.." "..self.playTime);
	if self.playTime <= 0 then
		if self.unit then
			self.unit:setState(homelandUnitStateMove);
		end
	else
		self.playTime = self.playTime - dt;
	end
	
end
