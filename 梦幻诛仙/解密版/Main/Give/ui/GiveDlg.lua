local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local GiveDlg = Lplus.Extend(ECPanelBase, "GiveDlg")
local ItemModule = require("Main.Item.ItemModule")
local ItemUtils = require("Main.Item.ItemUtils")
local Vector = require("Types.Vector")
local GUIUtils = require("GUI.GUIUtils")
local ItemTipsMgr = require("Main.Item.ItemTipsMgr")
local PetInterface = require("Main.Pet.Interface")
require("Main.module.ModuleId")
local PetMgr = require("Main.Pet.mgr.PetMgr")
local def = GiveDlg.define
local dlg
def.field("table")._items = nil
def.field("boolean")._bItemTemplateFill = false
def.field("number")._itemSelectIndex = -1
def.field("table")._pets = nil
def.field("boolean")._bPetTemplateFill = false
def.field("number")._petSelectIndex = -1
def.static("=>", GiveDlg).Instance = function(self)
  if nil == dlg then
    dlg = GiveDlg()
  end
  dlg._items = {}
  dlg._pets = {}
  return dlg
end
def.override().OnCreate = function(self)
  if "panel_giveitem" == self.m_panel.name then
    self:CreateGiveItemsDlg()
  elseif "panel_givepet" == self.m_panel.name then
    self:CreateGivePetsDlg()
  end
end
def.static("number").ShowGiveItemDlg = function(siftId)
  local p = require("netio.protocol.mzm.gsp.item.CSiftItemBySiftCfgReq").new(siftId)
  gmodule.network.sendProtocol(p)
end
def.method("number").PreparePets = function(self, petId)
  self._pets = {}
  local pets = PetInterface.GetPetsByTypeId(petId)
  for k, v in pairs(pets) do
    local petCfgData = v:GetPetCfgData()
    if false == v.isDisplay and false == v.isFighting and false == petCfgData.isSpecial then
      local modelCfg = require("Main.Pubrole.PubroleInterface").GetModelCfg(petCfgData.modelId)
      local iconId = modelCfg.headerIconId
      table.insert(self._pets, {
        id = v.id,
        name = v.name,
        iconId = iconId,
        level = v.level,
        count = 1,
        yaoli = v:GetYaoLi(),
        type = petCfgData.type
      })
    end
  end
  self:SortPets()
end
def.method().CreateGivePetsDlg = function(self)
  self:FillGiveDlg(self._pets, self._bPetTemplateFill, false)
  if #self._pets > 0 then
    self:SetPetSelect(1)
    self:ShowPetSelectName()
  end
end
def.method().SortItems = function(self)
  if #self._items > 0 then
    local itemId = self._items[1].id
    local integer, _ = math.modf(itemId * 1.0E-5)
    if textRes.Give[3] == tostring(integer) then
      self:SortOtherItems()
    elseif textRes.Give[4] == tostring(integer) then
      self:SortEquipItems()
    elseif textRes.Give[7] == tostring(integer) then
      self:SortDrugItems()
    elseif textRes.Give[8] == tostring(integer) then
      self:SortPetLifeItems()
    elseif textRes.Give[9] == tostring(integer) then
      self:SortBaoShiDuItems()
    end
  end
end
def.method().SortPets = function(self)
  table.sort(self._pets, function(a, b)
    return a.yaoli < b.yaoli
  end)
end
def.method().SortEquipItems = function(self)
  if self._items then
    do
      local ItemXStoreType = require("netio.protocol.mzm.gsp.item.ItemXStoreType")
      local function comp(itemInfo1, itemInfo2)
        local itemKey1, item1 = ItemModule.Instance():GetItemByUUID(itemInfo1.uuid[1], ItemModule.BAG)
        local itemKey2, item2 = ItemModule.Instance():GetItemByUUID(itemInfo2.uuid[1], ItemModule.BAG)
        local strenLevel1 = item1.extraMap[ItemXStoreType.STRENGTH_LEVEL]
        local strenLevel2 = item2.extraMap[ItemXStoreType.STRENGTH_LEVEL]
        return strenLevel1 < strenLevel2
      end
      table.sort(self._items, comp)
    end
  end
end
def.method().SortOtherItems = function(self)
end
def.method().SortDrugItems = function(self)
  local LivingSkillUtility = require("Main.Skill.LivingSkillUtility")
  local function comp(itemInfo1, itemInfo2)
    local itemCfg1 = LivingSkillUtility.GetInFightDrugItemInfo(itemInfo1.id)
    local itemCfg2 = LivingSkillUtility.GetInFightDrugItemInfo(itemInfo2.id)
    return itemCfg1.drugPro < itemCfg2.drugPro
  end
  if self._items then
    table.sort(self._items, comp)
  end
