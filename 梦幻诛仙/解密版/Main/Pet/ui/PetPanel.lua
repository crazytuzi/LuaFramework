local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local PetPanel = Lplus.Extend(ECPanelBase, "PetPanel")
local def = PetPanel.define
local PetData = Lplus.ForwardDeclare("PetData")
local PetPanelBasicNode = require("Main.Pet.ui.PetPanelBasicNode")
local PetPanelFanShengNode = require("Main.Pet.ui.PetPanelFanShengNode")
local PetPanelHuaShengNode = require("Main.Pet.ui.PetPanelHuaShengNode")
local PetPanelSoulNode = require("Main.Pet.soul.ui.PetPanelSoulNode")
local PetPanelMarkNode = require("Main.Pet.PetMark.ui.PetPanelMarkNode")
local PetMgr = require("Main.Pet.mgr.PetMgr")
local PetMgrInstance = PetMgr.Instance()
local PetUtility = require("Main.Pet.PetUtility")
local EC = require("Types.Vector3")
local Vector3 = EC.Vector3
local ECModel = require("Model.ECModel")
local GUIUtils = require("GUI.GUIUtils")
local PetModule = require("Main.Pet.PetModule")
local ItemModule = require("Main.Item.ItemModule")
local ItemUtils = require("Main.Item.ItemUtils")
local ItemTipsMgr = require("Main.Item.ItemTipsMgr")
local ItemType = require("consts.mzm.gsp.item.confbean.ItemType")
local CommonConfirmDlg = require("GUI.CommonConfirmDlg")
local PropertyType = require("consts.mzm.gsp.common.confbean.PropertyType")
local NodeId = require("Main.Pet.ui.PetPanelNodeEnum")
local SubNode = NodeId.SubNode
def.const("table").NodeId = NodeId
def.field("number").SubNodeId = 1
local NodeDefines = {
  [NodeId.BasicNode] = {
    tabName = "Tap_CW",
    rootName = "CW",
    node = PetPanelBasicNode
  },
  [NodeId.FanShengNode] = {
    tabName = "Tap_FS",
    rootName = "FS",
    node = PetPanelFanShengNode
  },
  [NodeId.HuaShengNode] = {
    tabName = "Tap_HS",
    rootName = "HS",
    node = PetPanelHuaShengNode
  },
  [NodeId.Soul] = {
    tabName = "Tap_LH",
    rootName = "LH",
    node = PetPanelSoulNode
  },
  [NodeId.PetMark] = {
    tabName = "Tap_YJ",
    rootName = "YJ",
    node = PetPanelMarkNode
  }
}
def.const("table").PropNameCfgKeyList = {
  PropertyType.PHYATK,
  PropertyType.MAGATK,
  PropertyType.PHYDEF,
  PropertyType.MAGDEF,
  PropertyType.SPEED
}
def.const("table").PropNameCfgKeyList2 = {
  PropertyType.MAX_HP,
  PropertyType.PHYATK,
  PropertyType.MAGATK,
  PropertyType.PHYDEF,
  PropertyType.MAGDEF,
  PropertyType.SPEED
}
def.const("number").PET_LIST_ITEM_MIN_HEIGHT = 92
def.const("number").PET_LIST_ITEM_OP_GROUP_HEIGHT = 100
def.const("number").PET_LIST_ITEM_OP_GROUP_OFFSET_Y = 100
def.field("table").nodes = nil
def.field("number").curNode = 1
def.field("number").nextNode = 1
def.field("userdata").selectedPetId = nil
def.field("number").selectedPetIndex = 0
def.field("table").petIdList = nil
def.field("table").petItemBagKeyList = nil
def.field("number").petItemBagItemAmount = 0
def.field("number").selectedPetItemIndex = 0
def.field("number").addSkillIconIndex = 0
def.field("table")._tipIns = nil
def.field("userdata").ui_Img_Bg0 = nil
def.field("userdata").ui_PetList = nil
def.field("userdata").ui_List_PetList = nil
def.field("table").tabToggles = nil
local instance
def.static("=>", PetPanel).Instance = function()
  if instance == nil then
    instance = PetPanel()
    instance:Init()
  end
  return instance
end
def.method().Init = function(self)
  self.curNode = PetPanel.NodeId.BasicNode
  self.nextNode = self.curNode
  self.m_TrigGC = true
  self.m_HideOnDestroy = true
end
def.method().ShowPanel = function(self)
  if self:IsShow() then
    self:SwitchToNode(self.nextNode)
    return
  end
  if self.m_panel and not self.m_panel.isnil then
    return
  end
  self:CreatePanel(RESPATH.PREFAB_PET_PANEL_RES, 1)
  self:SetModal(true)
end
def.method("number").ShowPanelEx = function(self, nodeId)
  self:ShowPanelExWithSubNode(nodeId, SubNode.None)
end
def.method("number", "number").ShowPanelExWithSubNode = function(self, nodeId, subNodeId)
  if nodeId == NodeId.SkillNode then
    nodeId = NodeId.BasicNode
    self.SubNodeId = SubNode.Skill
  else
    self.SubNodeId = subNodeId
  end
  self:SetNextNode(nodeId)
  self:ShowPanel()
