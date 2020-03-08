local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local FabaoTabNode = require("Main.Fabao.ui.FabaoTabNode")
local FabaoData = require("Main.Fabao.data.FabaoData")
local ItemUtils = require("Main.Item.ItemUtils")
local FabaoModule = Lplus.ForwardDeclare("FabaoModule")
local GUIUtils = require("GUI.GUIUtils")
local FabaoUtils = require("Main.Fabao.FabaoUtils")
local ItemTipsMgr = require("Main.Item.ItemTipsMgr")
local ItemXStoreType = require("netio.protocol.mzm.gsp.item.ItemXStoreType")
local FabaoSocialPanel = Lplus.ForwardDeclare("FabaoSocialPanel")
local FabaoSpiritInterface = require("Main.FabaoSpirit.FabaoSpiritInterface")
local FabaoSpiritModule = require("Main.FabaoSpirit.FabaoSpiritModule")
local FabaoBasicNode = Lplus.Extend(FabaoTabNode, "FabaoBasicNode")
local def = FabaoBasicNode.define
local SelectNodeId = {
  Btn_All = 0,
  Btn_Gold = 1,
  Btn_Wood = 2,
  Btn_Water = 3,
  Btn_Fire = 4,
  Btn_Dust = 5,
  Btn_Wind = 6
}
local MAX_FABAO_RANK = 0
local FABAO_TYPE_NUM = 7
local DEFAULT_RANK = 10
def.field("number").m_CurNode = 0
def.field("number").m_CurSelectNode = 0
def.field("number").m_CurSelectRank = 0
def.field("table").m_CurDisPlayFabao = nil
def.field("table").m_CurAllFabao = nil
def.field("table").m_UIObjs = nil
def.field("boolean").m_ShowSelectList = false
def.field("boolean").m_ShowSelectFabaoTypeList = false
def.field("boolean").m_ShowSelectFabaoRankList = false
def.override(ECPanelBase, "userdata").Init = function(self, base, node)
  FabaoTabNode.Init(self, base, node)
end
def.override().OnShow = function(self)
  self:InitData()
  self:InitUI()
  self:UpdateUI()
end
def.override().OnHide = function(self)
  self.m_UIObjs = nil
  self.m_CurAllFabao = nil
  self.m_CurDisPlayFabao = nil
  self.m_ShowSelectList = false
  self.m_ShowSelectFabaoTypeList = false
  self.m_ShowSelectFabaoRankList = false
end
def.override("=>", "boolean").HasSubNode = function(self)
  return true
end
def.method().InitUI = function(self)
  if nil == self.m_UIObjs then
    self.m_UIObjs = {}
  end
  self.m_UIObjs.FabaoGroup = self.m_node:FindDirect("Group_Equip")
  self.m_UIObjs.FabaoNodes = {}
  for i = 1, 6 do
    self.m_UIObjs.FabaoNodes[i] = self.m_UIObjs.FabaoGroup:FindDirect(string.format("Fabao_%d", i))
  end
  self.m_UIObjs.EffectLabel = self.m_node:FindDirect("Label")
  self.m_UIObjs.FabaoBagView = self.m_node:FindDirect("Group_BagEquipList")
  self.m_UIObjs.FabaoScroolView = self.m_node:FindDirect("Group_BagEquipList/Scroll View")
  self.m_UIObjs.FabaoListView = self.m_node:FindDirect("Group_BagEquipList/Scroll View/Grid")
  self.m_UIObjs.FabaoSelectTapGroup = self.m_node:FindDirect("Img_ChooseBg")
  self.m_UIObjs.BasicSubTaps = {}
  self.m_UIObjs.BasicSubTaps.MyFabao = self.m_node:FindDirect("Tap_My")
  self.m_UIObjs.BasicSubTaps.AllFabao = self.m_node:FindDirect("Tap_All")
  self.m_UIObjs.LeftFabaoList = self.m_panel:FindDirect("Img_Bg1/Group_List")
  self.m_UIObjs.LeftFabaoList:SetActive(false)
  self.m_UIObjs.disPlayTypeChooseList = self.m_node:FindDirect("List_ChooseFabao")
  self.m_UIObjs.displayFabaoLabel = self.m_node:FindDirect("Img_NameBg/Label_CurrentShow")
  self.m_UIObjs.SelectRankListView = self.m_node:FindDirect("List_ChooseStar")
  self.m_UIObjs.SelectTypeListView = self.m_node:FindDirect("List_ChooseShuxing")
  self.m_UIObjs.EffectGrid = self.m_node:FindDirect("Group_FB")
  self.m_UIObjs.EffectItem = {}
  for i = 1, 3 do
    self.m_UIObjs.EffectItem[i] = self.m_UIObjs.EffectGrid:FindDirect(string.format("FB_Item_%d", i))
  end
