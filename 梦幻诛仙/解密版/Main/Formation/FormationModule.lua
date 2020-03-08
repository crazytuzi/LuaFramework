local Lplus = require("Lplus")
local ModuleBase = require("Main.module.ModuleBase")
require("Main.module.ModuleId")
local FormationModule = Lplus.Extend(ModuleBase, "FormationModule")
local def = FormationModule.define
local DlgFormation = require("Main.Formation.ui.DlgFormation")
local FormationUtils = require("Main.Formation.FormationUtils")
local ItemModule = require("Main.Item.ItemModule")
local _instance
def.field("table").formations = nil
def.field(DlgFormation)._dlg = nil
def.static("=>", FormationModule).Instance = function()
  if _instance == nil then
    _instance = FormationModule()
    _instance.m_moduleId = ModuleId.FORMATION
  end
  return _instance
end
def.override().Init = function(self)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.zhenfa.SSyncAllZhenfaInfo", FormationModule._onAllFormation)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.zhenfa.SResZhenfaInfo", FormationModule._onFormationUpdate)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.zhenfa.SZhenfaErrorInfo", FormationModule._onFormationError)
  self.formations = {}
  Event.RegisterEvent(ModuleId.LOGIN, gmodule.notifyId.Login.LEAVE_WORLD, function()
    self:Reset()
  end)
  ModuleBase.Init(self)
end
def.override().OnReset = function(self)
  self.formations = {}
end
def.static("table")._onAllFormation = function(p)
  print("_onAllFormation")
  _instance.formations = {}
  for k, v in pairs(p.ZhenfaBeanList) do
    _instance.formations[v.zhenfaId] = {
      level = v.level,
      exp = v.exp
    }
  end
end
def.static("table")._onFormationUpdate = function(p)
  print("_onFormationUpdate")
  local name = FormationUtils.GetFormationCfg(p.zhenfaBean.zhenfaId).name
  if _instance.formations[p.zhenfaBean.zhenfaId] == nil then
    Toast(string.format(textRes.Formation[4], name))
  elseif _instance.formations[p.zhenfaBean.zhenfaId].level < p.zhenfaBean.level then
    Toast(string.format(textRes.Formation[5], name))
    SafeLuckDog(function()
      return true
    end)
  elseif _instance.formations[p.zhenfaBean.zhenfaId].level == p.zhenfaBean.level and _instance.formations[p.zhenfaBean.zhenfaId].exp < p.zhenfaBean.exp then
    Toast(string.format(textRes.Formation[6], p.zhenfaBean.exp - _instance.formations[p.zhenfaBean.zhenfaId].exp))
  end
  _instance.formations[p.zhenfaBean.zhenfaId] = {
    level = p.zhenfaBean.level,
    exp = p.zhenfaBean.exp
  }
  GameUtil.AddGlobalTimer(1, true, function()
    if _instance._dlg.m_panel ~= nil then
      _instance._dlg:UpdateAll()
    end
  end)
end
def.static("table")._onFormationError = function(p)
  print("_onFormationError:" .. p.resCode)
end
def.method("number", "=>", "number").GetFormationLevel = function(self, formationId)
  local level = 0
  local formation = self.formations[formationId]
  if formation ~= nil then
    level = formation.level
  end
  return level
end
def.method("number", "=>", "number").GetFormationExp = function(self, formationId)
  local exp = 0
  local formation = self.formations[formationId]
  if formation ~= nil then
    exp = formation.exp
  end
  return exp
end
def.method("number", "=>", "table").GetFormationInfo = function(self, formationId)
  return _instance:GetFormationInfoAtLevel(formationId, -1)
