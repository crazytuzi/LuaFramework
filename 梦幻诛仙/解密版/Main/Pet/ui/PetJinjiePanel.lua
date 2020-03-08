local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local PetJinjiePanel = Lplus.Extend(ECPanelBase, "PetJinjiePanel")
local def = PetJinjiePanel.define
local EC = require("Types.Vector3")
local Vector3 = EC.Vector3
local PetData = Lplus.ForwardDeclare("PetData")
local PetUtility = require("Main.Pet.PetUtility")
local PetModule = require("Main.Pet.PetModule")
local GUIUtils = require("GUI.GUIUtils")
local QualityType = require("netio.protocol.mzm.gsp.pet.CLianGuReq")
local ECModel = require("Model.ECModel")
local ItemModule = require("Main.Item.ItemModule")
local ItemUtils = require("Main.Item.ItemUtils")
local ItemTipsMgr = require("Main.Item.ItemTipsMgr")
def.const("number").NO_SKILL_ICON = 316
def.field(PetData).petData = nil
def.field("table").uiObjs = nil
def.field("number").preSkillId = 0
def.field("number").afterSkillId = 0
local instance
def.static("=>", PetJinjiePanel).Instance = function()
  if instance == nil then
    instance = PetJinjiePanel()
  end
  return instance
end
def.method(PetData, "=>", PetJinjiePanel).ShowPanel = function(self, petData)
  if instance.m_panel ~= nil then
    return
  end
  self.petData = petData
  self:CreatePanel(RESPATH.PREFAB_PET_JINJIE_PANEL, 1)
  self:SetModal(true)
  return self
end
def.override().OnCreate = function(self)
  if self:IsCanJinjie() then
    self:InitUI()
    self:SetPetJinjieData()
    self:SetCost()
    Event.RegisterEvent(ModuleId.ITEM, gmodule.notifyId.item.Item_OnBagInfoSynchronized, PetJinjiePanel.OnBagInfoSynchronized)
    Event.RegisterEvent(ModuleId.PET, gmodule.notifyId.Pet.PET_INFO_UPDATE, PetJinjiePanel.OnJinjieSuccess)
  else
    self:DestroyPanel()
  end
end
def.override().OnDestroy = function(self)
  self.petData = nil
  self.uiObjs = nil
  self.preSkillId = 0
  self.afterSkillId = 0
  Event.UnregisterEvent(ModuleId.ITEM, gmodule.notifyId.item.Item_OnBagInfoSynchronized, PetJinjiePanel.OnBagInfoSynchronized)
  Event.UnregisterEvent(ModuleId.PET, gmodule.notifyId.Pet.PET_INFO_UPDATE, PetJinjiePanel.OnJinjieSuccess)
end
def.method("=>", "boolean").IsCanJinjie = function(self)
  local pet = self.petData
  local curStage = pet.stageLevel
  local nextStageCfg = PetUtility.GetPetNextStateCfg(pet:GetPetCfgData().templateId, curStage)
  if nextStageCfg ~= nil then
    return true
  end
  return false
end
def.method().InitUI = function(self)
  self.uiObjs = {}
  self.uiObjs.Img_Bg0 = self.m_panel:FindDirect("Img_Bg0")
  self.uiObjs.Group_Skill_Pre = self.uiObjs.Img_Bg0:FindDirect("Group_Skill_Pre")
  self.uiObjs.Group_Skill_After = self.uiObjs.Img_Bg0:FindDirect("Group_Skill_After")
  self.uiObjs.Group_Attr_Pre = self.uiObjs.Img_Bg0:FindDirect("Group_Attr_Pre")
  self.uiObjs.Group_Attr_After = self.uiObjs.Img_Bg0:FindDirect("Group_Attr_After")
  self.uiObjs.Group_Grown_Pre = self.uiObjs.Img_Bg0:FindDirect("Group_Grown_Pre")
  self.uiObjs.Group_Grown_After = self.uiObjs.Img_Bg0:FindDirect("Group_Grown_After")
  self.uiObjs.Label_LevelLimited = self.uiObjs.Img_Bg0:FindDirect("Label_LevelLimited")
  self.uiObjs.Label_Current = self.uiObjs.Img_Bg0:FindDirect("Label_Current")
  self.uiObjs.Label_Next = self.uiObjs.Img_Bg0:FindDirect("Label_Next")
  self.uiObjs.Group_Cost = self.uiObjs.Img_Bg0:FindDirect("Group_Cost")
