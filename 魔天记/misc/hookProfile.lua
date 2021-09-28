
local logs = {}
local logHookFuncs = {}
local TimeInfo = {}

--local socket = require("socket")

local function hookEvent(mask)
	if mask == "call" then
		local info = debug.getinfo(2, "nf")
		
		if info.func then
			local name = logHookFuncs[info.func]
			if name then
				local info = TimeInfo[name]
				if not info then
					info = {count=0, totalTime=0, maxTime=0,minTime =0}
					info.tempTimeList = {}

					TimeInfo[name] = info
				end
				--info.tempTimeList[#info.tempTimeList+1] =socket.gettime()
				info.tempTimeList[#info.tempTimeList+1] = os.clock()
			end
		end
	elseif mask == "return" then
		local info = debug.getinfo(2, "nf")
		
		if info.func then
			local name = logHookFuncs[info.func]
			if name then
				
				local info = TimeInfo[name]
				if not info then
					return
				end
				--local t = socket.gettime() - (info.tempTimeList[#info.tempTimeList] or 0)
				local t = os.clock() - (info.tempTimeList[#info.tempTimeList] or 0)
				table.remove(info.tempTimeList,#info.tempTimeList)
				info.count = info.count + 1
				info.totalTime = info.totalTime + t
				if t > info.maxTime then
					info.maxTime = t
				elseif t < info.minTime then
					info.minTime = t
				end
			end
		end
	end
end

function hookRegisterEx(name,func)
	logHookFuncs[func] = name
	if not debug.gethook() then
		debug.sethook(hookEvent, "cr")
	end
end

function hookRegister(...)
	local objs = {...}
	print("function registerHook(...)", #objs)
	
	for i,obj in ipairs(objs) do
		local argIndex = 1
		local argName, argValue = debug.getlocal(2, argIndex)
		local name = nil
		while argName ~= nil do
			if argValue == obj then
				name = argName
				break
			end
			argIndex = argIndex + 1
			argName, argValue = debug.getlocal(2, argIndex)
		end
		for gname, gobj in pairs(_G) do
			if gobj == obj then
				name = gname
				break
			end
		end
		if name then
			logs[name] = name
			for fname, func in pairs(obj) do
				logHookFuncs[func] = name.."."  .. fname
			end
		end
	end
	if not debug.gethook() then
		debug.sethook(hookEvent, "cr")
	end
end

function hookLog(sortForTime)
	print("========================================")
	local logs = {}
	for name, info in pairs(TimeInfo) do
		-- local arrName = string.split(name,"/")
		-- info.name = arrName[#arrName]
		local log = {}
		log.name = name
		log.count = info.count
		log.totalTime = info.totalTime * 1000  --毫秒
		log.minTime = info.minTime * 1000
		log.maxTime = info.maxTime * 1000
		log.average = log.totalTime/log.count  --平均
		logs[#logs+1] = log
	end
	table.sort(logs, function(lhs, rhs)
		return lhs.average > rhs.average
	end)
	local outlogs = {}
	for i,log in ipairs(logs) do
		log.arank = i
		outlogs[i] = log
	end
    if sortForTime then
	table.sort(outlogs, function(lhs, rhs)
		return lhs.totalTime > rhs.totalTime
	end)
    else 
    table.sort(outlogs, function(lhs, rhs)
		return lhs.count > rhs.count
	end)
    end
	local strTb = {}
	for i,log in ipairs(outlogs) do
		strTb[#strTb+1] = i.." | "..log.name.."平均耗时:".. log.average.." | 最大耗时:"..log.maxTime.." | 最小耗时:"..log.minTime..
			" | 总耗时:"..log.totalTime.." | 调用次数:".. log.count
			
	end
	Debugger.Log("\n"..table.concat(strTb,"\n\n"))
	print("===================end=====================")
end



debug.sethook(hookEvent, "cr")

--hookLog()