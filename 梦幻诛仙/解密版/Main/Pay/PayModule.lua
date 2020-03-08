local ModuleBase = require("Main.module.ModuleBase")
local Lplus = require("Lplus")
local PayModule = Lplus.Extend(ModuleBase, "PayModule")
local Octets = require("netio.Octets")
local PayNode = require("Main.Pay.ui.PayNode")
local PayData = require("Main.Pay.PayData")
local ProductServiceType = require("consts.mzm.gsp.qingfu.confbean.ProductServiceType")
local ECMSDK = require("ProxySDK.ECMSDK")
local ECUniSDK = require("ProxySDK.ECUniSDK")
local instance
local def = PayModule.define
def.const("boolean").PAYON = true
def.const("number").DATADIRECTION = 4
def.field("table").m_PayData = nil
def.field("number").auTimer = 0
def.field("string").payTag = ""
def.field("function").applyOrderCallback = nil
def.field("number").lastPayPrice = 0
def.static("=>", PayModule).Instance = function()
  if not instance then
    instance = PayModule()
    instance.m_moduleId = ModuleId.PAY
  end
  return instance
end
def.override().Init = function(self)
  local sdktype = ClientCfg.GetSDKType()
  if sdktype == ClientCfg.SDKTYPE.MSDK then
    ECMSDK.SetMarketInfoCallback(PayModule.onMarketInfo)
  elseif sdktype == ClientCfg.SDKTYPE.UNISDK then
  end
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.qingfu.SSyncSaveAmtActivityInfo", PayModule.OnSSyncSaveAmtActivityInfo)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.qingfu.SGetSaveAmtActivityAwardSuccess", PayModule.OnSGetSaveAmtActivityAwardSuccess)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.qingfu.SGetSaveAmtActivityAwardFailed", PayModule.OnSGetSaveAmtActivityAwardFailed)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.qingfu.SApplyOrderIDRep", PayModule.OnApplyOrderId)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.qingfu.SDelFailureOrderRep", PayModule.OnDelOrderId)
  Event.RegisterEvent(ModuleId.LOGIN, gmodule.notifyId.Login.ENTER_WORLD, PayModule.onEnterWorld)
  Event.RegisterEvent(ModuleId.LOGIN, gmodule.notifyId.Login.LEAVE_WORLD, function()
    self:Reset()
  end)
  ModuleBase.Init(self)
end
def.override().OnReset = function(self)
  PayData.Instance():Init()
  GameUtil.RemoveGlobalTimer(instance.auTimer)
  self.payTag = ""
end
def.static("table", "table").onEnterWorld = function(p1, p2)
  PayData.Instance():Init()
  PayModule.PullPayData()
  PayModule.Instance():RefreshCoinInfo()
end
def.static().PullPayData = function()
  warn("PullPayData")
  local sdktype = ClientCfg.GetSDKType()
  if sdktype == ClientCfg.SDKTYPE.MSDK then
    ECMSDK.Instance()
    ECMSDK.GetMarketInfo()
    warn("MSDK GetMarketInfo")
  elseif sdktype == ClientCfg.SDKTYPE.UNISDK then
  end
end
def.static("string").onMarketInfo = function(jsonData)
  PayData.Instance():SetPayData(jsonData)
  if PayNode.Instance().isShow and PayNode.Instance().m_node and not PayNode.Instance().m_node.isnil then
    PayNode.Instance():UpdateInfo()
  end
end
def.static("table").OnFakePaySuccess = function(p)
  local retCode = p.retcode
  local cfgId = p.cfgId
  local gameOrderId = p.gameOrderId
  local orderCallbackURL = p.orderCallbackURL
  local ext = p.ext
  warn("OnFakePaySuccess:", p.retcode)
  if p.retcode == 0 then
    PayModule.onPay()
  end
  local payData = PayModule.Instance():GetPayTLogData()
  if payData then
    local params = {}
    local status = retCode == MSDK_PAY_CODE.PAY_SUCCESS and 1 or 2
    if payData.payParams.amount then
      params = {
        payData.payParams.amount,
        status
      }
    else
      params = {status}
    end
    ECMSDK.SendTLogToServer(payData.payType, params)
    PayModule.Instance():SetPayTLogData(_G.TLOGTYPE.NON, {})
  end
end
def.static("table").OnSSyncSaveAmtActivityInfo = function(p)
  PayNode.Instance():setSaveAmtInfo(p)
end
def.static("table").OnSGetSaveAmtActivityAwardSuccess = function(p)
  warn("OnSGetSaveAmtActivityAwardSuccess")
  PayNode.Instance():updateSaveAmtInfo(p)
