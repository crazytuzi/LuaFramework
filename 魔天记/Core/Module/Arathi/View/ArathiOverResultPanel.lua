require "Core.Module.Common.Panel";
require "Core.Module.Arathi.View.Item.ArathiOverResultListItem"
require "Core.Module.Arathi.View.Item.ArathiAwardItem"

ArathiOverResultPanel = Panel:New();

function ArathiOverResultPanel:_Init()
    self:_InitReference();
    self:_InitListener();
    self._totalTime = 10;
    self._timer = Timer.New( function(val) self:_OnTickHandler(val) end, 0, -1, false);
    self._timer:Start();
end

function ArathiOverResultPanel:_InitReference()
    local heroInfo = PlayerManager.hero.info;

    self._imgBg = UIUtil.GetChildByName(self._trsContent, "UITexture", "bg");
    self._btnTog1 = UIUtil.GetChildByName(self._trsContent, "UIToggle", "trsToggle/btnTog1");
    self._btnTog2 = UIUtil.GetChildByName(self._trsContent, "UIToggle", "trsToggle/btnTog2");
    self._btnTog3 = UIUtil.GetChildByName(self._trsContent, "UIToggle", "trsToggle/btnTog3");
    self._btnTog4 = UIUtil.GetChildByName(self._trsContent, "UIToggle", "trsToggle/btnTog4");

    self._trsList = UIUtil.GetChildByName(self._trsContent, "Transform", "trsList");
    self._scrollView = UIUtil.GetComponent(self._trsList, "UIScrollView");
    self._phalanxInfo = UIUtil.GetChildByName(self._trsList, "LuaAsynPhalanx", "phalanx");
    self._phalanx = Phalanx:New();
    self._phalanx:Init(self._phalanxInfo, ArathiOverResultListItem);

    self._imgHeroIcon = UIUtil.GetChildByName(self._trsContent, "UISprite", "trsSelf/imgIcon");
    self._imgHeroIcon.spriteName = heroInfo.kind .. "";
    self._txtHeroName = UIUtil.GetChildByName(self._trsContent, "UILabel", "trsSelf/txtName");
    self._txtHeroName.text = heroInfo.name;
    self._txtHeroLevel = UIUtil.GetChildByName(self._trsContent, "UILabel", "trsSelf/txtLevel");
    self._txtHeroLevel.text = heroInfo.level;

    self._firstWinAward = ArathiAwardItem:New(UIUtil.GetChildByName(self._trsContent, "Transform", "trsSelf/award1"));
    self._joinAward = ArathiAwardItem:New(UIUtil.GetChildByName(self._trsContent, "Transform", "trsSelf/award2"));
    self._rankAwardsTransform = UIUtil.GetChildByName(self._trsContent, "Transform", "trsSelf/rankAwards");
    self._rankAwards = { };
    for i = 1, 3 do
        local item = ArathiAwardItem:New(UIUtil.GetChildByName(self._rankAwardsTransform, "Transform", "award" .. i));
        self._rankAwards[i] = item;
    end
    self._btnClose = UIUtil.GetChildByName(self._trsContent, "UIButton", "btnClose");
    self._txtCloseLabel = UIUtil.GetChildByName(self._trsContent, "UILabel", "btnClose/txtLabel");
end

function ArathiOverResultPanel:_InitListener()
    self._onClickTog1Handler = function(go) self:_OnClickTog1Handler(self) end
    UIUtil.GetComponent(self._btnTog1, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickTog1Handler);

    self._onClickTog2Handler = function(go) self:_OnClickTog2Handler(self) end
    UIUtil.GetComponent(self._btnTog2, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickTog2Handler);

    self._onClickTog3Handler = function(go) self:_OnClickTog3Handler(self) end
    UIUtil.GetComponent(self._btnTog3, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickTog3Handler);

    self._onClickTog4Handler = function(go) self:_OnClickTog4Handler(self) end
    UIUtil.GetComponent(self._btnTog4, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickTog4Handler);

    self._onClickBtnClose = function(go) self:_OnClickBtnClose(self) end
    UIUtil.GetComponent(self._btnClose, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtnClose);
