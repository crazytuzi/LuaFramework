local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local ChatPresetEdit = Lplus.Extend(ECPanelBase, "ChatPresetEdit")
local def = ChatPresetEdit.define
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
local CommonConfirmDlg = require("GUI.CommonConfirmDlg")
def.field("boolean").saved = true
def.field("table").editMap = nil
def.override().OnCreate = function(self)
  self.editMap = clone(ChatModule.Instance():LoadChatPreset())
  self:SetText()
  self:SetModal(true)
end
def.method().SetText = function(self)
  for i = 1, 6 do
    local label = self.m_panel:FindDirect(string.format("Img_Bg/Group_Preset%02d/Img_Label%02d/Label_Preset", i, i)):GetComponent("UILabel")
    if self.editMap[i] then
      label:set_text(self.editMap[i])
    else
      label:set_text("")
    end
  end
end
def.override().OnDestroy = function(self)
end
def.method("string").onClick = function(self, id)
  print("Preset click", id)
  if id == "Btn_Close" then
    if self.saved then
      self:DestroyPanel()
    else
      CommonConfirmDlg.ShowConfirmCoundDown(textRes.Chat[10], textRes.Chat[11], textRes.Chat[12], textRes.Chat[13], 0, 0, function(selection, tag)
        if selection == 1 then
          ChatModule.Instance().QuickChatMap = clone(self.editMap)
          ChatModule.Instance():SaveChatPreset()
          self.saved = true
          Toast(textRes.Chat[35])
          self:DestroyPanel()
        else
          self:DestroyPanel()
        end
      end, nil)
    end
  elseif id == "Btn_Save" then
    ChatModule.Instance().QuickChatMap = clone(self.editMap)
    ChatModule.Instance():SaveChatPreset()
    self.saved = true
    Toast(textRes.Chat[35])
  elseif id == "Btn_Default" then
    ChatModule.Instance().QuickChatMap = nil
    ChatModule.Instance():SaveChatPreset()
    self.editMap = clone(ChatModule.Instance():LoadChatPreset())
    self:SetText()
    self.saved = true
    Toast(textRes.Chat[36])
  end
end
def.method("string", "string").onTextChange = function(self, id, val)
  print("TextChange", id)
  if string.find(id, "Img_Label") then
    local index = tonumber(string.sub(id, 10))
    self.editMap[index] = val
    self.saved = false
  end
end
ChatPresetEdit.Commit()
return ChatPresetEdit
