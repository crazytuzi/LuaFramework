





local Socket = require "Xmds.Pomelo.LuaGameSocket"
require "base64"
require "fightLevelHandler_pb"


Pomelo = Pomelo or {}


Pomelo.FightLevelHandler = {}

local function fubenListRequestEncoder(msg)
	local input = fightLevelHandler_pb.FubenListRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function fubenListRequestDecoder(stream)
	local res = fightLevelHandler_pb.FubenListResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.FightLevelHandler.fubenListRequest(mapId,type,cb,option)
	local msg = {}
	msg.mapId = mapId
	msg.type = type
	Socket.OnRequestStart("area.fightLevelHandler.fubenListRequest", option)
	Socket.Request("area.fightLevelHandler.fubenListRequest", msg, function(res)
		if(res.s2c_code == 200) then
			Pomelo.FightLevelHandler.lastFubenListResponse = res
			Socket.OnRequestEnd("area.fightLevelHandler.fubenListRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] area.fightLevelHandler.fubenListRequest decode error!!"
			end
			Socket.OnRequestEnd("area.fightLevelHandler.fubenListRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, fubenListRequestEncoder, fubenListRequestDecoder)
end


local function enterDungeonRequestEncoder(msg)
	local input = fightLevelHandler_pb.EnterDungeonRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function enterDungeonRequestDecoder(stream)
	local res = fightLevelHandler_pb.EnterDungeonResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.FightLevelHandler.enterDungeonRequest(c2s_dungeonId,cb,option)
	local msg = {}
	msg.c2s_dungeonId = c2s_dungeonId
	Socket.OnRequestStart("area.fightLevelHandler.enterDungeonRequest", option)
	Socket.Request("area.fightLevelHandler.enterDungeonRequest", msg, function(res)
		if(res.s2c_code == 200) then
			Pomelo.FightLevelHandler.lastEnterDungeonResponse = res
			Socket.OnRequestEnd("area.fightLevelHandler.enterDungeonRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] area.fightLevelHandler.enterDungeonRequest decode error!!"
			end
			Socket.OnRequestEnd("area.fightLevelHandler.enterDungeonRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, enterDungeonRequestEncoder, enterDungeonRequestDecoder)
end


local function replyEnterDungeonRequestEncoder(msg)
	local input = fightLevelHandler_pb.ReplyEnterDungeonRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function replyEnterDungeonRequestDecoder(stream)
	local res = fightLevelHandler_pb.ReplyEnterDungeonResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.FightLevelHandler.replyEnterDungeonRequest(c2s_type,c2s_dungeonId,cb,option)
	local msg = {}
	msg.c2s_type = c2s_type
	msg.c2s_dungeonId = c2s_dungeonId
	Socket.OnRequestStart("area.fightLevelHandler.replyEnterDungeonRequest", option)
	Socket.Request("area.fightLevelHandler.replyEnterDungeonRequest", msg, function(res)
		if(res.s2c_code == 200) then
			Pomelo.FightLevelHandler.lastReplyEnterDungeonResponse = res
			Socket.OnRequestEnd("area.fightLevelHandler.replyEnterDungeonRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] area.fightLevelHandler.replyEnterDungeonRequest decode error!!"
			end
			Socket.OnRequestEnd("area.fightLevelHandler.replyEnterDungeonRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, replyEnterDungeonRequestEncoder, replyEnterDungeonRequestDecoder)
end


local function leaveDungeonRequestEncoder(msg)
	local input = fightLevelHandler_pb.LeaveDungeonRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function leaveDungeonRequestDecoder(stream)
	local res = fightLevelHandler_pb.LeaveDungeonResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.FightLevelHandler.leaveDungeonRequest(cb,option)
	local input = nil
	Socket.OnRequestStart("area.fightLevelHandler.leaveDungeonRequest", option)
	Socket.Request("area.fightLevelHandler.leaveDungeonRequest", input, function(res)
		if(res.s2c_code == 200) then
			Pomelo.FightLevelHandler.lastLeaveDungeonResponse = res
			Socket.OnRequestEnd("area.fightLevelHandler.leaveDungeonRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] area.fightLevelHandler.leaveDungeonRequest decode error!!"
			end
			Socket.OnRequestEnd("area.fightLevelHandler.leaveDungeonRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, leaveDungeonRequestEncoder, leaveDungeonRequestDecoder)
end


local function worldBossListRequestEncoder(msg)
	local input = fightLevelHandler_pb.WorldBossListRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function worldBossListRequestDecoder(stream)
	local res = fightLevelHandler_pb.WorldBossListResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.FightLevelHandler.worldBossListRequest(cb,option)
	local input = nil
	Socket.OnRequestStart("area.fightLevelHandler.worldBossListRequest", option)
	Socket.Request("area.fightLevelHandler.worldBossListRequest", input, function(res)
		if(res.s2c_code == 200) then
			Pomelo.FightLevelHandler.lastWorldBossListResponse = res
			Socket.OnRequestEnd("area.fightLevelHandler.worldBossListRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] area.fightLevelHandler.worldBossListRequest decode error!!"
			end
			Socket.OnRequestEnd("area.fightLevelHandler.worldBossListRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, worldBossListRequestEncoder, worldBossListRequestDecoder)
end


local function enterWorldBossRequestEncoder(msg)
	local input = fightLevelHandler_pb.EnterWorldBossRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function enterWorldBossRequestDecoder(stream)
	local res = fightLevelHandler_pb.EnterWorldBossResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.FightLevelHandler.enterWorldBossRequest(s2c_areaId,cb,option)
	local msg = {}
	msg.s2c_areaId = s2c_areaId
	Socket.OnRequestStart("area.fightLevelHandler.enterWorldBossRequest", option)
	Socket.Request("area.fightLevelHandler.enterWorldBossRequest", msg, function(res)
		if(res.s2c_code == 200) then
			Pomelo.FightLevelHandler.lastEnterWorldBossResponse = res
			Socket.OnRequestEnd("area.fightLevelHandler.enterWorldBossRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] area.fightLevelHandler.enterWorldBossRequest decode error!!"
			end
			Socket.OnRequestEnd("area.fightLevelHandler.enterWorldBossRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, enterWorldBossRequestEncoder, enterWorldBossRequestDecoder)
end


local function getMonsterLeaderRequestEncoder(msg)
	local input = fightLevelHandler_pb.GetMonsterLeaderRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function getMonsterLeaderRequestDecoder(stream)
	local res = fightLevelHandler_pb.GetMonsterLeaderResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.FightLevelHandler.getMonsterLeaderRequest(s2c_monsterId,s2c_areaId,cb,option)
	local msg = {}
	msg.s2c_monsterId = s2c_monsterId
	msg.s2c_areaId = s2c_areaId
	Socket.OnRequestStart("area.fightLevelHandler.getMonsterLeaderRequest", option)
	Socket.Request("area.fightLevelHandler.getMonsterLeaderRequest", msg, function(res)
		if(res.s2c_code == 200) then
			Pomelo.FightLevelHandler.lastGetMonsterLeaderResponse = res
			Socket.OnRequestEnd("area.fightLevelHandler.getMonsterLeaderRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] area.fightLevelHandler.getMonsterLeaderRequest decode error!!"
			end
			Socket.OnRequestEnd("area.fightLevelHandler.getMonsterLeaderRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, getMonsterLeaderRequestEncoder, getMonsterLeaderRequestDecoder)
end


local function palaceListRequestEncoder(msg)
	local input = fightLevelHandler_pb.PalaceListRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function palaceListRequestDecoder(stream)
	local res = fightLevelHandler_pb.PalaceListResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.FightLevelHandler.palaceListRequest(s2c_type,cb,option)
	local msg = {}
	msg.s2c_type = s2c_type
	Socket.OnRequestStart("area.fightLevelHandler.palaceListRequest", option)
	Socket.Request("area.fightLevelHandler.palaceListRequest", msg, function(res)
		if(res.s2c_code == 200) then
			Pomelo.FightLevelHandler.lastPalaceListResponse = res
			Socket.OnRequestEnd("area.fightLevelHandler.palaceListRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] area.fightLevelHandler.palaceListRequest decode error!!"
			end
			Socket.OnRequestEnd("area.fightLevelHandler.palaceListRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, palaceListRequestEncoder, palaceListRequestDecoder)
end


local function getBossInfoRequestEncoder(msg)
	local input = fightLevelHandler_pb.GetBossInfoRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function getBossInfoRequestDecoder(stream)
	local res = fightLevelHandler_pb.GetBossInfoResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.FightLevelHandler.getBossInfoRequest(cb,option)
	local input = nil
	Socket.OnRequestStart("area.fightLevelHandler.getBossInfoRequest", option)
	Socket.Request("area.fightLevelHandler.getBossInfoRequest", input, function(res)
		if(res.s2c_code == 200) then
			Pomelo.FightLevelHandler.lastGetBossInfoResponse = res
			Socket.OnRequestEnd("area.fightLevelHandler.getBossInfoRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] area.fightLevelHandler.getBossInfoRequest decode error!!"
			end
			Socket.OnRequestEnd("area.fightLevelHandler.getBossInfoRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, getBossInfoRequestEncoder, getBossInfoRequestDecoder)
end


local function getBossDamageRankRequestEncoder(msg)
	local input = fightLevelHandler_pb.GetBossDamageRankRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function getBossDamageRankRequestDecoder(stream)
	local res = fightLevelHandler_pb.GetBossDamageRankResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.FightLevelHandler.getBossDamageRankRequest(cb,option)
	local input = nil
	Socket.OnRequestStart("area.fightLevelHandler.getBossDamageRankRequest", option)
	Socket.Request("area.fightLevelHandler.getBossDamageRankRequest", input, function(res)
		if(res.s2c_code == 200) then
			Pomelo.FightLevelHandler.lastGetBossDamageRankResponse = res
			Socket.OnRequestEnd("area.fightLevelHandler.getBossDamageRankRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] area.fightLevelHandler.getBossDamageRankRequest decode error!!"
			end
			Socket.OnRequestEnd("area.fightLevelHandler.getBossDamageRankRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, getBossDamageRankRequestEncoder, getBossDamageRankRequestDecoder)
end


local function getLllsionInfoRequestEncoder(msg)
	local input = fightLevelHandler_pb.GetLllsionInfoRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function getLllsionInfoRequestDecoder(stream)
	local res = fightLevelHandler_pb.GetLllsionInfoResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.FightLevelHandler.getLllsionInfoRequest(cb,option)
	local input = nil
	Socket.OnRequestStart("area.fightLevelHandler.getLllsionInfoRequest", option)
	Socket.Request("area.fightLevelHandler.getLllsionInfoRequest", input, function(res)
		if(res.s2c_code == 200) then
			Pomelo.FightLevelHandler.lastGetLllsionInfoResponse = res
			Socket.OnRequestEnd("area.fightLevelHandler.getLllsionInfoRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] area.fightLevelHandler.getLllsionInfoRequest decode error!!"
			end
			Socket.OnRequestEnd("area.fightLevelHandler.getLllsionInfoRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, getLllsionInfoRequestEncoder, getLllsionInfoRequestDecoder)
end


local function enterLllsionRequestEncoder(msg)
	local input = fightLevelHandler_pb.EnterLllsionRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function enterLllsionRequestDecoder(stream)
	local res = fightLevelHandler_pb.EnterLllsionResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.FightLevelHandler.enterLllsionRequest(c2s_id,cb,option)
	local msg = {}
	msg.c2s_id = c2s_id
	Socket.OnRequestStart("area.fightLevelHandler.enterLllsionRequest", option)
	Socket.Request("area.fightLevelHandler.enterLllsionRequest", msg, function(res)
		if(res.s2c_code == 200) then
			Pomelo.FightLevelHandler.lastEnterLllsionResponse = res
			Socket.OnRequestEnd("area.fightLevelHandler.enterLllsionRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] area.fightLevelHandler.enterLllsionRequest decode error!!"
			end
			Socket.OnRequestEnd("area.fightLevelHandler.enterLllsionRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, enterLllsionRequestEncoder, enterLllsionRequestDecoder)
end


local function getLllsionBossInfoRequestEncoder(msg)
	local input = fightLevelHandler_pb.GetLllsionBossInfoRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function getLllsionBossInfoRequestDecoder(stream)
	local res = fightLevelHandler_pb.GetLllsionBossInfoResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.FightLevelHandler.getLllsionBossInfoRequest(cb,option)
	local input = nil
	Socket.OnRequestStart("area.fightLevelHandler.getLllsionBossInfoRequest", option)
	Socket.Request("area.fightLevelHandler.getLllsionBossInfoRequest", input, function(res)
		if(res.s2c_code == 200) then
			Pomelo.FightLevelHandler.lastGetLllsionBossInfoResponse = res
			Socket.OnRequestEnd("area.fightLevelHandler.getLllsionBossInfoRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] area.fightLevelHandler.getLllsionBossInfoRequest decode error!!"
			end
			Socket.OnRequestEnd("area.fightLevelHandler.getLllsionBossInfoRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, getLllsionBossInfoRequestEncoder, getLllsionBossInfoRequestDecoder)
end


local function enterLllsionBossRequestEncoder(msg)
	local input = fightLevelHandler_pb.EnterLllsionBossRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function enterLllsionBossRequestDecoder(stream)
	local res = fightLevelHandler_pb.EnterLllsionBossResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.FightLevelHandler.enterLllsionBossRequest(c2s_id,cb,option)
	local msg = {}
	msg.c2s_id = c2s_id
	Socket.OnRequestStart("area.fightLevelHandler.enterLllsionBossRequest", option)
	Socket.Request("area.fightLevelHandler.enterLllsionBossRequest", msg, function(res)
		if(res.s2c_code == 200) then
			Pomelo.FightLevelHandler.lastEnterLllsionBossResponse = res
			Socket.OnRequestEnd("area.fightLevelHandler.enterLllsionBossRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] area.fightLevelHandler.enterLllsionBossRequest decode error!!"
			end
			Socket.OnRequestEnd("area.fightLevelHandler.enterLllsionBossRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, enterLllsionBossRequestEncoder, enterLllsionBossRequestDecoder)
end


local function getBenifitableRequestEncoder(msg)
	local input = fightLevelHandler_pb.GetBenifitableRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function getBenifitableRequestDecoder(stream)
	local res = fightLevelHandler_pb.GetBenifitableResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.FightLevelHandler.getBenifitableRequest(cb,option)
	local input = nil
	Socket.OnRequestStart("area.fightLevelHandler.getBenifitableRequest", option)
	Socket.Request("area.fightLevelHandler.getBenifitableRequest", input, function(res)
		if(res.s2c_code == 200) then
			Pomelo.FightLevelHandler.lastGetBenifitableResponse = res
			Socket.OnRequestEnd("area.fightLevelHandler.getBenifitableRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] area.fightLevelHandler.getBenifitableRequest decode error!!"
			end
			Socket.OnRequestEnd("area.fightLevelHandler.getBenifitableRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, getBenifitableRequestEncoder, getBenifitableRequestDecoder)
end


local function getLllsion2InfoRequestEncoder(msg)
	local input = fightLevelHandler_pb.GetLllsion2InfoRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function getLllsion2InfoRequestDecoder(stream)
	local res = fightLevelHandler_pb.GetLllsion2InfoResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.FightLevelHandler.getLllsion2InfoRequest(cb,option)
	local input = nil
	Socket.OnRequestStart("area.fightLevelHandler.getLllsion2InfoRequest", option)
	Socket.Request("area.fightLevelHandler.getLllsion2InfoRequest", input, function(res)
		if(res.s2c_code == 200) then
			Pomelo.FightLevelHandler.lastGetLllsion2InfoResponse = res
			Socket.OnRequestEnd("area.fightLevelHandler.getLllsion2InfoRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] area.fightLevelHandler.getLllsion2InfoRequest decode error!!"
			end
			Socket.OnRequestEnd("area.fightLevelHandler.getLllsion2InfoRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, getLllsion2InfoRequestEncoder, getLllsion2InfoRequestDecoder)
end


local function enterLllsion2RequestEncoder(msg)
	local input = fightLevelHandler_pb.EnterLllsion2Request()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function enterLllsion2RequestDecoder(stream)
	local res = fightLevelHandler_pb.EnterLllsion2Response()
	res:ParseFromString(stream)
	return res
end

function Pomelo.FightLevelHandler.enterLllsion2Request(cb,option)
	local input = nil
	Socket.OnRequestStart("area.fightLevelHandler.enterLllsion2Request", option)
	Socket.Request("area.fightLevelHandler.enterLllsion2Request", input, function(res)
		if(res.s2c_code == 200) then
			Pomelo.FightLevelHandler.lastEnterLllsion2Response = res
			Socket.OnRequestEnd("area.fightLevelHandler.enterLllsion2Request", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] area.fightLevelHandler.enterLllsion2Request decode error!!"
			end
			Socket.OnRequestEnd("area.fightLevelHandler.enterLllsion2Request", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, enterLllsion2RequestEncoder, enterLllsion2RequestDecoder)
end


local function addProfitRequestEncoder(msg)
	local input = fightLevelHandler_pb.AddProfitRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function addProfitRequestDecoder(stream)
	local res = fightLevelHandler_pb.AddProfitResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.FightLevelHandler.addProfitRequest(mapId,cb,option)
	local msg = {}
	msg.mapId = mapId
	Socket.OnRequestStart("area.fightLevelHandler.addProfitRequest", option)
	Socket.Request("area.fightLevelHandler.addProfitRequest", msg, function(res)
		if(res.s2c_code == 200) then
			Pomelo.FightLevelHandler.lastAddProfitResponse = res
			Socket.OnRequestEnd("area.fightLevelHandler.addProfitRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] area.fightLevelHandler.addProfitRequest decode error!!"
			end
			Socket.OnRequestEnd("area.fightLevelHandler.addProfitRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, addProfitRequestEncoder, addProfitRequestDecoder)
end


local function onConfirmEnterFubenPushDecoder(stream)
	local res = fightLevelHandler_pb.OnConfirmEnterFubenPush()
	res:ParseFromString(stream)
	return res
end

function Pomelo.FightLevelHandler.onConfirmEnterFubenPush(cb)
	Socket.On("area.fightLevelPush.onConfirmEnterFubenPush", function(res) 
		Pomelo.FightLevelHandler.lastOnConfirmEnterFubenPush = res
		cb(nil,res) 
	end, onConfirmEnterFubenPushDecoder) 
end


local function onMemberEnterFubenStateChangePushDecoder(stream)
	local res = fightLevelHandler_pb.OnMemberEnterFubenStateChangePush()
	res:ParseFromString(stream)
	return res
end

function Pomelo.FightLevelHandler.onMemberEnterFubenStateChangePush(cb)
	Socket.On("area.fightLevelPush.onMemberEnterFubenStateChangePush", function(res) 
		Pomelo.FightLevelHandler.lastOnMemberEnterFubenStateChangePush = res
		cb(nil,res) 
	end, onMemberEnterFubenStateChangePushDecoder) 
end


local function onFubenClosePushDecoder(stream)
	local res = fightLevelHandler_pb.OnFubenClosePush()
	res:ParseFromString(stream)
	return res
end

function Pomelo.FightLevelHandler.onFubenClosePush(cb)
	Socket.On("area.fightLevelPush.onFubenClosePush", function(res) 
		Pomelo.FightLevelHandler.lastOnFubenClosePush = res
		cb(nil,res) 
	end, onFubenClosePushDecoder) 
end


local function closeHandUpPushDecoder(stream)
	local res = fightLevelHandler_pb.CloseHandUpPush()
	res:ParseFromString(stream)
	return res
end

function Pomelo.FightLevelHandler.closeHandUpPush(cb)
	Socket.On("area.fightLevelPush.closeHandUpPush", function(res) 
		Pomelo.FightLevelHandler.lastCloseHandUpPush = res
		cb(nil,res) 
	end, closeHandUpPushDecoder) 
end


local function illusionPushDecoder(stream)
	local res = fightLevelHandler_pb.IllusionPush()
	res:ParseFromString(stream)
	return res
end

function Pomelo.FightLevelHandler.illusionPush(cb)
	Socket.On("area.fightLevelPush.illusionPush", function(res) 
		Pomelo.FightLevelHandler.lastIllusionPush = res
		cb(nil,res) 
	end, illusionPushDecoder) 
end


local function illusion2PushDecoder(stream)
	local res = fightLevelHandler_pb.Illusion2Push()
	res:ParseFromString(stream)
	return res
end

function Pomelo.FightLevelHandler.illusion2Push(cb)
	Socket.On("area.fightLevelPush.illusion2Push", function(res) 
		Pomelo.FightLevelHandler.lastIllusion2Push = res
		cb(nil,res) 
	end, illusion2PushDecoder) 
end





return Pomelo
