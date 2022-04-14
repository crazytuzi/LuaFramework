-- @Author: lwj
-- @Date:   2019-09-06 15:27:59 
-- @Last Modified time: 2019-09-06 15:28:07

require('game.godcele.RequireGodCelebration')
GodCelebrationController = GodCelebrationController or class("GodCelebrationController", BaseController)
local GodCelebrationController = GodCelebrationController

function GodCelebrationController:ctor()
    GodCelebrationController.Instance = self
    self.model = GodCelebrationModel:GetInstance()
    self:AddEvents()
    self:RegisterAllProtocal()
end

function GodCelebrationController:dctor()
    for i, v in pairs(self.global_event) do
        GlobalEvent:RemoveListener(v)
    end
    self.global_event = {}
    if self.crossday_delay_sche then
        GlobalSchedule:Stop(self.crossday_delay_sche)
        self.crossday_delay_sche = nil
    end
end

function GodCelebrationController:GetInstance()
    if not GodCelebrationController.Instance then
        GodCelebrationController.new()
    end
    return GodCelebrationController.Instance
end

function GodCelebrationController:RegisterAllProtocal()
    -- protobuff的模块名字，用到pb一定要写
    self.pb_module_name = ""
    -- self:RegisterProtocal(35025, self.RequestLoginVerify)
end

