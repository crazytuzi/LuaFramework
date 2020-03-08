local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local TurnedCardLevelUpPanel = Lplus.Extend(ECPanelBase, "TurnedCardLevelUpPanel")
local ItemData = require("Main.Item.ItemData")
local ItemTipsMgr = require("Main.Item.ItemTipsMgr")
local GUIUtils = require("GUI.GUIUtils")
local ItemUtils = require("Main.Item.ItemUtils")
local ItemModule = Lplus.ForwardDeclare("ItemModule")
local Vector = require("Types.Vector")
local ItemType = require("consts.mzm.gsp.item.confbean.ItemType")
local TurnedCardInterface = require("Main.TurnedCard.TurnedCardInterface")
local TurnedCardUtils = require("Main.TurnedCard.TurnedCardUtils")
local QualityEnum = require("consts.mzm.gsp.changemodelcard.confbean.QualityEnum")
local ProValueType = require("consts.mzm.gsp.common.confbean.ProValueType")
local def = TurnedCardLevelUpPanel.define
local instance
def.field("userdata").curUUID = nil
def.static("=>", TurnedCardLevelUpPanel).Instance = function()
  if instance == nil then
    instance = TurnedCardLevelUpPanel()
  end
  return instance
end
def.method("userdata").ShowPanel = function(self, uuid)
  if self:IsShow() then
    return
  end
  self.curUUID = uuid
  self:CreatePanel(RESPATH.PREFAB_SHAPESHIFT_LEVELUP, 0)
  self:SetModal(true)
end
def.override("boolean").OnShow = function(self, show)
  if show then
    self:setLevelInfo()
  else
  end
end
def.override().OnCreate = function(self)
  Event.RegisterEvent(ModuleId.TURNED_CARD, gmodule.notifyId.TurnedCard.Turned_Card_Exp_Change, TurnedCardLevelUpPanel.OnTurnedCardExpChange)
end
def.override().OnDestroy = function(self)
  Event.UnregisterEvent(ModuleId.TURNED_CARD, gmodule.notifyId.TurnedCard.Turned_Card_Exp_Change, TurnedCardLevelUpPanel.OnTurnedCardExpChange)
end
def.static("table", "table").OnTurnedCardExpChange = function(p1, p2)
  if instance and instance:IsShow() then
    instance:setLevelInfo()
  end
end
def.method().Hide = function(self)
  self:DestroyPanel()
end
def.method("userdata").onClickObj = function(self, clickObj)
  local id = clickObj.name
  warn("--------TurnedCardLevelUpPanel onClick:", id)
  local strs = string.split(id, "_")
  if id == "Btn_Close" then
    self:Hide()
  elseif id == "Btn_Upgrade" then
    local TurnedCardLevelUpUsePanel = require("Main.TurnedCard.ui.TurnedCardLevelUpUsePanel")
    TurnedCardLevelUpUsePanel.Instance():ShowPanel(self.curUUID)
  elseif id == "Btn_AttHelp" then
    local TurnedCardRestraintRelationship = require("Main.TurnedCard.ui.TurnedCardRestraintRelationship")
    local card = TurnedCardInterface.Instance():getTurnedCardById(self.curUUID)
    if card == nil then
      TurnedCardRestraintRelationship.Instance():ShowPanel()
    else
      local cardCfg = TurnedCardUtils.GetChangeModelCardCfg(card:getCardCfgId())
      TurnedCardRestraintRelationship.Instance():ShowPanelByClass(cardCfg.classType)
    end
  end
end
def.method().setLevelInfo = function(self)
  local curCard = TurnedCardInterface.Instance():getTurnedCardById(self.curUUID)
  if curCard == nil then
    return
  end
  local level = curCard:getCardLevel()
  local Img_Bg = self.m_panel:FindDirect("Img_Bg")
  local Group_Left = Img_Bg:FindDirect("Group_Left")
  local Group_Right = Img_Bg:FindDirect("Group_Right")
  self:setCurCardExp()
  self:setAttrInfo(Group_Left, level)
  self:setAttrInfo(Group_Right, level + 1)
