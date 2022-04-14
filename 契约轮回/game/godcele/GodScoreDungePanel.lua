-- @Author: lwj
-- @Date:   2019-09-10 16:36:20 
-- @Last Modified time: 2019-09-16 17:53:35

GodScoreDungePanel = GodScoreDungePanel or class("GodScoreDungePanel", BasePanel)
local GodScoreDungePanel = GodScoreDungePanel

function GodScoreDungePanel:ctor()
    self.abName = "sevenDayActive"
    self.assetName = "GodScoreDungePanel"
    self.layer = "UI"
    self.prepar_time = 0
    self.is_startting_count = false
    self.is_first_start_cd = true

    self.fight_coord = { 727, 813 }
    self.is_hide_model_effect = false
    self.model = GodCelebrationModel.GetInstance()
end

function GodScoreDungePanel:dctor()

end

function GodScoreDungePanel:Open()
    GodScoreDungePanel.super.Open(self)
end

function GodScoreDungePanel:OpenCallBack()
end

function GodScoreDungePanel:LoadCallBack()
    self.nodes = {
        "LeftShow/currentAwardCon/Viewport/certain_con", "LeftShow/name", "LeftShow/nextAwardCon/Viewport/random_con", "LeftShow/round",
        "LeftShow", "start_time", "start_time/time", "CountDown", "CountDown/cd",
    }
    self:GetChildren(self.nodes)
    self.name = GetText(self.name)
    self.prepare_time_t = GetText(self.time)
    self.cd = GetText(self.cd)
    self.round = GetText(self.round)

    self:AddEvent()
    self:InitPanel()
end

function GodScoreDungePanel:AddEvent()
    self.start_god_cele_cd_event_id = self.model:AddListener(GodCeleEvent.StartDungeonCD, handler(self, self.HandleStartCD))
    --self.enter_dunge_event_id = GlobalEvent:AddListener(DungeonEvent.GlobalEnterDungeInfo, handler(self, self.RestartPrePareCD))
end

function GodScoreDungePanel:RestartPrePareCD()
    if self.prepare_schedules then
        GlobalSchedule:Stop(self.prepare_schedules);
    end
    SetVisible(self.CountDown, false)
    SetVisible(self.start_time, true)
    self.prepare_schedules = nil;
    local dunge_info = self.model.dunge_info
    local prep_time = dunge_info.prep_time
    if prep_time < os.time() then
        SetVisible(self.start_time, false)
        self:StartDungeon();
    else
        local ostime = math.round(os.time());
        self.prepar_time = prep_time - ostime - 1;
        self.prepare_time_t.text = self.prepar_time
        self.prepare_schedules = GlobalSchedule:Start(handler(self, self.StartDungeon), 1, -1);
    end
    self:UpdateLeftShow()
end

function GodScoreDungePanel:InitPanel()
    SetVisible(self.CountDown, false)
    self:UpdateLeftShow()
    self:LoadRewa()
    SetAlignType(self.LeftShow, bit.bor(AlignType.Left, AlignType.Null))
    local info = self.model.dunge_info
    if info then
        self:HandleStartCD()
    end
end

function GodScoreDungePanel:HandleStartCD()
    if self.is_first_start_cd then
        if not self.is_startting_count then
            self.is_startting_count = true
            local dunge_info = self.model.dunge_info
            self:StartPrepareCD(dunge_info.prep_time)
        end
    else
        self:RestartPrePareCD()
    end

end

function GodScoreDungePanel:StartPrepareCD(prep_time)
    if prep_time < os.time() then
        SetVisible(self.start_time, false)
        self:StartDungeon();
    else
        local ostime = math.round(os.time());
        self.prepar_time = prep_time - ostime - 1;
        self.prepare_time_t.text = self.prepar_time
        self.prepare_schedules = GlobalSchedule:Start(handler(self, self.StartDungeon), 1, -1);
    end
end

function GodScoreDungePanel:StartDungeon()
    self.prepar_time = self.prepar_time - 1;
    self.prepare_time_t.text = tostring(self.prepar_time);
    if self.prepar_time <= 0 then
        self.start_time.gameObject:SetActive(false);

        if self.prepare_schedules then
            GlobalSchedule:Stop(self.prepare_schedules);
        end
        self.prepare_schedules = nil;
        SetVisible(self.CountDown, true)

        local function callback()
            --自动战斗
            TaskModel:GetInstance():StopTask();--先停掉任务,因为任务优先级高
            OperationManager:GetInstance():StopAStarMove();
            if not AutoFightManager:GetInstance():GetAutoFightState() then
                GlobalEvent:Brocast(FightEvent.AutoFight)
            end
        end
        OperationManager:GetInstance():TryMoveToPosition(nil, nil, { x = self.fight_coord[1], y = self.fight_coord[2] }, callback)
        local dunge_info = self.model.dunge_info
        self.end_time = dunge_info.end_time
        if self.cd_schedual then
            GlobalSchedule.StopFun(self.cd_schedual);
            self.cd_schedual = nil
        end
        self.cd_schedual = GlobalSchedule:Start(handler(self, self.EndDungeon), 0.2, -1);
        self.is_first_start_cd = false
    end