end
def.method("userdata").ShowPanelWithPetId = function(self, petId)
  self.selectedPetId = petId
  self:ShowPanel()
end
def.method("number").SetNextNode = function(self, nodeId)
  self.nextNode = nodeId
end
def.method().HidePanel = function(self)
  self:DestroyPanel()
end
def.override().OnCreate = function(self)
  self:InitUI()
  self.nodes = {}
  local ui_Img_Bg0 = self.m_panel:FindDirect("Img_Bg0")
  self.ui_Img_Bg0 = ui_Img_Bg0
  for nodeId, v in pairs(NodeDefines) do
    local nodeRoot = ui_Img_Bg0:FindDirect(v.rootName)
    if nodeRoot then
      nodeRoot:SetActive(false)
    end
    self.nodes[nodeId] = v.node.Instance()
    self.nodes[nodeId]:Init(self, nodeRoot)
    self.nodes[nodeId].nodeId = nodeId
  end
  self:UpdateTabBadges()
  Event.RegisterEvent(ModuleId.PET, gmodule.notifyId.Pet.PET_LIST_UPDATE, PetPanel.OnPetListUpdate)
  Event.RegisterEvent(ModuleId.PET, gmodule.notifyId.Pet.PET_INFO_UPDATE, PetPanel.OnPetInfoUpdate)
  Event.RegisterEvent(ModuleId.PET, gmodule.notifyId.Pet.PET_ADDED, PetPanel.OnPetAdded)
  Event.RegisterEvent(ModuleId.PET, gmodule.notifyId.Pet.PET_DELETED, PetPanel.OnPetDeleted)
  Event.RegisterEvent(ModuleId.PET, gmodule.notifyId.Pet.PET_STORE_POS_UPDATE, PetPanel.OnPetStorePosUpdate)
  Event.RegisterEvent(ModuleId.ITEM, gmodule.notifyId.item.Item_OnBagInfoSynchronized, PetPanel.OnBagInfoSynchronized)
  Event.RegisterEvent(ModuleId.PET, gmodule.notifyId.Pet.PET_USE_ITEM, PetPanel.OnPetItemBagItemUsed)
  Event.RegisterEvent(ModuleId.PET, gmodule.notifyId.Pet.PET_USE_EQUIPMENT, PetPanel.OnPetItemBagItemUsed)
  Event.RegisterEvent(ModuleId.PET, gmodule.notifyId.Pet.PET_FAN_SHENG_RESPONSE, PetPanel.OnPetFanShengResponse)
  Event.RegisterEvent(ModuleId.HERO, gmodule.notifyId.Hero.HERO_LEVEL_UP, PetPanel.OnHeroLevelUp)
  Event.RegisterEvent(ModuleId.PET, gmodule.notifyId.Pet.PET_BAG_CAPACITY_CHANGE, PetPanel.OnPetBagCapacityChange)
  Event.RegisterEvent(ModuleId.PET, gmodule.notifyId.Pet.PET_NOTIFY_COUNT_UPDATE, PetPanel.OnPetNotifyCountUpdate)
  Event.RegisterEvent(ModuleId.FEATURE, gmodule.notifyId.Feature.FeatureOpenChange, PetPanel.OnFunctionOpenChange)
  Event.RegisterEvent(ModuleId.PETTEAM, gmodule.notifyId.PetTeam.PETTEAM_REDDOT_CHANGE, PetPanel.OnPetTeamReddotChange)
end
def.override("boolean").OnShow = function(self, isShow)
  if not isShow then
    return
  end
  self:UpdateSoulTab()
  self:UpdatePetTeam()
  self:UpdateMarkTab()
  self:SwitchToNode(self.nextNode)
  if self.curNode == NodeId.BasicNode then
    if self.SubNodeId == SubNode.Attribute then
      self.ui_Img_Bg0:FindDirect("CW/Tap_SX"):GetComponent("UIToggle"):set_value(true)
    elseif self.SubNodeId == SubNode.Skill then
      self.ui_Img_Bg0:FindDirect("CW/Tap_JN"):GetComponent("UIToggle"):set_value(true)
    elseif self.SubNodeId == SubNode.Equip then
      self.ui_Img_Bg0:FindDirect("CW/Tap_Equip"):GetComponent("UIToggle"):set_value(true)
    else
      self.ui_Img_Bg0:FindDirect("CW/Tap_SX"):GetComponent("UIToggle"):set_value(true)
    end
  end
