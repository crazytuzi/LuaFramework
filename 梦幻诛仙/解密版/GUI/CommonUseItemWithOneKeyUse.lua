local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local CommonUseItemWithOneKeyUse = Lplus.Extend(ECPanelBase, "CommonUseItemWithOneKeyUse")
local ItemUtils = require("Main.Item.ItemUtils")
local ItemModule = require("Main.Item.ItemModule")
local GUIUtils = require("GUI.GUIUtils")
local ItemTipsMgr = require("Main.Item.ItemTipsMgr")
local def = CommonUseItemWithOneKeyUse.define
local instance
def.static("=>", CommonUseItemWithOneKeyUse).Instance = function()
  if instance == nil then
    instance = CommonUseItemWithOneKeyUse()
  end
  return instance
end
def.const("number").ALLUSETIME = 3
def.field("string").title = ""
def.field("table").itemTypeList = nil
def.field("table").itemList = nil
def.field("function").callback = nil
def.field("number").curIndex = 0
def.field("number").lastUseItemId = 0
def.field("number").repeatTimes = 0
def.field("table").itemIdMap = nil
def.field("table").initPos = nil
def.field("function").onDestroyCallback = nil
def.field("boolean").enableUseAll = true
def.static("string", "table", "function", "function").ShowCommonUseByItemId = function(title, itemIdList, callback, onDestroyCallback)
  local self = CommonUseItemWithOneKeyUse.Instance()
  if itemIdList == nil or callback == nil then
    return
  end
  self.title = title
  self.itemIdMap = {}
  for i = 1, #itemIdList do
    self.itemIdMap[itemIdList[i]] = 0
  end
  self.repeatTimes = 0
  self.callback = callback
  self.onDestroyCallback = onDestroyCallback
  self:UpdateItemData()
  if self:IsShow() then
    self:UpdateTitle()
    self:UpdateItemList()
    self:UpdateSelectInfo()
  else
    self:CreatePanel(RESPATH.PANEL_ONEKEY_QUICKUSE, 2)
  end
end
def.static("string", "table", "function", "function").ShowCommonUse = function(title, itemTypeList, callback, onDestroyCallback)
  local self = CommonUseItemWithOneKeyUse.Instance()
  if itemTypeList == nil or callback == nil then
    return
  end
  self.itemTypeList = itemTypeList
  self.title = title
  self.callback = callback
  self.onDestroyCallback = onDestroyCallback
  self.repeatTimes = 0
  self:UpdateItemData()
  if self:IsShow() then
    self:UpdateTitle()
    self:UpdateItemList()
    self:UpdateSelectInfo()
  else
    self:CreatePanel(RESPATH.PANEL_QUICKUSE, 2)
  end
end
def.method().UpdateItemData = function(self)
  if self.itemTypeList ~= nil then
    self.itemIdMap = {}
    for k, v in ipairs(self.itemTypeList) do
      local itemIds = ItemUtils.GetItemTypeRefIdList(v)
      for _, id in pairs(itemIds) do
        self.itemIdMap[id] = 0
      end
    end
    for k, v in ipairs(self.itemTypeList) do
      local items = ItemModule.Instance():GetItemsByItemType(ItemModule.BAG, v)
      for n, item in pairs(items) do
        self.itemIdMap[item.id] = self.itemIdMap[item.id] + item.number
      end
    end
  else
    for k, _ in pairs(self.itemIdMap) do
      self.itemIdMap[k] = 0
      self.itemIdMap[k] = ItemModule.Instance():GetNumberByItemId(ItemModule.BAG, k)
    end
  end
  self.itemList = {}
  for k, v in pairs(self.itemIdMap) do
    table.insert(self.itemList, {id = k, number = v})
  end
  table.sort(self.itemList, function(a, b)
    if a == nil then
      return true
    elseif b == nil then
      return false
    else
      return a.id < b.id
    end
  end)
end
def.override().OnCreate = function(self)
  Event.RegisterEventWithContext(ModuleId.ITEM, gmodule.notifyId.item.Item_OnBagInfoSynchronized, CommonUseItemWithOneKeyUse.OnItemChange, self)
  self:UpdateTitle()
  self:UpdateItemList()
  self:UpdateSelectInfo()
