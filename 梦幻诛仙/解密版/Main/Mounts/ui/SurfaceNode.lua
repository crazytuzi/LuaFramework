local Lplus = require("Lplus")
local MountsPanelNodeBase = require("Main.Mounts.ui.MountsPanelNodeBase")
local ECPanelBase = require("GUI.ECPanelBase")
local SurfaceNode = Lplus.Extend(MountsPanelNodeBase, "SurfaceNode")
local GUIUtils = require("GUI.GUIUtils")
local Vector = require("Types.Vector")
local Vector3 = require("Types.Vector3").Vector3
local MountsUIModel = require("Main.Mounts.MountsUIModel")
local MountsUtils = require("Main.Mounts.MountsUtils")
local MountsMgr = require("Main.Mounts.mgr.MountsMgr")
local ItemModule = require("Main.Item.ItemModule")
local ItemUtils = require("Main.Item.ItemUtils")
local ItemTipsMgr = require("Main.Item.ItemTipsMgr")
local CommonConfirmDlg = require("GUI.CommonConfirmDlg")
local def = SurfaceNode.define
def.field("table").uiObjs = nil
def.field(MountsUIModel).model = nil
def.field("boolean").isDragModel = false
def.field("number").selectedColorIndex = 0
def.field("boolean").hasEnoughMaterial = false
def.field("boolean").useYuanbao = false
def.field("number").needYuanbao = 0
def.field("number").needItemType = -1
def.field("number").needItemNum = 0
def.field("number").hasItemNum = 0
def.field("number").calItemId = 0
def.override(ECPanelBase, "userdata").Init = function(self, base, node)
  MountsPanelNodeBase.Init(self, base, node)
end
def.override().OnShow = function(self)
  self:InitUI()
  Event.RegisterEventWithContext(ModuleId.ITEM, gmodule.notifyId.item.Item_OnBagInfoSynchronized, SurfaceNode.OnBagInfoSynchronized, self)
  Event.RegisterEventWithContext(ModuleId.MOUNTS, gmodule.notifyId.Mounts.MountsDyeSuccess, SurfaceNode.OnMountsDyeSuccess, self)
  Event.RegisterEventWithContext(ModuleId.MOUNTS, gmodule.notifyId.Mounts.MountsOrnamentChange, SurfaceNode.OnMountsOrnamentChange, self)
end
def.override().OnHide = function(self)
  self:Clear()
  Event.UnregisterEvent(ModuleId.ITEM, gmodule.notifyId.item.Item_OnBagInfoSynchronized, SurfaceNode.OnBagInfoSynchronized)
  Event.UnregisterEvent(ModuleId.MOUNTS, gmodule.notifyId.Mounts.MountsDyeSuccess, SurfaceNode.OnMountsDyeSuccess)
  Event.UnregisterEvent(ModuleId.MOUNTS, gmodule.notifyId.Mounts.MountsOrnamentChange, SurfaceNode.OnMountsOrnamentChange)
end
def.method().Clear = function(self)
  self.uiObjs = nil
  if self.model ~= nil then
    self.model:Destroy()
    self.model = nil
  end
  self.isDragModel = false
  self:ClearData()
end
def.method().ClearData = function(self)
  self.selectedColorIndex = 0
  self.hasEnoughMaterial = false
  self.useYuanbao = false
  self.needYuanbao = 0
  self.needItemType = -1
  self.needItemNum = 0
  self.hasItemNum = 0
  self.calItemId = 0
end
def.method().InitUI = function(self)
  if not self.m_node or self.m_node.isnil then
    return
  end
  self.uiObjs = {}
  self.uiObjs.Group_Dye = self.m_node:FindDirect("Group_Dye")
  self.uiObjs.Group_ChooseType = self.uiObjs.Group_Dye:FindDirect("Group_ChooseType")
  GUIUtils.SetActive(self.uiObjs.Group_ChooseType, false)
