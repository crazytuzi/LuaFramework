local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local GameCommunityBtnPanel = Lplus.Extend(ECPanelBase, "GameCommunityBtnPanel")
local GUIUtils = require("GUI.GUIUtils")
local ECPanelBase = require("GUI.ECPanelBase")
local Vector = require("Types.Vector")
local ECMSDK = require("ProxySDK.ECMSDK")
local ECQQEC = require("ProxySDK.ECQQEC")
local Network = require("netio.Network")
local RelationShipChainMgr = require("Main.RelationShipChain.RelationShipChainMgr")
local Feature = require("netio.protocol.mzm.gsp.open.ModuleFunSwitchInfo")
local FeatureOpenListModule = require("Main.FeatureOpenList.FeatureOpenListModule")
local RecallModule = require("Main.Recall.RecallModule")
local def = GameCommunityBtnPanel.define
local IsEvaluation = function(...)
  return GameUtil.IsEvaluation()
end
def.const("table").CommunityUIDef = {
  qq = {
    {
      btnName = "Btn_Buluo",
      hide = IsEvaluation() or _G.IsCrossingServer()
    },
    {
      btnName = "Btn_RankFriends",
      hide = IsEvaluation() or _G.IsCrossingServer()
    },
    {
      btnName = "Btn_Live",
      hide = platform ~= 1 or _G.IsCrossingServer()
    },
    {
      btnName = "Btn_XinYue",
      hide = IsEvaluation() or ClientCfg.IsOtherChannel() or _G.IsCrossingServer()
    },
    {
      btnName = "Btn_QiErDianJing",
      hide = IsEvaluation() or _G.IsCrossingServer()
    },
    {
      btnName = "Btn_KeFu",
      hide = IsEvaluation() or _G.IsCrossingServer() or ClientCfg.IsOtherChannel()
    },
    {
      btnName = "Btn_WeiSheQu",
      hide = IsEvaluation() or _G.IsCrossingServer()
    },
    {
      btnName = "Btn_Gift",
      hide = not ClientCfg.IsOtherChannel() or _G.IsCrossingServer()
    },
    {
      btnName = "Btn_CallBack",
      hide = IsEvaluation()
    }
  },
  wechat = {
    {
      btnName = "Btn_GameCircle",
      hide = IsEvaluation() or _G.IsCrossingServer()
    },
    {
      btnName = "Btn_SubscribeRemind",
      hide = true
    },
    {
      btnName = "Btn_RankFriends",
      hide = IsEvaluation() or _G.IsCrossingServer()
    },
    {
      btnName = "Btn_Live",
      hide = platform ~= 1 or _G.IsCrossingServer()
    },
    {
      btnName = "Btn_XinYue",
      hide = IsEvaluation() or ClientCfg.IsOtherChannel() or _G.IsCrossingServer()
    },
    {
      btnName = "Btn_QiErDianJing",
      hide = IsEvaluation() or _G.IsCrossingServer()
    },
    {
      btnName = "Btn_KeFu",
      hide = IsEvaluation() or _G.IsCrossingServer() or ClientCfg.IsOtherChannel()
    },
    {
      btnName = "Btn_WeiSheQu",
      hide = IsEvaluation() or _G.IsCrossingServer()
    },
    {
      btnName = "Btn_Gift",
      hide = not ClientCfg.IsOtherChannel() or _G.IsCrossingServer()
    },
    {
      btnName = "Btn_CallBack",
      hide = IsEvaluation()
    },
    {
      btnName = "Btn_GongZhongHao",
      hide = IsEvaluation()
    }
  },
  guest = {
    {
      btnName = "Btn_GameCircle",
      hide = true
    },
    {
      btnName = "Btn_SubscribeRemind",
      hide = true
    },
    {
      btnName = "Btn_RankFriends",
      hide = true
    },
    {
      btnName = "Btn_Live",
      hide = platform ~= 1 or _G.IsCrossingServer()
    },
    {btnName = "Btn_XinYue", hide = true},
    {
      btnName = "Btn_QiErDianJing",
      hide = true
    },
    {btnName = "Btn_KeFu", hide = true},
    {
      btnName = "Btn_WeiSheQu",
      hide = true
    },
    {btnName = "Btn_Gift", hide = true},
    {
      btnName = "Btn_CallBack",
      hide = true
    }
  },
  facebook = {
    {
      btnName = "Btn_GameCircle",
      hide = true
    },
    {
      btnName = "Btn_SubscribeRemind",
      hide = true
    },
    {
      btnName = "Btn_RankFriends",
      hide = false
    },
    {btnName = "Btn_Live", hide = true},
    {btnName = "Btn_XinYue", hide = true},
    {
      btnName = "Btn_QiErDianJing",
      hide = true
    },
    {btnName = "Btn_KeFu", hide = true},
    {
      btnName = "Btn_WeiSheQu",
      hide = true
    },
    {btnName = "Btn_Gift", hide = true},
    {
      btnName = "Btn_CallBack",
      hide = true
    }
  },
  efun = {
    {btnName = "Btn_Buluo", hide = true},
    {
      btnName = "Btn_RankFriends",
      hide = true
    },
    {btnName = "Btn_Live", hide = true},
    {
      btnName = "Btn_QiErDianJing",
      hide = true
    },
    {btnName = "Btn_KeFu", hide = false},
    {btnName = "Btn_Gift", hide = true},
    {
      btnName = "Btn_CallBack",
      hide = true
    }
  },
  win = {
    {btnName = "Btn_Buluo"},
    {
      btnName = "Btn_RankFriends",
      hide = IsEvaluation() or platform ~= 0
    },
    {
      btnName = "Btn_Live",
      hide = platform ~= 1
    },
    {
      btnName = "Btn_QiErDianJing"
    },
    {
      btnName = "Btn_KeFu",
      hide = IsEvaluation() or _G.LoginPlatform == MSDK_LOGIN_PLATFORM.NON
    },
    {
      btnName = "Btn_Gift",
      hide = not ClientCfg.IsOtherChannel()
    },
    {
      btnName = "Btn_CallBack",
      hide = false
    }
  }
}
def.field("string").community = ""
def.field("table").uiObjs = nil
def.field("userdata").anchorGO = nil
def.field("number").lastDestroyTime = 0
local instance
def.static("=>", GameCommunityBtnPanel).Instance = function()
  if instance == nil then
    instance = GameCommunityBtnPanel()
  end
  return instance
