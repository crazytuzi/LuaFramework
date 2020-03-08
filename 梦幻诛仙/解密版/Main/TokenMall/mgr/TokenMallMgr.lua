local Lplus = require("Lplus")
local TokenMallMgr = Lplus.Class("TokenMallMgr")
local TokenMallUtils = require("Main.TokenMall.TokenMallUtils")
local TokenMallData = require("Main.TokenMall.data.TokenMallData")
local TokenMallDataMgr = require("Main.TokenMall.mgr.TokenMallDataMgr")
local ModuleFunSwitchInfo = require("netio.protocol.mzm.gsp.open.ModuleFunSwitchInfo")
local def = TokenMallMgr.define
def.field("table").queryMallCallback = nil
local instance
def.static("=>", TokenMallMgr).Instance = function()
  if instance == nil then
    instance = TokenMallMgr()
  end
  return instance
end
def.method().Init = function(self)
  self.queryMallCallback = {}
  TokenMallDataMgr.Instance():Init()
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.activitypointexchange.SMallInfoRsp", TokenMallMgr.OnSMallInfoRsp)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.activitypointexchange.SMallInfoError", TokenMallMgr.OnSMallInfoError)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.activitypointexchange.SPointExchangeRsp", TokenMallMgr.OnSPointExchangeRsp)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.activitypointexchange.SPointExchangeError", TokenMallMgr.OnSPointExchangeError)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.activitypointexchange.SExchangeCountInfoRsp", TokenMallMgr.OnSExchangeCountInfoRsp)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.activitypointexchange.SManualRefreshRsp", TokenMallMgr.OnSManualRefreshRsp)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.activitypointexchange.SManualRefreshError", TokenMallMgr.OnSManualRefreshError)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.activitypointexchange.SManualRefreshCountInfoRsp", TokenMallMgr.OnSManualRefreshCountInfoRsp)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.activitypointexchange.SSoldOutInfoRsp", TokenMallMgr.OnSSoldOutInfoRsp)
end
def.method().Clear = function(self)
  self.queryMallCallback = {}
  TokenMallDataMgr.Instance():Clear()
end
def.static("table").OnSMallInfoRsp = function(p)
  TokenMallMgr.Instance():ReceiveTokenMallInfo(p)
end
def.static("table").OnSMallInfoError = function(p)
  if textRes.TokenMall.SMallInfoError[p.errorCode] then
    Toast(textRes.TokenMall.SMallInfoError[p.errorCode])
  else
    Toast(string.format(textRes.TokenMall.SMallInfoError[-1], p.errorCode))
  end
end
def.static("table").OnSPointExchangeRsp = function(p)
  local mallData = TokenMallDataMgr.Instance():GetTokenMallData(p.activityPointExchangeMallCfgId)
  if mallData then
    mallData:SetItemCanBuyCount(p.goodsCfgId, p.available)
  end
  local params = {}
  params.activityId = p.activityId
  params.mallCfgId = p.activityPointExchangeMallCfgId
  Event.DispatchEvent(ModuleId.TOKEN_MALL, gmodule.notifyId.TokenMall.MALL_INFO_DATA_CHANGE, params)
end
def.static("table").OnSPointExchangeError = function(p)
  if textRes.TokenMall.SPointExchangeError[p.errorCode] then
    Toast(textRes.TokenMall.SPointExchangeError[p.errorCode])
  else
    Toast(string.format(textRes.TokenMall.SPointExchangeError[-1], p.errorCode))
  end
end
def.static("table").OnSExchangeCountInfoRsp = function(p)
  local mallData = TokenMallDataMgr.Instance():GetTokenMallData(p.activityPointExchangeMallCfgId)
  if mallData then
    mallData:UpdateMallExchangeData(p.exchangeCountInfo)
  end
  local params = {}
  params.activityId = p.activityId
  params.mallCfgId = p.activityPointExchangeMallCfgId
  Event.DispatchEvent(ModuleId.TOKEN_MALL, gmodule.notifyId.TokenMall.MALL_INFO_DATA_CHANGE, params)
end
def.static("table").OnSManualRefreshRsp = function(p)
  TokenMallMgr.Instance():ReceiveTokenMallInfo(p)
  local params = {}
  params.activityId = p.activityId
  params.mallCfgId = p.activityPointExchangeMallCfgId
  Event.DispatchEvent(ModuleId.TOKEN_MALL, gmodule.notifyId.TokenMall.MALL_INFO_DATA_CHANGE, params)
end
def.static("table").OnSManualRefreshError = function(p)
  if textRes.TokenMall.SManualRefreshError[p.errorCode] then
    Toast(textRes.TokenMall.SManualRefreshError[p.errorCode])
  else
    Toast(string.format(textRes.TokenMall.SManualRefreshError[-1], p.errorCode))
  end
