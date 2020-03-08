local Lplus = require("Lplus")
local TabNode = require("GUI.TabNode")
local ECPanelBase = require("GUI.ECPanelBase")
local ChatNode = Lplus.Extend(TabNode, "ChatNode")
local def = ChatNode.define
local ChatUtils = require("Main.Chat.ChatUtils")
local GUIUtils = require("GUI.GUIUtils")
local Vector = require("Types.Vector")
local ChatMsgData = require("Main.Chat.ChatMsgData")
local SocialPanel = Lplus.ForwardDeclare("SocialPanel")
local ChatModule = Lplus.ForwardDeclare("ChatModule")
local ChatConst = require("netio.protocol.mzm.gsp.chat.ChatConsts")
local FriendModule = Lplus.ForwardDeclare("FriendModule")
local SpeechMgr = require("Main.Chat.SpeechMgr")
local ChatInputDlg = require("Main.Chat.ui.ChatInputDlg")
local FriendCommonDlgManager = require("Main.friend.FriendCommonDlgManager")
local GangModule = require("Main.Gang.GangModule")
local BadgeModule = require("Main.Badge.BadgeModule")
local bmin = Vector.Vector3.new()
local bmax = Vector.Vector3.new()
def.const("number").MAXCHAT = 16
def.const("number").ADDONCE = 16
def.field("userdata").channelTitle = nil
def.field("table").channelTabs = nil
def.field("userdata").friendTitle = nil
def.field("userdata").systemTitle = nil
def.field("table").systemTabs = nil
def.field("userdata").input = nil
def.field("userdata").noInput = nil
def.field("userdata").newMsgBtn = nil
def.field("userdata").chatContent = nil
def.field("userdata").scroll = nil
def.field("userdata").chattable = nil
def.field("userdata").leftTemplate = nil
def.field("userdata").rightTemplate = nil
def.field("userdata").noteTemplate = nil
def.field("userdata").sysTemplate = nil
def.field("userdata").teamTemplate = nil
def.field("userdata").timeTemplate = nil
def.field("table").State2ProtocolMap = nil
def.field("boolean").canChat = true
def.field("number").curOperation = 0
def.field("boolean").doSpeech = false
def.field("boolean").inSpeech = false
def.field("number").lastMsgTime = 0
def.field("userdata").pool = nil
def.field("table").itemPool = nil
def.method().FixLabelName = function(self)
  self.m_node:FindDirect("Title_SysChatBtn/Tap_All/Label_Faction"):GetComponent("UILabel"):set_text(textRes.Chat.Tab[1])
  self.m_node:FindDirect("Title_SysChatBtn/Tap_Sys/Label_Team"):GetComponent("UILabel"):set_text(textRes.Chat.Tab[2])
  self.m_node:FindDirect("Title_SysChatBtn/Tap_Help/Label_Now"):GetComponent("UILabel"):set_text(textRes.Chat.Tab[3])
  self.m_node:FindDirect("Title_SysChatBtn/Tap_Personal/Label_World"):GetComponent("UILabel"):set_text(textRes.Chat.Tab[4])
end
def.override(ECPanelBase, "userdata").Init = function(self, base, node)
  TabNode.Init(self, base, node)
  self.channelTitle = self.m_node:FindDirect("Title_ChannelChatBtn")
  self.channelTabs = {}
  table.insert(self.channelTabs, self.channelTitle:FindDirect("Tap_Faction"))
  table.insert(self.channelTabs, self.channelTitle:FindDirect("Tap_Team"))
  table.insert(self.channelTabs, self.channelTitle:FindDirect("Tap_Now"))
  table.insert(self.channelTabs, self.channelTitle:FindDirect("Tap_World"))
  self.friendTitle = self.m_node:FindDirect("Title_FriendChatBtn")
  self.systemTitle = self.m_node:FindDirect("Title_SysChatBtn")
  self.systemTabs = {}
  table.insert(self.systemTabs, self.systemTitle:FindDirect("Tap_All"))
  table.insert(self.systemTabs, self.systemTitle:FindDirect("Tap_Sys"))
  table.insert(self.systemTabs, self.systemTitle:FindDirect("Tap_Help"))
  table.insert(self.systemTabs, self.systemTitle:FindDirect("Tap_Personal"))
  self.input = self.m_node:FindDirect("Img_BgChatInput")
  self.noInput = self.m_node:FindDirect("Img_BgChatNoInput")
  self.chatContent = self.m_node:FindDirect("Panel_ChatContent/Scroll View_Chat/Table_Chat")
  self.newMsgBtn = self.m_node:FindDirect("Panel_ChatContent/Btn_New")
  self.chattable = self.chatContent:GetComponent("UITable")
  self.chattable.RecursiveCalcBounds = false
  self.scroll = self.m_node:FindDirect("Panel_ChatContent/Scroll View_Chat"):GetComponent("UIScrollView")
  local pool = self.m_node:FindDirect("Panel_ChatContent/pool")
  self.leftTemplate = pool:FindDirect("ChatLeft")
  self.rightTemplate = pool:FindDirect("ChatRight")
  self.noteTemplate = pool:FindDirect("SystemInfo")
  self.sysTemplate = pool:FindDirect("System")
  self.teamTemplate = pool:FindDirect("Img_BgTeam")
  self.timeTemplate = pool:FindDirect("ChatTime")
  pool:SetActive(false)
  self.pool = pool
  self.itemPool = {}
  self.itemPool.l = {}
  self.itemPool.r = {}
  self.itemPool.n = {}
  self.itemPool.s = {}
  self.itemPool.t = {}
  self.itemPool.m = {}
  self:RebuildPool()
  self.leftTemplate:SetActive(false)
  self.rightTemplate:SetActive(false)
  self.noteTemplate:SetActive(false)
  self.sysTemplate:SetActive(false)
  self.teamTemplate:SetActive(false)
  self.timeTemplate:SetActive(false)
  self.newMsgBtn:SetActive(false)
  self:ToggleInputState("input")
  self.State2ProtocolMap = {
    [SocialPanel.StateConst.Current] = ChatConst.CHANNEL_CURRENT,
    [SocialPanel.StateConst.World] = ChatConst.CHANNEL_WORLD,
    [SocialPanel.StateConst.Team] = ChatConst.CHANNEL_TEAM,
    [SocialPanel.StateConst.Newer] = ChatConst.CHANNEL_NEWER,
    [SocialPanel.StateConst.Faction] = ChatConst.CHANNEL_FACTION,
    [SocialPanel.StateConst.Activity] = ChatConst.CHANNEL_ACTIVITY
  }
end
def.method("number").SwitchState = function(self, state)
  if state == SocialPanel.StateConst.Current or state == SocialPanel.StateConst.World or state == SocialPanel.StateConst.Team or state == SocialPanel.StateConst.Faction or state == SocialPanel.StateConst.Newer or state == SocialPanel.StateConst.Activity then
    self.m_base.state = SocialPanel.StateConst.Chat
    self.m_base.subState[SocialPanel.StateConst.Chat] = state
  elseif state == SocialPanel.StateConst.All or state == SocialPanel.StateConst.Sys or state == SocialPanel.StateConst.Help or state == SocialPanel.StateConst.Personal then
    self.m_base.state = SocialPanel.StateConst.System
    self.m_base.subState[SocialPanel.StateConst.System] = state
  elseif state == SocialPanel.StateConst.FriendChat then
    self.m_base.state = SocialPanel.StateConst.Friend
    self.m_base.subState[SocialPanel.StateConst.Friend] = state
  end
  if self.isShow then
    self:UpdateMsg()
  end
