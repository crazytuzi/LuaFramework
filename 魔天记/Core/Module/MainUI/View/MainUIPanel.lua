
require "Core.Module.Common.Panel"
require "Core.Module.MainUI.View.JoystickPanel"
require "Core.Module.MainUI.View.CastSkillPanel"
require "Core.Module.MainUI.View.HeroHeadPanel"
require "Core.Module.MainUI.View.TargetHeadPanel"
require "Core.Module.MainUI.View.BossHeadPanel"
require "Core.Module.MainUI.View.PlayerAndNpcHeadPanel"
require "Core.Module.MainUI.View.PartyAndTaskPanel"
require "Core.Module.MainUI.View.MainUISystemPanel"
require "Core.Module.MainUI.View.MainChatPanel"
require "Core.Module.MainUI.View.MainVoicePanel"

require "Core.Module.MainUI.View.DownTimer"
require "Core.Module.MainUI.View.SimpleWorldBosHurtRankPanel"
require "Core.Module.MainUI.View.FBNavigationPanel"
require "Core.Module.MainUI.View.ArathiWarInfoPanel"
require "Core.Module.MainUI.View.SysOpenTipPanel"
local ActOpenTipPanel = require "Core.Module.MainUI.View.ActOpenTipPanel"
require "Core.Module.ConvenientUse.ctr.ConvenientUseControll"

require "Core.Module.SelectScene.SelectSceneNotes"
require "Core.Module.MainUI.View.AutoStatePanel"

require "Core.Module.GuildWar.View.GuildWarInfoPanel"

require "Core.Manager.Item.ItemMoveManager"


-- MainUIPanel = Panel:New();
MainUIPanel = class("MainUIPanel", Panel)
local guaji = LanguageMgr.Get("MainUI/MainUIPanel/Guaji")
local quxiaoguaji = LanguageMgr.Get("MainUI/MainUIPanel/Quxiaoguaji")
local mingzuruqingCount = LanguageMgr.Get("MainUI/MainUIPanel/MingzuCount")
local logFlg = 0

MainUIPanel.Mode = {
    HIDE = 0;
    SHOW = 1;
}

function MainUIPanel:New()
    self = { };
    setmetatable(self, { __index = MainUIPanel });
    MainUIPanel.ins = self;
    return self;
end

function MainUIPanel:IsPopup()
    return false;
end

function MainUIPanel:GetUIOpenSoundName()
    return ""
end

function MainUIPanel:_Init()
    self._enable = true

    self:_InitReference();
    self:_InitListener();

    -- self._achievemenRewardPanelLogic = AchievemenRewardPanel:New();
    -- self._achievemenRewardPanelLogic:Init(self._achievemenRewardPanel)
    -- self._achievemenRewardPanelLogic:SetActive(false)
    -- self._titlePanelLogic = TitlePanel:New();
    -- self._titlePanelLogic:Init(self._titlePanel)
    -- self._titlePanelLogic:SetActive(false)
    self._joystickPanelLogic = JoystickPanel:New();
    self._joystickPanelLogic:Init(self._joystickPanel)

    self._castSkillPanelLogic = CastSkillPanel:New();
    self._castSkillPanelLogic:Init(self._castSkillPanel);

    self._heroHeadPanelLogic = HeroHeadPanel:New();
    self._heroHeadPanelLogic:Init(self._heroHeadPanel);

    self._targetHeadPanelLogic = TargetHeadPanel:New();
    self._targetHeadPanelLogic:Init(self._targetHeadPanel);

    self._bossHeadPanelLogic = BossHeadPanel:New();
    self._bossHeadPanelLogic:Init(self._bossHeadPanel);

    self._playerHeadPanelLogic = PlayerAndNpcHeadPanel:New();
    self._playerHeadPanelLogic:Init(self._playerHeadPanel);

    self._sysPanelLogic = MainUISystemPanel.New();
    self._sysPanelLogic:Init(self._sysPanel);
    self._sysPanelLogic:SetHeroHeadPanel(self._heroHeadPanelLogic);

    self._chatPanelLogic = MainChatPanel.New();
    self._chatPanelLogic:Init(self._chatPanel);
    if ChatManager.UseVoice then
        self._voicePanelLogic = MainVoicePanel.New();
        self._voicePanelLogic:Init(self._voicePanel);
    else
        self._voicePanel.gameObject:SetActive(false)
    end
    self._partyAndTaskPanelCtr = PartyAndTaskPanel:New();
    self._partyAndTaskPanelCtr:Init(self._partyAndTaskPanel.gameObject)

    self._SysOpenTipPanel = SysOpenTipPanel:New();
    self._SysOpenTipPanel:Init(self._sysOpenTipPanel);

    self._actOpenTipPanel = ActOpenTipPanel.New();
    self._actOpenTipPanel:Init(self._trsActOpenTipPanel);

    self._simpleWorldBosHurtRankPanelLogic = SimpleWorldBosHurtRankPanel:New()
    self._simpleWorldBosHurtRankPanelLogic:Init(self._simpleWorldBosHurtRankPanel)

    self._fbNavigationPanelLogic = FBNavigationPanel:New()
    self._fbNavigationPanelLogic:Init(self._fbNavigationPanel)

    self._arathiWarInfoPanelLogic = ArathiWarInfoPanel:New()
    self._arathiWarInfoPanelLogic:Init(self._arathiWarInfoPanel)

    self._autoStatePanelLogic = AutoStatePanel:New()
    self._autoStatePanelLogic:Init(self._trsAutoState);
    self._hero = HeroController:GetInstance()
    local playerInfo = self._hero.info
    self._expConfig = ConfigManager.GetConfig(ConfigManager.CONFIGNAME_CAREER_EXP)
    self._myLevelConfig = self._expConfig[playerInfo.level]
    self._maxExp = self._myLevelConfig.exp

    self:SetExpSlider(playerInfo.exp)
    self._rt = self._imgMiniMap.uvRect

    self._timer = Timer.New( function(val) self:_OnUpdata(val) end, 0.1, -1, false);
    self._timer:Start();
    self._txtPVPTick.text = ""
    MainUIProxy.TryGetMyFriend();
    ConvenientUseControll.GetIns():FirstLoinCheck();
    self._luaBehaviour:RegisterDelegate("OnEnable", function() self:_onEnable(self) end);

    -- self._autoFightExp = 0
    -- self._autoFightStartTime = 0
    self._SysOpenTipPanel:CheckLev();
    self._actOpenTipPanel:Check();

    self:SceneAfterInit();
    self._msgTimer = Timer.New( function()
        self:UpdateMsgMail()
        self._msgTimer = nil
    end , 2, 1, true):Start();
    local isRideUse = SystemManager.IsOpen(SystemConst.Id.MOUNT)
    self._imgRide.gameObject:SetActive(isRideUse)
    if (isRideUse) then
        self:SetRideIcon(self._hero:IsOnRide())
    end

    self:ProductsChange()


end

function MainUIPanel:_onEnable()
    if self._chatPanelLogic then self._chatPanelLogic:UpdateReset() end
end

function MainUIPanel:_Opened()
    self._sysPanelLogic:InitShow();
    PanelManager.OnMainUIFocus();

    ModuleManager.SendNotification(ItemMoveEffectNotes.OPEN_ITEMMOVEEFFECTPANEL, nil);
end

