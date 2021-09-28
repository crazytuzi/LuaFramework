--logEntry.lua
require "util.logtable"
--------------------------------------------------------------------------------

g_nowtick = 0
g_serverId = 0
g_all_table_in_creates = {}

local lastTick = os.time()
function lua_mem_gc()
	if os.time() - lastTick >= 20 then	
		collectgarbage("step")	
		lastTick = os.time()
	end
end

function time2tick()
	local t = os.date("*t", os.time())
	return t["year"]*100 + t["month"]
end

function safe_call_sql(sql)
	g_frame:CallSql(sql, 1, 0)
end

function create_table(tabName)
	local tick = time2tick()
	if tick ~= g_nowtick then
		g_nowtick = tick
		all_table_in_creates = {}
	end
	if not all_table_in_creates[tabName] then
		local create_sql = g_all_table4create[tabName]
		if create_sql then
			local sql = string.format(create_sql, tick)
			all_table_in_creates[tabName] = true
			safe_call_sql(sql)
		end
	end
end

function startLogger(serverID, frame)
	local serverId = serverID % 1000000
	local configId = load_logger_config(serverId)
	print("logger server try ro connect mysql! config is:", configId)
	
	g_frame = tolua.cast(frame, "CLogFrame")
	return g_frame:CreateDBEngine(configId)
end

function recvtLogger(tabName, logContext)
	lua_mem_gc()
	create_table(tabName)
	safe_call_sql(logContext)
--	print("recvtLogger: ", logContext)
end

