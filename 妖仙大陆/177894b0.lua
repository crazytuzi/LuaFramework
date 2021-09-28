





local Socket = require "Xmds.Pomelo.LuaGameSocket"
require "base64"
require "guildDepotHandler_pb"


Pomelo = Pomelo or {}


Pomelo.GuildDepotHandler = {}

local function depositItemRequestEncoder(msg)
	local input = guildDepotHandler_pb.DepositItemRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function depositItemRequestDecoder(stream)
	local res = guildDepotHandler_pb.DepositItemResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.GuildDepotHandler.depositItemRequest(c2s_fromIndex,cb,option)
	local msg = {}
	msg.c2s_fromIndex = c2s_fromIndex
	Socket.OnRequestStart("area.guildDepotHandler.depositItemRequest", option)
	Socket.Request("area.guildDepotHandler.depositItemRequest", msg, function(res)
		if(res.s2c_code == 200) then
			Pomelo.GuildDepotHandler.lastDepositItemResponse = res
			Socket.OnRequestEnd("area.guildDepotHandler.depositItemRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] area.guildDepotHandler.depositItemRequest decode error!!"
			end
			Socket.OnRequestEnd("area.guildDepotHandler.depositItemRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, depositItemRequestEncoder, depositItemRequestDecoder)
end


local function takeOutItemRequestEncoder(msg)
	local input = guildDepotHandler_pb.TakeOutItemRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function takeOutItemRequestDecoder(stream)
	local res = guildDepotHandler_pb.TakeOutItemResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.GuildDepotHandler.takeOutItemRequest(c2s_fromIndex,cb,option)
	local msg = {}
	msg.c2s_fromIndex = c2s_fromIndex
	Socket.OnRequestStart("area.guildDepotHandler.takeOutItemRequest", option)
	Socket.Request("area.guildDepotHandler.takeOutItemRequest", msg, function(res)
		if(res.s2c_code == 200) then
			Pomelo.GuildDepotHandler.lastTakeOutItemResponse = res
			Socket.OnRequestEnd("area.guildDepotHandler.takeOutItemRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] area.guildDepotHandler.takeOutItemRequest decode error!!"
			end
			Socket.OnRequestEnd("area.guildDepotHandler.takeOutItemRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, takeOutItemRequestEncoder, takeOutItemRequestDecoder)
end


local function setConditionRequestEncoder(msg)
	local input = guildDepotHandler_pb.SetConditionRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function setConditionRequestDecoder(stream)
	local res = guildDepotHandler_pb.SetConditionResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.GuildDepotHandler.setConditionRequest(useLevel,useUpLevel,useJob,minLevel,minUpLevel,minqColor,maxLevel,maxUpLevel,maxqColor,cb,option)
	local msg = {}
	msg.useLevel = useLevel
	msg.useUpLevel = useUpLevel
	msg.useJob = useJob
	msg.minLevel = minLevel
	msg.minUpLevel = minUpLevel
	msg.minqColor = minqColor
	msg.maxLevel = maxLevel
	msg.maxUpLevel = maxUpLevel
	msg.maxqColor = maxqColor
	Socket.OnRequestStart("area.guildDepotHandler.setConditionRequest", option)
	Socket.Request("area.guildDepotHandler.setConditionRequest", msg, function(res)
		if(res.s2c_code == 200) then
			Pomelo.GuildDepotHandler.lastSetConditionResponse = res
			Socket.OnRequestEnd("area.guildDepotHandler.setConditionRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] area.guildDepotHandler.setConditionRequest decode error!!"
			end
			Socket.OnRequestEnd("area.guildDepotHandler.setConditionRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, setConditionRequestEncoder, setConditionRequestDecoder)
end


local function deleteItemRequestEncoder(msg)
	local input = guildDepotHandler_pb.DeleteItemRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function deleteItemRequestDecoder(stream)
	local res = guildDepotHandler_pb.DeleteItemResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.GuildDepotHandler.deleteItemRequest(c2s_fromIndex,cb,option)
	local msg = {}
	msg.c2s_fromIndex = c2s_fromIndex
	Socket.OnRequestStart("area.guildDepotHandler.deleteItemRequest", option)
	Socket.Request("area.guildDepotHandler.deleteItemRequest", msg, function(res)
		if(res.s2c_code == 200) then
			Pomelo.GuildDepotHandler.lastDeleteItemResponse = res
			Socket.OnRequestEnd("area.guildDepotHandler.deleteItemRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] area.guildDepotHandler.deleteItemRequest decode error!!"
			end
			Socket.OnRequestEnd("area.guildDepotHandler.deleteItemRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, deleteItemRequestEncoder, deleteItemRequestDecoder)
end


local function upgradeDepotRequestEncoder(msg)
	local input = guildDepotHandler_pb.UpgradeDepotRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function upgradeDepotRequestDecoder(stream)
	local res = guildDepotHandler_pb.UpgradeDepotResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.GuildDepotHandler.upgradeDepotRequest(cb,option)
	local input = nil
	Socket.OnRequestStart("area.guildDepotHandler.upgradeDepotRequest", option)
	Socket.Request("area.guildDepotHandler.upgradeDepotRequest", input, function(res)
		if(res.s2c_code == 200) then
			Pomelo.GuildDepotHandler.lastUpgradeDepotResponse = res
			Socket.OnRequestEnd("area.guildDepotHandler.upgradeDepotRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] area.guildDepotHandler.upgradeDepotRequest decode error!!"
			end
			Socket.OnRequestEnd("area.guildDepotHandler.upgradeDepotRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, upgradeDepotRequestEncoder, upgradeDepotRequestDecoder)
end


local function depotRefreshPushDecoder(stream)
	local res = guildDepotHandler_pb.DepotRefreshPush()
	res:ParseFromString(stream)
	return res
end

function Pomelo.GuildDepotHandler.depotRefreshPush(cb)
	Socket.On("area.guildDepotPush.depotRefreshPush", function(res) 
		Pomelo.GuildDepotHandler.lastDepotRefreshPush = res
		cb(nil,res) 
	end, depotRefreshPushDecoder) 
end





return Pomelo