end
def.override("boolean").OnShow = function(self, isShow)
  if not isShow then
    return
  end
  if self.initPos then
    self.m_panel.localPosition = self.initPos
  else
    self.m_panel.localPosition = require("Types.Vector3").Vector3.zero
  end
end
def.override().OnDestroy = function(self)
  Event.UnregisterEvent(ModuleId.ITEM, gmodule.notifyId.item.Item_OnBagInfoSynchronized, CommonUseItemWithOneKeyUse.OnItemChange)
  self.lastUseItemId = 0
  self.initPos = nil
  self.itemTypeList = nil
  self.itemIdMap = nil
  self.enableUseAll = true
  self.curIndex = 0
  if self.onDestroyCallback then
    SafeCall(self.onDestroyCallback)
  end
end
def.method("table").OnItemChange = function(self, params)
  self:UpdateItemData()
  self:UpdateItemList()
  self:UpdateSelectInfo()
end
def.method().UpdateTitle = function(self)
  local titleLbl = self.m_panel:FindDirect("Img_Bg/Title")
  titleLbl:GetComponent("UILabel"):set_text(self.title)
end
def.method("number").SelectItem = function(self, index)
  if index <= 0 then
    self.curIndex = 0
  else
    self.curIndex = index
  end
  self:UpdateSelectInfo()
end
def.method("=>", "table").GetItemIdsNotInBag = function(self)
  local ret = {}
  for itemId, num in pairs(self.itemIdMap) do
    if num == 0 then
      table.insert(ret, itemId)
    end
  end
  return ret
end
def.method().UpdateItemList = function(self)
  local list = self.m_panel:FindDirect("Img_Bg/Group_Left/Scroll View/List")
  local listCmp = list:GetComponent("UIList")
  local listNum = #self.itemList
  listCmp:set_itemCount(listNum)
  listCmp:Resize()
  GameUtil.AddGlobalLateTimer(0, true, function()
    if not listCmp.isnil then
      listCmp:Reposition()
    end
  end)
  local items = listCmp:get_children()
  local itemCount = #self.itemList
  for i = 1, listNum do
    self:FillItemIcon(items[i], self.itemList[i].id, self.itemList[i].number, i)
    self.m_msgHandler:Touch(items[i])
  end
end
def.method("userdata", "number", "number", "number").FillItemIcon = function(self, uiGo, itemId, itemNum, index)
  local itemBase = ItemUtils.GetItemBase(itemId)
  local texture = uiGo:FindDirect(string.format("Img_Icon_%d", index))
  local uiTexture = texture:GetComponent("UITexture")
  GUIUtils.FillIcon(uiTexture, itemBase.icon)
  local numLbl = uiGo:FindDirect(string.format("Number_%d", index))
  numLbl:GetComponent("UILabel"):set_text(tostring(itemNum))
end
def.method().UpdateSelectInfo = function(self)
  if self.curIndex <= 0 or self.curIndex > #self.itemList then
    local rightPanel = self.m_panel:FindDirect("Img_Bg/Group_Right")
    rightPanel:SetActive(false)
    return
  else
    local rightPanel = self.m_panel:FindDirect("Img_Bg/Group_Right")
    rightPanel:SetActive(true)
  end
  local itemData = self.itemList[self.curIndex]
  local itemId
  if itemData then
    itemId = itemData.id
    if self.lastUseItemId ~= itemData.id then
      self.lastUseItemId = itemData.id
      self.repeatTimes = 0
    end
  end
  if itemId == nil then
    return
  end
  local itemBase = ItemUtils.GetItemBase(itemId)
  local icon = self.m_panel:FindDirect("Img_Bg/Group_Right/Item/Img_Icon")
  local uiTexture = icon:GetComponent("UITexture")
  GUIUtils.FillIcon(uiTexture, itemBase.icon)
  local name = self.m_panel:FindDirect("Img_Bg/Group_Right/Label_Name")
  name:GetComponent("UILabel"):set_text(itemBase.name)
  local htmlDes = self.m_panel:FindDirect("Img_Bg/Group_Right/Label_Describe")
  local html = ItemTipsMgr.Instance():GetSimpleDescription(itemBase)
  html = string.gsub(html, "ffffff", "8f3d21")
  htmlDes:GetComponent("NGUIHTML"):ForceHtmlText(html)
  local btn0 = self.m_panel:FindDirect("Img_Bg/Group_Right/Btn_Use")
  local btn1 = self.m_panel:FindDirect("Img_Bg/Group_Right/Btn_Get")
  local btn2 = self.m_panel:FindDirect("Img_Bg/Group_Right/Btn_AllUse")
  local itemNum = itemData and itemData.number or 0
  if itemNum > 0 then
    btn0:SetActive(true)
    btn1:SetActive(false)
    btn2:SetActive(true)
  else
    btn0:SetActive(false)
    btn1:SetActive(true)
    btn2:SetActive(false)
  end
