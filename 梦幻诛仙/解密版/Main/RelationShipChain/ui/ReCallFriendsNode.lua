local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local ECMSDK = require("ProxySDK.ECMSDK")
local GUIUtils = require("GUI.GUIUtils")
local RelationShipChainMgr = require("Main.RelationShipChain.RelationShipChainMgr")
local RelationShipChainData = require("Main.RelationShipChain.data.RelationShipChainData")
local ECLuaString = require("Utility.ECFilter")
local CommonConfirmDlg = require("GUI.CommonConfirmDlg")
local ServerListMgr = require("Main.Login.ServerListMgr")
local Network = require("netio.Network")
local ItemUtils = require("Main.Item.ItemUtils")
local ItemTipsMgr = require("Main.Item.ItemTipsMgr")
local Gender = require("consts.mzm.gsp.occupation.confbean.SGenderEnum")
local Occupation = require("consts.mzm.gsp.occupation.confbean.SOccupationEnum")
local QQVipFlag = require("netio.protocol.mzm.gsp.grc.QQVipFlag")
local RelationShipChainPanelNodeBase = require("Main.RelationShipChain.ui.RelationShipChainPanelNodeBase")
local ECGame = Lplus.ForwardDeclare("ECGame")
local ReCallFriendsNode = Lplus.Extend(RelationShipChainPanelNodeBase, "ReCallFriendsNode")
local def = ReCallFriendsNode.define
def.const("number").PAGESIZE = 8
def.field("number").m_ShowItemID = 0
def.field("number").m_OpenGiftType = 0
def.field("boolean").m_ForceSwith = false
def.field("boolean").m_Continue = false
def.field("number").m_CurrentPageIndex = 1
def.field("table").m_Data = nil
def.field("table").m_TextureData = function()
  return {}
end
local instance
def.static("=>", ReCallFriendsNode).Instance = function()
  if not instance then
    instance = ReCallFriendsNode()
  end
  return instance
end
def.override(ECPanelBase, "userdata").Init = function(self, base, node)
  RelationShipChainPanelNodeBase.Init(self, base, node)
end
def.override().OnShow = function(self)
  self:InitData()
  self:Update()
  Event.RegisterEvent(ModuleId.RELATIONSHIPCHAIN, gmodule.notifyId.RelationShipChain.NotifyRecallFriend, ReCallFriendsNode.OnNotifyRecallFriend)
  Event.RegisterEvent(ModuleId.RELATIONSHIPCHAIN, gmodule.notifyId.RelationShipChain.NotifyRecallFriendAward, ReCallFriendsNode.OnNotifyRecallFriendAward)
end
def.override().OnHide = function(self)
  self:Clear()
  Event.UnregisterEvent(ModuleId.RELATIONSHIPCHAIN, gmodule.notifyId.RelationShipChain.NotifyRecallFriend, ReCallFriendsNode.OnNotifyRecallFriend)
  Event.UnregisterEvent(ModuleId.RELATIONSHIPCHAIN, gmodule.notifyId.RelationShipChain.NotifyRecallFriendAward, ReCallFriendsNode.OnNotifyRecallFriendAward)
end
def.override().Clear = function(self)
  for k, v in pairs(self.m_TextureData) do
    if v then
      v:Destroy()
    end
    self.m_TextureData[k] = nil
  end
  self.m_ShowItemID = 0
  RelationShipChainPanelNodeBase.Clear(self)
end
def.override("=>", "boolean").IsUnlock = function(self)
  return true
end
def.static("table", "table").OnNotifyRecallFriend = function(params)
  if instance.m_panel and not instance.m_panel.isnil then
    instance:InitData()
    instance:FillMembersList()
  end
end
def.static("table", "table").OnNotifyRecallFriendAward = function(params)
  if instance.m_panel and not instance.m_panel.isnil then
    instance:UpdateLeftBottomView()
    instance:UpdateRedot()
  end
end
def.method("number").RecallFriends = function(self, index)
  local data = self.m_Data[index]
  local params = {}
  params.zone_id = data.zoneid
  params.role_id = Int64.new(data.roleid)
  params.open_id = data.openid
  RelationShipChainMgr.SendRecallFriendReq(params)
end
def.method().GetReward = function(self)
  local params = {}
  params.award_serial_no = RelationShipChainMgr.GetRecallFriendsAwardSerialID() + 1
  RelationShipChainMgr.GetRecallFriendsCountAward(params)
end
def.method().ShowTips = function(self)
  local btnGO = self.m_UIGO.Img_ItemFrame
  if btnGO and self.m_ShowItemID ~= 0 then
    ItemTipsMgr.Instance():ShowBasicTipsWithGO(self.m_ShowItemID, btnGO, 1, true)
  end
