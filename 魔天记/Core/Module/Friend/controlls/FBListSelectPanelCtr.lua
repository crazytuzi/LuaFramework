FBListSelectPanelCtr = class("FBListSelectPanelCtr");

function FBListSelectPanelCtr:New()
    self = { };
    setmetatable(self, { __index = FBListSelectPanelCtr });
    return self
end


function FBListSelectPanelCtr:Init(gameObject, groudDo2Bt)

    self.gameObject = gameObject;
    self.groudDo2Bt = groudDo2Bt;

    self.fbListBt = UIUtil.GetChildByName(self.gameObject, "Transform", "fbListBt");
    self.labelBg = UIUtil.GetChildByName(self.gameObject, "Transform", "labelBg");

    self.fbnameTxt = UIUtil.GetChildByName(self.gameObject, "UILabel", "fbnameTxt");
    self.fblvsTxt = UIUtil.GetChildByName(self.gameObject, "UILabel", "fblvsTxt");

    self.zidongPiPei_bt = UIUtil.GetChildByName(self.gameObject, "UIButton", "zidongPiPei_bt");
    self.zaomohanghua_bt = UIUtil.GetChildByName(self.gameObject, "UIButton", "zaomohanghua_bt");
    self.kaishifuben_bt = UIUtil.GetChildByName(self.gameObject, "UIButton", "kaishifuben_bt");
    self.kaishifuben_bt.gameObject:SetActive(false);

    self.pipeiIngTxt = UIUtil.GetChildByName(self.gameObject, "UILabel", "pipeiIngTxt");
    self.zidongPiPei_btLabel = UIUtil.GetChildByName(self.zidongPiPei_bt, "UILabel", "Label");

    self._showFBPiPeiPanel = function(go) self:_ShowFBPiPeiPanel(self) end
    UIUtil.GetComponent(self.fbListBt, "LuaUIEventListener"):RegisterDelegate("OnClick", self._showFBPiPeiPanel);
    UIUtil.GetComponent(self.labelBg, "LuaUIEventListener"):RegisterDelegate("OnClick", self._showFBPiPeiPanel);


    self._zidongPiPei_btHandler = function(go) self:_ZidongPiPei_btHandler(self) end
    UIUtil.GetComponent(self.zidongPiPei_bt, "LuaUIEventListener"):RegisterDelegate("OnClick", self._zidongPiPei_btHandler);

    self._zaomohanghua_btHandler = function(go) self:_Zaomohanghua_btHandler(self) end
    UIUtil.GetComponent(self.zaomohanghua_bt, "LuaUIEventListener"):RegisterDelegate("OnClick", self._zaomohanghua_btHandler);

    self._kaishifuben_btHandler = function(go) self:_Kaishifuben_btHandler(self) end
    UIUtil.GetComponent(self.kaishifuben_bt, "LuaUIEventListener"):RegisterDelegate("OnClick", self._kaishifuben_btHandler);


    MessageManager.AddListener(YaoQingPiPeiRightControll, YaoQingPiPeiRightControll.MESSAGE_YAOQINGPIPEIRIGHTCONTROLL_SELECTED_COMPLETE, FBListSelectPanelCtr.PiPeiSelectComplete, self);

    MessageManager.AddListener(TeamMatchDataManager, TeamMatchDataManager.MESSAGE_TEAMMATCH_PIPEI_SUCCESS, FBListSelectPanelCtr.PiPeiSuccessHandler, self);
    MessageManager.AddListener(TeamMatchDataManager, TeamMatchDataManager.MESSAGE_TEAMMATCH_PIPEI_ING, FBListSelectPanelCtr.PiPeiIngHandler, self);

    MessageManager.AddListener(TeamMatchDataManager, TeamMatchDataManager.MESSAGE_TEAMMATCH_RECPIPEIINFOS_CHANGE, FBListSelectPanelCtr.RecPipeiInfosHandler, self);

    MessageManager.AddListener(PartData, PartData.MESSAGE_PARTY_DATA_CHANGE, FBListSelectPanelCtr.MenberDataChange, self);


    self.pipei_ing_t = nil;


    self.pipeiIngTxt.gameObject:SetActive(false);


    if TeamMatchDataManager.currPiPeiIng_data ~= nil then
        self:PiPeiIngHandler(TeamMatchDataManager.currPiPeiIng_data.type)
    end

    local obj = TeamMatchDataManager.recPipeiInfos;
    if obj ~= nil then
        local t = obj.t;
        local lv = obj.lv;
        local min_lv = obj.min_lv;
        local max_lv = obj.max_lv;
        local cf = TeamMatchDataManager.GetCfByTypeAndmin_level(t, lv)
        if (cf.type == TeamMatchDataManager.type_1) then
            MessageManager.Dispatch(FriendNotes, FriendNotes.EVENT_CHANGE_INSTANCE);
        else
            MessageManager.Dispatch(FriendNotes, FriendNotes.EVENT_CHANGE_INSTANCE, cf.instance_id);
        end

    end

    local b = self:RecPipeiInfosHandler();
    if not b and FBListSelectPanelCtr.selectData ~= nil then

        self:SetInfosHandler(FBListSelectPanelCtr.selectData)

    end

