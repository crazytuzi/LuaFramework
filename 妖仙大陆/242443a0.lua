





local Socket = require "Xmds.Pomelo.LuaGameSocket"
require "base64"
require "playerHandler_pb"


Pomelo = Pomelo or {}


Pomelo.PlayerHandler = {}

local function getPlayerPositionRequestEncoder(msg)
	local input = playerHandler_pb.GetPlayerPositionRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function getPlayerPositionRequestDecoder(stream)
	local res = playerHandler_pb.GetPlayerPositionResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.PlayerHandler.getPlayerPositionRequest(s2c_playerId,cb,option)
	local msg = {}
	msg.s2c_playerId = s2c_playerId
	Socket.OnRequestStart("area.playerHandler.getPlayerPositionRequest", option)
	Socket.Request("area.playerHandler.getPlayerPositionRequest", msg, function(res)
		if(res.s2c_code == 200) then
			Pomelo.PlayerHandler.lastGetPlayerPositionResponse = res
			Socket.OnRequestEnd("area.playerHandler.getPlayerPositionRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] area.playerHandler.getPlayerPositionRequest decode error!!"
			end
			Socket.OnRequestEnd("area.playerHandler.getPlayerPositionRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, getPlayerPositionRequestEncoder, getPlayerPositionRequestDecoder)
end


local function transportRequestEncoder(msg)
	local input = playerHandler_pb.TransportRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function transportRequestDecoder(stream)
	local res = playerHandler_pb.TransportResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.PlayerHandler.transportRequest(c2s_transportId,cb,option)
	local msg = {}
	msg.c2s_transportId = c2s_transportId
	Socket.OnRequestStart("area.playerHandler.transportRequest", option)
	Socket.Request("area.playerHandler.transportRequest", msg, function(res)
		if(res.s2c_code == 200) then
			Pomelo.PlayerHandler.lastTransportResponse = res
			Socket.OnRequestEnd("area.playerHandler.transportRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] area.playerHandler.transportRequest decode error!!"
			end
			Socket.OnRequestEnd("area.playerHandler.transportRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, transportRequestEncoder, transportRequestDecoder)
end


local function enterSceneRequestEncoder(msg)
	local input = playerHandler_pb.EnterSceneRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function enterSceneRequestDecoder(stream)
	local res = playerHandler_pb.EnterSceneResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.PlayerHandler.enterSceneRequest(c2s_instanceId,cb,option)
	local msg = {}
	msg.c2s_instanceId = c2s_instanceId
	Socket.OnRequestStart("area.playerHandler.enterSceneRequest", option)
	Socket.Request("area.playerHandler.enterSceneRequest", msg, function(res)
		if(res.s2c_code == 200) then
			Pomelo.PlayerHandler.lastEnterSceneResponse = res
			Socket.OnRequestEnd("area.playerHandler.enterSceneRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] area.playerHandler.enterSceneRequest decode error!!"
			end
			Socket.OnRequestEnd("area.playerHandler.enterSceneRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, enterSceneRequestEncoder, enterSceneRequestDecoder)
end


local function queryLoadWayRequestEncoder(msg)
	local input = playerHandler_pb.QueryLoadWayRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function queryLoadWayRequestDecoder(stream)
	local res = playerHandler_pb.QueryLoadWayResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.PlayerHandler.queryLoadWayRequest(c2s_areaId,c2s_pointId,cb,option)
	local msg = {}
	msg.c2s_areaId = c2s_areaId
	msg.c2s_pointId = c2s_pointId
	Socket.OnRequestStart("area.playerHandler.queryLoadWayRequest", option)
	Socket.Request("area.playerHandler.queryLoadWayRequest", msg, function(res)
		if(res.s2c_code == 200) then
			Pomelo.PlayerHandler.lastQueryLoadWayResponse = res
			Socket.OnRequestEnd("area.playerHandler.queryLoadWayRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] area.playerHandler.queryLoadWayRequest decode error!!"
			end
			Socket.OnRequestEnd("area.playerHandler.queryLoadWayRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, queryLoadWayRequestEncoder, queryLoadWayRequestDecoder)
end


local function pickItemRequestEncoder(msg)
	local input = playerHandler_pb.PickItemRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function pickItemRequestDecoder(stream)
	local res = playerHandler_pb.PickItemResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.PlayerHandler.pickItemRequest(c2s_instanceId,c2s_itemId,cb,option)
	local msg = {}
	msg.c2s_instanceId = c2s_instanceId
	msg.c2s_itemId = c2s_itemId
	Socket.OnRequestStart("area.playerHandler.pickItemRequest", option)
	Socket.Request("area.playerHandler.pickItemRequest", msg, function(res)
		if(res.s2c_code == 200) then
			Pomelo.PlayerHandler.lastPickItemResponse = res
			Socket.OnRequestEnd("area.playerHandler.pickItemRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] area.playerHandler.pickItemRequest decode error!!"
			end
			Socket.OnRequestEnd("area.playerHandler.pickItemRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, pickItemRequestEncoder, pickItemRequestDecoder)
end


local function changeAreaRequestEncoder(msg)
	local input = playerHandler_pb.ChangeAreaRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function changeAreaRequestDecoder(stream)
	local res = playerHandler_pb.ChangeAreaResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.PlayerHandler.changeAreaRequest(c2s_pointId,c2s_type,cb,option)
	local msg = {}
	msg.c2s_pointId = c2s_pointId
	msg.c2s_type = c2s_type
	Socket.OnRequestStart("area.playerHandler.changeAreaRequest", option)
	Socket.Request("area.playerHandler.changeAreaRequest", msg, function(res)
		if(res.s2c_code == 200) then
			Pomelo.PlayerHandler.lastChangeAreaResponse = res
			Socket.OnRequestEnd("area.playerHandler.changeAreaRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] area.playerHandler.changeAreaRequest decode error!!"
			end
			Socket.OnRequestEnd("area.playerHandler.changeAreaRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, changeAreaRequestEncoder, changeAreaRequestDecoder)
end


local function transByAreaIdRequestEncoder(msg)
	local input = playerHandler_pb.TransByAreaIdRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function transByAreaIdRequestDecoder(stream)
	local res = playerHandler_pb.TransByAreaIdResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.PlayerHandler.transByAreaIdRequest(c2s_areaId,cb,option)
	local msg = {}
	msg.c2s_areaId = c2s_areaId
	Socket.OnRequestStart("area.playerHandler.transByAreaIdRequest", option)
	Socket.Request("area.playerHandler.transByAreaIdRequest", msg, function(res)
		if(res.s2c_code == 200) then
			Pomelo.PlayerHandler.lastTransByAreaIdResponse = res
			Socket.OnRequestEnd("area.playerHandler.transByAreaIdRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] area.playerHandler.transByAreaIdRequest decode error!!"
			end
			Socket.OnRequestEnd("area.playerHandler.transByAreaIdRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, transByAreaIdRequestEncoder, transByAreaIdRequestDecoder)
end


local function changeAreaXYRequestEncoder(msg)
	local input = playerHandler_pb.ChangeAreaXYRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function changeAreaXYRequestDecoder(stream)
	local res = playerHandler_pb.ChangeAreaXYResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.PlayerHandler.changeAreaXYRequest(mapId,posx,posy,instanceId,cb,option)
	local msg = {}
	msg.mapId = mapId
	msg.posx = posx
	msg.posy = posy
	msg.instanceId = instanceId
	Socket.OnRequestStart("area.playerHandler.changeAreaXYRequest", option)
	Socket.Request("area.playerHandler.changeAreaXYRequest", msg, function(res)
		if(res.s2c_code == 200) then
			Pomelo.PlayerHandler.lastChangeAreaXYResponse = res
			Socket.OnRequestEnd("area.playerHandler.changeAreaXYRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] area.playerHandler.changeAreaXYRequest decode error!!"
			end
			Socket.OnRequestEnd("area.playerHandler.changeAreaXYRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, changeAreaXYRequestEncoder, changeAreaXYRequestDecoder)
end


local function changeAreaByTaskRequestEncoder(msg)
	local input = playerHandler_pb.ChangeAreaByTaskRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function changeAreaByTaskRequestDecoder(stream)
	local res = playerHandler_pb.ChangeAreaByTaskResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.PlayerHandler.changeAreaByTaskRequest(mapId,taskId,posx,posy,point,cb,option)
	local msg = {}
	msg.mapId = mapId
	msg.taskId = taskId
	msg.posx = posx
	msg.posy = posy
	msg.point = point
	Socket.OnRequestStart("area.playerHandler.changeAreaByTaskRequest", option)
	Socket.Request("area.playerHandler.changeAreaByTaskRequest", msg, function(res)
		if(res.s2c_code == 200) then
			Pomelo.PlayerHandler.lastChangeAreaByTaskResponse = res
			Socket.OnRequestEnd("area.playerHandler.changeAreaByTaskRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] area.playerHandler.changeAreaByTaskRequest decode error!!"
			end
			Socket.OnRequestEnd("area.playerHandler.changeAreaByTaskRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, changeAreaByTaskRequestEncoder, changeAreaByTaskRequestDecoder)
end


local function recentContactsRequestEncoder(msg)
	local input = playerHandler_pb.RecentContactsRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function recentContactsRequestDecoder(stream)
	local res = playerHandler_pb.RecentContactsResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.PlayerHandler.recentContactsRequest(c2s_ids,cb,option)
	local msg = {}
	msg.c2s_ids = c2s_ids
	Socket.OnRequestStart("area.playerHandler.recentContactsRequest", option)
	Socket.Request("area.playerHandler.recentContactsRequest", msg, function(res)
		if(res.s2c_code == 200) then
			Pomelo.PlayerHandler.lastRecentContactsResponse = res
			Socket.OnRequestEnd("area.playerHandler.recentContactsRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] area.playerHandler.recentContactsRequest decode error!!"
			end
			Socket.OnRequestEnd("area.playerHandler.recentContactsRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, recentContactsRequestEncoder, recentContactsRequestDecoder)
end


local function ChangePkModelRequestEncoder(msg)
	local input = playerHandler_pb.ChangPkModelRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function ChangePkModelRequestDecoder(stream)
	local res = playerHandler_pb.ChangPkModelRespone()
	res:ParseFromString(stream)
	return res
end

function Pomelo.PlayerHandler.ChangePkModelRequest(c2s_model,cb,option)
	local msg = {}
	msg.c2s_model = c2s_model
	Socket.OnRequestStart("area.playerHandler.ChangePkModelRequest", option)
	Socket.Request("area.playerHandler.ChangePkModelRequest", msg, function(res)
		if(res.s2c_code == 200) then
			Pomelo.PlayerHandler.lastChangPkModelRespone = res
			Socket.OnRequestEnd("area.playerHandler.ChangePkModelRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] area.playerHandler.ChangePkModelRequest decode error!!"
			end
			Socket.OnRequestEnd("area.playerHandler.ChangePkModelRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, ChangePkModelRequestEncoder, ChangePkModelRequestDecoder)
end


local function reliveSendPosRequestEncoder(msg)
	local input = playerHandler_pb.ReliveSendPosRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function reliveSendPosRequestDecoder(stream)
	local res = playerHandler_pb.ReliveSendPosResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.PlayerHandler.reliveSendPosRequest(cb,option)
	local input = nil
	Socket.OnRequestStart("area.playerHandler.reliveSendPosRequest", option)
	Socket.Request("area.playerHandler.reliveSendPosRequest", input, function(res)
		if(res.s2c_code == 200) then
			Pomelo.PlayerHandler.lastReliveSendPosResponse = res
			Socket.OnRequestEnd("area.playerHandler.reliveSendPosRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] area.playerHandler.reliveSendPosRequest decode error!!"
			end
			Socket.OnRequestEnd("area.playerHandler.reliveSendPosRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, reliveSendPosRequestEncoder, reliveSendPosRequestDecoder)
end


local function reliveRequestEncoder(msg)
	local input = playerHandler_pb.ReliveRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function reliveRequestDecoder(stream)
	local res = playerHandler_pb.ReliveResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.PlayerHandler.reliveRequest(type,autoPay,cb,option)
	local msg = {}
	msg.type = type
	msg.autoPay = autoPay
	Socket.OnRequestStart("area.playerHandler.reliveRequest", option)
	Socket.Request("area.playerHandler.reliveRequest", msg, function(res)
		if(res.s2c_code == 200) then
			Pomelo.PlayerHandler.lastReliveResponse = res
			Socket.OnRequestEnd("area.playerHandler.reliveRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] area.playerHandler.reliveRequest decode error!!"
			end
			Socket.OnRequestEnd("area.playerHandler.reliveRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, reliveRequestEncoder, reliveRequestDecoder)
end


local function getAreaLinesRequestEncoder(msg)
	local input = playerHandler_pb.GetAreaLinesRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function getAreaLinesRequestDecoder(stream)
	local res = playerHandler_pb.GetAreaLinesResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.PlayerHandler.getAreaLinesRequest(cb,option)
	local input = nil
	Socket.OnRequestStart("area.playerHandler.getAreaLinesRequest", option)
	Socket.Request("area.playerHandler.getAreaLinesRequest", input, function(res)
		if(res.s2c_code == 200) then
			Pomelo.PlayerHandler.lastGetAreaLinesResponse = res
			Socket.OnRequestEnd("area.playerHandler.getAreaLinesRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] area.playerHandler.getAreaLinesRequest decode error!!"
			end
			Socket.OnRequestEnd("area.playerHandler.getAreaLinesRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, getAreaLinesRequestEncoder, getAreaLinesRequestDecoder)
end


local function transByInstanceIdRequestEncoder(msg)
	local input = playerHandler_pb.TransByInstanceIdRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function transByInstanceIdRequestDecoder(stream)
	local res = playerHandler_pb.TransByInstanceIdResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.PlayerHandler.transByInstanceIdRequest(c2s_instanceId,cb,option)
	local msg = {}
	msg.c2s_instanceId = c2s_instanceId
	Socket.OnRequestStart("area.playerHandler.transByInstanceIdRequest", option)
	Socket.Request("area.playerHandler.transByInstanceIdRequest", msg, function(res)
		if(res.s2c_code == 200) then
			Pomelo.PlayerHandler.lastTransByInstanceIdResponse = res
			Socket.OnRequestEnd("area.playerHandler.transByInstanceIdRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] area.playerHandler.transByInstanceIdRequest decode error!!"
			end
			Socket.OnRequestEnd("area.playerHandler.transByInstanceIdRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, transByInstanceIdRequestEncoder, transByInstanceIdRequestDecoder)
end


local function lookUpOtherPlayerRequestEncoder(msg)
	local input = playerHandler_pb.LookUpOtherPlayerRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function lookUpOtherPlayerRequestDecoder(stream)
	local res = playerHandler_pb.LookUpOtherPlayerResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.PlayerHandler.lookUpOtherPlayerRequest(c2s_playerId,c2s_type,cb,option)
	local msg = {}
	msg.c2s_playerId = c2s_playerId
	msg.c2s_type = c2s_type
	Socket.OnRequestStart("area.playerHandler.lookUpOtherPlayerRequest", option)
	Socket.Request("area.playerHandler.lookUpOtherPlayerRequest", msg, function(res)
		if(res.s2c_code == 200) then
			Pomelo.PlayerHandler.lastLookUpOtherPlayerResponse = res
			Socket.OnRequestEnd("area.playerHandler.lookUpOtherPlayerRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] area.playerHandler.lookUpOtherPlayerRequest decode error!!"
			end
			Socket.OnRequestEnd("area.playerHandler.lookUpOtherPlayerRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, lookUpOtherPlayerRequestEncoder, lookUpOtherPlayerRequestDecoder)
end


local function agreeRebirthRequestEncoder(msg)
	local input = playerHandler_pb.AgreeRebirthRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function agreeRebirthRequestDecoder(stream)
	local res = playerHandler_pb.AgreeRebirthResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.PlayerHandler.agreeRebirthRequest(cb,option)
	local input = nil
	Socket.OnRequestStart("area.playerHandler.agreeRebirthRequest", option)
	Socket.Request("area.playerHandler.agreeRebirthRequest", input, function(res)
		if(res.s2c_code == 200) then
			Pomelo.PlayerHandler.lastAgreeRebirthResponse = res
			Socket.OnRequestEnd("area.playerHandler.agreeRebirthRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] area.playerHandler.agreeRebirthRequest decode error!!"
			end
			Socket.OnRequestEnd("area.playerHandler.agreeRebirthRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, agreeRebirthRequestEncoder, agreeRebirthRequestDecoder)
end


local function cdkRequestEncoder(msg)
	local input = playerHandler_pb.CDKRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function cdkRequestDecoder(stream)
	local res = playerHandler_pb.CDKResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.PlayerHandler.cdkRequest(c2s_cdk,c2s_channel,cb,option)
	local msg = {}
	msg.c2s_cdk = c2s_cdk
	msg.c2s_channel = c2s_channel
	Socket.OnRequestStart("area.playerHandler.cdkRequest", option)
	Socket.Request("area.playerHandler.cdkRequest", msg, function(res)
		if(res.s2c_code == 200) then
			Pomelo.PlayerHandler.lastCDKResponse = res
			Socket.OnRequestEnd("area.playerHandler.cdkRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] area.playerHandler.cdkRequest decode error!!"
			end
			Socket.OnRequestEnd("area.playerHandler.cdkRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, cdkRequestEncoder, cdkRequestDecoder)
end


local function setCustomConfigRequestEncoder(msg)
	local input = playerHandler_pb.CustomConfigRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function setCustomConfigRequestDecoder(stream)
	local res = playerHandler_pb.CustomConfigResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.PlayerHandler.setCustomConfigRequest(c2s_key,c2s_value,cb,option)
	local msg = {}
	msg.c2s_key = c2s_key
	msg.c2s_value = c2s_value
	Socket.OnRequestStart("area.playerHandler.setCustomConfigRequest", option)
	Socket.Request("area.playerHandler.setCustomConfigRequest", msg, function(res)
		if(res.s2c_code == 200) then
			Pomelo.PlayerHandler.lastCustomConfigResponse = res
			Socket.OnRequestEnd("area.playerHandler.setCustomConfigRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] area.playerHandler.setCustomConfigRequest decode error!!"
			end
			Socket.OnRequestEnd("area.playerHandler.setCustomConfigRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, setCustomConfigRequestEncoder, setCustomConfigRequestDecoder)
end


local function leaveAreaRequestEncoder(msg)
	local input = playerHandler_pb.LeaveAreaRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function leaveAreaRequestDecoder(stream)
	local res = playerHandler_pb.LeaveAreaResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.PlayerHandler.leaveAreaRequest(cb,option)
	local input = nil
	Socket.OnRequestStart("area.playerHandler.leaveAreaRequest", option)
	Socket.Request("area.playerHandler.leaveAreaRequest", input, function(res)
		if(res.s2c_code == 200) then
			Pomelo.PlayerHandler.lastLeaveAreaResponse = res
			Socket.OnRequestEnd("area.playerHandler.leaveAreaRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] area.playerHandler.leaveAreaRequest decode error!!"
			end
			Socket.OnRequestEnd("area.playerHandler.leaveAreaRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, leaveAreaRequestEncoder, leaveAreaRequestDecoder)
end


local function getSimulateDropByTcRequestEncoder(msg)
	local input = playerHandler_pb.SimulateDropByTcRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function getSimulateDropByTcRequestDecoder(stream)
	local res = playerHandler_pb.SimulateDropByTcResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.PlayerHandler.getSimulateDropByTcRequest(c2s_tcCode,c2s_tcCount,c2s_tcLevel,cb,option)
	local msg = {}
	msg.c2s_tcCode = c2s_tcCode
	msg.c2s_tcCount = c2s_tcCount
	msg.c2s_tcLevel = c2s_tcLevel
	Socket.OnRequestStart("area.playerHandler.getSimulateDropByTcRequest", option)
	Socket.Request("area.playerHandler.getSimulateDropByTcRequest", msg, function(res)
		if(res.s2c_code == 200) then
			Pomelo.PlayerHandler.lastSimulateDropByTcResponse = res
			Socket.OnRequestEnd("area.playerHandler.getSimulateDropByTcRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] area.playerHandler.getSimulateDropByTcRequest decode error!!"
			end
			Socket.OnRequestEnd("area.playerHandler.getSimulateDropByTcRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, getSimulateDropByTcRequestEncoder, getSimulateDropByTcRequestDecoder)
end


local function upgradeClassRequestEncoder(msg)
	local input = playerHandler_pb.UpgradeClassRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function upgradeClassRequestDecoder(stream)
	local res = playerHandler_pb.UpgradeClassResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.PlayerHandler.upgradeClassRequest(cb,option)
	local input = nil
	Socket.OnRequestStart("area.playerHandler.upgradeClassRequest", option)
	Socket.Request("area.playerHandler.upgradeClassRequest", input, function(res)
		if(res.s2c_code == 200) then
			Pomelo.PlayerHandler.lastUpgradeClassResponse = res
			Socket.OnRequestEnd("area.playerHandler.upgradeClassRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] area.playerHandler.upgradeClassRequest decode error!!"
			end
			Socket.OnRequestEnd("area.playerHandler.upgradeClassRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, upgradeClassRequestEncoder, upgradeClassRequestDecoder)
end


local function getClassEventConditionRequestEncoder(msg)
	local input = playerHandler_pb.GetClassEventConditionRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function getClassEventConditionRequestDecoder(stream)
	local res = playerHandler_pb.GetClassEventConditionResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.PlayerHandler.getClassEventConditionRequest(cb,option)
	local input = nil
	Socket.OnRequestStart("area.playerHandler.getClassEventConditionRequest", option)
	Socket.Request("area.playerHandler.getClassEventConditionRequest", input, function(res)
		if(res.s2c_code == 200) then
			Pomelo.PlayerHandler.lastGetClassEventConditionResponse = res
			Socket.OnRequestEnd("area.playerHandler.getClassEventConditionRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] area.playerHandler.getClassEventConditionRequest decode error!!"
			end
			Socket.OnRequestEnd("area.playerHandler.getClassEventConditionRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, getClassEventConditionRequestEncoder, getClassEventConditionRequestDecoder)
end


local function clientReadyRequestEncoder(msg)
	local input = playerHandler_pb.ClientReadyRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function clientReadyRequestDecoder(stream)
	local res = playerHandler_pb.ClientReadyResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.PlayerHandler.clientReadyRequest(cb,option)
	local input = nil
	Socket.OnRequestStart("area.playerHandler.clientReadyRequest", option)
	Socket.Request("area.playerHandler.clientReadyRequest", input, function(res)
		if(res.s2c_code == 200) then
			Pomelo.PlayerHandler.lastClientReadyResponse = res
			Socket.OnRequestEnd("area.playerHandler.clientReadyRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] area.playerHandler.clientReadyRequest decode error!!"
			end
			Socket.OnRequestEnd("area.playerHandler.clientReadyRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, clientReadyRequestEncoder, clientReadyRequestDecoder)
end


local function sendGMCmdRequestEncoder(msg)
	local input = playerHandler_pb.SendGMCmdRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function sendGMCmdRequestDecoder(stream)
	local res = playerHandler_pb.SendGMCmdResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.PlayerHandler.sendGMCmdRequest(c2s_msg,cb,option)
	local msg = {}
	msg.c2s_msg = c2s_msg
	Socket.OnRequestStart("area.playerHandler.sendGMCmdRequest", option)
	Socket.Request("area.playerHandler.sendGMCmdRequest", msg, function(res)
		if(res.s2c_code == 200) then
			Pomelo.PlayerHandler.lastSendGMCmdResponse = res
			Socket.OnRequestEnd("area.playerHandler.sendGMCmdRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] area.playerHandler.sendGMCmdRequest decode error!!"
			end
			Socket.OnRequestEnd("area.playerHandler.sendGMCmdRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, sendGMCmdRequestEncoder, sendGMCmdRequestDecoder)
end


local function exchangePropertyInfoRequestEncoder(msg)
	local input = playerHandler_pb.ExchangePropertyInfoRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function exchangePropertyInfoRequestDecoder(stream)
	local res = playerHandler_pb.ExchangePropertyInfoResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.PlayerHandler.exchangePropertyInfoRequest(cb,option)
	local input = nil
	Socket.OnRequestStart("area.playerHandler.exchangePropertyInfoRequest", option)
	Socket.Request("area.playerHandler.exchangePropertyInfoRequest", input, function(res)
		if(res.s2c_code == 200) then
			Pomelo.PlayerHandler.lastExchangePropertyInfoResponse = res
			Socket.OnRequestEnd("area.playerHandler.exchangePropertyInfoRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] area.playerHandler.exchangePropertyInfoRequest decode error!!"
			end
			Socket.OnRequestEnd("area.playerHandler.exchangePropertyInfoRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, exchangePropertyInfoRequestEncoder, exchangePropertyInfoRequestDecoder)
end


local function exchangePropertyRequestEncoder(msg)
	local input = playerHandler_pb.ExchangePropertyRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function exchangePropertyRequestDecoder(stream)
	local res = playerHandler_pb.ExchangePropertyResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.PlayerHandler.exchangePropertyRequest(type,cb,option)
	local msg = {}
	msg.type = type
	Socket.OnRequestStart("area.playerHandler.exchangePropertyRequest", option)
	Socket.Request("area.playerHandler.exchangePropertyRequest", msg, function(res)
		if(res.s2c_code == 200) then
			Pomelo.PlayerHandler.lastExchangePropertyResponse = res
			Socket.OnRequestEnd("area.playerHandler.exchangePropertyRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] area.playerHandler.exchangePropertyRequest decode error!!"
			end
			Socket.OnRequestEnd("area.playerHandler.exchangePropertyRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, exchangePropertyRequestEncoder, exchangePropertyRequestDecoder)
end


local function battleEventNotifyEncoder(msg)
	local input = playerHandler_pb.BattleEventNotify()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

function Pomelo.PlayerHandler.battleEventNotify(c2s_data)
	local msg = {}
	msg.c2s_data = c2s_data
	Socket.Notify("area.playerHandler.battleEventNotify", msg, battleEventNotifyEncoder)
end


local function clientConfigPushDecoder(stream)
	local res = playerHandler_pb.ClientConfigPush()
	res:ParseFromString(stream)
	return res
end

function Pomelo.PlayerHandler.clientConfigPush(cb)
	Socket.On("area.playerPush.clientConfigPush", function(res) 
		Pomelo.PlayerHandler.lastClientConfigPush = res
		cb(nil,res) 
	end, clientConfigPushDecoder) 
end


local function battleEventPushDecoder(stream)
	local res = playerHandler_pb.BattleEventPush()
	res:ParseFromString(stream)
	return res
end

function Pomelo.PlayerHandler.battleEventPush(cb)
	Socket.On("area.playerPush.battleEventPush", function(res) 
		Pomelo.PlayerHandler.lastBattleEventPush = res
		cb(nil,res) 
	end, battleEventPushDecoder) 
end


local function battleClearPushDecoder(stream)
	local res = playerHandler_pb.BattleClearPush()
	res:ParseFromString(stream)
	return res
end

function Pomelo.PlayerHandler.battleClearPush(cb)
	Socket.On("area.playerPush.battleClearPush", function(res) 
		Pomelo.PlayerHandler.lastBattleClearPush = res
		cb(nil,res) 
	end, battleClearPushDecoder) 
end


local function onSuperScriptPushDecoder(stream)
	local res = playerHandler_pb.SuperScriptPush()
	res:ParseFromString(stream)
	return res
end

function Pomelo.PlayerHandler.onSuperScriptPush(cb)
	Socket.On("area.playerPush.onSuperScriptPush", function(res) 
		Pomelo.PlayerHandler.lastSuperScriptPush = res
		cb(nil,res) 
	end, onSuperScriptPushDecoder) 
end


local function changeAreaPushDecoder(stream)
	local res = playerHandler_pb.ChangeAreaPush()
	res:ParseFromString(stream)
	return res
end

function Pomelo.PlayerHandler.changeAreaPush(cb)
	Socket.On("area.playerPush.changeAreaPush", function(res) 
		Pomelo.PlayerHandler.lastChangeAreaPush = res
		cb(nil,res) 
	end, changeAreaPushDecoder) 
end


local function playerDynamicPushDecoder(stream)
	local res = playerHandler_pb.PlayerDynamicPush()
	res:ParseFromString(stream)
	return res
end

function Pomelo.PlayerHandler.playerDynamicPush(cb)
	Socket.On("area.playerPush.playerDynamicPush", function(res) 
		Pomelo.PlayerHandler.lastPlayerDynamicPush = res
		cb(nil,res) 
	end, playerDynamicPushDecoder) 
end


local function playerRelivePushDecoder(stream)
	local res = playerHandler_pb.PlayerRelivePush()
	res:ParseFromString(stream)
	return res
end

function Pomelo.PlayerHandler.playerRelivePush(cb)
	Socket.On("area.playerPush.playerRelivePush", function(res) 
		Pomelo.PlayerHandler.lastPlayerRelivePush = res
		cb(nil,res) 
	end, playerRelivePushDecoder) 
end


local function playerSaverRebirthPushDecoder(stream)
	local res = playerHandler_pb.PlayerSaverRebirthPush()
	res:ParseFromString(stream)
	return res
end

function Pomelo.PlayerHandler.playerSaverRebirthPush(cb)
	Socket.On("area.playerPush.playerSaverRebirthPush", function(res) 
		Pomelo.PlayerHandler.lastPlayerSaverRebirthPush = res
		cb(nil,res) 
	end, playerSaverRebirthPushDecoder) 
end


local function simulateDropPushDecoder(stream)
	local res = playerHandler_pb.SimulateDataPush()
	res:ParseFromString(stream)
	return res
end

function Pomelo.PlayerHandler.simulateDropPush(cb)
	Socket.On("area.playerPush.simulateDropPush", function(res) 
		Pomelo.PlayerHandler.lastSimulateDataPush = res
		cb(nil,res) 
	end, simulateDropPushDecoder) 
end


local function kickPlayerPushDecoder(stream)
	local res = playerHandler_pb.KickPlayerPush()
	res:ParseFromString(stream)
	return res
end

function Pomelo.PlayerHandler.kickPlayerPush(cb)
	Socket.On("area.playerPush.kickPlayerPush", function(res) 
		Pomelo.PlayerHandler.lastKickPlayerPush = res
		cb(nil,res) 
	end, kickPlayerPushDecoder) 
end


local function suitPropertyUpPushDecoder(stream)
	local res = playerHandler_pb.SuitPropertyUpPush()
	res:ParseFromString(stream)
	return res
end

function Pomelo.PlayerHandler.suitPropertyUpPush(cb)
	Socket.On("area.playerPush.suitPropertyUpPush", function(res) 
		Pomelo.PlayerHandler.lastSuitPropertyUpPush = res
		cb(nil,res) 
	end, suitPropertyUpPushDecoder) 
end


local function commonPropertyPushDecoder(stream)
	local res = playerHandler_pb.CommonPropertyPush()
	res:ParseFromString(stream)
	return res
end

function Pomelo.PlayerHandler.commonPropertyPush(cb)
	Socket.On("area.playerPush.commonPropertyPush", function(res) 
		Pomelo.PlayerHandler.lastCommonPropertyPush = res
		cb(nil,res) 
	end, commonPropertyPushDecoder) 
end


local function buffPropertyPushDecoder(stream)
	local res = playerHandler_pb.BuffPropertyPush()
	res:ParseFromString(stream)
	return res
end

function Pomelo.PlayerHandler.buffPropertyPush(cb)
	Socket.On("area.playerPush.buffPropertyPush", function(res) 
		Pomelo.PlayerHandler.lastBuffPropertyPush = res
		cb(nil,res) 
	end, buffPropertyPushDecoder) 
end


local function playerBattleAttributePushDecoder(stream)
	local res = playerHandler_pb.PlayerBattleAttributePush()
	res:ParseFromString(stream)
	return res
end

function Pomelo.PlayerHandler.playerBattleAttributePush(cb)
	Socket.On("area.playerPush.playerBattleAttributePush", function(res) 
		Pomelo.PlayerHandler.lastPlayerBattleAttributePush = res
		cb(nil,res) 
	end, playerBattleAttributePushDecoder) 
end


local function payGiftStatePushDecoder(stream)
	local res = playerHandler_pb.PayGiftStatePush()
	res:ParseFromString(stream)
	return res
end

function Pomelo.PlayerHandler.payGiftStatePush(cb)
	Socket.On("area.playerPush.payGiftStatePush", function(res) 
		Pomelo.PlayerHandler.lastPayGiftStatePush = res
		cb(nil,res) 
	end, payGiftStatePushDecoder) 
end





return Pomelo
