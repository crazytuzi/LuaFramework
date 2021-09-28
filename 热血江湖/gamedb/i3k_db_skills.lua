----------------- auto generate db file ------------------------
i3k_db_skills = 
{
	___loadedKeys = {},

};
local skills_mt = { __index  = function(table, key)
	if key <= 0 then
		return nil;
	end

	local fileKey = 0;
	if key < 100000 then --主角
	fileKey = math.floor(key / 10000)
	else --怪物、佣兵、神兵
	fileKey = math.floor(key / 100)
	end
	if table.___loadedKeys[fileKey] ~= nil then
		return nil;
	end
	table.___loadedKeys[fileKey] = true;

	local filename = 'script/gamedb/skills/skill_' .. fileKey
	local _call = function()
		return require(filename).get_db_table();
	end

	local _err = function()
		i3k_warn('unable load db file[' .. filename .. ']');
		--i3k_warn(debug.traceback());
	end

	local ret, _db = xpcall(_call, _err);
	if not ret then
		return nil;
	end
	for k, v in pairs(_db) do
		table[k] = v;
	end
	i3k_game_unload_script(filename);
	return table[key]
end };
setmetatable(i3k_db_skills, skills_mt);


local EMPTY_TABLE = {};
local DEFAULT_SKILLDATA_METATABLE = {__index = {studyLvl = 1, needCoin = 0, needItemID = 0, needItemNum = 0, needMP = 0, addSP = 0, cool = 0,skillpower = 0, skillrealpower = { 0, 0, 0, 0, 0,  }, spArgs1 = '', spArgs2 = '', spArgs3 = '', spArgs4 = '', spArgs5 = '', additionalDamage = 0, additionalProp = EMPTY_TABLE, additionalAiID = EMPTY_TABLE, auraAddBuffs = EMPTY_TABLE, inheritRatio = 0, summonedPopId = 0, summonedSkill = { 0, 0, 0, 0, 0,  },}}
local DEFAULT_EVENTS_DAMAGE_METATABLE = {__index = { odds = 0, atrType = 0, acrType = 0, arg1 = 0.0, arg2 = 0.0, realmAddon = 0.0 }}
local DEFAULT_EVENTS_STATUESINGLE_METATABLE = {__index = { odds = 0, buffID = 0 }}
local DEFAULT_EVENTS_STATUE_METATABLE = {__index = { { odds = 0, buffID = 0 }, { odds = 0, buffID = 0 } }}
local DEFAULT_EVENTS = { triTime = 0, hitEffID = 0, useEffID = 0, hitSoundID = 0, damage = { odds = 0, atrType = 0, acrType = 0, arg1 = 0.0, arg2 = 0.0, realmAddon = 0.0 }, status = { { odds = 0, buffID = 0 }, { odds = 0, buffID = 0 } } }
local DEFAULT_EVENTS_METATABLE = {__index = { triTime = 0, hitEffID = 0, useEffID = 0, hitSoundID = 0, damage = { odds = 0, atrType = 0, acrType = 0, arg1 = 0.0, arg2 = 0.0, realmAddon = 0.0 }, status = { { odds = 0, buffID = 0 }, { odds = 0, buffID = 0 } } }}
local GET_EVENT_KEY_METATABLE = {__index = function(table,key)
	if key > 0 and key < 4 then
		return DEFAULT_EVENTS
	end
end}
----------------- auto generate db file ------------------------
i3k_db_skill_datas = 
{
	___loadedKeys = {},

};
local skill_data_level_mt = { __index  = function(table, key)
	if key <= 0 then
		return nil;
	end

	local fileKey = 0
	if table.skillid < 100000 then --主角
		fileKey = table.skillid
	else --怪物、佣兵、神兵
		fileKey = math.floor(table.skillid / 40) * 40
	end

	if table.___loadedKeys[fileKey] ~= nil then
		return nil;
	end
	table.___loadedKeys[fileKey] = true;

	local filename = 'script/gamedb/skills/skill_data_' .. fileKey;
		local _call = function()
		return require(filename).get_db_table();
	end

	local _err = function()
		i3k_warn('unable load db file[' .. filename .. ']');
		--i3k_warn(debug.traceback());
	end

	local ret, _db = xpcall(_call, _err);
	if not ret then
		return nil;
	end
	if _db[table.skillid] == nil then
		i3k_warn('db file[' .. filename .. '] has not skillid ' .. table.skillid);
		return nil;
	end
	for k, v in pairs(_db[table.skillid]) do
		if table.skillid ~= 9999999 then
			setmetatable(v, DEFAULT_SKILLDATA_METATABLE)
			if v.events then
				setmetatable(v.events, GET_EVENT_KEY_METATABLE)
				for i = 1, 3 do
					if v.events[i] then
						setmetatable(v.events[i], DEFAULT_EVENTS_METATABLE)
						if v.events[i].damage then
							setmetatable(v.events[i].damage, DEFAULT_EVENTS_DAMAGE_METATABLE)
						end
						if v.events[i].status then
							setmetatable(v.events[i].status, DEFAULT_EVENTS_STATUE_METATABLE)
							for k = 1, 2 do
								if v.events[i].status[k] then
									setmetatable(v.events[i].status[k], DEFAULT_EVENTS_STATUESINGLE_METATABLE)
								end
							end
						end
					end
				end
			end
		end
	table[k] = v;
	end
	_db[table.skillid] = nil;
	if next(_db) == nil then
		i3k_game_unload_script(filename);
	end
	return table[key]
end };