end

function ArathiOverResultPanel:_Dispose()
    self:_DisposeListener();
    self:_DisposeReference();
end

function ArathiOverResultPanel:_DisposeListener()
    UIUtil.GetComponent(self._btnTog1, "LuaUIEventListener"):RemoveDelegate("OnClick");
    self._onClickTog1Handler = nil;

    UIUtil.GetComponent(self._btnTog2, "LuaUIEventListener"):RemoveDelegate("OnClick");
    self._onClickTog2Handler = nil;

    UIUtil.GetComponent(self._btnTog3, "LuaUIEventListener"):RemoveDelegate("OnClick");
    self._onClickTog3Handler = nil;

    UIUtil.GetComponent(self._btnTog4, "LuaUIEventListener"):RemoveDelegate("OnClick");
    self._onClickTog4Handler = nil;

    UIUtil.GetComponent(self._btnClose, "LuaUIEventListener"):RemoveDelegate("OnClick");
    self._onClickBtnClose = nil;

    -- MessageManager.RemoveListener(ArathiNotes, ArathiNotes.EVENT_ARATHIDATA, ArathiOverResultPanel._OnDataHandler);
end

function ArathiOverResultPanel:_DisposeReference()
    if (self._timer) then
        self._timer:Stop();
        self._timer = nil;
    end
    if (self._effBg) then
        Resourcer.Recycle(self._effBg, false);
        self._effBg = nil;
    end
    if (self._effWin) then
        Resourcer.Recycle(self._effWin, false);
        self._effWin = nil;
    end
    self._imgBg = nil;
    self._btnTog1 = nil;
    self._btnTog2 = nil;
    self._btnTog3 = nil;
    self._btnTog4 = nil;

    self._trsList = nil;
    self._scrollView = nil;
    self._phalanxInfo = nil;
    self._phalanx:Dispose()
    self._phalanx = nil;

    self._imgHeroIcon = nil;
    self._txtHeroName = nil;
    self._txtHeroLevel = nil;

    self._firstWinAward:Dispose();
    self._firstWinAward = nil;
    self._joinAward:Dispose();
    self._joinAward = nil;

    for i, v in pairs(self._rankAwards) do
        v:Dispose();
    end
    self._rankAwards = nil;
    self._rankAwardsTransform = nil;

    self._btnClose = nil;

    self._data = nil;
end

function ArathiOverResultPanel:_ShowEffect(win)
    if (win == 1) then
        self._effBg = UIUtil.GetUIEffect("ui_win_BG", self._trsContent, self._imgBg, 3);
        self._effWin = UIUtil.GetUIEffect("ui_win", self._trsContent, self._imgBg, 4);
        UIUtil.ScaleParticleSystem(self._effWin, 0.6);
        Util.SetLocalPos(self._effWin, 0, 230, 0)
        --        self._effWin.transform.localPosition = Vector3.New(0, 230, 0);
    else
        self._effBg = UIUtil.GetUIEffect("ui_lose", self._trsContent, self._imgBg, 3);
    end
    UIUtil.ScaleParticleSystem(self._effBg, 0.6);
    Util.SetLocalPos(self._effBg, 0, 230, 0)

    --    self._effBg.transform.localPosition = Vector3.New(0, 230, 0);
end

function ArathiOverResultPanel:_Opened()
    self._isOpened = true
    if (self._data) then
        self:_ShowEffect(self._data.win)
    end
end