end
local _infoPackMap = {}
def.method("string", "string").AddInfoPack = function(self, name, cipher)
  if not self.input:FindDirect("Img_BgInput"):get_activeInHierarchy() then
    return
  end
  local input = self.input:FindDirect("Img_BgInput"):GetComponent("UIInput")
  if not GUIUtils.CheckUIInput(input) then
    return
  end
  local ret = input:Insert(name, true)
  if ret > 0 then
    _infoPackMap[ret] = cipher
  else
    Toast(textRes.Chat[30])
  end
end
def.method("string").AddChatContent = function(self, content)
  if not self.input:FindDirect("Img_BgInput"):get_activeInHierarchy() then
    return
  end
  local input = self.input:FindDirect("Img_BgInput"):GetComponent("UIInput")
  if not GUIUtils.CheckUIInput(input) then
    return
  end
  input:Insert(content, false)
end
def.method("string").SetChatContent = function(self, content)
  if not self.input:FindDirect("Img_BgInput"):get_activeInHierarchy() then
    return
  end
  local input = self.input:FindDirect("Img_BgInput"):GetComponent("UIInput")
  input:set_value(content)
end
def.method("table").AddMsg = function(self, msg)
  if self:canAdd(msg) == false then
    return
  end
  local hasCnt = self.chatContent:get_childCount() > 0
  if msg.type == ChatMsgData.MsgType.FRIEND then
    if msg.time - self.lastMsgTime > 256 then
      self:InsertTime(msg.time)
    end
    self.lastMsgTime = msg.time
  end
  local newItem = self:_addOneMsg(msg, false)
  local dragAmountY = hasCnt and self.scroll:GetDragAmount().y or 0
  GameUtil.AddGlobalLateTimer(0.01, true, function()
    if dragAmountY < 0.1 then
      local removed = self:RemoveOldMsg()
      self.chattable:Reposition()
      local bvalid, minx, miny, minz, maxx, maxy, maxz = GameUtil.GetUITableTotalBounds(self.chattable)
      if bvalid then
        bmin:Set(minx, miny, minz)
        bmax:Set(maxx, maxy, maxz)
        self.scroll:SetOuterBounds(bmin, bmax)
      else
        self.scroll:ResetOuterBounds()
      end
      self.scroll:ResetPosition()
    else
      self.chattable:Reposition()
      local bvalid, minx, miny, minz, maxx, maxy, maxz = GameUtil.GetUITableTotalBounds(self.chattable)
      if bvalid then
        bmin:Set(minx, miny, minz)
        bmax:Set(maxx, maxy, maxz)
        self.scroll:SetOuterBounds(bmin, bmax)
      else
        self.scroll:ResetOuterBounds()
      end
      self.newMsgBtn:SetActive(true)
    end
  end)
end
def.method("table", "boolean").AddMsgBatch = function(self, msgs, inverse)
  if inverse then
    for i = 1, #msgs do
      local msg = msgs[i]
      if not msg.delete then
        local obj = self:_addOneMsg(msg, true)
        if msg.type == ChatMsgData.MsgType.FRIEND then
          local formerTime = msgs[i + 1] and msgs[i + 1].time or 0 or 0
          if msg.time - formerTime > 256 then
            local time = self:InsertTime(msg.time)
            time.transform:SetAsFirstSibling()
          end
        end
      end
    end
  else
    for i = #msgs, 1, -1 do
      local msg = msgs[i]
      if not msg.delete then
        if msg.type == ChatMsgData.MsgType.FRIEND then
          if 256 < msg.time - self.lastMsgTime then
            self:InsertTime(msg.time)
          end
          self.lastMsgTime = msg.time
        end
        local obj = self:_addOneMsg(msg, false)
      end
    end
  end
  GameUtil.AddGlobalLateTimer(0.01, true, function()
    local old_bvalid, old_minx, old_miny, old_minz, old_maxx, old_maxy, old_maxz = GameUtil.GetUITableTotalBounds(self.chattable)
    self.chattable:Reposition()
    local bvalid, minx, miny, minz, maxx, maxy, maxz = GameUtil.GetUITableTotalBounds(self.chattable)
    if bvalid then
      bmin:Set(minx, miny, minz)
      bmax:Set(maxx, maxy, maxz)
      self.scroll:SetOuterBounds(bmin, bmax)
    else
      self.scroll:ResetOuterBounds()
    end
    if not inverse then
      self.scroll:ResetPosition()
    else
      local movey = old_maxy - maxy + miny - old_miny
      local move = Vector.Vector3.new(0, movey, 0)
      self.scroll:stopScroll()
      self.scroll:MoveAbsolute(move)
    end
  end)
end
def.method("table", "boolean", "=>", "userdata")._addOneMsg = function(self, msg, inverse)
  local itemNew
  if msg.note then
    itemNew = self:GetFromPool("n")
    self.m_base.m_msgHandler:Touch(itemNew)
    itemNew.parent = self.chatContent
    itemNew.name = string.format("N_Unique_%d", msg.unique)
    itemNew:set_localScale(Vector.Vector3.one)
    self:FillNoteMsg(itemNew, msg)
    itemNew:SetActive(true)
  elseif msg.type == ChatMsgData.MsgType.FRIEND or msg.type == ChatMsgData.MsgType.CHANNEL then
    local heroProp = require("Main.Hero.Interface").GetHeroProp()
    if heroProp.id == msg.roleId then
      itemNew = self:GetFromPool("r")
      self.m_base.m_msgHandler:Touch(itemNew)
      itemNew.parent = self.chatContent
      itemNew.name = string.format("R_Unique_%d", msg.unique)
      itemNew:set_localScale(Vector.Vector3.one)
      self:FillChatMsg(itemNew, msg)
      itemNew:SetActive(true)
    else
      itemNew = self:GetFromPool("l")
      self.m_base.m_msgHandler:Touch(itemNew)
      itemNew.parent = self.chatContent
      itemNew.name = string.format("L_Unique_%d", msg.unique)
      itemNew:set_localScale(Vector.Vector3.one)
      self:FillChatMsg(itemNew, msg)
      itemNew:SetActive(true)
    end
    local img_text = itemNew:FindChildByPrefix("Img_Text")
    if img_text then
      img_text.name = string.format("Img_Text_%d", msg.unique)
      local Btn_Copy = itemNew:FindChildByPrefix("Btn_Copy")
      if Btn_Copy then
        Btn_Copy.name = string.format("Btn_Copy_%d", msg.unique)
      end
      local Btn_Delete = itemNew:FindChildByPrefix("Btn_Delete")
      if Btn_Delete then
        Btn_Delete.name = string.format("Btn_Delete_%d", msg.unique)
      end
    end
  elseif msg.type == ChatMsgData.MsgType.SYSTEM then
    itemNew = self:GetFromPool("s")
    self.m_base.m_msgHandler:Touch(itemNew)
    itemNew.parent = self.chatContent
    itemNew.name = string.format("S_Unique_%d", msg.unique)
    itemNew:set_localScale(Vector.Vector3.one)
    self:FillSysMsg(itemNew, msg)
    itemNew:SetActive(true)
  end
  if inverse then
    itemNew.transform:SetAsFirstSibling()
  end
  return itemNew
end
def.method().ClearMsgOperation = function(self)
  print("ClearMsgOperation", self.curOperation)
  local curItem = self.chatContent:FindDirect(string.format("L_Unique_%d", self.curOperation)) or self.chatContent:FindDirect(string.format("R_Unique_%d", self.curOperation))
  if curItem ~= nil then
    local Btn_Copy = curItem:FindDirect(string.format("Btn_Copy_%d", self.curOperation))
    local Btn_Delete = curItem:FindDirect(string.format("Btn_Delete_%d", self.curOperation))
    Btn_Copy:SetActive(false)
    Btn_Delete:SetActive(false)
    self.curOperation = 0
  end
  local curPaste = self.input:FindDirect("Img_BgInput/Btn_Paste")
  if curPaste ~= nil then
    curPaste:SetActive(false)
  end
