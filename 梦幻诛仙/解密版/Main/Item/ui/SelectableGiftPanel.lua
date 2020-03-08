local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local SelectableGiftPanel = Lplus.Extend(ECPanelBase, "SelectableGiftPanel")
local ItemUtils = require("Main.Item.ItemUtils")
local GUIUtils = require("GUI.GUIUtils")
local def = SelectableGiftPanel.define
local dlg
def.field("number").itemId = 0
def.field("userdata").uuid = nil
def.field("number").selIndex = 0
def.field("table").itemList = nil
def.static("=>", SelectableGiftPanel).Instance = function(self)
  if nil == dlg then
    dlg = SelectableGiftPanel()
  end
  return dlg
end
def.static("number", "userdata").ShowGiftsPreview = function(itemId, uuid)
  local tip = SelectableGiftPanel.Instance()
  tip.itemId = itemId
  tip.uuid = uuid
  tip:CreatePanel(RESPATH.PREFAB_GIFT_SELECTABLE_PANEL, 2)
  tip:SetModal(true)
end
def.override().OnCreate = function(self)
  if self.m_panel == nil then
    return
  end
  local cfg = ItemUtils.GetSelectableGiftItemCfg(self.itemId)
  if cfg then
    self.itemList = cfg.items
  else
    self.itemList = {}
  end
  self:UpdateInfo()
  Event.RegisterEvent(ModuleId.ITEM, gmodule.notifyId.item.Item_Use_Selectable_Bag_Item_Res, SelectableGiftPanel.OnUseItemRes)
end
def.override().OnDestroy = function(self)
  self.selIndex = 0
  self.itemList = nil
  Event.UnregisterEvent(ModuleId.ITEM, gmodule.notifyId.item.Item_Use_Selectable_Bag_Item_Res, SelectableGiftPanel.OnUseItemRes)
end
def.method().UpdateInfo = function(self)
  self:UpdateTitle()
  self:UpdateGifts()
end
def.method().UpdateTitle = function(self)
  local Img_Bg = self.m_panel:FindDirect("Img_Bg")
  local Label = Img_Bg:FindDirect("Img_Title/Label")
  local itemBase = ItemUtils.GetItemBase(self.itemId)
  local itemName = itemBase and itemBase.name or ""
  GUIUtils.SetText(Label, itemName)
end
def.method().UpdateGifts = function(self)
  local Img_BgItem = self.m_panel:FindDirect("Img_Bg/Img_BgItem")
  local ScrollView = Img_BgItem:FindDirect("Scroll View")
  local Grid = ScrollView:FindDirect("Grid")
  local itemGiftNum = #self.itemList
  local num = itemGiftNum
  local uiList = Grid:GetComponent("UIList")
  uiList:set_itemCount(num)
  uiList:Resize()
  GameUtil.AddGlobalLateTimer(0, true, function()
    if not uiList.isnil then
      uiList:Reposition()
    end
  end)
  local giftsUI = uiList:get_children()
  for i = 1, itemGiftNum do
    local index = i
    local giftUI = giftsUI[index]
    local itemGiftInfo = self.itemList[i]
    self:FillItemGiftInfo(giftUI, index, itemGiftInfo)
  end
  self:TouchGameObject(self.m_panel, self.m_parent)
  ScrollView:GetComponent("UIScrollView"):ResetPosition()
end
def.method("userdata", "number", "table").FillItemGiftInfo = function(self, giftUI, index, itemGiftInfo)
  local Texture = giftUI:FindDirect(string.format("Texture_%d", index))
  local Label_Num = giftUI:FindDirect(string.format("Label_Nun_%d", index))
  local Label_Name = giftUI:FindDirect(string.format("Label_Name_%d", index))
  local itemBase = ItemUtils.GetItemBase(itemGiftInfo.itemId)
  local iconId = itemBase and itemBase.icon or 0
  local itemName = itemBase and itemBase.name or ""
  local itemNum = itemGiftInfo.itemNum
  GUIUtils.SetTexture(Texture, iconId)
  GUIUtils.SetText(Label_Name, itemName)
  GUIUtils.SetText(Label_Num, itemNum)
end
def.method().OnGetBtnClick = function(self)
  if self.selIndex == 0 then
    Toast(textRes.Item[9600])
    return
  end
  local itemGiftInfo = self.itemList[self.selIndex]
  local selGiftId = itemGiftInfo.itemId
  local uuid = self.uuid
  local ItemModule = require("Main.Item.ItemModule")
  ItemModule.UseSelectBagItem(uuid, self.selIndex)
end
def.method("number", "userdata").ShowItemTips = function(self, index, clickobj)
  local ItemTipsMgr = require("Main.Item.ItemTipsMgr")
  local obj = clickobj
  local position = obj:get_position()
  local screenPos = WorldPosToScreen(position.x, position.y)
  local sprite = obj:GetComponent("UISprite")
  ItemTipsMgr.Instance():ShowBasicTips(self.itemList[index].itemId, screenPos.x, screenPos.y, sprite:get_width(), sprite:get_height(), 0, false)
end
def.method("userdata").OnGiftClick = function(self, clickobj)
  local id = clickobj.name
  local index = tonumber(string.sub(id, #"Img_Item_" + 1, -1))
  self.selIndex = index
  self:ShowItemTips(index, clickobj)
end
def.method("userdata").onClickObj = function(self, clickobj)
  local id = clickobj.name
  if "Btn_Close" == id then
    self:DestroyPanel()
  elseif id == "Btn_Get" then
    self:OnGetBtnClick()
  elseif string.sub(id, 1, #"Img_Item_") == "Img_Item_" then
    self:OnGiftClick(clickobj)
  end
end
def.static("table", "table").OnUseItemRes = function(params, context)
  local itemId = params[1]
  local num = params[2]
  local PersonalHelper = require("Main.Chat.PersonalHelper")
  PersonalHelper.GetItemMsg(itemId, num)
  dlg:DestroyPanel()
end
SelectableGiftPanel.Commit()
return SelectableGiftPanel
