local Lplus = require("Lplus")
local ComponentBase = require("Main.MainUI.ui.MainUIComponentBase")
local MainUIChat = Lplus.Extend(ComponentBase, "MainUIChat")
local ChatModule = Lplus.ForwardDeclare("ChatModule")
local ChatMsgData = require("Main.Chat.ChatMsgData")
local ChatUtils = require("Main.Chat.ChatUtils")
local GangModule = require("Main.Gang.GangModule")
local CircleQueue = require("Main.Chat.CircleQueue")
local SpeechMgr = require("Main.Chat.SpeechMgr")
local Vector = require("Types.Vector")
local ChatConsts = require("netio.protocol.mzm.gsp.chat.ChatConsts")
local AtUtils = require("Main.Chat.At.AtUtils")
local def = MainUIChat.define
local instance
def.static("=>", MainUIChat).Instance = function()
  if instance == nil then
    instance = MainUIChat()
    instance:Init()
  end
  return instance
end
def.const("number").DATALIMIT = 32
def.const("number").LOWLIMIT = 6
def.const("number").HEIGHLIMIT = 12
def.const("number").LAODONCE = 1
def.field("table").VoiceBtnPosition = nil
def.field("userdata").template = nil
def.field("userdata").teamTemplate = nil
def.field("userdata").chatTable = nil
def.field("userdata").chatTableComp = nil
def.field("userdata").scroll = nil
def.field("userdata").ui_Img_RedChat = nil
def.field("userdata").ui_Img_Mail = nil
def.field("userdata").ui_Img_RedChannel = nil
def.field("string").curSpeech = ""
def.field("boolean").inSpeech = false
def.field("table").chatItemPool = nil
def.field("table").teamItemPool = nil
def.field("userdata").pool = nil
def.field("number").LIMIT = 6
def.field("number").newMsgCount = 0
def.field(CircleQueue).msgs = nil
def.field("boolean").hiding = false
def.override().Init = function(self)
  self.chatItemPool = {}
  self.teamItemPool = {}
  self.msgs = CircleQueue.new(MainUIChat.DATALIMIT)
end
def.method().ClearMsgData = function(self)
  self.msgs = CircleQueue.new(MainUIChat.DATALIMIT)
end
def.override().Shrink = function(self)
  local subNode2 = self.m_node:FindDirect("Img_Chat")
  self:_Shrink(subNode2, ComponentBase.Dir.Bottom)
end
def.override().Expand = function(self)
  local subNode2 = self.m_node:FindDirect("Img_Chat")
  local tweenPosition2 = subNode2:GetComponent("TweenPosition")
  if tweenPosition2 then
    if self.m_anchorNode and self.m_anchorNode.isnil == false then
      tweenPosition2.from = self.m_anchorNode.localPosition
    end
    tweenPosition2:PlayReverse()
  end
end
def.override().OnCreate = function(self)
  self.template = self.m_node:FindDirect("Img_Chat/Scroll View_Chat/Table_Chat/Chat")
  local itemNew = Object.Instantiate(self.template)
  local tempmsg = {}
  tempmsg.content = "abc"
  local HtmlHelper = require("Main.Chat.HtmlHelper")
  local str = HtmlHelper.ConvertSystemChat(tempmsg)
  local html = itemNew:GetComponent("NGUIHTML")
  html:ForceHtmlText(str)
  Object.Destroy(itemNew)
  self.template:SetActive(false)
  self.teamTemplate = self.m_node:FindDirect("Img_Chat/Scroll View_Chat/Table_Chat/Group_Team")
  self.teamTemplate:SetActive(false)
  self.chatTable = self.m_node:FindDirect("Img_Chat/Scroll View_Chat/Table_Chat")
  self.chatTableComp = self.chatTable:GetComponent("UITable")
  self.chatTableComp.RecursiveCalcBounds = false
  self.scroll = self.m_node:FindDirect("Img_Chat/Scroll View_Chat"):GetComponent("UIScrollView")
  self.ui_Img_RedChat = self.m_node:FindDirect("Panel_Btn/Group_Btn/Btn_Chat/Img_RedChat")
  self.ui_Img_Mail = self.m_node:FindDirect("Panel_Btn/Group_Btn/Btn_Chat/Img_Mail")
  self.ui_Img_RedChannel = self.m_node:FindDirect("Panel_Btn/Group_Btn/Btn_Talk/Img_Red")
  self.hiding = false
  local pool = GameObject.GameObject("pool")
  pool.parent = self.m_node
  self.template.parent = pool
  self.teamTemplate.parent = pool
  pool:SetActive(false)
  self.pool = pool
  self.ui_Img_Mail:SetActive(false)
  self:InitVoiceBtnPosition()
  self:UpdateVoiceBtn()
  self:ShowNew(false)
  Event.RegisterEvent(ModuleId.FRIEND, gmodule.notifyId.Friend.Friend_OnApplicantsChange, MainUIChat.OnUnreadMessageUpdate)
  Event.RegisterEvent(ModuleId.GANG, gmodule.notifyId.Gang.Gang_AnnouncementsChanged, MainUIChat.OnUnreadAnnouncementsUpdate)
  Event.RegisterEvent(ModuleId.FRIEND, gmodule.notifyId.Friend.Friend_OnMailsChange, MainUIChat.OnUnreadMailAmountChange)
  Event.RegisterEvent(ModuleId.SYSTEM_SETTING, gmodule.notifyId.SystemSetting.OPEN_VOICE_SETTING_PANEL, MainUIChat.OpenSetting)
  Event.RegisterEvent(ModuleId.GANG, gmodule.notifyId.Gang.Gang_InfoChanged, MainUIChat.OnGangChange)
  Event.RegisterEvent(ModuleId.GANG_CROSS, gmodule.notifyId.GangCross.GangCross_SyncRoleCompete, MainUIChat.OnGangChange)
  Event.RegisterEvent(ModuleId.TEAM, gmodule.notifyId.Team.UPDATE_TEAM_INFO, MainUIChat.OnUpdateTeam)
  Event.RegisterEvent(ModuleId.HERO, gmodule.notifyId.Hero.HERO_LEVEL_UP, MainUIChat.OnLevelUp)
  Event.RegisterEvent(ModuleId.CHAT, gmodule.notifyId.Chat.TeamPlatform_Change, MainUIChat.OnTeamPlatformChange)
  Event.RegisterEvent(ModuleId.FEATURE, gmodule.notifyId.Feature.FeatureOpenChange, MainUIChat.OnFeatureOpenChange)
  Event.RegisterEvent(ModuleId.SHITU, gmodule.notifyId.Shitu.MASTER_TASK_INFO_CHANGE, MainUIChat.OnMasterTaskInfoChange)
  Event.RegisterEvent(ModuleId.CTF, gmodule.notifyId.CTF.EnterSingleBattle, MainUIChat.OnSingleBattleChange)
  Event.RegisterEvent(ModuleId.CTF, gmodule.notifyId.CTF.LeaveSingleBattle, MainUIChat.OnSingleBattleChange)
  Event.RegisterEvent(ModuleId.CHAT, gmodule.notifyId.Chat.CHAT_AT_MSG_CHANGE, MainUIChat.OnAtMsgChange)
  Event.RegisterEvent(ModuleId.CHAT, gmodule.notifyId.Chat.GroupChatMsgUpdate, MainUIChat.OnGroupChatMsgUpdate)
  GameUtil.AddGlobalTimer(0.1, true, function()
    if self.m_node and not self.m_node.isnil then
      self:ClearMsgs()
      self:AddNewMsgs()
    end
  end)
