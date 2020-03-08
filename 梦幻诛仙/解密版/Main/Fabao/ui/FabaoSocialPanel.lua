local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local FabaoBasicNode = require("Main.Fabao.ui.FabaoBasicNode")
local FabaoCZNode = require("Main.Fabao.ui.FabaoCZNode")
local FabaoXQNode = require("Main.Fabao.ui.FabaoXQNode")
local FabaoSpiritNode = require("Main.FabaoSpirit.ui.FabaoSpiritNode")
local ItemModule = require("Main.Item.ItemModule")
local FabaoSocialPanel = Lplus.Extend(ECPanelBase, "FabaoSocialPanel")
local def = FabaoSocialPanel.define
def.const("table").BasicSubNode = {MyFabao = 1, FabaoTuJian = 2}
def.const("table").CZSubNode = {
  LevelUp = 1,
  StarUp = 2,
  SkillWash = 3
}
def.const("table").NodeId = {
  FabaoBasic = 1,
  FabaoCZ = 2,
  FabaoXQ = 3,
  FabaoSpirit = 4
}
def.field("number").m_CurNode = 0
def.field("table").m_Params = nil
def.field("table").m_FabaoNodes = nil
def.field("table").m_TapNodes = nil
local instance
def.static("=>", FabaoSocialPanel).Instance = function()
  if nil == instance then
    instance = FabaoSocialPanel()
    instance.m_TrigGC = true
    instance.m_TryIncLoadSpeed = true
  end
  return instance
end
def.method("=>", "boolean").CanOpenFabao = function(self)
  local heroLevel = require("Main.Hero.Interface").GetHeroProp().level
  local FabaoOpenLevel = require("Main.Fabao.FabaoUtils").GetFabaoConstValue("FABAO_OPEN_LEVEL") or 60
  if heroLevel < FabaoOpenLevel then
    Toast(textRes.Fabao[122]:format(FabaoOpenLevel))
    return false
  else
    return true
  end
end
def.method("number").ShowPanel = function(self, node)
  if not self:CanOpenFabao() then
    return
  end
  if self:IsShow() then
    self:SwitchToNode(node)
    return
  end
  if node == FabaoSocialPanel.NodeId.FabaoCZ and not self:CanOpenTap(node) then
    Toast(textRes.Fabao[99])
    return
  end
  self.m_CurNode = node
  self:CreatePanel(RESPATH.PREFAB_NEW_FABAO_PANEL, 1)
  self:SetModal(true)
end
def.method("number", "table").ShowPanelWithParams = function(self, node, params)
  if not self:CanOpenFabao() then
    return
  end
  if self:IsShow() then
    self.m_Params = params
    self:SwitchToNode(node)
    return
  end
  if node == FabaoSocialPanel.NodeId.FabaoCZ and not self:CanOpenTap(node) then
    Toast(textRes.Fabao[99])
    return
  end
  self.m_CurNode = node
  self.m_Params = params
  self:CreatePanel(RESPATH.PREFAB_NEW_FABAO_PANEL, 1)
  self:SetModal(true)
end
def.override().OnCreate = function(self)
  Event.RegisterEvent(ModuleId.FABAO, gmodule.notifyId.Fabao.FABAO_WEARINFO_CHANGE, FabaoSocialPanel.OnFabaoWearInfoChange)
  Event.RegisterEvent(ModuleId.FABAO, gmodule.notifyId.Fabao.LONGJING_QX_INFO_CHANGE, FabaoSocialPanel.OnLongJingInfoChange)
  Event.RegisterEvent(ModuleId.ITEM, gmodule.notifyId.item.Item_OnBagInfoSynchronized, FabaoSocialPanel.OnBagInfoSynchronized)
  Event.RegisterEvent(ModuleId.FABAO, gmodule.notifyId.Fabao.FABAO_DISPLAY_CHANGE, FabaoSocialPanel.OnFabaoDisplayChange)
  Event.RegisterEvent(ModuleId.FABAO_SPIRIT, gmodule.notifyId.FabaoSpirit.NoticeChange, FabaoSocialPanel.OnFabaoLQNoticeChange)
  Event.RegisterEvent(ModuleId.FABAO_SPIRIT, gmodule.notifyId.FabaoSpirit.FeatureChange, FabaoSocialPanel.OnFabaoLQNoticeChange)
  self:InitUI()
  self:FirstShowUI()
