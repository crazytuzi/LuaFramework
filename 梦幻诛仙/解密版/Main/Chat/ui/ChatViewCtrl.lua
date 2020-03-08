local Lplus = require("Lplus")
local ChatViewCtrl = Lplus.Class("ChatViewCtrl")
local def = ChatViewCtrl.define
local ECPanelBase = require("GUI.ECPanelBase")
local ChatUtils = require("Main.Chat.ChatUtils")
local GUIUtils = require("GUI.GUIUtils")
local Vector = require("Types.Vector")
local ChatMsgData = require("Main.Chat.ChatMsgData")
local ChatModule = Lplus.ForwardDeclare("ChatModule")
local ChatConst = require("netio.protocol.mzm.gsp.chat.ChatConsts")
local FriendModule = Lplus.ForwardDeclare("FriendModule")
local SpeechMgr = require("Main.Chat.SpeechMgr")
local GangUtility = require("Main.Gang.GangUtility")
local ChatInputDlg = require("Main.Chat.ui.ChatInputDlg")
local FriendCommonDlgManager = require("Main.friend.FriendCommonDlgManager")
local GangModule = require("Main.Gang.GangModule")
local BadgeModule = require("Main.Badge.BadgeModule")
local ChatRedGiftData = require("Main.ChatRedGift.ChatRedGiftData")
local AbsoluteTimer = require("Main.Common.AbsoluteTimer")
local AvatarInterface = require("Main.Avatar.AvatarInterface")
local SexEnum = require("consts.mzm.gsp.award.confbean.SexEnum")
local AtUtils = require("Main.Chat.At.AtUtils")
local AtMgr = require("Main.Chat.At.AtMgr")
local bmin = Vector.Vector3.new()
local bmax = Vector.Vector3.new()
def.const("number").MAXCHAT = 128
def.field("table").context = nil
def.field("userdata").chatContent = nil
def.field("userdata").newMsgBtn = nil
def.field("userdata").announceMent = nil
def.field("userdata").redGiftTip = nil
def.field("userdata").scroll = nil
def.field("userdata").chattable = nil
def.field("userdata").leftTemplate = nil
def.field("userdata").rightTemplate = nil
def.field("userdata").noteTemplate = nil
def.field("userdata").sysTemplate = nil
def.field("userdata").teamTemplate = nil
def.field("userdata").timeTemplate = nil
def.field("userdata").pool = nil
def.field("table").itemPool = nil
def.field("number").curOperation = 0
def.field("number").PAGE_COUNT = 16
def.field(ECPanelBase).m_base = nil
def.field("userdata").m_node = nil
def.field("function").requestMsgDelegate = nil
def.field("userdata")._pressObj = nil
def.field("userdata")._atMsgBtn = nil
def.field("userdata")._atMsgLabel = nil
def.field("table")._channelAtData = nil
def.field("table")._orgAtData = nil
def.field("userdata")._atBtnAnchorUp = nil
def.field("userdata")._atBtnAnchorDown = nil
def.virtual(ECPanelBase, "userdata", "number", "function").Init = function(self, base, node, page, delegate)
  self.m_base = base
  self.m_node = node
  self.PAGE_COUNT = page
  self.requestMsgDelegate = delegate
  self.chatContent = self.m_node:FindDirect("Scroll View_Chat/Table_Chat")
  self.newMsgBtn = self.m_node:FindDirect("Btn_New")
  self.announceMent = self.m_node:FindDirect("Group_Announce")
  self.redGiftTip = self.m_node:FindDirect("Group_RedBag")
  self.chattable = self.chatContent:GetComponent("UITable")
  self.chattable.RecursiveCalcBounds = false
  self.scroll = self.m_node:FindDirect("Scroll View_Chat"):GetComponent("UIScrollView")
  local pool = self.m_node:FindDirect("pool")
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
  self.announceMent:SetActive(false)
  if self.redGiftTip then
    self.redGiftTip:SetActive(false)
  else
    warn("PanelCat No RedGiftTip")
  end
  self._atBtnAnchorUp = self.m_node:FindDirect("Point_AtNew/Point_Up")
  self._atBtnAnchorDown = self.m_node:FindDirect("Point_AtNew/Point_Down")
  if _G.IsNil(self._atMsgBtn) then
    self._atMsgBtn = self.m_node:FindDirect("Btn_AtNew")
    self._atMsgBtn = self._atMsgBtn or self._atBtnAnchorUp:FindDirect("Btn_AtNew")
    self._atMsgBtn = self._atMsgBtn or self._atBtnAnchorDown:FindDirect("Btn_AtNew")
  end
  if _G.IsNil(self._atMsgLabel) then
    self._atMsgLabel = self._atMsgBtn:FindDirect("Label_New")
  end
  GUIUtils.SetActive(self._atMsgBtn, false)
end
def.method("table").SetContext = function(self, cnt)
  self.context = cnt
  self:UpdateRedGiftTip()
end
def.virtual().UpdateRedGiftTip = function(self)
  if not self.context or not self.context.channel then
    if self.redGiftTip then
      self.redGiftTip:SetActive(false)
    end
    return
  end
  local _redGiftInfo = ChatRedGiftData.Instance():GetNewChatRedGiftByChannelType(self.m_base.channelType, self.context.channel)
  if _redGiftInfo then
    if self.redGiftTip then
      self.redGiftTip:SetActive(true)
      local label_redgift = self.redGiftTip:FindDirect("Label_New"):GetComponent("UILabel")
      label_redgift:set_text(string.format(textRes.ChatRedGift[20], _redGiftInfo.roleInfo.name))
      if self.announceMent.activeSelf or self.newMsgBtn.activeSelf then
        local _pos = self.announceMent.localPosition
        self.redGiftTip.localPosition = Vector.Vector3.new(_pos.x, _pos.y - 38, _pos.z)
      else
        self.redGiftTip.localPosition = self.announceMent.localPosition
      end
    end
  elseif self.redGiftTip then
    self.redGiftTip:SetActive(false)
  end