end
def.method().SetPetJinjieData = function(self)
  local pet = self.petData
  local petCfg = pet:GetPetCfgData()
  local petQuality = pet.petQuality
  local PetQualityType = PetData.PetQualityType
  local curStage = pet.stageLevel
  local nextStageCfg = PetUtility.GetPetNextStateCfg(pet:GetPetCfgData().templateId, curStage)
  GUIUtils.SetText(self.uiObjs.Label_LevelLimited, string.format(textRes.Pet[174], nextStageCfg.upStageNeedLevel))
  GUIUtils.SetText(self.uiObjs.Label_Current, string.format(textRes.Pet[175], curStage))
  GUIUtils.SetText(self.uiObjs.Label_Next, string.format(textRes.Pet[175], curStage + 1))
  self:SetPetGrownAttr(self.uiObjs.Group_Grown_Pre, petCfg, pet.growValue)
  self:SetPetGrownAttr(self.uiObjs.Group_Grown_After, petCfg, pet.growValue + nextStageCfg.growAddRate / 10000)
  local function GetQualityTuple(petQualityType)
    return {
      value = petQuality:GetQuality(petQualityType) or 0,
      minValue = petCfg:GetMinQuality(petQualityType) or 0,
      maxValue = petQuality:GetMaxQuality(petQualityType) or 0
    }
  end
  local qualityTable = {
    GetQualityTuple(PetQualityType.HP_APT),
    GetQualityTuple(PetQualityType.PHYATK_APT),
    GetQualityTuple(PetQualityType.MAGATK_APT),
    GetQualityTuple(PetQualityType.PHYDEF_APT),
    GetQualityTuple(PetQualityType.MAGDEF_APT),
    GetQualityTuple(PetQualityType.SPEED_APT)
  }
  local growValue = {
    nextStageCfg.hpAptAdd,
    nextStageCfg.phyAtkAptAdd,
    nextStageCfg.magAtkAptAdd,
    nextStageCfg.phyDefAptAdd,
    nextStageCfg.magDefAptAdd,
    nextStageCfg.speedAptAdd
  }
  self:SetPetAttribute(self.uiObjs.Group_Attr_Pre, qualityTable, nil)
  self:SetPetAttribute(self.uiObjs.Group_Attr_After, qualityTable, growValue)
  local curSpecialSkillId = PetUtility.GetPetStateSkillId(nextStageCfg.petJinJieSkillCfgId, curStage)
  local nextSpecialSkillId = nextStageCfg.skillId
  if pet:HasSkill(curSpecialSkillId) then
    self.preSkillId = curSpecialSkillId
    self.afterSkillId = nextSpecialSkillId
  else
    self.preSkillId = 0
    self.afterSkillId = 0
  end
  self:SetPetSkill(self.uiObjs.Group_Skill_Pre, self.preSkillId)
  self:SetPetSkill(self.uiObjs.Group_Skill_After, self.afterSkillId)
end
def.method("userdata", "table", "number").SetPetGrownAttr = function(self, group, petCfg, growValue)
  local Btn_Add = group:FindDirect("Btn_Add")
  local Label_GrownNum = group:FindDirect("Label_GrownNum")
  GUIUtils.SetActive(Btn_Add, false)
  local color = PetUtility.GetPetGrowValueColor(growValue, petCfg.growMinValue, petCfg.growMaxValue)
  local value = string.format("%.3f", growValue)
  local meaning = PetUtility.GetPetGrowValueMeaning(growValue, petCfg.growMinValue, petCfg.growMaxValue)
  local growStr = string.format("[%s]%s(%s)[-]", color, growValue, meaning)
  GUIUtils.SetText(Label_GrownNum, growStr)
end
def.method("userdata", "table", "table").SetPetAttribute = function(self, group, qualityTable, growValue)
  growValue = growValue or {}
  for i, v in ipairs(qualityTable) do
    local ui_Slider = group:FindDirect(string.format("Slider_Attribute%02d", i))
    local ui_Label = GUIUtils.FindDirect(ui_Slider, string.format("Label_AttributeSlider%02d", i))
    local growNum = growValue[i] or 0
    local value, maxValue, minValue = v.value + growNum, v.maxValue + growNum, v.minValue
    local progress = 0
    if value and maxValue and minValue then
      progress = PetUtility.GetPetQualityProgress(value, minValue, maxValue)
    end
    GUIUtils.SetProgress(ui_Slider, "UIProgressBar", progress)
    local text = ""
    if value and maxValue then
      if growNum ~= 0 then
        text = string.format(textRes.Pet[180], value, maxValue, growNum)
      else
        text = string.format(textRes.Pet[179], value, maxValue)
      end
    end
    GUIUtils.SetText(ui_Label, text)
  end
end
def.method("userdata", "number").SetPetSkill = function(self, group, skillId)
  local Label_SkillName = group:FindDirect("Label_SkillName")
  local Img_SkillBg = group:FindDirect("Img_SkillBg")
  local Img_SkillIcon = Img_SkillBg:FindDirect("Img_SkillIcon")
  local skillCfg = PetUtility.Instance():GetPetSkillCfg(skillId)
  if skillId ~= 0 and skillCfg ~= nil then
    GUIUtils.FillIcon(Img_SkillIcon:GetComponent("UITexture"), skillCfg.iconId)
    GUIUtils.SetText(Label_SkillName, skillCfg.name)
  else
    GUIUtils.SetText(Label_SkillName, textRes.Pet[176])
    GUIUtils.FillIcon(Img_SkillIcon:GetComponent("UITexture"), PetJinjiePanel.NO_SKILL_ICON)
  end
