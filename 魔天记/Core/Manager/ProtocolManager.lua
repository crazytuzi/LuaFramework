require "Core.Net.PtCommand";
require "Core.Net.PtRegister"

SOCKET_CONNECT = "SOCKET_CONNECT";
SOCKET_DATA = "SOCKET_DATA";
SOCKET_CLOSE = "SOCKET_CLOSE";
SOCKET_ERROR = "SOCKET_ERROR";

ProtocolManager = {};

--[[local ProtocolManager_instance = {__index = ProtocolManager};  --创建一个表做实例对象的元表，__index 设置为 这个单例类
function ProtocolManager:new()
	local self = {};
	setmetatable( self , ProtocolManager_instance);
	--把全局的表ProtocolManager设置为self（新创建表）的元表的__index字段
	--每次获得单例时，创建一个self表（对象），该表继承全局表ProtocolManager，每次修改全局表中的字段后，下次再次调用时，该字段都是已经修改过的
	return self;
end--]]

local _sendHandlers = {};
local _receiveHandlers = {};
local _errorCodeHandler;
local _commands = {};
local _listeners = {};
local _sender;

local _OnReceive = function(buffer)
	local code, errCode = PtCommand:ReadHeader(buffer);
	if _commands[code] == nil then
		Error("解析数据失败，查看前后台协议是否一致");
		return;
	end
	
	if isDebug then
		log("Socket Receive: [" .. tostring(code) .. "," .. _commands[code].desc .. "," .. buffer:ToArray() .. "]");
	end	
	
	local hasBody = _commands[code]:HasBody();
	local down = _commands[code]:ReadBody();
	if _listeners[code] ~= nil then
		for i,v in ipairs(_listeners[code]) do
			if hasBody then
				v(errCode, down);
			else
				v(errCode);
			end
		end
		for i,v in ipairs(_receiveHandlers) do
			v(code);
		end
		if errCode ~= 0 and _errorCodeHandler ~= nil then
			_errorCodeHandler(errCode);
		end
	end
end

function ProtocolManager.Init(sender)
	_sender = sender;
	RegistProtocol();
--	EventManager.AddListener(SocketManager.instance, SOCKET_DATA, "ProtocolManager._OnRecevie", _OnReceive);
end

function ProtocolManager.RegistSendHandler(sendHandler)
	table.insert(_sendHandlers, sendHandler);
end

function ProtocolManager.RegistReceiveHandler(receiveHandler)
	table.insert(_receiveHandlers, receiveHandler);
end

function ProtocolManager.RegistErrorHandler(errorHandler)
	_errorCodeHandler = errorHandler;
end

function ProtocolManager.AddCommand(command)
	if _commands[command.code] ~= nil then
		Warning("协议号:[" .. tostring(command.code) .. ", " .. command.desc .. "] 已存在");
		return;
	end	
	_commands[command.code] = command;
end

function ProtocolManager.AddListener(code, handler)
	if _listeners[code] == nil then
		_listeners[code] = {handler};
	else
		if isDebug then
			for i,v in ipairs(_listeners[code]) do
				if v == handler then
					Error("不能注册相同协议侦听器：" .. tostring(code) .. "," .. handler);
					return;
				end
			end 
		end
		table.insert(_listeners[code], handler);
	end
end

function ProtocolManager.RemoveListener(code, handler)
	if _listeners[code] == nil then
		Warning("不存在协议侦听器，协议号：" .. tostring(code));
	else
		for i=#_listeners[code], 1, -1 do
            if _listeners[code][i] == handler then
                table.remove(_listeners[code], i);
            end
        end 
	end
end

function ProtocolManager.Send(code, up)
	if _sender ~= nil then
		_sender.Send(code, up);
		return;
	end
	--如果没有自定义发送器，采用默认方式发送
	ProtocolManager.SendPackage(code, up)
end

function ProtocolManager.SendPackage(code, up)
	if _commands[code] ~= nil then
		if isDebug then 			
			log("Socket send: [" .. tostring(code) .. "," .. _commands[code].desc .. "]"); 
		end
		local buffer = _commands[code]:Write(up);
		SocketManager.instance:SendMessage(buffer);
		for i,v in ipairs(_sendHandlers) do
			_sendHandlers[i](code);
		end
	end
end