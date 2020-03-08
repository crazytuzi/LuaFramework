local Lplus = require("Lplus")
local TabNode = require("GUI.TabNode")
local GUIUtils = require("GUI.GUIUtils")
local RecallUtils = require("Main.Recall.RecallUtils")
local RecallData = require("Main.Recall.data.RecallData")
local RecallProtocols = require("Main.Recall.RecallProtocols")
local RecallAwardRebateNode = Lplus.Extend(TabNode, "RecallAwardRebateNode")
local def = RecallAwardRebateNode.define
local instance
def.static("=>", RecallAwardRebateNode).Instance = function()
  if instance == nil then
    instance = RecallAwardRebateNode()
  end
  return instance
end
def.field("boolean")._bInited = false
def.field("table")._uiObjs = nil
def.field("table")._bindedFriendList = nil
def.field("table")._headTextureList = nil
def.field("number")._todayLeftNum = 0
def.method("number", "userdata").Update = function(self, tabIdx, tab)
  if not self:IsUnlock() then
    warn("[RecallAwardRebateNode:Update] Featrue not open.")
    GUIUtils.SetActive(tab, false)
    GUIUtils.SetActive(self.m_node, false)
    if self.isShow then
      self:Hide()
    end
  else
    GUIUtils.SetActive(tab, true)
    local GetRecallAwardNode = require("Main.RelationShipChain.ui.GetRecallAwardNode")
    if tabIdx == GetRecallAwardNode.TAB.REBATE then
      RecallProtocols.SendCGetRecallRebateInfoReq()
      GameUtil.AddGlobalLateTimer(0, true, function()
        self:Show()
      end)
    elseif self.isShow then
      self:Hide()
    end
  end
end
def.method("=>", "boolean").IsUnlock = function(self)
  local bFeatrueOpen = require("Main.Recall.RecallModule").Instance():IsRebateOpen(false)
  if not bFeatrueOpen then
    return false
  else
    return true
  end
end
def.override().OnShow = function(self)
  self:InitUI()
  self:_ShowDesc()
  self:_UpdateUI()
  self:_HandleEventListeners(true)
end
def.method().InitUI = function(self)
  self._uiObjs = {}
  self._uiObjs.Group_NoData = self.m_node:FindDirect("Group_NoData")
  self._uiObjs.Group_Award = self.m_node:FindDirect("Reward")
  self._uiObjs.Label_RewardOne = self._uiObjs.Group_Award:FindDirect("Label_RewardOne")
  self._uiObjs.Label_RewardTwo = self._uiObjs.Group_Award:FindDirect("Label_RewardTwo")
  self._uiObjs.Label_YuanBao_Total = self._uiObjs.Group_Award:FindDirect("Img_MoneyBag/Label_Num_YuanBao")
  self._uiObjs.Label_YuanBao_Today = self._uiObjs.Group_Award:FindDirect("YuanBao_Rest/Img_BgNum/Label")
  self._uiObjs.Group_Friends = self.m_node:FindDirect("Friends")
  self._uiObjs.Scroll_View = self._uiObjs.Group_Friends:FindDirect("Players/Scroll View")
  self._uiObjs.uiScrollView = self._uiObjs.Scroll_View:GetComponent("UIScrollView")
  self._uiObjs.List_Players = self._uiObjs.Scroll_View:FindDirect("List_Players")
  self._uiObjs.uiList = self._uiObjs.List_Players:GetComponent("UIList")
  self._bInited = true
end
def.method()._ShowDesc = function(self)
  local desc1 = string.format(textRes.Recall.REBATE_DESC_1, RecallUtils.GetConst("REBATE_PERIOD"), RecallUtils.GetConst("RECHARGE_REBATE_PERCENT"))
  GUIUtils.SetText(self._uiObjs.Label_RewardOne, desc1)
  local desc2 = string.format(textRes.Recall.REBATE_DESC_2, RecallUtils.GetConst("YUAN_BAO_DRAW"))
  GUIUtils.SetText(self._uiObjs.Label_RewardTwo, desc2)
end
def.method()._UpdateUI = function(self)
  self._bindedFriendList = RecallData.Instance():GetBindedRecalledFriendList()
  local totalNum = RecallData.Instance():GetTotalRestRebateNum()
  if totalNum > 0 or self._bindedFriendList and #self._bindedFriendList > 0 then
    GUIUtils.SetActive(self._uiObjs.Group_NoData, false)
    GUIUtils.SetActive(self._uiObjs.Group_Award, true)
    GUIUtils.SetActive(self._uiObjs.Group_Friends, true)
    self:UpdateFriendList()
    self:UpdateRebate()
  else
    GUIUtils.SetActive(self._uiObjs.Group_NoData, true)
    GUIUtils.SetActive(self._uiObjs.Group_Award, false)
    GUIUtils.SetActive(self._uiObjs.Group_Friends, false)
  end
end
def.override().OnHide = function(self)
  self:_HandleEventListeners(false)
  if self._bInited then
    self:Reset()
    self._bInited = false
  end
