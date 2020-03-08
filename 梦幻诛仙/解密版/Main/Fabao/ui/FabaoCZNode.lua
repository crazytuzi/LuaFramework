local Lplus = require("Lplus")
local FabaoTabNode = require("Main.Fabao.ui.FabaoTabNode")
local ECPanelBase = require("GUI.ECPanelBase")
local GUIUtils = require("GUI.GUIUtils")
local ECUIModel = require("Model.ECUIModel")
local ItemXStoreType = require("netio.protocol.mzm.gsp.item.ItemXStoreType")
local FabaoSocialPanel = Lplus.ForwardDeclare("FabaoSocialPanel")
local FabaoModule = Lplus.ForwardDeclare("FabaoModule")
local FabaoUtils = require("Main.Fabao.FabaoUtils")
local ItemUtils = require("Main.Item.ItemUtils")
local ItemModule = require("Main.Item.ItemModule")
local FabaoSJSubNode = require("Main.Fabao.ui.FabaoSJSubNode")
local FabaoXLSubNode = require("Main.Fabao.ui.FabaoXLSubNode")
local FabaoSXSubNode = require("Main.Fabao.ui.FabaoSXSubNode")
local FabaoCZNode = Lplus.Extend(FabaoTabNode, "FabaoCZNode")
local def = FabaoCZNode.define
local SubNodes = {
  [1] = {TapName = "Tap_SJ", GroupName = "Group_SJ"},
  [2] = {TapName = "Tap_SX", GroupName = "Group_SX"},
  [3] = {TapName = "Tap_XL", GroupName = "Group_XL"}
}
def.field("number").m_CurNode = 0
def.field("table").m_Nodes = nil
def.field("table").m_UIObjs = nil
def.field("table").m_CurAllFabao = nil
def.field("number").m_CurSelectIndex = 0
def.override(ECPanelBase, "userdata").Init = function(self, base, node)
  FabaoTabNode.Init(self, base, node)
end
def.override().OnShow = function(self)
  warn("OnShow ~~~~~~~~~~ ")
  self:InitData()
  self:InitUI()
  self:UpdateLeftFabaoList()
  self:UpdateRedNotice()
  self:UpdateRightView()
end
def.override().OnHide = function(self)
  if self.m_UIObjs ~= nil and self.m_UIObjs.LeftFabaoList ~= nil then
    self.m_UIObjs.LeftFabaoList:SetActive(false)
  end
  self.m_UIObjs = nil
  self.m_CurAllFabao = nil
  if self.m_Nodes then
    for k, v in pairs(self.m_Nodes) do
      v:Hide()
    end
  end
  self.m_Nodes = nil
end
def.override("=>", "boolean").HasSubNode = function(self)
  return true
end
def.method().InitUI = function(self)
  if nil == self.m_UIObjs then
    self.m_UIObjs = {}
  end
  self.m_UIObjs.LeftFabaoList = self.m_panel:FindDirect("Img_Bg1/Group_List")
  self.m_UIObjs.LeftFabaoList:SetActive(true)
  self.m_UIObjs.SJGroup = self.m_node:FindDirect("Group_SJ")
  self.m_UIObjs.SXGroup = self.m_node:FindDirect("Group_SX")
  self.m_UIObjs.XLGroup = self.m_node:FindDirect("Group_XL")
  if nil == self.m_Nodes then
    self.m_Nodes = {}
    self.m_Nodes[FabaoSocialPanel.CZSubNode.LevelUp] = FabaoSJSubNode()
    self.m_Nodes[FabaoSocialPanel.CZSubNode.LevelUp]:Init(self.m_base, self.m_UIObjs.SJGroup)
    self.m_Nodes[FabaoSocialPanel.CZSubNode.StarUp] = FabaoSXSubNode()
    self.m_Nodes[FabaoSocialPanel.CZSubNode.StarUp]:Init(self.m_base, self.m_UIObjs.SXGroup)
    self.m_Nodes[FabaoSocialPanel.CZSubNode.SkillWash] = FabaoXLSubNode()
    self.m_Nodes[FabaoSocialPanel.CZSubNode.SkillWash]:Init(self.m_base, self.m_UIObjs.XLGroup)
  end
