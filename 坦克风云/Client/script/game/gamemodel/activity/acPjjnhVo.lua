acPjjnhVo=activityVo:new()

function acPjjnhVo:new()
	local nc={}
	setmetatable(nc,self)
	self.__index=self
	return nc
end

function acPjjnhVo:updateSpecialData(data)
    if data then
    	if data.t then
	      self.lastTime=data.t
	    end
    	if data.cost1 then
    		self.cost1=data.cost1
    	end
    	if data.cost2 then
    		self.cost2=data.cost2
    	end
        if data.task then
            self.task = data.task
        end
        if data.l then
            self.l=data.l
        end
        if data.f then
            self.f=data.f
        end
        if data.t1 then -- t1任务次数
            self.t1=data.t1
        end
        if data.t2 then
            self.t2=data.t2
        end
        if data.t3 then
            self.t3=data.t3
        end
        if data.tr then --當天任務領取過獎勵的id  配置中的id 不是任務id
            self.tr=data.tr
        end
        if data.rlog then
            self.rlog=data.rlog
        end
        if data.flickReward then -- 大奖，需要加闪框(对应奖池的index)
            self.flickReward=data.flickReward
        end

        if data.version then
            self.version =data.version
        end
        -- if data.bgImg then
        --     self.bgImg=data.bgImg
        -- end
        -- if data.acIcon then
        --     self.acIcon=data.acIcon
        -- end
        
        -- if data.nameType then
        --     self.nameType=data.nameType
        -- end

    end
end