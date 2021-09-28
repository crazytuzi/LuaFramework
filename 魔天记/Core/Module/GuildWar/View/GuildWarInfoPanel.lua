require "Core.Module.Common.Panel";

GuildWarInfoPanel = Panel:New();

function GuildWarInfoPanel:IsPopup()
    return false;
end

function GuildWarInfoPanel:IsFixDepth()
    return true;
end

function GuildWarInfoPanel:_Init()
    self:_InitReference();
    self:_InitListener();
end

function GuildWarInfoPanel:_InitReference()
	local trsContent = UIUtil.GetChildByName(self._transform, "Transform", "trsContent");
    local topContent = UIUtil.GetChildByName(trsContent, "Transform", "topPanel");
    local rightPanel = UIUtil.GetChildByName(trsContent, "Transform", "rightPanel");

    self._btnFunction = UIUtil.GetChildByName(trsContent, "UIButton", "btnFunction");
    self._btnFunctionIcon = UIUtil.GetChildByName(trsContent, "UISprite", "btnFunction/imgIcon");
    self._btnDetail = UIUtil.GetChildByName(rightPanel, "UIButton", "btnDetail");
    --self._btnDesc = UIUtil.GetChildByName(rightPanel, "UIButton", "btnDesc");

    self._txtTime = UIUtil.GetChildByName(topContent, "UILabel", "txtTime");
    self._txtCamp1 = UIUtil.GetChildByName(topContent, "UILabel", "txtCamp1");
    self._txtCamp2 = UIUtil.GetChildByName(topContent, "UILabel", "txtCamp2");
    self._txtBuff = UIUtil.GetChildByName(rightPanel, "UILabel", "txtBuff");
    self._txtPoint = UIUtil.GetChildByName(rightPanel, "UILabel", "txtPoint");
    self._txtRank = UIUtil.GetChildByName(rightPanel, "UILabel", "txtRank");

    self._timer = Timer.New( function(val) self:_OnUpdata(val) end, 0.3, -1, false);
    self._timer:Start();
end

function GuildWarInfoPanel:_DisposeReference()
    if self._timer then
        self._timer:Stop();
        self._timer = nil;
    end

    if self._unlockTimer then
        self._unlockTimer:Stop();
        self._unlockTimer = nil;
    end
end

function GuildWarInfoPanel:_InitListener()
    self._onClickFunctionHandler = function() self:_OnClickFunctionHandler() end
    UIUtil.GetComponent(self._btnFunction, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickFunctionHandler);
    self._onClickBtnDetail = function() self:_OnClickBtnDetail() end
    UIUtil.GetComponent(self._btnDetail, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtnDetail);    

    self._onClickTxtBuff = function() self:_OnClickTxtBuff() end
    UIUtil.GetComponent(self._txtBuff, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickTxtBuff);
    --self._onClickBtnDesc = function () self:_OnClickBtnDesc() end
    --UIUtil.GetComponent(self._btnDesc, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtnDesc);
    

    MessageManager.AddListener(GameSceneManager, GameSceneManager.MESSAGE_SCENE_START, GuildWarInfoPanel._SceneStartHandler, self);
    MessageManager.AddListener(ArathiNotes, ArathiNotes.EVENT_HEROINPOINTAREA, GuildWarInfoPanel._OnHeroInPointHandler, self);
    MessageManager.AddListener(ArathiNotes, ArathiNotes.EVENT_HEROOUTPOINTAREA, GuildWarInfoPanel._OnHeroOutPointHandler, self);
    MessageManager.AddListener(GuildWarNotes, GuildWarNotes.ENV_REFRESH_WARINFO, GuildWarInfoPanel._UpdateInfo, self);
    MessageManager.AddListener(GuildWarNotes, GuildWarNotes.ENV_START_COLLECT, GuildWarInfoPanel._StartCollect, self);
    MessageManager.AddListener(GuildWarNotes, GuildWarNotes.RSP_INFO, GuildWarInfoPanel.UpdateDisplay, self);
end

