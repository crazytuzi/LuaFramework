local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local ECMSDK = require("ProxySDK.ECMSDK")
local GUIUtils = require("GUI.GUIUtils")
local ItemUtils = require("Main.Item.ItemUtils")
local ItemTipsMgr = require("Main.Item.ItemTipsMgr")
local RelationShipChainMgr = require("Main.RelationShipChain.RelationShipChainMgr")
local CommonConfirmDlg = require("GUI.CommonConfirmDlg")
local RelationShipChainPanelNodeBase = require("Main.RelationShipChain.ui.RelationShipChainPanelNodeBase")
local RecallAwardActiveNode = require("Main.Recall.ui.RecallAwardActiveNode")
local RecallAwardRebateNode = require("Main.Recall.ui.RecallAwardRebateNode")
local RecallModule = require("Main.Recall.RecallModule")
local GetRecallAwardNode = Lplus.Extend(RelationShipChainPanelNodeBase, "GetRecallAwardNode")
local def = GetRecallAwardNode.define
def.const("table").TAB = {
  COMEBACK = 1,
  ACCUMLATELAND = 2,
  ACTIVE = 3,
  REBATE = 4
}
def.field("number").m_CurrentTab = 1
def.field("table").m_BigGiftAwardInfo = nil
def.field("table").m_ListData = nil
def.field("table").m_TipsData = nil
def.field("table")._nodes = nil
def.const("table").SubNodeInfos = {
  {
    ID = 3,
    Instance = RecallAwardActiveNode.Instance(),
    GroupName = "Group_TogetherBound",
    TabName = "Grid_Tab/Tab_3"
  },
  {
    ID = 4,
    Instance = RecallAwardRebateNode.Instance(),
    GroupName = "Group_FanLi",
    TabName = "Grid_Tab/Tab_4"
  }
}
local instance
def.static("=>", GetRecallAwardNode).Instance = function()
  if not instance then
    instance = GetRecallAwardNode()
  end
  return instance
end
def.static("table", "table").OnNotifyRecallFriendBigGiftAward = function(params)
  if instance.m_panel and not instance.m_panel.isnil then
    instance:UpdateBigGiftBtnView()
    instance:UpdateRedot()
  end
end
def.static("table", "table").OnNotifyRecallFriendSignAward = function(params)
  if instance.m_panel and not instance.m_panel.isnil then
    instance:UpdateComeBackDaiySignPage()
    instance:UpdateRedot()
  end
end
def.override(ECPanelBase, "userdata").Init = function(self, base, node)
  RelationShipChainPanelNodeBase.Init(self, base, node)
end
def.override().OnShow = function(self)
  self:InitData()
  self:Update()
  Event.RegisterEvent(ModuleId.RELATIONSHIPCHAIN, gmodule.notifyId.RelationShipChain.NotifyRecallFriendBigGiftAward, GetRecallAwardNode.OnNotifyRecallFriendBigGiftAward)
  Event.RegisterEvent(ModuleId.RELATIONSHIPCHAIN, gmodule.notifyId.RelationShipChain.NotifyRecallFriendSignAward, GetRecallAwardNode.OnNotifyRecallFriendSignAward)
  Event.RegisterEvent(ModuleId.RECALL, gmodule.notifyId.Recall.RECALL_AFK_INFO_CHANGE, GetRecallAwardNode.OnAwardInfoChange)
  Event.RegisterEvent(ModuleId.RECALL, gmodule.notifyId.Recall.HERO_RETURN_INFO_CHANGE, GetRecallAwardNode.OnAwardInfoChange)
  Event.RegisterEvent(ModuleId.RECALL, gmodule.notifyId.Recall.BINDED_FRIEND_ACTIVE_CHANGE, GetRecallAwardNode.OnAwardInfoChange)
  Event.RegisterEvent(ModuleId.RECALL, gmodule.notifyId.Recall.BINDED_FRIEND_REBATE_CHANGE, GetRecallAwardNode.OnAwardInfoChange)
