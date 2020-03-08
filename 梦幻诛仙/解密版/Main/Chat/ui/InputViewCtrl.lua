local Lplus = require("Lplus")
local InputViewCtrl = Lplus.Class("InputViewCtrl")
local def = InputViewCtrl.define
require("Utility/Utf8Helper")
local ECPanelBase = require("GUI.ECPanelBase")
local ChatUtils = require("Main.Chat.ChatUtils")
local GUIUtils = require("GUI.GUIUtils")
local Vector = require("Types.Vector")
local ChatMsgData = require("Main.Chat.ChatMsgData")
local ChatModule = Lplus.ForwardDeclare("ChatModule")
local ChatConst = require("netio.protocol.mzm.gsp.chat.ChatConsts")
local FriendModule = Lplus.ForwardDeclare("FriendModule")
local HtmlHelper = require("Main.Chat.HtmlHelper")
local SpeechMgr = require("Main.Chat.SpeechMgr")
local ChatInputDlg = require("Main.Chat.ui.ChatInputDlg")
local FriendCommonDlgManager = require("Main.friend.FriendCommonDlgManager")
local GangModule = require("Main.Gang.GangModule")
local BadgeModule = require("Main.Badge.BadgeModule")
local ChannelChatPanel = Lplus.ForwardDeclare("ChannelChatPanel")
local _infoPackMap = {}
def.field(ECPanelBase).m_base = nil
def.field("userdata").m_node = nil
def.field("function").submitDelegate = nil
def.field("function").voiceDelegate = nil
def.field("boolean").doSpeech = false
def.field("boolean").inSpeech = false
def.field("userdata").input = nil
def.field("boolean").canChat = true
def.field("boolean").hiding = false
def.virtual(ECPanelBase, "userdata", "function", "function").Init = function(self, base, node, delegate, delegate2)
  self.m_base = base
  self.m_node = node
  self.submitDelegate = delegate
  self.voiceDelegate = delegate2
  self.input = self.m_node:FindDirect("Img_BgInput"):GetComponent("UIInput")
  self:SetInputToWord()
end
def.method("boolean").ShowInputView = function(self, show)
  self.m_node:SetActive(show)
end
def.method().ResetInputView = function(self)
  if self.m_node and not self.m_node.isnil and self.m_node:get_activeInHierarchy() then
    local SpeakBtn = self.m_node:FindDirect("Btn_Speak")
    local InputBtn = self.m_node:FindDirect("Btn_Input")
    local AddBtn = self.m_node:FindDirect("Btn_Add")
    local ImgInput = self.m_node:FindDirect("Img_BgInput")
    local ImgSpeak = self.m_node:FindDirect("Img_BgSpeak")
    SpeakBtn:SetActive(true)
    AddBtn:SetActive(true)
    ImgInput:SetActive(true)
    InputBtn:SetActive(false)
    ImgSpeak:SetActive(false)
  end
end
def.virtual().SetInputToWord = function(self)
  local btnInput = self.m_node:FindDirect("Btn_Input")
  local btnSpeak = self.m_node:FindDirect("Btn_Speak")
  local input = self.m_node:FindDirect("Img_BgInput")
  local speak = self.m_node:FindDirect("Img_BgSpeak")
  local face = self.m_node:FindDirect("Btn_Add")
  btnInput:SetActive(false)
  btnSpeak:SetActive(true)
  input:SetActive(true)
  speak:SetActive(false)
  face:SetActive(true)
end
def.method().SetInputToVoice = function(self)
  local chatPanel = ChannelChatPanel.Instance()
  if chatPanel.channelType == ChatMsgData.MsgType.CHANNEL and chatPanel.channelSubType == ChatMsgData.Channel.LIVE then
    Toast(textRes.Chat[38])
    return
  end
  local btnInput = self.m_node:FindDirect("Btn_Input")
  local btnSpeak = self.m_node:FindDirect("Btn_Speak")
  local input = self.m_node:FindDirect("Img_BgInput")
  local speak = self.m_node:FindDirect("Img_BgSpeak")
  local face = self.m_node:FindDirect("Btn_Add")
  btnInput:SetActive(true)
  btnSpeak:SetActive(false)
  input:SetActive(false)
  speak:SetActive(true)
  face:SetActive(false)
end
def.method().ClearContent = function(self)
  self.input:set_value("")
end
def.method().SubmitContent = function(self)
  local content = self.input:get_value()
  local suc = self:SendContent(content, true)
  if suc then
    self.input:set_value("")
  end
end
def.method().BackSpaceContent = function(self)
  if self.input then
    local text = self.input:get_value()
    if text then
      self.input:set_value(string.sub(text, 1, string.len(text) - 1))
    end
  end
end
def.method("string").AddContent = function(self, content)
  if not self.input.gameObject:get_activeInHierarchy() then
    return
  end
  if GUIUtils.CheckUIInput(self.input) then
    self.input:Insert(content, false)
  end
end
def.method("string").SetContent = function(self)
  if not self.input.gameObject:get_activeInHierarchy() then
    return
  end
  self.input:set_value(content)
end
def.method("=>", "string").GetContentRaw = function(self)
  if self.input and not self.input.isnil then
    return self.input:get_value(content) or ""
  end
  return ""
end
def.method("string").SetContentRaw = function(self, content)
  if self.input and not self.input.isnil then
    self.input:set_value(content)
  end
