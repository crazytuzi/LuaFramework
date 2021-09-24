acWsjdzzIIVo=activityVo:new()

function acWsjdzzIIVo:updateSpecialData(data)
    -- 配置
    if data._activeCfg then
        if data._activeCfg.taskList then
            self.taskList=data._activeCfg.taskList
        end
        if data._activeCfg.cost then
            self.cost=data._activeCfg.cost
        end
        if data._activeCfg.bossLife then
            self.bossLife=data._activeCfg.bossLife
        end
        if data._activeCfg.pumpkinLife then
            self.pumpkinLife=data._activeCfg.pumpkinLife
        end
        if data._activeCfg.noticeNum then
            self.noticeNum=data._activeCfg.noticeNum
        end
        if data._activeCfg.version then
            self.version=tonumber(data._activeCfg.version)
        end
        if data._activeCfg.reward then
            self.reward=data._activeCfg.reward
        end
        if data._activeCfg.map then
            self.map2=data._activeCfg.map
        end
        if data._activeCfg.mapRows then
            self.mapRows=data._activeCfg.mapRows
        end
    end

    -- 数据
    if data.t then
    	self.lastTime=data.t
    end
    if data.l then
    	self.curBossLife=data.l
    end
    if data.r then
    	self.taskData=data.r
    end
    if data.f then
    	self.rewardData=data.f
    end
    if data.m then
    	self.map=data.m
    end
    if data.log then
        self.log=data.log
    end
end