end
def.override().OnHide = function(self)
  self:Clear()
  Event.UnregisterEvent(ModuleId.RELATIONSHIPCHAIN, gmodule.notifyId.RelationShipChain.NotifyRecallFriendBigGiftAward, GetRecallAwardNode.OnNotifyRecallFriendBigGiftAward)
  Event.UnregisterEvent(ModuleId.RELATIONSHIPCHAIN, gmodule.notifyId.RelationShipChain.NotifyRecallFriendSignAward, GetRecallAwardNode.OnNotifyRecallFriendSignAward)
  Event.UnregisterEvent(ModuleId.RECALL, gmodule.notifyId.Recall.RECALL_AFK_INFO_CHANGE, GetRecallAwardNode.OnAwardInfoChange)
  Event.UnregisterEvent(ModuleId.RECALL, gmodule.notifyId.Recall.HERO_RETURN_INFO_CHANGE, GetRecallAwardNode.OnAwardInfoChange)
  Event.UnregisterEvent(ModuleId.RECALL, gmodule.notifyId.Recall.BINDED_FRIEND_ACTIVE_CHANGE, GetRecallAwardNode.OnAwardInfoChange)
  Event.UnregisterEvent(ModuleId.RECALL, gmodule.notifyId.Recall.BINDED_FRIEND_REBATE_CHANGE, GetRecallAwardNode.OnAwardInfoChange)
end
def.override().Clear = function(self)
  if self._nodes then
    local node = self._nodes[self.m_CurrentTab]
    if not _G.IsNil(node) and node.isShow then
      node:Hide()
    end
    self._nodes = nil
  end
  RelationShipChainPanelNodeBase.Clear(self)
  self.m_BigGiftAwardInfo = nil
  self.m_ListData = nil
  self.m_TipsData = nil
end
def.override("=>", "boolean").IsUnlock = function(self)
  if RelationShipChainMgr.IsRecallPlayer() then
    return true
  else
    local result = false
    for k, v in ipairs(GetRecallAwardNode.SubNodeInfos) do
      local instance = v.Instance
      if instance and instance:IsUnlock() then
        result = true
        break
      end
    end
    return result
  end
end
def.method("number").ShowTips = function(self, index)
  local data = self.m_TipsData[index]
  if data then
    ItemTipsMgr.Instance():ShowBasicTipsWithGO(data.id, data.go, 1, true)
  end
end
def.override("userdata").onClickObj = function(self, clickobj)
  local id = clickobj.name
  if id == "Tab_1" then
    self.m_CurrentTab = GetRecallAwardNode.TAB.COMEBACK
    self:Update()
  elseif id == "Tab_2" then
    self.m_CurrentTab = GetRecallAwardNode.TAB.ACCUMLATELAND
    self:Update()
  elseif id == "Tab_3" then
    self.m_CurrentTab = GetRecallAwardNode.TAB.ACTIVE
    self:Update()
  elseif id == "Tab_4" then
    self.m_CurrentTab = GetRecallAwardNode.TAB.REBATE
    self:Update()
  elseif id == "Btn_LingQu" then
    RelationShipChainMgr.GetRecallFriendsBigGiftAward({})
  elseif id == "Btn_Get" then
    local index = tonumber(clickobj.parent.parent.name:sub(-1, -1))
    if index then
      self:GetRecallSignAward(index)
    end
  elseif id:find("Img_BgIcon") == 1 then
    local index = tonumber(id:sub(-1, -1))
    if self.m_CurrentTab == GetRecallAwardNode.TAB.ACCUMLATELAND then
      local itemIndex = tonumber(clickobj.parent.parent.name:sub(-1, -1))
      index = itemIndex * 10 + index
    end
    self:ShowTips(index)
  else
    local node = self._nodes[self.m_CurrentTab]
    if node then
      node:onClickObj(clickobj)
    else
    end
  end
end
def.method("number").GetRecallSignAward = function(self, index)
  RelationShipChainMgr.GetRecallFriendSignAward({sign_day = index})