end
def.method().InitData = function(self)
  self.m_CurDisPlayFabao = FabaoData.Instance():GetCurDisplayFabao()
  local targetNode = self.m_CurNode
  if 0 == targetNode then
    targetNode = FabaoSocialPanel.BasicSubNode.MyFabao
  end
  local params = self.m_Params
  if params and params.basicSubNode then
    targetNode = params.basicSubNode
  end
  self.m_Params = nil
  self.m_CurNode = targetNode
  local SelectNode = SelectNodeId.Btn_All
  if params and params.basicSelectNode then
    SelectNode = params.basicSelectNode
  end
  self.m_CurSelectNode = SelectNode
  if self.m_CurNode == FabaoSocialPanel.BasicSubNode.FabaoTuJian and self.m_CurSelectRank == 0 then
    self.m_CurSelectRank = DEFAULT_RANK
  end
end
def.method().UpdateUI = function(self)
  self:UpdateData()
  self:UpdateCurShowFabaoView()
  self:UpdateLeftView()
  self:UpdateRightView()
end
def.method().UpdateCurShowFabaoView = function(self)
  if nil == self.m_UIObjs then
    return
  end
  self.m_CurDisPlayFabao = FabaoData.Instance():GetCurDisplayFabao()
  if not self.m_ShowSelectList then
    self.m_UIObjs.disPlayTypeChooseList:SetActive(false)
  else
    self.m_UIObjs.disPlayTypeChooseList:SetActive(true)
  end
  local showName = textRes.Fabao[82]
  if nil ~= self.m_CurDisPlayFabao and nil ~= self.m_CurDisPlayFabao.fabaoData then
    local fabaodata = self.m_CurDisPlayFabao.fabaoData
    showName = ItemUtils.GetItemBase(fabaodata.id).name
  end
  local equipedLQClsId = FabaoSpiritModule.GetEquipedLQClsId()
  if equipedLQClsId ~= 0 then
    local LQBasicInfo = FabaoSpiritInterface.GetOwnLQBasicInfoByClsId(equipedLQClsId)
    if LQBasicInfo ~= nil then
      showName = LQBasicInfo.name
    end
  end
  self.m_UIObjs.displayFabaoLabel:GetComponent("UILabel"):set_text(showName)
