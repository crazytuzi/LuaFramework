local _M = {}
_M.__index = _M

local cjson = require"cjson"

local mapData = {
	quest = nil,
	player = nil,
	monster = nil,
	npc = nil
}

local playerDataTmp = {
	id = nil,
	name = nil,
	force = nil,
	level = nil,
	legionIcon = nil,
	teamId = nil,
	legionId = nil,
	x = nil,
	y = nil
}

local monsterDataTmp = {
	id = nil,
	name = nil,
	type = nil,
	level = nil,
	x = nil,
	y = nil
}

local npcDataTmp = {
	id = nil,
	name = nil,
	func = nil,
	x = nil,
	y = nil
}

function _M.getAliveMonsterLineInfoRequest(cb)
  Pomelo.MapHandler.getAliveMonsterLineInfoRequest(function (ex,sjson)
    if not ex then
      local param = sjson:ToData()
      cb(param)
    end
  end, XmdsNetManage.PackExtData.New(false, true))
end

function _M.enterSceneByAreaIdRequest(cb)
	Pomelo.MapHandler.enterSceneByAreaIdRequest(c2s_areaId,function (ex,sjson)
		if not ex then
			local param = sjson:ToData()
			
			cb(param.data)
		end
	end)
	
end

function _M.getWorldMapListRequest(cb)
	Pomelo.MapHandler.getWorldMapListRequest(function (ex,sjson)
		if not ex then
			local param = sjson:ToData()
			
			cb(param.data)
		end
	end)
	
end

function _M.getMapListRequest(c2s_mapId, cb)
	Pomelo.MapHandler.getMapListRequest(c2s_mapId, function (ex,sjson)
		if not ex then
	      	local param = sjson:ToData()
	      	cb(param)
	    end
	end)
	
end

function _M.transByAreaIdRequest(c2s_areaId, cb)
	Pomelo.PlayerHandler.transByAreaIdRequest(c2s_areaId, function (ex,sjson)
		if not ex then
	      	local param = sjson:ToData()
	      	cb(param)
	    end
	end)
	
end

function _M.getPlayerPositionRequest(s2c_playerId, cb)
	Pomelo.PlayerHandler.getPlayerPositionRequest(s2c_playerId, function (ex,sjson)
		if not ex then
	      	local param = sjson:ToData()
	      	cb(param)
	    end
	end)
end

function _M.RequestPlayerList(cb)
    Pomelo.MapHandler.getPlayerListRequest(function (ex,sjson)
    	if not ex then
        	local param = sjson:ToData()
        	cb(param.data)
        	
        end
    end)
	
end

local function InitMock()
	
	local playerList = {}
	for i=1,12 do
		local tmp = {}
		tmp.id = i
		tmp.name = "player"..i
		tmp.force = i % 3
		tmp.level = 20 + i * 5
		tmp.legionIcon = i % 2
		tmp.teamId = i % 5
		tmp.legionId = (i + 1) % 5
		tmp.x = 20 + i * 15
		tmp.y = 20 + i * 15
		table.insert(playerList, tmp)
	end
	mapData.player = playerList

	
	local monsterList = {}
	for i=1,12 do
		local tmp = {}
		tmp.id = i
		tmp.name = "monster"..i
		tmp.type = i % 3 + 1
		tmp.level = 20 + i * 5
		tmp.x = 160 - i * 30
		tmp.y = 20 + i * 30
		table.insert(monsterList, tmp)
	end
	mapData.monster = monsterList

	
	local bit = require("bit")
	local npcList = {}
	for i=1,12 do
		local tmp = {}
		tmp.id = i
		tmp.name = "npc"..i
		tmp.func = bit.rshift(i, 1)
		tmp.x = 100 - i * 10
		tmp.y = 60 + i * 10
		table.insert(npcList, tmp)
	end
	mapData.npc = npcList
end

InitMock()

function _M.InitNetWork()

end

return _M
