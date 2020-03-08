local Lplus = require("Lplus")
local net_common = require("PB.net_common")
local S2CManager = require("S2C.S2CManager")
local S2CCommand = require("S2C.S2CCommand")
local C2SCommand = require("C2S.C2SCommand")
local ProtocolManager = require("Protocol.ProtocolManager")
local GProtocNet = require("Protocol.GProtocNet")
local GProtocNet_Re = require("Protocol.GProtocNet_Re")
local AnonymousEventManager = require("Utility.AnonymousEvent").AnonymousEventManager
local GcCallbacks = require("Utility.GcCallbacks")
local pairs = pairs
local require = require
local type = type
local warn = warn
local error = error
local tostring = tostring
local _G = _G
local Octets = Octets
require("Utility.global").disable()
local l_nameToInfo = {}
local l_pbClassToInfo = {}
local function addPbInfo(type, name, pb_class, id)
  local info = {
    type = type,
    name = name,
    pb_class = pb_class,
    id = id
  }
  l_nameToInfo[name] = info
  l_pbClassToInfo[pb_class] = info
end
local l_s2cIdToS2cClass = {}
local l_s2cHandlerMap = {}
local l_dsIdToDsClass = {}
local l_dsIdToPbClass = {}
local l_dsHandlerMap = {}
local function registerS2C(name, id, pb_class)
  local s2c_class = Lplus.Extend(S2CCommand, "PB.S2C_CMD." .. name)
  do
    local def = s2c_class.define
    def.field("table").msg = nil
    def.override("userdata").Unmarshal = function(self, br)
      local msg = pb_class()
      local allBytes = br:ReadAllBytes()
      msg:ParseFromString(allBytes)
      self.msg = msg
    end
  end
  s2c_class.Commit()
  S2CManager.Register(id, s2c_class)
  addPbInfo("S2C", name, pb_class, id)
  l_s2cIdToS2cClass[id] = s2c_class
end
local C2SProtocCommand = Lplus.Extend(C2SCommand, "PB.C2SProtocCommand")
do
  local def = C2SProtocCommand.define
  def.final("number", "table", "=>", C2SProtocCommand).new = function(id, msg)
    local obj = C2SProtocCommand()
    obj.m_id = id
    obj.m_msg = msg
    return obj
  end
  def.override("=>", "number").GetType = function(self)
    return self.m_id
  end
  def.override("userdata").Marshal = function(self, bw)
    local str = self.m_msg:SerializeToString()
    bw:WriteBytes(self.m_msg:SerializeToString())
  end
  def.field("number").m_id = 0
  def.field("table").m_msg = nil
end
C2SProtocCommand.Commit()
local function registerC2S(name, id, pb_class)
  addPbInfo("C2S", name, pb_class, id)
end
local l_dsProtocolManager = AnonymousEventManager()
do
  local function gprotocNetHandler(sender, cmd)
    local cmdId = cmd.dtype
    local content = cmd.datainfo:getBytes()
    local ds_class = l_dsIdToDsClass[cmdId]
    if ds_class then
      local event = ds_class.new(content)
      l_dsProtocolManager:raiseEvent(sender, event)
    else
      warn("unhandled ds protocol buffer type " .. cmdId)
    end
  end
  ProtocolManager.AddHandler(GProtocNet_Re, gprotocNetHandler)
end
local function registerDS(name, id, pb_class)
  local ds_class = Lplus.Class("PB.DS_CMD." .. name)
  do
    local def = ds_class.define
    def.field("table").msg = nil
    def.final("string", "=>", ds_class).new = function(content)
      local obj = ds_class()
      local msg = pb_class()
      msg:ParseFromString(content)
      obj.msg = msg
      return obj
    end
  end
  ds_class.Commit()
  addPbInfo("DS", name, pb_class, id)
  l_dsIdToDsClass[id] = ds_class
  l_dsIdToPbClass[id] = pb_class
