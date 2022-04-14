-- @Author: lwj
-- @Date:   2020-01-06 11:16:23
-- @Last Modified time: 2020-01-06 11:16:40

require('game.gundam_act.RequireGundamAct')
GundamActController = GundamActController or class("GundamActController", BaseController)
local GundamActController = GundamActController

function GundamActController:ctor()
    GundamActController.Instance = self
    self.model = GundamActModel:GetInstance()
    self.global_event = {}
    self:AddEvents()
    self:RegisterAllProtocal()
end

function GundamActController:dctor()
    if not table.isempty(self.global_event) then
        for i, v in pairs(self.global_event) do
            GlobalEvent:RemoveListener(v)
        end
        self.global_event = {}
    end
end

function GundamActController:GetInstance()
    if not GundamActController.Instance then
        GundamActController.new()
    end
    return GundamActController.Instance
end

function GundamActController:RegisterAllProtocal()
    -- protobuff的模块名字，用到pb一定要写
    self.pb_module_name = ""
end

function GundamActController:AddEvents()
    self.global_event[#self.global_event + 1] = GlobalEvent:AddListener(OperateEvent.DLIVER_YY_INFO, handler(self, self.HandleYYInfo))
    local function callback()
        local opday = LoginModel.GetInstance():GetOpenTime()
        if opday > 3 then
            self.model:Brocast(GundamActEvent.ClosePanel)
        else
            self:GetInfo()
        end
    end
    self.global_event[#self.global_event + 1] = GlobalEvent:AddListener(EventName.CrossDay, callback)

    local function callback()
        local opday = LoginModel.GetInstance():GetOpenTime()
        if opday > 0 and opday <= 3 then
            self:GetInfo()
        end
    end
    self.global_event[#self.global_event + 1] = GlobalEvent:AddListener(EventName.CrossDayAfter, callback)
end

function GundamActController:GameStart()
    local function step()
        self:GetInfo()
    end
    GlobalSchedule:StartOnce(step, Constant.GameStartReqLevel.Ordinary)
end

function GundamActController:GetInfo()
    local list = self.model.act_id_list
    for i = 1, #list do
        local id = list[i]
        GlobalEvent:Brocast(OperateEvent.REQUEST_GET_YY_INFO, id)
    end
end

function GundamActController:HandleYYInfo(data)
    local is_self = false
    local list = self.model.act_id_list
    for i = 1, #list do
        if data.id == list[i] then
            is_self = true
            break
        end
    end
    if not is_self then
        return
    end
    self.model:SetInfo(data)
    if not self.model:IsEnoughData() then
        return
    end
    self.model:Brocast(GundamActEvent.ReciveYYInfo)
    self:CheckRD()
end

function GundamActController:CheckRD()
    self.model.is_showing_task_rd = false
    local is_show_once_rd = false
    local lv = RoleInfoModel.GetInstance():GetMainRoleLevel()
    if lv >= 180 then
        if not self.model:IsAllFinish() then
            ----没有全部完成
            if self.model:IsHaveRewaCanFetch() then
                --有可以获取的奖励
                self.model.is_showing_task_rd = true
                is_show_once_rd = true
            else
                --没有
                if self.model:CheckLastOneDayTime() then
                    --大于1天
                    is_show_once_rd = true
                end
            end
        end
    end
    --主界面
    GlobalEvent:Brocast(GundamActEvent.UpdateGundamIconRD, is_show_once_rd)
    self.model:Brocast(GundamActEvent.UpdateGundamPanelRD)
end