function MainUIPanel:_InitReference()
    local btns = UIUtil.GetComponentsInChildren(self._transform, "UIButton");
    self._btnBackPack = UIUtil.GetChildInComponents(btns, "btnBackPack");
    self._btnFriend = UIUtil.GetChildInComponents(btns, "btnFriend");
    self._btnOutFB = UIUtil.GetChildInComponents(btns, "btnOutFB");
    self._btnOutLD = UIUtil.GetChildInComponents(btns, "btnOutLD");
    self._btnExit = UIUtil.GetChildInComponents(btns, "btnExit");
    self._btnMail = UIUtil.GetChildInComponents(btns, "btnMail");

    self._btnWildVipBoss = UIUtil.GetChildByName(self._trsContent, "Transform", "btnWildVipBoss");

    self.btn_yaoqingTip = UIUtil.GetChildInComponents(btns, "btn_yaoqingTip");
    self.btn_cameraReset = UIUtil.GetChildInComponents(btns, "btn_cameraReset").gameObject;

    self._sliderExp = UIUtil.GetChildByName(self._trsContent, "UISlider", "sliderExp")
    self._joystickPanel = UIUtil.GetChildByName(self._transform, "UI_JoystickPanel")
    -- self._achievemenRewardPanel = UIUtil.GetChildByName(self._transform, "UI_AchievemenRewardPanel")
    -- self._titlePanel = UIUtil.GetChildByName(self._transform, "UI_TitlePanel")
    self._simpleWorldBosHurtRankPanel = UIUtil.GetChildByName(self._transform, "UI_SimpleWorldBosHurtRankPanel")
    self._fbNavigationPanel = UIUtil.GetChildByName(self._transform, "UI_FBNavigation")

    self._castSkillPanel = UIUtil.GetChildByName(self._transform, "UI_CastSkillPanel");
    self._heroHeadPanel = UIUtil.GetChildByName(self._transform, "UI_HeroHeadPanel");
    self._targetHeadPanel = UIUtil.GetChildByName(self._transform, "UI_TargetHeadPanel");
    self._bossHeadPanel = UIUtil.GetChildByName(self._transform, "UI_BossHeadPanel");
    self._playerHeadPanel = UIUtil.GetChildByName(self._transform, "UI_PlayerHeadPanel");
    self._sysPanel = UIUtil.GetChildByName(self._transform, "UI_SysPanel");
    self._chatPanel = UIUtil.GetChildByName(self._transform, "UI_ChatPanel");
    self._voicePanel = UIUtil.GetChildByName(self._transform, "UI_VoicePanel");
    self._arathiWarInfoPanel = UIUtil.GetChildByName(self._transform, "UI_ArathiWarInfoPanel");
    self._guildWarInfoPanel = UIUtil.GetChildByName(self._transform, "UI_GuildWarInfoPanel");
    self._guajiExpPanel = UIUtil.GetChildByName(self._transform, "UI_GuaJiExp")
    self._sysOpenTipPanel = UIUtil.GetChildByName(self._transform, "UI_SysOpenTipPanel");
    self._trsActOpenTipPanel = UIUtil.GetChildByName(self._transform, "UI_ActOpenTipPanel");

    self.ctip = UIUtil.GetChildByName(self._btnBackPack, "UISprite", "ctip")


    self._imgGujiBg = UIUtil.GetChildByName(self._guajiExpPanel, "UISprite", "bg")
    self._txtMapName = UIUtil.GetChildByName(self._trsContent, "UILabel", "trsMiniMap/txtMapName");
    self._txtFbTime = UIUtil.GetChildByName(self._trsContent, "UILabel", "txtFbTime");
    self._txtPVPTick = UIUtil.GetChildByName(self._trsContent, "UILabel", "txtPVPTick");
    self._txtElseTime = UIUtil.GetChildByName(self._trsContent, "UILabel", "txtElseTime");
    self._txtGuaJiExp = UIUtil.GetChildByName(self._guajiExpPanel, "UILabel", "txtContent")
    self._txtMingZuRuQin = UIUtil.GetChildByName(self._trsContent, "UILabel", "txtMingZuRuQin")
    self._btnFriend_npoint = UIUtil.GetChildByName(self._btnFriend, "UISprite", "npoint");
    self._btnFriend_npoint.gameObject:SetActive(false);
    self._imgRide = UIUtil.GetChildByName(self._trsContent, "UISprite", "imgRide")
    self._partyAndTaskPanel = UIUtil.GetChildByName(self._transform, "UI_PartyAndTaskPanel");
    self._imgMiniMap = UIUtil.GetChildByName(self._trsContent, "UITexture", "trsMiniMap/MapMaskPanel/imgMiniMap");
    self._btnMiniMapTog = UIUtil.GetChildByName(self._trsContent, "UISprite", "trsMiniMap/btnMiniMapTog");
    self._iconMiniMapShow = UIUtil.GetChildByName(self._trsContent, "UISprite", "trsMiniMap/MapMaskPanel");
    self._iconMiniMapHide = UIUtil.GetChildByName(self._trsContent, "UISprite", "trsMiniMap/iconMiniMapHide");
    self._iconMiniMapHide.gameObject:SetActive(false);
    self._showMiniMap = true;

    self._trsTarget = UIUtil.GetChildByName(self._trsContent, "MapMaskPanel/imgMiniMap/imgTarget")
    self._trsHeadMask = UIUtil.GetChildByName(self._transform, "UISprite", "UI_HeroHeadPanel/trsContent/trsHeadMask");
    self._goHeadMask = self._trsHeadMask.gameObject
    self._autoFightButton = UIUtil.GetChildByName(self._trsContent, "UIButton", "btnAutoFight");
    -- self._autoFightSprite = UIUtil.GetChildByName(self._trsContent, "UISprite", "btnAutoFight/Background");
    -- self._autoFightLabel = UIUtil.GetChildByName(self._trsContent, "UISprite", "btnAutoFight/Background");
    self._trsAutoState = UIUtil.GetChildByName(self._trsContent, "trsAutoState");

    self:RefeshAutoFightButtonLable();
    -- self._autoFightButton.value = PlayerManager.hero:IsAutoFight();
    self.btn_yaoqingTip.gameObject:SetActive(false);
    self._txtElseTime.text = ""
    self._txtMingZuRuQin.gameObject:SetActive(false)
    SetUIEnable(self._guajiExpPanel, false);
    self.ctip.gameObject:SetActive(false);

    ItemMoveManager.Bind(self._btnBackPack.transform, ItemMoveManager.bind_name.backBag_main_bt)

end

