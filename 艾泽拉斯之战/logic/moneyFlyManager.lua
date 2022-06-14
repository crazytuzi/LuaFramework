moneyFlyManager = class("moneyFlyManager");

moneyFlyManager.guid = 1;

function moneyFlyManager:ctor()
	
	self.instances = {};
	
end

function moneyFlyManager:destroy()
	
	for k,v in pairs(self.instances) do
		v:destroy();
	end
	
	self.instances = {};
	
end

function moneyFlyManager:createMoneyFly(moneyType, spriteCount, startPos, endPos)
	
	local imageName = "";
	if enum.MONEY_ICON_STRING[moneyType] then
		imageName = enum.MONEY_ICON_STRING[moneyType];
	else
		imageName = moneyType;
		moneyType = enum.MONEY_TYPE.MONEY_TYPE_INVALID;
	end
	
	local instance = moneyFlyObject.new(imageName, spriteCount, startPos, endPos);
	
	instance:setMoneyType(moneyType);
		
	instance:setGUID(moneyFlyManager.guid);
	
	instance:init();
	
	table.insert(self.instances, instance);
	
	moneyFlyManager.guid = moneyFlyManager.guid + 1;
	
	return instance;
	
end

function moneyFlyManager:destoryMoneyFly(instance)
	
	local pos = nil;
	
	for k, v in pairs(self.instances) do
		if v == instance then
			pos = k;
			break;
		end
	end
	
	if pos then
		self.instances[pos]:destory();
		table.remove(self.instances, pos);
	end
	
	instance = nil;
end

function moneyFlyManager:tick(dt)
	
	local deleteList = {};
	
	for k,v in pairs(self.instances) do
		local shouldTick = v:tick(dt);
		
		if not shouldTick then
			table.insert(deleteList, v);
		end
		
	end
	
	for k,v in pairs(deleteList) do
		self:destoryMoneyFly(v);
	end
	
	deleteList = nil;
	
end