end
def.override("boolean").OnShow = function(self, s)
  if not s then
    return
  end
  if self.m_CurNode == FabaoSocialPanel.NodeId.FabaoCZ then
    self.m_FabaoNodes[FabaoSocialPanel.NodeId.FabaoCZ]:OnBagInfoSynchronized({
      bagId = ItemModule.FABAOBAG
    }, nil)
  elseif self.m_CurNode == FabaoSocialPanel.NodeId.FabaoXQ then
    self.m_FabaoNodes[FabaoSocialPanel.NodeId.FabaoXQ]:RepostionLongjingList()
  elseif self.m_CurNode == FabaoSocialPanel.NodeId.FabaoBasic then
    self.m_FabaoNodes[FabaoSocialPanel.NodeId.FabaoBasic]:UpdateUI()
  elseif self.m_CurNode == FabaoSocialPanel.NodeId.FabaoSpirit then
    self.m_FabaoNodes[FabaoSocialPanel.NodeId.FabaoSpirit]:UpdateUI()
  end
end
def.override().OnDestroy = function(self)
  Event.UnregisterEvent(ModuleId.FABAO, gmodule.notifyId.Fabao.FABAO_WEARINFO_CHANGE, FabaoSocialPanel.OnFabaoWearInfoChange)
  Event.UnregisterEvent(ModuleId.FABAO, gmodule.notifyId.Fabao.LONGJING_QX_INFO_CHANGE, FabaoSocialPanel.OnLongJingInfoChange)
  Event.UnregisterEvent(ModuleId.ITEM, gmodule.notifyId.item.Item_OnBagInfoSynchronized, FabaoSocialPanel.OnBagInfoSynchronized)
  Event.UnregisterEvent(ModuleId.FABAO, gmodule.notifyId.Fabao.FABAO_DISPLAY_CHANGE, FabaoSocialPanel.OnFabaoDisplayChange)
  Event.UnregisterEvent(ModuleId.FABAO_SPIRIT, gmodule.notifyId.FabaoSpirit.NoticeChange, FabaoSocialPanel.OnFabaoLQNoticeChange)
  Event.UnregisterEvent(ModuleId.FABAO_SPIRIT, gmodule.notifyId.FabaoSpirit.FeatureChange, FabaoSocialPanel.OnFabaoLQNoticeChange)
  self.m_FabaoNodes[self.m_CurNode]:Hide()
  self.m_CurNode = 0
  self.m_Params = nil
  self.m_FabaoNodes = nil
  self.m_TapNodes = nil
end
def.method().InitUI = function(self)
  if nil == self.m_FabaoNodes then
    self.m_FabaoNodes = {}
  end
  local nodeRoot = self.m_panel:FindDirect("Img_Bg1/FB")
  self.m_FabaoNodes[FabaoSocialPanel.NodeId.FabaoBasic] = FabaoBasicNode()
  self.m_FabaoNodes[FabaoSocialPanel.NodeId.FabaoBasic]:Init(self, nodeRoot)
  nodeRoot = self.m_panel:FindDirect("Img_Bg1/CZ")
  self.m_FabaoNodes[FabaoSocialPanel.NodeId.FabaoCZ] = FabaoCZNode()
  self.m_FabaoNodes[FabaoSocialPanel.NodeId.FabaoCZ]:Init(self, nodeRoot)
  nodeRoot = self.m_panel:FindDirect("Img_Bg1/XQ")
  self.m_FabaoNodes[FabaoSocialPanel.NodeId.FabaoXQ] = FabaoXQNode()
  self.m_FabaoNodes[FabaoSocialPanel.NodeId.FabaoXQ]:Init(self, nodeRoot)
  nodeRoot = self.m_panel:FindDirect("Img_Bg1/LQ")
  self.m_FabaoNodes[FabaoSocialPanel.NodeId.FabaoSpirit] = FabaoSpiritNode.Instance()
  self.m_FabaoNodes[FabaoSocialPanel.NodeId.FabaoSpirit]:Init(self, nodeRoot)
  nodeRoot = nil
  if nil == self.m_TapNodes then
    self.m_TapNodes = {}
  end
  self.m_TapNodes[FabaoSocialPanel.NodeId.FabaoBasic] = self.m_panel:FindDirect("Img_Bg1/Group_Tab/Tab_FB")
  self.m_TapNodes[FabaoSocialPanel.NodeId.FabaoCZ] = self.m_panel:FindDirect("Img_Bg1/Group_Tab/Tab_CZ")
  self.m_TapNodes[FabaoSocialPanel.NodeId.FabaoXQ] = self.m_panel:FindDirect("Img_Bg1/Group_Tab/Tab_XQ")
  self.m_TapNodes[FabaoSocialPanel.NodeId.FabaoSpirit] = self.m_panel:FindDirect("Img_Bg1/Group_Tab/Tab_LQ")
  self.m_panel:FindDirect("Img_Bg1/Group_List"):SetActive(false)
