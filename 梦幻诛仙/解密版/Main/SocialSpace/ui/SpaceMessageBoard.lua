local MODULE_NAME = (...)
local Lplus = require("Lplus")
local SpacePanelNodeBase = import(".SpacePanelNodeBase")
local SpaceMessageBoard = Lplus.Extend(SpacePanelNodeBase, MODULE_NAME)
local GUIUtils = require("GUI.GUIUtils")
local Vector = require("Types.Vector")
local def = SpaceMessageBoard.define
local HeroInterface = require("Main.Hero.Interface")
local SocialSpaceUtils = import("..SocialSpaceUtils")
local SocialSpaceModule = require("Main.SocialSpace.SocialSpaceModule")
local ECSocialSpaceMan = require("Main.SocialSpace.ECSocialSpaceMan")
local ECSocialSpaceConfig = require("Main.SocialSpace.ECSocialSpaceConfig")
local SocialSpaceFocusMan = require("Main.SocialSpace.SocialSpaceFocusMan")
local SocialSpaceProfileMan = require("Main.SocialSpace.SocialSpaceProfileMan")
local ECDebugOption = require("Main.ECDebugOption")
local ECSpaceMsgs = require("Main.SocialSpace.ECSpaceMsgs")
local SpaceInputCtrl = import(".SpaceInputCtrl")
local CommonConfirmDlg = require("GUI.CommonConfirmDlg")
local FriendModule = Lplus.ForwardDeclare("FriendModule")
local MsgRefreshState = {
  Hide = 0,
  Down = 1,
  Up = 2,
  Pull = 3
}
def.const("table").MsgRefreshState = MsgRefreshState
def.field("table").m_UIGOs = nil
def.field(ECSocialSpaceMan).m_spaceMan = nil
def.field(ECSpaceMsgs.ECSpaceBaseInfo).m_spaceBase = nil
def.field(SpaceInputCtrl).m_msgInputCtrl = nil
def.field("number").m_msgCountPerPage = 4
def.field("boolean").m_viewInited = false
def.field("userdata").m_replyRoleId = Zero_Int64_Init
def.field("string").m_replyRoleName = ""
def.field("userdata").m_targetMsgId = Zero_Int64_Init
def.field("boolean").m_bAppendingMsg = false
def.field("number").m_msgRefreshState = -1
def.field("table").m_friendMarkContainer = nil
def.override().OnCreate = function(self)
  self.m_spaceMan = ECSocialSpaceMan.Instance()
end
def.override().OnShow = function(self)
  self.m_spaceBase = self.m_base.m_baseInfo
  self.m_friendMarkContainer = require("Main.SocialSpace.FriendMarkHelper").Instance():CreateContainer()
  self:InitUI()
  self:UpdateUI()
  self:CheckHasNewMsg()
  Event.RegisterEventWithContext(ModuleId.FRIEND, gmodule.notifyId.Friend.Friend_OnFriendChanged, self.OnFriendChanged, self)
  Event.RegisterEventWithContext(ModuleId.SOCIAL_SPACE, gmodule.notifyId.SocialSpace.TreauseChestChanged, self.OnTreauseChestChanged, self)
  Event.RegisterEventWithContext(ModuleId.SOCIAL_SPACE, gmodule.notifyId.SocialSpace.PopularChanged, self.OnPopularChanged, self)
  Event.RegisterEventWithContext(ModuleId.SOCIAL_SPACE, gmodule.notifyId.SocialSpace.BlacklistChanged, self.OnBlacklistChanged, self)
end
def.override().OnHide = function(self)
  Event.UnregisterEvent(ModuleId.SOCIAL_SPACE, gmodule.notifyId.SocialSpace.BlacklistChanged, self.OnBlacklistChanged)
  Event.UnregisterEvent(ModuleId.SOCIAL_SPACE, gmodule.notifyId.SocialSpace.PopularChanged, self.OnPopularChanged)
  Event.UnregisterEvent(ModuleId.SOCIAL_SPACE, gmodule.notifyId.SocialSpace.TreauseChestChanged, self.OnTreauseChestChanged)
  Event.UnregisterEvent(ModuleId.FRIEND, gmodule.notifyId.Friend.Friend_OnFriendChanged, self.OnFriendChanged)
  if self.m_msgInputCtrl then
    self.m_msgInputCtrl:Destroy()
    self.m_msgInputCtrl = nil
  end
  if self.m_friendMarkContainer then
    self.m_friendMarkContainer:Destroy()
    self.m_friendMarkContainer = nil
  end
  self.m_UIGOs = nil
