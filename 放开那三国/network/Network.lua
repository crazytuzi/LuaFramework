-- Filename: Network.lua
-- Author: chengliang
-- Date: 2013-05-28
-- Purpose: 该文件用于网络调用相关模块公用处理函数

module ("Network", package.seeall)

require "script/ui/tip/AlertTip"
require "script/ui/network/LoadingUI"


-- TODO 分OS 赋值方法名
-- TODO  rpcCountry

local kNetworkConnectFailed = "failed" -- 和C++层定义的字符串一致

kSOCKET_TYPE_MAIN 		= "main"	--主Socket
kSOCKET_TYPE_COUNTRY 	= "country" --国战Socket

-- wp 保存Connect
local wpConnectMap = {}
-- wp 保存Token
local wpTokenMap = {}


local kTypeNormal 		= 1	-- 正常请求类型
local kTypeNoLoading 	= 2	-- 没有Loading界面
local kTypeRe 			= 3	-- 推送



local contryDisconnectedLister = {} -- 国战断线 监听

--[[
	@desc 保存每个请求信息的map，每个请求的信息是数组
	@desc mContextMap[cbFlag] = {cbFunc, args, requestType}  （第四个参数 socketType 废弃）
	@parm: cbFlag: 回调的标识名称
	@parm: cbFunc: 回调的方法
	@parm: args: 调用函数需要的参数
	@parm: requestType: 是否是正常、推送、无Loading 的请求
	@parm: socketType: 使用哪个SocketType  （废弃）
--]]
local mContextMap = {}

-- socket 实例对应的Key
local _socketKeyMap = {}


-- 设置mainSocket
function setMainSocketKey( socketKey )
	_socketKeyMap[kSOCKET_TYPE_MAIN] = socketKey
end
function getMainSocketKey()
	return _socketKeyMap[kSOCKET_TYPE_MAIN]
end

-- 设置国战的Socket
function setCountrySocketKey( socketKey)
	
	_socketKeyMap[kSOCKET_TYPE_COUNTRY] = socketKey
end
function getCountrySocketKey()
	return _socketKeyMap[kSOCKET_TYPE_COUNTRY]
end
-- 注册 国战断线 监听
function registerCountryDisconnected(pKey, pCallback )
	contryDisconnectedLister[pKey] = pCallback
end
function contryDisconnected()
	for k, pCall in pairs(contryDisconnectedLister) do
		pCall()
	end
end
function removeCountryRegister( pKey )
	contryDisconnectedLister[pKey] = nil
end

-- 某个Socket是否已经连接
function isSocketConnectedBy( socketType )
	--不得已 注：通过这个字段是否为nil判断是否建立连接
	if(_socketKeyMap[socketType] == nil)then
		return false
	else
		return true
	end
end

-- 获取socket
function getSocketKeyBy( socketType )
	return _socketKeyMap[socketType]
end

-- 断开某个socket By type
function closeSocketBy( socketType )
	print("socketType:", socketType)
	print_t(_socketKeyMap)

	disconnectBy(_socketKeyMap[socketType])
	_socketKeyMap[socketType] = nil
end


-- 关闭socket By key
function disconnectBy( socketKey )
	if(socketKey ~= nil)then
		if(g_system_type == kBT_PLATFORM_WP8)then
			wpConnectMap[socketKey][2]:close(socketKey)
			wpConnectMap[socketKey] = nil
		else
			if(BTNetClient:getInstance().disconnect ~= nil)then
				BTNetClient:getInstance():disconnect(socketKey)
			end
		end
	else
		-- Warining
		print("[warning]: socketKey:" , socketKey , " is not exist!")
	end
end

-- 连接国战Socket
function connectCountrySocket( ipStr, port )
	setCountrySocketKey(nil)
	return connectSocketBy( ipStr, port, kSOCKET_TYPE_COUNTRY)
end

-- 连接主业务Socket
function connectMainSocket( ipStr, port )
	setMainSocketKey(nil)
	return connectSocketBy( ipStr, port, kSOCKET_TYPE_MAIN )
