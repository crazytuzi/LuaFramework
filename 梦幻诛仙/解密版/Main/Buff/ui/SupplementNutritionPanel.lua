local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local SupplementNutritionPanel = Lplus.Extend(ECPanelBase, "SupplementNutritionPanel")
local def = SupplementNutritionPanel.define
local NutritionMgr = require("Main.Buff.NutritionMgr")
local Vector = require("Types.Vector")
local ItemModule = require("Main.Item.ItemModule")
local ItemTipsMgr = require("Main.Item.ItemTipsMgr")
local GUIUtils = require("GUI.GUIUtils")
local NOT_SET = 0
def.field("number")._selectedSupplementMethod = NOT_SET
def.field("number")._selectedItemIndex = NOT_SET
def.field("table")._itemList = nil
def.field("table").uiObjs = nil
def.field("boolean").isCreated = false
local instance
def.static("=>", SupplementNutritionPanel).Instance = function()
  if instance == nil then
    instance = SupplementNutritionPanel()
  end
  return instance
end
def.method().ShowPanel = function(self)
  self:CreatePanel(RESPATH.PREFAB_SUPPLEMENT_NUTRITION_PANEL, 1)
  self:SetModal(true)
end
def.method().HidePanel = function(self)
  self:DestroyPanel()
end
def.override().OnCreate = function(self)
  self:InitUI()
  self:UpdateUI()
  Event.RegisterEvent(ModuleId.ITEM, gmodule.notifyId.item.Item_OnBagInfoSynchronized, SupplementNutritionPanel.OnBagInfoSynchronized)
  Event.RegisterEvent(ModuleId.ITEM, gmodule.notifyId.item.Item_Money_SilverChanged, SupplementNutritionPanel.OnSilverMoneyChanged)
  Event.RegisterEvent(ModuleId.BUFF, gmodule.notifyId.Buff.BUFF_INFO_UPDATE, SupplementNutritionPanel.OnBuffInfoUpdate)
  self.isCreated = true
end
def.method().InitUI = function(self)
  self.m_panel:SetActive(true)
  self.uiObjs = {}
  self.uiObjs.Img_Bg = self.m_panel:FindDirect("Img_Bg")
  self.uiObjs.Group_NeedFood = self.uiObjs.Img_Bg:FindDirect("Group_NeedFood")
  self.uiObjs.Grid = self.uiObjs.Group_NeedFood:FindDirect("Scroll View/Grid")
  self.uiObjs.Gruop_Toggle1 = self.uiObjs.Group_NeedFood:FindDirect("Gruop_Toggle")
  self.uiObjs.Toggle_UseItem = self.uiObjs.Gruop_Toggle1:FindDirect("Toggle_UseItem")
  self.uiObjs.Toggle_UseItem:GetComponent("UIToggle"):set_startsActive(false)
  self.uiObjs.Label_Describ1 = self.uiObjs.Gruop_Toggle1:FindDirect("Label_Describ")
  self.uiObjs.Group_NeedSilver = self.uiObjs.Img_Bg:FindDirect("Group_NeedSilver")
  self.uiObjs.Label_SilverNum = self.uiObjs.Group_NeedSilver:FindDirect("Label_SilverNum")
  self.uiObjs.Group_Toggle2 = self.uiObjs.Group_NeedSilver:FindDirect("Group_Toggle")
  self.uiObjs.Toggle_UseSilver = self.uiObjs.Group_Toggle2:FindDirect("Toggle_UseSilver")
  self.uiObjs.Label_Describ2 = self.uiObjs.Group_Toggle2:FindDirect("Label_Describ")
  self._itemList = {}
  self._selectedItemIndex = 0
end
def.override().OnDestroy = function(self)
  self:Clear()
  Event.UnregisterEvent(ModuleId.ITEM, gmodule.notifyId.item.Item_OnBagInfoSynchronized, SupplementNutritionPanel.OnBagInfoSynchronized)
  Event.UnregisterEvent(ModuleId.ITEM, gmodule.notifyId.item.Item_Money_SilverChanged, SupplementNutritionPanel.OnSilverMoneyChanged)
  Event.UnregisterEvent(ModuleId.BUFF, gmodule.notifyId.Buff.BUFF_INFO_UPDATE, SupplementNutritionPanel.OnBuffInfoUpdate)
end
def.method().Clear = function(self)
  self.uiObjs = nil
  self._itemList = nil
  self.isCreated = false
