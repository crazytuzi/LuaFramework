acFightRanknewVo=activityVo:new()

function acFightRanknewVo:initRefresh()
    -- 以下三个变量一起使用
    self.needRefresh = true -- 活动结束后是否需要刷新数据（比如排行结束后）
    self.refresh = false -- 活动结束后是否已刷新过数据
end

function acFightRanknewVo:updateSpecialData(data)
    self.acEt = self.acEt - 86400

    self.refreshTs = self.et - 86400 -- 刷新时间（比如排行结束时间）

    if data and data.maxRank then
	    self.maxRank=data.maxRank
	end
end