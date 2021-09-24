acZjjzVo=activityVo:new()

function acZjjzVo:updateSpecialData(data)
   -- 配置
    if data._activeCfg then
        self.activeCfg=data._activeCfg
    end

    if data.t1 then -- 完成进度
    	self.t1=data.t1
    end
    if data.v then
    	self.v=data.v
    end
    if data.r2 then -- 领取
    	self.r2=data.r2
    end
    if data.r1 then
    	self.r1=data.r1
    end

end