function GuildWarInfoPanel:_DisposeListener()
    UIUtil.GetComponent(self._btnFunction, "LuaUIEventListener"):RemoveDelegate("OnClick");
    self._onClickFunctionHandler = nil;
    UIUtil.GetComponent(self._btnDetail, "LuaUIEventListener"):RemoveDelegate("OnClick");
    self._onClickBtnDetail = nil;
    UIUtil.GetComponent(self._txtBuff, "LuaUIEventListener"):RemoveDelegate("OnClick");
    self._onClickTxtBuff = nil;
    --UIUtil.GetComponent(self._btnDesc, "LuaUIEventListener"):RemoveDelegate("OnClick");
    --self._onClickBtnDesc = nil;

    MessageManager.RemoveListener(GameSceneManager, GameSceneManager.MESSAGE_SCENE_START, GuildWarInfoPanel._SceneStartHandler);
    MessageManager.RemoveListener(ArathiNotes, ArathiNotes.EVENT_HEROINPOINTAREA, GuildWarInfoPanel._OnHeroInPointHandler);
    MessageManager.RemoveListener(ArathiNotes, ArathiNotes.EVENT_HEROOUTPOINTAREA, GuildWarInfoPanel._OnHeroOutPointHandler);
    MessageManager.RemoveListener(GuildWarNotes, GuildWarNotes.ENV_REFRESH_WARINFO, GuildWarInfoPanel._UpdateInfo);
    MessageManager.RemoveListener(GuildWarNotes, GuildWarNotes.ENV_START_COLLECT, GuildWarInfoPanel._StartCollect);
    MessageManager.RemoveListener(GuildWarNotes, GuildWarNotes.RSP_INFO, GuildWarInfoPanel.UpdateDisplay);
end

function GuildWarInfoPanel:_Dispose()
    self:_DisposeListener();
    self:_DisposeReference();
end

function GuildWarInfoPanel:_Opened()
    
end

local tmp = 0;
function GuildWarInfoPanel:_OnUpdata()
    if self._sysTime then
	   self:_UpdateTime();
    end

    tmp = tmp + 1;
    if tmp > 2 then
        self:_UpdateBuff();
        tmp = 0;
    end
end

function GuildWarInfoPanel:UpdateDisplay()
    self._sysTime = os.time();
    self:_UpdateInfo();
    self:_UpdateTime();
    self:_UpdateBuff();
    --self:_UpdateScene();
    --{{id = 51, rt = 60000, st = EventStateValue.close}}
end

function GuildWarInfoPanel:_OnClickFunctionHandler()
	if (self._currPointInfo) then
        PlayerManager.hero:SetFightStatus(false);
        if (self._currPointInfo.type == 4) then
            GuildWarProxy.ReqCollect(self._currPointInfo.id, 0);
        end
    end
end

function GuildWarInfoPanel:_OnClickBtnDetail()
    ModuleManager.SendNotification(GuildWarNotes.OPEN_DETAIL_PANEL);
end

function GuildWarInfoPanel:_OnClickTxtBuff()
    MsgUtils.ShowTips("GuildWar/Info/buffTips");
end

--[[
function GuildWarInfoPanel:_OnClickBtnDesc()
    ModuleManager.SendNotification(GuildWarNotes.OPEN_DESC_PANEL);
end
]]

function GuildWarInfoPanel:_SceneStartHandler()
    local mInfo = GameSceneManager.map.info;
    if (mInfo.type == InstanceDataManager.MapType.GuildWar) then
        GuildWarProxy.ReqInfo();
    end
end

function GuildWarInfoPanel:_OnHeroInPointHandler(info)
    self._currPointInfo = info;
    if (info) then
        self._btnFunction.gameObject:SetActive(true);
        if (info.type == 3) then
            self._btnFunctionIcon.spriteName = "arathiOccupy";
        else
            self._btnFunctionIcon.spriteName = "arathiPick";
        end
    else
        self._btnFunction.gameObject:SetActive(false);
    end
end

