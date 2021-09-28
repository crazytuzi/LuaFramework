





local Socket = require "Zeus.Pomelo.LuaGameSocket"
require "base64"
require "guildManagerDepotHandler_pb"


Pomelo = Pomelo or {}


Pomelo.GuildManagerDepotHandler = {}

function Pomelo.GuildManagerDepotHandler.getDepotInfoRequest(cb,option)
	local input = nil
	Socket.Request("manager.guildManagerDepotHandler.getDepotInfoRequest", input,function(stream)
		stream = ZZBase64.decode(stream)
		local res = guildManagerDepotHandler_pb.GetDepotInfoResponse()
		res:ParseFromString(stream)
		if(res.s2c_code == 200) then
			Pomelo.GuildManagerDepotHandler.lastGetDepotInfoResponse = res
			Socket.OnRequestEnd(true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] manager.guildManagerDepotHandler.getDepotInfoRequest decode error!!"
			end
			Socket.OnRequestEnd(false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end,option)
end

function Pomelo.GuildManagerDepotHandler.getDepotRecordRequest(page,cb,option)
	local msg = {}
	msg.page = page
	local input = guildManagerDepotHandler_pb.GetDepotRecordRequest()
	protobuf.FromMessage(input,msg)
	Socket.Request("manager.guildManagerDepotHandler.getDepotRecordRequest", ZZBase64.encode(input:SerializeToString()),function(stream)
		stream = ZZBase64.decode(stream)
		local res = guildManagerDepotHandler_pb.GetDepotRecordResponse()
		res:ParseFromString(stream)
		if(res.s2c_code == 200) then
			Pomelo.GuildManagerDepotHandler.lastGetDepotRecordResponse = res
			Socket.OnRequestEnd(true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] manager.guildManagerDepotHandler.getDepotRecordRequest decode error!!"
			end
			Socket.OnRequestEnd(false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end,option)
end




return Pomelo
