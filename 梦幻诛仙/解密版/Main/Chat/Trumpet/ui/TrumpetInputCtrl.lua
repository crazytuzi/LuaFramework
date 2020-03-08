local Lplus = require("Lplus")
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
local TrumpetInputCtrl = Lplus.Class("TrumpetInputCtrl")
local def = TrumpetInputCtrl.define
local _infoPackMap = {}
def.field(ECPanelBase).m_base = nil
def.field("userdata").m_node = nil
def.field("function").submitDelegate = nil
def.field("userdata").input = nil
def.field("boolean").canChat = true
def.field("boolean").hiding = false
def.virtual(ECPanelBase, "userdata", "function").Init = function(self, base, node, delegate)
  self.m_base = base
  self.m_node = node
  self.submitDelegate = delegate
  self.input = self.m_node:FindDirect("Img_BgInput"):GetComponent("UIInput")
end
def.method().ClearContent = function(self)
  self.input:set_value("")
end
def.method().SubmitContent = function(self)
  local suc = self:SendContent(self.input:get_value(), true)
  if suc then
    self.input:set_value("")
  end
end
def.method("string", "=>", "string").GetContent = function(self, content)
  content = self:ConvertEmoji(content)
  content = self:GetInfoPack(content)
  content = ChatUtils.FilterHtmlTag(content)
  content = _G.TrimIllegalChar(content)
  content = ChatUtils.ChatContentTrim(content)
  content = HtmlHelper.ConvertHtmlKeyWord(content)
  return content
end
def.method("string", "boolean", "=>", "boolean").SendContent = function(self, cnt, record)
  if self.canChat == false then
    Toast(textRes.Chat[3])
    return false
  end
  local content = self:GetContent(cnt)
  if content == nil or content == "" then
    Toast(textRes.Chat.Trumpet.CONTENT_EMPTY)
    self.input:set_value("")
    return true
  end
  if record then
    require("Main.Chat.ChatMemo").Instance():AddMemo(content)
  end
  if self.submitDelegate(content) then
    self.input:set_value("")
    return true
  else
    return false
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
def.method().FocusOnInput = function(self)
  self.input:set_isSelected(true)
end
def.method("string", "string", "=>", "boolean")._CheckAddInfoPack = function(self, name, cipher)
  local result = true
  if not ChatUtils.IsStringEmoji(cipher) and self:_GetLinkInfoPackCount(self.input:get_value()) > 0 then
    result = false
  end
  return result
end
def.method("string", "=>", "number")._GetLinkInfoPackCount = function(self, cnt)
  local result = 0
  if cnt then
    for str in string.gmatch(cnt, "[\001-\a]") do
      local infoStr = _infoPackMap[str:byte(1)]
      if infoStr and not ChatUtils.IsStringEmoji(infoStr) then
        result = result + 1
      end
    end
  end
  return result
end
def.method("string", "string").AddInfoPack = function(self, name, cipher)
  if not self.input.gameObject:get_activeInHierarchy() then
    return
  end
  if not GUIUtils.CheckUIInput(self.input) then
    return
  end
  if not self:_CheckAddInfoPack(name, cipher) then
    Toast(textRes.Chat.Trumpet.LINK_TOO_MUCK)
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
  ChatInputDlg.ShowChatInputDlg(self)
end
def.method("string", "=>", "boolean").onClick = function(self, id)
  if id == "Btn_Clear" then
    self:ClearContent()
    return true
  elseif id == "Btn_Look" then
    self:OpenChatInput()
    return true
  elseif id == "Btn_Paste" then
    local content = require("Main.Chat.ChatMemo").Instance():GetClipBoard()
    if content and content ~= "" then
      self.input:set_value(content)
    end
    local curPaste = self.m_node:FindDirect("Btn_Paste")
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
  warn("[TrumpetInputCtrl:onSubmit] onSubmit!")
  if id == "Img_BgInput" then
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
  end
end
def.method().OnDestroy = function(self)
end
def.method("string", "boolean", "=>", "boolean").onPress = function(self, id, state)
  return false
end
def.method("string", "userdata", "=>", "boolean").onDragOut = function(self, id, go)
  return false
end
def.method("string", "userdata", "=>", "boolean").onDragOver = function(self, id, go)
  return false
end
TrumpetInputCtrl.Commit()
return TrumpetInputCtrl
