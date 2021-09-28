require "Core.Module.Friend.controlls.items.PartyFloatHeroInfoItem";
require "Core.Module.Friend.controlls.PartData"




PartyFloatPanelControll = class("PartyFloatPanelControll");

-- 是否屏蔽跟随
PartyFloatPanelControll.fb_genshui = true;

function PartyFloatPanelControll:New()
    self = { };
    setmetatable(self, { __index = PartyFloatPanelControll });
    return self
end


function PartyFloatPanelControll:Init(gameObject)
    self.gameObject = gameObject;


    self.hero1 = UIUtil.GetChildByName(self.gameObject, "Transform", "hero1");
    self.hero2 = UIUtil.GetChildByName(self.gameObject, "Transform", "hero2");
    self.hero3 = UIUtil.GetChildByName(self.gameObject, "Transform", "hero3");
    self.bg = UIUtil.GetChildByName(self.gameObject, "UISprite", "bg");
    self.treamtipTxt = UIUtil.GetChildByName(self.gameObject, "UILabel", "treamtipTxt");

    self.btnGenSui1 = UIUtil.GetChildByName(self.gameObject, "UIButton", "btnGenSui1");
    self.btnGenSui2 = UIUtil.GetChildByName(self.gameObject, "UIButton", "btnGenSui2");

    self.btnGenSuiLabel1 = UIUtil.GetChildByName(self.btnGenSui1, "UILabel", "Label");
    self.btnGenSuiLabel2 = UIUtil.GetChildByName(self.btnGenSui2, "UILabel", "Label");

    self.heroCtrl1 = PartyFloatHeroInfoItem:New();
    self.heroCtrl1:Init(self.hero1);

    self.heroCtrl2 = PartyFloatHeroInfoItem:New();
    self.heroCtrl2:Init(self.hero2);

    self.heroCtrl3 = PartyFloatHeroInfoItem:New();
    self.heroCtrl3:Init(self.hero3);


    self.todoManagerInfo = nil;


    --  需要监听  组队请求
    self._onClickBtn = function(go) self:_OnClickBtn(self) end
    UIUtil.GetComponent(self.bg, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtn);

    self._onClickBtnGenSui1 = function(go) self:_OnClickBtnGenSui1(self) end
    UIUtil.GetComponent(self.btnGenSui1, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtnGenSui1);

    self._onClickBtnGenSui2 = function(go) self:_OnClickBtnGenSui2(self) end
    UIUtil.GetComponent(self.btnGenSui2, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtnGenSui2);

    MessageManager.AddListener(FriendNotes, FriendNotes.MESSAGE_INVTOGROUDSRESULT, PartyFloatPanelControll.InvToGroudSResult, self);
    MessageManager.AddListener(FriendNotes, FriendNotes.MESSAGE_ASKFORJOINTPARTYRESULT, PartyFloatPanelControll.AskForJointPartyResult, self);
    MessageManager.AddListener(PartData, PartData.MESSAGE_PARTY_MENBER_DATA_CHANGE, PartyFloatPanelControll.MenberDataChange, self);

    MessageManager.AddListener(RoleFollowAiController, RoleFollowAiController.MESSAGE_FOLLOWTARGET_CHANGE, PartyFloatPanelControll.FollowTargetChange, self);
    MessageManager.AddListener(HeroController, HeroController.MESSAGE_FOLLOWTYPE_CHANGE, PartyFloatPanelControll.FollowTargetChange, self);

    MessageManager.AddListener(PartData, PartData.MESSAGE_PARTY_DATA_CHANGE, PartyFloatPanelControll.PartDataChangeHandlerForFollow, self);
    MessageManager.AddListener(PartData, PartData.MESSAGE_PARTY_DATA_CHANGE, PartyFloatPanelControll.PartDataChangeHandler, self);
    MessageManager.AddListener(ZongMenLiLianDataManager, ZongMenLiLianDataManager.MESSAGE_ZMLL_PREINFO_CHANGE, PartyFloatPanelControll.InitZongMenLiLian, self);

    MessageManager.AddListener(GameSceneManager, GameSceneManager.MESSAGE_SCENE_AFTER_INIT, PartyFloatPanelControll.SceneAfterInit, self);

    MessageManager.AddListener(ZongMenLiLianPanel, ZongMenLiLianPanel.MESSAGE_ZONGMENLILIAN_TRY_ACTIVE, PartyFloatPanelControll.TryDisTodoManager, self);

    MessageManager.AddListener(TodoManager, TodoManager.TODO_START_DO, PartyFloatPanelControll.TodoMamagerClickHander, self);

    self:InitZongMenLiLian();

    self._timer = Timer.New( function(val) self:_OnTickHandler(val) end, 2, -1, false);
    self._timer:Start();


    self._InvToGroudSData_invIds = { };
    self._InvToGroudSData_Ids = { };
    self._AskForJointParty_Ids = { };

