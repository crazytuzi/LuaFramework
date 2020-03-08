local MODULE_NAME = (...)
local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local SpaceNewMessagePanel = Lplus.Extend(ECPanelBase, MODULE_NAME)
local Vector = require("Types.Vector")
local GUIUtils = require("GUI.GUIUtils")
local def = SpaceNewMessagePanel.define
local ECSpaceMsgs = require("Main.SocialSpace.ECSpaceMsgs")
local SocialSpaceUtils = import("..SocialSpaceUtils")
local ECSocialSpaceMan = require("Main.SocialSpace.ECSocialSpaceMan")
local ECSocialSpaceCosMan = require("Main.SocialSpace.ECSocialSpaceCosMan")
local ECDebugOption = require("Main.ECDebugOption")
local cos_cfg = ECSocialSpaceCosMan.Instance():GetCosCfg()
local NEW_MSG_TYPE = ECSpaceMsgs.NEW_MSG_TYPE
local NEW_MSG_SOURCE_TYPE = ECSpaceMsgs.NEW_MSG_SOURCE_TYPE
def.field("table").m_UIGOs = nil
def.field("table").m_newMsgList = nil
def.field("boolean").m_bAppendingMsg = false
def.field("boolean").m_bReqingMsg = false
def.field("table").m_friendMarkContainer = nil
local instance
def.static("=>", SpaceNewMessagePanel).Instance = function()
  if instance == nil then
    instance = SpaceNewMessagePanel()
  end
  return instance
end
def.method().ShowPanel = function(self)
  if self.m_panel and not self.m_panel.isnil then
    self:DestroyPanel()
  end
  self:SetModal(true)
  self:CreatePanel(RESPATH.PREFAB_SOCIAL_SPACE_NEW_MESSAGES_PANEL, 2)
end
def.override().OnCreate = function(self)
  self:InitData()
  self:InitUI()
  self:UpdateUI()
end
def.override().OnDestroy = function(self)
  self.m_UIGOs = nil
  self.m_newMsgList = nil
  self.m_bAppendingMsg = false
  self.m_bReqingMsg = false
  if self.m_friendMarkContainer then
    self.m_friendMarkContainer:Destroy()
    self.m_friendMarkContainer = nil
  end
end
def.method("userdata").onClickObj = function(self, obj)
  local id = obj.name
  if id == "Btn_Close" or id == "Modal" then
    self:DestroyPanel()
  elseif id == "Img_Head" then
    self:OnClickRoleHead(obj)
  elseif id:find("message_") then
    self:OnClickMsgBg(obj)
  end
end
def.method().InitData = function(self)
  self.m_newMsgList = {}
  self.m_friendMarkContainer = require("Main.SocialSpace.FriendMarkHelper").Instance():CreateContainer()
end
def.method().InitUI = function(self)
  self.m_UIGOs = {}
  self.m_UIGOs.Img_Bg = self.m_panel:FindDirect("Img_Bg")
  self.m_UIGOs.Group_List = self.m_UIGOs.Img_Bg:FindDirect("Group_List")
  self.m_UIGOs.Group_List_Message = self.m_UIGOs.Group_List:FindDirect("Group_List")
  self.m_UIGOs.ScrollView_Message = self.m_UIGOs.Group_List_Message:FindDirect("Scrolllist")
  self.m_UIGOs.Table_Message = self.m_UIGOs.ScrollView_Message:FindDirect("Table")
  self.m_UIGOs.Template_Message = self.m_UIGOs.Table_Message:FindDirect("Message")
  self.m_UIGOs.Template_Message:SetActive(false)
  self.m_UIGOs.Template_Message:GetComponent("UIWidget"):set_alpha(0)
  self.m_UIGOs.UIScrollView_Message = self.m_UIGOs.ScrollView_Message:GetComponent("UIScrollView")
  self.m_UIGOs.Group_NoData = self.m_UIGOs.Group_List:FindDirect("Group_NoData")
  local Label_NoData = self.m_UIGOs.Group_NoData:FindDirect("Img_Talk/Label")
  GUIUtils.SetText(Label_NoData, textRes.SocialSpace[35])
end
def.method().UpdateUI = function(self)
  self:AppendNextPageMsg(false)
end
def.method("=>", "userdata").NewMessageUI = function(self)
  local go = GameObject.Instantiate(self.m_UIGOs.Template_Message)
  go:SetActive(true)
  go.parent = self.m_UIGOs.Table_Message
  go.localScale = Vector.Vector3.one
  go.localPosition = Vector.Vector3.zero
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
def.method("boolean").AppendNextPageMsg = function(self, bCheckCoolTime)
  if self.m_bReqingMsg then
    return
  end
  ECSocialSpaceMan.Instance():Req_GetHostPlayerNewMsgs(function(data)
    if data.retcode ~= 0 then
      return
    end
    if not self:IsLoaded() then
      return
    end
    self.m_bReqingMsg = false
    local hostRoleId = _G.GetMyRoleID()
    local data = ECSocialSpaceMan.Instance():GetSpaceData(hostRoleId)
    if data then
      local newMsgs = data.newMsgs
      for i = 1, #newMsgs do
        table.insert(self.m_newMsgList, newMsgs[i])
      end
    end
    self:RefreshMsgList(self.m_newMsgList)
  end, bCheckCoolTime)