function MainUIPanel:_InitListener()
    self._onClickRide = function() self:_OnClickRide() end
    UIUtil.GetComponent(self._imgRide, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickRide);

    self._onToggle = function(go) self:_OnToggle() end
    UIUtil.GetComponent(self._trsHeadMask, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onToggle);

    self._onClickBtnBackPack = function(go) self:_OnClickBtnBackPack(self) end
    UIUtil.GetComponent(self._btnBackPack, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtnBackPack);

    self._onClickFriend = function(go) self:_OnClickBtnFriend(self) end
    UIUtil.GetComponent(self._btnFriend, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickFriend);
    self._onClickMail = function(go) self:_OnClickBtnMail(self) end
    UIUtil.GetComponent(self._btnMail, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickMail);

    self._onClickbtnOutFB = function(go) self:_OnClickbtnOutFB(self) end
    UIUtil.GetComponent(self._btnOutFB, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickbtnOutFB);

    self._onClickbtnOutLD = function(go) self:_OnClickbtnOutLD(self) end
    UIUtil.GetComponent(self._btnOutLD, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickbtnOutLD);

    self._onClickbtnExit = function(go) self:_OnClickbtnExit(self) end
    UIUtil.GetComponent(self._btnExit, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickbtnExit);

    self._onClickbtnWildVipBoss = function(go) self:_OnClickbtnWildVipBoss(self) end
    UIUtil.GetComponent(self._btnWildVipBoss, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickbtnWildVipBoss);

    self._onClickbtn_yaoqingTip = function(go) self:_OnClickbtn_yaoqingTip(self) end
    UIUtil.GetComponent(self.btn_yaoqingTip, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickbtn_yaoqingTip);

    UIUtil.GetComponent(self.btn_cameraReset, "LuaUIEventListener"):RegisterDelegate("OnClick", self._OnClickCameraRevet);

    self._onClickBtnMap = function(go) self:_OnClickBtnMap(self) end
    UIUtil.GetComponent(self._imgMiniMap, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtnMap);

    self._onClickbtnAutoFight = function(go) self:_OnClickbtnAutoFight(self); end
    UIUtil.GetComponent(self._autoFightButton, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickbtnAutoFight);

    self._onClickMiniMapTog = function(go) self:_OnClickMiniMapTog(self); end
    UIUtil.GetComponent(self._btnMiniMapTog, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickMiniMapTog);

    UIUtil.GetComponent(self._txtMapName, "LuaUIEventListener"):RegisterDelegate("OnClick", self._OnClickMapName);

    self._onKeyCode = function(go, key) self:_OnKeyCode(key) end
    UICamera.onKey = self._onKeyCode;

    self._onClick = UICamera.VoidDelegate( function(go) self:_OnClick(go) end)
    UICamera.onClick = UICamera.onClick + self._onClick;

    MessageManager.AddListener(PlayerManager, PlayerManager.SelfExpChange, MainUIPanel.SetExpSlider, self)
    MessageManager.AddListener(PlayerManager, PlayerManager.SelfLevelChange, MainUIPanel.LevelChange, self)
    MessageManager.AddListener(MainUINotes, MainUINotes.ENV_REFRESH_SYSICONS, MainUIPanel.SystemUnlock, self)
    MessageManager.AddListener(GameSceneManager, GameSceneManager.MESSAGE_SCENE_CHANGE, MainUIPanel.SceneChange, self);
    MessageManager.AddListener(GameSceneManager, GameSceneManager.MESSAGE_SCENE_AFTER_INIT, MainUIPanel.SceneAfterInit, self);
    MessageManager.AddListener(InstancePanelProxy, InstancePanelProxy.MESSAGE_ELSETIME_CHANGE, MainUIPanel.FBElseTimeChange, self);
    MessageManager.AddListener(XMBossProxy, XMBossProxy.MESSAGE_XMBOSS_GETFB_ELSETIME, MainUIPanel.FBElseTimeChange, self);
    MessageManager.AddListener(InstancePanelProxy, InstancePanelProxy.MESSAGE_FB_OVER, MainUIPanel.FBOver, self);
    MessageManager.AddListener(FriendDataManager, FriendDataManager.MESSAGE_CHAT_DATA_CHANGE, MainUIPanel.ChatDataChange, self);
    MessageManager.AddListener(FriendDataManager, FriendDataManager.MESSAGE_CHAT_CHECK_CHANGE, MainUIPanel.ChatDataChange, self);
    MessageManager.AddListener(PlayerManager, PlayerManager.StartAutoFight, MainUIPanel.OnStartAutoFightHandler, self);
    MessageManager.AddListener(PlayerManager, PlayerManager.StopAutoFight, MainUIPanel.OnStopAutoFightHandler, self);
    MessageManager.AddListener(GameSceneManager, GameSceneManager.MESSAGE_SCENE_LINE_CHANGE, MainUIPanel._OnSceneChange, self);
    MessageManager.AddListener(YaoyuanProxy, YaoyuanProxy.MESSAGE_REC_0X140ADATA, MainUIPanel.Rec_0x140AData, self);
    MessageManager.AddListener(MainUINotes, MainUINotes.SET_SYSPANEL_DISPLAY, MainUIPanel.SetDisplay, self);
    MessageManager.AddListener(SceneMap, SceneMap.MINGZURUQIN, MainUIPanel.SetNpcCount, self);
    MessageManager.AddListener(SceneMap, SceneMap.MINGZURUQIN_END, MainUIPanel.MingzuruqinEnd, self);
    MessageManager.AddListener(SceneEventManager, DownTimer.DOWN_TIME_START, MainUIPanel.OnStartDownTime, self);
    MessageManager.AddListener(SceneEventManager, DownTimer.DOWN_TIME_END, MainUIPanel.OnEndDownTime, self);
    MessageManager.AddListener(MainUINotes, MainUINotes.OPERATE_ENABLE, MainUIPanel.OnOperateEnable, self);
    MessageManager.AddListener(FriendProxy, FriendProxy.MESSAGE_GENSHUI_MB_CHANGE, MainUIPanel.GensuiMenberChange, self);
    MessageManager.AddListener(MailManager, MailNotes.MAIL_UPDATE_NEW, MainUIPanel.UpdateMsgMail, self);
    MessageManager.AddListener(MailManager, MailNotes.MAIL_UPDATE_LIST, MainUIPanel.UpdateMsgFriend, self);
    MessageManager.AddListener(MainUIProxy, MainUIProxy.MESSAGE_RECAUTOFIGHTEXP_CALLBACK, MainUIPanel.SetExpSliderForAutoFight, self);
    MessageManager.AddListener(BackpackDataManager, BackpackDataManager.MESSAGE_BAG_PRODUCTS_CHANGE, MainUIPanel.ProductsChange, self);
    -- MessageManager.AddListener(RideManager, RideManager.RideUseState, MainUIPanel.RideStateChange, self);
    MessageManager.AddListener(RideManager, RideManager.RideDownOrOn, MainUIPanel.RideDownOrOn, self);

    MessageManager.AddListener(MainUIProxy, MainUIProxy.MESSAGE_MAINUI_WORLDBOSSEND, MainUIPanel.WorldBossEndHandler, self);


    -- Timer.New( ChatManager.Test, 2, 1, false):Start()
end

-- 系统开放发生改变
function MainUIPanel:SystemUnlock()
    local isRideUse = SystemManager.IsOpen(SystemConst.Id.MOUNT)
    self._imgRide.gameObject:SetActive(isRideUse)
end

-- true 为上坐骑 false为下坐骑
function MainUIPanel:RideDownOrOn(v)
    self:SetRideIcon(v)
end

function MainUIPanel:SetRideIcon(v)
    self._imgRide.spriteName = v and "onRide" or "outRide"
end

-- function MainUIPanel:RideStateChange(v)
--     self._imgRide.gameObject:SetActive(v)
--     if (v) then
--         self:SetRideIcon(self._hero:IsOnRide())
--     end
-- end
function MainUIPanel:_OnClickRide()
    -- local hero = HeroController:GetInstance()
    if (RideManager.GetIsRideUse()) then
        if (self._hero) then
            if (self._hero:IsOnRide()) then
                RideProxy.SendGetDownRide()
            else
                RideProxy.SendGetOnRide()
            end
        end
    else
        MsgUtils.ShowTips("ride/MainUIPanel/notUseRide")
    end

end

function MainUIPanel:_OnClick(go)
    if (go) then

        if GuideManager.isForceGuiding and GuideManager.forceSysGo and GuideManager.forceSysGo ~= go then
            -- 强制引导时 不允许点击除目标以外的其他物件.
            return;
        end

        if (go ~= self._goHeadMask) then
            if self._sysPanelLogic.expand then
                if self._heroHeadPanelLogic.mode == MainUIPanel.Mode.SHOW then
                    self._partyAndTaskPanelCtr:UpdateMode(MainUIPanel.Mode.SHOW);
                end

                self._heroHeadPanelLogic:Hide();
            end

            self._sysPanelLogic:CheckClickGo(go);

            --[[            if self._sysPanelLogic.expand then
                self._sysPanelLogic:UpdateMode(MainUIPanel.Mode.HIDE);
                self._partyAndTaskPanelCtr:UpdateMode(MainUIPanel.Mode.HIDE);
            end
            ]]
        end

        if self._voicePanelLogic then
            self._voicePanelLogic:OnCameraClick(go)
        end

        if go ~= self.btn_cameraReset then
            logFlg = 0
        end
    end

end

function MainUIPanel:ShowPanel(tg, mClass)
    if tg == nil then
        tg = mClass:New();
        tg:Init(self._transform);
    end
    tg:Show();
    return tg;
end

function MainUIPanel:ClosePanel(tg)

    if tg ~= nil then
        tg:Dispose();
        tg = nil;
    end

    return tg;
end





function MainUIPanel:SysPanelIsExpand()
    return self._sysPanelLogic.expand;
end

function MainUIPanel:ActPanelIsExpand()
    return self._sysPanelLogic.mode == MainUIPanel.Mode.SHOW;
end

function MainUIPanel:SetNpcCount(data)
    self._txtMingZuRuQin.text = mingzuruqingCount .. data.cur .. "/" .. data.all
end

function MainUIPanel:MingzuruqinEnd(state)
    self._txtMingZuRuQin.gameObject:SetActive(state)
end

function MainUIPanel:_Dispose()
    self._enable = false

    self:_DisposeListener();
    self:_DisposeReference();
end

