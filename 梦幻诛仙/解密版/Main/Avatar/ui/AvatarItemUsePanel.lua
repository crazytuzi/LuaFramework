local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local GUIUtils = require("GUI.GUIUtils")
local AvatarItemUsePanel = Lplus.Extend(ECPanelBase, "AvatarItemUsePanel")
local ItemTipsMgr = require("Main.Item.ItemTipsMgr")
local ItemModule = require("Main.Item.ItemModule")
local ItemUtils = require("Main.Item.ItemUtils")
local AvatarInterface = require("Main.Avatar.AvatarInterface")
local def = AvatarItemUsePanel.define
local instance
def.field("number").avatarId = 0
def.field("table").avatarItemList = nil
def.field("table").selectedItemList = nil
def.static("=>", AvatarItemUsePanel).Instance = function()
  if instance == nil then
    instance = AvatarItemUsePanel()
    instance:Init()
  end
  return instance
end
def.method().Init = function(self)
  self.m_TrigGC = true
end
def.method("number").ShowPanel = function(self, avatarId)
  self.avatarId = avatarId
  if self:IsShow() then
    return
  end
  self:CreatePanel(RESPATH.PERFAB_CHANGE_HEAD_PROP, 0)
  self:SetModal(true)
end
def.method().HideDlg = function(self)
  self:DestroyPanel()