end

function PartyFloatPanelControll:Dispose()

    MessageManager.RemoveListener(FriendNotes, FriendNotes.MESSAGE_INVTOGROUDSRESULT, PartyFloatPanelControll.InvToGroudSResult);

    MessageManager.RemoveListener(FriendNotes, FriendNotes.MESSAGE_ASKFORJOINTPARTYRESULT, PartyFloatPanelControll.AskForJointPartyResult);
    MessageManager.RemoveListener(PartData, PartData.MESSAGE_PARTY_MENBER_DATA_CHANGE, PartyFloatPanelControll.MenberDataChange);

    MessageManager.RemoveListener(RoleFollowAiController, RoleFollowAiController.MESSAGE_FOLLOWTARGET_CHANGE, PartyFloatPanelControll.FollowTargetChange);
    MessageManager.RemoveListener(HeroController, HeroController.MESSAGE_FOLLOWTYPE_CHANGE, PartyFloatPanelControll.FollowTargetChange);

    MessageManager.RemoveListener(PartData, PartData.MESSAGE_PARTY_DATA_CHANGE, PartyFloatPanelControll.PartDataChangeHandlerForFollow);
    MessageManager.RemoveListener(PartData, PartData.MESSAGE_PARTY_DATA_CHANGE, PartyFloatPanelControll.PartDataChangeHandler);
    MessageManager.RemoveListener(ZongMenLiLianDataManager, ZongMenLiLianDataManager.MESSAGE_ZMLL_PREINFO_CHANGE, PartyFloatPanelControll.InitZongMenLiLian);

    MessageManager.RemoveListener(GameSceneManager, GameSceneManager.MESSAGE_SCENE_AFTER_INIT, PartyFloatPanelControll.SceneAfterInit);

    MessageManager.RemoveListener(ZongMenLiLianPanel, ZongMenLiLianPanel.MESSAGE_ZONGMENLILIAN_TRY_ACTIVE, PartyFloatPanelControll.TryDisTodoManager);

    MessageManager.RemoveListener(TodoManager, TodoManager.TODO_START_DO, PartyFloatPanelControll.TodoMamagerClickHander);



    if (self._timer) then
        self._timer:Stop();
        self._timer = nil;
    end

    self.heroCtrl1:Dispose()
    self.heroCtrl1 = nil
    self.heroCtrl2:Dispose()
    self.heroCtrl2 = nil
    self.heroCtrl3:Dispose()
    self.heroCtrl3 = nil


    UIUtil.GetComponent(self.bg, "LuaUIEventListener"):RemoveDelegate("OnClick");
    self._onClickBtn = nil;


    self.hero1 = nil;
    self.hero2 = nil;
    self.hero3 = nil;
    self.bg = nil;
    self.treamtipTxt = nil;

    self.btnGenSui1 = nil;
    self.btnGenSui2 = nil;

    self.btnGenSuiLabel1 = nil;
    self.btnGenSuiLabel2 = nil;


end

