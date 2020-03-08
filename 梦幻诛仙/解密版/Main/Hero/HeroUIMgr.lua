local MODULE_NAME = (...)
local Lplus = require("Lplus")
local ModuleBase = require("Main.module.ModuleBase")
local HeroUIMgr = Lplus.Class("HeroUIMgr")
local PersonalHelper = require("Main.Chat.PersonalHelper")
local def = HeroUIMgr.define
local UISet = {
  HeroProp = "HeroPropPanel",
  HeroEnergy = "HeroEnergyPanel",
  HeroAssignProp = "HeroAssignPropPanel"
}
def.const("table").UISet = UISet
def.field("string").modulePrefix = ""
local instance
def.static("=>", HeroUIMgr).Instance = function()
  if instance == nil then
    instance = HeroUIMgr()
  end
  return instance
end
def.method().Init = function(self)
  self:InitModulePrefix()
  Event.RegisterEvent(ModuleId.HERO, gmodule.notifyId.Hero.HERO_ENERGY_CHANGED, HeroUIMgr.OnHeroEnergyChanged)
  Event.RegisterEvent(ModuleId.HERO, gmodule.notifyId.Hero.HERO_ENERGY_IS_FULL, HeroUIMgr.OnEnergyFull)
  Event.RegisterEvent(ModuleId.HERO, gmodule.notifyId.Hero.HERO_ENERGY_NEARLY_FULL, HeroUIMgr.OnEnergyNearlyFull)
  Event.RegisterEvent(ModuleId.ACTIVITY, gmodule.notifyId.activity.Activity_Active, HeroUIMgr.OnOpenEnergyPanelReq)
  Event.RegisterEvent(ModuleId.HERO, gmodule.notifyId.Hero.OPEN_ENERGY_PANEL, HeroUIMgr.OnOpenEnergyPanelReq)
  Event.RegisterEvent(ModuleId.HERO, gmodule.notifyId.Hero.HERO_FIGHT_VALUE_CHANGED, HeroUIMgr.OnFightValueChanged)
  Event.RegisterEvent(ModuleId.HERO, gmodule.notifyId.Hero.OPEN_ASSIGN_PROP_PANEL, HeroUIMgr.OnOpenAssignPropPanelReq)
  Event.RegisterEvent(ModuleId.HERO, gmodule.notifyId.Hero.HERO_RENAME_SUCCESS, HeroUIMgr.OnRenameSuccess)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.role.SUseExpItemRes", HeroUIMgr.OnSUseExpItemRes)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.role.SVigorWorkRes", HeroUIMgr.OnSVigorWorkRes)
end
def.method().InitModulePrefix = function(self)
  local sPos, ePos = string.find(MODULE_NAME, ".[%w_]+$")
  self.modulePrefix = string.sub(MODULE_NAME, 1, sPos - 1)
end
def.method("string", "=>", "table").GetUI = function(self, uiName)
  return require(self.modulePrefix .. ".ui." .. uiName)
end
def.static("table", "table").OnHeroEnergyChanged = function(params)
  local energy, lastEnergy = unpack(params)
  local delta = energy - lastEnergy
  if delta > 0 then
    local text = string.format(textRes.Hero[39], delta)
    PersonalHelper.CommonMsg(PersonalHelper.Type.Text, text)
  end
end
def.static("table", "table").OnEnergyFull = function()
  PersonalHelper.CommonMsg(PersonalHelper.Type.Text, textRes.Hero[24])
end
def.static("table", "table").OnEnergyNearlyFull = function()
  PersonalHelper.CommonMsg(PersonalHelper.Type.Text, textRes.Hero[23])
end
def.static("table", "table").OnOpenEnergyPanelReq = function()
  local self = instance
  self:GetUI(UISet.HeroEnergy).Instance():ShowPanel()
end
def.static("table", "table").OnFightValueChanged = function(params)
  local from, to = params.lastFightValue, params.fightValue
  require("Main.Common.OutFightDo").Instance():Do(function()
    GameUtil.AddGlobalTimer(0, true, function()
      require("Main.Hero.ui.HeroFightValueTip").Instance():ShowTip(from, to)
    end)
    SafeLuckDog(function()
      local MathHelper = require("Common.MathHelper")
      return MathHelper.Between(from, to, 10000) or MathHelper.Between(from, to, 20000) or MathHelper.Between(from, to, 30000)
    end)
  end, nil)
end
def.static("table").OnSUseExpItemRes = function(data)
  local addExp = data.addExp
  PersonalHelper.GetExpMsg(addExp)
  local itemId = data.itemId or 0
  local ItemUtils = require("Main.Item.ItemUtils")
  local itemBase = ItemUtils.GetItemBase(itemId)
  local itemName = "nil"
  if itemBase then
    itemName = itemBase.name
    local namecolor = itemBase.namecolor
    local HtmlHelper = require("Main.Chat.HtmlHelper")
    local color = HtmlHelper.NameColor[namecolor]
    itemName = string.format("<font color=#%s>%s</font>", color, itemName)
  end
  local text = string.format(textRes.Hero[60], itemName, data.usedNum, data.leftNum)
  Toast(text)
end
def.static("table").OnSVigorWorkRes = function(data)
  local ItemModule = require("Main.Item.ItemModule")
  local addSilver = data.addSilver
  PersonalHelper.GetMoneyMsg(ItemModule.MONEY_TYPE_SILVER, tostring(addSilver))
end
def.static("table", "table").OnOpenAssignPropPanelReq = function()
  local self = instance
  self:GetUI(UISet.HeroAssignProp).Instance():ShowPanel()
end
def.static("table", "table").OnRenameSuccess = function()
  local CommonRenamePanel = require("GUI.CommonRenamePanel").Instance()
  CommonRenamePanel:HidePanel()
end
def.static().OpenHeroBianqingDlg = function()
  require("GUI.ECGUIMan").Instance():DestroyUIAtLevel(1)
  local StrongerType = require("consts.mzm.gsp.grow.confbean.StrongerType")
  require("Main.Grow.GrowUIMgr").OpenBianqiangPanel(StrongerType.MAJOR_GROW)
end
return HeroUIMgr.Commit()
