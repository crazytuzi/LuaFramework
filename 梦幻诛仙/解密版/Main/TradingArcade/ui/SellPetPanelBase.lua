local MODULE_NAME = (...)
local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local SellPetPanelBase = Lplus.Extend(ECPanelBase, MODULE_NAME)
local GUIUtils = require("GUI.GUIUtils")
local ItemUtils = require("Main.Item.ItemUtils")
local SellServiceMgr = require("Main.TradingArcade.SellServiceMgr")
local TradingArcadeUtils = require("Main.TradingArcade.TradingArcadeUtils")
local TradingArcadeProtocol = require("Main.TradingArcade.TradingArcadeProtocol")
local CommonDigitalKeyboard = require("GUI.CommonDigitalKeyboard")
local ItemTipsMgr = require("Main.Item.ItemTipsMgr")
local PetUtility = require("Main.Pet.PetUtility")
local PetData = require("Main.Pet.data.PetData")
local def = SellPetPanelBase.define
def.field("table").m_pet = nil
def.field("table").m_uiGOs = nil
def.field("number").m_price = 0
def.field("number").m_num = 0
def.field("number").m_maxNum = 0
def.field("number").m_minPrice = 0
def.field("number").m_maxPrice = 0
def.field("number").m_onSellMinPrice = 0
def.field("number").m_onSellMaxPrice = 0
def.method("userdata").onClickObj = function(self, obj)
  local id = obj.name
  local linkText = obj:GetComponent("NGUILinkText")
  if linkText then
    self:HandleLinkText(linkText)
  elseif string.find(id, "Img_BgSkill") then
    self:OnSkillIconClick(obj)
  else
    self:onClick(id)
  end
end
def.method("string").onClick = function(self, id)
  if id == "Btn_Close" then
    self:DestroyPanel()
  elseif id == "Modal" then
    self:DestroyPanel()
  elseif id == "Btn_Cancel" then
    self:OnCancelBtnClick()
  elseif id == "Btn_Sell" then
    self:OnSellBtnClick()
  elseif id == "Img_BgPrice" then
    self:OnPriceLabelClick()
  end
end
def.override().OnCreate = function(self)
  if self.m_panel == nil then
    return
  end
  self:InitUI()
  self:UpdateUI()
  self:LightingPriceLabel()
end
def.override().OnDestroy = function(self)
  self.m_uiGOs = nil
  self.m_pet = nil
end
def.virtual().OnSellBtnClick = function(self)
end
def.virtual().OnCancelBtnClick = function(self)
end
def.virtual().InitUI = function(self)
  self.m_uiGOs = {}
  self.m_uiGOs.Img_Bg0 = self.m_panel:FindDirect("Img_Bg0")
  self.m_uiGOs.Group_Info = self.m_uiGOs.Img_Bg0:FindDirect("Group_Info")
  self.m_uiGOs.Img_BgRightItem = self.m_uiGOs.Group_Info:FindDirect("Img_BgRightItem")
  self.m_uiGOs.Texture_RightIcon = self.m_uiGOs.Img_BgRightItem:FindDirect("Texture_RightIcon")
  self.m_uiGOs.Label_Name = self.m_uiGOs.Group_Info:FindDirect("Label_Name")
  self.m_uiGOs.Label_Level = self.m_uiGOs.Group_Info:FindDirect("Label_Level")
  self.m_uiGOs.Img_BgPrice = self.m_uiGOs.Group_Info:FindDirect("Group_Price/Img_BgPrice")
  self.m_uiGOs.Label_Price = self.m_uiGOs.Img_BgPrice:FindDirect("Label_Price")
  self.m_uiGOs.Label_Tax = self.m_uiGOs.Group_Info:FindDirect("Group_Tax/Img_BgTax/Label_Tax")
  self.m_uiGOs.Group_PriceLimt = self.m_uiGOs.Group_Info:FindDirect("Group_PriceLimt")
  self.m_uiGOs.Label_LowLimit = self.m_uiGOs.Group_PriceLimt:FindDirect("Label_LowLimit")
  self.m_uiGOs.Label_UpLimit = self.m_uiGOs.Group_PriceLimt:FindDirect("Label_UpLimit")
  self.m_uiGOs.Label_Time = self.m_uiGOs.Group_Info:FindDirect("Group_ShowTime/Img_Bg/Label_Time")
  self.m_uiGOs.Group_Right = self.m_uiGOs.Img_Bg0:FindDirect("Group_Right")
  self.m_uiGOs.Group_Attribute = self.m_uiGOs.Group_Right:FindDirect("Group_Attribute")
  self.m_uiGOs.Group_GrowLabel = self.m_uiGOs.Group_Attribute:FindDirect("Label")
  self.m_uiGOs.Group_GrowLabel.name = "Group_GrowLabel"
  self.m_uiGOs.Label_Grow = self.m_uiGOs.Group_GrowLabel:FindDirect("Label")
  self.m_uiGOs.Group_LifeLabel = self.m_uiGOs.Group_Attribute:FindDirect("Label")
  self.m_uiGOs.Group_LifeLabel.name = "Group_LifeLabel"
  self.m_uiGOs.Label_Life = self.m_uiGOs.Group_LifeLabel:FindDirect("Label")
  self.m_uiGOs.Img_JN_BgAttribute = self.m_uiGOs.Group_Attribute:FindDirect("Img_JN_BgAttribute")
  self.m_uiGOs.Group_Skill = self.m_uiGOs.Group_Right:FindDirect("Group_Skill")
  self.m_uiGOs.HtmlLabel = self.m_uiGOs.Group_Skill:FindDirect("Img_Bg/Label")
  self.m_uiGOs.Grid_Skill = self.m_uiGOs.Group_Skill:FindDirect("Group_All/Scroll View/Grid")
  local boxCollider = self.m_uiGOs.Img_BgPrice:GetComponent("BoxCollider")
  if boxCollider == nil then
    boxCollider = self.m_uiGOs.Img_BgPrice:AddComponent("BoxCollider")
    local uiWidget = self.m_uiGOs.Img_BgPrice:GetComponent("UIWidget")
    uiWidget.autoResizeBoxCollider = true
    uiWidget:ResizeCollider()
    self.m_msgHandler:Touch(self.m_uiGOs.Img_BgPrice)
  end
  self.m_num = 1
  self.m_maxNum = 1
  local marketPetCfg = TradingArcadeUtils.GetMarketPetCfg(self.m_pet.typeId)
  self.m_minPrice = TradingArcadeUtils.GetPetOnSellMinPrice(self.m_pet)
  self.m_maxPrice = TradingArcadeUtils.GetPetOnSellMaxPrice(self.m_pet)