end

function GodScoreDungePanel:EndDungeon()
    local timeTab = nil;
    local timestr = "";
    local formatTime = "%02d";
    --整个副本的结束时间
    if self.end_time then
        timeTab = TimeManager:GetLastTimeData(os.time(), self.end_time);
        if table.isempty(timeTab) then
            GlobalSchedule.StopFun(self.cd_schedual);
        else
            if not timeTab.min then
                timeTab.min = 0
            end
            timestr = timestr .. string.format(formatTime, timeTab.min) .. ":";
            if not timeTab.sec then
                timeTab.sec = 0
            end
            timestr = timestr .. string.format(formatTime, timeTab.sec);
            self.cd.text = string.format(ConfigLanguage.CoupleDungeon.DungeCDHead, timestr);--"副本倒计时: " ..
        end
    end
end

function GodScoreDungePanel:UpdateLeftShow()
    self.enter_info = self.model.dunge_enter_info
    local dunge_id = self.enter_info.id
    local dunge_cf = Config.db_dunge[dunge_id]
    if not dunge_cf then
        logError("GodScoreDungePanel,dunge配置没有id为：dunge_id的配置:", dunge_id)
        return
    end
    self.name.text = dunge_cf.name
    self.round.text = string.format(ConfigLanguage.GodCele.DungeonCurFloor, self.enter_info .floor)
end

function GodScoreDungePanel:LoadRewa()
    local dunge_id = self.enter_info.id
    local dunge_cf = Config.db_dunge_wave[dunge_id .. "@" .. 1]
    local settled_list = String2Table(dunge_cf.reward)
    self.settle_rewa_list = self.settle_rewa_list or {}
    local len = #settled_list
    for i = 1, len do
        local item = self.settle_rewa_list[i]
        if not item then
            item = GoodsIconSettorTwo(self.certain_con)
            self.settle_rewa_list[i] = item
        else
            item:SetVisible(true)
        end
        local rewa_data = settled_list[i]
        local param = {}
        local operate_param = {}
        param["item_id"] = rewa_data[1]
        param["model"] = self.model
        param["can_click"] = true
        param["operate_param"] = operate_param
        param["size"] = { x = 80, y = 80 }
        param["num"] = rewa_data[2]
        param.bind = rewa_data[3]
        item:SetIcon(param)
    end
    for i = len + 1, #self.settle_rewa_list do
        local item = self.settle_rewa_list[i]
        item:SetVisible(false)
    end

    self.random_rewa_list = self.random_rewa_list or {}
    local list = String2Table(dunge_cf.reward_pr)
    local len = #list
    for i = 1, len do
        local item = self.random_rewa_list[i]
        if not item then
            item = GoodsIconSettorTwo(self.random_con)
            self.random_rewa_list[i] = item
        else
            item:SetVisible(true)
        end
        local rewa_data = list[i]
        local param = {}
        local operate_param = {}
        param["item_id"] = rewa_data[1]
        param["model"] = self.model
        param["can_click"] = true
        param["operate_param"] = operate_param
        param["size"] = { x = 80, y = 80 }
        param["num"] = rewa_data[2]
        param.bind = rewa_data[3]
        --local color = Config.db_item[id].color - 1
        --param["color_effect"] = color
        --param["effect_type"] = 2  --活动特效：2
        item:SetIcon(param)
    end
    for i = len + 1, #self.random_rewa_list do
        local item = self.random_rewa_list[i]
        item:SetVisible(false)
    end
end

function GodScoreDungePanel:CloseCallBack()
    if self.enter_dunge_event_id then
        GlobalEvent:RemoveListener(self.enter_dunge_event_id)
        self.enter_dunge_event_id = nil
    end
    if self.start_god_cele_cd_event_id then
        self.model:RemoveListener(self.start_god_cele_cd_event_id)
        self.start_god_cele_cd_event_id = nil
    end
    GlobalSchedule.StopFun(self.cd_schedual);
    for i, v in pairs(self.settle_rewa_list) do
        if v then
            v:destroy()
        end
    end
    self.settle_rewa_list = {}
    for i, v in pairs(self.random_rewa_list) do
        if v then
            v:destroy()
        end
    end
    self.random_rewa_list = {}
end