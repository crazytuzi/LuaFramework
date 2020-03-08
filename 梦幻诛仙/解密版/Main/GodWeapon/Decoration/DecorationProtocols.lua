local MODULE_NAME = (...)
local Lplus = require("Lplus")
local DecorationProtocols = Lplus.Class(MODULE_NAME)
local def = DecorationProtocols.define
local instance
local DecorationMgr = Lplus.ForwardDeclare("DecorationMgr")
local DecorationUtils = require("Main.GodWeapon.Decoration.DecorationUtils")
local txtConst = textRes.GodWeapon.Decoration
def.static("=>", DecorationProtocols).Instance = function()
  if instance == nil then
    instance = DecorationProtocols()
  end
  return instance
end
def.method().Init = function(self)
  local Cls = DecorationProtocols
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.superequipment.SUpgradeWuShiSuccess", Cls.OnSUpgradeWSSuccess)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.superequipment.SUseWuShiItemResponse", Cls.OnSUseWSSuccess)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.superequipment.SPutOnWuShiSuccess", Cls.OnSPutOnWSSuccess)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.superequipment.SPutOffWuShiSuccess", Cls.OnSPutOffWSSuccess)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.superequipment.SSynWuShiInfo", Cls.OnSSynWSInfo)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.superequipment.SWuShiError", Cls.OnSErrorInfo)
end
def.static("number", "number", "boolean").CSendUpgradeWSReq = function(WSCfgId, itemId, bUseAll)
  local CUpgradeWuShi = require("netio.protocol.mzm.gsp.superequipment.CUpgradeWuShi")
  local p
  if bUseAll then
    p = CUpgradeWuShi.new(itemId, WSCfgId, CUpgradeWuShi.consume_all)
  else
    p = CUpgradeWuShi.new(itemId, WSCfgId, CUpgradeWuShi.consume_one)
  end
  gmodule.network.sendProtocol(p)
end
def.static("number", "number").CSendUseWSItemReq = function(bagId, itemKey)
  local p = require("netio.protocol.mzm.gsp.superequipment.CUseWuShiItem").new(bagId, itemKey)
  gmodule.network.sendProtocol(p)
end
def.static("number").CPutOnWSReq = function(itemId)
  local p = require("netio.protocol.mzm.gsp.superequipment.CPutOnWuShi").new(itemId)
  gmodule.network.sendProtocol(p)
end
def.static().CPutOffWSReq = function()
  local p = require("netio.protocol.mzm.gsp.superequipment.CPutOffWuShi").new()
  gmodule.network.sendProtocol(p)
end
local WuShiInfo = require("netio.protocol.mzm.gsp.superequipment.WuShiInfo")
def.static("table").OnSUpgradeWSSuccess = function(p)
  local data = DecorationMgr.GetData()
  local owndWSInfo = data:GetOwndWSInfoByCfgId(p.lastWuShiCfgId)
  local heroProp = _G.GetHeroProp()
  if owndWSInfo ~= nil and p.wuShiCfgId == p.lastWuShiCfgId then
    owndWSInfo.fragmentCount = p.fragmentCount
    local preIsActive = owndWSInfo.isActivate
    owndWSInfo.isActivate = p.isActivate
    if owndWSInfo.isActivate == WuShiInfo.ACTIVATE and preIsActive ~= owndWSInfo.isActivate then
      require("Main.GodWeapon.ui.UIGetOrUpgradeHint").Instance():ShowPanelGet(owndWSInfo)
    end
    Event.DispatchEvent(ModuleId.GOD_WEAPON, gmodule.notifyId.GodWeapon.WUSHI_USE_FRAGMENTS_SUCCESS, p)
  elseif owndWSInfo ~= nil then
    local preWSBasicCfg = DecorationUtils.GetWSBasicCfgById(p.lastWuShiCfgId)
    local curWSBasicCfg = DecorationUtils.GetWSBasicCfgById(p.wuShiCfgId)
    curWSBasicCfg.wuShiCfgId = p.wuShiCfgId
    curWSBasicCfg.isOn = owndWSInfo.isOn
    curWSBasicCfg.isActivate = p.isActivate
    curWSBasicCfg.fragmentCount = p.fragmentCount
    data:UpdateOwndWSInfo(p.lastWuShiCfgId, curWSBasicCfg)
    local preWSDisplayCfg = data:GetDisplayCfg(preWSBasicCfg.displayTypeId, heroProp.occupation, heroProp.gender)
    local curWSDisplayCfg = data:GetDisplayCfg(curWSBasicCfg.displayTypeId, heroProp.occupation, heroProp.gender)
    if preWSDisplayCfg.equipModelId ~= curWSDisplayCfg.equipModelId then
      local WSInfo = {
        cur = {
          modelId = curWSDisplayCfg.equipModelId,
          wuShiCfgId = p.wuShiCfgId,
          basicCfg = curWSBasicCfg
        },
        pre = {
          modelId = preWSDisplayCfg.equipModelId,
          wuShiCfgId = p.lastWuShiCfgId,
          basicCfg = preWSBasicCfg
        }
      }
      require("Main.GodWeapon.ui.UIGetOrUpgradeHint").Instance():ShowPanelUpgrade(WSInfo)
    elseif preIsActive == WuShiInfo.NOT_ACTIVATE then
    else
      Toast(txtConst[15]:format(curWSBasicCfg.name, curWSBasicCfg.level))
    end
    Event.DispatchEvent(ModuleId.GOD_WEAPON, gmodule.notifyId.GodWeapon.WUSHI_LEVEL_UP_SUCCESS, p)
  else
    local WSBasicCfg = DecorationUtils.GetWSBasicCfgById(p.wuShiCfgId)
    WSBasicCfg.wuShiCfgId = p.wuShiCfgId
    WSBasicCfg.isOn = false
    WSBasicCfg.isActivate = p.isActivate
    WSBasicCfg.fragmentCount = p.fragmentCount
    data:AddOwndWS(WSBasicCfg)
    data:UpdateWSInfoList()
    if WSBasicCfg.isActivate == WuShiInfo.ACTIVATE then
      require("Main.GodWeapon.ui.UIGetOrUpgradeHint").Instance():ShowPanelGet(WSBasicCfg)
    end
    Event.DispatchEvent(ModuleId.GOD_WEAPON, gmodule.notifyId.GodWeapon.WUSHI_USE_FRAGMENTS_SUCCESS, p)
  end