end
def.method().SortPetLifeItems = function(self)
  local function comp(itemInfo1, itemInfo2)
    local itemCfg1 = ItemUtils.GetPetLifeCfg(itemInfo1.id)
    local itemCfg2 = ItemUtils.GetPetLifeCfg(itemInfo2.id)
    return itemCfg1.drugPro < itemCfg2.drugPro
  end
  if self._items then
    table.sort(self._items, comp)
  end
end
def.method().SortBaoShiDuItems = function(self)
  local LivingSkillUtility = require("Main.Skill.LivingSkillUtility")
  local function comp(itemInfo1, itemInfo2)
    local itemCfg1 = LivingSkillUtility.GetBaoShiDuItemInfo(itemInfo1.id)
    local itemCfg2 = LivingSkillUtility.GetBaoShiDuItemInfo(itemInfo2.id)
    return itemCfg1.drugPro < itemCfg2.drugPro
  end
  if self._items then
    table.sort(self._items, comp)
  end
end
def.method("table").PrepareItems = function(self, itemList)
  local idTbl = {}
  for k, v in pairs(itemList) do
    local num = ItemModule.Instance():GetItemCountById(v)
    if 0 ~= num then
      idTbl[v] = num
    end
  end
  self._items = {}
  local bagItems = ItemModule.Instance():GetItems()
  for k, v in pairs(bagItems) do
    if nil ~= idTbl[v.id] then
      table.insert(self._items, {
        key = k,
        id = v.id,
        count = v.number,
        uuid = v.uuid
      })
    end
  end
  self:SortItems()
end
def.method().CreateGiveItemsDlg = function(self)
  self:FillGiveDlg(self._items, self._bItemTemplateFill, true)
  if #self._items > 0 then
    self:SetItemSelect(1)
    self:ShowItemSelectName()
  end
end
def.method("number").SetItemSelect = function(self, index)
  self._itemSelectIndex = index
  local grid = self.m_panel:FindDirect("Img_Bg/Img_Background/Scroll View/Grid")
  local obj = grid:FindDirect(string.format("Img_Bg0%d", index))
  obj:GetComponent("UIToggle"):set_isChecked(true)
  GameUtil.AddGlobalTimer(0.1, true, function()
    if self.m_panel and false == self.m_panel.isnil then
      self:ShowItemTips(index)
    end
  end)
end
def.method("number").ShowItemTips = function(self, index)
  local bg = self.m_panel:FindDirect("Img_Bg")
  local position = bg:get_position()
  local screenPos = WorldPosToScreen(position.x, position.y)
  local sprite = bg:GetComponent("UISprite")
  local item = ItemModule.Instance():GetItemByBagIdAndItemKey(ItemModule.BAG, self._items[index].key)
  ItemTipsMgr.Instance():ShowTips(item, ItemModule.BAG, self._items[index].key, ItemTipsMgr.Source.Other, screenPos.x, screenPos.y, sprite:get_width(), sprite:get_height(), 0)
end
def.method("number").SetPetSelect = function(self, index)
  self._petSelectIndex = index
  local grid = self.m_panel:FindDirect("Img_Bg/Img_Background/Scroll View/Grid")
  local obj = grid:FindDirect(string.format("Img_Bg0%d", index))
  obj:GetComponent("UIToggle"):set_isChecked(true)
end
def.method("table", "boolean", "boolean").FillGiveDlg = function(self, tbl, bTemplateFill, bIsItem)
  bTemplateFill = false
  local grid = self.m_panel:FindDirect("Img_Bg/Img_Background/Scroll View/Grid")
  local eleTemplate = grid:FindDirect("Img_Bg01")
  if 0 == #tbl then
    eleTemplate:SetActive(false)
    return
  end
  grid:GetChild(0):SetActive(true)
  self:FillElementList(tbl, eleTemplate, grid, bTemplateFill, bIsItem)
  local uiGrid = grid:GetComponent("UIGrid")
  uiGrid:Reposition()
  self:TouchGameObject(self.m_panel, self.m_parent)
