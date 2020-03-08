local MODULE_NAME = (...)
local Lplus = require("Lplus")
local Protocols = Lplus.Class(MODULE_NAME)
local instance
local def = Protocols.define
local txtConst = textRes.WelcomeParty
def.static("=>", Protocols).Instance = function()
  if instance == nil then
    instance = Protocols()
  end
  return instance
end
def.method().Init = function(self)
  local Cls = Protocols
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.legoushangcheng.SGetBuyInfoRsp", Cls.OnQueryBuyInfoRes)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.legoushangcheng.SBuyGoodsSuccess", Cls.OnBuyTescoGoodsSuccess)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.legoushangcheng.SBuyGoodsError", Cls.OnBuyTescoGoodsFailed)
end
def.static().SendQueryBuyInfoReq = function()
  local p = require("netio.protocol.mzm.gsp.legoushangcheng.CGetBuyInfoReq").new()
  gmodule.network.sendProtocol(p)
end
def.static("number").SendBuyTescoGoodsReq = function(cfgId)
  local p = require("netio.protocol.mzm.gsp.legoushangcheng.CBuyGoodsReq").new(cfgId)
  gmodule.network.sendProtocol(p)
end
def.static("table").OnQueryBuyInfoRes = function(p)
  Event.DispatchEvent(ModuleId.WELCOME_PARTY, gmodule.notifyId.WelcomeParty.QueryBuyInfoRes, p.cfgId2buyCount)
end
def.static("table").OnBuyTescoGoodsSuccess = function(p)
  Event.DispatchEvent(ModuleId.WELCOME_PARTY, gmodule.notifyId.WelcomeParty.BuyGoodsSuccess, p)
end
def.static("table").OnBuyTescoGoodsFailed = function(p)
  local ERROR_CODE = require("netio.protocol.mzm.gsp.legoushangcheng.SBuyGoodsError")
  if ERROR_CODE.BUY_COUNT_ERROR == p.errorCode then
    Toast(txtConst[4])
  elseif ERROR_CODE.MONEY_NOT_ENOUGH == p.errorCode then
    Event.DispatchEvent(ModuleId.WELCOME_PARTY, gmodule.notifyId.WelcomeParty.BuyGoodsFailed, {type = 2})
  elseif ERROR_CODE.BAG_IS_FULL == p.errorCode then
    Toast(txtConst[5])
  end
end
return Protocols.Commit()
