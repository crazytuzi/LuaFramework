





local Socket = require "Xmds.Pomelo.LuaGameSocket"
require "base64"
require "guildManagerHandler_pb"


Pomelo = Pomelo or {}


Pomelo.GuildManagerHandler = {}

local function getDepotAllGridsRequestEncoder(msg)
	local input = guildManagerHandler_pb.GetDepotAllGridsRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function getDepotAllGridsRequestDecoder(stream)
	local res = guildManagerHandler_pb.GetDepotAllGridsResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.GuildManagerHandler.getDepotAllGridsRequest(cb,option)
	local input = nil
	Socket.OnRequestStart("guild.guildManagerHandler.getDepotAllGridsRequest", option)
	Socket.Request("guild.guildManagerHandler.getDepotAllGridsRequest", input, function(res)
		if(res.s2c_code == 200) then
			Pomelo.GuildManagerHandler.lastGetDepotAllGridsResponse = res
			Socket.OnRequestEnd("guild.guildManagerHandler.getDepotAllGridsRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] guild.guildManagerHandler.getDepotAllGridsRequest decode error!!"
			end
			Socket.OnRequestEnd("guild.guildManagerHandler.getDepotAllGridsRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, getDepotAllGridsRequestEncoder, getDepotAllGridsRequestDecoder)
end


local function getDepotAllDetailsRequestEncoder(msg)
	local input = guildManagerHandler_pb.GetDepotAllDetailsRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function getDepotAllDetailsRequestDecoder(stream)
	local res = guildManagerHandler_pb.GetDepotAllDetailsResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.GuildManagerHandler.getDepotAllDetailsRequest(cb,option)
	local input = nil
	Socket.OnRequestStart("guild.guildManagerHandler.getDepotAllDetailsRequest", option)
	Socket.Request("guild.guildManagerHandler.getDepotAllDetailsRequest", input, function(res)
		if(res.s2c_code == 200) then
			Pomelo.GuildManagerHandler.lastGetDepotAllDetailsResponse = res
			Socket.OnRequestEnd("guild.guildManagerHandler.getDepotAllDetailsRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] guild.guildManagerHandler.getDepotAllDetailsRequest decode error!!"
			end
			Socket.OnRequestEnd("guild.guildManagerHandler.getDepotAllDetailsRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, getDepotAllDetailsRequestEncoder, getDepotAllDetailsRequestDecoder)
end


local function getDepotOneGridInfoRequestEncoder(msg)
	local input = guildManagerHandler_pb.GetDepotOneGridInfoRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function getDepotOneGridInfoRequestDecoder(stream)
	local res = guildManagerHandler_pb.GetDepotOneGridInfoResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.GuildManagerHandler.getDepotOneGridInfoRequest(bagIndex,cb,option)
	local msg = {}
	msg.bagIndex = bagIndex
	Socket.OnRequestStart("guild.guildManagerHandler.getDepotOneGridInfoRequest", option)
	Socket.Request("guild.guildManagerHandler.getDepotOneGridInfoRequest", msg, function(res)
		if(res.s2c_code == 200) then
			Pomelo.GuildManagerHandler.lastGetDepotOneGridInfoResponse = res
			Socket.OnRequestEnd("guild.guildManagerHandler.getDepotOneGridInfoRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] guild.guildManagerHandler.getDepotOneGridInfoRequest decode error!!"
			end
			Socket.OnRequestEnd("guild.guildManagerHandler.getDepotOneGridInfoRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, getDepotOneGridInfoRequestEncoder, getDepotOneGridInfoRequestDecoder)
end


local function getDepotInfoRequestEncoder(msg)
	local input = guildManagerHandler_pb.GetDepotInfoRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function getDepotInfoRequestDecoder(stream)
	local res = guildManagerHandler_pb.GetDepotInfoResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.GuildManagerHandler.getDepotInfoRequest(cb,option)
	local input = nil
	Socket.OnRequestStart("guild.guildManagerHandler.getDepotInfoRequest", option)
	Socket.Request("guild.guildManagerHandler.getDepotInfoRequest", input, function(res)
		if(res.s2c_code == 200) then
			Pomelo.GuildManagerHandler.lastGetDepotInfoResponse = res
			Socket.OnRequestEnd("guild.guildManagerHandler.getDepotInfoRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] guild.guildManagerHandler.getDepotInfoRequest decode error!!"
			end
			Socket.OnRequestEnd("guild.guildManagerHandler.getDepotInfoRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, getDepotInfoRequestEncoder, getDepotInfoRequestDecoder)
end


local function getDepotRecordRequestEncoder(msg)
	local input = guildManagerHandler_pb.GetDepotRecordRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function getDepotRecordRequestDecoder(stream)
	local res = guildManagerHandler_pb.GetDepotRecordResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.GuildManagerHandler.getDepotRecordRequest(page,cb,option)
	local msg = {}
	msg.page = page
	Socket.OnRequestStart("guild.guildManagerHandler.getDepotRecordRequest", option)
	Socket.Request("guild.guildManagerHandler.getDepotRecordRequest", msg, function(res)
		if(res.s2c_code == 200) then
			Pomelo.GuildManagerHandler.lastGetDepotRecordResponse = res
			Socket.OnRequestEnd("guild.guildManagerHandler.getDepotRecordRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] guild.guildManagerHandler.getDepotRecordRequest decode error!!"
			end
			Socket.OnRequestEnd("guild.guildManagerHandler.getDepotRecordRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, getDepotRecordRequestEncoder, getDepotRecordRequestDecoder)
end


local function getBlessInfoRequestEncoder(msg)
	local input = guildManagerHandler_pb.GetBlessInfoRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function getBlessInfoRequestDecoder(stream)
	local res = guildManagerHandler_pb.GetBlessInfoResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.GuildManagerHandler.getBlessInfoRequest(cb,option)
	local input = nil
	Socket.OnRequestStart("guild.guildManagerHandler.getBlessInfoRequest", option)
	Socket.Request("guild.guildManagerHandler.getBlessInfoRequest", input, function(res)
		if(res.s2c_code == 200) then
			Pomelo.GuildManagerHandler.lastGetBlessInfoResponse = res
			Socket.OnRequestEnd("guild.guildManagerHandler.getBlessInfoRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] guild.guildManagerHandler.getBlessInfoRequest decode error!!"
			end
			Socket.OnRequestEnd("guild.guildManagerHandler.getBlessInfoRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, getBlessInfoRequestEncoder, getBlessInfoRequestDecoder)
end


local function getBlessRecordRequestEncoder(msg)
	local input = guildManagerHandler_pb.GetBlessRecordRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function getBlessRecordRequestDecoder(stream)
	local res = guildManagerHandler_pb.GetBlessRecordResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.GuildManagerHandler.getBlessRecordRequest(page,cb,option)
	local msg = {}
	msg.page = page
	Socket.OnRequestStart("guild.guildManagerHandler.getBlessRecordRequest", option)
	Socket.Request("guild.guildManagerHandler.getBlessRecordRequest", msg, function(res)
		if(res.s2c_code == 200) then
			Pomelo.GuildManagerHandler.lastGetBlessRecordResponse = res
			Socket.OnRequestEnd("guild.guildManagerHandler.getBlessRecordRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] guild.guildManagerHandler.getBlessRecordRequest decode error!!"
			end
			Socket.OnRequestEnd("guild.guildManagerHandler.getBlessRecordRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, getBlessRecordRequestEncoder, getBlessRecordRequestDecoder)
end


local function getBuildingLevelRequestEncoder(msg)
	local input = guildManagerHandler_pb.GetBuildingLevelRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function getBuildingLevelRequestDecoder(stream)
	local res = guildManagerHandler_pb.GetBuildingLevelResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.GuildManagerHandler.getBuildingLevelRequest(cb,option)
	local input = nil
	Socket.OnRequestStart("guild.guildManagerHandler.getBuildingLevelRequest", option)
	Socket.Request("guild.guildManagerHandler.getBuildingLevelRequest", input, function(res)
		if(res.s2c_code == 200) then
			Pomelo.GuildManagerHandler.lastGetBuildingLevelResponse = res
			Socket.OnRequestEnd("guild.guildManagerHandler.getBuildingLevelRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] guild.guildManagerHandler.getBuildingLevelRequest decode error!!"
			end
			Socket.OnRequestEnd("guild.guildManagerHandler.getBuildingLevelRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, getBuildingLevelRequestEncoder, getBuildingLevelRequestDecoder)
end


local function openGuildDungeonRequestEncoder(msg)
	local input = guildManagerHandler_pb.OpenGuildDungeonRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function openGuildDungeonRequestDecoder(stream)
	local res = guildManagerHandler_pb.OpenGuildDungeonResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.GuildManagerHandler.openGuildDungeonRequest(cb,option)
	local input = nil
	Socket.OnRequestStart("guild.guildManagerHandler.openGuildDungeonRequest", option)
	Socket.Request("guild.guildManagerHandler.openGuildDungeonRequest", input, function(res)
		if(res.s2c_code == 200) then
			Pomelo.GuildManagerHandler.lastOpenGuildDungeonResponse = res
			Socket.OnRequestEnd("guild.guildManagerHandler.openGuildDungeonRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] guild.guildManagerHandler.openGuildDungeonRequest decode error!!"
			end
			Socket.OnRequestEnd("guild.guildManagerHandler.openGuildDungeonRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, openGuildDungeonRequestEncoder, openGuildDungeonRequestDecoder)
end


local function guildDungeonListRequestEncoder(msg)
	local input = guildManagerHandler_pb.GuildDungeonListRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function guildDungeonListRequestDecoder(stream)
	local res = guildManagerHandler_pb.GuildDungeonListResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.GuildManagerHandler.guildDungeonListRequest(cb,option)
	local input = nil
	Socket.OnRequestStart("guild.guildManagerHandler.guildDungeonListRequest", option)
	Socket.Request("guild.guildManagerHandler.guildDungeonListRequest", input, function(res)
		if(res.s2c_code == 200) then
			Pomelo.GuildManagerHandler.lastGuildDungeonListResponse = res
			Socket.OnRequestEnd("guild.guildManagerHandler.guildDungeonListRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] guild.guildManagerHandler.guildDungeonListRequest decode error!!"
			end
			Socket.OnRequestEnd("guild.guildManagerHandler.guildDungeonListRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, guildDungeonListRequestEncoder, guildDungeonListRequestDecoder)
end


local function dungeonRankRequestEncoder(msg)
	local input = guildManagerHandler_pb.DungeonRankRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function dungeonRankRequestDecoder(stream)
	local res = guildManagerHandler_pb.DungeonRankResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.GuildManagerHandler.dungeonRankRequest(s2c_type,cb,option)
	local msg = {}
	msg.s2c_type = s2c_type
	Socket.OnRequestStart("guild.guildManagerHandler.dungeonRankRequest", option)
	Socket.Request("guild.guildManagerHandler.dungeonRankRequest", msg, function(res)
		if(res.s2c_code == 200) then
			Pomelo.GuildManagerHandler.lastDungeonRankResponse = res
			Socket.OnRequestEnd("guild.guildManagerHandler.dungeonRankRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] guild.guildManagerHandler.dungeonRankRequest decode error!!"
			end
			Socket.OnRequestEnd("guild.guildManagerHandler.dungeonRankRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, dungeonRankRequestEncoder, dungeonRankRequestDecoder)
end


local function dungeonAwardInfoRequestEncoder(msg)
	local input = guildManagerHandler_pb.DungeonAwardInfoRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function dungeonAwardInfoRequestDecoder(stream)
	local res = guildManagerHandler_pb.DungeonAwardInfoResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.GuildManagerHandler.dungeonAwardInfoRequest(cb,option)
	local input = nil
	Socket.OnRequestStart("guild.guildManagerHandler.dungeonAwardInfoRequest", option)
	Socket.Request("guild.guildManagerHandler.dungeonAwardInfoRequest", input, function(res)
		if(res.s2c_code == 200) then
			Pomelo.GuildManagerHandler.lastDungeonAwardInfoResponse = res
			Socket.OnRequestEnd("guild.guildManagerHandler.dungeonAwardInfoRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] guild.guildManagerHandler.dungeonAwardInfoRequest decode error!!"
			end
			Socket.OnRequestEnd("guild.guildManagerHandler.dungeonAwardInfoRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, dungeonAwardInfoRequestEncoder, dungeonAwardInfoRequestDecoder)
end


local function diceAwardRequestEncoder(msg)
	local input = guildManagerHandler_pb.DiceAwardRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function diceAwardRequestDecoder(stream)
	local res = guildManagerHandler_pb.DiceAwardResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.GuildManagerHandler.diceAwardRequest(s2c_pos,cb,option)
	local msg = {}
	msg.s2c_pos = s2c_pos
	Socket.OnRequestStart("guild.guildManagerHandler.diceAwardRequest", option)
	Socket.Request("guild.guildManagerHandler.diceAwardRequest", msg, function(res)
		if(res.s2c_code == 200) then
			Pomelo.GuildManagerHandler.lastDiceAwardResponse = res
			Socket.OnRequestEnd("guild.guildManagerHandler.diceAwardRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] guild.guildManagerHandler.diceAwardRequest decode error!!"
			end
			Socket.OnRequestEnd("guild.guildManagerHandler.diceAwardRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, diceAwardRequestEncoder, diceAwardRequestDecoder)
end





return Pomelo