end
def.method("table").RefreshMsgList = function(self, msgList)
  local curMsgCount = self.m_UIGOs.Table_Message:get_childCount() - 1
  if ECDebugOption.Instance().showSSlog then
  end
  local msgNum = #msgList
  for i = curMsgCount + 1, #msgList do
    local msg = msgList[i]
    local itemUI = self.m_UIGOs.Table_Message:FindDirect(string.format("message_%d", i))
    if not itemUI then
      itemUI = self:NewMessageUI()
      itemUI.name = string.format("message_%d", i)
      itemUI.transform:SetAsLastSibling()
    end
    self:UpdateSingleMsg(itemUI, msg)
  end
  self:RepositionMsgTable(nil, true)
  self.m_UIGOs.Group_NoData:SetActive(msgNum == 0)
end
def.method("userdata", ECSpaceMsgs.ECNewMsg).UpdateSingleMsg = function(self, itemUI, msg)
  if not self:IsLoaded() then
    return
  end
  self:SetMessage(itemUI, msg)
end
def.method().PlayNoMoreMsgAni = function(self)
  TODO("PlayNoMoreMsgAni")
end
def.virtual("userdata", "table").SetMessage = function(self, go, messageInfo)
  local Group_Head = go:FindDirect("Group_Head")
  local Group_Name = Group_Head:FindDirect("Group_Name")
  local Img_Head = Group_Head:FindDirect("Img_Head")
  local Group_Content = Group_Head:FindDirect("Group_Content")
  local Texture_Photo = Group_Head:FindDirect("Texture_Photo")
  local Label_Info = Group_Head:FindDirect("Label_Info")
  GUIUtils.SetActive(Texture_Photo, false)
  GUIUtils.SetActive(Label_Info, false)
  local Group_Time = go:FindDirect("Group_Time")
  local Label_Time = Group_Time:FindDirect("Label_Time")
  self:SetHeadAvatar(Img_Head, messageInfo)
  self:SetGroupName(Group_Name, messageInfo)
  self:SetCreateTime(Label_Time, messageInfo.timestamp)
  self:SetGroupContent(Group_Content, messageInfo)
  self:SetGroupContext(Group_Head, messageInfo)
  self:RepositionMessage(go, 2)
end
def.method("userdata", "table").SetGroupContent = function(self, Group_Content, messageInfo)
  local Img_LikeIcon = Group_Content:FindDirect("Img_LikeIcon")
  local Html_Text = Group_Content:FindDirect("Html_Text")
  local Img_Text = Group_Content:FindDirect("Img_Text")
  local mainText
  local showLikeIcon = false
  if messageInfo.newMsgType == NEW_MSG_TYPE.FAVOR_ON_MSG then
    showLikeIcon = true
  elseif messageInfo.newMsgType == NEW_MSG_TYPE.CANCEL_FAVOR_ON_MSG then
    mainText = SocialSpaceUtils.BuildSpaceRichContent(textRes.SocialSpace.NewMsg[16], "")
  else
    mainText = messageInfo.strRichMsg
  end
  GUIUtils.SetActive(Img_LikeIcon, showLikeIcon)
  GUIUtils.SetActive(Img_Text, not showLikeIcon)
  local html = Html_Text:GetComponent("NGUIHTML")
  html:ForceHtmlText(mainText or "")