end
local SUseWuShiItemResponse = require("netio.protocol.mzm.gsp.superequipment.SUseWuShiItemResponse")
def.static("table").OnSUseWSSuccess = function(p)
  if p.opt == SUseWuShiItemResponse.SHOW_WU_SHI then
    local UIGodWeaponBasic = require("Main.GodWeapon.ui.UIGodWeaponBasic")
    UIGodWeaponBasic.Instance():ShowWithParams(UIGodWeaponBasic.NodeId.Decoration, {
      cfgId = p.wuShiCfgId
    })
  else
    local data = DecorationMgr.GetData()
    local WSBasicCfg = DecorationUtils.GetWSBasicCfgById(p.wuShiCfgId)
    if WSBasicCfg ~= nil then
      WSBasicCfg.wuShiCfgId = p.wuShiCfgId
      WSBasicCfg.isOn = WuShiInfo.OFF
      WSBasicCfg.isActivate = WuShiInfo.ACTIVATE
      WSBasicCfg.fragmentCount = 0
      data:AddOwndWS(WSBasicCfg)
      data:UpdateWSInfoList()
    end
    require("Main.GodWeapon.ui.UIGetOrUpgradeHint").Instance():ShowPanelGet(p)
  end
end
def.static("table").OnSPutOnWSSuccess = function(p)
  DecorationMgr.GetData():PutOnWS(p.wuShiCfgId)
  local WSBasicCfg = DecorationUtils.GetWSBasicCfgById(p.wuShiCfgId)
  if WSBasicCfg ~= nil then
    Toast(txtConst[17]:format(WSBasicCfg.name))
  end
  Event.DispatchEvent(ModuleId.GOD_WEAPON, gmodule.notifyId.GodWeapon.WS_PUTON_CHANGE, p)
end
def.static("table").OnSPutOffWSSuccess = function(p)
  local wsCfg = DecorationMgr.GetData():PutOffWS()
  if wsCfg ~= nil then
    Toast(txtConst[18]:format(wsCfg.name))
  end
  Event.DispatchEvent(ModuleId.GOD_WEAPON, gmodule.notifyId.GodWeapon.WS_PUTON_CHANGE, p)
end
def.static("table").OnSSynWSInfo = function(p)
  if p.wuShiInfos == nil then
    return
  end
  DecorationMgr.GetData():SetOwnedWSList(p.wuShiInfos)
end
local SWuShiError = require("netio.protocol.mzm.gsp.superequipment.SWuShiError")
def.static("table").OnSErrorInfo = function(p)
  local errorCode = p.errorCode
  for errorMsg, code in pairs(SWuShiError) do
    if errorCode == code then
      warn("error:", errorMsg)
    end
  end
end
return DecorationProtocols.Commit()
