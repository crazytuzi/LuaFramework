YaoShouManager = {}

local _data = nil
local _config = ConfigManager.GetConfig(ConfigManager.CONFIG_YAOSHOU_BOSS)

local firstCount = 0;
local killCount = 0;

function YaoShouManager.Init()
	_data = {}
	firstCount = 0;
	killCount = 0;
	for k, v in pairs(_config) do
		if v.type == 1 then
			_data[k] = YaoShouManager.BuildBoss(v);
		end
	end
end

function YaoShouManager.SetBossData(data)
	if(data) then
		firstCount = data.fc;
		killCount = data.kc;
		for k, v in ipairs(data.l) do
			if(_data[v.id]) then				
				_data[v.id].ln = v.ln
				_data[v.id].rt = v.rt
			end
		end
	end
end

function YaoShouManager.BuildBoss(v)
	local info = {}
	
	setmetatable(info, {__index = v});	
	info.rewardF = {};
	info.rewardK = {};
	local kind = PlayerManager.GetPlayerKind();
	for k1, v1 in ipairs(v.firstattack_show) do
		local reward = string.split(v1, "_");
		local pId = tonumber(reward[1]);
		local cId = tonumber(reward[2]);
		if cId == 0 or cId == kind then
			table.insert(info.rewardF, ProductManager.GetProductById(pId))
		end
	end
	for k1, v1 in ipairs(v.lastattack_show) do
		local reward = string.split(v1, "_");
		local pId = tonumber(reward[1]);
		local cId = tonumber(reward[2]);
		if cId == 0 or cId == kind then
			table.insert(info.rewardK, ProductManager.GetProductById(pId))
		end
	end

	info.monsterInfo = {}
	setmetatable(info.monsterInfo, {__index = ConfigManager.GetMonById(v.monster_id)});
	
	info.mapInfo = {}
	setmetatable(info.mapInfo, {__index = ConfigManager.GetMapById(v.boss_born_map)});
	local temp = string.split(v.boss_born_point, "|")
	
	info.boss_born_point = {tonumber(temp[1]), tonumber(temp[2])}
	--temp = string.split(v.boss_player_point, "|")
	--info.boss_player_point = {tonumber(temp[1]), tonumber(temp[2])}
	--temp = string.split(v.boss_guide_point, "|")		
	--info.boss_guide_point = {tonumber(temp[1]), tonumber(temp[2])}
	
	return info;
end

function YaoShouManager.GetAllBossData()
	local _list = {};
	for k, v in pairs(_data) do
		table.insert(_list, v);
	end
	return _list;
end

function YaoShouManager.GetFCNum()
	return firstCount;
end

function YaoShouManager.GetKCNum()
	return killCount;
end