end
def.override("userdata").onClickObj = function(self, clickobj)
  local id = clickobj.name
  if id == "Btn_LeaveMessage" then
    self:OnClickLeaveMsgBtn()
  elseif id == "Btn_Send" then
    self:OnClickSendBtn()
  elseif id == "Btn_Clear" then
    self:ClearInputedMsg()
  elseif id == "Btn_Add" then
    self:OnClickEmojiBtn()
  elseif id == "Btn_Back" then
    self:OnClickBackBtn()
  elseif id == "Btn_Del" then
    self:OnClickDelBtn(clickobj)
  elseif id == "Img_Head" then
    self:OnClickHeadImg(clickobj)
  elseif id == "Btn_Pop" then
    self:OnClickPopBtn(clickobj)
  elseif id == "Btn_GiftGive" then
    self:OnClickGiveGiftBtn(clickobj)
  elseif id:sub(1, 12) == "sspace_role_" then
    self:OnClickRoleLink(clickobj)
  elseif id == "Btn_AddFriends" then
    self:OnClickAddFriendBtn()
  elseif id == "Btn_FollowSpace" then
    self:OnClickFocusBtn()
  elseif id == "Btn_BlackList" then
    self:OnClickBlackListBtn()
  elseif id == "Img_Icon" and clickobj.parent.name == "Group_Chest" then
    GUIUtils.ShowHoverSmallTip(constant.CFriendsCircleConsts.treasure_box_tips_cfg_Id, {sourceObj = clickobj})
  elseif id == "Img_Icon" and clickobj.parent.name == "Group_Popularity" then
    GUIUtils.ShowHoverSmallTip(constant.CFriendsCircleConsts.popularity_values_tips_cfg_id, {sourceObj = clickobj})
  elseif id == "Img_Icon" and clickobj.parent.name == "Group_Gift" then
    GUIUtils.ShowHoverSmallTip(constant.CFriendsCircleConsts.gift_tips_cfg_id, {sourceObj = clickobj})
  elseif id == "Img_Btn" and clickobj.parent.name == "Group_Chest" then
    self:OnClickAddChestBtn()
  elseif id == "Img_Btn" and clickobj.parent.name == "Group_Popularity" then
    self:OnClickPosHistoryBtn()
  elseif id == "Img_Btn" and clickobj.parent.name == "Group_Gift" then
    self:OnClickGiftHistoryBtn()
  else
    local msgId = self:GetCurDealMsgID(clickobj, 1)
    if msgId then
      self:OnSelectMsg(msgId)
    end
  end
end
def.method().InitUI = function(self)
  self.m_UIGOs = {}
  self.m_UIGOs.Group_NoData = self.m_node:FindDirect("Group_NoData")
  self.m_UIGOs.Group_Right = self.m_node:FindDirect("Group_Right")
  self.m_UIGOs.Group_Message = self.m_UIGOs.Group_Right:FindDirect("Group_Message")
  self.m_UIGOs.ScrollView_Message = self.m_UIGOs.Group_Message:FindDirect("ScrollView")
  self.m_UIGOs.UIScrollView_Message = self.m_UIGOs.ScrollView_Message:GetComponent("UIScrollView")
  self.m_UIGOs.Table_Message = self.m_UIGOs.ScrollView_Message:FindDirect("Table")
  self.m_UIGOs.Template_Message = self.m_UIGOs.Table_Message:FindDirect("Message")
  self.m_UIGOs.Template_Message:SetActive(false)
  self.m_UIGOs.Template_Message:GetComponent("UIWidget"):set_alpha(0)
  self.m_UIGOs.Group_Refresh = self.m_UIGOs.Group_Message:FindDirect("Refresh")
  self.m_UIGOs.Group_RefreshDown = self.m_UIGOs.Group_Refresh:FindDirect("Group_Down")
  self.m_UIGOs.Group_RefreshUp = self.m_UIGOs.Group_Refresh:FindDirect("Group_Up")
  self.m_UIGOs.Panel_PushOptions = self.m_UIGOs.Group_Right:FindDirect("Panel_PushOptions")
  self.m_UIGOs.Group_InputWords = self.m_UIGOs.Group_Right:FindDirect("Group_InputWords")
  self.m_UIGOs.Group_Title = self.m_UIGOs.Group_Right:FindDirect("Group_Title")
  self.m_UIGOs.Group_Bottom = self.m_UIGOs.Group_Right:FindDirect("Group_Bottom")
  self.m_UIGOs.Btn_FollowSpace = self.m_UIGOs.Group_Bottom:FindDirect("Btn_FollowSpace")
  if self.m_UIGOs.Btn_FollowSpace then
    self.m_UIGOs.Btn_FollowSpace.transform:SetAsFirstSibling()
  end
  local Img_BgInput = self.m_UIGOs.Group_InputWords:FindDirect("Img_BgInput")
  local uiInput = Img_BgInput:GetComponent("UIInput")
  self.m_UIGOs.msgInput = uiInput
  self.m_msgInputCtrl = SpaceInputCtrl.New(self, uiInput)
  if self.m_UIGOs.Group_NoData then
    GUIUtils.SetText(self.m_UIGOs.Group_NoData:FindDirect("Img_Talk/Label"), textRes.SocialSpace[38])
  end
