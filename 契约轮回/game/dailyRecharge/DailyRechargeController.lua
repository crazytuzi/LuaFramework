-- @Author: lwj
-- @Date:   2019-03-29 19:06:35
-- @Last Modified time: 2019-03-29 19:06:41

require('game.dailyRecharge.RequireDailyRecharge')
DailyRechargeController = DailyRechargeController or class("DailyRechargeController", BaseController)
local DailyRechargeController = DailyRechargeController

function DailyRechargeController:ctor()
    DailyRechargeController.Instance = self
    self.model = DailyRechargeModel:GetInstance()
    self.act_list = { 100201, 100202, 100301 }
    self:AddEvents()
    self:RegisterAllProtocal()
end

function DailyRechargeController:dctor()
    if self.sche then
        GlobalSchedule:Stop(self.sche)
        self.sche = nil
    end
    if self.check_rd_event_id then
        self.model:RemoveListener(self.check_rd_event_id)
        self.check_rd_event_id = nil
    end
end

function DailyRechargeController:GetInstance()
    if not DailyRechargeController.Instance then
        DailyRechargeController.new()
    end
    return DailyRechargeController.Instance
end

function DailyRechargeController:RegisterAllProtocal()
    -- protobuff的模块名字，用到pb一定要写
    self.pb_module_name = ""
    -- self:RegisterProtocal(35025, self.RequestLoginVerify)
end

function DailyRechargeController:GetActConfig()
    for i, v in pairs(self.act_list) do
        local cf = OperateModel.GetInstance():GetConfig(v)
        self.model:SetActConfig(cf)
    end
end

function DailyRechargeController:AddEvents()
    local function callback()
        --获取 前\后的奖励信息
        self:GetActConfig()
        local first_cf = self.model:GetActConfigByActId(100201)
        local time_tbl = String2Table(first_cf.time)
        local split_day = time_tbl[2][1]
        self.model.is_open_panel = true
        local act_id = 100201
        local open_day = LoginModel.GetInstance():GetOpenTime()
        if open_day > split_day then
            act_id = 100202
        end
        GlobalEvent:Brocast(OperateEvent.REQUEST_GET_YY_INFO, act_id)
        --获取成就奖励信息
        GlobalEvent:Brocast(OperateEvent.REQUEST_GET_YY_INFO, 100301)
    end
    GlobalEvent:AddListener(DailyRechargeEvent.OpenDailyRechargePanel, callback)
    GlobalEvent:AddListener(OperateEvent.DLIVER_YY_INFO, handler(self, self.SetYYInfo))

    self.check_rd_event_id = self.model:AddListener(DailyRechargeEvent.CheckRD, handler(self, self.CheckRD))
end

function DailyRechargeController:SetYYInfo(info)
    if info.id ~= 100201 and info.id ~= 100202 and info.id ~= 100301 then
        return
    end
    if info.id == 100301 then
        self.model:SetAchiInfo(info)
    elseif info.id == 100201 or info.id == 100202 then
        self.model:SetYYInfo(info)
    end
    --dump(info, "<color=#6ce19b>ConyrollerSetYYInfo   ConyrollerSetYYInfo  ConyrollerSetYYInfo  ConyrollerSetYYInfo</color>")
    if self.model:IsAlreadyGetAllInfo() then
        if self.model.is_open_panel then
            self.model.is_open_panel = false
            lua_panelMgr:GetPanelOrCreate(DailyRechargeGatherPanel):Open()
        end
        self:CheckRD()
        if self.model.is_show_rd_once then
            self:ShowRedDotInMain(info.id)
        end
    end
end

function DailyRechargeController:CheckRD()
    local is_show = self.model:ChangeRDShow()
    GlobalEvent:Brocast(MainEvent.ChangeSystemShowInStronger, 32, is_show)
end

function DailyRechargeController:GameStart()
end

function DailyRechargeController:ShowRedDotInMain(act_id)
    self.model.is_show_rd_once = false
    OperateModel.GetInstance():UpdateIconReddot(act_id, true)
end

