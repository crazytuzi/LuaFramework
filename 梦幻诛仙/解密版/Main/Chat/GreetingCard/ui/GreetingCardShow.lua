local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local GreetingCardShow = Lplus.Extend(ECPanelBase, "GreetingCardShow")
local HtmlHelper = require("Main.Chat.HtmlHelper")
local Vector = require("Types.Vector")
local def = GreetingCardShow.define
def.field("string").content = ""
def.field("function").createCallback = nil
def.static("string", "string", "function").ShowGreetingCardShow = function(content, prefab, cb)
  local dlg = GreetingCardShow()
  dlg.content = content
  dlg.content = HtmlHelper.ConvertEmoji(dlg.content)
  dlg.createCallback = cb
  local path = dlg:makePath(prefab)
  dlg:CreatePanel(path, 0)
  dlg:SetOutTouchDisappear()
end
def.override().OnCreate = function(self)
  local colorLbl = self.m_panel:FindDirect("Img_Bg0/Label_Color")
  local lblCmp = colorLbl:GetComponent("UILabel")
  local color = lblCmp:get_textColor()
  local r = color:get_r() * 256
  local g = color:get_g() * 256
  local b = color:get_b() * 256
  local colorStr = string.format("#%02x%02x%02x", r, g, b)
  local word = self.m_panel:FindDirect("Img_Bg0/Label_Content")
  local text = self.content
  text = HtmlHelper.ConvertEmoji(text)
  word:GetComponent("NGUIHTML"):ForceHtmlText(string.format("<p align=left valign=middle linespacing=10><font color=%s size=22>%s</font></p>", colorStr, text))
  if self.createCallback then
    GameUtil.AddGlobalTimer(0.01, true, function()
      if self.m_panel and not self.m_panel.isnil and self.createCallback then
        self.createCallback(self)
      end
    end)
  end
end
def.method("string", "=>", "string").makePath = function(self, prefabName)
  return string.format("Arts/Prefab/%s.prefab.u3dext", prefabName)
end
return GreetingCardShow.Commit()
