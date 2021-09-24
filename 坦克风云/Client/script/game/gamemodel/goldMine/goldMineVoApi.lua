goldMineVoApi={
    goldMineTb={},
    gatherResList=nil,
    resCount=0,
    dailyGems={},
    refreshGemsFlag=false,
    refreshNewMine=false,
    direction={{0,200,0,200},{200,400,0,200},{400,600,0,200},{0,200,200,400},{200,400,200,400},{400,600,200,400},{0,200,400,600},{200,400,400,600},{400,600,400,600}}
}

function goldMineVoApi:updateData(data)
    return goldMineVo:initWithData(data)
end

-- 获取金矿采集金币上限(包括皮肤的加成)
function goldMineVoApi:getGemLimit( ... )
    
    local allGemlimit = 0
    local basic = goldMineCfg.dailyGemLimit
    allGemlimit = allGemlimit + basic

    -- 获取基地皮肤的加成
    if base.isSkin and base.isSkin == 1 then
        buildDecorateVoApi:initSkinTb()
        local skinAdd = buildDecorateVoApi:addGemLimit()
        allGemlimit = allGemlimit + skinAdd
    end

    --战机改装技能加成
    local pskillAdd = planeRefitVoApi:getSkvByType(66)
    allGemlimit = allGemlimit + pskillAdd
    
    return allGemlimit
end

--获取采集资源的列表
function goldMineVoApi:getGatherResList()
    self.resCount=0
    if self.gatherResList==nil then
        self.gatherResList={}
        self.gatherResList.u={}
        self.gatherResList.r={}
    end
    if goldMineCfg.resOutputCfg.u then
        for k,v in pairs(goldMineCfg.resOutputCfg.u) do
            if k=="gems" then
                local cur=self:getDailyGemsCount()
                local max=self:getGemLimit()
                if self.gatherResList.u[k]==nil then
                    self.gatherResList.u[k]={cur=cur,max=max,index=v.index}
                else
                    self.gatherResList.u[k].cur=cur
                    self.gatherResList.u[k].max=max
                end
                self.resCount=self.resCount+1
            end
        end
    end
    if goldMineCfg.resOutputCfg.r then
        for k,v in pairs(goldMineCfg.resOutputCfg.r) do
            local cur=alienTechVoApi:getAlienDailyResByType(k)
            local max=alienTechVoApi:getAlienGatherUpByType(k)
            if cur>max then
                cur=max
            end
            if self.gatherResList.r[k]==nil then
                self.gatherResList.r[k]={cur=cur,max=max,index=v.index}
            else
                self.gatherResList.r[k].cur=cur
                self.gatherResList.r[k].max=max
            end
            self.resCount=self.resCount+1
        end
    end
    return self.gatherResList,self.resCount
end

function goldMineVoApi:getGatherRes(resType,key)
    local cur,max
    if self.gatherResList then
        if resType=="u" then
            if self.gatherResList.u and self.gatherResList.u[key] then
                if key=="gems" then
                    cur=self:getDailyGemsCount()
                    max=self.gatherResList.u[key].max
                    local gemLimit = self:getGemLimit()
                    if max ~= gemLimit then
                        self.gatherResList.u[key].max = gemLimit
                        max = self.gatherResList.u[key].max
                    end
                end
            end         
        elseif resType=="r" then
            if self.gatherResList.r and self.gatherResList.r[key] then
                cur=alienTechVoApi:getAlienDailyResByType(key)
                max=alienTechVoApi:getAlienGatherUpByType(key)
            end
        end
    end
    if cur and max and tonumber(cur)>tonumber(max) then
        cur=max
    end
    return cur,max
end

--判断该矿点是不是金矿矿点
function goldMineVoApi:isGoldMine(mid)
    local flag=false
    local level=0
    if base.wl==1 and base.goldmine==1 then
        local illegalFlag=worldBaseVoApi:isIllegalSaok()
        if illegalFlag==true then
            return flag,level
        end
        if self.goldMineTb[mid] then
            local lefttime=self:getGoldMineLeftTime(mid)
            if lefttime==0 then
                self:removeGoldMine(mid)
            else
                flag=true
                level=self.goldMineTb[mid].level
            end
        end
    end
    return flag,level
