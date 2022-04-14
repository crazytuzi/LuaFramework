-- @Author: lwj
-- @Date:   2019-07-18 14:30:31
-- @Last Modified time: 2019-11-05 10:59:31

require("game.openHigh.RequireOpenHigh")
OpenHighController = OpenHighController or class("OpenHighController", BaseController)
local OpenHighController = OpenHighController

function OpenHighController:ctor()
    OpenHighController.Instance = self
    self.model = OpenHighModel:GetInstance()
    self:AddEvents()
    self:RegisterAllProtocal()
end

function OpenHighController:dctor()
    for i, v in pairs(self.global_event) do
        GlobalEvent:RemoveListener(v)
    end
    self.global_event = {}
end

function OpenHighController:GetInstance()
    if not OpenHighController.Instance then
        OpenHighController.new()
    end
    return OpenHighController.Instance
end

function OpenHighController:RegisterAllProtocal()
    self.pb_module_name = ""
end

function OpenHighController:AddEvents()
    local function callback(data)
        if not self:IsSelfAct(data.id) then
            return
        end
        self.model:SetActInfo(data)
        --dump(data, "<color=#6ce19b>OpenHighController   OpenHighController  OpenHighController  OpenHighController</color>")
        if self.model.is_open_panel then
            self.model.is_open_panel = false
            lua_panelMgr:GetPanelOrCreate(OpenHighPanel):Open()
        else
            self.model:Brocast(OpenHighEvent.UpdateTaskPro)
        end
        self:CheckOpenHighRD(data)
    end
    GlobalEvent:AddListener(OperateEvent.DLIVER_YY_INFO, callback)

    self.global_event = {}
    self.global_event[#self.global_event + 1] = GlobalEvent:AddListener(OpenHighEvent.MainBtnClick, handler(self, self.HandleMainClick))
    self.global_event[#self.global_event + 1] = GlobalEvent:AddListener(OperateEvent.SUCCESS_GET_REWARD, handler(self, self.HandleSuccessRewarded))
    self.global_event[#self.global_event + 1] = GlobalEvent:AddListener(BagEvent.UpdateGoods, handler(self, self.CheckColeRD))
end

function OpenHighController:CheckColeRD()
    if not self.model.game_started then
        return
    end
    local data = {}
    data.id = 120301
    self:CheckOpenHighRD(data)
end

function OpenHighController:CheckOpenHighRD(data)
    local is_show_rd = false
    local id = data.id
    if id == 120101 then
        is_show_rd = self.model:CheckMainRD(id)
    elseif id == 120201 then
        is_show_rd = self.model:CheckWeddingRD()
    elseif id == 120301 then
        is_show_rd = self.model:CheckColeRD()
    elseif id == 120401 then
        is_show_rd = self.model:CheckCreateClubRD()
    elseif id == OperateModel.GetInstance():GetActIdByType(205) then
        is_show_rd = self.model:CheckClubFightRD()
    end
    --local is_can_hide = self.model:IsCanHideMainIconRD()
    OperateModel.GetInstance():UpdateIconReddot(id, is_show_rd)
    self.model:Brocast(OpenHighEvent.UpdateTopItemRD, id, is_show_rd)
end

-- overwrite
function OpenHighController:GameStart()
    local function step()
        self.model.game_started = true
    end
    GlobalSchedule:StartOnce(step, 12)
end

function OpenHighController:HandleMainClick()
    self.model.is_open_panel = true
    self:HandleOpenPanel()
end

function OpenHighController:HandleOpenPanel()
    self.model:CheckActListId()
    local list = self.model.act_id_list
    for i, v in pairs(list) do
        GlobalEvent:Brocast(OperateEvent.REQUEST_GET_YY_INFO, v)
        local end_time = OperateModel.GetInstance():GetActEndTimeByActId(v)
        self.model:SetEndTimeByActId(v, end_time)
    end
end

function OpenHighController:HandleSuccessRewarded(data)
    if not self:IsSelfAct(data.act_id) then
        return
    end
    GlobalEvent:Brocast(OperateEvent.REQUEST_GET_YY_INFO, data.act_id)
    Notify.ShowText("Claimed")
    self.model:Brocast(OpenHighEvent.SuccessFetchRewa, data)
end

function OpenHighController:IsSelfAct(tar_id)
    self.model:CheckActListId()
    local result = false
    for i, v in pairs(self.model.act_id_list) do
        if tar_id == v then
            result = true
            break
        end
    end
    return result
end
