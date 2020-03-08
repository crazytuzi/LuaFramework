local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local DlgMagicMarkUnlock = Lplus.Extend(ECPanelBase, "DlgMagicMarkUnlock")
local def = DlgMagicMarkUnlock.define
local dlg
local GUIUtils = require("GUI.GUIUtils")
def.field("number").markType = 0
def.field("table").items = nil
def.static("=>", DlgMagicMarkUnlock).Instance = function()
  if dlg == nil then
    dlg = DlgMagicMarkUnlock()
  end
  return dlg
end
def.override().OnCreate = function(self)
  self:ShowUnlockTime()
end
def.method("number").ShowDlg = function(self, markType)
  if self.m_panel then
    self:DestroyPanel()
  end
  self.markType = markType
  local ItemModule = require("Main.Item.ItemModule")
  local ItemType = require("consts.mzm.gsp.item.confbean.ItemType")
  local items = ItemModule.Instance():GetItemsByItemType(ItemModule.BAG, ItemType.MAGIC_MARK)
  self.items = {}
  if items then
    for _, item in pairs(items) do
      local markcfg = gmodule.moduleMgr:GetModule(ModuleId.MAGIC_MARK):GetMagicMarkItemCfg(item.id)
      if markcfg and markcfg.magicType == self.markType then
        item.lastHour = markcfg.lastHour
        table.insert(self.items, item)
      end
    end
  end
  if #self.items == 0 then
    Toast(textRes.MagicMark[14])
    return
  end
  table.sort(self.items, function(a, b)
    if a == nil then
      return true
    elseif b == nil then
      return false
    elseif a.lastHour < 0 and b.lastHour < 0 then
      return a.id < b.id
    elseif a.lastHour < 0 then
      return true
    elseif b.lastHour < 0 then
      return false
    elseif a.lastHour > b.lastHour then
      return true
    else
      return false
    end
  end)
  self:CreatePanel(RESPATH.PREFAB_MAGIC_MARK_UNLOCK_PANEL, 2)
  self:SetModal(true)
end
def.override().OnDestroy = function(self)
  self.items = nil
end
def.method("string").onClick = function(self, id)
  if id == "Btn_AllSelect" then
    self:CheckAll(true)
    self:ShowUnlockTime()
  elseif id == "Btn_ClearSelect" then
    self:CheckAll(false)
    self:ShowUnlockTime()
  elseif id == "Btn_Buy" then
    if self:Unlock() then
      self:DestroyPanel()
    end
  elseif id == "Btn_Close" then
    self:DestroyPanel()
  elseif string.find(id, "item_") then
    self:ShowUnlockTime()
  end
end
def.override("boolean").OnShow = function(self, s)
  if s == false then
    return
  end
  self:ShowAllItems()
  if gmodule.moduleMgr:GetModule(ModuleId.MAGIC_MARK):hasMagicMark(self.markType) then
    self.m_panel:FindDirect("Img_Bg/Btn_Buy/Label_Buy"):GetComponent("UILabel").text = textRes.MagicMark[21]
  else
    self.m_panel:FindDirect("Img_Bg/Btn_Buy/Label_Buy"):GetComponent("UILabel").text = textRes.MagicMark[20]
  end
end
def.method().ShowUnlockTime = function(self)
  if self.m_panel then
    local listPanel = self.m_panel:FindDirect("Img_Bg/Img_Bg1/Scroll View_Item/List_Item")
    local uiList = listPanel:GetComponent("UIList")
    local count = self.items and #self.items or 0
    local duration = 0
    local checked_count = 0
    if count > 0 and 0 < uiList.itemCount then
      local uiItems = uiList.children
      for i = 1, count do
        local uiItem = uiItems[i]
        if uiItem then
          local isChecked = uiItem:GetComponent("UIToggle").isChecked
          if isChecked then
            checked_count = checked_count + 1
            if 0 > self.items[i].lastHour then
              duration = -1
            elseif duration >= 0 then
              duration = duration + self.items[i].lastHour
            end
          end
        end
      end
    end
    self.m_panel:FindDirect("Img_Bg/Btn_AllSelect"):SetActive(count > checked_count)
    self.m_panel:FindDirect("Img_Bg/Btn_ClearSelect"):SetActive(checked_count == count)
    local str = ""
    if duration < 0 then
      str = textRes.MagicMark[15]
    elseif duration > 0 then
      str = string.format(textRes.MagicMark[10], math.floor(duration / 24))
    elseif duration == 0 then
      self.m_panel:FindDirect("Img_Bg/Label_Tips2"):SetActive(false)
      return
    end
    self.m_panel:FindDirect("Img_Bg/Label_Tips2"):SetActive(true)
    self.m_panel:FindDirect("Img_Bg/Label_Tips2"):GetComponent("UILabel").text = str
  end