end


-- 关闭国战Socket
function closeCountrySocket()
	closeSocketBy(kSOCKET_TYPE_COUNTRY)
end

-- 关闭MainSocket
function closeMainSocket()
	closeSocketBy(kSOCKET_TYPE_MAIN)
end

-- 关闭所有Socket
function closeAllSocket()
	closeCountrySocket()
	closeMainSocket()
end

--[[
	@des:  国战 正常请求 有LoadingUI
	@parm: cbFunc: 回调的方法
	@parm: cbFlag: 回调的标识名称
	@parm: rpcName: 调用后端函数的名称
	@parm: args: 调用函数需要的参数
--]]    
function rpcCountry(cbFunc, cbFlag, rpcName, args )
	doRPC(cbFunc, cbFlag, rpcName, args, kSOCKET_TYPE_COUNTRY, kTypeNormal )
end

--[[
	@des:  国战 无LoadingUI
	@parm: 同上
--]] 
function noLoadingRpcCountry( cbFunc, cbFlag, rpcName, args)
	doRPC(cbFunc, cbFlag, rpcName, args, kSOCKET_TYPE_COUNTRY, kTypeNoLoading )
end


-- 根据类型 创建Socket
function connectSocketBy( ipStr, port, socketType )
	socketType = socketType or kSOCKET_TYPE_MAIN
	-- 注册socket异常
	Network.re_rpc(LoginScene.netWorkFailed, "failed")
	local socketKey = nil
	if(g_system_type == kBT_PLATFORM_WP8)then
		-- WP
		local mConn = connectWP(ipStr, port, socketType)
		if(mConn ~= nil)then
			-- 设置key
			socketKey = socketType

			-- 保存Token和connect
			local token_conn_table = {"0", mConn}
			wpConnectMap[socketKey] = token_conn_table
		else
			return false
		end
	else
		-- iOS、Android
		socketKey = connect(ipStr, port)
	end
	if(socketKey == kNetworkConnectFailed)then
		return false
	else
		_socketKeyMap[socketType] = socketKey
		return true
	end
end


--[[
	@des:  lua层主动调用网络连接接口  仅iOS和Android 
	@parm: phost: 服务器hostname或ip
	@parm: pport: 服务器端口
--]] 
function connect (phost, pport)
	local client = BTNetClient:getInstance()
	local socketStr = client:connectWithAddr(phost, pport)
    if (socketStr == nil ) then
        CCLuaLog("The network is unavailable.")
        return nil
    end
    return socketStr
end

--[[
	@des:  正常请求 有LoadingUI
	@parm: cbFunc: 回调的方法
	@parm: cbFlag: 回调的标识名称
	@parm: rpcName: 调用后端函数的名称
	@parm: args: 调用函数需要的参数
	@parm: autoRelease: 调用完成后是否删除此回调方法 (已废弃)
	@parm: socketType: 使用哪个SocketType
--]]    
function rpc(cbFunc, cbFlag, rpcName, args, autoRelease, socketType)
	doRPC(cbFunc, cbFlag, rpcName, args, socketType, kTypeNormal )
end

--[[
	@des:  无LoadingUI
	@parm: 同上
--]] 
function no_loading_rpc( cbFunc, cbFlag, rpcName, args, autoRelease, socketType )
	doRPC(cbFunc, cbFlag, rpcName, args, socketType, kTypeNoLoading )
end

-- 删除 推送
function remove_re_rpc( cbFlag )
	mContextMap[cbFlag] = nil
end

-- 推送  
function re_rpc( cbFunc, cbFlag, rpcName)
	mContextMap[cbFlag] = {cbFunc, {}, kTypeRe}
	if(g_system_type ~= kBT_PLATFORM_WP8)then
		-- iOS、Android
	 	registerLuaHandler(cbFlag, networkHandler, false)
	end
end

