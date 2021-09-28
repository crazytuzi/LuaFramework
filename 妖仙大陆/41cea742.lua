



local _M = {}
_M.__index = _M

local player

local player_proto

local player_pb = require"player_pb"

local function CheckPlayer()
  if not player then
    if XmdsNetManage.Instance.IsNet then
      local json = DataMgr.Instance.UserData:GetAttribute(UserData.NotiFyStatus.PLAYER) 
      if type(json) == "string" then
        local	stream = ZZBase64.decode(json)
        local Player = player_pb.Player()
        Player:ParseFromString(stream)
        player_proto = Player
        player = Player:ToData()
      end
    else
      player = {}
    end
  end
end

local function GetBindPlayerData()
  CheckPlayer()
  return player
end

local function GetBindPlayeProto()
  CheckPlayer()
  return player_proto
end

function _M.initial()
  print("Player initial") 
end

function _M.ChangePkModelRequest(c2s_model,cb)
  Pomelo.PlayerHandler.ChangePkModelRequest(c2s_model, function (ex,json)
      if not ex then
        local param = json:ToData()
        cb(param)
      end
    end)
end

function _M.ChangeAreaXYRequest(mapId,posx,posy,instanceId,cb)
    Pomelo.PlayerHandler.changeAreaXYRequest(mapId,posx,posy,instanceId, function (ex,json)
    if not ex then
        local param = json:ToData()
        cb(param)
      end
    end)
end

function _M.RequestMapLineInfo(cb)
  Pomelo.PlayerHandler.getAreaLinesRequest(function (ex,json)
    if not ex and cb then
      local p = json:ToData()
      cb(p.s2c_data)
    end
  end)
end

function _M.RequestTransByInstanceId(instanceId)
  Pomelo.PlayerHandler.transByInstanceIdRequest(instanceId,function (ex,json)
    
  end)
end

function _M.LeaveAreaRequest(cb)
  
  Pomelo.PlayerHandler.leaveAreaRequest(function (ex,sjson)
    if not ex then
      local param = sjson:ToData()
      if cb ~= nil then
        cb(param)
      end
    end
  end)
end

function _M.GetAgoraDynamicKeyRequest(channelName, uid, cb)
  Pomelo.PlayerHandler.getAgoraDynamicKeyRequest(channelName, uid, function (ex,sjson)
    if not ex then
      local param = sjson:ToData()
      if cb ~= nil then
        cb(param)
      end
    end
  end)
end

function _M.UpgradeClassRequest(cb)
  Pomelo.PlayerHandler.upgradeClassRequest(function (ex,sjson)
    if not ex then
          local param = sjson:ToData()
          if cb ~= nil then
            cb(param)
          end
      end
  end)
end

function _M.GetClassEventCondition(cb)
  Pomelo.PlayerHandler.getClassEventConditionRequest(function (ex,sjson)
    if not ex then
          local param = sjson:ToData()
          if cb ~= nil then
            cb(param.s2c_flag)
          end
      end
  end)
end

function _M.ExchangePropertyInfoRequest(cb)
  Pomelo.PlayerHandler.exchangePropertyInfoRequest(function (ex,sjson)
    if not ex then
          local param = sjson:ToData()
          cb(param)
      end
  end)
end

function _M.ExchangePropertyRequest(index, cb)
  Pomelo.PlayerHandler.exchangePropertyRequest(index, function (ex,sjson)
    if not ex then
          local param = sjson:ToData()
          cb(param)
      end
  end)
end

_M.GetBindPlayerData = GetBindPlayerData
_M.GetBindPlayeProto = GetBindPlayeProto
return _M
