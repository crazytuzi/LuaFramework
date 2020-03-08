local Lplus = require("Lplus")
local ModuleBase = require("Main.module.ModuleBase")
local EquipModule = Lplus.Extend(ModuleBase, "EquipModule")
require("Main.module.ModuleId")
local EquipUtils = require("Main.Equip.EquipUtils")
local EquipSocialPanel = require("Main.Equip.ui.EquipSocialPanel")
local EquipEffectResetPanel = require("Main.Equip.ui.EquipEffectResetPanel")
local def = EquipModule.define
local instance
def.field(EquipSocialPanel)._dlg = nil
def.field("number")._strenLvByRes = 0
def.field("number")._eqpFixKey = 0
def.field("number")._eqpFixBagId = 0
def.field("table")._eqpAllFixInfo = nil
def.field("number").m_EquipNewFuncState = 0
def.field("number").curQiLinMode = 0
def.static("=>", EquipModule).Instance = function()
  if nil == instance then
    instance = EquipModule()
    instance._dlg = EquipSocialPanel.Instance()
    instance.m_moduleId = ModuleId.EQUIP
  end
  return instance
end
def.override().Init = function(self)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.item.SEquipMakeRes", EquipModule.onEquipMakeSuccess)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.item.SEquipQiLinRes", EquipModule.SEquipQiLinRes)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.item.SEquipTransferHunRes", EquipModule.SEquipInheritRes)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.item.SCommonErrorInfo", EquipModule.SCommonErrorInfo)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.item.SResItemYuanbaoPriceWithId", EquipModule.SResItemYuanbaoPriceWithId)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.item.SEquipMakeYunanbaoPriceRes", EquipModule.SEquipMakeYunanbaoPriceRes)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.item.SLockHunSuccess", EquipModule.onLockHunSuccess)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.item.SRefreshHunSuccess", EquipModule.onRefreshHunSuccess)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.item.SUnLockHunSuccess", EquipModule.onUnLockSuccess)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.item.SConfirmRefreshHunSuccess", EquipModule.onReplaceHunSuccess)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.item.SSynEquiptipRes", EquipModule.onSEquipNewFuncState)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.item.SSynEquipQilinModeRes", EquipModule.OnSSynEquipQilinModeRes)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.item.SSynEquipQiLinOperateRes", EquipModule.OnSSynEquipQiLinOperateRes)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.item.SEquipSkillRefreshRes", EquipModule.OnSEquipSkillRefreshRes)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.item.SReplaceEquipSkillRes", EquipModule.OnSReplaceEquipSkillRes)
  Event.RegisterEvent(ModuleId.MAINUI, gmodule.notifyId.MainUI.BTN_EQUIPMENT_CLICK, EquipModule._onShow)
  Event.RegisterEvent(ModuleId.ITEM, gmodule.notifyId.item.Item_OnBagInfoSynchronized, EquipModule._onBagInfoSyncronized)
  Event.RegisterEvent(ModuleId.ITEM, gmodule.notifyId.item.Item_Money_SilverChanged, EquipModule._itemMoneySilverChanged)
  Event.RegisterEvent(ModuleId.LOGIN, gmodule.notifyId.Login.LEAVE_WORLD, function()
    self:Reset()
  end)
  Event.RegisterEvent(ModuleId.FEATURE, gmodule.notifyId.Feature.FeatureOpenChange, EquipModule.OnFunctionOpenChange)
  Event.RegisterEvent(ModuleId.ITEM, gmodule.notifyId.item.Item_Money_GoldChanged, EquipModule.OnItemGoldChange)
  Event.RegisterEvent(ModuleId.EQUIP, gmodule.notifyId.Equip.Equip_Bless_Notify_Change, EquipModule.OnEquipBlessNotifyChange)
  require("Main.Equip.EquipBlessMgr").Instance():Init()
  ModuleBase.Init(self)
end
def.override().OnReset = function(self)
  self._strenLvByRes = 0
  self._eqpFixKey = 0
  self._eqpFixBagId = 0
  self._eqpAllFixInfo = nil
  self.m_EquipNewFuncState = 0
  self.curQiLinMode = 0
  self._dlg._bIsEquipMakeDataInit = false