end
def.override("userdata").ChooseMounts = function(self, mountsId)
  if not self.isShow then
    return
  end
  MountsPanelNodeBase.ChooseMounts(self, mountsId)
  self:ClearData()
  self:FillMountsModelAndColors()
  self:SetDyeCost()
  self:SetButtonStatus()
  self:SetMountsOrnament()
end
def.override().NoMounts = function(self)
  if not self.isShow then
    return
  end
  MountsPanelNodeBase.NoMounts(self)
  GUIUtils.SetActive(self.uiObjs.Group_Dye, false)
end
def.method().FillMountsModelAndColors = function(self)
  local mounts = MountsMgr.Instance():GetMountsById(self.curMountsId)
  local mountsCfg = MountsUtils.GetMountsCfgById(mounts.mounts_cfg_id)
  if mounts == nil or mountsCfg == nil then
    GUIUtils.SetActive(self.uiObjs.Group_Dye, false)
    return
  end
  GUIUtils.SetActive(self.uiObjs.Group_Dye, true)
  local Model = self.uiObjs.Group_Dye:FindDirect("Model")
  local uiModel = Model:GetComponent("UIModel")
  if self.model ~= nil then
    self.model:Destroy()
  end
  self.model = MountsUtils.LoadMountsModel(uiModel, mounts.mounts_cfg_id, mounts.current_ornament_rank, mounts.color_id, function()
    if self.model ~= nil then
      self.model:SetDir(-135)
    end
  end)
  local Group_Color = self.uiObjs.Group_Dye:FindDirect("Group_Color")
  local Container = Group_Color:FindDirect("Container")
  local dyeColors = MountsUtils.GetMountsDyeColorCfg(mounts.mounts_cfg_id) or {}
  local dyeSelecterCount = 14
  for i = 1, #dyeColors do
    local colorData = dyeColors[i]
    local colorObj = Container:FindDirect("WingColor" .. i)
    if colorObj ~= nil then
      GUIUtils.SetActive(colorObj, true)
      local dyeData = GetModelColorCfg(colorData.modelColorId)
      if dyeData then
        local alpha = (dyeData.part2_a < 128 and dyeData.part2_a or 128) / 255 * 2
        GUIUtils.SetColor(colorObj, Color.Color(dyeData.part2_r / 255 * alpha, dyeData.part2_g / 255 * alpha, dyeData.part2_b / 255 * alpha, 1), GUIUtils.COTYPE.SPRITE)
        if colorData.id == mounts.color_id then
          self.selectedColorIndex = i
          colorObj:GetComponent("UIToggle").value = true
        end
      end
    end
  end
  for i = #dyeColors + 1, dyeSelecterCount do
    local colorObj = Container:FindDirect("WingColor" .. i)
    GUIUtils.SetActive(colorObj, false)
  end