end
def.method().UpdateUI = function(self)
  self:UpdateHeadInfos()
  self:UpdateBottomGroup()
end
def.method().UpdateHeadInfos = function(self)
  local Label_Histroy = self.m_UIGOs.Group_Title:FindDirect("Label_Histroy")
  local Label_Week = self.m_UIGOs.Group_Title:FindDirect("Label_Week")
  local Group_Chest = self.m_UIGOs.Group_Title:FindDirect("Group_Chest")
  local Group_Popularity = self.m_UIGOs.Group_Title:FindDirect("Group_Popularity")
  local Group_Gift = self.m_UIGOs.Group_Title:FindDirect("Group_Gift")
  local text = textRes.SocialSpace[16]:format(self.m_spaceBase.totalPopular)
  GUIUtils.SetText(Label_Histroy, text)
  local text = textRes.SocialSpace[17]:format(self.m_spaceBase.thisWeekPopular)
  GUIUtils.SetText(Label_Week, text)
  local Label_ChestNum = Group_Chest:FindDirect("Label_Num")
  local Label_PopNum = Group_Popularity:FindDirect("Label_Num")
  local Label_GiftNum = Group_Gift:FindDirect("Label_Num")
  GUIUtils.SetText(Label_ChestNum, self.m_spaceBase.giftCount)
  GUIUtils.SetText(Label_PopNum, self.m_spaceBase.totalPopular)
  GUIUtils.SetText(Label_GiftNum, self.m_spaceBase.gainGiftCount)
  local Img_Btn = Group_Chest:FindDirect("Img_Btn")
  GUIUtils.SetActive(Img_Btn, self.m_base:IsMySpace())
end
def.method().UpdateBottomGroup = function(self)
  local showBtnGroup = not self.m_base:IsMySpace()
  self.m_UIGOs.Group_Bottom:SetActive(showBtnGroup)
  if showBtnGroup then
    self:UpdateAddFriendBtn()
    self:UpdateFocusBtn()
    self:UpdateBlacklistBtn()
  end
  self:RepositionBottomGroup()
end
def.method().RepositionBottomGroup = function(self)
  self.m_UIGOs.Group_Bottom:GetComponent("UIGrid"):Reposition()
end
def.method().UpdateAddFriendBtn = function(self)
  local sameServer = self.m_spaceMan:IsTheSameServerWithHost(self.m_spaceBase.serverId)
  local canShowFocusBtn = self:CanShowFocusBtn()
  local canShow = sameServer and not canShowFocusBtn
  local Btn_AddFriends = self.m_UIGOs.Group_Bottom:FindDirect("Btn_AddFriends")
  Btn_AddFriends:SetActive(canShow)
  if not canShow then
    return
  end
  local isMyFriend = FriendModule.Instance():GetFriendInfo(self.m_ownerId)
  local Label_Name = Btn_AddFriends:FindDirect("Label_Name")
  local text = isMyFriend and textRes.Friend[2] or textRes.Friend[1]
  GUIUtils.SetText(Label_Name, text)
end
def.method().UpdateFocusBtn = function(self)
  local canShow = self:CanShowFocusBtn()
  GUIUtils.SetActive(self.m_UIGOs.Btn_FollowSpace, canShow)
  if not canShow then
    return
  end
  local Label_Name = self.m_UIGOs.Btn_FollowSpace:FindDirect("Label_Name")
  local text
  if SocialSpaceFocusMan.Instance():HasFocusOnRole(self.m_ownerId) then
    text = textRes.SocialSpace[119]
  else
    text = textRes.SocialSpace[113]
  end
  GUIUtils.SetText(Label_Name, text)
end
def.method("=>", "boolean").CanShowFocusBtn = function(self)
  return false
