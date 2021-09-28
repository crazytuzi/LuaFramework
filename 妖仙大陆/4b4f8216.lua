





local Socket = require "Xmds.Pomelo.LuaGameSocket"
require "base64"
require "equipHandler_pb"


Pomelo = Pomelo or {}


Pomelo.EquipHandler = {}

local function unEquipRequestEncoder(msg)
	local input = equipHandler_pb.UnEquipRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function unEquipRequestDecoder(stream)
	local res = equipHandler_pb.UnEquipResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.EquipHandler.unEquipRequest(c2s_gridIndex,cb,option)
	local msg = {}
	msg.c2s_gridIndex = c2s_gridIndex
	Socket.OnRequestStart("area.equipHandler.unEquipRequest", option)
	Socket.Request("area.equipHandler.unEquipRequest", msg, function(res)
		if(res.s2c_code == 200) then
			Pomelo.EquipHandler.lastUnEquipResponse = res
			Socket.OnRequestEnd("area.equipHandler.unEquipRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] area.equipHandler.unEquipRequest decode error!!"
			end
			Socket.OnRequestEnd("area.equipHandler.unEquipRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, unEquipRequestEncoder, unEquipRequestDecoder)
end


local function equipRequestEncoder(msg)
	local input = equipHandler_pb.EquipRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function equipRequestDecoder(stream)
	local res = equipHandler_pb.EquipResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.EquipHandler.equipRequest(c2s_gridIndex,cb,option)
	local msg = {}
	msg.c2s_gridIndex = c2s_gridIndex
	Socket.OnRequestStart("area.equipHandler.equipRequest", option)
	Socket.Request("area.equipHandler.equipRequest", msg, function(res)
		if(res.s2c_code == 200) then
			Pomelo.EquipHandler.lastEquipResponse = res
			Socket.OnRequestEnd("area.equipHandler.equipRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] area.equipHandler.equipRequest decode error!!"
			end
			Socket.OnRequestEnd("area.equipHandler.equipRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, equipRequestEncoder, equipRequestDecoder)
end


local function equipPreStrengthenRequestEncoder(msg)
	local input = equipHandler_pb.EquipPreStrengthenRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function equipPreStrengthenRequestDecoder(stream)
	local res = equipHandler_pb.EquipPreStrengthenResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.EquipHandler.equipPreStrengthenRequest(c2s_pos,cb,option)
	local msg = {}
	msg.c2s_pos = c2s_pos
	Socket.OnRequestStart("area.equipHandler.equipPreStrengthenRequest", option)
	Socket.Request("area.equipHandler.equipPreStrengthenRequest", msg, function(res)
		if(res.s2c_code == 200) then
			Pomelo.EquipHandler.lastEquipPreStrengthenResponse = res
			Socket.OnRequestEnd("area.equipHandler.equipPreStrengthenRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] area.equipHandler.equipPreStrengthenRequest decode error!!"
			end
			Socket.OnRequestEnd("area.equipHandler.equipPreStrengthenRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, equipPreStrengthenRequestEncoder, equipPreStrengthenRequestDecoder)
end


local function openEquipHandlerRequestEncoder(msg)
	local input = equipHandler_pb.OpenEquipHandlerRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function openEquipHandlerRequestDecoder(stream)
	local res = equipHandler_pb.OpenEquipHandlerResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.EquipHandler.openEquipHandlerRequest(code,cb,option)
	local msg = {}
	msg.code = code
	Socket.OnRequestStart("area.equipHandler.openEquipHandlerRequest", option)
	Socket.Request("area.equipHandler.openEquipHandlerRequest", msg, function(res)
		if(res.s2c_code == 200) then
			Pomelo.EquipHandler.lastOpenEquipHandlerResponse = res
			Socket.OnRequestEnd("area.equipHandler.openEquipHandlerRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] area.equipHandler.openEquipHandlerRequest decode error!!"
			end
			Socket.OnRequestEnd("area.equipHandler.openEquipHandlerRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, openEquipHandlerRequestEncoder, openEquipHandlerRequestDecoder)
end


local function equipStrengthenRequestEncoder(msg)
	local input = equipHandler_pb.EquipStrengthenRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function equipStrengthenRequestDecoder(stream)
	local res = equipHandler_pb.EquipStrengthenResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.EquipHandler.equipStrengthenRequest(c2s_pos,c2s_useZuan,cb,option)
	local msg = {}
	msg.c2s_pos = c2s_pos
	msg.c2s_useZuan = c2s_useZuan
	Socket.OnRequestStart("area.equipHandler.equipStrengthenRequest", option)
	Socket.Request("area.equipHandler.equipStrengthenRequest", msg, function(res)
		if(res.s2c_code == 200) then
			Pomelo.EquipHandler.lastEquipStrengthenResponse = res
			Socket.OnRequestEnd("area.equipHandler.equipStrengthenRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] area.equipHandler.equipStrengthenRequest decode error!!"
			end
			Socket.OnRequestEnd("area.equipHandler.equipStrengthenRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, equipStrengthenRequestEncoder, equipStrengthenRequestDecoder)
end


local function enchantEquipRequestEncoder(msg)
	local input = equipHandler_pb.EnchantEquipRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function enchantEquipRequestDecoder(stream)
	local res = equipHandler_pb.EnchantEquipResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.EquipHandler.enchantEquipRequest(c2s_pos,c2s_gridIndex,c2s_diamond,cb,option)
	local msg = {}
	msg.c2s_pos = c2s_pos
	msg.c2s_gridIndex = c2s_gridIndex
	msg.c2s_diamond = c2s_diamond
	Socket.OnRequestStart("area.equipHandler.enchantEquipRequest", option)
	Socket.Request("area.equipHandler.enchantEquipRequest", msg, function(res)
		if(res.s2c_code == 200) then
			Pomelo.EquipHandler.lastEnchantEquipResponse = res
			Socket.OnRequestEnd("area.equipHandler.enchantEquipRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] area.equipHandler.enchantEquipRequest decode error!!"
			end
			Socket.OnRequestEnd("area.equipHandler.enchantEquipRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, enchantEquipRequestEncoder, enchantEquipRequestDecoder)
end


local function confirmEnchantEquipRequestEncoder(msg)
	local input = equipHandler_pb.ConfirmEnchantEquipRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function confirmEnchantEquipRequestDecoder(stream)
	local res = equipHandler_pb.ConfirmEnchantEquipResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.EquipHandler.confirmEnchantEquipRequest(c2s_pos,cb,option)
	local msg = {}
	msg.c2s_pos = c2s_pos
	Socket.OnRequestStart("area.equipHandler.confirmEnchantEquipRequest", option)
	Socket.Request("area.equipHandler.confirmEnchantEquipRequest", msg, function(res)
		if(res.s2c_code == 200) then
			Pomelo.EquipHandler.lastConfirmEnchantEquipResponse = res
			Socket.OnRequestEnd("area.equipHandler.confirmEnchantEquipRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] area.equipHandler.confirmEnchantEquipRequest decode error!!"
			end
			Socket.OnRequestEnd("area.equipHandler.confirmEnchantEquipRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, confirmEnchantEquipRequestEncoder, confirmEnchantEquipRequestDecoder)
end


local function identifyEquipRequestEncoder(msg)
	local input = equipHandler_pb.IdentifyEquipRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function identifyEquipRequestDecoder(stream)
	local res = equipHandler_pb.IdentifyEquipResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.EquipHandler.identifyEquipRequest(c2s_gridIndex,cb,option)
	local msg = {}
	msg.c2s_gridIndex = c2s_gridIndex
	Socket.OnRequestStart("area.equipHandler.identifyEquipRequest", option)
	Socket.Request("area.equipHandler.identifyEquipRequest", msg, function(res)
		if(res.s2c_code == 200) then
			Pomelo.EquipHandler.lastIdentifyEquipResponse = res
			Socket.OnRequestEnd("area.equipHandler.identifyEquipRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] area.equipHandler.identifyEquipRequest decode error!!"
			end
			Socket.OnRequestEnd("area.equipHandler.identifyEquipRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, identifyEquipRequestEncoder, identifyEquipRequestDecoder)
end


local function refineEquipRequestEncoder(msg)
	local input = equipHandler_pb.RefineEquipRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function refineEquipRequestDecoder(stream)
	local res = equipHandler_pb.RefineEquipResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.EquipHandler.refineEquipRequest(c2s_pos,c2s_itemCode,cb,option)
	local msg = {}
	msg.c2s_pos = c2s_pos
	msg.c2s_itemCode = c2s_itemCode
	Socket.OnRequestStart("area.equipHandler.refineEquipRequest", option)
	Socket.Request("area.equipHandler.refineEquipRequest", msg, function(res)
		if(res.s2c_code == 200) then
			Pomelo.EquipHandler.lastRefineEquipResponse = res
			Socket.OnRequestEnd("area.equipHandler.refineEquipRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] area.equipHandler.refineEquipRequest decode error!!"
			end
			Socket.OnRequestEnd("area.equipHandler.refineEquipRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, refineEquipRequestEncoder, refineEquipRequestDecoder)
end


local function refineOneKeyRequestEncoder(msg)
	local input = equipHandler_pb.RefineOneKeyRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function refineOneKeyRequestDecoder(stream)
	local res = equipHandler_pb.RefineOneKeyResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.EquipHandler.refineOneKeyRequest(c2s_pos,c2s_itemCode,cb,option)
	local msg = {}
	msg.c2s_pos = c2s_pos
	msg.c2s_itemCode = c2s_itemCode
	Socket.OnRequestStart("area.equipHandler.refineOneKeyRequest", option)
	Socket.Request("area.equipHandler.refineOneKeyRequest", msg, function(res)
		if(res.s2c_code == 200) then
			Pomelo.EquipHandler.lastRefineOneKeyResponse = res
			Socket.OnRequestEnd("area.equipHandler.refineOneKeyRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] area.equipHandler.refineOneKeyRequest decode error!!"
			end
			Socket.OnRequestEnd("area.equipHandler.refineOneKeyRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, refineOneKeyRequestEncoder, refineOneKeyRequestDecoder)
end


local function refineResetRequestEncoder(msg)
	local input = equipHandler_pb.RefineResetRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function refineResetRequestDecoder(stream)
	local res = equipHandler_pb.RefineResetResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.EquipHandler.refineResetRequest(c2s_pos,c2s_propIndex,cb,option)
	local msg = {}
	msg.c2s_pos = c2s_pos
	msg.c2s_propIndex = c2s_propIndex
	Socket.OnRequestStart("area.equipHandler.refineResetRequest", option)
	Socket.Request("area.equipHandler.refineResetRequest", msg, function(res)
		if(res.s2c_code == 200) then
			Pomelo.EquipHandler.lastRefineResetResponse = res
			Socket.OnRequestEnd("area.equipHandler.refineResetRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] area.equipHandler.refineResetRequest decode error!!"
			end
			Socket.OnRequestEnd("area.equipHandler.refineResetRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, refineResetRequestEncoder, refineResetRequestDecoder)
end


local function equipMakeRequestEncoder(msg)
	local input = equipHandler_pb.EquipMakeRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function equipMakeRequestDecoder(stream)
	local res = equipHandler_pb.EquipMakeResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.EquipHandler.equipMakeRequest(c2s_targetCode,cb,option)
	local msg = {}
	msg.c2s_targetCode = c2s_targetCode
	Socket.OnRequestStart("area.equipHandler.equipMakeRequest", option)
	Socket.Request("area.equipHandler.equipMakeRequest", msg, function(res)
		if(res.s2c_code == 200) then
			Pomelo.EquipHandler.lastEquipMakeResponse = res
			Socket.OnRequestEnd("area.equipHandler.equipMakeRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] area.equipHandler.equipMakeRequest decode error!!"
			end
			Socket.OnRequestEnd("area.equipHandler.equipMakeRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, equipMakeRequestEncoder, equipMakeRequestDecoder)
end


local function equipLevelUpRequestEncoder(msg)
	local input = equipHandler_pb.EquipLevelUpRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function equipLevelUpRequestDecoder(stream)
	local res = equipHandler_pb.EquipLevelUpResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.EquipHandler.equipLevelUpRequest(c2s_equipPos,c2s_mateType,cb,option)
	local msg = {}
	msg.c2s_equipPos = c2s_equipPos
	msg.c2s_mateType = c2s_mateType
	Socket.OnRequestStart("area.equipHandler.equipLevelUpRequest", option)
	Socket.Request("area.equipHandler.equipLevelUpRequest", msg, function(res)
		if(res.s2c_code == 200) then
			Pomelo.EquipHandler.lastEquipLevelUpResponse = res
			Socket.OnRequestEnd("area.equipHandler.equipLevelUpRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] area.equipHandler.equipLevelUpRequest decode error!!"
			end
			Socket.OnRequestEnd("area.equipHandler.equipLevelUpRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, equipLevelUpRequestEncoder, equipLevelUpRequestDecoder)
end


local function equipColorUpRequestEncoder(msg)
	local input = equipHandler_pb.EquipColorUpRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function equipColorUpRequestDecoder(stream)
	local res = equipHandler_pb.EquipColorUpResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.EquipHandler.equipColorUpRequest(c2s_equipPos,cb,option)
	local msg = {}
	msg.c2s_equipPos = c2s_equipPos
	Socket.OnRequestStart("area.equipHandler.equipColorUpRequest", option)
	Socket.Request("area.equipHandler.equipColorUpRequest", msg, function(res)
		if(res.s2c_code == 200) then
			Pomelo.EquipHandler.lastEquipColorUpResponse = res
			Socket.OnRequestEnd("area.equipHandler.equipColorUpRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] area.equipHandler.equipColorUpRequest decode error!!"
			end
			Socket.OnRequestEnd("area.equipHandler.equipColorUpRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, equipColorUpRequestEncoder, equipColorUpRequestDecoder)
end


local function fillGemRequestEncoder(msg)
	local input = equipHandler_pb.FillGemRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function fillGemRequestDecoder(stream)
	local res = equipHandler_pb.FillGemResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.EquipHandler.fillGemRequest(c2s_pos,c2s_index,c2s_gridIndex,cb,option)
	local msg = {}
	msg.c2s_pos = c2s_pos
	msg.c2s_index = c2s_index
	msg.c2s_gridIndex = c2s_gridIndex
	Socket.OnRequestStart("area.equipHandler.fillGemRequest", option)
	Socket.Request("area.equipHandler.fillGemRequest", msg, function(res)
		if(res.s2c_code == 200) then
			Pomelo.EquipHandler.lastFillGemResponse = res
			Socket.OnRequestEnd("area.equipHandler.fillGemRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] area.equipHandler.fillGemRequest decode error!!"
			end
			Socket.OnRequestEnd("area.equipHandler.fillGemRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, fillGemRequestEncoder, fillGemRequestDecoder)
end


local function fillAllGemRequestEncoder(msg)
	local input = equipHandler_pb.FillAllGemRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function fillAllGemRequestDecoder(stream)
	local res = equipHandler_pb.FillAllGemResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.EquipHandler.fillAllGemRequest(c2s_pos,cb,option)
	local msg = {}
	msg.c2s_pos = c2s_pos
	Socket.OnRequestStart("area.equipHandler.fillAllGemRequest", option)
	Socket.Request("area.equipHandler.fillAllGemRequest", msg, function(res)
		if(res.s2c_code == 200) then
			Pomelo.EquipHandler.lastFillAllGemResponse = res
			Socket.OnRequestEnd("area.equipHandler.fillAllGemRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] area.equipHandler.fillAllGemRequest decode error!!"
			end
			Socket.OnRequestEnd("area.equipHandler.fillAllGemRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, fillAllGemRequestEncoder, fillAllGemRequestDecoder)
end


local function unFillGemRequestEncoder(msg)
	local input = equipHandler_pb.UnFillGemRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function unFillGemRequestDecoder(stream)
	local res = equipHandler_pb.UnFillGemResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.EquipHandler.unFillGemRequest(c2s_pos,c2s_index,cb,option)
	local msg = {}
	msg.c2s_pos = c2s_pos
	msg.c2s_index = c2s_index
	Socket.OnRequestStart("area.equipHandler.unFillGemRequest", option)
	Socket.Request("area.equipHandler.unFillGemRequest", msg, function(res)
		if(res.s2c_code == 200) then
			Pomelo.EquipHandler.lastUnFillGemResponse = res
			Socket.OnRequestEnd("area.equipHandler.unFillGemRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] area.equipHandler.unFillGemRequest decode error!!"
			end
			Socket.OnRequestEnd("area.equipHandler.unFillGemRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, unFillGemRequestEncoder, unFillGemRequestDecoder)
end


local function unFillAllGemRequestEncoder(msg)
	local input = equipHandler_pb.UnFillAllGemRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function unFillAllGemRequestDecoder(stream)
	local res = equipHandler_pb.UnFillAllGemResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.EquipHandler.unFillAllGemRequest(c2s_pos,cb,option)
	local msg = {}
	msg.c2s_pos = c2s_pos
	Socket.OnRequestStart("area.equipHandler.unFillAllGemRequest", option)
	Socket.Request("area.equipHandler.unFillAllGemRequest", msg, function(res)
		if(res.s2c_code == 200) then
			Pomelo.EquipHandler.lastUnFillAllGemResponse = res
			Socket.OnRequestEnd("area.equipHandler.unFillAllGemRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] area.equipHandler.unFillAllGemRequest decode error!!"
			end
			Socket.OnRequestEnd("area.equipHandler.unFillAllGemRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, unFillAllGemRequestEncoder, unFillAllGemRequestDecoder)
end


local function getSuitAttrRequestEncoder(msg)
	local input = equipHandler_pb.GetSuitAttrRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function getSuitAttrRequestDecoder(stream)
	local res = equipHandler_pb.GetSuitAttrResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.EquipHandler.getSuitAttrRequest(cb,option)
	local input = nil
	Socket.OnRequestStart("area.equipHandler.getSuitAttrRequest", option)
	Socket.Request("area.equipHandler.getSuitAttrRequest", input, function(res)
		if(res.s2c_code == 200) then
			Pomelo.EquipHandler.lastGetSuitAttrResponse = res
			Socket.OnRequestEnd("area.equipHandler.getSuitAttrRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] area.equipHandler.getSuitAttrRequest decode error!!"
			end
			Socket.OnRequestEnd("area.equipHandler.getSuitAttrRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, getSuitAttrRequestEncoder, getSuitAttrRequestDecoder)
end


local function getSuitDetailRequestEncoder(msg)
	local input = equipHandler_pb.GetSuitDetailRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function getSuitDetailRequestDecoder(stream)
	local res = equipHandler_pb.GetSuitDetailResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.EquipHandler.getSuitDetailRequest(c2s_suitType,cb,option)
	local msg = {}
	msg.c2s_suitType = c2s_suitType
	Socket.OnRequestStart("area.equipHandler.getSuitDetailRequest", option)
	Socket.Request("area.equipHandler.getSuitDetailRequest", msg, function(res)
		if(res.s2c_code == 200) then
			Pomelo.EquipHandler.lastGetSuitDetailResponse = res
			Socket.OnRequestEnd("area.equipHandler.getSuitDetailRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] area.equipHandler.getSuitDetailRequest decode error!!"
			end
			Socket.OnRequestEnd("area.equipHandler.getSuitDetailRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, getSuitDetailRequestEncoder, getSuitDetailRequestDecoder)
end


local function getInheritInfoRequestEncoder(msg)
	local input = equipHandler_pb.GetInheritInfoRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function getInheritInfoRequestDecoder(stream)
	local res = equipHandler_pb.GetInheritInfoResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.EquipHandler.getInheritInfoRequest(c2s_inheritEquip,c2s_beiInheritEquip,cb,option)
	local msg = {}
	msg.c2s_inheritEquip = c2s_inheritEquip
	msg.c2s_beiInheritEquip = c2s_beiInheritEquip
	Socket.OnRequestStart("area.equipHandler.getInheritInfoRequest", option)
	Socket.Request("area.equipHandler.getInheritInfoRequest", msg, function(res)
		if(res.s2c_code == 200) then
			Pomelo.EquipHandler.lastGetInheritInfoResponse = res
			Socket.OnRequestEnd("area.equipHandler.getInheritInfoRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] area.equipHandler.getInheritInfoRequest decode error!!"
			end
			Socket.OnRequestEnd("area.equipHandler.getInheritInfoRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, getInheritInfoRequestEncoder, getInheritInfoRequestDecoder)
end


local function equipInheritRequestEncoder(msg)
	local input = equipHandler_pb.EquipInheritRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function equipInheritRequestDecoder(stream)
	local res = equipHandler_pb.EquipInheritResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.EquipHandler.equipInheritRequest(c2s_inheritEquip,c2s_beiInheritEquip,c2s_magical,c2s_jewel,c2s_refine,c2s_isAuto,cb,option)
	local msg = {}
	msg.c2s_inheritEquip = c2s_inheritEquip
	msg.c2s_beiInheritEquip = c2s_beiInheritEquip
	msg.c2s_magical = c2s_magical
	msg.c2s_jewel = c2s_jewel
	msg.c2s_refine = c2s_refine
	msg.c2s_isAuto = c2s_isAuto
	Socket.OnRequestStart("area.equipHandler.equipInheritRequest", option)
	Socket.Request("area.equipHandler.equipInheritRequest", msg, function(res)
		if(res.s2c_code == 200) then
			Pomelo.EquipHandler.lastEquipInheritResponse = res
			Socket.OnRequestEnd("area.equipHandler.equipInheritRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] area.equipHandler.equipInheritRequest decode error!!"
			end
			Socket.OnRequestEnd("area.equipHandler.equipInheritRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, equipInheritRequestEncoder, equipInheritRequestDecoder)
end


local function equipMeltRequestEncoder(msg)
	local input = equipHandler_pb.EquipMeltRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function equipMeltRequestDecoder(stream)
	local res = equipHandler_pb.EquipMeltResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.EquipHandler.equipMeltRequest(c2s_indexs,cb,option)
	local msg = {}
	msg.c2s_indexs = c2s_indexs
	Socket.OnRequestStart("area.equipHandler.equipMeltRequest", option)
	Socket.Request("area.equipHandler.equipMeltRequest", msg, function(res)
		if(res.s2c_code == 200) then
			Pomelo.EquipHandler.lastEquipMeltResponse = res
			Socket.OnRequestEnd("area.equipHandler.equipMeltRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] area.equipHandler.equipMeltRequest decode error!!"
			end
			Socket.OnRequestEnd("area.equipHandler.equipMeltRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, equipMeltRequestEncoder, equipMeltRequestDecoder)
end


local function chatEquipDetailRequestEncoder(msg)
	local input = equipHandler_pb.ChatEquipDetailRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function chatEquipDetailRequestDecoder(stream)
	local res = equipHandler_pb.ChatEquipDetailResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.EquipHandler.chatEquipDetailRequest(c2s_id,cb,option)
	local msg = {}
	msg.c2s_id = c2s_id
	Socket.OnRequestStart("area.equipHandler.chatEquipDetailRequest", option)
	Socket.Request("area.equipHandler.chatEquipDetailRequest", msg, function(res)
		if(res.s2c_code == 200) then
			Pomelo.EquipHandler.lastChatEquipDetailResponse = res
			Socket.OnRequestEnd("area.equipHandler.chatEquipDetailRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] area.equipHandler.chatEquipDetailRequest decode error!!"
			end
			Socket.OnRequestEnd("area.equipHandler.chatEquipDetailRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, chatEquipDetailRequestEncoder, chatEquipDetailRequestDecoder)
end


local function equipRebornRequestEncoder(msg)
	local input = equipHandler_pb.EquipRebornRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function equipRebornRequestDecoder(stream)
	local res = equipHandler_pb.EquipRebornResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.EquipHandler.equipRebornRequest(equipId,cb,option)
	local msg = {}
	msg.equipId = equipId
	Socket.OnRequestStart("area.equipHandler.equipRebornRequest", option)
	Socket.Request("area.equipHandler.equipRebornRequest", msg, function(res)
		if(res.s2c_code == 200) then
			Pomelo.EquipHandler.lastEquipRebornResponse = res
			Socket.OnRequestEnd("area.equipHandler.equipRebornRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] area.equipHandler.equipRebornRequest decode error!!"
			end
			Socket.OnRequestEnd("area.equipHandler.equipRebornRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, equipRebornRequestEncoder, equipRebornRequestDecoder)
end


local function equipRebuildRequestEncoder(msg)
	local input = equipHandler_pb.EquipRebuildRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function equipRebuildRequestDecoder(stream)
	local res = equipHandler_pb.EquipRebuildResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.EquipHandler.equipRebuildRequest(equipId,lockedAttId,cb,option)
	local msg = {}
	msg.equipId = equipId
	msg.lockedAttId = lockedAttId
	Socket.OnRequestStart("area.equipHandler.equipRebuildRequest", option)
	Socket.Request("area.equipHandler.equipRebuildRequest", msg, function(res)
		if(res.s2c_code == 200) then
			Pomelo.EquipHandler.lastEquipRebuildResponse = res
			Socket.OnRequestEnd("area.equipHandler.equipRebuildRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] area.equipHandler.equipRebuildRequest decode error!!"
			end
			Socket.OnRequestEnd("area.equipHandler.equipRebuildRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, equipRebuildRequestEncoder, equipRebuildRequestDecoder)
end


local function equipSeniorRebuildRequestEncoder(msg)
	local input = equipHandler_pb.EquipSeniorRebuildRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function equipSeniorRebuildRequestDecoder(stream)
	local res = equipHandler_pb.EquipSeniorRebuildResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.EquipHandler.equipSeniorRebuildRequest(equipId,cb,option)
	local msg = {}
	msg.equipId = equipId
	Socket.OnRequestStart("area.equipHandler.equipSeniorRebuildRequest", option)
	Socket.Request("area.equipHandler.equipSeniorRebuildRequest", msg, function(res)
		if(res.s2c_code == 200) then
			Pomelo.EquipHandler.lastEquipSeniorRebuildResponse = res
			Socket.OnRequestEnd("area.equipHandler.equipSeniorRebuildRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] area.equipHandler.equipSeniorRebuildRequest decode error!!"
			end
			Socket.OnRequestEnd("area.equipHandler.equipSeniorRebuildRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, equipSeniorRebuildRequestEncoder, equipSeniorRebuildRequestDecoder)
end


local function equipRefineRequestEncoder(msg)
	local input = equipHandler_pb.EquipRefineRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function equipRefineRequestDecoder(stream)
	local res = equipHandler_pb.EquipRefineResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.EquipHandler.equipRefineRequest(equipId,attrkey,cb,option)
	local msg = {}
	msg.equipId = equipId
	msg.attrkey = attrkey
	Socket.OnRequestStart("area.equipHandler.equipRefineRequest", option)
	Socket.Request("area.equipHandler.equipRefineRequest", msg, function(res)
		if(res.s2c_code == 200) then
			Pomelo.EquipHandler.lastEquipRefineResponse = res
			Socket.OnRequestEnd("area.equipHandler.equipRefineRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] area.equipHandler.equipRefineRequest decode error!!"
			end
			Socket.OnRequestEnd("area.equipHandler.equipRefineRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, equipRefineRequestEncoder, equipRefineRequestDecoder)
end


local function equipRefineLegendRequestEncoder(msg)
	local input = equipHandler_pb.EquipRefineLegendRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function equipRefineLegendRequestDecoder(stream)
	local res = equipHandler_pb.EquipRefineLegendResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.EquipHandler.equipRefineLegendRequest(equipId,attrkey,cb,option)
	local msg = {}
	msg.equipId = equipId
	msg.attrkey = attrkey
	Socket.OnRequestStart("area.equipHandler.equipRefineLegendRequest", option)
	Socket.Request("area.equipHandler.equipRefineLegendRequest", msg, function(res)
		if(res.s2c_code == 200) then
			Pomelo.EquipHandler.lastEquipRefineLegendResponse = res
			Socket.OnRequestEnd("area.equipHandler.equipRefineLegendRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] area.equipHandler.equipRefineLegendRequest decode error!!"
			end
			Socket.OnRequestEnd("area.equipHandler.equipRefineLegendRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, equipRefineLegendRequestEncoder, equipRefineLegendRequestDecoder)
end


local function saveRebornRequestEncoder(msg)
	local input = equipHandler_pb.SaveRebornRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function saveRebornRequestDecoder(stream)
	local res = equipHandler_pb.SaveRebornResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.EquipHandler.saveRebornRequest(equipId,cb,option)
	local msg = {}
	msg.equipId = equipId
	Socket.OnRequestStart("area.equipHandler.saveRebornRequest", option)
	Socket.Request("area.equipHandler.saveRebornRequest", msg, function(res)
		if(res.s2c_code == 200) then
			Pomelo.EquipHandler.lastSaveRebornResponse = res
			Socket.OnRequestEnd("area.equipHandler.saveRebornRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] area.equipHandler.saveRebornRequest decode error!!"
			end
			Socket.OnRequestEnd("area.equipHandler.saveRebornRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, saveRebornRequestEncoder, saveRebornRequestDecoder)
end


local function saveRebuildRequestEncoder(msg)
	local input = equipHandler_pb.SaveRebuildRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function saveRebuildRequestDecoder(stream)
	local res = equipHandler_pb.SaveRebuildResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.EquipHandler.saveRebuildRequest(equipId,cb,option)
	local msg = {}
	msg.equipId = equipId
	Socket.OnRequestStart("area.equipHandler.saveRebuildRequest", option)
	Socket.Request("area.equipHandler.saveRebuildRequest", msg, function(res)
		if(res.s2c_code == 200) then
			Pomelo.EquipHandler.lastSaveRebuildResponse = res
			Socket.OnRequestEnd("area.equipHandler.saveRebuildRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] area.equipHandler.saveRebuildRequest decode error!!"
			end
			Socket.OnRequestEnd("area.equipHandler.saveRebuildRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, saveRebuildRequestEncoder, saveRebuildRequestDecoder)
end


local function smritiRequestEncoder(msg)
	local input = equipHandler_pb.SmritiRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function smritiRequestDecoder(stream)
	local res = equipHandler_pb.SmritiResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.EquipHandler.smritiRequest(letf_equipId,right_equipId,cb,option)
	local msg = {}
	msg.letf_equipId = letf_equipId
	msg.right_equipId = right_equipId
	Socket.OnRequestStart("area.equipHandler.smritiRequest", option)
	Socket.Request("area.equipHandler.smritiRequest", msg, function(res)
		if(res.s2c_code == 200) then
			Pomelo.EquipHandler.lastSmritiResponse = res
			Socket.OnRequestEnd("area.equipHandler.smritiRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] area.equipHandler.smritiRequest decode error!!"
			end
			Socket.OnRequestEnd("area.equipHandler.smritiRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, smritiRequestEncoder, smritiRequestDecoder)
end


local function saveSeniorRebuildRequestEncoder(msg)
	local input = equipHandler_pb.SaveSeniorRebuildRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function saveSeniorRebuildRequestDecoder(stream)
	local res = equipHandler_pb.SaveSeniorRebuildResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.EquipHandler.saveSeniorRebuildRequest(equipId,cb,option)
	local msg = {}
	msg.equipId = equipId
	Socket.OnRequestStart("area.equipHandler.saveSeniorRebuildRequest", option)
	Socket.Request("area.equipHandler.saveSeniorRebuildRequest", msg, function(res)
		if(res.s2c_code == 200) then
			Pomelo.EquipHandler.lastSaveSeniorRebuildResponse = res
			Socket.OnRequestEnd("area.equipHandler.saveSeniorRebuildRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] area.equipHandler.saveSeniorRebuildRequest decode error!!"
			end
			Socket.OnRequestEnd("area.equipHandler.saveSeniorRebuildRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, saveSeniorRebuildRequestEncoder, saveSeniorRebuildRequestDecoder)
end


local function saveRefineRequestEncoder(msg)
	local input = equipHandler_pb.SaveRefineRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function saveRefineRequestDecoder(stream)
	local res = equipHandler_pb.SaveRefineResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.EquipHandler.saveRefineRequest(equipId,attrkey,cb,option)
	local msg = {}
	msg.equipId = equipId
	msg.attrkey = attrkey
	Socket.OnRequestStart("area.equipHandler.saveRefineRequest", option)
	Socket.Request("area.equipHandler.saveRefineRequest", msg, function(res)
		if(res.s2c_code == 200) then
			Pomelo.EquipHandler.lastSaveRefineResponse = res
			Socket.OnRequestEnd("area.equipHandler.saveRefineRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] area.equipHandler.saveRefineRequest decode error!!"
			end
			Socket.OnRequestEnd("area.equipHandler.saveRefineRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, saveRefineRequestEncoder, saveRefineRequestDecoder)
end


local function saveRefineLegendRequestEncoder(msg)
	local input = equipHandler_pb.SaveRefineLegendRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function saveRefineLegendRequestDecoder(stream)
	local res = equipHandler_pb.SaveRefineLegendResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.EquipHandler.saveRefineLegendRequest(equipId,attrkey,cb,option)
	local msg = {}
	msg.equipId = equipId
	msg.attrkey = attrkey
	Socket.OnRequestStart("area.equipHandler.saveRefineLegendRequest", option)
	Socket.Request("area.equipHandler.saveRefineLegendRequest", msg, function(res)
		if(res.s2c_code == 200) then
			Pomelo.EquipHandler.lastSaveRefineLegendResponse = res
			Socket.OnRequestEnd("area.equipHandler.saveRefineLegendRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] area.equipHandler.saveRefineLegendRequest decode error!!"
			end
			Socket.OnRequestEnd("area.equipHandler.saveRefineLegendRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, saveRefineLegendRequestEncoder, saveRefineLegendRequestDecoder)
end


local function getRefineExtPropRequestEncoder(msg)
	local input = equipHandler_pb.GetRefineExtPropRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function getRefineExtPropRequestDecoder(stream)
	local res = equipHandler_pb.GetRefineExtPropResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.EquipHandler.getRefineExtPropRequest(equipId,cb,option)
	local msg = {}
	msg.equipId = equipId
	Socket.OnRequestStart("area.equipHandler.getRefineExtPropRequest", option)
	Socket.Request("area.equipHandler.getRefineExtPropRequest", msg, function(res)
		if(res.s2c_code == 200) then
			Pomelo.EquipHandler.lastGetRefineExtPropResponse = res
			Socket.OnRequestEnd("area.equipHandler.getRefineExtPropRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] area.equipHandler.getRefineExtPropRequest decode error!!"
			end
			Socket.OnRequestEnd("area.equipHandler.getRefineExtPropRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, getRefineExtPropRequestEncoder, getRefineExtPropRequestDecoder)
end


local function equipmentSimplePushDecoder(stream)
	local res = equipHandler_pb.EquipmentSimplePush()
	res:ParseFromString(stream)
	return res
end

function Pomelo.EquipHandler.equipmentSimplePush(cb)
	Socket.On("area.equipPush.equipmentSimplePush", function(res) 
		Pomelo.EquipHandler.lastEquipmentSimplePush = res
		cb(nil,res) 
	end, equipmentSimplePushDecoder) 
end


local function equipInheritPushDecoder(stream)
	local res = equipHandler_pb.EquipInheritPush()
	res:ParseFromString(stream)
	return res
end

function Pomelo.EquipHandler.equipInheritPush(cb)
	Socket.On("area.equipPush.equipInheritPush", function(res) 
		Pomelo.EquipHandler.lastEquipInheritPush = res
		cb(nil,res) 
	end, equipInheritPushDecoder) 
end


local function equipStrengthPosPushDecoder(stream)
	local res = equipHandler_pb.StrengthPosPush()
	res:ParseFromString(stream)
	return res
end

function Pomelo.EquipHandler.equipStrengthPosPush(cb)
	Socket.On("area.equipPush.equipStrengthPosPush", function(res) 
		Pomelo.EquipHandler.lastStrengthPosPush = res
		cb(nil,res) 
	end, equipStrengthPosPushDecoder) 
end





return Pomelo