end

-- 此函数 好像不再使用
function FBListSelectPanelCtr:SetInstanceId(val)


    self._currInstanceId = val;

    if FBListSelectPanelCtr.selectData ~= nil then
        self:CheckBts(FBListSelectPanelCtr.selectData.team_match_data);
    end



    --  self.kaishifuben_bt.gameObject:SetActive(self._currInstanceId ~= nil);
end

function FBListSelectPanelCtr:CheckBts(team_match_data)


    if team_match_data ~= nil and(team_match_data.type == TeamMatchDataManager.type_1) then

        self.kaishifuben_bt.gameObject:SetActive(false);
        -- self.groudDo2Bt.gameObject:SetActive(false);
    else
        -- self.kaishifuben_bt.gameObject:SetActive(self._currInstanceId ~= nil);
        -- self.groudDo2Bt.gameObject:SetActive(self._currInstanceId ~= nil);
        self.kaishifuben_bt.gameObject:SetActive(true);
        --- self.groudDo2Bt.gameObject:SetActive(true);
    end

end

function FBListSelectPanelCtr:IsCanDo()

    local mt = PartData.GetMyTeam();
    local b = PartData.MeIsTeamLeader();

    if mt ~= nil and not b then
        return false;
    end

    return true;
end


function FBListSelectPanelCtr:_ZidongPiPei_btHandler()

    if self.pipei_ing_t ~= nil then
        -- 需要取消匹配
        TeamMatchDataManager.QuXianPiPei(self.pipei_ing_t);
    else
        self:TryPiPei();


    end

end

function FBListSelectPanelCtr:TryPiPei()

    local b = FBListSelectPanelCtr:IsCanDo();

    if b then

        if FBListSelectPanelCtr.selectData ~= nil then

            local team_match_data = FBListSelectPanelCtr.selectData.team_match_data;
            local min_lv = FBListSelectPanelCtr.selectData.min_lv;
            local max_lv = FBListSelectPanelCtr.selectData.max_lv;

            self.hasPipei_t = nil;
            TeamMatchDataManager.TeamMatchPiPei(team_match_data, min_lv, max_lv);

        else
            MsgUtils.ShowTips("Friend/FBListSelectPanelCtr/label10");

        end

    else
        MsgUtils.ShowTips("Friend/FBListSelectPanelCtr/label1");
    end


end

function FBListSelectPanelCtr:_Zaomohanghua_btHandler()

    local b = FBListSelectPanelCtr:IsCanDo();

    if b then

        if FBListSelectPanelCtr.selectData ~= nil then

            local num = PartData.GetMyTeamNunberNum();

            if num == 4 then
                MsgUtils.ShowTips("ZongMenLiLian/ZongMenLiLianPanel/label5");
            else
                local team_match_data = FBListSelectPanelCtr.selectData.team_match_data;


                ZongMenLiLianProxy.ZongMenLiLianYaoQing(team_match_data.type, FBListSelectPanelCtr.selectData.min_lv, FBListSelectPanelCtr.selectData.max_lv)
            end

        else
            MsgUtils.ShowTips("Friend/FBListSelectPanelCtr/label2");
        end


    else
        MsgUtils.ShowTips("Friend/FBListSelectPanelCtr/label3");
    end


