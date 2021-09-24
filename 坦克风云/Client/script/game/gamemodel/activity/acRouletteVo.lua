acRouletteVo=activityVo:new()
function acRouletteVo:new()
    local nc={}
    setmetatable(nc,self)
    self.__index=self
    return nc
end

function acRouletteVo:updateSpecialData(data)
    -- self.rankList=data["list"]          --排行榜
    -- self.point=data["point"]            --个人的物资点数
    -- self.consume=data["consume"]        --今日消费额度
    -- self.rewardList=data["rewards"]     --奖池中的奖励物品
    -- self.chips=data["chips"]            --今日剩余可抽奖次数
    print("daaaate",data.version)
    self.acEt=self.et-86400

    --今日消费额度
    if self.consume==nil then
    	self.consume=0
    end
    if data.un then
    	self.consume=tonumber(data.un) or 0
    end
    
    if data.version  then
        self.version =data.version
    end

    -- if self.cfg == nil then
    --     self.cfg ={}
    -- end
    if data.reward then
        self.cfg =data.reward or {}
    end

    --今日已经抽奖次数
    if self.hasUsedNum==nil then
    	self.hasUsedNum=0
    end
    if data.c then
    	self.hasUsedNum=tonumber(data.c) or 0
    end

    --上次抽奖时间的凌晨时间戳
    if self.lastTime==nil then
    	self.lastTime=0
    end
    if data.t then
    	self.lastTime=tonumber(data.t) or 0
    end

    --排行榜领奖次数
    if self.listRewardNum==nil then
        self.listRewardNum=0
    end
    if data.rr then
        self.listRewardNum=tonumber(data.rr) or 0
    end
    
    --今日的物资点数
    if self.point==nil then
    	self.point=0
    end
    --今日已经用掉的免费抽奖次数
    if self.hasUsedFreeNum==nil then
    	self.hasUsedFreeNum=0
    end
    --今日用物资领奖次数
    if self.pointRewardNum==nil then
    	self.pointRewardNum=0
    end
    if data.d then
    	if data.d.point then
    		self.point=tonumber(data.d.point) or 0
    	end
    	if data.d.fn then
    		self.hasUsedFreeNum=tonumber(data.d.fn) or 0
    	end
    	if data.d.fr then
    		self.pointRewardNum=tonumber(data.d.fr) or 0
    	end
    end

    local function sortAsc(a, b)
        if tonumber(a[4]) and tonumber(b[4]) then
            if tonumber(a[4])==tonumber(b[4]) then
                if tonumber(a[3]) and tonumber(b[3]) then
                    return tonumber(a[3]) > tonumber(b[3])
                end
            else
                return tonumber(a[4]) > tonumber(b[4])
            end
        else
            if tonumber(a[3]) and tonumber(b[3]) then
                return tonumber(a[3]) > tonumber(b[3])
            end
        end
    end

    --总物资点数
    if self.totalPoint==nil then
        self.totalPoint=0
    end
    if data.point then
        self.totalPoint=tonumber(data.point) or 0
        if self.rankList and SizeOfTable(self.rankList)>0 then
            for k,v in pairs(self.rankList) do
                if v and SizeOfTable(v)>0 and v[1] and tostring(v[1])==tostring(playerVoApi:getPlayerName()) then
                    self.rankList[k][1]=playerVoApi:getPlayerName()
                    self.rankList[k][2]=playerVoApi:getPlayerLevel()
                    self.rankList[k][3]=playerVoApi:getPlayerPower()
                    self.rankList[k][4]=self.totalPoint or 0
                end
            end
            if self.rankList and SizeOfTable(self.rankList)>0 then
                table.sort(self.rankList,sortAsc)
            end
        end
    end

    --排行榜
    if self.rankList==nil then
    	self.rankList={}
    end
    if data.rankList then
    	self.rankList=data.rankList
    	for k,v in pairs(self.rankList) do
    		if v and SizeOfTable(v)>0 and v[1] and tostring(v[1])==tostring(playerVoApi:getPlayerName()) then
				self.rankList[k][1]=playerVoApi:getPlayerName()
				self.rankList[k][2]=playerVoApi:getPlayerLevel()
				self.rankList[k][3]=playerVoApi:getPlayerPower()
				self.rankList[k][4]=self.totalPoint or 0
			end
    	end
    	if self.rankList and SizeOfTable(self.rankList)>0 then
			table.sort(self.rankList,sortAsc)
    	end
    end


    if self.lastTime and G_isToday(self.lastTime)==false then
        self.consume=0
        self.hasUsedNum=0
        self.point=0
        self.hasUsedFreeNum=0
        self.pointRewardNum=0
    end


end


