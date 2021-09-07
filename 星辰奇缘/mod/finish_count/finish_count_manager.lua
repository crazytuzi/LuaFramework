------------------
--结算系统统一逻辑
------------------
FinishCountManager = FinishCountManager or BaseClass(BaseManager)

function FinishCountManager:__init()
    if FinishCountManager.Instance then
        Log.Error("不可以对单例对象重复实例化")
    end
    FinishCountManager.Instance = self;
    self:InitHandler()
    self.timer_id = 0
    self.model = FinishCountModel.New()
end

function FinishCountManager:__delete()
    self.model:DeleteMe()
    self.model = nil
end

function FinishCountManager:InitHandler()

end