end
def.method().UpdatePetTeam = function(self)
  local Vector = require("Types.Vector")
  local PetTeamModule = require("Main.PetTeam.PetTeamModule")
  local bOpen = PetTeamModule.Instance():IsOpen(false)
  local BtnPetTeam = self.ui_Img_Bg0:FindDirect("PetList/Btn_Dou")
  local Btn_Tj = self.ui_Img_Bg0:FindDirect("PetList/Btn_Tj")
  if bOpen then
    GUIUtils.SetActive(BtnPetTeam, true)
    Btn_Tj:set_localPosition(Vector.Vector3.new(-1.5, -225, 0))
    local Img_New = BtnPetTeam:FindDirect("Img_New")
    local bReddot = PetTeamModule.Instance():NeedReddotWithFrag()
    GUIUtils.SetActive(Img_New, bReddot)
  else
    GUIUtils.SetActive(BtnPetTeam, false)
    Btn_Tj:set_localPosition(Vector.Vector3.new(60, -225, 0))
  end
end
def.method().UpdateSoulTab = function(self)
  local PetSoulMgr = require("Main.Pet.soul.PetSoulMgr")
  local Soul_Tab = self.m_panel:FindDirect("Img_Bg0/Tap_LH")
  if PetSoulMgr.Instance():IsOpen(false) then
    GUIUtils.SetActive(Soul_Tab, true)
  else
    GUIUtils.SetActive(Soul_Tab, false)
    if self.curNode == NodeId.Soul then
      self:SwitchToNode(NodeId.BasicNode)
    end
  end
end
def.method().UpdateMarkTab = function(self)
  local PetMarkMgr = require("Main.Pet.PetMark.PetMarkMgr")
  local Mark_Tab = self.m_panel:FindDirect("Img_Bg0/Tap_YJ")
  if PetMarkMgr.Instance():IsOpen() then
    GUIUtils.SetActive(Mark_Tab, true)
  else
    GUIUtils.SetActive(Mark_Tab, false)
    if self.curNode == NodeId.PetMark then
      self:SwitchToNode(NodeId.BasicNode)
    end
  end
end
def.override().OnDestroy = function(self)
  Event.UnregisterEvent(ModuleId.PET, gmodule.notifyId.Pet.PET_LIST_UPDATE, PetPanel.OnPetListUpdate)
  Event.UnregisterEvent(ModuleId.PET, gmodule.notifyId.Pet.PET_INFO_UPDATE, PetPanel.OnPetInfoUpdate)
  Event.UnregisterEvent(ModuleId.PET, gmodule.notifyId.Pet.PET_ADDED, PetPanel.OnPetAdded)
  Event.UnregisterEvent(ModuleId.PET, gmodule.notifyId.Pet.PET_DELETED, PetPanel.OnPetDeleted)
  Event.UnregisterEvent(ModuleId.PET, gmodule.notifyId.Pet.PET_STORE_POS_UPDATE, PetPanel.OnPetStorePosUpdate)
  Event.UnregisterEvent(ModuleId.ITEM, gmodule.notifyId.item.Item_OnBagInfoSynchronized, PetPanel.OnBagInfoSynchronized)
  Event.UnregisterEvent(ModuleId.PET, gmodule.notifyId.Pet.PET_USE_ITEM, PetPanel.OnPetItemBagItemUsed)
  Event.UnregisterEvent(ModuleId.PET, gmodule.notifyId.Pet.PET_USE_EQUIPMENT, PetPanel.OnPetItemBagItemUsed)
  Event.UnregisterEvent(ModuleId.PET, gmodule.notifyId.Pet.PET_FAN_SHENG_RESPONSE, PetPanel.OnPetFanShengResponse)
  Event.UnregisterEvent(ModuleId.HERO, gmodule.notifyId.Hero.HERO_LEVEL_UP, PetPanel.OnHeroLevelUp)
  Event.UnregisterEvent(ModuleId.PET, gmodule.notifyId.Pet.PET_BAG_CAPACITY_CHANGE, PetPanel.OnPetBagCapacityChange)
  Event.UnregisterEvent(ModuleId.PET, gmodule.notifyId.Pet.PET_NOTIFY_COUNT_UPDATE, PetPanel.OnPetNotifyCountUpdate)
  Event.UnregisterEvent(ModuleId.FEATURE, gmodule.notifyId.Feature.FeatureOpenChange, PetPanel.OnFunctionOpenChange)
  Event.UnregisterEvent(ModuleId.PETTEAM, gmodule.notifyId.PetTeam.PETTEAM_REDDOT_CHANGE, PetPanel.OnPetTeamReddotChange)
  self.nodes[self.curNode]:Hide()
  self.ui_PetList = nil
  self.ui_List_PetList = nil
  self.ui_Img_Bg0 = nil
  self.curNode = PetPanel.NodeId.BasicNode
  self.nextNode = self.curNode