end
def.method("table", "userdata", "userdata", "boolean", "boolean").FillElementList = function(self, tbl, eleTemplate, gridTemplate, bTemplateFill, bIsItem)
  local index = 1
  if bIsItem and (self._items == nil or index > #self._items) then
    return
  end
  if false == bTemplateFill then
    index = 2
    if #tbl > 0 then
      self:FillElementInfo(1, eleTemplate, gridTemplate, bIsItem)
      bTemplateFill = true
    end
  else
    index = 1
  end
  for i = index, #tbl do
    local eleNew = Object.Instantiate(eleTemplate)
    self:FillElementInfo(i, eleNew, gridTemplate, bIsItem)
  end
end
def.method("number", "userdata", "userdata", "boolean").FillElementInfo = function(self, index, eleNew, gridTemplate, bIsItem)
  eleNew:set_name(string.format("Img_Bg0%d", index))
  eleNew.parent = gridTemplate
  eleNew:set_localScale(Vector.Vector3.one)
  eleNew:FindDirect("Img_Select"):SetActive(true)
  eleNew:GetComponent("UIToggle"):set_isChecked(false)
  if bIsItem then
    self:FillItemInfo(index, eleNew)
  else
    self:FillPetInfo(index, eleNew)
  end
end
def.method("number", "userdata").FillItemInfo = function(self, index, itemNew)
  local itemTex = itemNew:FindDirect("Img_Icon"):GetComponent("UITexture")
  local itemBase = ItemUtils.GetItemBase(self._items[index].id)
  GUIUtils.FillIcon(itemTex, itemBase.icon)
  itemNew:FindDirect("Label_Num"):GetComponent("UILabel"):set_text(self._items[index].count)
end
def.method("number", "userdata").FillPetInfo = function(self, index, petNew)
  local petTex = petNew:FindDirect("Img_BgIcon/Img_Icon"):GetComponent("UITexture")
  GUIUtils.FillIcon(petTex, self._pets[index].iconId)
  petNew:FindDirect("Label_Lv"):GetComponent("UILabel"):set_text(string.format(textRes.Give[6], self._pets[index].level))
  petNew:FindDirect("Label_Name"):GetComponent("UILabel"):set_text(self._pets[index].name)
  local typeName = textRes.Pet.Type[self._pets[index].type]
  petNew:FindDirect("Labe_PetType"):GetComponent("UILabel"):set_text(typeName)
end
def.method().ShowItemSelectName = function(self)
  local itemBase = ItemUtils.GetItemBase(self._items[self._itemSelectIndex].id)
  local str = string.format(textRes.Give[1], itemBase.name)
  local background = self.m_panel:FindDirect("Img_Bg")
  background:FindDirect("Label_Tips"):GetComponent("UILabel"):set_text(str)
end
def.method().ShowPetSelectName = function(self)
  local str = string.format(textRes.Give[1], self._pets[self._petSelectIndex].name)
  local background = self.m_panel:FindDirect("Img_Bg")
  background:FindDirect("Label_Tips"):GetComponent("UILabel"):set_text(str)
end
def.method("userdata").onClickObj = function(self, clickobj)
  local id = clickobj.name
  if string.find(id, "Img_Bg0") then
    local indexStr = string.sub(id, string.len("Img_Bg0") + 1)
    local index = tonumber(indexStr)
    if "panel_giveitem" == self.m_panel.name then
      self:SetItemSelect(index)
      self:ShowItemSelectName()
    elseif "panel_givepet" == self.m_panel.name then
      self:SetPetSelect(index)
      self:ShowPetSelectName()
    end
  elseif id == "Img_BgIcon" then
    if "panel_givepet" == self.m_panel.name then
      local pName = clickobj.parent.name
      local indexStr = string.sub(pName, string.len("Img_Bg0") + 1)
      local index = tonumber(indexStr)
      if index then
        local petId = self._pets[index].id
        local pet = PetMgr.Instance():GetPet(petId)
        if pet then
          require("Main.Pet.ui.PetInfoPanel").Instance():ShowPanel(pet)
        end
      end
    end
  elseif id == "Btn_Confirm" then
    if "panel_giveitem" == self.m_panel.name then
      if -1 == self._itemSelectIndex then
        Toast(textRes.Give[2])
      elseif self._items and self._items[self._itemSelectIndex] then
        local tbl = {
          ItemModule.BAG,
          self._items[self._itemSelectIndex].uuid[1]
        }
        Event.DispatchEvent(ModuleId.GIVE, gmodule.notifyId.Give.Give_ItemSelect, tbl)
      else
        warn("error give dlg self._items = ", self._items)
        warn("error give dlg self._itemSelectIndex = ", self._itemSelectIndex)
      end
    elseif "panel_givepet" == self.m_panel.name then
      if -1 == self._petSelectIndex then
        Toast(textRes.Give[2])
      elseif self._pets and self._pets[self._petSelectIndex] then
        local tbl = {
          self._pets[self._petSelectIndex].id
        }
        Event.DispatchEvent(ModuleId.GIVE, gmodule.notifyId.Give.Give_PetSelect, tbl)
      else
        warn("error give dlg self._pets = ", self._pets)
        warn("error give dlg self._petSelectIndex = ", self._petSelectIndex)
      end
    end
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
GiveDlg.Commit()
return GiveDlg