end
def.method().SetDyeCost = function(self)
  local Img_Item = self.uiObjs.Group_Dye:FindDirect("Img_Item")
  local Label_ItemName = Img_Item:FindDirect("Label_ItemName")
  local Texture_Item = Img_Item:FindDirect("Texture_Item")
  local Label_Num = Img_Item:FindDirect("Label_Num")
  local mounts = MountsMgr.Instance():GetMountsById(self.curMountsId)
  local mountsCfg = MountsUtils.GetMountsCfgById(mounts.mounts_cfg_id)
  local dyeColors = MountsUtils.GetMountsDyeColorCfg(mounts.mounts_cfg_id) or {}
  self.hasEnoughMaterial = false
  if dyeColors[self.selectedColorIndex] == nil then
    GUIUtils.SetActive(Img_Item, false)
  elseif dyeColors[self.selectedColorIndex].id == mounts.color_id then
    self.hasEnoughMaterial = true
    GUIUtils.SetActive(Img_Item, false)
  else
    GUIUtils.SetActive(Img_Item, true)
    local needItemType = dyeColors[self.selectedColorIndex].costItemType
    local needNum = dyeColors[self.selectedColorIndex].itemCount
    local calItemId = dyeColors[self.selectedColorIndex].itemId
    local needItemList = ItemUtils.GetItemTypeRefIdList(needItemType)
    if needItemList ~= nil then
      local itemBase = ItemUtils.GetItemBase(needItemList[1])
      if itemBase ~= nil then
        self.needItemType = needItemType
        GUIUtils.FillIcon(Texture_Item:GetComponent("UITexture"), itemBase.icon)
        local hasNum = 0
        local items = ItemModule.Instance():GetItemsByItemType(ItemModule.BAG, needItemType)
        for k, v in pairs(items) do
          hasNum = hasNum + v.number
        end
        self.needItemNum = needNum
        self.hasItemNum = hasNum
        self.calItemId = calItemId
        if needNum > hasNum then
          GUIUtils.SetText(Label_Num, string.format("[ff0000]%d/%d[-]", hasNum, needNum))
        else
          GUIUtils.SetText(Label_Num, string.format("%d/%d", hasNum, needNum))
          self.hasEnoughMaterial = true
        end
        GUIUtils.SetText(Label_ItemName, itemBase.name)
      end
    else
      GUIUtils.SetActive(Img_Item, false)
    end
  end
end
def.method().SetButtonStatus = function(self)
  local Btn_Dye = self.uiObjs.Group_Dye:FindDirect("Btn_Dye")
  local Group_Yuanbao = Btn_Dye:FindDirect("Group_Yuanbao")
  local Label_Money = Group_Yuanbao:FindDirect("Label_Money")
  local Label_Dye = Btn_Dye:FindDirect("Label")
  if not self.useYuanbao or self.hasEnoughMaterial then
    GUIUtils.SetActive(Label_Dye, true)
    GUIUtils.SetText(Label_Dye, textRes.Mounts[43])
    GUIUtils.SetActive(Group_Yuanbao, false)
  else
    require("Main.Item.ItemConsumeHelper").Instance():GetItemYuanBaoPrice(self.calItemId, function(result)
      if self.m_panel == nil or self.m_panel.isnil then
        return
      end
      self.needYuanbao = result * (self.needItemNum - self.hasItemNum)
      GUIUtils.SetActive(Label_Dye, false)
      GUIUtils.SetActive(Group_Yuanbao, true)
      GUIUtils.SetText(Label_Money, self.needYuanbao)
    end)
  end
  local Img_Item = self.uiObjs.Group_Dye:FindDirect("Img_Item")
  local Btn_UseGold = Img_Item:FindDirect("Btn_UseGold")
  Btn_UseGold:GetComponent("UIToggle").value = self.useYuanbao
end
def.method().SetMountsOrnament = function(self)
  GUIUtils.SetActive(self.uiObjs.Group_ChooseType, false)
  local Label_PeishiTitle = self.uiObjs.Group_Dye:FindDirect("Label_PeishiTitle")
  local Label_PeiShi = self.uiObjs.Group_Dye:FindDirect("Label_PeiShi")
  local mounts = MountsMgr.Instance():GetMountsById(self.curMountsId)
  if mounts == nil then
    GUIUtils.SetActive(Label_PeishiTitle, false)
    GUIUtils.SetActive(Label_PeiShi, false)
  else
    local availableRank = MountsUtils.GetMountsAvailableRank(mounts.mounts_cfg_id)
    if #availableRank > 1 then
      GUIUtils.SetActive(Label_PeishiTitle, true)
      GUIUtils.SetActive(Label_PeiShi, true)
      GUIUtils.SetText(Label_PeiShi, string.format(textRes.Mounts[112], mounts.current_ornament_rank))
    else
      GUIUtils.SetActive(Label_PeishiTitle, false)
      GUIUtils.SetActive(Label_PeiShi, false)
    end
  end
