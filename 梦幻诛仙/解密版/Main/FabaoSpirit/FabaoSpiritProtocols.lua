local MODULE_NAME = (...)
local Lplus = require("Lplus")
local FabaoSpiritProtocols = Lplus.Class(MODULE_NAME)
local def = FabaoSpiritProtocols.define
local FabaoSpiritModule = Lplus.ForwardDeclare("FabaoSpiritModule")
def.static().Init = function()
  local Cls = FabaoSpiritProtocols
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.fabaolingqi.SEquipArtifactFail", Cls.OnSEquipLQFail)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.fabaolingqi.SEquipArtifactSuccess", Cls.OnSEquipLQSuccess)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.fabaolingqi.SExtendArtifactSuccess", Cls.OnSExtendLQSuccess)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.fabaolingqi.SImproveArtifactFail", Cls.OnSImproveLQFailed)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.fabaolingqi.SImproveArtifactSuccess", Cls.OnSImproveLQSuccess)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.fabaolingqi.SSyncArtifactInformation", Cls.OnSSynLQInfo)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.fabaolingqi.SUnequipArtifactSuccess", Cls.OnSUnequipLQSuccess)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.fabaolingqi.SUnlockArtifactSuccess", Cls.OnSUnlockLQSuccess)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.fabaolingqi.SUpgradeArtifactFail", Cls.OnSUpgradeLQFailed)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.fabaolingqi.SUpgradeArtifactSuccess", Cls.OnSUpgradeLQSuccess)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.fabaolingqi.SUseExchangeItemFail", Cls.SUseExchangeItemFail)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.fabaolingqi.SGetArtifactInfoRes", Cls.OnSGetArtifactInfoRes)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.fabaolingqi.SImproveArtifactUseAllSuccess", Cls.OnSImproveArtifactUseAllSuccess)
end
def.static("number").SendEquipLQReq = function(clsId)
  warn(">>>>Send CEquipArtifactReq clsId ", clsId)
  local p = require("netio.protocol.mzm.gsp.fabaolingqi.CEquipArtifactReq").new(clsId)
  gmodule.network.sendProtocol(p)
end
def.static().SendUnEquipLQReq = function()
  warn(">>>>Send SendUnEquipLQReq<<<<")
  local p = require("netio.protocol.mzm.gsp.fabaolingqi.CUnequipArtifactReq").new()
  gmodule.network.sendProtocol(p)
end
def.static("number", "number", "boolean", "userdata").SendImproveLQReq = function(clsId, propertyId, bUseYB, owndYB)
  warn(">>>>Send SendImproveLQReq<<<<")
  local iUsYB = 0
  if bUseYB then
    iUsYB = 1
  end
  local p = require("netio.protocol.mzm.gsp.fabaolingqi.CImproveArtifactReq").new(clsId, propertyId, iUsYB, owndYB)
  gmodule.network.sendProtocol(p)
end
def.static("number").SendUpgradeLQReq = function(clsId)
  warn(">>>>Send CUpgradeArtifactReq<<<<")
  local p = require("netio.protocol.mzm.gsp.fabaolingqi.CUpgradeArtifactReq").new(clsId)
  gmodule.network.sendProtocol(p)
end
def.static("number", "number").SendUseItemReq = function(itemKey, iNum)
  warn(">>>>Send CUseExchangeItemReq<<<<")
  local p = require("netio.protocol.mzm.gsp.fabaolingqi.CUseExchangeItemReq").new(itemKey, iNum)
  gmodule.network.sendProtocol(p)
end
def.static("userdata", "number").SendQueryRoleLQInfo = function(roleId, clsId)
  local p = require("netio.protocol.mzm.gsp.fabaolingqi.CGetArtifactInfoReq").new(roleId, clsId)
  gmodule.network.sendProtocol(p)
end
def.static("table").OnSEquipLQFail = function(p)
  if p.retcode == 1 then
    warn(">>>>NOT_OWN<<<<")
  end
end
def.static("table").OnSEquipLQSuccess = function(p)
  local FabaoSpiritUtils = require("Main.FabaoSpirit.FabaoSpiritUtils")
  FabaoSpiritModule.SetEquipedLQClsId(p.class_id)
  local LQInfo = FabaoSpiritModule.GetOwnedLQInfos()[p.class_id]
  if LQInfo ~= nil then
    local LQClsCfg = FabaoSpiritUtils.GetLQClsCfgByClsId(p.class_id)
    local lv = 1
    if #LQClsCfg.arrCfgId ~= 1 then
      lv = LQInfo.level
    end
    local cfgId = LQClsCfg.arrCfgId[lv]
    local basicCfg = FabaoSpiritUtils.GetFabaoLQCfg(cfgId or 0)
    Toast(textRes.FabaoSpirit[20]:format(basicCfg and basicCfg.name or ""))
  end
  Event.DispatchEvent(ModuleId.FABAO_SPIRIT, gmodule.notifyId.FabaoSpirit.EquipedLQChange, {bEquiped = true})
  Event.DispatchEvent(ModuleId.FABAO, gmodule.notifyId.Fabao.FABAO_DISPLAY_CHANGE, {fabaoType = 0})
