local MODULE_NAME = (...)
local Lplus = require("Lplus")
local SpacePanelNodeBase = import(".SpacePanelNodeBase")
local SpaceFriendsCircleNode = Lplus.Extend(SpacePanelNodeBase, MODULE_NAME)
local GUIUtils = require("GUI.GUIUtils")
local Vector = require("Types.Vector")
local def = SpaceFriendsCircleNode.define
local SocialSpaceUtils = import("..SocialSpaceUtils")
local ECSocialSpaceMan = require("Main.SocialSpace.ECSocialSpaceMan")
local ECSocialSpaceCosMan = require("Main.SocialSpace.ECSocialSpaceCosMan")
local ECDebugOption = require("Main.ECDebugOption")
local ECSpaceMsgs = require("Main.SocialSpace.ECSpaceMsgs")
local ECSocialSpaceConfig = require("Main.SocialSpace.ECSocialSpaceConfig")
local SocialSpaceProfileMan = require("Main.SocialSpace.SocialSpaceProfileMan")
local ChatUtils = require("Main.Chat.ChatUtils")
local HtmlHelper = require("Main.Chat.HtmlHelper")
local SpaceInputCtrl = import(".SpaceInputCtrl")
local CommonConfirmDlg = require("GUI.CommonConfirmDlg")
local cos_cfg = ECSocialSpaceCosMan.Instance():GetCosCfg()
local ShortReplyDisplayNum = 3
local LongReplyDisplayNum = 10
local MAX_DISPLAY_PIC = 4
local MsgRefreshState = {
  Hide = 0,
  Down = 1,
  Up = 2,
  Pull = 3
}
def.const("table").MsgRefreshState = MsgRefreshState
local MsgPubType = {
  NewMsg = 1,
  ReplyMsg = 2,
  LeaveMsg = 3
}
def.const("table").MsgPubType = MsgPubType
def.field("table").m_UIGOs = nil
def.field("number").m_msgCountPerPage = 4
def.field("boolean").m_bOnlyShowSelf = false
def.field("boolean").m_bAppendingMsg = false
def.field("number").m_msgRefreshState = -1
def.field("table").m_pubMsgParams = nil
def.field(ECSocialSpaceMan).m_spaceMan = nil
def.field(SpaceInputCtrl).m_msgInputCtrl = nil
def.field("userdata").m_replyMsgId = Zero_Int64_Init
def.field("userdata").m_replyId = Zero_Int64_Init
def.field("userdata").m_replyRoleId = Zero_Int64_Init
def.field("string").m_replyRoleName = ""
def.field("number").m_replyDisplyNum = ShortReplyDisplayNum
def.field("table").m_detailMsg = nil
def.field("userdata").m_detailMsgUI = nil
def.field("boolean").m_hasAppendedMsg = false
def.field("table").m_friendMarkContainer = nil
def.override().OnCreate = function(self)
  self.m_spaceMan = ECSocialSpaceMan.Instance()
end
def.override("=>", "boolean").IsOpen = function(self)
  return self.m_base:IsMySpace()
end
def.override().OnShow = function(self)
  self.m_friendMarkContainer = require("Main.SocialSpace.FriendMarkHelper").Instance():CreateContainer()
  self:InitUI()
  self:CheckHasNewMsg()
  self:UpdateNewMsgCount()
  Event.RegisterEventWithContext(ModuleId.SOCIAL_SPACE, gmodule.notifyId.SocialSpace.SpaceNewMsg, self.OnNewMsg, self)
  Event.RegisterEventWithContext(ModuleId.SOCIAL_SPACE, gmodule.notifyId.SocialSpace.MsgPublished, self.OnMsgPublished, self)
end
def.override().OnHide = function(self)
  Event.UnregisterEvent(ModuleId.SOCIAL_SPACE, gmodule.notifyId.SocialSpace.MsgPublished, self.OnMsgPublished)
  Event.UnregisterEvent(ModuleId.SOCIAL_SPACE, gmodule.notifyId.SocialSpace.SpaceNewMsg, self.OnNewMsg)
  if self.m_msgInputCtrl then
    self.m_msgInputCtrl:Destroy()
    self.m_msgInputCtrl = nil
  end
  if self.m_friendMarkContainer then
    self.m_friendMarkContainer:Destroy()
    self.m_friendMarkContainer = nil
  end
  self:ShowPubMsgOptions(false)
