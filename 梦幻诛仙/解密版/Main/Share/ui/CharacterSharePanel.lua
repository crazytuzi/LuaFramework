local Lplus = require("Lplus")
local BaseSharePanel = require("Main.Share.ui.BaseSharePanel")
local CharacterSharePanel = Lplus.Extend(BaseSharePanel, "CharacterSharePanel")
local HeroPropMgr = require("Main.Hero.mgr.HeroPropMgr")
local ItemUtils = require("Main.Item.ItemUtils")
local EquipUtils = require("Main.Equip.EquipUtils")
local GUIUtils = require("GUI.GUIUtils")
local WingInterface = require("Main.Wing.WingInterface")
local WearPos = require("consts.mzm.gsp.item.confbean.WearPos")
local ECUIModel = require("Model.ECUIModel")
local def = CharacterSharePanel.define
local instance
def.field("table")._uiObjs = nil
def.field("table")._model = nil
def.static("=>", CharacterSharePanel).Instance = function()
  if instance == nil then
    instance = CharacterSharePanel()
    instance.m_depthLayer = GUIDEPTH.TOPMOST
  end
  return instance
end
def.method().ShowSharePanel = function(self)
  self:CreatePanel(RESPATH.PREFEB_CHARACTER_SHARE_PANEL, 1)
  self:SetModal(true)
end
def.override().OnCreate = function(self)
  BaseSharePanel.OnCreate(self)
  self:_InitUI()
  self:_SetPlayerBasicInfo()
  self:_SetPlayerBasicProp()
  self:_SetPlayerHighProp()
  self:_SetPlayerEquips()
  self:_SetPlayerModel()
end
def.method()._InitUI = function(self)
  self._uiObjs = {}
  self._uiObjs.Img_Bg0 = self.m_panel:FindDirect("Img _Bg0")
  self._uiObjs.Group_Name = self._uiObjs.Img_Bg0:FindDirect("Group_Name")
  self._uiObjs.Img_BgAttribute = self._uiObjs.Img_Bg0:FindDirect("Img_BgAttribute")
  self._uiObjs.Group_HighAttribute = self._uiObjs.Img_BgAttribute:FindDirect("Group_HighAttribute")
  self._uiObjs.Group_BasicAttribute = self._uiObjs.Img_BgAttribute:FindDirect("Group_BasicAttribute")
  self._uiObjs.Group_Left = self._uiObjs.Img_Bg0:FindDirect("Group_Left")
  self._uiObjs.Group_WeiXin = self._uiObjs.Img_Bg0:FindDirect("Group_WeiXin")
  self._uiObjs.Group_QQ = self._uiObjs.Img_Bg0:FindDirect("Group_QQ")
  self._uiObjs.Img_Logo = self._uiObjs.Img_Bg0:FindDirect("Img_Logo")
  self._uiObjs.Img_Logo:SetActive(false)
  self._uiObjs.Group_QQ:SetActive(false)
  self._uiObjs.Group_WeiXin:SetActive(false)
  self._uiObjs.Img_Bg0:FindDirect("Btn_Close"):SetActive(false)
end
def.method()._SetPlayerBasicInfo = function(self)
  local playerName = self._uiObjs.Group_Name:FindDirect("Label_Name")
  local playerLevel = self._uiObjs.Group_Name:FindDirect("Label_Lv")
  local playerOccupation = self._uiObjs.Group_Name:FindDirect("Label_MenPai")
  local PlayerId = self._uiObjs.Group_Name:FindDirect("Label__IdNum")
  local heroProp = HeroPropMgr.Instance():GetHeroProp()
  playerName:GetComponent("UILabel").text = heroProp.name
  playerLevel:GetComponent("UILabel").text = "Lv." .. heroProp.level
  playerOccupation:GetComponent("UILabel").text = textRes.Occupation[heroProp.occupation]
  local displayId = require("Main.Hero.HeroUtility").Instance():RoleIDToDisplayID(heroProp.id)
  PlayerId:GetComponent("UILabel").text = textRes.Share[1] .. displayId:tostring()
  local powerLabel = self._uiObjs.Group_Left:FindDirect("Label_PowerNumber"):GetComponent("UILabel")
  powerLabel.text = heroProp.fightValue
end
def.method()._SetPlayerBasicProp = function(self)
  local heroProp = HeroPropMgr.Instance():GetHeroProp()
  local secondProp = heroProp.secondProp
  local props = {
    secondProp.phyAtk,
    secondProp.magAtk,
    secondProp.phyDef,
    secondProp.magDef,
    secondProp.speed
  }
  local Grid_SX_Attribute = self._uiObjs.Group_BasicAttribute:FindDirect("Grid_SX_Attribute01")
  for i = 1, #props do
    local propLabel = Grid_SX_Attribute:FindDirect(string.format("Img_SX_Attribute%02d/Label_SX_AttributeNum%02d", i, i))
    propLabel:GetComponent("UILabel").text = props[i]
  end
