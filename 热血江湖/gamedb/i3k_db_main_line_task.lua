----------------- auto generate db file ------------------------
i3k_db_main_line_task = 
{
	___loadedKeys = {},

};
local main_line_task_mt = { __index  = function(table, key)
	if key <= 0 then
		return nil;
	end

	local fileKey = math.floor(key / 50);
	if table.___loadedKeys[fileKey] ~= nil then
		return nil;
	end
	table.___loadedKeys[fileKey] = true;

	local filename = 'script/gamedb/tasks/task_' .. fileKey;
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
setmetatable(i3k_db_main_line_task, main_line_task_mt);

