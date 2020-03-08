local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local ItemUtils = require("Main.Item.ItemUtils")
local EquipUtils = require("Main.Equip.EquipUtils")
local GUIUtils = require("GUI.GUIUtils")
local ItemTipsMgr = require("Main.Item.ItemTipsMgr")
local ItemType = require("consts.mzm.gsp.item.confbean.ItemType")
local ItemXStoreType = require("netio.protocol.mzm.gsp.item.ItemXStoreType")
local ItemTips = require("Main.Item.ui.ItemTips")
local EasyUseDlg = require("Main.Item.ui.EasyUseDlg")
local CommonConfirmDlg = require("GUI.CommonConfirmDlg")
local WingUtils = require("Main.Wing.WingUtils")
local WearPos = require("consts.mzm.gsp.item.confbean.WearPos")
local ECUIModel = require("Model.ECUIModel")
local Vector = require("Types.Vector")
local LookOverEquip = Lplus.Extend(ECPanelBase, "LookOverEquip")
local def = LookOverEquip.define
local _instance
def.field("table").model = nil
def.field("boolean").isDrag = false
def.field("table").data_Equip = nil
def.field("table").data_Wing = nil
def.field("table").data_Aircraft = nil
def.field("table").data_Fabao = nil
def.field("table").data_Info = nil
def.field("table").data_Model = nil
def.static("=>", LookOverEquip).Instance = function(self)
  if _instance == nil then
    _instance = LookOverEquip()
  end
  return _instance
end
def.static("table").ShowCharactorEquipInfo = function(data)
  local self = LookOverEquip.Instance()
  if self.m_panel then
    return
  end
  self.data_Info = {}
  self.data_Info.name = data.rolename
  self.data_Info.id = data.roleid
  self.data_Info.occupationId = data.ocpid
  self.data_Info.level = data.level
  self.data_Model = data.modelinfo
  self.data_Equip = {}
  if data.items then
    for k, v in pairs(data.items) do
      self.data_Equip[k] = v
    end
  end
  if data.winginfos and #data.winginfos > 0 then
    self.data_Wing = data.winginfos[1]
  end
  if data.aircraft then
    self.data_Aircraft = data.aircraft
  end
  if data.fabaoInfos and 0 < #data.fabaoInfos then
    self.data_Fabao = data.fabaoInfos[1]
  end
  self:CreatePanel(RESPATH.PREFAB_LOOK_OVER_CHARACTOR, 1)
  self:SetModal(true)
end
def.override().OnCreate = function(self)
  self:UpdateEquips()
  self:UpdateHeroInfo()
  self:UpdateModel()
end
def.override().OnDestroy = function(self)
  self.data_Equip = nil
  self.data_Info = nil
  self.data_Model = nil
  self.data_Wing = nil
  self.data_Aircraft = nil
  self.data_Fabao = nil
  self:DestroyModel()
  self.isDrag = false
end
def.override("boolean").OnShow = function(self, show)
  if show and self.model then
    self.model:Play(ActionName.Stand)
  end
end
def.method().DestroyModel = function(self)
  if self.model then
    self.model:Destroy()
    self.model = nil
  end
