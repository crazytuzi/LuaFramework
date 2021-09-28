





local Socket = require "Xmds.Pomelo.LuaGameSocket"
require "base64"
require "goddessHandler_pb"


Pomelo = Pomelo or {}


Pomelo.GoddessHandler = {}

local function enterGoddessSceneRequestEncoder(msg)
	local input = goddessHandler_pb.EnterGoddessSceneRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function enterGoddessSceneRequestDecoder(stream)
	local res = goddessHandler_pb.EnterGoddessSceneResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.GoddessHandler.enterGoddessSceneRequest(cb,option)
	local input = nil
	Socket.OnRequestStart("area.goddessHandler.enterGoddessSceneRequest", option)
	Socket.Request("area.goddessHandler.enterGoddessSceneRequest", input, function(res)
		if(res.s2c_code == 200) then
			Pomelo.GoddessHandler.lastEnterGoddessSceneResponse = res
			Socket.OnRequestEnd("area.goddessHandler.enterGoddessSceneRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] area.goddessHandler.enterGoddessSceneRequest decode error!!"
			end
			Socket.OnRequestEnd("area.goddessHandler.enterGoddessSceneRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, enterGoddessSceneRequestEncoder, enterGoddessSceneRequestDecoder)
end


local function outGoddessSceneRequestEncoder(msg)
	local input = goddessHandler_pb.OutGoddessSceneRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function outGoddessSceneRequestDecoder(stream)
	local res = goddessHandler_pb.OutGoddessSceneResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.GoddessHandler.outGoddessSceneRequest(cb,option)
	local input = nil
	Socket.OnRequestStart("area.goddessHandler.outGoddessSceneRequest", option)
	Socket.Request("area.goddessHandler.outGoddessSceneRequest", input, function(res)
		if(res.s2c_code == 200) then
			Pomelo.GoddessHandler.lastOutGoddessSceneResponse = res
			Socket.OnRequestEnd("area.goddessHandler.outGoddessSceneRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] area.goddessHandler.outGoddessSceneRequest decode error!!"
			end
			Socket.OnRequestEnd("area.goddessHandler.outGoddessSceneRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, outGoddessSceneRequestEncoder, outGoddessSceneRequestDecoder)
end


local function activeGoddessRequestEncoder(msg)
	local input = goddessHandler_pb.ActiveGoddessRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function activeGoddessRequestDecoder(stream)
	local res = goddessHandler_pb.ActiveGoddessResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.GoddessHandler.activeGoddessRequest(c2s_goddessTemplateId,cb,option)
	local msg = {}
	msg.c2s_goddessTemplateId = c2s_goddessTemplateId
	Socket.OnRequestStart("area.goddessHandler.activeGoddessRequest", option)
	Socket.Request("area.goddessHandler.activeGoddessRequest", msg, function(res)
		if(res.s2c_code == 200) then
			Pomelo.GoddessHandler.lastActiveGoddessResponse = res
			Socket.OnRequestEnd("area.goddessHandler.activeGoddessRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] area.goddessHandler.activeGoddessRequest decode error!!"
			end
			Socket.OnRequestEnd("area.goddessHandler.activeGoddessRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, activeGoddessRequestEncoder, activeGoddessRequestDecoder)
end


local function onBattleGoddessRequestEncoder(msg)
	local input = goddessHandler_pb.OnBattleGoddessRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function onBattleGoddessRequestDecoder(stream)
	local res = goddessHandler_pb.OnBattleGoddessResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.GoddessHandler.onBattleGoddessRequest(c2s_goddessId,cb,option)
	local msg = {}
	msg.c2s_goddessId = c2s_goddessId
	Socket.OnRequestStart("area.goddessHandler.onBattleGoddessRequest", option)
	Socket.Request("area.goddessHandler.onBattleGoddessRequest", msg, function(res)
		if(res.s2c_code == 200) then
			Pomelo.GoddessHandler.lastOnBattleGoddessResponse = res
			Socket.OnRequestEnd("area.goddessHandler.onBattleGoddessRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] area.goddessHandler.onBattleGoddessRequest decode error!!"
			end
			Socket.OnRequestEnd("area.goddessHandler.onBattleGoddessRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, onBattleGoddessRequestEncoder, onBattleGoddessRequestDecoder)
end


local function offBattleGoddessRequestEncoder(msg)
	local input = goddessHandler_pb.OffBattleGoddessRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function offBattleGoddessRequestDecoder(stream)
	local res = goddessHandler_pb.OffBattleGoddessResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.GoddessHandler.offBattleGoddessRequest(c2s_goddessId,cb,option)
	local msg = {}
	msg.c2s_goddessId = c2s_goddessId
	Socket.OnRequestStart("area.goddessHandler.offBattleGoddessRequest", option)
	Socket.Request("area.goddessHandler.offBattleGoddessRequest", msg, function(res)
		if(res.s2c_code == 200) then
			Pomelo.GoddessHandler.lastOffBattleGoddessResponse = res
			Socket.OnRequestEnd("area.goddessHandler.offBattleGoddessRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] area.goddessHandler.offBattleGoddessRequest decode error!!"
			end
			Socket.OnRequestEnd("area.goddessHandler.offBattleGoddessRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, offBattleGoddessRequestEncoder, offBattleGoddessRequestDecoder)
end


local function getGiftsRequestEncoder(msg)
	local input = goddessHandler_pb.GetGiftsRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function getGiftsRequestDecoder(stream)
	local res = goddessHandler_pb.GetGiftsResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.GoddessHandler.getGiftsRequest(c2s_goddessId,cb,option)
	local msg = {}
	msg.c2s_goddessId = c2s_goddessId
	Socket.OnRequestStart("area.goddessHandler.getGiftsRequest", option)
	Socket.Request("area.goddessHandler.getGiftsRequest", msg, function(res)
		if(res.s2c_code == 200) then
			Pomelo.GoddessHandler.lastGetGiftsResponse = res
			Socket.OnRequestEnd("area.goddessHandler.getGiftsRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] area.goddessHandler.getGiftsRequest decode error!!"
			end
			Socket.OnRequestEnd("area.goddessHandler.getGiftsRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, getGiftsRequestEncoder, getGiftsRequestDecoder)
end


local function buyGiftRequestEncoder(msg)
	local input = goddessHandler_pb.BuyGiftRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function buyGiftRequestDecoder(stream)
	local res = goddessHandler_pb.BuyGiftResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.GoddessHandler.buyGiftRequest(c2s_goddessId,c2s_giftId,cb,option)
	local msg = {}
	msg.c2s_goddessId = c2s_goddessId
	msg.c2s_giftId = c2s_giftId
	Socket.OnRequestStart("area.goddessHandler.buyGiftRequest", option)
	Socket.Request("area.goddessHandler.buyGiftRequest", msg, function(res)
		if(res.s2c_code == 200) then
			Pomelo.GoddessHandler.lastBuyGiftResponse = res
			Socket.OnRequestEnd("area.goddessHandler.buyGiftRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] area.goddessHandler.buyGiftRequest decode error!!"
			end
			Socket.OnRequestEnd("area.goddessHandler.buyGiftRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, buyGiftRequestEncoder, buyGiftRequestDecoder)
end


local function unEquipGiftRequestEncoder(msg)
	local input = goddessHandler_pb.UnEquipGiftRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function unEquipGiftRequestDecoder(stream)
	local res = goddessHandler_pb.UnEquipGiftResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.GoddessHandler.unEquipGiftRequest(c2s_goddessId,c2s_giftId,cb,option)
	local msg = {}
	msg.c2s_goddessId = c2s_goddessId
	msg.c2s_giftId = c2s_giftId
	Socket.OnRequestStart("area.goddessHandler.unEquipGiftRequest", option)
	Socket.Request("area.goddessHandler.unEquipGiftRequest", msg, function(res)
		if(res.s2c_code == 200) then
			Pomelo.GoddessHandler.lastUnEquipGiftResponse = res
			Socket.OnRequestEnd("area.goddessHandler.unEquipGiftRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] area.goddessHandler.unEquipGiftRequest decode error!!"
			end
			Socket.OnRequestEnd("area.goddessHandler.unEquipGiftRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, unEquipGiftRequestEncoder, unEquipGiftRequestDecoder)
end


local function equipGiftRequestEncoder(msg)
	local input = goddessHandler_pb.EquipGiftRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function equipGiftRequestDecoder(stream)
	local res = goddessHandler_pb.EquipGiftResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.GoddessHandler.equipGiftRequest(c2s_goddessId,c2s_giftId,cb,option)
	local msg = {}
	msg.c2s_goddessId = c2s_goddessId
	msg.c2s_giftId = c2s_giftId
	Socket.OnRequestStart("area.goddessHandler.equipGiftRequest", option)
	Socket.Request("area.goddessHandler.equipGiftRequest", msg, function(res)
		if(res.s2c_code == 200) then
			Pomelo.GoddessHandler.lastEquipGiftResponse = res
			Socket.OnRequestEnd("area.goddessHandler.equipGiftRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] area.goddessHandler.equipGiftRequest decode error!!"
			end
			Socket.OnRequestEnd("area.goddessHandler.equipGiftRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, equipGiftRequestEncoder, equipGiftRequestDecoder)
end


local function upIntimacyRequestEncoder(msg)
	local input = goddessHandler_pb.UpIntimacyRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function upIntimacyRequestDecoder(stream)
	local res = goddessHandler_pb.UpIntimacyResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.GoddessHandler.upIntimacyRequest(c2s_goddessId,c2s_type,cb,option)
	local msg = {}
	msg.c2s_goddessId = c2s_goddessId
	msg.c2s_type = c2s_type
	Socket.OnRequestStart("area.goddessHandler.upIntimacyRequest", option)
	Socket.Request("area.goddessHandler.upIntimacyRequest", msg, function(res)
		if(res.s2c_code == 200) then
			Pomelo.GoddessHandler.lastUpIntimacyResponse = res
			Socket.OnRequestEnd("area.goddessHandler.upIntimacyRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] area.goddessHandler.upIntimacyRequest decode error!!"
			end
			Socket.OnRequestEnd("area.goddessHandler.upIntimacyRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, upIntimacyRequestEncoder, upIntimacyRequestDecoder)
end


local function upStarRequestEncoder(msg)
	local input = goddessHandler_pb.UpStarRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function upStarRequestDecoder(stream)
	local res = goddessHandler_pb.UpStarResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.GoddessHandler.upStarRequest(c2s_goddessId,cb,option)
	local msg = {}
	msg.c2s_goddessId = c2s_goddessId
	Socket.OnRequestStart("area.goddessHandler.upStarRequest", option)
	Socket.Request("area.goddessHandler.upStarRequest", msg, function(res)
		if(res.s2c_code == 200) then
			Pomelo.GoddessHandler.lastUpStarResponse = res
			Socket.OnRequestEnd("area.goddessHandler.upStarRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] area.goddessHandler.upStarRequest decode error!!"
			end
			Socket.OnRequestEnd("area.goddessHandler.upStarRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, upStarRequestEncoder, upStarRequestDecoder)
end


local function getCommInfoRequestEncoder(msg)
	local input = goddessHandler_pb.GetCommInfoRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function getCommInfoRequestDecoder(stream)
	local res = goddessHandler_pb.GetCommInfoResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.GoddessHandler.getCommInfoRequest(c2s_goddessId,cb,option)
	local msg = {}
	msg.c2s_goddessId = c2s_goddessId
	Socket.OnRequestStart("area.goddessHandler.getCommInfoRequest", option)
	Socket.Request("area.goddessHandler.getCommInfoRequest", msg, function(res)
		if(res.s2c_code == 200) then
			Pomelo.GoddessHandler.lastGetCommInfoResponse = res
			Socket.OnRequestEnd("area.goddessHandler.getCommInfoRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] area.goddessHandler.getCommInfoRequest decode error!!"
			end
			Socket.OnRequestEnd("area.goddessHandler.getCommInfoRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, getCommInfoRequestEncoder, getCommInfoRequestDecoder)
end


local function getGoddessDetailRequestEncoder(msg)
	local input = goddessHandler_pb.GetGoddessDetailRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function getGoddessDetailRequestDecoder(stream)
	local res = goddessHandler_pb.GetGoddessDetailResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.GoddessHandler.getGoddessDetailRequest(c2s_goddessId,cb,option)
	local msg = {}
	msg.c2s_goddessId = c2s_goddessId
	Socket.OnRequestStart("area.goddessHandler.getGoddessDetailRequest", option)
	Socket.Request("area.goddessHandler.getGoddessDetailRequest", msg, function(res)
		if(res.s2c_code == 200) then
			Pomelo.GoddessHandler.lastGetGoddessDetailResponse = res
			Socket.OnRequestEnd("area.goddessHandler.getGoddessDetailRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] area.goddessHandler.getGoddessDetailRequest decode error!!"
			end
			Socket.OnRequestEnd("area.goddessHandler.getGoddessDetailRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, getGoddessDetailRequestEncoder, getGoddessDetailRequestDecoder)
end


local function getAllGoddessRequestEncoder(msg)
	local input = goddessHandler_pb.GetAllGoddessRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function getAllGoddessRequestDecoder(stream)
	local res = goddessHandler_pb.GetAllGoddessResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.GoddessHandler.getAllGoddessRequest(cb,option)
	local input = nil
	Socket.OnRequestStart("area.goddessHandler.getAllGoddessRequest", option)
	Socket.Request("area.goddessHandler.getAllGoddessRequest", input, function(res)
		if(res.s2c_code == 200) then
			Pomelo.GoddessHandler.lastGetAllGoddessResponse = res
			Socket.OnRequestEnd("area.goddessHandler.getAllGoddessRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] area.goddessHandler.getAllGoddessRequest decode error!!"
			end
			Socket.OnRequestEnd("area.goddessHandler.getAllGoddessRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, getAllGoddessRequestEncoder, getAllGoddessRequestDecoder)
end


local function goddessEquipDynamicPushDecoder(stream)
	local res = goddessHandler_pb.GoddessEquipDynamicPush()
	res:ParseFromString(stream)
	return res
end

function Pomelo.GoddessHandler.goddessEquipDynamicPush(cb)
	Socket.On("area.goddessPush.goddessEquipDynamicPush", function(res) 
		Pomelo.GoddessHandler.lastGoddessEquipDynamicPush = res
		cb(nil,res) 
	end, goddessEquipDynamicPushDecoder) 
end


local function goddessGiftDynamicPushDecoder(stream)
	local res = goddessHandler_pb.GoddessGiftDynamicPush()
	res:ParseFromString(stream)
	return res
end

function Pomelo.GoddessHandler.goddessGiftDynamicPush(cb)
	Socket.On("area.goddessPush.goddessGiftDynamicPush", function(res) 
		Pomelo.GoddessHandler.lastGoddessGiftDynamicPush = res
		cb(nil,res) 
	end, goddessGiftDynamicPushDecoder) 
end





return Pomelo