end
def.override().OnDestroy = function(self)
  Event.UnregisterEvent(ModuleId.FRIEND, gmodule.notifyId.Friend.Friend_OnApplicantsChange, MainUIChat.OnUnreadMessageUpdate)
  Event.UnregisterEvent(ModuleId.FRIEND, gmodule.notifyId.Friend.Friend_OnMailsChange, MainUIChat.OnUnreadMailAmountChange)
  Event.UnregisterEvent(ModuleId.SYSTEM_SETTING, gmodule.notifyId.SystemSetting.OPEN_VOICE_SETTING_PANEL, MainUIChat.OpenSetting)
  Event.UnregisterEvent(ModuleId.GANG, gmodule.notifyId.Gang.Gang_AnnouncementsChanged, MainUIChat.OnUnreadAnnouncementsUpdate)
  Event.UnregisterEvent(ModuleId.GANG, gmodule.notifyId.Gang.Gang_InfoChanged, MainUIChat.OnGangChange)
  Event.UnregisterEvent(ModuleId.GANG_CROSS, gmodule.notifyId.GangCross.GangCross_SyncRoleCompete, MainUIChat.OnGangChange)
  Event.UnregisterEvent(ModuleId.TEAM, gmodule.notifyId.Team.UPDATE_TEAM_INFO, MainUIChat.OnUpdateTeam)
  Event.UnregisterEvent(ModuleId.HERO, gmodule.notifyId.Hero.HERO_LEVEL_UP, MainUIChat.OnLevelUp)
  Event.UnregisterEvent(ModuleId.CHAT, gmodule.notifyId.Chat.TeamPlatform_Change, MainUIChat.OnTeamPlatformChange)
  Event.UnregisterEvent(ModuleId.FEATURE, gmodule.notifyId.Feature.FeatureOpenChange, MainUIChat.OnFeatureOpenChange)
  Event.UnregisterEvent(ModuleId.SHITU, gmodule.notifyId.Shitu.MASTER_TASK_INFO_CHANGE, MainUIChat.OnMasterTaskInfoChange)
  Event.UnregisterEvent(ModuleId.CTF, gmodule.notifyId.CTF.EnterSingleBattle, MainUIChat.OnSingleBattleChange)
  Event.UnregisterEvent(ModuleId.CTF, gmodule.notifyId.CTF.LeaveSingleBattle, MainUIChat.OnSingleBattleChange)
  Event.UnregisterEvent(ModuleId.CHAT, gmodule.notifyId.Chat.CHAT_AT_MSG_CHANGE, MainUIChat.OnAtMsgChange)
  Event.UnregisterEvent(ModuleId.CHAT, gmodule.notifyId.Chat.GroupChatMsgUpdate, MainUIChat.OnGroupChatMsgUpdate)
  self.ui_Img_RedChat = nil
  self.ui_Img_Mail = nil
  self.scroll = nil
  self.chatTableComp = nil
  self.template = nil
  self.chatItemPool = {}
  self.teamItemPool = {}
  self.newMsgCount = 0
  self.hiding = false
  if self.curSpeech ~= "" then
    SpeechMgr.Instance():CancelSpeech()
    self.curSpeech = ""
    self.inSpeech = false
  else
    require("Main.Chat.ui.SpeechTip").Instance():Close()
  end
end
def.override("boolean").SetVisible = function(self, visible)
  if visible then
    self.m_node:GetComponent("UIPanel"):set_alpha(1)
  else
    self.m_node:GetComponent("UIPanel"):set_alpha(0)
  end
end
def.method().InitVoiceBtnPosition = function(self)
  local hasGang = require("Main.Gang.GangModule").Instance():HasGang()
  local voiceNew = self.m_node:FindDirect("Panel_Btn/Group_Btn/Btn_VioceNew")
  local voiceFaction = self.m_node:FindDirect("Panel_Btn/Group_Btn/Btn_VioceFaction")
  local voiceTeam = self.m_node:FindDirect("Panel_Btn/Group_Btn/Btn_VioceTeam")
  local voiceWorld = self.m_node:FindDirect("Panel_Btn/Group_Btn/Btn_VioceWorld")
  self.VoiceBtnPosition = {}
  local pos1 = voiceNew.localPosition
  local pos2 = voiceTeam.localPosition
  local pos3 = voiceWorld.localPosition
  self.VoiceBtnPosition[1] = {
    x = pos1.x,
    y = pos1.y
  }
  self.VoiceBtnPosition[2] = {
    x = pos2.x,
    y = pos2.y
  }
  self.VoiceBtnPosition[3] = {
    x = pos3.x,
    y = pos3.y
  }
