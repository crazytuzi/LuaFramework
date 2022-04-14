-- @Author: lwj
-- @Date:   2019-12-05 14:55:57
-- @Last Modified time: 2019-12-05 14:56:07

require('game.dial.RequireDial')
DialController = DialController or class("DialController", BaseController)
local DialController = DialController

function DialController:ctor()
    DialController.Instance = self
    self.model = DialModel:GetInstance()
    self.global_event = {}
    self:AddEvents()
    self:RegisterAllProtocal()
end

function DialController:dctor()
end

function DialController:GetInstance()
    if not DialController.Instance then
        DialController.new()
    end
    return DialController.Instance
end

function DialController:RegisterAllProtocal()
end

function DialController:AddEvents()
    self.global_event = {}
    self.global_event[#self.global_event + 1] = GlobalEvent:AddListener(DialEvent.OpenRechaP, handler(self, self.HandleOpenRechaP))
    self.global_event[#self.global_event + 1] = GlobalEvent:AddListener(OperateEvent.DILIVER_D_INFO, handler(self, self.HandleInfo))
    self.global_event[#self.global_event + 1] = GlobalEvent:AddListener(OperateEvent.DILIVER_TURN_RESULT, handler(self, self.HandleTurnReuslt))
    self.global_event[#self.global_event + 1] = GlobalEvent:AddListener(OperateEvent.UPDATE_D_PRO, handler(self, self.HandleUpdatePro))
    self.global_event[#self.global_event + 1] = GlobalEvent:AddListener(EventName.CrossDayAfter, handler(self, self.HandleCross))
end

function DialController:HandleOpenRechaP()
    lua_panelMgr:GetPanelOrCreate(RechargeDialPanel):Open()
end

function DialController:HandleCross()
    local id = OperateModel.GetInstance():GetActIdByType(750)
    --if id ~= 0 then
    --    GlobalEvent:Brocast(OperateEvent.REQUEST_D_INFO, id)
    --end
end

function DialController:GameStart()
    local function step()
        local id = OperateModel.GetInstance():GetActIdByType(750)
        if id ~= 0 then
            GlobalEvent:Brocast(OperateEvent.REQUEST_D_INFO, id)
        end
    end
    self.crossday_delay_sche = GlobalSchedule:StartOnce(step, Constant.GameStartReqLevel.VLow)
end

function DialController:HandleInfo(act_id, data)
    if act_id == OperateModel.GetInstance():GetActIdByType(750) then
        self.model:SetInfo(data)
        --dump(data, "<color=#6ce19b>HandleMCInfo   HandleMCInfo  HandleMCInfo  HandleMCInfo</color>")
        self.model:Brocast(DialEvent.UpdateDPanel)
    end
    self:RedDotOperate(act_id)
end

function DialController:HandleUpdatePro(act_id, progress)
    if act_id == OperateModel.GetInstance():GetActIdByType(750) then
        self.model:UpdatePro(act_id, progress)
        --GlobalEvent:Brocast(OperateEvent.REQUEST_D_INFO, act_id)
        self.model:Brocast(DialEvent.UpdateDPanel)
    end
    self:RedDotOperate(act_id)
end

function DialController:HandleTurnReuslt(act_id, data)
    local is_self_act = false
    if act_id == OperateModel.GetInstance():GetActIdByType(750) then
        is_self_act = true
    end
    if is_self_act then
        self.model:UpdateInfo(act_id, data)
        self.model:Brocast(DialEvent.StartTurnDial, act_id, data.hit)
    end
    self:RedDotOperate(act_id)
end

function DialController:OnTurnCallBack(index)
    self:UpdateTableHit()
    self:CheckIsEmpty()
end

function DialController:RedDotOperate(act_id)
    local is_show
    if act_id == OperateModel.GetInstance():GetActIdByType(750) then
        is_show = self.model:CheckRechargeRD()
        GlobalEvent:Brocast(MainEvent.ChangeRedDot, "dial", is_show)
    end
end