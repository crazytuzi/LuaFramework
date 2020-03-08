local Lplus = require("Lplus")
local AtProtocols = Lplus.Class("AtProtocols")
local def = AtProtocols.define
def.static().RegisterProtocols = function()
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.role.SGetRoleInfoRes", AtProtocols.OnSGetRoleInfoRes)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.role.SGetRoleInfoByNameFail", AtProtocols.OnSGetRoleInfoByNameFail)
end
def.static("userdata").SendCGetRoleInfoByIdReq = function(roleId)
  warn("[AtProtocols:SendCGetRoleInfoByIdReq] Send CGetRoleInfoReq, roleId:", roleId and Int64.tostring(roleId))
  local p = require("netio.protocol.mzm.gsp.role.CGetRoleInfoReq").new(roleId)
  gmodule.network.sendProtocol(p)
end
def.static("string").SendCGetRoleInfoByNameReq = function(name)
  warn("[AtProtocols:SendCGetRoleInfoByNameReq] Send CGetRoleInfoByNameReq, name:", name)
  local Octets = require("netio.Octets")
  local octets = Octets.rawFromString(name)
  local p = require("netio.protocol.mzm.gsp.role.CGetRoleInfoByNameReq").new(octets)
  gmodule.network.sendProtocol(p)
end
def.static("table").OnSGetRoleInfoRes = function(p)
  warn("[AtProtocols:OnSGetRoleInfoRes] On SGetRoleInfoRes!")
  require("Main.Chat.At.AtMgr").OnSGetRoleInfoRes(p)
end
def.static("table").OnSGetRoleInfoByNameFail = function(p)
  warn("[AtProtocols:OnSGetRoleInfoByNameFail] On SGetRoleInfoByNameFail! p.res:", p.res)
  require("Main.Chat.At.AtMgr").OnSGetRoleInfoByNameFail(p)
end
AtProtocols.Commit()
return AtProtocols
