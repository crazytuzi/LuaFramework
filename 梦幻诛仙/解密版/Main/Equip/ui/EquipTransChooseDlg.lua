local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local ECGUIMan = require("GUI.ECGUIMan")
local EquipTransChooseDlg = Lplus.Extend(ECPanelBase, "EquipTransChooseDlg")
local EquipStrenTransData = require("Main.Equip.EquipStrenTransData")
local ItemModule = require("Main.Item.ItemModule")
local Vector = require("Types.Vector")
local GUIUtils = require("GUI.GUIUtils")
local ItemTipsMgr = require("Main.Item.ItemTipsMgr")
local def = EquipTransChooseDlg.define
def.field("table")._mainEquipTrans = nil
def.field("table")._chooseEquips = nil
def.field("boolean")._bChooseTemplateFill = false
def.field("number")._chooseEquipIndex = -1
def.field("function")._callback = nil
def.field("table")._tag = nil
def.field("boolean")._bIsTrans = true
def.override().OnCreate = function(self)
  self._chooseEquips = {}
  self:Init()
  self:UpdateInfo()
end
def.static("table", "function", "table", "boolean").ShowEquipChoose = function(equip, callback, tag, bIsTrans)
  local dlg = EquipTransChooseDlg()
  dlg._mainEquipTrans = equip
  dlg._callback = callback
  dlg._tag = tag
  dlg._bIsTrans = bIsTrans
  dlg:SetModal(true)
  dlg:CreatePanel(RESPATH.PREFAB_EQUIP_CHOOSE_PANEL, 2)
end
def.method().Init = function(self)
  if nil == self._mainEquipTrans then
    return
  end
  self._chooseEquips = EquipTransChooseDlg.IfHaveCostEquips(self._bIsTrans, self._mainEquipTrans)
end
def.static("boolean", "table", "=>", "table").IfHaveCostEquips = function(bIsTrans, equip)
  local record0 = DynamicData.GetRecord(CFG_PATH.DATA_EQQUIPCFG, equip.id)
  local mainWearPos = record0:GetIntValue("wearpos")
  local equips = EquipStrenTransData.Instance():GetTransEquips()
  if false == bIsTrans then
    equips = EquipStrenTransData.Instance():GetInheritEquips()
  end
  local bagId = require("netio.protocol.mzm.gsp.item.BagInfo").BAG
  local mainStrenLevel = 0
  local ItemXStoreType = require("netio.protocol.mzm.gsp.item.ItemXStoreType")
  local mainEquipItem = ItemModule.Instance():GetItemByBagIdAndItemKey(equip.bagId, equip.key)
  if nil ~= mainEquipItem then
    mainStrenLevel = mainEquipItem.extraMap[ItemXStoreType.STRENGTH_LEVEL]
    if nil == mainStrenLevel then
      mainStrenLevel = 0
    end
  end
  local chooseEquips = {}
  local position = require("consts.mzm.gsp.item.confbean.WearPos")
  for k, v in pairs(equips) do
    local isSamePos = v.wearPos == mainWearPos or v.wearPos == position.ALL
    local sameEqp = v.bagId == equip.bagId and v.key == equip.key
    if isSamePos and v.useLevel <= equip.useLevel and false == sameEqp and v.bagId == bagId then
      local equipItem = ItemModule.Instance():GetItemByBagIdAndItemKey(v.bagId, v.key)
      if bIsTrans then
        if 0 < #equipItem.exproList then
          table.insert(chooseEquips, {
            id = v.id,
            useLevel = v.useLevel,
            wearPos = v.wearPos,
            bagId = v.bagId,
            iconId = v.iconId,
            name = v.name,
            exproList = equipItem.exproList,
            key = v.key,
            namecolor = v.namecolor
          })
        end
      else
        local strenLevel = 0
        local bGodEquip = false
        if nil ~= equipItem then
          strenLevel = equipItem.extraMap[ItemXStoreType.STRENGTH_LEVEL]
          if nil == strenLevel then
            strenLevel = 0
          end
          local godeWeaponStage = equipItem.extraMap[ItemXStoreType.SUPER_EQUIPMENT_STAGE]
          bGodEquip = godeWeaponStage and godeWeaponStage > 0
        end
        if strenLevel < 5 and not bGodEquip then
          table.insert(chooseEquips, {
            id = v.id,
            useLevel = v.useLevel,
            wearPos = v.wearPos,
            bagId = v.bagId,
            iconId = v.iconId,
            name = v.name,
            exproList = equipItem.exproList,
            key = v.key,
            namecolor = v.namecolor
          })
        end
      end
    end
  end
  return chooseEquips