end
def.method("string").onClick = function(self, id)
  print(string.format("%s click event: id = %s", tostring(self), id))
  if id == "Btn_Close" then
    self:HidePanel()
  elseif id == "Modal" then
    self:DestroyPanel()
  elseif id == "Btn_Storage" then
    self:OnStorageButtonClick()
  elseif id == "Btn_Tj" then
    self:OnTuJianButtonClick()
  elseif string.sub(id, 1, 12) == "Img_CW_Item_" then
    self:OnItemClick(id)
  elseif id == "Btn_AddPetNum" then
    self:OnExpandPetBagNumButtonClick()
  elseif string.sub(id, 1, 4) == "Pet_" then
    local index = tonumber(string.sub(id, 5, -1))
    self:OnPetListItemClick(index)
  elseif id == "Tap_CW" then
    self:SwitchToNode(PetPanel.NodeId.BasicNode)
  elseif id == "Tap_FS" then
    self:SwitchToNode(PetPanel.NodeId.FanShengNode)
  elseif id == "Tap_HS" then
    self:SwitchToNode(PetPanel.NodeId.HuaShengNode)
  elseif id == "Tap_JN" then
    self.SubNodeId = SubNode.Skill
  elseif id == "Tap_LH" then
    self:SwitchToNode(PetPanel.NodeId.Soul)
  elseif id == "Tap_YJ" then
    self:SwitchToNode(PetPanel.NodeId.PetMark)
  elseif id == "Btn_Dou" then
    self:OnBtn_DouClick()
  else
    self.nodes[self.curNode]:onClick(id)
  end
end
def.method("string").onDoubleClick = function(self, id)
  if string.sub(id, 1, 4) == "Pet_" then
    local index = tonumber(string.sub(id, 5, -1))
    self:OnPetListItemDoubleClick(index)
  else
    self.nodes[self.curNode]:onDoubleClick(id)
  end
end
def.method("string", "string").onTweenerFinish = function(self, id, tweenId)
end
def.method("string", "boolean").onPress = function(self, id, state)
  self.nodes[self.curNode]:onPress(id, state)
end
def.method("string", "boolean").onToggle = function(self, id, isActive)
  self.nodes[self.curNode]:onToggle(id, isActive)
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
def.static("table", "table").OnPetListUpdate = function()
  local self = instance
  if not self:IsShow() then
    return
  end
  self:UpdateUI()
end
def.static("table", "table").OnPetInfoUpdate = function(params)
  local petId = params[1]
  local self = instance
  if not self:IsShow() then
    return
  end
  if self.selectedPetId ~= petId then
    self:UpdatePetListItemById(petId)
    return
  end
  self:UpdatePetInfo(petId)
end
def.static("table", "table").OnPetAdded = function(params)
  local petId = params[1]
  local self = instance
  if not self:IsShow() then
    return
  end
  self.nodes[self.curNode]:OnPetAdded(petId)
end
def.static("table", "table").OnPetDeleted = function(params)
  local petId = params[1]
  local self = instance
  if not self:IsShow() then
    return
  end
  self.nodes[self.curNode]:OnPetDeleted(petId)
end
def.static("table", "table").OnPetStorePosUpdate = function()
  local self = instance
  if not self:IsShow() then
    return
  end
  self:UpdateUI()
end
def.static("table", "table").OnBagInfoSynchronized = function()
  local self = instance
  self.nodes[self.curNode]:OnBagInfoSynchronized()
  instance:UpdatePetTeam()
end
def.static("table", "table").OnPetFanShengResponse = function(params)
  local self = instance
  local oldPetId = params[1]
  local newPetId = params[2]
  local isFanShengPetSelected = false
  if self.selectedPetId == oldPetId then
    self.selectedPetId = newPetId
    self.petIdList[self.selectedPetIndex] = newPetId
    isFanShengPetSelected = true
  else
    for i, petId in ipairs(self.petIdList) do
      if petId == oldPetId then
        self.petIdList[i] = newPetId
      end
    end
  end
  if isFanShengPetSelected then
    self:UpdateUI()
  end
end
def.static("table", "table").OnHeroLevelUp = function(params)
  instance:UpdateTuJianNotice()
  instance:UpdateSoulTab()
  instance:UpdateMarkTab()
end
def.method().UpdateUI = function(self)
  self.nodes[self.curNode]:UpdateUI()
end
def.method("userdata").UpdatePetInfo = function(self, petId)
  self.nodes[self.curNode]:UpdatePetInfo(petId)
end
def.method("number").SwitchToNode = function(self, node)
  self.nextNode = node
  if node ~= PetPanel.NodeId.None and self.curNode ~= node then
    self.nodes[self.curNode]:Hide()
  end
  self.curNode = node
  if NodeDefines[self.curNode] then
    local tabName = NodeDefines[self.curNode].tabName
    self.ui_Img_Bg0:FindDirect(tabName):GetComponent("UIToggle"):set_value(true)
  end
  self.nodes[self.curNode]:Show()
end
def.method().InitUI = function(self)
  self.ui_PetList = self.m_panel:FindDirect("Img_Bg0/PetList")
  self.ui_List_PetList = self.ui_PetList:FindDirect("Img_PetList/Scroll View_PetList/List_PetList")
  self.ui_List_PetList:FindDirect("Img_BgPet01/Pet01"):GetComponent("UIToggle"):set_startsActive(false)
  self.m_panel:FindDirect("Img_Bg0/Tap_CW"):GetComponent("UIToggle"):set_startsActive(false)