end
def.method().UpdateLeftView = function(self)
  if nil == self.m_UIObjs then
    return
  end
  local allFabao = FabaoData.Instance():GetAllFabaoData()
  local allLingJing = FabaoData.Instance():GetAllLongJingData()
  if allFabao then
    for i = 1, 6 do
      local fabaoNode = self.m_UIObjs.FabaoNodes[i]
      local bgSprite = fabaoNode:FindDirect("Img_FabaoDi")
      local fabaoTexture = fabaoNode:FindDirect("Img_FabaoDi/Icon_Fabao_1")
      local fabaoAddTexture = fabaoNode:FindDirect("Img_FabaoDi/Img_Add")
      local fabaoInfo = allFabao[i]
      if fabaoInfo then
        local fabaoId = fabaoInfo.id
        local itemBase = ItemUtils.GetItemBase(fabaoId)
        local namecolor = itemBase.namecolor
        local iconId = itemBase.icon
        bgSprite:GetComponent("UISprite"):set_spriteName(string.format("Cell_%02d", namecolor))
        GUIUtils.FillIcon(fabaoTexture:GetComponent("UITexture"), iconId)
        fabaoAddTexture:SetActive(false)
      else
        bgSprite:GetComponent("UISprite"):set_spriteName("Cell_00")
        fabaoTexture:GetComponent("UITexture").mainTexture = nil
        fabaoAddTexture:SetActive(true)
      end
    end
  end
  if allLingJing then
    for fabaoType, Info in pairs(allLingJing) do
      local fabaoNode = self.m_UIObjs.FabaoNodes[fabaoType]
      local slots = {}
      if fabaoNode and not fabaoNode.isnil then
        for i = 1, 3 do
          slots[i] = fabaoNode:FindDirect(string.format("Img_Slot_%d/Img_SlotIcon", i))
        end
      end
      for i = 1, 3 do
        if slots[i] and not slots[i].isnil then
          local longjingInfo = Info[i]
          if longjingInfo then
            local longjingId = longjingInfo.id
            local itemBase = ItemUtils.GetItemBase(longjingId)
            local iconId = itemBase.icon
            GUIUtils.FillIcon(slots[i]:GetComponent("UITexture"), iconId)
          else
            slots[i]:GetComponent("UITexture").mainTexture = nil
          end
        end
      end
    end
  end
  self:UpdateFabaoExtraEffect()
end
def.method("=>", "number", "number").GetCurMinRankLevelAndFabaoCount = function(self)
  local allFabao = FabaoData.Instance():GetAllFabaoData()
  if not allFabao then
    return 0, 1
  end
  local minRank = 10
  local fabaoCount = 0
  for k, v in pairs(allFabao) do
    if v then
      fabaoCount = fabaoCount + 1
      local fabaoBase = ItemUtils.GetFabaoItem(v.id)
      local rank = fabaoBase.rank
      if minRank > rank then
        minRank = rank
      end
    end
  end
  return fabaoCount, minRank
end
def.method().UpdateFabaoExtraEffect = function(self)
  self.m_UIObjs.EffectLabel:FindDirect("Label_CombineAdd"):SetActive(false)
  local fabaoCount, minRank = self:GetCurMinRankLevelAndFabaoCount()
  local minEffectRankLevel = FabaoUtils.GetMinEffectFabaoLevel()
  if fabaoCount < 6 or minRank < minEffectRankLevel then
    self.m_UIObjs.EffectItem[1]:SetActive(true)
    self.m_UIObjs.EffectItem[2]:SetActive(false)
    self.m_UIObjs.EffectItem[3]:SetActive(false)
    local selectImg = self.m_UIObjs.EffectItem[1]:FindDirect("Img_Selected")
    local rankLevelLabel = self.m_UIObjs.EffectItem[1]:FindDirect("Label_Number")
    selectImg:SetActive(false)
    rankLevelLabel:GetComponent("UILabel"):set_text(string.format("%d%s", minEffectRankLevel, textRes.Fabao[71]))
  else
    local nextRankLevel, isMax = FabaoUtils.GetNextEffectFabaoLevel(minRank)
    local selectImg2 = self.m_UIObjs.EffectItem[2]:FindDirect("Img_Selected")
    local rankLevelLabel2 = self.m_UIObjs.EffectItem[2]:FindDirect("Label_Number")
    local selectImg3 = self.m_UIObjs.EffectItem[3]:FindDirect("Img_Selected")
    local rankLevelLabel3 = self.m_UIObjs.EffectItem[3]:FindDirect("Label_Number")
    if not isMax then
      self.m_UIObjs.EffectItem[1]:SetActive(false)
      self.m_UIObjs.EffectItem[2]:SetActive(true)
      self.m_UIObjs.EffectItem[3]:SetActive(true)
      selectImg2:SetActive(true)
      rankLevelLabel2:GetComponent("UILabel"):set_text(string.format("%d%s", minRank, textRes.Fabao[71]))
      selectImg3:SetActive(false)
      rankLevelLabel3:GetComponent("UILabel"):set_text(string.format("%d%s", nextRankLevel, textRes.Fabao[71]))
    else
      self.m_UIObjs.EffectItem[1]:SetActive(false)
      self.m_UIObjs.EffectItem[2]:SetActive(false)
      self.m_UIObjs.EffectItem[3]:SetActive(true)
      selectImg3:SetActive(true)
      rankLevelLabel3:GetComponent("UILabel"):set_text(string.format("%d%s", nextRankLevel, textRes.Fabao[71]))
    end
  end
  GameUtil.AddGlobalLateTimer(0.01, true, function()
    if self.m_UIObjs and self.m_UIObjs.EffectGrid and not self.m_UIObjs.EffectGrid.isnil then
      local uiGrid = self.m_UIObjs.EffectGrid:GetComponent("UIGrid")
      uiGrid:Reposition()
    end
  end)