end
def.method().Reset = function(self)
  if _G.IsNil(self._uiObjs) then
    return
  end
  self:ClearFriendList()
  self._bindedFriendList = nil
  self._uiObjs = nil
end
def.method().UpdateFriendList = function(self)
  self:ClearFriendList()
  local friendCount = self._bindedFriendList and #self._bindedFriendList or 0
  self._headTextureList = {}
  if friendCount > 0 then
    self._uiObjs.uiList.itemCount = friendCount
    self._uiObjs.uiList:Resize()
    self._uiObjs.uiList:Reposition()
    for idx, recalledFriendInfo in ipairs(self._bindedFriendList) do
      self:ShowFriendInfo(idx, recalledFriendInfo)
    end
  else
  end
end
def.method("number", "table").ShowFriendInfo = function(self, idx, recalledFriendInfo)
  local listItem = self._uiObjs.uiList.children[idx]
  if nil == listItem then
    warn("[ERROR][RecallAwardRebateNode:ShowFriendInfo] listItem nil at idx:", idx)
    return
  end
  if nil == recalledFriendInfo then
    warn("[ERROR][RecallAwardRebateNode:ShowFriendInfo] recalledFriendInfo nil at idx:", idx)
    return
  end
  local restRebateDay = recalledFriendInfo:GetRestRebateDay()
  local Label_RestDay = listItem:FindDirect("Label_RestDay")
  GUIUtils.SetText(Label_RestDay, string.format(textRes.Recall.REBATE_REST_DAY, restRebateDay))
  local Img_Head = listItem:FindDirect("Texture_IconGroup")
  local headURL = RecallUtils.ProcessHeadImgURL(recalledFriendInfo:GetFigureUrl())
  GUIUtils.FillTextureFromURL(Img_Head, headURL, function(tex2d)
    if self._headTextureList then
      table.insert(self._headTextureList, tex2d)
    end
  end)
  local Label_FriendName = listItem:FindDirect("Label_FriendName")
  GUIUtils.SetText(Label_FriendName, recalledFriendInfo:GetNickName())
end
def.method().ClearFriendList = function(self)
  if self._headTextureList and #self._headTextureList > 0 then
    for _, headTexture in pairs(self._headTextureList) do
      if headTexture ~= nil then
        headTexture:Destroy()
      end
    end
    self._headTextureList = nil
  end
  if not _G.IsNil(self._uiObjs) and not _G.IsNil(self._uiObjs.uiList) then
    self._uiObjs.uiList.itemCount = 0
    self._uiObjs.uiList:Resize()
    self._uiObjs.uiList:Reposition()
  end
end
def.method().UpdateRebate = function(self)
  local totalNum = RecallData.Instance():GetTotalRestRebateNum()
  self._todayLeftNum = RecallData.Instance():GetTodayLeftRebateNum()
  GUIUtils.SetText(self._uiObjs.Label_YuanBao_Total, totalNum)
  GUIUtils.SetText(self._uiObjs.Label_YuanBao_Today, self._todayLeftNum)
end
def.override("userdata").onClickObj = function(self, clickObj)
  local id = clickObj.name
  if id == "Btn_Question" then
    self:OnBtn_Help(id)
  elseif id == "Btn_Receive" then
    self:OnBtn_Receive(id)
  end
end
def.method("string").OnBtn_Help = function(self, id)
  GUIUtils.ShowHoverTip(RecallUtils.GetConst("REBATE_TIP_ID"), 0, 0)
end
def.method("string").OnBtn_Receive = function(self, id)
  warn("[RecallAwardRebateNode:OnBtn_Receive] On Btn_Receive clicked.")
  local fetchLevel = RecallUtils.GetConst("YUAN_BAO_MIN_LEVEL")
  if fetchLevel <= _G.GetHeroProp().level then
    if RecallData.Instance():GetTodayLeftRebateNum() > 0 then
      RecallProtocols.SendCGetRecallRebateReq(self._todayLeftNum)
    else
      Toast(textRes.Recall.FETCH_REBATE_FAIL_TODAY_NONE)
    end
  else
    local toast = string.format(textRes.Recall.FETCH_REBATE_FAIL_LOW_LEVEL, fetchLevel)
    Toast(toast)
  end
end
def.method("boolean")._HandleEventListeners = function(self, isRigister)
  local eventFunc
  if isRigister then
    eventFunc = Event.RegisterEvent
  else
    eventFunc = Event.UnregisterEvent
  end
  if eventFunc then
    eventFunc(ModuleId.RECALL, gmodule.notifyId.Recall.BINDED_FRIEND_REBATE_CHANGE, RecallAwardRebateNode.OnRabateChange)
  end
end
def.static("table", "table").OnRabateChange = function(params, context)
  warn("[RecallAwardRebateNode:OnRabateChange] Update FriendList.")
  local self = instance
  self:_UpdateUI()
end
return RecallAwardRebateNode.Commit()
