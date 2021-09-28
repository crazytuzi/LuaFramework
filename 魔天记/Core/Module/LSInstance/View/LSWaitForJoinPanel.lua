require "Core.Module.Common.Panel"

require "Core.Module.LSInstance.View.item.LSRoleItem"

LSWaitForJoinPanel = class("LSWaitForJoinPanel", Panel);
function LSWaitForJoinPanel:New()
    self = { };
    setmetatable(self, { __index = LSWaitForJoinPanel });
    return self
end


function LSWaitForJoinPanel:_Init()
    self:_InitReference();
    self:_InitListener();
end

function LSWaitForJoinPanel:_InitReference()
    local btns = UIUtil.GetComponentsInChildren(self._trsContent, "UIButton");
    self._btn_close = UIUtil.GetChildInComponents(btns, "btn_close");
    self._btn_ok = UIUtil.GetChildInComponents(btns, "btn_ok");
    self._btn_no = UIUtil.GetChildInComponents(btns, "btn_no");

    self.mainView = UIUtil.GetChildByName(self._trsContent, "Transform", "mainView");

    self.titleTxt = UIUtil.GetChildByName(self.mainView, "UILabel", "titleTxt");
    self.timeTxt = UIUtil.GetChildByName(self.mainView, "UILabel", "timeTxt");
    self.waitForTipTxt = UIUtil.GetChildByName(self.mainView, "UILabel", "waitForTipTxt");

    --  self._txtGuYong = UIUtil.GetChildByName(self.mainView, "UILabel", "txtGuYong");

    for i = 1, 4 do
        self["roleItem" .. i] = UIUtil.GetChildByName(self.mainView, "Transform", "roleItem" .. i);
        self["roleItemCtr" .. i] = LSRoleItem:New();
        self["roleItemCtr" .. i]:Init(self["roleItem" .. i]);
    end

    MessageManager.AddListener(PartData, PartData.MESSAGE_PARTY_DATA_CHANGE, LSWaitForJoinPanel.PartDataChangeHandler, self);
    MessageManager.AddListener(PartData, PartData.MESSAGE_PARTY_MENBER_ACCEPT_CHANGE, LSWaitForJoinPanel.PartAcceptChangeHandler, self);

     MessageManager.AddListener(LSInstanceProxy, LSInstanceProxy.MESSAGE_TREAMCANCLETOFB, LSWaitForJoinPanel.TreamCancleToFbResult, self);

    self:UpData(0);
    self._fb_else_totalTime = 20;
    self:FBJoinElseTimeChange();

    self.hasSetAnswer = false;
end

function LSWaitForJoinPanel:_InitListener()
    self._onClickBtn_close = function(go) self:_OnClickBtn_close(self) end
    UIUtil.GetComponent(self._btn_close, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtn_close);
    self._onClickBtn_ok = function(go) self:_OnClickBtn_ok(self) end
    UIUtil.GetComponent(self._btn_ok, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtn_ok);
    self._onClickBtn_no = function(go) self:_OnClickBtn_no(self) end
    UIUtil.GetComponent(self._btn_no, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtn_no);
end

function LSWaitForJoinPanel:_OnClickBtn_close()

    if not self.hasSetAnswer and not self.isMb then

        -- 如果最近是队长 ， 那就不做处理

        self:_OnClickBtn_no();
    end

    ModuleManager.SendNotification(LSInstanceNotes.CLOSE_LSWAITFORJOINPANEL);
end

function LSWaitForJoinPanel:_OnClickBtn_ok()

  local b = AppSplitDownProxy.Loaded();
    if not b then
        MsgUtils.ShowTips("LSInstance/LSWaitForJoinPanel/label3");
        self:_OnClickBtn_no()
        return;
    end

    self.hasSetAnswer = true;
    LSInstanceProxy.AskTeamToFbTip_OK()
end

function LSWaitForJoinPanel:_OnClickBtn_no()
    self.hasSetAnswer = true;
    ModuleManager.SendNotification(LSInstanceNotes.CLOSE_LSWAITFORJOINPANEL);
    LSInstanceProxy.AskTeamToFbTip_Cancel()
end

function LSWaitForJoinPanel:PartDataChangeHandler(type)

    -- 队伍发生改变的时候， 关闭  界面， 需要队长重新邀请
    --  http://192.168.0.8:3000/issues/796
    -- self:UpData()

    ModuleManager.SendNotification(LSInstanceNotes.CLOSE_LSWAITFORJOINPANEL);

end

-- 
function LSWaitForJoinPanel:PartAcceptChangeHandler()

    self:UpData()
end

function LSWaitForJoinPanel:TreamCancleToFbResult()

    ModuleManager.SendNotification(LSInstanceNotes.CLOSE_LSWAITFORJOINPANEL);
end


function LSWaitForJoinPanel:UpData()
    self:UpTeamInfo()