end
def.virtual("boolean").ClickRedGfitTip = function(self, isCloseClick)
  if not self.context or not self.context.channel then
    return
  end
  local _redGiftInfo = ChatRedGiftData.Instance():GetNewChatRedGiftByChannelType(self.m_base.channelType, self.context.channel)
  if isCloseClick then
    if _redGiftInfo then
      ChatRedGiftData.Instance():OpenChatRedGift(_redGiftInfo)
    end
  elseif _redGiftInfo then
    Event.DispatchEvent(ModuleId.CHATREDGIFT, gmodule.notifyId.ChatRedGift.Get_ChatRedGiftProtocol, {
      redGiftId = _redGiftInfo.redGiftId,
      channelType = self.m_base.channelType,
      channelSubType = self.context.channel
    })
    ChatRedGiftData.Instance():OpenChatRedGift(_redGiftInfo)
  end
  self:UpdateRedGiftTip()
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
  elseif msg.type == ChatMsgData.MsgType.FRIEND or msg.type == ChatMsgData.MsgType.CHANNEL or msg.type == ChatMsgData.MsgType.GROUP then
    local heroProp = require("Main.Hero.Interface").GetHeroProp()
    if heroProp.id == msg.roleId and msg.id ~= ChatMsgData.Channel.TRUMPET then
      itemNew = self:GetFromPool("r")
      self.m_base.m_msgHandler:Touch(itemNew)
      itemNew.parent = self.chatContent
      itemNew.name = string.format("R_Unique_%d", msg.unique)
      itemNew:set_localScale(Vector.Vector3.one)
      self:FillChatMsg(itemNew, msg)
      itemNew:SetActive(true)
      local img_text = itemNew:FindChildByPrefix("Img_Text")
      if img_text then
        if msg.contentType == ChatConst.CONTENT_CHATGIFT then
          img_text:GetComponent("UISprite"):set_spriteName("Img_Red")
        elseif not self:SetImgTxt(img_text, msg, true) then
          img_text:GetComponent("UISprite"):set_spriteName("Img_PaoLv")
        end
      end
    else
      itemNew = self:GetFromPool("l")
      self.m_base.m_msgHandler:Touch(itemNew)
      itemNew.parent = self.chatContent
      itemNew.name = string.format("L_Unique_%d", msg.unique)
      itemNew:set_localScale(Vector.Vector3.one)
      self:FillChatMsg(itemNew, msg)
      itemNew:SetActive(true)
      local img_text = itemNew:FindChildByPrefix("Img_Text")
      if img_text then
        if msg.contentType == ChatConst.CONTENT_CHATGIFT then
          img_text:GetComponent("UISprite"):set_spriteName("Img_RedLeft")
        elseif not self:SetImgTxt(img_text, msg, false) then
          img_text:GetComponent("UISprite"):set_spriteName("Img_PaoBai")
        end
      end
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
      local spriteData = img_text:GetComponent("UISprite")
      local htmlWidth = itemNew:FindChildByPrefix("Html_Text"):GetComponent("UIWidget").width
      if spriteData ~= nil then
        if htmlWidth < 40 then
          spriteData:set_width(70)
        else
          spriteData:set_width(htmlWidth + 40)
        end
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
def.method("userdata", "table", "boolean", "=>", "boolean").SetImgTxt = function(self, imgBubble, msg, bRight)
  local ChatBubbleUtil = require("Main.Chat.ChatBubble.ChatBubbleUtils")
  if require("Main.Chat.ChatBubble.ChatBubbleMgr").IsFeatureOpen() then
    imgBubble:SetActive(true)
    local bubbleCfg = ChatBubbleUtil.GetBubbleCfgById(msg.bubbleId and msg.bubbleId or constant.ChatBubbleConsts.defaultChatBubbleCfgId)
    if bubbleCfg then
      if bRight then
        ChatBubbleUtil.SetSprite(imgBubble, bubbleCfg.myUIReource)
      else
        ChatBubbleUtil.SetSprite(imgBubble, bubbleCfg.uiResource)
      end
      return true
    end
  else
    imgBubble:SetActive(true)
    if bRight then
      ChatBubbleUtil.SetSprite(imgBubble, _G.DefaultBubbleCfg.myUIReource)
    else
      ChatBubbleUtil.SetSprite(imgBubble, _G.DefaultBubbleCfg.uiResource)
    end
  end
  return true
end
def.virtual("table").AddMsg = function(self, msg)
  local hasCnt = self.chatContent:get_childCount() > 0
  local scrollBounds = self.scroll:get_bounds()
  local clipBounds = self.scroll:GetClipBounds()
  local scrollHeight = scrollBounds.max.y - scrollBounds.min.y
  local clipHeight = clipBounds.size.y
  local dragAmountY = hasCnt and self.scroll:GetDragAmount().y or 0
  local newItem = self:_addOneMsg(msg, false)
  if scrollHeight > clipHeight then
    if dragAmountY < 0.1 then
      self:RemoveOldMsg()
      self:DelayResetTableAndScroll()
    else
      self:RemoveOverflowMsg()
      self:DelayResetTable()
      self:ShowNew(true)
    end
  else
    self:RemoveOldMsg()
    self:DelayResetTableAndScroll()
  end
end
def.virtual("table", "boolean").AddMsgBatch = function(self, msgs, inverse)
  if inverse then
    for i = 1, #msgs do
      local msg = msgs[i]
      if not msg.delete then
        local obj = self:_addOneMsg(msg, true)
      end
    end
  else
    for i = #msgs, 1, -1 do
      local msg = msgs[i]
      if not msg.delete then
        local obj = self:_addOneMsg(msg, false)
      end
    end
  end