end
def.method("string").onClick = function(self, id)
  if id == "Btn_Close" then
    self:DestroyPanel()
  elseif string.sub(id, 1, 9) == "Img_Equip" then
    local index = tonumber(string.sub(id, 10))
    local source = self.m_panel:FindDirect("Img_Bg0/Group_EquipInfo/" .. id)
    if not source then
      return
    end
    local position = source.position
    local screenPos = WorldPosToScreen(position.x, position.y)
    local widget = source:GetComponent("UIWidget")
    if not widget then
      return
    end
    if index == WearPos.WING then
      if self.data_Wing then
        local level = self.data_Wing.curLv
        local phase = self.data_Wing.curRank
        local fakeId = 0
        if 0 < self.data_Wing.checkWing then
          local itemBase = WingUtils.GetWingFakeItemByWingId(self.data_Wing.checkWing)
          fakeId = itemBase and itemBase.itemid or 0
          ItemTipsMgr.Instance():ShowWingItemTip(fakeId, level, phase, screenPos.x, screenPos.y, widget.width, widget.height, 0, false, false)
        end
      end
    elseif index == WearPos.AIRCRAFT then
      local aircraftItemId = self.data_Aircraft and require("Main.Aircraft.AircraftInterface").GetAircraftItemId(self.data_Aircraft.aircraft_cfg_id) or 0
      if aircraftItemId > 0 then
        ItemTipsMgr.Instance():ShowAircraftTip(aircraftItemId, false)
      end
    elseif 7 == index then
      if self.data_Fabao then
        local fabaoId = self.data_Fabao.id
        local fabaoItemBase = ItemUtils.GetItemBase(fabaoId)
        if fabaoItemBase then
          ItemTipsMgr.Instance():ShowFabaoWearTips(self.data_Fabao, fabaoItemBase, ItemTipsMgr.Source.Other, 0, 0, 0, 0, 0, false)
        end
      end
    else
      local item = self.data_Equip[index]
      if item then
        ItemTipsMgr.Instance():ShowTips(item, 0, 0, ItemTipsMgr.Source.Other, screenPos.x, screenPos.y, widget.width, widget.height, 0)
      end
    end
  end
end
def.method("string").onDragStart = function(self, id)
  if id == "Model" then
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
def.method().UpdateModel = function(self)
  if self.data_Model then
    do
      local uiModel = self.m_panel:FindDirect("Img_Bg0/Group_EquipInfo/Img_BgCharacter/Model"):GetComponent("UIModel")
      self.model = ECUIModel.new(self.data_Model.modelid)
      self.model:AddOnLoadCallback("lookover", function()
        uiModel.modelGameObject = self.model.m_model
        if uiModel.mCanOverflow ~= nil then
          uiModel.mCanOverflow = true
          local camera = uiModel:get_modelCamera()
          camera:set_orthographic(true)
        end
      end)
      LoadModel(self.model, self.data_Model, 0, 0, 180, false, false)
    end
  end
end
def.method().UpdateHeroInfo = function(self)
  local displayId = require("Main.Hero.HeroUtility").Instance():RoleIDToDisplayID(self.data_Info.id)
  local occupationSpriteName = GUIUtils.GetOccupationSmallIcon(self.data_Info.occupationId)
  local infoGroup = self.m_panel:FindDirect("Img_Bg0/Img_SX_BgLeft")
  local nameLabel = infoGroup:FindDirect("Label_SX_Name"):GetComponent("UILabel")
  local lvLabel = infoGroup:FindDirect("Label_SX_Lv"):GetComponent("UILabel")
  local occupationSprite = infoGroup:FindDirect("Img_SX_School"):GetComponent("UISprite")
  local idLabel = infoGroup:FindDirect("Label_SX_IdNum"):GetComponent("UILabel")
  nameLabel:set_text(self.data_Info.name)
  lvLabel:set_text(string.format(textRes.Hero[1], self.data_Info.level))
  occupationSprite:set_spriteName(occupationSpriteName)
  idLabel:set_text(string.format(textRes.Hero[2], displayId:tostring()))