end
def.override().OnShow = function(self)
  self.lastMsgTime = 0
  Event.RegisterEvent(ModuleId.FRIEND, gmodule.notifyId.Friend.Friend_OnFriendAdd, ChatNode.OnFriendAdd)
  Event.RegisterEvent(ModuleId.FRIEND, gmodule.notifyId.Friend.Friend_OnFriendNameChanged, ChatNode.OnChatNameChange)
  Event.RegisterEvent(ModuleId.CHAT, gmodule.notifyId.Chat.Cache_Name_Change, ChatNode.OnChatNameChange)
  print("ChatNode OnShow")
end
def.override().OnHide = function(self)
  Event.UnregisterEvent(ModuleId.FRIEND, gmodule.notifyId.Friend.Friend_OnFriendAdd, ChatNode.OnFriendAdd)
  Event.UnregisterEvent(ModuleId.FRIEND, gmodule.notifyId.Friend.Friend_OnFriendNameChanged, ChatNode.OnChatNameChange)
  Event.UnregisterEvent(ModuleId.CHAT, gmodule.notifyId.Chat.Cache_Name_Change, ChatNode.OnChatNameChange)
end
def.static("table", "table").OnFriendAdd = function(p1, p2)
  local roleId = p1[1]
  if roleId == ChatModule.Instance().curChatId then
    SocialPanel.Instance():UpdateChatMsg()
  end
end
def.static("table", "table").OnChatNameChange = function(p1, p2)
  local roleId = p1.roleId
  local roleName = p1.roleName
  warn("OnChatNameChange", roleId, roleName)
  if roleId == ChatModule.Instance().curChatId then
    ChatModule.Instance().curChatName = roleName
    SocialPanel.Instance():RefreshPrivateChatName()
  end
end
def.override("string").onClick = function(self, id)
  if string.find(id, "Img_Head_") then
    local indexStr = string.sub(id, 10)
    local roleId = Int64.new(indexStr)
    local myId = _G.GetMyRoleID()
    if roleId ~= myId then
      local state = FriendCommonDlgManager.StateConst.Null
      if self.m_base.state == SocialPanel.StateConst.Chat and self.m_base.subState[SocialPanel.StateConst.Chat] == SocialPanel.StateConst.Faction then
        state = FriendCommonDlgManager.StateConst.GangChat
      else
        state = FriendCommonDlgManager.StateConst.OtherChat
      end
      FriendCommonDlgManager.ApplyShowFriendCommonDlg(roleId, state)
    end
  elseif id == "Btn_Speak" then
    self:ToggleInputState("speak")
  elseif id == "Btn_Input" then
    self:ToggleInputState("input")
  elseif id == "Btn_Clear" then
    local input = self.input:FindDirect("Img_BgInput"):GetComponent("UIInput")
    input:set_value("")
  elseif id == "Btn_Send" then
    self:SubmitContent(true)
  elseif id == "Btn_Add" then
    self:ToggleInputState("input")
    ChatInputDlg.ShowChatInputDlg(ChatInputDlg.Type.Chat)
  elseif id == "Btn_Preset" then
    local PresetDlg = require("Main.Chat.ui.ChatPresetDlg")
    PresetDlg.ShowChatPreset(function(sentence)
      self:SubmitContent2(sentence, false)
    end)
  elseif id == "Tap_Faction" then
    if GangModule.Instance():HasGang() then
      self:SwitchState(SocialPanel.StateConst.Faction)
    else
      self:SwitchState(SocialPanel.StateConst.Newer)
    end
  elseif id == "Tap_Team" then
    self:SwitchState(SocialPanel.StateConst.Team)
  elseif id == "Tap_Now" then
    do break end
    self:SwitchState(SocialPanel.StateConst.Activity)
    do break end
    self:SwitchState(SocialPanel.StateConst.Current)
  elseif id == "Tap_World" then
    self:SwitchState(SocialPanel.StateConst.World)
  elseif id == "Tap_All" then
    self:SwitchState(SocialPanel.StateConst.All)
  elseif id == "Tap_Sys" then
    self:SwitchState(SocialPanel.StateConst.Sys)
  elseif id == "Tap_Help" then
    self:SwitchState(SocialPanel.StateConst.Help)
  elseif id == "Tap_Personal" then
    self:SwitchState(SocialPanel.StateConst.Personal)
  elseif id == "Btn_ChatSetting" then
    local ChatSetting = require("Main.Chat.ui.ChatSettingDlg")
    local settingDlg = ChatSetting()
    settingDlg:CreatePanel(RESPATH.PREFAB_CHAT_SETTING, 2)
  elseif id == "Btn_FriendClear" then
    self:ClearMsg()
    ChatMsgData.Instance():ClearMsg64(ChatMsgData.MsgType.FRIEND, ChatModule.Instance().curChatId)
    Event.DispatchEvent(ModuleId.CHAT, gmodule.notifyId.Chat.UpdateFirendMsg, {
      roleId = ChatModule.Instance().curChatId,
      new = -1
    })
  elseif id == "Btn_FriendBack" then
    ChatModule.Instance().curChatId = Int64.new(0)
    ChatModule.Instance().curChatName = ""
    SocialPanel.Instance():SwitchTo(SocialPanel.NodeId.FRIENDNODE)
    SocialPanel.Instance():UpdateFriendList()
  elseif id == "Btn_Left" then
    self:ToggleChannel(false)
  elseif id == "Btn_Right" then
    self:ToggleChannel(true)
  elseif id == "Btn_New" then
    local old = self:RemoveOldMsg()
    if old > 0 then
      self.chattable:Reposition()
      local bvalid, minx, miny, minz, maxx, maxy, maxz = GameUtil.GetUITableTotalBounds(self.chattable)
      if bvalid then
        bmin:Set(minx, miny, minz)
        bmax:Set(maxx, maxy, maxz)
        self.scroll:SetOuterBounds(bmin, bmax)
      else
        self.scroll:ResetOuterBounds()
      end
    end
    self.scroll:ResetPosition()
    self.newMsgBtn:SetActive(false)
  elseif string.find(id, "Img_Text_") then
    local unique = tonumber(string.sub(id, 10))
    local chatItem = self.chatContent:FindDirect(string.format("L_Unique_%d", unique)) or self.chatContent:FindDirect(string.format("R_Unique_%d", unique))
    if chatItem then
      local html = chatItem:FindDirect("Html_Text")
      local voiceObj = GameObject.FindChildByPrefix(html, "voice_", false)
      if voiceObj then
        GameObject.SendMessage(voiceObj, "OnVoiceButtonClick", voiceObj, 0)
        local voiceId = tonumber(string.sub(voiceObj.name, 7))
        if voiceId then
          SpeechMgr.Instance():DownloadAndPlay(voiceId, nil)
        end
      end
    end
  elseif string.find(id, "voice_") then
    local index = tonumber(string.sub(id, 7))
    SpeechMgr.Instance():DownloadAndPlay(index, nil)
  elseif string.find(id, "question_") then
    require("Main.Question.QuestionModule").Instance():AnswerGangHelp(id)
  elseif string.find(id, "qyxt_") then
    require("Main.Question.EveryNightQuestionModule").Instance():AnswerGangHelp(id)
  elseif string.find(id, "btn_") then
    print("Button click in chat")
    Event.DispatchEvent(ModuleId.CHAT, gmodule.notifyId.Chat.BtnClickInChat, {
      id = string.sub(id, 5)
    })
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
  elseif string.find(id)("fashion_") then
    ChatModule.Instance():RequestInfoPack(id)
  elseif string.find(id, "wedding_") then
    require("Main.Marriage.MarriageInterface").JoinWedding(id)
  elseif string.find(id, "redpacket_") then
    require("Main.Marriage.MarriageInterface").SendRedPacket(id, ChatModule.Instance().curChatName)
  elseif string.find(id, "Btn_Delete_") then
    local unique = tonumber(string.sub(id, 12))
    ChatMsgData.Instance():DeleteUniqueMsg(unique)
    self:UpdateMsg()
  elseif string.find(id, "Btn_Copy_") then
    local unique = tonumber(string.sub(id, 10))
    require("Main.Chat.ChatMemo").Instance():CopyOneByUniqueId(unique)
    self:ClearMsgOperation()
  elseif id == "Btn_Paste" then
    local content = require("Main.Chat.ChatMemo").Instance():GetClipBoard()
    self:AddChatContent(content)
    self:ClearMsgOperation()
  elseif string.find(id, "Btn_Join_") then
    local index = string.sub(id, 10)
    Event.DispatchEvent(ModuleId.CHAT, gmodule.notifyId.Chat.Chat_Apply_Team, {index})
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
  elseif id == "addstranger" then
    require("Main.friend.FriendModule").AddFriendOrDeleteFriend(ChatModule.Instance().curChatId, ChatModule.Instance().curChatName)
  elseif id == "blockstanger" then
    require("Main.friend.FriendModule").AddShield(ChatModule.Instance().curChatId, ChatModule.Instance().curChatName)
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
  elseif string.find(id, "mounts_") then
    ChatModule.Instance():RequestInfoPack(id)
  end
