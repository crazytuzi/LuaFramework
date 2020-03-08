local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local GUIUtils = require("GUI.GUIUtils")
local AtMgr = require("Main.Chat.At.AtMgr")
local AtData = require("Main.Chat.At.data.AtData")
local AtUtils = require("Main.Chat.At.AtUtils")
local MathHelper = require("Common.MathHelper")
local AtMsgData = require("Main.Chat.At.data.AtMsgData")
local ChatModule = Lplus.ForwardDeclare("ChatModule")
local AtBoxPanel = Lplus.Extend(ECPanelBase, "AtBoxPanel")
local def = AtBoxPanel.define
local instance
def.static("=>", AtBoxPanel).Instance = function()
  if instance == nil then
    instance = AtBoxPanel()
  end
  return instance
end
def.field("table")._uiObjs = nil
def.field("number")._destAtMsgIdx = 0
def.field("table")._destAtMsg = nil
def.field("table")._atMsgList = nil
def.const("number").PAGE_COUNT = 3
def.field("table")._toBeDelAtMsgList = nil
def.field("function")._groupInitCB = nil
def.static("table").ShowPanel = function(atMsgData)
  if not AtMgr.Instance():IsOpen(true) then
    if AtBoxPanel.Instance():IsShow() then
      AtBoxPanel.Instance():DestroyPanel()
    end
    return
  end
  AtBoxPanel.Instance():_InitData(atMsgData)
  if AtBoxPanel.Instance():IsShow() then
    AtBoxPanel.Instance():UpdateUI()
    return
  end
  instance:CreatePanel(RESPATH.PREFAB_AT_MSG_BOX, 2)
end
def.method("table")._InitData = function(self, atMsgData)
  self._destAtMsg = atMsgData
  self._atMsgList = AtData.Instance():GetAllAtMsg()
  self._toBeDelAtMsgList = {}
  if self._destAtMsg then
    table.insert(self._toBeDelAtMsgList, self._destAtMsg)
  end
end
def.override().OnCreate = function(self)
  self:SetModal(false)
  self:_InitUI()
end
def.method()._InitUI = function(self)
  self._uiObjs = {}
  self._uiObjs.Img_Bg = self.m_panel:FindDirect("Img_Bg")
  self._uiObjs.Group_List = self._uiObjs.Img_Bg:FindDirect("Group_List")
  self._uiObjs.MsgScrollView = self._uiObjs.Group_List:FindDirect("Scroll View")
  self._uiObjs.uiScrollView = self._uiObjs.MsgScrollView:GetComponent("UIScrollView")
  self._uiObjs.MsgList = self._uiObjs.MsgScrollView:FindDirect("List")
  self._uiObjs.uiList = self._uiObjs.MsgList:GetComponent("UIList")
  self._uiObjs.Label_Num = self._uiObjs.Img_Bg:FindDirect("Group_Num/Label_Num")
  self._uiObjs.Group_NoData = self._uiObjs.Img_Bg:FindDirect("Group_NoData")
  self._uiObjs.BtnDeleteAll = self._uiObjs.Img_Bg:FindDirect("Btn_Reply")
end
def.override("boolean").OnShow = function(self, show)
  self:HandleEventListeners(show)
  if show then
    self:UpdateUI()
  else
  end
end
def.method().UpdateUI = function(self)
  self:UpdateAllAtMsgs()
  self:ScrollToAtMsg()
end
def.override().OnDestroy = function(self)
  if self._toBeDelAtMsgList and #self._toBeDelAtMsgList > 0 then
    for _, atMsgData in ipairs(self._toBeDelAtMsgList) do
      AtData.Instance():RemoveAtMsg(atMsgData)
    end
  end
  self:_Reset()
end
def.method()._Reset = function(self)
  self:_ClearList()
  self._destAtMsgIdx = 0
  self._destAtMsg = nil
  self._atMsgList = nil
  self._toBeDelAtMsgList = nil
  self._groupInitCB = nil
  self._uiObjs = nil
end
def.method().UpdateAllAtMsgs = function(self)
  self:_ClearList()
  local msgCount = self:GetMsgCount()
  GUIUtils.SetText(self._uiObjs.Label_Num, msgCount)
  if msgCount > 0 then
    GUIUtils.SetActive(self._uiObjs.Group_NoData, false)
    GUIUtils.SetActive(self._uiObjs.Group_List, true)
    GUIUtils.SetActive(self._uiObjs.BtnDeleteAll, true)
    self._uiObjs.uiList.itemCount = msgCount
    self._uiObjs.uiList:Resize()
    self._uiObjs.uiList:Reposition()
    for idx, atMsgData in ipairs(self._atMsgList) do
      if self._destAtMsg and AtMsgData.eq(atMsgData, self._destAtMsg) then
        self._destAtMsgIdx = idx
      end
      self:ShowAtMsg(idx, atMsgData)
    end
  else
    GUIUtils.SetActive(self._uiObjs.Group_NoData, true)
    GUIUtils.SetActive(self._uiObjs.Group_List, false)
    GUIUtils.SetActive(self._uiObjs.BtnDeleteAll, false)
  end
