local CUR_CLASS_NAME = (...)
local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local AwardPanelNodeBase = require("Main.Award.ui.AwardPanelNodeBase")
local GiftNode = Lplus.Extend(AwardPanelNodeBase, CUR_CLASS_NAME)
local GiftMgr = require("Main.Award.mgr.GiftMgr")
local LevelUpAwardMgr = require("Main.Award.mgr.LevelUpAwardMgr")
local GiftType = require("consts.mzm.gsp.signaward.confbean.GiftType")
local GUIUtils = require("GUI.GUIUtils")
local def = GiftNode.define
def.field("table").uiObjs = nil
def.override(ECPanelBase, "userdata").Init = function(self, base, node)
  AwardPanelNodeBase.Init(self, base, node)
  self.awardType = GiftType.GIFT_CODE
end
def.override().OnShow = function(self)
  self:InitUI()
  self:UpdateUI()
  Event.RegisterEvent(ModuleId.AWARD, gmodule.notifyId.Award.USE_GIFT_CARD_SUCCESS, GiftNode.OnUseGiftCardSuccess)
end
def.override().OnHide = function(self)
  Event.UnregisterEvent(ModuleId.AWARD, gmodule.notifyId.Award.USE_GIFT_CARD_SUCCESS, GiftNode.OnUseGiftCardSuccess)
  self:Clear()
end
def.override("=>", "boolean").IsOpen = function(self)
  local isMSDK = ClientCfg.GetSDKType() == ClientCfg.SDKTYPE.MSDK
  return not isMSDK
end
def.override("userdata").onClickObj = function(self, obj)
  local id = obj.name
  if id == "Btn_Get" then
  else
    self:onClick(id)
  end
end
def.override("string").onClick = function(self, id)
  if id == "Btn_Active" then
    self:OnDrawAwardButtonClicked()
  end
end
def.override("=>", "boolean").IsHaveNotifyMessage = function(self)
  return false
end
def.override().InitUI = function(self)
  self.uiObjs = {}
  self.uiObjs.Img_BgInput = self.m_node:FindDirect("Img_BgInput")
  self.uiObjs.InputLabel = self.uiObjs.Img_BgInput:FindDirect("Label")
  self.uiObjs.InputLabel:GetComponent("UIInput").value = ""
  local jumpLabel = self.m_node:FindDirect("Label")
  local jumpToWEB = self:IsJumpToWEB()
  local notJumpToWEB = not jumpToWEB
  GUIUtils.SetActive(self.uiObjs.Img_BgInput, notJumpToWEB)
  GUIUtils.SetActive(self.uiObjs.InputLabel, notJumpToWEB)
  GUIUtils.SetActive(jumpLabel, jumpToWEB)
  local Btn_URL = self.m_node:FindChildByPrefix("Btn_URL_", false)
  if Btn_URL == nil then
    Btn_URL = self.m_node:FindDirect("Btn_Active")
  end
  local btnText
  if notJumpToWEB then
    Btn_URL.name = "Btn_Active"
    btnText = textRes.Award[22]
  else
    btnText = textRes.Award[23]
  end
  local Label = Btn_URL:FindDirect("Label")
  GUIUtils.SetText(Label, btnText)
end
def.method().UpdateUI = function(self)
end
def.method("=>", "boolean").IsJumpToWEB = function(self)
  local isMSDK = ClientCfg.GetSDKType() == ClientCfg.SDKTYPE.MSDK
  return isMSDK and true or false
end
def.method().OnDrawAwardButtonClicked = function(self)
  local giftCode = self.uiObjs.InputLabel:GetComponent("UIInput").value
  if giftCode == "" then
    Toast(textRes.Award[6])
    return
  end
  if GiftMgr.Instance():ExchangeGift(giftCode) == GiftMgr.CResult.GIFT_CODE_FORMAT_ERROR then
    Toast(textRes.Award[9])
  end
end
def.static("table", "table").OnUseGiftCardSuccess = function(params)
  local AwardPanel = require("Main.Award.ui.AwardPanel")
  local instance = AwardPanel.Instance().nodes[AwardPanel.NodeId.Gift]
  instance.uiObjs.InputLabel:GetComponent("UIInput").value = ""
end
def.method().Clear = function(self)
  self.uiObjs = nil
end
return GiftNode.Commit()