function ArathiOverResultPanel:SetData(data)
    local hInfo = PlayerManager.hero.info
    self._data = data;

    if (hInfo.kind == 101000) then
        self._btnTog1.value = true
        self:_OnClickTog1Handler();
    elseif (hInfo.kind == 102000) then
        self._btnTog2.value = true
        self:_OnClickTog2Handler();
    elseif (hInfo.kind == 103000) then
        self._btnTog3.value = true
        self:_OnClickTog3Handler();
    elseif (hInfo.kind == 104000) then
        self._btnTog4.value = true
        self:_OnClickTog4Handler();
    end

    local tx = 360;
    if (self._isOpened) then
        self:_ShowEffect(self._data.win)
    end
    if (data) then
        if (data.faw) then
            local count = table.getCount(data.faw)
            if (count > 0) then
                self._firstWinAward:SetProductId(data.faw[1].spId, data.faw[1].am)
                self._firstWinAward:SetActive(true);
                tx = tx + 120;
            end
        else

        end
        if (data.jaw) then
            local count = table.getCount(data.jaw)
            if (count > 0) then
                local lpt = self._joinAward._transform.localPosition;
                self._joinAward:SetProductId(data.jaw[1].spId, data.jaw[1].am);
                Util.SetLocalPos(self._joinAward._transform, tx, lpt.y, lpt.z)
                --                self._joinAward._transform.localPosition = Vector3.New(tx, lpt.y, lpt.z);
                self._joinAward:SetActive(true);
                tx = tx + 120;
            end
        end
        if (data.raw) then
            local count = table.getCount(data.raw)
            if (count > 0) then
                local index = 1;
                if (count > 3) then count = 3 end
                local stx =(1 - count) * 60
                for i, v in pairs(data.raw) do
                    if (index <= 3) then
                        local item = self._rankAwards[index]
                        local slpt = item._transform.localPosition;
                        item:SetProductId(v.spId, v.am);
                        Util.SetLocalPos(item._transform, stx, slpt.y, slpt.z)
                        --                        item._transform.localPosition = Vector3.New(stx, slpt.y, slpt.z);
                        index = index + 1;
                        stx = stx + 120;
                    end
                end


                local lpt = self._rankAwardsTransform.localPosition;
                Util.SetLocalPos(self._rankAwardsTransform, tx +(count - 1) * 60, lpt.y, lpt.z)
                --                self._rankAwardsTransform.localPosition = Vector3.New(tx +(count - 1) * 60, lpt.y, lpt.z);
                self._rankAwardsTransform.gameObject:SetActive(true);
            end
        end
    end
end

function ArathiOverResultPanel:_OnClickBtnClose()
    if (self._data) then
        local to = { }
        to.sid = self._data.sid;
        to.position = Convert.PointFromServer(self._data.x, self._data.y, self._data.z);
        GameSceneManager.GotoScene(self._data.sid,nil,to);
    end
    ModuleManager.SendNotification(ArathiNotes.CLOSE_ARATHIOVERRESULTPANEL)
end

function ArathiOverResultPanel:_OnClickTog1Handler()
    local d = self._data["101000"];
    if (d == nil) then
        d = { };
    end
    self._phalanx:Build(table.getCount(d), 1, d);
    self._scrollView:ResetPosition();
end

function ArathiOverResultPanel:_OnClickTog2Handler()
    local d = self._data["102000"];
    if (d == nil) then
        d = { };
    end
    self._phalanx:Build(table.getCount(d), 1, d);
    self._scrollView:ResetPosition();
end

function ArathiOverResultPanel:_OnClickTog3Handler()
    local d = self._data["103000"];
    if (d == nil) then
        d = { };
    end
    self._phalanx:Build(table.getCount(d), 1, d);
    self._scrollView:ResetPosition();
end

function ArathiOverResultPanel:_OnClickTog4Handler()
    local d = self._data["104000"];
    if (d == nil) then
        d = { };
    end
    self._phalanx:Build(table.getCount(d), 1, d);
    self._scrollView:ResetPosition();
end

function ArathiOverResultPanel:_OnTickHandler()
    if (self._totalTime) then
        self._totalTime = self._totalTime - Timer.deltaTime;
        local cTime = math.ceil(self._totalTime);
        if (self._currTime ~= cTime) then
            self._currTime = cTime
            self._txtCloseLabel.text = LanguageMgr.Get("Arathi/OverResult/exit", { n = cTime });
        end
        if (cTime < 1) then
            self._totalTime = nil;
            self:_OnClickBtnClose()
        end
    end
end