end
local NET_PROTOCBUF_TYPE = net_common.NET_PROTOCBUF_TYPE
local C2S_GS_PROTOC_TYPE = net_common.C2S_GS_PROTOC_TYPE
local S2C_GS_PROTOC_TYPE = net_common.S2C_GS_PROTOC_TYPE
for MsgName, MsgType in pairs(net_common) do
  if type(MsgType) == "table" and MsgType.GetFieldDescriptor then
    local field = MsgType.GetFieldDescriptor("type")
    if field then
      local theType = field.enum_type
      local MsgID = field.default_value
      if theType == NET_PROTOCBUF_TYPE then
        registerDS(MsgName, MsgID, MsgType)
      elseif theType == C2S_GS_PROTOC_TYPE then
        registerC2S(MsgName, MsgID, MsgType)
      elseif theType == S2C_GS_PROTOC_TYPE then
        registerS2C(MsgName, MsgID, MsgType)
      end
    end
  end
end
local pb_helper = Lplus.Class("PB.pb_helper")
do
  local def = pb_helper.define
  local function requireCmdInfoByName(cmdName)
    local info = l_nameToInfo[cmdName]
    if info == nil then
      error("bad protocol buffers command name: " .. tostring(cmdName))
    end
    return info.type, info.pb_class, info.id
  end
  def.static("string", "=>", "table").GetCmdClass = function(cmdName)
    local info = l_nameToInfo[cmdName]
    if info then
      return info.pb_class
    else
      return nil
    end
  end
  def.static("string", "=>", "table").NewCmd = function(cmdName)
    local info = l_nameToInfo[cmdName]
    if info then
      return info.pb_class()
    else
      return nil
    end
  end
  def.static("string", "function").AddHandler = function(cmdName, handler)
    local type, pb_class, id = requireCmdInfoByName(cmdName)
    if type == "S2C" then
      local s2c_class = l_s2cIdToS2cClass[id]
      local function realHandler(sender, cmd)
        handler(sender, cmd.msg)
      end
      l_s2cHandlerMap[handler] = realHandler
      S2CManager.AddHandler(s2c_class, realHandler)
    elseif type == "DS" then
      local ds_class = l_dsIdToDsClass[id]
      local function realHandler(sender, cmd)
        handler(sender, cmd.msg)
      end
      l_dsHandlerMap[handler] = realHandler
      l_dsProtocolManager:addHandler(ds_class, realHandler)
    else
      error(("bad protocol type to receive, got type: %s, name: %s"):format(type, name))
    end
  end
  def.static("string", "function", GcCallbacks).AddHandlerWithCleaner = function(cmdName, handler, cleaner)
    pb_helper.AddHandler(cmdName, handler)
    cleaner:add(function()
      pb_helper.RemoveHandler(cmdName, handler)
    end)
  end
  def.static("string", "function").RemoveHandler = function(cmdName, handler)
    local type, pb_class, id = requireCmdInfoByName(cmdName)
    if type == "S2C" then
      local s2c_class = l_s2cIdToS2cClass[id]
      local realHandler = l_s2cHandlerMap[handler]
      if realHandler then
        S2CManager.RemoveHandler(s2c_class, realHandler)
        l_s2cHandlerMap[handler] = nil
      end
    elseif type == "DS" then
      local ds_class = l_dsIdToDsClass[id]
      local realHandler = l_dsHandlerMap[handler]
      if realHandler then
        l_dsProtocolManager:removeHandler(ds_class, realHandler)
        l_dsHandlerMap[handler] = nil
      end
    else
      error(("bad protocol type to receive, got type: %s, name: %s"):format(type, name))
    end
  end
  def.static("table").Send = function(msg)
    local pb_class = msg:GetMessage()
    local info = l_pbClassToInfo[pb_class]
    local type, id = info.type, info.id
    if type == "C2S" then
      local cmd = C2SProtocCommand.new(id, msg)
      local ECGame = require("Main.ECGame")
      ECGame.Instance().m_Network:SendGameData(cmd)
    elseif type == "DS" then
      local ECGame = require("Main.ECGame")
      local cmd = GProtocNet()
      cmd.dtype = id
      cmd.roleid = ECGame.Instance().m_HostPlayer.ID
      cmd.datainfo = Octets.Octets()
      cmd.datainfo:replace(msg:SerializeToString())
      ECGame.Instance().m_Network:SendProtocol(cmd)
    else
      error(("bad protocol type to send, got type: %s"):format(type))
    end
  end
  def.static("number", "userdata").MakeDSCmd = function(id, data)
    local pb_class = l_dsIdToPbClass(id)
    local msg = pb_class()
    local content = data:getBytes()
    msg:ParseFromString(content)
    return msg
  end
end
return pb_helper.Commit()