end
def.method().UpdateRightView = function(self)
  if nil == self.m_UIObjs then
    return
  end
  self:UpdateToggleState()
  self:UpdateRightChooseLableView()
  self:UpdateFabaoSelectList()
  self:UpdateFabaoListView()
end
def.method().UpdateRightChooseLableView = function(self)
  local typeLabel = self.m_node:FindDirect("Img_Shuxing/Label_Shuxing")
  local rankLabel = self.m_node:FindDirect("Img_Star/Label_Star")
  local typeName = textRes.Fabao.FabaoBaoTypeName[self.m_CurSelectNode] or " "
  local rankName = ""
  if self.m_CurSelectRank == 0 then
    rankName = textRes.Fabao[111]
  else
    rankName = string.format("%d %s", self.m_CurSelectRank, textRes.Fabao[71])
  end
  typeLabel:GetComponent("UILabel"):set_text(typeName)
  rankLabel:GetComponent("UILabel"):set_text(rankName)
end
def.method().UpdateFabaoSelectList = function(self)
  if self.m_ShowSelectFabaoRankList then
    self.m_UIObjs.SelectRankListView:SetActive(true)
    self:UpdateRightChooseView(2)
  else
    self.m_UIObjs.SelectRankListView:SetActive(false)
  end
  if self.m_ShowSelectFabaoTypeList then
    self.m_UIObjs.SelectTypeListView:SetActive(true)
    self:UpdateRightChooseView(1)
  else
    self.m_UIObjs.SelectTypeListView:SetActive(false)
  end
end
def.method("number").UpdateRightChooseView = function(self, select)
  local listView
  local itemNum = 0
  if 1 == select then
    listView = self.m_UIObjs.SelectTypeListView:FindDirect("Scroll View/Grid")
    itemNum = FABAO_TYPE_NUM
  elseif 2 == select then
    listView = self.m_UIObjs.SelectRankListView:FindDirect("Scroll View/Grid")
    if 0 == MAX_FABAO_RANK then
      MAX_FABAO_RANK = FabaoUtils.GetFabaoMaxRank()
    end
    itemNum = MAX_FABAO_RANK + 1
  end
  local items = GUIUtils.InitUIList(listView, itemNum, false)
  for i = 1, itemNum do
    local itemObj = items[i]
    if 1 == select then
      itemObj.name = string.format("fabaoTypeItem_%d", i)
    elseif 2 == select then
      itemObj.name = string.format("fabaoRankItem_%d", i)
    end
    local uiLabel = itemObj:FindDirect(string.format("Name_%d/Label_1_%d", i, i)):GetComponent("UILabel")
    if 1 == select then
      uiLabel:set_text(textRes.Fabao.FabaoBaoTypeName[i - 1])
    elseif 2 == select then
      if 1 == i then
        uiLabel:set_text(textRes.Fabao[111])
      else
        uiLabel:set_text(string.format("%d %s", i - 1, textRes.Fabao[71]))
      end
    end
  end
  self.m_base.m_msgHandler:Touch(listView)
  GUIUtils.Reposition(listView, "UIList", 0.01)
end
def.method().UpdateToggleState = function(self)
  local uiToggle
  if self.m_CurNode == FabaoSocialPanel.BasicSubNode.MyFabao then
    uiToggle = self.m_UIObjs.BasicSubTaps.MyFabao:GetComponent("UIToggle")
  else
    uiToggle = self.m_UIObjs.BasicSubTaps.AllFabao:GetComponent("UIToggle")
  end
  uiToggle.value = true
  for k, v in pairs(SelectNodeId) do
    if v == self.m_CurSelectNode then
      local tabName = k
      local tabBtn = self.m_UIObjs.FabaoSelectTapGroup:FindDirect(tabName)
      if tabBtn and not tabBtn.isnil then
        uiToggle = tabBtn:GetComponent("UIToggle")
        uiToggle.value = true
      end
      break
    end
  end
  uiToggle = nil