end
def.method().InitData = function(self)
  if 0 == self.m_CurNode then
    self.m_CurNode = FabaoSocialPanel.CZSubNode.LevelUp
  end
  local params = self.m_Params
  if params and params.czSubNode then
    self.m_CurNode = params.czSubNode
  end
  self.m_Params = nil
  if 0 == self.m_CurSelectIndex then
    self.m_CurSelectIndex = 1
  end
  self.m_CurAllFabao = require("Main.Fabao.FabaoModule").Instance():GetAllFabao()
end
def.method().UpdateLeftFabaoList = function(self)
  self:CheckFabaoList()
  local fabaoNum = #self.m_CurAllFabao
  local scroll = self.m_UIObjs.LeftFabaoList:FindDirect("Scroll View_List")
  local listView = scroll:FindDirect("Grid_List")
  local selectObj
  local listItem = GUIUtils.InitUIList(listView, fabaoNum, false)
  for i = 1, fabaoNum do
    local itemObj = listItem[i]
    itemObj.name = string.format("FabaoItem_%d", i)
    local fabaoData = self.m_CurAllFabao[i]
    local fabaoItemInfo = FabaoModule.GetFabaoItemInfo(fabaoData.key, fabaoData.fabaoType)
    if nil == fabaoItemInfo then
      return
    end
    local fabaoBase = ItemUtils.GetFabaoItem(fabaoItemInfo.id)
    local fabaoItemBase = ItemUtils.GetItemBase(fabaoItemInfo.id)
    local ImgWear = itemObj:FindDirect(string.format("Img_Wear_%d", i))
    local bgSprite = itemObj:FindDirect(string.format("Group_Icon_%d/Icon_BgEquip01_%d", i, i))
    local texture = itemObj:FindDirect(string.format("Group_Icon_%d/Icon_Equip01_%d", i, i))
    local levelLabel = itemObj:FindDirect(string.format("Label_Level_%d", i))
    local nameLabel = itemObj:FindDirect(string.format("Label_Name_%d", i))
    local red = itemObj:FindDirect(string.format("Img_Red_%d", i))
    ImgWear:SetActive(fabaoData.equiped)
    bgSprite:GetComponent("UISprite"):set_spriteName(string.format("Cell_%02d", fabaoItemBase.namecolor))
    GUIUtils.FillIcon(texture:GetComponent("UITexture"), fabaoItemBase.icon)
    nameLabel:GetComponent("UILabel"):set_text(fabaoItemBase.name)
    local ItemXStoreType = require("netio.protocol.mzm.gsp.item.ItemXStoreType")
    local fabaoLevel = fabaoItemInfo.extraMap[ItemXStoreType.FABAO_CUR_LV]
    levelLabel:GetComponent("UILabel"):set_text(string.format("%d%s", fabaoLevel, textRes.Fabao[12]))
    if i == self.m_CurSelectIndex then
      selectObj = itemObj
      itemObj:GetComponent("UIToggle").value = true
    end
    red:SetActive(FabaoModule.Instance():IsFabaoRed(fabaoItemInfo))
  end
  self.m_base.m_msgHandler:Touch(listView)
  GameUtil.AddGlobalTimer(0.01, true, function()
    if scroll.isnil or listView.isnil then
      return
    end
    listView:GetComponent("UIList"):Reposition()
    if selectObj and not selectObj.isnil then
      scroll:GetComponent("UIScrollView"):DragToMakeVisible(selectObj.transform, 1024)
    else
      scroll:GetComponent("UIScrollView"):ResetPosition()
    end
  end)
