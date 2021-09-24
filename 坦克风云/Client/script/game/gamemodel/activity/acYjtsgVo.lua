acYjtsgVo=activityVo:new()

function acYjtsgVo:updateSpecialData(data)
   -- 配置
    if data._activeCfg then
        self.activeCfg=data._activeCfg
    end
    -- 数据
    if data.ls~=nil then
        self.rate= data.ls
    end
    if data.t then
        self.lastTime =data.t
    end
    if data.v then
        self.free= data.v
    end

    if data.l then
        self.l = data.l 
    end
    if data.f then
        self.vipHadNum = data.f
    end
end