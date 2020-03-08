local Lplus = require("Lplus")
local EC = require("Types.Vector3")
local AtlasMan = require("GUI.AtlasMan")
local ECPanelBase = require("GUI.ECPanelBase")
local ECPanelCombine = require("GUI.ECPanelCombine")
local ECIvtrItems = require("Inventory.ECIvtrItems")
local ElementData = require("Data.ElementData")
local ECEquipDesc = require("Data.ECEquipDesc")
local ECGUITools = require("GUI.ECGUITools")
local NotifyMoneyChange = require("Event.NotifyMoneyChange")
local Exptypes = require("Data.Exptypes")
local IVTRESSENCEEQUIPMENTs = require("Inventory.ECIvtrEquip")
local ECPanelBobyShop = require("GUI.ECPanelBobyShop")
local ECGame = Lplus.ForwardDeclare("ECGame")
local Expdef = require("Data.Expdef")
local CLIENT_ITEM_STATE = Expdef.CLIENT_ITEM_STATE
local ITEM_PROC_TYPE = Expdef.ITEM_PROC_TYPE
local ECItemTools = require("Inventory.ECItemTools")
local InventoryFile = dofile("Configs/inventory_open.lua")
local ECPackagePage = Lplus.Class("ECPackagePage")
local def = ECPackagePage.define
def.const("number").MAXNUM = 80
def.const("table").FILTERTYPE = {
  ALL = 1,
  EQUIPMENT = 2,
  MATERIAL = 3
}
def.const("table").SHOWFLAG = {
  NORMAL = 1,
  COMBINE = 2,
  SHOP_BUY = 3,
  SHOP_SELL = 4
}
def.field("boolean").m_InitType = true
def.field("boolean").m_FilterChange = false
def.field("boolean").m_StateChange = false
def.field("number").m_Filter = 1
def.field("number").m_State = 1
def.field("number").m_CurrentPage = 1
def.field("number").m_FirstLockMoneyIndex = 0
def.field("number").m_UnlockMoneyNum = 0
def.field("number").m_UnlockMoneyConsum = 0
def.field("table").m_Parent = nil
def.field("table").m_SubPanels = nil
def.field("table").m_ItemData = function()
  return {}
end
def.field("table").m_GridData = function()
  return {}
end
def.field("userdata").m_panel = nil
local MAXNUM = 80
local pageNum = 16
def.static("table", "userdata", "=>", ECPackagePage).new = function(parent, panel)
  local obj = ECPackagePage()
  obj.m_panel = panel
  obj.m_Parent = parent
  local panels = {}
  panels[1] = obj.m_panel:FindChild("SubPanel_Grid1")
  panels[2] = obj.m_panel:FindChild("SubPanel_Grid2")
  panels[3] = obj.m_panel:FindChild("SubPanel_Grid3")
  panels[4] = obj.m_panel:FindChild("SubPanel_Grid4")
  panels[5] = obj.m_panel:FindChild("SubPanel_Grid5")
  obj.m_SubPanels = panels
  return obj
end
def.method().Init = function(self)
  self.m_Filter = ECPackagePage.FILTERTYPE.ALL
  self.m_State = ECPackagePage.SHOWFLAG.NORMAL
  self:InitPackageData()
  self:SortItemListData()
  self:UpdatePackageData()
  self:InitAllGridView()
  self:UpdateButton()