end
def.static("table").OnSExtendLQSuccess = function(p)
  local clsId = p.class_id
  local expire_time = p.expire_time
  local LQInfo = FabaoSpiritModule.GetOwnedLQInfos()[clsId]
  if LQInfo ~= nil then
    LQInfo.expire_time = expire_time
    local FabaoSpiritNode = require("Main.FabaoSpirit.ui.FabaoSpiritNode")
    FabaoSpiritNode.SetSelectClsId(clsId)
    local FabaoSocialPanel = require("Main.Fabao.ui.FabaoSocialPanel")
    FabaoSocialPanel.Instance():ShowPanel(FabaoSocialPanel.NodeId.FabaoSpirit)
  end
end
def.static("table").OnSImproveLQFailed = function(p)
  local clsId = p.class_id
  local propType = p.property_type
  if p.retcode == 1 then
    warn(">>>>NOT_IMPROVABLE<<<<")
  elseif p.retcode == 2 then
    warn(">>>>REACH_MAXIMUM<<<<")
  elseif p.retcode == 3 then
    warn(">>>>ITEM_NOT_EXISTS<<<<")
  elseif p.retcode == 4 then
    warn(">>>>ITEM_NUM_NOT_ENOUGH<<<<")
  end
  local errStr = textRes.FabaoSpirit.SImproveArtifactFail[p.retcode]
  if errStr then
    Toast(errStr)
  end
end
def.static("table").OnSImproveLQSuccess = function(p)
  local clsId = p.class_id or 0
  local propType = p.property_type or 0
  local propVal = p.property_value or 0
  local LQInfo = FabaoSpiritModule.GetOwnedLQInfos()[clsId]
  if LQInfo ~= nil then
    local diff = propVal - (LQInfo.properties[propType] or 0)
    LQInfo.properties[propType] = propVal
    Event.DispatchEvent(ModuleId.FABAO_SPIRIT, gmodule.notifyId.FabaoSpirit.LQPropInfoChange, {improveProp = diff, propType = propType})
  end
  local FabaoSpiritNode = require("Main.FabaoSpirit.ui.FabaoSpiritNode")
  if FabaoSpiritNode.Instance().isShow then
    FabaoSpiritNode.Instance():OnSImproveLQSuccess(p)
  end
end
def.static("table").OnSSynLQInfo = function(p)
  local fabaoSpiritModule = FabaoSpiritModule.Instance()
  fabaoSpiritModule._ownedLQInfos = p.artifact_map
  FabaoSpiritModule.SetEquipedLQClsId(p.equipped_artifact_class)
end
def.static("table").OnSUnequipLQSuccess = function(p)
  FabaoSpiritModule.SetEquipedLQClsId(0)
  Toast(textRes.FabaoSpirit[21])
  Event.DispatchEvent(ModuleId.FABAO_SPIRIT, gmodule.notifyId.FabaoSpirit.EquipedLQChange, {bEquiped = false})
end
def.static("table").OnSUnlockLQSuccess = function(p)
  local FabaoSpiritUtils = require("Main.FabaoSpirit.FabaoSpiritUtils")
  local clsId = p.class_id or 0
  local lv = p.level or 0
  local expire_time = p.expire_time or 0
  local ownLQInfos = FabaoSpiritModule.GetOwnedLQInfos()
  local LQClsCfg = FabaoSpiritUtils.GetLQClsCfgByClsId(clsId)
  local upgrade_exp = 0
  if LQClsCfg ~= nil then
    upgrade_exp = LQClsCfg.arrExp[lv] or 0
  end
  ownLQInfos[clsId] = {
    expire_time = expire_time,
    level = lv,
    upgrade_exp = upgrade_exp,
    properties = {},
    class_id = clsId,
    tgNew = true
  }
  FabaoSpiritModule.FillProperties(clsId)
  Event.DispatchEvent(ModuleId.FABAO_SPIRIT, gmodule.notifyId.FabaoSpirit.OwndLQChange, nil)
  require("Main.FabaoSpirit.ui.UIGetAndUpgradeHint").Instance():ShowPanel(1, ownLQInfos[clsId])