end
def.method("number", "table").ShowAtMsg = function(self, idx, atMsgData)
  local listItem = self._uiObjs.uiList.children[idx]
  if nil == listItem then
    warn("[ERROR][AtBoxPanel:ShowAtMsg] listItem nil at idx:", idx)
    return
  end
  if nil == atMsgData then
    warn("[ERROR][AtBoxPanel:ShowAtMsg] atMsgData nil at idx:", idx)
    return
  end
  local Img_PlayerSelect = listItem:FindDirect("Img_PlayerSelect")
  GUIUtils.SetActive(Img_PlayerSelect, self._destAtMsgIdx == idx)
  local Texture_IconHead = listItem:FindDirect("Img_PlayerHead/Texture_IconHead")
  _G.SetAvatarIcon(Texture_IconHead, atMsgData:GetAvatarId())
  local Img_AvatarFrame = listItem:FindDirect("Img_PlayerHead/Img_AvatarFrame")
  _G.SetAvatarFrameIcon(Img_AvatarFrame, atMsgData:GetAvatarFrame())
  local Label_Level = listItem:FindDirect("Img_PlayerHead/Label_Level")
  GUIUtils.SetText(Label_Level, atMsgData:GetLevel())
  local Label_Channel = listItem:FindDirect("Img_Channel/Label")
  GUIUtils.SetText(Label_Channel, AtUtils.GetChannelName(atMsgData.channel))
  local Label_Name = listItem:FindDirect("Img_PlayerHead/Label_Name")
  GUIUtils.SetText(Label_Name, atMsgData:GetRoleName())
  local Img_MenPai = listItem:FindDirect("Img_PlayerHead/Img_MenPai")
  GUIUtils.SetSprite(Img_MenPai, GUIUtils.GetOccupationSmallIcon(atMsgData:GetOccpId()))
  local Img_Sex = listItem:FindDirect("Img_PlayerHead/Img_Sex")
  GUIUtils.SetSprite(Img_Sex, GUIUtils.GetSexIcon(atMsgData:GetGender()))
  local Label_Time = listItem:FindDirect("Label_Time")
  GUIUtils.SetText(Label_Time, AtUtils.GetTimeStampString(atMsgData:GetTimeStamp()))
  local Drag_Note = listItem:FindDirect("Group_Note/Drag_Note")
  local htmlContent = Drag_Note:GetComponent("NGUIHTML")
  htmlContent:ForceHtmlText(atMsgData:GetPlainHtml())
end
def.method("=>", "number").GetMsgCount = function(self)
  return self._atMsgList and #self._atMsgList or 0
end
def.method()._ClearList = function(self)
  self._uiObjs.uiList.itemCount = 0
  self._uiObjs.uiList:Resize()
  self._uiObjs.uiList:Reposition()
end
def.method().ScrollToAtMsg = function(self)
  if self:GetMsgCount() > AtBoxPanel.PAGE_COUNT then
    GameUtil.AddGlobalLateTimer(0.01, true, function()
      self:ScrollToIdx(self._destAtMsgIdx)
    end)
  end
end
def.method("number").ScrollToIdx = function(self, idx)
  warn("[AtBoxPanel:ScrollToIdx] ScrollToIdx idx, self:GetMsgCount():", idx, self:GetMsgCount())
  idx = MathHelper.Clamp(idx, 1, self:GetMsgCount())
  if idx <= self:GetHalfClipMsgCount() then
    self:ResetScroll()
  else
    local count = self:GetMsgCount()
    local amountY = idx / count
    self._uiObjs.uiScrollView:SetDragAmount(0, amountY, false)
  end
end
def.method().ResetScroll = function(self)
  self._uiObjs.uiScrollView:ResetPosition()
end
def.method("=>", "number").GetHalfClipMsgCount = function(self)
  return math.floor(AtBoxPanel.PAGE_COUNT / 2)
end
def.method("table").DeleteAtMsg = function(self, atMsgData)
  local index = self:GetAtMsgIdx()
  self:DoDeleteAtMsg(index, self._atMsgList[index])
