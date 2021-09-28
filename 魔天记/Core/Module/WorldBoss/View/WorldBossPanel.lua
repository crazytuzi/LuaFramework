require "Core.Module.Common.Panel"
require "Core.Module.WorldBoss.View.Item.WorldBossProductItem"

WorldBossPanel = class("WorldBossPanel", Panel);
function WorldBossPanel:New()
    self = { };
    setmetatable(self, { __index = WorldBossPanel });
    return self
end

function WorldBossPanel:_Init()
    self._bossInfo = self:_GetBossInfo();

    self:_InitReference();
    self:_InitListener();
    WorldBossProxy.RefreshBossInfos();
end

function WorldBossPanel:_GetBossInfo()
    local cfg = ConfigManager.GetConfig(ConfigManager.CONFIGNAME_BOSS_BASE);
    if (cfg) then
        for i, v in pairs(cfg) do
            return v
        end
    end
    return nil
end

function WorldBossPanel:_InitReference()
    local left = UIUtil.GetChildByName(self._trsContent, "Transform", "left");
    local right = UIUtil.GetChildByName(self._trsContent, "Transform", "right");
    local mole = { };
    mole.kind = self._bossInfo.monster_id;
    self._btn_close = UIUtil.GetChildByName(self._trsContent, "UIButton", "btn_close");
    self._btn_help = UIUtil.GetChildByName(self._trsContent, "UIButton", "btn_help");

    self._txtDesc = UIUtil.GetChildByName(left, "UILabel", "txtDesc");
    self._txtDesc.text = self._bossInfo.desc;
    self._txtActivityTime = UIUtil.GetChildByName(left, "UILabel", "txtActivityTime");

    self._awards = { };
    for i = 1, 5 do
        local product = UIUtil.GetChildByName(left, "Transform", "product" .. i);
        local pItem = WorldBossProductItem:New(product);
        self._awards[i] = pItem;
    end
    self._btnHurtRank = UIUtil.GetChildByName(left, "UIButton", "btnHurtRank");

    self._txtStatus = UIUtil.GetChildByName(right, "UILabel", "txtStatus");
    self._btnGo = UIUtil.GetChildByName(right, "UIButton", "btnGo");
    self._trsRoleParent = UIUtil.GetChildByName(right, "Transform", "imgRole/roleCamera/trsRoleParent");
    self._txtKilled = UIUtil.GetChildByName(right, "Transform", "txtKilled");

    if (self._bossInfo.model_rate) then
        self._trsRoleParent.localScale = Vector3.one * self._bossInfo.model_rate * 100;
    end
    self._uiAnimationModel = UIAnimationModel:New(mole, self._trsRoleParent, UIMonsterModelCreater);

    for i, v in pairs(self._bossInfo.drop) do
        local p = string.split(v, "_");
        self._awards[i]:SetProductId(tonumber(p[1]));
    end
end


function WorldBossPanel:_InitListener()
    self._onClickBtn_close = function(go) self:_OnClickBtn_close(self) end
    UIUtil.GetComponent(self._btn_close, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtn_close);

    self._onClickBtn_help = function(go) self:_OnClickBtn_help(self) end
    UIUtil.GetComponent(self._btn_help, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtn_help);

    self._onClickBtnHurtRank = function(go) self:_OnClickBtnHurtRank(self) end
    UIUtil.GetComponent(self._btnHurtRank, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtnHurtRank);

    self._onClickBtnGo = function(go) self:_OnClickBtnGo(self) end
    UIUtil.GetComponent(self._btnGo, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtnGo);

    MessageManager.AddListener(WorldBossNotes, WorldBossNotes.EVENT_BOSSINFOS, WorldBossPanel._OnDataHandler, self);
end

function WorldBossPanel:_OnDataHandler(data)
    if (data) then
        self._rTime = data.rt;
        if (self._rTime <= 0) then

            self:_StopTimer();

            if (data.st == 0) then
                self._btnGo.gameObject:SetActive(true);
                self._txtKilled.gameObject:SetActive(false);
                self._txtStatus.text = LanguageMgr.Get("WorldBoss/info/fighting");
            else
                self._btnGo.gameObject:SetActive(false);
                self._txtKilled.gameObject:SetActive(true);
                self._txtStatus.text = "";
            end
        else
            self._btnGo.gameObject:SetActive(false);
            self._txtKilled.gameObject:SetActive(false);
            self:_StartTimer();
        end

        local cfg = ConfigManager.GetConfig(ConfigManager.CONFIGNAME_BOSS_TIME);
        if (cfg) then
            local tItem = cfg[data.id];
            if (tItem) then
                self._txtActivityTime.text = tItem.open_time .. "-" .. tItem.end_time;
            else
                self._txtActivityTime.text = "";
            end
        else
            self._txtActivityTime.text = "";
        end
    end