end
def.method("string", "boolean", "=>", "boolean").SendContent = function(self, cnt, record)
  local content = cnt
  content = self:ConvertEmoji(content)
  content = self:GetInfoPack(content)
  content = ChatUtils.FilterHtmlTag(content)
  content = _G.TrimIllegalChar(content)
  content = ChatUtils.ChatContentTrim(content)
  if require("Main.ECGame").Instance():OpenGM(content) then
    self.input:set_value("")
    return true
  end
  if self.canChat == false then
    Toast(textRes.Chat[3])
    return false
  end
  if content == nil or content == "" then
    Toast(textRes.Chat[4])
    self.input:set_value("")
    return true
  end
  content = HtmlHelper.ConvertHtmlKeyWord(content)
  if record then
    require("Main.Chat.ChatMemo").Instance():AddMemo(content)
  end
  if self.submitDelegate(content) then
    self.input:set_value("")
    GameUtil.AddGlobalTimer(1, true, function()
      self.canChat = true
    end)
    return true
  else
    return false
  end
end
def.method().FocusOnInput = function(self)
  self.input:set_isSelected(true)
end
def.method("string", "string").AddInfoPack = function(self, name, cipher)
  if not self.input.gameObject:get_activeInHierarchy() then
    return
  end
  if not GUIUtils.CheckUIInput(self.input) then
    return
  end
  local ret = self.input:Insert(name, true)
  if ret > 0 then
    _infoPackMap[ret] = cipher
  else
    Toast(textRes.Chat[30])
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
def.method("string", "=>", "string").ConvertEmoji = function(self, cnt)
  local ret = string.gsub(cnt, "#%d?%d?%d?%d", function(str)
    local code = tonumber(string.sub(str, 2))
    if code then
      local emojiName = string.format("%04d", code)
      if ChatInputDlg.Instance():CheckEmoji(emojiName) then
        return string.format("{e:%s}", emojiName)
      else
        return str
      end
    else
      return str
    end
  end)
  return ret
end
def.virtual().OpenChatInput = function(self)
  self:SetInputToWord()
  ChatInputDlg.ShowChatInputDlg(self)
end
def.method("string", "=>", "boolean").onClick = function(self, id)
  if id == "Btn_Speak" then
  elseif id == "Btn_Input" then
    self:SetInputToWord()
    return true
  elseif id == "Btn_Clear" then
    self:ClearContent()
    return true
  elseif id == "Btn_Send" then
    self:SubmitContent()
    return true
  elseif id == "Btn_Add" then
    self:OpenChatInput()
    return true
  elseif id == "Btn_Preset" then
    return true
  elseif id == "Btn_Paste" then
    local content = require("Main.Chat.ChatMemo").Instance():GetClipBoard()
    if content and content ~= "" then
      self.input:set_value(content)
    end
    local curPaste = self.m_node:FindDirect("Img_BgInput/Btn_Paste")
    if curPaste ~= nil then
      curPaste:SetActive(false)
    end
    return true
  end
  return false
end
def.method("string", "=>", "boolean").onLongPress = function(self, id)
  return false
end
def.method("string", "userdata", "=>", "boolean").onSubmit = function(self, id, ctrl)
  if id == "Img_BgInput" or id == "Btn_Speak" then
    self:SubmitContent()
    return true
  end
  return false
end
def.method("boolean").OnShow = function(self, show)
  if not show then
    self.hiding = true
  else
    self.hiding = false
    if self.doSpeech then
      local voiceBtn = self.m_node:FindDirect("Btn_Speak")
      local pressBtn = UICamera.IsPressed(voiceBtn)
      if pressBtn then
        UICamera.Raycast(Input.mousePosition)
        local press = UICamera.IsHighlighted(voiceBtn)
        if press then
          if not self.inSpeech then
            self.inSpeech = true
            SpeechMgr.Instance():Pause(false)
          end
        elseif self.inSpeech then
          self.inSpeech = false
          SpeechMgr.Instance():Pause(true)
        end
      else
        SpeechMgr.Instance():CancelSpeech()
      end
    end
  end
end
def.method().OnDestroy = function(self)
  if self.doSpeech then
    SpeechMgr.Instance():CancelSpeech()
    self.doSpeech = false
    self.inSpeech = false
    self.hiding = false
  else
    require("Main.Chat.ui.SpeechTip").Instance():Close()
  end
end
def.method("string", "boolean", "=>", "boolean").onPress = function(self, id, state)
  if id == "Img_BgSpeak" or id == "Btn_Speak" then
    if state then
      if SpeechMgr.Instance():StartSpeech() then
        self.doSpeech = true
        self.inSpeech = true
        self.voiceDelegate(SpeechMgr.Instance())
      end
    else
      if self.doSpeech then
        if self.inSpeech and not self.hiding then
          SpeechMgr.Instance():EndSpeech()
        else
          SpeechMgr.Instance():CancelSpeech()
        end
      end
      self.doSpeech = false
      self.inSpeech = false
    end
    return true
  end
  return false
end
def.method("string", "userdata", "=>", "boolean").onDragOut = function(self, id, go)
  if not self.hiding and self.doSpeech then
    local press = UICamera.IsHighlighted(go)
    if press == true then
      self.inSpeech = true
      SpeechMgr.Instance():Pause(false)
    else
      self.inSpeech = false
      SpeechMgr.Instance():Pause(true)
    end
    return true
  end
  return false
end
def.method("string", "userdata", "=>", "boolean").onDragOver = function(self, id, go)
  if id == "Img_BgSpeak" then
    if not self.hiding and self.doSpeech then
      self.inSpeech = true
      SpeechMgr.Instance():Pause(false)
    end
    return true
  end
  return false
end
InputViewCtrl.Commit()
return InputViewCtrl