end
def.method("table").UpdateOneMsg = function(self, msg)
  if self.chatContent and not self.chatContent.isnil then
    local msgGo = self.chatContent:FindDirect(string.format("R_Unique_%d", msg.unique)) or self.chatContent:FindDirect(string.format("L_Unique_%d", msg.unique))
    if msgGo then
      local html = msgGo:FindDirect("Html_Text"):GetComponent("NGUIHTML")
      html:ForceHtmlText(msg.plainHtml)
      local img_text = msgGo:FindChildByPrefix("Img_Text")
      if img_text then
        local spriteData = img_text:GetComponent("UISprite")
        local htmlWidth = msgGo:FindDirect("Html_Text"):GetComponent("UIWidget").width
        if spriteData ~= nil then
          if htmlWidth < 40 then
            spriteData:set_width(70)
          else
            spriteData:set_width(htmlWidth + 40)
          end
        end
      end
      self:DelayResetTableAndKeepScroll()
    end
  end
end
def.method("boolean").ShowNew = function(self, show)
  self.newMsgBtn:SetActive(show)
  self:UpdateRedGiftTip()
  self:UpdateAtBtnPos()
end
def.method("boolean").ShowAnnounceMent = function(self, show)
  self.announceMent:SetActive(show)
  self:UpdateRedGiftTip()
end
def.method("string").SetAnnounceMent = function(self, content)
  local label = self.announceMent:FindDirect("Label_New"):GetComponent("UILabel")
  label:set_text(content)
end
def.method().ResetTable = function(self)
  if self.chattable == nil or self.chattable.isnil then
    return
  end
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
def.method().DelayResetTable = function(self)
  GameUtil.AddGlobalLateTimer(0.01, true, function()
    self:ResetTable()
  end)
end
def.method().ResetTableAndScroll = function(self)
  if self.chattable == nil or self.chattable.isnil then
    return
  end
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
end
def.method().DelayResetTableAndScroll = function(self)
  GameUtil.AddGlobalLateTimer(0.01, true, function()
    self:ResetTableAndScroll()
  end)
end
def.method().ResetTableAndKeepScroll = function(self)
  if self.chattable == nil or self.chattable.isnil then
    return
  end
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
  local movey = old_maxy - maxy + miny - old_miny
  local move = Vector.Vector3.new(0, movey, 0)
  self.scroll:stopScroll()
  self.scroll:MoveAbsolute(move)
end
def.method().DelayResetTableAndKeepScroll = function(self)
  GameUtil.AddGlobalLateTimer(0.01, true, function()
    self:ResetTableAndKeepScroll()
  end)
end
def.method().ClearMsgOperation = function(self)
  local curItem = self.chatContent:FindDirect(string.format("L_Unique_%d", self.curOperation)) or self.chatContent:FindDirect(string.format("R_Unique_%d", self.curOperation))
  if curItem ~= nil then
    local Btn_Copy = curItem:FindDirect(string.format("Btn_Copy_%d", self.curOperation))
    local Btn_Delete = curItem:FindDirect(string.format("Btn_Delete_%d", self.curOperation))
    Btn_Copy:SetActive(false)
    Btn_Delete:SetActive(false)
    self.curOperation = 0
  end
end
def.method("boolean").Show = function(self, show)
  self.m_node:SetActive(show)
end
def.method("=>", "boolean").CheckContext = function(self)
  if self.context and (self.context.channel == ChatMsgData.Channel.CITY or self.context.channel == ChatMsgData.Channel.LIVE) then
    Toast(textRes.Chat[68])
    return false
  end
  return true
end
def.method("userdata", "=>", "boolean").onClickObj = function(self, obj)
  if string.find(obj.name, "Img_Badge") then
    self:OnClickBadge(obj)
    return true
  end
  return false
end
def.method("userdata").OnClickBadge = function(self, badge)
  if badge ~= nil then
    local badgeTag = badge:GetComponent("UILabel")
    if badgeTag ~= nil then
      local badgeId = tonumber(badgeTag.text)
      local badgeInfo = require("Main.Badge.BadgeModule").Instance():GetBadgeInfo(badgeId)
      local position = badge:get_position()
      local screenPos = WorldPosToScreen(position.x, position.y)
      local widget = badge:GetComponent("UIWidget")
      local desc = badgeInfo.desc
      if badgeInfo.limitTime ~= nil then
        desc = desc .. os.date(textRes.Item[142], badgeInfo.limitTime)
      end
      require("Main.Item.ItemTipsMgr").Instance():ShowCustomTip(badgeInfo.name, badgeInfo.iconId, textRes.Item[141], desc, screenPos.x, screenPos.y, widget:get_width(), widget:get_height(), 0)
    end
  end