end
def.virtual().InitUI = function(self)
  if self.m_UIGOs == nil then
    self.m_UIGOs = {}
    self.m_UIGOs.Group_NoData = self.m_node:FindDirect("Group_NoData")
    self.m_UIGOs.Group_Right = self.m_node:FindDirect("Group_Right")
    self.m_UIGOs.Group_Message = self.m_UIGOs.Group_Right:FindDirect("Group_Message")
    self.m_UIGOs.ScrollView_Message = self.m_UIGOs.Group_Message:FindDirect("ScrollView")
    self.m_UIGOs.UIScrollView_Message = self.m_UIGOs.ScrollView_Message:GetComponent("UIScrollView")
    self.m_UIGOs.Table_Message = self.m_UIGOs.ScrollView_Message:FindDirect("Table")
    self.m_UIGOs.Template_Message = self.m_UIGOs.Table_Message:FindDirect("Message")
    self.m_UIGOs.Template_Message:SetActive(false)
    self.m_UIGOs.Group_Refresh = self.m_UIGOs.Group_Message:FindDirect("Refresh")
    self.m_UIGOs.Group_RefreshDown = self.m_UIGOs.Group_Refresh:FindDirect("Group_Down")
    self.m_UIGOs.Group_RefreshUp = self.m_UIGOs.Group_Refresh:FindDirect("Group_Up")
    self.m_UIGOs.Panel_PushOptions = self.m_UIGOs.Group_Right:FindDirect("Panel_PushOptions")
    self.m_UIGOs.Group_InputWords = self.m_UIGOs.Group_Right:FindDirect("Group_InputWords")
    self.m_UIGOs.Group_Title = self.m_UIGOs.Group_Right:FindDirect("Group_Title")
    self.m_UIGOs.ScrollView_MessageDetail = GameObject.Instantiate(self.m_UIGOs.ScrollView_Message)
    self.m_UIGOs.ScrollView_MessageDetail.parent = self.m_UIGOs.Group_Message
    self.m_UIGOs.ScrollView_MessageDetail.localScale = Vector.Vector3.one
    self.m_UIGOs.ScrollView_MessageDetail.localPosition = self.m_UIGOs.ScrollView_Message
    self.m_UIGOs.ScrollView_MessageDetail:SetActive(false)
    self.m_UIGOs.UIScrollView_MessageDetail = self.m_UIGOs.ScrollView_MessageDetail:GetComponent("UIScrollView")
    self:SwitchPubTextMsg(false, nil)
  elseif self.m_needReset then
    local Table_Message = self.m_UIGOs.Table_Message
    local childCount = Table_Message:get_childCount()
    for i = 1, childCount - 1 do
      local child = Table_Message:GetChild(i)
      GameObject.Destroy(child)
    end
    self.m_msgList = {}
    self.m_hasAppendedMsg = false
    self.m_needReset = false
  end
  local Img_BgInput = self.m_UIGOs.Group_InputWords:FindDirect("Img_BgInput")
  local uiInput = Img_BgInput:GetComponent("UIInput")
  self.m_UIGOs.msgInput = uiInput
  self.m_msgInputCtrl = SpaceInputCtrl.New(self, uiInput)
end
def.override("userdata").onClickObj = function(self, clickobj)
  local id = clickobj.name
  local isShowPubMsgOptions = false
  if id == "Btn_Push" then
    isShowPubMsgOptions = self:OnPubMessageBtnClick()
  elseif id == "Btn_Send" then
    self:OnClickSendBtn()
  elseif id == "Btn_Clear" then
    self:ClearInputedMsg()
  elseif id == "Btn_Add" then
    self:OnClickEmojiBtn()
  elseif id == "Btn_Back" then
    self:OnClickBackBtn()
  elseif id == "Btn_BackMain" then
    self:OnClickBackMainBtn()
  elseif id == "Btn_Del" then
    self:OnClickDelBtn(clickobj)
  elseif id == "Img_Like" then
    self:OnClickLikeBtn(clickobj)
  elseif id == "Img_Icon" and clickobj.parent.name == "Group_Like" then
    self:OnClickLikeListBtn(clickobj)
  elseif id == "Label_Name" and clickobj.parent.name == "Group_ShowAll" then
    self:OnClickShowAllBtn(clickobj)
  elseif id == "Img_Repost" then
    self:OnClickRepostBtn(clickobj)
  elseif id == "Img_Reply" then
    self:OnClickReplyImg(clickobj)
  elseif id == "Img_Head" then
    self:OnClickHeadImg(clickobj)
  elseif id == "Btn_NewMessage" then
    self:OnClickNewMessageBtn()
  elseif id == "Btn_Transmit" then
    self:OnClickTransmitBtn(clickobj)
  elseif id == "Btn_Option" then
    self:OnClickOptionBtn()
  elseif id == "Btn_BlackList" then
    SocialSpaceUtils.ShowFeatureNotOpenPrompt()
  elseif id:sub(1, 4) == "Btn_" and self:IsPubMsgOptionOpend() then
    if id == "Btn_1" then
      self:SwitchPubTextMsg(true, {
        pubType = MsgPubType.NewMsg,
        labelSendText = textRes.SocialSpace[29]
      })
    elseif id == "Btn_2" then
      self:GetImageToUpload(ECSocialSpaceCosMan.FROM_CAMERA)
    elseif id == "Btn_3" then
      self:GetImageToUpload(ECSocialSpaceCosMan.FROM_ALBUM)
    else
      SocialSpaceUtils.ShowFeatureNotOpenPrompt()
    end
  elseif id:sub(1, 12) == "sspace_role_" then
    self:OnClickRoleLink(clickobj)
  elseif id:sub(1, 7) == "Texture" and clickobj.parent.parent.name == "Group_Texture" then
    self:OnClickPicture(clickobj)
  else
    local msgId = self:GetCurDealMsgID(clickobj, 1)
    if msgId and not self:IsPubMsgOptionOpend() then
      self:OnClickMsgBg(clickobj, msgId)
    end
  end
  self:ShowPubMsgOptions(isShowPubMsgOptions)