end
def.method().FirstShowUI = function(self)
  if 0 == self.m_CurNode then
    self.m_CurNode = FabaoSocialPanel.NodeId.FabaoBasic
  end
  self:UpdateRedNotice()
  self:CheckFeatureOpen()
  self:SwitchToNode(self.m_CurNode)
end
def.method().UpdateRedNotice = function(self)
  local xqRedImg = self.m_panel:FindDirect("Img_Bg1/Group_Tab/Tab_XQ/Img_Red")
  local xqRedNotice = require("Main.Fabao.FabaoModule").Instance():CheckXQRedNotice()
  xqRedImg:SetActive(xqRedNotice)
  local czRedImg = self.m_panel:FindDirect("Img_Bg1/Group_Tab/Tab_CZ/Img_New")
  local czRedNotice = require("Main.Fabao.FabaoModule").Instance():CheckCZRedNotice()
  czRedImg:SetActive(czRedNotice)
  local lqRedImg = self.m_panel:FindDirect("Img_Bg1/Group_Tab/Tab_LQ/Img_Red")
  local bRedNotice = require("Main.FabaoSpirit.FabaoSpiritModule").CheckLQRedNotice()
  lqRedImg:SetActive(bRedNotice)
end
def.method().CheckFeatureOpen = function(self)
  local lqTab = self.m_panel:FindDirect("Img_Bg1/Group_Tab/Tab_LQ")
  local bFeatureOpen = require("Main.FabaoSpirit.FabaoSpiritModule").CheckFeatureOpen()
  self.m_TapNodes[FabaoSocialPanel.NodeId.FabaoSpirit]:SetActive(bFeatureOpen)
  if not bFeatureOpen then
    if self.m_CurNode == FabaoSocialPanel.NodeId.FabaoSpirit then
      self.m_CurNode = FabaoSocialPanel.NodeId.FabaoBasic
    end
    self:SwitchToNode(self.m_CurNode)
  end
end
def.method("number", "=>", "boolean").CanOpenTap = function(self, targetNode)
  if targetNode == FabaoSocialPanel.NodeId.FabaoCZ then
    local FabaoInWear = require("Main.Fabao.data.FabaoData").Instance():GetAllFabaoData()
    local ItemType = require("consts.mzm.gsp.item.confbean.ItemType")
    local fabaoInBag = ItemModule.Instance():GetItemsByItemType(ItemModule.FABAOBAG, ItemType.FABAO_ITEM)
    local emptyInWear = false
    local emptyInBag = false
    local mathHelper = require("Common.MathHelper")
    if nil == FabaoInWear or 0 == mathHelper.CountTable(FabaoInWear) then
      emptyInWear = true
    end
    if nil == fabaoInBag or 0 == mathHelper.CountTable(fabaoInBag) then
      emptyInBag = true
    end
    return not emptyInWear or not emptyInBag
  else
    return true
  end
end
def.method("number").SwitchToNode = function(self, targetNode)
  for k, v in pairs(self.m_FabaoNodes) do
    if k == targetNode then
      self.m_CurNode = targetNode
      local tapNode = self.m_TapNodes[self.m_CurNode]
      tapNode:GetComponent("UIToggle").value = true
      v:ShowWithParams(self.m_Params)
      self.m_Params = nil
    else
      local tapNode = self.m_TapNodes[k]
      tapNode:GetComponent("UIToggle").value = false
      v:Hide()
    end
  end