end
def.method().UpdateBlacklistBtn = function(self)
  local sameServer = self.m_spaceMan:IsTheSameServerWithHost(self.m_spaceBase.serverId)
  local Btn_BlackList = self.m_UIGOs.Group_Bottom:FindDirect("Btn_BlackList")
  local btnCanShow = false
  if sameServer then
    btnCanShow = true
  else
    local Feature = require("netio.protocol.mzm.gsp.open.ModuleFunSwitchInfo")
    if _G.IsFeatureOpen(Feature.TYPE_FRIENDS_CIRCLE_CROSS_SERVER_BLACK_LIST) then
      btnCanShow = true
    end
  end
  Btn_BlackList:SetActive(btnCanShow)
  if not btnCanShow then
    return
  end
  if not self.m_spaceMan:IsBlacklistInited() then
    Btn_BlackList:SetActive(false)
    self.m_spaceMan:ReqHostBlacklist(nil, false)
    return
  end
  local isInMyBlacklist = self.m_spaceMan:IsRoleInActiveBlacklist(self.m_ownerId)
  local Label_Name = Btn_BlackList:FindDirect("Label_Name")
  local text = isInMyBlacklist and textRes.SocialSpace[94] or textRes.SocialSpace[93]
  GUIUtils.SetText(Label_Name, text)
end
def.override("boolean", "boolean").RefreshMsg = function(self, bGetEarlyMsg, bCheckCoolTime)
  if not self:IsNodeShow() then
    return
  end
  local roleId, len = self.m_ownerId, self.m_msgCountPerPage
  local lastID
  if bGetEarlyMsg then
    local msgCount = self.m_UIGOs.Table_Message:get_childCount() - 1
    if msgCount > 0 then
      local LastObj = self.m_UIGOs.Table_Message:GetChild(msgCount)
      local be, ed
      be, ed, lastID = LastObj.name:find("message_(%d+)")
      lastID = lastID and Int64.ParseString(lastID)
    end
  end
  lastID = lastID or Zero_Int64
  ECSocialSpaceMan.Instance():LoadPlayerLeaveMsgsBeforeID(roleId, lastID, len, function(msgList)
    if not self:IsNodeShow() then
      return
    end
    self:AppendMsgList(msgList, bGetEarlyMsg)
    if #msgList == 0 and bGetEarlyMsg and bCheckCoolTime then
      self:PlayNoMoreMsgAni()
    end
  end, bCheckCoolTime)
end
def.method("table", "boolean").AppendMsgList = function(self, srclist, bGetEarlyMsg)
  if not self.m_panel or self.m_panel.isnil then
    return
  end
  local msgCount = self.m_UIGOs.Table_Message:get_childCount() - 1
  local beginIdx = bGetEarlyMsg and msgCount or 0
  local msgList = self:FliterMsgList(srclist)
  if ECDebugOption.Instance().showSSlog then
    print("bGetEarlyMsg", bGetEarlyMsg)
  end
  self.m_msgList = self.m_spaceMan:MergeSort(self.m_msgList, msgList, ECSocialSpaceMan.STATUS_SORT_TYPE.TIMESTAMP, 0)
  local updatedMsgs = {}
  for i, msg in ipairs(msgList) do
    updatedMsgs[msg.ID:tostring()] = msg
  end
  local siblingIndex = 1
  for i, msg in ipairs(self.m_msgList) do
    local msgId = msg.ID
    local msgIdStr = msgId:tostring()
    local itemUI = self.m_UIGOs.Table_Message:FindDirect(string.format("message_%s", msgIdStr))
    if updatedMsgs[msgIdStr] then
      itemUI = itemUI or self:NewMessageUI()
      itemUI.transform:SetSiblingIndex(siblingIndex)
      self:UpdateSingleMsg(itemUI, msg)
      siblingIndex = siblingIndex + 1
    elseif itemUI then
      itemUI.transform:SetSiblingIndex(siblingIndex)
      self:SetMessageTime(itemUI, msg)
      siblingIndex = siblingIndex + 1
    end
  end
  local noData = false
  if beginIdx == 0 then
    noData = #msgList == 0
  end
  GUIUtils.SetActive(self.m_UIGOs.Group_NoData, noData)
  local haveData = not noData
  if haveData then
    self:RepositionMsgTable(nil, true)
  end
end
def.method("userdata", "boolean").RepositionMsgTable = function(self, focusItemUI, bReposTable)
  GameUtil.AddGlobalTimer(0, true, function()
    GameUtil.AddGlobalTimer(0, true, function()
      if self:IsNodeShow() then
        if bReposTable then
          GUIUtils.Reposition(self.m_UIGOs.Table_Message, "UITable")
        end
        local ScrollView = self.m_UIGOs.UIScrollView_Message
        local uiScrollView = ScrollView:GetComponent("UIScrollView")
        if not _G.IsNil(focusItemUI) then
          uiScrollView:DragToMakeVisible(focusItemUI.transform, 4)
          self.m_viewInited = true
        end
        if not self.m_viewInited then
          uiScrollView:ResetPosition()
          self.m_viewInited = true
        end
      end
    end)
  end)
