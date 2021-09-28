require "Core.Module.Common.Panel";

ArathiSignupPanel = Panel:New();

local timeCfg = ConfigManager.GetConfig(ConfigManager.CONFIGNAME_BATTLEGROUND_TIME);
local arathiActivityItem = ActivityDataManager.GetCfByInterface_id(ActivityDataManager.interface_id_15);
local signNum = 2 --3
function ArathiSignupPanel:_Init()

    self:_InitReference();
    self:_InitListener();
    self._turn = 1;
    self._currCount = 0;
    self._timer = Timer.New( function(val) self:_OnTickHandler(val) end, 0.4, -1, false);
    self._timer:Start();
    self:_OnTickHandler();
end

function ArathiSignupPanel:_InitReference()
    self._btnClose = UIUtil.GetChildByName(self._trsContent, "UIButton", "btnClose");
    self._txtCurrTime = UIUtil.GetChildByName(self._trsContent, "UILabel", "txtCurrTime");
    self._txtCurrNum = UIUtil.GetChildByName(self._trsContent, "UILabel", "txtCurrNum");

    self._txtTimes = { }
    self._txtSignupeds = { }
    self._btnSignups = { }

    for i = 1, signNum do
        self._txtTimes[i] = UIUtil.GetChildByName(self._trsContent, "UILabel", "trsTime" .. i .. "/txtTime");
        self._txtSignupeds[i] = UIUtil.GetChildByName(self._trsContent, "UILabel", "trsTime" .. i .. "/txtSignuped");
        self._btnSignups[i] = UIUtil.GetChildByName(self._trsContent, "UIButton", "trsTime" .. i .. "/btnSignup");
    end

end

function ArathiSignupPanel:_InitListener()
    self._onClickBtnClose = function(go) self:_OnClickBtnClose(self) end
    UIUtil.GetComponent(self._btnClose, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtnClose);

    self._onClickBtnSignup1 = function(go) self:_OnClickBtnSignup1(self) end
    UIUtil.GetComponent(self._btnSignups[1], "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtnSignup1);

    self._onClickBtnSignup2 = function(go) self:_OnClickBtnSignup2(self) end
    UIUtil.GetComponent(self._btnSignups[2], "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtnSignup2);

--    self._onClickBtnSignup3 = function(go) self:_OnClickBtnSignup3(self) end
--    UIUtil.GetComponent(self._btnSignups[3], "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtnSignup3);

    MessageManager.AddListener(ArathiNotes, ArathiNotes.EVENT_ARATHISIGNUP, ArathiSignupPanel._OnDataHandler, self);
end

function ArathiSignupPanel:_Dispose()
    self:_DisposeListener();
    self:_DisposeReference();
end

function ArathiSignupPanel:_DisposeListener()
    UIUtil.GetComponent(self._btnClose, "LuaUIEventListener"):RemoveDelegate("OnClick");
    self._onClickBtnClose = nil;

    UIUtil.GetComponent(self._btnSignups[1], "LuaUIEventListener"):RemoveDelegate("OnClick");
    self._onClickBtnSignup1 = nil;

    UIUtil.GetComponent(self._btnSignups[2], "LuaUIEventListener"):RemoveDelegate("OnClick");
    self._onClickBtnSignup2 = nil;

--    UIUtil.GetComponent(self._btnSignups[3], "LuaUIEventListener"):RemoveDelegate("OnClick");
--    self._onClickBtnSignup3 = nil;

    MessageManager.RemoveListener(ArathiNotes, ArathiNotes.EVENT_ARATHISIGNUP, ArathiSignupPanel._OnDataHandler);
end

function ArathiSignupPanel:_DisposeReference()
    self._timer:Stop();
    self._timer = nil;

    self._btnClose = nil;
    self._txtCurrTime = nil;
    self._txtCurrNum = nil;

    for i = 1, signNum do
        self._txtTimes[i] = nil;
        self._txtSignupeds[i] = nil;
        self._btnSignups[i] = nil;
    end
    self._txtTimes = nil;
    self._txtSignupeds = nil;
    self._btnSignups = nil;
end

local canUseTime = LanguageMgr.Get("ArathiSignupPanel/canUseTime")
function ArathiSignupPanel:SetData(data)
    self._data = data;
    self._turn = data.turn
    local tid =(self._turn - 1) * 3;
    local maxCount = 3;
    self._currCount = data.bts;
    if (arathiActivityItem) then maxCount = arathiActivityItem.activity_times end
    if (data.bts > maxCount) then data.bts = maxCount end
    self._currCount = maxCount - data.bts
    for i = 1, signNum do
        local id = tid + i;
        local t = timeCfg[id];
        local txtTime = self._txtTimes[i];
        local txtSignuped = self._txtSignupeds[i];
        local btnSignup = self._btnSignups[i];
        local status = self:_GetStatusById(id, data.el);
        txtTime.text = t["enter"] .. "-" .. t["end"];
        btnSignup.gameObject:SetActive(status ~= 1);
        btnSignup.isEnabled =(status ~= 2);
        txtSignuped.gameObject:SetActive(status == 1);
        if (status == 1) then
            self._currCount = self._currCount - 1
        end
    end
    self._txtCurrNum.text = canUseTime..(maxCount - data.bts) .. "/" .. maxCount .. "[-]"
end

function ArathiSignupPanel:_GetStatusById(id, ls)
    if (ls) then
        for i, v in pairs(ls) do
            if (v.id == id) then
                return v.st;
            end
        end
    end
    return 0
end

function ArathiSignupPanel:_OnDataHandler(data)
    local tid =(self._turn - 1) * 3;
    local id = data.id - tid;
    local txtTime = self._txtTimes[id];
    local txtSignuped = self._txtSignupeds[id];
    local btnSignup = self._btnSignups[id];
    btnSignup.gameObject:SetActive(false);
    btnSignup.isEnabled =(true);
    txtSignuped.gameObject:SetActive(true);
    self._currCount = self._currCount - 1;
    if (self._data) then
        for i, v in pairs(self._data.el) do
            if (v.id == data.id) then
                v.st = 1;
            end
        end
    end
end

local curTime = LanguageMgr.Get("ArathiSignupPanel/curTime")
function ArathiSignupPanel:_OnTickHandler()
    self._txtCurrTime.text = curTime .. os.date("%X", GetOffsetTime())
end

function ArathiSignupPanel:_OnClickBtnClose()
    ModuleManager.SendNotification(ArathiNotes.CLOSE_ARATHISIGNUPPANEL)
end

function ArathiSignupPanel:_OnClickBtnSignup1()
    if (self._currCount > 0) then
        local id =(self._turn - 1) * 3 + 1;
        ArathiProxy.ArathiSignup(id);
    else
        MsgUtils.ShowTips(nil, nil, nil, LanguageMgr.Get("Arathi/Signup/countErr"));
    end
end

function ArathiSignupPanel:_OnClickBtnSignup2()
    if (self._currCount > 0) then
        local id =(self._turn - 1) * 3 + 2;
        ArathiProxy.ArathiSignup(id);
    else
        MsgUtils.ShowTips(nil, nil, nil, LanguageMgr.Get("Arathi/Signup/countErr"));
    end
end

function ArathiSignupPanel:_OnClickBtnSignup3()
    if (self._currCount > 0) then
        local id =(self._turn - 1) * 3 + 3;
        ArathiProxy.ArathiSignup(id);
    else
        MsgUtils.ShowTips(nil, nil, nil, LanguageMgr.Get("Arathi/Signup/countErr"));
    end
end