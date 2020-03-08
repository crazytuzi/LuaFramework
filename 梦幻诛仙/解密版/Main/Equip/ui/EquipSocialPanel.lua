local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local GUIUtils = require("GUI.GUIUtils")
local EquipSocialPanel = Lplus.Extend(ECPanelBase, "EquipSocialPanel")
local EquipMakeNode = require("Main.Equip.ui.EquipMakeNode")
local EquipStrenNode = require("Main.Equip.ui.EquipStrenNode")
local EquipTransNode = require("Main.Equip.ui.EquipTransNode")
local EquipInheritNode = require("Main.Equip.ui.EquipInheritNode")
local EquipXiHunNode = require("Main.Equip.ui.EquipXiHunNode")
local EquipStrenTransData = require("Main.Equip.EquipStrenTransData")
local EquipMakeData = require("Main.Equip.EquipMakeData")
local Vector = require("Types.Vector")
local GUIUtils = require("GUI.GUIUtils")
local EquipUtils = require("Main.Equip.EquipUtils")
local EquipModule = Lplus.ForwardDeclare("EquipModule")
local ItemUtils = require("Main.Item.ItemUtils")
local def = EquipSocialPanel.define
local instance
def.const("table").NodeId = {
  EQUIPMAKE = 1,
  EQUIPSTREN = 2,
  EQUIPTRANS = 3,
  EQUIPINHERIT = 4,
  EQUIPXIHUN = 5,
  EQUIPFUHUN = 6
}
def.field("table").nodes = nil
def.field("number").curNode = 0
def.field("number").state = 0
def.const("table").StateConst = {
  EquipMake = 1,
  EquipStren = 2,
  EquipTrans = 3,
  EquipInherit = 4,
  EquipXihun = 5,
  EquipFuhun = 6
}
def.const("table").NodeInfo = {
  [1] = {tapName = "Tap_DZ"},
  [2] = {tapName = "Tap_QL"},
  [4] = {tapName = "Tap_CC"},
  [5] = {tapName = "Tap_XH"}
}
def.field(EquipStrenTransData)._equipStrenTransData = nil
def.field("boolean")._bEquipTemplateFill = false
def.field("table")._equipStrenTransList = nil
def.field(EquipMakeData)._equipMakeData = nil
def.field("boolean")._bIsEquipMakeDataInit = false
def.field("table").selectMakeEquipInfo = nil
def.field("number").selectStrenEquipKey = -1
def.field("number").selectStrenEquipPos = 0
def.field("table").selectOldItem = nil
def.field("table").selectNewItem = nil
def.static("=>", EquipSocialPanel).Instance = function()
  if nil == instance then
    instance = EquipSocialPanel()
    instance._equipStrenTransData = EquipStrenTransData.Instance()
    instance._equipMakeData = EquipMakeData.Instance()
    instance._bIsEquipMakeDataInit = false
    instance._equipStrenTransList = {}
    instance.m_TrigGC = true
    instance.m_TryIncLoadSpeed = true
    instance.m_HideOnDestroy = true
  end
  return instance
end
def.static("number").ShowSocialPanel = function(st)
  if _G.CheckCrossServerAndToast() then
    return
  end
  local socialPanel = EquipSocialPanel.Instance()
  local canOpen = socialPanel:MatchOpenLevel(st)
  if false == canOpen then
    return
  end
  socialPanel.state = st
  if false == socialPanel._bIsEquipMakeDataInit then
    socialPanel._equipMakeData:Init()
    socialPanel._bIsEquipMakeDataInit = true
  end
  if socialPanel:IsShow() then
    socialPanel:UpdateStateConst()
  else
    socialPanel:SetModal(true)
    socialPanel:CreatePanel(RESPATH.PREFAB_EQUIP_MAIN_PANEL, 1)
  end
end
def.override("boolean").OnShow = function(self, isShow)
  if isShow and EquipSocialPanel.NodeId.EQUIPXIHUN == self.curNode then
    self.nodes[self.curNode]:OnRefreshView()
  end
end
def.method().UpdateTapState = function(self)
  local tapMakeRed = self.m_panel:FindDirect("Img_BgEquip/Tap_DZ/Img_Red")
  local tapStrenRed = self.m_panel:FindDirect("Img_BgEquip/Tap_QL/Img_Red1")
  local tapXiHunRed = self.m_panel:FindDirect("Img_BgEquip/Tap_XH/Img_Red")
  local tapInherithRed = self.m_panel:FindDirect("Img_BgEquip/Tap_CC/Img_Red")
  if EquipModule.Instance():CheckRedNotice(EquipSocialPanel.NodeId.EQUIPMAKE) or require("Main.Equip.EquipBlessMgr").Instance():HasNotify() then
    tapMakeRed:SetActive(true)
  else
    tapMakeRed:SetActive(false)
  end
  if EquipModule.Instance():CheckRedNotice(EquipSocialPanel.NodeId.EQUIPSTREN) then
    tapStrenRed:SetActive(true)
  else
    tapStrenRed:SetActive(false)
  end
  if EquipModule.Instance():CheckRedNotice(EquipSocialPanel.NodeId.EQUIPXIHUN) then
    tapXiHunRed:SetActive(true)
  else
    tapXiHunRed:SetActive(false)
  end
  if EquipModule.Instance():CheckRedNotice(EquipSocialPanel.NodeId.EQUIPINHERIT) then
    tapInherithRed:SetActive(true)
  else
    tapInherithRed:SetActive(false)
  end
