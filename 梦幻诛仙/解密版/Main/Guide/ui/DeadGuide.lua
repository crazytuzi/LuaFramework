local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local GUIUtils = require("GUI.GUIUtils")
local GuideUtils = require("Main.Guide.GuideUtils")
local FunType = require("consts.mzm.gsp.guide.confbean.FunType")
local AdvanceType = require("consts.mzm.gsp.guide.confbean.AdvanceType")
local Vector = require("Types.Vector")
local DeadGuide = Lplus.Extend(ECPanelBase, "DeadGuide")
local def = DeadGuide.define
def.field("table").deadAdv = nil
local instance
def.static("=>", DeadGuide).Instance = function()
  if instance == nil then
    instance = DeadGuide()
    instance.deadAdv = {}
  end
  return instance
end
def.static().ShowDeadGuide = function()
  local deadGuide = DeadGuide.Instance()
  if deadGuide.m_panel then
    deadGuide:DestroyPanel()
  end
  deadGuide:FilterDeadGuide()
  if #deadGuide.deadAdv > 0 then
    deadGuide:CreatePanel(RESPATH.PREFAB_DEAD_GUIDE, 1)
  end
end
def.static().CloseDeadGuide = function()
  local deadGuide = DeadGuide.Instance()
  if deadGuide.m_panel then
    deadGuide:DestroyPanel()
  end
end
def.override().OnCreate = function(self)
  self:UpdateButtons()
end
def.method().FilterDeadGuide = function(self)
  local GuideModule = require("Main.Guide.GuideModule")
  local deads = GuideUtils.GetDieAdvanceCfg()
  local deadtbl = {}
  for k, v in ipairs(deads) do
    local type = v.func
    local canAdd = false
    if type == AdvanceType.EQUIP then
      canAdd = GuideModule.Instance():CheckFunction(FunType.EQUIP)
    elseif type == AdvanceType.MENPAI then
      canAdd = GuideModule.Instance():CheckFunction(FunType.SKILL)
      if canAdd then
        local SkillModule = require("Main.Skill.SkillModule")
        canAdd = SkillModule.Instance():CanEnhanceSkillFunc(SkillModule.SkillFuncType.Occupation)
      end
    elseif type == AdvanceType.XIULIAN then
      canAdd = GuideModule.Instance():CheckFunction(FunType.SKILL)
      if canAdd then
        local SkillModule = require("Main.Skill.SkillModule")
        canAdd = SkillModule.Instance():CanEnhanceSkillFunc(SkillModule.SkillFuncType.Exercise)
      end
    elseif type == AdvanceType.PET then
      local PetModule = require("Main.Pet.PetModule")
      canAdd = PetModule.Instance():IsFightingPetCanAssignProp()
    elseif type == AdvanceType.XIANLV then
      canAdd = GuideModule.Instance():CheckFunction(FunType.XIANLV)
    end
    if canAdd then
      local info = {}
      info.name = v.name
      info.func = v.func
      info.icon = v.iconid
      table.insert(deadtbl, info)
    end
  end
  self.deadAdv = deadtbl
end
def.method().UpdateButtons = function(self)
  local uiList = self.m_panel:FindDirect("Img_Bg1/Scroll View/List"):GetComponent("UIList")
  uiList:set_itemCount(#self.deadAdv)
  uiList:Resize()
  GameUtil.AddGlobalLateTimer(0, true, function()
    uiList:Reposition()
  end)
  local allWays = uiList:get_children()
  for i = 1, #allWays do
    local item = allWays[i]
    local info = self.deadAdv[i]
    local icon = item:FindDirect(string.format("Img_Icon_%d", i)):GetComponent("UITexture")
    GUIUtils.FillIcon(icon, info.icon)
    local name = item:FindDirect(string.format("Label_%d", i)):GetComponent("UILabel")
    name:set_text(info.name)
  end
  self:TouchGameObject(self.m_panel, self.m_parent)
end
def.method("string").onClick = function(self, id)
  if id == "Btn_Close" then
    self:DestroyPanel()
  elseif string.find(id, "Img_BgIcon1_") then
    local index = tonumber(string.sub(id, 13))
    local info = self.deadAdv[index]
    if info.func == AdvanceType.EQUIP then
      Event.DispatchEvent(ModuleId.MAINUI, gmodule.notifyId.MainUI.BTN_EQUIPMENT_CLICK, nil)
    elseif info.func == AdvanceType.MENPAI then
      local SkillModule = require("Main.Skill.SkillModule")
      Event.DispatchEvent(ModuleId.SKILL, gmodule.notifyId.Skill.REQ_OPEN_SKILL_PANEL, {
        SkillModule.SkillFuncType.Occupation
      })
    elseif info.func == AdvanceType.XIULIAN then
      local SkillModule = require("Main.Skill.SkillModule")
      Event.DispatchEvent(ModuleId.SKILL, gmodule.notifyId.Skill.REQ_OPEN_SKILL_PANEL, {
        SkillModule.SkillFuncType.Exercise
      })
    elseif info.func == AdvanceType.PET then
      Event.DispatchEvent(ModuleId.MAINUI, gmodule.notifyId.MainUI.BTN_PET_PROP_CLICK, nil)
    elseif info.func == AdvanceType.XIANLV then
      Event.DispatchEvent(ModuleId.MAINUI, gmodule.notifyId.MainUI.BTN_PARTNER_CLICK, nil)
    end
  end
end
DeadGuide.Commit()
return DeadGuide