function PartyFloatPanelControll:SceneAfterInit()


    local info = ZongMenLiLianDataManager.GetZongMenLiLianPreInfo();

    if info ~= nil then
        ZongMenLiLianProxy.GetZongMenLiLianPreInfo()
    end

end

function PartyFloatPanelControll:GensuiMenberChange(list)


    self.heroCtrl1:GensuiMenberChange(list);
    self.heroCtrl2:GensuiMenberChange(list);
    self.heroCtrl3:GensuiMenberChange(list);

end


function PartyFloatPanelControll:_OnClickBtn()
    ModuleManager.SendNotification(FriendNotes.OPEN_FRIENDPANEL, FriendNotes.PANEL_PARTY);

end

--[[

18 队员升级，战斗力改变通知（服务端发出）
输出：
[id:玩家id，l:等级,hp:血量,max_hp:最大血量,f:战斗力]
0x0B18

]]
function PartyFloatPanelControll:MenberDataChange(data)

    local myTeamData = PartData.GetMyTeam();

    if myTeamData ~= nil then

        local m = myTeamData.m;

        for i = 1, 3 do

            local ctr = self["heroCtrl" .. i];
            -- p_id
            local did = data.id .. "";
            --  log("i"..i.. " ctr.p_id ".. ctr.p_id.."  did "..did);
            if ctr.p_id == did then
                ctr:SetPhData(data);
                return;
            end
        end
    end

end

--[[
03 请求加入队伍消息（队长收到申请消息）
输出：
id：玩家名字
name：队员昵称
0x0B03

]]
function PartyFloatPanelControll:AskForJointPartyResult(data)

    self.AskForJointPartyData = data;
    if (data.errCode == nil) then

        --[[
        ModuleManager.SendNotification(ConfirmNotes.OPEN_CONFIRM1PANEL, {
            title = LanguageMgr.Get("common/notice"),
            msg = data.name .. LanguageMgr.Get("Friend/PartyFloatPanelControll/tip2"),
            ok_Label = LanguageMgr.Get("common/agree"),
            cance_lLabel = LanguageMgr.Get("common/cancle"),
            hander = PartyFloatPanelControll.AccAskFroAessJointParty,
            cancelHandler = PartyFloatPanelControll.NotAccAskFroAessJointParty,
            target = self;
            close_time = 60;
            data = nil
        } );
        ]]

        local confirmData = {
            title = LanguageMgr.Get("common/notice"),
            msg = data.name .. LanguageMgr.Get("Friend/PartyFloatPanelControll/tip2"),
            ok_Label = LanguageMgr.Get("common/agree"),
            cance_lLabel = LanguageMgr.Get("common/cancle"),
            hander = PartyFloatPanelControll.AccAskFroAessJointParty,
            cancelHandler = PartyFloatPanelControll.NotAccAskFroAessJointParty,

            closeHandler = PartyFloatPanelControll.Confirm1PanelAskForJointPartyCloseHandler,
            returnSelfHandler = PartyFloatPanelControll.AddConfirm1PanelAskForJointPartyReturnHandler,
            target = self;
            cancel_time = 60;
            data = data
        }

        --  self._AskForJointParty_Ids ={};
        local cpanel = self:TryGetAskForJointPartyConfirm(data);
        if cpanel ~= nil then

            cpanel:SetData(confirmData);
        else
            ModuleManager.SendNotification(ConfirmNotes.OPEN_CONFIRM1PANEL, confirmData);
        end

    end


end

function PartyFloatPanelControll:Confirm1PanelAskForJointPartyCloseHandler(data)

    self:RemoveConfirm1PanelAskForJointPartyInfos(data.ConfirmTg);
end

function PartyFloatPanelControll:RemoveConfirm1PanelAskForJointPartyInfos(tg)

    for k, v in pairs(self._AskForJointParty_Ids) do
        if v == tg then
            self._AskForJointParty_Ids[k] = nil;
        end
    end

end