end
def.method("number", "number").SetEquipMakeInfo = function(self, type, level)
  self.selectMakeEquipInfo = {}
  self.selectMakeEquipInfo.type = type
  self.selectMakeEquipInfo.level = level
end
def.method("number", "number").SetEquipStrenKeyAndPos = function(self, key, pos)
  self.selectStrenEquipKey = key
  self.selectStrenEquipPos = pos
end
def.method().InitStrenTransData = function(self)
  self._equipStrenTransData:Init()
  self:UpdateEquipStrenTransList(true)
  self._bEquipTemplateFill = false
  self:FillEquipStrenTransList()
end
def.override().OnCreate = function(self)
  Event.RegisterEvent(ModuleId.FASHION, gmodule.notifyId.Fashion.FashionExpired, EquipSocialPanel.OnFashionExpired)
  self.nodes = {}
  self._equipStrenTransList = {}
  local equipMakeNode = self.m_panel:FindDirect("Img_BgEquip/DZ")
  self.nodes[EquipSocialPanel.NodeId.EQUIPMAKE] = EquipMakeNode()
  self.nodes[EquipSocialPanel.NodeId.EQUIPMAKE]:Init(self, equipMakeNode)
  local equipStrenNode = self.m_panel:FindDirect("Img_BgEquip/QL")
  self.nodes[EquipSocialPanel.NodeId.EQUIPSTREN] = EquipStrenNode()
  self.nodes[EquipSocialPanel.NodeId.EQUIPSTREN]:Init(self, equipStrenNode)
  local equipTransNode = self.m_panel:FindDirect("Img_BgEquip/FH")
  self.nodes[EquipSocialPanel.NodeId.EQUIPTRANS] = EquipTransNode()
  self.nodes[EquipSocialPanel.NodeId.EQUIPTRANS]:Init(self, equipTransNode)
  local equipInheritNode = self.m_panel:FindDirect("Img_BgEquip/CC")
  self.nodes[EquipSocialPanel.NodeId.EQUIPINHERIT] = EquipInheritNode()
  self.nodes[EquipSocialPanel.NodeId.EQUIPINHERIT]:Init(self, equipInheritNode)
  local equipXiHunNode = self.m_panel:FindDirect("Img_BgEquip/XH")
  self.nodes[EquipSocialPanel.NodeId.EQUIPXIHUN] = EquipXiHunNode()
  self.nodes[EquipSocialPanel.NodeId.EQUIPXIHUN]:Init(self, equipXiHunNode)
  self:UpdateCanStrenState()
  self:UpdateTapState()
  self:UpdateStateConst()
end
def.override().OnDestroy = function(self)
  self.curNode = 0
  self.nodes = nil
  self._equipStrenTransList = nil
  self.state = 0
  Event.UnregisterEvent(ModuleId.FASHION, gmodule.notifyId.Fashion.FashionExpired, EquipSocialPanel.OnFashionExpired)
end
def.method().UpdateStateConst = function(self)
  if EquipSocialPanel.StateConst.EquipMake == self.state then
    if self.selectMakeEquipInfo ~= nil then
      self.nodes[EquipSocialPanel.NodeId.EQUIPMAKE]:SetEquipMakeInfo(self.selectMakeEquipInfo.type, self.selectMakeEquipInfo.level)
      self.selectMakeEquipInfo = nil
    end
    self.curNode = EquipSocialPanel.NodeId.EQUIPMAKE
    self:SwitchTo(EquipSocialPanel.NodeId.EQUIPMAKE)
    self.m_panel:FindDirect("Img_BgEquip/EquipList"):SetActive(false)
    local toggle = self.m_panel:FindDirect("Img_BgEquip/Tap_DZ"):GetComponent("UIToggle")
    toggle:set_value(true)
  elseif EquipSocialPanel.StateConst.EquipStren == self.state then
    self.curNode = EquipSocialPanel.NodeId.EQUIPSTREN
    self:InitStrenTransData()
    if self.selectStrenEquipKey ~= -1 and self.selectStrenEquipPos ~= 0 then
      self.nodes[EquipSocialPanel.NodeId.EQUIPSTREN]:SetEquipStrenKeyAndPos(self.selectStrenEquipKey, self.selectStrenEquipPos)
      self.selectStrenEquipKey = -1
      self.selectStrenEquipPos = 0
    end
    self:SwitchTo(EquipSocialPanel.NodeId.EQUIPSTREN)
    self:ResetEquipNewFuncState(EquipSocialPanel.NodeId.EQUIPSTREN)
    self.m_panel:FindDirect("Img_BgEquip/EquipList"):SetActive(true)
    local toggle = self.m_panel:FindDirect("Img_BgEquip/Tap_QL"):GetComponent("UIToggle")
    toggle:set_value(true)
  elseif EquipSocialPanel.StateConst.EquipTrans == self.state then
    self.curNode = EquipSocialPanel.NodeId.EQUIPTRANS
    self:InitStrenTransData()
    self:SwitchTo(EquipSocialPanel.NodeId.EQUIPTRANS)
    self.m_panel:FindDirect("Img_BgEquip/EquipList"):SetActive(true)
    local toggle = self.m_panel:FindDirect("Img_BgEquip/Tap_FH"):GetComponent("UIToggle")
    toggle:set_value(true)
  elseif EquipSocialPanel.StateConst.EquipXihun == self.state then
    self.curNode = EquipSocialPanel.NodeId.EQUIPXIHUN
    self:InitStrenTransData()
    self:SwitchTo(EquipSocialPanel.NodeId.EQUIPXIHUN)
    self.m_panel:FindDirect("Img_BgEquip/EquipList"):SetActive(true)
    local toggle = self.m_panel:FindDirect("Img_BgEquip/Tap_XH"):GetComponent("UIToggle")
    toggle:set_value(true)
  elseif EquipSocialPanel.StateConst.EquipInherit == self.state then
    self.curNode = EquipSocialPanel.NodeId.EQUIPINHERIT
    self:InitStrenTransData()
    if self.selectNewItem ~= nil and self.selectOldItem ~= nil then
      self.nodes[EquipSocialPanel.NodeId.EQUIPINHERIT]:SetPreInhertInfo(self.selectOldItem, self.selectNewItem)
      self.selectOldItem = nil
      self.selectNewItem = nil
    end
    self:SwitchTo(EquipSocialPanel.NodeId.EQUIPINHERIT)
    self.m_panel:FindDirect("Img_BgEquip/EquipList"):SetActive(true)
    local toggle = self.m_panel:FindDirect("Img_BgEquip/Tap_CC"):GetComponent("UIToggle")
    toggle:set_value(true)
  end
