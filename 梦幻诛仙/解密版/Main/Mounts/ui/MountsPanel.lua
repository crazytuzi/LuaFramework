local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local MountsPanel = Lplus.Extend(ECPanelBase, "MountsPanel")
local GUIUtils = require("GUI.GUIUtils")
local EC = require("Types.Vector3")
local MountsMgr = require("Main.Mounts.mgr.MountsMgr")
local BasicAttrNode = require("Main.Mounts.ui.BasicAttrNode")
local BattleNode = require("Main.Mounts.ui.BattleNode")
local GuardNode = require("Main.Mounts.ui.GuardNode")
local SurfaceNode = require("Main.Mounts.ui.SurfaceNode")
local MountsUtils = require("Main.Mounts.MountsUtils")
local MountsTypeEnum = require("consts.mzm.gsp.mounts.confbean.MountsTypeEnum")
local MountsConst = require("netio.protocol.mzm.gsp.mounts.MountsConst")
local def = MountsPanel.define
local instance
local NodeId = {
  BasicAttr = 1,
  Battle = 2,
  Guard = 3,
  Surface = 4
}
local NodeDefines = {
  [NodeId.BasicAttr] = {
    tabName = "Tap_CW",
    rootName = "SX",
    node = BasicAttrNode
  },
  [NodeId.Battle] = {
    tabName = "Tap_SZ",
    rootName = "SZ",
    node = BattleNode
  },
  [NodeId.Guard] = {
    tabName = "Tap_SH",
    rootName = "SH",
    node = GuardNode
  },
  [NodeId.Surface] = {
    tabName = "Tap_WG",
    rootName = "WG",
    node = SurfaceNode
  }
}
def.const("table").NodeId = NodeId
def.field("table").tabs = nil
def.field("table").nodes = nil
def.field("table").uiObjs = nil
def.field("number").curNode = 0
def.field("userdata").curSelectMountsId = nil
def.field("number").curSelectType = 0
def.static("=>", MountsPanel).Instance = function()
  if instance == nil then
    instance = MountsPanel()
  end
  return instance
end
def.method().ShowPanel = function(self)
  if self.m_panel ~= nil then
    return
  end
  self:CreatePanel(RESPATH.PREFAB_MOUNTS, 1)
  self:SetModal(true)
end
def.method("number").ShowPanelWithTabId = function(self, tabId)
  if self.m_panel ~= nil then
    return
  end
  self.curNode = tabId
  self:CreatePanel(RESPATH.PREFAB_MOUNTS, 1)
  self:SetModal(true)
end
def.override().OnCreate = function(self)
  self:InitUI()
  self:InitNodes()
  self:InitMountsType()
  self:SetSelectedMountsType(self.curSelectType)
  self:SetMountsList()
  if self.curNode == 0 then
    self:SwitchTo(NodeId.BasicAttr)
  else
    self:SwitchTo(self.curNode)
  end
  Event.RegisterEvent(ModuleId.MOUNTS, gmodule.notifyId.Mounts.MountsListChange, MountsPanel.OnMountsListChange)
  Event.RegisterEvent(ModuleId.MOUNTS, gmodule.notifyId.Mounts.RideMountsChange, MountsPanel.OnRideMountsChange)
  Event.RegisterEvent(ModuleId.MOUNTS, gmodule.notifyId.Mounts.MountsBattleStatusChange, MountsPanel.OnMountsBattleStatusChange)
  Event.RegisterEvent(ModuleId.MOUNTS, gmodule.notifyId.Mounts.MountsRankUpSuccess, MountsPanel.OnMountsRankUpSuccess)
  Event.RegisterEvent(ModuleId.MOUNTS, gmodule.notifyId.Mounts.MountsFunctionOpenChange, MountsPanel.OnMountsFunctionOpenChange)
  Event.RegisterEvent(ModuleId.MOUNTS, gmodule.notifyId.Mounts.MountsExtendTimeSuccess, MountsPanel.OnMountsExtendTimeSuccess)
  Event.RegisterEvent(ModuleId.MOUNTS, gmodule.notifyId.Mounts.MountsProtectPet, MountsPanel.OnMountsProtectStatusChange)
  Event.RegisterEvent(ModuleId.MOUNTS, gmodule.notifyId.Mounts.MountsUnProtectPet, MountsPanel.OnMountsProtectStatusChange)
  Event.RegisterEvent(ModuleId.MOUNTS, gmodule.notifyId.Mounts.MountsProtectPetChange, MountsPanel.OnMountsProtectStatusChange)