end
def.static("table").OnSGetSaveAmtActivityAwardFailed = function(p)
  warn("OnSGetSaveAmtActivityAwardFailed:" .. p.retcode)
  if p.retcode == require("netio.protocol.mzm.gsp.qingfu.SGetSaveAmtActivityAwardFailed").ERROR_ACTVITY_NOT_OPEN then
    Toast(textRes.Pay[101])
  elseif p.retcode == require("netio.protocol.mzm.gsp.qingfu.SGetSaveAmtActivityAwardFailed").ERROR_NOT_PURCHASE_FUND then
    Toast(textRes.Pay[102])
  elseif p.retcode == require("netio.protocol.mzm.gsp.qingfu.SGetSaveAmtActivityAwardFailed").ERROR_ALREADY_GET_AWARD then
    Toast(textRes.Pay[103])
  end
end
def.static("table").OnApplyOrderId = function(p)
  local self = PayModule.Instance()
  warn("OnApplyOrderId", p.retcode)
  if p.retcode ~= 0 then
    return
  end
  if platform == 0 then
    PayModule.OnFakePaySuccess(p)
    return
  end
  if self.applyOrderCallback then
    local cfgId = p.cfgId
    local orderId = GetStringFromOcts(p.gameOrderId) or ""
    local url = GetStringFromOcts(p.orderCallbackURL) or ""
    self.applyOrderCallback(cfgId, orderId, url)
    self.applyOrderCallback = nil
  end
end
def.static("table").OnDelOrderId = function(p)
  if p.retcode ~= 0 then
    return
  end
  if platform == 0 then
    return
  end
  local orderId = GetStringFromOcts(p.gameOrderId)
  warn("Delete OrderId", orderId)
end
def.static().onPay = function()
  Event.DispatchEvent(ModuleId.PAY, gmodule.notifyId.Pay.PaySuccess, {
    PayModule.Instance().payTag
  })
  PayModule.Instance().payTag = ""
  Toast(textRes.Pay[1])
  warn("Pay Success, Please Check you wallet")
  local sdktype = ClientCfg.GetSDKType()
  if sdktype == ClientCfg.SDKTYPE.MSDK or sdktype == ClientCfg.SDKTYPE.NON then
    GameUtil.RemoveGlobalTimer(instance.auTimer)
    instance.auTimer = GameUtil.AddGlobalTimer(5, true, function()
      local LoginUtility = require("Main.Login.LoginUtility")
      local appid = ECMSDK.GetCombineAppID()
      LoginUtility.DataToAuany(PayModule.DATADIRECTION, 50, {appid = appid}, 0, Octets.raw())
    end)
  end
end
def.static("table").onUniPay = function(params)
  if params.flag == "0" then
    if PayModule.Instance().lastPayPrice > 0 then
      TraceHelper.trace("IAPFinished", {
        price = PayModule.Instance().lastPayPrice
      })
      PayModule.Instance().lastPayPrice = 0
    end
    Event.DispatchEvent(ModuleId.PAY, gmodule.notifyId.Pay.PaySuccess, {
      PayModule.Instance().payTag
    })
    PayModule.Instance().payTag = ""
    Toast(textRes.Pay[1])
    warn("Pay Success, Please Check you wallet")
  else
    if PayModule.Instance().lastPayPrice > 0 then
      TraceHelper.trace("IAPCancelled", {
        price = PayModule.Instance().lastPayPrice
      })
      PayModule.Instance().lastPayPrice = 0
    end
    warn("Pay Fail", params.flag)
    Toast(textRes.Pay[9])
  end
end
def.static("=>", "number", "table").GetPayData = function()
  return PayData.Instance():GetPayDataVer(), PayData.Instance():GetPayData()
end
def.static("table", "string").PayWithTag = function(info, tag)
  local loginModule = gmodule.moduleMgr:GetModule(ModuleId.LOGIN)
  local isFakePlatform = loginModule:IsFakeLoginPlatform()
  if isFakePlatform then
    Toast(textRes.Pay[10])
    return
  end
  local suc = PayModule._Pay(info)
  if suc then
    PayModule.Instance().payTag = tag
    Event.DispatchEvent(ModuleId.PAY, gmodule.notifyId.Pay.PayStart, {tag})
  end
end
def.static("table").Pay = function(info)
  PayModule.PayWithTag(info, "")
