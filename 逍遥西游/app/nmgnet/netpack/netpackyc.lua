function cryptoprotocal:handshakedcallback(netpackycObj)
  netpackycObj.state = 3
  if netpackycObj.handshaked then
    netpackycObj.handshaked()
  end
end
function cryptoprotocal:send(netpackycObj, msg)
  netpackycObj:socket_write(msg)
end
local netpackyc = {}
local cryptoProto = "Y\n"
local cryptkey = "worinimapoxieyi"
local debug = false
local function dprint(...)
  if debug then
    print(...)
  end
end
function netpackyc.new(obj, o)
  o = o or {}
  if type(obj) == "number" then
    o.fd = obj
  elseif type(obj) == "string" then
    o.fd = tonumber(obj)
  else
    o.socket = obj
    o.fd = obj:getfd()
  end
  setmetatable(o, netpackyc)
  netpackyc.__index = netpackyc
  o.netpackxs = netpackxs.new()
  function o.npconfig:msghandler(...)
    return netpackyc.msghandler(o, ...)
  end
  function o.npconfig:rawmsghandler(...)
    return netpackyc.rawmsghandler(o, ...)
  end
  o.npconfig.sendrawdata = o.sendrawdata
  o.netpackxs:init(o.npconfig)
  return o
end
function netpackyc:afterConnect()
  self.state = 1
end
function netpackyc:handshake(nmsg)
  if self.state == 1 then
    print("---------------->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>", cryptkey, nmsg)
    local toproto = cryptoprotocal:desdecode(cryptkey, nmsg)
    self.protocal = toproto
  end
  if self.protocal == "D\n" then
    self.handshake_state = nil
    self.state = 3
    dprint("[C]handshake finish.")
    if self.handshaked then
      self.handshaked()
    end
  elseif self.protocal == cryptoProto then
    if self.state == 1 then
      self.state = 2
    else
      cryptoprotocal:autoStep(self, nmsg)
    end
  else
    error(nmsg)
  end
end
function netpackyc:socket_write(...)
  if self.state == 3 then
    if self.protocal == "D\n" then
      self.netpackxs.senddata(self.netpackxs, ...)
    elseif self.protocal == cryptoProto then
      local msg = cryptoprotocal:enCrypto(self, ...)
      self.netpackxs.senddata(self.netpackxs, msg)
    else
      error(self.protocal)
    end
  else
    self.netpackxs.senddata(self.netpackxs, ...)
  end
end
function netpackyc:rawmsghandler(fd, msg, sz)
  if self.state == 3 then
    if self.protocal == "D\n" then
      local nmsg = self.netpackxs.tostring(msg, sz)
      return self:msghandler(fd, nmsg)
    elseif self.protocal == cryptoProto then
      local nmsg = self.netpackxs.tostring(msg, sz)
      nmsg = cryptoprotocal:deCrypto(self, nmsg)
      return self:msghandler(fd, nmsg)
    else
      error(self.protocal)
    end
  else
    local nmsg = self.netpackxs.tostring(msg, sz)
    return self:msghandler(fd, nmsg)
  end
end
function netpackyc:msghandler(fd, nmsg)
  assert(self.state)
  if self.state == 1 then
    self:handshake(nmsg)
  elseif self.state == 2 then
    self:handshake(nmsg)
  else
    dprint("netpackyc ok.", nmsg)
    return nmsg
  end
end
function netpackyc:trystep()
  local msg, sz = self.socket_read()
  if sz > 0 then
    return self.netpackxs:unpack(self.fd, msg, sz)
  end
  return nil
end
function netpackyc:unpack(msg, sz)
  if sz > 0 then
    return self.netpackxs:unpack(self.fd, msg, sz)
  end
  return nil
end
return netpackyc
