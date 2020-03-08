local Lplus = require("Lplus")
local ItemUtils = require("Main.Item.ItemUtils")
local ItemModule = require("Main.Item.ItemModule")
local ItemXStoreType = require("netio.protocol.mzm.gsp.item.ItemXStoreType")
local ECPanelBase = require("GUI.ECPanelBase")
local GUIUtils = require("GUI.GUIUtils")
local CommonConfirmDlg = require("GUI.CommonConfirmDlg")
local RepairEquipPanel = Lplus.Extend(ECPanelBase, "RepairEquipPanel")
local def = RepairEquipPanel.define
local instance
def.field("number").m_NeedMoney = 0
def.field("number").m_CurIndex = 0
def.field("number").m_ListNum = 0
def.field("table").m_ListData = nil
def.field("table").m_UIGO = nil
def.field("userdata").m_Money = nil
def.static("=>", RepairEquipPanel).Instance = function()
  if not instance then
    instance = RepairEquipPanel()
  end
  return instance
end
def.static("table", "table").OnEquipUpdate = function(p1, p2)
  if instance and instance.m_panel and not instance.m_panel.isnil then
    instance.m_CurIndex = 0
    instance:Update()
  end
end
def.method().ShowPanel = function(self)
  if self:IsShow() then
    self:DestroyPanel()
  end
  self:CreatePanel(RESPATH.PREFAB_REPIR_EQUIP_PANEL, GUILEVEL.MUTEX)
  self:SetModal(true)
end
def.override().OnCreate = function(self)
  self:InitUI()
  self:Update()
  Event.RegisterEvent(ModuleId.ITEM, gmodule.notifyId.item.Item_Equip_Broken_Update, RepairEquipPanel.OnEquipUpdate)
end
def.override().OnDestroy = function(self)
  self.m_NeedMoney = 0
  self.m_CurIndex = 0
  self.m_UIGO = nil
  self.m_Money = nil
  Event.UnregisterEvent(ModuleId.ITEM, gmodule.notifyId.item.Item_Equip_Broken_Update, RepairEquipPanel.OnEquipUpdate)
end
def.method().FixEquip = function(self)
  local item = self.m_ListData[self.m_CurIndex]
  if not item then
    return
  end
  local fixEquip = require("netio.protocol.mzm.gsp.item.CFixEquipment").new(item.type, item.data.itemKey)
  gmodule.network.sendProtocol(fixEquip)
end
def.method("string").onClick = function(self, id)
  if id == "Btn_Close" then
    self:DestroyPanel()
  elseif id == "Btn_Add" then
    GoToBuySilver(false)
  elseif id == "Btn_Repair" then
    if self.m_ListNum == 0 then
      Toast(textRes.Item[159])
      return
    elseif self.m_CurIndex == 0 then
      Toast(textRes.Item[158])
      return
    end
    self:FixEquip()
  elseif id == "Btn_RepairAll" then
    if self.m_ListNum == 0 then
      Toast(textRes.Item[159])
      return
    end
    ItemModule.Instance():FixAllEquip(true)
  elseif id:find("Img_Item_") == 1 then
    local _, lastIndex = id:find("Img_Item_")
    local index = tonumber(id:sub(lastIndex + 1, id:len()))
    self.m_CurIndex = index
    self:UpdateMoneyData()
    self:UpdateRightView()
  end
end
def.method().UpdateListData = function(self)
  self.m_ListData = {}
  local bagType = {
    ItemModule.EQUIPBAG,
    ItemModule.BAG
  }
  local index = 0
  for _, t in pairs(bagType) do
    local temp = ItemModule.Instance():GetBrokenEquipsByBagID(t)
    for _, v in pairs(temp) do
      index = index + 1
      self.m_ListData[index] = {}
      self.m_ListData[index].type = t
      self.m_ListData[index].data = v
    end
  end
  table.sort(self.m_ListData, function(l, r)
    local lType = l.type
    local rType = r.type
    if lType ~= rType then
      return lType > rType
    else
      local lIndex = l.data.position
      local rIndex = r.data.position
      return lIndex < rIndex
    end
  end)
  self.m_ListNum = index
end
def.method().UpdateMoneyData = function(self)
  self.m_Money = ItemModule.Instance():GetMoney(ItemModule.MONEY_TYPE_SILVER)
  local item = self.m_ListData[self.m_CurIndex]
  if not item then
    return
  end
  local itemBase = ItemUtils.GetItemBase(item.data.id)
  local equipBase = ItemUtils.GetEquipBase(item.data.id)
  local equipFullDurable = equipBase.usePoint
  local durable = item.data.extraMap[ItemXStoreType.USE_POINT_VALUE]
  local fixCost = 0
  local equipLevl = itemBase.useLevel
  local entries = DynamicData.GetTable(CFG_PATH.DATA_EQUIP_TRANS_INHERIT_CFG)
  local count = DynamicDataTable.GetRecordsCount(entries)
  DynamicDataTable.FastGetRecordBegin(entries)
  for i = 0, count - 1 do
    local entry = DynamicDataTable.FastGetRecordByIdx(entries, i)
    local equipmentLevel = DynamicRecord.GetIntValue(entry, "equipmentLevel")
    if equipmentLevel == equipLevl then
      fixCost = DynamicRecord.GetIntValue(entry, "fixOnePointNeedSilver")
      break
    end
  end
  DynamicDataTable.FastGetRecordEnd(entries)
  self.m_NeedMoney = (equipFullDurable - durable) * fixCost
