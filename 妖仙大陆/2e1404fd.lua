





local Socket = require "Xmds.Pomelo.LuaGameSocket"
require "base64"
require "rankHandler_pb"


Pomelo = Pomelo or {}


Pomelo.RankHandler = {}

local function getRankInfoRequestEncoder(msg)
	local input = rankHandler_pb.GetRankInfoRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function getRankInfoRequestDecoder(stream)
	local res = rankHandler_pb.GetRankInfoResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.RankHandler.getRankInfoRequest(cb,option)
	local input = nil
	Socket.OnRequestStart("area.rankHandler.getRankInfoRequest", option)
	Socket.Request("area.rankHandler.getRankInfoRequest", input, function(res)
		if(res.s2c_code == 200) then
			Pomelo.RankHandler.lastGetRankInfoResponse = res
			Socket.OnRequestEnd("area.rankHandler.getRankInfoRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] area.rankHandler.getRankInfoRequest decode error!!"
			end
			Socket.OnRequestEnd("area.rankHandler.getRankInfoRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, getRankInfoRequestEncoder, getRankInfoRequestDecoder)
end


local function saveRankNotifyEncoder(msg)
	local input = rankHandler_pb.SaveRankNotify()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

function Pomelo.RankHandler.saveRankNotify(c2s_selectedRankId)
	local msg = {}
	msg.c2s_selectedRankId = c2s_selectedRankId
	Socket.Notify("area.rankHandler.saveRankNotify", msg, saveRankNotifyEncoder)
end


local function onAwardRankPushDecoder(stream)
	local res = rankHandler_pb.OnAwardRankPush()
	res:ParseFromString(stream)
	return res
end

function Pomelo.RankHandler.onAwardRankPush(cb)
	Socket.On("area.rankPush.onAwardRankPush", function(res) 
		Pomelo.RankHandler.lastOnAwardRankPush = res
		cb(nil,res) 
	end, onAwardRankPushDecoder) 
end





return Pomelo
