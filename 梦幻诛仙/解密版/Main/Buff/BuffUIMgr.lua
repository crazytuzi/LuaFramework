local MODULE_NAME = (...)
local Lplus = require("Lplus")
local ModuleBase = require("Main.module.ModuleBase")
local BuffUIMgr = Lplus.Class("BuffUIMgr")
local PetUtility = require("Main.Pet.PetUtility")
local PetMgr = require("Main.Pet.mgr.PetMgr")
local def = BuffUIMgr.define
local UISet = {
  BuffPanel = "BuffPanel",
  SupplementNutrition = "SupplementNutritionPanel"
}
def.const("table").UISet = UISet
def.field("string").modulePrefix = ""
local instance
def.static("=>", BuffUIMgr).Instance = function()
  if instance == nil then
    instance = BuffUIMgr()
    instance:Init()
  end
  return instance
end
def.method().Init = function(self)
  self:InitModulePrefix()
  Event.RegisterEvent(ModuleId.BUFF, gmodule.notifyId.Buff.REQ_SUPPLEMENT_NUTRITION_PANEL, BuffUIMgr.OnReqSupplementNutritionPanel)
  Event.RegisterEvent(ModuleId.BUFF, gmodule.notifyId.Buff.SUCCESS_SUPPLEMENT_NUTRITION, BuffUIMgr.OnSuccessSupplementNutrition)
  Event.RegisterEvent(ModuleId.BUFF, gmodule.notifyId.Buff.BUFF_INFO_UPDATE, BuffUIMgr.OnBuffInfoUpdate)
end
def.method().InitModulePrefix = function(self)
  local sPos, ePos = string.find(MODULE_NAME, ".[%w_]+$")
  self.modulePrefix = string.sub(MODULE_NAME, 1, sPos - 1)
end
def.method("string", "=>", "table").GetUI = function(self, uiName)
  return require(self.modulePrefix .. ".ui." .. uiName)
end
def.static("table", "table").OnReqSupplementNutritionPanel = function(...)
  instance:GetUI(UISet.SupplementNutrition).Instance():ShowPanel()
end
def.static("table", "table").OnSuccessSupplementNutrition = function(params)
  local value = params[1]
  Toast(string.format(textRes.Buff[10], value))
end
def.static("table", "table").OnBuffInfoUpdate = function(params)
  local buffId = params[1]
  local BuffMgr = require("Main.Buff.BuffMgr")
  if not gmodule.moduleMgr:GetModule(ModuleId.LOGIN).isEnteredWorld then
    return
  end
  if buffId ~= BuffMgr.NUTRITION_BUFF_ID then
    return
  end
  local nutritionBuffData = BuffMgr.Instance():GetBuff(buffId)
  if Int64.eq(nutritionBuffData.remainValue, 0) then
    BuffUIMgr.QuerySupplementNutrition()
  end
end
local dlg
def.static().QuerySupplementNutrition = function()
  if dlg and dlg.m_panel and not dlg.m_panel.isnil then
    return
  end
  local CommonConfirmDlg = require("GUI.CommonConfirmDlg")
  local message = textRes.Buff[12]
  dlg = CommonConfirmDlg.ShowConfirm("", message, BuffUIMgr.ConfirmSupplementCallback, {neededSilverMoney = neededSilverMoney})
end
def.static("number", "table").ConfirmSupplementCallback = function(state, tag)
  if state == 0 then
    return
  end
  Event.DispatchEvent(ModuleId.BUFF, gmodule.notifyId.Buff.REQ_SUPPLEMENT_NUTRITION_PANEL, nil)
end
return BuffUIMgr.Commit()