end
def.method("=>", "boolean").OnPubMessageBtnClick = function(self)
  if self:IsPubMsgOptionOpend() then
    return false
  else
    return true
  end
end
def.method("=>", "boolean").IsPubMsgOptionOpend = function(self)
  return self.m_UIGOs.Panel_PushOptions.activeSelf
end
def.method("boolean").ShowPubMsgOptions = function(self, isShow)
  self.m_UIGOs.Panel_PushOptions:SetActive(isShow)
  if not isShow then
    return
  end
end
def.virtual("boolean", "table").SwitchPubTextMsg = function(self, isShow, params)
  local isTitleShow = not isShow and self:IsTitleCanSee() and not self:IsShowMsgDetail()
  self.m_UIGOs.Group_Title:SetActive(isTitleShow)
  local Btn_Add = self.m_UIGOs.Group_InputWords:FindDirect("Btn_Add")
  local Img_BgInput = self.m_UIGOs.Group_InputWords:FindDirect("Img_BgInput")
  local Label_Detail = self.m_UIGOs.Group_InputWords:FindDirect("Label_Detail")
  local Btn_Back = self.m_UIGOs.Group_InputWords:FindDirect("Btn_Back")
  local Btn_BackMain = self.m_UIGOs.Group_InputWords:FindDirect("Btn_BackMain")
  if not isShow and self:IsShowMsgDetail() then
    self.m_UIGOs.Group_InputWords:SetActive(true)
    Btn_Add:SetActive(false)
    Img_BgInput:SetActive(false)
    Btn_Back:SetActive(false)
    GUIUtils.SetActive(Label_Detail, true)
    GUIUtils.SetActive(Btn_BackMain, true)
  else
    self.m_UIGOs.Group_InputWords:SetActive(isShow)
    Btn_Add:SetActive(isShow)
    Img_BgInput:SetActive(isShow)
    Btn_Back:SetActive(isShow)
    GUIUtils.SetActive(Label_Detail, not isShow)
    GUIUtils.SetActive(Btn_BackMain, not isShow)
  end
  if not isShow then
    return
  end
  local defaultText
  if params and params.pubType == MsgPubType.NewMsg then
    self.m_charLimit = ECSocialSpaceConfig.getMsgCharLimit()
    defaultText = textRes.SocialSpace[55]
  else
    self.m_charLimit = ECSocialSpaceConfig.getReplyMsgCharLimit()
    if self.m_replyRoleId ~= Zero_Int64 then
      defaultText = textRes.SocialSpace[19]:format(self.m_replyRoleName)
    else
      defaultText = textRes.SocialSpace[27]
    end
  end
  self.m_UIGOs.msgInput:set_defaultText(defaultText)
  self.m_UIGOs.msgInput:set_characterLimit(self.m_charLimit)
  self.m_pubMsgParams = params
  if params then
    local Label_Send = self.m_UIGOs.Group_InputWords:FindDirect("Img_BgInput/Btn_Send/Label_Send")
    GUIUtils.SetText(Label_Send, params.labelSendText)
  end
end
def.virtual("=>", "boolean").IsTitleCanSee = function(self)
  return true
end
def.method().OnClickSendBtn = function(self)
  local params = self.m_pubMsgParams
  if params == nil then
    return
  end
  if params.pubType == MsgPubType.NewMsg then
    self:OnSendNewMsg()
  elseif params.pubType == MsgPubType.ReplyMsg then
    self:OnSendReplyMsg()
  end
end
def.method("string", "=>", "boolean").OnSendContent = function(self, content)
  local params = self.m_pubMsgParams
  if params == nil then
    return
  end
  if params.pubType == MsgPubType.NewMsg then
    return self:SendNewMsg(content)
  elseif params.pubType == MsgPubType.ReplyMsg then
    return self:SendReplyMsg(content)
  end
  return true
end
def.method().OnSendNewMsg = function(self)
  local Img_BgInput = self.m_UIGOs.Group_InputWords:FindDirect("Img_BgInput")
  local uiInput = Img_BgInput:GetComponent("UIInput")
  local inputValue = uiInput:get_value()
  self:SendNewMsg(inputValue)
end
def.method("string", "=>", "boolean").SendNewMsg = function(self, inputValue)
  local plainMsg = self.m_msgInputCtrl:GetContent(inputValue)
  if plainMsg == "" then
    Toast(textRes.SocialSpace[13])
    return false
  end
  local msg = ECSpaceMsgs.ECSpaceMsg()
  msg.strPlainMsg = plainMsg
  self.m_spaceMan:Req_PublishNewStatus(msg, function(data)
    if data.retcode ~= 0 then
      return
    end
    if not self:IsNodeShow() then
      return
    end
  end, true)
  self:ClearAfterSend()
  return true
end
def.method().ClearAfterSend = function(self)
  self:ClearInputedMsg()
end
def.method().OnClickEmojiBtn = function(self)
  self.m_msgInputCtrl:ShowInputDlg()
end
def.method().OnClickBackBtn = function(self)
  if self:IsShowMsgDetail() then
    self:OnClickBackMainBtn()
  end
  self:SwitchPubTextMsg(false, nil)
