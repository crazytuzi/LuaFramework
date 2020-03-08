local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local InviteAwardPanel = Lplus.Extend(ECPanelBase, "InviteAwardPanel")
local PostInviteInfoPanel = require("Main.Award.ui.PostInviteInfoPanel")
local RelationShipChainMgr = require("Main.RelationShipChain.RelationShipChainMgr")
local ItemTipsMgr = require("Main.Item.ItemTipsMgr")
local GUIUtils = require("GUI.GUIUtils")
local ItemUtils = require("Main.Item.ItemUtils")
local ECMSDK = require("ProxySDK.ECMSDK")
local def = InviteAwardPanel.define
local Vector = require("Types.Vector")
local ECGUIMan = require("GUI.ECGUIMan")
def.field("table").m_UIGO = nil
local instance
def.static("=>", InviteAwardPanel).Instance = function()
  if not instance then
    instance = InviteAwardPanel()
  end
  return instance
end
def.static("table", "table").OnInviteFriendsGift = function(p1, p2)
  warn("OnInviteFriendsGift~~~~~~~~~~")
  if instance.m_panel and not instance.m_panel.isnil then
    instance:UpdateUI()
  end
end
def.method().ShowPanel = function(self)
  if self.m_panel and not self.m_panel.isnil then
    self:DestroyPanel()
  end
  self:CreatePanel(RESPATH.PREFAB_AWARD_INVITEAWARD_PANEL, 0)
end
def.override().OnCreate = function(self)
  self:InitUI()
  self:UpdateUI()
  Event.RegisterEvent(ModuleId.RELATIONSHIPCHAIN, gmodule.notifyId.RelationShipChain.NotifyInviteFriendsGift, InviteAwardPanel.OnInviteFriendsGift)
end
def.method().InitUI = function(self)
  self.m_UIGO = {}
  self.m_UIGO.AwardNum = self.m_panel:FindDirect("Group_TuiGuangRen/Group_Center/Img_Left/Label/Label")
  self.m_UIGO.YuanbaoNum = self.m_panel:FindDirect("Group_TuiGuangRen/Group_Center/Img_Right/Bg_YuanBaoNum/Label_Num")
  self.m_UIGO.PersonNum = self.m_panel:FindDirect("Group_TuiGuangRen/Group_Bottom/Label_Invite/Label_Num")
end
def.method().UpdateUI = function(self)
  local inviteFriendData = RelationShipChainMgr.GetInviteFriendData()
  if inviteFriendData.award_gift_times then
    GUIUtils.SetText(self.m_UIGO.AwardNum, tostring(inviteFriendData.award_gift_times))
  end
  if inviteFriendData.rebate_bind_yuanbao then
    GUIUtils.SetText(self.m_UIGO.YuanbaoNum, inviteFriendData.rebate_bind_yuanbao:tostring())
  end
  if inviteFriendData.invitee_num then
    GUIUtils.SetText(self.m_UIGO.PersonNum, tostring(inviteFriendData.invitee_num))
  end
end
def.override().OnDestroy = function(self)
  self.m_UIGO = nil
  Event.UnregisterEvent(ModuleId.RELATIONSHIPCHAIN, gmodule.notifyId.RelationShipChain.NotifyInviteFriendsGift, InviteAwardPanel.OnInviteFriendsGift)
end
def.method().Invite = function(self)
  local sdktype = ClientCfg.GetSDKType()
  if sdktype == ClientCfg.SDKTYPE.MSDK then
    if _G.LoginPlatform == MSDK_LOGIN_PLATFORM.WX and not ECMSDK.IsPlatformInstalled(_G.MSDK_LOGIN_PLATFORM.WX) then
      Toast(textRes.Common[311])
      return
    elseif _G.LoginPlatform == MSDK_LOGIN_PLATFORM.QQ and not ECMSDK.IsPlatformInstalled(_G.MSDK_LOGIN_PLATFORM.QQ) then
      Toast(textRes.Common[310])
      return
    elseif _G.LoginPlatform == MSDK_LOGIN_PLATFORM.GUEST then
      Toast(textRes.Common[313])
      return
    end
    local ShareTipsPanel = require("Main.RelationShipChain.ui.ShareTipsPanel")
    ShareTipsPanel.Instance():ShowPanel(false)
  else
    local ECUniSDK = require("ProxySDK.ECUniSDK")
    local inviteFriendData = RelationShipChainMgr.GetInviteFriendData()
    if ECUniSDK.Instance():SDKIS(ECUniSDK.CHANNELTYPE.EFUNTW) or ECUniSDK.Instance():SDKIS(ECUniSDK.CHANNELTYPE.EFUNHK) then
      ECUniSDK.Instance():Share({
        name = textRes.RelationShipChain[64],
        caption = textRes.RelationShipChain[65],
        shareDesc = textRes.RelationShipChain[66] .. GetStringFromOcts(inviteFriendData.invite_code),
        type = ECUniSDK.SHARETYPE.FB
      })
    elseif ECUniSDK.Instance():SDKIS(ECUniSDK.CHANNELTYPE.LOONG) then
      ECUniSDK.Instance():Share({
        title = textRes.RelationShipChain[101],
        desc = textRes.RelationShipChain[102]:format(GetStringFromOcts(inviteFriendData.invite_code))
      })
    end
  end
end
def.method("userdata").onClickObj = function(self, obj)
  local id = obj.name
  if id == "Btn_FaBu" then
    PostInviteInfoPanel.Instance():ShowPanel()
  elseif id == "Btn_Invite" then
    self:Invite()
  elseif id == "Btn_TipsLeft" then
    local tipsID = RelationShipChainMgr.GetInviteFriendConstant("TIPS_ID_3")
    local content = require("Main.Common.TipsHelper").GetHoverTip(tipsID)
    require("GUI.CommonUITipsDlg").ShowCommonTip(content, {x = 0, y = 0})
  elseif id == "Btn_TipsRight" then
    local tipsID = RelationShipChainMgr.GetInviteFriendConstant("TIPS_ID_4")
    local content = require("Main.Common.TipsHelper").GetHoverTip(tipsID)
    require("GUI.CommonUITipsDlg").ShowCommonTip(content, {x = 0, y = 0})
  elseif id == "Btn_Tips" then
    local tipsID = RelationShipChainMgr.GetInviteFriendConstant("TIPS_ID_2")
    local content = require("Main.Common.TipsHelper").GetHoverTip(tipsID)
    require("GUI.CommonUITipsDlg").ShowCommonTip(content, {x = 0, y = 0})
  elseif id == "Texture" then
    local itemId = RelationShipChainMgr.GetInviteFriendConstant("TIPS_ID_1")
    local position = obj:get_position()
    local screenPos = WorldPosToScreen(position.x, position.y)
    local sprite = obj:GetComponent("UIWidget")
    ItemTipsMgr.Instance():ShowBasicTips(itemId, screenPos.x, screenPos.y, sprite:get_width(), sprite:get_height(), -1, false)
  elseif id == "Btn_Get1" then
    local num = self.m_UIGO.AwardNum:GetComponent("UILabel").text
    if num == "0" then
      Toast(textRes.Common[411])
      return
    end
    RelationShipChainMgr.GetInviteFriendsGift({})
  elseif id == "Btn_Get2" then
    local num = self.m_UIGO.YuanbaoNum:GetComponent("UILabel").text
    if num == "0" then
      Toast(textRes.Common[411])
      return
    end
    RelationShipChainMgr.GetInviteFriendsRebateBindYuanbao({})
  end
end
return InviteAwardPanel.Commit()