end
def.method("string", "=>", "boolean").onClick = function(self, id)
  if string.find(id, "Img_Head_") then
    if not self:CheckContext() then
      return true
    end
    local indexStr = string.sub(id, 10)
    local roleId = Int64.new(indexStr)
    local myId = _G.GetMyRoleID()
    if roleId ~= myId then
      local state = FriendCommonDlgManager.StateConst.OtherChat
      FriendCommonDlgManager.ApplyShowFriendCommonDlg(roleId, state)
    end
    return true
  elseif id == "Btn_New" then
    self:ResetTableAndScroll()
    self:ShowNew(false)
    return true
  elseif id == "Img_Di" then
    self:ClickRedGfitTip(false)
    return true
  elseif id == "Btn_CloseRedBag" then
    self:ClickRedGfitTip(true)
    return true
  elseif id == "Btn_CloseAnnounceMent" then
    self:ShowAnnounceMent(false)
    return true
  elseif string.find(id, "Img_Text_") then
    local unique = tonumber(string.sub(id, 10))
    local chatItem = self.chatContent:FindDirect(string.format("L_Unique_%d", unique)) or self.chatContent:FindDirect(string.format("R_Unique_%d", unique))
    if chatItem then
      local html = chatItem:FindDirect("Html_Text")
      local voiceObj = GameObject.FindChildByPrefix(html, "voice_", false)
      if voiceObj then
        GameObject.SendMessage(voiceObj, "OnVoiceButtonClick", voiceObj, 0)
        local uniqueId = tonumber(string.sub(voiceObj.name, 7))
        if uniqueId then
          local msg = ChatMsgData.Instance():GetUniqueMsg(uniqueId)
          if msg and msg.fileId then
            SpeechMgr.Instance():PlayInterrupt(msg.fileId, msg.second)
          end
        end
      end
    end
    return true
  elseif string.find(id, "voice_") then
    local index = tonumber(string.sub(id, 7))
    if index then
      local msg = ChatMsgData.Instance():GetUniqueMsg(index)
      warn("fileId", msg.fileId)
      if msg and msg.fileId then
        SpeechMgr.Instance():PlayInterrupt(msg.fileId, msg.second)
      end
    end
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
  elseif string.find(id, "card_") then
    Event.DispatchEvent(ModuleId.CHAT, gmodule.notifyId.Chat.CARD_CLICK, {
      id = string.sub(id, 6)
    })
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
  elseif string.find(id, "fabaospirit_") then
    if not self:CheckContext() then
      return true
    end
    ChatModule.Instance():RequestFabaoLingQiPackInfo(id)
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
    return true
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
  elseif string.find(id, "Btn_Delete_") then
    local unique = tonumber(string.sub(id, 12))
    ChatMsgData.Instance():DeleteUniqueMsg(unique)
    return true
  elseif string.find(id, "Btn_Copy_") then
    local unique = tonumber(string.sub(id, 10))
    require("Main.Chat.ChatMemo").Instance():CopyOneByUniqueId(unique)
    self:ClearMsgOperation()
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
  elseif id == "addstranger" then
    require("Main.friend.FriendModule").Instance():RequestAddFriendToServer(self.m_base.curChatId)
    return true
  elseif id == "blockstanger" then
    require("Main.friend.FriendModule").Instance():CRequestAddRoleToShield(self.m_base.curChatId, self.m_base.curName)
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
  elseif id == "wanted" then
    local WantedMgr = require("Main.PlayerPK.WantedMgr")
    WantedMgr.Instance():GoToPlayerWantedNpc()
  elseif string.find(id, AtUtils.GetHTMLAtPrefix()) then
    AtMgr.OnClickAtInfoPack(id)
    return true
  elseif id == "Btn_AtNew" then
    self:OnBtn_AtNew()
    return true
  elseif string.find(id, "gangteam_") then
    require("Main.Gang.GangTeamMgr").OnBtnGangTeamLink(id)
    return true
  elseif string.find(id, "shenyao_") then
    require("Main.Gang.GodMedicine.GodMedicineMgr").OnHyperLinkClick(id)
    return true
  elseif string.find(id, "TurnedCard_") then
    local strs = string.split(id, "_")
    require("Main.TurnedCard.TurnedCardUtils").ShowTurnedCardTips(tonumber(strs[2]), tonumber(strs[3]))
  end
  return false
end
def.method("userdata", "boolean", "=>", "boolean").onPressObj = function(self, clickobj, bPress)
  if bPress then
    self._pressObj = clickobj
  else
    self._pressObj = nil
  end
  return false
end
def.method("string", "=>", "boolean").onLongPress = function(self, id)
  if string.find(id, "Img_Head_") then
    local indexStr = string.sub(id, 10)
    local roleId = Int64.new(indexStr)
    local myId = _G.GetMyRoleID()
    if not Int64.eq(roleId, myId) then
      AtMgr.Instance():OnLongPressRoleHead(self._pressObj, roleId)
    end
  end
  return false
end
def.method("string", "=>", "boolean").onDragEnd = function(self, id)
  if string.find(id, "_Unique_") or string.find(id, "Img_Text_") or id == "Html_Text" or string.find(id, "Img_Head_") or id == "Time" or id == "Img_Bg" or string.find(id, "Team_") or string.find(id, "btn_join") then
    local dragAmount = self.scroll:GetDragAmount()
    if dragAmount.y < -0.01 then
      self:ShowNew(false)
      self:RemoveOldMsg()
      self:ResetTableAndKeepScroll()
    elseif dragAmount.y > 1.01 then
      self:AddOldMsg()
    end
    return true
  end
  return false
end
def.method("string", "userdata", "number", "table", "=>", "boolean").onSpringFinish = function(self, id, scrollView, type, position)
  if id == "Scroll View_Chat" and type == 2 then
    return true
  end
  return false
end
def.method("=>", "number").RemoveOverflowMsg = function(self)
  local oldCount = self.chatContent:get_childCount() - ChatViewCtrl.MAXCHAT
  local deleteCount = oldCount
  if oldCount > 0 then
    local toBeDeleted = {}
    for i = oldCount - 1, 0, -1 do
      local pig = self.chatContent:GetChild(i)
      table.insert(toBeDeleted, pig)
    end
    for k, pig in ipairs(toBeDeleted) do
      self:BackToPool(pig)
    end
    deleteCount = #toBeDeleted
  else
    deleteCount = 0
  end
  return deleteCount
end
def.method("=>", "number").RemoveOldMsg = function(self)
  local oldCount = self.chatContent:get_childCount() - self.PAGE_COUNT
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
  else
    deleteCount = 0
  end
  return deleteCount
end
def.method("=>", "number").GetOldestUnique = function(self)
  local count = self.chatContent:get_childCount()
  if count > 0 then
    for i = 0, count - 1 do
      local msgObj = self.chatContent:GetChild(i)
      local unique = self:GetMsgUnique(msgObj)
      if unique >= 0 then
        return unique
      end
    end
  end
  return 0
end
def.method().AddOldMsg = function(self)
  local unique = self:GetOldestUnique()
  local msgs = self.requestMsgDelegate(unique, self.PAGE_COUNT)
  if #msgs > 0 then
    self:AddMsgBatch(msgs, true)
    self:DelayResetTableAndKeepScroll()
  end
