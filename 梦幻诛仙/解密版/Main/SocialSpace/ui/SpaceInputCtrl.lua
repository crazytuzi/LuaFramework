local MODULE_NAME = (...)
local Lplus = require("Lplus")
local SpaceInputCtrl = Lplus.Class(MODULE_NAME)
local def = SpaceInputCtrl.define
local ChatInputDlg = require("Main.Chat.ui.ChatInputDlg")
local ChatUtils = require("Main.Chat.ChatUtils")
local HtmlHelper = require("Main.Chat.HtmlHelper")
local GUIUtils = require("GUI.GUIUtils")
local ECSocialSpaceMan = require("Main.SocialSpace.ECSocialSpaceMan")
local MenuType = ChatInputDlg.StateConst
def.const("table").MenuType = MenuType
def.field("table").m_base = nil
def.field("table").m_infoPackMap = BLANK_TABLE_INIT
def.field("userdata").m_input = nil
def.field("userdata").input = nil
def.field("table").m_neededMenus = nil
def.static("table", "userdata", "=>", SpaceInputCtrl).New = function(base, uiInput)
  local self = SpaceInputCtrl()
  self.m_base = base
  self.m_input = uiInput
  self.input = self.m_input
  self:OnInit()
  return self
end
def.method().OnInit = function(self)
  self.m_neededMenus = {
    [MenuType.Emoji] = true,
    [MenuType.Mood] = true
  }
end
def.method().ShowInputDlg = function(self)
  ChatInputDlg.ShowChatInputDlg(self)
end
def.method("table").SetNeededMenus = function(self, menuList)
  self.m_neededMenus = {}
  for i, v in ipairs(menuList) do
    self.m_neededMenus[v] = true
  end
end
def.method("number", "=>", "boolean").IsNeededMenu = function(self, menuType)
  return self.m_neededMenus[menuType] and true or false
end
def.method("string", "string").AddInfoPack = function(self, name, cipher)
  if _G.IsNil(self.m_input) then
    return
  end
  if not GUIUtils.CheckUIInput(self.m_input) then
    return
  end
  local ret = self.m_input:Insert(name, true)
  if ret > 0 then
    self.m_infoPackMap[ret] = cipher
  else
    Toast(textRes.Chat[30])
  end
end
def.method("string", "=>", "string").GetContent = function(self, content)
  content = self:ConvertEmoji(content)
  content = self:GetInfoPack(content)
  content = ChatUtils.FilterHtmlTag(content)
  content = _G.TrimIllegalChar(content)
  content = ChatUtils.ChatContentTrim(content)
  content = HtmlHelper.ConvertHtmlKeyWord(content)
  content = ECSocialSpaceMan.Instance():FilterSensitiveWords(content)
  return content
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
def.method("string", "=>", "string").GetInfoPack = function(self, cnt)
  local hasInfoPackStr = string.gsub(cnt, "[\001-\a]", function(str)
    local infoStr = self.m_infoPackMap[str:byte(1)]
    if infoStr then
      return infoStr
    else
      return ""
    end
  end)
  return hasInfoPackStr
end
def.method().SubmitContent = function(self)
  self.m_base:OnClickSendBtn()
end
def.method("string", "boolean", "=>", "boolean").SendContent = function(self, cnt, record)
  local ret = self.m_base:OnSendContent(cnt)
  if ret == true then
    ChatInputDlg.Instance():DestroyPanel()
  end
  return ret
end
def.method().ClearContent = function(self)
  self.m_infoPackMap = {}
  self.m_input:set_value("")
end
def.method().FocusOnInput = function(self)
  if _G.IsNil(self.m_input) then
    return
  end
  self.m_input:set_isSelected(true)
end
def.method("string").AddContent = function(self, content)
  if _G.IsNil(self.m_input) then
    return
  end
  if GUIUtils.CheckUIInput(self.m_input) then
    self.m_input:Insert(content, false)
  end
end
def.method().BackSpaceContent = function(self)
  if _G.IsNil(self.m_input) then
    return
  end
  local text = self.m_input:get_value()
  if text then
    self.m_input:set_value(string.sub(text, 1, string.len(text) - 1))
  end
end
def.method().Destroy = function(self)
  self:ClearContent()
  ChatInputDlg.Instance():DestroyPanel()
end
return SpaceInputCtrl.Commit()
