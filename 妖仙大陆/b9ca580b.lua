





local Socket = require "Xmds.Pomelo.LuaGameSocket"
require "base64"
require "cardHandler_pb"


Pomelo = Pomelo or {}


Pomelo.CardHandler = {}

local function cardRegisterRequestEncoder(msg)
	local input = cardHandler_pb.CardRegisterRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function cardRegisterRequestDecoder(stream)
	local res = cardHandler_pb.CardRegisterResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.CardHandler.cardRegisterRequest(c2s_cardId,cb,option)
	local msg = {}
	msg.c2s_cardId = c2s_cardId
	Socket.OnRequestStart("area.cardHandler.cardRegisterRequest", option)
	Socket.Request("area.cardHandler.cardRegisterRequest", msg, function(res)
		if(res.s2c_code == 200) then
			Pomelo.CardHandler.lastCardRegisterResponse = res
			Socket.OnRequestEnd("area.cardHandler.cardRegisterRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] area.cardHandler.cardRegisterRequest decode error!!"
			end
			Socket.OnRequestEnd("area.cardHandler.cardRegisterRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, cardRegisterRequestEncoder, cardRegisterRequestDecoder)
end


local function cardLevelUpRequestEncoder(msg)
	local input = cardHandler_pb.CardLevelUpRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function cardLevelUpRequestDecoder(stream)
	local res = cardHandler_pb.CardLevelUpResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.CardHandler.cardLevelUpRequest(c2s_cardTemplateId,cb,option)
	local msg = {}
	msg.c2s_cardTemplateId = c2s_cardTemplateId
	Socket.OnRequestStart("area.cardHandler.cardLevelUpRequest", option)
	Socket.Request("area.cardHandler.cardLevelUpRequest", msg, function(res)
		if(res.s2c_code == 200) then
			Pomelo.CardHandler.lastCardLevelUpResponse = res
			Socket.OnRequestEnd("area.cardHandler.cardLevelUpRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] area.cardHandler.cardLevelUpRequest decode error!!"
			end
			Socket.OnRequestEnd("area.cardHandler.cardLevelUpRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, cardLevelUpRequestEncoder, cardLevelUpRequestDecoder)
end


local function cardPreLevelUpRequestEncoder(msg)
	local input = cardHandler_pb.CardPreLevelUpRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function cardPreLevelUpRequestDecoder(stream)
	local res = cardHandler_pb.CardPreLevelUpResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.CardHandler.cardPreLevelUpRequest(c2s_cardTemplateId,cb,option)
	local msg = {}
	msg.c2s_cardTemplateId = c2s_cardTemplateId
	Socket.OnRequestStart("area.cardHandler.cardPreLevelUpRequest", option)
	Socket.Request("area.cardHandler.cardPreLevelUpRequest", msg, function(res)
		if(res.s2c_code == 200) then
			Pomelo.CardHandler.lastCardPreLevelUpResponse = res
			Socket.OnRequestEnd("area.cardHandler.cardPreLevelUpRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] area.cardHandler.cardPreLevelUpRequest decode error!!"
			end
			Socket.OnRequestEnd("area.cardHandler.cardPreLevelUpRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, cardPreLevelUpRequestEncoder, cardPreLevelUpRequestDecoder)
end


local function cardGetAwardRequestEncoder(msg)
	local input = cardHandler_pb.CardGetAwardRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function cardGetAwardRequestDecoder(stream)
	local res = cardHandler_pb.CardGetAwardResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.CardHandler.cardGetAwardRequest(c2s_awardId,cb,option)
	local msg = {}
	msg.c2s_awardId = c2s_awardId
	Socket.OnRequestStart("area.cardHandler.cardGetAwardRequest", option)
	Socket.Request("area.cardHandler.cardGetAwardRequest", msg, function(res)
		if(res.s2c_code == 200) then
			Pomelo.CardHandler.lastCardGetAwardResponse = res
			Socket.OnRequestEnd("area.cardHandler.cardGetAwardRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] area.cardHandler.cardGetAwardRequest decode error!!"
			end
			Socket.OnRequestEnd("area.cardHandler.cardGetAwardRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, cardGetAwardRequestEncoder, cardGetAwardRequestDecoder)
end


local function cardEquipRequestEncoder(msg)
	local input = cardHandler_pb.CardEquipRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function cardEquipRequestDecoder(stream)
	local res = cardHandler_pb.CardEquipResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.CardHandler.cardEquipRequest(c2s_cardId,c2s_holePos,cb,option)
	local msg = {}
	msg.c2s_cardId = c2s_cardId
	msg.c2s_holePos = c2s_holePos
	Socket.OnRequestStart("area.cardHandler.cardEquipRequest", option)
	Socket.Request("area.cardHandler.cardEquipRequest", msg, function(res)
		if(res.s2c_code == 200) then
			Pomelo.CardHandler.lastCardEquipResponse = res
			Socket.OnRequestEnd("area.cardHandler.cardEquipRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] area.cardHandler.cardEquipRequest decode error!!"
			end
			Socket.OnRequestEnd("area.cardHandler.cardEquipRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, cardEquipRequestEncoder, cardEquipRequestDecoder)
end


local function cardQueryAllDataRequestEncoder(msg)
	local input = cardHandler_pb.CardQueryAllDataRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function cardQueryAllDataRequestDecoder(stream)
	local res = cardHandler_pb.CardQueryAllDataResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.CardHandler.cardQueryAllDataRequest(cb,option)
	local input = nil
	Socket.OnRequestStart("area.cardHandler.cardQueryAllDataRequest", option)
	Socket.Request("area.cardHandler.cardQueryAllDataRequest", input, function(res)
		if(res.s2c_code == 200) then
			Pomelo.CardHandler.lastCardQueryAllDataResponse = res
			Socket.OnRequestEnd("area.cardHandler.cardQueryAllDataRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] area.cardHandler.cardQueryAllDataRequest decode error!!"
			end
			Socket.OnRequestEnd("area.cardHandler.cardQueryAllDataRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, cardQueryAllDataRequestEncoder, cardQueryAllDataRequestDecoder)
end





return Pomelo