end
def.method().UpdateFabaoListView = function(self)
  local ListView = self.m_UIObjs.FabaoListView
  local fabaoNum = #self.m_CurAllFabao
  local listItem = GUIUtils.InitUIList(ListView, fabaoNum, false)
  for i = 1, fabaoNum do
    local itemObj = listItem[i]
    itemObj.name = string.format("fabaoItem_%d", i)
    local fabaoData = self.m_CurAllFabao[i]
    local bgSprite = itemObj:GetComponent("UISprite")
    local fabaoTexture = itemObj:FindDirect(string.format("Img_EquipIcon_%d", i)):GetComponent("UITexture")
    local starLabel = itemObj:FindDirect(string.format("Label_Star_%d", i)):GetComponent("UILabel")
    local newImg = itemObj:FindDirect(string.format("Img_New_%d", i))
    local numLabel = itemObj:FindDirect(string.format("Label_Num_%d", i))
    bgSprite:set_spriteName(string.format("Cell_%02d", fabaoData.namecolor))
    GUIUtils.FillIcon(fabaoTexture, fabaoData.iconId)
    if fabaoData.rank and fabaoData.rank > 0 then
      starLabel:set_text(string.format("%d%s", fabaoData.rank, textRes.Fabao[71]))
    else
      starLabel:set_text("")
    end
    if self.m_CurNode == FabaoSocialPanel.BasicSubNode.MyFabao then
      local fabaoKey = fabaoData.key
      local isNew = FabaoModule.Instance():GetFabaoNew(fabaoKey)
      newImg:SetActive(isNew)
    else
      newImg:SetActive(false)
    end
    if fabaoData.num and 1 < fabaoData.num then
      numLabel:SetActive(true)
      numLabel:GetComponent("UILabel"):set_text(tostring(fabaoData.num))
    else
      numLabel:SetActive(false)
    end
  end
  GUIUtils.Reposition(ListView, "UIList", 0.01)
  self.m_base.m_msgHandler:Touch(ListView)
  ListView:GetComponent("UIList"):DragToMakeVisible(0, 100)
  GameUtil.AddGlobalLateTimer(0.01, true, function()
    if self.m_UIObjs and self.m_UIObjs.FabaoScroolView and not self.m_UIObjs.FabaoScroolView.isnil then
      self.m_UIObjs.FabaoScroolView:GetComponent("UIScrollView"):ResetPosition()
    end
  end)
end
def.method().UpdateData = function(self)
  self.m_CurDisPlayFabao = FabaoData.Instance():GetCurDisplayFabao()
  if self.m_CurNode == FabaoSocialPanel.BasicSubNode.MyFabao then
    local FabaoModule = Lplus.ForwardDeclare("FabaoModule")
    self.m_CurAllFabao = FabaoModule.Instance():GetAllThingInFabaoBagByTypeAndRank(self.m_CurSelectNode, self.m_CurSelectRank)
  elseif self.m_CurNode == FabaoSocialPanel.BasicSubNode.FabaoTuJian then
    self.m_CurAllFabao = FabaoUtils.GetAllFabaoInCfgOnTypeAndRank(self.m_CurSelectNode, self.m_CurSelectRank)
  else
    self.m_CurAllFabao = {}
  end