end
def.method("table", "=>", "boolean").FilterItem = function(self, item)
  if self.m_State == ECPackagePage.SHOWFLAG.NORMAL then
    if self.m_Filter == ECPackagePage.FILTERTYPE.ALL then
      if item then
        return true
      else
        return false
      end
    elseif self.m_Filter == ECPackagePage.FILTERTYPE.EQUIPMENT then
      if item and item.m_CID == ECIvtrItems.ECIvtrItem.ITEM_CLASSID.ICID_EQUIP then
        return true
      else
        return false
      end
    elseif self.m_Filter == ECPackagePage.FILTERTYPE.MATERIAL then
      if item and item.m_CID ~= ECIvtrItems.ECIvtrItem.ITEM_CLASSID.ICID_EQUIP and ECItemTools.CanUse(item) then
        return true
      else
        return false
      end
    end
  elseif self.m_State == ECPackagePage.SHOWFLAG.COMBINE then
    if self.m_Filter == ECPackagePage.FILTERTYPE.ALL then
      if item and item.m_ItemCmnProp.compose_output_id ~= 0 then
        return true
      else
        return false
      end
    elseif self.m_Filter == ECPackagePage.FILTERTYPE.EQUIPMENT then
      return false
    elseif self.m_Filter == ECPackagePage.FILTERTYPE.MATERIAL then
      if item and item.m_ItemCmnProp.compose_output_id ~= 0 and ECItemTools.CanUse(item) then
        return true
      else
        return false
      end
    end
  elseif self.m_State == ECPackagePage.SHOWFLAG.SHOP_SELL then
    if self.m_Filter == ECPackagePage.FILTERTYPE.ALL then
      if item and ECItemTools.CanSell(item) then
        return true
      else
        return false
      end
    elseif self.m_Filter == ECPackagePage.FILTERTYPE.EQUIPMENT then
      if item and ECItemTools.CanSell(item) and item.m_CID == ECIvtrItems.ECIvtrItem.ITEM_CLASSID.ICID_EQUIP then
        return true
      else
        return false
      end
    elseif self.m_Filter == ECPackagePage.FILTERTYPE.MATERIAL then
      if item and ECItemTools.CanSell(item) and ECItemTools.CanUse(item) then
        return true
      else
        return false
      end
    end
  elseif self.m_State == ECPackagePage.SHOWFLAG.SHOP_BUY then
    if self.m_Filter == ECPackagePage.FILTERTYPE.ALL then
      if item then
        return true
      else
        return false
      end
    elseif self.m_Filter == ECPackagePage.FILTERTYPE.EQUIPMENT then
      if item and item.m_CID == ECIvtrItems.ECIvtrItem.ITEM_CLASSID.ICID_EQUIP then
        return true
      else
        return false
      end
    elseif self.m_Filter == ECPackagePage.FILTERTYPE.MATERIAL then
      if item and ECItemTools.CanUse(item) then
        return true
      else
        return false
      end
    end
  end
end
local function CalculateLockGrid()
  local hp = ECGame.Instance().m_HostPlayer
  local lv = hp.InfoData.Lv
  local inventoryConfig = InventoryFile.inventoryConfig
  local lvNum, lvTotalNum = 0, 0
  local lockLvTable = {}
  local lockMoneyTable = {}
  for _, v in pairs(inventoryConfig) do
    if v.type == 1 then
      lvTotalNum = lvTotalNum + v.num
      if lv >= v.lv then
        lvNum = lvNum + v.num
      else
        for i = 1, v.num do
          table.insert(lockLvTable, 1, v.lv)
        end
      end
    else
      for i = 1, v.num do
        table.insert(lockMoneyTable, 1, {
          num = v.num,
          money = v.money
        })
      end
    end
  end
  local lockNumMoney = hp.Package.NormalPack.totalSize - lvNum
  if lockNumMoney > 0 then
    for i = 1, lockNumMoney do
      table.remove(lockMoneyTable)
    end
  end
  return lvTotalNum - lvNum, MAXNUM - lvTotalNum - lockNumMoney, lockLvTable, lockMoneyTable
end
def.method().InitPackageData = function(self)
  self.m_ItemData = {}
  local hp = ECGame.Instance().m_HostPlayer
  local pack = hp.Package.NormalPack
  local lockNumLv, lockNumMoney, lockLvTable, lockMoneyTable = CalculateLockGrid()
  for i = 0, MAXNUM - 1 do
    local temp = {}
    if i < pack.totalSize then
      local item = pack.m_ItemSet[i]
      temp.lock = false
      if self:FilterItem(item) then
        temp.data = item
        temp.forsell = item.m_SellLock
        temp.fakeIndex = item.Slot
      else
        temp.data = nil
        temp.forsell = false
        temp.fakeIndex = nil
      end
    else
      temp.lock = true
      temp.forsell = false
      temp.data = nil
      temp.fakeIndex = nil
      if lockNumLv ~= 0 then
        temp.lockLv = lockLvTable[lockNumLv]
        lockNumLv = lockNumLv - 1
      elseif lockNumMoney > 0 then
        temp.lockLv = 0
        temp.lockMoneyInfo = lockMoneyTable[lockNumMoney]
        lockNumMoney = lockNumMoney - 1
      end
    end
    self.m_ItemData[i] = temp
  end