end
def.method().ResetClip = function(self)
  if not self.scroll.isnil then
    local uiPanel = self.scroll:get_panel()
    if uiPanel then
      uiPanel:set_clipOffset(Vector.Vector2.zero)
      local trans = uiPanel.transform
      trans.localPosition = Vector.Vector3.zero
    end
  end
end
def.method().ClearMsg = function(self)
  local count = self.chatContent:get_childCount()
  for i = count - 1, 0, -1 do
    local child = self.chatContent:GetChild(i)
    self:BackToPool(child)
  end
  self:ResetClip()
  self:ResetTableAndScroll()
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
  head.name = "Img_Head_0"
  if head then
    local lv = head:FindDirect("Label_Lv"):GetComponent("UILabel")
    lv:set_text("")
    _G.SetAvatarIcon(head)
    local headTexture = head:GetComponent("UITexture")
    GUIUtils.FillIcon(headTexture, msg.publishIcon)
    local iconSex = head:FindDirect("Img_Sex")
    if iconSex then
      local SGenderEnum = require("consts.mzm.gsp.occupation.confbean.SGenderEnum")
      GUIUtils.SetSprite(iconSex, GUIUtils.GetSexIcon(SGenderEnum.MALE))
    end
    local iconMenPai = head:FindDirect("Img_MenPai")
    GUIUtils.SetActive(iconMenPai, false)
    local imgFrame = head:FindDirect("Img_BgHead01")
    local avatarFrameId = require("Main.Avatar.AvatarFrameMgr").Instance():getDefaultAvatarFrameId()
    _G.SetAvatarFrameIcon(imgFrame, avatarFrameId)
  end
  local name = obj:FindDirect("Label_Name"):GetComponent("UILabel")
  name:set_text(msg.roleName)
  for i = 1, 2 do
    local badgeSprite = obj:FindDirect("Img_Badge" .. i)
    badgeSprite:SetActive(false)
  end
  local imgTxt = obj:FindChildByPrefix("Img_Text")
  self:SetImgTxt(imgTxt, msg, false)
end
def.method("userdata", "table").FillNormalChat = function(self, obj, msg)
  local html = obj:FindDirect("Html_Text"):GetComponent("NGUIHTML")
  html:ForceHtmlText(msg.plainHtml)
  local head = obj:FindChildByPrefix("Img_Head")
  if head then
    local lv = head:FindDirect("Label_Lv"):GetComponent("UILabel")
    lv:set_text(msg.level)
    SetAvatarIcon(head, msg.avatarId)
    head.name = "Img_Head_" .. msg.roleId:tostring()
    local imgFrame = head:FindDirect("Img_BgHead01")
    _G.SetAvatarFrameIcon(imgFrame, msg.avatarFrameId)
    local menpai = msg.occupationId
    local iconMenPai = head:FindDirect("Img_MenPai")
    if menpai and iconMenPai then
      iconMenPai:SetActive(true)
      GUIUtils.SetSprite(iconMenPai, GUIUtils.GetOccupationSmallIcon(menpai))
    elseif iconMenPai then
      iconMenPai:SetActive(false)
    end
    local sex = msg.gender
    local iconSex = head:FindDirect("Img_Sex")
    if sex and iconSex then
      GUIUtils.SetSprite(iconSex, GUIUtils.GetSexIcon(sex))
    end
    local sameSvr = head:FindDirect("Img_TongFu")
    if sameSvr then
      if msg.server == require("netio.Network").m_zoneid then
        sameSvr:SetActive(true)
      else
        sameSvr:SetActive(false)
      end
    end
  end
  local name = obj:FindDirect("Label_Name"):GetComponent("UILabel")
  if msg.isCaptain then
    name:set_text(msg.roleName .. textRes.Chat[2])
  elseif msg.position and msg.position ~= 6 and msg.position ~= 7 then
    local GangCrossData = require("Main.GangCross.data.GangCrossData")
    local duty = ""
    if IsCrossingServer() and GangCrossData.Instance():HasGang() then
      local gangTitle = GangCrossData.Instance():GetGangTitle()
      duty = GangUtility.GetDutyNameByDutyLvAndCfgId(gangTitle, msg.position)
    else
      local GangData = require("Main.Gang.data.GangData").Instance()
      duty = GangData:GetDutyNameByLv(msg.position)
    end
    name:set_text(msg.roleName .. string.format(textRes.Chat[14], duty))
  elseif msg.server then
    local serverListMgr = require("Main.Login.ServerListMgr").Instance()
    local serverInfo = serverListMgr:GetServerCfg(msg.server)
    if serverInfo then
      local serverName = serverInfo.name
      name:set_text(msg.roleName .. string.format(textRes.Chat[14], serverName))
    else
      name:set_text(msg.roleName)
    end
  else
    name:set_text(msg.roleName)
  end
  local trumpetIconIndex = 0
  for i = 1, 3 do
    local badgeSprite = obj:FindDirect("Img_Badge" .. i)
    if badgeSprite then
      if i <= 2 and msg.badge[i] ~= nil then
        badgeSprite:SetActive(true)
        local badge = BadgeModule.Instance():GetBadgeInfo(msg.badge[i]).spriteName
        badgeSprite:GetComponent("UISprite"):set_spriteName(badge)
        badgeSprite:GetComponent("UISprite"):UpdateAnchors()
        local badgeTag = badgeSprite:GetComponent("UILabel")
        if badgeTag == nil then
          badgeTag = badgeSprite:AddComponent("UILabel")
          badgeTag:set_enabled(false)
        end
        badgeTag.text = msg.badge[i]
        local boxCollider = badgeSprite:GetComponent("BoxCollider")
        if boxCollider == nil then
          boxCollider = badgeSprite:AddComponent("BoxCollider")
          badgeSprite:GetComponent("UISprite"):set_autoResizeBoxCollider(true)
        end
      elseif msg.id == ChatMsgData.Channel.TRUMPET and trumpetIconIndex <= 0 then
        trumpetIconIndex = i
        badgeSprite:SetActive(true)
        ChatViewCtrl.FillSprite(RESPATH.COMMONATLAS, "Img_Broadcast", badgeSprite:GetComponent("UISprite"))
      else
        badgeSprite:SetActive(false)
      end
    end
  end