end
def.method().UpdateChooseDisplayList = function(self)
  local chooseList = self.m_UIObjs.disPlayTypeChooseList:FindDirect("Scroll View/Grid")
  local allWearFabao = FabaoData.Instance():GetAllFabaoData()
  local myFabaoNum = 0
  local allFabao = {}
  if allWearFabao then
    for k, v in pairs(allWearFabao) do
      if v then
        local fabao = {}
        fabao.fabaoType = k
        fabao.fabaoInfo = v
        table.insert(allFabao, fabao)
        myFabaoNum = myFabaoNum + 1
      end
    end
  end
  if FabaoSpiritModule.CheckFeatureOpen() then
    local ownedLQBasicInfos = FabaoSpiritInterface.GetOwnedLQBasicInfos()
    for clsId, ownLQInfo in pairs(ownedLQBasicInfos) do
      local LQ = {}
      LQ.clsId = clsId
      LQ.Info = ownLQInfo
      warn("clsId", clsId, "ownLQInfo.name", ownLQInfo.name)
      table.insert(allFabao, LQ)
      myFabaoNum = myFabaoNum + 1
    end
  end
  local listItem = GUIUtils.InitUIList(chooseList, myFabaoNum, false)
  for i = 1, myFabaoNum do
    local itemObj = listItem[i]
    local fabaoNameLabel = itemObj:FindDirect(string.format("FabaoName_%d/Label_1_%d", i, i))
    local fabao = allFabao[i]
    if fabao.clsId == nil then
      local fabaoType = fabao.fabaoType
      local fabaoBase = ItemUtils.GetItemBase(fabao.fabaoInfo.id)
      local fabaoName = fabaoBase.name
      itemObj.name = string.format("DisplayFabaoItem_%d", fabaoType)
      fabaoNameLabel:GetComponent("UILabel"):set_text(fabaoName)
    else
      itemObj.name = string.format("DisplayFabaoItem_%d_%d", 0, fabao.clsId)
      fabaoNameLabel:GetComponent("UILabel"):set_text(fabao.Info.name)
    end
  end
  GUIUtils.Reposition(chooseList, "UIList", 0.01)
  self.m_base.m_msgHandler:Touch(chooseList)
  self.m_UIObjs.disPlayTypeChooseList:SetActive(true)
end
def.override("userdata").onClickObj = function(self, clickObj)
  local id = clickObj.name
  warn("oclickObj ~~~ ", id, clickObj.parent.name, self.m_ShowSelectList)
  if self.m_ShowSelectList and not string.find(id, "FabaoName_") then
    self.m_ShowSelectList = false
    self:UpdateCurShowFabaoView()
  end
  if self.m_ShowSelectFabaoTypeList and not string.find(id, "Name_") then
    self.m_ShowSelectFabaoTypeList = false
    self:UpdateFabaoSelectList()
  end
  if self.m_ShowSelectFabaoRankList and not string.find(id, "Name_") then
    self.m_ShowSelectFabaoRankList = false
    self:UpdateFabaoSelectList()
  end
  if "Img_ChooseBg" == clickObj.parent.name then
    local selectName = id
    self:SetSelectNodeId(selectName)
    self:UpdateData()
    self:UpdateRightView()
  elseif string.sub(id, 1, 5) == "Name_" then
    self:OnClickRightSelect(clickObj)
  elseif "Tap_My" == id then
    self:SetCurNodeId(FabaoSocialPanel.BasicSubNode.MyFabao)
    self.m_CurSelectNode = 0
    self.m_CurSelectRank = 0
    self:UpdateData()
    self:UpdateRightView()
  elseif "Tap_All" == id then
    self:SetCurNodeId(FabaoSocialPanel.BasicSubNode.FabaoTuJian)
    self.m_CurSelectNode = 0
    self.m_CurSelectRank = DEFAULT_RANK
    self:UpdateData()
    self:UpdateRightView()
  elseif string.find(id, "fabaoItem_") then
    local strs = string.split(id, "_")
    local index = tonumber(strs[2])
    if self.m_CurNode == FabaoSocialPanel.BasicSubNode.FabaoTuJian then
      self:OnClickFabaoSpecialTip(index, clickObj)
    else
      local fabao = self.m_CurAllFabao[index]
      local fabaoKey = fabao.key
      local FabaoModule = require("Main.Fabao.FabaoModule")
      FabaoModule.Instance():SetFabaoNew(fabaoKey, false)
      clickObj:FindDirect(string.format("Img_New_%d", index)):SetActive(false)
      self:OnClickFabaoWearTip(index, clickObj, true)
    end
  elseif "Img_FabaoDi" == id then
    self:OnClickFabaoSelect(clickObj)
  elseif "Btn_Change" == id then
    if not self.m_ShowSelectList then
      self:UpdateChooseDisplayList()
      self.m_ShowSelectList = true
    end
  elseif string.sub(id, 1, 10) == "FabaoName_" then
    local parentName = clickObj.parent.name
    local strs = string.split(parentName, "_")
    if strs[3] == nil then
      self:OnClickChooseList(tonumber(strs[2]))
    else
      self:OnClickChooseLQList(tonumber(strs[3]))
    end
  elseif "Btn_Tips" == id then
    local hoverTipId = FabaoUtils.GetFabaoEffectHoverTipId()
    GUIUtils.ShowHoverTip(hoverTipId, 0, 0)
  elseif string.find(id, "Img_Slot_") then
    self:OnClickLongjingSlot(clickObj)
  elseif "Btn_SelectStar" == id then
    self.m_ShowSelectFabaoRankList = true
    self:UpdateFabaoSelectList()
  elseif "Btn_SelectSX" == id then
    self.m_ShowSelectFabaoTypeList = true
    self:UpdateFabaoSelectList()
  elseif "FB_Item_" == string.sub(id, 1, 8) then
    self:OnClickFabaoEffectBtn(clickObj)
  end
