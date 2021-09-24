acChunjiepanshengVo=activityVo:new()
function acChunjiepanshengVo:new()
	local nc={}
	setmetatable(nc,self)
	self.__index=self

	return nc
end

function acChunjiepanshengVo:updateSpecialData(data)
    if data~=nil then
        if data.version then
            self.version =data.version
        end
        -- 任务点
        if data.taskPoint then
            self.taskPoint =data.taskPoint
        end
        -- 任务点奖励
        if data.taskPointReward then
            self.taskPointReward =data.taskPointReward
        end
        -- 任务列表
        if data.taskList then
            self.taskList =data.taskList
        end
        -- 完成各个任务所得奖励
        if data.taskAllFinReward then
            self.taskAllFinReward =data.taskAllFinReward
        end

        -- 记录每天任务的完成情况，领取情况
        -- d1~dn 第几天
        -- tk 任务进度  tk = {aa = 1,bb = 1,},
        -- fin 任务领取标志  fin = {t1 = 1,t2 = 1,},
        -- gf = 1, 免费宝箱
        if data.day then
            self.day=data.day
        end

        -- 当前任务点数
        if data.n then
            self.myPoint=data.n
        end

        -- 任务点领取标志
        if data.tbox then
            self.tbox=data.tbox
        end

    end

end