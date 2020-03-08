local Lplus = require("Lplus")
local net_common = require("PB.net_common")
local ProtocolManager = require("Protocol.ProtocolManager")
local CommonInvite = require("Protocol.CommonInvite")
ProtocolManager.Register(580, "CommonInvite")
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
local l_dsIdToDsClass = {}
local l_dsIdToPbClass = {}
local l_dsHandlerMap = {}
local l_dsProtocolManager = AnonymousEventManager()
do
  local function gprotocNetHandler(sender, cmd)
    local cmdId = cmd.dtype
    local content = cmd.datainfo:getBytes()
    local ds_class = l_dsIdToDsClass[cmdId]
    if ds_class then
      local event = ds_class.new(cmd.xid, content)
      l_dsProtocolManager:raiseEvent(sender, event)
    else
      warn("unhandled ds protocol buffer type " .. cmdId)
    end
  end
  ProtocolManager.AddHandler(CommonInvite, gprotocNetHandler)
end
local function registerDS(name, id, pb_class)
  local ds_class = Lplus.Class("PB.COMMONINVITE." .. name)
  do
    local def = ds_class.define
    def.field("table").msg = nil
    def.field("number").xid = 0
    def.final("number", "string", "=>", ds_class).new = function(xid, content)
      local obj = ds_class()
      local msg = pb_class()
      obj.xid = xid
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
for MsgName, MsgType in pairs(net_common) do
  if type(MsgType) == "table" and MsgType.GetFieldDescriptor then
    local field = MsgType.GetFieldDescriptor("type")
    if field then
      local theType = field.enum_type
      local MsgID = field.default_value
      if theType == NET_PROTOCBUF_TYPE then
        registerDS(MsgName, MsgID, MsgType)
      end
    end
  end
end
local pb_commoninvite = Lplus.Class("PB.pb_commoninvite")
do
  local def = pb_commoninvite.define
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
    if type == "DS" then
      local ds_class = l_dsIdToDsClass[id]
      local function realHandler(sender, cmd)
        handler(sender, cmd.xid, cmd.msg)
      end
      l_dsHandlerMap[handler] = realHandler
      l_dsProtocolManager:addHandler(ds_class, realHandler)
    else
      error(("bad protocol type to receive, got type: %s, name: %s"):format(type, name))
    end
  end
  def.static("string", "function", GcCallbacks).AddHandlerWithCleaner = function(cmdName, handler, cleaner)
    pb_commoninvite.AddHandler(cmdName, handler)
    cleaner:add(function()
      pb_commoninvite.RemoveHandler(cmdName, handler)
    end)
  end
  def.static("string", "function").RemoveHandler = function(cmdName, handler)
    local type, pb_class, id = requireCmdInfoByName(cmdName)
    if type == "DS" then
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
    if type == "DS" then
      local ECGame = require("Main.ECGame")
      local cmd = GProtocNet()
      cmd.dtype = id
      cmd.roleid = ECGame.Instance().m_HostPlayer.ID
      cmd.datainfo = Octets.Octets()
      cmd.datainfo:replace(msg:SerializeToString())
      ECGame.Instance().m_Network:SendProtocol(cmd)
    else
      error(("bad protocol type to send, got type: %s, name: %s"):format(type, name))
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
return pb_commoninvite.Commit()
