





local Socket = require "Xmds.Pomelo.LuaGameSocket"
require "base64"
require "battleHandler_pb"


Pomelo = Pomelo or {}


Pomelo.BattleHandler = {}

local function throwPointRequestEncoder(msg)
	local input = battleHandler_pb.ThrowPointRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function throwPointRequestDecoder(stream)
	local res = battleHandler_pb.ThrowPointResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.BattleHandler.throwPointRequest(id,cb,option)
	local msg = {}
	msg.id = id
	Socket.OnRequestStart("area.battleHandler.throwPointRequest", option)
	Socket.Request("area.battleHandler.throwPointRequest", msg, function(res)
		if(res.s2c_code == 200) then
			Pomelo.BattleHandler.lastThrowPointResponse = res
			Socket.OnRequestEnd("area.battleHandler.throwPointRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] area.battleHandler.throwPointRequest decode error!!"
			end
			Socket.OnRequestEnd("area.battleHandler.throwPointRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, throwPointRequestEncoder, throwPointRequestDecoder)
end


local function throwPointItemListPushDecoder(stream)
	local res = battleHandler_pb.ThrowPointItemListPush()
	res:ParseFromString(stream)
	return res
end

function Pomelo.BattleHandler.throwPointItemListPush(cb)
	Socket.On("area.battlePush.throwPointItemListPush", function(res) 
		Pomelo.BattleHandler.lastThrowPointItemListPush = res
		cb(nil,res) 
	end, throwPointItemListPushDecoder) 
end


local function throwPointResultPushDecoder(stream)
	local res = battleHandler_pb.ThrowPointResultPush()
	res:ParseFromString(stream)
	return res
end

function Pomelo.BattleHandler.throwPointResultPush(cb)
	Socket.On("area.battlePush.throwPointResultPush", function(res) 
		Pomelo.BattleHandler.lastThrowPointResultPush = res
		cb(nil,res) 
	end, throwPointResultPushDecoder) 
end


local function fightLevelResultPushDecoder(stream)
	local res = battleHandler_pb.FightLevelResultPush()
	res:ParseFromString(stream)
	return res
end

function Pomelo.BattleHandler.fightLevelResultPush(cb)
	Socket.On("area.battlePush.fightLevelResultPush", function(res) 
		Pomelo.BattleHandler.lastFightLevelResultPush = res
		cb(nil,res) 
	end, fightLevelResultPushDecoder) 
end


local function itemDropPushDecoder(stream)
	local res = battleHandler_pb.ItemDropPush()
	res:ParseFromString(stream)
	return res
end

function Pomelo.BattleHandler.itemDropPush(cb)
	Socket.On("area.battlePush.itemDropPush", function(res) 
		Pomelo.BattleHandler.lastItemDropPush = res
		cb(nil,res) 
	end, itemDropPushDecoder) 
end


local function sceneNamePushDecoder(stream)
	local res = battleHandler_pb.SceneNamePush()
	res:ParseFromString(stream)
	return res
end

function Pomelo.BattleHandler.sceneNamePush(cb)
	Socket.On("area.battlePush.sceneNamePush", function(res) 
		Pomelo.BattleHandler.lastSceneNamePush = res
		cb(nil,res) 
	end, sceneNamePushDecoder) 
end


local function resourceDungeonResultPushDecoder(stream)
	local res = battleHandler_pb.ResourceDungeonResultPush()
	res:ParseFromString(stream)
	return res
end

function Pomelo.BattleHandler.resourceDungeonResultPush(cb)
	Socket.On("area.battlePush.resourceDungeonResultPush", function(res) 
		Pomelo.BattleHandler.lastResourceDungeonResultPush = res
		cb(nil,res) 
	end, resourceDungeonResultPushDecoder) 
end





return Pomelo
