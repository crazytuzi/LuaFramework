--LibComSdk.lua


local LibComSdk = class("LibComSdk")

function LibComSdk:ctor( ... )
	self._sdkHandler = LibComSdkHandler:create()
	self._sdkHandler:retain()

	self._handlers = {}

	self._sdkHandler:registerScriptHandler(function ( event, ... )
		local args = {...}
		if type(event) == "string" then
			self:_callHandler( "_"..event, args )
		end
	end)

	ExitHelper:getInstance():addExitExcute(function (  )
 		self._sdkHandler:release()
 		self._sdkHandler = nil
 	end)
end

function LibComSdk:_callHandler( hanalerName, args )
	local handler = self._handlers[hanalerName]
	if handler ~= nil then
		if handler[1] ~= nil and handler[2] ~= nil then
			handler[1](handler[2], unpack(args))
		elseif handler.func ~= nil then
			handler[1]( unpack(args) )
		end
	end
end

-- handler func param format is: [platform, ret, param]
function LibComSdk:setInitHandler( func, target )
	self._handlers["_onInit"] = {func, target}
end

-- handler func param format is: [platform, ret, param]
function LibComSdk:setCheckVersionHandler( func, target )
	self._handlers["_onCheckVersion"] = {func, target}
end

-- handler func param format is: [platform, ret, param, isFastLogin]
function LibComSdk:setLoginHandler( func, target )
	self._handlers["_onLogin"] = {func, target}
end

-- handler func param format is: [platform, ret, param]
function LibComSdk:setLogoutHandler( func, target )
	self._handlers["_onLogout"] = {func, target}
end

-- handler func param format is: [platform, ret, param]
function LibComSdk:setBindHandler( func, target )
	self._handlers["_onBind"] = {func, target}
end

-- handler func param format is: [platform, ret, param]
function LibComSdk:setLoginPlatformHandler( func, target )
	self._handlers["_onLoginPlatform"] = {func, target}
end

-- handler func param format is: [platform, ret, param]
function LibComSdk:setPayHandler( func, target )
	self._handlers["_onPay"] = {func, target}
end

-- handler func param format is: [platform, funcName, paramConfig]
function LibComSdk:setCallStringMethodHandler( func, target )
	self._handlers["_onCallStringMethod"] = {func, target}
end

-- handler func param format is: [platform, funcName, paramConfig]
function LibComSdk:setCallVoidMethodHandler( func, target )
	self._handlers["_onCallVoidMethod"] = {func, target}
end



return LibComSdk
