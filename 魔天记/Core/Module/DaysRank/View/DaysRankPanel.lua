require "Core.Module.Common.Panel";
require "Core.Module.DaysRank.View.Item.DaysRankDayItem";
require "Core.Module.DaysRank.View.Item.DaysRankItem";

DaysRankPanel = Panel:New()

function DaysRankPanel:_Init()
    self:_InitReference();
    self:_InitListener();
end

function DaysRankPanel:_InitReference()
    self._btnClose = UIUtil.GetChildByName(self._trsContent, "UIButton", "btn_close");

    self._trsBanner = UIUtil.GetChildByName(self._trsContent, "Transform", "trsBanner");
    self._scollview = UIUtil.GetChildByName(self._trsContent, "UIScrollView", "trsList")


    self._daysPhalanxInfo = UIUtil.GetChildByName(self._trsContent, "LuaAsynPhalanx", "phalanx");
    self._daysPhalanx = Phalanx:New();
    self._daysPhalanx:Init(self._daysPhalanxInfo, DaysRankDayItem);

    self._listPhalanxInfo = UIUtil.GetChildByName(self._trsContent, "LuaAsynPhalanx", "trsList/phalanx");
    self._listPhalanx = Phalanx:New();
    self._listPhalanx:Init(self._listPhalanxInfo, DaysRankItem);

    local ds = DaysRankManager.GetDays();
    local dayCount = #ds;
    self._daysPhalanx:Build(dayCount, 1, ds);

    self._trsInfo = UIUtil.GetChildByName(self._trsContent, "Transform", "trsInfo");
    -- self._titleRank = UIUtil.GetChildByName(self._trsInfo, "UILabel", "titleRank");
    self._titleMyVal = UIUtil.GetChildByName(self._trsInfo, "UILabel", "titleMyVal");

    self._txtMyVal = UIUtil.GetChildByName(self._trsInfo, "UILabel", "txtMyVal");
    self._txtMyRank = UIUtil.GetChildByName(self._trsInfo, "UILabel", "txtMyRank");
    self._txtTime = UIUtil.GetChildByName(self._trsInfo, "UILabel", "txtTime");
    self._txtSys = UIUtil.GetChildByName(self._trsInfo, "UILabel", "txtSys");
    self._icoSysList = { };
    for i = 1, 4 do
        self._icoSysList[i] = UIUtil.GetChildByName(self._trsInfo, "UISprite", "icoSys" .. i);
    end

    self._btnRank = UIUtil.GetChildByName(self._trsContent, "UIButton", "btnRank");

    self._banner = { };
    for i = 1, 7 do
        self._banner[i] = UIUtil.GetChildByName(self._trsContent, "Transform", "trsBanner/" .. i);
    end
end