end
def.method("table", "number").SetPetList = function(self, petList, petNum)
  local list_petList = self.ui_List_PetList:GetComponent("UIList")
  local amount = self:GetMaxPetListItemNumber()
  list_petList:set_itemCount(amount)
  list_petList:Resize()
  local sortedPetList = {}
  for k, v in pairs(petList) do
    table.insert(sortedPetList, v)
  end
  table.sort(sortedPetList, PetMgr.PetSortFunction)
  local items = list_petList.children
  self.petIdList = {}
  for index = 1, amount do
    local listItem = items[index]
    local petListItem = listItem:FindDirect("Pet01")
    if petListItem then
      petListItem:set_name("Pet_" .. index)
    else
      petListItem = listItem:FindDirect("Pet_" .. index)
    end
    petListItem:GetComponent("UIToggle"):set_startsActive(false)
    if index <= #sortedPetList then
      local pet = sortedPetList[index]
      self.petIdList[index] = pet.id
      self:SetTargetListItemInfo(index, petListItem, pet)
    elseif index <= PetMgrInstance.bagSize then
      self:SetEmptyListItem(index, petListItem)
    else
      self:SetExpandListItem(index, petListItem)
    end
  end
  self:SetPetBagCapacityInfo(petNum, PetMgrInstance.bagSize)
  list_petList:Resize()
  list_petList:Reposition()
  self:TouchGameObject(self.m_panel, self.m_parent)
end
def.method("=>", "number").GetMaxPetListItemNumber = function()
  local num = PetMgrInstance.bagSize
  if PetMgrInstance:CanExpandPetBag() then
    num = num + 1
  end
  return num
end
def.method("number", "table").SetListItemInfo = function(self, index, pet)
  local petListItem = self.ui_List_PetList:FindDirect(string.format("item_%d/Pet_%d", index, index))
  self:SetTargetListItemInfo(index, petListItem, pet)
end
def.method("number", "userdata", "table").SetTargetListItemInfo = function(self, index, petListItem, pet)
  petListItem:FindDirect("Label_PetName01"):GetComponent("UILabel"):set_text(pet.name)
  petListItem:FindDirect("Label_PetLv01"):GetComponent("UILabel"):set_text(string.format(textRes.Pet[1], pet.level))
  local Img_Zhuan = petListItem:FindDirect("Img_Zhuan")
  local Img_Bang = petListItem:FindDirect("Img_Bang")
  local Img_Xiyou = petListItem:FindDirect("Img_Xiyou")
  Img_Zhuan:SetActive(false)
  Img_Bang:SetActive(false)
  GUIUtils.SetActive(Img_Xiyou, false)
  if pet:IsSpecial() then
    Img_Zhuan:SetActive(true)
  elseif pet:IsBinded() then
    Img_Bang:SetActive(true)
  elseif pet:IsRarity() then
    GUIUtils.SetActive(Img_Xiyou, true)
  end
  local Img_BgPetItem = petListItem:FindDirect("Img_BgPetItem")
  Img_BgPetItem:SetActive(true)
  local Img_PetMark01 = Img_BgPetItem:FindDirect("Img_PetMark01")
  if pet.isFighting then
    Img_PetMark01:SetActive(true)
  else
    Img_PetMark01:SetActive(false)
  end
  local iconId = pet:GetHeadIconId()
  local uiTexture = Img_BgPetItem:FindDirect("Icon_Pet01"):GetComponent("UITexture")
  GUIUtils.FillIcon(uiTexture, iconId)
  local spriteName = pet:GetHeadIconBGSpriteName()
  GUIUtils.SetSprite(Img_BgPetItem, spriteName)
  local notifyBadge = false
  if pet:NeedAssignProp() then
    notifyBadge = true
  end
  GUIUtils.SetActive(petListItem:FindDirect("Img_Red"), notifyBadge)
  local Label_PowerLv = petListItem:FindDirect("Label_PowerLv")
  local yaolicfg = pet:GetPetYaoLiCfg()
  local encodeChar = yaolicfg.encodeChar
  GUIUtils.SetText(Label_PowerLv, encodeChar)
  petListItem:FindDirect("Group_Add"):SetActive(false)
  petListItem:FindDirect("Group_Empty"):SetActive(false)
end
def.method("number", "userdata").SetEmptyListItem = function(self, index, petListItem)
  petListItem:FindDirect("Label_PetName01"):GetComponent("UILabel"):set_text("")
  petListItem:FindDirect("Label_PetLv01"):GetComponent("UILabel"):set_text("")
  local Img_Zhuan = petListItem:FindDirect("Img_Zhuan")
  local Img_Bang = petListItem:FindDirect("Img_Bang")
  local Img_Xiyou = petListItem:FindDirect("Img_Xiyou")
  Img_Zhuan:SetActive(false)
  Img_Bang:SetActive(false)
  GUIUtils.SetActive(Img_Xiyou, false)
  GUIUtils.SetText(petListItem:FindDirect("Label_PowerLv"), "")
  local Img_BgPetItem = petListItem:FindDirect("Img_BgPetItem")
  Img_BgPetItem:SetActive(false)
  petListItem:FindDirect("Group_Add"):SetActive(false)
  petListItem:FindDirect("Group_Empty"):SetActive(true)
  GUIUtils.SetActive(petListItem:FindDirect("Img_Red"), false)
