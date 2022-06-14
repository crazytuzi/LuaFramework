homelandUnitStateMove = class("homelandUnitStateMove", homelandUnitState);

function homelandUnitStateMove:init()
	
	if not self.unit then
		return;
	end
	
	self.unit:PlaySkill("run", false, false, 1.0, -1, -1, "", false);
	
	local angel = math.random();
	angel = angel * math.PI * 2;
	
	self.unit:setRotateAngle(angel);
	
	local q = LORD.Quaternion(LORD.Vector3(0,1,0),angel);
	--local q = LORD.Quaternion(LORD.Vector3(0, 1, 0), angle);
	
	self.movedir = q * LORD.Vector3(0, 0, 1);
	self.movespeed = 1;
	
	self.minPlayTimeInterval = 4;
	self.maxPlayTimeInterval = 6;
	
	-- ÇÐ»»¼ä¸ô
	self.playTimeInterval = self.minPlayTimeInterval + math.random() * (self.maxPlayTimeInterval - self.minPlayTimeInterval);

end

function homelandUnitStateMove:destroy()

end

function homelandUnitStateMove:tick(dt)
	if not self.unit then
		return;
	end
	
	local position = self.unit:GetPosition();
	position = position + self.movedir * self.movespeed * dt;
	
	local distance = (self.unit:getCenterPosition() - position):len();
	if distance >= self.unit:getMoveRadius() then
		
		local angel = self.unit:getRotateAngle();
		angel = angel + math.PI;
		self.unit:setRotateAngle(angel);
		
		self.movedir = self.movedir * -1;
	else
		self.unit:SetPosition(position);
	end
	
	if self.playTimeInterval <= 0 then
		
		local skillnames = self.unit:getSkills();
		local count = #skillnames;
		count = count + 1;
		local index = math.random(1, count);
		
		if index == count then
			self.unit:setState(homelandUnitStateIdle);
		else
			self.unit:setState(homelandUnitStateWin, skillnames[index]);
		end
		
	else
		self.playTimeInterval = self.playTimeInterval - dt;
	end
end