end

function FBListSelectPanelCtr:SangleWantFightTeamFBHandler(data)
  local fb_id = data.fb_id;

    -- 发送进入副本邀请
    GameSceneManager.GoToFB(fb_id)
end

function FBListSelectPanelCtr:_Kaishifuben_btHandler()
    if (self._currInstanceId) then

        local mt = PartData.GetMyTeam();

        if mt == nil then
        -- http://192.168.0.8:3000/issues/6906
         ModuleManager.SendNotification(ConfirmNotes.OPEN_CONFIRM1PANEL, {
            title = LanguageMgr.Get("common/notice"),
            msg = LanguageMgr.Get("Friend/FBListSelectPanelCtr/label11"),
            ok_Label = LanguageMgr.Get("common/ok"),
            cance_lLabel = LanguageMgr.Get("common/cancle"),
            hander = FriendProxy.TryCreateArmy,
            target = nil,
            data = {fun=FBListSelectPanelCtr.SangleWantFightTeamFBHandler,fun_target=self,data={fb_id=self._currInstanceId}}
        } );

        else
            -- 检测 自己是否 是队长
            local isMb = PartData.MeIsTeamLeader();
            if isMb then

                -- 发送进入副本邀请
                GameSceneManager.GoToFB(self._currInstanceId)
            else
                MsgUtils.ShowTips("LSInstance/LSBottomPanelCtr/label5");
            end
        end



    end
end

function FBListSelectPanelCtr:PiPeiSelectComplete(data)

    FBListSelectPanelCtr.selectData = data;

    local team_match_data = data.team_match_data;
    local min_lv = data.min_lv;
    local max_lv = data.max_lv;
    local isAutoPiPei = data.isAutoPiPei;


    self:SetLabelInfo(team_match_data, min_lv, max_lv);



    if isAutoPiPei then
        -- 需要匹配 新的状态
        self:TryPiPei();
    else
        -- 需要取消之前匹配的 状态
        if self.pipei_ing_t ~= nil then
            -- 需要取消匹配
            TeamMatchDataManager.QuXianPiPei(self.pipei_ing_t);
        end
    end



    if (team_match_data.type == TeamMatchDataManager.type_1) then
        MessageManager.Dispatch(FriendNotes, FriendNotes.EVENT_CHANGE_INSTANCE);
    else
        MessageManager.Dispatch(FriendNotes, FriendNotes.EVENT_CHANGE_INSTANCE, team_match_data.instance_id);
    end

    self:CheckBts(team_match_data);

end


function FBListSelectPanelCtr:SetLabelInfo(team_match_data, min_lv, max_lv)


    self._currInstanceId = team_match_data.instance_id;

    self.fbnameTxt.text = LanguageMgr.Get("Friend/FBListSelectPanelCtr/label4", { n = team_match_data.name });

    if min_lv > max_lv then
        self.fblvsTxt.text = LanguageMgr.Get("Friend/FBListSelectPanelCtr/label5", { min = GetLvDes1(max_lv), max = GetLvDes1(min_lv) });
    else
        self.fblvsTxt.text = LanguageMgr.Get("Friend/FBListSelectPanelCtr/label5", { min = GetLvDes1(min_lv), max = GetLvDes1(max_lv) });
    end


end


-- 匹配成功
function FBListSelectPanelCtr:PiPeiSuccessHandler(t)

    self.pipei_ing_t = nil;
    self.pipeiIngTxt.gameObject:SetActive(false);
    self.zidongPiPei_btLabel.text = LanguageMgr.Get("Friend/FBListSelectPanelCtr/label6");

end

