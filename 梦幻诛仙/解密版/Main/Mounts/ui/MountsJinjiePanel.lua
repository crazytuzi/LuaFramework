local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local MountsJinjiePanel = Lplus.Extend(ECPanelBase, "MountsJinjiePanel")
local GUIUtils = require("GUI.GUIUtils")
local EC = require("Types.Vector3")
local MountsMgr = require("Main.Mounts.mgr.MountsMgr")
local MountsUtils = require("Main.Mounts.MountsUtils")
local MountsTypeEnum = require("consts.mzm.gsp.mounts.confbean.MountsTypeEnum")
local Vector = require("Types.Vector")
local Vector3 = require("Types.Vector3").Vector3
local ItemUtils = require("Main.Item.ItemUtils")
local ItemModule = require("Main.Item.ItemModule")
local ItemTipsMgr = require("Main.Item.ItemTipsMgr")
local ItemType = require("consts.mzm.gsp.item.confbean.ItemType")
local MountsConst = require("netio.protocol.mzm.gsp.mounts.MountsConst")
local CommonConfirmDlg = require("GUI.CommonConfirmDlg")
local def = MountsJinjiePanel.define
local instance
def.const("number").MAX_REPEAT_TIMES = 3
def.field("table").uiObjs = nil
def.field("userdata").mountsId = nil
def.field("table").itemMaterials = nil
def.field("table").itemChipMaterials = nil
def.field("number").selectedItemId = -1
def.field("number").selectedMountsId = -1
def.field("table").usedItemIds = nil
def.static("=>", MountsJinjiePanel).Instance = function()
  if instance == nil then
    instance = MountsJinjiePanel()
  end
  return instance
end
def.method("userdata").ShowPanel = function(self, mountsId)
  if self.m_panel ~= nil or mountsId == nil then
    return
  end
  self.mountsId = mountsId
  self:CreatePanel(RESPATH.PANEL_QUICKUSE, 2)
  self:SetModal(true)
end
def.override().OnCreate = function(self)
  self:InitUI()
  self:HideMaterialDetail()
  self:LoadMountsRankUpItemMaterials()
  self:SetCanUseMaterial()
  Event.RegisterEvent(ModuleId.MOUNTS, gmodule.notifyId.Mounts.MountsFunctionOpenChange, MountsJinjiePanel.OnMountsFunctionOpenChange)
  Event.RegisterEvent(ModuleId.MOUNTS, gmodule.notifyId.Mounts.MountsAddScoreSuccess, MountsJinjiePanel.OnMountsAddScoreSuccess)
  Event.RegisterEvent(ModuleId.MOUNTS, gmodule.notifyId.Mounts.MountsListChange, MountsJinjiePanel.OnMountsListChange)
  Event.RegisterEvent(ModuleId.ITEM, gmodule.notifyId.item.Item_OnBagInfoSynchronized, MountsJinjiePanel.OnItemChange)
end
def.override().OnDestroy = function(self)
  self.uiObjs = nil
  self.itemMaterials = nil
  self.itemChipMaterials = nil
  self.selectedItemId = -1
  self.selectedMountsId = -1
  self.usedItemIds = nil
  Event.UnregisterEvent(ModuleId.MOUNTS, gmodule.notifyId.Mounts.MountsFunctionOpenChange, MountsJinjiePanel.OnMountsFunctionOpenChange)
  Event.UnregisterEvent(ModuleId.MOUNTS, gmodule.notifyId.Mounts.MountsAddScoreSuccess, MountsJinjiePanel.OnMountsAddScoreSuccess)
  Event.UnregisterEvent(ModuleId.MOUNTS, gmodule.notifyId.Mounts.MountsListChange, MountsJinjiePanel.OnMountsListChange)
  Event.UnregisterEvent(ModuleId.ITEM, gmodule.notifyId.item.Item_OnBagInfoSynchronized, MountsJinjiePanel.OnItemChange)
end
def.method().LoadMountsRankUpItemMaterials = function(self)
  if self.mountsId == nil then
    warn("rank up wrong mounts:" .. self.mountsId:tostring())
    return
  end
  local mountsType = MountsMgr.Instance():GetMountsType(self.mountsId)
  self.itemMaterials = MountsUtils.GetMountsRankUpItemMaterialIds(mountsType) or {}
  self.itemChipMaterials = MountsUtils.GetMountsRankUpItemChipMaterialIds(mountsType) or {}