end
def.override().OnDestroy = function(self)
  if self.nodes[self.curNode] ~= nil then
    self.nodes[self.curNode]:Hide()
  end
  self.tabs = nil
  self.nodes = nil
  self.uiObjs = nil
  self.curNode = 0
  self.curSelectMountsId = nil
  self.curSelectType = 0
  Event.UnregisterEvent(ModuleId.MOUNTS, gmodule.notifyId.Mounts.MountsListChange, MountsPanel.OnMountsListChange)
  Event.UnregisterEvent(ModuleId.MOUNTS, gmodule.notifyId.Mounts.RideMountsChange, MountsPanel.OnRideMountsChange)
  Event.UnregisterEvent(ModuleId.MOUNTS, gmodule.notifyId.Mounts.MountsBattleStatusChange, MountsPanel.OnMountsBattleStatusChange)
  Event.UnregisterEvent(ModuleId.MOUNTS, gmodule.notifyId.Mounts.MountsRankUpSuccess, MountsPanel.OnMountsRankUpSuccess)
  Event.UnregisterEvent(ModuleId.MOUNTS, gmodule.notifyId.Mounts.MountsFunctionOpenChange, MountsPanel.OnMountsFunctionOpenChange)
  Event.UnregisterEvent(ModuleId.MOUNTS, gmodule.notifyId.Mounts.MountsExtendTimeSuccess, MountsPanel.OnMountsExtendTimeSuccess)
  Event.UnregisterEvent(ModuleId.MOUNTS, gmodule.notifyId.Mounts.MountsProtectPet, MountsPanel.OnMountsProtectStatusChange)
  Event.UnregisterEvent(ModuleId.MOUNTS, gmodule.notifyId.Mounts.MountsUnProtectPet, MountsPanel.OnMountsProtectStatusChange)
  Event.UnregisterEvent(ModuleId.MOUNTS, gmodule.notifyId.Mounts.MountsProtectPetChange, MountsPanel.OnMountsProtectStatusChange)
end
def.method().InitUI = function(self)
  self.uiObjs = {}
  self.uiObjs.Img_Bg0 = self.m_panel:FindDirect("Img_Bg0")
  self.uiObjs.PetList = self.uiObjs.Img_Bg0:FindDirect("PetList")
  self.uiObjs.Img_PetList = self.uiObjs.PetList:FindDirect("Img_PetList")
  self.uiObjs.Label_PetListNum = self.uiObjs.Img_PetList:FindDirect("Label_PetListNum")
  self.uiObjs.Scroll_View_PetList = self.uiObjs.Img_PetList:FindDirect("Scroll View_PetList")
  self.uiObjs.Group_ChooseType = self.uiObjs.PetList:FindDirect("Group_ChooseType")
  GUIUtils.SetActive(self.uiObjs.PetList:FindDirect("Btn_Tj"), not GameUtil.IsEvaluation())
  GUIUtils.SetActive(self.uiObjs.Group_ChooseType, false)