end
def.method("number", "=>", "boolean").CheckRedNotice = function(self, nodeId)
  local curState = self.m_EquipNewFuncState
  local stateRes = 0
  if nodeId == EquipSocialPanel.NodeId.EQUIPMAKE then
    stateRes = curState
  elseif nodeId == EquipSocialPanel.NodeId.EQUIPSTREN then
    stateRes = bit.rshift(curState, 1)
  elseif nodeId == EquipSocialPanel.NodeId.EQUIPXIHUN then
    stateRes = bit.rshift(curState, 2)
  elseif nodeId == EquipSocialPanel.NodeId.EQUIPINHERIT then
    stateRes = bit.rshift(curState, 3)
  end
  stateRes = bit.band(stateRes, 1)
  if stateRes > 0 then
    return true
  else
    return false
  end
end
def.method("=>", "boolean").CheckRedNoticeAll = function(self)
  local makeNotice = self:CheckRedNotice(EquipSocialPanel.NodeId.EQUIPMAKE) or require("Main.Equip.EquipBlessMgr").Instance():HasNotify()
  local strenNotice = self:CheckRedNotice(EquipSocialPanel.NodeId.EQUIPSTREN)
  local xihunNotice = self:CheckRedNotice(EquipSocialPanel.NodeId.EQUIPXIHUN)
  local inherithNotice = self:CheckRedNotice(EquipSocialPanel.NodeId.EQUIPINHERIT)
  return makeNotice or strenNotice or xihunNotice or inherithNotice
end
def.method("number").SetNewFuncState = function(self, state)
  self.m_EquipNewFuncState = state
end
def.method("number").ResetNewFuncState = function(self, nodeId)
  local targetId = 15
  if nodeId == EquipSocialPanel.NodeId.EQUIPMAKE then
    self.m_EquipNewFuncState = bit.band(self.m_EquipNewFuncState, bit.bnot(1))
    targetId = bit.band(targetId, bit.bnot(1))
  elseif nodeId == EquipSocialPanel.NodeId.EQUIPSTREN then
    self.m_EquipNewFuncState = bit.band(self.m_EquipNewFuncState, bit.bnot(2))
    targetId = bit.band(targetId, bit.bnot(2))
  elseif nodeId == EquipSocialPanel.NodeId.EQUIPXIHUN then
    self.m_EquipNewFuncState = bit.band(self.m_EquipNewFuncState, bit.bnot(4))
    targetId = bit.band(targetId, bit.bnot(4))
  elseif nodeId == EquipSocialPanel.NodeId.EQUIPINHERIT then
    self.m_EquipNewFuncState = bit.band(self.m_EquipNewFuncState, bit.bnot(8))
    targetId = bit.band(targetId, bit.bnot(8))
  end
  if self._dlg and self._dlg.m_panel and false == self._dlg.m_panel.isnil then
    self._dlg:UpdateTapState()
  end
  Event.DispatchEvent(ModuleId.EQUIP, gmodule.notifyId.Equip.Equip_NewFunction_ChangeState, nil)
  local CProtocol = require("netio.protocol.mzm.gsp.item.CClearEquiptipReq")
  local p = CProtocol.new(targetId)
  gmodule.network.sendProtocol(p)
  warn("send protocol ~~~~~ ", targetId, self.m_EquipNewFuncState)
