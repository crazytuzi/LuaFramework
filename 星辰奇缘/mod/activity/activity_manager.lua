--活动管理器
ActivityManager = ActivityManager or BaseClass(BaseManager)

function ActivityManager:__init()
    if ActivityManager.Instance then
        Log.Error("不可以对单例对象重复实例化")
    end
    ActivityManager.Instance = self;
    self.model = ActivityModel.New()
    self:InitHandler()
end

function ActivityManager:__delete()
    self.model:DeleteMe()
    self.model = nil
end

--初始化活动提示状态
function ActivityManager:InitHandler()
    self:InitNoticeState()
end

--初始化活动提示状态
function ActivityManager:InitNoticeState()
    self.model.activity_notice_states[GlobalEumn.ActivityEumn.fairy] = false
    self.model.activity_notice_states[GlobalEumn.ActivityEumn.para] = false
    self.model.activity_notice_states[GlobalEumn.ActivityEumn.qualify] = false
    self.model.activity_notice_states[GlobalEumn.ActivityEumn.warrior] = false
    self.model.activity_notice_states[GlobalEumn.ActivityEumn.classes] = false
    self.model.activity_notice_states[GlobalEumn.ActivityEumn.exam] = false
    self.model.activity_notice_states[GlobalEumn.ActivityEumn.top_compete] = false
    self.model.activity_notice_states[GlobalEumn.ActivityEumn.pet_love] = false
    self.model.activity_notice_states[GlobalEumn.ActivityEumn.guild_siege] = false
    self.model.activity_notice_states[GlobalEumn.ActivityEumn.ingot_crash] = false
    self.model.activity_notice_states[GlobalEumn.ActivityEumn.guild_dragon] = false

    self.model.notice_state_times[GlobalEumn.ActivityEumn.fairy] = BaseUtils.BASE_TIME
    self.model.notice_state_times[GlobalEumn.ActivityEumn.para] = BaseUtils.BASE_TIME
    self.model.notice_state_times[GlobalEumn.ActivityEumn.qualify] = BaseUtils.BASE_TIME
    self.model.notice_state_times[GlobalEumn.ActivityEumn.warrior] = BaseUtils.BASE_TIME
    self.model.notice_state_times[GlobalEumn.ActivityEumn.classes] = BaseUtils.BASE_TIME
    self.model.notice_state_times[GlobalEumn.ActivityEumn.exam] = BaseUtils.BASE_TIME
    self.model.notice_state_times[GlobalEumn.ActivityEumn.top_compete] = BaseUtils.BASE_TIME
    self.model.notice_state_times[GlobalEumn.ActivityEumn.pet_love] = BaseUtils.BASE_TIME
    self.model.notice_state_times[GlobalEumn.ActivityEumn.guild_siege] = BaseUtils.BASE_TIME
    self.model.notice_state_times[GlobalEumn.ActivityEumn.ingot_crash] = BaseUtils.BASE_TIME
    self.model.notice_state_times[GlobalEumn.ActivityEumn.guild_dragon] = BaseUtils.BASE_TIME
end

--记录活动提示状态
function ActivityManager:MarkNoticeState(activity, state)
    if state == nil then
        self.model.activity_notice_states[activity] = true
    else
        self.model.activity_notice_states[activity] = state
    end
end

--获取活动提示状态
function ActivityManager:GetNoticeState(activity)
    local last_time = self.model.notice_state_times[activity]
    local time_gap = BaseUtils.BASE_TIME - last_time
    if time_gap < 86400 then
        --一天之内
        return self.model.activity_notice_states[activity]
    else
        --超过一天
        self.model.notice_state_times[activity] = BaseUtils.BASE_TIME
        return false
    end
end

function ActivityManager:StopNotice(activity)
    if self.model.notice_timer[activity] ~= nil then
        LuaTimer.Delete(self.model.notice_timer[activity])
        self.model.notice_timer[activity] = nil
    end
end