end
def.method("userdata").OnClickFabaoEffectBtn = function(self, clickObj)
  warn("OnClickFabaoEffectBtn ~~~~~~~~~~~~ ", clickObj.name)
  local name = clickObj.name
  local strs = string.split(name, "_")
  local index = tonumber(strs[3])
  local pos = clickObj.position
  local screenPos = WorldPosToScreen(pos.x, pos.y)
  if 1 == index then
    local minEffectRankLevel = FabaoUtils.GetMinEffectFabaoLevel()
    FabaoUtils.ShowFabaoEffectTip(minEffectRankLevel, false, screenPos.x, screenPos.y)
  elseif 2 == index then
    local _, minRankLevel = self:GetCurMinRankLevelAndFabaoCount()
    FabaoUtils.ShowFabaoEffectTip(minRankLevel, true, screenPos.x, screenPos.y)
  elseif 3 == index then
    local _, minRankLevel = self:GetCurMinRankLevelAndFabaoCount()
    local nextRankLevel, isMax = FabaoUtils.GetNextEffectFabaoLevel(minRankLevel)
    FabaoUtils.ShowFabaoEffectTip(nextRankLevel, isMax and minRankLevel == nextRankLevel, screenPos.x, screenPos.y)
  end
end
def.method("userdata").OnClickRightSelect = function(self, clickObj)
  local parentName = clickObj.parent.name
  if string.find(parentName, "fabaoTypeItem_") then
    local strs = string.split(parentName, "_")
    local index = tonumber(strs[2]) - 1
    self.m_CurSelectNode = index
    self.m_ShowSelectFabaoTypeList = false
  elseif string.find(parentName, "fabaoRankItem_") then
    local strs = string.split(parentName, "_")
    local index = tonumber(strs[2])
    self.m_CurSelectRank = index - 1
    self.m_ShowSelectFabaoRankList = false
  end
  self:UpdateData()
  self:UpdateRightView()
end
def.method("userdata").OnClickLongjingSlot = function(self, clickObj)
  local parentName = clickObj.parent.name
  local name = clickObj.name
  if nil == string.find(parentName, "Fabao_") then
    return
  end
  local fabaoType = tonumber(string.split(parentName, "_")[2])
  local slotPos = tonumber(string.split(name, "_")[3])
  local longjingData = FabaoData.Instance():GetLongJingByTypeAndPos(fabaoType, slotPos)
  if longjingData then
    ItemTipsMgr.Instance():ShowLongJingSpecialTips(longjingData, fabaoType, slotPos, true, 0, 0, 0, 0, 0, false)
  else
    Toast(textRes.Fabao[100])
  end
