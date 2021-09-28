require "Core.Module.Common.Panel"

require "Core.Module.ZongMenLiLian.View.item.ZongMenLiLianItem"
require "Core.Module.ZongMenLiLian.controll.ZMLLBottomPanelCtr"

require "Core.Manager.Item.TeamMatchDataManager"

ZongMenLiLianPanel = class("ZongMenLiLianPanel", Panel);


ZongMenLiLianPanel.MESSAGE_ZONGMENLILIAN_TRY_ACTIVE = "MESSAGE_ZONGMENLILIAN_TRY_ACTIVE";

function ZongMenLiLianPanel:New()
    self = { };
    setmetatable(self, { __index = ZongMenLiLianPanel });
    return self
end


function ZongMenLiLianPanel:_Init()
    self:_InitReference();
    self:_InitListener();
end

function ZongMenLiLianPanel:_InitReference()
    local btns = UIUtil.GetComponentsInChildren(self._trsContent, "UIButton");
    self._btn_close = UIUtil.GetChildInComponents(btns, "btn_close");
    self._btnTiaozhan = UIUtil.GetChildInComponents(btns, "btnTiaozhan");
    self._btnpipei = UIUtil.GetChildInComponents(btns, "btnpipei");
    self._btn_nkonw = UIUtil.GetChildInComponents(btns, "btn_nkonw");

    self.btn_aoqing = UIUtil.GetChildInComponents(btns, "btn_aoqing");


    self.mainView = UIUtil.GetChildByName(self._trsContent, "Transform", "mainView");
    self.listPanel = UIUtil.GetChildByName(self.mainView, "Transform", "listPanel");
    self.subPanel = UIUtil.GetChildByName(self.listPanel, "Transform", "subPanel");

    self.subPanelScrollView = UIUtil.GetChildByName(self.listPanel, "UIScrollView", "subPanel");

    self._table = UIUtil.GetChildByName(self.subPanel, "Transform", "table");
    self._tablephalanx = UIUtil.GetChildByName(self.subPanel, "LuaAsynPhalanx", "table");




    self.bottomPanel = UIUtil.GetChildByName(self.mainView, "Transform", "bottomPanel");
    self.bottomPanelCtr = ZMLLBottomPanelCtr:New();
    self.bottomPanelCtr:Init(self.bottomPanel)

    self._btnpipeiLabel = UIUtil.GetChildByName(self._btnpipei, "UILabel", "Label");
    self.pipeiIngTxt = UIUtil.GetChildByName(self.bottomPanel, "UILabel", "pipeiIngTxt");

    self:InitFbList();


    MessageManager.AddListener(TeamMatchDataManager, TeamMatchDataManager.MESSAGE_TEAMMATCH_PIPEI_ING, ZongMenLiLianPanel.PiPeiIngHandler, self);
    MessageManager.AddListener(TeamMatchDataManager, TeamMatchDataManager.MESSAGE_TEAMMATCH_PIPEI_SUCCESS, ZongMenLiLianPanel.PiPeiSuccessHandler, self);

    MessageManager.AddListener(PartData, PartData.MESSAGE_PARTY_DATA_CHANGE, ZongMenLiLianPanel.PartDataChangeHandler, self);


    self.pipeiIngTxt.gameObject:SetActive(false);


    ZongMenLiLianProxy.GetZongMenInfo();

    if TeamMatchDataManager.currPiPeiIng_data ~= nil and TeamMatchDataManager.currPiPeiIng_data.type == TeamMatchDataManager.type_1 then
        self.pipeiIngTxt.gameObject:SetActive(true);
        self._btnpipeiLabel.text = LanguageMgr.Get("ZongMenLiLian/ZongMenLiLianPanel/label1");


        local tnum = PartData.GetMyTeamNunberNum();
        local me_tl = PartData.MeIsTeamLeader();
        if tnum > 1 and not me_tl then
            self.pipeiIngTxt.gameObject:SetActive(false);
            self._btnpipeiLabel.text = LanguageMgr.Get("ZongMenLiLian/ZongMenLiLianPanel/label2");
        end


    else
        self.pipeiIngTxt.gameObject:SetActive(false);
        self._btnpipeiLabel.text = LanguageMgr.Get("ZongMenLiLian/ZongMenLiLianPanel/label2");
    end


    self:PartDataChangeHandler();
end

function ZongMenLiLianPanel:_InitListener()
    self._onClickBtn_close = function(go) self:_OnClickBtn_close(self) end
    UIUtil.GetComponent(self._btn_close, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtn_close);
    self._onClickBtnTiaozhan = function(go) self:_OnClickBtnTiaozhan(self) end
    UIUtil.GetComponent(self._btnTiaozhan, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtnTiaozhan);
    self._onClickBtnpipei = function(go) self:_OnClickBtnpipei(self) end
    UIUtil.GetComponent(self._btnpipei, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtnpipei);
    self._onClickBtn_nkonw = function(go) self:_OnClickBtn_nkonw(self) end
    UIUtil.GetComponent(self._btn_nkonw, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtn_nkonw);

    self._onClickBtn_aoqing = function(go) self:_OnClickBtn_aoqing(self) end
    UIUtil.GetComponent(self.btn_aoqing, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtn_aoqing);