end
def.static("table").OnSUpgradeLQFailed = function(p)
  if p.retcode == 1 then
    warn(">>>>NOT_UPGRADABLE<<<<")
  elseif p.retcode == 2 then
    warn(">>>>REACH_MAXIMUM<<<<")
  elseif p.retcode == 3 then
    warn(">>>>ITEM_NOT_EXISTS<<<<")
  end
end
def.static("table").OnSUpgradeLQSuccess = function(p)
  local clsId = p.class_id or 0
  local upgrade_exp = p.upgrade_exp or 0
  local ownLQInfos = FabaoSpiritModule.GetOwnedLQInfos()
  local LQInfo = ownLQInfos[clsId]
  if LQInfo ~= nil then
    LQInfo.upgrade_exp = upgrade_exp
    local preLv = LQInfo.level
    LQInfo.level = p.level
    Event.DispatchEvent(ModuleId.FABAO_SPIRIT, gmodule.notifyId.FabaoSpirit.LQInfoChange, {bUpdateList = true})
    if preLv ~= LQInfo.level then
      LQInfo.class_id = clsId
      require("Main.FabaoSpirit.ui.UIGetAndUpgradeHint").Instance():ShowPanel(2, LQInfo)
    end
  end
end
def.static("table").SUseExchangeItemFail = function(p)
  if p.retcode == 1 then
    warn(">>>ITEM_NOT_EXISTS<<<<")
  elseif p.retcode == 2 then
    warn(">>>INVALID_ITEM<<<<")
  elseif p.retcode == 3 then
    warn(">>>ALREADY_UNLOCKED<<<<")
  end
end
def.static("table").OnSGetArtifactInfoRes = function(p)
  local ItemTipsMgr = require("Main.Item.ItemTipsMgr")
  local FabaoSpiritUtils = require("Main.FabaoSpirit.FabaoSpiritUtils")
  local ItemUtils = require("Main.Item.ItemUtils")
  local roleLQInfo = p.info
  if roleLQInfo ~= nil then
    local LQClsCfg = FabaoSpiritUtils.GetLQClsCfgByClsId(p.class_id)
    local lv = 1
    if #LQClsCfg.arrCfgId ~= 1 then
      lv = roleLQInfo.level
    end
    local cfgId = LQClsCfg.arrCfgId[lv]
    local itemId = FabaoSpiritUtils.GetItemIdByCfgId(cfgId)
    local itemBase = ItemUtils.GetItemBase(itemId)
    roleLQInfo.bIsEquip = false
    ItemTipsMgr.Instance():ShowFabaoLQWearTips(roleLQInfo, itemBase, ItemTipsMgr.Source.Equip, 0, 0, 0, 0, 0, false)
  end
end
def.static("number", "number", "boolean", "userdata").SendCPetFightSetTeamFormationReq = function(clsId, propertyId, bUseYB, owndYB)
  warn("[FabaoSpiritProtocols:SendCPetFightSetTeamFormationReq] Send CImproveArtifactUseAllReq:", clsId, propertyId, bUseYB, owndYB and Int64.tostring(owndYB))
  local iUsYB = 0
  if bUseYB then
    iUsYB = 1
  end
  local p = require("netio.protocol.mzm.gsp.fabaolingqi.CImproveArtifactUseAllReq").new(clsId, propertyId, iUsYB, owndYB)
  gmodule.network.sendProtocol(p)
end
def.static("table").OnSImproveArtifactUseAllSuccess = function(p)
  warn("[FabaoSpiritProtocols:OnSImproveArtifactUseAllSuccess] On SImproveArtifactUseAllSuccess:", p.class_id, p.property_type, p.property_value, p.consumed_item_num, p.consumed_yuanbao)
  local clsId = p.class_id or 0
  local propType = p.property_type or 0
  local propVal = p.property_value or 0
  local LQInfo = FabaoSpiritModule.GetOwnedLQInfos()[clsId]
  if LQInfo ~= nil then
    local diff = propVal - (LQInfo.properties[propType] or 0)
    LQInfo.properties[propType] = propVal
    Event.DispatchEvent(ModuleId.FABAO_SPIRIT, gmodule.notifyId.FabaoSpirit.LQPropInfoChange, {
      improveProp = diff,
      propType = propType,
      bQuick = true
    })
    local FabaoSpiritUtils = require("Main.FabaoSpirit.FabaoSpiritUtils")
    local attrName = FabaoSpiritUtils.GetFabaoSpiritProName(propType)
    local toast = string.format(textRes.FabaoSpirit[40], p.consumed_item_num, p.consumed_yuanbao, attrName, diff)
    Toast(toast)
  end
end
return FabaoSpiritProtocols.Commit()
