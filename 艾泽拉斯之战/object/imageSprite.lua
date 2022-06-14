
function imageSpriteCreator(name)
	local window = LORD.toStaticImage(LORD.GUIWindowManager:Instance():CreateGUIWindow("StaticImage", name));
	
	engine.uiRoot:AddChildWindow(window);
	
	return window;
end


imageSprite = class("imageSprite", imageSpriteCreator);

function imageSprite:initSprite()
	
	self.time = 0;
	self.playFlag = false;
	
	self.startPos = LORD.Vector2(0, 0);
	self.endPos = LORD.Vector2(0, 0);
	
	-- init data
	-- angle
	self.dir = 0; -- 45 - 135
	self.startSpeed = 0; -- pixel / s;
	
	self.startSpeedX = 0;
	self.startSpeedY = 0;
	
	self.delete = false;
end

function imageSprite:destory()
	
	if self then
		LORD.GUIWindowManager:Instance():DestroyGUIWindow(self);
	end	
	
	self = nil;
	
end

function imageSprite:start()
	self.playFlag = true;
	self:SetVisible(false);
	
	local size = 30 + math.random() * 30;
	
	self:SetWidth(LORD.UDim(0, size));
	self:SetHeight(LORD.UDim(0, size));
	
	self:SetRotate(math.random() * 360);
	self:SetLevel(-size);
end

function imageSprite:stop()
	self.playFlag = false;
end

function imageSprite:markDelete()
	self.delete = true;
end

function imageSprite:isDelete()
	return self.delete;
end

function imageSprite:setStartTime(time)
	self.startTime = time;
	
	self.dir = math.random() * 60 + 60; -- 45 - 135
	self.startSpeed = 300 + math.random() * 50; 
	
	self.startSpeedX = self.startSpeed * math.cos(math.rad(self.dir));
	
	-- y 轴向下是正
	self.startSpeedY = -self.startSpeed * math.sin(math.rad(self.dir));

end

function imageSprite:setStartPos(pos)
	self.startPos = pos;
end

function imageSprite:setEndPos(pos)
	self.endPos = pos;
end

function imageSprite:setMoneyType(moneyType)
	self.moneyType = moneyType;
end

function imageSprite:tick(dt)
	
	if not self.playFlag then
				
		self.startTime = self.startTime - dt;
		
		if self.startTime < 0 then
			self:start();
		else
			return false;
		end
	end
	
	local gravityTime = 0.8;
	local gravitya = 700;
	local a = 700;
	
	-- animate logic
	if self.time < gravityTime then
		-- 重力过程
		self:SetVisible(false)
		local xOffset = self.startPos.x + self.startSpeedX * self.time;
		local yOffset = self.startPos.y + self.startSpeedY * self.time + 0.5 * gravitya * self.time * self.time;
		
		self:SetXPosition(LORD.UDim(0, xOffset));
		self:SetYPosition(LORD.UDim(0, yOffset));
		
	else

		self:SetVisible(true);
		-- 加速过程
		local timeStamp = self.time - gravityTime;
		
		local startX = self.startPos.x + self.startSpeedX * gravityTime;
		local startY = self.startPos.y + self.startSpeedY * gravityTime + 0.5 * gravitya * gravityTime * gravityTime;
		
		local startPos = LORD.Vector2(startX, startY);
		local dir = self.endPos - startPos;
		
		-- normalize
		local length = dir:len();
		local wholeTime = math.sqrt(2 * length / a);
		
		dir.x = dir.x / length;
		dir.y = dir.y / length;
					
		local offset = startPos + dir * 0.5 * a * timeStamp * timeStamp;

		self:SetXPosition(LORD.UDim(0, offset.x));
		self:SetYPosition(LORD.UDim(0, offset.y));
		
		if timeStamp >= wholeTime then
			self:SetVisible(false);
			eventManager.dispatchEvent({name = global_event.RESOURCE_SCALE_ICON, moneyType = self.moneyType });
			
			self:stop();
			self:markDelete();
			return true;
		end
	end
	
	self.time = self.time + dt;
	
	return false;
end