end




function ZongMenLiLianPanel:_OnClickBtn_close()
    SequenceManager.TriggerEvent(SequenceEventType.Guide.PANEL_CLOSEBTN_CLICK, self._name);
    ModuleManager.SendNotification(ZongMenLiLianNotes.CLOSE_ZONGMENLILIANPANEL);
end

function ZongMenLiLianPanel:_OnClickBtnTiaozhan()



    -- 如果 已经开启 过了， 那么 就不需要 再次 开启
    local info = ZongMenLiLianDataManager.GetZongMenLiLianPreInfo();

    if info == nil then

        local tm = PartData.GetMyTeam();
        local t_num = PartData.GetMyTeamNunberNum();

        local ins_cf = InstanceDataManager.GetFirstInsCf(InstanceDataManager.InstanceType.type_ZongMenLiLian);
        local min_num = ins_cf.min_num;


        if tm == nil then

            MsgUtils.ShowTips("LSInstance/LSBottomPanelCtr/label6");

            self:GotoTeamUIAndClose(self.bottomPanelCtr.data,true)
            return;

        elseif t_num < min_num then
            MsgUtils.ShowTips("LSInstance/LSBottomPanelCtr/label4");

            self:GotoTeamUIAndClose(self.bottomPanelCtr.data,true)
            return;

        end


        ZongMenLiLianProxy.OpenZongMenLiLian();
    else
         ModuleManager.SendNotification(ActivityNotes.CLOSE_ACTIVITY);
        MessageManager.Dispatch(ZongMenLiLianPanel, ZongMenLiLianPanel.MESSAGE_ZONGMENLILIAN_TRY_ACTIVE);
    end


    self:_OnClickBtn_close();

end

--  http://192.168.0.8:3000/issues/4158
function ZongMenLiLianPanel:GotoTeamUIAndClose(data,setPipeiData)
   
   local res = ConfigManager.Clone(data);
   
    ModuleManager.SendNotification(ActivityNotes.CLOSE_ACTIVITY);

    ModuleManager.SendNotification(FriendNotes.OPEN_FRIENDPANEL, FriendNotes.PANEL_PARTY);

    if setPipeiData then
       YaoQingPiPeiRightControll.SetPiPeiInfos(res, res.min_level, res.max_level, false)
  
    end
   
    self:_OnClickBtn_close()

end

function ZongMenLiLianPanel:_OnClickBtnpipei()

    if ZongMenLiLianItem.currSelected ~= nil then

        SequenceManager.TriggerEvent(SequenceEventType.Guide.ZONGMEN_MATCH);

        if TeamMatchDataManager.currPiPeiIng_data ~= nil and TeamMatchDataManager.currPiPeiIng_data.type == TeamMatchDataManager.type_1 then
            TeamMatchDataManager.QuXianPiPei(TeamMatchDataManager.type_1);
            return;
        end

        -- 如果队伍人数 是 4 人， 那么就队伍满， 不需要匹配
        local pnum = PartData.GetMyTeamNunberNum();
        if pnum == 4 then
            MsgUtils.ShowTips(nil, nil, nil, LanguageMgr.Get("ZongMenLiLian/ZongMenLiLianPanel/label3"));
            return;
        end

        -------------------------------------------------------------------------

        local fbd = ZongMenLiLianItem.currSelected.data;

        -- 如果自己没有队伍， 那么可以 操作， 如果自己有队伍，只能队长才能操作
        local mt = PartData.GetMyTeam();
        if mt == nil then
            self:DoMatch(fbd);
        else
            local misl = PartData.MeIsTeamLeader();
            if misl then
                self:DoMatch(fbd);
            else
                MsgUtils.ShowTips(nil, nil, nil, LanguageMgr.Get("ZongMenLiLian/ZongMenLiLianPanel/label4"));

            end
        end

    end


end

function ZongMenLiLianPanel:DoMatch(fbd)

    TeamMatchDataManager.TeamMatchPiPei(fbd);
    -- http://192.168.0.8:3000/issues/4158
    self:GotoTeamUIAndClose(self.bottomPanelCtr.data,false)
end

function ZongMenLiLianPanel:PiPeiIngHandler(t)

    if t == TeamMatchDataManager.type_1 then
        self.pipeiIngTxt.gameObject:SetActive(true);
        self._btnpipeiLabel.text = LanguageMgr.Get("ZongMenLiLian/ZongMenLiLianPanel/label1");
    else
        self.pipeiIngTxt.gameObject:SetActive(false);
        self._btnpipeiLabel.text = LanguageMgr.Get("ZongMenLiLian/ZongMenLiLianPanel/label2");
    end

end


