--
-- @Author: LaoY
-- @Date:   2019-01-03 16:49:10
--
require('game.activity.RequireActivity')

ActivityController = ActivityController or class("ActivityController", BaseController)

function ActivityController:ctor()
    ActivityController.Instance = self
    self.model = ActivityModel:GetInstance()
    self:AddEvents()
    self:RegisterAllProtocal()
end

function ActivityController:dctor()
end

function ActivityController:GetInstance()
    if not ActivityController.Instance then
        ActivityController.new()
    end
    return ActivityController.Instance
end

function ActivityController:RegisterAllProtocal()
    -- protobuff的模块名字，用到pb一定要写
    self.pb_module_name = "pb_1600_activity_pb"
    self:RegisterProtocal(proto.ACTIVITY_START, self.HandleStartActivity)
    self:RegisterProtocal(proto.ACTIVITY_STOP, self.HandleStopActivity)
    self:RegisterProtocal(proto.ACTIVITY_PREDICT, self.HandlePredictActivity)
    self:RegisterProtocal(proto.ACTIVITY_PREDICT, self.HandlePredictActivity)
    self:RegisterProtocal(proto.ACTIVITY_LIST, self.HandleActivityList)
    self:RegisterProtocal(proto.ACTIVITY_ALL, self.HandleAllList)
end

function ActivityController:AddEvents()
    -- --请求基本信息
    -- local function ON_REQ_BASE_INFO()

    -- end
    -- self.model:AddListener(ActivityEvent.REQ_PORTO, ON_REQ_BASE_INFO)
end

-- overwrite
function ActivityController:GameStart()
    local function step()
        self:RequestActivityList()
    end
    self.time_id = GlobalSchedule:StartOnce(step, Constant.GameStartReqLevel.Low)
end

--请求 
function ActivityController:RequestActivityList()
    -- local pb = self:GetPbObject("m_activity_list_tos")
    self:WriteMsg(proto.ACTIVITY_LIST)
end

--返回 
function ActivityController:HandleActivityList()
    local data = self:ReadMsg("m_activity_list_toc")
    self.model:AddActivityList(data.activities)
end

--返回 
function ActivityController:HandleStartActivity()
    local data = self:ReadMsg("m_activity_start_toc")
    self.model:AddActivity(data)
end

--返回
function ActivityController:HandleStopActivity()
    local data = self:ReadMsg("m_activity_stop_toc")
    self.model:RemoveActivity(data.id)
end

--返回 
function ActivityController:HandlePredictActivity()
    local data = self:ReadMsg("m_activity_predict_toc")
    local cf = Config.db_activity[data.id]
    if cf then
        if not data.etime then
            data.etime = data.stime + cf.pre
        end
        GlobalEvent:Brocast(MainEvent.ChangeLeftIcon, cf.key, true, data.id, data.stime, data.etime, true)
    end
    self.model.predict_list[data.id] = data
    GlobalEvent:Brocast(ActivityEvent.PredictActivity, data.id)
end

function ActivityController:RequsetAllActList()
    self:WriteMsg(proto.ACTIVITY_ALL)
end

function ActivityController:HandleAllList()
    local data = self:ReadMsg("m_activity_all_toc")
    GlobalEvent:Brocast(ActivityEvent.DiliverAllActivity, data.activities)
end