end
def.method().InitUI = function(self)
  self.uiObjs = {}
  self.uiObjs.Title = self.m_panel:FindDirect("Img_Bg/Title")
  GUIUtils.SetText(self.uiObjs.Title, textRes.Mounts[76])
  self.uiObjs.Img_Bg = self.m_panel:FindDirect("Img_Bg")
  self.uiObjs.Group_Left = self.uiObjs.Img_Bg:FindDirect("Group_Left")
  self.uiObjs.Group_Right = self.uiObjs.Img_Bg:FindDirect("Group_Right")
  self.uiObjs.Btn_Use = self.uiObjs.Group_Right:FindDirect("Btn_Use")
  self.uiObjs.Btn_Get = self.uiObjs.Group_Right:FindDirect("Btn_Get")
  self.uiObjs.Item = self.uiObjs.Group_Right:FindDirect("Item")
  self.uiObjs.Img_Icon = self.uiObjs.Item:FindDirect("Img_Icon")
  self.uiObjs.Label_Name = self.uiObjs.Group_Right:FindDirect("Label_Name")
  self.uiObjs.Label_Describe = self.uiObjs.Group_Right:FindDirect("Label_Describe")
end
def.method().HideMaterialDetail = function(self)
  GUIUtils.SetActive(self.uiObjs.Btn_Use, false)
  GUIUtils.SetActive(self.uiObjs.Btn_Get, false)
  GUIUtils.SetActive(self.uiObjs.Item, false)
  GUIUtils.SetText(self.uiObjs.Label_Name, "")
  self.uiObjs.Label_Describe:GetComponent("NGUIHTML"):ForceHtmlText("")
end
def.method().SetCanUseMaterial = function(self)
  local sameTypeMounts = MountsMgr.Instance():GetSameTypeMounts(self.mountsId) or {}
  local materialMounts = {}
  for i = 1, #sameTypeMounts do
    if not MountsMgr.Instance():IsMountsBattle(sameTypeMounts[i].mounts_id) then
      table.insert(materialMounts, sameTypeMounts[i])
    end
  end
  local materialItems = {}
  for i = 1, #self.itemMaterials do
    local num = ItemModule.Instance():GetNumberByItemId(ItemModule.BAG, self.itemMaterials[i])
    if i == 1 or num > 0 then
      table.insert(materialItems, self.itemMaterials[i])
    end
  end
  for i = 1, #self.itemChipMaterials do
    local num = ItemModule.Instance():GetNumberByItemId(ItemModule.BAG, self.itemChipMaterials[i])
    if i == 1 or num > 0 then
      table.insert(materialItems, self.itemChipMaterials[i])
    end
  end
  local ScrollView = self.uiObjs.Group_Left:FindDirect("Scroll View")
  local List = ScrollView:FindDirect("List")
  local uiList = List:GetComponent("UIList")
  local itemCount = #materialItems
  local mountsCount = #materialMounts
  local listNum = itemCount + mountsCount
  uiList.itemCount = listNum
  uiList:Resize()
  local items = uiList.children
  for i = 1, #items do
    if i <= itemCount then
      self:FillItemMaterialInfo(i, items[i], materialItems[i])
    else
      self:FillMountsMaterialInfo(i, items[i], materialMounts[i - itemCount])
    end
  end
  GameUtil.AddGlobalLateTimer(0, true, function()
    if not uiList.isnil then
      uiList:Reposition()
    end
  end)
end
def.method("number", "userdata", "number").FillItemMaterialInfo = function(self, idx, item, itemId)
  local texture = item:FindDirect(string.format("Img_Icon_%d", idx))
  local Number = item:FindDirect(string.format("Number_%d", idx))
  local itemBase = ItemUtils.GetItemBase(itemId)
  local uiTexture = texture:GetComponent("UITexture")
  GUIUtils.FillIcon(uiTexture, itemBase.icon)
  GUIUtils.SetText(Number, ItemModule.Instance():GetNumberByItemId(ItemModule.BAG, itemId))
  item.name = "item_" .. itemId
end
def.method("number", "userdata", "table").FillMountsMaterialInfo = function(self, idx, item, mounts)
  local texture = item:FindDirect(string.format("Img_Icon_%d", idx))
  local Number = item:FindDirect(string.format("Number_%d", idx))
  local mountsCfg = MountsUtils.GetMountsCfgById(mounts.mounts_cfg_id)
  local uiTexture = texture:GetComponent("UITexture")
  GUIUtils.FillIcon(uiTexture, mountsCfg.mountsIconId)
  GUIUtils.SetText(Number, "1")
  item.name = "mounts_" .. mounts.mounts_id:tostring()