end
def.method().UpdateUI = function(self)
  local pet = self.m_pet
  local iconId = pet:GetHeadIconId()
  local bgSpriteName = pet:GetHeadIconBGSpriteName()
  GUIUtils.SetText(self.m_uiGOs.Label_Name, pet.name)
  GUIUtils.SetTexture(self.m_uiGOs.Texture_RightIcon, iconId)
  GUIUtils.SetSprite(self.m_uiGOs.Img_BgRightItem, bgSpriteName)
  local text = string.format(textRes.Common[3], pet.level)
  GUIUtils.SetText(self.m_uiGOs.Label_Level, text)
  self:SetGrowValue(pet)
  self:SetLife(pet)
  self:SetQualityValueFromPetData(pet)
  self:SetPetSkillList(pet)
  self:UpdatePrices()
  self:UpdatePublicTime()
  self:UpdateOnSellPriceRange()
end
def.method("table").SetGrowValue = function(self, pet)
  local viewData = PetUtility.GetPetGrowValueViewData(pet)
  local text = string.format("[%s]%s(%s)[-]", viewData.color, viewData.value, viewData.meaning)
  GUIUtils.SetText(self.m_uiGOs.Label_Grow, text)
end
def.method("table").SetLife = function(self, pet)
  local text = pet.life
  if pet:IsNeverDie() then
    text = textRes.Pet[45]
  end
  GUIUtils.SetText(self.m_uiGOs.Label_Life, text)