function PartyFloatPanelControll:TryGetAskForJointPartyConfirm(data)

    local id = data.id;
    return self._AskForJointParty_Ids[id];

end

function PartyFloatPanelControll:AddConfirm1PanelAskForJointPartyReturnHandler(tg)

    local data = tg.data;
    local id = data.id;
    self._AskForJointParty_Ids[id] = tg;
    tg.data.ConfirmTg = tg;

end


-- 拒接  请求加入队伍
function PartyFloatPanelControll:NotAccAskFroAessJointParty(data)

    --  self:AskFroAessJointPartyDeal(0);
     self:RemoveConfirm1PanelAskForJointPartyInfos(data.ConfirmTg);
end

-- 接受 请求加入队伍
function PartyFloatPanelControll:AccAskFroAessJointParty(data)

    self:AskFroAessJointPartyDeal(1);
    self:RemoveConfirm1PanelAskForJointPartyInfos(data.ConfirmTg);
end

--[[
04 队长审批申请
输入：
pid：申请加队的玩家ID
s:是否同意加入（0:不同意，1同意）
输出：
s:是否通过（0:不通过,1:通过）
0x0B04

]]
function PartyFloatPanelControll:AskFroAessJointPartyDeal(s)

    local p_id = self.AskForJointPartyData.id .. "";

    FriendProxy.AskFroAessJointPartyDeal(s, p_id);

end



--[[
0B 玩家收到邀请加入队伍消息(服务端发出)
输出：
id：队伍ID
name:邀请人昵称
0x0B0B


]]

function PartyFloatPanelControll:InvToGroudSResult(data)

    self.InvToGroudSData = data;

    if (data.errCode == nil) then

        local confirmData = {
            title = LanguageMgr.Get("common/notice"),
            msg = data.name .. LanguageMgr.Get("Friend/PartyFloatPanelControll/tip4"),

            ok_Label = LanguageMgr.Get("common/agree"),
            cance_lLabel = LanguageMgr.Get("common/refuse"),
            hander = PartyFloatPanelControll.AessJointParty,
            cancelHandler = PartyFloatPanelControll.NotAessJointParty,
            closeHandler = PartyFloatPanelControll.Confirm1PanelCloseHandler,
            returnSelfHandler = PartyFloatPanelControll.AddConfirm1PanelReturnHandler,
            target = self;
            cancel_time = 60;
            data = data
        }

        local cpanel = self:TryGetInvToGroudSConfirm(data);
        if cpanel ~= nil then

            cpanel:SetData(confirmData);
        else
            ModuleManager.SendNotification(ConfirmNotes.OPEN_CONFIRM1PANEL, confirmData);
        end


    end

end

--[[
id：队伍ID （没有用-1）
name:邀请人昵称
invId：邀请者ID（没有用-1）
]]
function PartyFloatPanelControll:TryGetInvToGroudSConfirm(data)

    local id = data.id;
    local invId = data.invId;

    if id ~= -1 then
        if self._InvToGroudSData_Ids[id] ~= nil then
            return self._InvToGroudSData_Ids[id];
        end

    else
        return self._InvToGroudSData_invIds[invId];
    end

    return nil;
end

function PartyFloatPanelControll:AddConfirm1PanelReturnHandler(tg)

    local data = tg.data;

    local id = data.id;
    local invId = data.invId;

    if id ~= -1 then
        self._InvToGroudSData_Ids[id] = tg;
    else
        self._InvToGroudSData_invIds[invId] = tg;
    end

    tg.data.ConfirmTg = tg;

end

function PartyFloatPanelControll:RemoveConfirm1PanelInfos(tg)

    for k, v in pairs(self._InvToGroudSData_Ids) do
        if v == tg then
            self._InvToGroudSData_Ids[k] = nil;
        end
    end

    for k, v in pairs(self._InvToGroudSData_invIds) do
        if v == tg then
            self._InvToGroudSData_invIds[k] = nil;
        end
    end

end

