local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local BreakOutNode = require("Main.GodWeapon.ui.BreakOutNode")
local JewelNode = require("Main.GodWeapon.ui.JewelNode")
local DecorationNode = require("Main.GodWeapon.ui.DecorationNode")
local GUIUtils = require("GUI.GUIUtils")
local ItemUtils = require("Main.Item.ItemUtils")
local ItemXStoreType = require("netio.protocol.mzm.gsp.item.ItemXStoreType")
local UIGodWeaponBasic = Lplus.Extend(ECPanelBase, "UIGodWeaponBasic")
local def = UIGodWeaponBasic.define
local instance
def.field("boolean").isDrag = false
def.static("=>", UIGodWeaponBasic).Instance = function()
  if instance == nil then
    instance = UIGodWeaponBasic()
  end
  return instance
end
def.const("table").NodeId = {
  BreakOut = 1,
  Jewel = 2,
  Decoration = 3
}
def.field("number")._curNodeId = 0
def.field("table")._nodes = nil
def.field("table")._tabs = nil
def.field("table")._reddotCheckFuncMap = nil
def.field("table")._tab2NodeIdMap = nil
def.field("table")._params = nil
def.field("table")._equipList = nil
def.field("table")._uiObjs = nil
def.method("number").ShowPanel = function(self, node)
  if self:IsLoaded() then
    return
  end
  if self:IsShow() then
    self:SwitchTo(node)
    return
  end
  self._curNodeId = node
  self:CreatePanel(RESPATH.PREFAB_GODWEAPON, 1)
  self:SetModal(true)
end
def.method("number", "table").ShowWithParams = function(self, node, params)
  if self:IsShow() then
    self._params = params
    self:SwitchTo(node)
    return
  end
  self._curNodeId = node
  self._params = params
  self:CreatePanel(RESPATH.PREFAB_GODWEAPON, 1)
  self:SetModal(true)
end
def.override().OnCreate = function(self)
  Event.RegisterEventWithContext(ModuleId.GOD_WEAPON, gmodule.notifyId.GodWeapon.GOD_WEAPON_FEATURE_CHANGE, UIGodWeaponBasic.OnFeatureChange, self)
  Event.RegisterEventWithContext(ModuleId.GOD_WEAPON, gmodule.notifyId.GodWeapon.JEWEL_REDNOTICE_CHANGE, UIGodWeaponBasic.OnRedNoticeChg, self)
  Event.RegisterEventWithContext(ModuleId.GOD_WEAPON, gmodule.notifyId.GodWeapon.WS_IMPROVE_ITEM_CHG, UIGodWeaponBasic.OnRedNoticeChg, self)
  Event.RegisterEventWithContext(ModuleId.ITEM, gmodule.notifyId.item.Item_OnBagInfoSynchronized, UIGodWeaponBasic.OnRedNoticeChg, self)
  Event.RegisterEventWithContext(ModuleId.ITEM, gmodule.notifyId.item.Item_GodWeapon_Bag_Change, UIGodWeaponBasic.OnRedNoticeChg, self)
  self:InitUI()