end
def.static("table", "table").OnFeatureOpenChange = function(p)
  if p.feature == Feature.TYPE_ESPORTS then
    GUIUtils.SetActive(self.uiObjs.qedjBtn, p.open)
  elseif p.feature == Feature.TYPE_IOS_REPLAYKIT then
    GUIUtils.SetActive(self.uiObjs.liveBtn, p.open)
  elseif p.feature == Feature.TYPE_RECALL_FRIEND then
    GUIUtils.SetActive(self.uiObjs.callBackBtn, p.open)
  end
end
def.method("userdata").ShowPanel = function(self, anchorGO)
  if self.m_panel then
    self:DestroyPanel()
  end
  self.anchorGO = anchorGO
  self:CreatePanel(RESPATH.PREFAB_GAME_COMMUNITY_BTN_PANEL, 0)
  self:SetOutTouchDisappear()
end
def.method("=>", "boolean").IsJustDestroy = function(self)
  return math.abs(GameUtil.GetTickCount() - self.lastDestroyTime) < 500
end
def.override().OnCreate = function(self)
  self:InitCommunity()
  self:InitUI()
  Event.RegisterEvent(ModuleId.FIGHT, gmodule.notifyId.Fight.ENTER_FIGHT, GameCommunityBtnPanel.OnEnterFight)
  Event.RegisterEvent(ModuleId.FEATURE, gmodule.notifyId.Feature.FeatureOpenChange, GameCommunityBtnPanel.OnFeatureOpenChange)
  self.m_bCanMoveBackward = true
  Event.RegisterEvent(ModuleId.RELATIONSHIPCHAIN, gmodule.notifyId.RelationShipChain.NotifyRecallFriendBigGiftAward, GameCommunityBtnPanel.OnNotifyRecallFriendBigGiftAward)
  Event.RegisterEvent(ModuleId.RELATIONSHIPCHAIN, gmodule.notifyId.RelationShipChain.NotifyRecallFriendSignAward, GameCommunityBtnPanel.OnNotifyRecallFriendSignAward)
  Event.RegisterEvent(ModuleId.RECALL, gmodule.notifyId.Recall.RECALL_AFK_INFO_CHANGE, GameCommunityBtnPanel.OnRecallInfoChange)
  Event.RegisterEvent(ModuleId.RECALL, gmodule.notifyId.Recall.HERO_RETURN_INFO_CHANGE, GameCommunityBtnPanel.OnRecallInfoChange)
  Event.RegisterEvent(ModuleId.RECALL, gmodule.notifyId.Recall.BINDED_FRIEND_ACTIVE_CHANGE, GameCommunityBtnPanel.OnRecallInfoChange)
  Event.RegisterEvent(ModuleId.RECALL, gmodule.notifyId.Recall.BINDED_FRIEND_REBATE_CHANGE, GameCommunityBtnPanel.OnRecallInfoChange)
