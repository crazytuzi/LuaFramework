require "Core.Module.Common.Panel"
require "Core.Module.WildBoss.View.Item.WildBossMapItem"

WildBossPanel = class("WildBossPanel", Panel);
local insert = table.insert

function WildBossPanel:New()
    self = { };
    setmetatable(self, { __index = WildBossPanel });
    return self
end 

function WildBossPanel:_Init()
    self._onAreaClick = function(go) self:_OnAreaClick(go) end
    self:_InitReference();
    self:_InitListener();
    self:_InitMap();
    WildBossProxy.RefreshBossInfos()
end

function WildBossPanel:_InitReference()
    self._btn_close = UIUtil.GetChildByName(self._trsContent, "UIButton", "btn_close");
    self._btn_help = UIUtil.GetChildByName(self._trsContent, "UIButton", "btn_help");
    self._btnRank = UIUtil.GetChildByName(self._trsContent, "UIButton", "btnRank");

    self._areaPrefab = UIUtil.GetChildByName(self._trsContent, "areaPrefab").gameObject;
    self._map = UIUtil.GetChildByName(self._trsContent, "map").gameObject;

    self._txtTimeTitle = UIUtil.GetChildByName(self._trsContent, "UILabel", "txtTimeTitle");
    self._txtTime = UIUtil.GetChildByName(self._trsContent, "UILabel", "txtTime");

    self._txtOngoing = UIUtil.GetChildByName(self._trsContent, "UILabel", "txtOngoing");
end

function WildBossPanel:_InitMap()
    local parent = self._map;
    local prefab = self._areaPrefab;
    self._areaItems = { }
    if (prefab and parent) then
        local mapConfig = ConfigManager.GetConfig(ConfigManager.CONFIGNAME_MAP)
        for k, v in pairs(mapConfig) do
            if (v.map_icon ~= "") then
                local item = WildBossMapItem:New(NGUITools.AddChild(parent, self._areaPrefab).transform, v);
                item:AddClickListener(self, self._OnClickMapItem);
                insert(self._areaItems, item);
            end
        end
        prefab:SetActive(false);
    end
end

function WildBossPanel:_InitListener()
    self._onClickBtn_close = function(go) self:_OnClickBtn_close(self) end
    UIUtil.GetComponent(self._btn_close, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtn_close);

    self._onClickBtn_help = function(go) self:_OnClickBtn_help(self) end
    UIUtil.GetComponent(self._btn_help, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtn_help);

    self._onClickBtnRank = function(go) self:_OnClickBtnRank(self) end
    UIUtil.GetComponent(self._btnRank, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtnRank);

    MessageManager.AddListener(WildBossNotes, WildBossNotes.EVENT_BOSSINFOS, WildBossPanel._OnDataHandler, self);
end

function WildBossPanel:_OnDataHandler(data)
--    local data = {
--        l =
--        {
--            {
--                sid = 701000,
--                ln = 1,
--                mid = 127001,
--                st = 1,
--                lv = 60,
--                x = 100,
--                y = 100,
--                z = 100
--            },
--            {
--                sid = 701001,
--                ln = 1,
--                mid = 127010,
--                st = 1,
--                lv = 60,
--                x = 100,
--                y = 100,
--                z = 100
--            },
--            {
--                sid = 701001,
--                ln = 1,
--                mid = 127011,
--                st = 1,
--                lv = 60,
--                x = 500,
--                y = 500,
--                z = 500
--            }
--        },
--        rt = 0
--    }
    if (data) then
        self:_ClearBossData();
        self._rTime = data.rt;
        if (self._rTime <= 0) then
            self._txtOngoing.gameObject:SetActive(true);
            self._txtTimeTitle.gameObject:SetActive(false);
            self._txtTime.gameObject:SetActive(false);
            self:_StopTimer();
        else
            self._rTime = self._rTime + 1;
            self._txtOngoing.gameObject:SetActive(false);
            self._txtTimeTitle.gameObject:SetActive(true);
            self._txtTime.gameObject:SetActive(true);
            self:_StartTimer();
        end
        if (data.l) then
