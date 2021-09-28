----------------- auto generate db file ------------------------
i3k_db_monsters = 
{
	___loadedKeys = {},

};
local monsters_mt = { __index  = function(table, key)
	if key <= 0 then
		return nil;
	end

	local fileKey = math.floor(key / 100);
	if table.___loadedKeys[fileKey] ~= nil then
		return nil;
	end
	table.___loadedKeys[fileKey] = true;

	local filename = 'script/gamedb/monsters/monster_' .. fileKey;
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
setmetatable(i3k_db_monsters, monsters_mt);


i3k_db_monsters_damageodds =
{
	[1] = {  race = 1, desc = '野兽', damageIncProp = 1022, damageDesProp = 1027,},
	[2] = {  race = 2, desc = '盗匪', damageIncProp = 1023, damageDesProp = 1028,},
	[3] = {  race = 3, desc = '武者', damageIncProp = 1024, damageDesProp = 1029,},
	[4] = {  race = 4, desc = '刺客', damageIncProp = 1025, damageDesProp = 1030,},
	[5] = {  race = 5, desc = '术师', damageIncProp = 1026, damageDesProp = 1031,},
	[6] = {  race = 6, desc = '特殊', damageIncProp = 1035, damageDesProp = 1036,},
	[7] = {  race = 7, desc = '建筑', damageIncProp = -1, damageDesProp = -1,},
}