end
def.override("string").onLongPress = function(self, id)
  if string.find(id, "Img_Text_") then
    local unique = tonumber(string.sub(id, 10))
    local chatItem = self.chatContent:FindDirect(string.format("L_Unique_%d", unique)) or self.chatContent:FindDirect(string.format("R_Unique_%d", unique))
    if chatItem then
      local Btn_Copy = chatItem:FindDirect(string.format("Btn_Copy_%d", unique))
      local Btn_Delete = chatItem:FindDirect(string.format("Btn_Delete_%d", unique))
      Btn_Copy:SetActive(true)
      Btn_Delete:SetActive(true)
      self.curOperation = unique
    end
  elseif id == "Img_BgInput" then
    local content = require("Main.Chat.ChatMemo").Instance():GetClipBoard()
    if content and content ~= "" then
      local curPaste = self.input:FindDirect("Img_BgInput/Btn_Paste")
      if curPaste ~= nil then
        curPaste:SetActive(true)
      end
    end
  end
end
def.override("string", "userdata").onSubmit = function(self, id, ctrl)
  if id == "Img_BgInput" then
    self:SubmitContent(true)
  end
end
def.override("string", "boolean").onPress = function(self, id, state)
  if id == "Img_BgSpeak" then
    if state then
      self.doSpeech = true
      self.inSpeech = true
      SpeechMgr.Instance():StartSpeech()
    else
      if self.doSpeech then
        if self.inSpeech then
          if self.m_base.state == SocialPanel.StateConst.Friend and self.m_base.subState[SocialPanel.StateConst.Friend] == SocialPanel.StateConst.FriendChat then
            SpeechMgr.Instance():SetRole(true)
          else
            SpeechMgr.Instance():SetChannel(self.State2ProtocolMap[self.m_base.subState[self.m_base.state]])
          end
          SpeechMgr.Instance():EndSpeech()
        else
          SpeechMgr.Instance():CancelSpeech()
        end
      end
      self.doSpeech = false
      self.inSpeech = false
    end
  end
end
def.override("string", "userdata").onDragOut = function(self, id, go)
  if self.doSpeech then
    local press = UICamera.IsHighlighted(go)
    if press == true then
      self.inSpeech = true
      SpeechMgr.Instance():Pause(false)
    else
      self.inSpeech = false
      SpeechMgr.Instance():Pause(true)
    end
  end
end
def.override("string", "userdata").onDragOver = function(self, id, go)
  if id == "Img_BgSpeak" and self.doSpeech then
    self.inSpeech = true
    SpeechMgr.Instance():Pause(false)
  end
end
def.override("string").onDragEnd = function(self, id)
  if string.find(id, "_Unique_") or string.find(id, "Img_Text_") or id == "Html_Text" or string.find(id, "Img_Head_") or id == "Time" or id == "Img_Bg" or string.find(id, "Team_") or string.find(id, "btn_join") then
    local dragAmount = self.scroll:GetDragAmount()
    if dragAmount.y < -0.01 then
      self:RemoveOldMsg()
      self.chattable:Reposition()
      local bvalid, minx, miny, minz, maxx, maxy, maxz = GameUtil.GetUITableTotalBounds(self.chattable)
      if bvalid then
        bmin:Set(minx, miny, minz)
        bmax:Set(maxx, maxy, maxz)
        self.scroll:SetOuterBounds(bmin, bmax)
      else
        self.scroll:ResetOuterBounds()
      end
    elseif dragAmount.y > 1.01 then
      self:AddOldMsg()
    end
  end
end
def.override("string", "userdata", "number", "table").onSpringFinish = function(self, id, scrollView, type, position)
  if type == 2 then
    local scroll = scrollView:GetComponent("UIScrollView")
    local amount = scroll:GetDragAmount()
    if amount.y < 0.01 then
      self.newMsgBtn:SetActive(false)
    end
  end
end
def.method("string", "=>", "string").GetInfoPack = function(self, cnt)
  local hasInfoPackStr = string.gsub(cnt, "[\001-\a]", function(str)
    local infoStr = _infoPackMap[str:byte(1)]
    if infoStr then
      return infoStr
    else
      return ""
    end
  end)
  return hasInfoPackStr
end
def.method("string", "boolean").SubmitContent2 = function(self, cnt, record)
  local input = self.input:FindDirect("Img_BgInput"):GetComponent("UIInput")
  local content = cnt
  content = self:GetInfoPack(content)
  content = ChatUtils.FilterHtmlTag(content)
  require("Utility/Utf8Helper")
  content = _G.TrimIllegalChar(content)
  content = ChatUtils.ChatContentTrim(content)
  if require("Main.ECGame").Instance():OpenGM(content) then
    input:set_value("")
    return
  end
  if self.canChat == false then
    Toast(textRes.Chat[3])
    return
  end
  if content == nil or content == "" then
    local note = textRes.Chat[4]
    Toast(note)
    input:set_value("")
    return
  end
  if record then
    require("Main.Chat.ChatMemo").Instance():AddMemo(content)
  end
  if self.m_base.state == SocialPanel.StateConst.Friend and self.m_base.subState[SocialPanel.StateConst.Friend] == SocialPanel.StateConst.FriendChat then
    ChatModule.Instance():SendPrivateMsg(content, false)
    self.canChat = false
    GameUtil.AddGlobalTimer(1, true, function()
      self.canChat = true
    end)
    input:set_value("")
    return
  end
  if self.m_base.subState[SocialPanel.StateConst.Chat] == SocialPanel.StateConst.Team then
    local TeamData = require("Main.Team.TeamData")
    print("TeamChat", TeamData.Instance():HasTeam())
    if TeamData.Instance():HasTeam() == false then
      local note = textRes.Chat[5]
      Toast(note)
      return
    end
  end
  if ChatModule.Instance():SendChannelMsg(content, self.State2ProtocolMap[self.m_base.subState[self.m_base.state]], false) then
    input:set_value("")
    self.canChat = false
    GameUtil.AddGlobalTimer(1, true, function()
      self.canChat = true
    end)
  end
end
def.method("boolean").SubmitContent = function(self, record)
  local input = self.input:FindDirect("Img_BgInput"):GetComponent("UIInput")
  local content = input:get_value()
  self:SubmitContent2(content, record)