end
def.method("number").SwitchTo = function(self, nodeId)
  self.curNode = 0
  for k, v in pairs(self.nodes) do
    if nodeId == k then
      local nodeInfo = EquipSocialPanel.NodeInfo[k]
      if nodeInfo then
        self.m_panel:FindDirect("Img_BgEquip/" .. nodeInfo.tapName):GetComponent("UIToggle").value = true
      end
      v:Show()
      self.curNode = nodeId
    else
      v:Hide()
      local nodeInfo = EquipSocialPanel.NodeInfo[k]
      if nodeInfo then
        self.m_panel:FindDirect("Img_BgEquip/" .. nodeInfo.tapName):GetComponent("UIToggle").value = false
      end
    end
  end
end
def.method().selectToCurNode = function(self)
  if EquipSocialPanel.NodeId.EQUIPMAKE == self.curNode then
    local toggle = self.m_panel:FindDirect("Img_BgEquip/Tap_DZ"):GetComponent("UIToggle")
    toggle:set_value(true)
  elseif EquipSocialPanel.NodeId.EQUIPSTREN == self.curNode then
    local toggle = self.m_panel:FindDirect("Img_BgEquip/Tap_QL"):GetComponent("UIToggle")
    toggle:set_value(true)
  elseif EquipSocialPanel.NodeId.EQUIPTRANS == self.curNode then
    local toggle = self.m_panel:FindDirect("Img_BgEquip/Tap_FH"):GetComponent("UIToggle")
    toggle:set_value(true)
  elseif EquipSocialPanel.NodeId.EQUIPINHERIT == self.curNode then
    local toggle = self.m_panel:FindDirect("Img_BgEquip/Tap_CC"):GetComponent("UIToggle")
    toggle:set_value(true)
  elseif EquipSocialPanel.NodeId.EQUIPXIHUN == self.curNode then
    local toggle = self.m_panel:FindDirect("Img_BgEquip/Tap_XH"):GetComponent("UIToggle")
    toggle:set_value(true)
  end
end
def.method("number", "=>", "boolean").MatchOpenLevel = function(self, target)
  local heroLevel = require("Main.Hero.Interface").GetHeroProp().level
  local openLevel = 0
  if target == EquipSocialPanel.NodeId.EQUIPSTREN or target == EquipSocialPanel.StateConst.EquipStren then
    openLevel = EquipUtils.GetEquipFunctionNeedLevel("EQUIP_QILIN_OPEN_LEVEL")
    if heroLevel < openLevel then
      self:LevelNotMatchToast("EQUIP_QILIN_OPEN_LEVEL")
      return false
    end
  elseif target == EquipSocialPanel.NodeId.EQUIPXIHUN or target == EquipSocialPanel.StateConst.EquipXihun then
    openLevel = EquipUtils.GetEquipFunctionNeedLevel("EQUIP_XIHUN_OPEN_LEVEL")
    if heroLevel < openLevel then
      self:LevelNotMatchToast("EQUIP_XIHUN_OPEN_LEVEL")
      return false
    end
  elseif target == EquipSocialPanel.NodeId.EQUIPINHERIT or target == EquipSocialPanel.StateConst.EquipInherit then
    openLevel = EquipUtils.GetEquipFunctionNeedLevel("EQUIP_FUHUN_OPEN_LEVEL")
    if heroLevel < openLevel then
      self:LevelNotMatchToast("EQUIP_FUHUN_OPEN_LEVEL")
      return false
    end
  elseif target == EquipSocialPanel.NodeId.EQUIPMAKE or target == EquipSocialPanel.StateConst.EquipMake then
    openLevel = EquipUtils.GetEquipFunctionNeedLevel("EQUIP_MAKE_OPEN_LEVEL")
    if heroLevel < openLevel then
      self:LevelNotMatchToast("EQUIP_MAKE_OPEN_LEVEL")
      return false
    end
  end
  return true
end
def.method("string").LevelNotMatchToast = function(self, targetName)
  local openLevel = EquipUtils.GetEquipFunctionNeedLevel(targetName)
  Toast(string.format(textRes.Equip[96], openLevel))
  return
end
def.method("number").ResetEquipNewFuncState = function(self, nodeId)
  if EquipModule.Instance():CheckRedNotice(nodeId) then
    EquipModule.Instance():ResetNewFuncState(nodeId)
  end