end
def.method().InitNodes = function(self)
  if not self.uiObjs.Img_Bg0 then
    return
  end
  self.nodes = {}
  self.tabs = {}
  for nodeId, v in pairs(NodeDefines) do
    local nodeRoot = self.uiObjs.Img_Bg0:FindDirect(v.rootName)
    local nodeTab = self.uiObjs.Img_Bg0:FindDirect(v.tabName)
    GUIUtils.SetActive(nodeRoot, false)
    nodeTab:GetComponent("UIToggle").value = false
    self.tabs[nodeId] = nodeTab
    if v.node then
      self.nodes[nodeId] = v.node()
      self.nodes[nodeId]:Init(self, nodeRoot)
    else
      self.nodes[nodeId] = v.node
    end
  end
end
def.method().InitMountsType = function(self)
  local ScrollView = self.uiObjs.Group_ChooseType:FindDirect("Img_Bg2/Scroll View")
  local List_Item = ScrollView:FindDirect("List_Item")
  local uiList = List_Item:GetComponent("UIList")
  local MountsType = {}
  table.insert(MountsType, 0)
  for k, v in pairs(MountsTypeEnum) do
    if textRes.Mounts.MountsType[v] ~= nil then
      table.insert(MountsType, v)
    end
  end
  table.sort(MountsType, function(a, b)
    return a < b
  end)
  local typeCount = #MountsType
  uiList:set_itemCount(typeCount)
  uiList:Resize()
  local items = uiList.children
  for i = 1, #items do
    local listItem = items[i]
    local typeId = MountsType[i]
    listItem.name = "MountsType_" .. typeId
    GUIUtils.SetText(listItem:FindDirect("Btn_Item/Label_Name2"), textRes.Mounts.MountsType[typeId])
  end
  uiList:Resize()
  uiList:Reposition()
  GameUtil.AddGlobalTimer(0, true, function()
    ScrollView:GetComponent("UIScrollView"):ResetPosition()
  end)
end
def.method("number").SetSelectedMountsType = function(self, typeId)
  self.curSelectType = typeId
  local Label_PetList = self.uiObjs.Img_PetList:FindDirect("Label_PetList")
  GUIUtils.SetText(Label_PetList, textRes.Mounts.MountsType[typeId])
end
def.method("number").SwitchTo = function(self, nodeId)
  local preNode = self.curNode
  self.curNode = nodeId
  if self.nodes[preNode] ~= nil and self.tabs[preNode] ~= nil then
    self.nodes[preNode]:Hide()
    self.tabs[preNode]:GetComponent("UIToggle").value = false
  end
  if self.nodes[self.curNode] ~= nil and self.tabs[self.curNode] ~= nil then
    self.nodes[self.curNode]:Show()
    self.tabs[self.curNode]:GetComponent("UIToggle").value = true
  end
  self:SetMountsList()
  self:ShowCurrentMountsInfo()
