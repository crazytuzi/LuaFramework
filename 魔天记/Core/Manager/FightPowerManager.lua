FightPowerManager = {}
local fightCapacity = {}
local fightCapacityData = {}
local myCareerConfig = {}

function FightPowerManager.Init()
	fightCapacity = ConfigManager.GetConfig(ConfigManager.CONFIGNAME_FIGHAT_CAPACITY)
	fightCapacityData = {}
	
	for k, v in pairs(fightCapacity) do
		if(fightCapacityData[v.career] == nil) then
			fightCapacityData[v.career] = {}
		end
		fightCapacityData[v.career] [v.nature] = v.value
	end
end

function FightPowerManager.SetMyCareer(c)
	myCareerConfig = fightCapacityData[c]
  
	if(myCareerConfig == nil) then	
		myCareerConfig = fightCapacityData[0]
	end
end

function FightPowerManager.CalculatePower(data, isCareer)
	local config = {}
   
	if(isCareer ~= nil and isCareer == true) then
		config = myCareerConfig  
	else
		config = fightCapacityData[0]
	end
	local sum = 0
	for k, v in pairs(config) do
		if(data[k] ~= nil) then
			sum = sum +(data[k] * v)
		end
	end
 
	sum = math.floor(sum);
	
	return sum
end

function CalculatePower(data, isCareer)
	if(data == nil) then return 0 end
	return FightPowerManager.CalculatePower(data, isCareer)
end 