--[[
	@des:  通用RPC
	@parm: requestType 是否是正常、推送、无Loading 的请求
	@parm: 同上
--]] 
function doRPC( cbFunc, cbFlag, rpcName, args, socketType, requestType )
	socketType = socketType or kSOCKET_TYPE_MAIN
	requestType = requestType or kTypeNormal
	local socketKey = getSocketKeyBy(socketType)
	if(socketKey==nil)then
		print("[Error]: There is no socket by type:" .. socketType .. "!!!")
		return 
	end

	if(requestType == kTypeNormal)then
		LoadingUI.addLoadingUI()
	end

	-- 保存 相关lua层的参数
	mContextMap[cbFlag] = {cbFunc, args, requestType}
	if(g_system_type == kBT_PLATFORM_WP8)then
		-- WP
		rpcCallWP( cbFlag, rpcName, args, socketKey )
	else
		-- iOS、Android
		registerLuaHandler(cbFlag, networkHandler, true)
		callRPC( cbFlag, rpcName, args, socketKey )
	end
end

-- 发送网络请求 仅iOS
function callRPC( cbFlag, rpcName, args, socketKey )
	local disp = BTEventDispatcher:getInstance()
	if(string.checkScriptVersion(g_publish_version, "5.0.0") >=0)then
		disp:callRPC(cbFlag, rpcName, args, socketKey)
	else
		disp:callRPC(cbFlag, rpcName, args)
	end
end

-- 注册lua层回调 仅iOS
function registerLuaHandler( cbFlag, networkHandler, autoRelease )
	local disp = BTEventDispatcher:getInstance()
    disp:addLuaHandler(cbFlag, networkHandler, autoRelease)
end

-- 网络统一接口
function networkHandler(cbFlag, dictData, bRet)
	
	if not bRet and g_debug_mode then
	-- 调试模式先调错误页面
		require "script/ui/tip/AlertTip"
		AlertTip.showAlert(dictData.err, function ( ... )
			-- body
		end)
	end

	-- 获得lua层的相关接口信息
	local requestLuaInfo = mContextMap[cbFlag]
	print_t(requestLuaInfo)
	if(requestLuaInfo ~= nil)then
		if(requestLuaInfo[3] == kTypeNormal)then
			LoadingUI.reduceLoadingUI()
		end

		if(requestLuaInfo[3] ~= kTypeRe)then
			mContextMap[cbFlag] = nil
		end
		if(requestLuaInfo[1] ~= nil)then
			requestLuaInfo[1](cbFlag, dictData, bRet)
		end
	else
		LoadingUI.reduceLoadingUI()
	end

end

-- 网络参数统一处理接口
function argsHandler(...)
	local args = CCArray:create()
	for k, v in ipairs({...}) do
		if (type(v) == "number") then
			args:addObject(CCInteger:create(v))
		elseif(type(v) == "string") then
			args:addObject(CCString:create(v))
		elseif(type(v) == "table") then
			args:addObject(argsHandler(v))
		else
			print("Error: unexpected type.")
		end
	end
	return args
end

-- 上面的函数在处理参数为table类型时出现溢出的bug
function argsHandlerOfTable(tParams)
	if table.isEmpty(tParams) then
		return nil
	end
	local args = CCArray:create()
	for i = 1, #tParams do
		local v = tParams[i]
		if (type(v) == "number") then
			args:addObject(CCInteger:create(v))
		elseif(type(v) == "string") then
			args:addObject(CCString:create(v))
		elseif(type(v) == "table") then
			args:addObject(argsHandlerOfTable(v))
		elseif(type(v) == "userdata") then
			args:addObject(v)
		else
			CCLuaLog("Error: unexpected type.")
		end
	end
	return args

end

-- lua层主动调用网络连接接口  仅WP  加Type
function connectWP (phost, pport, socketType)
	socketType = socketType or kSOCKET_TYPE_MAIN
	local mConn = CNetwork:sharedNetwork():newConnection()
	mConn:registerBodyFunc(function(body, head)
		onBodyData(body, head, socketType)
	end)

	mConn:registerCloseFunc(function()
		onClosed(socketType)
	end)
	
	if(mConn:connect(phost, pport))then
		return mConn
	end
	return nil
