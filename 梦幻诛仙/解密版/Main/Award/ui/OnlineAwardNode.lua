local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local AwardPanelNodeBase = require("Main.Award.ui.AwardPanelNodeBase")
local OnlineAwardNode = Lplus.Extend(AwardPanelNodeBase, "OnlineAwardNode")
local ItemUtils = require("Main.Item.ItemUtils")
local OnlineAwardMgr = require("Main.Award.mgr.OnlineAwardMgr")
local EasyBasicItemTip = require("Main.Common.EasyBasicItemTip")
local GUIUtils = require("GUI.GUIUtils")
local GiftType = require("consts.mzm.gsp.signaward.confbean.GiftType")
local def = OnlineAwardNode.define
def.field(EasyBasicItemTip).itemTipHelper = nil
def.field("table").catchedAwardList = nil
def.field("table").catchedAwardState = nil
def.field("table").uiObjs = nil
def.override(ECPanelBase, "userdata").Init = function(self, base, node)
  AwardPanelNodeBase.Init(self, base, node)
  self.awardType = GiftType.ONLINE_AWARD
  self:SendRefreshOnlineTimeReq()
end
def.override().OnShow = function(self)
  self:InitUI()
  self:UpdateUI()
  Timer:RegisterListener(self.UpdateTimeLabels, self)
  Event.RegisterEvent(ModuleId.AWARD, gmodule.notifyId.Award.ONLINE_AWARD_UPDATE, OnlineAwardNode.OnOnlineAwardUpdate)
  Event.RegisterEvent(ModuleId.AWARD, gmodule.notifyId.Award.ONLINE_TIME_UPDATE, OnlineAwardNode.OnOnlineTimeUpdate)
end
def.override().OnHide = function(self)
  Event.UnregisterEvent(ModuleId.AWARD, gmodule.notifyId.Award.ONLINE_AWARD_UPDATE, OnlineAwardNode.OnOnlineAwardUpdate)
  Event.UnregisterEvent(ModuleId.AWARD, gmodule.notifyId.Award.ONLINE_TIME_UPDATE, OnlineAwardNode.OnOnlineTimeUpdate)
  Timer:RemoveListener(self.UpdateTimeLabels)
  self:Clear()
end
def.override("=>", "boolean").IsOpen = function(self)
  return OnlineAwardMgr.Instance():IsOpen()
