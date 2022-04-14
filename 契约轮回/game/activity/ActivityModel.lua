--
-- @Author: LaoY
-- @Date:   2019-01-03 16:49:59
--
ActivityModel = ActivityModel or class("ActivityModel", BaseModel)

function ActivityModel:ctor()
    ActivityModel.Instance = self
    self:Reset()
end

function ActivityModel:Reset()
    self.act_list = {}
    self.predict_list = {}
end

function ActivityModel.GetInstance()
    if ActivityModel.Instance == nil then
        ActivityModel()
    end
    return ActivityModel.Instance
end

function ActivityModel:AddActivityList(list)
    for k, data in pairs(list) do
        if data.state ~= 1 then
            self:AddActivity(data)
        else
            local cf = Config.db_activity[data.id]
            if cf then
                GlobalEvent:Brocast(MainEvent.ChangeLeftIcon, cf.key, true, data.id, data.stime, data.etime, true)
            end
            self.predict_list[data.id] = data
            GlobalEvent:Brocast(ActivityEvent.PredictActivity, data.id)
        end

    end
end

function ActivityModel:AddActivity(data)
    local cf = Config.db_activity[data.id]
    if cf then
        GlobalEvent:Brocast(MainEvent.ChangeLeftIcon, cf.key, true, data.id, data.stime, data.etime, false)
    end
    self.act_list[data.id] = data
    GlobalEvent:Brocast(ActivityEvent.ChangeActivity, true, data.id, data.stime, data.etime)
end

function ActivityModel:RemoveActivity(id)
    local cf = Config.db_activity[id]
    if cf then
        GlobalEvent:Brocast(MainEvent.ChangeLeftIcon, cf.key, false, id)
    end
    self.act_list[id] = nil
    GlobalEvent:Brocast(ActivityEvent.ChangeActivity, false, id)
end

--活动是否开启
function ActivityModel:GetActivity(id)
    return self.act_list[id]
end

--根据场景id获取活动id
function ActivityModel:GetActId(scene_id)
    for k, v in pairs(Config.db_activity) do
        if v.scene == scene_id then
            return v.id
        end
    end
    return 0
end