end
def.method().ShowAllItems = function(self)
  if self.m_panel == nil then
    return
  end
  local listPanel = self.m_panel:FindDirect("Img_Bg/Img_Bg1/Scroll View_Item/List_Item")
  local uiList = listPanel:GetComponent("UIList")
  if self.items == nil or #self.items == 0 then
    uiList.itemCount = 0
    uiList:Resize()
    return
  end
  local ItemUtils = require("Main.Item.ItemUtils")
  uiList.itemCount = #self.items
  uiList:Resize()
  local uiItems = uiList.children
  for i = 1, uiList.itemCount do
    local uiItem = uiItems[i]
    local itemdata = self.items[i]
    local itemBase = ItemUtils.GetItemBase(itemdata.id)
    local Texture_Icon = uiItem:FindDirect("Icon_Equip01")
    if itemBase then
      uiItem:FindDirect("Label_EquipName01"):GetComponent("UILabel").text = itemBase.name
      GUIUtils.SetTexture(Texture_Icon, itemBase.icon)
    end
  end
end
def.method("boolean").CheckAll = function(self, check)
  local listPanel = self.m_panel:FindDirect("Img_Bg/Img_Bg1/Scroll View_Item/List_Item")
  local uiList = listPanel:GetComponent("UIList")
  local count = uiList.itemCount
  if count <= 0 then
    return
  end
  local uiItems = uiList.children
  for i = 1, count do
    local uiItem = uiItems[i]
    uiItem:GetComponent("UIToggle"):set_isChecked(check)
  end
end
def.method("=>", "boolean").Unlock = function(self)
  if IsCrossingServer() then
    ToastCrossingServerForbiden()
    return false
  end
  local IDIPInterface = require("Main.IDIP.IDIPInterface")
  local ItemSwitchInfo = require("netio.protocol.mzm.gsp.idip.ItemSwitchInfo")
  local bOpen = IDIPInterface.IsItemIDIPOpen(ItemSwitchInfo.MAGIC_MARK, self.markType)
  if not bOpen then
    Toast(textRes.MagicMark[24])
    return false
  end
  local listPanel = self.m_panel:FindDirect("Img_Bg/Img_Bg1/Scroll View_Item/List_Item")
  local uiList = listPanel:GetComponent("UIList")
  local count = uiList.itemCount
  if count <= 0 then
    return false
  end
  local uiItems = uiList.children
  local itemIds = {}
  for i = 1, count do
    local uiItem = uiItems[i]
    local isChecked = uiItem:GetComponent("UIToggle").isChecked
    if isChecked then
      table.insert(itemIds, self.items[i].id)
    end
  end
  if #itemIds <= 0 then
    Toast(textRes.MagicMark[22])
    return false
  end
  local pro
  if gmodule.moduleMgr:GetModule(ModuleId.MAGIC_MARK):hasMagicMark(self.markType) then
    local lefttime = gmodule.moduleMgr:GetModule(ModuleId.MAGIC_MARK).owned[self.markType]
    if Int64.lt(lefttime, 0) then
      Toast(textRes.MagicMark[13])
      return false
    end
    pro = require("netio.protocol.mzm.gsp.magicmark.CExtendMagicMarkTimeReq").new(itemIds)
  else
    pro = require("netio.protocol.mzm.gsp.magicmark.CUnLockMagicMarkReq").new(itemIds)
  end
  gmodule.network.sendProtocol(pro)
  return true
end
DlgMagicMarkUnlock.Commit()
return DlgMagicMarkUnlock