end
def.method("userdata").onClickObj = function(self, clickObj)
  local id = clickObj.name
  if "Btn_Close" == id then
    self:DestroyPanel()
  elseif "Tab_FB" == id then
    self:SwitchToNode(FabaoSocialPanel.NodeId.FabaoBasic)
  elseif "Tab_CZ" == id then
    if not self:CanOpenTap(FabaoSocialPanel.NodeId.FabaoCZ) then
      Toast(textRes.Fabao[99])
      self:SwitchToNode(self.m_CurNode)
      return
    end
    self:SwitchToNode(FabaoSocialPanel.NodeId.FabaoCZ)
  elseif "Tab_XQ" == id then
    self:SwitchToNode(FabaoSocialPanel.NodeId.FabaoXQ)
  elseif "Tab_LQ" == id then
    self:SwitchToNode(FabaoSocialPanel.NodeId.FabaoSpirit)
  else
    self.m_FabaoNodes[self.m_CurNode]:onClickObj(clickObj)
  end
end
def.method("number", "table").OnYuanBaoPriceRes = function(self, uid, itemid2yuanbao)
  if self.m_panel and not self.m_panel.isnil and self.m_CurNode == FabaoSocialPanel.NodeId.FabaoCZ then
    self.m_FabaoNodes[self.m_CurNode]:OnYuanBaoPriceRes(uid, itemid2yuanbao)
  end
end
def.static("table", "table").OnFabaoWearInfoChange = function(p1, p2)
  warn(" FabaoSocialPanel OnFabaoWearInfoChange ~~~~~~~~~~~~")
  local self = FabaoSocialPanel.Instance()
  if self.m_panel and not self.m_panel.isnil then
    self:UpdateRedNotice()
    if self.m_CurNode == FabaoSocialPanel.NodeId.FabaoBasic then
      self.m_FabaoNodes[FabaoSocialPanel.NodeId.FabaoBasic]:UpdateUI()
    elseif self.m_CurNode == FabaoSocialPanel.NodeId.FabaoCZ then
      self.m_FabaoNodes[FabaoSocialPanel.NodeId.FabaoCZ]:OnFabaoWearInfoChange(p1, p2)
    end
  end
end
def.static("table", "table").OnLongJingInfoChange = function(p1, p2)
  local self = FabaoSocialPanel.Instance()
  if self.m_panel and not self.m_panel.isnil then
    self:UpdateRedNotice()
    if self.m_CurNode == FabaoSocialPanel.NodeId.FabaoBasic then
      self.m_FabaoNodes[FabaoSocialPanel.NodeId.FabaoBasic]:UpdateUI()
    elseif self.m_CurNode == FabaoSocialPanel.NodeId.FabaoXQ then
      self.m_FabaoNodes[FabaoSocialPanel.NodeId.FabaoXQ]:Update()
    end
  else
  end
end
def.static("table", "table").OnFabaoDisplayChange = function(p1, p2)
  local self = FabaoSocialPanel.Instance()
  if self.m_panel and not self.m_panel.isnil and self.m_CurNode == FabaoSocialPanel.NodeId.FabaoBasic then
    self.m_FabaoNodes[FabaoSocialPanel.NodeId.FabaoBasic]:UpdateCurShowFabaoView()
  end
end
def.static("table", "table").OnBagInfoSynchronized = function(p1, p2)
  warn(" FabaoSocialPanel OnBagInfoSynchronized ~~~~~~~~~~~~")
  local self = FabaoSocialPanel.Instance()
  if self.m_panel and not self.m_panel.isnil then
    self:UpdateRedNotice()
    if self.m_CurNode == FabaoSocialPanel.NodeId.FabaoCZ then
      self.m_FabaoNodes[FabaoSocialPanel.NodeId.FabaoCZ]:OnBagInfoSynchronized(p1, p2)
    elseif self.m_CurNode == FabaoSocialPanel.NodeId.FabaoBasic then
      if p1 and p1.bagId == ItemModule.FABAOBAG then
        self.m_FabaoNodes[FabaoSocialPanel.NodeId.FabaoBasic]:UpdateUI()
      end
    elseif self.m_CurNode == FabaoSocialPanel.NodeId.FabaoXQ then
      local nodeRoot = self.m_FabaoNodes[FabaoSocialPanel.NodeId.FabaoXQ].m_node
      if nodeRoot and not nodeRoot.isnil and nodeRoot:get_activeInHierarchy() then
        self.m_FabaoNodes[FabaoSocialPanel.NodeId.FabaoXQ]:Update()
      end
    end
  end