end
def.method().SetCost = function(self)
  local Btn_GoUp = self.uiObjs.Group_Cost:FindDirect("Btn_GoUp")
  local Img_CostIcon = self.uiObjs.Group_Cost:FindDirect("Img_CostIcon")
  local Img_SkillIcon = Img_CostIcon:FindDirect("Img_SkillIcon")
  local Label_CostNumber = Img_CostIcon:FindDirect("Label_CostNumber")
  local Label_CostName = Img_CostIcon:FindDirect("Label")
  local x = 1
  local pet = self.petData
  local curStage = pet.stageLevel
  local nextStageCfg = PetUtility.GetPetNextStateCfg(pet:GetPetCfgData().templateId, curStage)
  if nextStageCfg == nil then
    GUIUtils.SetText(Label_CostNumber, "0/0")
    return
  end
  local needItemList = ItemUtils.GetItemTypeRefIdList(nextStageCfg.itemType)
  if needItemList ~= nil then
    local needItemId = needItemList[1]
    local needItemType = nextStageCfg.itemType
    local itemBase = ItemUtils.GetItemBase(needItemId)
    local btnEnable = false
    if itemBase ~= nil then
      GUIUtils.FillIcon(Img_SkillIcon:GetComponent("UITexture"), itemBase.icon)
      local hasNum = 0
      local items = ItemModule.Instance():GetItemsByItemType(ItemModule.BAG, needItemType)
      for k, v in pairs(items) do
        hasNum = hasNum + v.number
      end
      local needNum = nextStageCfg.itemNum
      if hasNum < needNum then
        GUIUtils.SetText(Label_CostNumber, string.format("[ff0000]%d/%d[-]", hasNum, needNum))
      else
        GUIUtils.SetText(Label_CostNumber, string.format("%d/%d", hasNum, needNum))
        btnEnable = true
      end
      GUIUtils.SetText(Label_CostName, itemBase.name)
    end
    Btn_GoUp:GetComponent("UIButton"):set_isEnabled(btnEnable)
  end
end
def.method().Jinjie = function(self)
  if not IsFeatureOpen(require("netio.protocol.mzm.gsp.open.ModuleFunSwitchInfo").TYPE_PET_STAGE_LEVELUP) then
    Toast(textRes.Pet[183])
    return
  end
  local pet = self.petData
  local curStage = pet.stageLevel
  local nextStageCfg = PetUtility.GetPetNextStateCfg(pet:GetPetCfgData().templateId, curStage)
  if nextStageCfg == nil then
    return
  end
  if pet.level < nextStageCfg.upStageNeedLevel then
    Toast(string.format(textRes.Pet[173], nextStageCfg.upStageNeedLevel, nextStageCfg.stage))
    return
  end
  local needItemList = ItemUtils.GetItemTypeRefIdList(nextStageCfg.itemType)
  if needItemList == nil then
    return
  end
  local costItem = ItemUtils.GetItemBase(needItemList[1])
  if costItem == nil then
    return
  end
  local str = string.format(textRes.Pet[182], nextStageCfg.itemNum, costItem.name, pet.name)
  local CommonConfirmDlg = require("GUI.CommonConfirmDlg")
  CommonConfirmDlg.ShowConfirm(textRes.Pet[181], str, function(result)
    if result == 1 then
      require("Main.Pet.mgr.PetMgr").Instance():JinjieReq(pet.id, false, 0)
    end
  end, nil)
end
def.static("table", "table").OnBagInfoSynchronized = function()
  local self = instance
  self:SetCost()
end
def.static("table", "table").OnJinjieSuccess = function()
  local self = instance
  if self:IsCanJinjie() then
    self:SetPetJinjieData()
    self:SetCost()
  else
    local petName = self.petData.name
    Toast(string.format(textRes.Pet[178], petName))
    self:DestroyPanel()
  end
end
def.method("userdata").onClickObj = function(self, obj)
  local objName = obj.name
  if string.find(objName, "Img_SkillBg") then
    local parentName = obj.transform.parent.gameObject.name
    local skillId = 0
    if parentName == "Group_Skill_Pre" then
      skillId = self.preSkillId
    elseif parentName == "Group_Skill_After" then
      skillId = self.afterSkillId
    end
    if skillId ~= 0 then
      PetUtility.ShowPetSkillTip(skillId, obj, 0)
    end
  elseif objName == "Img_SkillIcon" then
    local pet = self.petData
    local curStage = pet.stageLevel
    local nextStageCfg = PetUtility.GetPetNextStateCfg(pet:GetPetCfgData().templateId, curStage)
    if nextStageCfg ~= nil then
      local needItemList = ItemUtils.GetItemTypeRefIdList(nextStageCfg.itemType)
      if needItemList ~= nil then
        local needItemId = needItemList[1]
        ItemTipsMgr.Instance():ShowBasicTipsWithGO(needItemId, obj.parent, 0, true)
      end
    end
  else
    self:onClick(objName)
  end
end
def.method("string").onClick = function(self, id)
  if id == "Btn_Close" then
    self:DestroyPanel()
  elseif id == "Btn_GoUp" then
    self:Jinjie()
  end
end
def.method().Clear = function(self)
end
return PetJinjiePanel.Commit()
