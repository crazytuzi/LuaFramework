acRoulette4Vo=activityVo:new()
function acRoulette4Vo:new()
    local nc={}
    setmetatable(nc,self)
    self.__index=self
    return nc
end

function acRoulette4Vo:updateSpecialData(data)
    -- self.rankList=data["list"]          --排行榜
    -- self.point=data["point"]            --个人的物资点数
    -- self.consume=data["consume"]        --今日消费额度
    -- self.rewardList=data["rewards"]     --奖池中的奖励物品
    -- self.chips=data["chips"]            --今日剩余可抽奖次数
    -- self.acCfg=data["reward"]           --后台返回的活动配置

    -- "st": 1405306260, 
    -- "et": 1438346700, 
    -- "vip": 1, -- 为了统计vip用户（如果统计过了，则此值会大于0）
    -- "t": 1405440000, -- 重置后的时间(以此来判断是否过了凌晨，重置所有数据)
    -- "v": 0, 
    -- "c": 2, -- 当天使用过的次数
    -- "d": {
    --     "n": 9, -- 拥有的每日抽奖次数
    --     "superReward": {
    --         "props_p3": 1
    --     }, 
    --     "feed": 0, -- 分享获得的抽奖次数（如果此值有并且大于0表示分享过了，前台不要再调后台分享了）
    --     "fn": {"f1":1,"f2":1} --每日免费次数（有两次，如果没有领取，是空表，如果领取了会有值，在送免费次数时间内，有值的情况下，前台不要请求后台）
    --     "un":100 -- 充值的金币数（这个会直接折算成领奖次数，不够一次抽奖的剩余充值额度）
    -- }, 
    -- "type": 1

    -- "wheelFortune4": {
    --     "type": 1, 
    --     "startTime": {
    --         "f2": [
    --             14, 
    --             30
    --         ], 
    --         "f1": [
    --             11, 
    --             30
    --         ]
    --     }, 
    --     "propConsume": [
    --         "p212", 
    --         1
    --     ], 
    --     "lotteryConsume": 400, 
    --     "durationTime": 1800, 
    --     "sortID": 180, 
    --     "st": "1404355860", 
    --     "et": "1439124300", 
    --     "pool": {}
    -- }, 



    -- self.acEt=self.et-86400

    --后台返回的活动配置
    if self.acCfg==nil then
        self.acCfg={}
    end
    if data.startTime then
        self.acCfg.startTime=data.startTime or {}
    end
    if data.propConsume then
        self.acCfg.propConsume=data.propConsume or {}
    end
    if data.lotteryConsume then
        self.acCfg.lotteryConsume=data.lotteryConsume or {}
    end
    if data.durationTime then
        self.acCfg.durationTime=data.durationTime or 0
    end
    if data.pool then
        self.acCfg.pool=data.pool or {}
    end

    --今日消费额度
    -- if self.consume==nil then
    -- 	self.consume=0
    -- end
    -- if data.un then
    -- 	self.consume=tonumber(data.un) or 0
    -- end
    
    --今日已经抽奖次数
    if self.hasUsedNum==nil then
    	self.hasUsedNum=0
    end
    if data.c then
    	self.hasUsedNum=tonumber(data.c) or 0
    end

    --上次抽奖、充值时间的凌晨时间戳
    if self.lastTime==nil then
    	self.lastTime=0
    end
    if data.t then
    	self.lastTime=tonumber(data.t) or 0
    end

    --排行榜领奖次数
    -- if self.listRewardNum==nil then
    --     self.listRewardNum=0
    -- end
    -- if data.rr then
    --     self.listRewardNum=tonumber(data.rr) or 0
    -- end
    
    --今日的物资点数
    -- if self.point==nil then
    -- 	self.point=0
    -- end
    --今日已经用掉的免费抽奖
    if self.hasUsedFreeNum==nil then
    	self.hasUsedFreeNum={}
    end
    --今日用物资领奖次数
    -- if self.pointRewardNum==nil then
    -- 	self.pointRewardNum=0
    -- end

    if self.leftNum==nil then
        self.leftNum=0
    end
    if self.feedNum==nil then
        self.feedNum=0
    end
    if self.rechargeNum==nil then
        self.rechargeNum=0
    end
    if data.d then
    	-- if data.d.point then
    	-- 	self.point=tonumber(data.d.point) or 0
    	-- end
    	-- if data.d.fn then
    	-- 	self.hasUsedFreeNum=tonumber(data.d.fn) or 0
    	-- end
    	-- if data.d.fr then
    	-- 	self.pointRewardNum=tonumber(data.d.fr) or 0
    	-- end


        if data.d.n then
            self.leftNum=tonumber(data.d.n) or 0
        end
        if data.d.fn then
            self.hasUsedFreeNum=data.d.fn or {}
        end
        if data.d.feed then
            self.feedNum=tonumber(data.d.feed) or 0
        end
        if data.d.un then
            self.rechargeNum=tonumber(data.d.un) or 0
        end

    end

    local function sortAsc(a, b)
        if a and b then
            if a[3] and b[3] and tonumber(a[3]) and tonumber(b[3]) then
                if tonumber(a[3])==tonumber(b[3]) then
                    if tonumber(a[5]) and tonumber(b[5]) then
                        return tonumber(a[5]) > tonumber(b[5])
                    end
                else
                    return tonumber(a[3]) < tonumber(b[3])
                end
            else
                if a[5] and b[5] and tonumber(a[5]) and tonumber(b[5]) then
                    return tonumber(a[5]) > tonumber(b[5])
                end
            end
        end
    end

    --总物资点数
    -- if self.totalPoint==nil then
    --     self.totalPoint=0
    -- end
    -- if data.point then
    --     self.totalPoint=tonumber(data.point) or 0
    --     if self.rankList and SizeOfTable(self.rankList)>0 then
    --         for k,v in pairs(self.rankList) do
    --             if v and SizeOfTable(v)>0 and v[1] and tostring(v[1])==tostring(playerVoApi:getPlayerName()) then
    --                 self.rankList[k][1]=playerVoApi:getPlayerName()
    --                 self.rankList[k][2]=playerVoApi:getPlayerLevel()
    --                 self.rankList[k][3]=playerVoApi:getPlayerPower()
    --                 self.rankList[k][4]=self.totalPoint or 0
    --             end
    --         end
    --         if self.rankList and SizeOfTable(self.rankList)>0 then
    --             table.sort(self.rankList,sortAsc)
    --         end
    --     end
    -- end

    --排行榜
    if self.rankList==nil then
    	self.rankList={}
    end
    if data.awardList then
    	self.rankList=data.awardList
   --  	for k,v in pairs(self.rankList) do
   --  		if v and SizeOfTable(v)>0 and v[1] and tostring(v[1])==tostring(playerVoApi:getPlayerName()) then
			-- 	self.rankList[k][1]=playerVoApi:getPlayerName()
			-- 	self.rankList[k][2]=playerVoApi:getPlayerLevel()
			-- 	self.rankList[k][3]=playerVoApi:getPlayerPower()
			-- 	self.rankList[k][4]=self.totalPoint or 0
			-- end
   --  	end
    	if self.rankList and SizeOfTable(self.rankList)>0 then
			table.sort(self.rankList,sortAsc)
    	end
    end


    if self.lastTime and G_isToday(self.lastTime)==false then
        -- self.consume=0
        self.hasUsedNum=0
        -- self.point=0
        -- self.hasUsedFreeNum=0
        -- self.pointRewardNum=0

        self.leftNum=0
        self.hasUsedFreeNum={}
        self.feedNum=0
        self.rechargeNum=0
    end


end


