-- @Author: lwj
-- @Date:   2019-08-24 17:09:03 
-- @Last Modified time: 2019-08-24 17:09:06

CoupleDungeLeftCenter = CoupleDungeLeftCenter or class("CoupleDungeLeftCenter", BasePanel)
local CoupleDungeLeftCenter = CoupleDungeLeftCenter

function CoupleDungeLeftCenter:ctor()
    self.abName = "marry"
    self.assetName = "CoupleDungeLeftCenter"
    self.layer = "Bottom"
    self.dunge_id = 30103
    self.prepar_time = 0
    self.events = {};

    self.model = CoupleModel.GetInstance()
end

function CoupleDungeLeftCenter:dctor()
    GlobalEvent:RemoveTabListener(self.events);
    self.events = nil;
end

function CoupleDungeLeftCenter:Open()
    CoupleDungeLeftCenter.super.Open(self)
end

function CoupleDungeLeftCenter:OpenCallBack()
end

function CoupleDungeLeftCenter:LoadCallBack()
    self.nodes = {
        "LeftShow/target", "CountDown/cd", "LeftShow/dunge_name", "CountDown", "start_time/time", "start_time",
        --"LeftShow/con_one", "LeftShow/con_two",
        "LeftShow/Scroll_one/Viewport/con_one", "LeftShow/Scroll_two/Viewport/con_two", "LeftShow",
    }
    self:GetChildren(self.nodes)
    self.dunge_name = GetText(self.dunge_name)
    self.target = GetText(self.target)
    self.cd = GetText(self.cd)
    self.prepare_time_t = GetText(self.time)

    self:AddEvent()
    self:InitPanel()

    local mons = SceneManager:GetInstance():GetObjectListByType(enum.ACTOR_TYPE.ACTOR_TYPE_CREEP);
    if mons then
        for k, v in pairs(mons) do
            self:HandleNewCreate(v);
        end
    end
end

function CoupleDungeLeftCenter:AddEvent()
    self.update_target_event_id = GlobalEvent:AddListener(MarryEvent.UpdateDungeonTarget, handler(self, self.UpdateTargetShow))
    local function callback()
        GlobalSchedule.StopFun(self.cd_schedual);
        SetVisible(self.CountDown, false)
    end
    self.stop_cd_event_id = GlobalEvent:AddListener(DungeonEvent.DeliverQuestion, callback)

    print2(">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>");
    print2(">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>");
    GlobalEvent.AddEventListenerInTab(EventName.NewSceneObject, handler(self, self.HandleNewCreate), self.events);
end

function CoupleDungeLeftCenter:InitPanel()
    SetVisible(self.CountDown, false)
    self.dunge_cf = Config.db_dunge[self.dunge_id]
    if not self.dunge_cf then
        logError("CoupleDungeLeftCenter,没有Dunge配置")
        return
    end

    local enter_info = self.model:GetEnterInfo()
    self.dunge_name.text = self.dunge_cf.name
    self:LoadReward()
    self:UpdateTargetShow()
    SetAlignType(self.LeftShow, bit.bor(AlignType.Left, AlignType.Null))
    --开始准备倒数
    self:StartPrepareCD(enter_info.prep_time)
end

function CoupleDungeLeftCenter:StartPrepareCD(prep_time)
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

function CoupleDungeLeftCenter:StartDungeon()
    self.prepar_time = self.prepar_time - 1;
    self.prepare_time_t.text = tostring(self.prepar_time);
    if self.prepar_time <= 0 then
        self.start_time.gameObject:SetActive(false);

        if self.prepare_schedules then
            GlobalSchedule:Stop(self.prepare_schedules);
        end
        self.prepare_schedules = nil;
        SetVisible(self.CountDown, true)
        --自动战斗
        TaskModel:GetInstance():StopTask();--先停掉任务,因为任务优先级高
        OperationManager:GetInstance():StopAStarMove();
        if not AutoFightManager:GetInstance():GetAutoFightState() then
            GlobalEvent:Brocast(FightEvent.AutoFight)
        end

        local enter_info = self.model:GetEnterInfo()
        self.end_time = enter_info.end_time
        self.cd_schedual = GlobalSchedule:Start(handler(self, self.EndDungeon), 0.2, -1);
    end
end

function CoupleDungeLeftCenter:EndDungeon()
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

function CoupleDungeLeftCenter:LoadReward()
    local rewa_cf = String2Table(Config.db_dunge_couple.reward.val)[1]
    self.rewa_all_item_list = self.rewa_all_item_list or {}
    self.rewa_part_item_list = self.rewa_part_item_list or {}
    local len = #rewa_cf
    for i = 1, len do
        local item_list = i == 1 and self.rewa_all_item_list or self.rewa_part_item_list
        local con = i == 1 and self.con_one or self.con_two
        local list = rewa_cf[i][2]
        local count = #list
        for i = 1, count do
            local item = item_list[i]
            if not item then
                item = GoodsIconSettorTwo(con)
                item_list[i] = item
            else
                item:SetVisible(true)
            end
            local param = {}
            local operate_param = {}
            local num = list[i][2]
            local item_id = list[i][1]
            param["item_id"] = item_id
            param["model"] = self.model
            param["can_click"] = true
            param["operate_param"] = operate_param
            param["size"] = { x = 60, y = 60 }
            local final_num = num
            if item_id == enum.ITEM.ITEM_PLAYER_EXP or item_id == enum.ITEM.ITEM_WORLDLV_EXP then
                final_num = GetProcessedExpNum(item_id, num)
            end
            param["num"] = final_num
            param.bind = list[i][3]
            item:SetIcon(param)
        end
        for i = count + 1, #item_list do
            local item = item_list[i]
            item:SetVisible(false)
        end
    end
end

function CoupleDungeLeftCenter:UpdateTargetShow()
    local target_tbl = String2Table(self.dunge_cf.complete)[1]
    local creep_id = target_tbl[2]
    local num = target_tbl[3]
    local creep_name = Config.db_creep[creep_id].name
    local name = "<color=#5bd122>" .. creep_name .. "</color>"
    local kill_num = self.model:GetKillCreapByCreapId(creep_id)
    self.target.text = string.format(ConfigLanguage.CoupleDungeon.DungeonTarget, name, kill_num, num)
end

function CoupleDungeLeftCenter:CloseCallBack()
    if self.prepare_schedules then
        GlobalSchedule:Stop(self.prepare_schedules);
    end
    self.prepare_schedules = nil;
    if self.stop_cd_event_id then
        GlobalEvent:RemoveListener(self.stop_cd_event_id)
        self.stop_cd_event_id = nil
    end
    if self.update_target_event_id then
        GlobalEvent:RemoveListener(self.update_target_event_id)
        self.update_target_event_id = nil
    end
    for i, v in pairs(self.rewa_all_item_list) do
        if v then
            v:destroy()
        end
    end
    self.rewa_all_item_list = {}
    for i, v in pairs(self.rewa_part_item_list) do
        if v then
            v:destroy()
        end
    end
    self.rewa_part_item_list = {}
    GlobalSchedule.StopFun(self.cd_schedual);
end

local ConfigLanguage = require('game.config.language.CnLanguage')
function CoupleDungeLeftCenter:HandleNewCreate(monster)
    if monster and monster.object_type == enum.ACTOR_TYPE.ACTOR_TYPE_CREEP then
        if monster.object_info and monster.object_info.name then
            local level = RoleInfoModel:GetInstance():GetMainRoleLevel();
            monster.name_container:SetName(string.format(ConfigLanguage.Common.Level, level) .. " " .. monster.object_info.name);
        end
    end
end