end
def.method().SortItemListData = function(self)
  if #self.m_ItemData == 0 then
    return
  end
  local sortList = {}
  local index = 1
  for i = 0, #self.m_ItemData do
    if self.m_ItemData[i] then
      sortList[index] = self.m_ItemData[i]
      index = index + 1
    end
  end
  local itemCIDTable = {
    [1] = 2,
    [2] = 3,
    [3] = 6,
    [4] = 7,
    [5] = 13
  }
  local function sortItem(left, right)
    if not left and right then
      return false
    end
    if left and not right then
      return true
    end
    if left and right then
      if left.lock and not right.lock then
        return false
      end
      if not left.lock and right.lock then
        return true
      end
      if not left.lock and not right.lock then
        if left.forsell then
          return false
        end
        if right.forsell then
          return true
        end
        if left.data and not right.data then
          return true
        end
        if not left.data and right.data then
          return false
        end
        if left.data and right.data then
          if right.data.tid == 0 or left.data.tid == 0 then
            return false
          end
          local lIndex = ElementData.getEssence(left.data.tid).common_prop.sort_type
          if lIndex == 0 then
            lIndex = left.data.m_CID
          else
            lIndex = itemCIDTable[lIndex]
          end
          local rIndex = ElementData.getEssence(right.data.tid).common_prop.sort_type
          if rIndex == 0 then
            rIndex = right.data.m_CID
          else
            rIndex = itemCIDTable[rIndex]
          end
          if lIndex ~= rIndex then
            return lIndex < rIndex
          end
          if lIndex == rIndex and lIndex == ECIvtrItems.ECIvtrItem.ITEM_CLASSID.ICID_EQUIP then
            local lEquipMask = ElementData.getEssence(left.data.tid).equip_mask
            local rEquipMask = ElementData.getEssence(right.data.tid).equip_mask
            if lEquipMask ~= rEquipMask then
              return lEquipMask < rEquipMask
            end
          elseif lIndex == rIndex and lIndex == ECIvtrItems.ECIvtrItem.ITEM_CLASSID.ICID_ESTONE then
            local lStoneType = ElementData.getEssence(left.data.tid).stone_type
            local rStoneType = ElementData.getEssence(right.data.tid).stone_type
            if lStoneType ~= rStoneType then
              return lStoneType < rStoneType
            end
          end
          if left.data.tid ~= right.data.tid then
            return left.data.tid > right.data.tid
          end
          if left.data:CurQuality() ~= right.data:CurQuality() then
            return left.data:CurQuality() > right.data:CurQuality()
          end
          if left.data.IsBind ~= right.data.IsBind then
            return left.data.IsBind
          end
        end
      end
      if left.lock and right.lock then
        if left.lockLv == 0 and right.lockLv ~= 0 then
          return false
        end
        if left.lockLv ~= 0 and right.lockLv == 0 then
          return true
        end
        if left.lockLv ~= 0 and right.lockLv ~= 0 then
          return left.lockLv < right.lockLv
        end
        if left.lockLv == 0 and right.lockLv == 0 then
          return left.lockMoneyInfo.money < right.lockMoneyInfo.money
        end
      end
    end
  end
  table.sort(sortList, sortItem)
  local find = false
  for i = 0, MAXNUM - 1 do
    self.m_ItemData[i] = sortList[i + 1]
    if self.m_ItemData[i].lockLv == 0 and not find then
      self.m_FirstLockMoneyIndex = i
      find = true
    end
  end
end
def.method().UpdatePackageData = function(self)
  self.m_GridData = self.m_ItemData
