





local Socket = require "Xmds.Pomelo.LuaGameSocket"
require "base64"
require "giftOnlineHandler_pb"


Pomelo = Pomelo or {}


Pomelo.GiftOnlineHandler = {}

local function getOnLineGiftRequestEncoder(msg)
	local input = giftOnlineHandler_pb.GetOnLineGiftRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function getOnLineGiftRequestDecoder(stream)
	local res = giftOnlineHandler_pb.GetOnLineGiftResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.GiftOnlineHandler.getOnLineGiftRequest(cb,option)
	local input = nil
	Socket.OnRequestStart("area.giftOnlineHandler.getOnLineGiftRequest", option)
	Socket.Request("area.giftOnlineHandler.getOnLineGiftRequest", input, function(res)
		if(res.s2c_code == 200) then
			Pomelo.GiftOnlineHandler.lastGetOnLineGiftResponse = res
			Socket.OnRequestEnd("area.giftOnlineHandler.getOnLineGiftRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] area.giftOnlineHandler.getOnLineGiftRequest decode error!!"
			end
			Socket.OnRequestEnd("area.giftOnlineHandler.getOnLineGiftRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, getOnLineGiftRequestEncoder, getOnLineGiftRequestDecoder)
end





return Pomelo
