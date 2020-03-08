local MODULE_NAME = (...)
local Lplus = require("Lplus")
local BuildHomelandMgr = Lplus.Class(MODULE_NAME)
local HouseMgr = require("Main.Homeland.HouseMgr")
local ItemModule = Lplus.ForwardDeclare("ItemModule")
local CurrencyFactory = require("Main.Currency.CurrencyFactory")
local def = BuildHomelandMgr.define
def.const("table").PayMethod = HouseMgr.PayMethod
def.const("table").CResult = {
  Success = 0,
  CurrencyNotEnough = 1,
  DeedNotEnough = 2
}
local instance
def.static("=>", BuildHomelandMgr).Instance = function(self)
  if instance == nil then
    instance = BuildHomelandMgr()
    instance:Init()
  end
  return instance
end
def.method().Init = function(self)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.homeland.SCreateHomelandRes", BuildHomelandMgr.OnSCreateHomelandRes)
end
def.method("=>", "table").GetBuildHomeNeeds = function(self, payMethod)
  return HouseMgr.Instance():GetBuildHouseNeeds()
end
def.method("=>", "number").BuildHomeUseCurrency = function(self)
  print("BuildHomeUseCurrency")
  local needs = self:GetBuildHomeNeeds()
  local needCurrency = needs.currency
  local currency = CurrencyFactory.Create(needCurrency.currencyType)
  local haveNum = currency:GetHaveNum()
  if haveNum < needCurrency.number then
    currency:AcquireWithQuery()
    return BuildHomelandMgr.CResult.CurrencyNotEnough
  end
  self:CCreateHomelandReq(BuildHomelandMgr.PayMethod.Currency)
  return BuildHomelandMgr.CResult.Success
end
def.method("=>", "number").BuildHomeUseDeed = function(self)
  print("BuildHomeUseDeed")
  if not self:IsDeedEnough() then
    return BuildHomelandMgr.CResult.DeedNotEnough
  end
  self:CCreateHomelandReq(BuildHomelandMgr.PayMethod.Deed)
  return BuildHomelandMgr.CResult.Success
end
def.method("=>", "boolean").IsDeedEnough = function(self)
  local needs = self:GetBuildHomeNeeds()
  local needNum = needs.item.number
  local itemId = needs.item.itemId
  local haveNum = ItemModule.Instance():GetItemCountById(itemId)
  if needNum > haveNum then
    return false
  else
    return true
  end
end
def.method("number").CCreateHomelandReq = function(self, createType)
  print("CCreateHomelandReq createType=", createType)
  local p = require("netio.protocol.mzm.gsp.homeland.CCreateHomelandReq").new(createType)
  gmodule.network.sendProtocol(p)
end
def.static("table").OnSCreateHomelandRes = function(p)
  Toast(textRes.Homeland[23])
  Event.DispatchEvent(ModuleId.HOMELAND, gmodule.notifyId.Homeland.Build_Homeland_Success, nil)
  local effectId = _G.constant.CHomelandCfgConsts.CREATE_HOME_EFFECT_ID or 0
  local effectCfg = _G.GetEffectRes(effectId)
  if effectCfg then
    local resPath = effectCfg.path
    require("Fx.GUIFxMan").Instance():Play(resPath, "Build_Homeland_Success", 0, 0, -1, false)
  end
  SafeLuckDog(function()
    return true
  end)
end
return BuildHomelandMgr.Commit()
