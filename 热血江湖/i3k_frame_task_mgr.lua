
local PRIOR_CRITICAL = 1
local PRIOR_NORMAL = 2

local MAX_FINISH_TIME = 5
local MAX_FINISH_TIME_CRITICAL = 0.5

local l_timeLine = 0
local l_tickLine = 0

local tasks = { }

local _debugInfo = ""

local function runTask(n)
	for k = 1, n do
		local task = tasks[1].task
		table.remove(tasks, 1)
		task.run()
	end
	--l_timeLastRun = l_timeLine
end

local function update(dTime)
	l_timeLine = l_timeLine + dTime

	--TODO
	local nTask = #tasks
	if Debugger.GetPendingTaskCount then
		local debugInfo = "pending tasks:" .. Debugger.GetPendingTaskCount() .. ", " .. nTask
		if _debugInfo ~= debugInfo then
			cc.Director:getInstance():setDebugInfo(debugInfo)
			_debugInfo = debugInfo
		end
	end

	--
	if nTask == 0 then
		return 0
	end

	--[[
	if l_timeLine - l_tickLine < MAX_FINISH_TIME then
		return;
	end
	l_tickLine = l_timeLine;
	]]

	local i = 0
	while i < nTask and tasks[i + 1].deadLine <= l_timeLine do
		i = i + 1
	end

	local j = i
	while j < nTask and tasks[j + 1].deadLine <= l_timeLine + MAX_FINISH_TIME do
		j = j + 1
	end

	local k = j - i
	local a = k * dTime / MAX_FINISH_TIME
	if a > k then
		a = k
	end
	if a < 0 then
		a = 0
	end
	if a >= 1 then
		a = i3k_integer(a)
	elseif a > 0 then
		a = 1 --TODO
	end
	local n = math.max(1, i + a)
	runTask(n)
	return n
	--[[
	runTask(1);
	return 1
	]]
end

local function addNormalTask(task)
	table.insert(tasks, { task = task, deadLine = l_timeLine + MAX_FINISH_TIME })
end

local function addCriticalTask(task)
	local deadLine = l_timeLine + MAX_FINISH_TIME_CRITICAL
	local i = 0
	while i < nTask and tasks[i + 1].deadLine <= deadLine do
		i = i + 1
	end
	table.insert(tasks, { task = task, deadLine = deadLine }, i + 1)
end

local function updateTask(checkFunc)
	local ids = { }
	for i, v in ipairs(tasks) do
		if checkFunc(v.task) then
			table.insert(ids, i)
		end
	end
	local n = #ids
	if n > 0 then
		for k = n, 1, -1 do
			local id = ids[k]
			table.remove(tasks, id)
		end
	end
end

local function clearTasks()
	tasks = { 
	}
end

return {
	update = update,
	addNormalTask = addNormalTask,
	addCriticalTask = addCriticalTask,
	updateTask = updateTask,
	clearTasks = clearTasks,
}
