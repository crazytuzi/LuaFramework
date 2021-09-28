local netpackxa = require("netpackxa")
local queue
local netpackxs = setmetatable({}, {
  __gc = function()
    netpackxa.clear(queue)
  end
})
setmetatable(netpackxs, netpackxa)
netpackxa.__index = netpackxa
local debug = false
local function dprint(...)
  if debug then
    print(...)
  end
end
function netpackxs.new(obj, o)
  local self = netpackxs
  o = o or {}
  setmetatable(o, self)
  self.__index = self
  return o
end
function netpackxs:init(config)
  self.msghandler = config.msghandler or self.msghandler
  self.rawmsghandler = config.rawmsghandler or self.rawmsghandler
  self.sendrawdata = config.sendrawdata or self.sendrawdata
  dprint("init msghandler", self.msghandler)
  dprint("init rawmsghandler", self.rawmsghandler)
  dprint("init sendrawdata", self.sendrawdata)
end
function netpackxs:senddata(value, size)
  local msg, sz = netpackxa.pack(value, size)
  self.sendrawdata(netpackxa.tostring(msg, sz))
end
local MSG = {}
function netpackxs:msghandler(fd, nmsg)
  return nmsg
end
function netpackxs:rawmsghandler(fd, msg, sz)
  local nmsg = netpackxa.tostring(msg, sz)
  return self:msghandler(fd, nmsg)
end
local function dispatch_msg(netpackxs, fd, msg, sz)
  dprint("dispatch_msg", fd, sz, msg)
  return netpackxs:rawmsghandler(fd, msg, sz)
end
function MSG.data(netpackxs, fd, msg, sz)
  return {
    dispatch_msg(netpackxs, fd, msg, sz)
  }
end
local function dispatch_queue(netpackxs)
  dprint("dispatch_queue")
  local fd, msg, sz = netpackxa.pop(queue)
  if fd then
    local rs = {}
    local r = dispatch_msg(netpackxs, fd, msg, sz)
    if r then
      rs[#rs + 1] = r
    end
    for fd, msg, sz in netpackxa.pop, queue, nil do
      r = dispatch_msg(netpackxs, fd, msg, sz)
      if r then
        rs[#rs + 1] = r
      end
    end
    return rs
  end
end
MSG.more = dispatch_queue
function netpackxs:dispatch(q, type, ...)
  dprint("netpackxs:dispatch", q, type, ...)
  queue = q
  if type then
    return MSG[type](self, ...)
  end
end
function netpackxs:unpack(fd, dt, sz)
  dprint("netpackxs:unpack", fd, sz)
  return self:dispatch(netpackxa.filter(queue, dt, sz, fd))
end
return netpackxs
