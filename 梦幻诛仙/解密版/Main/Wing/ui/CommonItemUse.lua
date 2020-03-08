local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local CommonItemUse = Lplus.Extend(ECPanelBase, "CommonItemUse")
local ItemUtils = require("Main.Item.ItemUtils")
local ItemModule = require("Main.Item.ItemModule")
local GUIUtils = require("GUI.GUIUtils")
local ItemTipsMgr = require("Main.Item.ItemTipsMgr")
local def = CommonItemUse.define
local instance
def.static("=>", CommonItemUse).Instance = function()
  if instance == nil then
    instance = CommonItemUse()
  end
  return instance
end
def.const("number").ALLUSETIME = 3
def.field("string").title = ""
def.field("table").itemList = nil
def.field("table").itemMap = nil
def.field("function").callback = nil
def.field("number").curIndex = 0
def.field("number").lastUseId = 0
def.field("number").repeatTimes = 0
def.field("number").bagId = ItemModule.BAG
def.static("string", "table", "function").ShowCommonUseByItemId = function(title, itemIdList, callback)
  CommonItemUse.ShowCommonUseByItemIdWithBagId(title, itemIdList, callback, ItemModule.BAG)
end
def.static("string", "table", "function").ShowCommonUse = function(title, itemTypList, callback)
  CommonItemUse.ShowCommonUseWithBagId(title, itemTypList, callback, ItemModule.BAG)
end
def.static("string", "table", "function", "number").ShowCommonUseByItemIdWithBagId = function(title, itemIdList, callback, bagId)
  local self = CommonItemUse.Instance()
  if self:IsShow() then
    return
  end
  if itemIdList == nil or callback == nil then
    return
  end
  self.curIndex = 0
  self.title = title
  self.itemList = itemIdList
  self.bagId = bagId
  self.itemMap = {}
  self:UpdateItemNum()
  self.callback = callback
  self:CreatePanel(RESPATH.PANEL_QUICKUSE, 2)
  self:SetModal(true)
end
def.static("string", "table", "function", "number").ShowCommonUseWithBagId = function(title, itemTypList, callback, bagId)
  local self = CommonItemUse.Instance()
  if self:IsShow() then
    return
  end
  if itemTypList == nil or callback == nil then
    return
  end
  self.curIndex = 0
  self.title = title
  self.bagId = bagId
  self.itemList = {}
  for k, v in ipairs(itemTypList) do
    local items = ItemUtils.GetItemTypeRefIdList(v)
    table.insertto(self.itemList, items)
  end
  self.itemMap = {}
  self:UpdateItemNum()
  self.callback = callback
  self:CreatePanel(RESPATH.PANEL_QUICKUSE, 2)
  self:SetModal(true)
end
def.method().UpdateItemNum = function(self)
  if self.itemList ~= nil then
    for k, v in ipairs(self.itemList) do
      local num = ItemModule.Instance():GetNumberByItemId(self.bagId, v)
      self.itemMap[v] = num
    end
  end
end
def.override().OnCreate = function(self)
  Event.RegisterEventWithContext(ModuleId.ITEM, gmodule.notifyId.item.Item_OnBagInfoSynchronized, CommonItemUse.OnItemChange, self)
  self:UpdateTitle()
  self:UpdateItemList()
  self:UpdateSelectInfo()
end
def.override("boolean").OnShow = function(self, isShow)
end
def.override().OnDestroy = function(self)
  Event.UnregisterEvent(ModuleId.ITEM, gmodule.notifyId.item.Item_OnBagInfoSynchronized, CommonItemUse.OnItemChange)
  self.lastUseId = 0
end
def.method("table").OnItemChange = function(self, params)
  self:UpdateItemNum()
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
  elseif index > #self.itemList then
    self.curIndex = 0
  else
    self.curIndex = index
  end
  self:UpdateSelectInfo()
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
  for i = 1, #items do
    local uiGo = items[i]
    local itemId = self.itemList[i]
    local itemNum = self.itemMap[itemId] or 0
    self:FillItemIcon(uiGo, itemId, itemNum, i)
    self.m_msgHandler:Touch(uiGo)
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
  if self.curIndex <= 0 then
    local rightPanel = self.m_panel:FindDirect("Img_Bg/Group_Right")
    rightPanel:SetActive(false)
    return
  else
    local rightPanel = self.m_panel:FindDirect("Img_Bg/Group_Right")
    rightPanel:SetActive(true)
  end
  local itemId = self.itemList[self.curIndex]
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
  local itemNum = self.itemMap[itemId] or 0
  if itemNum > 0 then
    btn0:SetActive(true)
    btn1:SetActive(false)
  else
    btn0:SetActive(false)
    btn1:SetActive(true)
  end
end
def.method().UseItem = function(self)
  if self.curIndex <= 0 then
    Toast(textRes.Wing[13])
  else
    do
      local itemId = self.itemList[self.curIndex]
      if self.callback then
        local ret = self.callback(itemId, false)
        if ret == nil or not ret then
          ret = true
        end
        if self.lastUseId == itemId then
          if ret then
            self.repeatTimes = self.repeatTimes + 1
            if self.repeatTimes == CommonItemUse.ALLUSETIME then
              local itemBase = ItemUtils.GetItemBase(itemId)
              local askStr = string.format(textRes.Item[8323], require("Main.Chat.HtmlHelper").NameColor[itemBase.namecolor], itemBase.name)
              require("GUI.CommonConfirmDlg").ShowConfirm(textRes.Item[8324], askStr, function(selection, tag)
                if selection == 1 then
                  self.repeatTimes = 0
                  self.callback(itemId, true)
                end
              end, nil)
            end
          end
        else
          self.lastUseId = itemId
          self.repeatTimes = 1
        end
      end
    end
  end
end
def.method().AccessItem = function(self)
  if self.curIndex <= 0 then
    Toast(textRes.Wing[13])
  else
    local itemId = self.itemList[self.curIndex]
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
  elseif id == "Btn_Get" then
    self:AccessItem()
  elseif string.sub(id, 1, 5) == "Item_" then
    local index = tonumber(string.sub(id, 6))
    self:SelectItem(index)
  end
end
return CommonItemUse.Commit()
