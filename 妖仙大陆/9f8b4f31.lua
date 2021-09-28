





local Socket = require "Xmds.Pomelo.LuaGameSocket"
require "base64"
require "consignmentLineHandler_pb"


Pomelo = Pomelo or {}


Pomelo.ConsignmentLineHandler = {}

local function addConsignmentRequestEncoder(msg)
	local input = consignmentLineHandler_pb.AddConsignmentRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function addConsignmentRequestDecoder(stream)
	local res = consignmentLineHandler_pb.AddConsignmentResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.ConsignmentLineHandler.addConsignmentRequest(c2s_index,c2s_number,c2s_price,c2s_global,c2s_isAnonymous,c2s_id,cb,option)
	local msg = {}
	msg.c2s_index = c2s_index
	msg.c2s_number = c2s_number
	msg.c2s_price = c2s_price
	msg.c2s_global = c2s_global
	msg.c2s_isAnonymous = c2s_isAnonymous
	msg.c2s_id = c2s_id
	Socket.OnRequestStart("area.consignmentLineHandler.addConsignmentRequest", option)
	Socket.Request("area.consignmentLineHandler.addConsignmentRequest", msg, function(res)
		if(res.s2c_code == 200) then
			Pomelo.ConsignmentLineHandler.lastAddConsignmentResponse = res
			Socket.OnRequestEnd("area.consignmentLineHandler.addConsignmentRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] area.consignmentLineHandler.addConsignmentRequest decode error!!"
			end
			Socket.OnRequestEnd("area.consignmentLineHandler.addConsignmentRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, addConsignmentRequestEncoder, addConsignmentRequestDecoder)
end


local function removeConsignmentRequestEncoder(msg)
	local input = consignmentLineHandler_pb.RemoveConsignmentRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function removeConsignmentRequestDecoder(stream)
	local res = consignmentLineHandler_pb.RemoveConsignmentResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.ConsignmentLineHandler.removeConsignmentRequest(c2s_id,c2s_global,cb,option)
	local msg = {}
	msg.c2s_id = c2s_id
	msg.c2s_global = c2s_global
	Socket.OnRequestStart("area.consignmentLineHandler.removeConsignmentRequest", option)
	Socket.Request("area.consignmentLineHandler.removeConsignmentRequest", msg, function(res)
		if(res.s2c_code == 200) then
			Pomelo.ConsignmentLineHandler.lastRemoveConsignmentResponse = res
			Socket.OnRequestEnd("area.consignmentLineHandler.removeConsignmentRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] area.consignmentLineHandler.removeConsignmentRequest decode error!!"
			end
			Socket.OnRequestEnd("area.consignmentLineHandler.removeConsignmentRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, removeConsignmentRequestEncoder, removeConsignmentRequestDecoder)
end


local function buyConsignmentRequestEncoder(msg)
	local input = consignmentLineHandler_pb.BuyConsignmentRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function buyConsignmentRequestDecoder(stream)
	local res = consignmentLineHandler_pb.BuyConsignmentResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.ConsignmentLineHandler.buyConsignmentRequest(c2s_id,c2s_global,cb,option)
	local msg = {}
	msg.c2s_id = c2s_id
	msg.c2s_global = c2s_global
	Socket.OnRequestStart("area.consignmentLineHandler.buyConsignmentRequest", option)
	Socket.Request("area.consignmentLineHandler.buyConsignmentRequest", msg, function(res)
		if(res.s2c_code == 200) then
			Pomelo.ConsignmentLineHandler.lastBuyConsignmentResponse = res
			Socket.OnRequestEnd("area.consignmentLineHandler.buyConsignmentRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] area.consignmentLineHandler.buyConsignmentRequest decode error!!"
			end
			Socket.OnRequestEnd("area.consignmentLineHandler.buyConsignmentRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, buyConsignmentRequestEncoder, buyConsignmentRequestDecoder)
end


local function consignmentListRequestEncoder(msg)
	local input = consignmentLineHandler_pb.ConsignmentListRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function consignmentListRequestDecoder(stream)
	local res = consignmentLineHandler_pb.ConsignmentListResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.ConsignmentLineHandler.consignmentListRequest(c2s_pro,c2s_qcolor,c2s_order,c2s_itemSecondType,c2s_page,c2s_global,c2s_itemType,c2s_level,cb,option)
	local msg = {}
	msg.c2s_pro = c2s_pro
	msg.c2s_qcolor = c2s_qcolor
	msg.c2s_order = c2s_order
	msg.c2s_itemSecondType = c2s_itemSecondType
	msg.c2s_page = c2s_page
	msg.c2s_global = c2s_global
	msg.c2s_itemType = c2s_itemType
	msg.c2s_level = c2s_level
	Socket.OnRequestStart("area.consignmentLineHandler.consignmentListRequest", option)
	Socket.Request("area.consignmentLineHandler.consignmentListRequest", msg, function(res)
		if(res.s2c_code == 200) then
			Pomelo.ConsignmentLineHandler.lastConsignmentListResponse = res
			Socket.OnRequestEnd("area.consignmentLineHandler.consignmentListRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] area.consignmentLineHandler.consignmentListRequest decode error!!"
			end
			Socket.OnRequestEnd("area.consignmentLineHandler.consignmentListRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, consignmentListRequestEncoder, consignmentListRequestDecoder)
end


local function myConsignmentRequestEncoder(msg)
	local input = consignmentLineHandler_pb.MyConsignmentRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function myConsignmentRequestDecoder(stream)
	local res = consignmentLineHandler_pb.MyConsignmentResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.ConsignmentLineHandler.myConsignmentRequest(c2s_global,cb,option)
	local msg = {}
	msg.c2s_global = c2s_global
	Socket.OnRequestStart("area.consignmentLineHandler.myConsignmentRequest", option)
	Socket.Request("area.consignmentLineHandler.myConsignmentRequest", msg, function(res)
		if(res.s2c_code == 200) then
			Pomelo.ConsignmentLineHandler.lastMyConsignmentResponse = res
			Socket.OnRequestEnd("area.consignmentLineHandler.myConsignmentRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] area.consignmentLineHandler.myConsignmentRequest decode error!!"
			end
			Socket.OnRequestEnd("area.consignmentLineHandler.myConsignmentRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, myConsignmentRequestEncoder, myConsignmentRequestDecoder)
end


local function searchConsignmentRequestEncoder(msg)
	local input = consignmentLineHandler_pb.SearchConsignmentRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function searchConsignmentRequestDecoder(stream)
	local res = consignmentLineHandler_pb.SearchConsignmentResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.ConsignmentLineHandler.searchConsignmentRequest(c2s_condition,c2s_global,cb,option)
	local msg = {}
	msg.c2s_condition = c2s_condition
	msg.c2s_global = c2s_global
	Socket.OnRequestStart("area.consignmentLineHandler.searchConsignmentRequest", option)
	Socket.Request("area.consignmentLineHandler.searchConsignmentRequest", msg, function(res)
		if(res.s2c_code == 200) then
			Pomelo.ConsignmentLineHandler.lastSearchConsignmentResponse = res
			Socket.OnRequestEnd("area.consignmentLineHandler.searchConsignmentRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] area.consignmentLineHandler.searchConsignmentRequest decode error!!"
			end
			Socket.OnRequestEnd("area.consignmentLineHandler.searchConsignmentRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, searchConsignmentRequestEncoder, searchConsignmentRequestDecoder)
end


local function publicItemRequestEncoder(msg)
	local input = consignmentLineHandler_pb.PublicItemRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function publicItemRequestDecoder(stream)
	local res = consignmentLineHandler_pb.PublicItemResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.ConsignmentLineHandler.publicItemRequest(id,cb,option)
	local msg = {}
	msg.id = id
	Socket.OnRequestStart("area.consignmentLineHandler.publicItemRequest", option)
	Socket.Request("area.consignmentLineHandler.publicItemRequest", msg, function(res)
		if(res.s2c_code == 200) then
			Pomelo.ConsignmentLineHandler.lastPublicItemResponse = res
			Socket.OnRequestEnd("area.consignmentLineHandler.publicItemRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] area.consignmentLineHandler.publicItemRequest decode error!!"
			end
			Socket.OnRequestEnd("area.consignmentLineHandler.publicItemRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, publicItemRequestEncoder, publicItemRequestDecoder)
end


local function consignmentRemovePushDecoder(stream)
	local res = consignmentLineHandler_pb.ConsignmentRemovePush()
	res:ParseFromString(stream)
	return res
end

function Pomelo.ConsignmentLineHandler.consignmentRemovePush(cb)
	Socket.On("area.consignmentLinePush.consignmentRemovePush", function(res) 
		Pomelo.ConsignmentLineHandler.lastConsignmentRemovePush = res
		cb(nil,res) 
	end, consignmentRemovePushDecoder) 
end





return Pomelo
