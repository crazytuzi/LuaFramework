local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local GUIUtils = require("GUI.GUIUtils")
local RelationShipChainMgr = require("Main.RelationShipChain.RelationShipChainMgr")
local ECLuaString = require("Utility.ECFilter")
local ServerListMgr = require("Main.Login.ServerListMgr")
local Network = require("netio.Network")
local ItemUtils = require("Main.Item.ItemUtils")
local ItemTipsMgr = require("Main.Item.ItemTipsMgr")
local Gender = require("consts.mzm.gsp.occupation.confbean.SGenderEnum")
local Occupation = require("consts.mzm.gsp.occupation.confbean.SOccupationEnum")
local QQVipFlag = require("netio.protocol.mzm.gsp.grc.QQVipFlag")
local RelationShipChainPanelNodeBase = require("Main.RelationShipChain.ui.RelationShipChainPanelNodeBase")
local RecallUtils = require("Main.Recall.RecallUtils")
local RecallData = require("Main.Recall.data.RecallData")
local RecallProtocols = require("Main.Recall.RecallProtocols")
local RecallNode = Lplus.Extend(RelationShipChainPanelNodeBase, "RecallNode")
local def = RecallNode.define
local instance
def.static("=>", RecallNode).Instance = function()
  if not instance then
    instance = RecallNode()
  end
  return instance
end
def.field("number")._showItemID = 0
def.field("table")._recallRoleList = nil
def.field("table")._headTextureList = function()
  return {}
end
def.override(ECPanelBase, "userdata").Init = function(self, base, node)
  RelationShipChainPanelNodeBase.Init(self, base, node)
end
def.override().OnShow = function(self)
  self:InitData()
  self:Update()
  self:HandleEventListeners(true)
end
def.override().OnHide = function(self)
  self:HandleEventListeners(false)
  self:Clear()
end
def.override().Clear = function(self)
  for k, v in pairs(self._headTextureList) do
    if v then
      v:Destroy()
    end
    self._headTextureList[k] = nil
  end
  self._showItemID = 0
  RelationShipChainPanelNodeBase.Clear(self)
end
def.override("=>", "boolean").IsUnlock = function(self)
  local isOpen = require("Main.Recall.RecallModule").Instance():IsOpen(false)
  return isOpen
end
def.method().InitData = function(self)
  self._recallRoleList = RecallData.Instance():FilterAfkFriendList({
    RecallData.RecallAfkType.CanBeRecall,
    RecallData.RecallAfkType.AlreadyRecall
  })
end
def.override().InitUI = function(self)
  RelationShipChainPanelNodeBase.InitUI(self)
  self.m_UIGO = {}
  self.m_UIGO.ScrollView = self.m_panel:FindDirect("Img_Bg0/Group_Friend/Img_BgList/Scroll View_List")
  self.m_UIGO.FriendList = self.m_panel:FindDirect("Img_Bg0/Group_Friend/Img_BgList/Scroll View_List/List_Friend")
  self.m_UIGO.Group_NumBonus = self.m_panel:FindDirect("Img_Bg0/Group_Friend/Group_NumBonus")
  self.m_UIGO.FriendNum = self.m_panel:FindDirect("Img_Bg0/Group_Friend/Group_NumBonus/Label_FriendNum")
  self.m_UIGO.GetReward = self.m_panel:FindDirect("Img_Bg0/Group_Friend/Group_NumBonus/Label_Active")
  self.m_UIGO.NextLevel = self.m_panel:FindDirect("Img_Bg0/Group_Friend/Group_NumBonus/Label_NextLevel")
  self.m_UIGO.ItemIcon = self.m_panel:FindDirect("Img_Bg0/Group_Friend/Group_NumBonus/Img_ItemFrame/Img_ItemIcon")
  self.m_UIGO.ItemNum = self.m_panel:FindDirect("Img_Bg0/Group_Friend/Group_NumBonus/Img_ItemFrame/Label_ItemNum")
  self.m_UIGO.BtnToggle = self.m_panel:FindDirect("Img_Bg0/Group_Friend/Group_FuncBtns/Btn_Toggle")
  self.m_UIGO.OpenToggle = self.m_panel:FindDirect("Img_Bg0/Group_Friend/Group_FuncBtns/Btn_Toggle/Label_Open")
  self.m_UIGO.CloseToggle = self.m_panel:FindDirect("Img_Bg0/Group_Friend/Group_FuncBtns/Btn_Toggle/Label_Close")
  self.m_UIGO.Img_ItemFrame = self.m_panel:FindDirect("Img_Bg0/Group_Friend/Group_NumBonus/Img_ItemFrame")
  self.m_UIGO.UI_FX = self.m_panel:FindDirect("Img_Bg0/Group_Friend/Group_NumBonus/UI_FX")
  self.m_UIGO.Group_Empty = self.m_panel:FindDirect("Img_Bg0/Group_Friend/Group_Empty")