end
def.method().UpdateInfo = function(self)
  if nil == self.m_panel then
    return
  end
  self._bChooseTemplateFill = false
  local bg = self.m_panel:FindDirect("Img_Bg")
  local gridTemplate = bg:FindDirect("Img_Bg1/Scroll View_Use/Grid_Use")
  local chooseTemplate = gridTemplate:FindDirect("Img_Bg01")
  if 0 == #self._chooseEquips then
    chooseTemplate:SetActive(false)
    return
  end
  local count = 1
  gridTemplate:GetChild(0):SetActive(true)
  self:FillChooseList(count, chooseTemplate, gridTemplate)
  local uiGrid = gridTemplate:GetComponent("UIGrid")
  uiGrid:Reposition()
  self:TouchGameObject(self.m_panel, self.m_parent)
end
def.method("number", "userdata", "userdata").FillChooseList = function(self, count, chooseTemplate, gridTemplate)
  local index = 1
  if false == self._bChooseTemplateFill then
    index = 2
    if #self._chooseEquips > 0 then
      self:FillChooseInfo(1, count, chooseTemplate, gridTemplate)
      self._bChooseTemplateFill = true
    end
  else
    index = 1
  end
  for i = index, #self._chooseEquips do
    count = count + 1
    local chooseNew = Object.Instantiate(chooseTemplate)
    self:FillChooseInfo(i, count, chooseNew, gridTemplate)
  end
end
def.method("number", "number", "userdata", "userdata").FillChooseInfo = function(self, index, count, chooseNew, gridTemplate)
  chooseNew:set_name(string.format("Img_Bg0%d", count))
  chooseNew.parent = gridTemplate
  chooseNew:set_localScale(Vector.Vector3.one)
  local chooseSprite = chooseNew:FindDirect("Img_Icon"):GetComponent("UITexture")
  GUIUtils.FillIcon(chooseSprite, self._chooseEquips[index].iconId)
  local Sprite = chooseNew:GetComponent("UISprite")
  Sprite:set_spriteName(string.format("Cell_%02d", self._chooseEquips[index].namecolor))
end
def.method("userdata").onClickObj = function(self, clickobj)
  local id = clickobj.name
  if string.find(id, "Img_Bg0") then
    local indexStr = string.sub(id, string.len("Img_Bg0") + 1)
    local index = tonumber(indexStr)
    self._chooseEquipIndex = index
    local obj = self.m_panel:FindDirect("Img_Bg")
    local position = obj:get_position()
    local screenPos = WorldPosToScreen(position.x, position.y)
    local sprite = obj:GetComponent("UISprite")
    local item = ItemModule.Instance():GetItemByBagIdAndItemKey(self._chooseEquips[self._chooseEquipIndex].bagId, self._chooseEquips[self._chooseEquipIndex].key)
    ItemTipsMgr.Instance():ShowTips(item, ItemModule.BAG, self._chooseEquips[self._chooseEquipIndex].key, ItemTipsMgr.Source.Other, screenPos.x, screenPos.y, sprite:get_width(), sprite:get_height(), -1)
  elseif id == "Btn_Confirm" then
    if -1 == self._chooseEquipIndex then
      Toast(textRes.Equip[21])
      return
    end
    self._callback(self._tag, self._chooseEquips[self._chooseEquipIndex])
    self:DestroyPanel()
    self = nil
  elseif id == "Btn_Close" then
    self:DestroyPanel()
    self = nil
  elseif "Modal" == id then
    self:DestroyPanel()
    self = nil
  end
end
EquipTransChooseDlg.Commit()
return EquipTransChooseDlg
