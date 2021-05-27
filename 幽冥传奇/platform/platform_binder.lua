PlatformBinder = {
	callback_list = {},
}

function PlatformBinder.TestCall(fun)
	if nil == fun then return false end

	return "true" == AdapterToLua:jsonCall("call_test", fun)
end

function PlatformBinder:JsonCall(fun, arg, key, callback)
	if nil == fun then return end

	arg = arg or ""
	key = key or ""

	if nil ~= callback and "function" == type(callback) then
		self.callback_list[fun] = { k = key, c = callback }
	end

	return AdapterToLua:jsonCall(fun, arg, key)
end

function PlatformBinder:JsonBind(event, callback)
	if nil == event or nil == callback then return end

	self.callback_list[event] = { k = "", c = callback }
end

function PlatformBinder:JsonCallback(fun, key, ret)
	if nil == fun or nil == key then return end

	local cb = self.callback_list[fun];
	if nil ~= cb then
		if cb.k == key and nil ~= cb.c then 
			local r = cb.c(ret)
			if not r and cb == self.callback_list[fun] then
				self.callback_list[fun] = nil
			end
		end
	end
end

AdapterToLua:setJsonCallback(LUA_CALLBACK(PlatformBinder, PlatformBinder.JsonCallback))

PlatformBinder:JsonBind("event_net_state_change", function(ret) if nil ~= ret then NetStateChanged(tonumber(ret)) end return true end)