end
def.method().DeleteCharactor = function(self)
  local input = self.input:FindDirect("Img_BgInput"):GetComponent("UIInput")
  local text = input:get_value()
  input:set_value(string.sub(text, 1, string.len(text) - 1))
end
def.method().FocusOnInput = function(self)
  local input = self.input:FindDirect("Img_BgInput"):GetComponent("UIInput")
  input:set_isSelected(true)
end
def.method().UpdateTab = function(self)
  local faction = self.channelTitle:FindDirect("Tap_Faction/Label_Faction"):GetComponent("UILabel")
  if GangModule.Instance():HasGang() then
    faction:set_text(textRes.Chat[6])
  else
    faction:set_text(textRes.Chat[7])
  end
  local now = self.channelTitle:FindDirect("Tap_Now/Label_Now"):GetComponent("UILabel")
  do break end
  now:set_text(textRes.Chat[8])
  do break end
  now:set_text(textRes.Chat[9])
end
def.method().UpdateMsg = function(self)
  self:UpdateTab()
  self:ClearMsg()
  local subState = self.m_base.subState[self.m_base.state]
  if subState == SocialPanel.StateConst.Current then
    self.channelTitle:SetActive(true)
    local curToggle = self.channelTitle:FindDirect("Tap_Now"):GetComponent("UIToggle")
    curToggle:set_value(true)
    self.friendTitle:SetActive(false)
    self.systemTitle:SetActive(false)
    self.input:SetActive(true)
    self.noInput:SetActive(false)
    local msgs = ChatMsgData.Instance():GetMsg(ChatMsgData.MsgType.CHANNEL, ChatMsgData.Channel.CURRENT, ChatNode.MAXCHAT)
    if #msgs > 0 then
      self:AddMsgBatch(msgs, false)
    end
  elseif subState == SocialPanel.StateConst.Activity then
    self.channelTitle:SetActive(true)
    local curToggle = self.channelTitle:FindDirect("Tap_Now"):GetComponent("UIToggle")
    curToggle:set_value(true)
    self.friendTitle:SetActive(false)
    self.systemTitle:SetActive(false)
    self.input:SetActive(true)
    self.noInput:SetActive(false)
    local msgs = ChatMsgData.Instance():GetMsg(ChatMsgData.MsgType.CHANNEL, ChatMsgData.Channel.ACTIVITY, ChatNode.MAXCHAT)
    if #msgs > 0 then
      self:AddMsgBatch(msgs, false)
    end
  elseif subState == SocialPanel.StateConst.Faction then
    self.channelTitle:SetActive(true)
    local curToggle = self.channelTitle:FindDirect("Tap_Faction"):GetComponent("UIToggle")
    curToggle:set_value(true)
    self.friendTitle:SetActive(false)
    self.systemTitle:SetActive(false)
    self.input:SetActive(true)
    self.noInput:SetActive(false)
    local msgs = ChatMsgData.Instance():GetMsg(ChatMsgData.MsgType.CHANNEL, ChatMsgData.Channel.FACTION, ChatNode.MAXCHAT)
    if #msgs > 0 then
      self:AddMsgBatch(msgs, false)
    end
  elseif subState == SocialPanel.StateConst.Newer then
    self.channelTitle:SetActive(true)
    local curToggle = self.channelTitle:FindDirect("Tap_Faction"):GetComponent("UIToggle")
    curToggle:set_value(true)
    self.friendTitle:SetActive(false)
    self.systemTitle:SetActive(false)
    self.input:SetActive(true)
    self.noInput:SetActive(false)
    local msgs = ChatMsgData.Instance():GetMsg(ChatMsgData.MsgType.CHANNEL, ChatMsgData.Channel.NEWER, ChatNode.MAXCHAT)
    if #msgs > 0 then
      self:AddMsgBatch(msgs, false)
    end
  elseif subState == SocialPanel.StateConst.Team then
    self.channelTitle:SetActive(true)
    local curToggle = self.channelTitle:FindDirect("Tap_Team"):GetComponent("UIToggle")
    curToggle:set_value(true)
    self.friendTitle:SetActive(false)
    self.systemTitle:SetActive(false)
    self.input:SetActive(true)
    self.noInput:SetActive(false)
    local msgs = ChatMsgData.Instance():GetMsg(ChatMsgData.MsgType.CHANNEL, ChatMsgData.Channel.TEAM, ChatNode.MAXCHAT)
    if #msgs > 0 then
      self:AddMsgBatch(msgs, false)
    end
    if not require("Main.Team.TeamData").Instance():HasTeam() then
      self:AddTeamBatch()
      if #msgs == 0 then
        self:RefreshChat()
      end
    end
  elseif subState == SocialPanel.StateConst.World then
    self.channelTitle:SetActive(true)
    local curToggle = self.channelTitle:FindDirect("Tap_World"):GetComponent("UIToggle")
    curToggle:set_value(true)
    self.friendTitle:SetActive(false)
    self.systemTitle:SetActive(false)
    self.input:SetActive(true)
    self.noInput:SetActive(false)
    local msgs = ChatMsgData.Instance():GetMsg(ChatMsgData.MsgType.CHANNEL, ChatMsgData.Channel.WORLD, ChatNode.MAXCHAT)
    if #msgs > 0 then
      self:AddMsgBatch(msgs, false)
    end
  elseif subState == SocialPanel.StateConst.All then
    self.channelTitle:SetActive(false)
    self.friendTitle:SetActive(false)
    self.systemTitle:SetActive(true)
    local curToggle = self.systemTitle:FindDirect("Tap_All"):GetComponent("UIToggle")
    curToggle:set_value(true)
    self.input:SetActive(false)
    self.noInput:SetActive(true)
    local msgs = ChatMsgData.Instance():GetMsg(ChatMsgData.MsgType.SYSTEM, ChatMsgData.System.ALL, ChatNode.MAXCHAT)
    if #msgs > 0 then
      self:AddMsgBatch(msgs, false)
    end
  elseif subState == SocialPanel.StateConst.Sys then
    self.channelTitle:SetActive(false)
    self.friendTitle:SetActive(false)
    self.systemTitle:SetActive(true)
    local curToggle = self.systemTitle:FindDirect("Tap_Sys"):GetComponent("UIToggle")
    curToggle:set_value(true)
    self.input:SetActive(false)
    self.noInput:SetActive(true)
    local msgs = ChatMsgData.Instance():GetMsg(ChatMsgData.MsgType.SYSTEM, ChatMsgData.System.SYS, ChatNode.MAXCHAT)
    if #msgs > 0 then
      self:AddMsgBatch(msgs, false)
    end
  elseif subState == SocialPanel.StateConst.Help then
    self.channelTitle:SetActive(false)
    self.friendTitle:SetActive(false)
    self.systemTitle:SetActive(true)
    local curToggle = self.systemTitle:FindDirect("Tap_Help"):GetComponent("UIToggle")
    curToggle:set_value(true)
    self.input:SetActive(false)
    self.noInput:SetActive(true)
    local msgs = ChatMsgData.Instance():GetMsg(ChatMsgData.MsgType.SYSTEM, ChatMsgData.System.HELP, ChatNode.MAXCHAT)
    if #msgs > 0 then
      self:AddMsgBatch(msgs, false)
    end
  elseif subState == SocialPanel.StateConst.Personal then
    self.channelTitle:SetActive(false)
    self.friendTitle:SetActive(false)
    self.systemTitle:SetActive(true)
    local curToggle = self.systemTitle:FindDirect("Tap_Personal"):GetComponent("UIToggle")
    curToggle:set_value(true)
    self.input:SetActive(false)
    self.noInput:SetActive(true)
    local msgs = ChatMsgData.Instance():GetMsg(ChatMsgData.MsgType.SYSTEM, ChatMsgData.System.PERSONAL, ChatNode.MAXCHAT)
    if #msgs > 0 then
      self:AddMsgBatch(msgs, false)
    end
  elseif subState == SocialPanel.StateConst.FriendChat then
    self.channelTitle:SetActive(false)
    self.friendTitle:SetActive(true)
    self.systemTitle:SetActive(false)
    self.input:SetActive(true)
    self.noInput:SetActive(false)
    self:SetPrivateChatTitle()
    local msgs = ChatMsgData.Instance():GetMsg64(ChatMsgData.MsgType.FRIEND, ChatModule.Instance().curChatId, ChatNode.MAXCHAT)
    if #msgs > 0 then
      self:AddMsgBatch(msgs, false)
    end
    local friend = require("Main.friend.FriendData").Instance():GetFriendInfo(ChatModule.Instance().curChatId)
    if not friend then
      self:AddStangerNotice()
      if #msgs == 0 then
        self:RefreshChat()
      end
    end
  end
