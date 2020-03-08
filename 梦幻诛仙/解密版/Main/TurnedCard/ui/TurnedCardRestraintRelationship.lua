local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local TurnedCardRestraintRelationship = Lplus.Extend(ECPanelBase, "TurnedCardRestraintRelationship")
local GUIUtils = require("GUI.GUIUtils")
local ItemUtils = require("Main.Item.ItemUtils")
local ItemModule = Lplus.ForwardDeclare("ItemModule")
local Vector = require("Types.Vector")
local TurnedCardInterface = require("Main.TurnedCard.TurnedCardInterface")
local TurnedCardUtils = require("Main.TurnedCard.TurnedCardUtils")
local TokenType = require("consts.mzm.gsp.item.confbean.TokenType")
local ECModel = require("Model.ECModel")
local UIModelWrap = require("Model.UIModelWrap")
local def = TurnedCardRestraintRelationship.define
local instance
def.field("number").curType = 0
def.field("number").restraintLevel = 1
def.field("table").berestraintLevel = nil
def.field("number").noLevel = 1
def.static("=>", TurnedCardRestraintRelationship).Instance = function()
  if instance == nil then
    instance = TurnedCardRestraintRelationship()
  end
  return instance
end
def.method("number").ShowPanelByClass = function(self, class)
  self.curType = class
  self:ShowPanel()
end
def.method().ShowPanel = function(self)
  if self:IsShow() then
    return
  end
  self:CreatePanel(RESPATH.PREFAB_SHAPESHIFT_ATT_TIPS, 0)
  self:SetModal(true)
end
def.override("boolean").OnShow = function(self, show)
  if show then
    self:initSelectedClass()
    self:setSelectedClassInfo()
    self:HideAllLevelList()
  else
    self.curType = 0
    self.berestraintLevel = nil
    self.restraintLevel = 1
    self.noLevel = 1
  end
end
def.method().initSelectedClass = function(self)
  if self.curType == 0 then
    self.curType = 1
  end
  self.berestraintLevel = {1, 1}
  local Group_Item = self.m_panel:FindDirect("Img_Bg/Group_Item")
  for i = 1, 6 do
    local Item = Group_Item:FindDirect("Item_0" .. i)
    Item:GetComponent("UIToggle").value = i == self.curType
  end
end
def.override().OnCreate = function(self)
end
def.override().OnDestroy = function(self)
end
def.method().Hide = function(self)
  self:HideAllLevelList()
  self:DestroyPanel()