end
def.override().OnShow = function(self)
  local num = require("Main.friend.FriendModule").Instance():GetAllFriendCount() or 0
  self:SetUnreadMessageNum(num)
  local unReadMail = require("Main.friend.FriendData").Instance():GetUnReadMailsNum() or 0
  local gangUnRead = require("Main.Gang.data.GangData").Instance():GetUnReadAnnoNum() or 0
  unReadMail = unReadMail + gangUnRead
  local hasRead = require("Main.UpdateNotice.UpdateNoticeModule").Instance():HasRead()
  if hasRead == false then
    unReadMail = unReadMail + 1
  end
  self:UpdateMailIcon(unReadMail)
  self:RefreshMain()
  self:UpdateChatReddot()
end
def.method("=>", "boolean").GetToggleState = function(self)
  local btnup = self.m_node:FindDirect("Panel_Btn/Group_Btn/Btn_Up"):GetComponent("UIToggleEx")
  return btnup.value
end
def.method().SetViewLow = function(self)
  local Img_Chat = self.m_node:FindDirect("Img_Chat")
  local Img_ChatWidget = Img_Chat:GetComponent("UIWidget")
  Img_ChatWidget:set_height(100)
  local btnGroup = self.m_node:FindDirect("Panel_Btn/Group_Btn"):GetComponent("UIWidget"):UpdateAnchors()
  local btnup = self.m_node:FindDirect("Panel_Btn/Group_Btn/Btn_Up"):GetComponent("UIToggleEx")
  btnup:set_value(false)
  self.LIMIT = MainUIChat.LOWLIMIT
  self:RefreshMain()
end
def.method().SetViewHigh = function(self)
  local Img_Chat = self.m_node:FindDirect("Img_Chat")
  local Img_ChatWidget = Img_Chat:GetComponent("UIWidget")
  Img_ChatWidget:set_height(220)
  local btnGroup = self.m_node:FindDirect("Panel_Btn/Group_Btn"):GetComponent("UIWidget"):UpdateAnchors()
  local btnup = self.m_node:FindDirect("Panel_Btn/Group_Btn/Btn_Up"):GetComponent("UIToggleEx")
  btnup:set_value(true)
  self.LIMIT = MainUIChat.HEIGHLIMIT
  self:AddOldMsgs()
  self:RefreshMain()
end
def.override().OnHide = function(self)
end
def.override("number").OnLayerChange = function(self, layer)
  if layer == ClientDef_Layer.UI then
    self.hiding = false
    if self.curSpeech ~= "" then
      local voiceBtn = self.m_node:FindDirect("Panel_Btn/Group_Btn/" .. self.curSpeech)
      local onBtn = UICamera.IsHighlighted(voiceBtn)
      if onBtn then
        if not self.inSpeech then
          self.inSpeech = true
          SpeechMgr.Instance():Pause(false)
        end
      elseif self.inSpeech then
        self.inSpeech = false
        SpeechMgr.Instance():Pause(true)
      end
    end
  elseif layer == ClientDef_Layer.Invisible then
    self.hiding = true
  end
end
def.override("string", "boolean").OnToggle = function(self, id, value)
  if id == "Btn_Up" then
    if value then
      self:SetViewHigh()
    else
      self:SetViewLow()
    end
    local SystemSettingModule = require("Main.SystemSetting.SystemSettingModule")
    local setting = SystemSettingModule.Instance():GetSetting(SystemSettingModule.SystemSetting.ANCHOR)
    local ECApollo = require("ProxySDK.ECApollo")
    if setting.isEnabled and ECApollo.IsOpen() then
      Event.DispatchEvent(ModuleId.CHAT, gmodule.notifyId.Chat.OnToggle, {
        switch = not value
      })
    end
  end