function MainUIPanel:_DisposeListener()
    UIUtil.GetComponent(self._imgRide, "LuaUIEventListener"):RemoveDelegate("OnClick");
    self._onClickRide = nil


    UIUtil.GetComponent(self._btnBackPack, "LuaUIEventListener"):RemoveDelegate("OnClick");
    self._onClickBtnBackPack = nil;

    UIUtil.GetComponent(self._btnFriend, "LuaUIEventListener"):RemoveDelegate("OnClick");
    self._onClickFriend = nil;
    UIUtil.GetComponent(self._btnMail, "LuaUIEventListener"):RemoveDelegate("OnClick");
    self._onClickMail = nil;

    UIUtil.GetComponent(self._trsHeadMask, "LuaUIEventListener"):RemoveDelegate("OnClick");
    self._onToggle = nil;

    UIUtil.GetComponent(self._autoFightButton, "LuaUIEventListener"):RemoveDelegate("OnClick");
    self._onClickbtnAutoFight = nil;

    UIUtil.GetComponent(self._imgMiniMap, "LuaUIEventListener"):RemoveDelegate("OnClick");
    self._onClickBtnMap = nil;

    UIUtil.GetComponent(self._btnOutFB, "LuaUIEventListener"):RemoveDelegate("OnClick");
    self._onClickbtnOutFB = nil


    UIUtil.GetComponent(self.btn_yaoqingTip, "LuaUIEventListener"):RemoveDelegate("OnClick");
    self._onClickbtn_yaoqingTip = nil

    UIUtil.GetComponent(self.btn_cameraReset, "LuaUIEventListener"):RemoveDelegate("OnClick");

    UIUtil.GetComponent(self._btnOutLD, "LuaUIEventListener"):RemoveDelegate("OnClick");
    self._onClickbtnOutLD = nil

    UIUtil.GetComponent(self._btnExit, "LuaUIEventListener"):RemoveDelegate("OnClick");
    self._onClickbtnExit = nil

    UIUtil.GetComponent(self._btnWildVipBoss, "LuaUIEventListener"):RemoveDelegate("OnClick");
    self._onClickbtnWildVipBoss = nil

    UIUtil.GetComponent(self._btnMiniMapTog, "LuaUIEventListener"):RemoveDelegate("OnClick");
    self._onClickMiniMapTog = nil;

    UIUtil.GetComponent(self._txtMapName, "LuaUIEventListener"):RemoveDelegate("OnClick");

    UICamera.onClick = UICamera.onClick - self._onClick;
    MessageManager.RemoveListener(PlayerManager, PlayerManager.SelfExpChange, MainUIPanel.SetExpSlider)
    MessageManager.RemoveListener(PlayerManager, PlayerManager.SelfLevelChange, MainUIPanel.LevelChange)
    MessageManager.RemoveListener(MainUINotes, MainUINotes.ENV_REFRESH_SYSICONS, MainUIPanel.SystemUnlock)
    MessageManager.RemoveListener(GameSceneManager, GameSceneManager.MESSAGE_SCENE_CHANGE, MainUIPanel.SceneChange);
    MessageManager.RemoveListener(GameSceneManager, GameSceneManager.MESSAGE_SCENE_AFTER_INIT, MainUIPanel.SceneAfterInit);
    MessageManager.RemoveListener(InstancePanelProxy, InstancePanelProxy.MESSAGE_ELSETIME_CHANGE, MainUIPanel.FBElseTimeChange);
    MessageManager.RemoveListener(XMBossProxy, XMBossProxy.MESSAGE_XMBOSS_GETFB_ELSETIME, MainUIPanel.FBElseTimeChange);

    MessageManager.RemoveListener(InstancePanelProxy, InstancePanelProxy.MESSAGE_FB_OVER, MainUIPanel.FBOver);

    MessageManager.RemoveListener(FriendDataManager, FriendDataManager.MESSAGE_CHAT_CHECK_CHANGE, MainUIPanel.ChatDataChange);
    MessageManager.RemoveListener(FriendDataManager, FriendDataManager.MESSAGE_CHAT_DATA_CHANGE, MainUIPanel.ChatDataChange);

    MessageManager.RemoveListener(PlayerManager, PlayerManager.StartAutoFight, MainUIPanel.OnStartAutoFightHandler);
    MessageManager.RemoveListener(PlayerManager, PlayerManager.StopAutoFight, MainUIPanel.OnStopAutoFightHandler);

    MessageManager.RemoveListener(GameSceneManager, GameSceneManager.MESSAGE_SCENE_LINE_CHANGE, MainUIPanel._OnSceneChange);

    MessageManager.RemoveListener(YaoyuanProxy, YaoyuanProxy.MESSAGE_REC_0X140ADATA, MainUIPanel.Rec_0x140AData);

    MessageManager.RemoveListener(MainUINotes, MainUINotes.SET_SYSPANEL_DISPLAY, MainUIPanel.SetDisplay);
    MessageManager.RemoveListener(SceneMap, SceneMap.MINGZURUQIN, MainUIPanel.SetNpcCount);
    MessageManager.RemoveListener(SceneMap, SceneMap.MINGZURUQIN_END, MainUIPanel.MingzuruqinEnd);

    MessageManager.RemoveListener(SceneEventManager, DownTimer.DOWN_TIME_START, MainUIPanel.OnStartDownTime);
    MessageManager.RemoveListener(SceneEventManager, DownTimer.DOWN_TIME_END, MainUIPanel.OnEndDownTime);

    MessageManager.RemoveListener(MainUINotes, MainUINotes.OPERATE_ENABLE, MainUIPanel.OnOperateEnable);

    MessageManager.RemoveListener(FriendProxy, FriendProxy.MESSAGE_GENSHUI_MB_CHANGE, MainUIPanel.GensuiMenberChange);
    MessageManager.RemoveListener(MailManager, MailNotes.MAIL_UPDATE_NEW, MainUIPanel.UpdateMsgMail);
    MessageManager.RemoveListener(MailManager, MailNotes.MAIL_UPDATE_LIST, MainUIPanel.UpdateMsgFriend);

    MessageManager.RemoveListener(MainUIProxy, MainUIProxy.MESSAGE_RECAUTOFIGHTEXP_CALLBACK, MainUIPanel.SetExpSliderForAutoFight);

    MessageManager.RemoveListener(BackpackDataManager, BackpackDataManager.MESSAGE_BAG_PRODUCTS_CHANGE, MainUIPanel.ProductsChange);
    -- MessageManager.RemoveListener(RideManager, RideManager.RideUseState, MainUIPanel.RideStateChange, self);
    MessageManager.RemoveListener(RideManager, RideManager.RideDownOrOn, MainUIPanel.RideDownOrOn, self);

    MessageManager.RemoveListener(MainUIProxy, MainUIProxy.MESSAGE_MAINUI_WORLDBOSSEND, MainUIPanel.WorldBossEndHandler, self);


    -- self._achievemenRewardPanelLogic:Dispose()
    -- self._achievemenRewardPanelLogic = nil
    -- self._titlePanelLogic:Dispose()
    -- self._titlePanelLogic = nil
    self._joystickPanelLogic:Dispose()
    self._joystickPanelLogic = nil
    self._castSkillPanelLogic:Dispose();
    self._castSkillPanelLogic = nil
    self._heroHeadPanelLogic:Dispose();
    self._heroHeadPanelLogic = nil
    self._targetHeadPanelLogic:Dispose();
    self._targetHeadPanelLogic = nil
    self._bossHeadPanelLogic:Dispose();
    self._bossHeadPanelLogic = nil;
    self._playerHeadPanelLogic:Dispose();
    self._playerHeadPanelLogic = nil;



    self._chatPanelLogic:Dispose();
    self._chatPanelLogic = nil
    if self._voicePanelLogic then
        self._voicePanelLogic:Dispose();
        self._voicePanelLogic = nil
    end
    self._partyAndTaskPanelCtr:Dispose()
    self._partyAndTaskPanelCtr = nil

    self._SysOpenTipPanel:Dispose();
    self._SysOpenTipPanel = nil;

    self._actOpenTipPanel:Dispose();
    self._actOpenTipPanel = nil;

    self._sysPanelLogic:Dispose()
    self._sysPanelLogic = nil

    self._simpleWorldBosHurtRankPanelLogic:Dispose()
    self._simpleWorldBosHurtRankPanelLogic = nil;

    self._fbNavigationPanelLogic:Dispose()
    self._fbNavigationPanelLogic = nil;

    self._arathiWarInfoPanelLogic:Dispose()
    self._arathiWarInfoPanelLogic = nil;

    self._autoStatePanelLogic:Dispose()
    self._arathiWarInfoPanelLogic = nil;

    if self._downTimer then
        self._downTimer:Clear()
        self._downTimer = nil
    end
end

function MainUIPanel:_DisposeReference()
    self._btnBackPack = nil;
    self._btnFriend = nil
    self._btnMail = nil

    if (self._timer) then
        self._timer:Stop();
        self._timer = nil;
    end

    if (self._tickTimer) then
        self._tickTimer:Stop();
        self._tickTimer = nil;
    end

    if self._sec_timer ~= nil then
        self._sec_timer:Stop();
        self._sec_timer = nil;
        self.FB_gameOver = true;
    end


    self._btnLottery = nil

    self._btnOutFB = nil;
    self.btn_yaoqingTip = nil;
    self._btnOutLD = nil;
    self._btnExit = nil;
    self._btnWildVipBoss = nil;
    self._txtFbTime = nil;
    self._sliderExp = nil
    self._hero = nil
    if self._mainTexturePath then UIUtil.RecycleTexture(self._mainTexturePath) end

    self._imgMiniMap = nil

    if (self._guajiEffect) then
        self._guajiEffect:Dispose()
        self._guajiEffect = nil
    end
end

function MainUIPanel:_OnToggle()
    local map = GameSceneManager.map;
    local mapType = map.info.type

    if (mapType ~= InstanceDataManager.MapType.Novice) then
        SequenceManager.TriggerEvent(SequenceEventType.Guide.MAINUI_HERO_HEAD_TOGGLE);

        self._heroHeadPanelLogic:Toggle();
        self._sysPanelLogic:Toggle();

        if self._sysPanelLogic.expand then
            -- self._sysPanelLogic:UpdateMode(MainUIPanel.Mode.HIDE);
            self._partyAndTaskPanelCtr:UpdateMode(MainUIPanel.Mode.HIDE);
        else
            self._partyAndTaskPanelCtr:UpdateMode(MainUIPanel.Mode.SHOW);
        end
    end
