local Lplus = require("Lplus")
local ChildrenFashionMgr = Lplus.Class("ChildrenFashionMgr")
local ChildrenDataMgr = require("Main.Children.ChildrenDataMgr")
local ChildrenUtils = require("Main.Children.ChildrenUtils")
local def = ChildrenFashionMgr.define
local instance
def.static("=>", ChildrenFashionMgr).Instance = function()
  if instance == nil then
    instance = ChildrenFashionMgr()
  end
  return instance
end
def.field("table").m_fashions = nil
def.method().Init = function(self)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.Children.SSyncFashionInfo", ChildrenFashionMgr.OnSSyncFashionInfo)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.Children.SBuyFashionSuccess", ChildrenFashionMgr.OnSBuyFashionSuccess)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.Children.SBuyFashionFailed", ChildrenFashionMgr.OnSBuyFashionFailed)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.Children.SSyncRemoveFashionInfo", ChildrenFashionMgr.OnSSyncRemoveFashionInfo)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.Children.SWearFashionSuccess", ChildrenFashionMgr.OnSWearFashionSuccess)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.Children.SWearFashionFailed", ChildrenFashionMgr.OnSWearFashionFailed)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.Children.SUndressFashionSuccess", ChildrenFashionMgr.OnSUndressFashionSuccess)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.Children.SUndressFashionFailed", ChildrenFashionMgr.OnSUndressFashionFailed)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.Children.SRenewalFashionRsp", ChildrenFashionMgr.OnSExtendFashionTimeRsp)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.Children.SRenewalFashionError", ChildrenFashionMgr.OnSExtendFashionTimeError)
end
def.method().Reset = function(self)
  self.m_fashions = nil
end
def.static("table").OnSSyncFashionInfo = function(p)
  local self = ChildrenFashionMgr.Instance()
  if self.m_fashions == nil then
    self.m_fashions = {}
  end
  for k, v in pairs(p.fashions) do
    local fashion = {}
    fashion.startTime = v.start_time
    self.m_fashions[k] = fashion
  end
end
def.static("table").OnSSyncRemoveFashionInfo = function(p)
  local self = ChildrenFashionMgr.Instance()
  if self.m_fashions == nil then
    return
  end
  self.m_fashions[p.fashion_cfgid] = nil
  Event.DispatchEvent(ModuleId.CHILDREN, gmodule.notifyId.Children.Fashion_Update, nil)
  local fashionCfg = ChildrenUtils.GetChildrenFashionCfg(p.fashion_cfgid)
  Toast(string.format(textRes.Children[5005], fashionCfg.name))
end
def.static("table").OnSBuyFashionSuccess = function(p)
  local self = ChildrenFashionMgr.Instance()
  local fashion = {}
  fashion.startTime = p.fashion_info.start_time
  if self.m_fashions == nil then
    self.m_fashions = {}
  end
  self.m_fashions[p.fashion_cfgid] = fashion
  Event.DispatchEvent(ModuleId.CHILDREN, gmodule.notifyId.Children.Fashion_Update, nil)
  local fashionCfg = ChildrenUtils.GetChildrenFashionCfg(p.fashion_cfgid)
  Toast(string.format(textRes.Children[5004], fashionCfg.name))
end
def.static("table").OnSBuyFashionFailed = function(p)
  local tipStr = textRes.Children.BuyFashionError[p.retcode]
  if tipStr then
    Toast(tipStr)
  end
end
def.static("table").OnSWearFashionSuccess = function(p)
  local child = ChildrenDataMgr.Instance():GetChildById(p.childid)
  if child then
    local fashionCfg = ChildrenUtils.GetChildrenFashionCfg(p.dressed_info.fashion_cfgid)
    child:SetFashion(fashionCfg.phase, p.dressed_info)
    Event.DispatchEvent(ModuleId.CHILDREN, gmodule.notifyId.Children.Fashion_Change, {
      p.childid,
      fashionCfg.phase
    })
    Toast(string.format(textRes.Children[5006], child:GetName(), fashionCfg.name))
  end
end
def.static("table").OnSWearFashionFailed = function(p)
  local tipStr = textRes.Children.WearFashionError[p.retcode]
  if tipStr then
    Toast(tipStr)
  end