end
def.override().OnDestroy = function(self)
  Event.UnregisterEvent(ModuleId.FIGHT, gmodule.notifyId.Fight.ENTER_FIGHT, GameCommunityBtnPanel.OnEnterFight)
  Event.UnregisterEvent(ModuleId.FEATURE, gmodule.notifyId.Feature.FeatureOpenChange, GameCommunityBtnPanel.OnFeatureOpenChange)
  Event.UnregisterEvent(ModuleId.RELATIONSHIPCHAIN, gmodule.notifyId.RelationShipChain.NotifyRecallFriendBigGiftAward, GameCommunityBtnPanel.OnNotifyRecallFriendBigGiftAward)
  Event.UnregisterEvent(ModuleId.RELATIONSHIPCHAIN, gmodule.notifyId.RelationShipChain.NotifyRecallFriendSignAward, GameCommunityBtnPanel.OnNotifyRecallFriendSignAward)
  Event.UnregisterEvent(ModuleId.RECALL, gmodule.notifyId.Recall.RECALL_AFK_INFO_CHANGE, GameCommunityBtnPanel.OnRecallInfoChange)
  Event.UnregisterEvent(ModuleId.RECALL, gmodule.notifyId.Recall.HERO_RETURN_INFO_CHANGE, GameCommunityBtnPanel.OnRecallInfoChange)
  Event.UnregisterEvent(ModuleId.RECALL, gmodule.notifyId.Recall.BINDED_FRIEND_ACTIVE_CHANGE, GameCommunityBtnPanel.OnRecallInfoChange)
  Event.UnregisterEvent(ModuleId.RECALL, gmodule.notifyId.Recall.BINDED_FRIEND_REBATE_CHANGE, GameCommunityBtnPanel.OnRecallInfoChange)
  self:ClearUI()
  self.community = ""
  self.lastDestroyTime = GameUtil.GetTickCount()
end
def.method().InitUI = function(self)
  self.uiObjs = {}
  self.m_panel:SetActive(true)
  self.uiObjs.Img_Bg = self.m_panel:FindDirect("Img_Bg")
  self.uiObjs.Scroll_View = self.uiObjs.Img_Bg:FindDirect("Scroll_View")
  self.uiObjs.Grid_Btn = self.uiObjs.Scroll_View:FindDirect("Grid_Btn")
  local imgRedGO = self.uiObjs.Grid_Btn:FindDirect("Btn_RankFriends/Img_Red")
  GUIUtils.SetActive(imgRedGO, RelationShipChainMgr.CanReciveGift() or RelationShipChainMgr.CanReciveFriendNumGift())
  self:UpdateRecallReddot()
  self.uiObjs.qedjBtn = self.uiObjs.Grid_Btn:FindDirect("Btn_QiErDianJing")
  GUIUtils.SetActive(self.uiObjs.qedjBtn, FeatureOpenListModule.Instance():CheckFeatureOpen(Feature.TYPE_ESPORTS))
  self.uiObjs.liveBtn = self.uiObjs.Grid_Btn:FindDirect("Btn_Live")
  GUIUtils.SetActive(self.uiObjs.liveBtn, FeatureOpenListModule.Instance():CheckFeatureOpen(Feature.TYPE_IOS_REPLAYKIT))
  self.uiObjs.callBackBtn = self.uiObjs.Grid_Btn:FindDirect("Btn_CallBack")
  GUIUtils.SetActive(self.uiObjs.callBackBtn, FeatureOpenListModule.Instance():CheckFeatureOpen(Feature.TYPE_RECALL_FRIEND))
  local communityUIDef = GameCommunityBtnPanel.CommunityUIDef[self.community]
  if communityUIDef then
    do
      local uiBtnNameSet = {}
      for i, uidef in ipairs(communityUIDef) do
        uiBtnNameSet[uidef.btnName] = not uidef.hide
      end
      local childCount = self.uiObjs.Grid_Btn.childCount
      for i = 0, childCount - 1 do
        local childGO = self.uiObjs.Grid_Btn:GetChild(i)
        local display = uiBtnNameSet[childGO.name] and true or false
        GUIUtils.SetActive(childGO, display)
      end
      self.uiObjs.Grid_Btn:GetComponent("UIGrid"):Reposition()
      local uiTableResizeBackground = self.uiObjs.Img_Bg:GetComponent("UITableResizeBackground")
      GameUtil.AddGlobalTimer(0, true, function(...)
        GameUtil.AddGlobalLateTimer(0, true, function(...)
          if uiTableResizeBackground.isnil then
            return
          end
          uiTableResizeBackground:Reposition()
          self:UpdatePosition()
        end)
      end)
    end
  end
  self:UpdatePosition()
  self.uiObjs.Img_Bg:GetComponent("UISprite").enabled = not GameUtil.IsEvaluation()
