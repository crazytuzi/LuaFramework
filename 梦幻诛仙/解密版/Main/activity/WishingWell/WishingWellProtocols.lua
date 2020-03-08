local Lplus = require("Lplus")
local WishingWellData = require("Main.activity.WishingWell.data.WishingWellData")
local WishingWellProtocols = Lplus.Class("WishingWellProtocols")
local def = WishingWellProtocols.define
def.static().RegisterEvents = function()
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.bless.SGetBlessInfoSuccess", WishingWellProtocols.OnSGetBlessInfoSuccess)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.bless.SBlessSuccess", WishingWellProtocols.OnSBlessSuccess)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.bless.SBlessFailed", WishingWellProtocols.OnSBlessFailed)
end
def.static("table").OnSGetBlessInfoSuccess = function(p)
  WishingWellData.Instance():SetWishCount(p.activity_cfgid, p.bless_info.num, p.bless_info.last_time)
end
def.static("table").OnSBlessSuccess = function(p)
  WishingWellData.Instance():SetWishCount(p.activity_cfgid, p.bless_info.num, p.bless_info.last_time)
end
def.static("table").OnSBlessFailed = function(p)
  local text = textRes.WishingWell.SBlessFailed[p.retcode]
  if text then
    Toast(text)
  else
    warn("[WishingWellProtocols:OnSBlessFailed] textRes.WishingWell.SBlessFailed[p.retcode] nil for retcode:", p.retcode)
  end
end
def.static("number").SendCGetBlessInfo = function(type)
  local p = require("netio.protocol.mzm.gsp.bless.CGetBlessInfo").new(type)
  gmodule.network.sendProtocol(p)
end
def.static("number").SendCBless = function(type)
  local p = require("netio.protocol.mzm.gsp.bless.CBless").new(type)
  gmodule.network.sendProtocol(p)
end
WishingWellProtocols.Commit()
return WishingWellProtocols
