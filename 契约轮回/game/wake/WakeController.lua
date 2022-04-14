require('game.wake.RequireWake')

WakeController = WakeController or class("WakeController", BaseController)
local WakeController = WakeController

function WakeController:ctor()
    WakeController.Instance = self
    self.model = WakeModel:GetInstance()
    self:AddEvents()
    self:RegisterAllProtocal()
end

function WakeController:dctor()
end

function WakeController:GetInstance()
    if not WakeController.Instance then
        WakeController.new()
    end
    return WakeController.Instance
end

function WakeController:RegisterAllProtocal()
    -- protobuff的模块名字，用到pb一定要写
    self.pb_module_name = "pb_1117_wake_pb"
    self:RegisterProtocal(proto.WAKE_INFO, self.HandleWakeInfo)
    self:RegisterProtocal(proto.WAKE_TASK, self.HandleWakeTask)
    self:RegisterProtocal(proto.WAKE_NEXT_STEP, self.HandleGoNextStep)
    self:RegisterProtocal(proto.WAKE_START, self.HandleWakeStart)
    self:RegisterProtocal(proto.WAKE_GET_GRIDS, self.HandleWakeGrid)
    self:RegisterProtocal(proto.WAKE_ACTIVE_GRID, self.HandleActiveGrid)
end

function WakeController:AddEvents()
    -- --请求基本信息
    -- local function ON_REQ_BASE_INFO()
    -- self:RequestLoginVerify()
    -- end
    -- self.model:AddListener(WakeModel.REQ_BASE_INFO, ON_REQ_BASE_INFO)
    local function call_back()
        local wake = RoleInfoModel:GetInstance():GetRoleValue("wake") or 0
        local level = RoleInfoModel:GetInstance():GetMainRoleLevel() or 0
        local career = RoleInfoModel:GetInstance():GetRoleValue("career") or 0
        local key = career .. "@" .. (wake + 1)
        local next_wake_item = Config.db_wake[key]
        if next_wake_item then
            local open_level = next_wake_item.open_level
            if level >= open_level and OpenTipModel.GetInstance():IsOpenSystem(600, 1) and wake <= 5 then
                
                if wake <= 3 then
                    --前四次觉醒
                    lua_panelMgr:GetPanelOrCreate(WakePanel):Open()
                elseif wake == 4  then
                    --五次觉醒
                    local panel = lua_panelMgr:GetPanelOrCreate(WakeTwoPanel)
                    panel:Open()

                    local data = {}
                    panel:SetData(data)
                elseif wake == 5  then
                    --六次觉醒
                    local panel = lua_panelMgr:GetPanelOrCreate(WakeThreePanel)
                    panel:Open()

                    local data = {}
                    
                    panel:SetData(data)
                end
                
             
            else
                Notify.ShowText("Awakening function unavailable for now")
            end
        else
            Notify.ShowText("Awakening finished")
        end
    end
    GlobalEvent:AddListener(WakeEvent.OpenWakePanel, call_back)

    local function call_back()
        self:UpdateIcon()
    end
    GlobalEvent:AddListener(MainEvent.CheckLoadMainIcon, call_back)
    RoleInfoModel:GetInstance():GetMainRoleData():BindData("wake", call_back)
    RoleInfoModel:GetInstance():GetMainRoleData():BindData("level", call_back)
    GlobalEvent:AddListener(TaskEvent.GlobalUpdateTask, call_back)

    local function call_back()
        self:Strongger()
    end
    GlobalEvent:AddListener(BagEvent.UpdateGoods, call_back)
    --GlobalEvent:AddListener(GoodsEvent.UpdateNum, call_back)
    --GlobalEvent:AddListener(GoodsEvent.DelItems, call_back)
    --GlobalEvent:AddListener(BagEvent.AddItems, call_back)
end