function GuildWarInfoPanel:_OnHeroOutPointHandler(info)
    self._currPointInfo = nil;
    self._btnFunction.gameObject:SetActive(false);
end

function GuildWarInfoPanel:_StartCollect(data)
    if (self._currPointInfo and data.t == 0) then
        ModuleManager.SendNotification(CountdownNotes.OPEN_COUNTDOWNBARNPANEL, {
            time = 8.5,
            title = LanguageMgr.Get("GuildWarInfoPanel/collect"),
            cancelHandler = function() self:_CancelOccupyMine() end;
            suspend = function() return self:_CheckSuspendOccupy() end
        } )
    end
end

function GuildWarInfoPanel:_CancelOccupyMine()
    ModuleManager.SendNotification(CountdownNotes.CLOSE_COUNTDOWNBARNPANEL);
    if (self._currPointInfo) then        
        GuildWarProxy.ReqCollect(self._currPointInfo.id, 1);
    end
end

function GuildWarInfoPanel:_CheckSuspendOccupy()
    local hero = PlayerManager.hero;
    if (hero == nil) then
        return true;
    end
    if (hero:IsFightStatus()) then
        return true;
    end
    if (self._currPointInfo) then
        if (self._currPointInfo.type == 3 and(self._pointCamp ~= self._currPointInfo.camp or self._currPointInfo.camp == PlayerManager.hero.info.camp)) then
            return true
        end
    else
        return true;
    end
    local act = hero:GetAction();
    if (act ~= nil and(act.__cname ~= "StandAction" and act.__cname ~= "SendStandAction")) then
        return true
    end
    return false;
end


function GuildWarInfoPanel:_UpdateTime()
    if not self._isEnd then
        local d = GuildDataManager.war;
        local currTime = os.time() - self._sysTime;
        if currTime > d.endTime then
            self._txtTime.text = GuildWarInfoPanel.FormatTime(0);
            self._isEnd = true;
        else
            self._txtTime.text = GuildWarInfoPanel.FormatTime(d.endTime - currTime);
        end
    end
end

function GuildWarInfoPanel:_UpdateScene()
    local d = GuildDataManager.war;
    local unlockTime = d.startTime - 10;

    if unlockTime > 0 then
        local msg = {
            downTime = unlockTime,
            prefix = LanguageMgr.Get("downTime/prefix")
            ,
            endMsg = LanguageMgr.Get("MainUI/MainUIPanel/StartFight")
            ,
            endMsgDuration = 3
        }
        MessageManager.Dispatch(SceneEventManager, DownTimer.DOWN_TIME_START, msg);

        self._unlockTimer = Timer.New( function(val) self:_UnlockObstacleStatus(); end, unlockTime, 1, false);
    else
        self:_UnlockObstacleStatus();
    end
end

local insert = table.insert;
function GuildWarInfoPanel:_UnlockObstacleStatus()
    local mapCfg = ConfigManager.GetConfig(ConfigManager.CONFIGNAME_MAP)[GuildDataManager.warMapId];
    local obsIds = obsIds["map_obstacle"]

    local data = {};
    for k, v in pairs(obsIds) do
        insert(data, {id = v.id, st = 1});
    end
    GameSceneManager.map:SetEventMgrUpdate(data);
end

function GuildWarInfoPanel.FormatTime(val)
    local m = math.floor(val) % 60;
    local f = math.floor(math.floor(val) / 60);
    return string.format("%.2d:%.2d", f, m);
end

function GuildWarInfoPanel:_UpdateInfo()
    local d = GuildDataManager.war;

    self._txtCamp1.text = d.wp1;
    self._txtCamp2.text = d.wp2;
    self._txtPoint.text = d.mp;
    self._txtRank.text = d.mr;
end

local buffId = 300209;
function GuildWarInfoPanel:_UpdateBuff()
    local buffs = HeroController.GetInstance():GetBuffs();
    local num = 0;
    for i, v in ipairs(buffs) do
        if v.info.id == buffId then
            num = v.overlap * 5;
            break;
        end
    end
    self._txtBuff.text = string.format("%d%%", num);
end