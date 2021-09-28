
module(..., package.seeall)

local profile_data = 
{
	func_map = { }
}

local function clear()
	profile_data = 
	{
		func_map = { },
	}
end

function start(interval)
	stop()	
	debug.sethook(function()
		local lvl = 1
		while true do
			lvl = lvl + 1
			local caller = debug.getinfo(lvl, "nS")
			if not caller then return end
			local func_id = string.format("%s:%d", caller.source, caller.linedefined)
			local func_name = caller.name or "noname"

			local func_info = profile_data.func_map[func_id]
			if not func_info then
				func_info = { count = 0, direct_count = 0, name = func_name }
				profile_data.func_map[func_id] = func_info
			end
			func_info.count = func_info.count + 1
			if lvl == 2 then
				func_info.direct_count = func_info.direct_count + 1
			end
		end
	end, "", interval or 10000)
end

function stop()
	debug.sethook()
	clear()
end

function dump(logger, max_seq)
	logger = logger or i3k_log
	if not logger then return end
	local list = { }
	local count = 0
	local direct_count = 0
	for id, info in pairs(profile_data.func_map) do
		table.insert(list, { id = id, info = info })
		direct_count = direct_count + info.direct_count
		count = count + info.count
	end

	table.sort(list, function(a, b)
		return a.info.direct_count > b.info.direct_count
	end)

	logger("###################################### DIRECT ##################################")
	for i, e in ipairs(list) do
		logger(string.format("%d\t%d(%.2f%%)\t%s %s", i, e.info.direct_count, e.info.direct_count * 100/direct_count, e.id, e.info.name))
		if max_seq and i >= max_seq then
			break
		end
	end
	logger("###############################################################################")

	table.sort(list, function(a, b)
		return a.info.count > b.info.count
	end)

	logger("#######################################  ALL  ################################")
	for i, e in ipairs(list) do
		logger(string.format("%d\t%d(%.2f%%)\t%s %s", i, e.info.count, e.info.count * 100/count, e.id, e.info.name))
		if max_seq and i >= max_seq then
			break
		end
	end
	logger("###############################################################################")
end