end
def.override("userdata").onClickObj = function(self, obj)
  local id = obj.name
  if id == "Btn_Get" then
    local anchorId = obj.transform.parent.parent.gameObject.name
    local index = tonumber(string.sub(anchorId, #"item_" + 1, -1))
    self:OnDrawAwardButtonClicked(index)
  else
    self:onClick(id)
  end
end
def.override("string").onClick = function(self, id)
  if id == "Button_Tips" then
  elseif self.itemTipHelper:CheckItem2ShowTip(id, -1, false) then
  end
end
def.override("=>", "boolean").IsHaveNotifyMessage = function(self)
  return OnlineAwardMgr.Instance():IsHaveNotifyMessage()
end
def.override().InitUI = function(self)
  self.uiObjs = {}
  self.uiObjs.List_Online = self.m_node:FindDirect("Scroll View_Online/List_Online")
  self.uiObjs.Label_Time = self.m_node:FindDirect("Group_Top/Img_Bg/Label_Time")
  self.itemTipHelper = EasyBasicItemTip()
end
def.method().UpdateUI = function(self)
  self:UpdateAwardList()
  self:UpdateTimeLabels(0)
end
def.method("number").UpdateTimeLabels = function(self, dt)
  local curOnlineTime = OnlineAwardMgr.Instance():GetCurrentOnlineTime()
  if curOnlineTime <= 0 then
    return
  end
  self:UpdateOnlineTime(curOnlineTime)
end
def.method("number", "=>", "string").MakeTimeStr = function(self, timeVal)
  if timeVal < 0 then
    return ""
  end
  local hour = math.modf(timeVal / 3600)
  local min = math.modf((timeVal - hour * 3600) / 60)
  local sec = timeVal - hour * 3600 - min * 60
  local timeStr = string.format("%02d:%02d:%02d", hour, min, sec)
  return timeStr
end
def.method("number").UpdateOnlineTime = function(self, onlineTime)
  local timeStr = self:MakeTimeStr(onlineTime)
  self.uiObjs.Label_Time:GetComponent("UILabel"):set_text(timeStr)
end
def.method().UpdateAwardList = function(self)
  local awardList = OnlineAwardMgr.Instance():GetOverallAwardList()
  self.catchedAwardList = awardList
  local onlineAwardStates = OnlineAwardMgr.Instance():GetOnlineAwardState()
  self.catchedAwardState = onlineAwardStates
  self:SetAwardList()
end
def.method().SetAwardList = function(self)
  if self.catchedAwardState == nil or self.catchedAwardList == nil then
    return
  end
  local uiList = self.uiObjs.List_Online:GetComponent("UIList")
  uiList:set_itemCount(#self.catchedAwardList)
  uiList:Resize()
  uiList:Reposition()
  for i, award in ipairs(self.catchedAwardList) do
    self:SetAwardItems(i, award, self.catchedAwardState)
  end
  self.m_base:TouchGameObject(self.m_base.m_panel, self.m_base.m_parent)
  GameUtil.AddGlobalLateTimer(0, true, function()
    if not uiList.isnil then
      uiList:Reposition()
    end
  end)
end
def.method("number", "table", "table").SetAwardItems = function(self, index, award, onlineAwardStates)
  local listItem = self.uiObjs.List_Online:FindDirect("item_" .. index)
  local MAX_ITEM_PER_ROW = 3
  for i = 1, MAX_ITEM_PER_ROW do
    local Img_BgIcon = listItem:FindDirect(string.format("Group_Icon/Img_BgIcon%d", i))
    if Img_BgIcon then
      Img_BgIcon.name = "Img_BgIcon_" .. award.time .. "_" .. i
    else
      Img_BgIcon = listItem:FindDirect(string.format("Group_Icon/Img_BgIcon_%d_%d", award.time, i))
    end
    local item = award.items[i]
    if item then
      local itemId = item.itemId
      local itemBase = ItemUtils.GetItemBase(itemId)
      local iconId = itemBase.icon
      local uiTexture = Img_BgIcon:FindDirect("Texture_Icon"):GetComponent("UITexture")
      GUIUtils.FillIcon(uiTexture, iconId)
      local text = 1 < item.num and item.num or ""
      Img_BgIcon:FindDirect("Label_Num"):GetComponent("UILabel"):set_text(text)
      local quality = itemBase.namecolor
      local uiSprite = Img_BgIcon:GetComponent("UISprite")
      uiSprite:set_spriteName(string.format("Cell_%02d", quality))
      self.itemTipHelper:RegisterItem2ShowTip(itemId, Img_BgIcon)
      if onlineAwardStates.drawedTimes[award.time] then
        GUIUtils.SetTextureEffect(uiTexture, GUIUtils.Effect.Gray)
        uiSprite:set_spriteName("Cell_07")
      end
    else
      Img_BgIcon:SetActive(false)
    end
  end
  local Goup_Ling = listItem:FindDirect("Goup_Ling")
  Goup_Ling:FindDirect("Btn_Get"):SetActive(false)
  Goup_Ling:FindDirect("Img_YiLing"):SetActive(false)
  local Group_Info = Goup_Ling:FindDirect("Group_Info")
  Group_Info:SetActive(true)
  local uiLabelInfo = Group_Info:FindDirect("Label_Info"):GetComponent("UILabel")
  local timeStr = math.modf(award.time / 60)
  local awardStr = ItemUtils.GetItemBase(award.items[1].itemId).name
  uiLabelInfo:set_text(string.format(textRes.Award[69], timeStr, awardStr))
  if OnlineAwardMgr.Instance():IsDrawed(award.time) then
    Goup_Ling:FindDirect("Img_YiLing"):SetActive(true)
  else
    local Btn_Get = Goup_Ling:FindDirect("Btn_Get")
    Btn_Get:SetActive(true)
    local uiButton = Btn_Get:GetComponent("UIButton")
    if OnlineAwardMgr.Instance():CanDrawed(award.time) then
      uiButton:set_isEnabled(true)
      local scrollObj = self.uiObjs.List_Online.transform.parent.gameObject
      self:DragToMakeVisible(scrollObj, listItem, 4000)
    else
      uiButton:set_isEnabled(false)
    end
  end
end
def.method("number").OnDrawAwardButtonClicked = function(self, index)
  if self.catchedAwardList == nil then
    return
  end
  local award = self.catchedAwardList[index]
  if not award then
    return
  end
  local time = award.time
  if OnlineAwardMgr.Instance():CanDrawed(time) then
    if index > 1 then
      local lastAward = self.catchedAwardList[index - 1]
      local isLastAwardDrawed = OnlineAwardMgr.Instance():IsDrawed(lastAward.time)
      if not isLastAwardDrawed then
        Toast(textRes.Award[14])
        return
      end
    end
    OnlineAwardMgr.Instance():DrawOnlineAward(time)
    local ECMSDK = require("ProxySDK.ECMSDK")
    ECMSDK.SendTLogToServer(_G.TLOGTYPE.ONLINEAWARD, {time})
  else
    Toast(textRes.Award[70])
  end
end
def.static("table", "table").OnOnlineAwardUpdate = function(params)
  local AwardPanel = require("Main.Award.ui.AwardPanel")
  local instance = AwardPanel.Instance().nodes[AwardPanel.NodeId.OnlineAward]
  instance:UpdateUI()
end
def.static("table", "table").OnOnlineTimeUpdate = function(params)
  local AwardPanel = require("Main.Award.ui.AwardPanel")
  local instance = AwardPanel.Instance().nodes[AwardPanel.NodeId.OnlineAward]
  instance:UpdateTimeLabels(0)
end
def.method().Clear = function(self)
  self.uiObjs = nil
end
def.method().SendRefreshOnlineTimeReq = function(self)
  local p = require("netio.protocol.mzm.gsp.signaward.COpenOnlineAwardReq").new()
  gmodule.network.sendProtocol(p)
end
return OnlineAwardNode.Commit()