end
def.method("number", "number", "=>", "table").GetFormationInfoAtLevel = function(self, formationId, level)
-- fail 147
null
21
-- fail 156
null
21
  local FormationConst = FormationUtils.GetFormationConst()
  local formationCfg = FormationUtils.GetFormationCfg(formationId)
  if formationCfg == nil then
    return nil
  end
  local info = {}
  info.id = formationId
  info.name = formationCfg.name
  info.level = level <= 0 and self:GetFormationLevel(formationId) or level
  info.icon = formationCfg.icon
  info.backIcon = formationCfg.backIcon
  info.Effect = {}
  if info.level > 0 then
    for i = 1, 5 do
      local aName = ""
      local aValue = 0
      local aValueStr = ""
      local bName = ""
      local bValue = 0
      local bValueStr = ""
      local aPropCfg = 0 < formationCfg.effectInfo[i].AEffect and GetCommonPropNameCfg(formationCfg.effectInfo[i].AEffect) or nil
      local bPropCfg = 0 < formationCfg.effectInfo[i].BEffect and GetCommonPropNameCfg(formationCfg.effectInfo[i].BEffect) or nil
      if aPropCfg then
        aValue = (formationCfg.effectInfo[i].AInit + (info.level - FormationConst.initLevel) * formationCfg.effectInfo[i].AGrow) / 100
        aName = aPropCfg.propName
        if not (aValue >= 0) or not string.format("+%.1f%%", aValue) then
        end
        aValueStr = aName .. " " .. string.format("%.1f%%", aValue)
      end
      if bPropCfg then
        bValue = (formationCfg.effectInfo[i].BInit + (info.level - FormationConst.initLevel) * formationCfg.effectInfo[i].BGrow) / 100
        bName = bPropCfg.propName
        if not (bValue >= 0) or not string.format("+%.1f%%", bValue) then
        end
        bValueStr = bName .. " " .. string.format("%.1f%%", bValue)
      end
      local desc = aValueStr .. " " .. bValueStr
      info.Effect[i] = {
        EffectA = {
          name = aName,
          value = aValue,
          str = aValueStr,
          isGood = aPropCfg.isGood
        },
        EffectB = {
          name = bName,
          value = bValue,
          str = bValueStr,
          isGood = bPropCfg.isGood
        },
        desc = desc
      }
    end
  else
    warn("\228\189\160\230\178\161\230\156\137\229\173\166\228\188\154\232\191\153\228\184\170\233\152\181\230\179\149\230\151\182\239\188\140\228\184\141\232\166\129\232\176\131\231\148\168\232\191\153\228\184\170\229\135\189\230\149\176")
  end
  info.KZInfo = {}
  for k, v in pairs(formationCfg.KZInfo) do
    info.KZInfo[k] = {}
    local kzformationCfg = FormationUtils.GetFormationCfg(k)
    info.KZInfo[k].name = kzformationCfg.name
    info.KZInfo[k].icon = kzformationCfg.icon
    info.KZInfo[k].value = v.value
  end
  info.BKInfo = {}
  for k, v in pairs(formationCfg.BKInfo) do
    info.BKInfo[k] = {}
    local bkformationCfg = FormationUtils.GetFormationCfg(k)
    info.BKInfo[k].name = bkformationCfg.name
    info.BKInfo[k].icon = bkformationCfg.icon
    info.BKInfo[k].value = v.value
  end
  return info
end
def.method("number", "number", "function").ShowFormationDlg = function(self, openFormation, selectFormation, formationToggleCallback)
  if self._dlg == nil then
    self._dlg = DlgFormation()
  end
  self._dlg:SelectFormation(selectFormation)
  self._dlg:OpenFormation(openFormation)
  self._dlg:SetToggleCallback(formationToggleCallback)
  if self.formations ~= nil then
    self._dlg:CreatePanel(RESPATH.FORMATION_DLG, 1)
    self._dlg.m_TrigGC = true
  end
end
def.method("number").LearnFormationById = function(self, formationId)
  local learnFormation = require("netio.protocol.mzm.gsp.zhenfa.CReqStudyZhenfa").new(formationId)
  gmodule.network.sendProtocol(learnFormation)
end
def.method("table", "number").AdvanceFormation = function(self, items, formationId)
  local itemList = {}
  local NeedItemBean = require("netio.protocol.mzm.gsp.zhenfa.NeedItemBean")
  for k, v in ipairs(items) do
    if v.select > 0 then
      table.insert(itemList, NeedItemBean.new(v.id, v.select))
    end
  end
  if #itemList > 0 then
    local advanceformation = require("netio.protocol.mzm.gsp.zhenfa.CReqZhenfaAddExp").new(formationId, itemList)
    gmodule.network.sendProtocol(advanceformation)
  else
    Toast(textRes.Formation[16])
  end
end
def.method("=>", "boolean").IsAnyThingAboutFormationInBag = function(self)
  local ItemType = require("consts.mzm.gsp.item.confbean.ItemType")
  local key, item = ItemModule.Instance():SelectOneItemByItemType(ItemModule.BAG, ItemType.ZHENFA_FRAGMENT_ITEM)
  if key >= 0 then
    return true
  end
  key, item = ItemModule.Instance():SelectOneItemByItemType(ItemModule.BAG, ItemType.ZHENFA_ITEM)
  if key >= 0 then
    return true
  end
  return false
end
def.method("=>", "table", "table").GetSepFormationList = function(self)
  local learnedList = {}
  local unlearnList = {}
  local formations = FormationUtils.GetAllFormations()
  for k, v in pairs(formations) do
    if self.formations[k] ~= nil then
      learnedList[k] = v
    else
      unlearnList[k] = v
    end
  end
  return learnedList, unlearnList
end
FormationModule.Commit()
return FormationModule