end
def.method().InitUI = function(self)
  self._uiObjs = {}
  self._uiObjs.Group_EquipList = self.m_panel:FindDirect("Img_Bg/Group_EquipList")
  self._uiObjs.equipScrollView = self._uiObjs.Group_EquipList:FindDirect("Group_EquipList/Group_List/Scroll View_EquipList"):GetComponent("UIScrollView")
  self._uiObjs.Grid_EquipList = self._uiObjs.Group_EquipList:FindDirect("Group_EquipList/Group_List/Scroll View_EquipList/Grid_EquipList")
  self._uiObjs.equipUIList = self._uiObjs.Grid_EquipList:GetComponent("UIList")
  self._uiObjs.Group_EquipList:FindDirect("Group_LongJingList"):SetActive(false)
  self._uiObjs.Group_EquipList:FindDirect("Group_EquipList"):SetActive(true)
  if self._nodes == nil then
    self._nodes = {}
  end
  if self._tabs == nil then
    self._tabs = {}
  end
  if self._tab2NodeIdMap == nil then
    self._tab2NodeIdMap = {}
  end
  if self._reddotCheckFuncMap == nil then
    self._reddotCheckFuncMap = {}
  end
  local nodeId = UIGodWeaponBasic.NodeId.BreakOut
  local nodeRoot = self.m_panel:FindDirect("Img_Bg/Group_TP")
  self._tabs[nodeId] = self.m_panel:FindDirect("Img_Bg/Tap_TP")
  self._tab2NodeIdMap[self._tabs[nodeId].name] = nodeId
  self._reddotCheckFuncMap[nodeId] = require("Main.GodWeapon.BreakOutMgr").CheckEquipBreakOutReddot
  self._nodes[nodeId] = BreakOutNode.Instance()
  self._nodes[nodeId]:Init(self, nodeRoot)
  nodeId = UIGodWeaponBasic.NodeId.Jewel
  nodeRoot = self.m_panel:FindDirect("Img_Bg/Group_BS")
  self._tabs[nodeId] = self.m_panel:FindDirect("Img_Bg/Tap_BS")
  self._reddotCheckFuncMap[nodeId] = require("Main.GodWeapon.JewelMgr").CheckEquipJewelReddot
  self._tab2NodeIdMap[self._tabs[nodeId].name] = nodeId
  self._nodes[nodeId] = JewelNode.Instance()
  self._nodes[nodeId]:Init(self, nodeRoot)
  nodeId = UIGodWeaponBasic.NodeId.Decoration
  nodeRoot = self.m_panel:FindDirect("Img_Bg/Group_WS")
  self._tabs[nodeId] = self.m_panel:FindDirect("Img_Bg/Tap_WS")
  self._tab2NodeIdMap[self._tabs[nodeId].name] = nodeId
  self._nodes[nodeId] = DecorationNode.Instance()
  self._nodes[nodeId]:Init(self, nodeRoot)
end
def.override("boolean").OnShow = function(self, bShow)
  self:HandleEventListeners(bShow)
  if bShow then
    if self._curNodeId <= 0 then
      self._curNodeId = UIGodWeaponBasic.NodeId.BreakOut
    end
    self:UpdateRedNotice()
    self:CheckFeatureOpen()
    if self._curNodeId == UIGodWeaponBasic.NodeId.Jewel then
      self._nodes[UIGodWeaponBasic.NodeId.Jewel]:UpdateUI()
    else
      self:SwitchTo(self._curNodeId)
    end
  else
  end
end
def.method().UpdateRedNotice = function(self)
  local JewelMgr = require("Main.GodWeapon.JewelMgr")
  local bShowRedDot = JewelMgr.IsShowRedDot()
  local imgRedDot = self.m_panel:FindDirect("Img_Bg/Tap_BS/Img_Red")
  imgRedDot:SetActive(bShowRedDot)
  local DecorationMgr = require("Main.GodWeapon.DecorationMgr")
  if DecorationMgr.IsFeatureOpen() then
    bShowRedDot = DecorationMgr.IsShowRedDot()
    imgRedDot = self.m_panel:FindDirect("Img_Bg/Tap_WS/Img_Red")
    imgRedDot:SetActive(bShowRedDot)
  end
end
local EC = require("Types.Vector")
def.method().CheckFeatureOpen = function(self)
  local JewelMgr = require("Main.GodWeapon.JewelMgr")
  local DecorationMgr = require("Main.GodWeapon.DecorationMgr")
  local bJewelOpen = JewelMgr.IsFeatureOpen()
  local bWSopen = DecorationMgr.IsFeatureOpen()
  local ctrlTabJewel = self.m_panel:FindDirect("Img_Bg/Tap_BS")
  local ctrlTabWS = self.m_panel:FindDirect("Img_Bg/Tap_WS")
  ctrlTabJewel:SetActive(bJewelOpen)
  ctrlTabWS:SetActive(bWSopen)
  if bJewelOpen then
    ctrlTabWS.transform.localPosition = EC.Vector3.new(422, -74, 0)
  else
    ctrlTabWS.transform.localPosition = ctrlTabJewel.transform.localPosition
  end
end
def.method("number").SwitchTo = function(self, nodeId)
  if nil == self._tabs[nodeId] then
    warn("[ERROR][UIGodWeaponBasic:SwitchTo] nodeId invalid:", nodeId)
    return
  end
  warn("[UIGodWeaponBasic:SwitchTo] Switch To nodeId:", nodeId)
  GUIUtils.SetActive(self._uiObjs.Group_EquipList, false)
  self._curNodeId = nodeId
  for k, node in pairs(self._nodes) do
    local tabNode = self._tabs[nodeId]
    tabNode:GetComponent("UIToggle").value = true
    if k == nodeId then
      local tabNode = self._tabs[self._curNodeId]
      tabNode:GetComponent("UIToggle").value = true
      node:ShowWithParams(self._params)
      self._params = nil
    else
      local tabNode = self._tabs[k]
      tabNode:GetComponent("UIToggle").value = false
      node:Hide()
    end
  end
