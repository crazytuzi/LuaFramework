require "Core.Module.UIRequest.UIRequestNotes"
local json = require "cjson"


SocketClientLua = {};

SocketClientLua.EVENT_CONNECTION_SUCCEED = "event_connection_succeed";
SocketClientLua.EVENT_RECONNECTION_SUCCEED = "event_reconnection_succeed";  -- tangping
SocketClientLua.EVENT_CONNECTION_FAIL = "event_connection_fail";
SocketClientLua.EVENT_CONNECTION_TIMEOUT = "event_connection_timeout";
SocketClientLua.EVENT_DISCONNECT = "event_disconnect";

local _ins = nil;
local _showLoading = false;
local _currentCmd = - 1;
local msgPack = require "net.MessagePack"
local allSendCommon = {}
local printLog = true
function SocketClientLua.Get_ins()
	if _ins == nil then
		_ins = SocketClientLua:New();
	end
	return _ins;
end

function SocketClientLua:New(o)
	o = o or {};
	setmetatable(o, {__index = self});
	
	o.socket = TcpGameClientForLua.New();
	-- c# 的接口类
	o.listeners = {};
	o.statuHandler = nil;
	--开启关闭网络消息打印
	 
	return o;
end

local ignorErrorCode = {1, 5, 6, 7}   -- 忽略协议错误显示显示的错误码  
local ignorePrintCmds = {0x010a, 0x0306, 0x0307, 0x0308, 0x0601, 0x0602, 0x0603, 0x0604, 0x0605};

function SocketClientLua:DisDataInHandler(cmd_int, data_table)
	local key_listeners = self.listeners[cmd_int];
	if(data_table.errMsg) then
		log(data_table.errMsg)
	end
	if(data_table.errCode and not table.contains(ignorErrorCode, data_table.errCode)) then
		if(data_table.errMsg) then			
			MsgUtils.ShowTips(nil, nil, nil, data_table.errMsg);
		end
	end
	
	
	if key_listeners ~= nil then
		for key, v in pairs(key_listeners) do
			--Warning(string.format("%#x:%s",cmd_int, v._hname))
			if GameSceneManager.debug then Profiler.BeginSample(string.format("%#x:%s", cmd_int, v._hname)) end
			if(v.owner ~= nil) then
				v.hander(v.owner, cmd_int, data_table);
			else
				v.hander(cmd_int, data_table);
			end
			if GameSceneManager.debug then Profiler.EndSample() end
			-- callBackHandler
		end
		-- end for
	end
	-- end if
end

-- 添加 数据进入回调
function SocketClientLua:AddDataPacketListener(cmd_int, handler, owner)
	local key_listeners = self.listeners[cmd_int];
	if key_listeners == nil then
		self.listeners[cmd_int] = {};
	end
	
	if(self.listeners[cmd_int] [handler] == nil) then
		self.listeners[cmd_int] [handler] = {}
	end
	self.listeners[cmd_int] [handler].hander = handler;
	if owner ~= nil then
		self.listeners[cmd_int] [handler].owner = owner
	end
	if GameSceneManager.debug then self.listeners[cmd_int] [handler]._hname = GetClassFuncName(3) end
end


-- 移除 数据进入回调
function SocketClientLua:RemoveDataPacketListener(cmd_int, handler)
	local key_listeners = self.listeners[cmd_int];
	if key_listeners ~= nil then
		
		for key, value in pairs(key_listeners) do
			
			if key == handler then
				key_listeners[key] = nil;
				return;
			end
			-- end if
		end
		-- end for
	end
	--  end if
end

--  数据进入
function SocketClientLua.DataIn(cmd_int, data)
	--     SocketClientLua.Get_ins():DisDataInHandler(cmd_int, data);
	--    if (useNew) then
	--        SocketClientLua.Get_ins():DisDataInHandler(cmd_int, data);
	--    else
	-- log(" S <-- " .. string.format("0x%X", cmd_int) .. " , " .. data)
	if printLog and not table.contains(ignorePrintCmds, cmd_int) then 
		log(string.format("S <-- cmd=0x%X, data=%s", cmd_int, data)) 
	end
	local obj = json.decode(data);
	SocketClientLua.Get_ins():DisDataInHandler(cmd_int, obj);
	--    end
	SocketClientLua:ClearLoading(cmd_int);
end

-- 连接 服务器 情况回调
function SocketClientLua.NetStatuHandler(statu, err)
	local ins = SocketClientLua.Get_ins();
	local fun = ins.statuHandler;
	if fun ~= nil then
		fun(statu, err);
	end
	SocketClientLua:ClearLoading(- 1);
end

function SocketClientLua:Connect(ip, port, _statuHandler)
	self.statuHandler = _statuHandler;
	self.socket:Connect(ip, port);
	
	-- tp.connect(ip, port, 10, nil)
end

-- 改变连接状态处理器 --tangping
function SocketClientLua:ChangeStatuHandler(_statuHandler)
	self.statuHandler = _statuHandler;
end


local notCheckCommon = {511, 774, 775, 776, 795, 1539, 518, 519, 520, 521, 523, 4609, 1028, 2056, 0x1540}

local useNew = true
-- 发送数据, showLoading是否显示请求屏障
-- 添加发送成功或失败标识
function SocketClientLua:SendMessage(cmd_int, data_table, showLoading)
	
	if(useNew) then		
		if(not table.contains(notCheckCommon, cmd_int)) then
			if(allSendCommon[cmd_int]) then		
				local internal = GetTimeMillisecond() - allSendCommon[cmd_int]		
				if(internal < 200 and internal >= 0) then				
					return false
				else	
					allSendCommon[cmd_int] = GetTimeMillisecond()	
				end
			else
				
				allSendCommon[cmd_int] = GetTimeMillisecond()
			end
		end
		local data = msgPack.pack(data_table)
		
		if printLog and not table.contains(ignorePrintCmds, cmd_int) then 
			log(string.format("C --> cmd=0x%X, data=%s", cmd_int, json.encode(data_table))) 
		end
		
		if(#data == 1) then
			self.socket:SendMessage(cmd_int, "")
		else
			self.socket:SendMessage(cmd_int, data)
		end
		
	else
		local str = json.encode(data_table);
		self.socket:SendMessage(cmd_int, str);
	end
	
	if showLoading then
		SocketClientLua:ShowLoading(cmd_int);
	end
	return true
end



function SocketClientLua:SendTestMessage(cmd_int, str)
	local data = json.decode(str)
	self:SendMessage(cmd_int, data, false)
end

-- tangping
function SocketClientLua:ShowLoading(cmd_int)
	-- log("SocketClientLua:ShowLoading:cmd=" .. cmd_int);
	ModuleManager.SendNotification(UIRequestNotes.OPEN_REQUEST_PANEL);
	_currentCmd = cmd_int;
	_showLoading = true;
end

function SocketClientLua:ClearLoading(cmd_int)
	if _showLoading == false then
		return;
	end
	-- log("SocketClientLua:ClearLoading:cmd=" .. cmd_int..",_currentCmd=".._currentCmd);
	if cmd_int ~= _currentCmd and cmd_int ~= - 1 then return; end;
	ModuleManager.SendNotification(UIRequestNotes.CLOSE_REQUEST_PANEL);
	_currentCmd = - 1;
	_showLoading = false;
end

function SocketClientLua:Close()
	self.socket:Close()
	--    self.socket = nil
	_currentCmd = - 1;
	_showLoading = false;
	--    _ins = nil
end