end
def.method().ShowMountsOrnamentSelector = function(self)
  local mounts = MountsMgr.Instance():GetMountsById(self.curMountsId)
  if mounts == nil then
    GUIUtils.SetActive(self.uiObjs.Group_ChooseType, false)
    return
  end
  local availableRank = MountsUtils.GetMountsAvailableRank(mounts.mounts_cfg_id)
  GUIUtils.SetActive(self.uiObjs.Group_ChooseType, true)
  local ScrollView = self.uiObjs.Group_ChooseType:FindDirect("Img_Bg2/Scroll View")
  local List_Item = ScrollView:FindDirect("List_Item")
  local uiList = List_Item:GetComponent("UIList")
  uiList:set_itemCount(#availableRank)
  uiList:Resize()
  local items = uiList.children
  for i = 1, #items do
    local listItem = items[i]
    local Btn_Item = listItem:FindDirect("Btn_Item")
    if Btn_Item == nil then
      Btn_Item = listItem:FindDirect("Ornament_Item")
    else
      Btn_Item.name = "Ornament_Item"
    end
    listItem.name = "OrnamentRank_" .. availableRank[i]
    GUIUtils.SetText(listItem:FindDirect("Ornament_Item/Label_Name2"), string.format(textRes.Mounts[112], availableRank[i]))
    Btn_Item:GetComponent("UIButton"):set_enabled(false)
    if availableRank[i] <= mounts.mounts_rank then
      GUIUtils.SetColor(Btn_Item, Color.Color(1, 1, 1, 1), GUIUtils.COTYPE.SPRITE)
    else
      GUIUtils.SetColor(Btn_Item, Color.Color(0.7, 0.7, 0.7, 1), GUIUtils.COTYPE.SPRITE)
    end
  end
  uiList:Resize()
  uiList:Reposition()
  GameUtil.AddGlobalTimer(0.1, true, function()
    if ScrollView.isnil then
      return
    end
    ScrollView:GetComponent("UIScrollView"):ResetPosition()
  end)
end
def.method().ClickUseYuanbao = function(self)
  local Img_Item = self.uiObjs.Group_Dye:FindDirect("Img_Item")
  local Btn_UseGold = Img_Item:FindDirect("Btn_UseGold")
  if not Btn_UseGold:GetComponent("UIToggle").value then
    self.useYuanbao = false
    self:SetButtonStatus()
    return
  end
  self:ConfirmUseYuanbao()
end
def.method().ConfirmUseYuanbao = function(self)
  if self.hasEnoughMaterial then
    self.useYuanbao = false
    self:SetButtonStatus()
    Toast(textRes.Mounts[42])
    return
  end
  CommonConfirmDlg.ShowConfirm("", textRes.Mounts[51], function(result)
    self.useYuanbao = result == 1
    self:SetButtonStatus()
  end, nil)
end
def.method("number").TryDyeColor = function(self, colorIndex)
  self.selectedColorIndex = colorIndex
  self:DyeModel()
  self:SetDyeCost()
  self:SetButtonStatus()
end
def.method().DyeModel = function(self)
  if self.model ~= nil then
    local mounts = MountsMgr.Instance():GetMountsById(self.curMountsId)
    local dyeColors = MountsUtils.GetMountsDyeColorCfg(mounts.mounts_cfg_id) or {}
    if dyeColors[self.selectedColorIndex] ~= nil then
      self.model:SetMountsColor(dyeColors[self.selectedColorIndex].id)
    end
  end
end
def.method("userdata").ShowMaterialTips = function(self, source)
  if self.needItemType ~= -1 then
    local needItemList = ItemUtils.GetItemTypeRefIdList(self.needItemType)
    if needItemList ~= nil then
      local needItemId = self.calItemId
      ItemTipsMgr.Instance():ShowBasicTipsWithGO(needItemId, source.parent, 0, true)
    end
  end
end
def.method().DyeMounts = function(self)
  if _G.CheckCrossServerAndToast() then
    return
  end
  local mounts = MountsMgr.Instance():GetMountsById(self.curMountsId)
  local dyeColors = MountsUtils.GetMountsDyeColorCfg(mounts.mounts_cfg_id) or {}
  if dyeColors[self.selectedColorIndex] == nil then
    return
  elseif dyeColors[self.selectedColorIndex].id == mounts.color_id then
    Toast(textRes.Mounts[44])
    return
  end
  if self.hasEnoughMaterial or self.useYuanbao then
    local yuanBaoNum = ItemModule.Instance():GetAllYuanBao()
    if Int64.lt(yuanBaoNum, self.needYuanbao) then
      _G.GotoBuyYuanbao()
      return
    end
    MountsMgr.Instance():MountsDye(self.curMountsId, dyeColors[self.selectedColorIndex].id, self.useYuanbao, self.needYuanbao)
  else
    self:ConfirmUseYuanbao()
  end
end
def.method("number").ChooseMountsOrnament = function(self, ornamentRank)
  if _G.CheckCrossServerAndToast() then
    return
  end
  local mounts = MountsMgr.Instance():GetMountsById(self.curMountsId)
  if mounts == nil then
    return
  end
  if ornamentRank > mounts.mounts_rank then
    Toast(string.format(textRes.Mounts[113], ornamentRank, ornamentRank))
    return
  elseif ornamentRank == mounts.current_ornament_rank then
    Toast(string.format(textRes.Mounts[114], ornamentRank))
    return
  end
  MountsMgr.Instance():MountsSelectOrnament(self.curMountsId, ornamentRank)
end
def.override("userdata").onClickObj = function(self, clickObj)
  GUIUtils.SetActive(self.uiObjs.Group_ChooseType, false)
  local id = clickObj.name
  if id == "Ornament_Item" then
    local parent = clickObj.parent
    if parent ~= nil then
      id = parent.name
      clickObj = parent
    end
  end
  if string.find(id, "WingColor") then
    local index = tonumber(string.sub(id, #"WingColor" + 1))
    if index ~= nil then
      self:TryDyeColor(index)
    end
  elseif id == "Texture_Item" then
    self:ShowMaterialTips(clickObj)
  elseif id == "Btn_UseGold" then
    self:ClickUseYuanbao()
  elseif id == "Btn_Dye" then
    self:DyeMounts()
  elseif id == "Btn_ChooseProvince" then
    self:ShowMountsOrnamentSelector()
  elseif string.find(id, "OrnamentRank_") then
    local rank = tonumber(string.sub(id, #"OrnamentRank_" + 1))
    if rank ~= nil then
      self:ChooseMountsOrnament(rank)
    end
  end
end
def.override("string").onDragStart = function(self, id)
  if id == "Model" then
    self.isDragModel = true
  end
end
def.override("string").onDragEnd = function(self, id)
  self.isDragModel = false
end
def.override("string", "number", "number").onDrag = function(self, id, dx, dy)
  if self.isDragModel == true and self.model then
    self.model:SetDir(self.model.m_ang - dx / 2)
  end
end
def.static("table", "table").OnBagInfoSynchronized = function(context, params)
  local self = context
  if self ~= nil then
    self:SetDyeCost()
    self:SetButtonStatus()
  end
end
def.static("table", "table").OnMountsDyeSuccess = function(context, params)
  local self = context
  if self ~= nil then
    self:SetDyeCost()
    self:SetButtonStatus()
  end
end
def.static("table", "table").OnMountsOrnamentChange = function(context, params)
  local self = context
  if self ~= nil then
    local mountsId = params[1]
    local ornamentRank = params[2]
    if mountsId ~= nil and ornamentRank ~= nil and self.curMountsId ~= nil and Int64.eq(mountsId, self.curMountsId) then
      Toast(string.format(textRes.Mounts[115], ornamentRank))
      self:SetMountsOrnament()
      self:FillMountsModelAndColors()
    end
  end
end
SurfaceNode.Commit()
return SurfaceNode
