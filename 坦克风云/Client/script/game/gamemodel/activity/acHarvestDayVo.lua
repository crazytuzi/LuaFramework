acHarvestDayVo=activityVo:new()
function acHarvestDayVo:new()
    local nc={}
    setmetatable(nc,self)
    self.__index=self

    
    self.bidRewardNum=0     --投拍前10名已经领奖次数
    self.bidCanRewardNum=0  --投拍前10名可以领奖次数
    self.warRewardNum=0     --参战已经领奖次数
    self.warCanRewardNum=0  --参战可以领奖次数
    self.vicRewardNum=0     --胜利已经领奖次数
    self.vicCanRewardNum=0  --胜利可以领奖次数

    self.bidRank=10         --投拍前多少名可以领奖
    self.maxRewardTab={0,0,0}  --{投拍最多领奖次数,参战最多领奖次数,胜利最多领奖次数}

    return nc
end

function acHarvestDayVo:updateSpecialData(data)
    --  self.acEt=self.et-86400

    if data then
        if data.numconfig and SizeOfTable(data.numconfig)>0 then
            self.maxRewardTab=data.numconfig[1] or {0,0,0}
            self.bidRank=tonumber(data.numconfig[2]) or 0
        end
        if data.t then
            self.bidCanRewardNum=tonumber(data.t) or 0
            if self.bidCanRewardNum<0 then
                self.bidCanRewardNum=0
            end
            if self.bidCanRewardNum>self.maxRewardTab[1] then
                self.bidCanRewardNum=self.maxRewardTab[1]
            end
        end
        if data.v then
            self.warCanRewardNum=tonumber(data.v) or 0
            if self.warCanRewardNum<0 then
                self.warCanRewardNum=0
            end
            if self.warCanRewardNum>self.maxRewardTab[2] then
                self.warCanRewardNum=self.maxRewardTab[2]
            end
        end
        if data.c then
            self.vicCanRewardNum=tonumber(data.c) or 0
            if self.vicCanRewardNum<0 then
                self.vicCanRewardNum=0
            end
            if self.vicCanRewardNum>self.maxRewardTab[3] then
                self.vicCanRewardNum=self.maxRewardTab[3]
            end
        end
        if data.r then
            if data.r.t then
                self.bidRewardNum=tonumber(data.r.t) or 0
                if self.bidRewardNum<0 then
                    self.bidRewardNum=0
                end
                if self.bidRewardNum>self.maxRewardTab[1] then
                    self.bidRewardNum=self.maxRewardTab[1]
                end
            end
            if data.r.v then
                self.warRewardNum=tonumber(data.r.v) or 0
                if self.warRewardNum<0 then
                    self.warRewardNum=0
                end
                if self.warRewardNum>self.maxRewardTab[2] then
                    self.warRewardNum=self.maxRewardTab[2]
                end
            end
            if data.r.c then
                self.vicRewardNum=tonumber(data.r.c) or 0
                if self.vicRewardNum<0 then
                    self.vicRewardNum=0
                end
                if self.vicRewardNum>self.maxRewardTab[3] then
                    self.vicRewardNum=self.maxRewardTab[3]
                end
            end 
        end
    end

end