end
def.method().UpdateRecallReddot = function(self)
  if RecallModule.Instance():IsOpen(false) then
    self:UpdateNewRecallReddot()
  else
    self:UpdateOldRecallReddot()
  end
end
def.method().UpdateOldRecallReddot = function(self)
  local imgRedGO = self.uiObjs.Grid_Btn:FindDirect("Btn_CallBack/Img_Red")
  GUIUtils.SetActive(imgRedGO, RelationShipChainMgr.GetBigGiftAwardState() == 0 or RelationShipChainMgr.CanGetRecallFriendSignAward() or RelationShipChainMgr.CanReciveRecallFriendNumGift() or RelationShipChainMgr.ToadyCanRecallFriend())
end
def.method().ClearUI = function(self)
  self.uiObjs = nil
end
def.method().UpdatePosition = function(self)
  if self.anchorGO == nil or self.anchorGO.isnil then
    warn("GameCommunityBtnPanel need anchor!")
    return
  end
  local position = self.anchorGO.position
  local uiWidget = self.anchorGO:GetComponent("UIWidget")
  local offsetY = 80
  if uiWidget then
    offsetY = uiWidget.height / 2 + 5
  end
  local offsetX = 0
  if GameUtil.IsEvaluation() then
    offsetX = 160
  end
  self.uiObjs.Img_Bg.position = position
  local localPosition = self.uiObjs.Img_Bg.localPosition
  self.uiObjs.Img_Bg.localPosition = Vector.Vector3.new(localPosition.x + offsetX, localPosition.y - offsetY, localPosition.z)
  GUIUtils.RestrictUIWidgetInScreen(self.uiObjs.Img_Bg)