end
def.static("table").SCommonErrorInfo = function(p)
  local commonInfo = require("netio.protocol.mzm.gsp.item.SCommonErrorInfo")
  if p.errorCode == commonInfo.EQUIP_TRANSFER_BAGID_ERROR or p.errorCode == commonInfo.EQUIP_TRANSFER_KEY_ERROR or p.errorCode == commonInfo.EQUIP_TRANSFER_HUN_KEY_ERROR or p.errorCode == commonInfo.EQUIP_TRANSFER_CONF_ERROR or p.errorCode == commonInfo.EQUIP_TRANSFER_TRAN_CONF_ERROR or p.errorCode == commonInfo.EQUIP_TRANSFER_SILVER_NOT_ENOUGH or p.errorCode == commonInfo.EQUIP_TRANSFER_ITEM_NOT_ENOUGH or p.errorCode == commonInfo.EQUIP_TRANSFER_WEAR_POS_ERROR or p.errorCode == commonInfo.EQUIP_TRANSFER_NO_HUN_ERROR or p.errorCode == commonInfo.EQUIP_TRANSFER_LEVEL_ERROR or p.errorCode == commonInfo.EQUIP_TRANSFER_REMOVE_EQUIP_ERROR or p.errorCode == commonInfo.EQUIP_TRANSFER_REPLACE_HUN_ERROR then
    if EquipModule.Instance()._dlg and EquipModule.Instance()._dlg.m_panel and false == EquipModule.Instance()._dlg.m_panel.isnil then
      EquipModule.Instance()._dlg:FailedEquipTrans()
    end
  elseif p.errorCode == commonInfo.EQUIP_QILIN_BAGID_ERROR or p.errorCode == commonInfo.EQUIP_QILIN_KEY_ERROR or p.errorCode == commonInfo.EQUIP_QILIN_CONF_ERROR or p.errorCode == commonInfo.EQUIP_QILIN_QILIN_CONF_ERROR or p.errorCode == commonInfo.EQUIP_QILIN_SILVER_NOT_ENOUGH or p.errorCode == commonInfo.EQUIP_QILIN_ITEM_NOT_ENOUGH or p.errorCode == commonInfo.EQUIP_QILIN_SUCCESSITEM_NOT_ENOUGH or p.errorCode == commonInfo.EQUIP_QILIN_LEVEL_ERROR or p.errorCode == commonInfo.EQUIP_QILIN_CAN_NOT_USE_SUCCESSITEM or p.errorCode == commonInfo.EQUIP_QILIN_YUNABO_NOT_ENOUGH or p.errorCode == commonInfo.EQUIP_QILIN_ITEM_LEVEL_ERROR or p.errorCode == commonInfo.ITEM_YUAN_BAO_PRICE then
    if EquipModule.Instance()._dlg and EquipModule.Instance()._dlg.m_panel and false == EquipModule.Instance()._dlg.m_panel.isnil then
      EquipModule.Instance()._dlg:UpdateBtnState()
      EquipModule.Instance()._dlg:ShowCommonEorrorInfo(p.errorCode)
    end
  elseif p.errorCode == commonInfo.EQUIP_INHERIT_BAGID_ERROR or p.errorCode == commonInfo.EQUIP_INHERIT_KEY_ERROR or p.errorCode == commonInfo.EQUIP_INHERIT_CONF_ERROR or p.errorCode == commonInfo.EQUIP_INHERIT_HERI_CONF_ERROR or p.errorCode == commonInfo.EQUIP_INHERIT_SILVER_NOT_ENOUGH or p.errorCode == commonInfo.EQUIP_INHERIT_WEAR_POS_ERROR or p.errorCode == commonInfo.EQUIP_INHERIT_EQUIP_LEVEL_ERROR or p.errorCode == commonInfo.EQUIP_INHERIT_LIN_LEVEL_ERROR or p.errorCode == commonInfo.EQUIP_INHERIT_REMOVE_EQUIP_ERROR then
    if EquipModule.Instance()._dlg and EquipModule.Instance()._dlg.m_panel and false == EquipModule.Instance()._dlg.m_panel.isnil then
      EquipModule.Instance()._dlg:UpdateBtnState()
      EquipModule.Instance()._dlg:ShowCommonEorrorInfo(p.errorCode)
    end
  elseif p.errorCode == commonInfo.ITEM_OPER_BAGID_WRONG or p.errorCode == commonInfo.ITEM_OPER_UNKNOWN_WRONG or p.errorCode == commonInfo.ITEM_OPER_WRONG_CFG or p.errorCode == commonInfo.ITEM_OPER_UUID_WRONG or p.errorCode == commonInfo.ITEM_OPER_USECOUNT_WRONG or p.errorCode == commonInfo.EQUIP_WRONG_CFG or p.errorCode == commonInfo.EQUIP_REFRESH_HUN_TMP_EXTRA_PROP_EMPTY or p.errorCode == commonInfo.EQUIP_REFRESH_HUN_ITEM_NOT_ENOUGH or p.errorCode == commonInfo.EQUIP_LOCK_HUN_ALREADY_LOCKED or p.errorCode == commonInfo.EQUIP_LOCK_HUN_MAX_NUM_LIMIT or p.errorCode == commonInfo.EQUIP_LOCK_HUN_ITEM_NOT_ENOUGH or p.errorCode == commonInfo.EQUIP_LOCK_HUN_YUANBAO_NOT_ENOUGH or p.errorCode == commonInfo.EQUIP_UNLOCK_HUN_NOT_LOCKED or p.errorCode == commonInfo.ITEM_YUAN_BAO_PRICE or p.errorCode == commonInfo.ACCUMULATION_NEED_YUANBAO_ERROR or p.errorCode == commonInfo.ROLE_HAS_ITEM_CAN_NOT_USE_YUANBAO then
    if EquipModule.Instance()._dlg and EquipModule.Instance()._dlg.m_panel and false == EquipModule.Instance()._dlg.m_panel.isnil then
      EquipModule.Instance()._dlg:ShowCommonEorrorInfo(p.errorCode)
    end
  elseif p.errorCode == commonInfo.EQUIP_MAKE_BAG_ERROR or p.errorCode == commonInfo.EQUIP_MAKE_MAKE_CONF_ERROR or p.errorCode == commonInfo.EQUIP_MAKE_EQUIP_CONF_ERROR or p.errorCode == commonInfo.EQUIP_MAKE_ITEM_CONF_ERROR or p.errorCode == commonInfo.EQUIP_MAKE_LEVEL_ERROR or p.errorCode == commonInfo.EQUIP_MAKE_OCCUPATIONH_ERROR or p.errorCode == commonInfo.EQUIP_MAKE_GENDER_ERROR or p.errorCode == commonInfo.EQUIP_MAKE_ITEM_NOT_ENOUGH or p.errorCode == commonInfo.EQUIP_MAKE_YUANBAO_NOT_ENOUGH or p.errorCode == commonInfo.EQUIP_MAKE_FAILED then
  elseif p.errorCode == commonInfo.EQUIP_LEVEL_IS_TOO_LOW or p.errorCode == commonInfo.EQUIP_MAX_LIN_LEVEL_ERROR then
    local str = textRes.Equip.CommonError[p.errorCode]
    if str and str ~= "" then
      Toast(str)
    end
  end