end
def.static("table").OnSUndressFashionSuccess = function(p)
  local child = ChildrenDataMgr.Instance():GetChildById(p.childid)
  if child then
    local fashionCfg = ChildrenUtils.GetChildrenFashionCfg(p.fashion_cfgid)
    child:SetFashion(fashionCfg.phase, nil)
    Event.DispatchEvent(ModuleId.CHILDREN, gmodule.notifyId.Children.Fashion_Change, {
      p.childid,
      fashionCfg.phase
    })
    Toast(string.format(textRes.Children[5007], child:GetName(), fashionCfg.name))
  end
end
def.static("table").OnSUndressFashionFailed = function(p)
  local tipStr = textRes.Children.UndressFashionError[p.retcode]
  if tipStr then
    Toast(tipStr)
  end
end
def.static("number", "number", "number").CSendExtendFashionReq = function(bagId, itemKey, fashionCfgId)
  local p = require("netio.protocol.mzm.gsp.Children.CRenewalFashionReq").new(bagId, itemKey, fashionCfgId)
  gmodule.network.sendProtocol(p)
end
def.static("table").OnSExtendFashionTimeRsp = function(p)
  if instance.m_fashions[p.fashionCfgId] ~= nil then
    instance.m_fashions[p.fashionCfgId].startTime = p.fashionInfo.start_time
  end
  local fashionCfg = ChildrenUtils.GetChildrenFashionCfg(p.fashionCfgId)
  Toast(textRes.Children[5014]:format(fashionCfg.name))
  Event.DispatchEvent(ModuleId.CHILDREN, gmodule.notifyId.Children.Fashion_TimeChg, {
    p.fashionCfgId
  })
end
def.static("table").OnSExtendFashionTimeError = function(p)
  local ERROR_CODE = require("netio.protocol.mzm.gsp.Children.SRenewalFashionError")
  if p.errorCode == ERROR_CODE.ITEM_NOT_EXIST then
    Toast(textRes.Children[5010])
  elseif p.errorCode == ERROR_CODE.FASHION_NOT_EXIST then
    warn("[ERROR: Fashion not exist]")
  elseif p.errorCode == ERROR_CODE.TYPE_NOT_MATCH then
    warn("[ERROR: Type not match]")
  elseif p.errorCode == ERROR_CODE.NEVER_EXPIRE then
    Toast(textRes.Children[5011])
  end
end
def.static("=>", "boolean").IsExtendTimeOpen = function()
  local bOpen = IsFeatureOpen(require("netio.protocol.mzm.gsp.open.ModuleFunSwitchInfo").TYPE_CHILD_FASHION_RENEWAL)
  return bOpen
end
def.method("number").UnlockFashion = function(self, fashionId)
  if not IsFeatureOpen(require("netio.protocol.mzm.gsp.open.ModuleFunSwitchInfo").TYPE_CHILD_FASHION) then
    return
  end
  gmodule.network.sendProtocol(require("netio.protocol.mzm.gsp.children.CBuyFashion").new(fashionId))
end
def.method("userdata", "number").DressFashion = function(self, cid, fashionId)
  if not IsFeatureOpen(require("netio.protocol.mzm.gsp.open.ModuleFunSwitchInfo").TYPE_CHILD_FASHION) then
    return
  end
  gmodule.network.sendProtocol(require("netio.protocol.mzm.gsp.children.CWearFashion").new(cid, fashionId))
end
def.method("userdata", "number").UndressFashion = function(self, cid, fashionId)
  if not IsFeatureOpen(require("netio.protocol.mzm.gsp.open.ModuleFunSwitchInfo").TYPE_CHILD_FASHION) then
    return
  end
  gmodule.network.sendProtocol(require("netio.protocol.mzm.gsp.children.CUndressFashion").new(cid, fashionId))
end
def.method("number", "number", "=>", "table").GetFashionsByPeriodAndGender = function(self, period, gender)
  local SGenderEnum = require("consts.mzm.gsp.occupation.confbean.SGenderEnum")
  local allFashions = ChildrenUtils.GetAllChildrenFashion()
  local fashions = {}
  for k, v in ipairs(allFashions) do
    if v.phase == period and (v.gender == SGenderEnum.ALL or v.gender == gender) then
      table.insert(fashions, v.id)
    end
  end
  return fashions
end
def.method("number", "=>", "table").GetFashionInfo = function(self, fashionId)
  if self.m_fashions then
    return self.m_fashions[fashionId]
  else
    return nil
  end
end
def.method("number", "=>", "boolean").IsUnlock = function(self, fashionId)
  if self.m_fashions then
    return self.m_fashions[fashionId] ~= nil
  else
    return false
  end
end
ChildrenFashionMgr.Commit()
return ChildrenFashionMgr
