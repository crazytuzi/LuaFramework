

WildBossManager = {}


local _data = nil
local _vipData = {};
local _allVipData = {};
local _focusData = nil --关注的boss
--local json = require "cjson"
local _savekey = ""
local _curRound = 0
local MaxTime = 3

local _vipStatus = {};

local _insert = table.insert;

function WildBossManager.Init(id)
	_curRound = 0
	_savekey = ""
	_focusData = {}	
	local _config = ConfigManager.GetConfig(ConfigManager.CONFIGNAME_WILDBOSS)
	_data = {}
	for k, v in pairs(_config) do
		_focusData[k] = false
		_data[k] = WildBossManager.BuildBoss(v);
	end
	
	_vipData = {};
	local vipCfgs = ConfigManager.GetConfig(ConfigManager.CONFIGNAME_VIP_WILDBOSS);
	for k, v in pairs(vipCfgs) do
		if _vipData[v.map_level] == nil then
			_vipData[v.map_level] = {};
		end
		_focusData[k] = false
		local info = WildBossManager.BuildBoss(v);
		info.isVip = true;
		_insert(_vipData[v.map_level], info);
		_allVipData[k] = info;
	end
	
	WildBossManager.InitFocusData(id)
end

function WildBossManager.GetWildBossIndex(id)
	for k, v in ipairs(_data) do
		if(v.id == id) then
			return k
		end
	end
	
	return 1
end

function WildBossManager.BuildBoss(v)
	local info = {}
	
	setmetatable(info, {__index = v});	
	info.rewardItem = {};
	local kind = PlayerManager.GetPlayerKind();
	for k1, v1 in ipairs(v.drop) do
		local reward = string.split(v1, "_");
		local pId = tonumber(reward[1]);
		local cId = tonumber(reward[2]);
		if cId == 0 or cId == kind then
			table.insert(info.rewardItem, ProductManager.GetProductById(pId))
		end
	end
	info.monsterInfo = {}
	setmetatable(info.monsterInfo, {__index = ConfigManager.GetMonById(v.monster_id)});
	
	info.mapInfo = {}
	setmetatable(info.mapInfo, {__index = ConfigManager.GetMapById(v.map_id)});
	local temp = string.split(v.boss_born_point, "|")
	
	info.boss_born_point = {tonumber(temp[1]), tonumber(temp[2])}
	temp = string.split(v.boss_player_point, "|")
	info.boss_player_point = {tonumber(temp[1]), tonumber(temp[2])}
	temp = string.split(v.boss_guide_point, "|")		
	info.boss_guide_point = {tonumber(temp[1]), tonumber(temp[2])}
	
	return info;
end

function WildBossManager.SetWildBossData(data)	
	if(data) then
		_curRound = data.c
		for k, v in ipairs(data.l) do
			if(_data[v.id]) then				
				_data[v.id].ln = v.ln
				_data[v.id].rt = v.rt				
			end
		end
	end
end

function WildBossManager.SetVipBossData(data)
	if data then
		_curVipRound = data.c;
		for k, v in ipairs(data.l) do
			if(_allVipData[v.id]) then				
				_allVipData[v.id].ln = v.ln
				_allVipData[v.id].rt = v.rt
			end
		end
		MessageManager.Dispatch(WildBossNotes, WildBossNotes.RSP_VIP_BOSS_INFO);
	end
end

function WildBossManager.GetWildBossData(id)
	return _data[id]
end

function WildBossManager.GetAllWildBossData()
	return _data
end

function WildBossManager.GetAllVipBossData()
	return _vipData;
end

function WildBossManager.GetFucusData()
	return _focusData	
end

--boss是否关注
function WildBossManager.IsBossFocus(id)
	
	return _focusData[id] or false
end

--初始化关注boss的数据 要在有玩家Id后再初始化
function WildBossManager.InitFocusData(id)
	_savekey = "wildBoss" .. id	
	local str = Util.GetString(_savekey)
	
	if(str and str ~= "") then	
		local tmp = string.split(str, ",");
		for i, v in ipairs(tmp) do
			_focusData[tonumber(v)] = true;
		end
	end
end

function WildBossManager.SaveFocusData(id, enable)
	_focusData[id] = enable
	
	WildBossManager._SaveFocusData()
end

function WildBossManager._SaveFocusData()
	local tmp = {};
	for k, v in pairs(_focusData) do
		if v then
			_insert(tmp, k);
		end
	end
	
	local str = table.concat(tmp, ",");
	Util.SetString(_savekey, str)
end

function WildBossManager.GetIsMore()
	return _curRound >= MaxTime
end

function WildBossManager.GetRoundDes()
	return(_curRound or "0") .. "/" .. MaxTime
end

function WildBossManager.GetVipRoundDes()
	return(_curVipRound or "0") .. "/" .. 10
end

function WildBossManager.GetNearestBossIndex()
	local index = 1
	local level = PlayerManager.GetPlayerLevel()
	
	for k, v in pairs(_data) do
		if(level >= v.mapInfo.level) then
			index = k			
		end
	end
	
	if(index < 1) then
		index = 1
	end
	-- return 1
	return index
end

function WildBossManager.SortBossByLv(a, b)
	local lv = PlayerManager.GetPlayerLevel();
	local f1 = lv >= a.rec_level_lower and lv <= a.rec_level_upper;
	local f2 = lv >= b.rec_level_lower and lv <= b.rec_level_upper;
	if f1 == f2 then
		return a.id < b.id;
	else
		return f1;
	end
end

function WildBossManager.UpdateVipBossData(data)
	if _allVipData[data.id] then
		_allVipData[data.id].rt = data.rt;
		MessageManager.Dispatch(WildBossNotes, WildBossNotes.RSP_VIP_BOSS_INFO);
	end
end

function WildBossManager.GetVipBossListInMap()
	local mapId = tonumber(GameSceneManager.id);
	local list = {};
	for k, v in pairs(_allVipData) do
		if v.mapInfo.id == mapId then
			_insert(list, v);
		end
	end
	return list;
end 