end
def.static("table").onEquipMakeSuccess = function(p)
  if EquipModule.Instance()._dlg and EquipModule.Instance()._dlg.m_panel and false == EquipModule.Instance()._dlg.m_panel.isnil then
    EquipModule.Instance()._dlg:ShowEquipMakeSuccessFrame(p.key, p.eqpInfo)
  end
end
def.static("table").SEquipQiLinRes = function(p)
  if EquipModule.Instance()._dlg and EquipModule.Instance()._dlg.m_panel and false == EquipModule.Instance()._dlg.m_panel.isnil then
    EquipModule.Instance()._strenLvByRes = p.strengthLevel
    EquipModule.Instance()._dlg:UpdateEquipStrenFrame(p.strengthLevel, p.isSuccess, p.iteminfo)
  end
  SafeLuckDog(function()
    return p.isSuccess > 0 and p.strengthLevel >= 7
  end)
end
def.static("table").SEquipTransferHunRes = function(p)
  if EquipModule.Instance()._dlg and EquipModule.Instance()._dlg.m_panel and false == EquipModule.Instance()._dlg.m_panel.isnil then
    EquipModule.Instance()._dlg:RefeshEquipTrans(p.desEquipHunIndex, p.newHun)
  end
end
def.static("table").SEquipInheritRes = function(p)
  if EquipModule.Instance()._dlg and EquipModule.Instance()._dlg.m_panel and false == EquipModule.Instance()._dlg.m_panel.isnil then
    EquipModule.Instance()._dlg:OnUpdateEquipInheritInfo(p.newExproList)
  end
end
def.static("table").SResItemYuanbaoPriceWithId = function(p)
  if EquipModule.Instance()._dlg and EquipModule.Instance()._dlg.m_panel and false == EquipModule.Instance()._dlg.m_panel.isnil then
    EquipModule.Instance()._dlg:SetEquipMakeItemNeedGold(p.uid, p.itemid2yuanbao)
  end
end
def.static("table").SEquipMakeYunanbaoPriceRes = function(p)
  if EquipModule.Instance()._dlg and EquipModule.Instance()._dlg.m_panel and false == EquipModule.Instance()._dlg.m_panel.isnil then
    EquipModule.Instance()._dlg:EquipMakeItemGoldDifferent(p.eqpId, p.serverNeedYuanbao)
  end
end
def.static("table", "table")._onShow = function(p1, p2)
  if instance._dlg.m_panel == nil then
    if EquipModule.IsEquipDlgShow() then
      EquipSocialPanel.ShowSocialPanel(EquipSocialPanel.StateConst.EquipStren)
    end
  else
    instance._dlg:DestroyPanel()
  end