end
def.method().CheckFabaoList = function(self)
  if nil == self.m_CurAllFabao then
    return
  end
  local curFabao = self.m_CurAllFabao[self.m_CurSelectIndex]
  if nil == curFabao then
    return
  end
  local curFabaoInfo = FabaoModule.GetFabaoItemInfo(curFabao.key, curFabao.fabaoType)
  local curUuid = curFabaoInfo.uuid[1]
  local temp = {}
  for k, v in pairs(self.m_CurAllFabao) do
    local fabaoItemInfo = FabaoModule.GetFabaoItemInfo(v.key, v.fabaoType)
    if fabaoItemInfo then
      v.itemInfo = fabaoItemInfo
      table.insert(temp, v)
    end
  end
  self.m_CurAllFabao = temp
  temp = nil
  for k, v in pairs(self.m_CurAllFabao) do
    local fabaoItemInfo = FabaoModule.GetFabaoItemInfo(v.key, v.fabaoType)
    local uuid = fabaoItemInfo.uuid[1]
    if curUuid:eq(uuid) then
      self.m_CurSelectIndex = k
      break
    end
  end
  if self.m_CurSelectIndex > #self.m_CurAllFabao then
    self.m_CurSelectIndex = #self.m_CurAllFabao
  end
end
def.method("number").SetCurNode = function(self, nodeId)
  self.m_CurNode = nodeId
end
def.method("number").SetSelectIndex = function(self, index)
  self.m_CurSelectIndex = index
end
def.method().UpdateRedNotice = function(self)
  local redImg = self.m_node:FindDirect("Tap_SX/Img_New")
  local hasRedNotice = require("Main.Fabao.FabaoModule").Instance():CheckCZRedNotice()
  redImg:SetActive(hasRedNotice)
end
def.method().UpdateRightView = function(self)
  local curFabao = self.m_CurAllFabao[self.m_CurSelectIndex]
  local curNode = self.m_CurNode
  for k, v in pairs(SubNodes) do
    local TapObj = self.m_node:FindDirect(v.TapName)
    local GroupObj = self.m_node:FindDirect(v.GroupName)
    if k == curNode then
      TapObj:GetComponent("UIToggle").value = true
      self.m_Nodes[curNode]:Show(curFabao)
    else
      TapObj:GetComponent("UIToggle").value = false
      self.m_Nodes[k]:Hide()
    end
  end
end
def.override("userdata").onClickObj = function(self, clickObj)
  local id = clickObj.name
  if string.find(id, "FabaoItem_") then
    local strs = string.split(id, "_")
    local index = tonumber(strs[2])
    clickObj:GetComponent("UIToggle").value = true
    self:SetSelectIndex(index)
    self:UpdateRightView()
  elseif "Tap_SJ" == id then
    self:SetCurNode(FabaoSocialPanel.CZSubNode.LevelUp)
    self:UpdateRightView()
  elseif "Tap_SX" == id then
    self:SetCurNode(FabaoSocialPanel.CZSubNode.StarUp)
    self:UpdateRightView()
  elseif "Tap_XL" == id then
    self:SetCurNode(FabaoSocialPanel.CZSubNode.SkillWash)
    self:UpdateRightView()
  else
    self.m_Nodes[self.m_CurNode]:onClickObj(clickObj)
  end
end
def.method("table", "table").OnFabaoWearInfoChange = function(self, p1, p2)
  warn("OnFabaoWearInfoChange ~~~~~~~~~ ")
  if self.m_node and not self.m_node.isnil then
    self:UpdateLeftFabaoList()
    self:UpdateRedNotice()
    self.m_Nodes[self.m_CurNode]:Update()
  end
end
def.method("number", "number").OnSFabaoAddExpSucc = function(self, fabaoId, addExp)
  warn("OnSFabaoAddExpSucc  ~~~~~~~~~~~~~ ")
end
def.method("number", "number", "number").OnSFabaoLevelUp = function(self, fabaoId, oldLevel, curLevel)
  warn("OnSFabaoLevelUp  ~~~~~~~~~~~~~ ")
  if not self.m_node or self.m_node.isnil then
    return
  end
  local FabaoCommonPanel = require("Main.Fabao.ui.FabaoCommonPanel")
  local params = {}
  params.LevelUpInfo = {}
  params.LevelUpInfo.fabaoId = fabaoId
  params.LevelUpInfo.oldLevel = oldLevel
  params.LevelUpInfo.curLevel = curLevel
  FabaoCommonPanel.Instance():ShowPanel(FabaoCommonPanel.TypeDefine.FabaoLevelUp, params)