end
def.static("string", "string", "userdata").FillSprite = function(atlasName, spriteName, uiSprite)
  GameUtil.AsyncLoad(atlasName, function(obj)
    local atlas = obj:GetComponent("UIAtlas")
    uiSprite:set_atlas(atlas)
    uiSprite:set_spriteName(spriteName)
  end)
end
def.method("userdata", "table").FillNoteMsg = function(self, obj, msg)
  local html = obj:FindDirect("Html_SystemInfo"):GetComponent("NGUIHTML")
  html:ForceHtmlText(msg.plainHtml)
end
def.method("userdata", "table").FillSysMsg = function(self, obj, msg)
  local html = obj:FindDirect("Html_Text"):GetComponent("NGUIHTML")
  html:ForceHtmlText(msg.plainHtml)
end
def.method("table").AddTeamBatch = function(self, teamInfos)
  for k, v in pairs(teamInfos) do
    self:_addTeam(v)
  end
end
def.method("table").RefreshTeamPlatform = function(self, teams)
  for k, v in pairs(teams) do
    self:RefreshTeam(v)
  end
  self:ResetTableAndScroll()
end
def.method("table").RefreshTeam = function(self, data)
  local teamItem = self.chatContent:FindDirect("Team_" .. data.id)
  if teamItem then
    if data.num > 0 and data.num <= data.maxNum then
      local Img_Team = teamItem:FindDirect("Img_Team")
      local numLabel = Img_Team:FindDirect("Label_Num"):GetComponent("UILabel")
      local silder = Img_Team:FindDirect("Img_BgSlider"):GetComponent("UISlider")
      local timeLabel = Img_Team:FindDirect("Label_Time"):GetComponent("UILabel")
      local JoinBtn = Img_Team:FindChildByPrefix("Btn_Join", false)
      local FullLabel = Img_Team:FindDirect("Label_FullTeam")
      Img_Team:FindDirect("Img_BgSlider"):SetActive(false)
      numLabel:set_text(string.format("(%d/%d)", data.num, data.maxNum))
      local pastTime = os.time() - data.time
      if pastTime < 60 then
        timeLabel:set_text(textRes.Chat[22])
      else
        timeLabel:set_text(string.format(textRes.Chat[21], math.floor(pastTime / 60)))
      end
      if data.num == data.maxNum then
        if JoinBtn then
          JoinBtn:SetActive(false)
        end
        FullLabel:SetActive(true)
      else
        if JoinBtn then
          JoinBtn:SetActive(true)
        end
        FullLabel:SetActive(false)
      end
    else
      self:BackToPool(teamItem)
    end
  elseif data.num > 0 and data.num <= data.maxNum then
    self:_addTeam(data)
  end
end
def.method("table", "=>", "userdata")._addTeam = function(self, data)
  local itemNew = self:GetFromPool("m")
  itemNew.parent = self.chatContent
  itemNew.name = "Team_" .. data.id
  itemNew:set_localScale(Vector.Vector3.one)
  itemNew:SetActive(true)
  local ImgHead = itemNew:FindDirect("Img_Head")
  local leaderLvLabel = itemNew:FindDirect("Img_Head/Label_Lv")
  SetAvatarIcon(ImgHead, data.leaderAvatarId)
  local frame = ImgHead:FindDirect("Img_BgHead1")
  SetAvatarFrameIcon(frame, data.leaderAvatarFrameId)
  local camp = itemNew:FindDirect("Img_MenPai")
  camp:GetComponent("UISprite"):set_spriteName(GUIUtils.GetOccupationSmallIcon(data.leaderOccupation))
  local genderSpr = itemNew:FindDirect("Img_Sex")
  genderSpr:GetComponent("UISprite"):set_spriteName(GUIUtils.GetGenderSprite(data.leaderGender))
  leaderLvLabel:GetComponent("UILabel"):set_text(tostring(data.leaderLevel))
  local leaderName = itemNew:FindDirect("Label_Name"):GetComponent("UILabel")
  local Img_Team = itemNew:FindDirect("Img_Team")
  local actName = Img_Team:FindDirect("Label_NameActive"):GetComponent("UILabel")
  local teamlv = Img_Team:FindDirect("Label_TeamLv"):GetComponent("UILabel")
  local numLabel = Img_Team:FindDirect("Label_Num"):GetComponent("UILabel")
  local silder = Img_Team:FindDirect("Img_BgSlider"):GetComponent("UISlider")
  local timeLabel = Img_Team:FindDirect("Label_Time"):GetComponent("UILabel")
  Img_Team:FindDirect("Img_BgSlider"):SetActive(false)
  leaderName:set_text(data.leaderName .. ": ")
  actName:set_text(data.name)
  teamlv:set_text(string.format(textRes.Chat[20], data.minLv, data.maxLv))
  numLabel:set_text(string.format("(%d/%d)", data.num, data.maxNum))
  local pastTime = GetServerTime() - data.time
  if pastTime < 60 then
    timeLabel:set_text(textRes.Chat[22])
  else
    timeLabel:set_text(string.format(textRes.Chat[21], math.floor(pastTime / 60)))
  end
  local btn_join = Img_Team:FindChildByPrefix("Btn_Join", false)
  if btn_join then
    btn_join.name = "Btn_Join_" .. data.teamId
  end
  local FullLabel = Img_Team:FindDirect("Label_FullTeam")
  if data.num == data.maxNum then
    if btn_join then
      btn_join:SetActive(false)
    end
    FullLabel:SetActive(true)
  else
    if btn_join then
      btn_join:SetActive(true)
    end
    FullLabel:SetActive(false)
  end
  local imgBubble = itemNew:FindDirect("Img_Text")
  local ChatBubbleUtil = require("Main.Chat.ChatBubble.ChatBubbleUtils")
  local bubbleCfg = ChatBubbleUtil.GetBubbleCfgById(data.bubbleId and data.bubbleId or constant.ChatBubbleConsts.defaultChatBubbleCfgId)
  if bubbleCfg then
    ChatBubbleUtil.SetSprite(imgBubble, bubbleCfg.uiResource)
  end
  self.m_base.m_msgHandler:Touch(itemNew)
  return itemNew