end
def.method("table").UpdateFakePackageData = function(self, event)
  local pack = ECGame.Instance().m_HostPlayer.Package.NormalPack
  if event.m_UpdateType == 1 then
    if self.m_State == ECPackagePage.SHOWFLAG.COMBINE and event.m_UpdateInfo.item.m_ItemCmnProp.compose_output_id == 0 then
      return
    end
    local new = true
    for i = 0, pack.totalSize - 1 do
      if self.m_GridData[i].fakeIndex and self.m_GridData[i].fakeIndex == event.m_UpdateInfo.item.Slot then
        self.m_GridData[i].data = event.m_UpdateInfo.item
        new = false
        break
      end
    end
    if new then
      for i = 0, pack.totalSize - 1 do
        if not self.m_GridData[i].data and self:FilterItem(event.m_UpdateInfo.item) then
          local temp = {}
          temp.lock = false
          temp.data = event.m_UpdateInfo.item
          temp.forsell = event.m_UpdateInfo.item.m_SellLock
          temp.fakeIndex = event.m_UpdateInfo.item.Slot
          temp.update = true
          self.m_GridData[i] = temp
          break
        end
      end
    end
  elseif event.m_UpdateType == 2 then
    for i = 0, pack.totalSize - 1 do
      if self.m_GridData[i].data and self.m_GridData[i].data.Slot == event.m_UpdateInfo.index and 0 >= self.m_GridData[i].data.NormalCount + self.m_GridData[i].data.BindCount then
        self.m_GridData[i].data = nil
      end
    end
  elseif event.m_UpdateType == 3 then
    if not event.m_UpdateInfo.item2 then
      for i = 0, pack.totalSize - 1 do
        if self.m_GridData[i] and not self.m_GridData[i].data then
          self.m_GridData[i].data = event.m_UpdateInfo.item1
          self.m_GridData[i].fakeIndex = event.m_UpdateInfo.index
          break
        end
      end
    elseif not event.m_UpdateInfo.item1 then
      for i = 0, pack.totalSize - 1 do
        if self.m_GridData[i].fakeIndex and self.m_GridData[i].fakeIndex == event.m_UpdateInfo.index then
          self.m_GridData[i].data = nil
          break
        end
      end
    else
      for i = 0, pack.totalSize - 1 do
        if self.m_GridData[i].fakeIndex and self.m_GridData[i].fakeIndex == event.m_UpdateInfo.index then
          self.m_GridData[i].data = event.m_UpdateInfo.item1
          self.m_GridData[i].fakeIndex = event.m_UpdateInfo.index
          break
        end
      end
    end
  elseif event.m_UpdateType == 5 then
    for i = 0, pack.totalSize - 1 do
      if self.m_GridData[i].data and self.m_GridData[i].data.Slot == event.m_UpdateInfo.item.Slot then
        self.m_GridData[i].data = event.m_UpdateInfo.item
      end
    end
  end
end
def.method().InitAllGridView = function(self)
  for pageIndex = 1, MAXNUM / pageNum do
    local subPanel = self.m_SubPanels[pageIndex]
    local beginIndex = (pageIndex - 1) * pageNum
    local endIndex = pageIndex * pageNum - 1
    for i = beginIndex, endIndex do
      local itemData = self.m_GridData[i]
      if itemData then
        self:UpdateGrid(math.fmod(i, pageNum), itemData, subPanel)
      end
    end
  end
