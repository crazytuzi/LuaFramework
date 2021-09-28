





local Socket = require "Xmds.Pomelo.LuaGameSocket"
require "base64"
require "functionOpenHandler_pb"


Pomelo = Pomelo or {}


Pomelo.FunctionOpenHandler = {}

local function getFunctionListRequestEncoder(msg)
	local input = functionOpenHandler_pb.GetFunctionListRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function getFunctionListRequestDecoder(stream)
	local res = functionOpenHandler_pb.GetFunctionListResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.FunctionOpenHandler.getFunctionListRequest(cb,option)
	local input = nil
	Socket.OnRequestStart("area.functionOpenHandler.getFunctionListRequest", option)
	Socket.Request("area.functionOpenHandler.getFunctionListRequest", input, function(res)
		if(res.s2c_code == 200) then
			Pomelo.FunctionOpenHandler.lastGetFunctionListResponse = res
			Socket.OnRequestEnd("area.functionOpenHandler.getFunctionListRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] area.functionOpenHandler.getFunctionListRequest decode error!!"
			end
			Socket.OnRequestEnd("area.functionOpenHandler.getFunctionListRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, getFunctionListRequestEncoder, getFunctionListRequestDecoder)
end


local function setFunctionPlayedRequestEncoder(msg)
	local input = functionOpenHandler_pb.SetFunctionPlayedRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function setFunctionPlayedRequestDecoder(stream)
	local res = functionOpenHandler_pb.SetFunctionPlayedResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.FunctionOpenHandler.setFunctionPlayedRequest(functionName,cb,option)
	local msg = {}
	msg.functionName = functionName
	Socket.OnRequestStart("area.functionOpenHandler.setFunctionPlayedRequest", option)
	Socket.Request("area.functionOpenHandler.setFunctionPlayedRequest", msg, function(res)
		if(res.s2c_code == 200) then
			Pomelo.FunctionOpenHandler.lastSetFunctionPlayedResponse = res
			Socket.OnRequestEnd("area.functionOpenHandler.setFunctionPlayedRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] area.functionOpenHandler.setFunctionPlayedRequest decode error!!"
			end
			Socket.OnRequestEnd("area.functionOpenHandler.setFunctionPlayedRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, setFunctionPlayedRequestEncoder, setFunctionPlayedRequestDecoder)
end


local function receiveFunctionAwardRequestEncoder(msg)
	local input = functionOpenHandler_pb.ReceiveFunctionAwardRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function receiveFunctionAwardRequestDecoder(stream)
	local res = functionOpenHandler_pb.ReceiveFunctionAwardResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.FunctionOpenHandler.receiveFunctionAwardRequest(guide_id,cb,option)
	local msg = {}
	msg.guide_id = guide_id
	Socket.OnRequestStart("area.functionOpenHandler.receiveFunctionAwardRequest", option)
	Socket.Request("area.functionOpenHandler.receiveFunctionAwardRequest", msg, function(res)
		if(res.s2c_code == 200) then
			Pomelo.FunctionOpenHandler.lastReceiveFunctionAwardResponse = res
			Socket.OnRequestEnd("area.functionOpenHandler.receiveFunctionAwardRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] area.functionOpenHandler.receiveFunctionAwardRequest decode error!!"
			end
			Socket.OnRequestEnd("area.functionOpenHandler.receiveFunctionAwardRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, receiveFunctionAwardRequestEncoder, receiveFunctionAwardRequestDecoder)
end


local function functionOpenListPushDecoder(stream)
	local res = functionOpenHandler_pb.FunctionOpenListPush()
	res:ParseFromString(stream)
	return res
end

function Pomelo.FunctionOpenHandler.functionOpenListPush(cb)
	Socket.On("area.functionOpenPush.functionOpenListPush", function(res) 
		Pomelo.FunctionOpenHandler.lastFunctionOpenListPush = res
		cb(nil,res) 
	end, functionOpenListPushDecoder) 
end


local function functionAwardListPushDecoder(stream)
	local res = functionOpenHandler_pb.FunctionAwardListPush()
	res:ParseFromString(stream)
	return res
end

function Pomelo.FunctionOpenHandler.functionAwardListPush(cb)
	Socket.On("area.functionOpenPush.functionAwardListPush", function(res) 
		Pomelo.FunctionOpenHandler.lastFunctionAwardListPush = res
		cb(nil,res) 
	end, functionAwardListPushDecoder) 
end





return Pomelo
