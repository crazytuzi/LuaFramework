local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local PetMarkBagPanel = Lplus.Extend(ECPanelBase, "PetMarkBagPanel")
local ItemData = require("Main.Item.ItemData")
local ItemTipsMgr = require("Main.Item.ItemTipsMgr")
local GUIUtils = require("GUI.GUIUtils")
local ItemUtils = require("Main.Item.ItemUtils")
local ItemModule = Lplus.ForwardDeclare("ItemModule")
local Vector = require("Types.Vector")
local ItemType = require("consts.mzm.gsp.item.confbean.ItemType")
local def = PetMarkBagPanel.define
def.field(ItemModule)._itemModule = nil
def.field("number").selOcp = 0
def.field("boolean").isArrangingBag = false
def.field("number").selectedItemKey = -1
local instance
def.static("=>", PetMarkBagPanel).Instance = function()
  if instance == nil then
    instance = PetMarkBagPanel()
    instance._itemModule = ItemModule.Instance()
  end
  return instance
end
def.method().ShowPanel = function(self)
  if self:IsShow() then
    return
  end
  self:CreatePanel(RESPATH.PREFAB_PET_MARK_BAG_PANEL, 0)
  self:SetModal(true)
end
def.override("boolean").OnShow = function(self, show)
  if show then
    self:setBagInfo()
    self:UpdateBag()
  end
end
def.override().OnCreate = function(self)
  self.isArrangingBag = false
  Event.RegisterEvent(ModuleId.ITEM, gmodule.notifyId.item.Item_OnBagInfoSynchronized, PetMarkBagPanel.OnBagInfoSynchronized)
  Event.RegisterEvent(ModuleId.FEATURE, gmodule.notifyId.Feature.FeatureOpenChange, PetMarkBagPanel.OnFunctionOpenChange)
end
def.override().OnDestroy = function(self)
  self.selOcp = 0
  self.selectedItemKey = -1
  Event.UnregisterEvent(ModuleId.ITEM, gmodule.notifyId.item.Item_OnBagInfoSynchronized, PetMarkBagPanel.OnBagInfoSynchronized)
  Event.UnregisterEvent(ModuleId.FEATURE, gmodule.notifyId.Feature.FeatureOpenChange, PetMarkBagPanel.OnFunctionOpenChange)
end
def.static("table", "table").OnBagInfoSynchronized = function(p1, p2)
  if instance and p1.bagId == ItemModule.PET_MARK_BAG then
    instance:UpdateBag()
  end
end
def.method().Hide = function(self)
  self:DestroyPanel()
end
def.method().setBagInfo = function(self)
  local Grid_Item = self.m_panel:FindDirect("Img_Bg0/Img_Item/Scroll View_Item/Grid_Item")
  local data = ItemData.Instance()
  local cap = data:GetBagCapacity(ItemModule.PET_MARK_BAG)
  if cap == 0 then
    warn("!!!!!!!cap:", cap)
    cap = 100
  end
  local item001 = Grid_Item:FindDirect("Item_001")
  for i = 1, cap do
    local item = Grid_Item:FindDirect(string.format("Item_%03d", i))
    if item == nil then
      local itemNew = Object.Instantiate(item001)
      itemNew:set_name(string.format("Item_%03d", i))
      itemNew.parent = Grid_Item
      itemNew:set_localScale(Vector.Vector3.one)
      self.m_msgHandler:Touch(itemNew)
    end
  end
  local uiGrid = Grid_Item:GetComponent("UIGrid")
  uiGrid:Reposition()
end
def.method().UpdateBag = function(self)
  local items = ItemData.Instance():GetBag(ItemModule.PET_MARK_BAG)
  local bagGrid = self.m_panel:FindDirect("Img_Bg0/Img_Item/Scroll View_Item/Grid_Item")
  local childCount = bagGrid:get_childCount()
  for i = 0, childCount - 1 do
    local item = bagGrid:GetChild(i)
    if string.sub(item.name, 1, 5) ~= "Item_" then
      break
    end
    local info = items[i]
    if info then
      self:SetIcon(item, i, info, true)
    else
      self:ClearIcon(item)
    end
  end
  local uiGrid = bagGrid:GetComponent("UIGrid")
  uiGrid:Reposition()
end
def.method("userdata", "number", "table", "boolean").SetIcon = function(self, item, itemKey, itemInfo, showNew)
  local icon = item:FindDirect("Img_Icon")
  local uiTexture = icon:GetComponent("UITexture")
  local itemBase = ItemUtils.GetItemBase(itemInfo.id)
  icon:SetActive(true)
  GUIUtils.FillIcon(uiTexture, itemBase.icon)
  local num = item:FindDirect("Label_Num")
  if itemInfo.number > 1 then
    num:SetActive(true)
    num:GetComponent("UILabel"):set_text(string.format("%2d", itemInfo.number))
  else
    num:SetActive(false)
  end
  if ItemModule.Instance():GetBagItemNew(ItemModule.PET_MARK_BAG, itemKey) then
    item:FindDirect("Img_New"):SetActive(true)
  else
    item:FindDirect("Img_New"):SetActive(false)
  end
  item:FindDirect("Img_Tpye"):SetActive(false)
  item:FindDirect("Img_Select"):SetActive(true)
  local bg = item:FindDirect("Img_Bg")
  GUIUtils.SetSprite(bg, ItemUtils.GetItemFrame(itemInfo, itemBase))
  local broken = item:FindDirect("Img_EquipBroken")
  if itemBase.itemType == ItemType.EQUIP and itemInfo.extraMap[ItemXStoreType.USE_POINT_VALUE] <= 50 then
    broken:SetActive(true)
  else
    broken:SetActive(false)
  end
  local bang = item:FindDirect("Img_Bang")
  local zhuan = item:FindDirect("Img_Zhuan")
  local rarity = item:FindDirect("Img_Xiyou")
  if bang and zhuan then
    if itemBase.isProprietary then
      bang:SetActive(false)
      zhuan:SetActive(true)
      GUIUtils.SetActive(rarity, false)
    elseif ItemUtils.IsItemBind(itemInfo) then
      bang:SetActive(true)
      zhuan:SetActive(false)
      GUIUtils.SetActive(rarity, false)
    elseif ItemUtils.IsRarity(itemInfo.id) then
      bang:SetActive(false)
      zhuan:SetActive(false)
      GUIUtils.SetActive(rarity, true)
    else
      bang:SetActive(false)
      zhuan:SetActive(false)
      GUIUtils.SetActive(rarity, false)
    end
  end
  local red = item:FindDirect("Img_Red")
  if red then
    red:SetActive(false)
  end