end
def.method("table").SetQualityValueFromPetData = function(self, pet)
  local PetQualityType = PetData.PetQualityType
  local petQuality = pet.petQuality
  local petCfgData = pet:GetPetCfgData()
  local function GetQualityTuple(petQualityType)
    return {
      value = petQuality:GetQuality(petQualityType) or 0,
      minValue = petCfgData:GetMinQuality(petQualityType) or 0,
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
  self:SetQualityValue(qualityTable)
end
def.method("table").SetQualityValue = function(self, qualityTable)
  if qualityTable == nil then
    local qualityCount = 6
    qualityTable = {}
    for i = 1, qualityCount do
      qualityTable[i] = {}
    end
  end
  for i, v in ipairs(qualityTable) do
    local ui_Slider = self.m_uiGOs.Img_JN_BgAttribute:FindDirect(string.format("Attribute%02d", i))
    local ui_Label = GUIUtils.FindDirect(ui_Slider, string.format("Label_JN_AttributeSlider%02d", i))
    local value, maxValue, minValue = v.value, v.maxValue, v.minValue
    local text = ""
    if value and maxValue then
      text = string.format("%d/%d", value, maxValue)
    end
    GUIUtils.SetText(ui_Label, text)
  end
end
def.method("table").SetPetSkillList = function(self, pet)
  local skillIdList = pet:GetSkillIdList()
  local grid = self.m_uiGOs.Grid_Skill
  if grid == nil then
    return
  end
  local gridItemCount = grid.childCount
  for i = 1, gridItemCount do
    local skillId = skillIdList[i]
    local objIndex = string.format("%02d", i)
    local itemObj = grid:GetChild(i - 1)
    local skillIconName = "Img_HS_IconSkill02_01"
    local IconSkill = itemObj:FindDirect(skillIconName)
    if skillId then
      local skillCfg = PetUtility.Instance():GetPetSkillCfg(skillId)
      if skillCfg.iconId == 0 then
        warn(string.format("skill(%s)'s iconId == 0", skillCfg.name))
      end
      GUIUtils.SetTexture(IconSkill, skillCfg.iconId)
      PetUtility.SetPetSkillBgColor(itemObj, skillId)
    else
      GUIUtils.SetTexture(IconSkill, 0)
      PetUtility.SetOriginPetSkillBg(itemObj, "Img_SkillFg")
    end
  end
end
def.virtual().UpdatePublicTime = function(self)
  local remainMinute = TradingArcadeUtils.GetCurrentPublicTime()
  local hour = require("Common.MathHelper").Floor(remainMinute / 60)
  local minute = remainMinute % 60
  local text = string.format(textRes.TradingArcade[16], hour, minute)
  GUIUtils.SetText(self.m_uiGOs.Label_Time, text)
end
def.virtual().UpdatePrices = function(self)
  TradingArcadeUtils.SetPriceLabel(self.m_uiGOs.Label_Price, self.m_price)
  local serviceCharge = self:GetServiceCharge()
  TradingArcadeUtils.SetPriceLabel(self.m_uiGOs.Label_Tax, serviceCharge)
end
def.method("=>", "number").GetTotalPrice = function(self)
  return self.m_price * self.m_num
end
def.method("=>", "number").GetServiceCharge = function(self)
  local totalPrice = self:GetTotalPrice()
  return SellServiceMgr.Instance():CalcServiceCharge(totalPrice)
end
def.method().FocusOnPriceLabel = function(self)
  self:LightingPriceLabel()
  self:ShowDigitalKeyboard()
end
def.method().LightingPriceLabel = function(self)
  local path = "panel_blackshopsellpet/Img_Bg0/Group_Info/Group_Price/Img_BgPrice"
  GUIUtils.AddLightEffectToPanel(path, GUIUtils.Light.Square)
end
def.method().OnPriceLabelClick = function(self)
  self:ShowDigitalKeyboard()
end
def.method().ShowDigitalKeyboard = function(self)
  CommonDigitalKeyboard.Instance():ShowPanelEx(self.m_maxPrice, function(val, tag)
    if self.m_panel and not self.m_panel.isnil then
      self.m_price = val
      self:UpdatePrices()
      if val == self.m_maxPrice then
        Toast(string.format(textRes.TradingArcade[13], self.m_maxPrice))
      end
    end
  end, nil)
  CommonDigitalKeyboard.Instance():SetPos(250, 0)
end
def.method().UpdateOnSellPriceRange = function(self)
  local lowText = self.m_onSellMinPrice
  if self.m_onSellMinPrice == 0 then
    lowText = ""
  end
  local highText = self.m_onSellMaxPrice
  if self.m_onSellMaxPrice == 0 then
    highText = ""
  end
  GUIUtils.SetText(self.m_uiGOs.Label_LowLimit, lowText)
  GUIUtils.SetText(self.m_uiGOs.Label_UpLimit, highText)
end
def.method("userdata").HandleLinkText = function(self, linkText)
  local skillId
  if getmetatable(linkText) then
    skillId = tonumber(linkText.linkText)
  end
  if skillId == nil then
    return
  end
  local level = self.m_pet.level
  local sourceObj = self.m_uiGOs.HtmlLabel.parent
  PetUtility.ShowPetSkillTipEx(skillId, level, sourceObj, 0, nil)
end
def.method("userdata").OnSkillIconClick = function(self, obj)
  local id = obj.name
  local index = tonumber(string.sub(id, #"Img_BgSkill" + 1, -1))
  if index == nil then
    warn(string.format("OnSkillIconClick %s, index is nil!!!", tostring(obj)))
    return
  end
  local skillIdList = self.m_pet:GetSkillIdList()
  local skillId = skillIdList[index]
  if skillId == nil then
    return
  end
  local level = self.m_pet.level
  local sourceObj = self.m_uiGOs.HtmlLabel.parent
  PetUtility.ShowPetSkillTipEx(skillId, level, sourceObj, 0, nil)
end
def.method("number").QueryPetPrices = function(self, petCfgId)
  TradingArcadeProtocol.CQueryPetPrice(petCfgId, function(p)
    if p.petCfgId ~= petCfgId then
      return
    end
    self.m_onSellMinPrice = p.prices[1] or ""
    self.m_onSellMaxPrice = p.prices[2] or ""
    if self.m_panel == nil or self.m_panel.isnil then
      return
    end
    self:UpdateOnSellPriceRange()
  end)
end
return SellPetPanelBase.Commit()
