require "Core.Module.InstancePanel.View.items.GiftItem"

LSBottomPanelCtr = class("LSBottomPanelCtr");

function LSBottomPanelCtr:New()
    self = { };
    setmetatable(self, { __index = LSBottomPanelCtr });
    return self
end


function LSBottomPanelCtr:Init(gameObject)
    self.gameObject = gameObject;

    self.hasSet = false;

    self.fbdecTxt = UIUtil.GetChildByName(self.gameObject, "UILabel", "fbdecTxt");
    self.minPlyerJoinTxt = UIUtil.GetChildByName(self.gameObject, "UILabel", "minPlyerJoinTxt");
    self.joinTimeTxt = UIUtil.GetChildByName(self.gameObject, "UILabel", "joinTimeTxt");

    self.btnTiaozhan = UIUtil.GetChildByName(self.gameObject, "UIButton", "btnTiaozhan");
    self.btnSangleTiaozhan = UIUtil.GetChildByName(self.gameObject, "UIButton", "btnSangleTiaozhan");
    self.btnpipei = UIUtil.GetChildByName(self.gameObject, "UIButton", "btnpipei");
    self.btnGuYong = UIUtil.GetChildByName(self.gameObject, "UIButton", "btnGuYong");

    self._btnpipeiLabel = UIUtil.GetChildByName(self.btnpipei, "UILabel", "Label");
    self.pipeiIngTxt = UIUtil.GetChildByName(self.gameObject, "UILabel", "pipeiIngTxt");

    self._onTiaozhanBt = function(go) self:_OnTiaozhanBt(self) end
    UIUtil.GetComponent(self.btnTiaozhan, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onTiaozhanBt);

    self._onSangleTiaozhanBt = function(go) self:_OnSangleTiaozhanBt(self) end
    UIUtil.GetComponent(self.btnSangleTiaozhan, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onSangleTiaozhanBt);

    self._onpipeiBt = function(go) self:_OnpipeiBt(self) end
    UIUtil.GetComponent(self.btnpipei, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onpipeiBt);

    self._guYongBt = function(go) self:_GuYongBt(self) end
    UIUtil.GetComponent(self.btnGuYong, "LuaUIEventListener"):RegisterDelegate("OnClick", self._guYongBt);

    for i = 1, 4 do
        self["product" .. i] = UIUtil.GetChildByName(self.gameObject, "Transform", "product" .. i);
        self["productCtr" .. i] = ProductCtrl:New();
        self["productCtr" .. i]:Init(self["product" .. i], { hasLocke = true, use_sprite = true, iconType = ProductCtrl.IconType_rectangle });
        self["productCtr" .. i]:SetOnClickBtnHandler(ProductCtrl.TYPE_FROM_OTHER);
    end

    self.pipeiIngTxt.gameObject:SetActive(false);
    self.btnSangleTiaozhan.gameObject:SetActive(false);

    self:CheckPartData()

    InstanceDataManager.UpData();





    -- 队伍发生改变需要重新 获取
    MessageManager.AddListener(PartData, PartData.MESSAGE_PARTY_DATA_CHANGE, LSBottomPanelCtr.PartDataChangeHandler, self);
    MessageManager.AddListener(TeamMatchDataManager, TeamMatchDataManager.MESSAGE_TEAMMATCH_PIPEI_ING, LSBottomPanelCtr.PiPeiIngHandler, self);
    MessageManager.AddListener(TeamMatchDataManager, TeamMatchDataManager.MESSAGE_TEAMMATCH_PIPEI_SUCCESS, LSBottomPanelCtr.PiPeiSuccessHandler, self);

    MessageManager.AddListener(InstanceDataManager, InstanceDataManager.MESSAGE_0X0F01_CHANGE, LSBottomPanelCtr.UpInfos, self);


    self:PartDataChangeHandler();


end