end
def.method().UpdateRedot = function(self)
  if RecallModule.Instance():IsOpen(false) then
    self:UpdateRedotNew()
  else
    self:UpdateRedotOld()
  end
end
def.method().UpdateRedotOld = function(self)
  local redDotGO1 = self.m_node:FindDirect("Grid_Tab/Tab_1/Img_Red")
  GUIUtils.SetActive(redDotGO1, RelationShipChainMgr.GetBigGiftAwardState() == 0)
  GameUtil.AddGlobalLateTimer(0.7, true, function()
    if not self.m_node or self.m_node.isnil then
      return
    end
    local redDotGO2 = self.m_node:FindDirect("Grid_Tab/Tab_2/Img_Red")
    GUIUtils.SetActive(redDotGO2, RelationShipChainMgr.CanGetRecallFriendSignAward())
  end)
end
def.method().InitData = function(self)
  local hasBigGift = RelationShipChainMgr.GetBigGiftAwardState() == 0
  self.m_CurrentTab = hasBigGift and GetRecallAwardNode.TAB.COMEBACK or GetRecallAwardNode.TAB.ACCUMLATELAND
  local awardID = RelationShipChainMgr.GetRecallFriendConstant("BIG_GIFT_RECALL_AWARD_ID")
  local awardCfg = ItemUtils.GetGiftAwardCfgByAwardId(awardID)
  self.m_BigGiftAwardInfo = awardCfg.itemList
  self.m_ListData = RelationShipChainMgr.GetRecallFriendSignAwardCfg()
end
def.override().InitUI = function(self)
  RelationShipChainPanelNodeBase.InitUI(self)
  self.m_UIGO = {}
  self.m_UIGO.Grid_Tab = self.m_node:FindDirect("Grid_Tab")
  self.m_UIGO.Group_LeiDeng = self.m_node:FindDirect("Group_LeiDeng")
  self.m_UIGO.Group_GiftBag = self.m_node:FindDirect("Group_GiftBag")
  self.m_UIGO.List_LeiDeng = self.m_UIGO.Group_LeiDeng:FindDirect("Scroll View_LeiDeng/List_LeiDeng")
  self.m_UIGO.Group_TogetherBound = self.m_node:FindDirect("Group_TogetherBound")
  self.m_UIGO.Group_FanLi = self.m_node:FindDirect("Group_FanLi")
  self._nodes = {}
  for k, v in ipairs(GetRecallAwardNode.SubNodeInfos) do
    local instance = v.Instance
    local groupGO = self.m_node:FindDirect(v.GroupName)
    local tabGO = self.m_node:FindDirect(v.TabName)
    self._nodes[v.ID] = instance
    self._nodes[v.ID]:Init(self.m_base, groupGO)
  end
end
def.method().UpdateBigGiftBtnView = function(self)
  GUIUtils.SetActive(self.m_UIGO.Group_GiftBag:FindDirect("Btn_LingQu"), RelationShipChainMgr.GetBigGiftAwardState() == 0)
  GUIUtils.SetActive(self.m_UIGO.Group_GiftBag:FindDirect("Img_HaveLing"), RelationShipChainMgr.GetBigGiftAwardState() ~= 0)
end
def.method().UpdateBigGiftPage = function(self)
  if not self.m_BigGiftAwardInfo then
    return
  end
  local gridGO = self.m_UIGO.Group_GiftBag:FindDirect("Grid_Items")
  self.m_TipsData = {}
  for i = 1, 8 do
    local itemData = self.m_BigGiftAwardInfo[i]
    local itemGO = gridGO:FindDirect(("Img_BgIcon%d"):format(i))
    if itemData then
      GUIUtils.SetActive(itemGO, true)
      local textureGO = itemGO:FindDirect("Texture_Icon")
      local numGO = itemGO:FindDirect("Label_Num")
      local nameGO = itemGO:FindDirect("Label_Name2")
      local baseData = ItemUtils.GetItemBase(itemData.itemId)
      GUIUtils.SetTexture(textureGO, baseData.icon)
      GUIUtils.SetText(numGO, itemData.num)
      GUIUtils.SetTextAndColor(nameGO, baseData.name, Color.Red)
      self.m_TipsData[i] = {
        id = itemData.itemId,
        go = itemGO
      }
    else
      GUIUtils.SetActive(itemGO, false)
    end
  end
  self:UpdateBigGiftBtnView()