function GodCelebrationController:AddEvents()
    self.global_event = {}
    self.global_event[#self.global_event + 1] = GlobalEvent:AddListener(GodCeleEvent.OpenSevenDayActivePanel, handler(self, self.HandleOpenNationPanel))
    self.global_event[#self.global_event + 1] = GlobalEvent:AddListener(DungeonEvent.GlobalEnterDungeInfo, handler(self, self.HandleEnterDungeInfo))
    self.global_event[#self.global_event + 1] = GlobalEvent:AddListener(DungeonEvent.DUNGEON_EXP_GOLD_INFO, handler(self, self.HandleDungeonInfo))
    self.global_event[#self.global_event + 1] = GlobalEvent:AddListener(OperateEvent.DLIVER_YY_INFO, handler(self, self.ActiveInfo))
    self.global_event[#self.global_event + 1] = GlobalEvent:AddListener(OperateEvent.SUCCESS_GET_REWARD, handler(self, self.ReturnReward))
    self.global_event[#self.global_event + 1] = GlobalEvent:AddListener(DungeonEvent.UpdateDungeonData, handler(self, self.HandleDungePanel))
    local function callback()
        local function step()
            DungeonCtrl.GetInstance():RequestDungeonPanel(enum.SCENE_STYPE.SCENE_STYPE_DUNGE_YUNYING_TOWER)
        end
        GlobalSchedule:StartOnce(step, 60)
    end
    self.global_event[#self.global_event + 1] = GlobalEvent:AddListener(EventName.CrossDay, callback)

    local function callback()
        local data = {}
        data.id = 150501
        self:ActiveInfo(data, true)
    end
    self.global_event[#self.global_event + 1] = GlobalEvent:AddListener(BagEvent.UpdateGoods, callback)
    --self.global_event[#self.global_event + 1] = GlobalEvent:AddListener(BagEvent.AddItems, callback)
end

function GodCelebrationController:HandleDungeonInfo(data)
    if data.stype ~= enum.SCENE_STYPE.SCENE_STYPE_DUNGE_YUNYING_TOWER then
        return
    end
    self.model.dunge_info = data
    self.model:Brocast(GodCeleEvent.StartDungeonCD)
    --UpdateTargetShow()
end

function GodCelebrationController:HandleEnterDungeInfo(data)
    if not data.stype == enum.SCENE_STYPE.SCENE_STYPE_DUNGE_YUNYING_TOWER then
        return
    end
    self.model.dunge_enter_info = data
end

-- overwrite
--function GodCelebrationController:GameStart()
--
--end
--
function GodCelebrationController:HandleOpenNationPanel(type_id)
    lua_panelMgr:GetPanelOrCreate(GodCelebrationPanel):Open(type_id)
end

function GodCelebrationController:HandleOpenDayActiveEvent()
    lua_panelMgr:GetPanelOrCreate(SevenDayActivePanel):Open(1)
end

function GodCelebrationController:RegisterAllProtocol()
    ---[[protobuff的模块名字，用到pb一定要写]]
    --self.pb_module_name = "protobuff_Name"
    -- self:RegisterProtocal(proto.GAME_PAYSUCC, self.HandlePaySucc)
end

-- overwrite
function GodCelebrationController:GameStart()
    --DungeonCtrl.GetInstance():RequestDungeonPanel(enum.SCENE_STYPE.SCENE_STYPE_DUNGE_YUNYING_TOWER)
    local function step()
        local data = {}
        data.id = 150501
        self:ActiveInfo(data)
    end
    self.crossday_delay_sche = GlobalSchedule:StartOnce(step, Constant.LoadResLevel.Low)
end

function GodCelebrationController:ActiveInfo(info, is_update_goods)
    --if info.stype ~= enum.SCENE_STYPE.SCENE_STYPE_DUNGE_YUNYING_TOWER then
    --    return
    --end
    --dump(info, "<color=#6ce19b>GodCelebrationController   GodCelebrationController  GodCelebrationController  GodCelebrationController</color>")
    local id = info.id
    if OperateModel:GetInstance():GetActIdByType(504) == info.id then
        --限購
        self.model.redPoints[id] = self.model.isFirstOpen_buy
    end
    self:CheckExchangeRD(info)
    if not is_update_goods then
        self:CheckFreeDunge()
    end
    if OperateModel:GetInstance():GetActIdByType(502) == info.id or OperateModel:GetInstance():GetActIdByType(503) == info.id then
        --冲榜
        self.model.redPoints[id] = false
        for i = 1, #info.tasks do
            if info.tasks[i].state == enum.YY_TASK_STATE.YY_TASK_STATE_FINISH then
                --已完成
                self.model.redPoints[id] = true
                break
            end
        end
        local isRed = false
        for i, v in pairs(self.model.redPoints) do
            if v == true then
                isRed = true
                break
            end
        end
        OperateModel:GetInstance():UpdateIconReddot(id, isRed)
    end
    self.model:Brocast(GodCeleEvent.RedPointInfo)
end

function GodCelebrationController:GetExchangeTaskInfo(info, id)
    if not info then
        return
    end
    local result
    for i = 1, #info do
        local data = info[i]
        if data.id == id then
            result = data
            break
        end
    end
    return result
end

function GodCelebrationController:ReturnReward(data)
    for id, v in pairs(self.model.redPoints) do
        if data.act_id == id and data.act_id ~= 150501 then
            local info = OperateModel:GetInstance():GetActInfo(id)
            local boo = false
            for i = 1, #info.tasks do
                if info.tasks[i].state == enum.YY_TASK_STATE.YY_TASK_STATE_FINISH then
                    boo = true
                    break
                end
            end
            self.model.redPoints[id] = boo
        end
    end
    local isRed = false
    for i, v in pairs(self.model.redPoints) do
        if v == true then
            isRed = true
            -- break
        end
        OperateModel:GetInstance():UpdateIconReddot(i, v)
    end
    self.model:Brocast(GodCeleEvent.RedPointInfo)
    local data = {}
    data.id = 150501
    self:CheckExchangeRD(data)
end

-- function GodCelebrationController:HandlePaySucc()
--     local data = self:ReadMsg("m_game_paysucc_toc", "pb_1000_game_pb")

--     self.model:Brocast(SevenDayActiveEvent.PaySucc)
-- end

function GodCelebrationController:CheckExchangeRD(info)
    if OperateModel:GetInstance():GetActIdByType(505) == info.id then
        local id = info.id
        local num = BagModel.GetInstance():GetItemNumByItemID(13140)
        local list = OperateModel.GetInstance():GetRewardConfig(id)
        local act_info = OperateModel:GetInstance():GetActInfo(id)
        if not act_info then
            return
        end
        if not list then
            if AppConfig.Debug then
                logError("GodCelebrationController:CheckExchangeRD,the list is nil ,act id = ",id)
            end
            return
        end
        local info_list = act_info.tasks
        local is_show = false
        for i = 1, #list do
            local data = list[i]
            local info = self:GetExchangeTaskInfo(info_list, data.id)
            if info then
                local cur_ex_count = info.count
                local limit = String2Table(data.limit)[2]
                local need_num = String2Table(data.cost)[1][2]
                --有剩余兑换数量
                if cur_ex_count < limit then
                    if num >= need_num then
                        is_show = true
                        break
                    end
                end
            end
        end
        self.model.redPoints[id] = is_show
        self.model:Brocast(GodCeleEvent.RedPointInfo)
        local isRed = false
        for _, v in pairs(self.model.redPoints) do
            if v == true then
                isRed = true
                break
            end
        end
        OperateModel:GetInstance():UpdateIconReddot(id, isRed)
    end
end

function GodCelebrationController:CheckFreeDunge()
    local dunge_panel_data = self.model:GetDungePanelInfo()
    if table.isempty(dunge_panel_data) then
        return
    end
    --按钮文本更新
    local dunge_id = dunge_panel_data.id
    local dunge_cf = Config.db_dunge[dunge_id]
    local scene_id = dunge_cf.scene
    local scene_cf = Config.db_scene[scene_id]
    local cost_tbl = String2Table(scene_cf.cost)
    --免费次数的总数
    local free_time = cost_tbl[1][2]
    --当前剩余次数
    local rest_time = dunge_panel_data.info.max_times - dunge_panel_data.info.cur_times
    --付费次数的总数
    local pay_time = dunge_panel_data.info.max_times - free_time
    --剩余次数小于等于付费次数，需要开始付费
    self.pay_tbl = cost_tbl[2][3][1]
    --剩余次数文本
    local is_show = false
    if rest_time > 0 then
        if rest_time - pay_time > 0 then
            --免费
            is_show = true
        end
    end

    self.model.redPoints[150601] = is_show
    local isRed = false
    for i, v in pairs(self.model.redPoints) do
        if v == true then
            isRed = true
            break
        end
    end
    OperateModel:GetInstance():UpdateIconReddot(150601, isRed)
    self.model:Brocast(GodCeleEvent.RedPointInfo)
end

function GodCelebrationController:HandleDungePanel(stype, data)
    if stype ~= enum.SCENE_STYPE.SCENE_STYPE_DUNGE_YUNYING_TOWER then
        return
    end
    self.model:SetDungePanelInfo(data)
    self:CheckFreeDunge()
end