end
def.method("number", "table", "userdata").UpdateGrid = function(self, index, gridData, subPanel)
  local grid = subPanel:FindChild("Grid" .. string.format("%02d", index + 1))
  local item_tid_tag = grid:FindChildByPrefix("item_tid_")
  if not item_tid_tag then
    item_tid_tag = GameObject.GameObject("item_tid_0")
    item_tid_tag.parent = grid
  end
  item_tid_tag.name = "item_tid_0"
  if not gridData.lock then
    grid:FindChild("Img_UnlockChoose"):SetActive(false)
    grid:FindChild("Img_Lock"):SetActive(false)
    grid:FindChild("Txt_LevelOpen"):SetActive(false)
    if gridData.data then
      local imgItem = grid:FindChild("Img_Item")
      imgItem:SetActive(true)
      local pathID = 0
      local imgPath = ""
      local isEquip, isBind, isQuest, isUp, canUse, coldtime, coldID, num, expathID, borderName = ECItemTools.GetGridState(gridData.data)
      if isEquip then
        local quality = gridData.data:CurQuality()
        pathID = ElementData.getEssence(gridData.data.tid).file_icons[quality]
        if pathID == 0 then
          pathID = gridData.data.m_ItemCmnProp.file_icon
        end
      else
        pathID = gridData.data.m_ItemCmnProp.file_icon
      end
      if gridData.data.m_CID ~= ECIvtrItems.ECIvtrItem.ITEM_CLASSID.ICID_UNKNOWN then
        imgPath = datapath.GetPathByID(pathID)
        ECGUITools.UpdateGridImage(imgPath, imgItem)
      else
        ECGUITools.setDefaultIcon(imgItem, ECIvtrItems.ECIvtrItem.ITEM_CLASSID.ICID_UNKNOWN)
      end
      local imgBind = grid:FindChild("Img_Bind")
      if isBind then
        imgBind:SetActive(true)
      else
        imgBind:SetActive(false)
      end
      local imgQuest = grid:FindChild("Img_Quest")
      if isQuest then
        imgQuest:SetActive(true)
        ECGUITools.UpdateGridImage(datapath.GetPathByID(expathID), imgQuest)
      else
        imgQuest:SetActive(false)
      end
      local imgUp = grid:FindChild("Img_Up")
      local imgDown = grid:FindChild("Img_Down")
      if isEquip then
        local upgradeFightValue = ECItemTools.GetUpgradeFightValue(gridData.data)
        if upgradeFightValue > 0 then
          imgUp:SetActive(true)
          imgDown:SetActive(false)
        elseif upgradeFightValue < 0 then
          imgUp:SetActive(false)
          imgDown:SetActive(true)
        else
          imgUp:SetActive(false)
          imgDown:SetActive(false)
        end
      else
        imgUp:SetActive(false)
        imgDown:SetActive(false)
      end
      local imgNon = grid:FindChild("Img_Non")
      if not ECItemTools.UseRedColor(gridData.data) then
        imgNon:SetActive(false)
      else
        imgNon:SetActive(true)
      end
      local txtNum = grid:FindChild("Txt_Num")
      if num == 0 then
        txtNum:SetActive(false)
      else
        txtNum:SetActive(true)
        ECGUITools.UpdateLable(tostring(num), txtNum)
      end
      local imgTime = grid:FindChild("Img_Time")
      if coldtime == 0 then
        imgTime:SetActive(false)
      else
        GameUtil.AddCoolDownComponent(imgTime, coldID + 600)
      end
      local imgColor = grid:FindChild("Img_Color")
      if borderName:len() ~= 0 then
        imgColor:SetActive(true)
        imgColor:GetComponent("UISprite").spriteName = borderName
      else
        imgColor:SetActive(false)
      end
      grid:FindChild("Img_Check"):SetActive(true)
      if gridData.data.m_SellLock then
        local childrenCount = grid.transform.childCount
        for i = 0, childrenCount - 1 do
          grid.transform:GetChild(i).gameObject:SetActive(false)
        end
        grid:FindChild("Img_Grid"):SetActive(true)
      end
      item_tid_tag.name = "item_tid_" .. gridData.data.tid
    else
      local childrenCount = grid.transform.childCount
      for i = 0, childrenCount - 1 do
        grid.transform:GetChild(i).gameObject:SetActive(false)
      end
      grid:FindChild("Img_Grid"):SetActive(true)
    end
  elseif gridData.lock then
    local childrenCount = grid.transform.childCount
    for i = 0, childrenCount - 1 do
      grid.transform:GetChild(i).gameObject:SetActive(false)
    end
    grid:FindChild("Img_Grid"):SetActive(true)
    grid:FindChild("Img_Lock"):SetActive(true)
    if gridData.lockLv ~= 0 then
      grid:FindChild("Txt_LevelOpen"):SetActive(true)
      local desc = StringTable.Get(8302):format(gridData.lockLv)
      ECGUITools.UpdateLable(desc, grid:FindChild("Txt_LevelOpen"))
    end
  end
end
def.method("number").ResetUnlockView = function(self, index)
  local pageIndex = self.m_CurrentPage
  for i = MAXNUM - 1, index + 1, -1 do
    if self.m_GridData[i].lock and self.m_GridData[i].lockLv == 0 then
      local subPanel = self.m_SubPanels[pageIndex]
      local gridIndex = i - pageNum * (pageIndex - 1)
      if gridIndex < 0 then
        pageIndex = pageIndex - 1
      end
      local grid = subPanel:FindChild("Grid" .. string.format("%02d", gridIndex + 1))
      if grid then
        grid:FindChild("Img_UnlockChoose"):SetActive(false)
      end
    end
  end
end
def.method("number").HightUnlockGrid = function(self, index)
  self:ResetUnlockView(index)
  local pageIndex = self.m_CurrentPage
  for i = index, self.m_FirstLockMoneyIndex, -1 do
    if self.m_GridData[i].lock and self.m_GridData[i].lockLv == 0 then
      local subPanel = self.m_SubPanels[pageIndex]
      local gridIndex = i - pageNum * (pageIndex - 1)
      if gridIndex < 0 then
        pageIndex = pageIndex - 1
      end
      local grid = subPanel:FindChild("Grid" .. string.format("%02d", gridIndex + 1))
      if grid then
        grid:FindChild("Img_UnlockChoose"):SetActive(true)
      end
    end
  end