function LSBottomPanelCtr:PartDataChangeHandler()
    self:CheckPartData()

    local isld = PartData.MeIsTeamLeader();
    local tnum = PartData.GetMyTeamNunberNum();

    if isld and tnum == 4 then
        self:PiPeiSuccessHandler()
    end

end

function LSBottomPanelCtr:PiPeiIngHandler(t)

    if self.pipeiIngTxt ~= nil then

        if t == self.data.type then
            self.pipeiIngTxt.gameObject:SetActive(true);

            self._btnpipeiLabel.text = LanguageMgr.Get("ZongMenLiLian/ZongMenLiLianPanel/label1");
        else
            self.pipeiIngTxt.gameObject:SetActive(false);
            self._btnpipeiLabel.text = LanguageMgr.Get("ZongMenLiLian/ZongMenLiLianPanel/label2");
        end

    end


end


function LSBottomPanelCtr:PiPeiSuccessHandler(t)

    if self.pipeiIngTxt ~= nil then

        if self.data ~= nil and t == self.data.type then
            self.pipeiIngTxt.gameObject:SetActive(false);
            self._btnpipeiLabel.text = LanguageMgr.Get("ZongMenLiLian/ZongMenLiLianPanel/label2");
        else
            self.pipeiIngTxt.gameObject:SetActive(false);
            self._btnpipeiLabel.text = LanguageMgr.Get("ZongMenLiLian/ZongMenLiLianPanel/label2");
        end


    end



end



function LSBottomPanelCtr:CheckPartData()
    local arr = InstanceDataManager.GetListByKeys(InstanceDataManager.InstanceType.SpiritStonesInstance, InstanceDataManager.kind_0);
    local info = arr[1];
    local min_num = info.min_num;
    local team_nb_num = PartData.GetMyTeamNunberNum();
    self.fb_max_t = info.number;

    if team_nb_num >= min_num then
        self.minPlyerJoinTxt.text = "[9CFF94]" .. min_num .. LanguageMgr.Get("LSInstance/LSBottomPanelCtr/label1") .. "[-]";
        self.playerNumCanPlay = true;
    else
        self.minPlyerJoinTxt.text = "[FF4B4B]" .. min_num .. LanguageMgr.Get("LSInstance/LSBottomPanelCtr/label1") .. "[-]";
        self.playerNumCanPlay = false;
    end
end

function LSBottomPanelCtr:SetBtsActive(v)
    self.btnTiaozhan.gameObject:SetActive(v);
    self.btnpipei.gameObject:SetActive(v);
end

function LSBottomPanelCtr:UpInfos()

    if self.data ~= nil then
        local t_num = InstanceDataManager.GetTotalTNumByKey(self.data.fbData.type, InstanceDataManager.kind_0);


        local buy_num = InstanceDataManager.GetTotalTAndDtNumBuy(self.data.fbData.type);

        -- log(" self.data.fbData.type "..self.data.fbData.type.." buy_num "..buy_num.." self.fb_max_t "..self.fb_max_t);

        local max_t = self.fb_max_t + buy_num;
        local vipMaxBuyNum = VIPManager.GetSelfTeam_instance_Max_buy_num(self.data.fbData.type);

        if max_t > t_num then


            self.joinTimeTxt.text = "[9CFF94]" .. LanguageMgr.Get("LSInstance/LSBottomPanelCtr/label2") .. t_num .. "/" .. max_t .. "[-]";

            self.playTimeCanPlay = true;
        else

            self.joinTimeTxt.text = "[FF4B4B]" .. LanguageMgr.Get("LSInstance/LSBottomPanelCtr/label2") .. t_num .. "/" .. max_t .. "[-]";

            self.playTimeCanPlay = false;
        end

        self.canBuyNum = true;
        if buy_num >= vipMaxBuyNum then
            -- 已经不能购买次数
            self.canBuyNum = false;
        end

    end

end