end
def.method("number", "userdata").SetExpandListItem = function(self, index, petListItem)
  petListItem:FindDirect("Label_PetName01"):GetComponent("UILabel"):set_text("")
  petListItem:FindDirect("Label_PetLv01"):GetComponent("UILabel"):set_text("")
  local Img_Zhuan = petListItem:FindDirect("Img_Zhuan")
  local Img_Bang = petListItem:FindDirect("Img_Bang")
  local Img_Xiyou = petListItem:FindDirect("Img_Xiyou")
  Img_Zhuan:SetActive(false)
  Img_Bang:SetActive(false)
  GUIUtils.SetActive(Img_Xiyou, false)
  GUIUtils.SetText(petListItem:FindDirect("Label_PowerLv"), "")
  local Img_BgPetItem = petListItem:FindDirect("Img_BgPetItem")
  Img_BgPetItem:SetActive(false)
  petListItem:FindDirect("Group_Add"):SetActive(true)
  petListItem:FindDirect("Group_Empty"):SetActive(false)
  GUIUtils.SetActive(petListItem:FindDirect("Img_Red"), false)
end
def.method("number", "number").SetPetBagCapacityInfo = function(self, num, capacity)
  local label_petNum = self.ui_PetList:FindDirect("Img_PetList/Label_PetListNum"):GetComponent("UILabel")
  label_petNum:set_text(string.format("%d/%d", num, capacity))
end
def.method().SetPetListEmpty = function(self)
end
local isInited = false
def.method("number").SetSelectedListItem = function(self, index)
  local list_petList = self.ui_List_PetList:GetComponent("UIList")
  local itemList = list_petList:get_children()
  local petItemObj = itemList[index]
  if petItemObj == nil then
    return
  end
  GameUtil.AddGlobalLateTimer(0, true, function()
    GameUtil.AddGlobalLateTimer(0, true, function()
      if list_petList.isnil then
        return
      end
      local uiScrollView = list_petList.gameObject.transform.parent.gameObject:GetComponent("UIScrollView")
      local item = itemList[index]
      uiScrollView:UpdatePosition()
      if isInited then
        uiScrollView:DragToMakeVisible(item.transform, 4)
      end
      isInited = true
    end)
  end)
  petItemObj:FindDirect("Pet_" .. index):GetComponent("UIToggle"):set_value(true)
end
def.method("=>", "boolean").HavePetSkillBook = function(self)
  local items = ItemModule.Instance():GetItemsByBagId(ItemModule.BAG)
  for key, item in pairs(items) do
    local itemBase = ItemUtils.GetItemBase(item.id)
    if itemBase.itemType == ItemType.PET_SKILL_BOOK then
      return true
    end
  end
  return false
end
def.method().ShowPetItemBag = function(self)
  self.ui_PetList:SetActive(false)
  self.ui_Img_Bg0:FindDirect("CW/Img_CW_BgItem"):SetActive(true)
  local gridObj = self.ui_Img_Bg0:FindDirect("CW/Img_CW_BgItem/Scroll View_CW_Item/Gride_CW_Item")
  local gridComponent = gridObj:GetComponent("UIGrid")
  local itemTemplateRaw = gridObj:FindDirect("Img_CW_Item01")
  if itemTemplateRaw then
    itemTemplateRaw.name = "Img_CW_Item_0"
    itemTemplateRaw:SetActive(false)
  end
  self.petItemBagKeyList = {}
  local count = 0
  local items = ItemModule.Instance():GetItemsByBagId(ItemModule.BAG)
  for key, item in pairs(items) do
    local itemBase = ItemUtils.GetItemBase(item.id)
    if PetModule.PET_ITEM_TYPES[itemBase.itemType] then
      count = count + 1
      self:AddItem(gridObj, count, item, itemBase)
      table.insert(self.petItemBagKeyList, key)
    end
  end
  local gridItemCount = gridComponent:GetChildListCount()
  local gridChildList = gridComponent:GetChildList()
  for i = count + 1, gridItemCount do
    GameObject.Destroy(gridChildList[i].gameObject)
    gridChildList[i] = nil
  end
  gridComponent:Reposition()
  self:TouchGameObject(self.m_panel, self.m_parent)
  self.petItemBagItemAmount = count
end
def.method().UpdateTuJianNotice = function(self)
  local PetModule = Lplus.ForwardDeclare("PetModule")
  local Img_New = self.ui_PetList:FindDirect("Btn_Tj/Img_New")
  if PetModule.Instance():HasNewPetNotice() then
    Img_New:SetActive(true)
  else
    Img_New:SetActive(false)
  end
