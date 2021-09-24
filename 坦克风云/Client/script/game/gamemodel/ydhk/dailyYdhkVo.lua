-- @Author hj
-- @Date 2018-12-12
-- @Description 月度回馈数据处理模型

dailyYdhkVo = dailyActivityVo:new()

function dailyYdhkVo:canReward()
    return dailyYdhkVoApi:canReward()
end

function dailyYdhkVo:dispose()
    dailyYdhkVoApi:clear()
end

function dailyYdhkVo:updateData(data)
    if data and data.monthgive then
        
        -- 总花费
        if data.monthgive.cost then
            self.cost = data.monthgive.cost
        end
        -- 领取日志
        if data.monthgive.log then
            self.log = data.monthgive.log
        end
        -- 当前领取总金币
        if data.monthgive.reward then
            self.reward = data.monthgive.reward
        end
        -- 单日金币
        if data.monthgive.dreward then
            self.dreward = data.monthgive.dreward
        end
        -- 消耗金币对应的月末时间
        if data.monthgive.cts then
            self.cts = data.monthgive.cts
        end
        -- 上次消耗金币对应的月末时区
        if data.monthgive.ctz then
            self.ctz = data.monthgive.ctz
        end
        -- 上次领奖对应的时区
        if data.monthgive.rtz then
            self.rtz = data.monthgive.rtz
        end
        -- 上次领奖时间
        if data.monthgive.rts then
            self.rts = data.monthgive.rts
        end
    end
end