end
def.method().UpdateRedot = function(self)
end
def.method().Update = function(self)
  self:FillMembersList()
  self:ShowRecallAwards()
end
local spriteIndex = {
  "Img_First",
  "Img_Second",
  "Img_Third"
}
def.method().FillMembersList = function(self)
  local memberList = self._recallRoleList
  local scrollViewObj = self.m_UIGO.ScrollView
  local scrollListObj = self.m_UIGO.FriendList
  local GUIScrollList = scrollListObj:GetComponent("GUIScrollList")
  if not GUIScrollList then
    scrollListObj:AddComponent("GUIScrollList")
  end
  local uiScrollList = scrollListObj:GetComponent("UIScrollList")
  ScrollList_setUpdateFunc(uiScrollList, function(item, i)
    self:FillMemberInfo(item, i, memberList[i])
  end)
  ScrollList_setCount(uiScrollList, #memberList)
  GUIUtils.SetActive(self.m_UIGO.Group_Empty, #memberList == 0)
  self.m_base.m_msgHandler:Touch(scrollListObj)
  scrollViewObj:GetComponent("UIScrollView"):ResetPosition()
end
def.method("userdata", "number", "table").FillMemberInfo = function(self, item, index, afkFriendInfo)
  local rankNumGO = item:FindDirect("Label_Rank")
  local rankImgGO = item:FindDirect("Img_Rank")
  GUIUtils.SetActive(rankImgGO, index <= 3)
  GUIUtils.SetActive(rankNumGO, index > 3)
  GUIUtils.SetSprite(rankImgGO, spriteIndex[index])
  GUIUtils.SetText(rankNumGO, index)
  local sameServiceImgGO = item:FindDirect("Img_SameSign")
  GUIUtils.SetActive(sameServiceImgGO, afkFriendInfo:GetZoneId() == Network.m_zoneid)
  local headURL = RecallUtils.ProcessHeadImgURL(afkFriendInfo:GetFigureUrl())
  local headImgGO = item:FindDirect("Img_BgIconGroup/Texture_IconGroup")
  GUIUtils.FillTextureFromURL(headImgGO, headURL, function(tex2d)
    self._headTextureList[index] = tex2d
  end)
  local friendNameGO = item:FindDirect("Label_FriendName")
  local nickname = afkFriendInfo:GetNickName() or textRes.Recall.GET_NICK_NAME_FAIL
  local strLen, aNum, hNum = ECLuaString.Len(nickname or "")
  if aNum + hNum * 2 > 12 then
    local len = aNum / 2 + hNum > 6 and 6 or aNum / 2 + hNum
    nickname = ECLuaString.SubStr(nickname, 1, len) .. "..."
  end
  GUIUtils.SetText(friendNameGO, tostring(nickname))
  local levelGO = item:FindDirect("Label_Lv")
  GUIUtils.SetText(levelGO, string.format(textRes.Common[3], afkFriendInfo:GetLevel()))
  local schoolIconGO = item:FindDirect("Img_SchoolIcon")
  GUIUtils.SetSprite(schoolIconGO, GUIUtils.GetOccupationSmallIcon(afkFriendInfo:GetOccpId()))
  local serverNameGO = item:FindDirect("Label_ServerName")
  local serverCfg = ServerListMgr.Instance():GetServerCfg(afkFriendInfo:GetZoneId())
  local serverName = serverCfg and serverCfg.name or ""
  GUIUtils.SetText(serverNameGO, serverName)
  local inviteGO = item:FindDirect("Label_Invited")
  local btnInviteGO = item:FindDirect("Btn_Invite")
  local isInvite = not afkFriendInfo:IsHeroRecallPeriodOver()
  GUIUtils.SetActive(inviteGO, isInvite)
  GUIUtils.SetActive(btnInviteGO, not isInvite)
  local powerNumGO = item:FindDirect("Img_BgPower/Label_PowerNum")
  GUIUtils.SetText(powerNumGO, tostring(afkFriendInfo:GetFightPower()))
  local mySelfImgGO = item:FindDirect("Img_ListMySelf")
  GUIUtils.SetActive(mySelfImgGO, false)
  local charactorNameGO = item:FindDirect("Label_CharactorName")
  local rolename = afkFriendInfo:GetRoleName() or textRes.Recall.GET_ROLE_NAME_FAIL
  GUIUtils.SetText(charactorNameGO, rolename)
  local genderSprite = item:FindDirect("Img_Sex")
  GUIUtils.SetSprite(genderSprite, GUIUtils.GetGenderSprite(afkFriendInfo:GetGender()))
  local VIPGO = item:FindDirect("Img_BgIconGroup/Img_VipLogo")
  local sVIPGO = item:FindDirect("Img_BgIconGroup/Img_SVipLogo")
  local qq_vip_infos = afkFriendInfo:GetQQVipInfos()
  local isVIP = qq_vip_infos and qq_vip_infos[QQVipFlag.VIP_NORMAL] and qq_vip_infos[QQVipFlag.VIP_NORMAL].is_vip == 1
  local isSVIP = qq_vip_infos and qq_vip_infos[QQVipFlag.VIP_SUPER] and qq_vip_infos[QQVipFlag.VIP_SUPER].is_vip == 1
  GUIUtils.SetActive(sVIPGO, isSVIP and not GameUtil.IsEvaluation() and not ClientCfg.IsOtherChannel() and _G.LoginPlatform == _G.MSDK_LOGIN_PLATFORM.QQ)
  GUIUtils.SetActive(VIPGO, isVIP and not isSVIP and not GameUtil.IsEvaluation() and not ClientCfg.IsOtherChannel() and _G.LoginPlatform == _G.MSDK_LOGIN_PLATFORM.QQ)
  local weChatGO = item:FindDirect("Img_BgIconGroup/Img_WechatLogo")
  local imgYYBGO = item:FindDirect("Img_BgIconGroup/Img_YingyongbaoLogo")
  local gameCenterGO = item:FindDirect("Btn_FromGameCenter")
  local login_privilege = afkFriendInfo:GetLoginPrivilege()
  GUIUtils.SetActive(weChatGO, login_privilege == 2 and not GameUtil.IsEvaluation() and not ClientCfg.IsOtherChannel() and _G.LoginPlatform == _G.MSDK_LOGIN_PLATFORM.WX)
  GUIUtils.SetActive(imgYYBGO, login_privilege == 3 and not GameUtil.IsEvaluation() and not ClientCfg.IsOtherChannel())
  GUIUtils.SetActive(gameCenterGO, login_privilege == 1 and not GameUtil.IsEvaluation() and not ClientCfg.IsOtherChannel() and _G.LoginPlatform == _G.MSDK_LOGIN_PLATFORM.QQ)
  local Group_Money = item:FindDirect("Group_Money")
  local Img_Icon = Group_Money:FindDirect("Img_Icon")
  local Label_Num = Group_Money:FindDirect("Label_Num")
  local awardId = RecallUtils.GetConst("RECALL_FRIEND_FIX_AWARD_ID")
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
    GUIUtils.SetText(Label_Num, money.num)
  else
    GUIUtils.SetActive(Group_Money, false)
  end
end
def.method().ShowRecallAwards = function(self)
  local rewardSerialID = RelationShipChainMgr.GetRecallFriendsAwardSerialID()
  local awardID = 0
  local serialID = 0
  local currentMax = 0
  local isGetAll = false
  local friendNum = RelationShipChainMgr.GetRecallFriendNum()
  local rewardCfg = RelationShipChainMgr.GetRecallFriendNumAwardCfg()
  for k, v in pairs(rewardCfg) do
    if rewardSerialID + 1 == v.serial_no then
      awardID = v.award_cfg_id
      currentMax = v.need_count
    end
    if friendNum >= v.need_count then
      serialID = v.serial_no
    end
  end
  if currentMax == 0 then
    for k, v in pairs(rewardCfg) do
      currentMax = v.need_count
      awardID = v.award_cfg_id
    end
    isGetAll = true
  end
  if friendNum < 0 then
    friendNum = 0
  end
  local bounsGO = self.m_UIGO.Group_NumBonus
  GUIUtils.SetCollider(bounsGO, rewardSerialID < serialID)
  local friendNumGO = self.m_UIGO.FriendNum
  GUIUtils.SetText(friendNumGO, ("%d/%d"):format(friendNum, currentMax))
  local getRewardLabelGO = self.m_UIGO.GetReward
  GUIUtils.SetActive(getRewardLabelGO, rewardSerialID < serialID)
  local nextLevelGO = self.m_UIGO.NextLevel
  GUIUtils.SetActive(nextLevelGO, rewardSerialID >= serialID)
  GUIUtils.SetText(nextLevelGO, isGetAll and textRes.Recall.RECALL_AWARD_ALL_FETCHED or textRes.Recall.RECALL_AWARD_NEXT_LEVEL)
  local itemIconGO = self.m_UIGO.ItemIcon
  local itemNumGO = self.m_UIGO.ItemNum
  local uiFxGO = self.m_UIGO.UI_FX
  local itemList = RecallUtils.GetAwardItems(awardID)
  local icon = 0
  local num = 0
  if itemList and itemList[1] then
    local itemID = itemList[1].itemId
    local baseData = ItemUtils.GetItemBase(itemID)
    num = itemList[1].num
    icon = baseData.icon
    self._showItemID = itemID
  end
  GUIUtils.SetActive(uiFxGO, rewardSerialID < serialID)
  GUIUtils.SetText(itemNumGO, tostring(num))
  GUIUtils.SetTexture(itemIconGO, icon)
end
def.override("userdata").onClickObj = function(self, clickobj)
  local id = clickobj.name
  if id == "Btn_Invite" then
    local item, idx = ScrollList_getItem(clickobj)
    self:RecallFriends(idx)
  elseif id == "Btn_Toggle" then
  elseif id == "Btn_AwardTip" then
    local tipId = RecallUtils.GetConst("RECALL_FRIEND_DESCRIPTION")
    GUIUtils.ShowHoverTip(tipId)
  elseif id == "Btn_Share" then
    Toast(textRes.Recall.RECALL_SHARE_NOT_OPEN)
  elseif id == "Group_NumBonus" then
    self:GetReward()
  elseif id == "Img_ItemFrame" then
    self:ShowTips()
  elseif id:find("Img_WechatLogo") == 1 then
    Toast(textRes.Recall.RECALL_WECHAT_PRIVILEGE)
  end
end
def.method("number").RecallFriends = function(self, index)
  local afkFriendInfo = self._recallRoleList[index]
  if afkFriendInfo then
    local zoneId = afkFriendInfo:GetZoneId()
    local roleId = afkFriendInfo:GetRoleId()
    local openId = afkFriendInfo:GetOpenId()
    RecallProtocols.SendCRecallFriendReq(zoneId, roleId, openId)
  else
    warn("[ERROR][RecallNode:RecallFriends] afkFriendInfo nil at index:", index)
  end
end
def.method().GetReward = function(self)
  local params = {}
  params.award_serial_no = RelationShipChainMgr.GetRecallFriendsAwardSerialID() + 1
  RelationShipChainMgr.GetRecallFriendsCountAward(params)
end
def.method().ShowTips = function(self)
  local btnGO = self.m_UIGO.Img_ItemFrame
  if btnGO and self._showItemID ~= 0 then
    ItemTipsMgr.Instance():ShowBasicTipsWithGO(self._showItemID, btnGO, 1, true)
  end
end
def.method("boolean").HandleEventListeners = function(self, isRigister)
  local eventFunc
  if isRigister then
    eventFunc = Event.RegisterEvent
  else
    eventFunc = Event.UnregisterEvent
  end
  if eventFunc then
    eventFunc(ModuleId.RECALL, gmodule.notifyId.Recall.RECALL_AFK_INFO_CHANGE, RecallNode.OnNotifyRecallFriend)
    eventFunc(ModuleId.RELATIONSHIPCHAIN, gmodule.notifyId.RelationShipChain.NotifyRecallFriendAward, RecallNode.OnNotifyRecallFriendAward)
  end
end
def.static("table", "table").OnNotifyRecallFriend = function(params)
  if not _G.IsNil(instance.m_panel) then
    instance:InitData()
    instance:FillMembersList()
  end
end
def.static("table", "table").OnNotifyRecallFriendAward = function(params)
  if not _G.IsNil(instance.m_panel) then
    instance:ShowRecallAwards()
    instance:UpdateRedot()
  end
end
return RecallNode.Commit()