end
def.method().UpdateEquips = function(self)
  local equipments = self.data_Equip
  local equipIcons = self.m_panel:FindDirect("Img_Bg0/Group_EquipInfo")
  for i = 0, 8 do
    local icon = equipIcons:FindDirect(string.format("Img_Equip%d/Item_%d", i, i))
    icon:SetActive(false)
    local empty = equipIcons:FindDirect(string.format("Img_Equip%d/Img_Empty", i))
    empty:SetActive(true)
  end
  for k, v in pairs(equipments) do
    local index = k
    warn(string.format("Img_Equip%d/Item_%d", index, index))
    local equip = equipIcons:FindDirect(string.format("Img_Equip%d/Item_%d", index, index))
    equip:SetActive(true)
    self:SetIcon(equip, v)
    local empty = equipIcons:FindDirect(string.format("Img_Equip%d/Img_Empty", index))
    empty:SetActive(false)
  end
  if self.data_Wing then
    local wingId = self.data_Wing.checkWing
    local fakeId = 0
    if wingId > 0 then
      local itemBase = WingUtils.GetWingFakeItemByWingId(wingId)
      fakeId = itemBase and itemBase.itemid or 0
    end
    if fakeId > 0 then
      local equip = equipIcons:FindDirect(string.format("Img_Equip%d/Item_%d", WearPos.WING, WearPos.WING))
      equip:SetActive(true)
      self:SetIconBase(equip, fakeId)
    end
  end
  if self.data_Fabao then
    local fabaoId = self.data_Fabao.id
    if fabaoId then
      local fabaoItemBase = ItemUtils.GetItemBase(fabaoId)
      if fabaoItemBase then
        local equip = equipIcons:FindDirect(string.format("Img_Equip%d/Item_%d", 7, 7))
        equip:SetActive(true)
        self:SetIconBase(equip, fabaoId)
      end
    end
  end
  if self.data_Aircraft then
    local aircraftItemId = require("Main.Aircraft.AircraftInterface").GetAircraftItemId(self.data_Aircraft.aircraft_cfg_id)
    local equip = equipIcons:FindDirect(string.format("Img_Equip%d/Item_%d", WearPos.AIRCRAFT, WearPos.AIRCRAFT))
    local empty = equipIcons:FindDirect(string.format("Img_Equip%d/Img_Empty", WearPos.AIRCRAFT))
    if aircraftItemId > 0 then
      equip:SetActive(true)
      empty:SetActive(false)
      self:SetIconBase(equip, aircraftItemId)
    else
      equip:SetActive(false)
      empty:SetActive(true)
    end
  end
end
def.method("userdata", "table").SetIcon = function(self, item, itemInfo)
  local itemBase = ItemUtils.GetItemBase(itemInfo.id)
  local icon = item:FindDirect("Img_Icon")
  icon:SetActive(true)
  local uiTexture = icon:GetComponent("UITexture")
  GUIUtils.FillIcon(uiTexture, itemBase.icon)
  local num = item:FindDirect("Label_Num")
  if itemInfo.number > 1 then
    num:SetActive(true)
    num:GetComponent("UILabel"):set_text(string.format("%d", itemInfo.number))
  else
    num:SetActive(false)
  end
  item:FindDirect("Img_New"):SetActive(false)
  item:FindDirect("Img_Select"):SetActive(true)
  local bg = item:FindDirect("Img_Bg")
  GUIUtils.SetSprite(bg, ItemUtils.GetItemFrame(itemInfo, itemBase))
  item:FindDirect("Img_EquipBroken"):SetActive(false)
end
def.method("userdata", "number").SetIconBase = function(self, item, itemId)
  local icon = item:FindDirect("Img_Icon")
  local uiTexture = icon:GetComponent("UITexture")
  local itemBase = ItemUtils.GetItemBase(itemId)
  icon:SetActive(true)
  GUIUtils.FillIcon(uiTexture, itemBase.icon)
  local num = item:FindDirect("Label_Num")
  num:SetActive(false)
  item:FindDirect("Img_New"):SetActive(false)
  item:FindDirect("Img_Select"):SetActive(true)
  local bg = item:FindDirect("Img_Bg")
  local quality = itemBase.namecolor
  bg:GetComponent("UISprite"):set_spriteName(string.format("Cell_%02d", quality))
  local broken = item:FindDirect("Img_EquipBroken")
  broken:SetActive(false)
end
LookOverEquip.Commit()
return LookOverEquip