end
def.override().OnDestroy = function(self)
  Event.UnregisterEvent(ModuleId.GOD_WEAPON, gmodule.notifyId.GodWeapon.GOD_WEAPON_FEATURE_CHANGE, UIGodWeaponBasic.OnFeatureChange)
  Event.UnregisterEvent(ModuleId.GOD_WEAPON, gmodule.notifyId.GodWeapon.JEWEL_REDNOTICE_CHANGE, UIGodWeaponBasic.OnRedNoticeChg)
  Event.UnregisterEvent(ModuleId.ITEM, gmodule.notifyId.item.Item_OnBagInfoSynchronized, UIGodWeaponBasic.OnRedNoticeChg)
  Event.UnregisterEvent(ModuleId.ITEM, gmodule.notifyId.item.Item_GodWeapon_Bag_Change, UIGodWeaponBasic.OnRedNoticeChg)
  local curNode = self._nodes[self._curNodeId]
  if curNode then
    curNode:Hide()
  end
  self:ClearEquipList()
  self._curNodeId = 0
  self._nodes = nil
  self._tabs = nil
  self._params = nil
  self._equipList = nil
  self._uiObjs = nil
end
def.method("table").ShowEquipList = function(self, equipList)
  GUIUtils.SetActive(self._uiObjs.Group_EquipList, true)
  self:ClearEquipList()
  self._equipList = equipList
  if self._equipList and #self._equipList > 0 then
    self._uiObjs.equipUIList.itemCount = #self._equipList
    self._uiObjs.equipUIList:Resize()
    self._uiObjs.equipUIList:Reposition()
    for index, equipInfo in ipairs(self._equipList) do
      self:_SetListEquipInfo(index, equipInfo)
    end
  end
  self:UpdateEquipListReddots()
end
def.method("number", "table")._SetListEquipInfo = function(self, index, equipInfo)
  if nil == equipInfo then
    warn("[ERROR][UIGodWeaponBasic:_SetListEquipInfo] equipInfo nil at index:", index)
    return
  end
  local listItem = self._uiObjs.Grid_EquipList:FindDirect("Img_BgEquip_" .. index)
  if nil == listItem then
    warn("[ERROR][UIGodWeaponBasic:_SetListEquipInfo] listItem nil at index:", index)
    return
  end
  local Icon_BgEquip = listItem:FindDirect("Icon_BgEquip_" .. index)
  GUIUtils.SetSprite(Icon_BgEquip, ItemUtils.GetItemFrame(equipInfo, nil))
  local Icon_Equip = listItem:FindDirect("Icon_Equip_" .. index)
  local uiTexture = Icon_Equip:GetComponent("UITexture")
  GUIUtils.FillIcon(uiTexture, equipInfo.icon)
  local Label_EquipName = listItem:FindDirect("Label_EquipName_" .. index)
  GUIUtils.SetText(Label_EquipName, ItemUtils.GetItemName(equipInfo, nil))
  local Label_EquipLv00 = listItem:FindDirect("Label_EquipLv00_" .. index)
  local Label_EquipLv01 = listItem:FindDirect("Label_EquipLv01_" .. index)
  local godWeaponStage = equipInfo.extraMap[ItemXStoreType.SUPER_EQUIPMENT_STAGE]
  if godWeaponStage and godWeaponStage > 0 then
    GUIUtils.SetText(Label_EquipLv00, string.format(textRes.GodWeapon.BreakOut.GODWEAPON_STAGE, godWeaponStage))
    local godWeaponLevel = equipInfo.extraMap[ItemXStoreType.SUPER_EQUIPMENT_LEVEL]
    if godWeaponLevel and godWeaponLevel > 0 then
      GUIUtils.SetText(Label_EquipLv01, string.format(textRes.GodWeapon.BreakOut.GODWEAPON_LEVEL, godWeaponLevel))
    else
      GUIUtils.SetText(Label_EquipLv01, string.format(textRes.GodWeapon.BreakOut.GODWEAPON_LEVEL, 0))
    end
  else
    GUIUtils.SetText(Label_EquipLv00, textRes.GodWeapon.BreakOut.WEAPON_NOT_BREAK_OUT)
    GUIUtils.SetActive(Label_EquipLv01, false)
  end
  local Label_EquipType = listItem:FindDirect("Label_EquipType_" .. index)
  GUIUtils.SetText(Label_EquipType, equipInfo.typeName)
  local Img_EquipMark = listItem:FindDirect("Img_EquipMark_" .. index)
  GUIUtils.SetActive(Img_EquipMark, equipInfo.bEquiped)
  local Label_Num = listItem:FindDirect("Label_Num_" .. index)
  local strenStr = equipInfo.strenLevel and "+" .. equipInfo.strenLevel or ""
  GUIUtils.SetText(Label_Num, strenStr)
