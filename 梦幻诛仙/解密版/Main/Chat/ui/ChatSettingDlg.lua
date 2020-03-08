local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local ChatSettingDlg = Lplus.Extend(ECPanelBase, "ChatSettingDlg")
local def = ChatSettingDlg.define
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
def.const("table").NAME2ID = {
  Btn_SelectlFaction01 = ChatModule.SettingEnum.AUTOAUDIOGANG,
  Btn_SelectTeam01 = ChatModule.SettingEnum.AUTOAUDIOTEAM,
  Btn_SelectRecent01 = ChatModule.SettingEnum.AUTOAUDIOMAP,
  Btn_SelectWorld01 = ChatModule.SettingEnum.AUTOAUDIOWORLD,
  Btn_SelectFaction02 = ChatModule.SettingEnum.AVOIDGANG,
  Btn_SelectTeam02 = ChatModule.SettingEnum.AVOIDTEAM,
  Btn_SelectRecent02 = ChatModule.SettingEnum.AVOIDMAP,
  Btn_SelectWorld02 = ChatModule.SettingEnum.AVOIDWORLD
}
def.const("table").ID2PATH = {
  [ChatModule.SettingEnum.AUTOAUDIOGANG] = "Img_BgFriendTest/Btn_SelectlFaction01",
  [ChatModule.SettingEnum.AUTOAUDIOTEAM] = "Img_BgFriendTest/Btn_SelectTeam01",
  [ChatModule.SettingEnum.AUTOAUDIOMAP] = "Img_BgFriendTest/Btn_SelectRecent01",
  [ChatModule.SettingEnum.AUTOAUDIOWORLD] = "Img_BgFriendTest/Btn_SelectWorld01",
  [ChatModule.SettingEnum.AVOIDGANG] = "Img_BgFriendTest/Btn_SelectFaction02",
  [ChatModule.SettingEnum.AVOIDTEAM] = "Img_BgFriendTest/Btn_SelectTeam02",
  [ChatModule.SettingEnum.AVOIDMAP] = "Img_BgFriendTest/Btn_SelectRecent02",
  [ChatModule.SettingEnum.AVOIDWORLD] = "Img_BgFriendTest/Btn_SelectWorld02"
}
def.field("boolean").dirty = false
def.field("number").mEffect = 0
def.method("number").ShowPanel = function(self, effect)
  if self:IsShow() then
    return
  end
  self.mEffect = effect
  self:CreatePanel(RESPATH.PREFAB_CHAT_SETTING, 2)
end
def.override().OnCreate = function(self)
  self:SetModal(true)
  local settingMap = ChatModule.Instance().SettingMap
  for k, v in pairs(settingMap) do
    local toggleName = ChatSettingDlg.ID2PATH[k]
    if toggleName then
      local toggle = self.m_panel:FindDirect(toggleName):GetComponent("UIToggle")
      toggle:set_value(v == 1)
    end
  end
  self:SetNewOrFaction()
  if self.mEffect ~= 0 then
    self:AddEffect()
  end
end
def.override().OnDestroy = function(self)
  if self.dirty then
    ChatModule.Instance():SaveChatSetting()
  end
  ChatModule.Instance():SaveChatSetting()
  self.mEffect = 0
  self.dirty = false
end
def.method().AddEffect = function(self)
  local realPath = "panel_chatsetting/" .. ChatSettingDlg.ID2PATH[self.mEffect]
  local GUIUtils = require("GUI.GUIUtils")
  GUIUtils.AddLightEffectToPanel(realPath, GUIUtils.Light.Round)
end
def.method().SetNewOrFaction = function(self)
  local blockLabel = self.m_panel:FindDirect("Lable_ChannelFaction01")
  local voiceLabel = self.m_panel:FindDirect("Lable_ChannellFaction02")
  local hasGang = require("Main.Gang.GangModule").Instance():HasGang()
  local channel = ""
  if hasGang then
    channel = textRes.Chat[33]
  else
    channel = textRes.Chat[34]
  end
  blockLabel:GetComponent("UILabel"):set_text(channel)
  voiceLabel:GetComponent("UILabel"):set_text(channel)
end
def.method("string").onClick = function(self, id)
  if id == "Btn_Close" then
    self:DestroyPanel()
  elseif id == "Btn_BlockList" then
    self:DestroyPanel()
    Event.DispatchEvent(ModuleId.CHAT, gmodule.notifyId.Chat.ShowShieldList, nil)
  elseif id == "Btn_AtBox" then
    self:DestroyPanel()
    Event.DispatchEvent(ModuleId.CHAT, gmodule.notifyId.Chat.CHAT_BOX_BTN_CLICKED, nil)
  end
end
def.method("string", "boolean").onToggle = function(self, id, active)
  self.dirty = true
  local ID = ChatSettingDlg.NAME2ID[id]
  local settingMap = ChatModule.Instance().SettingMap
  if ID ~= nil then
    settingMap[ID] = active and 1 or 0
  end
  local ECMSDK = require("ProxySDK.ECMSDK")
  ECMSDK.SendTLogToServer(_G.TLOGTYPE.CHATSETTING, {
    id,
    active and 1 or 0
  })
end
ChatSettingDlg.Commit()
return ChatSettingDlg