end
def.method().InitUI = function(self)
  self.m_UIGO = {}
  self.m_UIGO.NeedMoney = self.m_panel:FindDirect("Img_Bg/Img_BgRight/Group_Operation1/Img_BgUseMoney/Label_UseMoneyNum")
  self.m_UIGO.Money = self.m_panel:FindDirect("Img_Bg/Img_BgRight/Group_Operation1/Img_BgHaveMoney/Label_HaveMoneyNum")
  self.m_UIGO.EquipGrid = self.m_panel:FindDirect("Img_Bg/Img_BgLeft/Scroll View_Equip/Grid_Equip")
  self.m_UIGO.EquipIcon = self.m_panel:FindDirect("Img_Bg/Img_BgRight/Group_Operation1/Img_Item1/Img_Icon")
  self.m_UIGO.EquipMask = self.m_panel:FindDirect("Img_Bg/Img_BgRight/Group_Operation1/Img_Item1/Img_EquipMark")
  self.m_UIGO.EquipBroken = self.m_panel:FindDirect("Img_Bg/Img_BgRight/Group_Operation1/Img_Item1/Img_EquipBroken")
  self.m_UIGO.EquipName = self.m_panel:FindDirect("Img_Bg/Img_BgRight/Group_Operation1/Label_EquipName")
  self.m_UIGO.EquipNum = self.m_panel:FindDirect("Img_Bg/Img_BgRight/Group_Operation1/Label_EquipNum")
  for i = 1, 3 do
    self.m_UIGO[("Group%d"):format(i)] = self.m_panel:FindDirect(("Img_Bg/Img_BgRight/Group_Operation%d"):format(i))
  end
end
def.method().UpdateRightView = function(self)
  local group1GO = self.m_UIGO.Group1
  local group2GO = self.m_UIGO.Group2
  local group3GO = self.m_UIGO.Group3
  GUIUtils.SetActive(group1GO, self.m_ListNum ~= 0 and self.m_CurIndex ~= 0)
  GUIUtils.SetActive(group2GO, self.m_ListNum == 0)
  GUIUtils.SetActive(group3GO, self.m_ListNum ~= 0 and self.m_CurIndex == 0)
  if group1GO.activeSelf then
    self:UpdateItemView()
    self:UpdateMoneyView()
  end
end
def.method().UpdateItemView = function(self)
  local iconGO = self.m_UIGO.EquipIcon
  local maskGO = self.m_UIGO.EquipMask
  local brokenGO = self.m_UIGO.EquipBroken
  local nameGO = self.m_UIGO.EquipName
  local numGO = self.m_UIGO.EquipNum
  if self.m_ListData[self.m_CurIndex] == nil then
    return
  end
  local type = self.m_ListData[self.m_CurIndex].type
  local item = self.m_ListData[self.m_CurIndex].data
  local itemBase = ItemUtils.GetItemBase(item.id)
  local equipBase = ItemUtils.GetEquipBase(itemBase.itemid)
  local usePoint = item.extraMap[ItemXStoreType.USE_POINT_VALUE]
  GUIUtils.SetTexture(iconGO, itemBase.icon)
  GUIUtils.SetActive(maskGO, type == ItemModule.EQUIPBAG)
  GUIUtils.SetActive(brokenGO, usePoint <= 50)
  GUIUtils.SetText(nameGO, itemBase.name)
  GUIUtils.SetText(numGO, ("%d/%d"):format(usePoint, equipBase.usePoint))
end
def.method().UpdateMoneyView = function(self)
  local moneyGO = self.m_UIGO.Money
  local needMoneyGO = self.m_UIGO.NeedMoney
  GUIUtils.SetText(needMoneyGO, tostring(self.m_NeedMoney))
  GUIUtils.SetText(moneyGO, Int64.tostring(self.m_Money))
end
def.method().UpdateEquipListView = function(self)
  local itemCount = self.m_ListNum
  local uiListGO = self.m_UIGO.EquipGrid
  local listItems = GUIUtils.InitUIList(uiListGO, itemCount)
  self.m_msgHandler:Touch(uiListGO)
  for i = 1, itemCount do
    local itemGO = listItems[i]
    local itemData = self.m_ListData[i]
    local iconGO = itemGO:FindDirect(("Img_Icon_%d"):format(i))
    local markGO = itemGO:FindDirect(("Img_EquipMark_%d"):format(i))
    local brokenGO = itemGO:FindDirect(("Img_EquipBroken_%d"):format(i))
    local itemBase = ItemUtils.GetItemBase(itemData.data.id)
    GUIUtils.SetActive(markGO, itemData.type == ItemModule.EQUIPBAG)
    GUIUtils.SetActive(brokenGO, itemData.data.extraMap[ItemXStoreType.USE_POINT_VALUE] <= 50)
    GUIUtils.SetTexture(iconGO, itemBase.icon)
  end
end
def.method().Update = function(self)
  self:UpdateListData()
  self:UpdateRightView()
  self:UpdateEquipListView()
end
RepairEquipPanel.Commit()
return RepairEquipPanel