function PartyFloatPanelControll:Confirm1PanelCloseHandler(data)

    self:RemoveConfirm1PanelInfos(data.ConfirmTg);
end

-- 拒接
function PartyFloatPanelControll:NotAessJointParty(data)

    self:RemoveConfirm1PanelInfos(data.ConfirmTg);
    self:IAessJointParty(0);

end

-- 接受 邀请加入 队伍
function PartyFloatPanelControll:AessJointParty(data)

    self:RemoveConfirm1PanelInfos(data.ConfirmTg);
    self:IAessJointParty(1);
end

function PartyFloatPanelControll:IAessJointParty(s)

    local g_id = self.InvToGroudSData.id;
    local invId = self.InvToGroudSData.invId;

    FriendProxy.TryAccJoinTeam(s, g_id, invId);


end



function PartyFloatPanelControll:Show()
    self.gameObject.gameObject:SetActive(true);



    self:PartDataChangeHandler(0);

    local tm = PartData.GetMyTeam();
    if tm ~= nil then
        FriendProxy.GenShuiMbChange()
    end

end

function PartyFloatPanelControll:Close()
    self.gameObject.gameObject:SetActive(false);

end

function PartyFloatPanelControll:_OnTickHandler()


    -- log("----------------PartyFloatPanelControll:_OnTickHandler-------------------");
    self.heroCtrl1:SetOnlineState();
    self.heroCtrl2:SetOnlineState();
    self.heroCtrl3:SetOnlineState();


end

function PartyFloatPanelControll:PartDataChangeHandler(dc_type)

    self.heroCtrl1:SetActive(false);
    self.heroCtrl2:SetActive(false);
    self.heroCtrl3:SetActive(false);

    self.treamtipTxt.text = LanguageMgr.Get("Friend/PartyFloatPanelControll/tip5");
    self.treamtipTxt.gameObject:SetActive(true);

    self.btnGenSui1.gameObject:SetActive(false);
    self.btnGenSui2.gameObject:SetActive(false);


    local myTeamData = PartData.GetMyTeam();
    self.bg.height = 70;

    if myTeamData ~= nil then
        local myHero = HeroController.GetInstance();
        local mydata = myHero.info;

        local m = myTeamData.m;
        local index = 1;

        for key, value in pairs(m) do

            if value.pid ~= mydata.id then
                if index < PartData.TEAM_MAX_NUM then
                    self["heroCtrl" .. index]:SetData(value);
                    index = index + 1;
                end


                self.treamtipTxt.gameObject:SetActive(false);
            end
        end

        if index == 1 then
            self.treamtipTxt.text = LanguageMgr.Get("Friend/PartyFloatPanelControll/tip6");
        end

        if index == 2 then
            self.bg.height = 70;
            Util.SetLocalPos(self.btnGenSui1, -618, -50, 0)
            Util.SetLocalPos(self.btnGenSui2, -479, -50, 0)

            --            self.btnGenSui1.transform.localPosition = Vector3.New(-618, -50, 0);
            --            self.btnGenSui2.transform.localPosition = Vector3.New(-479, -50, 0);

        elseif index == 3 then
            self.bg.height = 135;
            Util.SetLocalPos(self.btnGenSui1, -618, -120, 0)
            Util.SetLocalPos(self.btnGenSui2, -479, -120, 0)
            --            self.btnGenSui1.transform.localPosition = Vector3.New(-618, -120, 0);
            --            self.btnGenSui2.transform.localPosition = Vector3.New(-479, -120, 0);

        elseif index == 4 then
            self.bg.height = 200;
            Util.SetLocalPos(self.btnGenSui1, -618, -200, 0)
            Util.SetLocalPos(self.btnGenSui2, -479, -200, 0)
            --            self.btnGenSui1.transform.localPosition = Vector3.New(-618, -200, 0);
            --            self.btnGenSui2.transform.localPosition = Vector3.New(-479, -200, 0);
        end

        self:UpFollowInfos();


    end