end
def.method("userdata").OnClickFabaoSelect = function(self, clickObj)
  local parentObj = clickObj.parent
  local parentName = parentObj.name
  local strs = string.split(parentName, "_")
  local index = tonumber(strs[2])
  local fabaoData = FabaoData.Instance():GetFabaoByType(index)
  if fabaoData then
    self:OnClickFabaoWearTip(index, clickObj, false)
  else
    warn("to open wear selelct ui ~~~~ ")
    do
      local FabaoModule = require("Main.Fabao.FabaoModule")
      local selectFabao = FabaoModule.Instance():GetAllFabaoInBagByType(index)
      if 0 == #selectFabao then
        Toast(textRes.Fabao[93])
        return
      end
      local function callback(itemKey)
        if itemKey then
          FabaoModule.RequestWearOnFabao(itemKey)
        end
      end
      local FabaoSelectPanel = require("Main.Fabao.ui.FabaoSelectPanel")
      FabaoSelectPanel.Instance():ShowPanel(index, callback, textRes.Fabao[81], textRes.Fabao[94])
    end
  end
end
def.method("number").OnClickChooseList = function(self, index)
  warn("OnClickChooseList ~~~~~ ", index)
  self.m_ShowSelectList = false
  self.m_UIObjs.disPlayTypeChooseList:SetActive(false)
  local FabaoModule = require("Main.Fabao.FabaoModule")
  FabaoModule.RequestChangeDisplayFabao(index)
end
def.method("number").OnClickChooseLQList = function(self, clsId)
  self.m_ShowSelectList = false
  self.m_UIObjs.disPlayTypeChooseList:SetActive(false)
  local FabaoSpiritProtocols = require("Main.FabaoSpirit.FabaoSpiritProtocols")
  FabaoSpiritProtocols.SendEquipLQReq(clsId)
end
def.method("number", "userdata", "boolean").OnClickFabaoWearTip = function(self, index, clickObj, wearOn)
  if wearOn then
    local curFabao = self.m_CurAllFabao[index]
    if nil == curFabao then
      return
    end
    local FabaoModule = require("Main.Fabao.FabaoModule")
    local item = FabaoModule.GetFabaoItemInfo(curFabao.key, curFabao.fabaoType)
    item.key = curFabao.key
    local itemBase = ItemUtils.GetItemBase(curFabao.id)
    local ItemModule = require("Main.Item.ItemModule")
    ItemTipsMgr.Instance():ShowTips(item, ItemModule.FABAOBAG, curFabao.key, ItemTipsMgr.Source.FabaoBag, 0, 0, 0, 0, 0)
  else
    local fabaoType = index
    local fabaoData = FabaoData.Instance():GetFabaoByType(fabaoType)
    local fabaoId = fabaoData.id
    local itemBase = ItemUtils.GetItemBase(fabaoId)
    ItemTipsMgr.Instance():ShowFabaoWearTips(fabaoData, itemBase, -1, 0, 0, 0, 0, 0, true)
  end
end
def.method("number", "userdata").OnClickFabaoSpecialTip = function(self, index, clickObj)
  local curFabao = self.m_CurAllFabao[index]
  if nil == curFabao then
    return
  end
  local fabaoId = curFabao.id
  local position = self.m_node:FindDirect("Img_ListBg").position
  local screenPos = WorldPosToScreen(position.x, position.y)
  local sprite = self.m_node:FindDirect("Img_ListBg"):GetComponent("UISprite")
  local width = sprite:get_width()
  local height = sprite:get_height()
  warn("OnClickFabaoSpecialTip ~~~ ", fabaoId, ItemUtils.GetFabaoItem(fabaoId))
  ItemTipsMgr.Instance():ShowFabaoSpecialTip(fabaoId, false, screenPos.x, screenPos.y, width, height, 0, false)
end
def.method("string").SetSelectNodeId = function(self, selectName)
  warn("SetSelectNodeId ~~~~ ", selectName, SelectNodeId[selectName])
  self.m_CurSelectNode = SelectNodeId[selectName]
end
def.method("number").SetCurNodeId = function(self, nodeId)
  warn("SetCurNodeId ~~~ ", nodeId)
  self.m_CurNode = nodeId
end
FabaoBasicNode.Commit()
return FabaoBasicNode