end
def.method("table", "=>", "table").FliterMsgList = function(self, msgList)
  return msgList
end
def.method("userdata", ECSpaceMsgs.ECLeaveMsg).UpdateSingleMsg = function(self, itemUI, msg)
  if not self:IsNodeShow() then
    return
  end
  self:SetMessage(itemUI, msg)
end
def.method().UpdateAllMessagesTime = function(self)
  for i, msg in ipairs(self.m_msgList) do
    local msgId = msg.ID
    local msgIdStr = msgId:tostring()
    local itemUI = self.m_UIGOs.Table_Message:FindDirect(string.format("message_%s", msgIdStr))
    self:SetMessageTime(itemUI, msg)
  end
end
def.method("userdata", "table").SetMessageTime = function(self, go, messageInfo)
  if go == nil then
    return
  end
  local Group_Head = go:FindDirect("Group_Head")
  local Label_Time = Group_Head:FindDirect("Label_Time")
  self:SetCreateTime(Label_Time, messageInfo.timestamp)
end
def.method("=>", "userdata").NewMessageUI = function(self)
  local go = GameObject.Instantiate(self.m_UIGOs.Template_Message)
  go:SetActive(true)
  go.parent = self.m_UIGOs.Table_Message
  go.localScale = Vector.Vector3.one
  GameUtil.AddGlobalTimer(0, true, function()
    GameUtil.AddGlobalTimer(0, true, function()
      if _G.IsNil(go) then
        return
      end
      go:GetComponent("UIWidget"):set_alpha(1)
    end)
  end)
  return go
end
def.method().ResetViewPosition = function(self)
  local ScrollView = self.m_UIGOs.UIScrollView_Message
  local uiScrollView = ScrollView:GetComponent("UIScrollView")
  uiScrollView:ResetPosition()
end
def.method("userdata", "number").RepositionMessage = function(self, go, delayFrame)
  local function onReposition()
    local uiTableResizeBackground = go:GetComponent("UITableResizeBackground")
    uiTableResizeBackground:Reposition()
  end
  local function run(delayFrame)
    if delayFrame <= 0 then
      onReposition()
      return
    end
    GameUtil.AddGlobalLateTimer(0, true, function()
      if _G.IsNil(go) then
        return
      end
      run(delayFrame - 1)
    end)
  end
  run(delayFrame)
end
def.method("userdata", "table").SetMessage = function(self, go, messageInfo)
  go.name = "message_" .. tostring(messageInfo.ID)
  local Group_Head = go:FindDirect("Group_Head")
  local Label_Info = Group_Head:FindDirect("Label_Info")
  local Group_Texture = Group_Head:FindDirect("Group_Texture")
  local Group_Name = Group_Head:FindDirect("Group_Name")
  local Img_Head = Group_Head:FindDirect("Img_Head")
  local Label_Time = Group_Head:FindDirect("Label_Time")
  local Group_Common = Group_Head:FindDirect("Group_Common")
  self:SetHeadAvatar(Img_Head, messageInfo)
  self:SetGroupName(Group_Name, messageInfo)
  local strRichMsg = SocialSpaceUtils.BuildMsgBoardContent(messageInfo)
  self:SetTextMessage(Label_Info, strRichMsg)
  self:SetPhotoMessage(Group_Texture, messageInfo)
  self:SetCreateTime(Label_Time, messageInfo.timestamp)
  local Group_Like = go:FindDirect("Group_Like")
  local Group_Text = go:FindDirect("Group_Text")
  local Group_ShowMore = go:FindDirect("Group_ShowMore")
  Group_ShowMore:SetActive(false)
  self:SetGroupLike(Group_Like, messageInfo)
  self:SetGroupBriefReply(Group_Text, messageInfo)
  local Btn_Del = Group_Common:FindDirect("Btn_Del")
  local myRoleId = _G.GetMyRoleID()
  local canDel = myRoleId == messageInfo.roleId or myRoleId == messageInfo.targetId
  Btn_Del:SetActive(canDel)
  self:RepositionMessage(go, 2)
end
def.method("userdata", "table").SetGroupBriefReply = function(self, Group_Text, messageInfo)
  local haveReply = false
  Group_Text:SetActive(haveReply)
end
def.method("userdata", "table").SetGroupLike = function(self, Group_Like, messageInfo)
  Group_Like:SetActive(false)