end
def.method("number").ShowItemTip = function(self, index)
  self.selectedPetItemIndex = index
  local itemKey = self.petItemBagKeyList[index]
  local item = ItemModule.Instance():GetItemByBagIdAndItemKey(ItemModule.BAG, itemKey)
  local gridObj = self.ui_Img_Bg0:FindDirect("CW/Img_CW_BgItem/Scroll View_CW_Item/Gride_CW_Item")
  local source = gridObj:FindDirect("Img_CW_Item_" .. index)
  local position = source:get_position()
  local screenPos = WorldPosToScreen(position.x, position.y)
  local sprite = source:GetComponent("UISprite")
  local tip = ItemTipsMgr.Instance():ShowTips(item, ItemModule.BAG, itemKey, ItemTipsMgr.Source.PetItemBag, screenPos.x, screenPos.y, sprite:get_width(), sprite:get_height(), 0)
  self._tipIns = tip
end
def.static("table", "table").OnPetItemBagItemUsed = function(params, context)
  local self = instance
  local itemType, itemKey = params[1], params[2]
  local petId = self.petIdList[self.selectedPetIndex]
  if itemType == ItemType.PET_LIFE_ITEM then
    self:UsePetLifeItem(petId, itemType, itemKey)
  elseif itemType == ItemType.PET_GROW_ITEM then
    self:UsePetGrowItem(petId, itemType, itemKey)
  elseif itemType == ItemType.PET_RESET_ITEM then
    self:UsePetResetPropItem(petId, itemType, itemKey)
  elseif itemType == ItemType.PET_SKILL_BOOK then
    self:UsePetSkillBook(petId, itemType, itemKey)
  elseif itemType == ItemType.PET_EQUIP then
    self:UsePetEquipment(petId, itemType, itemKey)
  end
end
def.method("userdata", "number", "number").UsePetLifeItem = function(self, petId, itemType, itemKey)
  local pet = PetMgrInstance:GetPet(petId)
  if pet:IsNeverDie() then
    Toast(textRes.Pet[72])
  else
    local petCfgData = pet:GetPetCfgData()
    local bornMaxLife = petCfgData.bornMaxLife
    if bornMaxLife > pet.life then
      PetMgrInstance:UseItem(petId, itemKey, itemType)
    else
      Toast(textRes.Pet[73])
    end
  end
end
def.method("userdata", "number", "number").UsePetGrowItem = function(self, petId, itemType, itemKey)
  local pet = PetMgrInstance:GetPet(petId)
  local petCfgData = pet:GetPetCfgData()
  local growMaxValue = petCfgData.growMaxValue
  if growMaxValue > pet.growValue then
    PetMgrInstance:UseItem(petId, itemKey, itemType)
  else
    Toast(textRes.Pet[71])
  end
end
def.method("userdata", "number", "number").UsePetResetPropItem = function(self, petId, itemType, itemKey)
  local PetAssignPropMgr = require("Main.Pet.mgr.PetAssignPropMgr")
  local pet = PetMgrInstance:GetPet(petId)
  if pet.isCanResetProp then
    local item = ItemModule.Instance():GetItemByBagIdAndItemKey(ItemModule.BAG, itemKey)
    PetAssignPropMgr.Instance():ResetPotentialPoint(petId, item.number)
  else
    Toast(textRes.Pet[68])
  end
end
def.method("userdata", "number", "number").UsePetSkillBook = function(self, petId, itemType, itemKey)
  local PetSkillMgr = require("Main.Pet.mgr.PetSkillMgr")
  local skillBook = ItemModule.Instance():GetItemByBagIdAndItemKey(ItemModule.BAG, itemKey)
  local skillBookCfg = PetUtility.GetPetSkillBookItemCfg(skillBook.id)
  local skillId = skillBookCfg.skillId
  local pet = PetMgrInstance:GetPet(petId)
  local canStudySkillBook = true
  for i, id in ipairs(pet.skillIdList) do
    if skillId == id then
      canStudySkillBook = false
      break
    end
  end
  if canStudySkillBook then
    PetSkillMgr.Instance():StudySkillBookReq(petId, itemKey)
  else
    Toast(textRes.Pet[70])
  end
end
def.method("userdata", "number", "number").UsePetEquipment = function(self, petId, itemType, itemKey)
  local canEquipLevel = PetUtility.Instance():GetPetConstants("PET_CAN_EQUIP_LEVEL")
  local pet = PetMgrInstance:GetPet(self.selectedPetId)
  if canEquipLevel > pet.level then
    Toast(string.format(textRes.Pet[67], canEquipLevel))
    return
  end
  local item = ItemModule.Instance():GetItemByBagIdAndItemKey(ItemModule.BAG, itemKey)
  local itemBase = ItemUtils.GetItemBase(item.id)
  local pet = PetMgrInstance:GetPet(petId)
  require("GUI.CommonConfirmDlg").ShowConfirm(textRes.Common[8], string.format(textRes.Pet[36], "FFFF00", itemBase.name, "00FF00", pet.name), function(state, tag)
    if state == 1 then
      PetMgrInstance:EquipItemReq(petId, itemKey)
    end
  end, nil)
end
def.method().OnStorageButtonClick = function(self)
  if _G.CheckCrossServerAndToast() then
    return
  end
  require("Main.Pet.ui.PetStoragePanel").Instance():ShowPanel()