end

function MainUIPanel:Rec_0x140AData()


    local arr = YaoyuanProxy.Get0x140AData();
    local t_num = table.getn(arr);

    if t_num > 0 then
        self.btn_yaoqingTip.gameObject:SetActive(true);
    else
        self.btn_yaoqingTip.gameObject:SetActive(false);
    end

end

function MainUIPanel:OnOperateEnable(enable)
    self:SetMainUIOperateEnable(enable);
end

-- 队员 发生 跟随 改变 通知
function MainUIPanel:GensuiMenberChange(list)
    self._heroHeadPanelLogic:GensuiMenberChange(list)
    self._partyAndTaskPanelCtr:GensuiMenberChange(list)
end
function MainUIPanel:VipTry(bd)
    self._heroHeadPanelLogic:VipTry(bd)
end

function MainUIPanel:OnStartDownTime(data)
    if not self._downTimer then self._downTimer = DownTimer.New() end
    -- PrintTable(data,"",Warnging)
    self._downTimer:InitData(self._txtElseTime
    , data.downTime, data.prefix, data.endMsg
    , data.endMsgDuration, data.heartBeatTime, data.onComplete)
end


function MainUIPanel:WorldBossEndHandler()
    if not self._downTimer then self._downTimer = DownTimer.New() end
    -- PrintTable(data,"",Warnging)

    self.exitHandler = function()
        self:_OnClickbtnExit();
    end

    self._downTimer:InitData(self._txtElseTime
    , 10,
    LanguageMgr.Get("MainUI/MainUIPanel/outTip1"),
    ""
    ,
    1, 1, self.exitHandler)
end

function MainUIPanel:OnEndDownTime()
    if self._downTimer then self._downTimer:Clear() end
end

function MainUIPanel:OnStartAutoFightHandler()
    self:RefeshAutoFightButtonLable();
    if (PlayerManager.hero:IsFollowAiCtr()) then
        MsgUtils.ShowTips(nil, nil, nil, LanguageMgr.Get("figth/autoFight/follow"));
    end

    -- self._autoFightExp = 0
    -- self._autoFightStartTime = os.time()
end

function MainUIPanel:OnStopAutoFightHandler()
    self:RefeshAutoFightButtonLable();
    -- self._autoFightExp = 0
    -- self._autoFightStartTime = 0
    SetUIEnable(self._guajiExpPanel, false)
    if (self._guajiEffect) then
        self._guajiEffect:Dispose()
        self._guajiEffect = nil
    end
end

function MainUIPanel:RefeshAutoFightButtonLable()
    if (PlayerManager.hero:IsAutoFight()) then
        self._autoFightButton.normalSprite = "autoFight2"
        -- self._autoFightButton.normalSprite = "autoFight2"
        -- self._autoFightLabel.text = quxiaoguaji
    else
        self._autoFightButton.normalSprite = "autoFight"
        -- self._autoFightSprite.spriteName = "autoFight"
        -- self._autoFightLabel.text = guaji
    end
end

function MainUIPanel:ChatDataChange(id)
    FixedUpdateBeat:Add(self.UpTimeFroChatDataChange, self)
end
function MainUIPanel:UpTimeFroChatDataChange()
    self:UpdateMsgFriend()
    FixedUpdateBeat:Remove(self.UpTimeFroChatDataChange, self)
end
function MainUIPanel:UpdateMsgMail()
    -- Warning("UpdateMsgMail__" ..tostring(SystemManager.GetHasMail()))
    self:UpdateMsgFriend(SystemManager.GetHasMail())
end
function MainUIPanel:UpdateMsgFriend(flg)
    -- Warning(tostring(flg) .. tostring(FriendDataManager.HasNewChatMsg()) ..tostring(MailManager.GetRedPoint()))
    local d = flg
    local hasMail = d or MailManager.GetRedPoint();

    local is_in_fistfb = false;

    local sinfo = SceneMap.currSceneInfo;
    if sinfo ~= nil then
        local s_id = sinfo.id + 0;
        if s_id == 712000 then
            is_in_fistfb = true;
        end
    end

    self._btnMail.gameObject:SetActive(hasMail and not is_in_fistfb)
    -- Warning(tostring(hasMail))
    if not d then d = hasMail end
    if not d then d = FriendDataManager.HasNewChatMsg() end
    self._btnFriend_npoint.gameObject:SetActive(d)
end

--[[function MainUIPanel:_OnClickBtnPVP()
    PVPProxy.SendGetPVPPlayer()
    --    local data = { kind = 120043, mv = { x = 9436, y = 164, z = - 7321, a = 22796, paths = { }, st = 0 } }
    --    GameSceneManager.map:_PlayAppearAnimationHandler(0, data)
end

function MainUIPanel:_OnClickbtnTShop()
    ModuleManager.SendNotification(TShopNotes.OPEN_TSHOP, {type = TShopNotes.Shop_type_pvp});
end
]]
function MainUIPanel:_OnClickbtn_yaoqingTip()

    ModuleManager.SendNotification(YaoyuanNotes.OPEN_YAOYUANYAOQINGTIPPANEL);
end

function MainUIPanel:_OnClickbtnOutFB()
    ModuleManager.SendNotification(InstancePanelNotes.WANT_TO_LEAVE_FB);
end

function MainUIPanel:_OnClickbtnOutLD()
    GuildProxy.ReqExitZone();
end

function MainUIPanel:_OnClickbtnExit()
    local sinfo = SceneMap.currSceneInfo;
    local fb_data = ConfigManager.GetMapById(sinfo.id);
    if fb_data.type == InstanceDataManager.MapType.WorldBoss then
        GuildProxy.ReqExitZone();
        return;
    elseif fb_data.type == InstanceDataManager.MapType.VipWildBoss then
        MsgUtils.ShowConfirm(nil, "WildBossVip/exit", nil, GuildProxy.ReqExitZone);
    end
end

function MainUIPanel:_OnClickbtnWildVipBoss()
    ModuleManager.SendNotification(WildBossNotes.OPEN_WILDBOSSPANEL);
end

function MainUIPanel:_OnClickBtnMap()
    local map = GameSceneManager.map;
    if (map) then
        -- PrintTable(map.info,"",Warning)
        if (map.info.type == InstanceDataManager.MapType.ArathiWar) then
            ModuleManager.SendNotification(MapNotes.OPEN_ARATHIMAPPANEL);
            -- elseif (map.info.type == InstanceDataManager.MapType.GuildWar) then
            --    ModuleManager.SendNotification(MapNotes.OPEN_GUILDWARMAPPANEL);
        elseif (map.info.type == InstanceDataManager.MapType.Field) then
            ModuleManager.SendNotification(MapNotes.OPEN_FIELD_MAP_PANEL, map.info);
        elseif (map.info.type == InstanceDataManager.MapType.VipWildBoss) then
            ModuleManager.SendNotification(MapNotes.OPEN_BOSS_MAP_PANEL, map.info);
        elseif (map.info.type ~= InstanceDataManager.MapType.Novice) then
            ModuleManager.SendNotification(MapNotes.OPEN_MAPPANEL);
        end
    else
        ModuleManager.SendNotification(MapNotes.OPEN_MAPPANEL);
    end
end

function MainUIPanel:_OnClickBtnBackPack()
    LogHttp.SendOperaLog("背包")
    ModuleManager.SendNotification(BackpackNotes.OPEN_BAG_ALL);
end

function MainUIPanel:_OnClickBtnFriend()
    ModuleManager.SendNotification(FriendNotes.OPEN_FRIENDPANEL, FriendNotes.PANEL_FRIEND);
end

function MainUIPanel:_OnClickBtnMail()
    ModuleManager.SendNotification(FriendNotes.OPEN_FRIENDPANEL, FriendNotes.PANEL_MAIL)
end

function MainUIPanel:_OnClickMiniMapTog()
    self._showMiniMap = not self._showMiniMap;
    self._iconMiniMapShow.gameObject:SetActive(self._showMiniMap == true);
    self._iconMiniMapHide.gameObject:SetActive(self._showMiniMap == false);
end
function MainUIPanel:_OnClickCameraRevet()
    MainCameraController.GetInstance():RevertToDefaultSet()
    logFlg = logFlg + 1
    if logFlg == 5 then
        logFlg = 0
        local err = Engine.instance:GetLogError()
        print(err);
        if err and string.len(err) > 0 then Engine.instance:ShowLogPanel() end
    end