local skill_data_mt = { __index  = function(table, key)
	if key <= 0 then
		return nil;
	end

	local _call = function()
		local db = {skillid = key, ___loadedKeys = {}}
		setmetatable(db, skill_data_level_mt)
		return db
	end

	local _err = function()
		--i3k_warn(debug.traceback())
	end

	local ret, _db = xpcall(_call, _err);
	if not ret then
		return nil;
	end
	table[key] = _db;

	return _db;
end };
setmetatable(i3k_db_skill_datas, skill_data_mt);

i3k_db_state =
{
	[0] = { level = 0, name = '白露', item1ID = 0, item1Count = 0, item2ID = 0, item2Count = 0 },
	[1] = { level = 1, name = '绿竹', item1ID = 65724, item1Count = 2, item2ID = 65725, item2Count = 2 },
	[2] = { level = 2, name = '蓝田', item1ID = 65724, item1Count = 4, item2ID = 65726, item2Count = 2 },
	[3] = { level = 3, name = '紫庭', item1ID = 65724, item1Count = 8, item2ID = 65727, item2Count = 2 },
	[4] = { level = 4, name = '橙圃', item1ID = 65724, item1Count = 8, item2ID = 65728, item2Count = 2 },
};

i3k_db_skill_AddData =
{
	[1] = { id = 1, type = 1, combatType = 1, arg1 = 1002, arg2 = 1000, arg3 = 1003, arg4 = -1000, arg5 = 0, arg6 = { 0,  } },
	[2] = { id = 2, type = 1, combatType = 2, arg1 = 1003, arg2 = 1000, arg3 = 1002, arg4 = -1000, arg5 = 0, arg6 = { 0,  } },
	[3] = { id = 3, type = 2, combatType = 1, arg1 = 1, arg2 = 2, arg3 = 10000, arg4 = 3005, arg5 = 0, arg6 = { 0,  } },
	[4] = { id = 4, type = 2, combatType = 2, arg1 = 1, arg2 = 2, arg3 = 10000, arg4 = 3006, arg5 = 0, arg6 = { 0,  } },
	[5] = { id = 5, type = 3, combatType = 1, arg1 = 1, arg2 = 10000, arg3 = 0, arg4 = 0, arg5 = 0, arg6 = { 0,  } },
	[6] = { id = 6, type = 3, combatType = 2, arg1 = 2, arg2 = 10000, arg3 = 0, arg4 = 0, arg5 = 0, arg6 = { 0,  } },
	[7] = { id = 7, type = 4, combatType = 1, arg1 = 10000, arg2 = 10000, arg3 = 0, arg4 = 0, arg5 = 0, arg6 = { 0,  } },
	[8] = { id = 8, type = 5, combatType = 2, arg1 = 25000, arg2 = 0, arg3 = 10000, arg4 = 0, arg5 = 0, arg6 = { 0,  } },
	[9] = { id = 9, type = 3, combatType = 1, arg1 = 1, arg2 = 10000, arg3 = 0, arg4 = 0, arg5 = 0, arg6 = { 0,  } },
	[10] = { id = 10, type = 3, combatType = 2, arg1 = 2, arg2 = 10000, arg3 = 0, arg4 = 0, arg5 = 0, arg6 = { 0,  } },
	[11] = { id = 11, type = 2, combatType = 1, arg1 = 1, arg2 = 2, arg3 = 10000, arg4 = 3022, arg5 = 0, arg6 = { 0,  } },
	[12] = { id = 12, type = 2, combatType = 2, arg1 = 1, arg2 = 2, arg3 = 10000, arg4 = 3009, arg5 = 0, arg6 = { 0,  } },
	[13] = { id = 13, type = 6, combatType = 0, arg1 = 0, arg2 = 0, arg3 = 0, arg4 = 0, arg5 = 0, arg6 = { 0,  } },
	[14] = { id = 14, type = 7, combatType = 1, arg1 = 2, arg2 = 1, arg3 = 2, arg4 = 10000, arg5 = 900, arg6 = { 3010, 3011, 3012, 3013, 3014, 3015,  } },
	[15] = { id = 15, type = 7, combatType = 2, arg1 = 1, arg2 = 1, arg3 = 2, arg4 = 10000, arg5 = 900, arg6 = { 3016, 3017, 3018, 3019, 3020, 3021,  } },
	[16] = { id = 16, type = 2, combatType = 1, arg1 = 1, arg2 = 2, arg3 = 10000, arg4 = 3023, arg5 = 0, arg6 = { 0,  } },
	[17] = { id = 17, type = 2, combatType = 2, arg1 = 1, arg2 = 2, arg3 = 10000, arg4 = 3024, arg5 = 0, arg6 = { 0,  } },
};

