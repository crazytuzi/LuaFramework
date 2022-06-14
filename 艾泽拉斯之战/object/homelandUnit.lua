-- 构造函数
function homelandUnitCreator(actorName, scale)
	local actor = LORD.ActorManager:Instance():CreateActor(actorName, "idle", false);
	
	actor:SetScale(scale);
	actor:ChangeDark(0.65);
	actor:AddPluginEffect("shadow", "", "shadow.effect");
				
	return actor;
end


homelandUnit = class("homelandUnit", homelandUnitCreator);

function homelandUnit:init(shipIndex, unitConfig)
	
	self.shipIndex = shipIndex;	
	self.unitConfig = unitConfig;
	
	self.state = nil;
	
	-- 之后从配置读取
	self.centerPostion = LORD.Vector3(0, 0, 0);
	self.moveRadius = 5;
	self.rotateAngle = 0;

end

function homelandUnit:destroy()
	
	if self then
		LORD.ActorManager:Instance():DestroyActor(self);
	end
	
	if self.state then
		self.state:destroy();
		self.state = nil;
	end
	
end

function homelandUnit:getActorName()
	return self.unitConfig.resourceName;
end

function homelandUnit:getSkills()
	local skillid = self.unitConfig.skill;
	local skillname = {};
	
	for k,v in ipairs(skillid) do
		if dataConfig.configs.skillConfig[v] and dataConfig.configs.skillConfig[v].actionName then
			table.insert(skillname, dataConfig.configs.skillConfig[v].actionName);
		end
	end
	
	return skillname;
end

function homelandUnit:setCenterPosition(pos)
	self.centerPostion = pos;
end

function homelandUnit:getCenterPosition()
	return self.centerPostion;
end

function homelandUnit:setMoveRadius(radius)
	self.moveRadius = radius;
end

function homelandUnit:getMoveRadius()
	return self.moveRadius;
end

function homelandUnit:tick(dt)
	
	if self.state then
		self.state:tick(dt);
	end

end

-- state is  class 
function homelandUnit:setState(state, ...)

	if self.state then
		self.state:destroy();
		self.state = nil;
	end
	--print("homelandUnit:setState(state) ");
	self.state = state.new(self);
	self.state:init(...);
end

-- 设置朝向
function homelandUnit:setRotateAngle(angle)
	self.rotateAngle = angle;
	
	local q = LORD.Quaternion(LORD.Vector3(0, 1, 0), angle);
	self:SetOrientation(q);
end

function homelandUnit:getRotateAngle()
	return self.rotateAngle;
end