function ZongMenLiLianPanel:PiPeiSuccessHandler(t)

    if t == TeamMatchDataManager.type_1 then
        self.pipeiIngTxt.gameObject:SetActive(false);
        self._btnpipeiLabel.text = LanguageMgr.Get("ZongMenLiLian/ZongMenLiLianPanel/label2");
    else
        self.pipeiIngTxt.gameObject:SetActive(false);
        self._btnpipeiLabel.text = LanguageMgr.Get("ZongMenLiLian/ZongMenLiLianPanel/label2");
    end


end


function ZongMenLiLianPanel:PartDataChangeHandler()

    local isld = PartData.MeIsTeamLeader();
    local tnum = PartData.GetMyTeamNunberNum();

    if isld and tnum == 4 then
        self:PiPeiSuccessHandler(TeamMatchDataManager.type_1)
    end

end





function ZongMenLiLianPanel:_OnClickBtn_nkonw()
    ModuleManager.SendNotification(ZongMenLiLianNotes.OPEN_ZONGMENLILIANDECPANEL);
end

--[[
 喊话
]]
function ZongMenLiLianPanel:_OnClickBtn_aoqing()

    local num = PartData.GetMyTeamNunberNum();

    if num == 4 then
        MsgUtils.ShowTips(nil, nil, nil, LanguageMgr.Get("ZongMenLiLian/ZongMenLiLianPanel/label5"));
    else
        local fbd = ZongMenLiLianItem.currSelected.data;

        ZongMenLiLianProxy.ZongMenLiLianYaoQing(TeamMatchDataManager.type_1, fbd.min_level, fbd.max_level)
    end

end

function ZongMenLiLianPanel:InitFbList()

    self._productPanels = { };


    --  local dataArr = InstanceDataManager.GetListByKeys(InstanceDataManager.InstanceType.type_ZongMenLiLian,nil);
    local dataArr = TeamMatchDataManager.GetList(TeamMatchDataManager.type_1);

    local t_num = table.getn(dataArr);


    local selectIndex = 1;

    self._phalanx = Phalanx:New();
    self._phalanx:Init(self._tablephalanx, ZongMenLiLianItem)
    self._phalanx:Build(1, t_num, dataArr);




    if TeamMatchDataManager.currPiPeiIng_data == nil then
        -- 设置默认 选中状态
        self._phalanx._items[selectIndex].itemLogic:_OnClickBtn();

    else
        -- 设置默认选中匹配对象

        local hasSelect = false;
        for i = 1, t_num do
            local obj = self._phalanx._items[i].itemLogic;
            local b = obj:CheckPiPeiSelect(TeamMatchDataManager.currPiPeiIng_data);
            if b then
                hasSelect = b;
                selectIndex = i;
            end
        end

        if not hasSelect then
            self._phalanx._items[selectIndex].itemLogic:_OnClickBtn();
        end

    end

    if selectIndex <= 6 then
        self.subPanelScrollView:SetDragAmount(0, 0, false);
    end


end

function ZongMenLiLianPanel:_Dispose()
    self:_DisposeListener();
    self:_DisposeReference();
end

function ZongMenLiLianPanel:_DisposeListener()
    UIUtil.GetComponent(self._btn_close, "LuaUIEventListener"):RemoveDelegate("OnClick");
    self._onClickBtn_close = nil;
    UIUtil.GetComponent(self._btnTiaozhan, "LuaUIEventListener"):RemoveDelegate("OnClick");
    self._onClickBtnTiaozhan = nil;
    UIUtil.GetComponent(self._btnpipei, "LuaUIEventListener"):RemoveDelegate("OnClick");
    self._onClickBtnpipei = nil;
    UIUtil.GetComponent(self._btn_nkonw, "LuaUIEventListener"):RemoveDelegate("OnClick");
    self._onClickBtn_nkonw = nil;


    UIUtil.GetComponent(self.btn_aoqing, "LuaUIEventListener"):RemoveDelegate("OnClick");
    self._onClickBtn_aoqing = nil;

end

function ZongMenLiLianPanel:_DisposeReference()

    MessageManager.RemoveListener(TeamMatchDataManager, TeamMatchDataManager.MESSAGE_TEAMMATCH_PIPEI_ING, ZongMenLiLianPanel.PiPeiIngHandler);
    MessageManager.RemoveListener(TeamMatchDataManager, TeamMatchDataManager.MESSAGE_TEAMMATCH_PIPEI_SUCCESS, ZongMenLiLianPanel.PiPeiSuccessHandler);

    MessageManager.RemoveListener(PartData, PartData.MESSAGE_PARTY_DATA_CHANGE, ZongMenLiLianPanel.PartDataChangeHandler);

    self._phalanx:Dispose();
    self.bottomPanelCtr:Dispose()

    self._btn_close = nil;
    self._btnTiaozhan = nil;
    self._btnpipei = nil;
    self._btn_nkonw = nil;

    ZongMenLiLianItem.currSelected = nil;

    self.btn_aoqing = nil;


    self.mainView = nil;
    self.listPanel = nil;
    self.subPanel = nil;
    self._table = nil;
    self._tablephalanx = nil;

    self.bottomPanel = nil;
    self.bottomPanelCtr = nil;

    self._btnpipeiLabel = nil;
    self.pipeiIngTxt = nil;


end