end
def.method().SetMountsList = function(self)
  local dataList = MountsMgr.Instance():GetSortedMountsList()
  local showMount = {}
  for i = 1, #dataList do
    local mountsCfg = MountsUtils.GetMountsCfgById(dataList[i].mounts_cfg_id)
    if self.curSelectType == 0 or mountsCfg.mountsType == self.curSelectType then
      table.insert(showMount, dataList[i])
    end
  end
  local listPetList = self.uiObjs.Scroll_View_PetList:FindDirect("List_PetList")
  local uiList = listPetList:GetComponent("UIList")
  local maxSize = constant.CMountsConsts.maxMountsNum
  local amount = #showMount
  uiList:set_itemCount(amount)
  uiList:Resize()
  local items = uiList.children
  for index = 1, amount do
    local listItem = items[index]
    local petListItem = listItem:FindDirect("Pet01")
    if petListItem then
      petListItem:set_name("Pet_" .. index)
    else
      petListItem = listItem:FindDirect("Pet_" .. index)
    end
    petListItem:GetComponent("UIToggle"):set_startsActive(false)
    if index <= #dataList then
      self:SetMountsItemInfo(petListItem, showMount[index])
    elseif index <= maxSize then
      self:SetEmptyListItem(petListItem)
    end
  end
  uiList:Resize()
  uiList:Reposition()
  self:TouchGameObject(self.m_panel, self.m_parent)
  GUIUtils.SetText(self.uiObjs.Label_PetListNum, string.format("%d/%d", #dataList, maxSize))
end
def.method().ResetMountsListPosition = function(self)
  local listPetList = self.uiObjs.Scroll_View_PetList:FindDirect("List_PetList")
  local uiList = listPetList:GetComponent("UIList")
  local items = uiList.children
  local stayPos = 0
  for index = 1, #items do
    local listItem = items[index]
    local petListItem = listItem:FindDirect("Pet_" .. index)
    if petListItem:GetComponent("UIToggle").value then
      stayPos = listItem.localPosition.y + petListItem:GetComponent("UIWidget").height / 2
      break
    end
  end
  self.uiObjs.Scroll_View_PetList:GetComponent("UIScrollView"):SetDragDistance(0, -stayPos, false)
end
def.method("userdata", "table").SetMountsItemInfo = function(self, item, mounts)
  GUIUtils.SetActive(item:FindDirect("Group_Add"), false)
  GUIUtils.SetActive(item:FindDirect("Group_Empty"), false)
  GUIUtils.SetActive(item:FindDirect("Img_Red"), false)
  GUIUtils.SetActive(item:FindDirect("Img_BgPetItem"), true)
  local mountsCfg = MountsUtils.GetMountsCfgById(mounts.mounts_cfg_id)
  local Label_PetName01 = item:FindDirect("Label_PetName01")
  local Label_PetLv01 = item:FindDirect("Label_PetLv01")
  GUIUtils.SetText(Label_PetName01, mountsCfg.mountsName)
  if mountsCfg.mountsType == MountsTypeEnum.APPEARANCE_TYPE then
    if Int64.eq(mounts.remain_time, MountsConst.TIME_FOREVER) then
      GUIUtils.SetText(Label_PetLv01, textRes.Mounts[68])
    else
      local AbsoluteTimer = require("Main.Common.AbsoluteTimer")
      local t = AbsoluteTimer.GetServerTimeTable(Int64.ToNumber(mounts.remain_time))
      local timeStr = string.format("%02d/%02d %02d:%02d", t.month, t.day, t.hour, t.min)
      GUIUtils.SetText(Label_PetLv01, string.format(textRes.Mounts[58], timeStr))
    end
  else
    GUIUtils.SetText(Label_PetLv01, string.format(textRes.Mounts[1], mounts.mounts_rank))
  end
  local Img_BgPetItem = item:FindDirect("Img_BgPetItem")
  local Icon_Pet01 = Img_BgPetItem:FindDirect("Icon_Pet01")
  GUIUtils.FillIcon(Icon_Pet01:GetComponent("UITexture"), mountsCfg.mountsIconId)
  item:FindDirect("Img_Many"):SetActive(1 < mountsCfg.maxMountRoleNum)
  local mountsTag = item:GetComponent("UILabel")
  if mountsTag == nil then
    mountsTag = item:AddComponent("UILabel")
    mountsTag:set_enabled(false)
  end
  mountsTag.text = mounts.mounts_id:tostring()
  local Img_Shouhu = item:FindDirect("Img_Shouhu")
  local Img_Canzhan = item:FindDirect("Img_Canzhan")
  if self.curNode ~= NodeId.Guard then
    GUIUtils.SetActive(Img_Shouhu, false)
    local curRideId = MountsMgr.Instance():GetCurRideMountsId()
    if curRideId ~= nil and Int64.eq(mounts.mounts_id, curRideId) then
      GUIUtils.SetActive(Img_Canzhan, true)
    else
      GUIUtils.SetActive(Img_Canzhan, false)
    end
  else
    GUIUtils.SetActive(Img_Canzhan, false)
    GUIUtils.SetActive(Img_Shouhu, MountsMgr.Instance():MountsHasProtectedPet(mounts.mounts_id))
  end
  if MountsMgr.Instance():IsMountsBattle(mounts.mounts_id) then
    GUIUtils.SetActive(item:FindDirect("Img_Shangzhen"), true)
  else
    GUIUtils.SetActive(item:FindDirect("Img_Shangzhen"), false)
  end
end
def.method("userdata").SetEmptyListItem = function(self, item)
  GUIUtils.SetActive(item:FindDirect("Img_Shangzhen"), false)
  GUIUtils.SetActive(item:FindDirect("Group_Add"), false)
  GUIUtils.SetActive(item:FindDirect("Group_Empty"), true)
  GUIUtils.SetActive(item:FindDirect("Img_Red"), false)
  GUIUtils.SetActive(item:FindDirect("Img_BgPetItem"), false)
  local Label_PetName01 = item:FindDirect("Label_PetName01")
  local Label_PetLv01 = item:FindDirect("Label_PetLv01")
  GUIUtils.SetText(Label_PetName01, "")
  GUIUtils.SetText(Label_PetLv01, "")
end
def.method().ShowCurrentMountsInfo = function(self)
  local listPetList = self.uiObjs.Scroll_View_PetList:FindDirect("List_PetList")
  local uiList = listPetList:GetComponent("UIList")
  local items = uiList.children
  if #items == 0 then
    self.curSelectMountsId = nil
  elseif self.curSelectMountsId == nil then
    self:SelectedMountsItemByIndex(1)
  else
    local found = false
    for index = 1, #items do
      local listItem = items[index]
      local petListItem = listItem:FindDirect("Pet_" .. index)
      petListItem:GetComponent("UIToggle").value = true
      local mountsTag = petListItem:GetComponent("UILabel")
      if mountsTag ~= nil then
        local id = tonumber(mountsTag.text)
        if id ~= nil and Int64.eq(self.curSelectMountsId, id) then
          found = true
          self:SelectedMountsItemByIndex(index)
          break
        end
      end
    end
    if not found then
      self:SelectedMountsItemByIndex(1)
    end
  end
  if self.curNode == NodeId.Battle then
    return
  end
  if self.curSelectMountsId == nil then
    if self.nodes[self.curNode] ~= nil then
      self.nodes[self.curNode]:NoMounts()
    end
  elseif self.nodes[self.curNode] ~= nil then
    self.nodes[self.curNode]:ChooseMounts(self.curSelectMountsId)
  end
end
def.method("number").SelectedMountsItemByIndex = function(self, idx)
  local listPetList = self.uiObjs.Scroll_View_PetList:FindDirect("List_PetList")
  local uiList = listPetList:GetComponent("UIList")
  local items = uiList.children
  if items[idx] ~= nil then
    local listItem = items[idx]
    local petListItem = listItem:FindDirect("Pet_" .. idx)
    petListItem:GetComponent("UIToggle").value = true
    local mountsTag = petListItem:GetComponent("UILabel")
    if mountsTag ~= nil then
      local id = tonumber(mountsTag.text)
      if id ~= nil then
        self.curSelectMountsId = Int64.new(id)
      end
    end
  end
end
def.method("userdata").onClickObj = function(self, clickObj)
  GUIUtils.SetActive(self.uiObjs.Group_ChooseType, false)
  local id = clickObj.name
  if id == "Btn_Close" then
    self:DestroyPanel()
  elseif id == "Btn_Switch" then
    self:ToggleRideMounts()
  elseif "Tap_CW" == id then
    self:SwitchTo(NodeId.BasicAttr)
  elseif "Tap_SZ" == id then
    self:SwitchTo(NodeId.Battle)
  elseif "Tap_SH" == id then
    self:SwitchTo(NodeId.Guard)
  elseif "Tap_WG" == id then
    self:SwitchTo(NodeId.Surface)
  elseif string.find(id, "Pet_") then
    local mountsTag = clickObj:GetComponent("UILabel")
    if mountsTag ~= nil then
      local mountsId = tonumber(mountsTag.text)
      if mountsId ~= nil then
        self.curSelectMountsId = Int64.new(mountsId)
        self.nodes[self.curNode]:ChooseMounts(Int64.new(mountsId))
      end
    end
  elseif id == "Btn_ChooseType" then
    GUIUtils.SetActive(self.uiObjs.Group_ChooseType, true)
  elseif id == "Btn_Item" then
    local parent = clickObj.transform.parent.gameObject
    if parent ~= nil then
      local clickName = parent.name
      if string.find(clickName, "MountsType_") then
        local typeId = tonumber(string.sub(clickName, #"MountsType_" + 1))
        if typeId ~= nil then
          self:SetSelectedMountsType(typeId)
          self:SetMountsList()
          self:ShowCurrentMountsInfo()
          self:ResetMountsListPosition()
        end
      end
    end
  elseif id == "Btn_Tj" then
    require("Main.Mounts.ui.MountsTujianPanel").Instance():ShowPanel()
  elseif self.nodes[self.curNode] ~= nil then
    self.nodes[self.curNode]:onClickObj(clickObj)
  end
end
def.method("string").onDragStart = function(self, id)
  self.nodes[self.curNode]:onDragStart(id)
end
def.method("string").onDragEnd = function(self, id)
  self.nodes[self.curNode]:onDragEnd(id)
end
def.method("string", "number", "number").onDrag = function(self, id, dx, dy)
  self.nodes[self.curNode]:onDrag(id, dx, dy)
end
def.method().Close = function(self)
  self:DestroyPanel()
end
def.override("boolean").OnShow = function(self, s)
  if s then
    self:SetMountsList()
    self:ShowCurrentMountsInfo()
  end
end
def.method().ToggleRideMounts = function(self)
  local mountsMgr = MountsMgr.Instance()
  local curRideId = mountsMgr:GetCurRideMountsId()
  if curRideId ~= nil and Int64.eq(curRideId, self.curSelectMountsId) then
    mountsMgr:UnRideMounts()
  else
    mountsMgr:RideMounts(self.curSelectMountsId)
  end
end
def.static("table", "table").OnMountsListChange = function(params, context)
  local self = instance
  if self ~= nil then
    self:SetMountsList()
    self:ShowCurrentMountsInfo()
    self:ResetMountsListPosition()
  end
end
def.static("table", "table").OnRideMountsChange = function(params, context)
  local self = instance
  if self ~= nil then
    self:SetMountsList()
    self:ShowCurrentMountsInfo()
    self:ResetMountsListPosition()
  end
end
def.static("table", "table").OnMountsBattleStatusChange = function(params, context)
  local self = instance
  if self ~= nil then
    self:SetMountsList()
    self:ShowCurrentMountsInfo()
    self:ResetMountsListPosition()
  end
end
def.static("table", "table").OnMountsRankUpSuccess = function(params, context)
  local self = instance
  if self ~= nil then
    self:SetMountsList()
    self:ShowCurrentMountsInfo()
    self:ResetMountsListPosition()
  end
end
def.static("table", "table").OnMountsFunctionOpenChange = function(params, context)
  local self = instance
  if self ~= nil then
    local MountsModule = require("Main.Mounts.MountsModule")
    if not MountsModule.IsFunctionOpen() then
      Toast(textRes.Mounts[57])
      self:Close()
    end
  end
end
def.static("table", "table").OnMountsExtendTimeSuccess = function(params, context)
  local self = instance
  if self ~= nil then
    self:SetMountsList()
  end
end
def.static("table", "table").OnMountsProtectStatusChange = function(params, context)
  local self = instance
  if self ~= nil then
    self:SetMountsList()
  end
end
MountsPanel.Commit()
return MountsPanel
