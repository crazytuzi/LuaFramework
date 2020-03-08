local Lplus = require("Lplus")
local GUIUtils = require("GUI.GUIUtils")
local ChatModule = Lplus.ForwardDeclare("ChatModule")
local HtmlHelper = require("Main.Chat.HtmlHelper")
local ChatUtils = require("Main.Chat.ChatUtils")
local ECPanelBase = require("GUI.ECPanelBase")
local ItemUtils = require("Main.Item.ItemUtils")
local ChatMsgBuilder = require("Main.Chat.ChatMsgBuilder")
local ItemAccessMgr = require("Main.Item.ItemAccessMgr")
local TrumpetQueue = require("Main.Chat.Trumpet.data.TrumpetQueue")
local FightMgr = require("Main.Fight.FightMgr")
local MainUIPanel = require("Main.MainUI.ui.MainUIPanel")
local TrumpetMgr = require("Main.Chat.Trumpet.TrumpetMgr")
local Vector = require("Types.Vector")
local ChatMsgData = require("Main.Chat.ChatMsgData")
local AtUtils = require("Main.Chat.At.AtUtils")
local TrumpetPanel = Lplus.Extend(ECPanelBase, "TrumpetPanel")
local def = TrumpetPanel.define
local instance
def.static("=>", TrumpetPanel).Instance = function()
  if instance == nil then
    instance = TrumpetPanel()
  end
  return instance
end
def.field("table").m_CurTrumpet = nil
def.field("table").m_Anchor = nil
def.field("number").m_OriginDepth = 0
def.field("userdata").m_UIPanel = nil
def.field("userdata").m_chatGO = nil
def.field("userdata").m_htmlContent = nil
def.field("table").m_OriginChatPosition = nil
def.field("userdata").m_bgSpriteGO = nil
def.field("userdata").m_bgUISprite = nil
def.field("table").m_OriginSpritePosition = nil
def.static("table").ShowDlg = function(anchor)
  if nil == anchor or nil == anchor.anchor then
    warn("[ERROR][TrumpetPanel:ShowDlg] anchor or anchor.anchor NIL! DestroyPanel.")
    if TrumpetPanel.Instance():IsShow() then
      TrumpetPanel.Instance():DestroyPanel()
    end
    return
  end
  if TrumpetPanel.Instance():IsShow() then
    TrumpetPanel.Instance():SetAnchor(anchor)
    return
  elseif anchor then
    TrumpetPanel.Instance().m_Anchor = anchor
    TrumpetPanel.Instance():CreatePanel(RESPATH.PREFAB_TRUMPET_PANEL, 0)
  end
end
def.override().OnCreate = function(self)
  self:SetModal(false)
end
def.override().OnDestroy = function(self)
  self.m_Anchor = nil
end
def.override("boolean").OnShow = function(self, show)
  if show then
    self:InitUI()
    self.m_CurTrumpet = nil
    self:ShowTrumpet(TrumpetQueue.Instance():Top())
    self:SetAnchor(self.m_Anchor)
  end
end
def.method().InitUI = function(self)
  self.m_UIPanel = self.m_panel:GetComponent("UIPanel")
  self.m_OriginDepth = self.m_UIPanel:get_depth()
  self.m_chatGO = self.m_panel:FindDirect("Chat")
  self.m_htmlContent = self.m_chatGO:GetComponent("NGUIHTML")
  self.m_htmlContent:ForceHtmlText("")
  self.m_OriginChatPosition = self.m_chatGO:get_localPosition()
  self.m_bgSpriteGO = self.m_panel:FindDirect("Img_Text")
  self.m_bgUISprite = self.m_bgSpriteGO:GetComponent("UISprite")
  self.m_OriginSpritePosition = self.m_bgSpriteGO:get_localPosition()
end
def.method("=>", "boolean").CheckContext = function(self)
  return true
end
def.method("string", "=>", "boolean").onClick = function(self, id)
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
def.method("table").ShowTrumpet = function(self, trumpet)
  if nil == trumpet then
    warn("[TrumpetPanel:ShowTrumpet] trumpet nil hide TrumpetPanel.")
    self:DestroyPanel()
    return
  end
  self.m_CurTrumpet = trumpet
  self.m_htmlContent:ForceHtmlText(trumpet.msg.mainHtml)
  self:_AdjustChat()
  GUIUtils.SetSprite(self.m_bgSpriteGO, trumpet.cfg.spriteName)
end
def.method()._AdjustChat = function(self)
  local htmlHeight = self.m_htmlContent:get_height()
  local htmlWidth = self.m_htmlContent:get_width()
  self.m_chatGO:set_localPosition(Vector.Vector3.new(self.m_OriginChatPosition.x, htmlHeight + 10, self.m_OriginChatPosition.z))
  self.m_bgUISprite:set_height(htmlHeight + 40)
  self.m_bgUISprite:set_width(htmlWidth + 44)
  self.m_bgSpriteGO:set_localPosition(Vector.Vector3.new(self.m_OriginSpritePosition.x, htmlHeight + 30, self.m_OriginSpritePosition.z))
end
def.method("table").SetAnchor = function(self, anchor)
  if anchor and anchor.anchor then
    if self.m_panel.parent ~= anchor.anchor then
      self.m_Anchor = anchor
      self.m_panel.parent = self.m_Anchor.anchor
      self.m_panel:set_localPosition(Vector.Vector3.zero)
      self.m_panel:set_localScale(Vector.Vector3.one)
      if self.m_Anchor.isMainUI and _G.PlayerIsInFight() then
        GameUtil.AddGlobalTimer(0, true, function()
          if not _G.IsNil(self.m_UIPanel) then
            self.m_UIPanel:set_depth(-2000)
          end
        end)
      else
        GameUtil.AddGlobalTimer(0, true, function()
          if not _G.IsNil(self.m_UIPanel) then
            self.m_UIPanel:set_depth(36060)
          end
        end)
      end
    end
  else
    warn("[ERROR][TrumpetPanel:SetAnchor] anchor or anchor.anchor NIL! DestroyPanel.")
    self:DestroyPanel()
  end
end
TrumpetPanel.Commit()
return TrumpetPanel
