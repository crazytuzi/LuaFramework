local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local GUIUtils = require("GUI.GUIUtils")
local RecallUtils = require("Main.Recall.RecallUtils")
local RecallData = require("Main.Recall.data.RecallData")
local RecallProtocols = require("Main.Recall.RecallProtocols")
local ECLuaString = require("Utility.ECFilter")
local RecommandPanel = Lplus.Extend(ECPanelBase, "RecommandPanel")
local def = RecommandPanel.define
local instance
def.static("=>", RecommandPanel).Instance = function()
  if not instance then
    instance = RecommandPanel()
  end
  return instance
end
def.field("table")._uiObjs = nil
def.field("userdata")._headTexture = nil
def.field("table")._recallFriendList = nil
def.method().ShowPanel = function(self)
  if not require("Main.Recall.RecallModule").Instance():IsOpen(true) then
    if RecommandPanel.Instance():IsShow() then
      RecommandPanel.Instance():DestroyPanel()
    end
    return
  end
  if RecallData.Instance():ReachDayRecallLimit() or not RecallData.Instance():HaveCanRecallAfkFriend() then
    if RecommandPanel.Instance():IsShow() then
      RecommandPanel.Instance():DestroyPanel()
    end
    return
  end
  if self:IsShow() then
    self:UpdateUI()
  end
  self:CreatePanel(RESPATH.PREFAB_CALL_BACK_FRIENDS_TIPS_PANEL, 0)
end
def.override().OnCreate = function(self)
  self:SetModal(true)
  self:InitUI()
end
def.override().OnDestroy = function(self)
  self._recallFriendList = nil
  self._uiObjs = nil
  if self._headTexture ~= nil then
    self._headTexture:Destroy()
    self._headTexture = nil
  end
  require("Main.Common.EnterWorldAlertMgr").Instance():Next()
end
def.method().InitUI = function(self)
  self._uiObjs = {}
  self._uiObjs.Img_Bg0 = self.m_panel:FindDirect("Img_Bg0")
  self._uiObjs.Label_Tips = self._uiObjs.Img_Bg0:FindDirect("Group_Tips/Img_Talk/Label")
  self._uiObjs.Group_Player = self._uiObjs.Img_Bg0:FindDirect("Group_Player")
  self._uiObjs.Group_Money = self._uiObjs.Img_Bg0:FindDirect("Group_Money")
end
def.override("boolean").OnShow = function(self, show)
  if show then
    self:UpdateUI()
  else
  end
end
def.method().UpdateUI = function(self)
  self:InitData()
  self:ShowTip()
  self:ShowRoleInfo()
  self:ShowAwards()
end
def.method().InitData = function(self)
  self._recallFriendList = RecallData.Instance():FilterAfkFriendList({
    RecallData.RecallAfkType.CanRecall
  })
  local afkFriendCount = self._recallFriendList and #self._recallFriendList or 0
  local todayRecallCount = RecallData.Instance():GetTodayRecallCount()
  local maxRecallCountPerDay = RecallUtils.GetConst("MAX_RECALL_TIMES_EVERY_DAY")
  if afkFriendCount <= 0 or todayRecallCount >= maxRecallCountPerDay then
    warn("[RecommandPanel:InitData] afkFriendCount<=0 or todayRecallCount>=maxRecallCountPerDay:", afkFriendCount, todayRecallCount, maxRecallCountPerDay)
    self:DestroyPanel()
  else
    local showFriendCount = math.min(maxRecallCountPerDay - todayRecallCount, afkFriendCount)
    while showFriendCount < #self._recallFriendList do
      table.remove(self._recallFriendList)
    end
  end
