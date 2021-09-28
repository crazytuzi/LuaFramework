
module(..., package.seeall)

eErrOK = 0
eErrFailed = 1
eErrTimeout = 2
eErrUserCancel = 3

local eTimeoutDefault = 5

local uidSeed = 0

local _reqQueue = { }
local _reqCurrent = nil

local function genUID()
	uidSeed = uidSeed + 1
	return uidSeed
end

local function getTime()
	return os.time()
end

local function clearTimeoutReqs(uid)

	uid = uid or 0
	local callbacks = { }
	local now = getTime()

	for k = #_reqQueue, 1, -1 do
		local e = _reqQueue[k]
		if e.uid == uid or now >= e.timeout then
			table.insert(callbacks, e)
			table.remove(_reqQueue, k)
		end
	end

	if _reqCurrent then
		if _reqCurrent.uid == uid or now >= _reqCurrent.timeout then
			table.insert(callbacks, _reqCurrent)
			_reqCurrent = nil
		end
	end

	for k = #callbacks, 1, -1 do
		local e = callbacks[k]
		e.callback(e.uid, eErrTimeout)
	end
end

local function popReq()
	if not _reqCurrent and #_reqQueue > 0 then
		_reqCurrent = table.remove(_reqQueue, 1)
		i3k_game_http_get_file(_reqCurrent.uid, _reqCurrent.url)
	end
end

--in turn
function getFile(url, callback, timeout)
	if not url or not callback then
		return
	end
	local uid = genUID()
	timeout = timeout or eTimeoutDefault
	table.insert(_reqQueue, { uid = uid, url = url, callback = callback, timeout = getTime() + timeout })
	clearTimeoutReqs()
	popReq()
	g_i3k_coroutine_mgr:StartCoroutine(
		function ()
			g_i3k_coroutine_mgr.WaitForSeconds(timeout)
			clearTimeoutReqs(uid)
		end
	)
	return uid
end

function cancel(uid)
	uid = uid or 0
	local callbacks = { }

	if uid == 0 then
		callbacks = _reqQueue
		_reqQueue = { }
		if _reqCurrent then
			table.insert(callbacks, 1, _reqCurrent)
			_reqCurrent = nil
		end
	else
		if _reqCurrent then
			if _reqCurrent.uid == uid then
				table.insert(callbacks, _reqCurrent)
				_reqCurrent = nil
			end
		end
		if _reqCurrent then
			for i, e in ipairs(_reqQueue) do
				if e.uid == uid then
					table.insert(callbacks, e)
					table.remove(_reqQueue, i)
					break
				end
			end
		else
			popReq()
		end
	end

	for _, e in ipairs(callbacks) do
		e.callback(e.uid, eErrUserCancel)
	end
end

function cancelAll()
	cancel()
end

function stop()
	cancelAll()
end

function onGetFileRes(uid, ecode, text)
	clearTimeoutReqs()
	if not _reqCurrent or _reqCurrent.uid ~= uid then
		return
	end
	local req = _reqCurrent
	_reqCurrent = nil
	popReq()
	req.callback(uid, ecode == 0 and eErrOK or eErrFailed, text)
end