--            local list = { };
--            for i, v in pairs(data.l) do
--                local bl = false;
--                if (list[v.sid] == nil) then
--                    v.num = { t = 0, k = 0 }
--                    list[v.sid] = v;
--                    bl = true;
--                end
--                local data = list[v.sid];
--                if (v.st == 1) then
--                    data.num.k = data.num.k + 1;
--                else
--                    if (data.st == 1 and not bl) then
--                        data.mid = v.mid
--                        data.st = v.st
--                        data.x = v.x
--                        data.y = v.y
--                        data.z = v.z
--                    end
--                end
--                data.num.t = data.num.t + 1;
--            end
            for i, v in pairs(data.l) do
                local item = self:_GetAreaItem(tonumber(v.sid));
                if (item) then
                    item:SetData(v);
                end
            end
        end
    end
end

function WildBossPanel:_StartTimer()
    if (self._timer ~= nil) then
        self._timer:Reset( function(val) self:_OnTimerHandler(val) end, 0, -1, false);
    else
        self._timer = Timer.New( function(val) self:_OnTimerHandler(val) end, 0, -1, false);
    end
    self._timer:Start();
    self:_OnTimerHandler();
end

function WildBossPanel:_StopTimer()
    if (self._timer ~= nil) then
        self._timer:Stop();
    end
end

function WildBossPanel:_OnTimerHandler()
    if (self._rTime > 0) then
        self._rTime = self._rTime - Timer.deltaTime;
        local time = math.floor(self._rTime);
        local h = math.floor(time / 3600);
        local m = math.floor((time -(h * 3600)) / 60);
        local s = time % 60;
        local timeStr = string.format("%.2d:%.2d:%.2d", h, m, s);
        self._txtTime.text = timeStr;
    else
        self._txtOngoing.gameObject:SetActive(true);
        self._txtTimeTitle.gameObject:SetActive(false);
        self._txtTime.gameObject:SetActive(false);
        self._timer:Stop()
        WildBossProxy.RefreshBossInfos();
    end
end

function WildBossPanel:_ClearBossData()
    if (self._areaItems) then
        for i, v in pairs(self._areaItems) do
            v:SetData(nil);
        end
    end
end

function WildBossPanel:_GetAreaItem(mapid)
    if (self._areaItems) then
        for i, v in pairs(self._areaItems) do
            if (v.mapInfo.id == mapid) then
                return v;
            end
        end
    end
    return nil;
end

function WildBossPanel:_OnClickMapItem(v)
    if (v.data ~= nil) then
        ModuleManager.SendNotification(WildBossNotes.OPEN_WILDBOSSINFOPANEL, v.data);
    end
end

function WildBossPanel:_OnClickBtnRank()
    ModuleManager.SendNotification(WildBossNotes.OPEN_WILDBOSSRANKPANEL)
end

function WildBossPanel:_OnClickBtn_close()
    ModuleManager.SendNotification(WildBossNotes.CLOSE_WILDBOSSPANEL)
end

function WildBossPanel:_OnClickBtn_help()
    ModuleManager.SendNotification(WildBossNotes.OPEN_WILDBOSSHELPPANEL);
    -- local d = {};
    -- d.my = 25;
    -- d.myh = 898989;
    -- d.l = {}
    -- for i=1,50 do
    -- 	local t = {};
    -- 	t.id = i;
    -- 	t.n = "sss"..i;
    -- 	t.h = 100000 - i;
    -- 	insert(d.l,t);
    -- end
    -- ModuleManager.SendNotification(WildBossNotes.OPEN_WILDBOSSHURTRANKPANEL,d);	
end

function WildBossPanel:_Dispose()
    self:_StopTimer();
    self._timer = nil;
    self:_DisposeListener();
    self:_DisposeReference();
end

function WildBossPanel:_DisposeListener()
    UIUtil.GetComponent(self._btn_close, "LuaUIEventListener"):RemoveDelegate("OnClick");
    self._onClickBtn_close = nil;

    UIUtil.GetComponent(self._btn_help, "LuaUIEventListener"):RemoveDelegate("OnClick");
    self._onClickBtn_help = nil;

    UIUtil.GetComponent(self._btnRank, "LuaUIEventListener"):RemoveDelegate("OnClick");
    self._onClickBtnRank = nil;

    MessageManager.RemoveListener(WildBossNotes, WildBossNotes.EVENT_BOSSINFOS, WildBossPanel._OnDataHandler, self);
end

function WildBossPanel:_DisposeReference()
    if (self._areaItems) then
        for i, v in pairs(self._areaItems) do
            v:Dispose();
        end
        self._areaItems = nil;
    end
    self._btn_close = nil;
    self._btn_help = nil;
    self._btnRank = nil;
    self._areaPrefab = nil;
    self._map = nil;
    self._txtTimeTitle = nil;
    self._txtTime = nil;
    self._txtOngoing = nil;
end