end
def.method("number", "table").OnYuanBaoPriceRes = function(self, uid, itemid2yuanbao)
  if self.m_node and not self.m_node.isnil then
    if self.m_CurNode == FabaoSocialPanel.CZSubNode.SkillWash then
      self.m_Nodes[FabaoSocialPanel.CZSubNode.SkillWash]:OnYuanBaoPriceRes(uid, itemid2yuanbao)
    elseif self.m_CurNode == FabaoSocialPanel.CZSubNode.StarUp then
      self.m_Nodes[FabaoSocialPanel.CZSubNode.StarUp]:OnYuanBaoPriceRes(uid, itemid2yuanbao)
    end
  end
end
def.method("number", "userdata", "number").OnSFabaoWashSucRes = function(self, equiped, fabaouuid, skillid)
  warn("OnSFabaoWashSucRes ~~~~~~~~~~~~~~ ")
  if self.m_node and not self.m_node.isnil and self.m_CurNode == FabaoSocialPanel.CZSubNode.SkillWash then
    self.m_Nodes[FabaoSocialPanel.CZSubNode.SkillWash]:OnFabaoWashSucRes()
  end
end
def.method("number", "userdata", "number").OnSFabaoReplaceWashSkillRes = function(self, equiped, fabaouuid, skillid)
  warn("OnSFabaoReplaceWashSkillRes ~~~~~~~~~~~~~~  ")
  if self.m_node and not self.m_node.isnil and self.m_CurNode == FabaoSocialPanel.CZSubNode.SkillWash then
    self.m_Nodes[FabaoSocialPanel.CZSubNode.SkillWash]:OnFabaoReplaceWashSkillRes()
  end
end
def.method("number", "number", "userdata", "number", "number").OnSFabaoUpRankSucRes = function(self, ownSkillid, rankSkillid, fabaouuid, equiped, targetFabaoId)
  local fabaoItemInfo = FabaoModule.GetFabaoItemInfoEx(equiped, fabaouuid)
  if nil == fabaoItemInfo then
    return
  end
  local params = {}
  params.StarUpInfo = {}
  params.StarUpInfo.skillId1 = ownSkillid
  params.StarUpInfo.skillId2 = rankSkillid
  params.StarUpInfo.fabaoId1 = fabaoItemInfo.id
  params.StarUpInfo.fabaoId2 = targetFabaoId > 0 and targetFabaoId or FabaoUtils.GetNextRankFabaoId(fabaoItemInfo.id)
  params.StarUpInfo.fabaoLevel = fabaoItemInfo.extraMap[ItemXStoreType.FABAO_CUR_LV]
  params.StarUpInfo.fabaouuid = fabaoItemInfo.uuid[1]
  params.StarUpInfo.equiped = equiped
  local FabaoCommonPanel = require("Main.Fabao.ui.FabaoCommonPanel")
  FabaoCommonPanel.Instance():ShowPanel(FabaoCommonPanel.TypeDefine.FabaoStarUp, params)
end
def.method("table", "table").OnBagInfoSynchronized = function(self, p1, p2)
  if p1 then
    if p1.bagId == ItemModule.FABAOBAG then
      if self.m_node and not self.m_node.isnil then
        self:UpdateLeftFabaoList()
        self:UpdateRedNotice()
        self.m_Nodes[self.m_CurNode]:Update()
      end
    elseif self.m_node and not self.m_node.isnil then
      self.m_Nodes[self.m_CurNode]:Update()
    end
  end
end
def.method().OnLevelUpLimitByRoleLv = function(self)
  if self.m_node and not self.m_node.isnil and self.m_CurNode == FabaoSocialPanel.CZSubNode.LevelUp then
    self.m_Nodes[FabaoSocialPanel.CZSubNode.LevelUp]:OnLevelUpLimitByRoleLv()
  end
end
FabaoCZNode.Commit()
return FabaoCZNode
