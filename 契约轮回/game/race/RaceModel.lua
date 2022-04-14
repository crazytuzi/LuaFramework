RaceModel = RaceModel or class('RaceModel',BaseModel)

function RaceModel:ctor()
    RaceModel.Instance = self

    self:Reset()

end

function RaceModel:Reset()

    self.race_roles = {}  --竞赛玩家列表
    self.player_uid = -10001
    self.robot_1_uid = -10002
    self.robot_2_uid = -10003

    self.best_record = nil  --最佳时间

    self.enter_times = nil  --总的累计进入次数
    self.rest_time = nil  --当前活动期间的剩余进入次数

    self.arrows = {}
    self.arrows[1] = "left"
    self.arrows[2] = "right"
    self.arrows[3] = "up"
    self.arrows[4] = "down"
    self.arrows.left = 1
    self.arrows.right = 2
    self.arrows.up = 3
    self.arrows.down = 4

    self.conmand_cfgs = {}
    for k,v in ipairs(Config.db_dunge_race_conmand) do
        local times = String2Table(v.times)

        self.conmand_cfgs[k] = v
        self.conmand_cfgs[k].min_time = times[1]
        self.conmand_cfgs[k].max_time = times[2]
    end
    
    --是否再来一次
    self.is_replay = false

    --机甲竞速任务id 为nil表示当前不是由任务进入的
    self.task_id = nil

    self.is_matching = false --是否匹配中

    self.is_active_open = true  --活动是否已开启
end

function RaceModel.GetInstance()
    if RaceModel.Instance == nil then
        RaceModel.new()
    end
    return RaceModel.Instance
end

--是否为竞速场景
function RaceModel:IsRaceScene(scene_id)
    return scene_id == 90001
end