end
def.static("table", "=>", "boolean")._Pay = function(info)
  if info then
    TraceHelper.trace("IAPIntial", {
      price = info.rmb
    })
    PayModule.Instance().lastPayPrice = info.rmb
    local sdktype = ClientCfg.GetSDKType()
    if sdktype == ClientCfg.SDKTYPE.MSDK then
      local ECMSDK = require("ProxySDK.ECMSDK")
      local params = PayModule.BuildMSDKPayParams(info)
      warn("payParams:", params.payType, " | ", params.durtime, " | ", params.productID, " | ", params.serviceCode, " | ", params.serviceName, " | ", params.autoPay, " | ", params.saveValue)
      ECMSDK.Pay(params, PayModule.onPay)
    elseif sdktype == ClientCfg.SDKTYPE.UNISDK then
      if ECUniSDK.Instance():SDKIS(ECUniSDK.CHANNELTYPE.LOONG) then
        ECUniSDK.Instance():RequestCoinInfo(info.productId)
      end
      do
        local params = PayModule.BuildPayParams(info)
        local appid = ECUniSDK.Instance():GetUniAppId()
        PayModule.Instance():ApplyOrder(appid, info.id, function(cfgId, orderId, callbackUrl)
          warn("Get OrderId", cfgId, orderId, callbackUrl, info.id)
          if cfgId == info.id then
            params.callBackUrl = callbackUrl
            params.remark = orderId
            ECUniSDK.Instance():Pay(params, PayModule.onUniPay)
          end
        end)
      end
    elseif sdktype == ClientCfg.SDKTYPE.NON then
      PayModule.Instance():ApplyOrder("1", info.id, nil)
      warn("PC Fake Pay:", info.id)
    end
    return true
  else
    warn("Bad Pay Data")
    return false
  end
end
def.static("table", "=>", "table").BuildPayParams = function(info)
  local heroProp = require("Main.Hero.Interface"):GetBasicHeroProp()
  local params = {}
  params.productId = tostring(info.productId)
  params.price = tostring(info.rmb)
  params.roleId = tostring(heroProp.id)
  params.zoneId = tostring(require("netio.Network").m_zoneid)
  params.roleLv = tostring(heroProp.level)
  params.roleName = heroProp.name or ""
  params.userId = require("Main.ECGame").Instance().m_UserName or ""
  if platform == Platform.ios then
    params.gankType = "applegank"
  end
  params.remark = ""
  params.productName = info.productName
  params.productDesc = info.productName
  params.balance = info.balance
  return params
end
def.static("table", "=>", "table").BuildMSDKPayParams = function(info)
  local params = {}
  local ECMSDK = require("ProxySDK.ECMSDK")
  params.payType = info.productServiceType ~= ProductServiceType.NONE and ECMSDK.PAYTYPE.MONTH or ECMSDK.PAYTYPE.NORMAL
  if params.payType == ECMSDK.PAYTYPE.NORMAL then
    local numStr = tostring(info.yuanbao)
    params.durtime = numStr
    params.productID = tostring(info.productId)
    params.serviceCode = tostring(info.productServiceId)
    params.serviceName = info.productName
    params.autoPay = false
    params.saveValue = numStr
  else
    params.durtime = tostring(info.productServiceDurationDays)
    params.productID = tostring(info.productId)
    params.serviceCode = tostring(info.productServiceId)
    params.serviceName = info.productName
    params.autoPay = false
    params.saveValue = "1"
  end
  return params
end
def.method("string", "table").SetPayTLogData = function(self, payType, payParams)
  self.m_PayData = {}
  self.m_PayData.payType = payType
  self.m_PayData.payParams = payParams
end
def.method("table").UpdatePayTLogData = function(self, payParams)
  if self.m_PayData then
    self.m_PayData.payParams = payParams
  end
end
def.method("=>", "table").GetPayTLogData = function(self)
  return self.m_PayData
end
def.method("string", "number", "function").ApplyOrder = function(self, appid, cfgId, cb)
  local applyPayOrder = require("netio.protocol.mzm.gsp.qingfu.CApplyOrderIDReq").new(Octets.rawFromString(appid), cfgId, Octets.raw())
  gmodule.network.sendProtocol(applyPayOrder)
  self.applyOrderCallback = cb
end
def.method("string").DelOrder = function(self, orderId)
  local delOrder = require("netio.protocol.mzm.gsp.qingfu.CDelFailureOrderReq").new(Octets.rawFromString(orderId))
  gmodule.network.sendProtocol(delOrder)
end
def.method().RefreshCoinInfo = function()
  if platform == Platform.ios then
    local sdktype = ClientCfg.GetSDKType()
    if sdktype == ClientCfg.SDKTYPE.UNISDK and ECUniSDK.Instance():SDKIS(ECUniSDK.CHANNELTYPE.LOONG) then
      if ECUniSDK.Instance().m_coinInfo and ECUniSDK.Instance().m_coinInfo.productId then
        ECUniSDK.Instance():RequestCoinInfo("")
      else
        local cfgs = PayData.LoadQingFuCfg()
        if cfgs and cfgs[1] then
          ECUniSDK.Instance():RequestCoinInfo(cfgs[1].productId)
        end
      end
    end
  end
end
PayModule.Commit()
return PayModule
