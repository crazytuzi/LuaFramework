local ProtocolTable = require("netio.protocol.ProtocolTable")
local ConnectHandler = require("netio.ConnectHandler")
local OctetsStream = require("netio.OctetsStream")
_G.MaxProtoTimePerFrame = 0.012
_G.ProtoLogLevel = Application.isEditor and 2 or platform == 0 and 1 or 0
local ProtocolManager = {}
ProtocolManager.__isconnected = false
ProtocolManager.__callback = nil
local ProtocolClassTable = {}
local function RegisterProtocol(protoID, protoName)
  local funcs = {}
  local protoClass = require(protoName)
  ProtocolClassTable[protoID] = function()
    return protoClass, funcs
  end
end
for protoID, protoName in pairs(ProtocolTable) do
  if protoName ~= "netio.protocol.mzm.gsp.BeanImport" then
    RegisterProtocol(protoID, protoName)
  end
end
function ProtocolManager.GetProtocolStub(protoID)
  return ProtocolClassTable[protoID]
end
function ProtocolManager.startup(callback)
  ProtocolManager.__callback = callback
  local ret = __NetIO_Startup()
  if ProtocolManager.__callback then
    if ret then
      ProtocolManager.__callback:handleStartup(ConnectHandler.STARTUP_OK)
    else
      ProtocolManager.__callback:handleStartup(ConnectHandler.STARTUP_ERR)
    end
  end
  return ret
end
function ProtocolManager.cleanup()
  __NetIO_Cleanup()
end
function ProtocolManager.connect(host, port, userid, passwd)
  local ret = __NetIO_Connect(host, port, userid, passwd)
  if ProtocolManager.__callback then
    if ret then
      ProtocolManager.__callback:handleConnect(ConnectHandler.CONNECT_WAIT)
    else
      ProtocolManager.__callback:handleConnect(ConnectHandler.CONNECT_ERR)
    end
  end
  return ret
end
function ProtocolManager.disconnect()
  ProtocolManager.__isconnected = false
  __NetIO_Disconnect()
  if ProtocolManager.__callback then
    ProtocolManager.__callback:handleConnect(ConnectHandler.CONNECT_LOST)
  end
end
function ProtocolManager.resetConnectStatus(connect)
  ProtocolManager.__isconnected = connect
end
function ProtocolManager.isconnected()
  if _G.IsReplayNetIO then
    return true
  end
  return ProtocolManager.__isconnected
end
function ProtocolManager.checkconnect()
  local state = __NetIO_IsConnected()
  if ProtocolManager.__isconnected ~= state then
    ProtocolManager.__isconnected = state
    if ProtocolManager.__callback then
      if ProtocolManager.__isconnected then
        ProtocolManager.__callback:handleConnect(ConnectHandler.CONNECT_OK)
      else
        ProtocolManager.__callback:handleConnect(ConnectHandler.CONNECT_LOST)
      end
    end
  end
end
function ProtocolManager.RegisterModuleProtocol(protoID, callBack)
  local f = ProtocolClassTable[protoID]
  if f then
    local _, funcs = f()
    table.insert(funcs, callBack)
  end
end
function ProtocolManager.sendProtocol(protoObj)
  local os = OctetsStream.beginSendStream()
  protoObj:marshal(os)
  if protoObj.id ~= 100 then
    if _G.ProtoLogLevel == 1 then
      local protocolName = ProtocolTable[protoObj.id] or "UNKNOW"
      print("*LUA* Send Protocol ID = " .. protoObj.id .. "(" .. protocolName .. ")")
    elseif _G.ProtoLogLevel == 2 then
      print("<color=white>SendProtocol:" .. protoObj.__cname .. ">\n" .. pretty(protoObj) .. "</color>")
    end
  end
  local protoSize = OctetsStream.SendStreamSize(os)
  OctetsStream.endSendStream(os)
  os = OctetsStream.beginSendStream()
  os:marshalCompactUInt32(protoObj.id)
  os:marshalCompactUInt32(protoSize)
  protoObj:marshal(os)
  OctetsStream.SendStream(os)
  OctetsStream.endSendStream(os)
end
local octetsStreamTable = {}
local octStreamCount = 0
local NetIOHeroPosTable = {}
function ProtocolManager.SaveOctetsStream(protoID, octStreamData)
  local octStream = __NetIO_CreateOctStream(octStreamData)
  local now = os.time()
  local tmpTabel = {
    Time.frameCount,
    Time.time,
    #ProtocolClassTable,
    Time.realtimeSinceStartup,
    protoID,
    octStream
  }
  table.insert(octetsStreamTable, tmpTabel)
  octStreamCount = octStreamCount + 1