end
def.method("number").UpdatePageView = function(self, pageIndex)
  local subPanel = self.m_SubPanels[pageIndex]
  local beginIndex = (pageIndex - 1) * pageNum
  local endIndex = pageIndex * pageNum - 1
  for i = beginIndex, endIndex do
    local itemData = self.m_GridData[i]
    if itemData then
      self:UpdateGrid(math.fmod(i, pageNum), itemData, subPanel)
    end
  end
end
def.method().UpdateUIToggleView = function(self)
  self.m_panel:FindChild("Tab01"):GetComponent("UIToggle").value = self.m_CurrentPage == 1
  self.m_panel:FindChild("Tab02"):GetComponent("UIToggle").value = self.m_CurrentPage == 2
  self.m_panel:FindChild("Tab03"):GetComponent("UIToggle").value = self.m_CurrentPage == 3
  self.m_panel:FindChild("Tab04"):GetComponent("UIToggle").value = self.m_CurrentPage == 4
  self.m_panel:FindChild("Tab05"):GetComponent("UIToggle").value = self.m_CurrentPage == 5
end
def.method().Update = function(self)
  if not self.m_panel then
    return
  end
  self:UpdatePageView(self.m_CurrentPage)
  self:UpdateUIToggleView()
end
def.method().ReturnToFirstPage = function(self)
  self.m_CurrentPage = 1
  local packageView = self.m_panel:FindChild("PackageScrollView")
  packageView:GetComponent("UIScrollView"):ResetPosition()
  for i = 1, 5 do
    self:UpdatePageView(i)
  end
  self:UpdateUIToggleView()
end
def.method().UpdateButton = function(self)
  self.m_panel:FindChild("Btn_Combine"):SetActive(self.m_State == ECPackagePage.SHOWFLAG.NORMAL)
  self.m_panel:FindChild("Btn_Shop"):SetActive(self.m_State == ECPackagePage.SHOWFLAG.NORMAL)
  self.m_panel:FindChild("Btn_Sell"):SetActive(self.m_State == ECPackagePage.SHOWFLAG.NORMAL)
  self.m_panel:FindChild("Btn_CombineBack"):SetActive(self.m_State == ECPackagePage.SHOWFLAG.COMBINE)
  self.m_panel:FindChild("Btn_ShopBack"):SetActive(self.m_State == ECPackagePage.SHOWFLAG.SHOP_BUY)
  self.m_panel:FindChild("Btn_SellBack"):SetActive(self.m_State == ECPackagePage.SHOWFLAG.SHOP_SELL)
end
def.method("number", "=>", "number").CalculateConsumMoney = function(self, index)
  local money = 0
  for i = index, self.m_FirstLockMoneyIndex, -1 do
    if self.m_GridData[i].lock and self.m_GridData[i].lockLv == 0 then
      money = money + self.m_GridData[i].lockMoneyInfo.money
    end
  end
  self.m_UnlockMoneyConsum = money
  return money
end
local l_bShowClickItem
def.static("boolean").ShowClickItem = function(bShow)
  l_bShowClickItem = bShow
end
local function UnlockConfirmCallBack(self, retval)
  if retval == MsgBox.MsgBoxRetT.MBRT_OK then
    if self.m_UnlockMoneyConsum > ECGame.Instance().m_HostPlayer.Package.NormalPack.Money then
      FlashTipMan.FlashTip(StringTable.Get(8301))
      return
    end
    local pb_helper = require("PB.pb_helper")
    local net_common = require("PB.net_common")
    local gp_buy_backpack = net_common.gp_buy_backpack
    local msg = gp_buy_backpack()
    msg.inc_size = self.m_UnlockMoneyNum
    pb_helper.Send(msg)
  elseif retval == MsgBox.MsgBoxRetT.MBRT_CANCEL then
    self:ResetUnlockView(self.m_FirstLockMoneyIndex - 1)
  end