end

-- 发送请求 仅WP
function rpcCallWP(cbFlag, rpcName, args, socketKey)
	local wpConnect = getWPConnectBy(socketKey)
	args= toArgs(args)
	local request = {
		method=rpcName,
		args=args,
		token=wpConnect[1],
		callback={
			callbackName=cbFlag
		}
	}
	Logger.trace("request:%s", request)

	local data = amf3.encode(request)
	wpConnect[2]:send(data, true)
end

-- 获得 Connect 引用 仅WP
function getWPConnectBy( socketKey )
	return wpConnectMap[socketKey]
end

-- 被动断开回调  仅WP
function onClosed(socketType)
	Logger.warning("socket closed:%s", socketType)
	
	local context = mContextMap["failed"]
	if context ~= nil then
		local callback = context[1]
		local msg = {}
		msg.socketKey = socketType
		msg.NetWork = "NetWork"
		callback("failed", msg)
	else
		-- warning
		Logger.warning("no context when socket closed:%s", socketType)
	end
end

-- 网络请求完成 处理 仅WP
function onBodyData(body, head, socketType)
	Logger.trace("socketType:%s", socketType)
	local data = body
	local zipped, multi = string.byte(head, 6, 7);
	if zipped ~= 0 then
		data = GameUtil:unzipData(body)
	end

	data = amf3.decode(data)
	local rets = {}
	if multi ~= 0 then
		for i = 1, #data.ret do
			if type(data.ret[i]) == 'string' then
				data.ret[i] = amf3.decode(data.ret[i])
			end
			rets[i] = data.ret[i]
		end
	else
		rets[1] = data
	end

	Logger.trace("response:%s", rets)

	if data.time then
		BTUtil:syncTime(data.time)
	end
	if data.token ~= nil then
		wpConnectMap[socketType][1] = data.token
	end
	for i = 1, #rets do
		local ret = rets[i]
		if ret.err ~= "ping" then
			local callbackName = ret.callback.callbackName
			local context = mContextMap[callbackName]
			if(context~=nil)then
				Logger.trace("call:%s", callbackName)
				tableN2S(ret)
				networkHandler(callbackName, ret, ret.err == "ok")
			end
		end
	end
end

-- WP下处理userdata
function toArgs(args)
	local stype = type(args)
	if stype == 'table' then
		return args
	elseif stype == 'nil' then
		return {}
	elseif stype == 'userdata' then
		return cppToLua(args)
	else
		Logger.fatal("unsupported type:%s", stype)
	end
end

-- WP下处理userdata
function cppToLua(arg)
	local ret = nil
	if GameUtil:isCCArray(arg) then
		arg = tolua.cast(arg, "CCArray")
		ret = {}
		for i = 0, arg:count() - 1 do
			ret[i+1] = cppToLua(arg:objectAtIndex(i))
		end
	elseif GameUtil:isCCDictionary(arg) then
		arg = tolua.cast(arg, "CCDictionary")
		ret = {}
		local keys = arg:allKeys()
		if keys ~= nil then
			for i = 0, keys:count() -1 do
				local key = cppToLua(keys:objectAtIndex(i))
				ret[key] = cppToLua(arg:objectForKey(key))
			end
		end
	elseif GameUtil:isCCInteger(arg) then
		arg = tolua.cast(arg, "CCInteger")
		ret = arg:getValue()
	elseif GameUtil:isCCBool(arg) then
		arg = tolua.cast(arg, "CCBool")
		ret = arg:getValue()
	elseif GameUtil:isCCString(arg) then
		arg = tolua.cast(arg, "CCString")
		ret = arg:getCString()
	else
		Logger.trace("unsupported type:%s", tolua.type(arg))
	end
	return ret
end

-- WP专用 将table中的number 全部转成 string
function tableN2S(pTab)
	for k,v in pairs(pTab) do
		if(type(v) == "table")then
			tableN2S(v)
		elseif(type(v) == "number")then
			pTab[k] = tostring(v)
		else

		end
	end
end


