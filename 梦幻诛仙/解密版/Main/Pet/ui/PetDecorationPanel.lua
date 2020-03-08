local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local PetDecorationPanel = Lplus.Extend(ECPanelBase, "PetDecorationPanel")
local def = PetDecorationPanel.define
local EC = require("Types.Vector3")
local Vector3 = EC.Vector3
local Vector = require("Types.Vector")
local ECModel = require("Model.ECModel")
local PetUIModel = require("Main.Pet.PetUIModel")
local PetMgr = require("Main.Pet.mgr.PetMgr")
local PetData = Lplus.ForwardDeclare("PetData")
local PetUtility = require("Main.Pet.PetUtility")
local PetModule = require("Main.Pet.PetModule")
local GUIUtils = require("GUI.GUIUtils")
local ItemModule = require("Main.Item.ItemModule")
local PetType = require("consts.mzm.gsp.pet.confbean.PetType")
local EasyItemTipHelper = require("Main.Pet.EasyItemTipHelper")
local ItemUtils = require("Main.Item.ItemUtils")
local NOT_SET = -1
local NOT_SET = -1
def.field("userdata").petId = nil
def.field("table").model = nil
def.field("boolean").isDrag = false
def.field("boolean").canUseDecoration = false
def.field("table").decorationItemCfg = nil
def.field(EasyItemTipHelper).easyItemTipHelper = nil
def.field("userdata").ui_Img_Bg0 = nil
local instance
def.static("=>", PetDecorationPanel).Instance = function()
  if instance == nil then
    instance = PetDecorationPanel()
  end
  return instance
end
def.method().ShowPanel = function(self)
  if self:IsShow() then
    return
  end
  self:CreatePanel(RESPATH.PREFAB_PET_DECORATION_PANEL_RES, 1)
  self:SetModal(true)
end
def.override().OnCreate = function(self)
  self:InitUI()
  self:UpdateUI()
  Event.RegisterEvent(ModuleId.PET, gmodule.notifyId.Pet.PET_DECORATE_SUCCESS, PetDecorationPanel.OnPetDecorateSuccess)
  Event.RegisterEvent(ModuleId.ITEM, gmodule.notifyId.item.Item_OnBagInfoSynchronized, PetDecorationPanel.OnBagInfoSynchronized)
end
def.override("boolean").OnShow = function(self, s)
  if not s then
    return
  end
  self:ResumeModel()
end
def.override().OnDestroy = function(self)
  self.ui_Img_Bg0 = nil
  self.petId = nil
  self:DestroyModel()
  Event.UnregisterEvent(ModuleId.PET, gmodule.notifyId.Pet.PET_DECORATE_SUCCESS, PetDecorationPanel.OnPetDecorateSuccess)
  Event.UnregisterEvent(ModuleId.ITEM, gmodule.notifyId.item.Item_OnBagInfoSynchronized, PetDecorationPanel.OnBagInfoSynchronized)
  self.easyItemTipHelper = nil
end
def.method().InitUI = function(self)
  self.ui_Img_Bg0 = self.m_panel:FindDirect("Img_Bg0")
  self.easyItemTipHelper = EasyItemTipHelper()
end
def.method("string").onClick = function(self, id)
  print(string.format("%s click event: id = %s", tostring(self), id))
  if id == "Btn_Close" then
    self:DestroyPanel()
  elseif id == "Btn_Use" then
    self:OnUseButtonClick()
  elseif self.easyItemTipHelper:CheckItem2ShowTip(id) then
  end
end
def.method().OnUseButtonClick = function(self)
  if not self.canUseDecoration or not self.decorationItemCfg then
    Toast(textRes.Pet[85])
    return
  end
  local items = ItemModule.Instance():GetItemsByBagId(ItemModule.BAG)
  local itemKey = 0
  for key, item in pairs(items) do
    if item.id == self.decorationItemCfg.id then
      itemKey = key
      break
    end
  end
  PetMgr.Instance():EquipDecorateItemReq(self.petId, itemKey)
end
def.method("userdata").SetActivePet = function(self, petId)
  self.petId = petId
end
def.method().UpdateUI = function(self)
  if self.petId == nil then
    warn("not set pet")
    return
  end
  local pet = PetMgr.Instance():GetPet(self.petId)
  if pet == nil then
    warn("pet not exist id = ", self.petId)
    return
  end
  local pet = PetMgr.Instance():GetPet(self.petId)
  self.ui_Img_Bg0:FindDirect("Label_Name"):GetComponent("UILabel"):set_text(pet.name)
  PetUtility.SetYaoLiUIFromPet(self.ui_Img_Bg0:FindDirect("Img_BgPower"), pet)
  local Label_ChangeName = self.ui_Img_Bg0:FindDirect("Label_ChangeName")
  GUIUtils.SetActive(Label_ChangeName, true)
  if pet.extraModelCfgId ~= 0 then
    local displayModelInfo = ItemUtils.GetItemBase(pet.extraModelCfgId)
    if displayModelInfo ~= nil then
      GUIUtils.SetText(Label_ChangeName, string.format(textRes.Pet[218], displayModelInfo.name))
    else
      GUIUtils.SetText(Label_ChangeName, "")
    end
  else
    GUIUtils.SetText(Label_ChangeName, "")
  end
  self:LoadCfgData()
  self:UpdateQualityPreview()
  self:UpdateDecorationItem()
  self:UpdateModel()
end
def.method().LoadCfgData = function(self)
  local pet = PetMgr.Instance():GetPet(self.petId)
  local petCfgData = pet:GetPetCfgData()
  self.decorationItemCfg = PetUtility.GetPetDecorateItemCfg(petCfgData.decorateItemId)