end
def.static("table", "table")._onBagInfoSyncronized = function(p1, p2)
  if instance._dlg and instance._dlg.m_panel and false == instance._dlg.m_panel.isnil then
    instance._dlg:UpdateCanStrenState()
    if instance._dlg.curNode == EquipSocialPanel.NodeId.EQUIPMAKE then
      instance._dlg:RefeshEquipMakeItemNum()
      instance._dlg:JudgeEquipCanMake()
    elseif instance._dlg.curNode == EquipSocialPanel.NodeId.EQUIPSTREN then
      instance._dlg:RefreshEquipList()
      instance._dlg:UpdateEquipStrenNeedItem(EquipModule.Instance()._strenLvByRes)
    elseif instance._dlg.curNode == EquipSocialPanel.NodeId.EQUIPINHERIT then
      instance._dlg:UpdateEquipList()
      GameUtil.AddGlobalTimer(1, true, function()
        if instance._dlg and instance._dlg.m_panel and false == instance._dlg.m_panel.isnil then
          instance._dlg:UpdateEquipInheritList()
        end
      end)
    elseif instance._dlg.curNode == EquipSocialPanel.NodeId.EQUIPXIHUN then
      instance._dlg:RefreshEquipList()
      instance._dlg:OnEquipXinHunBagInfoSyn()
    end
  end
  local equipEffectResetPanel = EquipEffectResetPanel.Instance()
  if equipEffectResetPanel.m_panel and false == equipEffectResetPanel.m_panel.isnil and equipEffectResetPanel:IsShow() then
    equipEffectResetPanel:setSelectedEquipInfo()
  end
end
def.static("table").onLockHunSuccess = function(p)
  if instance._dlg and instance._dlg.m_panel and false == instance._dlg.m_panel.isnil then
    warn("onLockHunSuccess~~~~~~~~", p.bagid, p.uuid, p.hunIndex, type(p.hunIndex))
    instance._dlg:lockHunSuccess(p.bagid, p.uuid, p.hunIndex)
  end
end
def.static("table").onLockFailed = function(p)
  if instance._dlg and instance._dlg.m_panel and false == instance._dlg.m_panel.isnil then
    warn("onLockHunFailed~~~~~~~~")
    instance._dlg:lockHunFailed(p.bagid, p.uuid, p.hunIndex, p.retcode)
  end
end
def.static("table").onRefreshHunSuccess = function(p)
  if instance._dlg and instance._dlg.m_panel and false == instance._dlg.m_panel.isnil then
    warn("onRefreshHunSuccess~~~~~~~~")
    instance._dlg:RefresHunSuccess(p.bagid, p.uuid, p.extrProps)
  end
end
def.static("table").onRefreshHunFailed = function(p)
  if instance._dlg and instance._dlg.m_panel and false == instance._dlg.m_panel.isnil then
    warn("onRefreshHunSuccess~~~~~~~~")
    instance._dlg:RefresHunFailed(p.bagid, p.uuid, p.retcode)
  end
end
def.static("table").onUnLockSuccess = function(p)
  if instance._dlg and instance._dlg.m_panel and false == instance._dlg.m_panel.isnil then
    warn("onRefreshHunSuccess~~~~~~~~")
    instance._dlg:unLockHunSuccess(p.bagid, p.uuid, p.hunIndex)
  end
end
def.static("table").onUnLockFailed = function(p)
  if instance._dlg and instance._dlg.m_panel and false == instance._dlg.m_panel.isnil then
    warn("onRefreshHunSuccess~~~~~~~~")
    instance._dlg:unLockHunFailed(p.bagid, p.uuid, p.hunIndex, p.retcode)
  end
end
def.static("table").onReplaceHunSuccess = function(p)
  if instance._dlg and instance._dlg.m_panel and false == instance._dlg.m_panel.isnil then
    warn("onReplaceHunSuccess~~~~~~~~")
    instance._dlg:ReplaceHunSuccess(p.bagid, p.uuid, p.isReplace)
  end
end
def.static("table").onReplaceHunFailed = function(p)
  if instance._dlg and instance._dlg.m_panel and false == instance._dlg.m_panel.isnil then
    warn("onReplaceHunFailed~~~~~~~~")
    instance._dlg:ReplaceHunFailed(p.retcode, p.bagid, p.isReplace, p.uuid)
  end