function FBListSelectPanelCtr:PiPeiIngHandler(t)

    self.pipei_ing_t = t;
    self.pipeiIngTxt.gameObject:SetActive(true);
    self.zidongPiPei_btLabel.text = LanguageMgr.Get("Friend/FBListSelectPanelCtr/label9");



    local tnum = PartData.GetMyTeamNunberNum();
    local me_tl = PartData.MeIsTeamLeader();
    if (tnum > 1 and not me_tl) or tnum == 4 then
        self:PiPeiSuccessHandler(t)
    end


end

function FBListSelectPanelCtr:MenberDataChange(type)

    local t_num = PartData.GetMyTeamNunberNum();
    if t_num == 4 then
        self:PiPeiSuccessHandler(t)
    end

end

function FBListSelectPanelCtr:_ShowFBPiPeiPanel()

    local b = FBListSelectPanelCtr:IsCanDo();

    if b then
        ModuleManager.SendNotification(FriendNotes.OPEN_YAOQINGPIPEIPANEL, FBListSelectPanelCtr.selectData);
    else
        MsgUtils.ShowTips("Friend/FBListSelectPanelCtr/label8");
    end


end

function FBListSelectPanelCtr:RecPipeiInfosHandler()

    local obj = TeamMatchDataManager.recPipeiInfos;

    if obj ~= nil then

        local t = obj.t;
        local lv = obj.lv;
        local min_lv = obj.min_lv;
        local max_lv = obj.max_lv;

        local cf = TeamMatchDataManager.GetCfByTypeAndmin_level(t, lv)
        -------------------------------------
        local data = { };
        data.team_match_data = cf;
        data.min_lv = min_lv;
        data.max_lv = max_lv;
        data.isAutoPiPei = true;

        self:SetInfosHandler(data)
        return true;
    end

    return false;
end

function FBListSelectPanelCtr:SetInfosHandler(data)

    FBListSelectPanelCtr.selectData = data;
    -------------------------------------
    local team_match_data = data.team_match_data;
    self:SetLabelInfo(team_match_data, data.min_lv, data.max_lv);

    self:CheckBts(team_match_data);

end

function FBListSelectPanelCtr:Dispose()


    MessageManager.RemoveListener(YaoQingPiPeiRightControll, YaoQingPiPeiRightControll.MESSAGE_YAOQINGPIPEIRIGHTCONTROLL_SELECTED_COMPLETE, FBListSelectPanelCtr.PiPeiSelectComplete);
    MessageManager.RemoveListener(TeamMatchDataManager, TeamMatchDataManager.MESSAGE_TEAMMATCH_PIPEI_SUCCESS, FBListSelectPanelCtr.PiPeiSuccessHandler);
    MessageManager.RemoveListener(TeamMatchDataManager, TeamMatchDataManager.MESSAGE_TEAMMATCH_PIPEI_ING, FBListSelectPanelCtr.PiPeiIngHandler);
    MessageManager.RemoveListener(TeamMatchDataManager, TeamMatchDataManager.MESSAGE_TEAMMATCH_RECPIPEIINFOS_CHANGE, FBListSelectPanelCtr.RecPipeiInfosHandler);
    MessageManager.RemoveListener(PartData, PartData.MESSAGE_PARTY_DATA_CHANGE, FBListSelectPanelCtr.MenberDataChange);

    UIUtil.GetComponent(self.fbListBt, "LuaUIEventListener"):RemoveDelegate("OnClick");
    UIUtil.GetComponent(self.labelBg, "LuaUIEventListener"):RemoveDelegate("OnClick");

    UIUtil.GetComponent(self.zidongPiPei_bt, "LuaUIEventListener"):RemoveDelegate("OnClick");

    UIUtil.GetComponent(self.zaomohanghua_bt, "LuaUIEventListener"):RemoveDelegate("OnClick");

    UIUtil.GetComponent(self.kaishifuben_bt, "LuaUIEventListener"):RemoveDelegate("OnClick");

    self._showFBPiPeiPanel = nil;
    self._zidongPiPei_btHandler = nil;
    self._zaomohanghua_btHandler = nil;
    self._kaishifuben_btHandler = nil
end 