end
def.method("userdata").onClickObj = function(self, clickobj)
  local id = clickobj.name
  if "Btn_Close" == id then
    self:DestroyPanel()
  elseif id == "Modal" then
    self:DestroyPanel()
  elseif "Tap_DZ" == id then
    if false == self:MatchOpenLevel(EquipSocialPanel.NodeId.EQUIPMAKE) then
      self:selectToCurNode()
      self:SwitchTo(self.curNode)
      return
    end
    self.curNode = EquipSocialPanel.NodeId.EQUIPMAKE
    self:ResetEquipNewFuncState(EquipSocialPanel.NodeId.EQUIPMAKE)
    self.m_panel:FindDirect("Img_BgEquip/EquipList"):SetActive(false)
    self:SwitchTo(EquipSocialPanel.NodeId.EQUIPMAKE)
  elseif "Tap_QL" == id then
    if false == self:MatchOpenLevel(EquipSocialPanel.NodeId.EQUIPSTREN) then
      self:selectToCurNode()
      self:SwitchTo(self.curNode)
      return
    end
    self._equipStrenTransData:Init()
    self.curNode = EquipSocialPanel.NodeId.EQUIPSTREN
    self:ResetEquipNewFuncState(EquipSocialPanel.NodeId.EQUIPSTREN)
    self.m_panel:FindDirect("Img_BgEquip/EquipList"):SetActive(true)
    self:UpdateEquipStrenTransList(true)
    self._bEquipTemplateFill = false
    self:FillEquipStrenTransList()
    self:SelectFromEquipStrenTrans(1)
    self:SwitchTo(EquipSocialPanel.NodeId.EQUIPSTREN)
  elseif id == "Tap_XH" then
    if false == self:MatchOpenLevel(EquipSocialPanel.NodeId.EQUIPXIHUN) then
      self:selectToCurNode()
      self:SwitchTo(self.curNode)
      return
    end
    self._equipStrenTransData:Init()
    local curNum = #self._equipStrenTransData:GetTransEquips()
    if curNum == 0 then
      Toast(textRes.Equip[63])
      self:selectToCurNode()
      self:SwitchTo(self.curNode)
      return
    end
    self.curNode = EquipSocialPanel.NodeId.EQUIPXIHUN
    self:ResetEquipNewFuncState(EquipSocialPanel.NodeId.EQUIPXIHUN)
    self.m_panel:FindDirect("Img_BgEquip/EquipList"):SetActive(true)
    self:UpdateEquipStrenTransList(true)
    self._bEquipTemplateFill = false
    self:FillEquipStrenTransList()
    self:SelectFromEquipStrenTrans(1)
    self:SwitchTo(EquipSocialPanel.NodeId.EQUIPXIHUN)
  elseif "Tap_CC" == id then
    if false == self:MatchOpenLevel(EquipSocialPanel.NodeId.EQUIPINHERIT) then
      self:selectToCurNode()
      self:SwitchTo(self.curNode)
      return
    end
    self._equipStrenTransData:Init()
    local curNum = #self._equipStrenTransData:GetInheritEquips()
    if curNum == 0 then
      Toast(textRes.Equip[50])
      self:selectToCurNode()
      self:SwitchTo(self.curNode)
      return
    end
    self.curNode = EquipSocialPanel.NodeId.EQUIPINHERIT
    self:ResetEquipNewFuncState(EquipSocialPanel.NodeId.EQUIPINHERIT)
    self.m_panel:FindDirect("Img_BgEquip/EquipList"):SetActive(true)
    self:UpdateEquipStrenTransList(true)
    self._bEquipTemplateFill = false
    self:FillEquipStrenTransList()
    self:SelectFromEquipStrenTrans(1)
    self:SwitchTo(EquipSocialPanel.NodeId.EQUIPINHERIT)
  elseif string.sub(id, 1, #"Img_BgEquip01_") == "Img_BgEquip01_" then
    local index = tonumber(string.sub(id, #"Img_BgEquip01_" + 1, -1))
    self:SelectFromEquipStrenTrans(index)
    self.nodes[self.curNode]:OnEquipListClick(index)
  else
    self.nodes[self.curNode]:onClickObj(clickobj)
  end
end
def.method("string", "string", "number").onSelect = function(self, id, selected, index)
  if EquipSocialPanel.NodeId.EQUIPMAKE == self.curNode then
    self.nodes[self.curNode]:onSelect(id, selected, index)
  end
end
def.method().PrepareStrenTransEquips = function(self)
  if self.curNode == EquipSocialPanel.NodeId.EQUIPSTREN then
    self._equipStrenTransData:InitStrenEquip()
  elseif self.curNode == EquipSocialPanel.NodeId.EQUIPTRANS then
    self._equipStrenTransData:InitTransEquip()
  elseif self.curNode == EquipSocialPanel.NodeId.EQUIPXIHUN then
    self._equipStrenTransData:InitTransEquip()
  elseif self.curNode == EquipSocialPanel.NodeId.EQUIPINHERIT then
    self._equipStrenTransData:InitInheritEquip()
  end
  self:UpdateEquipStrenTransList(false)
  self._bEquipTemplateFill = false
end
def.method("boolean").UpdateEquipStrenTransList = function(self, bScrollViewReset)
  local srcNum = #self._equipStrenTransList
  local curNum = #self._equipStrenTransData:GetStrenEquips()
  if self.curNode == EquipSocialPanel.NodeId.EQUIPTRANS then
    curNum = #self._equipStrenTransData:GetTransEquips()
  elseif self.curNode == EquipSocialPanel.NodeId.EQUIPXIHUN then
    curNum = #self._equipStrenTransData:GetTransEquips()
  elseif self.curNode == EquipSocialPanel.NodeId.EQUIPINHERIT then
    curNum = #self._equipStrenTransData:GetInheritEquips()
  end
  local uiList = self.m_panel:FindDirect("Img_BgEquip/EquipList/Scroll View_EquipList/Grid_EquipList"):GetComponent("UIList")
  uiList:set_itemCount(curNum)
  uiList:Resize()
  GameUtil.AddGlobalLateTimer(0, true, function()
    if not uiList.isnil then
      uiList:Reposition()
    end
  end)
  self:TouchGameObject(self.m_panel, self.m_parent)
  if bScrollViewReset then
    do
      local ScrollView = self.m_panel:FindDirect("Img_BgEquip/EquipList/Scroll View_EquipList")
      GameUtil.AddGlobalLateTimer(0.1, true, function()
        if ScrollView and self.m_panel and false == self.m_panel.isnil then
          ScrollView:GetComponent("UIScrollView"):ResetPosition()
        end
      end)
    end
  end
end
def.method().FillEquipStrenTransList = function(self)
  if self.curNode == EquipSocialPanel.NodeId.EQUIPMAKE then
    return
  end
  local equipStrenTransList = self._equipStrenTransData:GetStrenEquips()
  if self.curNode == EquipSocialPanel.NodeId.EQUIPTRANS then
    equipStrenTransList = self._equipStrenTransData:GetTransEquips()
  elseif self.curNode == EquipSocialPanel.NodeId.EQUIPINHERIT then
    equipStrenTransList = self._equipStrenTransData:GetInheritEquips()
  elseif self.curNode == EquipSocialPanel.NodeId.EQUIPXIHUN then
    equipStrenTransList = self._equipStrenTransData:GetTransEquips()
  end
  self._equipStrenTransList = equipStrenTransList
  local uiList = self.m_panel:FindDirect("Img_BgEquip/EquipList/Scroll View_EquipList/Grid_EquipList"):GetComponent("UIList")
  local itemsUI = uiList:get_children()
  for i = 1, #itemsUI do
    local itemUI = itemsUI[i]
    local itemInfo = equipStrenTransList[i]
    self:FillEquipInfo(itemInfo, itemUI, i)
  end
end
def.method("table", "userdata", "number").FillEquipInfo = function(self, equipInfo, equipTemplate, index)
  local levelLabel = equipTemplate:FindDirect(string.format("Label_EquipLv01_%d", index))
  local typeLabel = equipTemplate:FindDirect(string.format("Label_EquipType01_%d", index))
  local activeLabel = equipTemplate:FindDirect(string.format("Lable_Active_%d", index))
  local redSprite = equipTemplate:FindDirect(string.format("Img_Red_%d", index))
  local strLv = equipInfo.useLevel .. textRes.Equip[30]
  if self.curNode == EquipSocialPanel.NodeId.EQUIPSTREN then
    local canStren = EquipUtils.canStren(equipInfo)
    if canStren then
      levelLabel:SetActive(false)
      typeLabel:SetActive(false)
      activeLabel:SetActive(true)
      redSprite:SetActive(true)
    else
      levelLabel:SetActive(true)
      typeLabel:SetActive(true)
      activeLabel:SetActive(false)
      redSprite:SetActive(false)
      levelLabel:GetComponent("UILabel"):set_text(strLv)
      typeLabel:GetComponent("UILabel"):set_text(equipInfo.typeName)
    end
  else
    levelLabel:SetActive(true)
    typeLabel:SetActive(true)
    activeLabel:SetActive(false)
    redSprite:SetActive(false)
    levelLabel:GetComponent("UILabel"):set_text(strLv)
    typeLabel:GetComponent("UILabel"):set_text(equipInfo.typeName)
  end
  equipTemplate:FindDirect(string.format("Label_EquipName01_%d", index)):GetComponent("UILabel"):set_text(ItemUtils.GetItemName(equipInfo, nil))
  local equipIcon = equipTemplate:FindDirect(string.format("Icon_Equip01_%d", index))
  equipIcon:SetActive(true)
  local equipIconTex = equipIcon:GetComponent("UITexture")
  GUIUtils.FillIcon(equipIconTex, equipInfo.iconId)
  local equipBgIcon = equipTemplate:FindDirect(string.format("Icon_BgEquip01_%d", index))
  equipBgIcon:SetActive(true)
  GUIUtils.SetSprite(equipBgIcon, ItemUtils.GetItemFrame(equipInfo, nil))
  equipTemplate:FindDirect(string.format("Img_EquipMark01_%d", index)):SetActive(equipInfo.bEquiped)
  equipTemplate:GetComponent("UIToggle"):set_isChecked(false)
  equipTemplate:FindDirect(string.format("Label_Key_%d", index)):SetActive(false)
  equipTemplate:FindDirect(string.format("Label_Key_%d", index)):GetComponent("UILabel"):set_text(equipInfo.key)
  local strenLevel = EquipUtils.GetEquipStrenLevel(equipInfo.bagId, equipInfo.key)
  equipTemplate:FindDirect(string.format("Label_QiLingNum_%d", index)):GetComponent("UILabel"):set_text(strenLevel)
end
def.method("number").SelectFromEquipStrenTrans = function(self, index)
  local gridTemplate = self.m_panel:FindDirect("Img_BgEquip/EquipList/Scroll View_EquipList/Grid_EquipList")
  local str = string.format("Img_BgEquip01_%d", index)
  local list = gridTemplate:GetComponent("UIList"):get_children()
  for i = 1, #list do
    local ui = list[i]
    if ui.name == str then
      ui:GetComponent("UIToggle"):set_isChecked(true)
    end
  end
end
def.method().UpdateCanStrenState = function(self)
  local hasEquipCanStren = EquipUtils.hasEquipCanStren()
  local qilinTip = self.m_panel:FindDirect("Img_BgEquip/Tap_QL/Img_Red")
  if hasEquipCanStren then
    qilinTip:SetActive(true)
  else
    qilinTip:SetActive(false)
  end
end
def.method().UpdateEquipTransList = function(self)
  if self.m_panel ~= nil and false == self.m_panel.isnil and self.m_panel:FindDirect("Img_BgEquip/FH"):get_activeInHierarchy() and EquipSocialPanel.NodeId.EQUIPTRANS == self.curNode then
    local key = self.nodes[EquipSocialPanel.NodeId.EQUIPTRANS]:GetEquipTransSelectedKey()
    self:UpdateEquipTransInheritList(key)
  end
end
def.method().UpdateEquipInheritList = function(self)
  if self.m_panel ~= nil and false == self.m_panel.isnil and self.m_panel:FindDirect("Img_BgEquip/CC"):get_activeInHierarchy() and EquipSocialPanel.NodeId.EQUIPINHERIT == self.curNode then
    local key = self.nodes[EquipSocialPanel.NodeId.EQUIPINHERIT]:GetEquipInheritSelectedKey()
    self:UpdateEquipTransInheritList(key)
  end
end
def.method().UpdateEquipList = function(self)
  if self.m_panel and false == self.m_panel.isnil and self.m_panel:get_activeInHierarchy() then
    self:PrepareStrenTransEquips()
    self:FillEquipStrenTransList()
  end
end
def.method().RefreshEquipList = function(self)
  if self.m_panel and false == self.m_panel.isnil then
    self._bEquipTemplateFill = false
    self:FillEquipStrenTransList()
  end
end
def.method("number").UpdateEquipTransInheritList = function(self, key)
  local gridTemplate = self.m_panel:FindDirect("Img_BgEquip/EquipList/Scroll View_EquipList/Grid_EquipList"):GetComponent("UIList")
  local eqpList = gridTemplate:get_children()
  for i = 1, #eqpList do
    local template = eqpList[i]
    local labelKey = tonumber(template:FindDirect(string.format("Label_Key_%d", i)):GetComponent("UILabel"):get_text())
    if labelKey == key then
      template:GetComponent("UIToggle"):set_isChecked(true)
    end
  end
end
def.method("number", "table").ShowEquipMakeSuccessFrame = function(self, key, info)
  if self.m_panel ~= nil and false == self.m_panel.isnil and EquipSocialPanel.NodeId.EQUIPMAKE == self.curNode then
    self.nodes[EquipSocialPanel.NodeId.EQUIPMAKE]:ShowEquipMakeSuccessFrame(key, info)
  end
end
def.method("number", "number", "table").UpdateEquipStrenFrame = function(self, strenLevel, bSuccess, itemInfo)
  if self.m_panel ~= nil and false == self.m_panel.isnil and EquipSocialPanel.NodeId.EQUIPSTREN == self.curNode then
    self.nodes[EquipSocialPanel.NodeId.EQUIPSTREN]:UpdateEquipStrenFrame(strenLevel, bSuccess, itemInfo)
  end
end
def.method("number", "table").UpdateAccumutionEquipStrenFrame = function(self, strenLevel, itemInfo)
  if self.m_panel ~= nil and false == self.m_panel.isnil and EquipSocialPanel.NodeId.EQUIPSTREN == self.curNode then
    self.nodes[EquipSocialPanel.NodeId.EQUIPSTREN]:UpdateAccumutionEquipStrenFrame(strenLevel, itemInfo)
  end
end
def.method().UpdateEquipQiLinMode = function(self)
  if self.m_panel ~= nil and false == self.m_panel.isnil and EquipSocialPanel.NodeId.EQUIPSTREN == self.curNode then
    self.nodes[EquipSocialPanel.NodeId.EQUIPSTREN]:SwitchQiLingMode()
  end
end
def.method("number", "table").RefeshEquipTrans = function(self, index, newInfo)
  if self.m_panel ~= nil and false == self.m_panel.isnil and EquipSocialPanel.NodeId.EQUIPTRANS == self.curNode then
    self.nodes[EquipSocialPanel.NodeId.EQUIPTRANS]:RefeshEquipTrans(index, newInfo)
  end
end
def.method().FailedEquipTrans = function(self)
  if self.m_panel ~= nil and false == self.m_panel.isnil and EquipSocialPanel.NodeId.EQUIPTRANS == self.curNode then
    self.nodes[EquipSocialPanel.NodeId.EQUIPTRANS]:FailedEquipTrans()
  end
end
def.method("table", "number", "number").RefeshEquipInheritInfo = function(self, newExproList, level, bSelect)
  if self.m_panel ~= nil and false == self.m_panel.isnil and EquipSocialPanel.NodeId.EQUIPINHERIT == self.curNode then
    self.nodes[EquipSocialPanel.NodeId.EQUIPINHERIT]:RefeshEquipInheritInfo(newExproList, level, bSelect)
  end
end
def.method("string").UpdateStrenLevelAfterInherit = function(self, strenLevel)
  if self.m_panel ~= nil and false == self.m_panel.isnil and EquipSocialPanel.NodeId.EQUIPINHERIT == self.curNode then
    self.nodes[EquipSocialPanel.NodeId.EQUIPINHERIT]:UpdateStrenLevelAfterInherit(strenLevel)
  end
end
def.method().RefeshEquipMakeItemNum = function(self)
  if self.m_panel ~= nil and false == self.m_panel.isnil and EquipSocialPanel.NodeId.EQUIPMAKE == self.curNode then
    self.nodes[EquipSocialPanel.NodeId.EQUIPMAKE]:RefeshEquipMakeItemNum()
  end
end
def.method().JudgeEquipCanMake = function(self)
  if self.m_panel ~= nil and false == self.m_panel.isnil and EquipSocialPanel.NodeId.EQUIPMAKE == self.curNode then
    self.nodes[EquipSocialPanel.NodeId.EQUIPMAKE]:JudgeEquipCanMake()
  end
end
def.method("number").UpdateEquipStrenNeedItem = function(self, strenLevel)
  if self.m_panel ~= nil and false == self.m_panel.isnil and EquipSocialPanel.NodeId.EQUIPSTREN == self.curNode then
    self.nodes[EquipSocialPanel.NodeId.EQUIPSTREN]:UpdateEquipStrenNeedItem(strenLevel)
  end
end
def.method().UpdateTransItemNum = function(self)
  if self.m_panel ~= nil and false == self.m_panel.isnil and EquipSocialPanel.NodeId.EQUIPTRANS == self.curNode then
    self.nodes[EquipSocialPanel.NodeId.EQUIPTRANS]:UpdateTransItemNum()
  end
end
def.method().RefeshSilverNum = function(self)
  if self.m_panel ~= nil and false == self.m_panel.isnil and EquipSocialPanel.NodeId.EQUIPMAKE == self.curNode then
    self.nodes[EquipSocialPanel.NodeId.EQUIPMAKE]:RefeshSilverNum()
  end
end
def.method().UpdateEquipStrenSilver = function(self)
  if self.m_panel ~= nil and false == self.m_panel.isnil and EquipSocialPanel.NodeId.EQUIPSTREN == self.curNode then
    self.nodes[EquipSocialPanel.NodeId.EQUIPSTREN]:UpdateEquipStrenSilver()
  end
end
def.method().UpdateTransSilverNum = function(self)
  if self.m_panel ~= nil and false == self.m_panel.isnil and EquipSocialPanel.NodeId.EQUIPTRANS == self.curNode then
    self.nodes[EquipSocialPanel.NodeId.EQUIPTRANS]:UpdateTransSilverNum()
  end
end
def.method().UpdateInheritSilverNum = function(self)
  if self.m_panel ~= nil and false == self.m_panel.isnil and EquipSocialPanel.NodeId.EQUIPINHERIT == self.curNode then
    self.nodes[EquipSocialPanel.NodeId.EQUIPINHERIT]:UpdateInheritSilverNum()
  end
end
def.method("number", "table").SetEquipMakeItemNeedGold = function(self, id, itemid2yuanbao)
  if self.m_panel ~= nil and false == self.m_panel.isnil then
    if EquipSocialPanel.NodeId.EQUIPMAKE == self.curNode then
      self.nodes[EquipSocialPanel.NodeId.EQUIPMAKE]:SetEquipMakeItemNeedGold(id, itemid2yuanbao)
    elseif EquipSocialPanel.NodeId.EQUIPXIHUN == self.curNode then
      self.nodes[EquipSocialPanel.NodeId.EQUIPXIHUN]:OnAskItemsYuanBaoPrice(id, itemid2yuanbao)
    elseif EquipSocialPanel.NodeId.EQUIPSTREN == self.curNode then
      self.nodes[EquipSocialPanel.NodeId.EQUIPSTREN]:OnAskQiLingItemsYuanBaoPrice(id, itemid2yuanbao)
    end
  end
end
def.method("number", "number").EquipMakeItemGoldDifferent = function(self, eqpId, serverNeedYuanbao)
  if self.m_panel ~= nil and false == self.m_panel.isnil and EquipSocialPanel.NodeId.EQUIPMAKE == self.curNode then
    self.nodes[EquipSocialPanel.NodeId.EQUIPMAKE]:EquipMakeItemGoldDifferent(eqpId, serverNeedYuanbao)
  end
end
def.method().UpdateCurEquipInfo = function(self)
  if self.m_panel ~= nil and false == self.m_panel.isnil and EquipSocialPanel.NodeId.EQUIPTRANS == self.curNode then
    self.nodes[EquipSocialPanel.NodeId.EQUIPTRANS]:UpdateCurEquipInfo()
  end
end
def.method().UpdateBtnState = function(self)
  if self.m_panel ~= nil and false == self.m_panel.isnil then
    if EquipSocialPanel.NodeId.EQUIPSTREN == self.curNode then
      self.nodes[EquipSocialPanel.NodeId.EQUIPSTREN]:UpdateBtnState()
    elseif EquipSocialPanel.NodeId.EQUIPINHERIT == self.curNode then
      self.nodes[EquipSocialPanel.NodeId.EQUIPINHERIT]:UpdateBtnState()
    end
  end
end
def.method("userdata").DelayCheckBtnEnableState = function(self, obj)
  GameUtil.AddGlobalTimer(5, true, function()
    if self.m_panel and false == self.m_panel.isnil and obj and not obj.isnil then
      local uiBtn = obj:GetComponent("UIButton")
      if uiBtn then
        uiBtn:set_isEnabled(true)
      end
    end
  end)
end
def.method("number", "userdata", "number").lockHunSuccess = function(self, bagid, uuid, hunIndex)
  if self.m_panel ~= nil and false == self.m_panel.isnil and EquipSocialPanel.NodeId.EQUIPXIHUN == self.curNode then
    self.nodes[EquipSocialPanel.NodeId.EQUIPXIHUN]:onLockHunSuccess(bagid, uuid, hunIndex)
  end
end
def.method("number", "userdata", "number", "number").lockHunFailed = function(self, bagid, uuid, hunIndex, retcode)
  if self.m_panel ~= nil and false == self.m_panel.isnil and EquipSocialPanel.NodeId.EQUIPXIHUN == self.curNode then
    self.nodes[EquipSocialPanel.NodeId.EQUIPXIHUN]:onLockHunFailed(bagid, uuid, hunIndex, retcode)
  end
end
def.method("number", "userdata", "table").RefresHunSuccess = function(self, bagid, uuid, extraProps)
  if self.m_panel ~= nil and false == self.m_panel.isnil and EquipSocialPanel.NodeId.EQUIPXIHUN == self.curNode then
    self.nodes[EquipSocialPanel.NodeId.EQUIPXIHUN]:onRefreshHunSuccess(bagid, uuid, extraProps)
  end
end
def.method("number", "userdata", "number").RefresHunFailed = function(self, bagid, uuid, retcode)
  if self.m_panel ~= nil and false == self.m_panel.isnil and EquipSocialPanel.NodeId.EQUIPXIHUN == self.curNode then
    self.nodes[EquipSocialPanel.NodeId.EQUIPXIHUN]:onRefreshHunFailed(bagid, uuid, retcode)
  end
end
def.method("number", "userdata", "number").unLockHunSuccess = function(self, bagid, uuid, hunIndex)
  if self.m_panel ~= nil and false == self.m_panel.isnil and EquipSocialPanel.NodeId.EQUIPXIHUN == self.curNode then
    self.nodes[EquipSocialPanel.NodeId.EQUIPXIHUN]:OnUnLockHunSuccess(bagid, uuid, hunIndex)
  end
end
def.method("number", "userdata", "number", "number").unLockHunFailed = function(self, bagid, uuid, hunIndex, retcode)
  if self.m_panel ~= nil and false == self.m_panel.isnil and EquipSocialPanel.NodeId.EQUIPXIHUN == self.curNode then
    self.nodes[EquipSocialPanel.NodeId.EQUIPXIHUN]:OnUnLockHunFailed(bagid, uuid, hunIndex, retcode)
  end
end
def.method().OnEquipXinHunBagInfoSyn = function(self)
  if self.m_panel ~= nil and false == self.m_panel.isnil and EquipSocialPanel.NodeId.EQUIPXIHUN == self.curNode then
    self.nodes[EquipSocialPanel.NodeId.EQUIPXIHUN]:OnBagInfoChange()
  end
end
def.method("number", "userdata", "number").ReplaceHunSuccess = function(self, bagid, uuid, isReplace)
  if self.m_panel ~= nil and false == self.m_panel.isnil and EquipSocialPanel.NodeId.EQUIPXIHUN == self.curNode then
    self.nodes[EquipSocialPanel.NodeId.EQUIPXIHUN]:onReplaceHunSuccess(bagid, uuid, isReplace)
  end
end
def.method("number", "number", "number", "userdata").ReplaceHunFailed = function(self, retcode, bagid, isReplace, uuid)
  if self.m_panel ~= nil and false == self.m_panel.isnil and EquipSocialPanel.NodeId.EQUIPXIHUN == self.curNode then
    self.nodes[EquipSocialPanel.NodeId.EQUIPXIHUN]:onReplaceHunFailed(retcode, bagid, isReplace, uuid)
  end
end
def.method("table").OnUpdateEquipInheritInfo = function(self, newExproList)
  if self.m_panel and false == self.m_panel.isnil and self.curNode == EquipSocialPanel.NodeId.EQUIPINHERIT then
    self.nodes[EquipSocialPanel.NodeId.EQUIPINHERIT]:UpdateEquipInheritInfo(newExproList)
  end
end
def.method("userdata", "table", "table").ShowInheritConfirmDlg = function(self, uuid, oldItem, item)
  self:SetInhertPreInfo(oldItem, item)
  EquipSocialPanel.ShowSocialPanel(EquipSocialPanel.StateConst.EquipInherit)
end
def.method("table", "table").SetInhertPreInfo = function(self, oldItem, newItem)
  self.selectOldItem = oldItem
  self.selectNewItem = newItem
end
def.method("number").ShowCommonEorrorInfo = function(self, errorCode)
  if self.m_panel ~= nil and false == self.m_panel.isnil then
    if textRes.Equip.CommonError[errorCode] == nil then
      Toast(textRes.Equip[302])
      return
    end
    Toast(textRes.Equip.CommonError[errorCode])
  end
end
def.static("table", "table").OnFashionExpired = function(p1, p2)
  local self = EquipSocialPanel.Instance()
  if not self.m_panel or self.m_panel.isnil then
    return
  end
  if self.curNode == EquipSocialPanel.NodeId.EQUIPSTREN then
    self.nodes[EquipSocialPanel.NodeId.EQUIPSTREN]:UpdateLuckFuInfo()
  end
end
EquipSocialPanel.Commit()
return EquipSocialPanel