end
def.override("userdata").onClickObj = function(self, clickobj)
  local id = clickobj.name
  if id == "Btn_Invite" then
    local item, idx = ScrollList_getItem(clickobj)
    self:RecallFriends(idx)
  elseif id == "Btn_Toggle" then
  elseif id == "Btn_AwardTip" then
    local tipId = RelationShipChainMgr.GetRecallFriendConstant("RECALL_FRIEND_DESCRIPTION")
    require("GUI.GUIUtils").ShowHoverTip(tipId)
  elseif id == "Btn_Share" then
    Toast(textRes.RelationShipChain[5])
  elseif id == "Group_NumBonus" then
    self:GetReward()
  elseif id == "Img_ItemFrame" then
    self:ShowTips()
  elseif id:find("Img_WechatLogo") == 1 then
    Toast(textRes.RelationShipChain[44])
  end
end
def.method().InitData = function(self)
  self.m_Data = {}
  local friendData = RelationShipChainMgr.GetFriendData()
  local temp = {}
  for _, v in pairs(friendData) do
    if (v.recall_state == 1 or v.recall_state == 2) and ECMSDK.GetMSDKInfo().openId ~= GetStringFromOcts(friendData.openid) then
      table.insert(temp, v)
    end
  end
  table.sort(temp, function(l, r)
    if not l.fighting_capacity or not r.fighting_capacity then
      return false
    end
    if l.recall_state ~= r.recall_state then
      return l.recall_state < r.recall_state
    elseif l.fighting_capacity ~= r.fighting_capacity then
      return l.fighting_capacity > r.fighting_capacity
    else
      return GetStringFromOcts(l.openid) > GetStringFromOcts(r.openid)
    end
  end)
  self.m_Data = temp
  self.m_OpenGiftType = RelationShipChainMgr.GetGrcGiftCfg().gift_type
  self.m_ForceSwith = RelationShipChainMgr.GetGiftSwith(self.m_OpenGiftType)
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
local spriteIndex = {
  "Img_First",
  "Img_Second",
  "Img_Third"
}
def.method().FillMembersList = function(self)
  local memberList = self.m_Data
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
def.method("userdata", "number", "table").FillMemberInfo = function(self, item, index, friendData)
  local rankNumGO = item:FindDirect("Label_Rank")
  local rankImgGO = item:FindDirect("Img_Rank")
  local sameServiceImgGO = item:FindDirect("Img_SameSign")
  local headImgGO = item:FindDirect("Img_BgIconGroup/Texture_IconGroup")
  local friendNameGO = item:FindDirect("Label_FriendName")
  local levelGO = item:FindDirect("Label_Lv")
  local schoolIconGO = item:FindDirect("Img_SchoolIcon")
  local serverNameGO = item:FindDirect("Label_ServerName")
  local inviteGO = item:FindDirect("Label_Invited")
  local powerNumGO = item:FindDirect("Img_BgPower/Label_PowerNum")
  local btnInviteGO = item:FindDirect("Btn_Invite")
  local mySelfImgGO = item:FindDirect("Img_ListMySelf")
  local charactorNameGO = item:FindDirect("Label_CharactorName")
  local VIPGO = item:FindDirect("Img_BgIconGroup/Img_VipLogo")
  local sVIPGO = item:FindDirect("Img_BgIconGroup/Img_SVipLogo")
  local weChatGO = item:FindDirect("Img_BgIconGroup/Img_WechatLogo")
  local imgYYBGO = item:FindDirect("Img_BgIconGroup/Img_YingyongbaoLogo")
  local gameCenterGO = item:FindDirect("Btn_FromGameCenter")
  local isInvite = friendData.recall_state == 2
  local rolename = GetStringFromOcts(friendData.rolename) or textRes.RelationShipChain[73]
  local nickname = GetStringFromOcts(friendData.nickname) or textRes.RelationShipChain[73]
  local strLen, aNum, hNum = ECLuaString.Len(nickname or "")
  if aNum + hNum * 2 > 12 then
    local len = aNum / 2 + hNum > 6 and 6 or aNum / 2 + hNum
    nickname = ECLuaString.SubStr(nickname, 1, len) .. "..."
  end
  local url = RelationShipChainMgr.ProcessHeadImgURL(friendData.figure_url)
  local serverName = ""
  if friendData.zoneid then
    local serverCfg = ServerListMgr.Instance():GetServerCfg(friendData.zoneid)
    if not serverCfg or not serverCfg.name then
      local serverName = ""
    end
  end
  local isVIP = friendData.qq_vip_infos[QQVipFlag.VIP_NORMAL] and friendData.qq_vip_infos[QQVipFlag.VIP_NORMAL].is_vip == 1
  local isSVIP = friendData.qq_vip_infos[QQVipFlag.VIP_SUPER] and friendData.qq_vip_infos[QQVipFlag.VIP_SUPER].is_vip == 1
  GUIUtils.SetActive(rankImgGO, index <= 3)
  GUIUtils.SetActive(rankNumGO, index > 3)
  GUIUtils.SetActive(mySelfImgGO, false)
  GUIUtils.SetActive(sameServiceImgGO, friendData.zoneid == Network.m_zoneid)
  GUIUtils.SetActive(inviteGO, isInvite)
  GUIUtils.SetActive(btnInviteGO, not isInvite)
  GUIUtils.SetActive(sVIPGO, isSVIP and not GameUtil.IsEvaluation() and not ClientCfg.IsOtherChannel() and _G.LoginPlatform == _G.MSDK_LOGIN_PLATFORM.QQ)
  GUIUtils.SetActive(VIPGO, isVIP and not isSVIP and not GameUtil.IsEvaluation() and not ClientCfg.IsOtherChannel() and _G.LoginPlatform == _G.MSDK_LOGIN_PLATFORM.QQ)
  GUIUtils.SetActive(weChatGO, friendData.login_privilege == 2 and not GameUtil.IsEvaluation() and not ClientCfg.IsOtherChannel() and _G.LoginPlatform == _G.MSDK_LOGIN_PLATFORM.WX)
  GUIUtils.SetActive(imgYYBGO, friendData.login_privilege == 3 and not GameUtil.IsEvaluation() and not ClientCfg.IsOtherChannel())
  GUIUtils.SetActive(gameCenterGO, friendData.login_privilege == 1 and not GameUtil.IsEvaluation() and not ClientCfg.IsOtherChannel() and _G.LoginPlatform == _G.MSDK_LOGIN_PLATFORM.QQ)
  GUIUtils.FillTextureFromURL(headImgGO, url, function(tex2d)
    self.m_TextureData[index] = tex2d
  end)
  GUIUtils.SetSprite(rankImgGO, spriteIndex[index])
  GUIUtils.SetText(rankNumGO, index)
  GUIUtils.SetText(friendNameGO, tostring(nickname))
  GUIUtils.SetText(levelGO, "Lv." .. tostring(friendData.level))
  GUIUtils.SetText(charactorNameGO, rolename)
  GUIUtils.SetText(powerNumGO, tostring(friendData.fighting_capacity))
  GUIUtils.SetText(serverNameGO, serverName)
  GUIUtils.SetSprite(schoolIconGO, GUIUtils.GetOccupationSmallIcon(friendData.occupation))
  local genderSprite = item:FindDirect("Img_Sex")
  GUIUtils.SetSprite(genderSprite, GUIUtils.GetGenderSprite(friendData.gender))
  local Group_Money = item:FindDirect("Group_Money")
  local Feature = require("netio.protocol.mzm.gsp.open.ModuleFunSwitchInfo")
  if _G.IsFeatureOpen(Feature.TYPE_RECALL_FRIEND_OPTIMIZE) then
    local Img_Icon = Group_Money:FindDirect("Img_Icon")
    local Label_Num = Group_Money:FindDirect("Label_Num")
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
      GUIUtils.SetText(Label_Num, money.num)
    else
      GUIUtils.SetActive(Group_Money, false)
    end
  else
    GUIUtils.SetActive(Group_Money, false)
  end
  local avatarFrame = item:FindDirect("Img_BgIconGroup")
  _G.SetAvatarFrameIcon(avatarFrame, friendData.avatar_frameid)
