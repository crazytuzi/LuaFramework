
moneyFlyObject = class("moneyFlyObject");

function moneyFlyObject:ctor(imageName, spriteCount, startPos, endPos)
	
	self.spriteCount = spriteCount;
	self.startPos = startPos;
	self.endPos = endPos;
	self.imageName = imageName;
	
	self.spriteList = {};
	
	self.time = 0;
	
end

function moneyFlyObject:init()

	local width = LORD.UDim(0, 40);
	local height = LORD.UDim(0, 40);
	
	for i=1, self.spriteCount do
		
		local sprite = imageSprite.new("money"..self:getGUID().."_"..i);
		sprite:initSprite();
		sprite:SetWidth(width);
		sprite:SetHeight(height);
		sprite:SetImage(self.imageName);
		sprite:SetVisible(false);
		sprite:setStartTime( 0.6 * i / self.spriteCount);
		sprite:SetLevel(0);
		sprite:SetXPosition(LORD.UDim(0, self.startPos.x));
		sprite:SetYPosition(LORD.UDim(0, self.startPos.y));
		sprite:setStartPos(self.startPos);
		sprite:setEndPos(self.endPos);
		sprite:setMoneyType(self.moneyType);
		
		table.insert(self.spriteList, sprite);
		
	end
	
end

function moneyFlyObject:setGUID(guid)
	self.guid = guid;
end

function moneyFlyObject:getGUID()
	return self.guid;
end

function moneyFlyObject:destory()
	
	for k,v in pairs(self.spriteList) do
		v:destory();
	end
	
	self.spriteList = nil;
	
end

function moneyFlyObject:setMoneyType(moneyType)
	self.moneyType = moneyType;
end

function moneyFlyObject:tick(dt)
	
	local shouldTick = false;
	
	for k,v in pairs(self.spriteList) do
		if not v:isDelete() then
			shouldTick = true;
			v:tick(dt);
		end
	end
	
	self.time = self.time + dt;
	
	return shouldTick;
end