end
def.method("userdata").ClearIcon = function(self, icon)
  local bg = icon:FindDirect("Img_Bg")
  bg:GetComponent("UISprite"):set_spriteName("Cell_00")
  icon:FindDirect("Label_Num"):SetActive(false)
  icon:FindDirect("Img_Icon"):SetActive(false)
  icon:FindDirect("Img_New"):SetActive(false)
  icon:FindDirect("Img_Select"):SetActive(false)
  icon:FindDirect("Img_EquipBroken"):SetActive(false)
  icon:FindDirect("Img_Tpye"):SetActive(false)
  local bang = icon:FindDirect("Img_Bang")
  if bang then
    bang:SetActive(false)
  end
  local zhuan = icon:FindDirect("Img_Zhuan")
  if zhuan then
    zhuan:SetActive(false)
  end
  local rarity = icon:FindDirect("Img_Xiyou")
  if rarity then
    rarity:SetActive(false)
  end
  local red = icon:FindDirect("Img_Red")
  if red then
    red:SetActive(false)
  end
end
def.method("userdata").onClickObj = function(self, clickObj)
  local id = clickObj.name
  if id == "Btn_Close" then
    self:Hide()
  elseif string.find(id, "Item_") then
    local indexStr = string.sub(id, 6)
    local index = tonumber(indexStr)
    if index then
      local key, item = self._itemModule:GetItemByPosition(ItemModule.PET_MARK_BAG, index - 1)
      self.selectedItemKey = key
      if key == -1 then
        self.m_panel:FindDirect("Img_Bg0/Img_Item/Scroll View_Item/Grid_Item/" .. id):GetComponent("UIToggle"):set_value(false)
        return
      else
        self.m_panel:FindDirect("Img_Bg0/Img_Item/Scroll View_Item/Grid_Item/" .. id):GetComponent("UIToggle"):set_value(true)
      end
      self.m_panel:FindDirect("Img_Bg0/Img_Item/Scroll View_Item/Grid_Item/" .. id .. "/Img_New"):SetActive(false)
      ItemModule.Instance():SetBagItemNew(ItemModule.PET_MARK_BAG, key, false)
      self:OnClickBagItem(key, item, clickObj)
    end
  elseif id == "Btn_Settle" then
    if _G.CheckCrossServerAndToast() then
      return
    end
    if self.isArrangingBag then
      Toast(textRes.Item[154])
      return
    end
    ItemModule.Instance():ClearBagItemNew(ItemModule.PET_MARK_BAG)
    ItemModule.ArrangeBag(ItemModule.PET_MARK_BAG)
    GameUtil.AddGlobalTimer(3, true, function()
      self.isArrangingBag = false
    end)
    self.isArrangingBag = true
  elseif id == "Btn_Use" then
    self:OnClickUseItem()
  end
end
def.method("number", "table", "userdata").OnClickBagItem = function(self, key, item, obj)
  local position = obj:get_position()
  local screenPos = WorldPosToScreen(position.x, position.y)
  local widget = obj:GetComponent("UIWidget")
  local tips = ItemTipsMgr.Instance():ShowTips(item, ItemModule.PET_MARK_BAG, key, ItemTipsMgr.Source.Bag, screenPos.x, screenPos.y, widget:get_width(), widget:get_height(), 0)
  local ocp = self:GetSelectedOccupation()
  tips:SetOperateContext({ocp = ocp})
end
def.method("=>", "number").GetSelectedOccupation = function(self)
  if self.selOcp == 0 then
    self.selOcp = _G.GetHeroProp().occupation
  end
  return self.selOcp
end
def.method().OnClickUseItem = function(self)
  if _G.CheckCrossServerAndToast() then
    return
  end
  if self.selectedItemKey == -1 then
    Toast(textRes.Item[8412])
    return
  end
  local item = ItemModule.Instance():GetItemByBagIdAndItemKey(ItemModule.PET_MARK_BAG, self.selectedItemKey)
  if item == nil then
    Toast(textRes.Item[8412])
    return
  end
  require("Main.Pet.PetMark.PetMarkMgr").Instance():UnlockPetMark(self.selectedItemKey)
end
def.static("table", "table").OnFunctionOpenChange = function(param, context)
  local ModuleFunSwitchInfo = require("netio.protocol.mzm.gsp.open.ModuleFunSwitchInfo")
  if param.feature == ModuleFunSwitchInfo.TYPE_PET_MARK and not param.open then
    instance:DestroyPanel()
  end
end
PetMarkBagPanel.Commit()
return PetMarkBagPanel
