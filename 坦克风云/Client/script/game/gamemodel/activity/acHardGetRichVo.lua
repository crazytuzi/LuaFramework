acHardGetRichVo=activityVo:new()
function acHardGetRichVo:new()
    local nc={}
    setmetatable(nc,self)
    self.__index=self
    return nc
end

function acHardGetRichVo:updateSpecialData(data)
    self.acEt=self.et-86400
    for k,v in pairs(data) do
        print("acHardGetRichVo:updateSpecialData=",k,v)
    end
    --{"v":0,"type":1,"c":0,"t":0}
    --活动期间资源采集倍数
    if data.v then
    	self.Multiple=data.v
    end
    --玩家采集资源
    if data.res and data.res~=0 then
        self.res={gold=0,r1=0,r2=0,r3=0,r4=0}
    	self.res=data.res
    end

    
    --玩家个人目标领奖
    if data.t and data.t~=0 then
        self.pReward={}
        self.pReward=data.t
    end

    if data.r then
        self.rReward=data.r
    end
    if data.rankreward then
        self.rankreward=data.rankreward
    end
    if data.personreward then
        self.personreward=data.personreward
    end
    
    if data.personalGoal then
        activityCfg.hardGetRich.personalGoal=data.personalGoal
    end
    if data.version then
        self.version =data.version
    end
end