end

function MainUIPanel:_OnClickMapName()
    if not GameSceneManager.hasSceneLine() then return end
    ModuleManager.SendNotification(SelectSceneNotes.OPEN_SELECTSCENE_PANEL)
end
function MainUIPanel:_OnSceneChange()
    if (not self._txtMapName) or(not GameSceneManager.map) then return end
    if not GameSceneManager.hasSceneLine() then
        self._txtMapName.text = GameSceneManager.map.info.name
    else
        local data = GameSceneManager.scenelineData
        self._txtMapName.text = GameSceneManager.map.info.name
        .. SelectSceneProxy.GetStateDesNumber(data.st, data.ln)
    end
end



function MainUIPanel:ProductsChange()
    local b = BackpackDataManager.NeedShowBagMainPoint();
    self.ctip.gameObject:SetActive(b);
end

function MainUIPanel:_OnClickbtnAutoFight(value)

    --[[    if (self._autoFightButton.value) then
        -- 打开
        ModuleManager.SendNotification(AutoFightNotes.OPEN_AUTOFIGHTPANEL);
        self._autoFightButton.value = false;
    else
        PlayerManager.hero:StopAutoFight();
        -- 停止
    end
    ]]
    local isAutoFight = PlayerManager.hero:IsAutoFight();
    if not isAutoFight then
        PlayerManager.hero:StartAutoFight(true);
    else
        PlayerManager.hero:StopAutoFight();
    end
end

function MainUIPanel:_OnKeyCode(key)
    if (key == KeyCode.Escape) then
        GuideManager.Stop();
        SDKHelper.instance:GetExitPanel()
    end
    if (GameConfig.instance.debugFlg == false) then
        return
    end
    if (key == KeyCode.F1) then
        Reconnect.OnDisConnection();
        Reconnect.TryConnect();
    elseif (key == KeyCode.F2) then
        ModuleManager.SendNotification(DialogNotes.CLOSE_DIALOGPANEL);
        Time.timeScale = Time.timeScale == 0 and 1 or 0
    elseif (key == KeyCode.F3) then
        -- ModuleManager.SendNotification(MallNotes.SHOW_BGOLD_GET_PANEL)
        -- ModuleManager.SendNotification(MallNotes.SHOW_MONEY_GET_PANEL)
        if GameSceneManager.debug then
            ModuleManager.SendNotification(GMNotes.OPEN_GMPANEL);
        end

        -- ModuleManager.SendNotification(NewTrumpNotes.OPEN_NEWTRUMPACTIVEPANEL,NewTrumpManager.GetAllTrumpData()[1])
    elseif (key == KeyCode.F4) then
        GuideManager.Stop();
    elseif (key == KeyCode.F5) then
        local ds = DialogSet.InitWithNewTaskDialog(TaskManager.GetTaskList()[1]);
        if ds then
            ModuleManager.SendNotification(DialogNotes.OPEN_DIALOGPANEL, ds);
        end
    elseif (key == KeyCode.F6) then
        ModuleManager.SendNotification(OtherInfoNotes.OPEN_INFO_PANEL, PlayerManager.playerId);
    elseif (key == KeyCode.F7) then
        ModuleManager.SendNotification(GuildNotes.OPEN_GUILD_OTHER_PANEL, GuildNotes.OTHER.SKILL);
    elseif (key == KeyCode.F8) then
        ModuleManager.SendNotification(DaysTargetNotes.OPEN_DAYSTARGET_PANEL);
        -- ModuleManager.SendNotification(RideNotes.OPEN_RIDEPANEL, 330008);
    elseif (key == KeyCode.F9) then
        GameSceneManager.GotoScene(709999);
    elseif (key == KeyCode.F10) then
        --  GuideManager.Guide("GuideGuMoAttack");
        local v = ConfigManager.GetConfig(ConfigManager.CONFIGNAME_SYSTEM)[175];
        -- SystemManager.AddToDelay(v);
        SystemManager.ShowNewTips(v);
    elseif (key == KeyCode.F11) then
        ArathiProxy.EnterReadyScene();
        -- GuideManager.Guide("GuideLoopTack");
        -- ModuleManager.SendNotification(RankNotes.OPEN_RANKPANEL, RankPanel.type.TOWER);
        -- MsgUtils.ShowTips("value", {value = "test" .. MainUIPanel._numIndex});
        -- MainUIPanel._numIndex = MainUIPanel._numIndex + 1;
        -- MainUIProxy.ScenePropChangeCallBack(0, {t=1,id=900002})
    elseif (key == KeyCode.F12) then
        -- PanelManager.Test();
        -- MainUIProxy.ScenePropChangeCallBack(0, {t=2,id=900002})
        -- ModuleManager.SendNotification(WiseEquipPanelNotes.OPEN_WISEEQUIPPANEL, {tabIndex = 2, eqIndex = 1, selectEqInBag = nil});
        --  ModuleManager.SendNotification(XinJiRisksNotes.OPEN_XINJIRISKSPANEL);
        --  ModuleManager.SendNotification(ActivityNotes.OPEN_ACTIVITY, { type = ActivityNotes.PANEL_RICHANGACTIVITY, id = 31 });
        -- ModuleManager.SendNotification(WingNotes.OPEN_WINGACTIVEPANEL,{id=1})
        --[[
        local spid = AutoFightAiController.GetCanBuySetCfPro(500020);

        self.setAndSavePro = function(spid, am)
          AutoFightManager.use_Drug_HP_id = spid;
          AutoFightManager.Save();
        end

        ModuleManager.SendNotification(ConvenientUseNotes.SHOW_CONVENIENTBUYPANEL, { shop_id = ShopDataManager.shtop_ids.SUISHENG, spid = spid, num = 99, doFun = self.setAndSavePro });

      ]]
        --  ItemMoveManager.Check(ItemMoveManager.interface_ids.getProAndMoveToBt, {spId=505053,am=2})

        -- MessageManager.Dispatch(MainUIProxy, MainUIProxy.MESSAGE_RECAUTOFIGHTEXP_CALLBACK, {exp=288});
        --  ItemMoveManager.Check(ItemMoveManager.interface_ids.getNewSkillAndMoveToBt, { skill_id = 201150, level = 1 })
        -- SingleFBWinResultPanel.UpStar()

        --  ModuleManager.SendNotification(XinJiRisksNotes.OPEN_XINJIRISKSPANEL, { elseTime = 50 });

        --  PromotePanel:OnCallInterface(2);

        --[[
        if self.testInvToGroudSResultIndex == nil then
            self.testInvToGroudSResultIndex = 1;
            self._partyAndTaskPanelCtr._partyFloatPanelControll:AskForJointPartyResult( { name = "name1", id = - 1, invId = 152454 })
        elseif self.testInvToGroudSResultIndex == 1 then
            self.testInvToGroudSResultIndex = 2;
            self._partyAndTaskPanelCtr._partyFloatPanelControll:AskForJointPartyResult( { name = "name1123", id = 12456, invId = 1512454 })

        elseif self.testInvToGroudSResultIndex == 2 then
            self.testInvToGroudSResultIndex = 3;
            self._partyAndTaskPanelCtr._partyFloatPanelControll:AskForJointPartyResult( { name = "name1456", id = 12456, invId = 15452454 })
        elseif self.testInvToGroudSResultIndex == 3 then
            self.testInvToGroudSResultIndex = 4;
            self._partyAndTaskPanelCtr._partyFloatPanelControll:AskForJointPartyResult( { name = "name1789", id = 12456, invId = 15892454 })
        end
      ]]

        -- SingleFBWinResultPanel:UpStar({17,5}, 756500);

      --  MainUIProxy.WorldBossEndHandler(0x1633, nil);

    --  ModuleManager.SendNotification(ActivityGiftsNotes.OPEN_ACTIVITYGIFTSPANEL,{code_id=3 , other = 100});

    end
end

