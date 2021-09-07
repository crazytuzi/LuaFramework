--活动model
ActivityModel = ActivityModel or BaseClass(BaseModel)

function ActivityModel:__init()
    self.notice_state_times = {}
    self.notice_timer = {}
    self.activity_notice_states = {}
end

function ActivityModel:__delete()

end