end
def.method("userdata", "table").SetHeadAvatar = function(self, Img_Head, messageInfo)
  _G.SetAvatarIcon(Img_Head, messageInfo.idphoto, messageInfo.avatarFrameId)
  local Label_Lv = Img_Head:FindDirect("Label_Lv")
  local EMPTY_LEVEL = ""
  GUIUtils.SetText(Label_Lv, EMPTY_LEVEL)
end
def.method("userdata", "table").SetGroupName = function(self, Group_Name, messageInfo)
  local Label_Name = Group_Name:FindDirect("Label_Name")
  local Img_Sex = Group_Name:FindDirect("Img_Sex")
  local Img_School = Group_Name:FindDirect("Img_School")
  local Img_Friend = Group_Name:FindDirect("Img_Friend")
  GUIUtils.SetText(Label_Name, messageInfo.playerName)
  GUIUtils.SetSprite(Img_Sex, "nil")
  GUIUtils.SetSprite(Img_School, "nil")
  SocialSpaceProfileMan.Instance():AsyncGetRoleProfile(messageInfo.roleId, function(profile)
    if not self:IsNodeShow() then
      return
    end
    GUIUtils.SetSprite(Img_Sex, GUIUtils.GetGenderSprite(profile.gender))
    GUIUtils.SetSprite(Img_School, GUIUtils.GetOccupationSmallIcon(profile.prof))
  end)
  self.m_friendMarkContainer:AddFriendMark({
    go = Img_Friend,
    roleId = messageInfo.roleId
  })
end
def.method("userdata", "string").SetTextMessage = function(self, Label_Info, strRichMsg)
  local html = Label_Info:GetComponent("NGUIHTML")
  self:SetHtmlText(html, strRichMsg)
end
def.method("userdata", "table").SetPhotoMessage = function(self, Group_Texture, messageInfo)
  Group_Texture:SetActive(false)
end
def.method("userdata", "number").SetCreateTime = function(self, Label_Time, timestamp)
  local text = SocialSpaceUtils.TimestampToDisplayText(timestamp)
  GUIUtils.SetText(Label_Time, text)
end
def.method().OnClickLeaveMsgBtn = function(self)
  self.m_replyRoleId = Zero_Int64
  self.m_replyRoleName = ""
  self:SwitchPubTextMsg(true, nil)
end
def.method("boolean", "table").SwitchPubTextMsg = function(self, isShow, params)
  self.m_UIGOs.Group_InputWords:SetActive(isShow)
  self.m_UIGOs.Group_Title:FindDirect("Btn_LeaveMessage"):SetActive(not isShow)
  self.m_UIGOs.Group_Title:FindDirect("Label_Histroy"):SetActive(not isShow)
  self.m_UIGOs.Group_Title:FindDirect("Label_Week"):SetActive(not isShow)
  local defaultText
  if self.m_replyRoleId ~= Zero_Int64 then
    defaultText = textRes.SocialSpace[19]:format(self.m_replyRoleName)
  else
    defaultText = textRes.SocialSpace[20]
  end
  self.m_UIGOs.msgInput:set_defaultText(defaultText)
  self.m_charLimit = ECSocialSpaceConfig.getLeaveMsgCharLimit()
  self.m_UIGOs.msgInput:set_characterLimit(self.m_charLimit)
end
def.method().OnClickSendBtn = function(self)
  self:OnLeaveMsg()
end
def.method("string", "=>", "boolean").OnSendContent = function(self, cnt)
  self:LeaveMsg(cnt)
  return true
end
def.method().OnLeaveMsg = function(self)
  local Img_BgInput = self.m_UIGOs.Group_InputWords:FindDirect("Img_BgInput")
  local uiInput = Img_BgInput:GetComponent("UIInput")
  local inputValue = uiInput:get_value()
  self:LeaveMsg(inputValue)