end
def.static("table", "table")._itemMoneySilverChanged = function(p1, p2)
  if instance._dlg and instance._dlg.m_panel and false == instance._dlg.m_panel.isnil then
    instance._dlg:UpdateCanStrenState()
    instance._dlg:RefeshSilverNum()
    instance._dlg:UpdateEquipStrenSilver()
    instance._dlg:UpdateTransSilverNum()
    instance._dlg:UpdateInheritSilverNum()
  end
  local equipEffectResetPanel = EquipEffectResetPanel.Instance()
  if equipEffectResetPanel.m_panel and false == equipEffectResetPanel.m_panel.isnil and equipEffectResetPanel:IsShow() then
    equipEffectResetPanel:setMoneyInfo()
  end
end
def.static("table").onSEquipNewFuncState = function(p)
  warn("onSEquipNewFuncState~~~~ ", p.state)
  EquipModule.Instance():SetNewFuncState(p.state)
  Event.DispatchEvent(ModuleId.EQUIP, gmodule.notifyId.Equip.Equip_NewFunction_ChangeState, {state = true})
  if instance._dlg and instance._dlg.m_panel and false == instance._dlg.m_panel.isnil then
    instance._dlg:UpdateTapState()
  end
end
def.static("=>", "boolean").IsEquipDlgShow = function()
  local equipMakeMinLev = EquipUtils.GetEquipOpenMinLevel()
  local prop = require("Main.Hero.Interface").GetBasicHeroProp()
  local level = prop.level
  if equipMakeMinLev > level then
    Toast(string.format(textRes.Equip[92], equipMakeMinLev))
    return false
  else
    return true
  end
end
def.static("number", "number", "number", "=>", "number").GetAttriValue = function(eqpId, attri, percent)
  local equipRecord = DynamicData.GetRecord(CFG_PATH.DATA_EQQUIPCFG, eqpId)
  local ItemXStoreType = require("netio.protocol.mzm.gsp.item.ItemXStoreType")
  local attriValue = 0
  local attr = 0
  local attrvaluemax = 0
  local attrvaluemin = 0
  if nil ~= equipRecord then
    if ItemXStoreType.ATTRI_A == attri then
      attr = equipRecord:GetIntValue("attrA")
      attrvaluemax = equipRecord:GetIntValue("attrAvaluemax")
      attrvaluemin = equipRecord:GetIntValue("attrAvaluemin")
    elseif ItemXStoreType.ATTRI_B == attri then
      attr = equipRecord:GetIntValue("attrB")
      attrvaluemax = equipRecord:GetIntValue("attrBvaluemax")
      attrvaluemin = equipRecord:GetIntValue("attrBvaluemin")
    end
  end
  attriValue = math.floor(attrvaluemin + (attrvaluemax - attrvaluemin) * percent / 10000)
  return attriValue
end
def.static("number", "=>", "string").GetAttriName = function(attri)
  local strAtt = ""
  local record = DynamicData.GetRecord(CFG_PATH.DATA_COMMON_PROPERTYNAME_CFG, attri)
  if nil ~= record then
    strAtt = DynamicRecord.GetStringValue(record, "propName")
  end
  return strAtt
end
def.static("number", "number", "=>", "string").GetProValStr = function(exaProCfgId, proValue)
  local bIsRate = EquipModule.IsProRate(exaProCfgId)
  local strPro = tostring(proValue)
  if bIsRate then
    proValue = proValue * 0.01
    proValue = string.format("%.1f", proValue)
    strPro = proValue .. "%"
  end
  return strPro
end
def.static("number", "=>", "boolean").IsProRate = function(exaProCfgId)
  local bIsRate = false
  local typeConst = require("consts.mzm.gsp.common.confbean.PropertyType")
  if exaProCfgId == typeConst.PHY_CRT_RATE or exaProCfgId == typeConst.MAG_CRT_RATE or exaProCfgId == typeConst.HEAL_CRT_RATE or exaProCfgId == typeConst.PHY_FIGHT_BACK_RATE or exaProCfgId == typeConst.MAG_FIGHT_BACK_RATE then
    bIsRate = true
  end
  return bIsRate