end
def.method().OnClickBackMainBtn = function(self)
  self:ShowMsgDetail(false, nil)
  self:CheckHasNewMsg()
end
def.method("userdata").OnClickDelBtn = function(self, sender)
  if sender.parent.name == "Group_Common" then
    self:OnClickMsgDelBtn(sender)
  elseif sender.parent.name:find("reply_") then
    self:OnClickReplyDelBtn(sender)
  end
end
def.method("userdata").OnClickMsgDelBtn = function(self, sender)
  local msgId = self:GetCurDealMsgID(sender)
  if msgId == nil then
    return
  end
  CommonConfirmDlg.ShowConfirm(textRes.Common[8], textRes.SocialSpace[14], function(s)
    if s == 1 then
      self.m_spaceMan:Req_DeleteSpaceMsg(self.m_ownerId, msgId, function(data)
        if self:IsNodeShow() then
          if self:IsShowMsgDetail() then
            self:OnClickBackMainBtn()
          end
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
def.method("userdata").OnClickReplyDelBtn = function(self, sender)
  local msgId = self:GetCurDealMsgID(sender)
  if msgId == nil then
    return
  end
  local replyId = Int64.ParseString(sender.parent.name:split("_")[2])
  CommonConfirmDlg.ShowConfirm(textRes.Common[8], textRes.SocialSpace[30], function(s)
    if s == 1 then
      self.m_spaceMan:Req_DeleteReplyMsg(ECSpaceMsgs.MSG_TYPE.NORMAL, self.m_ownerId, msgId, replyId, function(data)
        if not self:IsNodeShow() then
          return
        end
        self:UpdateSingleMsgByMsgID(msgId, true)
      end, true)
    end
  end, nil)
end
def.method().ClearInputedMsg = function(self)
  self.m_msgInputCtrl:ClearContent()
end
def.method("=>", "userdata").NewMessageUI = function(self)
  local go = GameObject.Instantiate(self.m_UIGOs.Template_Message)
  go:SetActive(true)
  go.parent = self.m_UIGOs.Table_Message
  go.localScale = Vector.Vector3.one
  go.localPosition = Vector.Vector3.zero
  return go
end
def.virtual("userdata", "table").SetMessage = function(self, go, messageInfo)
  go.name = "message_" .. tostring(messageInfo.ID)
  local Group_Head = go:FindDirect("Group_Head")
  local Label_Info = Group_Head:FindDirect("Label_Info")
  local Group_Texture = Group_Head:FindDirect("Group_Texture")
  local Group_Name = Group_Head:FindDirect("Group_Name")
  local Img_Head = Group_Head:FindDirect("Img_Head")
  local Label_Time = Group_Head:FindDirect("Label_Time")
  self:SetHeadAvatar(Img_Head, messageInfo)
  self:SetGroupName(Group_Name, messageInfo)
  self:SetTextMessage(Label_Info, messageInfo.strRichMsg)
  self:SetPhotoMessage(Group_Texture, messageInfo)
  self:SetCreateTime(Label_Time, messageInfo.timestamp)
  local Group_Oper = go:FindDirect("Group_Oper")
  local Group_Like = go:FindDirect("Group_Like")
  local Group_Text = go:FindDirect("Group_Text")
  local Group_ShowAll = go:FindDirect("Group_ShowAll")
  self:SetGroupOper(Group_Oper, messageInfo)
  self:SetGroupLike(Group_Like, messageInfo)
  self:SetGroupReply(Group_Text, messageInfo)
  self:SetGroupShowAll(Group_ShowAll, messageInfo)
  self:RepositionMessage(go, 2)
end
def.method("userdata", "table").SetGroupLike = function(self, Group_Like, messageInfo)
  local haveVote = messageInfo.favorList and #messageInfo.favorList > 0
  Group_Like:SetActive(haveVote)
  if not haveVote then
    return
  end
  local Img_Icon = Group_Like:FindDirect("Img_Icon")
  local Html_Text = Group_Like:FindDirect("Html_Text")
  local html = Html_Text:GetComponent("NGUIHTML")
  local content = SocialSpaceUtils.BuildFavorListContent(messageInfo.favorList, messageInfo.voteSize)
  self:SetHtmlText(html, content)
  GUIUtils.AddBoxCollider(Img_Icon)
end
def.method("userdata", "table").SetGroupOper = function(self, Group_Oper, messageInfo)
  local Group_Common = Group_Oper:FindDirect("Group_Common")
  local Img_Like = Group_Common:FindDirect("Img_Like")
  local Img_Repost = Group_Common:FindDirect("Img_Repost")
  local Label_Num_Like = Img_Like:FindDirect("Label_Num")
  GUIUtils.SetText(Label_Num_Like, messageInfo.voteSize)
  GUIUtils.Toggle(Img_Like, messageInfo.hasVoted)
  local Label_Num_Comment = Img_Repost:FindDirect("Label_Num")
  local Img_Icon_Comment = Img_Repost:FindDirect("Img_Icon")
  GUIUtils.SetText(Label_Num_Comment, messageInfo.replySize)
  local Btn_Del = Group_Common:FindDirect("Btn_Del")
  local myRoleId = _G.GetMyRoleID()
  local isMyPost = myRoleId == messageInfo.roleId
  Btn_Del:SetActive(isMyPost)
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
  local picCount = messageInfo.pics and #messageInfo.pics or 0
  if picCount == 0 then
    Group_Texture:SetActive(false)
    return
  end
  Group_Texture:SetActive(true)
  for i = 1, MAX_DISPLAY_PIC do
    local Group = Group_Texture:FindDirect(("Group_%02d"):format(i))
    if i <= picCount then
      Group:SetActive(true)
      do
        local Texture = Group:FindDirect(("Texture%02d"):format(i))
        local picUrl = messageInfo.pics[i]
        picUrl = ECSocialSpaceCosMan.PicProcessing(picUrl, cos_cfg.pic_processing_params_small)
        ECSocialSpaceCosMan.Instance():LoadFile(picUrl, function(filePath)
          if _G.IsNil(Texture) then
            return
          end
          self:FillTextureFromLocalPath(Texture, filePath)
        end)
      end
    else
      Group:SetActive(false)
    end
  end
end
def.method("userdata", "number").SetCreateTime = function(self, Label_Time, timestamp)
  local text = SocialSpaceUtils.TimestampToDisplayText(timestamp)
  GUIUtils.SetText(Label_Time, text)
end
def.method("userdata", "table").SetGroupReply = function(self, Group_Text, messageInfo)
  local haveReply = messageInfo.replyMsgList and #messageInfo.replyMsgList > 0
  Group_Text:SetActive(haveReply)
  if not haveReply then
    return
  end
  local function ResizeGroup(groupGO, size, prefixName)
    local childCount = groupGO.childCount
    if childCount == 0 then
      warn(string.format("There is no chilren under groupGO(%s)", groupGO.name))
      return
    end
    local template = groupGO:GetChild(0)
    if template.name ~= "_template" then
      template.name = "_template"
      template:SetActive(false)
    end
    local actualChildCount = childCount - 2
    if size > actualChildCount then
      for i = actualChildCount + 1, size do
        local go = GameObject.Instantiate(template)
        go:SetActive(true)
        go.parent = groupGO
        go.localScale = Vector.Vector3.one
        go.localPosition = Vector.Vector3.zero
        go.transform:SetSiblingIndex(i)
      end
    elseif size < actualChildCount then
      for i = actualChildCount, size + 1, -1 do
        local go = groupGO:GetChild(i)
        GameObject.DestroyImmediate(go)
      end
    end
    for i = 1, size do
      local go = groupGO:GetChild(i)
      go.name = string.format("%s%d", prefixName, i)
    end
  end
  local function RepositionGroup(groupGO, bgWidgetName)
    local childCount = groupGO.childCount
    local actualChildCount = childCount - 2
    local padding = 4
    local border = 4
    local bgStartY
    local widgetBorder = 18
    local totalH = 0
    for i = 1, actualChildCount do
      local go = groupGO:GetChild(i)
      local Html_Reply = go:FindDirect("Html_Reply")
      local widgetHeight = Html_Reply:GetComponent("UIWidget").height
      totalH = totalH + widgetHeight + widgetBorder
      local Img_Reply = go:FindDirect("Img_Reply")
      local uiDragScrollView = Img_Reply:GetComponent("UIDragScrollView")
      if uiDragScrollView == nil then
        Img_Reply:AddComponent("UIDragScrollView")
      end
    end
    local h = totalH / 2
    for i = 1, actualChildCount do
      local go = groupGO:GetChild(i)
      go.localPosition = Vector.Vector3.new(go.localPosition.x, h, 0)
      local Html_Reply = go:FindDirect("Html_Reply")
      local widgetHeight = Html_Reply:GetComponent("UIWidget").height
      h = h - widgetHeight - widgetBorder
    end
    if bgWidgetName then
      bgStartY = totalH / 2 + widgetBorder
      local bgWidget = groupGO:FindDirect(bgWidgetName)
      bgWidget:GetComponent("UIWidget").height = totalH
      bgWidget.localPosition = Vector.Vector3.new(bgWidget.localPosition.x, bgStartY, 0)
    end
  end
  local hp = self.m_spaceMan:GetHostPlayerInfos()
  local contentList = SocialSpaceUtils.BuildReplyListContent(messageInfo.replyMsgList, self.m_replyDisplyNum)
  ResizeGroup(Group_Text, #contentList, "reply_")
  for i, content in ipairs(contentList) do
    local replyMsg = messageInfo.replyMsgList[i]
    local groupReply = Group_Text:GetChild(i)
    groupReply.name = "reply_" .. replyMsg.replyId:tostring()
    local Html_Reply = groupReply:FindDirect("Html_Reply")
    local html = Html_Reply:GetComponent("NGUIHTML")
    self:SetHtmlText(html, content)
    local Btn_Del = groupReply:FindDirect("Btn_Del")
    local canDelReply = false
    if hp.roleId == replyMsg.roleId or hp.roleId == messageInfo.roleId then
      canDelReply = true
    end
    Btn_Del:SetActive(canDelReply)
  end
  RepositionGroup(Group_Text, "Img_Text")
end
def.method("userdata", "table").SetGroupShowAll = function(self, groupGO, messageInfo)
  if groupGO == nil then
    return
  end
  local showAll = messageInfo.replySize > ShortReplyDisplayNum and not self:IsShowMsgDetail()
  groupGO:SetActive(showAll)
  if not showAll then
    return
  end
  local Label_Name = groupGO:FindDirect("Label_Name")
  GUIUtils.SetText(Label_Name, textRes.SocialSpace[61]:format(messageInfo.replySize))
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
  ECSocialSpaceMan.Instance():LoadPlayerMsgListBeforeID(roleId, lastID, len, self.m_bOnlyShowSelf, function(msgList)
    if not self:IsNodeShow() then
      return
    end
    warn("#msgList", #msgList)
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
  local msgList = self:FilterMsgList(srclist)
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
  local bResetView = not self.m_hasAppendedMsg
  self:RepositionMsgTable(nil, true, bResetView)
  if beginIdx == 0 then
    local noData = #msgList == 0
    GUIUtils.SetActive(self.m_UIGOs.Group_NoData, noData)
    self.m_hasAppendedMsg = not noData
  else
    self.m_hasAppendedMsg = true
  end
end
def.method("userdata", "boolean", "varlist").RepositionMsgTable = function(self, focusItemUI, bReposTable, bResetView)
  if not self:IsNodeShow() then
    return
  end
  local Table_Message = focusItemUI and focusItemUI.parent or self.m_UIGOs.Table_Message
  local ScrollView_Message = Table_Message.parent
  GameUtil.AddGlobalTimer(0, true, function()
    GameUtil.AddGlobalTimer(0, true, function()
      if self:IsNodeShow() then
        if bReposTable then
          GUIUtils.Reposition(Table_Message, "UITable")
          GameUtil.AddGlobalTimer(0, true, function()
            if self:IsNodeShow() then
              GUIUtils.Reposition(Table_Message, "UITable")
            end
          end)
        end
        local uiScrollView = ScrollView_Message:GetComponent("UIScrollView")
        if bResetView then
          uiScrollView:ResetPosition()
        elseif not _G.IsNil(focusItemUI) then
          uiScrollView:DragToMakeVisible(focusItemUI.transform, 4)
        end
      end
    end)
  end)
end
def.method("table", "=>", "table").FilterMsgList = function(self, msgList)
  if not self.m_bOnlyShowSelf then
    return msgList
  end
  local t = {}
  local hostRoleId = self.m_ownerId
  for i = 1, #msgList do
    if msgList[i].roleId == hostRoleId then
      table.insert(t, msgList[i])
    end
  end
  return t
end
def.method("userdata", ECSpaceMsgs.ECSpaceMsg).UpdateSingleMsg = function(self, itemUI, msg)
  if not self:IsNodeShow() then
    return
  end
  self:SetMessage(itemUI, msg)
end
def.method("userdata", "boolean").UpdateSingleMsgByMsgID = function(self, msgId, dragToMakeVisible)
  if not self:IsNodeShow() then
    return
  end
  local msg = self.m_spaceMan:FindPlayerSpaceMsgByID(self.m_ownerId, msgId)
  local itemUI
  if self:IsShowMsgDetail() then
    itemUI = self.m_UIGOs.ScrollView_MessageDetail:FindDirect("Table/message_" .. msgId:tostring())
  else
    itemUI = self.m_UIGOs.Table_Message:FindDirect("message_" .. msgId:tostring())
  end
  self:UpdateSingleMsg(itemUI, msg)
  self:UpdateAllMessagesTime()
  if dragToMakeVisible then
    self:RepositionMsgTable(itemUI, true)
  else
    self:RepositionMsgTable(nil, true)
  end
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
def.override("userdata", "boolean").onPressObj = function(self, obj, state)
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
  elseif self:IsMessageDetailDraging() then
    local dragAmount = self.m_UIGOs.UIScrollView_MessageDetail:GetDragAmount()
    if dragAmount.y > 1.02 and not self.m_bAppendingMsg then
      self.m_bAppendingMsg = true
      self:LoadMoreMsgDetail()
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
def.method("=>", "boolean").IsMessageDetailDraging = function(self)
  if self.m_UIGOs.UIScrollView_MessageDetail:get_isDragging() then
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
def.method("userdata").OnSelectMsg = function(self, msgId)
  local msg = self.m_spaceMan:FindPlayerSpaceMsgByID(self.m_ownerId, msgId)
  if msg == nil then
    return
  end
  self.m_replyMsgId = msg.ID
  self:SwitchPubTextMsg(true, {
    pubType = MsgPubType.ReplyMsg,
    labelSendText = textRes.SocialSpace[28]
  })
end
def.method("userdata").OnClickLikeBtn = function(self, sender)
  local msgId = self:GetCurDealMsgID(sender)
  if msgId == nil then
    return
  end
  local msg = self.m_spaceMan:FindPlayerSpaceMsgByID(self.m_ownerId, msgId)
  if msg == nil then
    return
  end
  GUIUtils.Toggle(sender, msg.hasVoted)
  if msg.hasVoted then
    self.m_spaceMan:Req_CancelFavorOnMsg(ECSpaceMsgs.MSG_TYPE.NORMAL, self.m_ownerId, msgId, function(data)
      if not self:IsNodeShow() then
        return
      end
      self:UpdateSingleMsgByMsgID(msgId, false)
    end, true)
  else
    self.m_spaceMan:Req_AddFavorOnMsg(ECSpaceMsgs.MSG_TYPE.NORMAL, self.m_ownerId, msgId, function(data)
      if not self:IsNodeShow() then
        return
      end
      self:UpdateSingleMsgByMsgID(msgId, false)
    end, true)
  end
end
def.method("userdata").OnClickLikeListBtn = function(self, sender)
  local msgId = self:GetCurDealMsgID(sender)
  if msgId == nil then
    return
  end
  local msg = self.m_spaceMan:FindPlayerSpaceMsgByID(self.m_ownerId, msgId)
  if msg == nil then
    return
  end
  require("Main.SocialSpace.ui.SpaceLikeListPanel").Instance():ShowPanel(ECSpaceMsgs.MSG_TYPE.NORMAL, self.m_ownerId, msg.ID)
end
def.method("userdata").OnClickShowAllBtn = function(self, sender)
  local msgId = self:GetCurDealMsgID(sender)
  if msgId == nil then
    return
  end
  self:ShowMsgDetailById(msgId)
end
def.method("userdata").OnClickRepostBtn = function(self, sender)
  self.m_replyId = Zero_Int64
  self.m_replyRoleId = Zero_Int64
  self.m_replyRoleName = ""
  local msgId = self:GetCurDealMsgID(sender)
  self:OnSelectMsg(msgId)
end
def.method("userdata").OnClickReplyImg = function(self, sender)
  local replyId = Int64.ParseString(sender.parent.name:split("_")[2])
  local msgId = self:GetCurDealMsgID(sender, 5)
  local msg = self.m_spaceMan:FindPlayerSpaceMsgByID(self.m_ownerId, msgId)
  if msg == nil then
    return
  end
  for i, replyMsg in ipairs(msg.replyMsgList) do
    if replyMsg.replyId == replyId then
      self.m_replyId = replyId
      self.m_replyRoleId = replyMsg.roleId
      self.m_replyRoleName = replyMsg.playerName
    end
  end
  self:OnSelectMsg(msgId)
end
def.method("userdata").OnClickHeadImg = function(self, sender)
  local msgId = self:GetCurDealMsgID(sender, 5)
  local msg = self.m_spaceMan:FindPlayerSpaceMsgByID(self.m_ownerId, msgId)
  if msg == nil then
    return
  end
  self.m_spaceMan:ShowPlayerMenu(sender, msg.roleId, msg.playerName, msg.idphoto, msg.serverId)
end
def.method("userdata", "userdata").OnClickMsgBg = function(self, sender, msgId)
  local msg = self.m_spaceMan:FindPlayerSpaceMsgByID(self.m_ownerId, msgId)
  if msg == nil then
    return
  end
  if msg.replySize <= ShortReplyDisplayNum then
    return
  end
end
def.method("userdata").OnClickPicture = function(self, sender)
  local msgId = self:GetCurDealMsgID(sender, 5)
  local msg = self.m_spaceMan:FindPlayerSpaceMsgByID(self.m_ownerId, msgId)
  if msg == nil then
    return
  end
  local defaultIndex = tonumber(sender.name:sub(8, -1))
  if defaultIndex then
    SocialSpaceUtils.ShowPictureDisplayPanel(msg.pics, defaultIndex)
  end
end
def.method().OnClickNewMessageBtn = function(self)
  require("Main.SocialSpace.ui.SpaceNewMessagePanel").Instance():ShowPanel()
end
def.method("userdata").OnClickTransmitBtn = function(self, sender)
  local msgId = self:GetCurDealMsgID(sender, 5)
  if msgId == nil then
    return
  end
  local msg = self.m_spaceMan:FindPlayerSpaceMsgByID(self.m_ownerId, msgId)
  if msg == nil then
    return
  end
  local context = {}
  context.msgId = msgId
  context.ownerId = msg.roleId
  context.ownerName = msg.playerName
  SocialSpaceUtils.ShowShareOptionsPanel(sender, context)
end
def.method().OnClickOptionBtn = function(self)
  require("Main.SocialSpace.ui.SpaceSettingPanel").Instance():ShowPanel()
end
def.method().OnSendReplyMsg = function(self)
  local Img_BgInput = self.m_UIGOs.Group_InputWords:FindDirect("Img_BgInput")
  local uiInput = Img_BgInput:GetComponent("UIInput")
  local inputValue = uiInput:get_value()
  self:SendReplyMsg(inputValue)
end
def.method("string", "=>", "boolean").SendReplyMsg = function(self, inputValue)
  local plainMsg = self.m_msgInputCtrl:GetContent(inputValue)
  if plainMsg == "" then
    Toast(textRes.SocialSpace[13])
    return false
  end
  local hp = self.m_spaceMan:GetHostPlayerInfos()
  local itemData = ""
  local msg = ECSpaceMsgs.ECReplyMsg()
  msg.roleId = hp.roleId
  msg.serverId = hp.serverId
  msg.playerName = hp.name
  msg.idphoto = hp.avatarId
  msg.avatarFrameId = hp.avatarFrameId
  msg.urlphoto = ""
  msg.replyRoleId = self.m_replyRoleId
  msg.replyRoleName = self.m_replyRoleName
  msg.replyId = self.m_replyId
  msg.msgID = self.m_replyMsgId
  msg.strPlainMsg = plainMsg
  msg.strData = itemData
  msg.strRichMsg = ECSocialSpaceMan.BuildSpaceRichContent(msg.strPlainMsg, itemData)
  msg.timestamp = _G.GetServerTime()
  self.m_spaceMan:Req_AddReplyOnMsg(ECSpaceMsgs.MSG_TYPE.NORMAL, self.m_ownerId, msg, self.m_replyMsgId, function(data)
    if not self.m_panel or self.m_panel.isnil then
      return
    end
    self:UpdateSingleMsgByMsgID(self.m_replyMsgId, false)
    self.m_replyMsgId = Zero_Int64
  end, true)
  self:ClearAfterSend()
  self.m_replyRoleId = Zero_Int64
  self:SwitchPubTextMsg(false, nil)
  return true
end
def.method("userdata").ShowMsgDetailById = function(self, msgId)
  self.m_spaceMan:Req_GetStatusReplyList(ECSpaceMsgs.MSG_TYPE.NORMAL, self.m_ownerId, msgId, function(msg)
    if not self:IsNodeShow() then
      return
    end
    self:ShowMsgDetail(true, msg)
  end, true)
end
def.method("boolean", "table").ShowMsgDetail = function(self, isShow, msg)
  self.m_UIGOs.ScrollView_MessageDetail:SetActive(isShow)
  self.m_UIGOs.ScrollView_Message:SetActive(not isShow)
  self:SwitchPubTextMsg(false, nil)
  if not isShow then
    self.m_replyDisplyNum = ShortReplyDisplayNum
    self.m_base.m_targetMsgId = Zero_Int64
    return
  end
  local itemUI = self.m_UIGOs.ScrollView_MessageDetail:FindDirect("Table"):GetChild(0)
  itemUI:SetActive(true)
  self.m_detailMsg = msg
  self.m_detailMsgUI = itemUI
  self.m_replyDisplyNum = 0
  self:LoadMoreMsgDetail()
end
def.method().LoadMoreMsgDetail = function(self)
  local itemUI, msg = self.m_detailMsgUI, self.m_detailMsg
  self.m_replyDisplyNum = self.m_replyDisplyNum + LongReplyDisplayNum
  self:UpdateSingleMsg(itemUI, msg)
  if self.m_replyDisplyNum > LongReplyDisplayNum then
    self:RepositionMsgTable(nil, true, false)
  else
    self:RepositionMsgTable(itemUI, true, true)
  end
end
def.method("=>", "boolean").IsShowMsgDetail = function(self)
  return self.m_UIGOs.ScrollView_MessageDetail:get_activeSelf()
end
def.method("table").OnNewMsg = function(self, params)
  local num = params[1]
  self:SetNewMsgCount(num)
end
def.method("table").OnMsgPublished = function(self, params)
  self:CheckHasNewMsg()
end
def.method().UpdateNewMsgCount = function(self)
  local unreadMsgNum = self.m_spaceMan:GetUnreadMsgCount()
  self:SetNewMsgCount(unreadMsgNum)
end
def.method("number").SetNewMsgCount = function(self, count)
  local Btn_NewMessage = self.m_UIGOs.Group_Title:FindDirect("Btn_NewMessage")
  local Img_MakeRed = Btn_NewMessage:FindDirect("Img_MakeRed")
  Img_MakeRed:SetActive(count > 0)
  if count <= 0 then
    return
  end
  local UNREAD_MSG_MAX_NUM = 99
  local Label_MakeRedNum = Img_MakeRed:FindDirect("Label_MakeRedNum")
  local countText = count
  if count > UNREAD_MSG_MAX_NUM then
    countText = string.format("%d+", UNREAD_MSG_MAX_NUM)
  end
  GUIUtils.SetText(Label_MakeRedNum, countText)
end
def.method("number").GetImageToUpload = function(self, fromType)
  local Feature = require("netio.protocol.mzm.gsp.open.ModuleFunSwitchInfo")
  if not _G.IsFeatureOpen(Feature.TYPE_UPLOAD_PICTURE) then
    SocialSpaceUtils.ShowFeatureNotOpenPrompt()
    return
  end
  local extras = ECSocialSpaceCosMan.Instance():GetCreateMsgPictureExtraParams()
  ECSocialSpaceCosMan.Instance():DoGetImagePath(fromType, function(localPath)
    self:OnGetImagePath(localPath)
  end, extras)
end
def.method("string").OnGetImagePath = function(self, localPath)
  if not self:IsNodeShow() then
    return
  end
  if localPath == "" then
    localPath = nil
    return
  end
  local panel = require("Main.SocialSpace.ui.SpacePublishPicturePanel").Instance()
  panel:ShowPanel({localPath}, function()
    if not self:IsNodeShow() then
      return
    end
    self:CheckHasNewMsg()
  end)
end
return SpaceFriendsCircleNode.Commit()
