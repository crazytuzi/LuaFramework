-- 打雪仗活动
--hzf

SnowBallManager = SnowBallManager or BaseClass(BaseManager)

function SnowBallManager:__init()
    if SnowBallManager.Instance then
        Log.Error("不可以对单例对象重复实例化")
        return
    end
    SnowBallManager.Instance = self
    self.model = SnowBallModel.New(self)
    self.status = 0
    EventMgr.Instance:AddListener(event_name.match_status_change, function()
        if MatchManager.Instance.currid == 1000 and MatchManager.Instance.status == MatchStatus.Matching then
            self:OnBeginMatch()
        elseif MatchManager.Instance.currid == 1000 and MatchManager.Instance.status == MatchStatus.Matchend then
            self:OnMatchOK()
        end
    end)
    self:InitHandler()
end

function SnowBallManager:__delete()
    self.model:DeleteMe()
    self.model = nil
end

function SnowBallManager:InitHandler()

end

function SnowBallManager:ReqOnConnect()
    MatchManager.Instance:Require18306(1000)
    MatchManager.Instance:Require18307(1000)
end

function SnowBallManager:OnBeginMatch()
    self.model.match_time = Time.time
end

function SnowBallManager:OnMatchOK()
    self.model.match_time = Time.time+5
end