end
def.method("number").ChooseItemMaterial = function(self, itemId)
  self.selectedItemId = itemId
  self.selectedMountsId = -1
  self:FillSelectedItemInfo()
end
def.method().FillSelectedItemInfo = function(self)
  if self.selectedItemId == -1 then
    GUIUtils.SetActive(self.uiObjs.Item, false)
    GUIUtils.SetActive(self.uiObjs.Btn_Use, false)
    GUIUtils.SetActive(self.uiObjs.Btn_Get, false)
    GUIUtils.SetText(self.uiObjs.Label_Name, "")
    self.uiObjs.Label_Describe:GetComponent("NGUIHTML"):ForceHtmlText("")
    return
  end
  local itemBase = ItemUtils.GetItemBase(self.selectedItemId)
  local addScore = MountsUtils.GetMountsRankUpItemMaterialScore(self.selectedItemId)
  GUIUtils.SetActive(self.uiObjs.Item, true)
  GUIUtils.FillIcon(self.uiObjs.Img_Icon:GetComponent("UITexture"), itemBase.icon)
  GUIUtils.SetText(self.uiObjs.Label_Name, string.format(textRes.Mounts[78], itemBase.name))
  local html = ItemTipsMgr.Instance():GetSimpleDescription(itemBase)
  html = string.gsub(html, "ffffff", "8f3d21")
  html = string.format(textRes.Mounts[85], html, addScore)
  self.uiObjs.Label_Describe:GetComponent("NGUIHTML"):ForceHtmlText(html)
  local num = ItemModule.Instance():GetNumberByItemId(ItemModule.BAG, self.selectedItemId)
  if num > 0 then
    GUIUtils.SetActive(self.uiObjs.Btn_Use, true)
    GUIUtils.SetActive(self.uiObjs.Btn_Get, false)
  else
    GUIUtils.SetActive(self.uiObjs.Btn_Use, false)
    GUIUtils.SetActive(self.uiObjs.Btn_Get, true)
  end
end
def.method("number").ChooseMountsMaterial = function(self, mountsId)
  self.selectedMountsId = mountsId
  self.selectedItemId = -1
  self:FillSelectedMountsInfo()
end
def.method().FillSelectedMountsInfo = function(self, mountsId)
  local mounts = MountsMgr.Instance():GetMountsById(Int64.new(self.selectedMountsId))
  if mounts == nil then
    GUIUtils.SetActive(self.uiObjs.Item, false)
    GUIUtils.SetActive(self.uiObjs.Btn_Use, false)
    GUIUtils.SetActive(self.uiObjs.Btn_Get, false)
    GUIUtils.SetText(self.uiObjs.Label_Name, "")
    self.uiObjs.Label_Describe:GetComponent("NGUIHTML"):ForceHtmlText("")
    return
  end
  local mountsCfg = MountsUtils.GetMountsCfgById(mounts.mounts_cfg_id)
  local mountsRankCfg = MountsUtils.GetMountsCfgOfRank(mounts.mounts_cfg_id, mounts.mounts_rank)
  GUIUtils.SetActive(self.uiObjs.Item, true)
  GUIUtils.FillIcon(self.uiObjs.Img_Icon:GetComponent("UITexture"), mountsCfg.mountsIconId)
  GUIUtils.SetText(self.uiObjs.Label_Name, mountsCfg.mountsName)
  self.uiObjs.Label_Describe:GetComponent("NGUIHTML"):ForceHtmlText(string.format(textRes.Mounts[79], mounts.mounts_rank, mountsCfg.mountsName, mountsRankCfg.rankUpConvertScore))
  GUIUtils.SetActive(self.uiObjs.Btn_Use, true)
  GUIUtils.SetActive(self.uiObjs.Btn_Get, false)
end
def.method("userdata").ShowItemGetway = function(self, source)
  if self.selectedItemId ~= -1 then
    ItemTipsMgr.Instance():ShowBasicTipsWithGO(self.selectedItemId, source, 0, true)
  end
end
def.method().UseMaterial = function(self)
  if self.selectedItemId ~= -1 and self.selectedMountsId == -1 then
    self:UseItemMaterial()
  elseif self.selectedItemId == -1 and self.selectedMountsId ~= -1 then
    self:UseMountsMaterial()
  end