end
def.method("userdata").onClickObj = function(self, obj)
  local id = obj.name
  if id == "Btn_Buluo" then
    ECMSDK.SendTLogToServer(_G.TLOGTYPE.GROUP, {1})
    local url = textRes.Common.qq_buluo
    self:OnURLBtnClicked(url)
  elseif id == "Btn_GameCircle" then
    ECMSDK.SendTLogToServer(_G.TLOGTYPE.GROUP, {2})
    local url = textRes.Common.wechat_circle
    self:OnURLBtnClicked(url)
  elseif id == "Btn_OfficalGroup" then
    local url = textRes.Common.offical_group
    self:OnURLBtnClicked(url)
  elseif id == "Btn_SubscribeRemind" then
  elseif id == "Btn_RankFriends" then
    Event.DispatchEvent(ModuleId.MAINUI, gmodule.notifyId.MainUI.BTN_RANK_FRIEND_CLICK, nil)
  elseif id == "Btn_CallBack" then
    local recallFriendsPanel = require("Main.RelationShipChain.ui.RecallFriendsPanel")
    recallFriendsPanel.Instance():ShowPanel(1)
  elseif id == "Btn_GameHome" then
  elseif id == "Btn_XinYue" then
    ECMSDK.QQXinYueVIP()
  elseif id == "Btn_KeFu" then
    if ClientCfg.GetSDKType() == ClientCfg.SDKTYPE.MSDK then
      ECMSDK.OpenURL(platform == 1 and textRes.Common.custom_service_ios or textRes.Common.custom_service_android)
    else
      local ECUniSDK = require("ProxySDK.ECUniSDK")
      if ECUniSDK.Instance():SDKIS(ECUniSDK.CHANNELTYPE.EFUNTW) or ECUniSDK.Instance():SDKIS(ECUniSDK.CHANNELTYPE.EFUNHK) then
        ECUniSDK.Instance():CustomerService({})
      end
    end
  elseif id == "Btn_WeiSheQu" then
    local HeroProp = require("Main.Hero.Interface").GetBasicHeroProp()
    local rolename = HeroProp.name
    local roleid = HeroProp.id
    if platform == 2 then
      ECMSDK.OpenURL(textRes.Common.wechat_community:format(Network.m_zoneid, Int64.tostring(roleid), rolename))
    else
      ECMSDK.OpenURL(textRes.Common.wechat_community:format(Network.m_zoneid, Int64.tostring(roleid), rolename:urlencode()))
    end
  elseif id == "Btn_Gift" then
    local HeroProp = require("Main.Hero.Interface").GetBasicHeroProp()
    local roleid = HeroProp.id
    local rolename = HeroProp.name
    local ECMSDK = require("ProxySDK.ECMSDK")
    local Network = require("netio.Network")
    ECMSDK.OpenURL(textRes.Common.exchange_gift:format(Network.m_zoneid, Int64.tostring(roleid), rolename))
  elseif id == "Btn_Live" then
    if platform == 1 then
      local ECReplayKit = require("ProxySDK.ECReplayKit")
      ECReplayKit.BeginBroadcast(true, true)
    elseif platform == 0 then
      local IOSLivePanel = require("Main.Chat.ui.IOSLivePanel")
      IOSLivePanel.Instance():ShowPanel()
    end
  elseif id == "Btn_QiErDianJing" then
    if platform == 1 then
      ECMSDK.OpenURL(textRes.Common.electronic_sports_ios)
    elseif platform == 2 then
      local ECGUIMan = require("GUI.ECGUIMan")
      ECGUIMan.Instance():LockUIForever(true)
      ECQQEC.EnterLiveHallInGame()
    else
      local ECGUIMan = require("GUI.ECGUIMan")
      ECGUIMan.Instance():LockUI(true)
    end
  elseif id == "Btn_GongZhongHao" then
    self:OnURLBtnClicked(textRes.Common.wechat_subscribe)
  end
end
def.method("string").OnURLBtnClicked = function(self, url)
  ECMSDK.OpenURL(url)
end
def.method().InitCommunity = function(self)
  local community = "win"
  if ClientCfg.GetSDKType() == ClientCfg.SDKTYPE.MSDK then
    if LoginPlatform == MSDK_LOGIN_PLATFORM.QQ then
      community = "qq"
    elseif LoginPlatform == MSDK_LOGIN_PLATFORM.WX then
      community = "wechat"
    else
      community = "guest"
    end
  else
    local UniSDK = require("ProxySDK.ECUniSDK")
    if UniSDK.Instance():SDKIS(UniSDK.CHANNELTYPE.EFUNTW) or UniSDK.Instance():SDKIS(UniSDK.CHANNELTYPE.EFUNHK) then
      local isFBLogin = UniSDK.Instance():IsFBLogin()
      if isFBLogin then
        community = "facebook"
      else
        community = "efun"
      end
    end
  end
  self.community = community
end
def.static("table", "table").OnEnterFight = function(params, context)
  instance:DestroyPanel()
end
def.static("table", "table").OnNotifyRecallFriendBigGiftAward = function(param, context)
  local self = GameCommunityBtnPanel.Instance()
  self:UpdateRecallReddot()
end
def.static("table", "table").OnNotifyRecallFriendSignAward = function(param, context)
  local self = GameCommunityBtnPanel.Instance()
  self:UpdateRecallReddot()
end
def.static("table", "table").OnRecallInfoChange = function(param, context)
  local self = GameCommunityBtnPanel.Instance()
  self:UpdateNewRecallReddot()
end
def.method().UpdateNewRecallReddot = function(self)
  local imgRedGO = self.uiObjs.Grid_Btn:FindDirect("Btn_CallBack/Img_Red")
  GUIUtils.SetActive(imgRedGO, RecallModule.Instance():NeedReddot())
end
return GameCommunityBtnPanel.Commit()
