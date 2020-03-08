local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local ECMSDK = require("ProxySDK.ECMSDK")
local CommonConfirmDlg = require("GUI.CommonConfirmDlg")
local GUIUtils = require("GUI.GUIUtils")
local GangModule = require("Main.Gang.GangModule")
local ChatModule = require("Main.Chat.ChatModule")
local ChatConsts = require("netio.protocol.mzm.gsp.chat.ChatConsts")
local ShareComfirmPanel = Lplus.Extend(ECPanelBase, "ShareComfirmPanel")
local def = ShareComfirmPanel.define
def.const("table").SCENE = {
  SHARE = 1,
  SHOW = 2,
  COMPLAIN = 3,
  NORMAL = 4
}
def.field("number").m_Scene = 1
def.field("number").m_Param = 0
def.field("string").m_FriendOpenID = ""
def.field("string").m_SendName = ""
def.field("table").m_GameFriendInfo = nil
def.field("table").m_UIGO = nil
local instance
def.static("=>", ShareComfirmPanel).Instance = function()
  if not instance then
    instance = ShareComfirmPanel()
  end
  return instance
end
def.method("table").SetGameFriendInfo = function(self, gameFriendInfo)
  self.m_GameFriendInfo = gameFriendInfo
end
def.method("table").ShowPanel = function(self, data)
  if self:IsShow() then
    self:DestroyPanel()
  end
  self.m_Scene = data.type
  if data.id then
    self.m_FriendOpenID = GetStringFromOcts(data.id)
  end
  if data.param then
    self.m_Param = data.param
  end
  self:CreatePanel(RESPATH.PREFAB_SHARE_COMFIRM_PANEL, GUILEVEL.MUTEX)
  self:SetModal(true)
end
def.override().OnCreate = function(self)
  self:InitUI()
  self:InitData()
  self:Update()
  GameUtil.AddGlobalTimer(30, true, function()
    self:DestroyPanel()
  end)
end
def.method().CheckAndAddFriend = function(self)
  if self.m_Scene == ShareComfirmPanel.SCENE.SHARE then
    if self.m_GameFriendInfo then
      do
        local roleid = self.m_GameFriendInfo.roleid
        local zoneid = self.m_GameFriendInfo.zoneid
        local nickName = GetStringFromOcts(self.m_GameFriendInfo.nickname)
        local roleName = GetStringFromOcts(self.m_GameFriendInfo.rolename)
        local FriendModule = require("Main.friend.FriendModule")
        local Network = require("netio.Network")
        if not FriendModule.Instance():IsFriend(roleid) and Network.m_zoneid == zoneid then
          CommonConfirmDlg.ShowConfirmCoundDown(textRes.Friend[1], textRes.RelationShipChain[53]:format(nickName, roleName), "", "", 0, 0, function(selection, tag)
            if selection == 1 then
              require("Main.friend.ui.FriendMainDlg").AddFriend(roleid)
            end
          end, nil)
        end
      end
    else
      Debug.LogWarning("There is no game Friend data")
    end
  end
end
def.override().OnDestroy = function(self)
  self:CheckAndAddFriend()
  self.m_Scene = ShareComfirmPanel.SCENE.SHARE
  self.m_Param = 0
  self.m_FriendOpenID = ""
  self.m_SendName = ""
  self.m_GameFriendInfo = nil
  self.m_UIGO = nil
end
def.method().Tell = function(self)
  if self.m_Scene == ShareComfirmPanel.SCENE.SHARE then
    if _G.LoginPlatform == MSDK_LOGIN_PLATFORM.WX then
      CommonConfirmDlg.ShowConfirmCoundDown(textRes.RelationShipChain[1], textRes.RelationShipChain[2], "", "", 0, 0, function(selection, tag)
        if selection == 1 then
          ECMSDK.SendToGameFriend(1, self.m_FriendOpenID, textRes.RelationShipChain[33]:format(self.m_SendName), textRes.RelationShipChain[34], textRes.RelationShipChain[28], 3, "")
          self:DestroyPanel()
        end
      end, nil)
    else
      ECMSDK.SendToGameFriend(0, self.m_FriendOpenID, textRes.RelationShipChain[18], textRes.RelationShipChain[19], textRes.RelationShipChain[28], 3, "")
      self:DestroyPanel()
    end
  else
    local hasGang = GangModule.Instance():HasGang()
    if not hasGang then
      Toast(textRes.activity[353])
      return
    end
    local tip = textRes.activity[356]
    if self.m_Scene == ShareComfirmPanel.SCENE.SHOW then
      tip = textRes.activity[354]:format(self.m_Param)
    elseif self.m_Scene == ShareComfirmPanel.SCENE.NORMAL then
      tip = textRes.activity[355]:format(self.m_Param)
    end
    ChatModule.Instance():SendChannelMsg(tip, ChatConsts.CHANNEL_FACTION, false)
    self:DestroyPanel()
  end
end
def.method("string").onClick = function(self, id)
  if id == "Btn_NextTime" then
    self:DestroyPanel()
  elseif id == "Btn_Tell" then
    self:Tell()
  end
end
def.method().InitData = function(self)
  local heroProp = require("Main.Hero.Interface").GetBasicHeroProp()
  if heroProp then
    self.m_SendName = heroProp.name
  end
end
def.method().InitUI = function(self)
  self.m_UIGO = {}
  self.m_UIGO.Img = self.m_panel:FindDirect("Img_Bg/Img_ZS1")
  self.m_UIGO.BtnLabel = self.m_panel:FindDirect("Img_Bg/Btn_Tell/Label")
  self.m_UIGO.Label1 = self.m_panel:FindDirect("Img_Bg/Label_1")
  self.m_UIGO.Label2 = self.m_panel:FindDirect("Img_Bg/Label_2")
end
def.method().Update = function(self)
  local btnLabelGO = self.m_UIGO.BtnLabel
  local labelGO1 = self.m_UIGO.Label1
  local labelGO2 = self.m_UIGO.Label2
  local btnDesc = textRes.activity[344]
  local desc1 = textRes.activity[349]
  local desc2 = textRes.activity[350]
  if self.m_Scene == ShareComfirmPanel.SCENE.SHOW then
    btnDesc = textRes.activity[345]
    desc1 = textRes.activity[347]
    desc2 = textRes.activity[351]
  elseif self.m_Scene == ShareComfirmPanel.SCENE.COMPLAIN then
    btnDesc = textRes.activity[346]
    desc1 = textRes.activity[348]
    desc2 = textRes.activity[352]
  elseif self.m_Scene == ShareComfirmPanel.SCENE.NORMAL then
    btnDesc = textRes.activity[358]
    desc1 = textRes.activity[359]
    desc2 = textRes.activity[360]
  end
  GUIUtils.SetText(btnLabelGO, btnDesc)
  GUIUtils.SetText(labelGO1, desc1)
  GUIUtils.SetText(labelGO2, desc2)
end
return ShareComfirmPanel.Commit()