end

function LSWaitForJoinPanel:SetFbId(fb_id, guyong)
    self._guyong = guyong or 0;
    self.fb_id = fb_id;
    self.fb_cf = InstanceDataManager.GetMapCfById(fb_id);
    self.titleTxt.text = LanguageMgr.Get("LSInstance/LSWaitForJoinPanel/label1", { n = self.fb_cf.name });
    -- self._txtGuYong.text = LanguageMgr.Get("LSInstance/LSWaitForJoinPanel/label2", { n = (guyong or 0) });
    self:UpTeamInfo();
end

function LSWaitForJoinPanel:UpTeamInfo()


    local isMb = PartData.MeIsTeamLeader();


    self.isMb = isMb;

    for i = 1, 4 do
        self["roleItemCtr" .. i]:SetActive(false);
    end

    local teamArr = PartData.GetMyTeam().m;
    local t_num = table.getn(teamArr);
    if t_num > PartData.TEAM_MAX_NUM then
        t_num = PartData.TEAM_MAX_NUM;
    end
    for i = 1, t_num do
        self["roleItemCtr" .. i]:SetData(teamArr[i]);
    end

    self.waitAction = false;

    if isMb then

        self._btn_ok.gameObject:SetActive(false);
        self._btn_no.gameObject:SetActive(false);
        self.waitForTipTxt.gameObject:SetActive(true);
    else

        -- 检测自己是否 已经 做了接受操作
        self.waitForTipTxt.gameObject:SetActive(false);

        local myHero = HeroController.GetInstance();
        local mydata = myHero.info;

        local md = PartData.FindMyTeammateData(mydata.id);


        if md ~= nil and md.accept ~= nil then
            self._btn_ok.gameObject:SetActive(false);
            self._btn_no.gameObject:SetActive(false);
            self.waitAction = false;
        else
            self._btn_ok.gameObject:SetActive(true);
            self._btn_no.gameObject:SetActive(true);
            self.waitAction = true;
        end


    end


end

function LSWaitForJoinPanel:FBJoinElseTimeChange()


    local tem_str = self._fb_else_totalTime;

    if tem_str < 0 then
        tem_str = 0;
    end

    self.timeTxt.text = "" .. tem_str;

    self._sec_timer = Timer.New( function()

        self._fb_else_totalTime = self._fb_else_totalTime - 1;

        local tem_str = self._fb_else_totalTime;

        if tem_str < 0 then
            tem_str = 0;
        end

        self.timeTxt.text = "" .. tem_str;

        if self._fb_else_totalTime <= 0 then

            -- 默认 接受
            if self.waitAction then
                -- self:_OnClickBtn_no()
                self:_OnClickBtn_ok()
            end

            if self._sec_timer ~= nil then
                self._sec_timer:Stop();
                self._sec_timer = nil;
            end

        end

    end , 1, self._fb_else_totalTime + 0, false);
    self._sec_timer:Start();

end


function LSWaitForJoinPanel:_Dispose()
    self:_DisposeListener();
    self:_DisposeReference();
end

function LSWaitForJoinPanel:_DisposeListener()
    UIUtil.GetComponent(self._btn_close, "LuaUIEventListener"):RemoveDelegate("OnClick");
    self._onClickBtn_close = nil;
    UIUtil.GetComponent(self._btn_ok, "LuaUIEventListener"):RemoveDelegate("OnClick");
    self._onClickBtn_ok = nil;
    UIUtil.GetComponent(self._btn_no, "LuaUIEventListener"):RemoveDelegate("OnClick");
    self._onClickBtn_no = nil;
end

function LSWaitForJoinPanel:_DisposeReference()
    self._btn_close = nil;
    self._btn_ok = nil;
    self._btn_no = nil;

    for i = 1, 4 do
        self["roleItemCtr" .. i]:Dispose();
        self["roleItemCtr" .. i] = nil;
        self["roleItem" .. i] = nil;
    end

    MessageManager.RemoveListener(PartData, PartData.MESSAGE_PARTY_DATA_CHANGE, LSWaitForJoinPanel.PartDataChangeHandler);
    MessageManager.RemoveListener(PartData, PartData.MESSAGE_PARTY_MENBER_ACCEPT_CHANGE, LSWaitForJoinPanel.PartAcceptChangeHandler);
    MessageManager.RemoveListener(LSInstanceProxy, LSInstanceProxy.MESSAGE_TREAMCANCLETOFB, LSWaitForJoinPanel.TreamCancleToFbResult, self);

    if self._sec_timer ~= nil then
        self._sec_timer:Stop();
        self._sec_timer = nil;
    end

    self.mainView = nil;

    self.titleTxt = nil;
    self.timeTxt = nil;
    self.waitForTipTxt = nil;
    -- self._txtGuYong = nil;


end