local guajiExp1 = LanguageMgr.Get("MainUI/MainUIPanel/GuaJiExp")
local guajiExp2 = LanguageMgr.Get("MainUI/MainUIPanel/GuaJiExpWan")
local guajiExp3 = LanguageMgr.Get("MainUI/MainUIPanel/GuaJiExpYi")
local green = ColorDataManager.Get_green()
local guajiTime = 60
function MainUIPanel:SetExpSlider(data, cExp, f)
    if (self._sliderExp ~= nil) then
        self._sliderExp.value = data / self._maxExp
    end

    if cExp ~= nil then
        local msgs = { spId = 4, am = cExp };
        local fm = "message/exp/2"
        if f == 1 then

            -- 组队加成
            local pc2 = PartData.GetMyTeamExpAddition()

            -- 世界等级加成。
            local pc4 = PlayerManager.GetExpAdd();

            --[[            -- 坐骑加成
            local pc1 = RideManager.GetExpPer();

            -- 经验丹加成；
            local pc3 = 0--PlayerManager.GetExpAdd();

               -- VIP加成
            local pc5 = VIPManager.GetSelfExp_per()

            ]]

            local extAdd = HeroController.GetInstance():GetInfo().exp_per / 10
            local res = pc2 + pc4 + extAdd;
            if res > 0 then
                msgs.add = res
                fm = "message/exp/3"
            end
            -- Warning(pc2 .. "   " .. pc4.. "   " .. extAdd.. "   " .. res.. "   " .. fm)
        end
        -- MsgUtils.ShowProps( { msgs }, fm);
        MessageManager.Dispatch(MessageNotes, MessageNotes.ENV_SHOW_PROPS, { { l = fm, p = msgs } });
    end
end

function MainUIPanel:SetExpSliderForAutoFight(data)

    local _autoFightExp = data.exp;

    local b = PlayerManager.hero:IsAutoFight();

    if (b) then
        SetUIEnable(self._guajiExpPanel, true)

        local expTem = 0;
        if (_autoFightExp < 10000) then
            expTem = ColorDataManager.GetColorText(green, _autoFightExp) .. guajiExp1
        elseif _autoFightExp < 100000000 then
            expTem = ColorDataManager.GetColorText(green, string.format("%.2f", _autoFightExp / 10000) .. guajiExp2) .. guajiExp1
        else
            expTem = ColorDataManager.GetColorText(green, string.format("%.2f", _autoFightExp / 100000000) .. guajiExp3) .. guajiExp1
        end

        self._txtGuaJiExp.text = expTem .. ""


        local effectPath
        if (_autoFightExp > self._myLevelConfig.exp_base * 3) then
            self._imgGujiBg.spriteName = "guajiExp1"
            self._imgGujiBg:MakePixelPerfect()
            effectPath = "ui_exp_gain_rate2"
        elseif _autoFightExp > self._myLevelConfig.exp_base then
            self._imgGujiBg.spriteName = "guajiExp"
            self._imgGujiBg:MakePixelPerfect()
            effectPath = "ui_exp_gain_rate1"
        else
            self._imgGujiBg.spriteName = "guajiExp"
            self._imgGujiBg:MakePixelPerfect()
        end

        if (self._guajiEffect) then
            if (effectPath == nil or self._guajiEffect:GetEffectPath() ~= effectPath) then
                self._guajiEffect:Dispose()
                self._guajiEffect = nil
            end
        end

        if (effectPath) then
            if (self._guajiEffect == nil) then
                self._guajiEffect = UIEffect:New()
                self._guajiEffect:Init(self._imgGujiBg.transform, self._imgGujiBg, 0, effectPath)
            end
            self._guajiEffect:Play()
        end

    else
        SetUIEnable(self._guajiExpPanel, false)
    end


end

function MainUIPanel:LevelChange()
    local info = PlayerManager.GetPlayerInfo()
    self._myLevelConfig = self._expConfig[info.level]
    self._maxExp = self._myLevelConfig.exp
    -- pvp解锁提示
    if (info.level == 999) then
        ModuleManager.SendNotification(ConfirmNotes.OPEN_CONFIRM2PANEL, { title = LanguageMgr.Get("PVP/pkUnlockTitle"), msg = LanguageMgr.Get("PVP/pkUnlockMsg") });
    end

    self._SysOpenTipPanel:CheckLev();
end

function MainUIPanel:SceneChange()
    local map = GameSceneManager.map;
    local mapType = map.info.type
    self._joystickPanelLogic:StopDrag();

    self._partyAndTaskPanelCtr:SetActive(mapType ~= InstanceDataManager.MapType.Novice and mapType ~= InstanceDataManager.MapType.WorldBoss)

    if (mapType ~= InstanceDataManager.MapType.Field and mapType ~= InstanceDataManager.MapType.Guild and mapType ~= InstanceDataManager.MapType.Main) then
        self._sysPanelLogic:UpdateActMode(MainUIPanel.Mode.HIDE)
        self._sysPanelLogic:SetIconActive(false)
    else
        self._sysPanelLogic:SetIconActive(true)
    end

    if mapType == InstanceDataManager.MapType.ArathiWar then
        -- self._autoFightButton.gameObject:SetActive(false);
        self._arathiWarInfoPanelLogic:SetActive(true);
    else
        -- self._autoFightButton.gameObject:SetActive(true);
        self._arathiWarInfoPanelLogic:SetActive(false);
    end

    if mapType == InstanceDataManager.MapType.GuildWar then
        ModuleManager.SendNotification(GuildWarNotes.OPEN_INFO_PANEL);
    else
        ModuleManager.SendNotification(GuildWarNotes.CLOSE_INFO_PANEL);
    end
    -- self._guildWarInfoPanelLogic:SetActive(mapType == InstanceDataManager.MapType.GuildWar);
    self._autoFightButton.gameObject:SetActive(
    -- mapType ~= InstanceDataManager.MapType.Taboo and
    -- mapType ~= InstanceDataManager.MapType.ArathiWar and 
    mapType ~= InstanceDataManager.MapType.Novice);

    if (mapType == InstanceDataManager.MapType.Novice) then
        if self._sysPanelLogic.expand then
            self._sysPanelLogic:SysHide()
            self._heroHeadPanelLogic:Hide();
            self._partyAndTaskPanelCtr:UpdateMode(MainUIPanel.Mode.SHOW);
        end
    end

    -- self._chatPanelLogic:SetEnable(mapType ~= InstanceDataManager.MapType.Novice)
    -- self._voicePanelLogic:SetEnable(mapType ~= InstanceDataManager.MapType.Novice)
    self._chatPanelLogic._gameObject:SetActive(mapType ~= InstanceDataManager.MapType.Novice)
    if self._voicePanelLogic then
        self._voicePanelLogic._gameObject:SetActive(mapType ~= InstanceDataManager.MapType.Novice)
    end
    self._btnBackPack.gameObject:SetActive(mapType ~= InstanceDataManager.MapType.Novice);
    self._btnFriend.gameObject:SetActive(mapType ~= InstanceDataManager.MapType.Novice);

    if (map and mapType == InstanceDataManager.MapType.WorldBoss) then
        self._simpleWorldBosHurtRankPanelLogic:SetActive(true)
        -- self._partyAndTaskPanelCtr:SetActive(false)
        self._bossHeadPanelLogic:AutoListenerBoss(true);
        self._targetHeadPanelLogic:AlwayHide(true)
        self._playerHeadPanelLogic:AlwayHide(true)


        -- ChoosePKTypeProxy.ForcePeace();
    else
        self._simpleWorldBosHurtRankPanelLogic:SetActive(false)
        -- self._partyAndTaskPanelCtr:SetActive(true)
        self._bossHeadPanelLogic:AutoListenerBoss(false);
        self._targetHeadPanelLogic:AlwayHide(false)
        self._playerHeadPanelLogic:AlwayHide(false)
        -- ChoosePKTypeProxy.CancelForcePeace();
    end




end

