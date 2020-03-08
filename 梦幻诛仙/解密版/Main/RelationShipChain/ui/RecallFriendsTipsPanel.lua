local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local RelationShipChainMgr = require("Main.RelationShipChain.RelationShipChainMgr")
local RelationShipChainData = require("Main.RelationShipChain.data.RelationShipChainData")
local ECLuaString = require("Utility.ECFilter")
local GUIUtils = require("GUI.GUIUtils")
local RecallFriendsTipsPanel = Lplus.Extend(ECPanelBase, "RecallFriendsTipsPanel")
local def = RecallFriendsTipsPanel.define
local instance
def.field("table").uiObjs = nil
def.field("userdata").headTexture = nil
def.static("=>", RecallFriendsTipsPanel).Instance = function()
  if not instance then
    instance = RecallFriendsTipsPanel()
  end
  return instance
end
def.method().ShowPanel = function(self)
  if not RelationShipChainMgr.ToadyCanRecallFriend() then
    return
  end
  if self:IsShow() then
    self:DestroyPanel()
  end
  self:CreatePanel(RESPATH.PREFAB_CALL_BACK_FRIENDS_TIPS_PANEL, 0)
  self:SetModal(true)
end
def.override().OnCreate = function(self)
  self:InitUI()
  self:FillRecallData()
end
def.override().OnDestroy = function(self)
  self.uiObjs = nil
  if self.headTexture ~= nil then
    self.headTexture:Destroy()
    self.headTexture = nil
  end
  require("Main.Common.EnterWorldAlertMgr").Instance():Next()
end
def.method().InitUI = function(self)
  self.uiObjs = {}
  self.uiObjs.Img_Bg0 = self.m_panel:FindDirect("Img_Bg0")
  self.uiObjs.Label_Tips = self.uiObjs.Img_Bg0:FindDirect("Group_Tips/Img_Talk/Label")
  self.uiObjs.Group_Player = self.uiObjs.Img_Bg0:FindDirect("Group_Player")
  self.uiObjs.Group_Money = self.uiObjs.Img_Bg0:FindDirect("Group_Money")
end
def.method().FillRecallData = function(self)
  local recallFriends = RelationShipChainData.Instance():GetAllCanRecallFriends()
  if #recallFriends == 0 then
    self:DestroyPanel()
    return
  end
  local tips = ""
  local names = {}
  for i = 1, math.min(2, #recallFriends) do
    local nickname = _G.GetStringFromOcts(recallFriends[i].nickname) or textRes.RelationShipChain[73]
    local strLen, aNum, hNum = ECLuaString.Len(nickname or "")
    if aNum + hNum * 2 > 12 then
      local len = aNum / 2 + hNum > 6 and 6 or aNum / 2 + hNum
      nickname = ECLuaString.SubStr(nickname, 1, len) .. "..."
    end
    table.insert(names, tostring(nickname))
  end
  if #recallFriends == 1 then
    tips = string.format(textRes.RelationShipChain[71], names[1])
  elseif #recallFriends > 1 then
    local nameStr = string.format(textRes.RelationShipChain[72], table.concat(names, "\227\128\129"), #recallFriends)
    tips = string.format(textRes.RelationShipChain[71], nameStr)
  end
  GUIUtils.SetText(self.uiObjs.Label_Tips, tips)
  local firstPlayer = recallFriends[1]
  local Group_Head = self.uiObjs.Group_Player:FindDirect("Group_Head")
  local Img_Head = Group_Head:FindDirect("Img_Head")
  local Label_Name = Group_Head:FindDirect("Label_Name")
  local Img_School = Group_Head:FindDirect("Img_School")
  local Img_Sex = Group_Head:FindDirect("Img_Sex")
  local Label_Lv = Group_Head:FindDirect("Label_Lv")
  local Label_Server = Group_Head:FindDirect("Label_Server")
  local Label_SX_PowerNumber = self.uiObjs.Group_Player:FindDirect("Label_SX_PowerNumber")
  local avatarFrame = Group_Head:FindDirect("Sprite")
  local headURL = RelationShipChainMgr.ProcessHeadImgURL(firstPlayer.figure_url)
  GUIUtils.FillTextureFromURL(Img_Head, headURL, function(tex2d)
    self.headTexture = tex2d
  end)
  GUIUtils.SetText(Label_Name, _G.GetStringFromOcts(firstPlayer.nickname) or textRes.RelationShipChain[73])
  GUIUtils.SetSprite(Img_Sex, GUIUtils.GetGenderSprite(firstPlayer.gender))
  GUIUtils.SetSprite(Img_School, GUIUtils.GetOccupationSmallIcon(firstPlayer.occupation))
  GUIUtils.SetText(Label_Lv, string.format(textRes.Common[3], firstPlayer.level))
  GUIUtils.SetText(Label_SX_PowerNumber, firstPlayer.fighting_capacity:tostring())
  _G.SetAvatarFrameIcon(avatarFrame, firstPlayer.avatar_frameid)
  local serverCfg = require("Main.Login.ServerListMgr").Instance():GetServerCfg(firstPlayer.zoneid)
  local serverName = serverCfg and serverCfg.name or ""
  GUIUtils.SetText(Label_Server, serverName)
  local Img_Icon = self.uiObjs.Group_Money:FindDirect("Img_Icon")
  local Label_Num = self.uiObjs.Group_Money:FindDirect("Label_Num")
  local awardId = RelationShipChainData.GetRecallFriendConstant("RECALL_FRIEND_FIX_AWARD_ID")
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
    local canRecallFriendPerDay = RelationShipChainMgr.GetRecallFriendConstant("MAX_RECALL_TIMES_EVERY_DAY")
    local todayRecallFriendNum = RelationShipChainData.Instance():GetTodayRecallFriendNum()
    local count = math.min(math.max(0, canRecallFriendPerDay - todayRecallFriendNum), #recallFriends)
    GUIUtils.SetText(Label_Num, money.num * count)
  else
    GUIUtils.SetActive(self.uiObjs.Group_Money, false)
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
  local recallFriends = RelationShipChainData.Instance():GetAllCanRecallFriends()
  local canRecallFriendPerDay = RelationShipChainMgr.GetRecallFriendConstant("MAX_RECALL_TIMES_EVERY_DAY")
  local todayRecallFriendNum = RelationShipChainData.Instance():GetTodayRecallFriendNum()
  for i = 1, canRecallFriendPerDay - todayRecallFriendNum do
    if recallFriends[i] ~= nil then
      local params = {}
      params.zone_id = recallFriends[i].zoneid
      params.role_id = Int64.new(recallFriends[i].roleid)
      params.open_id = recallFriends[i].openid
      RelationShipChainMgr.SendRecallFriendReq(params)
    end
  end
end
return RecallFriendsTipsPanel.Commit()