end
def.method().UseItem = function(self)
  if self.curIndex <= 0 then
    Toast(textRes.Common[80])
  else
    local itemData = self.itemList[self.curIndex]
    if itemData == nil then
      return
    end
    local itemId = itemData.id
    if self.callback then
      if self.lastUseItemId == itemData.id and 0 < itemData.number then
        if self.enableUseAll and self.repeatTimes + 1 == CommonUseItemWithOneKeyUse.ALLUSETIME then
          local itemBase = ItemUtils.GetItemBase(itemId)
          local askStr = string.format(textRes.Item[8323], require("Main.Chat.HtmlHelper").NameColor[itemBase.namecolor], itemBase.name)
          require("GUI.CommonConfirmDlg").ShowConfirm(textRes.Item[8324], askStr, function(selection, tag)
            if selection == 1 then
              local item_data = self.itemList[self.curIndex]
              if item_data then
                self.callback(item_data.id, true)
                self.repeatTimes = 0
              end
            else
              self.repeatTimes = self.repeatTimes + 1
            end
          end, nil)
        else
          local ret = self.callback(itemData.id, false)
          if ret == nil then
            ret = true
          end
          if ret then
            itemData.number = itemData.number - 1
            self.repeatTimes = self.repeatTimes + 1
          end
        end
      else
        self.callback(itemData.id, false)
        self.lastUseItemId = itemData.id
        self.repeatTimes = 1
      end
    end
  end
end
def.method().UseAllItem = function(self)
  if self.curIndex <= 0 then
    Toast(textRes.Common[80])
  else
    local itemData = self.itemList[self.curIndex]
    if itemData == nil then
      return
    end
    local itemId = itemData.id
    if self.callback then
      self.callback(itemId, true)
    end
    self.lastUseItemId = itemData.id
    self.repeatTimes = 0
  end
end
def.method().AccessItem = function(self)
  if self.curIndex <= 0 then
    Toast(textRes.Common[80])
  else
    local itemData = self.itemList[self.curIndex]
    local itemId
    if itemData then
      itemId = itemData.id
    else
      local ids_not_in_bag = self:GetItemIdsNotInBag()
      local idx = self.curIndex - #self.itemList
      itemId = ids_not_in_bag[idx]
    end
    if itemId == nil then
      return
    end
    local ItemAccessMgr = require("Main.Item.ItemAccessMgr")
    local btnGo = self.m_panel:FindDirect("Img_Bg/Group_Right/Btn_Get")
    local position = btnGo.position
    local screenPos = WorldPosToScreen(position.x, position.y)
    local widget = btnGo:GetComponent("UIWidget")
    ItemAccessMgr.Instance():ShowSource(itemId, screenPos.x, screenPos.y, widget.width, widget.height, 0)
  end
end
def.method("string").onClick = function(self, id)
  if id == "Btn_Close" or id == "Modal" then
    self:DestroyPanel()
  elseif id == "Btn_Use" then
    self:UseItem()
  elseif id == "Btn_AllUse" then
    self:UseAllItem()
  elseif id == "Btn_Get" then
    self:AccessItem()
  elseif string.sub(id, 1, 5) == "Item_" then
    local index = tonumber(string.sub(id, 6))
    self:SelectItem(index)
  end
end
return CommonUseItemWithOneKeyUse.Commit()
