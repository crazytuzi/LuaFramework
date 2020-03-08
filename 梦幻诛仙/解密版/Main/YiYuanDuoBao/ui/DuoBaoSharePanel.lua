local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local DuoBaoSharePanel = Lplus.Extend(ECPanelBase, "DuoBaoSharePanel")
local GUIUtils = require("GUI.GUIUtils")
local ItemUtils = require("Main.Item.ItemUtils")
local def = DuoBaoSharePanel.define
def.field("number").m_itemId = 0
def.static("number").ShowDuoBaoSharePanel = function(itemId)
  local self = DuoBaoSharePanel()
  self.m_itemId = itemId
  self:CreatePanel(RESPATH.PREFAB_YIYUANDUOBAO_SHARE_PANEL, 0)
  self:SetModal(true)
end
def.override().OnCreate = function(self)
  self:UpdateItem()
end
def.override().OnDestroy = function(self)
end
def.override("boolean").OnShow = function(self, show)
end
def.method().UpdateItem = function(self)
  local itemBase = ItemUtils.GetItemBase(self.m_itemId)
  if itemBase then
    local iconBg = self.m_panel:FindDirect("Img_Bg0/Img_BgIcon1")
    local icon = iconBg:FindDirect("Texture_Icon")
    local nameLbl = self.m_panel:FindDirect("Img_Bg0/Label_ItemName")
    iconBg:GetComponent("UISprite"):set_spriteName(string.format("Cell_%2d", itemBase.namecolor))
    GUIUtils.FillIcon(icon:GetComponent("UITexture"), itemBase.icon)
    nameLbl:GetComponent("UILabel"):set_text(itemBase.name)
  end
end
def.method("string").onClick = function(self, id)
  if id == "Btn_Close" then
    self:DestroyPanel()
  elseif id == "Btn_ShareGang" then
    self:ShareInGang()
  elseif id == "Btn_ShareWorld" then
    self:ShareInWorld()
  elseif id == "Texture_Icon" then
    local icon = self.m_panel:FindDirect("Img_Bg0/Img_BgIcon1/Texture_Icon")
    require("Main.Item.ItemTipsMgr").Instance():ShowBasicTipsWithGO(self.m_itemId, icon, 0, false)
  end
end
def.method().ShareInGang = function(self)
  local ChatModule = require("Main.Chat.ChatModule")
  local ChatConst = require("netio.protocol.mzm.gsp.chat.ChatConsts")
  local itemBase = ItemUtils.GetItemBase(self.m_itemId)
  if itemBase then
    local content = string.format(textRes.YiYuanDuoBao[27], itemBase.name)
    ChatModule.Instance():SendChannelMsg(content, ChatConst.CHANNEL_FACTION, false)
  end
end
def.method().ShareInWorld = function(self)
  local ChatModule = require("Main.Chat.ChatModule")
  local ChatConst = require("netio.protocol.mzm.gsp.chat.ChatConsts")
  local itemBase = ItemUtils.GetItemBase(self.m_itemId)
  if itemBase then
    local content = string.format(textRes.YiYuanDuoBao[27], itemBase.name)
    ChatModule.Instance():SendChannelMsg(content, ChatConst.CHANNEL_WORLD, false)
  end
end
DuoBaoSharePanel.Commit()
return DuoBaoSharePanel
