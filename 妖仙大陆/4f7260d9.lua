





local Socket = require "Xmds.Pomelo.LuaGameSocket"
require "base64"
require "petHandler_pb"


Pomelo = Pomelo or {}


Pomelo.PetHandler = {}

local function getAllPetsBaseInfoRequestEncoder(msg)
	local input = petHandler_pb.GetAllPetsBaseInfoRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function getAllPetsBaseInfoRequestDecoder(stream)
	local res = petHandler_pb.GetAllPetsBaseInfoResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.PetHandler.getAllPetsBaseInfoRequest(cb,option)
	local input = nil
	Socket.OnRequestStart("area.petHandler.getAllPetsBaseInfoRequest", option)
	Socket.Request("area.petHandler.getAllPetsBaseInfoRequest", input, function(res)
		if(res.s2c_code == 200) then
			Pomelo.PetHandler.lastGetAllPetsBaseInfoResponse = res
			Socket.OnRequestEnd("area.petHandler.getAllPetsBaseInfoRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] area.petHandler.getAllPetsBaseInfoRequest decode error!!"
			end
			Socket.OnRequestEnd("area.petHandler.getAllPetsBaseInfoRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, getAllPetsBaseInfoRequestEncoder, getAllPetsBaseInfoRequestDecoder)
end


local function getPetInfoRequestEncoder(msg)
	local input = petHandler_pb.GetPetInfoRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function getPetInfoRequestDecoder(stream)
	local res = petHandler_pb.GetPetInfoResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.PetHandler.getPetInfoRequest(s2c_petId,s2c_ownId,cb,option)
	local msg = {}
	msg.s2c_petId = s2c_petId
	msg.s2c_ownId = s2c_ownId
	Socket.OnRequestStart("area.petHandler.getPetInfoRequest", option)
	Socket.Request("area.petHandler.getPetInfoRequest", msg, function(res)
		if(res.s2c_code == 200) then
			Pomelo.PetHandler.lastGetPetInfoResponse = res
			Socket.OnRequestEnd("area.petHandler.getPetInfoRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] area.petHandler.getPetInfoRequest decode error!!"
			end
			Socket.OnRequestEnd("area.petHandler.getPetInfoRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, getPetInfoRequestEncoder, getPetInfoRequestDecoder)
end


local function developPetRequestEncoder(msg)
	local input = petHandler_pb.DevelopPetRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function developPetRequestDecoder(stream)
	local res = petHandler_pb.DevelopPetResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.PetHandler.developPetRequest(s2c_type,s2c_itemCode,s2c_petId,cb,option)
	local msg = {}
	msg.s2c_type = s2c_type
	msg.s2c_itemCode = s2c_itemCode
	msg.s2c_petId = s2c_petId
	Socket.OnRequestStart("area.petHandler.developPetRequest", option)
	Socket.Request("area.petHandler.developPetRequest", msg, function(res)
		if(res.s2c_code == 200) then
			Pomelo.PetHandler.lastDevelopPetResponse = res
			Socket.OnRequestEnd("area.petHandler.developPetRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] area.petHandler.developPetRequest decode error!!"
			end
			Socket.OnRequestEnd("area.petHandler.developPetRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, developPetRequestEncoder, developPetRequestDecoder)
end


local function changePetNameRequestEncoder(msg)
	local input = petHandler_pb.ChangePetNameRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function changePetNameRequestDecoder(stream)
	local res = petHandler_pb.ChangePetNameResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.PetHandler.changePetNameRequest(s2c_petId,s2c_petName,cb,option)
	local msg = {}
	msg.s2c_petId = s2c_petId
	msg.s2c_petName = s2c_petName
	Socket.OnRequestStart("area.petHandler.changePetNameRequest", option)
	Socket.Request("area.petHandler.changePetNameRequest", msg, function(res)
		if(res.s2c_code == 200) then
			Pomelo.PetHandler.lastChangePetNameResponse = res
			Socket.OnRequestEnd("area.petHandler.changePetNameRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] area.petHandler.changePetNameRequest decode error!!"
			end
			Socket.OnRequestEnd("area.petHandler.changePetNameRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, changePetNameRequestEncoder, changePetNameRequestDecoder)
end


local function freePetRequestEncoder(msg)
	local input = petHandler_pb.FreePetRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function freePetRequestDecoder(stream)
	local res = petHandler_pb.FreePetResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.PetHandler.freePetRequest(s2c_petId,s2c_type,cb,option)
	local msg = {}
	msg.s2c_petId = s2c_petId
	msg.s2c_type = s2c_type
	Socket.OnRequestStart("area.petHandler.freePetRequest", option)
	Socket.Request("area.petHandler.freePetRequest", msg, function(res)
		if(res.s2c_code == 200) then
			Pomelo.PetHandler.lastFreePetResponse = res
			Socket.OnRequestEnd("area.petHandler.freePetRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] area.petHandler.freePetRequest decode error!!"
			end
			Socket.OnRequestEnd("area.petHandler.freePetRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, freePetRequestEncoder, freePetRequestDecoder)
end


local function petOutFightRequestEncoder(msg)
	local input = petHandler_pb.PetOutFightRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function petOutFightRequestDecoder(stream)
	local res = petHandler_pb.PetOutFightResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.PetHandler.petOutFightRequest(s2c_petId,s2c_type,cb,option)
	local msg = {}
	msg.s2c_petId = s2c_petId
	msg.s2c_type = s2c_type
	Socket.OnRequestStart("area.petHandler.petOutFightRequest", option)
	Socket.Request("area.petHandler.petOutFightRequest", msg, function(res)
		if(res.s2c_code == 200) then
			Pomelo.PetHandler.lastPetOutFightResponse = res
			Socket.OnRequestEnd("area.petHandler.petOutFightRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] area.petHandler.petOutFightRequest decode error!!"
			end
			Socket.OnRequestEnd("area.petHandler.petOutFightRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, petOutFightRequestEncoder, petOutFightRequestDecoder)
end


local function petReliveRequestEncoder(msg)
	local input = petHandler_pb.PetReliveRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function petReliveRequestDecoder(stream)
	local res = petHandler_pb.PetReliveResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.PetHandler.petReliveRequest(s2c_petId,cb,option)
	local msg = {}
	msg.s2c_petId = s2c_petId
	Socket.OnRequestStart("area.petHandler.petReliveRequest", option)
	Socket.Request("area.petHandler.petReliveRequest", msg, function(res)
		if(res.s2c_code == 200) then
			Pomelo.PetHandler.lastPetReliveResponse = res
			Socket.OnRequestEnd("area.petHandler.petReliveRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] area.petHandler.petReliveRequest decode error!!"
			end
			Socket.OnRequestEnd("area.petHandler.petReliveRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, petReliveRequestEncoder, petReliveRequestDecoder)
end


local function randPetNameRequestEncoder(msg)
	local input = petHandler_pb.RandPetNameRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function randPetNameRequestDecoder(stream)
	local res = petHandler_pb.RandPetNameResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.PetHandler.randPetNameRequest(cb,option)
	local input = nil
	Socket.OnRequestStart("area.petHandler.randPetNameRequest", option)
	Socket.Request("area.petHandler.randPetNameRequest", input, function(res)
		if(res.s2c_code == 200) then
			Pomelo.PetHandler.lastRandPetNameResponse = res
			Socket.OnRequestEnd("area.petHandler.randPetNameRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] area.petHandler.randPetNameRequest decode error!!"
			end
			Socket.OnRequestEnd("area.petHandler.randPetNameRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, randPetNameRequestEncoder, randPetNameRequestDecoder)
end


local function upGradeInfoRequestEncoder(msg)
	local input = petHandler_pb.UpGradeInfoRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function upGradeInfoRequestDecoder(stream)
	local res = petHandler_pb.UpGradeInfoResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.PetHandler.upGradeInfoRequest(s2c_petId,cb,option)
	local msg = {}
	msg.s2c_petId = s2c_petId
	Socket.OnRequestStart("area.petHandler.upGradeInfoRequest", option)
	Socket.Request("area.petHandler.upGradeInfoRequest", msg, function(res)
		if(res.s2c_code == 200) then
			Pomelo.PetHandler.lastUpGradeInfoResponse = res
			Socket.OnRequestEnd("area.petHandler.upGradeInfoRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] area.petHandler.upGradeInfoRequest decode error!!"
			end
			Socket.OnRequestEnd("area.petHandler.upGradeInfoRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, upGradeInfoRequestEncoder, upGradeInfoRequestDecoder)
end


local function upGradeLevelRequestEncoder(msg)
	local input = petHandler_pb.UpGradeLevelRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function upGradeLevelRequestDecoder(stream)
	local res = petHandler_pb.UpGradeLevelResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.PetHandler.upGradeLevelRequest(s2c_petId,cb,option)
	local msg = {}
	msg.s2c_petId = s2c_petId
	Socket.OnRequestStart("area.petHandler.upGradeLevelRequest", option)
	Socket.Request("area.petHandler.upGradeLevelRequest", msg, function(res)
		if(res.s2c_code == 200) then
			Pomelo.PetHandler.lastUpGradeLevelResponse = res
			Socket.OnRequestEnd("area.petHandler.upGradeLevelRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] area.petHandler.upGradeLevelRequest decode error!!"
			end
			Socket.OnRequestEnd("area.petHandler.upGradeLevelRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, upGradeLevelRequestEncoder, upGradeLevelRequestDecoder)
end


local function upGradeRandPropertyRequestEncoder(msg)
	local input = petHandler_pb.UpGradeRandPropertyRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function upGradeRandPropertyRequestDecoder(stream)
	local res = petHandler_pb.UpGradeRandPropertyResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.PetHandler.upGradeRandPropertyRequest(s2c_petId,s2c_pos,s2c_materialItems,cb,option)
	local msg = {}
	msg.s2c_petId = s2c_petId
	msg.s2c_pos = s2c_pos
	msg.s2c_materialItems = s2c_materialItems
	Socket.OnRequestStart("area.petHandler.upGradeRandPropertyRequest", option)
	Socket.Request("area.petHandler.upGradeRandPropertyRequest", msg, function(res)
		if(res.s2c_code == 200) then
			Pomelo.PetHandler.lastUpGradeRandPropertyResponse = res
			Socket.OnRequestEnd("area.petHandler.upGradeRandPropertyRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] area.petHandler.upGradeRandPropertyRequest decode error!!"
			end
			Socket.OnRequestEnd("area.petHandler.upGradeRandPropertyRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, upGradeRandPropertyRequestEncoder, upGradeRandPropertyRequestDecoder)
end


local function reSetRandPropertyRequestEncoder(msg)
	local input = petHandler_pb.ReSetRandPropertyRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function reSetRandPropertyRequestDecoder(stream)
	local res = petHandler_pb.ReSetRandPropertyResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.PetHandler.reSetRandPropertyRequest(s2c_petId,s2c_pos,cb,option)
	local msg = {}
	msg.s2c_petId = s2c_petId
	msg.s2c_pos = s2c_pos
	Socket.OnRequestStart("area.petHandler.reSetRandPropertyRequest", option)
	Socket.Request("area.petHandler.reSetRandPropertyRequest", msg, function(res)
		if(res.s2c_code == 200) then
			Pomelo.PetHandler.lastReSetRandPropertyResponse = res
			Socket.OnRequestEnd("area.petHandler.reSetRandPropertyRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] area.petHandler.reSetRandPropertyRequest decode error!!"
			end
			Socket.OnRequestEnd("area.petHandler.reSetRandPropertyRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, reSetRandPropertyRequestEncoder, reSetRandPropertyRequestDecoder)
end


local function randPropertyListRequestEncoder(msg)
	local input = petHandler_pb.RandPropertyListRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function randPropertyListRequestDecoder(stream)
	local res = petHandler_pb.RandPropertyListResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.PetHandler.randPropertyListRequest(s2c_petId,cb,option)
	local msg = {}
	msg.s2c_petId = s2c_petId
	Socket.OnRequestStart("area.petHandler.randPropertyListRequest", option)
	Socket.Request("area.petHandler.randPropertyListRequest", msg, function(res)
		if(res.s2c_code == 200) then
			Pomelo.PetHandler.lastRandPropertyListResponse = res
			Socket.OnRequestEnd("area.petHandler.randPropertyListRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] area.petHandler.randPropertyListRequest decode error!!"
			end
			Socket.OnRequestEnd("area.petHandler.randPropertyListRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, randPropertyListRequestEncoder, randPropertyListRequestDecoder)
end


local function petIllusionRequestEncoder(msg)
	local input = petHandler_pb.PetIllusionRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function petIllusionRequestDecoder(stream)
	local res = petHandler_pb.PetIllusionResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.PetHandler.petIllusionRequest(s2c_petId,cb,option)
	local msg = {}
	msg.s2c_petId = s2c_petId
	Socket.OnRequestStart("area.petHandler.petIllusionRequest", option)
	Socket.Request("area.petHandler.petIllusionRequest", msg, function(res)
		if(res.s2c_code == 200) then
			Pomelo.PetHandler.lastPetIllusionResponse = res
			Socket.OnRequestEnd("area.petHandler.petIllusionRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] area.petHandler.petIllusionRequest decode error!!"
			end
			Socket.OnRequestEnd("area.petHandler.petIllusionRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, petIllusionRequestEncoder, petIllusionRequestDecoder)
end


local function petIllusionInfoRequestEncoder(msg)
	local input = petHandler_pb.PetIllusionInfoRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function petIllusionInfoRequestDecoder(stream)
	local res = petHandler_pb.PetIllusionInfoResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.PetHandler.petIllusionInfoRequest(s2c_petId,cb,option)
	local msg = {}
	msg.s2c_petId = s2c_petId
	Socket.OnRequestStart("area.petHandler.petIllusionInfoRequest", option)
	Socket.Request("area.petHandler.petIllusionInfoRequest", msg, function(res)
		if(res.s2c_code == 200) then
			Pomelo.PetHandler.lastPetIllusionInfoResponse = res
			Socket.OnRequestEnd("area.petHandler.petIllusionInfoRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] area.petHandler.petIllusionInfoRequest decode error!!"
			end
			Socket.OnRequestEnd("area.petHandler.petIllusionInfoRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, petIllusionInfoRequestEncoder, petIllusionInfoRequestDecoder)
end


local function petIllusionReviewRequestEncoder(msg)
	local input = petHandler_pb.PetIllusionReviewRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function petIllusionReviewRequestDecoder(stream)
	local res = petHandler_pb.PetIllusionReviewResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.PetHandler.petIllusionReviewRequest(s2c_petId,cb,option)
	local msg = {}
	msg.s2c_petId = s2c_petId
	Socket.OnRequestStart("area.petHandler.petIllusionReviewRequest", option)
	Socket.Request("area.petHandler.petIllusionReviewRequest", msg, function(res)
		if(res.s2c_code == 200) then
			Pomelo.PetHandler.lastPetIllusionReviewResponse = res
			Socket.OnRequestEnd("area.petHandler.petIllusionReviewRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] area.petHandler.petIllusionReviewRequest decode error!!"
			end
			Socket.OnRequestEnd("area.petHandler.petIllusionReviewRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, petIllusionReviewRequestEncoder, petIllusionReviewRequestDecoder)
end


local function petComprehendSkillRequestEncoder(msg)
	local input = petHandler_pb.PetComprehendSkillRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function petComprehendSkillRequestDecoder(stream)
	local res = petHandler_pb.PetComprehendSkillResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.PetHandler.petComprehendSkillRequest(s2c_petId,s2c_skillBookCode,s2c_lockPos,cb,option)
	local msg = {}
	msg.s2c_petId = s2c_petId
	msg.s2c_skillBookCode = s2c_skillBookCode
	msg.s2c_lockPos = s2c_lockPos
	Socket.OnRequestStart("area.petHandler.petComprehendSkillRequest", option)
	Socket.Request("area.petHandler.petComprehendSkillRequest", msg, function(res)
		if(res.s2c_code == 200) then
			Pomelo.PetHandler.lastPetComprehendSkillResponse = res
			Socket.OnRequestEnd("area.petHandler.petComprehendSkillRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] area.petHandler.petComprehendSkillRequest decode error!!"
			end
			Socket.OnRequestEnd("area.petHandler.petComprehendSkillRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, petComprehendSkillRequestEncoder, petComprehendSkillRequestDecoder)
end


local function petSkillListRequestEncoder(msg)
	local input = petHandler_pb.PetSkillListRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function petSkillListRequestDecoder(stream)
	local res = petHandler_pb.PetSkillListResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.PetHandler.petSkillListRequest(s2c_petId,cb,option)
	local msg = {}
	msg.s2c_petId = s2c_petId
	Socket.OnRequestStart("area.petHandler.petSkillListRequest", option)
	Socket.Request("area.petHandler.petSkillListRequest", msg, function(res)
		if(res.s2c_code == 200) then
			Pomelo.PetHandler.lastPetSkillListResponse = res
			Socket.OnRequestEnd("area.petHandler.petSkillListRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] area.petHandler.petSkillListRequest decode error!!"
			end
			Socket.OnRequestEnd("area.petHandler.petSkillListRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, petSkillListRequestEncoder, petSkillListRequestDecoder)
end


local function petOnHookSetRequestEncoder(msg)
	local input = petHandler_pb.PetOnHookSetRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function petOnHookSetRequestDecoder(stream)
	local res = petHandler_pb.PetOnHookSetResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.PetHandler.petOnHookSetRequest(s2c_petId,s2c_onHookData,cb,option)
	local msg = {}
	msg.s2c_petId = s2c_petId
	msg.s2c_onHookData = s2c_onHookData
	Socket.OnRequestStart("area.petHandler.petOnHookSetRequest", option)
	Socket.Request("area.petHandler.petOnHookSetRequest", msg, function(res)
		if(res.s2c_code == 200) then
			Pomelo.PetHandler.lastPetOnHookSetResponse = res
			Socket.OnRequestEnd("area.petHandler.petOnHookSetRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] area.petHandler.petOnHookSetRequest decode error!!"
			end
			Socket.OnRequestEnd("area.petHandler.petOnHookSetRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, petOnHookSetRequestEncoder, petOnHookSetRequestDecoder)
end


local function petOnHookGetRequestEncoder(msg)
	local input = petHandler_pb.PetOnHookGetRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function petOnHookGetRequestDecoder(stream)
	local res = petHandler_pb.PetOnHookGetResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.PetHandler.petOnHookGetRequest(s2c_petId,cb,option)
	local msg = {}
	msg.s2c_petId = s2c_petId
	Socket.OnRequestStart("area.petHandler.petOnHookGetRequest", option)
	Socket.Request("area.petHandler.petOnHookGetRequest", msg, function(res)
		if(res.s2c_code == 200) then
			Pomelo.PetHandler.lastPetOnHookGetResponse = res
			Socket.OnRequestEnd("area.petHandler.petOnHookGetRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] area.petHandler.petOnHookGetRequest decode error!!"
			end
			Socket.OnRequestEnd("area.petHandler.petOnHookGetRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, petOnHookGetRequestEncoder, petOnHookGetRequestDecoder)
end


local function changePetPkModelRequestEncoder(msg)
	local input = petHandler_pb.ChangePetPkModelRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function changePetPkModelRequestDecoder(stream)
	local res = petHandler_pb.ChangePetPkModelResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.PetHandler.changePetPkModelRequest(c2s_model,cb,option)
	local msg = {}
	msg.c2s_model = c2s_model
	Socket.OnRequestStart("area.petHandler.changePetPkModelRequest", option)
	Socket.Request("area.petHandler.changePetPkModelRequest", msg, function(res)
		if(res.s2c_code == 200) then
			Pomelo.PetHandler.lastChangePetPkModelResponse = res
			Socket.OnRequestEnd("area.petHandler.changePetPkModelRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] area.petHandler.changePetPkModelRequest decode error!!"
			end
			Socket.OnRequestEnd("area.petHandler.changePetPkModelRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, changePetPkModelRequestEncoder, changePetPkModelRequestDecoder)
end


local function onPetDetailPushDecoder(stream)
	local res = petHandler_pb.OnPetDetailPush()
	res:ParseFromString(stream)
	return res
end

function Pomelo.PetHandler.onPetDetailPush(cb)
	Socket.On("area.petPush.onPetDetailPush", function(res) 
		Pomelo.PetHandler.lastOnPetDetailPush = res
		cb(nil,res) 
	end, onPetDetailPushDecoder) 
end


local function onPetExpPushDecoder(stream)
	local res = petHandler_pb.OnPetExpPush()
	res:ParseFromString(stream)
	return res
end

function Pomelo.PetHandler.onPetExpPush(cb)
	Socket.On("area.petPush.onPetExpPush", function(res) 
		Pomelo.PetHandler.lastOnPetExpPush = res
		cb(nil,res) 
	end, onPetExpPushDecoder) 
end





return Pomelo
