





local Socket = require "Xmds.Pomelo.LuaGameSocket"
require "base64"
require "petNewHandler_pb"


Pomelo = Pomelo or {}


Pomelo.PetNewHandler = {}

local function getAllPetsInfoRequestEncoder(msg)
	local input = petNewHandler_pb.GetAllPetsInfoRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function getAllPetsInfoRequestDecoder(stream)
	local res = petNewHandler_pb.GetAllPetsInfoResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.PetNewHandler.getAllPetsInfoRequest(cb,option)
	local input = nil
	Socket.OnRequestStart("area.petNewHandler.getAllPetsInfoRequest", option)
	Socket.Request("area.petNewHandler.getAllPetsInfoRequest", input, function(res)
		if(res.s2c_code == 200) then
			Pomelo.PetNewHandler.lastGetAllPetsInfoResponse = res
			Socket.OnRequestEnd("area.petNewHandler.getAllPetsInfoRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] area.petNewHandler.getAllPetsInfoRequest decode error!!"
			end
			Socket.OnRequestEnd("area.petNewHandler.getAllPetsInfoRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, getAllPetsInfoRequestEncoder, getAllPetsInfoRequestDecoder)
end


local function summonPetRequestEncoder(msg)
	local input = petNewHandler_pb.SummonPetRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function summonPetRequestDecoder(stream)
	local res = petNewHandler_pb.SummonPetResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.PetNewHandler.summonPetRequest(c2s_id,cb,option)
	local msg = {}
	msg.c2s_id = c2s_id
	Socket.OnRequestStart("area.petNewHandler.summonPetRequest", option)
	Socket.Request("area.petNewHandler.summonPetRequest", msg, function(res)
		if(res.s2c_code == 200) then
			Pomelo.PetNewHandler.lastSummonPetResponse = res
			Socket.OnRequestEnd("area.petNewHandler.summonPetRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] area.petNewHandler.summonPetRequest decode error!!"
			end
			Socket.OnRequestEnd("area.petNewHandler.summonPetRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, summonPetRequestEncoder, summonPetRequestDecoder)
end


local function upGradeUpLevelRequestEncoder(msg)
	local input = petNewHandler_pb.UpGradeUpLevelRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function upGradeUpLevelRequestDecoder(stream)
	local res = petNewHandler_pb.UpGradeUpLevelResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.PetNewHandler.upGradeUpLevelRequest(c2s_id,cb,option)
	local msg = {}
	msg.c2s_id = c2s_id
	Socket.OnRequestStart("area.petNewHandler.upGradeUpLevelRequest", option)
	Socket.Request("area.petNewHandler.upGradeUpLevelRequest", msg, function(res)
		if(res.s2c_code == 200) then
			Pomelo.PetNewHandler.lastUpGradeUpLevelResponse = res
			Socket.OnRequestEnd("area.petNewHandler.upGradeUpLevelRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] area.petNewHandler.upGradeUpLevelRequest decode error!!"
			end
			Socket.OnRequestEnd("area.petNewHandler.upGradeUpLevelRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, upGradeUpLevelRequestEncoder, upGradeUpLevelRequestDecoder)
end


local function addExpByItemRequestEncoder(msg)
	local input = petNewHandler_pb.AddExpByItemRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function addExpByItemRequestDecoder(stream)
	local res = petNewHandler_pb.AddExpByItemResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.PetNewHandler.addExpByItemRequest(c2s_id,c2s_itemCode,cb,option)
	local msg = {}
	msg.c2s_id = c2s_id
	msg.c2s_itemCode = c2s_itemCode
	Socket.OnRequestStart("area.petNewHandler.addExpByItemRequest", option)
	Socket.Request("area.petNewHandler.addExpByItemRequest", msg, function(res)
		if(res.s2c_code == 200) then
			Pomelo.PetNewHandler.lastAddExpByItemResponse = res
			Socket.OnRequestEnd("area.petNewHandler.addExpByItemRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] area.petNewHandler.addExpByItemRequest decode error!!"
			end
			Socket.OnRequestEnd("area.petNewHandler.addExpByItemRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, addExpByItemRequestEncoder, addExpByItemRequestDecoder)
end


local function upgradeOneLevelRequestEncoder(msg)
	local input = petNewHandler_pb.UpgradeOneLevelRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function upgradeOneLevelRequestDecoder(stream)
	local res = petNewHandler_pb.UpgradeOneLevelResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.PetNewHandler.upgradeOneLevelRequest(c2s_id,cb,option)
	local msg = {}
	msg.c2s_id = c2s_id
	Socket.OnRequestStart("area.petNewHandler.upgradeOneLevelRequest", option)
	Socket.Request("area.petNewHandler.upgradeOneLevelRequest", msg, function(res)
		if(res.s2c_code == 200) then
			Pomelo.PetNewHandler.lastUpgradeOneLevelResponse = res
			Socket.OnRequestEnd("area.petNewHandler.upgradeOneLevelRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] area.petNewHandler.upgradeOneLevelRequest decode error!!"
			end
			Socket.OnRequestEnd("area.petNewHandler.upgradeOneLevelRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, upgradeOneLevelRequestEncoder, upgradeOneLevelRequestDecoder)
end


local function upgradeToTopRequestEncoder(msg)
	local input = petNewHandler_pb.UpgradeToTopRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function upgradeToTopRequestDecoder(stream)
	local res = petNewHandler_pb.UpgradeToTopResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.PetNewHandler.upgradeToTopRequest(c2s_id,cb,option)
	local msg = {}
	msg.c2s_id = c2s_id
	Socket.OnRequestStart("area.petNewHandler.upgradeToTopRequest", option)
	Socket.Request("area.petNewHandler.upgradeToTopRequest", msg, function(res)
		if(res.s2c_code == 200) then
			Pomelo.PetNewHandler.lastUpgradeToTopResponse = res
			Socket.OnRequestEnd("area.petNewHandler.upgradeToTopRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] area.petNewHandler.upgradeToTopRequest decode error!!"
			end
			Socket.OnRequestEnd("area.petNewHandler.upgradeToTopRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, upgradeToTopRequestEncoder, upgradeToTopRequestDecoder)
end


local function changePetNameNewRequestEncoder(msg)
	local input = petNewHandler_pb.ChangePetNameNewRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function changePetNameNewRequestDecoder(stream)
	local res = petNewHandler_pb.ChangePetNameNewResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.PetNewHandler.changePetNameNewRequest(c2s_id,c2s_name,cb,option)
	local msg = {}
	msg.c2s_id = c2s_id
	msg.c2s_name = c2s_name
	Socket.OnRequestStart("area.petNewHandler.changePetNameNewRequest", option)
	Socket.Request("area.petNewHandler.changePetNameNewRequest", msg, function(res)
		if(res.s2c_code == 200) then
			Pomelo.PetNewHandler.lastChangePetNameNewResponse = res
			Socket.OnRequestEnd("area.petNewHandler.changePetNameNewRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] area.petNewHandler.changePetNameNewRequest decode error!!"
			end
			Socket.OnRequestEnd("area.petNewHandler.changePetNameNewRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, changePetNameNewRequestEncoder, changePetNameNewRequestDecoder)
end


local function petFightRequestEncoder(msg)
	local input = petNewHandler_pb.PetFightRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function petFightRequestDecoder(stream)
	local res = petNewHandler_pb.PetFightResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.PetNewHandler.petFightRequest(c2s_id,c2s_type,cb,option)
	local msg = {}
	msg.c2s_id = c2s_id
	msg.c2s_type = c2s_type
	Socket.OnRequestStart("area.petNewHandler.petFightRequest", option)
	Socket.Request("area.petNewHandler.petFightRequest", msg, function(res)
		if(res.s2c_code == 200) then
			Pomelo.PetNewHandler.lastPetFightResponse = res
			Socket.OnRequestEnd("area.petNewHandler.petFightRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] area.petNewHandler.petFightRequest decode error!!"
			end
			Socket.OnRequestEnd("area.petNewHandler.petFightRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, petFightRequestEncoder, petFightRequestDecoder)
end


local function getPetInfoNewRequestEncoder(msg)
	local input = petNewHandler_pb.GetPetInfoNewRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function getPetInfoNewRequestDecoder(stream)
	local res = petNewHandler_pb.GetPetInfoNewResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.PetNewHandler.getPetInfoNewRequest(c2s_petId,c2s_ownId,cb,option)
	local msg = {}
	msg.c2s_petId = c2s_petId
	msg.c2s_ownId = c2s_ownId
	Socket.OnRequestStart("area.petNewHandler.getPetInfoNewRequest", option)
	Socket.Request("area.petNewHandler.getPetInfoNewRequest", msg, function(res)
		if(res.s2c_code == 200) then
			Pomelo.PetNewHandler.lastGetPetInfoNewResponse = res
			Socket.OnRequestEnd("area.petNewHandler.getPetInfoNewRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] area.petNewHandler.getPetInfoNewRequest decode error!!"
			end
			Socket.OnRequestEnd("area.petNewHandler.getPetInfoNewRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, getPetInfoNewRequestEncoder, getPetInfoNewRequestDecoder)
end


local function onNewPetDetailPushDecoder(stream)
	local res = petNewHandler_pb.OnNewPetDetailPush()
	res:ParseFromString(stream)
	return res
end

function Pomelo.PetNewHandler.onNewPetDetailPush(cb)
	Socket.On("area.petNewPush.onNewPetDetailPush", function(res) 
		Pomelo.PetNewHandler.lastOnNewPetDetailPush = res
		cb(nil,res) 
	end, onNewPetDetailPushDecoder) 
end


local function petExpUpdatePushDecoder(stream)
	local res = petNewHandler_pb.PetExpUpdatePush()
	res:ParseFromString(stream)
	return res
end

function Pomelo.PetNewHandler.petExpUpdatePush(cb)
	Socket.On("area.petNewPush.petExpUpdatePush", function(res) 
		Pomelo.PetNewHandler.lastPetExpUpdatePush = res
		cb(nil,res) 
	end, petExpUpdatePushDecoder) 
end


local function petInfoUpdatePushDecoder(stream)
	local res = petNewHandler_pb.PetInfoUpdatePush()
	res:ParseFromString(stream)
	return res
end

function Pomelo.PetNewHandler.petInfoUpdatePush(cb)
	Socket.On("area.petNewPush.petInfoUpdatePush", function(res) 
		Pomelo.PetNewHandler.lastPetInfoUpdatePush = res
		cb(nil,res) 
	end, petInfoUpdatePushDecoder) 
end





return Pomelo