end


function PartyFloatPanelControll:FollowTargetChange()
    self:UpFollowInfos();
end

-- 宗门理论数据 发生 改变
function PartyFloatPanelControll:InitZongMenLiLian()

    if self.todoManagerInfo ~= nil then
        TodoManager.Remove(self.todoManagerInfo);
        -- 这里有可能 移除了 自动战斗 AI
        self.todoManagerInfo = nil;
    end

    local pinfo = ZongMenLiLianDataManager.GetZongMenLiLianPreInfo();

    -- 策划 定 的数据
    -- 2017 04-07 修改为 http://192.168.0.8:3000/issues/3722
    local p_num = ZongMenLiLianDataManager.p_max_num;


    if pinfo ~= nil then
        local mt = pinfo.t % p_num;
        mt = math.floor(mt);

        if pinfo.f == 1 then
            -- 在副本中

            -- 在宗门历练副本中还有其他人的时候，
            -- f==1 , 那么需要判断 宗门历练对应的副本
            local selectCfData = InstanceDataManager.GetMapCfById(ZongMenLiLianDataManager.npc_fb_id);
            local mid = selectCfData.map_id;
            local mapCf = ConfigManager.GetMapById(mid);

            local tmpData = { ico = 20, label = "todo/act/1", x = mt, y = p_num, desc = LanguageMgr.Get("Friend/PartyFloatPanelControll/tip7", { n = mapCf.name } ) };
            self.todoManagerInfo = TodoManager.Add(TodoConst.Type.NORMAL, tmpData);


            -- 这里需要判断 进场景后 是否需要 自动战斗， 如果事的话，那么就继续战斗
            GameSceneManager.Check_autoFight()

        else
            -- 不在副本中

            -- "宗门历练{x}/{y}";
            local pos = Convert.PointFromServer(pinfo.x, 0, pinfo.z);
            local tmpData = { ico = 20, label = "todo/act/1", x = mt, y = p_num, npcId = pinfo.npc + 0, mapId = pinfo.mid + 0, pos = pos, clickType = "forZMLL" };


            local func = function()
                log("TodoManager has move to npc ")
            end;
            self.todoManagerInfo = TodoManager.Add(TodoConst.Type.GOTONPC, tmpData, func);

        end

    end

end

function PartyFloatPanelControll:TodoMamagerClickHander(data)

    if data.data.clickType == "forZMLL" then
        ZongMenLiLianDataManager.autoFightForZMLL = true;
    end
end




function PartyFloatPanelControll:TryDisTodoManager()

    if self.todoManagerInfo ~= nil then
        TodoManager.Auto(self.todoManagerInfo)
    end

end

function PartyFloatPanelControll:PartDataChangeHandlerForFollow(dc_type)


    local fctr = HeroController:GetInstance():GetFollowAiCtr();


    if fctr ~= nil then
        -- 如果正在跟随， 那么改变 跟随目标
        local mt = PartData.GetMyTeam();

        if mt ~= nil then
            local ld = PartData.FindTeamLeader();

            -- 如果 队长换人了 那么就 中断 跟随

            if ld ~= nil then

                local currFollowTarget = fctr.currFollowTarget;
                if currFollowTarget ~= nil then
                    if currFollowTarget.target_id ~= ld.pid then
                        -- 队长 换人了， 那么就停止 跟随
                        HeroController:GetInstance():StopFollow();
                        -- 发送 主动取消跟随通知
                        local isld = PartData.MeIsTeamLeader();
                        if not isld then
                            FriendProxy.AnswerLdAskGenShui(0, 0);
                        end

                    end
                end
            end
        else
            HeroController:GetInstance():StopFollow();
            -- 发送 主动取消跟随通知
            -- FriendProxy.AnswerLdAskGenShui(0, 0);  -- 自己已经退出队伍了，

            -- 已经推出队伍，
            FriendProxy.DisGenSuiList( { })
        end

    else

        local mt = PartData.GetMyTeam();
        if mt ~= nil then

            -- if dc_type == PartData.PARTY_DATA_CHANGE_TYPE_SETNEW_TEAMLEADER_NAME then
            --  FriendProxy.GenShuiMbChange();
            -- end


        else
            FriendProxy.DisGenSuiList( { });
        end


    end

    self:UpFollowInfos();

    local mt = PartData.GetMyTeam();

    if dc_type == PartData.PARTY_DATA_CHANGE_TYPE_SETMYTEAM and mt == nil then

    else
        FriendProxy.GetPartyDress();
    end