end
def.method("userdata").onClickObj = function(self, clickObj)
  local id = clickObj.name
  if id == "Btn_Close" then
    self:Hide()
  elseif id == "Btn_Zone01" then
    local pName = clickObj.parent.name
    if pName == "Group_Buff" then
      self:setLevelList(clickObj)
    elseif pName == "Group_Debuff" then
      self:setLevelList(clickObj)
    end
  elseif id == "Btn_Zone02" then
    self:setLevelList(clickObj)
  elseif id == "Btn_Zone_Wu" then
    self:setLevelList(clickObj)
  elseif string.find(id, "Btn_Type_") then
    local idx = tonumber(string.sub(id, #"Btn_Type_" + 1))
    if idx then
      self:setLevel(clickObj, idx)
    end
  elseif string.find(id, "Item_0") then
    local idx = tonumber(string.sub(id, #"Item_0" + 1))
    if idx then
      self.curType = idx
      self.berestraintLevel = {1, 1}
      self.noLevel = 1
      self:setSelectedClassInfo()
    end
  else
    self:HideAllLevelList()
  end
end
def.method("userdata", "number").setLevel = function(self, clickObj, level)
  local Btn_Zone = clickObj.parent.parent.parent.parent
  local pName = Btn_Zone.parent.name
  if pName == "Group_Buff" then
    self.restraintLevel = level
    self:setRestraintInfo()
  elseif pName == "Group_Debuff" then
    if Btn_Zone.name == "Btn_Zone01" then
      self.berestraintLevel[1] = level
    elseif Btn_Zone.name == "Btn_Zone02" then
      self.berestraintLevel[2] = level
    end
    self:setBerestraintInfo()
  elseif pName == "Group_Wu" then
    self.noLevel = level
    self:setNoBestrictedInfo()
  end
  self:setLevelList(Btn_Zone)
end
def.method("userdata").setLevelList = function(self, obj)
  local Group_Zone = obj:FindDirect("Group_Zone")
  if Group_Zone.activeSelf then
    Group_Zone:SetActive(false)
    obj:GetComponent("UIToggleEx").value = true
  else
    local Btn_Zone01 = self.m_panel:FindDirect("Img_Bg/Group_Buff/Btn_Zone01")
    local Group_Debuff = self.m_panel:FindDirect("Img_Bg/Group_Debuff")
    local debuff_Btn1 = Group_Debuff:FindDirect("Btn_Zone01")
    local debuff_Btn2 = Group_Debuff:FindDirect("Btn_Zone02")
    local Group_Zone1 = Btn_Zone01:FindDirect("Group_Zone")
    if Group_Zone1.activeSelf then
      Btn_Zone01:GetComponent("UIToggleEx").value = true
      Group_Zone1:SetActive(false)
    end
    Group_Zone1 = debuff_Btn1:FindDirect("Group_Zone")
    if Group_Zone1.activeSelf then
      debuff_Btn1:GetComponent("UIToggleEx").value = true
      Group_Zone1:SetActive(false)
    end
    Group_Zone1 = debuff_Btn2:FindDirect("Group_Zone")
    if Group_Zone1.activeSelf then
      debuff_Btn1:GetComponent("UIToggleEx").value = true
      Group_Zone1:SetActive(false)
    end
    Group_Zone:SetActive(true)
  end
end
def.method().HideAllLevelList = function(self)
  local Btn_Zone01 = self.m_panel:FindDirect("Img_Bg/Group_Buff/Btn_Zone01")
  local Group_Debuff = self.m_panel:FindDirect("Img_Bg/Group_Debuff")
  local debuff_Btn1 = Group_Debuff:FindDirect("Btn_Zone01")
  local debuff_Btn2 = Group_Debuff:FindDirect("Btn_Zone02")
  Btn_Zone01:GetComponent("UIToggleEx").value = true
  debuff_Btn1:GetComponent("UIToggleEx").value = true
  debuff_Btn2:GetComponent("UIToggleEx").value = true
  Btn_Zone01:FindDirect("Group_Zone"):SetActive(false)
  debuff_Btn1:FindDirect("Group_Zone"):SetActive(false)
  debuff_Btn2:FindDirect("Group_Zone"):SetActive(false)
end
def.method().setSelectedClassInfo = function(self)
  local Group_Buff = self.m_panel:FindDirect("Img_Bg/Group_Buff")
  local Group_Debuff = self.m_panel:FindDirect("Img_Bg/Group_Debuff")
  local Group_Wu = self.m_panel:FindDirect("Img_Bg/Group_Wu")
  if self.curType == 0 then
    Group_Buff:SetActive(false)
    Group_Debuff:SetActive(false)
    Group_Wu:SetActive(true)
    local Btn_Zone_Wu = Group_Wu:FindDirect("Btn_Zone_Wu")
    local Group_Zone = Btn_Zone_Wu:FindDirect("Group_Zone")
    Btn_Zone_Wu:GetComponent("UIToggleEx").value = false
    Group_Zone:SetActive(false)
    self:setNoBestrictedInfo()
    return
  end
  Group_Wu:SetActive(false)
  Group_Buff:SetActive(true)
  Group_Debuff:SetActive(true)
  self:setRestraintInfo()
  self:setBerestraintInfo()
end
def.method().setRestraintInfo = function(self)
  local Group_Buff = self.m_panel:FindDirect("Img_Bg/Group_Buff")
  local classCfg = TurnedCardUtils.GetClassLevelCfg(self.curType)
  local classLevelCfg = classCfg.classLevels[self.restraintLevel]
  if classLevelCfg == nil then
    warn("!!!!!! restraintLevel is nil:", self.restraintLevel)
    return
  end
  local curClassCfg = TurnedCardUtils.GetCardClassCfg(self.curType)
  for i = 1, 3 do
    local Group_Item = Group_Buff:FindDirect("Group_Item0" .. i)
    local Img_Type01 = Group_Item:FindDirect("Img_Type01")
    local Img_Type02 = Group_Item:FindDirect("Img_Type02")
    local Label_Buff = Group_Item:FindDirect("Label_Buff")
    local Label_DeBuff = Group_Item:FindDirect("Label_DeBuff")
    local damageAddRates = classLevelCfg.damageAddRates[i]
    local damageReduceRates = classLevelCfg.damageReduceRates[i]
    local sealAddValue = classLevelCfg.sealAddRates[damageAddRates.classType]
    local sealAddStr = ""
    if sealAddValue and sealAddValue > 0 then
      sealAddStr = textRes.TurnedCard[28] .. " +" .. sealAddValue / 100 .. "%"
    end
    local sealReduceValue = classLevelCfg.sealReduceRates[damageAddRates.classType]
    local sealReduceStr = ""
    if sealReduceValue and sealReduceValue > 0 then
      sealReduceStr = textRes.TurnedCard[28] .. " -" .. sealReduceValue / 100 .. "%"
    end
    GUIUtils.FillIcon(Img_Type01:GetComponent("UITexture"), curClassCfg.iconId)
    local classCfg2 = TurnedCardUtils.GetCardClassCfg(damageAddRates.classType)
    GUIUtils.FillIcon(Img_Type02:GetComponent("UITexture"), classCfg2.iconId)
    Label_Buff:GetComponent("UILabel"):set_text(string.format(textRes.TurnedCard[22], tostring(damageAddRates.value / 100)) .. "% " .. sealAddStr)
    Label_DeBuff:GetComponent("UILabel"):set_text(string.format(textRes.TurnedCard[23], tostring(damageReduceRates.value / 100)) .. "% " .. sealReduceStr)
  end
  local Label = Group_Buff:FindDirect("Btn_Zone01/Label")
  Label:GetComponent("UILabel"):set_text(textRes.TurnedCard.CardLevelStr[self.restraintLevel])
end
def.method().setBerestraintInfo = function(self)
  local Group_Debuff = self.m_panel:FindDirect("Img_Bg/Group_Debuff")
  local classCfg = TurnedCardUtils.GetClassLevelCfg(self.curType)
  local classLevelCfg = classCfg.classLevels[self.restraintLevel]
  if classLevelCfg == nil then
    warn("!!!!!! setBerestraintInfo is nil:", self.restraintLevel)
    return
  end
  local curClassCfg = TurnedCardUtils.GetCardClassCfg(self.curType)
  for i = 1, 2 do
    local Group_Item = Group_Debuff:FindDirect("Group_Item0" .. i)
    local Img_Type01 = Group_Item:FindDirect("Img_Type01")
    local Img_Type02 = Group_Item:FindDirect("Img_Type02")
    local Label_Buff = Group_Item:FindDirect("Label_Buff")
    local Label_DeBuff = Group_Item:FindDirect("Label_DeBuff")
    GUIUtils.FillIcon(Img_Type02:GetComponent("UITexture"), curClassCfg.iconId)
    local beRestrictedClasses = classLevelCfg.beRestrictedClasses
    local class = beRestrictedClasses[i]
    local classCfg2 = TurnedCardUtils.GetCardClassCfg(class)
    GUIUtils.FillIcon(Img_Type01:GetComponent("UITexture"), classCfg2.iconId)
    local berestrictedClassCfg = TurnedCardUtils.GetClassLevelCfg(class)
    local berestrictedClassesLevelInfo = berestrictedClassCfg.classLevels[self.berestraintLevel[i]]
    if berestrictedClassesLevelInfo then
      local addValue, sealAddValue
      for i, v in ipairs(berestrictedClassesLevelInfo.damageAddRates) do
        if v.classType == self.curType then
          addValue = v.value
          sealAddValue = berestrictedClassesLevelInfo.sealAddRates[v.classType]
          break
        end
      end
      if addValue then
        local sealAddStr = ""
        if sealAddValue and sealAddValue > 0 then
          sealAddStr = textRes.TurnedCard[28] .. " -" .. sealAddValue / 100 .. "%"
        end
        Label_DeBuff:GetComponent("UILabel"):set_text(string.format(textRes.TurnedCard[23], tostring(addValue / 100)) .. "% " .. sealAddStr)
      else
        Label_DeBuff:GetComponent("UILabel"):set_text("")
      end
      local reduceValue, sealReduceValue
      for i, v in ipairs(berestrictedClassesLevelInfo.damageReduceRates) do
        if v.classType == self.curType then
          reduceValue = v.value
          sealReduceValue = berestrictedClassesLevelInfo.sealReduceRates[v.classType]
          break
        end
      end
      if reduceValue then
        local sealReduceStr = ""
        if sealReduceValue and sealReduceValue > 0 then
          sealReduceStr = textRes.TurnedCard[28] .. " +" .. sealReduceValue / 100 .. "%"
        end
        Label_Buff:GetComponent("UILabel"):set_text(string.format(textRes.TurnedCard[22], tostring(reduceValue / 100)) .. "% " .. sealReduceStr)
      else
        Label_Buff:GetComponent("UILabel"):set_text("")
      end
    end
  end
  local Label1 = Group_Debuff:FindDirect("Btn_Zone01/Label")
  Label1:GetComponent("UILabel"):set_text(textRes.TurnedCard.CardLevelStr[self.berestraintLevel[1]])
  local Label2 = Group_Debuff:FindDirect("Btn_Zone02/Label")
  Label2:GetComponent("UILabel"):set_text(textRes.TurnedCard.CardLevelStr[self.berestraintLevel[2]])
end
def.method().setNoBestrictedInfo = function(self)
  local classLevelCfg = TurnedCardUtils.GetClassLevelCfg(self.curType)
  local levelCfg = classLevelCfg.classLevels[1]
  if levelCfg == nil then
    return
  end
  local Group_Wu = self.m_panel:FindDirect("Img_Bg/Group_Wu")
  local curClassCfg = TurnedCardUtils.GetCardClassCfg(self.curType)
  for i = 1, 6 do
    local Group_Item = Group_Wu:FindDirect("Group_Item0" .. i)
    local Img_Type01 = Group_Item:FindDirect("Img_Type01")
    local Img_Type02 = Group_Item:FindDirect("Img_Type02")
    local Label_Buff = Group_Item:FindDirect("Label_Buff")
    local Label_DeBuff = Group_Item:FindDirect("Label_DeBuff")
    local class = levelCfg.beRestrictedClasses[i]
    local bestrictedCfg = TurnedCardUtils.GetCardClassCfg(class)
    GUIUtils.FillIcon(Img_Type02:GetComponent("UITexture"), curClassCfg.iconId)
    GUIUtils.FillIcon(Img_Type01:GetComponent("UITexture"), bestrictedCfg.iconId)
    local bestrictedLevelCfg = TurnedCardUtils.GetClassLevelCfg(class)
    local berestrictedClassesLevelInfo = bestrictedLevelCfg.classLevels[self.noLevel]
    if berestrictedClassesLevelInfo then
      local addValue, sealAddValue
      for i, v in ipairs(berestrictedClassesLevelInfo.damageAddRates) do
        if v.classType == self.curType then
          addValue = v.value
          sealAddValue = berestrictedClassesLevelInfo.sealAddRates[v.classType]
          break
        end
      end
      if addValue then
        local sealAddStr = ""
        if sealAddValue and sealAddValue > 0 then
          sealAddStr = textRes.TurnedCard[28] .. " -" .. sealAddValue / 100 .. "%"
        end
        Label_DeBuff:GetComponent("UILabel"):set_text(string.format(textRes.TurnedCard[23], tostring(addValue / 100)) .. "% " .. sealAddStr)
      else
        Label_DeBuff:GetComponent("UILabel"):set_text("")
      end
      local reduceValue, sealReduceValue
      for i, v in ipairs(berestrictedClassesLevelInfo.damageReduceRates) do
        if v.classType == self.curType then
          reduceValue = v.value
          sealReduceValue = berestrictedClassesLevelInfo.sealReduceRates[v.classType]
          break
        end
      end
      if reduceValue then
        local sealReduceStr = ""
        if sealReduceValue and sealReduceValue > 0 then
          sealReduceStr = textRes.TurnedCard[28] .. " +" .. sealReduceValue / 100 .. "%"
        end
        Label_Buff:GetComponent("UILabel"):set_text(string.format(textRes.TurnedCard[22], tostring(reduceValue / 100)) .. "% " .. sealReduceStr)
      else
        Label_Buff:GetComponent("UILabel"):set_text("")
      end
    end
  end
  local Label = Group_Wu:FindDirect("Btn_Zone_Wu/Label")
  Label:GetComponent("UILabel"):set_text(textRes.TurnedCard.CardLevelStr[self.noLevel])
end
TurnedCardRestraintRelationship.Commit()
return TurnedCardRestraintRelationship