end
def.method().AddOldMsg = function(self)
  local subState = self.m_base.subState[self.m_base.state]
  local unique = self:GetOldestUnique()
  if subState == SocialPanel.StateConst.Current then
    local msgs = ChatMsgData.Instance():GetOldMsg(ChatMsgData.MsgType.CHANNEL, ChatMsgData.Channel.CURRENT, unique, ChatNode.ADDONCE)
    if #msgs > 0 then
      self:AddMsgBatch(msgs, true)
    end
  elseif subState == SocialPanel.StateConst.Activity then
    local msgs = ChatMsgData.Instance():GetOldMsg(ChatMsgData.MsgType.CHANNEL, ChatMsgData.Channel.ACTIVITY, unique, ChatNode.ADDONCE)
    if #msgs > 0 then
      self:AddMsgBatch(msgs, true)
    end
  elseif subState == SocialPanel.StateConst.Faction then
    local msgs = ChatMsgData.Instance():GetOldMsg(ChatMsgData.MsgType.CHANNEL, ChatMsgData.Channel.FACTION, unique, ChatNode.ADDONCE)
    if #msgs > 0 then
      self:AddMsgBatch(msgs, true)
    end
  elseif subState == SocialPanel.StateConst.Newer then
    local msgs = ChatMsgData.Instance():GetOldMsg(ChatMsgData.MsgType.CHANNEL, ChatMsgData.Channel.NEWER, unique, ChatNode.ADDONCE)
    if #msgs > 0 then
      self:AddMsgBatch(msgs, true)
    end
  elseif subState == SocialPanel.StateConst.Team then
    local msgs = ChatMsgData.Instance():GetOldMsg(ChatMsgData.MsgType.CHANNEL, ChatMsgData.Channel.TEAM, unique, ChatNode.ADDONCE)
    if #msgs > 0 then
      self:AddMsgBatch(msgs, true)
    end
  elseif subState == SocialPanel.StateConst.World then
    local msgs = ChatMsgData.Instance():GetOldMsg(ChatMsgData.MsgType.CHANNEL, ChatMsgData.Channel.WORLD, unique, ChatNode.ADDONCE)
    if #msgs > 0 then
      self:AddMsgBatch(msgs, true)
    end
  elseif subState == SocialPanel.StateConst.All then
    local msgs = ChatMsgData.Instance():GetOldMsg(ChatMsgData.MsgType.SYSTEM, ChatMsgData.System.ALL, unique, ChatNode.ADDONCE)
    if #msgs > 0 then
      self:AddMsgBatch(msgs, true)
    end
  elseif subState == SocialPanel.StateConst.Sys then
    local msgs = ChatMsgData.Instance():GetOldMsg(ChatMsgData.MsgType.SYSTEM, ChatMsgData.System.SYS, unique, ChatNode.ADDONCE)
    if #msgs > 0 then
      self:AddMsgBatch(msgs, true)
    end
  elseif subState == SocialPanel.StateConst.Help then
    local msgs = ChatMsgData.Instance():GetOldMsg(ChatMsgData.MsgType.SYSTEM, ChatMsgData.System.HELP, unique, ChatNode.ADDONCE)
    if #msgs > 0 then
      self:AddMsgBatch(msgs, true)
    end
  elseif subState == SocialPanel.StateConst.Personal then
    local msgs = ChatMsgData.Instance():GetOldMsg(ChatMsgData.MsgType.SYSTEM, ChatMsgData.System.PERSONAL, unique, ChatNode.ADDONCE)
    if #msgs > 0 then
      self:AddMsgBatch(msgs, true)
    end
  elseif subState == SocialPanel.StateConst.FriendChat then
    local msgs = ChatMsgData.Instance():GetOldMsg64(ChatMsgData.MsgType.FRIEND, ChatModule.Instance().curChatId, unique, ChatNode.ADDONCE)
    if #msgs > 0 then
      self:AddMsgBatch(msgs, true)
    end
  end
end
def.method("=>", "number").RemoveOldMsg = function(self)
  local oldCount = self.chatContent:get_childCount() - ChatNode.MAXCHAT
  local deleteCount = oldCount
  if oldCount > 0 then
    local toBeDeleted = {}
    local pig = self.chatContent:GetChild(oldCount - 1)
    if pig.name ~= "Time" and string.sub(pig.name, 1, 5) ~= "Team_" then
      table.insert(toBeDeleted, pig)
    end
    for i = oldCount - 2, 0, -1 do
      local pig = self.chatContent:GetChild(i)
      if string.sub(pig.name, 1, 5) ~= "Team_" then
        table.insert(toBeDeleted, pig)
      end
    end
    for k, pig in ipairs(toBeDeleted) do
      self:BackToPool(pig)
    end
    deleteCount = #toBeDeleted
  end
  return deleteCount
end
def.method("=>", "number").GetOldestUnique = function(self)
  local count = self.chatContent:get_childCount()
  if count > 0 then
    for i = 0, count - 1 do
      local old = self.chatContent:GetChild(i)
      if string.sub(old.name, 3, 9) == "Unique_" then
        local uni = tonumber(string.sub(old.name, 10))
        return uni or 0
      end
    end
  end
  return 0
end
def.method().SetPrivateChatTitle = function(self)
  local nameLabel = self.friendTitle:FindDirect("Label_ChatName"):GetComponent("UILabel")
  nameLabel:set_text(ChatModule.Instance().curChatName)
  local friendNum = require("Main.friend.FriendModule").Instance():GetAllFriendCount() or 0
  self:SetNewMsgCount(friendNum)
end
def.method("number").SetNewMsgCount = function(self, count)
  local backBtn = self.friendTitle:FindDirect("Btn_FriendBack/Label_ChatBack")
  local backLabel = backBtn:GetComponent("UILabel")
  if count > 0 then
    backLabel:set_text(textRes.Chat[25] .. string.format(textRes.Chat[26], count))
  else
    backLabel:set_text(textRes.Chat[25])
  end
end
def.method("string").ToggleInputState = function(self, type)
  local btnInput = self.input:FindDirect("Btn_Input")
  local btnSpeak = self.input:FindDirect("Btn_Speak")
  local input = self.input:FindDirect("Img_BgInput")
  local speak = self.input:FindDirect("Img_BgSpeak")
  if type == "input" then
    btnInput:SetActive(false)
    input:SetActive(true)
    btnSpeak:SetActive(true)
    speak:SetActive(false)
  elseif type == "speak" then
    btnInput:SetActive(true)
    input:SetActive(false)
    btnSpeak:SetActive(false)
    speak:SetActive(true)
  end
end
def.method().ClearMsg = function(self)
  local count = self.chatContent:get_childCount()
  for i = count - 1, 0, -1 do
    local child = self.chatContent:GetChild(i)
    self:BackToPool(child)
  end
