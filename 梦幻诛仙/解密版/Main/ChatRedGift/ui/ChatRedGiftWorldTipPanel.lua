local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local ChatRedGiftWorldTipPanel = Lplus.Extend(ECPanelBase, "ChatRedGiftWorldTipPanel")
local def = ChatRedGiftWorldTipPanel.define
local instance
def.field("table").redGiftInfo = nil
def.static("=>", ChatRedGiftWorldTipPanel).Instance = function()
  if not instance then
    instance = ChatRedGiftWorldTipPanel()
  end
  return instance
end
def.method("table").ShowPanel = function(self, _redGiftInfo)
  self.redGiftInfo = _redGiftInfo
  if self:IsShow() then
    self:UpdateUI()
  else
    self:CreatePanel(RESPATH.PREFAB_CHATREDGIFT_WORLDTIP_PANEL, 2)
  end
end
def.override().OnCreate = function(self)
  Event.RegisterEvent(ModuleId.CHATREDGIFT, gmodule.notifyId.ChatRedGift.NewChatRedGift_Opened, ChatRedGiftWorldTipPanel.ClosePanel)
  self:UpdateUI()
end
def.override().OnDestroy = function(self)
  Event.UnregisterEvent(ModuleId.CHATREDGIFT, gmodule.notifyId.ChatRedGift.NewChatRedGift_Opened, ChatRedGiftWorldTipPanel.ClosePanel)
  self.redGiftInfo = nil
end
def.static("table", "table").ClosePanel = function(param, param1)
  if instance:IsShow() and instance.redGiftInfo.redGiftId == param.redGiftInfo.redGiftId then
    instance:DestroyPanel()
  end
end
def.method().UpdateUI = function(self)
  if not self.m_panel then
    return
  end
  local roleInfo = self.redGiftInfo.roleInfo
  local label_name = self.m_panel:FindDirect("Img_BgTarget/Label_TargetName"):GetComponent("UILabel")
  label_name:set_text(self.redGiftInfo.roleInfo.name)
  local headObj = self.m_panel:FindDirect("Img_BgTarget/Img_IconHead")
  if roleInfo.avatarId then
    _G.SetAvatarIcon(headObj, roleInfo.avatarId)
  else
    warn("ChatRedGiftWorldTipPanel: No avatarId")
    local spriteName = require("GUI.GUIUtils").GetHeadSpriteName(self.redGiftInfo.roleInfo.menpai, self.redGiftInfo.roleInfo.gender)
    local head = headObj:GetComponent("UISprite")
    head.spriteName = spriteName
  end
  local label_Lv = headObj:FindDirect("Label_LV"):GetComponent("UILabel")
  label_Lv:set_text(tostring(self.redGiftInfo.roleInfo.level))
  local label_Content = self.m_panel:FindDirect("Img_BgTarget/Img_BgContent/Label_Content"):GetComponent("UILabel")
  label_Content:set_text(self.redGiftInfo.content)
end
def.method()._GetRedGift = function(self)
  local ChatRedGiftUtility = require("Main.ChatRedGift.ChatRedGiftUtility")
  local ChatMsgData = require("Main.Chat.ChatMsgData")
  if not ChatRedGiftUtility.IsChatChanelOpened(self.redGiftInfo.channelType, self.redGiftInfo.channelSubType) then
    if self.redGiftInfo.channelType == ChatMsgData.MsgType.CHANNEL then
      require("Main.Chat.ui.ChannelChatPanel").ShowChannelChatPanel(self.redGiftInfo.channelType, self.redGiftInfo.channelSubType)
    elseif self.redGiftInfo.channelType == ChatMsgData.MsgType.GROUP then
      require("Main.friend.ui.SocialDlg").ShowGroupChat(self.redGiftInfo.groupId)
    end
  end
  Event.DispatchEvent(ModuleId.CHATREDGIFT, gmodule.notifyId.ChatRedGift.Get_ChatRedGiftProtocol, {
    redGiftId = self.redGiftInfo.redGiftId,
    channelType = self.redGiftInfo.channelType,
    channelSubType = self.redGiftInfo.channelSubType
  })
  self:DestroyPanel()
end
def.method("string").onClick = function(self, id)
  if id == "Btn_Close" then
    self:DestroyPanel()
  elseif id == "Btn_Qiang" then
    self:_GetRedGift()
  end
end
ChatRedGiftWorldTipPanel.Commit()
return ChatRedGiftWorldTipPanel
