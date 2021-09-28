
module(..., package.seeall)

local eStateIdle = 1
local eStateRecord = 2
local eStatePlay = 3

local eTypeComment = 1
local eTypePacket = 2

local _state = eStateIdle
local _startTime = 0

local VERSION = 1
local _title = nil
local _date = nil
local _records = { }

function isRecording()
	return _state == eStateRecord
end

function isPlaying()
	return _state == eStatePlay
end

function isIdle()
	return _state == eStateIdle
end

local function getTime()
	return g_i3k_game_handler:GetMillisecond() / 1000
end

function startRecord(title)
	_title = title or "untitled"
	_date = os.date("%Y%m%d_%H%M%S")
	_startTime = getTime()
	_records = { }
	_state = eStateRecord
end

function play()
	if not isIdle() then
		return
	end
	_state = eStatePlay
	g_i3k_coroutine_mgr:StartCoroutine(function ()
		local lastTime = 0
		for _, e in ipairs(_records) do
			if e.rtype == eTypePacket then
				local dTime = e.rtime - lastTime
				if dTime > 0 then
					g_i3k_coroutine_mgr.WaitForSeconds(dTime)
					lastTime = e.rtime
				end
				if not isPlaying() then
					break
				end
				i3k_game_str_channel_process(e.data)
			end
		end	
		_state = eStateIdle
	end)
end

function stop()
	_state = eStateIdle
end

function save(fileName)
	if isRecording() or not _title then
		return
	end

	fileName = fileName or string.format("%s_%s.rcd", _title, _date)
	
	local f = io.open(fileName, "w");
	if not f then
		return
	end

	f:write(string.format("%d\n", VERSION))
	f:write(string.format("%s\n", _title))
	f:write(string.format("%s\n", _date))

	for _, e in ipairs(_records) do
		f:write(string.format("%3.3f %d %s\n", e.rtime, e.rtype, e.data))
	end

	f:close()
end

function load(fileName)
	if not fileName or not isIdle() then
		return
	end

	local f = io.open(fileName, "r");
	if not f then
		return
	end
	f:close()

	local lines = { }
	for line in io.lines(fileName) do
		table.insert(lines, line)
	end

	_title = lines[2] or _title
	_date = lines[3] or _date
	_startTime = 0
	_records = { }
	for i = 4, #lines do
		local line = lines[i]
		local p1 = string.find(line, " ")
		if p1 and p1 > 1 then
			local p2 = string.find(line, " ", p1 + 1)
			if p2 and p2 > p1 + 1 then
				table.insert(_records, { rtime = tonumber(string.sub(line, 1, p1-1)), rtype = tonumber(string.sub(line, p1+1, p2-1)), data = string.sub(line, p2+1) })
			end
		end
	end
end

local function record(rtype, data)
	if not isRecording() then
		return
	end
	table.insert(_records, { rtime = getTime() - _startTime, rtype = rtype, data = data })
end

function recordComment(data)
	record(eTypeComment, data)
end

function recordPacket(data)
	record(eTypePacket, data)
end