end
def.method("string").onClick = function(self, id)
  print(string.format("%s click event: id = %s", tostring(self), id))
  if id == "Btn_Close" then
    self:HidePanel()
  elseif id == "Modal" then
    self:HidePanel()
  elseif id == "Toggle_UseItem" then
    self:SetSupplementMethod(NutritionMgr.SupplementNutritionMethod.UseItem)
  elseif id == "Toggle_UseSilver" then
    self:SetSupplementMethod(NutritionMgr.SupplementNutritionMethod.UseSilver)
  elseif string.sub(id, 1, #"Img_Bg_") == "Img_Bg_" then
    local index = tonumber(string.sub(id, #"Img_Bg_" + 1, -1))
    self:SelectItem(index)
  elseif id == "Btn_Confirm" then
    self:OnSupplementButtonClick()
  end
end
def.method().UpdateUI = function(self)
  local items = NutritionMgr.Instance():GetSupplementNutritionItems()
  self._itemList = items
  self:SetItemList(items)
  self:UpdateSilver()
  self:SetSelectedMethod(items)
end
def.method("table").SetSelectedMethod = function(self, items)
  if self:HaveSupplementNutritionItems(items) then
    self:SetSupplementMethod(NutritionMgr.SupplementNutritionMethod.UseItem)
  else
    self:SetSupplementMethod(NutritionMgr.SupplementNutritionMethod.UseSilver)
  end
end
def.method("number").SetSupplementMethod = function(self, method)
  if method == NutritionMgr.SupplementNutritionMethod.UseItem then
    if #self._itemList == 0 then
      self.uiObjs.Toggle_UseSilver:GetComponent("UIToggle"):set_value(true)
      Toast(textRes.Buff[17])
      return
    end
    self._selectedSupplementMethod = method
    self.uiObjs.Toggle_UseItem:GetComponent("UIToggle"):set_value(true)
    local index = self:GetSelectedItemIndex()
    self:SelectItem(index)
  elseif method == NutritionMgr.SupplementNutritionMethod.UseSilver then
    self._selectedSupplementMethod = method
    self.uiObjs.Toggle_UseSilver:GetComponent("UIToggle"):set_value(true)
    self:SelectItem(0)
  end
end
def.method("table", "=>", "boolean").HaveSupplementNutritionItems = function(self, items)
  if items == nil then
    return false
  end
  return #items > 0
end
def.method("table").SetItemList = function(self, items)
  local gridObj = self.uiObjs.Grid
  local gridComponent = gridObj:GetComponent("UIGrid")
  local itemTemplateRaw = gridObj:FindDirect("Img_Bg01")
  if itemTemplateRaw then
    itemTemplateRaw.name = "Img_Bg_0"
    itemTemplateRaw:SetActive(false)
    GUIUtils.SetActive(itemTemplateRaw:FindDirect("Img_Select"), true)
  else
    itemTemplateRaw = gridObj:FindDirect("Img_Bg_0")
  end
  for i, itemStruct in ipairs(items) do
    local itemBase = itemStruct.itemBase
    self:AddItem(gridObj, itemTemplateRaw, i, itemStruct)
  end
  local gridItemCount = gridComponent:GetChildListCount()
  local gridChildList = gridComponent:GetChildList()
  for i = #items + 1, gridItemCount do
    GameObject.Destroy(gridChildList[i].gameObject)
    gridChildList[i] = nil
  end
  gridComponent:Reposition()
  self:TouchGameObject(self.m_panel, self.m_parent)
end
def.method("userdata", "userdata", "number", "table").AddItem = function(self, gridObj, template, index, itemStruct)
  local gridComponent = gridObj:GetComponent("UIGrid")
  local gridItem = gridObj:FindDirect("Img_Bg_" .. index)
  if gridItem == nil then
    gridItem = GameObject.Instantiate(template)
    gridItem.name = "Img_Bg_" .. index
    gridItem:SetActive(true)
    gridComponent:AddChild(gridItem.transform)
    gridItem:set_localScale(Vector.Vector3.one)
  end
  gridItem:FindDirect("Label_Num"):GetComponent("UILabel"):set_text(itemStruct.item.number)
  local uiTexture = gridItem:FindDirect("Img_Icon"):GetComponent("UITexture")
  require("GUI.GUIUtils").FillIcon(uiTexture, itemStruct.itemBase.icon)
end
def.method().UpdateSilver = function(self)
  local curSilverMaxSupplement = NutritionMgr.Instance():GetCurSilverMaxSupplement()
  local haveSilver = ItemModule.Instance():GetMoney(ItemModule.MONEY_TYPE_SILVER)
  self.uiObjs.Label_SilverNum:GetComponent("UILabel"):set_text(tostring(curSilverMaxSupplement.useSilver))
  self.uiObjs.Label_Describ2:GetComponent("UILabel"):set_text(string.format(textRes.Buff[9], curSilverMaxSupplement.amount))
end
def.method("=>", "number").GetSelectedItemIndex = function(self)
  if self._selectedItemIndex == 0 then
    return 1
  elseif self._selectedItemIndex > #self._itemList then
    return #self._itemList
  end
  return self._selectedItemIndex
end
def.method("number").SelectItem = function(self, index)
  if index ~= 0 then
    self:FocusOnGridItem(index)
    self:ShowItemTip(index)
  else
    self:UnFocusGridItem(self._selectedItemIndex)
  end
  self._selectedItemIndex = index
end
def.method("number").FocusOnGridItem = function(self, index)
  self:_FocusOnGridItem(index, true)
end
def.method("number").UnFocusGridItem = function(self, index)
  self:_FocusOnGridItem(index, false)
end
def.method("number", "boolean")._FocusOnGridItem = function(self, index, state)
  local gridItem = self.uiObjs.Grid:FindDirect("Img_Bg_" .. index)
  if gridItem == nil then
    return
  end
  gridItem:GetComponent("UIToggle"):set_value(state)
  if state == true then
    do
      local scrollView = self.uiObjs.Grid.transform.parent.gameObject:GetComponent("UIScrollView")
      GameUtil.AddGlobalLateTimer(0, true, function()
        GameUtil.AddGlobalLateTimer(0, true, function()
          if _G.IsNil(scrollView) or _G.IsNil(gridItem) then
            return
          end
          scrollView:DragToMakeVisible(gridItem.transform, 4)
        end)
      end)
    end
  end
end
def.method("number").ShowItemTip = function(self, index)
  local itemStruct = self._itemList[index]
  if itemStruct == nil then
    return
  end
  local item = itemStruct.item
  local itemKey = itemStruct.itemKey
  local source = self.uiObjs.Img_Bg
  local position = source:get_position()
  local screenPos = WorldPosToScreen(position.x, position.y)
  local sprite = source:GetComponent("UISprite")
  local function ShowTip()
    ItemTipsMgr.Instance():ShowTips(item, ItemModule.BAG, itemKey, ItemTipsMgr.Source.Other, screenPos.x, screenPos.y, sprite:get_width(), sprite:get_height(), 0)
  end
  if self.isCreated then
    ShowTip()
  else
    GameUtil.AddGlobalLateTimer(0, true, ShowTip)
  end
end
def.method().OnSupplementButtonClick = function(self)
  if self._selectedSupplementMethod == NutritionMgr.SupplementNutritionMethod.UseSilver then
    self:OnSilverSupplementClick()
  elseif self._selectedSupplementMethod == NutritionMgr.SupplementNutritionMethod.UseItem then
    self:OnItemSupplementClick()
  end
end
def.method().OnSilverSupplementClick = function(self)
  local result = NutritionMgr.Instance():SilverSupplementNutrition()
  if result == NutritionMgr.CResult.SilverNotEnough then
    Toast(textRes.Common[13])
  elseif result == NutritionMgr.CResult.NutritionReachMax then
    Toast(textRes.Buff[11])
  end
end
def.method().OnItemSupplementClick = function(self)
  local itemStruct = self._itemList[self._selectedItemIndex]
  if itemStruct == nil then
    return
  end
  local result = NutritionMgr.Instance():ItemSupplementNutrition(itemStruct.itemKey)
  if result == NutritionMgr.CResult.NutritionReachMax then
    Toast(textRes.Buff[11])
  end
end
def.static("table", "table").OnBagInfoSynchronized = function(params, context)
  local self = instance
  self:UpdateUI()
end
def.static("table", "table").OnSilverMoneyChanged = function(params, context)
  local self = instance
  self:UpdateSilver()
end
def.static("table", "table").OnBuffInfoUpdate = function(params, context)
  local self = instance
  local buffId = params[1]
  local BuffMgr = require("Main.Buff.BuffMgr")
  if buffId == BuffMgr.NUTRITION_BUFF_ID then
    self:UpdateSilver()
  end
end
SupplementNutritionPanel.Commit()
return SupplementNutritionPanel