end
def.method().UpdateLeftBottomView = function(self)
  local bounsGO = self.m_UIGO.Group_NumBonus
  local friendNumGO = self.m_UIGO.FriendNum
  local getRewardLabelGO = self.m_UIGO.GetReward
  local nextLevelGO = self.m_UIGO.NextLevel
  local itemIconGO = self.m_UIGO.ItemIcon
  local itemNumGO = self.m_UIGO.ItemNum
  local uiFxGO = self.m_UIGO.UI_FX
  local friendNum = RelationShipChainMgr.GetRecallFriendNum()
  local rewardCfg = RelationShipChainMgr.GetRecallFriendNumAwardCfg()
  local serialID = 0
  local awardID = 0
  local currentMax = 0
  local rewardID = RelationShipChainMgr.GetRecallFriendsAwardSerialID()
  local isGetAll = false
  warn(rewardID, "ReCallFriendsNode UpdateLeftBottomView", currentMax)
  for k, v in pairs(rewardCfg) do
    if rewardID + 1 == v.serial_no then
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
  local key = ("%d_%d_%d"):format(awardID, Occupation.ALL, Gender.ALL)
  local awardcfg = ItemUtils.GetGiftAwardCfg(key)
  local icon = 0
  local num = 0
  if awardcfg and awardcfg.itemList[1] then
    local itemID = awardcfg.itemList[1].itemId
    local baseData = ItemUtils.GetItemBase(itemID)
    num = awardcfg.itemList[1].num
    icon = baseData.icon
    self.m_ShowItemID = itemID
  end
  if friendNum < 0 then
    friendNum = 0
  end
  GUIUtils.SetActive(uiFxGO, rewardID < serialID)
  GUIUtils.SetActive(getRewardLabelGO, rewardID < serialID)
  GUIUtils.SetActive(nextLevelGO, rewardID >= serialID)
  GUIUtils.SetCollider(bounsGO, rewardID < serialID)
  GUIUtils.SetText(nextLevelGO, isGetAll and textRes.RelationShipChain[55] or textRes.RelationShipChain[54])
  GUIUtils.SetText(friendNumGO, ("%d/%d"):format(friendNum, currentMax))
  GUIUtils.SetText(itemNumGO, tostring(num))
  GUIUtils.SetTexture(itemIconGO, icon)
end
def.method().Update = function(self)
  self:FillMembersList()
  self:UpdateLeftBottomView()
end
return ReCallFriendsNode.Commit()