end

function goldMineVoApi:getGoldMineLeftTime(mid)
    local leftTime=0
    if self.goldMineTb[mid] then
        local endTime=self.goldMineTb[mid].endTime
        leftTime=(tonumber(endTime)-tonumber(base.serverTime))
        if leftTime<0 then
            leftTime=0
        end
        if tonumber(leftTime)==0 then
            self:removeGoldMine(mid)
        end
    end
    return leftTime
end

function goldMineVoApi:getGoldMineAdd()
    return goldMineCfg.resOutputCfg.resUp*100
end

--添加一个金矿
function goldMineVoApi:addGoldMine(mid,level,endTime)
    if self.goldMineTb[mid]~=nil then
        self.goldMineTb[mid]=nil
    end
    -- print("mid=======",mid)
    -- print("level=======",level)
    -- print("endTime=======",endTime)
    -- if mid <= 360000 and mid >= 1 then
    --     local x = mid % 600
    --     if x == 0 then  x = 600 end
    --     local y = math.ceil(mid /600)
    --     print("x======",x)
    --     print("y======",y)
    -- end
    self.goldMineTb[mid]=goldMineVo:new(mid,level,endTime)
end

--当金矿矿点消失后要删除该矿点
function goldMineVoApi:removeGoldMine(mid)
    if self.goldMineTb[mid] then
        self.goldMineTb[mid]=nil
    end
end

--获取当前金矿列表
function goldMineVoApi:getGoldMineList()
    return self.goldMineTb
end

--获取采集的金币数量 参数为已采集时间 单位：秒
function goldMineVoApi:getGatherGemsCount(gatherTime, ggs)
    local speed = ggs or goldMineCfg.resOutputCfg.u.gems.time
    local count=math.floor(gatherTime/speed)
    local maxCount=math.floor(goldMineCfg.exploitTime/speed)
    if count>maxCount then
        count=maxCount
    end
    return count
end

function goldMineVoApi:checkUpdateDailyGems()
    if self.dailyGems and self.dailyGems.ts then
        if G_isToday(self.dailyGems.ts)==false then
            self.dailyGems={}
            self.dailyGems.ts=G_getWeeTs(base.serverTime)+86400
        end
    end
end

function goldMineVoApi:setDailyGemsData(data,isCheckLimit)
    self.dailyGems=data
    if self.dailyGems and isCheckLimit==true then
        if self.dailyGems.gems>self:getGemLimit() then

            self.dailyGems.gems=self:getGemLimit()
        end
    end
    self:setRefreshGemsFlag(true)
end

function goldMineVoApi:getDailyGemsCount()
    local num=0
    if self.dailyGems and self.dailyGems.gems then
        num=self.dailyGems.gems 
    end
    return num
end

function goldMineVoApi:setRefreshGemsFlag(flag)
    self.refreshGemsFlag=flag
end

function goldMineVoApi:getRefreshGemsFlag()
    return self.refreshGemsFlag
end

function goldMineVoApi:setRefreshNewMineFlag(flag)
    self.refreshNewMine=flag
end

function goldMineVoApi:needRefreshNewMine()
    return self.refreshNewMine
end

function goldMineVoApi:getGatherTime(disappearTime)
    local gatherTime=0
    if disappearTime then
        local bs=tonumber(disappearTime)-tonumber(goldMineCfg.exploitTime)
        gatherTime=tonumber(base.serverTime)-bs
    end
    return gatherTime
end

function goldMineVoApi:getMineDirection(x,y)
    local direction=1
    for dir,pos in pairs(self.direction) do
        if x>pos[1] and x<=pos[2] and y>pos[3] and y<=pos[4] then
            direction=dir
            do break end
        end
    end
    return direction
end

function goldMineVoApi:getDirectionName(dir)
    return getlocal("mine_direction"..dir)
end

function goldMineVoApi:getExploitTime()
    return math.floor(goldMineCfg.exploitTime/3600)
end

function goldMineVoApi:clear()
    self.goldMineTb={}
    self.gatherResList=nil
    self.resCount=0
    self.dailyGems={}
    self.refreshGemsFlag=false
    self.refreshNewMine=false
end