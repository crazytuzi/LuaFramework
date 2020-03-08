local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local ChatPresetDlg = Lplus.Extend(ECPanelBase, "ChatPresetDlg")
local def = ChatPresetDlg.define
local GUIUtils = require("GUI.GUIUtils")
local ChatModule = Lplus.ForwardDeclare("ChatModule")
local Vector = require("Types.Vector")
local ItemModule = require("Main.Item.ItemModule")
local ItemUtils = require("Main.Item.ItemUtils")
local MathHelper = require("Common.MathHelper")
local ItemTipsMgr = require("Main.Item.ItemTipsMgr")
local PetInterface = require("Main.Pet.Interface")
local PubroleInterface = require("Main.Pubrole.PubroleInterface")
local ChatMemo = require("Main.Chat.ChatMemo")
local HtmlHelper = require("Main.Chat.HtmlHelper")
local ChatUtils = require("Main.Chat.ChatUtils")
def.static("function").ShowChatPreset = function(callback)
  local dlg = ChatPresetDlg()
  dlg:SetSelectCallback(callback)
  dlg:CreatePanel(RESPATH.PREFAB_CHAT_PRESET, 2)
end
def.field("function").SelectCallback = nil
def.override().OnCreate = function(self)
  self:SetOutTouchDisappear()
  local QuickChatMap = ChatModule.Instance():LoadChatPreset()
  for i = 1, 6 do
    local label = self.m_panel:FindDirect(string.format("Img_Bg/Group_Preset%02d/Img_Label%02d/Label_Preset", i, i)):GetComponent("UILabel")
    if QuickChatMap[i] then
      label:set_text(QuickChatMap[i])
    else
      label:set_text("")
    end
  end
end
def.method("function").SetSelectCallback = function(self, func)
  self.SelectCallback = func
end
def.override().OnDestroy = function(self)
end
def.method("string").onClick = function(self, id)
  print("Preset click", id)
  if id == "Btn_Edit" then
    local PresetEdit = require("Main.Chat.ui.ChatPresetEdit")
    local dlg = PresetEdit()
    dlg:CreatePanel(RESPATH.PREFAB_CHAT_PRESET_EDIT, 1)
    self:DestroyPanel()
  elseif string.find(id, "Img_Label") then
    local index = tonumber(string.sub(id, 10))
    print("index", index)
    local QuickChatMap = ChatModule.Instance().QuickChatMap
    local sentence = QuickChatMap[index]
    if sentence and self.SelectCallback then
      self.SelectCallback(sentence)
    end
    self:DestroyPanel()
  end
end
ChatPresetDlg.Commit()
return ChatPresetDlg