end
def.method("string").onClick = function(self, id)
  if string.find(id, "Btn_All") == 1 then
    if self.m_Filter ~= ECPackagePage.FILTERTYPE.ALL then
      self.m_FilterChange = true
      self.m_Filter = ECPackagePage.FILTERTYPE.ALL
      self:InitPackageData()
      self:SortItemListData()
      self:UpdatePackageData()
      self:ReturnToFirstPage()
    else
      self.m_FilterChange = false
    end
  elseif string.find(id, "Btn_Equip") == 1 then
    if self.m_Filter ~= ECPackagePage.FILTERTYPE.EQUIPMENT then
      self.m_FilterChange = true
      self.m_Filter = ECPackagePage.FILTERTYPE.EQUIPMENT
      self:InitPackageData()
      self:SortItemListData()
      self:UpdatePackageData()
      self:ReturnToFirstPage()
    else
      self.m_FilterChange = false
    end
  elseif string.find(id, "Btn_Material") == 1 then
    if self.m_Filter ~= ECPackagePage.FILTERTYPE.MATERIAL then
      self.m_FilterChange = true
      self.m_Filter = ECPackagePage.FILTERTYPE.MATERIAL
      self:InitPackageData()
      self:SortItemListData()
      self:UpdatePackageData()
      self:ReturnToFirstPage()
    else
      self.m_FilterChange = false
    end
  elseif string.find(id, "Grid") == 1 then
    local gridIndex = tonumber(string.sub(id, -2, -1)) - 1
    local index = gridIndex + pageNum * (self.m_CurrentPage - 1)
    local item = self.m_GridData[index]
    if not item or not item.data then
      if item and item.lock and item.lockLv == 0 then
        local money = self:CalculateConsumMoney(index)
        self:HightUnlockGrid(index)
        self.m_UnlockMoneyNum = index - self.m_FirstLockMoneyIndex + 1
        local tooltip = StringTable.Get(8300):format(money, self.m_UnlockMoneyNum)
        MsgBox.ShowMsgBox(self, tooltip, "\230\143\144\231\164\186", MsgBoxType.MBBT_OKCANCEL, UnlockConfirmCallBack)
      end
      return
    end
    local pageIndex = self.m_CurrentPage
    local name = string.format("PackageScrollView/Grid/SubPanel_Grid%d/Group%d/%s", pageIndex, pageIndex, id)
    if self.m_State == ECPackagePage.SHOWFLAG.NORMAL then
      ItemTipMan.ShowItemTip(item.data, true, self.m_panel:FindChild(name))
    elseif self.m_State == ECPackagePage.SHOWFLAG.COMBINE then
      ECPanelCombine.Instance():UpdateItemData(item.data)
    elseif self.m_State == ECPackagePage.SHOWFLAG.SHOP_BUY then
      if ECPanelBobyShop.Instance().m_CurPage == ECPanelBobyShop.PAGE.Buy then
        ItemTipMan.ShowItemTip(item.data, true, self.m_panel:FindChild(name))
      end
    elseif self.m_State == ECPackagePage.SHOWFLAG.SHOP_SELL and not item.data.m_SellLock and ECPanelBobyShop.Instance().m_CurPage == ECPanelBobyShop.PAGE.Sell then
      ECPanelBobyShop.PrepareSell(item.data)
    end
  elseif id == "Btn_Combine" then
    self.m_Parent:ToggleSubPanelChar(false)
    self.m_Parent:Toggle3DModel(false)
    self.m_State = ECPackagePage.SHOWFLAG.COMBINE
    self.m_StateChange = true
    self:InitPackageData()
    self:SortItemListData()
    self:UpdatePackageData()
    self:ReturnToFirstPage()
    self:UpdateButton()
    ECPanelCombine.Instance():Toggle()
  elseif id == "Btn_CombineBack" then
    self.m_Parent:ToggleSubPanelChar(true)
    self.m_Parent:DestroyModel()
    self.m_Parent:LoadModel()
    self.m_Parent:Toggle3DModel(true)
    self.m_State = ECPackagePage.SHOWFLAG.NORMAL
    self.m_StateChange = true
    self:InitPackageData()
    self:SortItemListData()
    self:UpdatePackageData()
    self:ReturnToFirstPage()
    self:UpdateButton()
    ECPanelCombine.Instance():Toggle()
  elseif id == "Btn_Shop" then
    local cfg, datatype = ElementData.getConfig(special_id_config.id_special_id_config)
    if not cfg then
      return
    end
    local id_takealong_shop_npc = cfg.id_takealong_shop_npc
    self:OpenShop(id_takealong_shop_npc, true)
  elseif id == "Btn_Sell" then
    local cfg, datatype = ElementData.getConfig(special_id_config.id_special_id_config)
    if not cfg then
      return
    end
    local id_takealong_shop_npc = cfg.id_takealong_shop_npc
    self:OpenShop(id_takealong_shop_npc, false)
  elseif id == "Btn_ShopBack" or id == "Btn_SellBack" then
    ECPanelBobyShop.CloseShop()
    self.m_Parent:ToggleSubPanelChar(true)
    self.m_Parent:DestroyModel()
    self.m_Parent:LoadModel()
    self.m_Parent:Toggle3DModel(true)
    self.m_State = ECPackagePage.SHOWFLAG.NORMAL
    self.m_StateChange = true
    self:UpdateButton()
    self:InitPackageData()
    self:SortItemListData()
    self:UpdatePackageData()
    self:ReturnToFirstPage()
  end