end
def.method("table", "=>", "number").GetAtMsgIdx = function(self, atMsgData)
  local index = 0
  for idx, msg in ipairs(self._atMsgList) do
    if AtMsgData.eq(atMsgData, msg) then
      index = idx
      break
    end
  end
  return index
end
def.method("number").DeleteAtMsgByIdx = function(self, idx)
  local atMsgData = self._atMsgList and self._atMsgList[idx] or nil
  self:DoDeleteAtMsg(idx, atMsgData)
end
def.method("number", "table").DoDeleteAtMsg = function(self, idx, atMsgData)
  if idx <= 0 then
    warn("[ERROR][AtBoxPanel:DoDeleteAtMsg] invalid idx:", idx)
    return
  end
  if nil == atMsgData then
    warn("[ERROR][AtBoxPanel:DoDeleteAtMsg] atMsgData nil at idx:", idx)
    return
  end
  AtData.Instance():RemoveAtMsg(atMsgData)
  table.remove(self._atMsgList, idx)
  local msgCount = self:GetMsgCount()
  GUIUtils.SetText(self._uiObjs.Label_Num, msgCount)
  if msgCount > 0 then
    GUIUtils.SetActive(self._uiObjs.Group_NoData, false)
    GUIUtils.SetActive(self._uiObjs.Group_List, true)
    GUIUtils.SetActive(self._uiObjs.BtnDeleteAll, true)
    self._uiObjs.uiList.itemCount = msgCount
    self._uiObjs.uiList:Resize()
    for i = idx, msgCount do
      local msg = self._atMsgList[i]
      self:ShowAtMsg(i, msg)
    end
  else
    GUIUtils.SetActive(self._uiObjs.Group_NoData, true)
    GUIUtils.SetActive(self._uiObjs.Group_List, false)
    GUIUtils.SetActive(self._uiObjs.BtnDeleteAll, false)
  end
end
def.method("userdata").onClickObj = function(self, clickObj)
  local id = clickObj.name
  if id == "Btn_Close" then
    self:DestroyPanel()
  elseif id == "Btn_Reply" then
    if clickObj.parent and self._uiObjs.Img_Bg.name == clickObj.parent.name then
      self:OnBtnDeleteAll()
    else
      self:OnBtn_Reply(clickObj)
    end
  elseif id == "Btn_Delete" then
    self:OnBtn_Delete(clickObj)
  elseif self:CheckClickChatInfoPack(id) then
  end