end


function WorldBossPanel:_StartTimer()
    if (self._timer ~= nil) then
        self._timer:Reset( function(val) self:_OnTimerHandler(val) end, 0, -1, false);
    else
        self._timer = Timer.New( function(val) self:_OnTimerHandler(val) end, 0, -1, false);
    end
    self._timer:Start();
    self:_OnTimerHandler();
end

function WorldBossPanel:_StopTimer()
    if (self._timer ~= nil) then
        self._timer:Stop();
    end
end

function WorldBossPanel:_OnTimerHandler()
    if (self._rTime > 0) then
        self._rTime = self._rTime - Timer.deltaTime;
        local time = math.floor(self._rTime);
        local h = math.floor(time / 3600);
        local m = math.floor((time -(h * 3600)) / 60);
        local s = time % 60;
        if (h > 0) then
            self._txtStatus.text = string.format(LanguageMgr.Get("WorldBoss/info/time1"), h, m);
        else
            self._txtStatus.text = string.format(LanguageMgr.Get("WorldBoss/info/time2"), m, s);
        end
    else
        self._txtStatus.text = LanguageMgr.Get("WorldBoss/info/fighting");
        self._btnGo.gameObject:SetActive(true);
        self._txtKilled.gameObject:SetActive(false);
        self._timer:Stop()
    end
end

function WorldBossPanel:_OnClickBtnGo()
    if (self._bossInfo) then
        GameSceneManager.GotoScene(self._bossInfo.map_id)
        self:_OnClickBtn_close();
        ModuleManager.SendNotification(ActivityNotes.CLOSE_ACTIVITY);
    end
end

function WorldBossPanel:_OnClickBtnHurtRank()
    ModuleManager.SendNotification(WorldBossNotes.OPEN_WORLDBOSSHURTRANKPANEL)
end

function WorldBossPanel:_OnClickBtn_close()
    ModuleManager.SendNotification(WorldBossNotes.CLOSE_WORLDBOSSPANEL)
end

function WorldBossPanel:_OnClickBtn_help()
    ModuleManager.SendNotification(WorldBossNotes.OPEN_WORLDBOSSHELPPANEL);
end

function WorldBossPanel:_Dispose()
    self:_StopTimer();
    self._timer = nil;
    self:_DisposeListener();
    self:_DisposeReference();
end

function WorldBossPanel:_DisposeListener()
    UIUtil.GetComponent(self._btn_close, "LuaUIEventListener"):RemoveDelegate("OnClick");
    self._onClickBtn_close = nil;

    UIUtil.GetComponent(self._btn_help, "LuaUIEventListener"):RemoveDelegate("OnClick");
    self._onClickBtn_help = nil;

    UIUtil.GetComponent(self._btnHurtRank, "LuaUIEventListener"):RemoveDelegate("OnClick");
    self._onClickBtnHurtRank = nil;

    UIUtil.GetComponent(self._btnGo, "LuaUIEventListener"):RemoveDelegate("OnClick");
    self._onClickBtnGo = nil;

    MessageManager.RemoveListener(WorldBossNotes, WorldBossNotes.EVENT_BOSSINFOS, WorldBossPanel._OnDataHandler, self);
end

function WorldBossPanel:_DisposeReference()
    self._btn_close = nil;
    self._btn_help = nil;
    self._btnGo = nil;
    self._txtDesc = nil;
    self._txtActivityTime = nil;
    self._btnHurtRank = nil;
    self._txtStatus = nil;
    self._txtKilled = nil;
    if self._uiAnimationModel then
        self._uiAnimationModel:Dispose();
        self._uiAnimationModel = nil;
    end
    NGUITools.DestroyChildren(self._trsRoleParent);
    self._trsRoleParent = nil;
    for i, v in pairs(self._awards) do
        self._awards[i]:Dispose();
        self._awards[i] = nil;
    end
end