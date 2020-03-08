local Lplus = require("Lplus")
local Protocol = require("Protocol.Protocol")
local C2SCommand = require("C2S.C2SCommand")
local S2CCommand = require("S2C.S2CCommand")
local S2CManager = require("S2C.S2CManager")
local GamedataSend = require("Protocol.GamedataSend")
local ProtocolManager = require("Protocol.ProtocolManager")
local Callbacks = require("Utility.Callbacks")
local ECNetwork = Lplus.Class("ECNetwork")
local def = ECNetwork.define
def.field("userdata").m_GameSession = nil
def.field("userdata").account = nil
def.field("table").m_OldProtos = nil
def.field("boolean").PauseProtocol = false
def.field("number").ConnectTimes = 0
def.field("string").connectstatus = ""
def.static("=>", ECNetwork).new = function()
  local obj = ECNetwork()
  obj.m_OldProtos = {}
  obj.connectstatus = "broken"
  return obj
end
def.method().Init = function(self)
  self.m_GameSession = ECGameSession.Instance()
end
def.method().Release = function(self)
  if self.m_GameSession then
    self.m_GameSession:Close()
    self:OnClose()
  end
end
def.method("userdata").SetAccount = function(self, account)
  self.account = account
end
def.method("string", "number", "string", "string").ConnectToServer = function(self, server, port, username, password)
  self.m_GameSession:Close()
  self.m_GameSession:ConnectToServer(server, port, username, password)
  self.connectstatus = "waiting"
  self.ConnectTimes = self.ConnectTimes + 1
end
def.method().Close = function(self)
  self.m_GameSession:Close()
  self:OnClose()
end
def.method().OnClose = function(self)
  self.m_OldProtos = {}
  self.connectstatus = "broken"
  local panel = require("GUI.ECPanelCommonLoading")
  panel.Instance():ShowPanel(false)
end
def.method("userdata").OnPrtc_Challenge = function(self, octetsStream)
  self.m_GameSession:OnPrtc_Challenge(octetsStream)
  self.connectstatus = "connected"
  self.ConnectTimes = 0
end
def.method("userdata").OnPrtc_KeyExchange = function(self, octetsStream)
  self.m_GameSession:OnPrtc_KeyExchange(octetsStream)
end
local _max_proto_per_frame = 50
def.method("number").Tick = function(self, dt)
  local gs = self.m_GameSession
  gs:Tick(dt)
  if self.PauseProtocol then
    return
  end
  local cur_count = 0
  local oldproto = self.m_OldProtos
  local oldcount = #oldproto
  local index = 1
  if oldcount > 0 then
    self.m_OldProtos = {}
    for i = 1, oldcount, 2 do
      do
        local type = oldproto[i]
        local proto = oldproto[i + 1]
        local ret, errmsg = xpcall(function()
          ProtocolManager.OnReceiveProtocolData(type, proto)
        end, function(errlog)
          return debug.traceback(errlog)
        end)
        if not ret then
          local index = 1
          local temp = self.m_OldProtos
          for j = i + 2, oldcount do
            temp[index] = oldproto[j]
            index = index + 1
          end
          error(errmsg)
        end
        cur_count = cur_count + 1
        if self.PauseProtocol or cur_count >= _max_proto_per_frame then
          local temp = {}
          for j = i + 2, oldcount do
            temp[index] = oldproto[j]
            index = index + 1
          end
          self.m_OldProtos = temp
          return
        end
      end
    end
    oldproto = self.m_OldProtos
  end
  local tbl = gs:GetProtocols()
  local procount = #tbl
  for i = 1, procount, 2 do
    do
      local type = tbl[i]
      local proto = tbl[i + 1]
      local ret, errmsg = xpcall(function()
        ProtocolManager.OnReceiveProtocolData(type, proto)
      end, function(errlog)
        return debug.traceback(("failed to process protocol: %d: %s"):format(type, errlog))
      end)
      if not ret then
        local index = 1
        local temp = self.m_OldProtos
        for j = i + 2, procount do
          temp[index] = tbl[j]
          index = index + 1
        end
        error(errmsg)
      end
      cur_count = cur_count + 1
      if self.PauseProtocol or cur_count >= _max_proto_per_frame then
        for j = i + 2, procount do
          oldproto[index] = tbl[j]
          index = index + 1
        end
        return
      end
    end
  end
end
def.method(Protocol).SendProtocol = function(self, p)
  local os = OctetsStream.OctetsStream()
  p:Marshal(os)
  self.m_GameSession:SendLuaProtocol(p:GetType(), os)
end
_G.CmdServerDeltaTime = 0
def.method(C2SCommand).SendGameData = function(self, cmd)
  local g = GamedataSend()
  local bw = BinaryWriter.Create()
  bw:WriteUInt16(cmd:GetType())
  cmd:Marshal(bw)
  g.data = bw:ToOctets()
  self:SendProtocol(g)
end
def.method(GamedataSend).ProcessGameData = function(self, netCmd)
  local br = BinaryReader.Create(netCmd.data)
  local cmd_type = br:ReadUInt16()
  CmdServerDeltaTime = GameUtil.GetServerDeltaTime(netCmd.server_send_time)
  S2CManager.OnReceiveS2CCommandData(cmd_type, br)
end
ECNetwork.Commit()
return ECNetwork