function WakeController:UpdateIcon()
    local wake = RoleInfoModel:GetInstance():GetRoleValue("wake") or 0
    local level = RoleInfoModel:GetInstance():GetMainRoleLevel() or 0
    local career = RoleInfoModel:GetInstance():GetRoleValue("career") or 0
    local key = career .. "@" .. (wake + 1)
    local next_wake_item = Config.db_wake[key]
    if next_wake_item then
        local open_level = next_wake_item.open_level
        --等级满足下一觉醒的要求 显示图标
        if level >= open_level and OpenTipModel.GetInstance():IsOpenSystem(600, 1) and wake <= 5 then
            GlobalEvent:Brocast(MainEvent.ChangeRightIcon, "wake", true)
            local show_reddot = false
            if level >= next_wake_item.level and self.model:IsHaveWakeTask() then
                show_reddot = true
            end
            GlobalEvent:Brocast(MainEvent.ChangeRedDot, "wake", show_reddot)
        else
            GlobalEvent:Brocast(MainEvent.ChangeRightIcon, "wake", false)
        end
    else
        GlobalEvent:Brocast(MainEvent.ChangeRightIcon, "wake", false)
    end
	self:Strongger()
end

-- overwrite
function WakeController:GameStart()
    self:RequestWakeTask()
    GlobalSchedule:StartOnce(handler(self, self.UpdateIcon), Constant.GameStartReqLevel.Low)
end

----请求基本信息
function WakeController:RequestWakeInfo()
    local pb = self:GetPbObject("m_wake_info_tos")
    self:WriteMsg(proto.WAKE_INFO, pb)
end

----服务的返回信息
function WakeController:HandleWakeInfo()
    self.model:SetWakeTimes(data.wake_times)
    self.model:Brocast(WakeEvent.UpdateWakeTimes)
end

--请求获取觉醒任务进度
function WakeController:RequestWakeTask()
    local pb = self:GetPbObject("m_wake_task_tos")
    self:WriteMsg(proto.WAKE_TASK, pb)
end

function WakeController:HandleWakeTask()
    local data = self:ReadMsg("m_wake_task_toc")
    self.model:SetWakeStep(data.cur_step)
    self.model:UpdateWakeTasks(data.tasks)

    self.model:Brocast(WakeEvent.UpdateWakeTasks)
end

--请求点亮星座格子
function WakeController:RequestActiveGrid(grid_id)
    local pb = self:GetPbObject("m_wake_active_grid_tos")
    pb.grid_id = grid_id
    self:WriteMsg(proto.WAKE_ACTIVE_GRID, pb)
end


function WakeController:HandleActiveGrid()
    local data = self:ReadMsg("m_wake_active_grid_toc")
    self.model:UpdateWakeGrid(data.grid_id)

    self.model:Brocast(WakeEvent.UpdateWakeGrid)
end

--请求获取已点亮格子的进度
function WakeController:RequestWakeGrid()
    local pb = self:GetPbObject("m_wake_get_grids_tos")
    self:WriteMsg(proto.WAKE_GET_GRIDS, pb)
end

function WakeController:HandleWakeGrid()
    local data = self:ReadMsg("m_wake_get_grids_toc")
    self.model:UpdateWakeGrid(data.grid_id)

    self.model:Brocast(WakeEvent.UpdateWakeGrid)
end

--请求进入下一阶段
function WakeController:RequestGoNextStep()
    local pb = self:GetPbObject("m_wake_next_step_tos")
    self:WriteMsg(proto.WAKE_NEXT_STEP, pb)
end

function WakeController:HandleGoNextStep()
    local data = self:ReadMsg("m_wake_next_step_toc")

    self.model:Brocast(WakeEvent.HandleGoNextStep)
end

--请求觉醒
function WakeController:RequestWakeStart(wake_type)
    wake_type = wake_type or 0
    local pb = self:GetPbObject("m_wake_start_tos")
    pb.wake_type = wake_type
    self:WriteMsg(proto.WAKE_START, pb)
end

function WakeController:HandleWakeStart()
    local data = self:ReadMsg("m_wake_start_toc")
    self.model:Brocast(WakeEvent.WakeSuccess)
    --Notify.ShowText("觉醒成功")
    lua_panelMgr:GetPanelOrCreate(WakeResultPanel):Open()
end

function WakeController:Strongger()
    local show_reddot = self.model:IsCanStrong()
    GlobalEvent:Brocast(MainEvent.ChangeRedDot, "wake", show_reddot)
    GlobalEvent:Brocast(MainEvent.ChangeSystemShowInStronger, 14, show_reddot)
    local show_task_red = self.model:IsMainHaveRedDot()
    GlobalEvent:Brocast(WakeEvent.UpdateTaskRed, show_task_red)
end