end
function ProtocolManager.SaveOctetsToFile()
  local OctetsDir = GameUtil.GetAssetsPath() .. "/"
  local fileName = os.date("%Y-%m-%d_%H-%M-%S", os.time())
  local path = OctetsDir .. fileName .. ".replay"
  local file = io.open(path, "w+")
  if file then
    file:write(octStreamCount)
    file:write(" ")
  end
  io.close(file)
  local offset = string.len(tostring(octStreamCount))
  for k, v in pairs(octetsStreamTable) do
    local octSteam = __NetIO_SaveFileFromOctets(path, v[1], v[2], v[3], v[4], v[5], v[6])
  end
  ProtocolManager.SaveReplayHeroPosToFile(fileName)
end
function ProtocolManager.SaveReplayHeroPos()
  local heroModule = gmodule.moduleMgr:GetModule(ModuleId.HERO)
  if heroModule == nil then
    return
  end
  local role = heroModule.myRole
  if role == nil then
    return
  end
  local x = role.m_node2d.localPosition.x
  local y = role.m_node2d.localPosition.y
  local pos = {
    x,
    y,
    Time.time
  }
  table.insert(NetIOHeroPosTable, pos)
end
local beginPosTime = 0
local offsetPosTime = 0
local isFirst = true
function ProtocolManager.UpdateReplayHeroPos()
  if #NetIOHeroPosTable <= 0 then
    return
  end
  local time = NetIOHeroPosTable[1][3]
  if beginPosTime <= 0 then
    beginPosTime = time
    offsetPosTime = Time.time
  end
  beginPosTime = beginPosTime + Time.time - offsetPosTime
  offsetPosTime = Time.time
  if time <= beginPosTime then
    local map = gmodule.moduleMgr:GetModule(ModuleId.MAP)
    local hero = gmodule.moduleMgr:GetModule(ModuleId.HERO)
    if map and hero then
      local mapid = gmodule.moduleMgr:GetModule(ModuleId.MAP).currentMapId
      local heroModule = gmodule.moduleMgr:GetModule(ModuleId.HERO)
      if heroModule == nil or heroModule.myRole == nil then
        return
      end
      if isFirst then
        isFirst = false
        heroModule.myRole:SetPos(NetIOHeroPosTable[1][1], NetIOHeroPosTable[1][2])
      end
      heroModule:MoveTo(mapid, NetIOHeroPosTable[1][1], NetIOHeroPosTable[1][2], 0, 0, MoveType.AUTO, nil)
      table.remove(NetIOHeroPosTable, 1)
    end
  end