end
def.method().AddChannelAvoidNotice = function(self)
  local ChannelChatPanel = require("Main.Chat.ui.ChannelChatPanel")
  local curSubType = ChannelChatPanel.Instance().channelSubType
  local channelSubTypeName = textRes.Chat.ChannelSubTypeName[curSubType]
  if channelSubTypeName then
    local noticebutton = string.format("<a href='avoidsettingnotice' id=avoidsettingnotice><font color=#%s><u>[%s]</u></font></a>", link_defalut_color, textRes.Chat[60])
    local noticeStr = string.format(textRes.Chat[59], channelSubTypeName, noticebutton)
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
end
def.method("string").AddTextTipNotice = function(self, htmlStr)
  local noticehtml = require("Main.Chat.HtmlHelper").GenerateRawPlainNote(htmlStr)
  local itemNew = self:GetFromPool("n")
  itemNew.name = "N_Unique_0"
  self.m_base.m_msgHandler:Touch(itemNew)
  itemNew.parent = self.chatContent
  itemNew:set_localScale(Vector.Vector3.one)
  local html = itemNew:FindDirect("Html_SystemInfo"):GetComponent("NGUIHTML")
  html:ForceHtmlText(noticehtml)
  itemNew:SetActive(true)
end
def.method().AddStangerNotice = function(self)
  local button1 = string.format("<a href='addstranger' id=addstranger><font color=#%s><u>[%s]</u></font></a>", link_defalut_color, textRes.Chat[28])
  local button2 = string.format("<a href='blockstanger' id=blockstanger><font color=#%s><u>[%s]</u></font></a>", link_defalut_color, textRes.Chat[29])
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
def.method("number", "boolean", "=>", "userdata").InsertTime = function(self, chatTime, inverse)
  local curTime = GetServerTime()
  local chatTimeTable = AbsoluteTimer.GetServerTimeTable(chatTime)
  local curTimeTable = AbsoluteTimer.GetServerTimeTable(curTime)
  chatTimeTable.wday = chatTimeTable.wday - 1 > 0 and chatTimeTable.wday - 1 or 7
  curTimeTable.wday = curTimeTable.wday - 1 > 0 and curTimeTable.wday - 1 or 7
  local timeStr
  if chatTimeTable.year == curTimeTable.year then
    local today = curTimeTable.yday
    local chatday = chatTimeTable.yday
    if today == chatday then
      timeStr = string.format("%02d:%02d", chatTimeTable.hour, chatTimeTable.min)
    elseif today - chatday == curTimeTable.wday - chatTimeTable.wday then
      timeStr = textRes.Chat.WeekDay[chatTimeTable.wday] .. string.format(" %02d:%02d", chatTimeTable.hour, chatTimeTable.min)
    else
      timeStr = string.format("%02d-%02d %02d:%02d", chatTimeTable.month, chatTimeTable.day, chatTimeTable.hour, chatTimeTable.min)
    end
  else
    timeStr = string.format("%d-%02d-%02d %02d:%02d", chatTimeTable.year, chatTimeTable.month, chatTimeTable.day, chatTimeTable.hour, chatTimeTable.min)
  end
  local newTime = self:GetFromPool("t")
  newTime.name = "Time"
  newTime.parent = self.chatContent
  newTime:set_localScale(Vector.Vector3.one)
  local timeLabel = newTime:FindDirect("Label_Time"):GetComponent("UILabel")
  timeLabel:set_text(timeStr)
  newTime:SetActive(true)
  if inverse then
    newTime.transform:SetAsFirstSibling()
  end
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
def.method().UpdateAtBtn = function(self)
  GameUtil.AddGlobalLateTimer(0.01, true, function()
    self:DoUpdateAtBtn()
  end)
end
def.method().DoUpdateAtBtn = function(self)
  if nil == self.m_base or not self.m_base:IsShow() then
    return
  end
  if not AtMgr.Instance():IsOpen(false) then
    GUIUtils.SetActive(self._atMsgBtn, false)
    return
  end
  local curChannel = AtUtils.GetCurrentChannel()
  if nil == self._channelAtData or self._channelAtData.channel ~= curChannel then
    self._channelAtData = require("Main.Chat.At.data.AtData").Instance():GetChannelAtMsg(curChannel)
  end
  local curOrgId = AtUtils.GetChannelOrgId(curChannel)
  self._orgAtData = self._channelAtData and self._channelAtData:GetOrgAtMsg(curOrgId)
  local msgCount = self._orgAtData and self._orgAtData:GetMsgCount() or 0
  local maxAtNum = self._orgAtData and self._orgAtData.maxAtNum or 0
  if msgCount > 0 and maxAtNum > 0 then
    warn(string.format("[ChatViewCtrl:UpdateAtBtn] Update AtBtn: curChannel[%d], curOrgId[%s], msgCount[%d]:", curChannel, curOrgId and Int64.tostring(curOrgId) or "nil", msgCount))
    GUIUtils.SetActive(self._atMsgBtn, true)
    self:UpdateAtBtnPos()
    local countStr = msgCount
    if msgCount >= maxAtNum then
      countStr = maxAtNum .. "+"
    end
    countStr = string.format(textRes.Chat.At.AT_COUNT, countStr)
    GUIUtils.SetText(self._atMsgLabel, countStr)
  else
    warn("[ChatViewCtrl:UpdateAtBtn] no at msg for channel:", curChannel)
    GUIUtils.SetActive(self._atMsgBtn, false)
  end
