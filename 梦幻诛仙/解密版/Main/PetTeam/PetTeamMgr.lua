local Lplus = require("Lplus")
local PetTeamData = require("Main.PetTeam.data.PetTeamData")
local ModuleFunSwitchInfo = require("netio.protocol.mzm.gsp.open.ModuleFunSwitchInfo")
local PetTeamModule = require("Main.PetTeam.PetTeamModule")
local PetTeamMgr = Lplus.Class("PetTeamMgr")
local def = PetTeamMgr.define
local instance
def.static("=>", PetTeamMgr).Instance = function()
  if instance == nil then
    instance = PetTeamMgr()
  end
  return instance
end
def.method().Init = function(self)
  Event.RegisterEvent(ModuleId.FEATURE, gmodule.notifyId.Feature.FeatureOpenChange, PetTeamMgr.OnFunctionOpenChange)
  Event.RegisterEvent(ModuleId.LOGIN, gmodule.notifyId.Login.ENTER_WORLD, PetTeamMgr.OnEnterWorld)
  Event.RegisterEvent(ModuleId.LOGIN, gmodule.notifyId.Login.LEAVE_WORLD, PetTeamMgr.OnLeaveWorld)
  Event.RegisterEvent(ModuleId.HERO, gmodule.notifyId.Hero.HERO_LEVEL_UP, PetTeamMgr.OnHeroLevelUp)
  Event.RegisterEvent(ModuleId.ITEM, gmodule.notifyId.item.Item_OnBagInfoSynchronized, PetTeamMgr.OnBagChange)
  Event.RegisterEvent(ModuleId.PETTEAM, gmodule.notifyId.PetTeam.PETTEAM_USE_FORMATION_ITEM, PetTeamMgr.OnUseFormationItem)
end
def.static("table", "table").OnFunctionOpenChange = function(param, context)
  if param.feature == ModuleFunSwitchInfo.TYPE_PET_FIGHT then
    local bOpen = PetTeamModule.Instance():IsOpen(false)
    PetTeamModule.Instance():SetNewOpen(bOpen, true)
    if bOpen then
      local bUpgrade = PetTeamData.Instance():CanAnyFormationUpgrade(false)
      PetTeamModule.Instance():SetCanUpgrade(bUpgrade, false)
    end
    if not IsFeatureOpen(ModuleFunSwitchInfo.TYPE_PET_FIGHT) then
      local FormationPanel = require("Main.PetTeam.ui.FormationPanel")
      if FormationPanel.Instance():IsShow() then
        FormationPanel.Instance():DestroyPanel()
      end
      local OverallPanel = require("Main.PetTeam.ui.OverallPanel")
      if OverallPanel.Instance():IsShow() then
        OverallPanel.Instance():DestroyPanel()
      end
      local PetTeamPanel = require("Main.PetTeam.ui.PetTeamPanel")
      if PetTeamPanel.Instance():IsShow() then
        PetTeamPanel.Instance():DestroyPanel()
      end
      local PetFightSkillPanel = require("Main.PetTeam.ui.PetFightSkillPanel")
      if PetFightSkillPanel.Instance():IsShow() then
        PetFightSkillPanel.Instance():DestroyPanel()
      end
    end
  elseif param.feature == ModuleFunSwitchInfo.TYPE_PET_FIGHT_SKILL then
    local OverallPanel = require("Main.PetTeam.ui.OverallPanel")
    if OverallPanel.Instance():IsShow() then
      OverallPanel.Instance():DestroyPanel()
    end
    local PetFightSkillPanel = require("Main.PetTeam.ui.PetFightSkillPanel")
    if PetFightSkillPanel.Instance():IsShow() then
      PetFightSkillPanel.Instance():DestroyPanel()
    end
  end
end
def.static("table", "table").OnEnterWorld = function(param, context)
  local bOpen = PetTeamModule.Instance():IsOpen(false)
  if bOpen then
    local bUpgrade = PetTeamData.Instance():CanAnyFormationUpgrade(false)
    PetTeamModule.Instance():SetCanUpgrade(bUpgrade, false)
  end
end
def.static("table", "table").OnLeaveWorld = function(param, context)
  PetTeamModule.Instance():SetNewOpen(false, false)
  PetTeamModule.Instance():SetCanUpgrade(false, false)
  PetTeamData.Instance():OnLeaveWorld(param, context)
end
def.static("table", "table").OnHeroLevelUp = function(param, context)
  if param.level >= constant.CPetFightConsts.OPEN_LEVEL and param.lastLevel < constant.CPetFightConsts.OPEN_LEVEL then
    local bOpen = PetTeamModule.Instance():IsOpen(false)
    PetTeamModule.Instance():SetNewOpen(bOpen, true)
    if bOpen then
      local bUpgrade = PetTeamData.Instance():CanAnyFormationUpgrade(false)
      PetTeamModule.Instance():SetCanUpgrade(bUpgrade, false)
    end
  end
end
def.static("table", "table").OnBagChange = function(param, context)
  local bOpen = PetTeamModule.Instance():IsOpen(false)
  if bOpen then
    local bUpgrade = PetTeamData.Instance():CanAnyFormationUpgrade(false)
    PetTeamModule.Instance():SetCanUpgrade(bUpgrade, false)
  end
end
def.static("table", "table").OnUseFormationItem = function(param, context)
  if _G.CheckCrossServerAndToast() then
    return
  end
  local bOpen = PetTeamModule.Instance():IsOpen(false)
  if bOpen then
    local ItemModule = require("Main.Item.ItemModule")
    local bagId = param.bagId
    local itemKey = param.itemKey
    local itemInfo = ItemModule.Instance():GetItemByBagIdAndItemKey(bagId, itemKey)
    local formationId = 0
    if itemInfo then
      formationId = PetTeamData.Instance():GetFormationByItem(itemInfo.id)
    end
    local FormationPanel = require("Main.PetTeam.ui.FormationPanel")
    FormationPanel.ShowPanel(FormationPanel.ShowState.UPGRADE, formationId, nil)
  end
end
def.static("table", "table").OnClickMapFindpath = function(param, context)
  local PetTeamProtocols = require("Main.PetTeam.PetTeamProtocols")
end
PetTeamMgr.Commit()
return PetTeamMgr
