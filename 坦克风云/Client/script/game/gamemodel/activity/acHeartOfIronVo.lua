acHeartOfIronVo=activityVo:new()
function acHeartOfIronVo:new()
	local nc={}
	setmetatable(nc,self)
	self.__index=self

    self.taskTab={}
    self.changeday=0
    self.hadReward={}
    self.reward={}

	return nc
end

function acHeartOfIronVo:updateSpecialData(data)
    -- if data.condition then
    --     for k,v in pairs(data.condition) do
    --         if v and tonumber(v[1]) and tonumber(v[2]) then
    --             self.condition[tonumber(v[2])]={type=k,num=tonumber(v[1])}
    --         end  
    --     end
    -- end
    if data.v then
        for k,v in pairs(data.v) do
            local isReward=0
            if data.t then
                if type(data.t)=="table" then
                    if data.t[k] then
                        isReward=data.t[k] or 0
                    end
                end
            end
            if v and tonumber(v[1]) and tonumber(v[2]) then
                if v[3] and tonumber(v[3]) then
                    self.taskTab[tonumber(v[2])]={type=k,cfgNum=tonumber(v[1]),num=tonumber(v[3]),isReward=isReward}
                else
                    self.taskTab[tonumber(v[2])]={type=k,cfgNum=tonumber(v[1]),num=0,isReward=isReward}
                end
            end  
        end
    end
    -- if data.t then
    --     if type(data.t)=="table" then
    --         self.hadReward=data.t
    --     end
    -- end
    if data.changeday then
        self.changeday=data.changeday
    end
    if data.reward then
        local rewardCfg={}
        for k,v in pairs(data.reward) do
            local award=FormatItem(v,nil,true)
            table.insert(rewardCfg,award)
        end
        self.reward=rewardCfg
    end

    if self.changeday>0 then
        local regdate=playerVoApi:getRegdate()
        local regZeroTs=G_getWeeTs(regdate)
        local dayNum=math.ceil((base.serverTime-regZeroTs)/(3600*24))
        if dayNum-1>self.changeday then
            self.over = true
        else
            self.over = false
        end
    end

end