end
def.method().UpdateComeBackDaiySignPage = function(self)
  if not self.m_ListData then
    return
  end
  local scrollListObj = self.m_UIGO.List_LeiDeng
  local GUIScrollList = scrollListObj:GetComponent("GUIScrollList")
  if not GUIScrollList then
    scrollListObj:AddComponent("GUIScrollList")
  end
  local uiScrollList = scrollListObj:GetComponent("UIScrollList")
  self.m_TipsData = {}
  ScrollList_setUpdateFunc(uiScrollList, function(item, i)
    item.name = "item_" .. i
    self:FillListInfo(item, i, self.m_ListData[i])
  end)
  ScrollList_setCount(uiScrollList, #self.m_ListData)
  self.m_base.m_msgHandler:Touch(scrollListObj)
end
def.method("userdata", "number", "table").FillListInfo = function(self, item, index, listData)
  local numGO = item:FindDirect("Img_Ti/Label_Num")
  local tipGO = item:FindDirect("Label_Tip")
  local alreadyGetGO = item:FindDirect("Goup_Ling/Img_YiLing")
  local btnGetGO = item:FindDirect("Goup_Ling/Btn_Get")
  local dateGO = item:FindDirect("Goup_Ling/Group_Date")
  local outDateGO = item:FindDirect("Goup_Ling/Img_YiYuQi")
  local awardID = listData.awardId
  local signAwardData = RelationShipChainMgr.GetRecallFriendSignAwardData()
  GUIUtils.SetText(numGO, listData.signDay)
  GUIUtils.SetText(tipGO, listData.desc)
  GUIUtils.SetActive(dateGO, false)
  GUIUtils.SetActive(outDateGO, signAwardData[index] == 1)
  GUIUtils.SetActive(alreadyGetGO, signAwardData[index] == 3)
  GUIUtils.SetCollider(btnGetGO, signAwardData[index] == 0)
  GUIUtils.SetActive(btnGetGO, false)
  GUIUtils.SetActive(btnGetGO, signAwardData[index] == 0 or signAwardData[index] == 2)
  local awardCfg = ItemUtils.GetGiftAwardCfgByAwardId(awardID)
  local groupIconGO = item:FindDirect("Group_Icon")
  for i = 1, 3 do
    local itemData = awardCfg.itemList[i]
    local imgBg = groupIconGO:FindDirect(("Img_BgIcon%d"):format(i))
    local textureGO = imgBg:FindDirect("Texture_Icon")
    local itemNumGO = imgBg:FindDirect("Label_Num")
    GUIUtils.SetActive(imgBg, itemData ~= nil)
    if itemData then
      local baseData = ItemUtils.GetItemBase(itemData.itemId)
      GUIUtils.SetTexture(textureGO, baseData.icon)
      GUIUtils.SetText(itemNumGO, itemData.num)
      self.m_TipsData[index * 10 + i] = {
        id = itemData.itemId,
        go = imgBg
      }
    end
  end
end
def.method().Update = function(self)
  local bHeroReturn = RelationShipChainMgr.IsRecallPlayer()
  if bHeroReturn then
    local bBigGiftOpen = RelationShipChainMgr.GetBigGiftAwardState() == 0
    GUIUtils.SetActive(self.m_UIGO.Grid_Tab:FindDirect("Tab_1"), bBigGiftOpen)
    if not bBigGiftOpen and self.m_CurrentTab == GetRecallAwardNode.TAB.COMEBACK then
      self.m_CurrentTab = GetRecallAwardNode.TAB.ACCUMLATELAND
    end
    GUIUtils.SetActive(self.m_UIGO.Grid_Tab:FindDirect("Tab_2"), true)
    GUIUtils.SetActive(self.m_UIGO.Group_LeiDeng, self.m_CurrentTab == GetRecallAwardNode.TAB.ACCUMLATELAND)
    GUIUtils.SetActive(self.m_UIGO.Group_GiftBag, self.m_CurrentTab == GetRecallAwardNode.TAB.COMEBACK)
    GUIUtils.Toggle(self.m_UIGO.Grid_Tab:FindDirect("Tab_1"), self.m_CurrentTab == GetRecallAwardNode.TAB.COMEBACK)
    GUIUtils.Toggle(self.m_UIGO.Grid_Tab:FindDirect("Tab_2"), self.m_CurrentTab == GetRecallAwardNode.TAB.ACCUMLATELAND)
    if self.m_CurrentTab == GetRecallAwardNode.TAB.COMEBACK then
      self:UpdateBigGiftPage()
    elseif self.m_CurrentTab == GetRecallAwardNode.TAB.ACCUMLATELAND then
      self:UpdateComeBackDaiySignPage()
    end
  else
    GUIUtils.SetActive(self.m_UIGO.Grid_Tab:FindDirect("Tab_1"), false)
    GUIUtils.SetActive(self.m_UIGO.Grid_Tab:FindDirect("Tab_2"), false)
    GUIUtils.SetActive(self.m_UIGO.Group_LeiDeng, false)
    GUIUtils.SetActive(self.m_UIGO.Group_GiftBag, false)
    if self.m_CurrentTab == GetRecallAwardNode.TAB.ACCUMLATELAND or self.m_CurrentTab == GetRecallAwardNode.TAB.COMEBACK then
      self.m_CurrentTab = GetRecallAwardNode.TAB.ACTIVE
    end
  end
  if self.m_CurrentTab == GetRecallAwardNode.TAB.ACTIVE then
    local node = self._nodes[GetRecallAwardNode.TAB.ACTIVE]
    if _G.IsNil(node) or not node:IsUnlock() then
      self.m_CurrentTab = GetRecallAwardNode.TAB.REBATE
    end
  end
  for k, v in ipairs(GetRecallAwardNode.SubNodeInfos) do
    local instance = v.Instance
    if instance then
      local tabGO = self.m_node:FindDirect(v.TabName)
      GUIUtils.Toggle(tabGO, self.m_CurrentTab == v.ID)
      instance:Update(self.m_CurrentTab, self.m_node:FindDirect(v.TabName))
    end
  end
  GUIUtils.Reposition(self.m_UIGO.Grid_Tab, "UIGrid", 0)
end
def.static("table", "table").OnAwardInfoChange = function(param, context)
  local self = GetRecallAwardNode.Instance()
  self:UpdateRedotNew()
end
def.method().UpdateRedotNew = function(self)
  if _G.IsNil(self.m_node) then
    return
  end
  local Img_Red_LeiDeng = self.m_node:FindDirect("Grid_Tab/Tab_2/Img_Red")
  local bGiftReddot = RecallModule.Instance():NeedGiftReddot()
  GUIUtils.SetActive(Img_Red_GiftBag, bGiftReddot)
  local Img_Red_GiftBag = self.m_node:FindDirect("Grid_Tab/Tab_1/Img_Red")
  local bLoginReddot = RecallModule.Instance():NeedLoginReddot()
  GUIUtils.SetActive(Img_Red_LeiDeng, bLoginReddot)
  local Img_Red_TogetherBound = self.m_node:FindDirect("Grid_Tab/Tab_3/Img_Red")
  local bActiveReddot = RecallModule.Instance():NeedActiveReddot()
  GUIUtils.SetActive(Img_Red_TogetherBound, bActiveReddot)
  local Img_Red_FanLi = self.m_node:FindDirect("Grid_Tab/Tab_4/Img_Red")
  local bRebateReddot = RecallModule.Instance():NeedRebateReddot()
  GUIUtils.SetActive(Img_Red_FanLi, bRebateReddot)
end
return GetRecallAwardNode.Commit()