end
def.override("string").OnClick = function(self, id)
  if id == "Img_Chat" then
    require("Main.Chat.ui.ChannelChatPanel").ShowChannelChatPanel(-1, -1)
  elseif id == "Btn_Action" then
    require("Main.Chat.ui.DlgAction").Instance():ShowDlg()
  elseif string.find(id, "voice_") then
    local uniqueId = tonumber(string.sub(id, 7))
    if uniqueId then
      local msg = ChatMsgData.Instance():GetUniqueMsg(uniqueId)
      if msg and msg.fileId then
        SpeechMgr.Instance():PlayInterrupt(msg.fileId, msg.second)
      end
    end
  elseif string.find(id, "question_") then
    require("Main.Question.QuestionModule").Instance():AnswerGangHelp(id)
  elseif string.find(id, "qyxt_") then
    require("Main.Question.EveryNightQuestionModule").Instance():AnswerGangHelp(id)
  elseif string.find(id, "btn_") then
    Event.DispatchEvent(ModuleId.CHAT, gmodule.notifyId.Chat.BtnClickInChat, {
      id = string.sub(id, 5)
    })
  elseif string.find(id, "card_") then
    Event.DispatchEvent(ModuleId.CHAT, gmodule.notifyId.Chat.CARD_CLICK, {
      id = string.sub(id, 6)
    })
  elseif string.find(id, "Btn_Join_") then
    local index = string.sub(id, 10)
    Event.DispatchEvent(ModuleId.CHAT, gmodule.notifyId.Chat.Chat_Apply_Team, {index})
  elseif string.find(id, "item_") then
    ChatModule.Instance():RequestInfoPack(id)
  elseif string.find(id, "wing_") then
    ChatModule.Instance():RequestInfoPack(id)
  elseif string.find(id, "aircraft_") then
    ChatModule.Instance():RequestInfoPack(id)
  elseif string.find(id, "pet_") then
    ChatModule.Instance():RequestInfoPack(id)
  elseif string.find(id, "task_") then
    ChatModule.Instance():RequestInfoPack(id)
  elseif string.find(id, "fashion_") then
    ChatModule.Instance():RequestInfoPack(id)
  elseif string.find(id, "fabao_") then
    ChatModule.Instance():RequestFabaoPackInfo(id)
  elseif string.find(id, "fabaospirit_") then
    ChatModule.Instance():RequestFabaoLingQiPackInfo(id)
  elseif string.find(id, "team_") then
    require("Main.Chat.ui.ChannelChatPanel").ShowChannelChatPanel(-1, -1)
  elseif string.find(id, "unique_") then
    require("Main.Chat.ui.ChannelChatPanel").ShowChannelChatPanel(-1, -1)
  elseif string.sub(id, 1, 5) == "zone_" then
    ChatModule.Instance():RequestInfoPack(id)
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
  elseif string.find(id, "role_") then
    local FriendCommonDlgManager = require("Main.friend.FriendCommonDlgManager")
    local strs = string.split(id, "_")
    local channel = tonumber(strs[2])
    local roleId = Int64.new(strs[3])
    local myId = _G.GetMyRoleID()
    if roleId ~= myId then
      local state = FriendCommonDlgManager.StateConst.Null
      FriendCommonDlgManager.ApplyShowFriendCommonDlg(roleId, state)
    end
  elseif id == "Btn_ChatSetting" then
    local ChatSetting = require("Main.Chat.ui.ChatSettingDlg")
    local settingDlg = ChatSetting()
    settingDlg:CreatePanel(RESPATH.PREFAB_CHAT_SETTING, 2)
  elseif string.find(id, "Btn_TeamPlatform_Apply_") then
    local str = string.sub(id, #"Btn_TeamPlatform_Apply_" + 1)
    local strs = string.split(str, "_")
    Event.DispatchEvent(ModuleId.CHAT, gmodule.notifyId.Chat.Chat_Apply_Team_Ex, {
      unpack(strs)
    })
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
  elseif string.find(id, "marketGoods_") then
    local str = string.sub(id, #"marketGoods_" + 1)
    local strs = string.split(str, "_")
    Event.DispatchEvent(ModuleId.TRADING_ARCADE, gmodule.notifyId.TradingArcade.SHOW_GOODS_DETIAL_INFO, {
      unpack(strs)
    })
  elseif string.find(id, "marketGoto_") then
    local str = string.sub(id, #"marketGoto_" + 1)
    local strs = string.split(str, "_")
    Event.DispatchEvent(ModuleId.TRADING_ARCADE, gmodule.notifyId.TradingArcade.FOCUS_ON_GOODS, {
      unpack(strs)
    })
  elseif string.find(id, "spaceMoment_") then
    local str = string.sub(id, #"spaceMoment_" + 1)
    local strs = string.split(str, "_")
    Event.DispatchEvent(ModuleId.SOCIAL_SPACE, gmodule.notifyId.SocialSpace.ReqFocusOnMsg, {
      unpack(strs)
    })
  elseif id == "Btn_New" then
    self:ClearMsgs()
    self:AddNewMsgs()
    self:ShowNew(false)
  elseif string.find(id, "chengwei_") then
    local str = string.sub(id, #"chengwei_" + 1)
    local strs = string.split(str, "_")
    require("Main.title.TitleMgr").ShowChengweiTips(tonumber(strs[1]), strs[2])
  elseif string.find(id, "touxian_") then
    local str = string.sub(id, #"touxian_" + 1)
    local strs = string.split(str, "_")
    require("Main.title.TitleMgr").ShowTouxianTips(tonumber(strs[1]), strs[2])
  elseif string.find(id, "mounts_") then
    ChatModule.Instance():RequestInfoPack(id)
  elseif string.find(id, "child_") then
    require("Main.Children.ChildrenInterface").RequestChildInfoChat(id)
  elseif string.find(id, AtUtils.GetHTMLAtPrefix()) then
    require("Main.Chat.At.AtMgr").OnClickAtInfoPack(id)
  elseif string.find(id, "shenyao_") then
    require("Main.Gang.GodMedicine.GodMedicineMgr").OnHyperLinkClick(id)
  elseif string.find(id, "TurnedCard_") then
    local strs = string.split(id, "_")
    require("Main.TurnedCard.TurnedCardUtils").ShowTurnedCardTips(tonumber(strs[2]), tonumber(strs[3]))
  end
end
def.method("string", "boolean").onPress = function(self, id, press)
  if id == "Btn_VioceFaction" or id == "Btn_VioceTeam" or id == "Btn_VioceWorld" or id == "Btn_VioceNew" or id == "Btn_VoiceBattle" then
    if press then
      if SpeechMgr.Instance():StartSpeech() then
        self.curSpeech = id
        self.inSpeech = true
        local channel = self:Btn2Channel(self.curSpeech)
        SpeechMgr.Instance():SetChannel(channel)
      end
    else
      if self.inSpeech then
        SpeechMgr.Instance():EndSpeech()
      else
        SpeechMgr.Instance():CancelSpeech()
      end
      self.curSpeech = ""
      self.inSpeech = false
    end
  end
end
def.method("string", "userdata").onDragOut = function(self, id, go)
  if not self.hiding and self.curSpeech ~= "" then
    local press = UICamera.IsHighlighted(go)
    if press == true then
      self.inSpeech = true
      SpeechMgr.Instance():Pause(false)
    else
      GameUtil.AddGlobalTimer(0.1, true, function()
        if self.curSpeech ~= "" then
          self.inSpeech = false
          SpeechMgr.Instance():Pause(true)
        end
      end)
    end
  end
end
def.method("string", "userdata").onDragOver = function(self, id, go)
  if not self.hiding and self.curSpeech == id then
    self.inSpeech = true
    SpeechMgr.Instance():Pause(false)
  end
end
def.method("=>", "number").GetRawDragAmount = function(self)
  if self.chatTable.isnil or self.scroll.isnil then
    return 0
  end
  local childCount = self.chatTable:get_childCount()
  if childCount > 0 then
    return self.scroll:GetDragAmount().y
  else
    return 0
  end
end
def.method("=>", "number").GetDragAmount = function(self)
  if self.chatTable.isnil or self.scroll.isnil then
    return 0
  end
  local childCount = self.chatTable:get_childCount()
  if childCount > 0 then
    local scrollBound = self.scroll:get_bounds()
    local contentBound = self.scroll:GetClipBounds()
    local scrollHeight = scrollBound.max.y - scrollBound.min.y
    local clipHeight = contentBound.size.y
    if scrollHeight <= clipHeight then
      return 0
    else
      return self.scroll:GetDragAmount().y
    end
  else
    return 0
  end
end
def.method("string", "number", "number").onDrag = function(self, id, dx, dy)
  local dragAmount = self:GetRawDragAmount()
  if dragAmount < 0 then
    local childCount = self.chatTable:get_childCount()
    if childCount > 0 then
      do
        local lastChild = self.chatTable:GetChild(childCount - 1)
        local find, index = self.msgs:SearchOne(function(info)
          if info.teamId then
            return lastChild.name == "team_" .. info.id
          else
            return lastChild.name == "unique_" .. info.unique
          end
        end)
        if find then
          local msgs = self.msgs:GetForward(index, MainUIChat.LAODONCE)
          if #msgs > 0 then
            for i = 1, #msgs do
              if msgs[i].teamId then
                self:_addTeam(msgs[i], false)
              else
                self:_addMsg(msgs[i], false)
              end
            end
            self:RemoveSpareMsg(false)
            self:RefreshMainAndKeepScroll(lastChild)
          else
            self:ShowNew(false)
          end
        else
          local msgs = self.msgs:GetListReverse(MainUIChat.LAODONCE)
          if #msgs > 0 then
            for i = 1, #msgs do
              if msgs[i].teamId then
                self:_addTeam(msgs[i], false)
              else
                self:_addMsg(msgs[i], false)
              end
            end
            self:RemoveSpareMsg(false)
            self:RefreshMainAndKeepScroll(lastChild)
          else
            self:ShowNew(false)
          end
        end
      end
    end
  elseif dragAmount > 1 then
    local childCount = self.chatTable:get_childCount()
    if childCount > 0 then
      do
        local firstChild = self.chatTable:GetChild(0)
        local find, index = self.msgs:SearchOne(function(info)
          if info.teamId then
            return firstChild.name == "team_" .. info.id
          else
            return firstChild.name == "unique_" .. info.unique
          end
        end)
        if find then
          local msgs = self.msgs:GetBackward(index, MainUIChat.LAODONCE)
          if #msgs > 0 then
            for i = #msgs, 1, -1 do
              if msgs[i].teamId then
                self:_addTeam(msgs[i], true)
              else
                self:_addMsg(msgs[i], true)
              end
            end
            self:RemoveSpareMsg(true)
            self:RefreshMainAndKeepScroll(firstChild)
          end
        end
      end
    end
  end
end
def.method("boolean").ShowNew = function(self, new)
  if new then
    self.newMsgCount = self.newMsgCount + 1
    local newBtn = self.m_node:FindDirect("Panel_Btn/Group_Btn/Btn_New")
    newBtn:SetActive(true)
    local newLabel = newBtn:FindDirect("Label_New")
    local showNum = self.newMsgCount >= 100 and "99+" or tostring(self.newMsgCount)
    newLabel:GetComponent("UILabel"):set_text(string.format(textRes.Chat[54], showNum))
  else
    local newBtn = self.m_node:FindDirect("Panel_Btn/Group_Btn/Btn_New")
    newBtn:SetActive(false)
    self.newMsgCount = 0
  end
end
def.method("=>", "boolean").NeedAdd = function(self)
  local childCount = self.chatTable:get_childCount()
  local newMsg = self.msgs:GetNewOne()
  if childCount > 0 and newMsg then
    local lastChild = self.chatTable:GetChild(childCount - 1)
    local firstExist = true
    if newMsg.teamId then
      firstExist = lastChild.name == "team_" .. newMsg.id
    else
      firstExist = lastChild.name == "unique_" .. newMsg.unique
    end
    if firstExist then
      return self:GetDragAmount() < 0.1
    else
      return false
    end
  else
    return true
  end
end
def.method().ClearMsgs = function(self)
  if self.chatTable.isnil then
    return
  end
  while self.chatTable:get_childCount() > 0 do
    local removeIndex = self.chatTable:get_childCount() - 1
    local pig = self.chatTable:GetChild(removeIndex)
    pig.parent = self.pool
    if string.find(pig.name, "unique_") then
      table.insert(self.chatItemPool, pig)
    elseif string.find(pig.name, "team_") then
      table.insert(self.teamItemPool, pig)
    end
  end
end
def.method().AddNewMsgs = function(self)
  if self.chatTable.isnil then
    return
  end
  local childCount = self.chatTable:get_childCount()
  local msgs = self.msgs:GetList(self.LIMIT)
  for i = #msgs, 1, -1 do
    local msg = msgs[i]
    if msg.teamId then
      self:_addTeam(msg, false)
    else
      self:_addMsg(msg, false)
    end
  end
  self:RefreshMain()
end
def.method().AddOldMsgs = function(self)
  if self.chatTable.isnil then
    return
  end
  local childCount = self.chatTable:get_childCount()
  local msgs
  if childCount > 0 then
    do
      local lastChild = self.chatTable:GetChild(0)
      local find, index = self.msgs:SearchOne(function(info)
        if info.teamId then
          return lastChild.name == "team_" .. info.id
        else
          return lastChild.name == "unique_" .. info.unique
        end
      end)
      local need = self.LIMIT - childCount
      msgs = not find or need > 0 and self.msgs:GetBackward(index, need) or {}
      if msgs then
        for i = 1, #msgs do
          if msgs[i].teamId then
            self:_addTeam(msgs[i], true)
          else
            self:_addMsg(msgs[i], true)
          end
        end
        self:RefreshMain()
      end
    end
  end
end
def.method("table").AddMsg = function(self, msg)
  if self.template == nil or self.template.isnil then
    self.msgs:In(msg)
    return
  end
  if self:NeedAdd() then
    self.msgs:In(msg)
    self:_addMsg(msg, false)
    self:RemoveSpareMsg(false)
    self:RefreshMain()
  else
    self.msgs:In(msg)
    if self.template == nil or self.template.isnil then
      return
    end
    self:ShowNew(true)
  end
end
def.method("table").UpdateOneMsg = function(self, msg)
  if self.template == nil or self.template.isnil then
    return
  end
  local msgGo = self.chatTable:FindDirect(string.format("unique_" .. msg.unique))
  if msgGo then
    local html = msgGo:GetComponent("NGUIHTML")
    html:ForceHtmlText(msg.mainHtml)
    local childCount = self.chatTable:get_childCount()
    local lastChild = self.chatTable:GetChild(childCount - 1)
    self:RefreshMainAndKeepScroll(lastChild)
  end
end
def.method("table", "boolean")._addMsg = function(self, msg, inverse)
  local reuseItem = table.remove(self.chatItemPool)
  local itemNew
  if reuseItem then
    itemNew = reuseItem
  else
    itemNew = Object.Instantiate(self.template)
  end
  if itemNew == nil or itemNew.isnil then
    return
  end
  local ChatUtils = require("Main.Chat.ChatUtils")
  itemNew.name = "unique_" .. msg.unique
  itemNew.parent = self.chatTable
  itemNew:set_localScale(Vector.Vector3.one)
  itemNew:set_localPosition(Vector.Vector3.zero)
  itemNew:SetActive(true)
  if not reuseItem then
    self.m_container.m_msgHandler:Touch(itemNew)
  end
  local html = itemNew:GetComponent("NGUIHTML")
  if _G.isDebugBuild then
    GameUtil.BeginSamp("ForceHtmlText")
    html:ForceHtmlText(msg.mainHtml)
    GameUtil.EndSamp()
  else
    html:ForceHtmlText(msg.mainHtml)
  end
  if inverse then
    itemNew.transform:SetAsFirstSibling()
  end
end
def.static("table", "table").OnTeamPlatformChange = function(p1, p2)
  local teams = p1
  for k, v in ipairs(teams) do
    instance:RefreshTeam(v)
  end
end
def.static("table", "table").OnFeatureOpenChange = function(param, context)
  local self = instance
  if self ~= nil then
    local ModuleFunSwitchInfo = require("netio.protocol.mzm.gsp.open.ModuleFunSwitchInfo")
    if param.feature == ModuleFunSwitchInfo.TYPE_SHITU_TASK then
      self:UpdateShituInteractReddot()
    elseif param.feature == ModuleFunSwitchInfo.TYPE_AT then
      self:UpdateAtMsgReddot()
    end
  end
end
def.static("table", "table").OnMasterTaskInfoChange = function(param, context)
  local self = instance
  if self ~= nil then
    self:UpdateShituInteractReddot()
  end
end
def.method().UpdateShituInteractReddot = function(self)
  local num = require("Main.friend.FriendModule").Instance():GetAllFriendCount() or 0
  self:SetUnreadMessageNum(num)
end
def.method("table").RefreshTeam = function(self, data)
  if self.chatTable == nil or self.chatTable.isnil then
    return
  end
  local findTeam, index = self.msgs:SearchOne(function(info)
    if info.teamId == data.teamId then
      if info.num > 0 and info.num < info.maxNum then
        return true
      elseif data.num > 0 and data.num < data.maxNum then
        return false
      else
        return true
      end
    else
      return false
    end
  end)
  if findTeam then
    findTeam.num = data.num
    local teamItem = self:FindRealTeamItem(tonumber(data.id))
    if teamItem then
      self:_refreshTeam(teamItem, data)
    end
  else
    self:AddTeam(data)
  end
end
def.method("number", "=>", "userdata").FindRealTeamItem = function(self, teamId)
  if self.chatTable and not self.chatTable.isnil then
    local childCount = self.chatTable:get_childCount()
    if childCount > 0 then
      for i = childCount - 1, 0, -1 do
        local itemObj = self.chatTable:GetChild(i)
        local itemName = itemObj.name
        if string.find(itemName, "team_") then
          local strs = string.split(itemName, "_")
          if strs[2] then
            local id = tonumber(strs[2])
            if id == teamId then
              return itemObj
            end
          end
        end
      end
      return nil
    else
      return nil
    end
  else
    return nil
  end
end
def.method("table").AddTeam = function(self, data)
  if self.teamTemplate == nil or self.teamTemplate.isnil then
    return nil
  end
  if self:NeedAdd() then
    self.msgs:In(data)
    self:_addTeam(data, false)
    self:RemoveSpareMsg(false)
    self:RefreshMain()
  else
    self.msgs:In(data)
    self:ShowNew(true)
  end
end
def.method("table", "boolean")._addTeam = function(self, data, inverse)
  local reuseItem = table.remove(self.teamItemPool)
  local itemNew
  if reuseItem then
    itemNew = reuseItem
  else
    itemNew = Object.Instantiate(self.teamTemplate)
  end
  if itemNew == nil or itemNew.isnil then
    return
  end
  itemNew.parent = self.chatTable
  itemNew.name = "team_" .. data.id
  itemNew:set_localScale(Vector.Vector3.one)
  itemNew:set_localPosition(Vector.Vector3.zero)
  itemNew:SetActive(true)
  self:_refreshTeam(itemNew, data)
  if not reuseItem then
    self.m_container.m_msgHandler:Touch(itemNew)
  end
  if inverse then
    itemNew.transform:SetAsFirstSibling()
  end
end
def.method("userdata", "table")._refreshTeam = function(self, teamUI, data)
  local activityNameLabel = teamUI:FindDirect("Label_Name"):GetComponent("UILabel")
  activityNameLabel:set_text(string.format(textRes.Chat[32], data.name, data.minLv, data.maxLv, data.num, data.maxNum))
  if data.num > 0 and data.num < data.maxNum then
    local btnjoin = teamUI:FindChildByPrefix("Btn_Join")
    if btnjoin then
      btnjoin.name = "Btn_Join_" .. data.teamId
      local lbl = btnjoin:GetComponent("UILabel")
      lbl:UpdateAnchors()
      lbl:set_text(textRes.Chat[52])
    end
  else
    local btnjoin = teamUI:FindChildByPrefix("Btn_Join")
    if btnjoin then
      btnjoin.name = "Btn_Join_"
      local lbl = btnjoin:GetComponent("UILabel")
      lbl:UpdateAnchors()
      lbl:set_text(textRes.Chat[53])
    end
  end
end
local bmin = Vector.Vector3.new()
local bmax = Vector.Vector3.new()
local refreshTimer = 0
def.method().RefreshMain = function(self)
  if refreshTimer > 0 then
    return
  end
  refreshTimer = GameUtil.AddGlobalLateTimer(0, true, function()
    refreshTimer = 0
    if self.chatTable == nil or self.chatTable.isnil then
      return
    end
    if self.chatTableComp == nil and self.chatTableComp.isnil then
      return
    end
    self.chatTableComp:Reposition()
    local bvalid, minx, miny, minz, maxx, maxy, maxz = GameUtil.GetUITableTotalBounds(self.chatTableComp)
    if bvalid then
      bmin:Set(minx, miny, minz)
      bmax:Set(maxx, maxy, maxz)
      self.scroll:SetOuterBounds(bmin, bmax)
    else
      self.scroll:ResetOuterBounds()
    end
    self.scroll:ResetPosition()
  end)
end
def.method("userdata").RefreshMainAndKeepScroll = function(self, beacon)
  if refreshTimer > 0 then
    return
  end
  refreshTimer = GameUtil.AddGlobalLateTimer(0, true, function()
    refreshTimer = 0
    if self.chatTable == nil or self.chatTable.isnil then
      return
    end
    if self.chatTableComp == nil or self.chatTableComp.isnil then
      return
    end
    if beacon == nil or beacon.isnil then
      return
    end
    local oldPos = beacon:get_position()
    self.chatTableComp:Reposition()
    local newPos = beacon:get_position()
    local bvalid, minx, miny, minz, maxx, maxy, maxz = GameUtil.GetUITableTotalBounds(self.chatTableComp)
    if bvalid then
      bmin:Set(minx, miny, minz)
      bmax:Set(maxx, maxy, maxz)
      self.scroll:SetOuterBounds(bmin, bmax)
    else
      self.scroll:ResetOuterBounds()
    end
    local movey = oldPos.y - newPos.y
    local move = Vector.Vector3.new(0, movey, 0)
    self.scroll:stopScroll()
    self.scroll:MoveAbsolute(move)
  end)
end
def.method("boolean").RemoveSpareMsg = function(self, inverse)
  while self.chatTable:get_childCount() > self.LIMIT do
    local removeIndex = inverse and self.chatTable:get_childCount() - 1 or 0
    local pig = self.chatTable:GetChild(removeIndex)
    pig.parent = self.pool
    if string.find(pig.name, "unique_") then
      table.insert(self.chatItemPool, pig)
    elseif string.find(pig.name, "team_") then
      table.insert(self.teamItemPool, pig)
    end
  end
end
def.static("table", "table").OnUnreadMessageUpdate = function(param1, param2)
  local num = param1[1]
  instance:SetUnreadMessageNum(num)
end
def.static("table", "table").OnUnreadAnnouncementsUpdate = function(param1, param2)
  local unReadMail = require("Main.friend.FriendData").Instance():GetUnReadMailsNum() or 0
  unReadMail = unReadMail + param1[1]
  local hasRead = require("Main.UpdateNotice.UpdateNoticeModule").Instance():HasRead()
  if hasRead == false then
    unReadMail = unReadMail + 1
  end
  instance:UpdateMailIcon(unReadMail)
end
def.method("number").SetUnreadMessageNum = function(self, num)
  local ui_Img_RedChat = self.ui_Img_RedChat
  if num <= 0 then
    ui_Img_RedChat:SetActive(false)
  else
    ui_Img_RedChat:SetActive(true)
    if not (num < 100) or not num then
      num = "99+"
    end
    ui_Img_RedChat:FindDirect("Label_RedChat"):GetComponent("UILabel"):set_text(num)
  end
end
def.static("table", "table").OnUnreadMailAmountChange = function(params)
  local unReadMail = params[1]
  local gangUnRead = require("Main.Gang.data.GangData").Instance():GetUnReadAnnoNum() or 0
  unReadMail = unReadMail + gangUnRead
  instance:UpdateMailIcon(unReadMail)
end
def.method("number").UpdateMailIcon = function(self, unReadMail)
  local isShow = unReadMail > 0 and true or false
  local ui_Img_Mail = self.ui_Img_Mail
  ui_Img_Mail:SetActive(isShow)
  ui_Img_Mail:FindDirect("Label_Mail"):GetComponent("UILabel"):set_text(unReadMail >= 100 and "99+" or unReadMail)
end
def.static("table", "table").OpenSetting = function(p1, p2)
  local ChatSetting = require("Main.Chat.ui.ChatSettingDlg")
  local settingDlg = ChatSetting()
  settingDlg:CreatePanel(RESPATH.PREFAB_CHAT_SETTING, 2)
end
def.static("table", "table").OnGangChange = function(p1, p1)
  instance:UpdateVoiceBtn()
end
def.static("table", "table").OnSingleBattleChange = function(p1, p2)
  instance:UpdateVoiceBtn()
end
def.static("table", "table").OnUpdateTeam = function(p1, p1)
  instance:UpdateVoiceBtn()
end
def.static("table", "table").OnLevelUp = function(p1, p1)
  instance:UpdateVoiceBtn()
end
def.method().UpdateVoiceBtn = function(self)
  local role = gmodule.moduleMgr:GetModule(ModuleId.HERO).myRole
  if role and role:IsInState(RoleState.SINGLEBATTLE) then
    local battleVoice = self.m_node:FindDirect("Panel_Btn/Group_Btn/Btn_VoiceBattle")
    local voiceNew = self.m_node:FindDirect("Panel_Btn/Group_Btn/Btn_VioceNew")
    local voiceFaction = self.m_node:FindDirect("Panel_Btn/Group_Btn/Btn_VioceFaction")
    local voiceTeam = self.m_node:FindDirect("Panel_Btn/Group_Btn/Btn_VioceTeam")
    local voiceWorld = self.m_node:FindDirect("Panel_Btn/Group_Btn/Btn_VioceWorld")
    battleVoice:SetActive(true)
    voiceNew:SetActive(false)
    voiceFaction:SetActive(false)
    voiceTeam:SetActive(false)
    voiceWorld:SetActive(false)
    return
  else
    self.m_node:FindDirect("Panel_Btn/Group_Btn/Btn_VoiceBattle"):SetActive(false)
  end
  local hasGang = require("Main.Gang.GangModule").Instance():HasGang()
  local voiceNew = self.m_node:FindDirect("Panel_Btn/Group_Btn/Btn_VioceNew")
  local voiceFaction = self.m_node:FindDirect("Panel_Btn/Group_Btn/Btn_VioceFaction")
  local posIndex = 1
  if hasGang then
    voiceNew:SetActive(false)
    voiceFaction:SetActive(true)
    local pos = self.VoiceBtnPosition[posIndex]
    voiceFaction:set_localPosition(Vector.Vector3.new(pos.x, pos.y, 0))
  else
    voiceNew:SetActive(true)
    voiceFaction:SetActive(false)
    local pos = self.VoiceBtnPosition[posIndex]
    voiceNew:set_localPosition(Vector.Vector3.new(pos.x, pos.y, 0))
  end
  posIndex = posIndex + 1
  local hasTeam = require("Main.Team.TeamData").Instance():HasTeam()
  local voiceTeam = self.m_node:FindDirect("Panel_Btn/Group_Btn/Btn_VioceTeam")
  if hasTeam then
    voiceTeam:SetActive(true)
    local pos = self.VoiceBtnPosition[posIndex]
    voiceTeam:set_localPosition(Vector.Vector3.new(pos.x, pos.y, 0))
    posIndex = posIndex + 1
  else
    voiceTeam:SetActive(false)
  end
  local level = require("Main.Hero.Interface").GetBasicHeroProp().level
  local voiceWorld = self.m_node:FindDirect("Panel_Btn/Group_Btn/Btn_VioceWorld")
  if level >= ChatModule.Instance().ChatLimit[require("consts.mzm.gsp.chat.confbean.ChannelType").WORLD].levelLimit then
    voiceWorld:SetActive(true)
    local pos = self.VoiceBtnPosition[posIndex]
    voiceWorld:set_localPosition(Vector.Vector3.new(pos.x, pos.y, 0))
    posIndex = posIndex + 1
  else
    voiceWorld:SetActive(false)
  end
end
def.method("string", "=>", "number").Btn2Channel = function(self, btn)
  if btn == "Btn_VioceFaction" then
    return ChatConsts.CHANNEL_FACTION
  elseif btn == "Btn_VioceTeam" then
    return ChatConsts.CHANNEL_TEAM
  elseif btn == "Btn_VioceWorld" then
    return ChatConsts.CHANNEL_WORLD
  elseif btn == "Btn_VioceNew" then
    return ChatConsts.CHANNEL_NEWER
  elseif btn == "Btn_VoiceBattle" then
    return ChatConsts.CHANNEL_SINGLE_BATTLE__CAMP
  end
  return 0
end
def.method("table").RemoveMsgs = function(self, uniques)
  if self.chatTable and not self.chatTable.isnil then
    for k, v in ipairs(uniques) do
      do
        local find, index = self.msgs:SearchOne(function(msg)
          return msg.unique == v
        end)
        if find then
          self.msgs:DeleteOne(index)
        end
        local chatItem = self.chatTable:FindDirect(string.format("unique_%d", v))
        if chatItem then
          chatItem.parent = self.pool
          table.insert(self.chatItemPool, chatItem)
        end
      end
    end
    self:RefreshMain()
  end
end
def.static("table", "table").OnGroupChatMsgUpdate = function(param, context)
  local self = instance
  if self ~= nil then
    local num = require("Main.friend.FriendModule").Instance():GetAllFriendCount() or 0
    self:SetUnreadMessageNum(num)
  end
end
def.static("table", "table").OnAtMsgChange = function(param, context)
  local self = instance
  if self ~= nil then
    self:UpdateAtMsgReddot()
  end
end
def.method().UpdateAtMsgReddot = function(self)
  local num = require("Main.friend.FriendModule").Instance():GetAllFriendCount() or 0
  self:SetUnreadMessageNum(num)
  self:UpdateChatReddot()
end
def.method().UpdateChatReddot = function(self)
  local GUIUtils = require("GUI.GUIUtils")
  GUIUtils.SetActive(self.ui_Img_RedChannel, require("Main.Chat.At.AtMgr").Instance():NeedChatReddot())
end
MainUIChat.Commit()
return MainUIChat