function DaysRankPanel:_InitListener()
    self._onClickBtnClose = function(go) self:_OnClickBtnClose(self) end
    UIUtil.GetComponent(self._btnClose, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtnClose);

    self._onClickBtnRank = function(go) self:_OnClickBtnRank() end
    UIUtil.GetComponent(self._btnRank, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtnRank);

    self._onClickIcoSys = function(go) self:_OnClickIcoSys(go) end
    for i = 1, 4 do
        UIUtil.GetComponent(self._icoSysList[i], "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickIcoSys);
    end

    MessageManager.AddListener(DaysRankNotes, DaysRankNotes.ENV_DAYS_SELECT, DaysRankPanel.OnDaySelect, self);
    MessageManager.AddListener(DaysRankNotes, DaysRankNotes.RSP_DAYS_DETAIL, DaysRankPanel.OnRspDetail, self);
    MessageManager.AddListener(DaysRankNotes, DaysRankNotes.ENV_DAYS_AWARD_CHG, DaysRankPanel.OnAwardChg, self);

    self._timer = Timer.New( function(val) self:OnUpdate(val) end, 5, -1, false);
    self._timer:Start();
end

function DaysRankPanel:_Dispose()
    self:_DisposeListener();
    self:_DisposeReference();
end

function DaysRankPanel:_DisposeListener()
    UIUtil.GetComponent(self._btnClose, "LuaUIEventListener"):RemoveDelegate("OnClick");
    self._onClickBtnClose = nil;

    UIUtil.GetComponent(self._btnRank, "LuaUIEventListener"):RemoveDelegate("OnClick");
    self._onClickBtnRank = nil;

    for i = 1, 4 do
        UIUtil.GetComponent(self._icoSysList[i], "LuaUIEventListener"):RemoveDelegate("OnClick");
    end
    self._onClickIcoSys = nil;

    MessageManager.RemoveListener(DaysRankNotes, DaysRankNotes.ENV_DAYS_SELECT, DaysRankPanel.OnDaySelect);
    MessageManager.RemoveListener(DaysRankNotes, DaysRankNotes.RSP_DAYS_DETAIL, DaysRankPanel.OnRspDetail);
    MessageManager.RemoveListener(DaysRankNotes, DaysRankNotes.ENV_DAYS_AWARD_CHG, DaysRankPanel.OnAwardChg);

    self._timer:Stop();
    self._timer = nil;
end

function DaysRankPanel:_DisposeReference()
    self._daysPhalanx:Dispose();
    self._listPhalanx:Dispose();
end

function DaysRankPanel:_OnClickBtnClose()
    ModuleManager.SendNotification(DaysRankNotes.CLOSE_DAYSRANK_PANEL);
end

function DaysRankPanel:_Opened()
    local day = DaysRankManager.GetOpenDay();
    self:OnDaySelect(day);
end

function DaysRankPanel:OnDaySelect(data)


    if KaiFuManager.GetKaiFuHasDate() < data then
        MsgUtils.ShowTips("daysRank/day/notOpen", { day = data, title = LanguageMgr.Get("daysRank/title/" .. data) });
        return;
    end


    local items = self._daysPhalanx:GetItems();
    for i, v in ipairs(items) do
        v.itemLogic:SetSelect(data);
    end

    for i, v in ipairs(self._banner) do
        v.gameObject:SetActive(data == i);
    end

    self:UpdateDisplay(data);
end

function DaysRankPanel:OnUpdate()
    self:UpdateTime();
end

function DaysRankPanel:UpdateDisplay(day)

    self._type = day;
    local list = DaysRankManager.GetListByDay(day);
    local count = #list;
    self._listPhalanx:Build(count, 1, list);

    self:UpdateRedPoint();

    local openServerDay = KaiFuManager.GetKaiFuHasDate();
    self._btnRank.gameObject:SetActive(self._type <= openServerDay);

    -- 第一天判断
    local tmpDay = day == 1 and 2 or day;
    self._endTime = DaysRankPanel.GetDaysDesc(openServerDay, tmpDay);
    self._osTime = os.time();
    self:UpdateTime();

    local sysStr = LanguageMgr.Get("daysRank/sys/" .. day);
    local sysArr = { };
    if sysStr ~= "" then
        sysArr = string.split(sysStr, ",");
    end

    for i, v in ipairs(self._icoSysList) do
        if sysArr[i] then
            v.enabled = true;
            local cfg = SystemManager.GetCfg(tonumber(sysArr[i]));
            v.spriteName = cfg and cfg.icon or sysArr[i];
            v:MakePixelPerfect();
        else
            v.enabled = false;
        end
    end
    self._sysArr = sysArr;

    DaysRankProxy.ReqRankDetail(day);

    self:UpdateAward();
end

function DaysRankPanel:UpdateAward()
    local idx = DaysRankProxy.GetDayAwardIdx(self._type);
    self._scollview:ResetPosition();
    if idx > 3 then
        self._scollview:MoveRelative(Vector3.up * 140 *(idx - 3));
    end
end

function DaysRankPanel:OnAwardChg()
    self:UpdateRedPoint();
    self:UpdateList();
end

function DaysRankPanel:UpdateRedPoint()
    local items = self._daysPhalanx:GetItems();
    local item = nil;
    for i, v in ipairs(items) do
        item = v.itemLogic;
        item:UpdateRedPoint();
    end
end

function DaysRankPanel:UpdateList()
    local items = self._listPhalanx:GetItems();
    local item = nil;
    for i, v in ipairs(items) do
        item = v.itemLogic;
        item:UpdateStatus();
    end
end

function DaysRankPanel:UpdateTime()
    if self._endTime then
        local t = self._endTime - os.time() + self._osTime;
        if t > 0 then
            self._txtTime.text = LanguageMgr.Get("daysRank/time", { tStr = DaysRankPanel.FormatTime(t) });
        else
            self._txtTime.text = LanguageMgr.Get("daysRank/time/end");
        end
    else
        self._txtTime.text = "";
    end
end

function DaysRankPanel.FormatTime(t)
    if t > 3600 then
        local h = math.floor(t / 3600);
        local m = math.floor((t - h * 3600) / 60);
        return LanguageMgr.Get("time/hhmm", {h = h, m = m});
    end
    return LanguageMgr.Get("time/mm", {m = math.floor(t / 60)});
end

function DaysRankPanel.GetDaysDesc(a, b)
    local time = GetOffsetTime();
    local date = os.date("*t", time);
    date.day = date.day + b - a;
    local endTime = os.time( { year = date.year, month = date.month, day = date.day, hour = 23, min = 59, sec = 59 })
    return endTime - time;
    -- return os.date("%Y-%m-%d 23:59:59", os.time(date));
end

function DaysRankPanel:IsInDays()
    return KaiFuManager.GetKaiFuHasDate() >= self._type;
end

function DaysRankPanel:OnRspDetail(data)
    local my = data.my;

    if my.id > 0 then
        self._txtMyRank.text = my.id;
    else
        self._txtMyRank.text = LanguageMgr.Get("daysRank/notRank");
    end

    self._titleMyVal.text = LanguageMgr.Get("daysRank/label/" .. self._type);


    if self._type == DaysRankManager.Type.RMB then
        if self:IsInDays() then
            self._txtMyVal.text = my.value;
        else
            -- 没到充值日期 显示未开启
            self._txtMyVal.text = LanguageMgr.Get("daysRank/notOpen");
        end
    elseif self._type == DaysRankManager.Type.PET then
        local star,rankLevel = PetManager.GetMyStarAndRankLevel();
        self._txtMyVal.text = LanguageMgr.Get("daysRank/content/pet", { v1 = rankLevel, v2 = star });

    elseif self._type == DaysRankManager.Type.WING then
       
        self._txtMyVal.text = LanguageMgr.Get("daysRank/content/wing", my);

    else
        self._txtMyVal.text = my.value;
    end
end

function DaysRankPanel:_OnClickBtnRank()
    ModuleManager.SendNotification(DaysRankNotes.OPEN_DAYSRANK_LIST_PANEL, self._type);
end

function DaysRankPanel:_OnClickIcoSys(go)
    local idx = tonumber(string.sub(go.name, 7));

    local sysId = self._sysArr[idx];
    if sysId then
        sysId = tonumber(sysId);
        local cfg = SystemManager.GetCfg(sysId);
        if SystemManager.IsOpen(sysId) == false then
            if cfg.openType == 1 then
                MsgUtils.ShowTips("daysRank/sys/notOpen/1", { level = cfg.openVal });
            else
                local taskCfg = TaskManager.GetConfigById(cfg.openVal);
                MsgUtils.ShowTips("daysRank/sys/notOpen/2", { task = taskCfg.name or "null" });
            end

        else
            DaysRankPanel.OpenSys(sysId);
        end
    end
end

function DaysRankPanel.OpenSys(id)
    SystemManager.Nav(id);
end