--[[
order= [6]
--instance_id= [752001]
--id= [6]
fbData--monster_display= []
|      --icon_id= [fb_xyj]
|      drop--1= [4_1]
|      |    --2= [101_1]
|      --number= [2]
|      --enter_type= [2]
|      --position_x= [8702_8731]
|      --time= [30]
|      first_pass_reward
|      reward
|      --position_z= [-2188_-2128]
|      --open_map_condition= []
|      --is_hire= [true]
|      --desc= [狂暴的火系能量正在爆发，带来了巨大的危险，也带来了巨大的机遇，各位道友迅速出发，去寻找自己的机缘吧！]
|      --sweep_num= [0]
|      --exp= [75000]
|      --other_condition= [0]
|      chapter_reward
|      pass_conditions--1= [5_0_0]
|      --toward= [0]
|      npc--1= [0]
|      --inst_name= [小炎界]
|      --level= [15]
|      --failed_conditions= []
|      --money= [10000]
|      --id= [752001]
|      --min_num= [2]
|      --type= [3]
|      --sweep_star= [0]
|      --kind= [0]
|      --map_id= [704020]
|      sweep_drop
|      --need_power= [100000]
|      --name= [小炎界]
|      --instance_end_condition= [7_124007_1]
--type_name= [小炎界-装备]
--min_level= [15]
drop--1= [4_1]
|    --2= [101_1]
--desc= [小炎界中空间元力催生了大量的紫阳石，修仙人士纷纷前往寻宝]
--down_float= [15]
--icon_id= [fb_xyj]
--max_level= [100]
--type= [2]
--up_float= [20]
--name= [小炎界-15级]
--activity_id= [27]
]]
function LSBottomPanelCtr:SetData(data)

    self.data = data;

    local type = self.data.type;

    if type == InstanceDataManager.InstanceType.ExperienceInstance or
        type == InstanceDataManager.InstanceType.type_jiuyouwangzuo or
        type == InstanceDataManager.InstanceType.type_MingZhuRuQing then
        self.btnpipei.gameObject:SetActive(false);
    end

    if type == InstanceDataManager.InstanceType.type_endlessTry then
        self.btnSangleTiaozhan.gameObject:SetActive(true);
    end


    self.fbdecTxt.text = data.desc;


    local drop = self.data.drop;
    local t_num = table.getn(drop);

    if t_num == 1 and drop[1] == "" then
        -- 没有 掉了奖励
    else
        for i = 1, t_num do
            local reward = drop[i];
            local info = string.split(reward, "_");

            local spid = info[1] + 0;
            local _num = info[2] + 0;

            local pinfo = ProductManager.GetProductInfoById(spid, _num);
            self["productCtr" .. i]:SetData(pinfo);
        end
    end


    if not self.hasSet then

        if TeamMatchDataManager.currPiPeiIng_data ~= nil and self.data ~= nil and TeamMatchDataManager.currPiPeiIng_data.type == self.data.type then

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

        self.hasSet = true;
    end



    --[[
    local me = HeroController:GetInstance();
    local heroInfo = me.info;
    local my_lv = heroInfo.level;

    if my_lv >= self.data.min_level then
        self.btnTiaozhan.gameObject:SetActive(true);
        self.btnpipei.gameObject:SetActive(true);
    else
        self.btnTiaozhan.gameObject:SetActive(false);
        self.btnpipei.gameObject:SetActive(false);
    end
    ]]
end

--  http://192.168.0.8:3000/issues/3922
function LSBottomPanelCtr:GotoTeamUIAndClose(setPipeiData)

    ModuleManager.SendNotification(ActivityNotes.CLOSE_ACTIVITY);

    -- 需要设置 现在匹配目标

    ModuleManager.SendNotification(FriendNotes.OPEN_FRIENDPANEL, FriendNotes.PANEL_PARTY);

    if setPipeiData then
        YaoQingPiPeiRightControll.SetPiPeiInfos(self.data, self.data.min_level, self.data.max_level, false)
    end

    ModuleManager.SendNotification(LSInstanceNotes.CLOSE_LSINSTANCEPANEL);

end


