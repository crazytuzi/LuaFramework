-------------------------------------------------------
--module(..., package.seeall)

local require = require

g_i3k_coroutine_mgr = nil
function i3k_coroutine_mgr_create()
	if not g_i3k_coroutine_mgr then
		g_i3k_coroutine_mgr = i3k_coroutine_mgr.new()
		g_i3k_coroutine_mgr:Create()
	end

	return 1
end

function i3k_coroutine_mgr_update(dTime)
	if g_i3k_coroutine_mgr then
		g_i3k_coroutine_mgr:OnUpdate(dTime)
	end

	return 1
end

function i3k_coroutine_mgr_cleanup()
	if g_i3k_coroutine_mgr then
		g_i3k_coroutine_mgr:Release()
	end
	g_i3k_coroutine_mgr = nil

	return 1
end

-------------------------------------------------------
i3k_coroutine_mgr = i3k_class("i3k_coroutine_mgr")

function i3k_coroutine_mgr.WaitForNextFrame()
	return coroutine.yield(0)
end

function i3k_coroutine_mgr.WaitForSeconds(secs)
	return coroutine.yield(secs or 0)
end

function i3k_coroutine_mgr:ctor()
end

function i3k_coroutine_mgr:Create()
	self._timeLine = 0
	self._coroutines = { }
	return true
end

function i3k_coroutine_mgr:Release()
	self._coroutines = { }
end

function i3k_coroutine_mgr:OnUpdate(dTime)
	self._timeLine = self._timeLine + dTime
	local remove_ids = { }
	for i, e in ipairs(self._coroutines) do
		if not e.co then
			table.insert(remove_ids, i)
		elseif self._timeLine >= e.timeStart + e.timeout then
			local result, timeout = coroutine.resume(e.co, self._timeLine - e.timeStart)
			if not result then
				local tmpCo = e.co
				e.co = nil
				assert(false, debug.traceback(tmpCo, timeout))
			end
			if timeout then
				e.timeStart = self._timeLine
				e.timeout = timeout
			else
				table.insert(remove_ids, i)
			end		
		end
	end
	local n = #remove_ids
	if n > 0 then
		for k = n, 1, -1 do
			table.remove(self._coroutines, remove_ids[k])
		end
	end
end

function i3k_coroutine_mgr:StartCoroutine(func)
	local co = coroutine.create(func)

	local result, timeout = coroutine.resume(co, 0)
	if result then
		if timeout then
			local handler = { co = co, timeStart = self._timeLine, timeout = timeout }
			table.insert(self._coroutines, handler)
			return handler
		end
	else
		-- 一定要用assert， 因为i3k_error不会输出到scriptError里
		assert(false, debug.traceback(co, timeout))
	end
end

function i3k_coroutine_mgr:StopCoroutine(co)
	if co and co.co then
		co.co = nil
	end
end