end
def.method()._SetPlayerHighProp = function(self)
  local heroProp = HeroPropMgr.Instance():GetHeroProp()
  local propMap = heroProp.propMap
  local PropertyType = require("consts.mzm.gsp.common.confbean.PropertyType")
  local props = {
    propMap[PropertyType.PHY_CRIT_LEVEL],
    propMap[PropertyType.MAG_CRT_LEVEL],
    propMap[PropertyType.PHY_CRT_DEF_LEVEL],
    propMap[PropertyType.MAG_CRT_DEF_LEVEL],
    propMap[PropertyType.SEAL_HIT],
    propMap[PropertyType.SEAL_RESIST]
  }
  local Grid_SX_Attribute = self._uiObjs.Group_HighAttribute:FindDirect("Grid_SX_Attribute01")
  for i = 1, #props do
    local propLabel = Grid_SX_Attribute:FindDirect(string.format("Img_SX_Attribute%02d/Label_SX_AttributeNum%02d", i, i))
    propLabel:GetComponent("UILabel").text = props[i]
  end
end
def.method()._SetPlayerEquips = function(self)
  local itemModule = require("Main.Item.ItemModule").Instance()
  local equipments = itemModule:GetHeroEquipments()
  for k, v in pairs(equipments) do
    local index = v.position
    local equip = self._uiObjs.Group_Left:FindDirect(string.format("Img_Equip%d/Item_%d", index, index))
    local icon = equip:FindDirect("Img_Icon")
    local uiTexture = icon:GetComponent("UITexture")
    local itemBase = ItemUtils.GetItemBase(v.id)
    GUIUtils.FillIcon(uiTexture, itemBase.icon)
    icon:SetActive(true)
    local empty = self._uiObjs.Group_Left:FindDirect(string.format("Img_Equip%d/Img_Empty", index))
    empty:SetActive(false)
  end
  local fakeId = WingInterface.GetCurWingItemId()
  if fakeId > 0 then
    local equip = self._uiObjs.Group_Left:FindDirect(string.format("Img_Equip%d/Item_%d", WearPos.WING, WearPos.WING))
    local icon = equip:FindDirect("Img_Icon")
    local uiTexture = icon:GetComponent("UITexture")
    local itemBase = ItemUtils.GetItemBase(fakeId)
    if itemBase then
      GUIUtils.FillIcon(uiTexture, itemBase.icon)
      icon:SetActive(true)
    end
  else
    warn("FakeId=0!!!")
  end
  local displayFabao = require("Main.Fabao.data.FabaoData").Instance():GetCurDisplayFabao()
  if displayFabao then
    local fabaoType = displayFabao.fabaoType
    local fabaoData = displayFabao.fabaoData
    if fabaoType and fabaoType > 0 then
      local fabaoPos = WearPos.FABAO or 7
      local equip = self._uiObjs.Group_Left:FindDirect(string.format("Img_Equip%d/Item_%d", fabaoPos, fabaoPos))
      local icon = equip:FindDirect("Img_Icon")
      local uiTexture = icon:GetComponent("UITexture")
      local itemBase = ItemUtils.GetItemBase(fabaoData.id)
      if itemBase then
        GUIUtils.FillIcon(uiTexture, itemBase.icon)
        icon:SetActive(true)
      end
    end
  end
end
def.method()._SetPlayerModel = function(self)
  if self.m_panel ~= nil and not self.m_panel.isnil then
    do
      local uiModel = self._uiObjs.Group_Left:FindDirect("Img_BgCharacter/Model"):GetComponent("UIModel")
      local heroProp = require("Main.Hero.Interface").GetHeroProp()
      if heroProp == nil then
        return
      end
      local modelId = gmodule.moduleMgr:GetModule(ModuleId.HERO):GetMyModelId()
      if self._model ~= nil then
        self._model:Destroy()
      end
      self._model = ECUIModel.new(modelId)
      self._model.m_bUncache = true
      local modelInfo = gmodule.moduleMgr:GetModule(ModuleId.PUBROLE):GetRoleModelInfo(gmodule.moduleMgr:GetModule(ModuleId.HERO).roleId)
      self._model:AddOnLoadCallback("CharacterSharePanel", function()
        if self.m_panel == nil or self.m_panel.isnil then
          self._model:Destroy()
          self._model = nil
          return
        end
        if self._model == nil or self._model.m_model == nil or self._model.m_model.isnil or uiModel == nil or uiModel.isnil then
          return
        end
        uiModel.modelGameObject = self._model.m_model
        if uiModel.mCanOverflow ~= nil then
          uiModel.mCanOverflow = true
          local camera = uiModel:get_modelCamera()
          camera:set_orthographic(true)
        end
      end)
      _G.LoadModel(self._model, modelInfo, 0, 0, 180, false, false)
    end
  end
end
def.override().OnShare = function(self)
  self._uiObjs.Img_Logo:SetActive(true)
end
def.method("string").onClick = function(self, id)
  if id == "Btn_Close" then
    self:DestroyPanel()
  end
end
def.override().OnDestroy = function(self)
  self._uiObjs = nil
  if self._model ~= nil then
    self._model:Destroy()
    self._model = nil
  end
end
CharacterSharePanel.Commit()
return CharacterSharePanel