end
def.static("number", "number", "=>", "string", "number", "number").GetProRealValue = function(proType, proValue)
  local recProRandomValue = DynamicData.GetRecord(CFG_PATH.DATA_EQUIP_PRO_RANDOM_VALUE_CFG, proType)
  local proRealValue = 0
  local floatValue = 0
  if nil ~= recProRandomValue then
    local min = recProRandomValue:GetIntValue("extraProMin")
    local max = recProRandomValue:GetIntValue("extraProMax")
    local val = min + (max - min) * proValue / 10000
    floatValue = val
    proRealValue = math.floor(val)
  end
  local exaProCfgId = EquipModule.GetProTypeID(proType)
  return EquipModule.GetProValStr(exaProCfgId, proRealValue), proRealValue, floatValue
end
def.static("number", "=>", "string").GetProRandomName = function(pro)
  local proStr = ""
  local exaProCfgId = EquipModule.GetProTypeID(pro)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_COMMON_PROPERTYNAME_CFG, exaProCfgId)
  if nil ~= record then
    proStr = DynamicRecord.GetStringValue(record, "propName")
  end
  return proStr
end
def.static("number", "=>", "number").GetProTypeID = function(pro)
  local recProRandomValue = DynamicData.GetRecord(CFG_PATH.DATA_EQUIP_PRO_RANDOM_VALUE_CFG, pro)
  local exaProCfgId = 0
  if nil ~= recProRandomValue then
    exaProCfgId = recProRandomValue:GetIntValue("exaProCfgId")
  end
  return exaProCfgId
end
def.static("userdata", "number", "number", "table").ShowInheritConfirmDlg = function(uuid, itemkey, bagid, itemInfo)
end
def.static("table", "table").OnWearEquipRes = function(equipUUIDs, godWeaponUUIDs)
  local ComfirmDlg = require("GUI.CommonConfirmDlg")
  local function CheckGodWeaponTrans()
    if godWeaponUUIDs and next(godWeaponUUIDs) then
      warn("[EquipModule:OnWearEquipRes] check godweapon trans!")
      local function callback(id, tag)
        if id == 1 then
          require("Main.GodWeapon.BreakOut.BreakOutProtocols").SendCInheritGodWeapon(godWeaponUUIDs)
        else
        end
      end
      ComfirmDlg.ShowConfirm("", textRes.Equip[134], callback, nil)
    end
  end
  if equipUUIDs and next(equipUUIDs) then
    warn("[EquipModule:OnWearEquipRes] check equip stren trans!")
    local function callback1(id, tag)
      if id == 1 then
        EquipModule.OnRealtoTransferStren(equipUUIDs)
      else
      end
      CheckGodWeaponTrans()
    end
    ComfirmDlg.ShowConfirm("", textRes.Equip[104], callback1, nil)
  else
    CheckGodWeaponTrans()
  end
end
def.static("table").OnRealtoTransferStren = function(uuids)
  local CProtocol = require("netio.protocol.mzm.gsp.item.CTransferStrengthLevel")
  local p = CProtocol.new(uuids)
  gmodule.network.sendProtocol(p)
end
def.static("=>", "number").GetStrenExtraAddRate = function()
  local effectSkillIds = require("Main.Fashion.FashionData").Instance():GetCurrentFashionEffects()
  if nil == effectSkillIds then
    return 0
  end
  local EffectClassName = require("Main.Effect.EffectClassName")
  local StrenEffectName = EffectClassName.AddQiLingRateEffect
  local SkillMgr = require("Main.Skill.SkillMgr")
  local heroLevel = require("Main.Hero.Interface").GetHeroProp().level
  local addRate = 0
  for k, v in pairs(effectSkillIds) do
    if 0 ~= v then
      local effects = SkillMgr.Instance():GetPassiveSkillEffects(v, heroLevel)
      for _, groupEffect in pairs(effects) do
        local className = groupEffect.classname
        if className == StrenEffectName then
          addRate = addRate + groupEffect.value / groupEffect.fenmu * EquipUtils.GetJiGaoMax()
        end
      end
    end
  end
  return addRate
end
def.static("userdata", "number", "=>", "number").GetQiLingAddRate = function(uuid, bagId)
  local ItemModule = require("Main.Item.ItemModule")
  local allItemInBag = ItemModule.Instance():GetItemsByBagId(bagId)
  if nil == allItemInBag then
    return 0
  end
  local ItemXStoreType = require("netio.protocol.mzm.gsp.item.ItemXStoreType")
  for k, v in pairs(allItemInBag) do
    if v.uuid[1]:eq(uuid) then
      return v.extraMap[ItemXStoreType.QILING_SCORE] or 0
    end
  end
  return 0