end
def.method("string", "=>", "boolean").LeaveMsg = function(self, inputValue)
  if not self.m_base:IsMySpace() then
    if self.m_spaceBase.messageType == ECSpaceMsgs.ACCESS_TYPE.NOBODY then
      Toast(textRes.SocialSpace[41])
      return false
    end
    if self.m_spaceBase.messageType == ECSpaceMsgs.ACCESS_TYPE.ONLY_FRINEDS then
      local isMyFriend = FriendModule.Instance():GetFriendInfo(self.m_ownerId)
      if not isMyFriend then
        Toast(textRes.SocialSpace[42])
        return false
      end
    end
  end
  local plainMsg = self.m_msgInputCtrl:GetContent(inputValue)
  if plainMsg == "" then
    Toast(textRes.SocialSpace[13])
    return false
  end
  local msg = ECSpaceMsgs.ECLeaveMsg()
  msg.strPlainMsg = plainMsg
  local hp = self.m_spaceMan:GetHostPlayerInfos()
  local itemData = ""
  msg.roleId = hp.roleId
  msg.serverId = hp.serverId
  msg.playerName = hp.name
  msg.idphoto = hp.avatarId
  msg.avatarFrameId = hp.avatarFrameId
  msg.targetId = self.m_ownerId
  msg.replyRoleId = self.m_replyRoleId
  msg.replyRoleName = self.m_replyRoleName
  msg.strPlainMsg = plainMsg
  msg.strData = itemData
  msg.strRichMsg = ECSocialSpaceMan.BuildSpaceRichContent(plainMsg, itemData)
  msg.timestamp = _G.GetServerTime()
  self.m_spaceMan:Req_LeaveMsgToPlayer(msg, function(data)
    if not self:IsNodeShow() then
      return
    end
    self:CheckHasNewMsg()
  end, true)
  self:ClearAfterSend()
  return true
end
def.method().ClearAfterSend = function(self)
  self:ClearInputedMsg()
end
def.method().ClearInputedMsg = function(self)
  self.m_msgInputCtrl:ClearContent()
end
def.method().OnClickEmojiBtn = function(self)
  self.m_msgInputCtrl:ShowInputDlg()
end
def.method().OnClickBackBtn = function(self)
  self:SwitchPubTextMsg(false, nil)
end
def.method("userdata").OnClickDelBtn = function(self, sender)
  local msgId = self:GetCurDealMsgID(sender)
  if msgId == nil then
    return
  end
  CommonConfirmDlg.ShowConfirm(textRes.Common[8], textRes.SocialSpace[23], function(s)
    if s == 1 then
      self.m_spaceMan:Req_DeleteLeaveMsg(self.m_ownerId, msgId, function(data)
        if self:IsNodeShow() then
          self:RemoveMsgByMsgID(msgId)
          local msgCount = self.m_UIGOs.Table_Message:get_childCount() - 1
          if msgCount < self.m_msgCountPerPage then
            self:AppendNextPageMsg(false)
          end
        end
      end, true)
    end
  end, nil)
end
def.method("userdata").OnClickHeadImg = function(self, sender)
  local msgId = self:GetCurDealMsgID(sender, 5)
  local msg = self.m_spaceMan:FindPlayerLeaveMsgByID(self.m_ownerId, msgId)
  if msg == nil then
    return
  end
  self.m_spaceMan:ShowPlayerMenu(sender, msg.roleId, msg.playerName, msg.idphoto, msg.serverId)
end
def.method("userdata").OnClickPopBtn = function(self, sender)
  self.m_spaceMan:DoAddSpacePopular(self.m_ownerId)
end
def.method("userdata").OnClickGiveGiftBtn = function(self, sender)
  SocialSpaceUtils.ShowGiveGiftPanel(self.m_ownerId)
end
def.method().OnClickAddFriendBtn = function(self)
  local roleId = self.m_ownerId
  local roleName = self.m_ownerName
  FriendModule.AddFriendOrDeleteFriend(roleId, roleName)
end
def.method().OnClickFocusBtn = function(self)
end
def.method().OnClickBlackListBtn = function(self)
  if self.m_spaceMan:IsRoleInActiveBlacklist(self.m_ownerId) then
    self.m_spaceMan:ReqRemoveRoleFromBlacklist(self.m_ownerId)
  else
    local CommonConfirmDlg = require("GUI.CommonConfirmDlg")
    CommonConfirmDlg.ShowConfirm(textRes.Common[8], textRes.SocialSpace[92], function(s)
      if s == 1 then
        self.m_spaceMan:ReqAddRoleToBlacklist(self.m_ownerId, nil)
      end
    end, nil)
  end
end
def.method().OnClickAddChestBtn = function(self)
  local Feature = require("netio.protocol.mzm.gsp.open.ModuleFunSwitchInfo")
  if not _G.IsFeatureOpen(Feature.TYPE_BUY_TREASURE_BOX) then
    Toast(textRes.SocialSpace[45])
    return
  end
  local maxNum = ECSocialSpaceConfig.getMaxPlaceBoxCount()
  local maxBuyNum = maxNum - self.m_spaceBase.giftCount
  if maxBuyNum <= 0 then
    Toast(textRes.SocialSpace[46])
    return
  end
  local function onBuy(context, buyNum)
    if self.m_spaceBase == nil then
      return true
    end
    local maxBuyNum = maxNum - self.m_spaceBase.giftCount
    if buyNum > maxBuyNum then
      Toast(textRes.SocialSpace[48]:format(maxBuyNum))
      return false
    end
    self.m_spaceMan:BuyTreauseChest(buyNum)
    return true
  end
  local price = ECSocialSpaceConfig.getSpaceBoxPrice()
  local MoneyType = require("consts.mzm.gsp.item.confbean.MoneyType")
  local SpaceBuyItemPanel = require("Main.SocialSpace.ui.SpaceBuyItemPanel")
  local params = {}
  params.desc = textRes.SocialSpace[47]
  params.moneyType = MoneyType.GOLD
  params.price = price
  params.defaultNum = maxBuyNum
  params.maxNum = maxBuyNum
  SpaceBuyItemPanel.ShowPanel(params, onBuy, nil)