end
def.method("table", "=>", "boolean").canAdd = function(self, msg)
  local subState = self.m_base.subState[self.m_base.state]
  print("canAdd", msg.id, subState)
  if msg.type == ChatMsgData.MsgType.CHANNEL and msg.id == ChatMsgData.Channel.CURRENT and subState == SocialPanel.StateConst.Current then
    return true
  elseif msg.type == ChatMsgData.MsgType.CHANNEL and msg.id == ChatMsgData.Channel.TEAM and subState == SocialPanel.StateConst.Team then
    return true
  elseif msg.type == ChatMsgData.MsgType.CHANNEL and msg.id == ChatMsgData.Channel.WORLD and subState == SocialPanel.StateConst.World then
    return true
  elseif msg.type == ChatMsgData.MsgType.CHANNEL and msg.id == ChatMsgData.Channel.NEWER and subState == SocialPanel.StateConst.Newer then
    return true
  elseif msg.type == ChatMsgData.MsgType.CHANNEL and msg.id == ChatMsgData.Channel.FACTION and subState == SocialPanel.StateConst.Faction then
    return true
  elseif msg.type == ChatMsgData.MsgType.CHANNEL and msg.id == ChatMsgData.Channel.ACTIVITY and subState == SocialPanel.StateConst.Activity then
    return true
  elseif msg.type == ChatMsgData.MsgType.SYSTEM and msg.id == ChatMsgData.Channel.SYS and subState == SocialPanel.StateConst.Sys then
    return true
  elseif msg.type == ChatMsgData.MsgType.SYSTEM and msg.id == ChatMsgData.Channel.HELP and subState == SocialPanel.StateConst.Help then
    return true
  elseif msg.type == ChatMsgData.MsgType.SYSTEM and msg.id == ChatMsgData.Channel.PERSONAL and subState == SocialPanel.StateConst.Personal then
    return true
  elseif msg.type == ChatMsgData.MsgType.SYSTEM and subState == SocialPanel.StateConst.All then
    return true
  elseif msg.type == ChatMsgData.MsgType.FRIEND and ChatModule.Instance().curChatId == msg.id and subState == SocialPanel.StateConst.FriendChat then
    return true
  else
    return false
  end
end
def.method("userdata", "table").FillChatMsg = function(self, obj, msg)
  if self:IsWorldQuestionMsg(msg) then
    self:FillWorldQuestion(obj, msg)
  else
    self:FillNormalChat(obj, msg)
  end
end
def.method("table", "=>", "boolean").IsWorldQuestionMsg = function(self, msg)
  return msg.type == ChatMsgData.MsgType.CHANNEL and msg.id == ChatMsgData.Channel.WORLD and msg.roleId == 1
end
def.method("userdata", "table").FillWorldQuestion = function(self, obj, msg)
  local html = obj:FindDirect("Html_Text"):GetComponent("NGUIHTML")
  html:ForceHtmlText(msg.plainHtml)
  local head = obj:FindChildByPrefix("Img_Head")
  if head then
    local lv = head:FindDirect("Label_Lv"):GetComponent("UILabel")
    lv:set_text("")
    _G.SetAvatarIcon(head)
    local headTexture = head:GetComponent("UITexture")
    GUIUtils.FillIcon(headTexture, msg.publishIcon)
  end
  local name = obj:FindDirect("Label_Name"):GetComponent("UILabel")
  name:set_text(msg.roleName)
  for i = 1, 2 do
    local badgeSprite = obj:FindDirect("Img_Badge" .. i)
    badgeSprite:SetActive(false)
  end
end
def.method("userdata", "table").FillNormalChat = function(self, obj, msg)
  local html = obj:FindDirect("Html_Text"):GetComponent("NGUIHTML")
  html:ForceHtmlText(msg.plainHtml)
  local head = obj:FindChildByPrefix("Img_Head")
  if head then
    local lv = head:FindDirect("Label_Lv"):GetComponent("UILabel")
    lv:set_text(msg.level)
    local headSprite = head:GetComponent("UISprite")
    headSprite:set_spriteName(GUIUtils.GetHeadSpriteNameNoBound(msg.occupationId, msg.gender))
    head.name = "Img_Head_" .. msg.roleId:tostring()
  end
  local name = obj:FindDirect("Label_Name"):GetComponent("UILabel")
  if msg.isCaptain then
    name:set_text(msg.roleName .. textRes.Chat[2])
  elseif msg.position then
    local GangData = require("Main.Gang.data.GangData").Instance()
    local duty = GangData:GetDutyNameByLv(msg.position)
    name:set_text(msg.roleName .. string.format(textRes.Chat[14], duty))
  else
    name:set_text(msg.roleName)
  end
  for i = 1, 2 do
    local badgeSprite = obj:FindDirect("Img_Badge" .. i)
    if badgeSprite then
      if msg.badge[i] ~= nil then
        badgeSprite:SetActive(true)
        local badge = BadgeModule.Instance():GetBadgeInfo(msg.badge[i]).spriteName
        badgeSprite:GetComponent("UISprite"):set_spriteName(badge)
        badgeSprite:GetComponent("UISprite"):UpdateAnchors()
      else
        badgeSprite:SetActive(false)
      end
    end
  end
end
def.method("userdata", "table").FillNoteMsg = function(self, obj, msg)
  local html = obj:FindDirect("Html_SystemInfo"):GetComponent("NGUIHTML")
  html:ForceHtmlText(msg.plainHtml)
end
def.method("userdata", "table").FillSysMsg = function(self, obj, msg)
  local html = obj:FindDirect("Html_Text"):GetComponent("NGUIHTML")
  html:ForceHtmlText(msg.plainHtml)
end
def.method("boolean").ToggleChannel = function(self, forward)
  if ChatModule.Instance().curChatId == Int64.new(0) then
    for k, v in ipairs(self.channelTabs) do
      if v:get_activeInHierarchy() and v:GetComponent("UIToggle"):get_value() then
        local toselect = 0
        if forward then
          toselect = k + 1 > #self.channelTabs and 1 or k + 1
        else
          toselect = k - 1 < 1 and #self.channelTabs or k - 1
        end
        self:onClick(self.channelTabs[toselect].name)
        return
      end
    end
    for k, v in ipairs(self.systemTabs) do
      if v:get_activeInHierarchy() and v:GetComponent("UIToggle"):get_value() then
        local toselect = 0
        if forward then
          toselect = k + 1 > #self.channelTabs and 1 or k + 1
        else
          toselect = k - 1 < 1 and #self.channelTabs or k - 1
        end
        self:onClick(self.systemTabs[toselect].name)
        return
      end
    end
  else
    local roleId, roleName = FriendModule.Instance():GetPreviousOrNextFriendInfo(ChatModule.Instance().curChatId, not forward)
    if roleId and Int64.gt(roleId, 0) then
      ChatModule.Instance():StartPrivateChat(roleId, roleName, -1, -1, -1)
    end
  end
end
def.method().AddTeamBatch = function(self)
  if self.m_base.state ~= SocialPanel.StateConst.Chat then
    return
  end
  if self.m_base.subState[SocialPanel.StateConst.Chat] ~= SocialPanel.StateConst.Team then
    return
  end
  local teamInfos = ChatModule.Instance().teamPlatformChatMgr.teamInfos
  for k, v in pairs(teamInfos) do
    self:_addTeam(v)
  end
end
def.method("table").RefreshTeamPlatform = function(self, teams)
  if self.m_base.state ~= SocialPanel.StateConst.Chat then
    return
  end
  if self.m_base.subState[SocialPanel.StateConst.Chat] ~= SocialPanel.StateConst.Team then
    return
  end
  for k, v in pairs(teams) do
    self:RefreshTeam(v)
  end
  self:RefreshChat()