end
def.method("number", "boolean").OpenShop = function(self, id_takealong_shop_npc, is_buy)
  self.m_Parent:ToggleSubPanelChar(false)
  self.m_Parent:Toggle3DModel(false)
  ECPanelBobyShop.OpenShop(id_takealong_shop_npc, is_buy and ECPanelBobyShop.PAGE.Buy or ECPanelBobyShop.PAGE.Sell, function(buyPage)
    if buyPage then
      self.m_State = ECPackagePage.SHOWFLAG.SHOP_BUY
    else
      self.m_State = ECPackagePage.SHOWFLAG.SHOP_SELL
    end
    self.m_StateChange = true
    self:UpdateButton()
    self:InitPackageData()
    self:SortItemListData()
    self:UpdatePackageData()
    self:ReturnToFirstPage()
  end)
end
local lastPosition
def.method("table").OnScrollView = function(self, position)
  if position.x > 200 then
    self.m_CurrentPage = 1
  elseif position.x > -200 and position.x <= 200 then
    self.m_CurrentPage = 2
  elseif position.x > -600 and position.x <= -200 then
    self.m_CurrentPage = 3
  elseif position.x > -1200 and position.x <= -600 then
    self.m_CurrentPage = 4
  elseif position.x <= -1200 then
    self.m_CurrentPage = 5
  end
  if lastPosition and math.abs(lastPosition - position.x) < 0.01 and not self.m_FilterChange and not self.m_StateChange then
    lastPosition = position.x
    return
  end
  self:Update()
  lastPosition = position.x
end
def.method("string", "userdata", "number", "table").onSpringFinish = function(self, id, scrollView, type, position)
  self:OnScrollView(position)
end
def.method("number", "number").TurnToPage = function(self, iPage, strength)
  if not self.m_panel then
    return
  end
  local grid = self.m_panel:FindChild("PackageScrollView"):FindChild("Grid")
  grid:GetComponent("UIGrid"):DragToMakeVisible(iPage - 1, strength)
  self.m_CurrentPage = iPage
end
def.method("number").HightLightSlot = function(self, index)
  if not self.m_panel then
    return
  end
  local iPage = math.floor(index / pageNum)
  local iSlot = index % pageNum
  local grid = self.m_SubPanels[iPage + 1]:FindChild("Grid" .. string.format("%02d", iSlot + 1))
  local toggle = grid:GetComponent("UIToggle")
  if toggle then
    toggle.value = true
  end
end
def.method("number", "number", "boolean", "=>", "boolean").FindItemAndTurnToPage = function(self, tid, strength, bClickItem)
  if not self.m_panel then
    return false
  end
  if bClickItem then
    strength = math.max(strength, 1000)
  end
  for i = 1, MAXNUM do
    local itemData = self.m_GridData[i - 1]
    if itemData and itemData.data and itemData.data.tid == tid then
      local iPage = math.floor((i - 1) / pageNum) + 1
      self:HightLightSlot(i - 1)
      self:TurnToPage(iPage, strength)
      if bClickItem then
        local iGrid = (i - 1) % pageNum + 1
        self:onClick(("Grid%02d"):format(iGrid))
      end
      return true
    end
  end
  return false
end
def.method("table", "number", "boolean", "=>", "boolean").FindOneOfItemAndTurnToPage = function(self, tids, strength, bClickItem)
  if not self.m_panel then
    return false
  end
  for _, tid in ipairs(tids) do
    if self:FindItemAndTurnToPage(tid, strength, bClickItem) then
      return true
    end
  end
  return false
end
def.method("table").PackageUpdate = function(self, event)
  if not self.m_SubPanels or not self.m_Parent.m_panel then
    return
  end
  if self.m_Parent.m_SubPanels[1].activeSelf then
    self.m_Parent:Toggle3DModel(true)
  end
  self:UpdateFakePackageData(event)
  self:Update()
end
def.method().PackageSizeChange = function(self)
  self:InitPackageData()
  self:SortItemListData()
  self:UpdatePackageData()
  self:Update()
end
def.method().ForSellUpdate = function(self)
  self:PackageUpdate()
end
ECPackagePage.Commit()
return ECPackagePage
