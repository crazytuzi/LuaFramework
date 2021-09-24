acZncfVo=activityVo:new()
function acZncfVo:new()
	local nc={}
	setmetatable(nc,self)
	self.__index=self

	return nc
end

function acZncfVo:updateSpecialData(data)
    if data~=nil then
        if data._activeCfg then
            if data._activeCfg.version then
                self.version = data._activeCfg.version
            end
        end
        if not self.version then
            self.version = 1
        end
        if activityCfg.zncf then
           self.activeCfg = activityCfg.zncf[self.version]
           --开启等级
           self.openLv = self.activeCfg.openLv
           --使用随机语句的系统
           self.desc = self.activeCfg.desc
            --超越百分比范围对应第1-3个随机描述语句
           self.descType = self.activeCfg.descType
            --每日登陆奖励reward 前端奖励；severreward 后端奖励
           self.dailyReward = self.activeCfg.dailyReward
           self.rewardList = self.activeCfg.rewardList

       end
        if data.f then
            self.firstFree = data.f
        end
        -- if data.t then --上次抽奖的时间，用于跨天重置免费次数
        --     self.lastTime=data.t
        -- end
        -- if data.c then
        --     self.rewardFlag = data.c
        -- end

        if data.login and SizeOfTable(data.login) > 0 then
            self.lastTime = data.login[1] --每日登陆领奖时间戳
            self.rewardFlag = data.login[2]--每日领取奖励的标识 1:今日已领取
        end

        if data.rtd then--统计数据
            self.rtd = data.rtd
        end
        
        if data.rdb then--任务领取记录表
            self.rdb = data.rdb
        end

    end
end