function MainUIPanel:SceneAfterInit()
    self:SetMainUIOperateEnable(true)
    if (self._tickTimer) then
        self._tickTimer:Stop()
    end
    self._txtPVPTick.text = ""


    -- 需要检查 是否在副本里面
    local sinfo = SceneMap.currSceneInfo;

    if sinfo ~= nil then
        local s_id = sinfo.id + 0;
        local fb_data = ConfigManager.GetMapById(s_id);

        if fb_data.type == InstanceDataManager.MapType.Field then
            self._SysOpenTipPanel:SceneChange(true);
            self._actOpenTipPanel:SceneChange(true);
        else
            self._SysOpenTipPanel:SceneChange(false);
            self._actOpenTipPanel:SceneChange(false);
        end

        if fb_data.type == InstanceDataManager.MapType.Field or
            fb_data.type == InstanceDataManager.MapType.Main or
            fb_data.type == InstanceDataManager.MapType.WorldBoss or
            fb_data.type == InstanceDataManager.MapType.Guild or
            fb_data.type == InstanceDataManager.MapType.ArathiWar or
            fb_data.type == InstanceDataManager.MapType.GuildWar or
            fb_data.type == InstanceDataManager.MapType.VipWildBoss or
            fb_data.type == InstanceDataManager.MapType.Novice then

            self._btnOutFB.gameObject:SetActive(false);
            self._txtFbTime.gameObject:SetActive(false);

        else
            self._btnOutFB.gameObject:SetActive(true);
            self._txtFbTime.gameObject:SetActive(true);

            if GameSceneManager.fid == XMBossPanel.Fb_id then

                InstancePanelProxy.TryGetFB_ElseTime();
                self._btnOutFB.gameObject:SetActive(true);
            else
                --  self.txtElseTime.gameObject:SetActive(false);
                InstancePanelProxy.TryGetFB_ElseTime()
            end

            -- if fb_data.type ~= InstanceDataManager.MapType.XMBoss then
            --    InstancePanelProxy.TryGetFB_ElseTime()
            -- end
        end

        if fb_data.type == InstanceDataManager.MapType.Guild then
            self._btnOutLD.gameObject:SetActive(true);
        else
            self._btnOutLD.gameObject:SetActive(false);
        end

        if fb_data.type == InstanceDataManager.MapType.WorldBoss or fb_data.type == InstanceDataManager.MapType.VipWildBoss then
            self._btnExit.gameObject:SetActive(true);
        else
            self._btnExit.gameObject:SetActive(false);
        end

        if fb_data.type == InstanceDataManager.MapType.VipWildBoss then
            self._btnWildVipBoss.gameObject:SetActive(true);
        else
            self._btnWildVipBoss.gameObject:SetActive(false);
        end

        if GameSceneManager.fid ~= nil and GameSceneManager.fid ~= "" then

            local instanceData = InstanceDataManager.GetMapCfById(GameSceneManager.fid)
            if (instanceData.type == InstanceDataManager.InstanceType.PVPInstance) then
                if (self._tickTimer == nil) then
                    self._tickTimer = Timer.New( function(val) self:_OnPVPTickUpdate(val) end, 1, -1, false);
                end
                self:SetMainUIOperateEnable(false)
                self._pvpTick = PVPManager.PVPReadyTime
                self._txtPVPTick.text = tostring(self._pvpTick)
                self._tickTimer:Start();
            end
        end
    end


    FixedUpdateBeat:Add(self.CheckAfterSceneForAddFriend, self);



end

-- 检测 是否需要添加 好友
-- http://192.168.0.8:3000/issues/3918
-- 1、打1次副本后，系统自动询问是否要将队伍中的玩家加为好友；（排除已为好友玩家）
function MainUIPanel:CheckAfterSceneForAddFriend()

    if GameSceneManager.old_id ~= nil then
        local old_ins_cf = InstanceDataManager.GetInsByMapId(GameSceneManager.old_id);

        if old_ins_cf ~= nil then

            local list = PartData.TryGetNotMyFriendInTeam();
            local t_num = table.getn(list);
            local f_num = FriendDataManager.GetFriendNum();

            if t_num > 0 and f_num < FriendDataManager.friend_max_num then
                -- if t_num > 0 and f_num < 3 then
                ModuleManager.SendNotification(FriendNotes.OPEN_WAITFORADDFRIENDPANEL, list);
            end

        end
    end

    FixedUpdateBeat:Remove(self.CheckAfterSceneForAddFriend, self);


end



local startFight = LanguageMgr.Get("MainUI/MainUIPanel/StartFight")
function MainUIPanel:_OnPVPTickUpdate()
    self._pvpTick = self._pvpTick - 1
    if (self._pvpTick == 0) then
        self._txtPVPTick.text = startFight
        HeroController.GetInstance():StartAutoFight()
    elseif self._pvpTick < 0 then
        self._txtPVPTick.text = ""
        self._tickTimer:Stop()
        self:SetMainUIOperateEnable(true)
    else
        self._txtPVPTick.text = tostring(self._pvpTick)
    end
end

function MainUIPanel:FBElseTimeChange(finishTimeStamp)


    self._partyAndTaskPanelCtr:FBElseTimeChange(finishTimeStamp)


    self.FB_gameOver = false;
    self._finishTimeStamp = finishTimeStamp
    self._fb_else_totalTime = self._finishTimeStamp - GetTime();
    local tstr = GetTimeByStr1(self._fb_else_totalTime);
    self._txtFbTime.text = tstr;

    self._partyAndTaskPanelCtr:OnUpElseTime(self._fb_else_totalTime, true)

    if self._sec_timer ~= nil then
        self._sec_timer:Stop();
        self._sec_timer = nil;
    end

    if self._fb_else_totalTime > 0 then

        self.FB_gameOver = false;

        self._sec_timer = Timer.New( function()

            local tstr = GetTimeByStr1(self._fb_else_totalTime);
            self._fb_else_totalTime = self._finishTimeStamp - GetTime();
            self._txtFbTime.text = tstr;

            self._partyAndTaskPanelCtr:OnUpElseTime(self._fb_else_totalTime)

            if self._fb_else_totalTime < 0 or self.FB_gameOver == true then
                if self._sec_timer ~= nil then
                    self._sec_timer:Stop();
                    self._sec_timer = nil;
                    self.FB_gameOver = true;
                end
            end

        end , 1, self._fb_else_totalTime, false);
        self._sec_timer:Start();
        self._txtFbTime.gameObject:SetActive(true)
    else
        self._txtFbTime.gameObject:SetActive(false)
    end


end

function MainUIPanel:FBOver()
    self.FB_gameOver = true;
end

function MainUIPanel:UpdateMainUIPanel()
    if self._mapId == GameSceneManager.mapId then return end
    self._mapId = GameSceneManager.mapId
    self._map = GameSceneManager.map
    self._txtMapName.text = self._map.info.name
    if self._mainTexturePath then UIUtil.RecycleTexture(self._mainTexturePath) end
    self._mainTexturePath = "map/" .. GameSceneManager.map.info.minimap;
    local tex = UIUtil.GetTexture(self._mainTexturePath)
    if (tex == nil) then
        self._mainTexturePath = "map/10005"
        tex = UIUtil.GetTexture(self._mainTexturePath)
    end
    self._imgMiniMap.mainTexture = tex
end

function MainUIPanel.UpdateSys()

end

function MainUIPanel:_OnUpdata()
    if (self._hero) then
        if (self.pos == nil) then
            self.pos = self._hero.transform.position
        else
            if (Vector3.Distance2(self.pos, self._hero.transform.position) > 1) then
                self.pos = self._hero.transform.position
            else
                return
            end
        end
        local result = self:GetPos(self.pos)
        self._rt.x = result.x
        self._rt.y = result.y
        self._imgMiniMap.uvRect = self._rt
    end
end

local sin = math.sin(math.rad(45))
local cos = math.cos(math.rad(45))
function MainUIPanel:GetPos(pos)
    pos = Vector3((pos.x * cos + pos.z * sin), 0, pos.z * cos - pos.x * sin)
    local result = Vector3(((pos.x - self._map.info.offsetX) / self._map.info.mapXSize) -(0.5 * self._rt.width),((pos.z - self._map.info.offsetY) / self._map.info.mapYSize) -(0.5 * self._rt.height), 0)
    return result
end

function MainUIPanel:SetCastSkillOperateEnable(enable)
    self._castSkillPanelLogic:SetOperateEnable(enable)
end

function MainUIPanel:SetMainUIOperateEnable(enable)
    self._enable = enable
    if (self._joystickPanelLogic) then
        self._joystickPanelLogic:SetOperateEnable(self._enable)
    end
    if (self._castSkillPanelLogic) then
        self._castSkillPanelLogic:SetOperateEnable(self._enable)
    end
end

function MainUIPanel:SetDisplay(mode)
    self._heroHeadPanelLogic:SetDisplay(mode);
    self._sysPanelLogic:SetSysDisplay(mode);

    -- 打开系统列表 隐藏活动列表,任务面板
    if mode == MainUIPanel.Mode.SHOW then
        self._partyAndTaskPanelCtr:UpdateMode(MainUIPanel.Mode.HIDE);
        self._sysPanelLogic:UpdateActMode(MainUIPanel.Mode.HIDE);
    end
end

function MainUIPanel:SetActDisplay(mode)
    -- 打开活动列表 隐藏系统列表
    if mode == MainUIPanel.Mode.SHOW then
        self._sysPanelLogic:SetSysDisplay(MainUIPanel.Mode.HIDE);
    end
    self._sysPanelLogic:UpdateActMode(mode);
end
local show = LayerMask.GetMask(Layer.UI, Layer.UnActiveUI)
local hide = LayerMask.GetMask(Layer.UI)

function MainUIPanel:SetPanelLayer(enable)
    -- local y = enable and 0 or -100000
    -- Util.SetLocalPos(self._transform, 0, y, 0)
    Scene.instance.uiCamera2D.cullingMask = enable and show or hide
end 