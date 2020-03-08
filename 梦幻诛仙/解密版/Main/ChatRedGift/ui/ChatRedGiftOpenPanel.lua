local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local ChatRedGiftOpenPanel = Lplus.Extend(ECPanelBase, "ChatRedGiftOpenPanel")
local def = ChatRedGiftOpenPanel.define
local ChatRedGiftData = require("Main.ChatRedGift.ChatRedGiftData")
local instance
def.field("table").redGiftInfo = nil
def.static("=>", ChatRedGiftOpenPanel).Instance = function()
  if not instance then
    instance = ChatRedGiftOpenPanel()
    instance.m_TrigGC = true
  end
  return instance
end
def.method("table").ShowPanel = function(self, _redGiftInfo)
  if self:IsShow() or not _redGiftInfo then
    return
  end
  ChatRedGiftData.Instance():OpenChatRedGift(_redGiftInfo)
  self.redGiftInfo = _redGiftInfo
  self:CreatePanel(RESPATH.PREFAB_CHATREDGIFT_GET_PANEL, 2)
end
def.override().OnCreate = function(self)
  self:SetModal(true)
  self:UpdateUI()
end
def.override().OnDestroy = function(self)
  self.redGiftInfo = nil
end
def.method().UpdateUI = function(self)
  if self:IsShow() then
    local roleInfo = self.redGiftInfo.roleInfo
    local headObj = self.m_panel:FindDirect("Img_Bg/Img_BgTarget")
    local Img_IconHead = headObj:FindDirect("Img_IconHead")
    _G.SetAvatarIcon(Img_IconHead, roleInfo.avatarId)
    local frame = Img_IconHead:FindDirect("Img_IconBg")
    _G.SetAvatarFrameIcon(frame, roleInfo.avatarFrameId)
    local label_Lv = headObj:FindDirect("Img_IconHead/Label_LV"):GetComponent("UILabel")
    label_Lv:set_text(tostring(self.redGiftInfo.roleInfo.level))
    local label_Content = self.m_panel:FindDirect("Img_Bg/Img_BgContent/Label_Content"):GetComponent("UILabel")
    label_Content:set_text(self.redGiftInfo.content)
    local label_Tip = self.m_panel:FindDirect("Img_Bg/Label_Tip1"):GetComponent("UILabel")
    label_Tip:set_text(string.format(textRes.ChatRedGift[11], self.redGiftInfo.roleInfo.name))
  end
end
def.method("userdata").onClickObj = function(self, clickobj)
  local id = clickobj.name
  warn("onClickObj" .. id)
  if "Btn_Close" == id then
    self:DestroyPanel()
  elseif id == "Btn_Qiang" then
    self:GetRedGiftClick()
  elseif id == "Label_PaiHang" then
    Event.DispatchEvent(ModuleId.CHATREDGIFT, gmodule.notifyId.ChatRedGift.Rank_ChatRedGift, {
      redGiftInfo = self.redGiftInfo
    })
  end
end
def.method().GetRedGiftClick = function(self)
  gmodule.network.sendProtocol(require("netio.protocol.mzm.gsp.chat.CGetChatGiftReq").new(self.redGiftInfo.channelSubType, self.redGiftInfo.redGiftId))
  Event.DispatchEvent(ModuleId.CHATREDGIFT, gmodule.notifyId.ChatRedGift.Refresh_GangChatRedGift, {
    redGiftId = self.redGiftInfo.redGiftId
  })
  self:DestroyPanel()
end
ChatRedGiftOpenPanel.Commit()
return ChatRedGiftOpenPanel