end
function ProtocolManager.SaveReplayHeroPosToFile(fileName)
  local OctetsDir = GameUtil.GetAssetsPath() .. "/"
  local path = OctetsDir .. fileName .. "_pos.replay"
  local file = io.open(path, "w+")
  if file == nil then
    return
  end
  file:write(tostring(#NetIOHeroPosTable) .. "\n")
  for k, v in pairs(NetIOHeroPosTable) do
    file:write(tostring(v[1]) .. "\n")
    file:write(tostring(v[2]) .. "\n")
    file:write(tostring(v[3]) .. "\n")
  end
  NetIOHeroPosTable = {}
  io.close(file)
end
function ProtocolManager.LoadReplayHeroPosFromFile(fileName)
  local OctetsDir = GameUtil.GetAssetsPath() .. "/"
  local path = OctetsDir .. fileName .. "_pos.replay"
  local file = io.open(path, "r+")
  if file == nil then
    return
  end
  NetIOHeroPosTable = {}
  local count = file:read()
  for i = 1, count do
    local x = file:read()
    local y = file:read()
    local time = file:read()
    local pos = {
      tonumber(x),
      tonumber(y),
      tonumber(time)
    }
    table.insert(NetIOHeroPosTable, pos)
  end
  io.close(file)
end
function ProtocolManager.LoadOctetsFromFile(fileName)
  local OctetsDir = GameUtil.GetAssetsPath() .. "/"
  local path = OctetsDir .. fileName .. ".replay"
  local count = 0
  local file = io.open(path, "r")
  if file then
    count = file:read("*number")
  end
  io.close(file)
  local offset = string.len(tostring(count)) + 1
  ProtocolManager.ClearOctets()
  for i = 0, count - 1 do
    local netIOsize, allSize, octetSteam = __NetIO_LoadFileFromOctets(path, offset)
    if octetSteam ~= nil then
      local size = __NetIO_GetSize(octetSteam)
      offset = offset + allSize
      local netIOSteamData = __NetIO_UnmarshalOctetsByLen(octetSteam, netIOsize)
      local frameCount = __NetIO_UnmarshalUInt32(octetSteam)
      local time = __NetIO_UnmarshalFloat(octetSteam)
      local protoLen = __NetIO_UnmarshalUInt32(octetSteam)
      local realtimeSinceStartup = __NetIO_UnmarshalFloat(octetSteam)
      local protoid = __NetIO_UnmarshalUInt32(octetSteam)
      local tmpTabel = {
        frameCount,
        time,
        protoLen,
        realtimeSinceStartup,
        protoid,
        netIOSteamData,
        x,
        y
      }
      table.insert(octetsStreamTable, tmpTabel)
    end
  end
  ProtocolManager.LoadReplayHeroPosFromFile(fileName)
end
function ProtocolManager.PrintOctetsStream(...)
  for k, v in pairs(octetsStreamTable) do
    warn("k,v =", k, v[1])
  end
end
function ProtocolManager.ClearOctets()
  for k, v in pairs(octetsStreamTable) do
    __NetIO_DeleteOctets(v[6])
  end
  octetsStreamTable = {}
  octStreamCount = 0
end
local beginTime = 0
local offsetTime = 0
function ProtocolManager.BeginRecvSaveStream()
  if #octetsStreamTable <= 0 then
    return nil
  end
  local time = octetsStreamTable[1][2]
  if beginTime <= 0 then
    beginTime = time
    offsetTime = Time.time
  end
  beginTime = beginTime + Time.time - offsetTime
  offsetTime = Time.time
  if time <= beginTime then
    return octetsStreamTable[1][6]
  end
  return nil
end
function ProtocolManager.EndRecvSaveStream(os)
  __NetIO_DeleteOctets(os)
  table.remove(octetsStreamTable, 1)
end
function ProtocolManager.BeginIOStream()
  if _G.IsReplayNetIO then
    local stream = ProtocolManager.BeginRecvSaveStream()
    if stream == nil then
      return nil
    end
    return OctetsStream.new(stream)
  else
    return OctetsStream.beginRecvStream()
  end
  return nil
end
function ProtocolManager.EndIOStream(os)
  if _G.IsReplayNetIO then
    ProtocolManager.EndRecvSaveStream(os.nativeos)
  else
    OctetsStream.endRecvStream(os)
  end
end
function ProtocolManager.update()
  local network = require("netio.Network")
  local ret = false
  if _G.IsRecordNetIO then
    ProtocolManager.SaveReplayHeroPos()
  end
  if _G.IsReplayNetIO then
    ProtocolManager.UpdateReplayHeroPos()
  end
  local maxProtTime = Time.realtimeSinceStartup + _G.MaxProtoTimePerFrame
  local os = ProtocolManager.BeginIOStream()
  while os do
    ret = true
    local protoID = os:unmarshalCompactUInt32()
    if _G.IsReplayNetIO then
      warn("protoID = ", protoID)
    end
    if _G.IsRecordNetIO then
      ProtocolManager.SaveOctetsStream(protoID, os.nativeos)
    end
    if _G.ProtoLogLevel == 1 and protoID ~= 100 then
      local protocolName = ProtocolTable[protoID] or "UNKNOW"
      print("*LUA* accept protocol id = " .. protoID .. "(" .. protocolName .. ")")
    end
    local protoSize = os:unmarshalCompactUInt32()
    local func = ProtocolClassTable[protoID]
    if func then
      local protoClass, callback = func()
      local protoObj = protoClass.new()
      if protoObj and protoObj:sizepolicy(protoSize) then
        protoObj:unmarshal(os)
        if _G.ProtoLogLevel == 2 and protoID ~= 100 then
          print("<color=green>AcceptProtocol:" .. protoObj.__cname .. ">\n" .. pretty(protoObj) .. "</color>")
        end
        network.dispatchProtocol(callback, protoObj)
      end
    else
      print("*LUA* Protocol NOT Registered", protoID)
    end
    ProtocolManager.EndIOStream(os)
    if maxProtTime < Time.realtimeSinceStartup and not _G.IsReplayNetIO and not _G.CGPlay then
      GameUtil.SkipCurrentLoadFrame()
      _G.skip_cur_onload_frame = true
      break
    end
    os = ProtocolManager.BeginIOStream()
  end
  return ret
end
function ProtocolManager.sleep(ms)
  __NetIO_Sleep(ms)
end
function ProtocolManager.issessionadd()
  return __NetIO_IsSessionAdd()
end
function ProtocolManager.issessiondel()
  return __NetIO_IsSessionDel()
end
function ProtocolManager.issessionabort()
  return __NetIO_IsSessionAbort()
end
return ProtocolManager