end
def.method().UpdateModel = function(self)
  local pet = PetMgr.Instance():GetPet(self.petId)
  local objModel = self.ui_Img_Bg0:FindDirect("Img_Bg1/Model_Pet")
  local uiModel = objModel:GetComponent("UIModel")
  local boxCollider = objModel:GetComponent("BoxCollider")
  if boxCollider == nil then
    boxCollider = objModel:AddComponent("BoxCollider")
    boxCollider:set_size(Vector.Vector3.new(uiModel:get_width(), uiModel:get_height(), 0))
    uiModel:set_autoResizeBoxCollider(true)
    uiModel:set_depth(5)
    self:TouchGameObject(self.m_panel, self.m_parent)
  end
  local petCfgData = pet:GetPetCfgData()
  local modelResPath = GetModelPath(petCfgData.modelId)
  self:DestroyModel()
  self.model = PetUIModel.new(pet.typeId, uiModel)
  self.model:LoadDefault(nil)
  self.model:SetOrnament(true)
  self.model:SetCanExceedBound(true)
end
def.method().ResumeModel = function(self)
  if self.model then
    self.model:Play(ActionName.Stand)
  end
end
def.method().DestroyModel = function(self)
  if self.model ~= nil then
    self.model:Destroy()
    self.model = nil
  end
end
def.method("string").onDragStart = function(self, id)
  print("onDragStart", id)
  if id == "Model_Pet" then
    self.isDrag = true
  end
end
def.method("string").onDragEnd = function(self, id)
  self.isDrag = false
end
def.method("string", "number", "number").onDrag = function(self, id, dx, dy)
  if self.isDrag == true and self.model then
    self.model:SetDir(self.model.m_ang - dx / 2)
  end
end
def.method().UpdateQualityPreview = function(self)
  local pet = PetMgr.Instance():GetPet(self.petId)
  local addedValue = 0
  if self.decorationItemCfg then
    addedValue = self.decorationItemCfg.addRealAptMaxLimit
  end
  local PetQualityType = PetData.PetQualityType
  local petQuality = pet.petQuality
  local petCfgData = pet:GetPetCfgData()
  local function GetQualityTuple(petQualityType)
    return {
      value = petQuality:GetQuality(petQualityType) or 0,
      minValue = petCfgData:GetMinQuality(petQualityType) or 0,
      maxValue = petQuality:GetMaxQuality(petQualityType) or 0,
      addedValue = addedValue
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
  local ui_Img_BgAttribute = self.ui_Img_Bg0:FindDirect("Img_BgAttribute")
  for i, v in ipairs(qualityTable) do
    local slider = ui_Img_BgAttribute:FindDirect("Slider_Attribute0" .. i)
    local label = GUIUtils.FindDirect(slider, "Label_AttributeSlider0" .. i)
    local value = v.value + v.addedValue
    local minValue = v.minValue
    local maxValue = v.maxValue + v.addedValue
    local progress = 0
    if value and maxValue and minValue then
      progress = PetUtility.GetPetQualityProgress(value, minValue, maxValue)
    end
    GUIUtils.SetProgress(slider, "UIProgressBar", progress)
    local valueText = string.format("%d/%d", v.value + v.addedValue, v.maxValue + v.addedValue)
    local addedValue = v.addedValue
    if addedValue and addedValue > 0 then
      local addedText = string.format(textRes.Common[20], addedValue)
      local coloredText = string.format(textRes.Common[29], addedText)
      valueText = string.format("%s    %s", valueText, coloredText)
    end
    GUIUtils.SetText(label, valueText)
  end
end
def.method().UpdateDecorationItem = function(self)
  local itemId = 0
  if self.decorationItemCfg then
    itemId = self.decorationItemCfg.id
  end
  local ItemModule = require("Main.Item.ItemModule")
  local count = ItemModule.Instance():GetItemCountById(itemId)
  local itemBase = require("Main.Item.ItemUtils").GetItemBase(itemId)
  local iconId = itemBase.icon
  local useItemNum = 1
  local amountText = _G.GetFormatItemNumString(count, useItemNum)
  if count == 0 then
    self.canUseDecoration = false
  else
    self.canUseDecoration = true
  end
  self.ui_Img_Bg0:FindDirect("Label_Item01"):GetComponent("UILabel"):set_text(itemBase.name)
  local ui_Img_Item01 = self.ui_Img_Bg0:FindDirect("Img_Item01")
  ui_Img_Item01:FindDirect("Label_Num01"):GetComponent("UILabel"):set_text(amountText)
  local uiTexture = ui_Img_Item01:FindDirect("Img_Icon01"):GetComponent("UITexture")
  require("GUI.GUIUtils").FillIcon(uiTexture, iconId)
  local clickedObj = uiTexture.gameObject.transform.parent.gameObject
  self.easyItemTipHelper:RegisterItem2ShowTip(itemId, clickedObj)
end
def.static("table", "table").OnBagInfoSynchronized = function()
  instance:UpdateDecorationItem()
end
def.static("table", "table").OnPetDecorateSuccess = function()
  local self = instance
  local pet = PetMgr.Instance():GetPet(self.petId)
  local petCfgData = pet:GetPetCfgData()
  local color = PetUtility.GetPetTypeColor(petCfgData.type)
  local coloredPetName = string.format("<font color=#%s>%s</font>", color, pet.name)
  Toast(string.format(textRes.Pet[75], coloredPetName))
  self:DestroyPanel()
end
return PetDecorationPanel.Commit()