end
def.method().OnClickPosHistoryBtn = function(self)
  local Feature = require("netio.protocol.mzm.gsp.open.ModuleFunSwitchInfo")
  if not _G.IsFeatureOpen(Feature.TYPE_TREAD_CIRCLE) then
    Toast(textRes.SocialSpace[45])
    return
  end
  require("Main.SocialSpace.ui.SpacePopHistoryPanel").Instance():ShowPanel(self.m_ownerId)
end
def.method().OnClickGiftHistoryBtn = function(self)
  SocialSpaceUtils.ShowGiftHistory(self.m_ownerId)
end
def.method("userdata").OnSelectMsg = function(self, msgId)
  local msg = self.m_spaceMan:FindPlayerLeaveMsgByID(self.m_ownerId, msgId)
  if msg == nil then
    return
  end
  self.m_replyRoleId = msg.roleId
  self.m_replyRoleName = msg.playerName
  warn(self.m_replyRoleId, self.m_replyRoleName)
  self:SwitchPubTextMsg(true, nil)
end
local messageDragY
def.override("string").onDragStart = function(self, id)
end
def.override("string").onDragEnd = function(self, id)
  if self.m_msgRefreshState ~= MsgRefreshState.Hide then
    if self.m_msgRefreshState == MsgRefreshState.Up then
      self:CheckHasNewMsg()
    end
    self:SetMsgRefreshPrompt(MsgRefreshState.Hide)
  end
  messageDragY = nil
  self.m_bAppendingMsg = false
end
def.override("string", "number", "number").onDrag = function(self, id, dx, dy)
  if messageDragY or self:IsMessageDraging() then
    messageDragY = messageDragY or 0
    messageDragY = messageDragY + dy
    local dragAmount = self.m_UIGOs.UIScrollView_Message:GetDragAmount()
    if 0 > dragAmount.y then
      if messageDragY < -40 then
        self:SetMsgRefreshPrompt(MsgRefreshState.Up)
      elseif messageDragY < -5 then
        self:SetMsgRefreshPrompt(MsgRefreshState.Down)
      end
    elseif dragAmount.y > 1.02 and not self.m_bAppendingMsg then
      self.m_bAppendingMsg = true
      self:AppendNextPageMsg(true)
    end
  end
end
def.method("=>", "boolean").IsMessageDraging = function(self)
  if self.m_UIGOs.UIScrollView_Message:get_isDragging() then
    return true
  else
    return false
  end
end
def.method("number").SetMsgRefreshPrompt = function(self, state)
  if self.m_msgRefreshState == state and state ~= MsgRefreshState.Hide then
    return
  end
  if state == MsgRefreshState.Up then
    self.m_UIGOs.Group_Refresh:SetActive(true)
    self.m_UIGOs.Group_RefreshDown:SetActive(false)
    self.m_UIGOs.Group_RefreshUp:SetActive(true)
  elseif state == MsgRefreshState.Down then
    self.m_UIGOs.Group_Refresh:SetActive(true)
    self.m_UIGOs.Group_RefreshDown:SetActive(true)
    self.m_UIGOs.Group_RefreshUp:SetActive(false)
  else
    self.m_UIGOs.Group_Refresh:SetActive(false)
  end
  self.m_msgRefreshState = state
end
def.method("table").OnFriendChanged = function(self)
  self:UpdateAddFriendBtn()
  self:UpdateFocusBtn()
end
def.method("table").OnTreauseChestChanged = function(self)
  self:UpdateHeadInfos()
end
def.method("table").OnPopularChanged = function(self)
  self:UpdateHeadInfos()
end
def.method("table").OnBlacklistChanged = function(self, params)
  self:UpdateBlacklistBtn()
  self:RepositionBottomGroup()
end
def.method("table").OnFocusBtnChanged = function(self, params)
  self:UpdateBottomGroup()
end
return SpaceMessageBoard.Commit()