end
def.method().UpdateAtBtnPos = function(self)
  if self._atMsgBtn.activeSelf then
    local anchor
    if self.newMsgBtn.activeSelf then
      anchor = self._atBtnAnchorDown
    else
      anchor = self._atBtnAnchorUp
    end
    if anchor then
      self._atMsgBtn.parent = anchor
      self._atMsgBtn:set_localPosition(Vector.Vector3.zero)
    else
      warn("[ChatViewCtrl:UpdateAtBtnPos] anchor nil.")
    end
  end
end
def.method().OnBtn_AtNew = function(self)
  local atMsgData = self._orgAtData and self._orgAtData:GetLatestAtMsg()
  if atMsgData then
    local atRecordIdx, atRecordMsg = AtUtils.FindInChatMsgData(atMsgData)
    if atRecordIdx > 0 and atRecordMsg then
      self:JumpToAtMsg(atRecordIdx, atRecordMsg)
    else
      warn("[ChatViewCtrl:OnBtn_AtNew] open in msg box:", atMsgData.channel, atMsgData:GetContent())
      local AtBoxPanel = require("Main.Chat.At.ui.AtBoxPanel")
      AtBoxPanel.ShowPanel(atMsgData)
    end
  else
    warn("[ERROR][ChatViewCtrl:OnBtn_AtNew] self._orgAtData or self._orgAtData:GetLatestAtMsg() NIL.")
    self:UpdateAtBtn()
  end
end
def.method("number", "table").JumpToAtMsg = function(self, atRecordIdx, atRecordMsg)
  self._orgAtData:PopAtMsg()
  if atRecordIdx <= 0 or nil == atRecordMsg then
    warn("[ERROR][ChatViewCtrl:JumpToAtMsg] jump FAIL! atRecordIdx & atRecordMsg:", atRecordIdx, atRecordMsg)
    return
  end
  local oldestUnique = self:GetOldestUnique()
  local oldestMsgIdx = 0
  local recordCount = 0
  if atRecordMsg.type == ChatMsgData.MsgType.GROUP then
    oldestMsgIdx = AtUtils.GetUniqueIdx64(atRecordMsg.type, atRecordMsg.id, oldestUnique)
    recordCount = AtUtils.GetChatRecordCount64(atRecordMsg.type, atRecordMsg.id)
  else
    oldestMsgIdx = AtUtils.GetUniqueIdx(atRecordMsg.type, atRecordMsg.id, oldestUnique)
    recordCount = AtUtils.GetChatRecordCount(atRecordMsg.type, atRecordMsg.id)
  end
  local halfClipCount = self:GetHalfClipMsgCount()
  local recordMsgCount
  if recordCount <= self:GetClipMsgCount() then
    warn(string.format("[ChatViewCtrl:JumpToAtMsg] only one page, do not jump: atRecordIdx[%d], oldestMsgIdx[%d], recordCount[%d].", atRecordIdx, oldestMsgIdx, recordCount))
  elseif oldestMsgIdx >= atRecordIdx + halfClipCount then
    warn(string.format("[ChatViewCtrl:JumpToAtMsg] jump directly: atRecordIdx[%d], oldestMsgIdx[%d], oldestUnique[%d].", atRecordIdx, oldestMsgIdx, oldestUnique))
    self:DelayResetTableAndScrollToIdx(atRecordIdx)
  else
    local requestCount = atRecordIdx - oldestMsgIdx + halfClipCount
    local msgs = self.requestMsgDelegate(oldestUnique, requestCount)
    if #msgs > 0 then
      self:AddMsgBatch(msgs, true)
    end
    warn(string.format("[ChatViewCtrl:JumpToAtMsg] request then jump: atRecordIdx[%d], oldestMsgIdx[%d], requestCount[%d], #msgs[%d], oldestUnique[%d].", atRecordIdx, oldestMsgIdx, requestCount, #msgs, oldestUnique))
    local count = self.chatContent:get_childCount()
    self:DelayResetTableAndScrollToIdx(count)
  end
end
def.method("number").DelayResetTableAndScrollToIdx = function(self, idx)
  GameUtil.AddGlobalLateTimer(0.01, true, function()
    self:ResetTableAndScrollToIdx(idx)
  end)
end
def.method("number").ResetTableAndScrollToIdx = function(self, idx)
  if idx <= self:GetHalfClipMsgCount() then
    self:ResetTableAndScroll()
  else
    if self.chattable == nil or self.chattable.isnil then
      return
    end
    self.chattable:Reposition()
    local bvalid, minx, miny, minz, maxx, maxy, maxz = GameUtil.GetUITableTotalBounds(self.chattable)
    if bvalid then
      bmin:Set(minx, miny, minz)
      bmax:Set(maxx, maxy, maxz)
      self.scroll:SetOuterBounds(bmin, bmax)
    else
      self.scroll:ResetOuterBounds()
    end
    local count = self.chatContent:get_childCount()
    local amountY = idx / count
    self.scroll:SetDragAmount(0, amountY, false)
  end
end
def.method("=>", "number").GetLatestUnique = function(self)
  local count = self.chatContent:get_childCount()
  if count > 0 then
    for i = count - 1, 0, -1 do
      local msgObj = self.chatContent:GetChild(i)
      local unique = self:GetMsgUnique(msgObj)
      if unique >= 0 then
        warn("[ChatViewCtrl:GetLatestUnique] get latest msgObj.name:", msgObj.name)
        return unique
      end
    end
  end
  return 0
end
def.method("userdata", "=>", "number").GetMsgUnique = function(self, msgObj)
  local unique = -1
  if string.sub(msgObj.name, 3, 9) == "Unique_" then
    local uni = tonumber(string.sub(msgObj.name, 10))
    unique = uni or 0
  end
  return unique
end
def.virtual("=>", "number").GetClipMsgCount = function(self)
  return math.floor(self.PAGE_COUNT / 2)
end
def.virtual("=>", "number").GetHalfClipMsgCount = function(self)
  return math.floor(self.PAGE_COUNT / 4)
end
ChatViewCtrl.Commit()
return ChatViewCtrl