end
def.method("table").RefreshTeam = function(self, data)
  local teamItem = self.chatContent:FindDirect("Team_" .. data.id)
  if teamItem then
    if data.num > 0 and data.num < data.maxNum then
      local numLabel = teamItem:FindDirect("Label_Num"):GetComponent("UILabel")
      local silder = teamItem:FindDirect("Img_BgSlider"):GetComponent("UISlider")
      local timeLabel = teamItem:FindDirect("Label_Time"):GetComponent("UILabel")
      numLabel:set_text(string.format("(%d/%d)", data.num, data.maxNum))
      silder:set_sliderValue(data.num / data.maxNum)
      local pastTime = os.time() - data.time
      if pastTime < 60 then
        timeLabel:set_text(textRes.Chat[22])
      else
        timeLabel:set_text(string.format(textRes.Chat[21], math.floor(pastTime / 60)))
      end
    else
      self:BackToPool(teamItem)
    end
  elseif data.num > 0 and data.num < data.maxNum then
    self:_addTeam(data)
  end
end
def.method("table", "=>", "userdata")._addTeam = function(self, data)
  local itemNew = self:GetFromPool("m")
  itemNew.parent = self.chatContent
  itemNew.name = "Team_" .. data.id
  itemNew:set_localScale(Vector.Vector3.one)
  itemNew:SetActive(true)
  local leaderName = itemNew:FindDirect("Label_Name"):GetComponent("UILabel")
  local actName = itemNew:FindDirect("Label_NameActive"):GetComponent("UILabel")
  local teamlv = itemNew:FindDirect("Label_TeamLv"):GetComponent("UILabel")
  local numLabel = itemNew:FindDirect("Label_Num"):GetComponent("UILabel")
  local silder = itemNew:FindDirect("Img_BgSlider"):GetComponent("UISlider")
  local timeLabel = itemNew:FindDirect("Label_Time"):GetComponent("UILabel")
  leaderName:set_text(data.leaderName .. ": ")
  actName:set_text(data.name)
  teamlv:set_text(string.format(textRes.Chat[20], data.minLv, data.maxLv))
  numLabel:set_text(string.format("(%d/%d)", data.num, data.maxNum))
  silder:set_sliderValue(data.num / data.maxNum)
  local pastTime = GetServerTime() - data.time
  if pastTime < 60 then
    timeLabel:set_text(textRes.Chat[22])
  else
    timeLabel:set_text(string.format(textRes.Chat[21], math.floor(pastTime / 60)))
  end
  local btn_join = itemNew:FindChildByPrefix("Btn_Join")
  if btn_join then
    btn_join.name = "Btn_Join_" .. data.teamId
  end
  self.m_base.m_msgHandler:Touch(itemNew)
  return itemNew
end
def.method().RefreshChat = function(self)
  GameUtil.AddGlobalLateTimer(0.01, true, function()
    local removed = self:RemoveOldMsg()
    self.chattable:Reposition()
    local bvalid, minx, miny, minz, maxx, maxy, maxz = GameUtil.GetUITableTotalBounds(self.chattable)
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
def.method().AddStangerNotice = function(self)
  local button1 = string.format("<gameobj width=88 height=22 prefab='%s' id='addstranger' boxcollider='true' componentname='NGUITextButtonComponent' param='%s'>", RESPATH.PREFAB_HTML_BUTTON, textRes.Chat[28])
  local button2 = string.format("<gameobj width=88 height=22 prefab='%s' id='blockstanger' boxcollider='true' componentname='NGUITextButtonComponent' param='%s'>", RESPATH.PREFAB_HTML_BUTTON, textRes.Chat[29])
  local noticeStr = string.format("%s%s%s", textRes.Chat[27], button1, button2)
  local htmlStr = require("Main.Chat.HtmlHelper").GenerateRawPlainNote(noticeStr)
  local itemNew = self:GetFromPool("n")
  itemNew.name = "N_Unique_0"
  self.m_base.m_msgHandler:Touch(itemNew)
  itemNew.parent = self.chatContent
  itemNew:set_localScale(Vector.Vector3.one)
  local html = itemNew:FindDirect("Html_SystemInfo"):GetComponent("NGUIHTML")
  html:ForceHtmlText(htmlStr)
  itemNew:SetActive(true)
end
def.method("number", "=>", "userdata").InsertTime = function(self, chatTime)
  local curTime = GetServerTime()
  local chatTimeTable = os.date("*t", chatTime)
  local curTimeTable = os.date("*t", curTime)
  chatTimeTable.wday = chatTimeTable.wday - 1 > 0 and chatTimeTable.wday - 1 or 7
  curTimeTable.wday = curTimeTable.wday - 1 > 0 and curTimeTable.wday - 1 or 7
  local timeStr
  if chatTimeTable.year == curTimeTable.year then
    local today = curTimeTable.yday
    local chatday = chatTimeTable.yday
    if today == chatday then
      timeStr = os.date("%H:%M", chatTime)
    elseif today - chatday == curTimeTable.wday - chatTimeTable.wday then
      timeStr = textRes.Chat.WeekDay[chatTimeTable.wday] .. os.date(" %H:%M", chatTime)
    else
      timeStr = os.date("%m-%d %H:%M", chatTime)
    end
  else
    timeStr = os.date("%Y-%m-%d %H:%M", chatTime)
  end
  local newTime = self:GetFromPool("t")
  newTime.name = "Time"
  newTime.parent = self.chatContent
  newTime:set_localScale(Vector.Vector3.one)
  local timeLabel = newTime:FindDirect("Label_Time"):GetComponent("UILabel")
  timeLabel:set_text(timeStr)
  newTime:SetActive(true)
  return newTime
end
def.method().RebuildPool = function(self)
  local count = self.pool:get_childCount()
  for i = 0, count - 1 do
    local item = self.pool:GetChild(i)
    if string.sub(item.name, 1, 2) == "N_" then
      table.insert(self.itemPool.n, item)
    elseif string.sub(item.name, 1, 2) == "S_" then
      table.insert(self.itemPool.s, item)
    elseif string.sub(item.name, 1, 2) == "L_" then
      table.insert(self.itemPool.l, item)
    elseif string.sub(item.name, 1, 2) == "R_" then
      table.insert(self.itemPool.r, item)
    elseif item.name == "Time" then
      table.insert(self.itemPool.t, item)
    elseif item.name == "Team_" then
      table.insert(self.itemPool.t, item)
    end
  end
end
def.method("userdata").BackToPool = function(self, item)
  item.parent = self.pool
  if string.sub(item.name, 1, 2) == "N_" then
    table.insert(self.itemPool.n, item)
  elseif string.sub(item.name, 1, 2) == "S_" then
    table.insert(self.itemPool.s, item)
  elseif string.sub(item.name, 1, 2) == "L_" then
    table.insert(self.itemPool.l, item)
  elseif string.sub(item.name, 1, 2) == "R_" then
    table.insert(self.itemPool.r, item)
  elseif item.name == "Time" then
    table.insert(self.itemPool.t, item)
  elseif string.sub(item.name, 1, 5) == "Team_" then
    table.insert(self.itemPool.m, item)
  end
end
def.method("string", "=>", "userdata").GetFromPool = function(self, t)
  local item = table.remove(self.itemPool[t])
  if item then
    return item
  else
    if t == "n" then
      item = Object.Instantiate(self.noteTemplate)
    elseif t == "s" then
      item = Object.Instantiate(self.sysTemplate)
    elseif t == "l" then
      item = Object.Instantiate(self.leftTemplate)
    elseif t == "r" then
      item = Object.Instantiate(self.rightTemplate)
    elseif t == "t" then
      item = Object.Instantiate(self.timeTemplate)
    elseif t == "m" then
      item = Object.Instantiate(self.teamTemplate)
    end
    return item
  end
end
ChatNode.Commit()
return ChatNode