end
def.method("userdata").onClickObj = function(self, clickObj)
  local id = clickObj.name
  warn("AvatarItemUsePanel click id:", id)
  local strs = string.split(id, "_")
  if id == "Btn_Close" then
    self:HideDlg()
  elseif id == "Btn_AllSelect" then
    self.selectedItemList = {}
    for i, v in ipairs(self.avatarItemList) do
      self.selectedItemList[i] = v
    end
    self:setItemListSelectedState(true)
  elseif id == "Btn_ClearSelect" then
    self.selectedItemList = {}
    self:setItemListSelectedState(false)
  elseif id == "Btn_Change" or id == "Btn_Rollover" then
    local keys = {}
    if self.selectedItemList then
      for i, v in pairs(self.selectedItemList) do
        table.insert(keys, v.itemKey)
      end
    end
    if #keys > 0 then
      local p = require("netio.protocol.mzm.gsp.avatar.CUseUnlockItemReq").new(keys)
      gmodule.network.sendProtocol(p)
      warn("-------keys:", #keys)
      self:HideDlg()
    else
      Toast(textRes.Avatar[21])
    end
  elseif strs[1] == "item" then
    local idx = tonumber(strs[2])
    if idx then
      self.selectedItemList = self.selectedItemList or {}
      if self.selectedItemList[idx] == nil then
        for i, v in pairs(self.selectedItemList) do
          local avatarItemCfg = AvatarInterface.GetAvatarUnlockCfg(v.id)
          if avatarItemCfg.duration == 0 then
            Toast(textRes.Avatar[20])
            clickObj:GetComponent("UIToggle").value = false
            return
          end
        end
      end
      if self.selectedItemList[idx] then
        self.selectedItemList[idx] = nil
      else
        local curItem = self.avatarItemList[idx]
        self.selectedItemList[idx] = curItem
        local avatarItemCfg = AvatarInterface.GetAvatarUnlockCfg(curItem.id)
        if avatarItemCfg.duration == 0 then
          self:setItemListSelectedState(true)
        end
      end
      self:setBtnState()
    end
  end
end
def.override().OnCreate = function(self)
end
def.override().OnDestroy = function(self)
end
def.override("boolean").OnShow = function(self, b)
  if b then
    self:setAvatarItemList()
    self:setAddUseTime()
    self:setBtnState()
  else
    self.avatarItemList = nil
    self.selectedItemList = nil
  end
end
def.method().setAvatarItemList = function(self)
  local itemList = {}
  local unlockItemCfg = AvatarInterface.GetAvatar2UnlockItemCfg(self.avatarId)
  for i, v in ipairs(unlockItemCfg.items) do
    local items = ItemModule.Instance():GetItemsByItemID(ItemModule.BAG, v.itemId)
    for _, item in pairs(items) do
      table.insert(itemList, item)
    end
  end
  self.avatarItemList = itemList
  local List_Item = self.m_panel:FindDirect("Img_Bg/Img_Bg1/Scroll View_Item/List_Item")
  local uiList = List_Item:GetComponent("UIList")
  uiList.itemCount = #itemList
  uiList:Resize()
  for i, v in ipairs(itemList) do
    local item = List_Item:FindDirect("item_" .. i)
    if self.selectedItemList and self.selectedItemList[i] then
      item:GetComponent("UIToggle").value = true
    else
      item:GetComponent("UIToggle").value = false
    end
    local Icon_Equip01 = item:FindDirect("Icon_Equip01")
    local Label_EquipName01 = item:FindDirect("Label_EquipName01")
    local Label_Num = item:FindDirect("Label_Num")
    local itemBase = ItemUtils.GetItemBase(v.id)
    GUIUtils.FillIcon(Icon_Equip01:GetComponent("UITexture"), itemBase.icon)
    Label_EquipName01:GetComponent("UILabel"):set_text(itemBase.name)
    Label_Num:GetComponent("UILabel"):set_text(v.number)
  end
end
def.method("boolean").setItemListSelectedState = function(self, isSelected)
  local itemList = self.avatarItemList
  local List_Item = self.m_panel:FindDirect("Img_Bg/Img_Bg1/Scroll View_Item/List_Item")
  local uiList = List_Item:GetComponent("UIList")
  uiList.itemCount = #itemList
  uiList:Resize()
  local foreverIdx = -1
  if isSelected then
    foreverIdx = self:getForeverItemIdx()
  end
  for i, v in ipairs(itemList) do
    local item = List_Item:FindDirect("item_" .. i)
    if isSelected then
      if foreverIdx > 0 then
        local isEqual = foreverIdx == i
        item:GetComponent("UIToggle").value = isEqual
        if not isEqual then
          self.selectedItemList[i] = nil
        end
      else
        item:GetComponent("UIToggle").value = isSelected
      end
    else
      item:GetComponent("UIToggle").value = isSelected
    end
  end
  self:setBtnState()
end
def.method("=>", "number").getForeverItemIdx = function(self)
  local foreverIdx = -1
  for i, v in ipairs(self.avatarItemList) do
    local avatarItemCfg = AvatarInterface.GetAvatarUnlockCfg(v.id)
    if avatarItemCfg.duration == 0 then
      foreverIdx = i
      break
    end
  end
  return foreverIdx
end
def.method().setBtnState = function(self)
  local Img_Bg = self.m_panel:FindDirect("Img_Bg")
  local Btn_AllSelect = Img_Bg:FindDirect("Btn_AllSelect")
  local Btn_ClearSelect = Img_Bg:FindDirect("Btn_ClearSelect")
  local Btn_Rollover = Img_Bg:FindDirect("Btn_Rollover")
  local Btn_Change = Img_Bg:FindDirect("Btn_Change")
  local avatarInterface = AvatarInterface.Instance()
  if avatarInterface:isUnlockAvatarId(self.avatarId) then
    Btn_Change:SetActive(false)
    Btn_Rollover:SetActive(true)
  else
    Btn_Change:SetActive(true)
    Btn_Rollover:SetActive(false)
  end
  local isSelected = false
  if self.selectedItemList then
    for i, v in pairs(self.selectedItemList) do
      isSelected = true
      break
    end
  end
  if isSelected then
    Btn_AllSelect:SetActive(false)
    Btn_ClearSelect:SetActive(true)
  else
    Btn_AllSelect:SetActive(true)
    Btn_ClearSelect:SetActive(false)
  end
  self:setAddUseTime()
end
def.method().setAddUseTime = function(self)
  local Label_Tips2 = self.m_panel:FindDirect("Img_Bg/Label_Tips2")
  if self.selectedItemList then
    local time
    for i, v in pairs(self.selectedItemList) do
      local avatarItemCfg = AvatarInterface.GetAvatarUnlockCfg(v.id)
      if avatarItemCfg.duration == 0 then
        Label_Tips2:GetComponent("UILabel"):set_text(string.format(textRes.Avatar[17], textRes.Avatar[18]))
        return
      else
        time = time or 0
        time = time + avatarItemCfg.duration * v.number
      end
    end
    if time then
      local days = math.floor(time / 24)
      local hours = time - days * 24
      local timeStr = string.format(textRes.Avatar[19], days, hours)
      Label_Tips2:GetComponent("UILabel"):set_text(string.format(textRes.Avatar[17], timeStr))
    else
      Label_Tips2:GetComponent("UILabel"):set_text("")
    end
  else
    Label_Tips2:GetComponent("UILabel"):set_text("")
  end
end
AvatarItemUsePanel.Commit()
return AvatarItemUsePanel