end


function PartyFloatPanelControll:_OnClickBtnGenSui1()

    if self.gsBt1Type == PartyFloatPanelControll.gsBtType_1 then
        -- 队长 召唤跟随
        FriendProxy.LdAskGenShui()

    elseif self.gsBt1Type == PartyFloatPanelControll.gsBtType_3 then
        -- 队员 跟随
        local mt = PartData.GetMyTeam();

        if mt ~= nil then
            local ld = PartData.FindTeamLeader();
            if ld ~= nil then
                HeroController:GetInstance():StartFollow(ld.pid, HeroController.FOLLOWTYPE_FOR_TEAM);

                -- 发送 主动跟随通知
                FriendProxy.AnswerLdAskGenShui(1, 0)

                -- 改变状态
                self:UpFollowInfos();
            end
        else
            MsgUtils.ShowTips("Friend/PartyFloatPanelControll/tip3");
        end


    elseif self.gsBt1Type == PartyFloatPanelControll.gsBtType_4 then
        -- 队员 取消跟随
        HeroController:GetInstance():StopFollow();

        -- 发送 主动取消跟随通知
        FriendProxy.AnswerLdAskGenShui(0, 0)

        self:UpFollowInfos();
    end

end

function PartyFloatPanelControll:_OnClickBtnGenSui2()

    if self.gsBt2Type == PartyFloatPanelControll.gsBtType_2 then
        -- 队长取消 跟随
        FriendProxy.LdCancelGenShui()
    end

end


PartyFloatPanelControll.gsBtType_1 = 1;
PartyFloatPanelControll.gsBtType_2 = 2;
PartyFloatPanelControll.gsBtType_3 = 3;
PartyFloatPanelControll.gsBtType_4 = 4;

function PartyFloatPanelControll:UpFollowInfos()


    if PartyFloatPanelControll.fb_genshui then

        self.btnGenSui1.gameObject:SetActive(false);
        self.btnGenSui2.gameObject:SetActive(false);

        return;
    end

    local tmbLen = PartData.GetMyTeamNunberNum();
    if tmbLen > 1 then

        -- 判断 自己 是否是队长
        local misld = PartData.MeIsTeamLeader();

        if misld then
            self.btnGenSui1.gameObject:SetActive(true);
            self.btnGenSui2.gameObject:SetActive(true);
            self.btnGenSuiLabel1.text = LanguageMgr.Get("Friend/PartyFloatPanelControll/tip8");
            self.btnGenSuiLabel2.text = LanguageMgr.Get("Friend/PartyFloatPanelControll/tip9");

            self.gsBt1Type = PartyFloatPanelControll.gsBtType_1;
            self.gsBt2Type = PartyFloatPanelControll.gsBtType_2;
        else

            -- 需要是否在跟随状态
            self.btnGenSui1.gameObject:SetActive(true);

            local isFollow = HeroController:GetInstance():IsFollowAiCtr();

            if not isFollow then
                self.btnGenSuiLabel1.text = LanguageMgr.Get("Friend/PartyFloatPanelControll/tip10");
                self.gsBt1Type = PartyFloatPanelControll.gsBtType_3;

            else
                self.btnGenSuiLabel1.text = LanguageMgr.Get("Friend/PartyFloatPanelControll/tip9");
                self.gsBt1Type = PartyFloatPanelControll.gsBtType_4;

            end

        end

    end

end