end
def.method("userdata", "table").SetGroupContext = function(self, Group_Head, messageInfo)
  local Texture_Photo = Group_Head:FindDirect("Texture_Photo")
  local Label_Info = Group_Head:FindDirect("Label_Info")
  local contextText, contextPicture
  if messageInfo.sourceType == NEW_MSG_SOURCE_TYPE.TEXT then
    contextText = ECSocialSpaceMan.Instance():FilterSensitiveWords(messageInfo.sourceContent)
    contextText = SocialSpaceUtils.BuildSpaceRichContent(contextText, "")
  elseif messageInfo.sourceType == NEW_MSG_SOURCE_TYPE.PICTURE then
    contextPicture = messageInfo.sourceContent
  elseif messageInfo.newMsgType == NEW_MSG_TYPE.FAVOR_ON_MSG or messageInfo.newMsgType == NEW_MSG_TYPE.CANCEL_FAVOR_ON_MSG then
    contextText = messageInfo.strPlainMsg
  end
  GUIUtils.SetActive(Texture_Photo, contextPicture ~= nil)
  GUIUtils.SetActive(Label_Info, contextPicture == nil and contextText ~= nil)
  if contextPicture then
    GUIUtils.SetTexture(Texture_Photo, 0)
    local photoUrl = contextPicture
    photoUrl = ECSocialSpaceCosMan.PicProcessing(photoUrl, cos_cfg.pic_processing_params_small_square)
    ECSocialSpaceCosMan.Instance():LoadFile(photoUrl, function(filePath)
      if _G.IsNil(Texture) then
        return
      end
      GUIUtils.FillTextureFromLocalPath(Texture_Photo, filePath, nil)
    end)
  elseif contextText then
    local html = Label_Info:GetComponent("NGUIHTML")
    if html then
      contextText = SocialSpaceUtils.BuildSpaceRichContent(contextText, "")
      local maxLineNumber = 6
      html:set_maxLineNumber(maxLineNumber)
      if _G.CUR_CODE_VERSION < _G.COS_EX_CODE_VERSION then
        local constructTable = {contextText}
        for i = 1, maxLineNumber do
          table.insert(constructTable, "<br/>")
        end
        contextText = table.concat(constructTable)
      end
      html:ForceHtmlText(contextText)
      local uiWidget = html:GetComponent("UIWidget")
      if uiWidget.height > 120 then
        uiWidget.height = 120
      end
    else
      local uiLabel = Label_Info:GetComponent("UILabel")
      uiLabel:set_maxLineCount(6)
      GUIUtils.SetText(Label_Info, contextText)
    end
  end
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
  self.m_friendMarkContainer:AddFriendMark({
    go = Img_Friend,
    roleId = messageInfo.roleId
  })
end
def.method("userdata", "number").SetCreateTime = function(self, Label_Time, timestamp)
  local text = SocialSpaceUtils.TimestampToDisplayText(timestamp)
  GUIUtils.SetText(Label_Time, text)
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
def.method("userdata", "boolean").RepositionMsgTable = function(self, focusItemUI, bReposTable)
  GameUtil.AddGlobalTimer(0, true, function()
    GameUtil.AddGlobalTimer(0, true, function()
      if self:IsLoaded() then
        if bReposTable then
          GUIUtils.Reposition(self.m_UIGOs.Table_Message, "UITable")
        end
        local ScrollView = self.m_UIGOs.ScrollView_Message
        local uiScrollView = ScrollView:GetComponent("UIScrollView")
        if not _G.IsNil(focusItemUI) then
          uiScrollView:DragToMakeVisible(focusItemUI.transform, 4)
        end
      end
    end)
  end)
end
def.method("userdata").OnClickRoleHead = function(self, obj)
  local index = tonumber(obj.parent.parent.name:split("_")[2])
  if index == nil then
    return
  end
  local newMsg = self.m_newMsgList[index]
  if newMsg == nil then
    return
  end
  ECSocialSpaceMan.Instance():ShowPlayerMenu(obj, newMsg.roleId, newMsg.playerName, newMsg.idphoto, 0)
end
def.method("string", "number", "number").onDrag = function(self, id, dx, dy)
  if self.m_UIGOs.UIScrollView_Message:get_isDragging() then
    local dragAmount = self.m_UIGOs.UIScrollView_Message:GetDragAmount()
    if dragAmount.y > 1 and not self.m_bAppendingMsg then
      self.m_bAppendingMsg = true
      self:AppendNextPageMsg(false)
    end
  end
end
def.method("string").onDragEnd = function(self, id)
  self.m_bAppendingMsg = false
end
def.method("userdata").OnClickMsgBg = function(self, obj)
  local index = tonumber(obj.name:split("_")[2])
  if index == nil then
    return
  end
  local newMsg = self.m_newMsgList[index]
  if newMsg == nil then
    return
  end
  local hostRoleId = _G.GetMyRoleID()
  local NEW_MSG_TYPE = ECSpaceMsgs.NEW_MSG_TYPE
  local spaceMan = ECSocialSpaceMan.Instance()
  if newMsg.msgID ~= Zero_Int64 then
    spaceMan:Req_GetStatusInfo(newMsg.msgID, function(data)
      if data.retcode ~= 0 then
        return
      end
      if not self:IsLoaded() then
        return
      end
      local roleId = Int64.ParseString(data.moment.roleId)
      spaceMan:EnterSpaceWithMsgId(roleId, newMsg.msgID)
    end, false)
  elseif newMsg.leaveMsgId ~= Zero_Int64 then
    spaceMan:Req_GetLeaveMsgInfo(newMsg.leaveMsgId, function(data)
      if data.retcode ~= 0 then
        return
      end
      if not self:IsLoaded() then
        return
      end
      local roleId = Int64.ParseString(data.message.ownerId)
      spaceMan:EnterSpaceWithParams({
        roleId = roleId,
        leaveMsgId = newMsg.leaveMsgId
      })
    end, false)
  elseif newMsg.newMsgType == NEW_MSG_TYPE.GOTTEN_GIFT then
    SocialSpaceUtils.ShowGiftHistory(hostRoleId)
  end
end
return SpaceNewMessagePanel.Commit()