function LSBottomPanelCtr:_OnSangleTiaozhanBt()



    ModuleManager.SendNotification(ConfirmNotes.OPEN_CONFIRM1PANEL, {
        title = LanguageMgr.Get("common/notice"),
        msg = LanguageMgr.Get("LSInstance/LSBottomPanelCtr/label7"),
        ok_Label = LanguageMgr.Get("common/ok"),
        cance_lLabel = LanguageMgr.Get("common/cancle"),
        hander = function()

            SequenceManager.TriggerEvent(SequenceEventType.Guide.ENDLESS_SINGLE_MATCH);

            ModuleManager.SendNotification(LSInstanceNotes.CLOSE_LSINSTANCEPANEL);
            -- 关闭活动界面
            ModuleManager.SendNotification(ActivityNotes.CLOSE_ACTIVITY);

            local id = self.data.fbData.id;
            if id == 761003 then
                id = 761004;
            end
            GameSceneManager.GoToFB(id, nil, 1)
        end,
        target = nil,
        data = nil
    } );


end

function LSBottomPanelCtr:_OnTiaozhanBt()


    if (self.data.fbData.enter_type == 2) then
        local tm = PartData.GetMyTeam();
        if tm == nil then

            MsgUtils.ShowTips("LSInstance/LSBottomPanelCtr/label6");

            self:GotoTeamUIAndClose(true)
            return;
        end

        --[[
        if not self.playTimeCanPlay then

            MsgUtils.ShowTips("LSInstance/LSBottomPanelCtr/label3");
            log("---------self.playTimeCanPlay-----000-----------");
            return;
        else
        ]]
        if not self.playerNumCanPlay then

            MsgUtils.ShowTips("LSInstance/LSBottomPanelCtr/label4");
            self:GotoTeamUIAndClose(true)
            return;
        else

            -- 检测 自己是否 是队长
            local isMb = PartData.MeIsTeamLeader();
            if isMb then
                -- 发送进入副本邀请
                GameSceneManager.GoToFB(self.data.fbData.id)
            else
                MsgUtils.ShowTips("LSInstance/LSBottomPanelCtr/label5");
            end
        end

    else


        --[[
        if not self.playTimeCanPlay then
            MsgUtils.ShowTips("LSInstance/LSBottomPanelCtr/label3");
            return;
        end
        --]]
        ModuleManager.SendNotification(LSInstanceNotes.CLOSE_LSINSTANCEPANEL);
        -- 关闭活动界面
        ModuleManager.SendNotification(ActivityNotes.CLOSE_ACTIVITY);

        GameSceneManager.GoToFB(self.data.fbData.id)

    end





end

function LSBottomPanelCtr:_OnpipeiBt()


    if self.data ~= nil then

        SequenceManager.TriggerEvent(SequenceEventType.Guide.INSTANCE_MATCH, self.data);

        if TeamMatchDataManager.currPiPeiIng_data ~= nil and TeamMatchDataManager.currPiPeiIng_data.type == self.data.type then
            TeamMatchDataManager.QuXianPiPei(self.data.type);
            return;
        end


        -- 如果队伍人数 是 4 人， 那么就队伍满， 不需要匹配
        local pnum = PartData.GetMyTeamNunberNum();
        if pnum == 4 then
            MsgUtils.ShowTips("ZongMenLiLian/ZongMenLiLianPanel/label3");
            return;
        end

        ------------------------------------

        -- 如果自己没有队伍， 那么可以 操作， 如果自己有队伍，只能队长才能操作
        local mt = PartData.GetMyTeam();
        if mt == nil then
            TeamMatchDataManager.TeamMatchPiPei(self.data);

            --[[
                点击匹配后创建队伍开启副本匹配功能并前往组队界面选定相应的副本匹配，如果玩家当前选择的多人副本为小炎界副本，则跳转后的界面如下图；（在现有基础上， 点击匹配（取消匹配不处理）， 关闭活动界面， 副本界面， 打开队伍界面）
              http://192.168.0.8:3000/issues/3922

                ]]
            self:GotoTeamUIAndClose(false)

        else
            local misl = PartData.MeIsTeamLeader();
            if misl then
                TeamMatchDataManager.TeamMatchPiPei(self.data);

                --[[
                点击匹配后创建队伍开启副本匹配功能并前往组队界面选定相应的副本匹配，如果玩家当前选择的多人副本为小炎界副本，则跳转后的界面如下图；（在现有基础上， 点击匹配（取消匹配不处理）， 关闭活动界面， 副本界面， 打开队伍界面）
              http://192.168.0.8:3000/issues/3922

                ]]
                self:GotoTeamUIAndClose(false)
            else
                MsgUtils.ShowTips("ZongMenLiLian/ZongMenLiLianPanel/label4");

            end
        end




    end