end
def.method("number").SelectEquipByIdx = function(self, index)
  local listItem = self._uiObjs.Grid_EquipList:FindDirect("Img_BgEquip_" .. index)
  if listItem then
    GUIUtils.Toggle(listItem, true)
    local curNode = self._nodes[self._curNodeId]
    if curNode then
      local equipInfo = self._equipList and self._equipList[index] or nil
      curNode:OnEquipSelected(index, listItem, equipInfo)
    end
  else
    warn("[ERROR][UIGodWeaponBasic:SelectEquipListToggle] listItem nil at index:", index)
  end
end
def.method("userdata").SelectEquipByUuid = function(self, uuid)
  if nil == uuid or nil == self._equipList or #self._equipList < 1 then
    return
  end
  local equipIdx = -1
  for idx, equipInfo in ipairs(self._equipList) do
    if Int64.eq(uuid, equipInfo.uuid) then
      equipIdx = idx
      break
    end
  end
  if equipIdx > 0 then
    self:SelectEquipByIdx(equipIdx)
  end
end
def.method("string", "userdata")._OnEquipClicked = function(self, id, clickObj)
  local togglePrefix = "Img_BgEquip_"
  local index = tonumber(string.sub(id, string.len(togglePrefix) + 1))
  local curNode = self._nodes[self._curNodeId]
  if curNode then
    local equipInfo = self._equipList and self._equipList[index] or nil
    curNode:OnEquipSelected(index, clickObj, equipInfo)
  end
end
def.method().ClearEquipList = function(self)
  self._uiObjs.equipUIList.itemCount = 0
  self._uiObjs.equipUIList:Resize()
  self._uiObjs.equipUIList:Reposition()
end
def.method().UpdateEquipListReddots = function(self)
  if self._equipList and #self._equipList > 0 then
    for index, equipInfo in ipairs(self._equipList) do
      local listItem = self._uiObjs.Grid_EquipList:FindDirect("Img_BgEquip_" .. index)
      local Img_Red = listItem and listItem:FindDirect("Img_Red_" .. index) or nil
      local checkReddotFunc = self._reddotCheckFuncMap[self._curNodeId]
      if Img_Red and checkReddotFunc then
        GUIUtils.SetActive(Img_Red, checkReddotFunc(equipInfo))
      end
    end
  end
end
def.method("userdata").onClickObj = function(self, clickObj)
  local id = clickObj.name
  if id == "Btn_Close" then
    self:DestroyPanel()
  elseif string.find(id, "Tap_") then
    self:OnTabClicked(id)
  elseif string.find(id, "Img_BgEquip_") then
    self:_OnEquipClicked(id, clickObj)
  else
    self._nodes[self._curNodeId]:onClickObj(clickObj)
  end
end
def.method("string").onDragStart = function(self, id)
  if id == "Model" then
    self.isDrag = true
  end
end
def.method("string").onDragEnd = function(self, id)
  self.isDrag = false
end
def.method("string", "number", "number").onDrag = function(self, id, dx, dy)
  if self.isDrag == true then
    local curNode = self._nodes[self._curNodeId]
    if curNode.onDrag ~= nil then
      curNode:onDrag(id, dx, dy)
    end
  end
end
def.method("string").OnTabClicked = function(self, id)
  local nodeId = id and self._tab2NodeIdMap[id] or 0
  if nodeId == self._curNodeId then
    return
  end
  self:SwitchTo(nodeId)
end
def.method("boolean").HandleEventListeners = function(self, isRigister)
  local eventFunc
  if isRigister then
    eventFunc = Event.RegisterEvent
  else
    eventFunc = Event.UnregisterEvent
  end
  if eventFunc then
  end
end
def.method("table").OnFeatureChange = function(self, p)
  self:CheckFeatureOpen()
end
def.method("table").OnRedNoticeChg = function(self, p)
  self:UpdateRedNotice()
end
return UIGodWeaponBasic.Commit()