end
def.method().OnTuJianButtonClick = function(self)
  local pet = PetMgrInstance:GetPet(self.selectedPetId)
  local petTemplateId = pet and pet.typeId or 0
  require("Main.Pet.ui.PetTuJianPanel").Instance():ShowPanelWithPetTemplateId(petTemplateId)
end
def.method().OnBtn_DouClick = function(self)
  local PetTeamPanel = require("Main.PetTeam.ui.PetTeamPanel")
  PetTeamPanel.ShowPanel()
end
def.method("number").OnPetListItemClick = function(self, index)
  local maxNum = self:GetMaxPetListItemNumber()
  if index > PetMgrInstance.petNum and (index < maxNum or self:IsPetBagCapacityMax()) then
    Toast(textRes.Pet[104])
    self:OnTuJianButtonClick()
    self:UpdatePetItemToggleState()
  elseif index == maxNum and not self:IsPetBagCapacityMax() then
    self:OnExpandPetBagNumButtonClick()
    self:UpdatePetItemToggleState()
  else
    self.nodes[self.curNode]:OnPetItemClick(index)
  end
end
def.method().UpdatePetItemToggleState = function(self)
  local index = self.selectedPetIndex
  if index == 0 then
    return
  end
  local item = self.ui_List_PetList:FindDirect("item_" .. index)
  if item == nil then
    return
  end
  item:FindDirect("Pet_" .. index):GetComponent("UIToggle"):set_value(true)
end
def.method("=>", "boolean").IsPetBagCapacityMax = function(self)
  local expandBagCfg = PetUtility.Instance():GetExpandBagCfg(PetModule.PET_BAG_ID, PetMgrInstance.bagSize)
  if expandBagCfg == nil then
    return true
  end
  return not expandBagCfg.canExpand
end
def.method().OnExpandPetBagNumButtonClick = function(self)
  PetUtility.TryToExpandPetBag(PetModule.PET_BAG_ID, PetMgrInstance.bagSize)
end
def.method("number").OnPetListItemDoubleClick = function(self, index)
  local petId = self.petIdList[index]
  if petId == nil then
    return
  end
  self:OnFightingButtonClick()
end
def.method().OnFightingButtonClick = function(self)
  local petId = self.petIdList[self.selectedPetIndex]
  PetModule.Instance():TogglePetFightingState(petId)
end
def.static("table", "table").OnPetBagCapacityChange = function(params)
  instance:UpdatePetList()
end
def.static("table", "table").OnPetNotifyCountUpdate = function(params)
  instance:UpdateTabBadges()
end
def.static("table", "table").OnFunctionOpenChange = function(param, context)
  local ModuleFunSwitchInfo = require("netio.protocol.mzm.gsp.open.ModuleFunSwitchInfo")
  if param.feature == ModuleFunSwitchInfo.TYPE_PET_SOUL then
    instance:UpdateSoulTab()
  elseif param.feature == ModuleFunSwitchInfo.TYPE_PET_FIGHT then
    instance:UpdatePetTeam()
  elseif param.feature == ModuleFunSwitchInfo.TYPE_PET_MARK then
    instance:UpdateMarkTab()
  end
end
def.static("table", "table").OnPetTeamReddotChange = function(param, context)
  if instance then
    instance:UpdatePetTeam()
  end
end
def.method().UpdatePetList = function(self)
  local pets = PetMgrInstance:GetPetList()
  local petCount = PetMgrInstance:GetPetNum()
  self:SetPetList(pets, petCount)
end
def.method("userdata", "=>", "number").GetPetIndex = function(self, petId)
  local index = 0
  for i, id in ipairs(self.petIdList) do
    if id == petId then
      index = i
    end
  end
  return index
end
def.method("userdata").UpdatePetListItemById = function(self, petId)
  local index = self:GetPetIndex(petId)
  if index == 0 then
    warn(string.format("UpdatePetListItemById can't find pet(%s)"), tostring(petId))
    return
  end
  local petItem = self.ui_List_PetList:FindDirect(string.format("item_%d/Pet_%d", index, index))
  if petItem == nil then
    warn(string.format("UpdatePetListItemById can't find %s", string.format("item_%d/Pet_%d", index, index)))
    return
  end
  local pet = PetMgr.Instance():GetPet(petId)
  if pet == nil then
    return
  end
  self:SetTargetListItemInfo(index, petItem, pet)
end
def.method().UpdateTabBadges = function(self)
  for nodeId, node in pairs(self.nodes) do
    local hasNotify = false
    if node then
      hasNotify = node:HasNotify()
    end
    self:SetTabNotify(nodeId, hasNotify)
  end
end
def.method("number", "boolean").SetTabNotify = function(self, nodeId, state)
  if NodeDefines[nodeId] == nil then
    return
  end
  local tabObj = self.ui_Img_Bg0:FindDirect(NodeDefines[nodeId].tabName)
  if tabObj == nil then
    return
  end
  local Img_Red = tabObj:FindDirect("Img_Red")
  if Img_Red then
    Img_Red:SetActive(state)
  end
end
return PetPanel.Commit()