end

function LSBottomPanelCtr:_GuYongBt()
    if self.data ~= nil then
        local mt = PartData.GetMyTeam();
        local canGuYong = false;
        if mt == nil then
            FriendProxy.TryCreateArmy();
            canGuYong = true
        else
            canGuYong = PartData.MeIsTeamLeader();
        end
        if (canGuYong) then
            --            ModuleManager.SendNotification(LSInstanceNotes.CLOSE_LSINSTANCEPANEL);
            --            ModuleManager.SendNotification(ActivityNotes.CLOSE_ACTIVITY);
            HirePlayerProxy.LoadDataByInstanceId(self.data.fbData.id)
            -- ModuleManager.SendNotification(FriendNotes.OPEN_TEAMPANEL, self.data.fbData.id);
        else
            MsgUtils.ShowTips(nil, nil, nil, LanguageMgr.Get("ZongMenLiLian/ZongMenLiLianPanel/label6"));
        end
    end
end


function LSBottomPanelCtr:Show()

    self.gameObject.gameObject:SetActive(true);
end

function LSBottomPanelCtr:Hide()


    self.gameObject.gameObject:SetActive(false);
end

function LSBottomPanelCtr:Dispose()

    UIUtil.GetComponent(self.btnTiaozhan, "LuaUIEventListener"):RemoveDelegate("OnClick");
    UIUtil.GetComponent(self.btnSangleTiaozhan, "LuaUIEventListener"):RemoveDelegate("OnClick");
    UIUtil.GetComponent(self.btnpipei, "LuaUIEventListener"):RemoveDelegate("OnClick");
    UIUtil.GetComponent(self.btnGuYong, "LuaUIEventListener"):RemoveDelegate("OnClick");

    self._onSangleTiaozhanBt = nil;


    MessageManager.RemoveListener(PartData, PartData.MESSAGE_PARTY_DATA_CHANGE, LSBottomPanelCtr.PartDataChangeHandler);

    MessageManager.RemoveListener(TeamMatchDataManager, TeamMatchDataManager.MESSAGE_TEAMMATCH_PIPEI_ING, LSBottomPanelCtr.PiPeiIngHandler);
    MessageManager.RemoveListener(TeamMatchDataManager, TeamMatchDataManager.MESSAGE_TEAMMATCH_PIPEI_SUCCESS, LSBottomPanelCtr.PiPeiSuccessHandler);
    MessageManager.RemoveListener(InstanceDataManager, InstanceDataManager.MESSAGE_0X0F01_CHANGE, LSBottomPanelCtr.UpInfos);


    for i = 1, 4 do
        self["productCtr" .. i]:Dispose();
        self["productCtr" .. i] = nil;
        self["product" .. i] = nil;
    end




    self.gameObject = nil;


    self.fbdecTxt = nil;
    self.minPlyerJoinTxt = nil;
    self.joinTimeTxt = nil;

    self.btnTiaozhan = nil;
    self.btnpipei = nil;

    self._onTiaozhanBt = nil;
    self._onpipeiBt = nil;
    self._guYongBt = nil;

    self._btnpipeiLabel = nil;
    self.pipeiIngTxt = nil;

    self.btnGuYong = nil;

end