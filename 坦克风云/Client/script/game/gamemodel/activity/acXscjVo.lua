acXscjVo=activityVo:new()

function acXscjVo:updateSpecialData(data)
   -- 配置
    if data._activeCfg then
        self.activeCfg=data._activeCfg
    end

    if data.r then
    	self.alreadyT=data.r
    end
end