end
def.method().UseItemMaterial = function(self)
  local itemBase = ItemUtils.GetItemBase(self.selectedItemId)
  local useType
  if itemBase.itemType == ItemType.RIDDER_ITEM then
    useType = MountsConst.ITEM_TYPE
  elseif itemBase.itemType == ItemType.MOUNTS_CHIP_ITEM then
    useType = MountsConst.CHIP_TYPE
  end
  if useType ~= nil then
    if self:IsReachMaxRepeaUseTimes() then
      CommonConfirmDlg.ShowConfirm("", textRes.Mounts[86], function(result)
        self:ClearLastUsedItems()
        if result == 1 then
          MountsMgr.Instance():CostItemAddScore(self.mountsId, self.selectedItemId, useType, MountsConst.YES_UES_ALL)
        else
          MountsMgr.Instance():CostItemAddScore(self.mountsId, self.selectedItemId, useType, MountsConst.NO_USE_ALL)
        end
      end, nil)
    else
      self:RecordLastUsedItem()
      MountsMgr.Instance():CostItemAddScore(self.mountsId, self.selectedItemId, useType, MountsConst.NO_USE_ALL)
    end
  end
end
def.method().RecordLastUsedItem = function(self)
  self.usedItemIds = self.usedItemIds or {}
  if self.selectedItemId ~= -1 then
    table.insert(self.usedItemIds, self.selectedItemId)
    if #self.usedItemIds == MountsJinjiePanel.MAX_REPEAT_TIMES then
      table.remove(self.usedItemIds, 1)
    end
  end
end
def.method("=>", "boolean").IsReachMaxRepeaUseTimes = function(self)
  if self.usedItemIds == nil then
    return false
  end
  if MountsJinjiePanel.MAX_REPEAT_TIMES < 1 then
    return false
  end
  if #self.usedItemIds ~= MountsJinjiePanel.MAX_REPEAT_TIMES - 1 then
    return false
  end
  for i = 1, #self.usedItemIds - 1 do
    if self.usedItemIds[i] ~= self.usedItemIds[i + 1] then
      return false
    end
  end
  return self.usedItemIds[1] == self.selectedItemId
end
def.method().ClearLastUsedItems = function(self)
  self.usedItemIds = nil
end
def.method().UseMountsMaterial = function(self)
  self:ClearLastUsedItems()
  MountsMgr.Instance():CostMountsAddScore(self.mountsId, Int64.new(self.selectedMountsId))
end
def.method("userdata").onClickObj = function(self, clickObj)
  local id = clickObj.name
  if id == "Btn_Close" then
    self:DestroyPanel()
  elseif string.find(id, "item_") then
    local itemId = tonumber(string.sub(id, #"item_" + 1))
    if itemId ~= nil then
      self:ChooseItemMaterial(itemId)
    end
  elseif string.find(id, "mounts_") then
    local mountsId = tonumber(string.sub(id, #"mounts_" + 1))
    if mountsId ~= nil then
      self:ChooseMountsMaterial(mountsId)
    end
  elseif id == "Btn_Get" then
    self:ShowItemGetway(clickObj)
  elseif id == "Btn_Use" then
    self:UseMaterial()
  end
end
def.method().FakeClickLastGrid = function(self)
  local ScrollView = self.uiObjs.Group_Left:FindDirect("Scroll View")
  local List = ScrollView:FindDirect("List")
  local uiList = List:GetComponent("UIList")
  local items = uiList.children
  for i = 1, #items do
    local item = items[i]
    if item:GetComponent("UIToggle").value then
      self:onClickObj(item)
      return
    end
  end
  self:HideMaterialDetail()
end
def.static("table", "table").OnMountsFunctionOpenChange = function(params, context)
  local self = instance
  if self ~= nil then
    local MountsModule = require("Main.Mounts.MountsModule")
    if not MountsModule.IsFunctionOpen() then
      self:DestroyPanel()
    end
  end
end
def.static("table", "table").OnMountsAddScoreSuccess = function(params, context)
  local self = instance
  if self ~= nil and MountsMgr.Instance():IsMountsRankUpScoreFull(self.mountsId) then
    Toast(textRes.Mounts[84])
    self:DestroyPanel()
  end
end
def.static("table", "table").OnItemChange = function(params, context)
  local self = instance
  if self ~= nil then
    self:SetCanUseMaterial()
    self:FakeClickLastGrid()
  end
end
def.static("table", "table").OnMountsListChange = function(params, context)
  local self = instance
  if self ~= nil then
    self:SetCanUseMaterial()
    self:FakeClickLastGrid()
  end
end
MountsJinjiePanel.Commit()
return MountsJinjiePanel