end
def.method().ShowTip = function(self)
  local tips = ""
  if #self._recallFriendList == 1 then
    tips = string.format(textRes.Recall.RECALL_TIP, self._recallFriendList[1]:GetNickName())
  elseif #self._recallFriendList > 1 then
    local names = {}
    for i = 1, 2 do
      local nickname = self._recallFriendList[i]:GetNickName()
      local strLen, aNum, hNum = ECLuaString.Len(nickname or "")
      if aNum + hNum * 2 > 12 then
        local len = aNum / 2 + hNum > 6 and 6 or aNum / 2 + hNum
        nickname = ECLuaString.SubStr(nickname, 1, len) .. "..."
      end
      table.insert(names, tostring(nickname))
    end
    local nameStr = string.format(textRes.Recall.RECALL_TIP_MULTI, table.concat(names, "\227\128\129"), #self._recallFriendList)
    tips = string.format(textRes.Recall.RECALL_TIP, nameStr)
  end
  GUIUtils.SetText(self._uiObjs.Label_Tips, tips)
end
def.method().ShowRoleInfo = function(self)
  local firstPlayer = self._recallFriendList[1]
  local Group_Head = self._uiObjs.Group_Player:FindDirect("Group_Head")
  local Img_Head = Group_Head:FindDirect("Img_Head")
  local headURL = RecallUtils.ProcessHeadImgURL(firstPlayer:GetFigureUrl())
  GUIUtils.FillTextureFromURL(Img_Head, headURL, function(tex2d)
    self._headTexture = tex2d
  end)
  local Label_Name = Group_Head:FindDirect("Label_Name")
  GUIUtils.SetText(Label_Name, firstPlayer:GetNickName())
  local Img_Sex = Group_Head:FindDirect("Img_Sex")
  GUIUtils.SetSprite(Img_Sex, GUIUtils.GetGenderSprite(firstPlayer:GetGender()))
  local Img_School = Group_Head:FindDirect("Img_School")
  GUIUtils.SetSprite(Img_School, GUIUtils.GetOccupationSmallIcon(firstPlayer:GetOccpId()))
  local Label_Lv = Group_Head:FindDirect("Label_Lv")
  GUIUtils.SetText(Label_Lv, string.format(textRes.Common[3], firstPlayer:GetLevel()))
  local Label_SX_PowerNumber = self._uiObjs.Group_Player:FindDirect("Label_SX_PowerNumber")
  GUIUtils.SetText(Label_SX_PowerNumber, firstPlayer:GetFightPower())
  local Label_Server = Group_Head:FindDirect("Label_Server")
  local serverCfg = require("Main.Login.ServerListMgr").Instance():GetServerCfg(firstPlayer:GetZoneId())
  local serverName = serverCfg and serverCfg.name or ""
  GUIUtils.SetText(Label_Server, serverName)
end
def.method().ShowAwards = function(self)
  local Img_Icon = self._uiObjs.Group_Money:FindDirect("Img_Icon")
  local Label_Num = self._uiObjs.Group_Money:FindDirect("Label_Num")
  local awardId = RecallUtils.GetConst("RECALL_FRIEND_FIX_AWARD_ID")
  local ItemUtils = require("Main.Item.ItemUtils")
  local awardCfg = ItemUtils.GetGiftAwardCfgByAwardId(awardId)
  if awardCfg and awardCfg.moneyList[1] ~= nil then
    local money = awardCfg.moneyList[1]
    local AllMoneyType = require("consts.mzm.gsp.item.confbean.AllMoneyType")
    if money.bigType == AllMoneyType.TYPE_MONEY then
      local cfgInfo = ItemUtils.GetMoneyCfg(money.littleType)
      GUIUtils.SetSprite(Img_Icon, cfgInfo.icon)
    elseif money.bigType == AllMoneyType.TYPE_TOKEN then
      local cfgInfo = ItemUtils.GetTokenCfg(money.littleType)
      GUIUtils.SetSprite(Img_Icon, cfgInfo.icon)
    end
    local maxRecallCountPerDay = RecallUtils.GetConst("MAX_RECALL_TIMES_EVERY_DAY")
    local todayRecallCount = RecallData.Instance():GetTodayRecallCount()
    local count = math.min(math.max(0, maxRecallCountPerDay - todayRecallCount), #self._recallFriendList)
    GUIUtils.SetText(Label_Num, money.num * count)
  else
    GUIUtils.SetActive(self._uiObjs.Group_Money, false)
  end
end
def.method("string").onClick = function(self, id)
  if id == "Btn_Close" then
    self:DestroyPanel()
  elseif id == "Btn_Invite" then
    self:OnClickRecallFriend()
    self:DestroyPanel()
  end
end
def.method().OnClickRecallFriend = function(self)
  for i = 1, #self._recallFriendList do
    if self._recallFriendList[i] ~= nil then
      local zoneId = self._recallFriendList[i]:GetZoneId()
      local roleId = self._recallFriendList[i]:GetRoleId()
      local openId = self._recallFriendList[i]:GetOpenId()
      RecallProtocols.SendCRecallFriendReq(zoneId, roleId, openId)
    end
  end
end
return RecommandPanel.Commit()