end
def.method("string", "=>", "boolean").CheckClickChatInfoPack = function(self, id)
  if string.find(id, "role_") then
    local FriendCommonDlgManager = require("Main.friend.FriendCommonDlgManager")
    local strs = string.split(id, "_")
    local channel = tonumber(strs[2])
    local roleId = Int64.new(strs[3])
    local myId = _G.GetMyRoleID()
    if roleId ~= myId then
      local state = FriendCommonDlgManager.StateConst.Null
      FriendCommonDlgManager.ApplyShowFriendCommonDlg(roleId, state)
    end
    return true
  elseif string.find(id, "item_") then
    if not self:CheckContext() then
      return true
    end
    ChatModule.Instance():RequestInfoPack(id)
    return true
  elseif string.find(id, "wing_") then
    if not self:CheckContext() then
      return true
    end
    ChatModule.Instance():RequestInfoPack(id)
    return true
  elseif string.find(id, "aircraft_") then
    if not self:CheckContext() then
      return true
    end
    ChatModule.Instance():RequestInfoPack(id)
    return true
  elseif string.find(id, "pet_") then
    if not self:CheckContext() then
      return true
    end
    ChatModule.Instance():RequestInfoPack(id)
    return true
  elseif string.find(id, "task_") then
    ChatModule.Instance():RequestInfoPack(id)
    return true
  elseif string.find(id, "fashion_") then
    if not self:CheckContext() then
      return true
    end
    ChatModule.Instance():RequestInfoPack(id)
    return true
  elseif string.find(id, "fabao_") then
    if not self:CheckContext() then
      return true
    end
    ChatModule.Instance():RequestFabaoPackInfo(id)
    return true
  elseif string.find(id, "fabaospirit_") then
    if not self:CheckContext() then
      return true
    end
    ChatModule.Instance():RequestFabaoLingQiPackInfo(id)
    return true
  elseif string.find(id, "team_") then
    require("Main.Chat.ui.ChannelChatPanel").ShowChannelChatPanel(-1, -1)
    return true
  elseif string.find(id, "unique_") then
    require("Main.Chat.ui.ChannelChatPanel").ShowChannelChatPanel(-1, -1)
    return true
  elseif string.find(id, "question_") then
    require("Main.Question.QuestionModule").Instance():AnswerGangHelp(id)
    return true
  elseif string.find(id, "qyxt_") then
    require("Main.Question.EveryNightQuestionModule").Instance():AnswerGangHelp(id)
    return true
  elseif string.find(id, "btn_") then
    Event.DispatchEvent(ModuleId.CHAT, gmodule.notifyId.Chat.BtnClickInChat, {
      id = string.sub(id, 5)
    })
    return true
  elseif string.sub(id, 1, 5) == "zone_" then
    if not self:CheckContext() then
      return true
    end
    ChatModule.Instance():RequestInfoPack(id)
    return true
  elseif string.sub(id, 1, 4) == "msv_" then
    local roleId = Int64.new(string.sub(id, 5))
    Event.DispatchEvent(ModuleId.MENPAISTAR, gmodule.notifyId.MenpaiStar.Vote_Link, {roleId})
  elseif string.sub(id, 1, 12) == "crossbattle_" then
    local corpsId = Int64.new(string.sub(id, 13))
    Event.DispatchEvent(ModuleId.CROSS_BATTLE, gmodule.notifyId.CrossBattle.Cross_Battle_Vote_Link, {corpsId})
  elseif string.sub(id, 1, 11) == "corpscheck_" then
    local corpsId = Int64.new(string.sub(id, 12))
    local CorpsInterface = require("Main.Corps.CorpsInterface")
    CorpsInterface.CheckCorpsInfo(corpsId)
  elseif string.sub(id, 1, 8) == "achieve_" then
    require("Main.achievement.AchievementModule").Instance():ShowAchievementDlgFromChat(id)
  elseif string.sub(id, 1, 14) == "shoppingGroup_" then
    require("Main.GroupShopping.GroupShoppingModule").Instance():ShareClick(id)
  elseif string.find(id, "wedding_") then
    require("Main.Marriage.MarriageInterface").JoinWedding(id)
    return true
  elseif string.find(id, "redpacket_") then
    local curName = require("Main.friend.ui.SocialDlg").Instance().curName
    if curName and curName ~= "" then
      require("Main.Marriage.MarriageInterface").SendRedPacket(id, curName)
    end
    return true
  elseif string.find(id, "Btn_Join_") then
    local index = string.sub(id, 10)
    Event.DispatchEvent(ModuleId.CHAT, gmodule.notifyId.Chat.Chat_Apply_Team, {index})
    return true
  elseif string.find(id, "Btn_TeamPlatform_Apply_") then
    local str = string.sub(id, #"Btn_TeamPlatform_Apply_" + 1)
    local strs = string.split(str, "_")
    Event.DispatchEvent(ModuleId.CHAT, gmodule.notifyId.Chat.Chat_Apply_Team_Ex, {
      unpack(strs)
    })
    return true
  elseif string.find(id, "ChatRedGift_") then
    local str = string.sub(id, #"ChatRedGift_" + 1, -1)
    local strs = string.split(str, "_")
    local _redGiftId = Int64.new(strs[1])
    local _channelType = tonumber(strs[2])
    local _channelSubType = tonumber(strs[3])
    Event.DispatchEvent(ModuleId.CHATREDGIFT, gmodule.notifyId.ChatRedGift.Get_ChatRedGiftProtocol, {
      redGiftId = _redGiftId,
      channelType = _channelType,
      channelSubType = _channelSubType
    })
    return true
  elseif id == "avoidsettingnotice" then
    local ChatSetting = require("Main.Chat.ui.ChatSettingDlg")
    local ChannelChatPanel = require("Main.Chat.ui.ChannelChatPanel")
    local settingDlg = ChatSetting()
    local pathNode = require("Main.Chat.ChatModule").Instance():GetSettingEnum(ChannelChatPanel.Instance().channelSubType)
    settingDlg:ShowPanel(pathNode)
    return true
  elseif string.find(id, "marketGoods_") then
    local str = string.sub(id, #"marketGoods_" + 1)
    local strs = string.split(str, "_")
    Event.DispatchEvent(ModuleId.TRADING_ARCADE, gmodule.notifyId.TradingArcade.SHOW_GOODS_DETIAL_INFO, {
      unpack(strs)
    })
    return true
  elseif string.find(id, "marketGoto_") then
    local str = string.sub(id, #"marketGoto_" + 1)
    local strs = string.split(str, "_")
    Event.DispatchEvent(ModuleId.TRADING_ARCADE, gmodule.notifyId.TradingArcade.FOCUS_ON_GOODS, {
      unpack(strs)
    })
    return true
  elseif string.find(id, "spaceMoment_") then
    local str = string.sub(id, #"spaceMoment_" + 1)
    local strs = string.split(str, "_")
    Event.DispatchEvent(ModuleId.SOCIAL_SPACE, gmodule.notifyId.SocialSpace.ReqFocusOnMsg, {
      unpack(strs)
    })
    return true
  elseif string.find(id, "chengwei_") then
    local str = string.sub(id, #"chengwei_" + 1)
    local strs = string.split(str, "_")
    require("Main.title.TitleMgr").ShowChengweiTips(tonumber(strs[1]), strs[2])
    return true
  elseif string.find(id, "touxian_") then
    local str = string.sub(id, #"touxian_" + 1)
    local strs = string.split(str, "_")
    require("Main.title.TitleMgr").ShowTouxianTips(tonumber(strs[1]), strs[2])
    return true
  elseif string.find(id, "mounts_") then
    ChatModule.Instance():RequestInfoPack(id)
    return true
  elseif string.find(id, "child_") then
    require("Main.Children.ChildrenInterface").RequestChildInfoChat(id)
    return true
  elseif string.sub(id, 1, 9) == "sendgift_" then
    Event.DispatchEvent(ModuleId.CHAT, gmodule.notifyId.Chat.BtnClickInChat, {id = id})
    return true
  elseif string.find(id, AtUtils.GetHTMLAtPrefix()) then
    require("Main.Chat.At.AtMgr").OnClickAtInfoPack(id)
    return true
  end
  return false
end
def.method("=>", "boolean").CheckContext = function(self)
  return true
end
def.method().OnBtnDeleteAll = function(self)
  require("GUI.CommonConfirmDlg").ShowConfirm(textRes.Chat.At.CLEAR_CONFIRM_TITLE, textRes.Chat.At.CLEAR_CONFIRM_CONTENT, function(id, tag)
    if id == 1 then
      AtData.Instance():RemoveAllAtMsg()
      self:DestroyPanel()
    end
  end, nil)
end
def.method("userdata").OnBtn_Reply = function(self, clickObj)
  local parent = clickObj and clickObj.parent
  if parent then
    do
      local id = parent.name
      local togglePrefix = "item_"
      local idx = tonumber(string.sub(id, string.len(togglePrefix) + 1))
      local atMsgData = self._atMsgList and self._atMsgList[idx] or nil
      if atMsgData then
        table.insert(self._toBeDelAtMsgList, atMsgData)
        local ChatConsts = require("netio.protocol.mzm.gsp.chat.ChatConsts")
        if atMsgData.channel == ChatConsts.CHANNEL_GROUP then
          local GroupModule = require("Main.Group.GroupModule")
          if GroupModule.Instance():IsInitedBasicAllGroup() then
            AtUtils.ReplyAtMsg(atMsgData)
          else
            warn("[AtBoxPanel:OnBtn_Reply] group info not inited, wait for Group_BasicInfo_Inited.")
            function self._groupInitCB()
              warn("[AtBoxPanel:OnBtn_Reply] group info inited, ReplyAtMsg.")
              AtUtils.ReplyAtMsg(atMsgData)
            end
            local protocolMgr = require("Main.Group.GroupProtocolMgr")
            protocolMgr.SetWaitForBasicInfo(true)
            protocolMgr.CGroupBasicInfoReq()
          end
        else
          AtUtils.ReplyAtMsg(atMsgData)
        end
      else
        warn("[ERROR][AtBoxPanel:OnBtn_Reply] atMsgData nil at idx:", idx)
      end
    end
  end
end
def.method("userdata").OnBtn_Delete = function(self, clickObj)
  local parent = clickObj and clickObj.parent
  if parent then
    local id = parent.name
    local togglePrefix = "item_"
    local idx = tonumber(string.sub(id, string.len(togglePrefix) + 1))
    self:DeleteAtMsgByIdx(idx)
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
    eventFunc(ModuleId.GROUP, gmodule.notifyId.Group.Group_BasicInfo_Inited, AtBoxPanel.OnGroupBasicInfoInited)
  end
end
def.static("table", "table").OnGroupBasicInfoInited = function(params, context)
  local self = AtBoxPanel.Instance()
  if not _G.IsNil(self.m_panel) and self._groupInitCB then
    self._groupInitCB()
    self._groupInitCB = nil
  end
end
AtBoxPanel.Commit()
return AtBoxPanel