end
def.static("table").OnSManualRefreshCountInfoRsp = function(p)
  local mallData = TokenMallDataMgr.Instance():GetTokenMallData(p.activityPointExchangeMallCfgId)
  if mallData then
    mallData:UpdateMallManualRefreshData(p.manualRefreshCountInfo)
  end
  local params = {}
  params.activityId = p.activityId
  params.mallCfgId = p.activityPointExchangeMallCfgId
  Event.DispatchEvent(ModuleId.TOKEN_MALL, gmodule.notifyId.TokenMall.MALL_INFO_DATA_CHANGE, params)
end
def.static("table").OnSSoldOutInfoRsp = function(p)
  local mallData = TokenMallDataMgr.Instance():GetTokenMallData(p.activityPointExchangeMallCfgId)
  if mallData then
    mallData:UpdateBannedItems(p.soldOutInfo)
  end
  local params = {}
  params.activityId = p.activityId
  params.mallCfgId = p.activityPointExchangeMallCfgId
  Event.DispatchEvent(ModuleId.TOKEN_MALL, gmodule.notifyId.TokenMall.MALL_INFO_DATA_CHANGE, params)
end
def.method("number", "function").QueryTokenMallInfo = function(self, activityId, cb)
  self.queryMallCallback[activityId] = self.queryMallCallback[activityId] or {}
  if cb ~= nil then
    table.insert(self.queryMallCallback[activityId], cb)
  end
  local req = require("netio.protocol.mzm.gsp.activitypointexchange.CMallInfoReq").new(activityId)
  gmodule.network.sendProtocol(req)
end
def.method("table").ReceiveTokenMallInfo = function(self, data)
  local activityId = data.activityId
  local mallCfgId = data.activityPointExchangeMallCfgId
  local mallData = data.mallInfo
  local tokenMallData = TokenMallDataMgr.Instance():GetTokenMallData(mallCfgId)
  if tokenMallData == nil then
    tokenMallData = TokenMallData()
    TokenMallDataMgr.Instance():SetTokenMallData(mallCfgId, tokenMallData)
  end
  tokenMallData:RawSet(mallData)
  tokenMallData:SetRelatedActivityId(activityId)
  tokenMallData:SetTokenMallCfgId(mallCfgId)
  local callbacks = self.queryMallCallback[activityId]
  if callbacks ~= nil then
    for i = #callbacks, 1, -1 do
      callbacks[i](tokenMallData)
    end
  end
  self.queryMallCallback[activityId] = nil
end
def.method("number").OpenTokenMallByActivityId = function(self, activityId)
  if not self:CheckIsTokenMallOpenAndToast(activityId) then
    return
  end
  self:QueryTokenMallInfo(activityId, function(data)
    require("Main.TokenMall.ui.TokenMallPanel").Instance():ShowTokenMallPanel(data.tokenMallCfgId)
  end)
end
def.method("number", "number", "number").ExchangeItem = function(self, activityId, itemCfgId, count)
  local req = require("netio.protocol.mzm.gsp.activitypointexchange.CPointExchangeReq").new(activityId, itemCfgId, count)
  gmodule.network.sendProtocol(req)
end
def.method("number", "number").ManualRefreshMallInfo = function(self, activityId, count)
  local ItemModule = require("Main.Item.ItemModule")
  local yuanBaoNum = ItemModule.Instance():GetAllYuanBao()
  local req = require("netio.protocol.mzm.gsp.activitypointexchange.CManualRefreshReq").new(activityId, count, yuanBaoNum)
  gmodule.network.sendProtocol(req)
end
def.method("number").QueryMallManualRefreshInfo = function(self, activityId)
  local req = require("netio.protocol.mzm.gsp.activitypointexchange.CManualRefreshCountInfoReq").new(activityId)
  gmodule.network.sendProtocol(req)
end
def.method("number", "=>", "boolean").IsTokenMallOpen = function(self, activityId)
  local isMallOpen = _G.IsFeatureOpen(ModuleFunSwitchInfo.TYPE_ACTIVITY_POINT_EXCHANGE)
  if not isMallOpen then
    return false
  end
  local cfg = TokenMallUtils.GetActivityTokenMallCfg(activityId)
  if cfg == nil then
    return false
  end
  local isActivityMallOpen = _G.IsFeatureOpen(cfg.activitySwitchId)
  if not isActivityMallOpen then
    return false
  end
  return true
end
def.method("number", "=>", "boolean").CheckIsTokenMallOpenAndToast = function(self, activityId)
  local isMallOpen = _G.IsFeatureOpen(ModuleFunSwitchInfo.TYPE_ACTIVITY_POINT_EXCHANGE)
  if not isMallOpen then
    Toast(textRes.TokenMall[1])
    return false
  end
  local cfg = TokenMallUtils.GetActivityTokenMallCfg(activityId)
  if cfg == nil then
    Toast(textRes.TokenMall[2])
    return false
  end
  local isActivityMallOpen = _G.IsFeatureOpen(cfg.activitySwitchId)
  if not isActivityMallOpen then
    Toast(textRes.TokenMall[3])
    return false
  end
  return true
end
return TokenMallMgr.Commit()