end
def.static("number", "number").OnSFabaoAddExpSucc = function(fabaoId, addExp)
  local self = FabaoSocialPanel.Instance()
  if self.m_panel and not self.m_panel.isnil and self.m_CurNode == FabaoSocialPanel.NodeId.FabaoCZ then
    self.m_FabaoNodes[FabaoSocialPanel.NodeId.FabaoCZ]:OnSFabaoAddExpSucc(fabaoId, addExp)
  end
end
def.static("number", "number", "number").OnSFabaoLevelUp = function(fabaoId, oldLevel, curLevel)
  local self = FabaoSocialPanel.Instance()
  if self.m_panel and not self.m_panel.isnil and self.m_CurNode == FabaoSocialPanel.NodeId.FabaoCZ then
    self.m_FabaoNodes[FabaoSocialPanel.NodeId.FabaoCZ]:OnSFabaoLevelUp(fabaoId, oldLevel, curLevel)
  end
end
def.static("number", "userdata", "number").OnSFabaoWashSucRes = function(equiped, fabaouuid, skillid)
  local self = FabaoSocialPanel.Instance()
  if self.m_panel and not self.m_panel.isnil and self.m_CurNode == FabaoSocialPanel.NodeId.FabaoCZ then
    self.m_FabaoNodes[FabaoSocialPanel.NodeId.FabaoCZ]:OnSFabaoWashSucRes(equiped, fabaouuid, skillid)
  end
end
def.static("number", "userdata", "number").OnSFabaoReplaceWashSkillRes = function(equiped, fabaouuid, skillid)
  local self = FabaoSocialPanel.Instance()
  if self.m_panel and not self.m_panel.isnil and self.m_CurNode == FabaoSocialPanel.NodeId.FabaoCZ then
    self.m_FabaoNodes[FabaoSocialPanel.NodeId.FabaoCZ]:OnSFabaoReplaceWashSkillRes(equiped, fabaouuid, skillid)
  end
end
def.static("number", "number", "userdata", "number", "number").OnSFabaoUpRankSucRes = function(ownSkillid, rankSkillid, fabaouuid, equiped, targetFabaoId)
  local self = FabaoSocialPanel.Instance()
  if self.m_panel and not self.m_panel.isnil and self.m_CurNode == FabaoSocialPanel.NodeId.FabaoCZ then
    self.m_FabaoNodes[FabaoSocialPanel.NodeId.FabaoCZ]:OnSFabaoUpRankSucRes(ownSkillid, rankSkillid, fabaouuid, equiped, targetFabaoId)
  end
end
def.static("number", "number").OnLongjingMountSucc = function(itemid, pos)
  local self = FabaoSocialPanel.Instance()
  if self.m_panel and not self.m_panel.isnil and self.m_CurNode == FabaoSocialPanel.NodeId.FabaoXQ then
    self.m_FabaoNodes[FabaoSocialPanel.NodeId.FabaoXQ]:OnLongjingMountSucc(itemid, pos)
  end
end
def.static().OnLevelUpLimitByRoleLv = function()
  local self = FabaoSocialPanel.Instance()
  if self.m_panel and not self.m_panel.isnil and self.m_CurNode == FabaoSocialPanel.NodeId.FabaoCZ then
    self.m_FabaoNodes[FabaoSocialPanel.NodeId.FabaoCZ]:OnLevelUpLimitByRoleLv()
  end
end
def.static("table", "table").OnFabaoLQNoticeChange = function(p, c)
  local self = FabaoSocialPanel.Instance()
  if not self:IsShow() then
    return
  end
  self:CheckFeatureOpen()
  self:UpdateRedNotice()
end
FabaoSocialPanel.Commit()
return FabaoSocialPanel