end
def.method("userdata", "number").setAttrInfo = function(self, obj, level)
  local curCard = TurnedCardInterface.Instance():getTurnedCardById(self.curUUID)
  local cfgId = curCard:getCardCfgId()
  local cardCfg = TurnedCardUtils.GetChangeModelCardCfg(cfgId)
  local cardLevelCfg = TurnedCardUtils.GetCardLevelCfg(cfgId)
  local curLevelCfg = cardLevelCfg.cardLevels[level]
  if curLevelCfg == nil then
    obj:SetActive(false)
    warn("-----attr level Cfg is nil:", level)
    return
  end
  local Group_Attribute = obj:FindDirect("Group_Attribute")
  local propertys = curLevelCfg.propertys
  for i = 1, 5 do
    local Img_Attribute = Group_Attribute:FindDirect(string.format("Img_Attribute%02d", i))
    if Img_Attribute then
      local Label_Attribute = Img_Attribute:FindDirect(string.format("Label_Attribute%02d", i))
      local Label_AttributeNum = Img_Attribute:FindDirect(string.format("Label_AttributeNum%02d", i))
      local curProperty = propertys[i]
      if curProperty then
        local propertyCfg = _G.GetCommonPropNameCfg(curProperty.propType)
        if propertyCfg then
          Label_Attribute:GetComponent("UILabel"):set_text(propertyCfg.propName .. ":")
          if propertyCfg.valueType == ProValueType.TEN_THOUSAND_RATE then
            Label_AttributeNum:GetComponent("UILabel"):set_text("+" .. curProperty.value / 100 .. "%")
          else
            Label_AttributeNum:GetComponent("UILabel"):set_text("+" .. curProperty.value)
          end
        else
          Label_Attribute:GetComponent("UILabel"):set_text("")
          Label_AttributeNum:GetComponent("UILabel"):set_text("")
        end
      else
        Label_Attribute:GetComponent("UILabel"):set_text("")
        Label_AttributeNum:GetComponent("UILabel"):set_text("")
      end
    end
  end
  local classLevelCfg = TurnedCardUtils.GetClassLevelCfg(cardCfg.classType)
  local curLevelCfg = classLevelCfg.classLevels[level]
  local damageAddRates = curLevelCfg.damageAddRates
  local sealAddRates = curLevelCfg.sealAddRates
  local Group_Good = obj:FindDirect("Group_Good")
  for i = 1, 3 do
    local Group_Att = Group_Good:FindDirect("Group_Att0" .. i)
    local Img_Tpye = Group_Att:FindDirect("Img_Tpye")
    local Label_Att = Group_Att:FindDirect("Label_Att")
    local damageAdd = damageAddRates[i]
    if damageAdd then
      Group_Att:SetActive(true)
      local classCfg = TurnedCardUtils.GetCardClassCfg(damageAdd.classType)
      GUIUtils.FillIcon(Img_Tpye:GetComponent("UITexture"), classCfg.smallIconId)
      local sealStr = ""
      local sealValue = sealAddRates[damageAdd.classType]
      if sealValue and sealValue > 0 then
        sealStr = "\n" .. textRes.TurnedCard[28] .. " +" .. sealValue / 100 .. "%"
      end
      Label_Att:GetComponent("UILabel"):set_text(textRes.TurnedCard[6] .. " +" .. damageAdd.value / 100 .. "%" .. sealStr)
    else
      Group_Att:SetActive(false)
    end
  end
  local Group_Bad = obj:FindDirect("Group_Bad")
  local beRestrictedClasses = curLevelCfg.beRestrictedClasses
  for i = 1, 2 do
    local Group_Att = Group_Bad:FindDirect("Group_Att0" .. i)
    local Img_Tpye = Group_Att:FindDirect("Img_Tpye")
    local Label_Att = Group_Att:FindDirect("Label_Att")
    local beRestrictedClass = beRestrictedClasses[i]
    if beRestrictedClass then
      Group_Att:SetActive(true)
      local classCfg = TurnedCardUtils.GetCardClassCfg(beRestrictedClass)
      GUIUtils.FillIcon(Img_Tpye:GetComponent("UITexture"), classCfg.smallIconId)
      Label_Att:GetComponent("UILabel"):set_text("")
    else
      Group_Att:SetActive(false)
    end
  end
end
def.method().setCurCardExp = function(self)
  local curCard = TurnedCardInterface.Instance():getTurnedCardById(self.curUUID)
  if curCard == nil then
    return
  end
  local level = curCard:getCardLevel()
  local cfgId = curCard:getCardCfgId()
  local cardCfg = TurnedCardUtils.GetChangeModelCardCfg(cfgId)
  local cardLevelCfg = TurnedCardUtils.GetCardLevelCfg(cfgId)
  local curLevelCfg = cardLevelCfg.cardLevels[level]
  local Group_Exp = self.m_panel:FindDirect("Img_Bg/Group_Exp")
  local Label_LevelMax = self.m_panel:FindDirect("Img_Bg/Label_LevelMax")
  local Label_LevelMaxRight = self.m_panel:FindDirect("Img_Bg/Label_LevelMaxRight")
  if curLevelCfg == nil then
    warn("------setCurCardExp curLevelCfg is nil:", level)
    return
  end
  if cardLevelCfg.cardLevels[level + 1] == nil then
    Group_Exp:SetActive(false)
    Label_LevelMax:SetActive(true)
    Label_LevelMaxRight:SetActive(true)
    return
  end
  Group_Exp:SetActive(true)
  Label_LevelMax:SetActive(false)
  Label_LevelMaxRight:SetActive(false)
  local Group_Slider = Group_Exp:FindDirect("Group_Slider")
  local Label_Num = Group_Exp:FindDirect("Label_Num")
  local curExp = curCard:getExp()
  Group_Slider:GetComponent("UISlider").value = curExp / curLevelCfg.upgradeExp
  Label_Num:GetComponent("UILabel"):set_text(curExp .. "/" .. curLevelCfg.upgradeExp)
end
TurnedCardLevelUpPanel.Commit()
return TurnedCardLevelUpPanel