end
def.static("table").OnSSynEquipQilinModeRes = function(p)
  warn("--------OnSSynEquipQilinModeRes:", p.mode)
  local QiLinMode = require("netio/protocol/mzm/gsp/item/QiLinMode")
  local openId = require("netio.protocol.mzm.gsp.open.ModuleFunSwitchInfo").TYPE_QILIN_ACCUMULATION_MODE
  if IsFeatureOpen(openId) then
    instance.curQiLinMode = p.mode
  else
    instance.curQiLinMode = QiLinMode.RISK_MODE
  end
  if EquipModule.Instance()._dlg and EquipModule.Instance()._dlg.m_panel and false == EquipModule.Instance()._dlg.m_panel.isnil then
    EquipModule.Instance()._dlg:UpdateEquipQiLinMode()
    EquipModule.Instance()._dlg:UpdateCanStrenState()
    EquipModule.Instance()._dlg:UpdateEquipList()
    if p.mode == QiLinMode.RISK_MODE then
      Toast(textRes.Equip[204])
    elseif p.mode == QiLinMode.ACCUMULATION_MODE then
      Toast(textRes.Equip[205])
    end
  end
end
def.static("table").OnSSynEquipQiLinOperateRes = function(p)
  warn("------OnSSynEquipQilinModeRes:", p.strengthLevel)
  if EquipModule.Instance()._dlg and EquipModule.Instance()._dlg.m_panel and false == EquipModule.Instance()._dlg.m_panel.isnil then
    EquipModule.Instance()._strenLvByRes = p.strengthLevel
    EquipModule.Instance()._dlg:UpdateAccumutionEquipStrenFrame(p.strengthLevel, p.iteminfo)
  end
end
def.static("table", "table").OnFunctionOpenChange = function(p1, p2)
  local ModuleFunSwitchInfo = require("netio.protocol.mzm.gsp.open.ModuleFunSwitchInfo")
  local openId = ModuleFunSwitchInfo.TYPE_QILIN_ACCUMULATION_MODE
  if instance and p1.feature == openId then
    if not IsFeatureOpen(openId) then
      local QiLinMode = require("netio/protocol/mzm/gsp/item/QiLinMode")
      instance.curQiLinMode = QiLinMode.RISK_MODE
    end
    if EquipModule.Instance()._dlg and EquipModule.Instance()._dlg.m_panel and false == EquipModule.Instance()._dlg.m_panel.isnil then
      EquipModule.Instance()._dlg:UpdateEquipQiLinMode()
    end
  elseif p1.feature == ModuleFunSwitchInfo.TYPE_EQUIP_MAKE_N_LEVEL then
    require("Main.Equip.EquipMakeData").Instance():Init()
  end
end
def.static("table").OnSEquipSkillRefreshRes = function(p)
  local equipEffectResetPanel = EquipEffectResetPanel.Instance()
  if equipEffectResetPanel.m_panel and false == equipEffectResetPanel.m_panel.isnil and equipEffectResetPanel:IsShow() then
    equipEffectResetPanel:setSelectedEquipInfo()
  end
end
def.static("table").OnSReplaceEquipSkillRes = function(p)
  warn("-------OnSReplaceEquipSkillRes")
  local equipEffectResetPanel = EquipEffectResetPanel.Instance()
  if equipEffectResetPanel.m_panel and false == equipEffectResetPanel.m_panel.isnil and equipEffectResetPanel:IsShow() then
    equipEffectResetPanel:setSelectedEquipInfo()
    if equipEffectResetPanel.replaceTips ~= "" then
      Toast(equipEffectResetPanel.replaceTips)
    end
  end
end
def.static("table", "table").OnItemGoldChange = function(p1, p2)
  local equipEffectResetPanel = EquipEffectResetPanel.Instance()
  if equipEffectResetPanel.m_panel and false == equipEffectResetPanel.m_panel.isnil and equipEffectResetPanel:IsShow() then
    equipEffectResetPanel:setMoneyInfo()
  end
end
def.static("table", "table").OnEquipBlessNotifyChange = function(p1, p2)
  local self = instance
  if not _G.IsNil(self._dlg) and not _G.IsNil(self._dlg.m_panel) then
    self._dlg:UpdateTapState()
  end
  Event.DispatchEvent(ModuleId.EQUIP, gmodule.notifyId.Equip.Equip_NewFunction_ChangeState, nil)
end
EquipModule.Commit()
return EquipModule
