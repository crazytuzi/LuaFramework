require "luascript/script/game/gamemodel/slot/attackTankSoltVo"

attackTankSoltVoApi={
     allAttackTankSlots={},

     -- 异星矿场的队列
     alienMinesTankSlots={},

     refreshTimeTab={[1]=1,[5]=5,[15]=15,[30]=30,[60]=60},
     refreshTime={},
     goldMineRefreshTime={}, --处理金矿消失
    backTroopsSlot={}, --处理进攻军团城市战斗中，30分钟才允许强制返回部队的标识
}
function attackTankSoltVoApi:clear()
    
    for k,v in pairs(self.allAttackTankSlots) do
        v=nil
    end
   self.allAttackTankSlots=nil
   self.allAttackTankSlots={}

   for k,v in pairs(self.alienMinesTankSlots) do
        v=nil
    end
   self.alienMinesTankSlots=nil
   self.alienMinesTankSlots={}
   self.goldMineRefreshTime={} --处理金矿消失
   self.backTroopsSlot={}
end

function attackTankSoltVoApi:getAllAttackTankSlots()

    table.sort(self.allAttackTankSlots,function(a,b) return a.slotId<b.slotId end)
    return self.allAttackTankSlots
end


function attackTankSoltVoApi:sortAllAttackTankSlots()
    if self.allAttackTankSlots~=nil then
        table.sort(self.allAttackTankSlots,function(a,b) return a.slotId<b.slotId end)
    end
end


-- 异星矿场队列
function attackTankSoltVoApi:getlienMinesTankSlots()

    table.sort(self.alienMinesTankSlots,function(a,b) return a.slotId<b.slotId end)
    return self.alienMinesTankSlots
end

-- 得到总队列个数
function attackTankSoltVoApi:getAllTankSlotsNum()
    local num1 = SizeOfTable(self:getAllAttackTankSlots())
    local num2 = SizeOfTable(self:getlienMinesTankSlots())
    return num1+num2
end

function attackTankSoltVoApi:getSlotIdBytargetid(x,y)
   for k,v in pairs(self.alienMinesTankSlots) do
       if v.targetid[1]==x and  v.targetid[2]==y then
        return v.slotId
       end
   end
end

function attackTankSoltVoApi:getAllAttackTankSlotsHelpNum()
    local num=0 
    
    for k,v in pairs(self.allAttackTankSlots) do
        if v.isHelp==1 then
            num=num+1
        end
    end
    return num
end

--添加坦克进攻队列
function attackTankSoltVoApi:add(slotId,data)
    local wslotVo=attackTankSoltVo:new()
    wslotVo:initData(slotId,data)
    if self.refreshTime[slotId]==nil then
        self.refreshTime[slotId]=0
    end
    local mine={}
    if data.goldMine then --有goldMine字段的话，说明该矿当前是金矿
        self.goldMineRefreshTime[slotId]=0
        if base.wl==1 and base.goldmine==1 then --金矿处理
            --添加金矿信息
            mine.disappearTime=data.goldMine[2]
            mine.goldMineLv=data.goldMine[3]
        end
    end
    if base.richMineOpen==1 and base.landFormOpen==1 then --富矿处理
        mine.x=data.targetid[1]
        mine.y=data.targetid[2]
        mine.richLv=data.heatLv
    end
    mine.mid=tonumber(data.mid)
    mine.level=tonumber(data.level)
    worldBaseVoApi:resetWorldMine(mine)
    if data.alienMine and data.alienMine==1 then
        table.insert(self.alienMinesTankSlots,wslotVo)
    else
        table.insert(self.allAttackTankSlots,wslotVo)
    end
    
    if wslotVo.type==8 and wslotVo.isDef>0 then
        eventDispatcher:dispatchEvent("alliancecity.refreshCity")
    end
    --self.allAttackTankSlots[slotId]=wslotVo
end
function attackTankSoltVoApi:getLeftResAndTotalResBySlotId(id)
    local attackVo
    for k,v in pairs(self.allAttackTankSlots) do
        if v.slotId==id then
            attackVo=v
        end
    end
    if attackVo == nil then
        return 0,1
    end

    local type=tonumber(attackVo.type)
    local level=tonumber(attackVo.level)
    local scoutRes=nil
    local richLvAdd=worldBaseVoApi:getRichMineAdd(attackVo.heatLv)
    if mapCfg ~= nil and mapCfg[type] ~=nil and mapCfg[type][level] ~=nil and mapCfg[type][level].resource ~= nil then
        
        scoutRes=math.ceil(tonumber(mapCfg[type][level].resource)/3600)
        scoutRes=scoutRes*richLvAdd
    end
    
   
    --[[local speedRate = 0
    local acVo = activityVoApi:getActivityVo("ghostWars")
    if acVo~=nil and activityVoApi:isStart(acVo) and acVo.collectspeedup then
        speedRate = acVo.collectspeedup
        scoutRes=math.ceil(tonumber(mapCfg[type][level].resource)/60*(1+speedRate))
    end--]]
    -- --区域战buff
    -- local buffValue=0
    -- if localWarVoApi then
    --     local buffType=5
    --     local buffTab=localWarVoApi:getSelfOffice()
    --     if G_getHasValue(buffTab,buffType)==true then
    --         buffValue=G_getLocalWarBuffValue(buffType)
    --     end
    -- end
    -- scoutRes=scoutRes*(1+buffValue)
    
    --vate后台传的采集速度，已经计算过除了活动外的各种加成
    if attackVo.vate then
        scoutRes=math.ceil(tonumber(mapCfg[type][level].resource)/3600*(1+attackVo.vate))
    end

    --hardGetRich活动
    if activityVoApi:getActivityVo("hardGetRich")~=nil and activityVoApi:getActivityVo("hardGetRich").Multiple~=nil and scoutRes~=nil then
        scoutRes=math.ceil(scoutRes*(1+activityVoApi:getActivityVo("hardGetRich").Multiple))
    end

    local k,maxRes=nil 
    if attackVo and attackVo.maxRes then
        k,maxRes = next(attackVo.maxRes)    
    end
    local time=nil 
    if attackVo and attackVo.gts then
        time = base.serverTime-attackVo.gts
    end
    local k,nowRes=nil 
    if attackVo and attackVo.res then
        k,nowRes = next(attackVo.res)
    end
    if attackVo.bs==nil then
        if time and nowRes and scoutRes then
            nowRes=nowRes+scoutRes*time
        end
    end
    if nowRes and maxRes and nowRes>maxRes then
        nowRes=maxRes
    end
    --print("attackVo",time,base.serverTime,attackVo.gts,nowRes,maxRes)
    
    return nowRes,maxRes
    
end

function attackTankSoltVoApi:getAlienResBySlot(tankSlotVo,baseRes,key,rate)
    local count=0
    if tankSlotVo and baseRes and key and rate then
        count=tonumber(baseRes)*rate
        if tankSlotVo.AcRate and tankSlotVo.AcRate[2] then
            count=math.floor(count+count*tankSlotVo.AcRate[2])
        end
    end
    return count
end
-- 异星矿场 剩余资源
function attackTankSoltVoApi:getLeftResAndTotalResBySlotIdForAlienMines(id)
    local attackVo;
    for k,v in pairs(self.alienMinesTankSlots) do
        if v.slotId==id then
            attackVo=v
        end
    end

    local type=tonumber(attackVo.type)
    local level=tonumber(attackVo.level)
    local scoutRes=math.ceil(tonumber(mapCfg[4][level].resource)/3600)

    if attackVo.vate then
        scoutRes=math.ceil(tonumber(mapCfg[4][level].resource)/3600*(1+attackVo.vate))
    end

    local k,maxRes=next(attackVo.maxRes)    
    local time=base.serverTime-attackVo.gts

    local k,nowRes=next(attackVo.res)
    nowRes=nowRes+scoutRes*time
    local alienNowRes=alienMineCfg.collect[type].rate*nowRes
    local alienMaxRes=alienMineCfg.collect[type].rate*maxRes
    return nowRes,maxRes,alienNowRes,alienMaxRes
    
end
function attackTankSoltVoApi:getLeftTimeAndTotalTimeBySlotId(id)
    local attackVo;
    for k,v in pairs(self.allAttackTankSlots) do
        if v.slotId==id then
            attackVo=v
        end
    end
    if(attackVo==nil)then
        return 0,0
    end
    local totalTime,leftTime=0,0;
    if attackVo.bs~=nil then
        totalTime=attackVo.bs-attackVo.st--回家
        leftTime=attackVo.bs-base.serverTime
    elseif attackVo.isGather~=2 then
        if attackVo.isGather==0 or attackVo.isGather==1 then
            totalTime=attackVo.dist-attackVo.st--航行
            leftTime=attackVo.dist-base.serverTime
            if leftTime<=0 then
                leftTime=0;
            end
        elseif attackVo.isGather==3 or attackVo.isGather==4 or attackVo.isGather==5 then
            leftTime=0
        end
    else
        totalTime=attackVo.ges-attackVo.gts--采资源
        leftTime=attackVo.ges-base.serverTime
        if attackVo.privateMine and attackVo.privateMine[2] then
            local pTime = attackVo.privateMine[2] --保护矿到期时间
            if pTime < attackVo.ges then
                leftTime = pTime - base.serverTime
            end
        end

        if leftTime<=0 then
            leftTime=0;
        end
    end
    return leftTime,totalTime
end

-- 异星矿场 剩余时间
function attackTankSoltVoApi:getLeftTimeAndTotalTimeBySlotIdForAlienMines(id)
    local attackVo;
    for k,v in pairs(self.alienMinesTankSlots) do
        if v.slotId==id then
            attackVo=v
        end
    end
    local totalTime,leftTime=0,0;
    if attackVo.bs~=nil then
        totalTime=attackVo.bs-attackVo.st--回家
        leftTime=attackVo.bs-base.serverTime
    elseif attackVo.isGather~=2 then
        if attackVo.isGather==0 or attackVo.isGather==1 then
            totalTime=attackVo.dist-attackVo.st--航行
            leftTime=attackVo.dist-base.serverTime
            if leftTime<=0 then
                leftTime=0;
            end
        elseif attackVo.isGather==3 or attackVo.isGather==4 or attackVo.isGather==5 then
            leftTime=0
        end
    else
        totalTime=attackVo.ges-attackVo.gts--采资源
        leftTime=attackVo.ges-base.serverTime
        if leftTime<=0 then
            leftTime=0;
        end
    end
    return leftTime,totalTime
end
function attackTankSoltVoApi:getLeftTimeAll()
    local leftTimeAll={}
    for k,v in pairs(self.allAttackTankSlots) do
        local attackVo=v
        local type
        local leftTime=0
		local startTime=0
		local totalTime=0
        local isBegan=false
        local place={x=attackVo.targetid[1],y=attackVo.targetid[2]}
        local isGather=false
		local percentRes=0
        if attackVo.bs~=nil then
            --回家
            type=2
            leftTime=attackVo.bs-base.serverTime
			startTime=attackVo.st
        elseif (attackVo.isHelp==1 and attackVo.isGather~=4 and attackVo.isGather~=5) or (attackVo.isDef>0 and attackVo.isGather~=5 and attackVo.isGather~=6) then
            --协防过程中
            type=4
            leftTime=attackVo.dist-base.serverTime
            startTime=attackVo.st
        elseif attackVo.isGather==4 or attackVo.isGather==5 then
            --正在协防
            type=5

        elseif attackVo.isGather~=2 and attackVo.isGather~=3 and attackVo.isGather~=4 and attackVo.isGather~=5 and attackVo.isGather~=6 then
            --航行
            type=1
            leftTime=attackVo.dist-base.serverTime
            startTime=attackVo.st
            if attackVo.isGather==1 then
                isGather=true
            end
        else
            --采资源
            type=3
			if attackVo.isGather==3 or attackVo.isGather==4 or attackVo.isGather==5 then
                percentRes=100
			else
	            leftTime=attackVo.ges-base.serverTime
				startTime=attackVo.gts
				totalTime=attackVo.ges-attackVo.gts
	            local nowRes,maxRes=self:getLeftResAndTotalResBySlotId(attackVo.slotId)
				percentRes=math.floor(nowRes/maxRes*100)
				if percentRes<=0 then
					percentRes=1
				end
			end
        end
        if leftTime>=0 or attackVo.isGather==3 then
            table.insert(leftTimeAll,{type=type,startTime=startTime,time=leftTime,place=place,isGather=isGather,percentRes=percentRes})
        end
    end
    if SizeOfTable(leftTimeAll)>0 then
        local function sortAsc(a, b)
			if a.type==b.type then
				if a.startTime and b.startTime then
					return a.startTime > b.startTime
				end
			else
				return a.type<b.type
            end
        end
		table.sort(leftTimeAll,sortAsc)
    end
    return leftTimeAll
end

--临时解决后台队列卡死的方法（时间到自动加速队列）
function attackTankSoltVoApi:cronAttackAccelerate(cronidSend,targetSend)
    local function cronAttackCallBack(fn,data)
          local retTb=G_Json.decode(tostring(data))
          --OBJDEF:decode(data)
          if base:checkServerData(data)==true then
                if base.heroSwitch==1 then
                    --请求英雄数据
                    local function heroGetlistHandler(fn,data)
                        local ret,sData=base:checkServerData(data)
                            if ret==true then
                                if base.he==1 and sData and sData.data and sData.data.equip and heroEquipVoApi then
                                    heroEquipVoApi:formatData(sData.data.equip)
                                    heroEquipVoApi.ifNeedSendRequest=true
                                end
                            end
                        end
                    socketHelper:heroGetlist(heroGetlistHandler)
                end
          end
    end
    --[[
        local cronidSend=self.tanksSlotTab[idx+1].slotId;
        local targetSend=self.tanksSlotTab[idx+1].targetid;
    ]]
    local attackerSend=playerVoApi:getUid()

    socketHelper:cronAttack(cronidSend,targetSend,attackerSend,0,cronAttackCallBack);
end

--金矿消失后强制队伍回家
function attackTankSoltVoApi:forceTroopBack(attackVo)
    if attackVo==nil or type(attackVo)~="table" then
        do return end
    end
    local function serverBack(fn,data)
        if base:checkServerData(data)==true then
            enemyVoApi:deleteEnemy(attackVo.targetid[1],attackVo.targetid[2])
            if attackVo.goldMine then
                attackVo.goldMine=nil
            end
        end
    end
    socketHelper:troopBack(attackVo.slotId,serverBack,1)
end

function attackTankSoltVoApi:tick()
    local isOrderChange=false
    local needRefreshMineTb={}
    for k,v in pairs(self.allAttackTankSlots) do

            local leftTime,totalTime=self:getLeftTimeAndTotalTimeBySlotId(tonumber(v.slotId))
            if v.bs==nil then
                if v.isGather~=3 and v.isGather~=4 and v.isGather~=5 then
                    if leftTime<=0 then --当前队列完成
                       leftTime=0
                       
                       if v.isGather~=2 then
                           if  self.refreshTimeTab[self.refreshTime[v.slotId]]~=nil then
                               
                               if self.refreshTime[v.slotId]==1 then
                                 G_SyncData()
                               else
                                 self:cronAttackAccelerate(v.slotId,v.targetid)
                               end
                               
                               --G_SyncData()
                               

                            end
                            self.refreshTime[v.slotId]=self.refreshTime[v.slotId]+1
                            if self.refreshTime[v.slotId]>=60 then
                                self.refreshTime[v.slotId]=60;
                            end
                        end
                        if v.isGather==1 then
                            if(v.targetid and v.targetid[1] and v.targetid[2])then
                                table.insert(needRefreshMineTb,{x=v.targetid[1],y=v.targetid[2]})
                            end
                        end
                    end
                end
                if v.isGather==2 and v.goldMine and base.wl==1 and base.goldmine==1 then --如果当前是采集中并且该矿当前是金矿，当金矿消失后强制返回部队
                    local disappearTime=0
                    if v.goldMine[2] then
                        disappearTime=(tonumber(v.goldMine[2])-tonumber(base.serverTime))
                        if disappearTime<=0 then
                            disappearTime=0
                        end
                    end
                    if disappearTime==0 then
                        if self.refreshTimeTab[self.goldMineRefreshTime[v.slotId]]~=nil then
                            if self.goldMineRefreshTime[v.slotId]>=1 then
                                self:forceTroopBack(v) --调用部队返回接口，强制返回部队
                                if(v.targetid and v.targetid[1] and v.targetid[2])then
                                    table.insert(needRefreshMineTb,{x=v.targetid[1],y=v.targetid[2]})
                                end
                            end
                        end
                        self.goldMineRefreshTime[v.slotId]=self.goldMineRefreshTime[v.slotId]+1
                        if self.goldMineRefreshTime[v.slotId]>=60 then
                            self.goldMineRefreshTime[v.slotId]=60
                        end
                    end
                end
            else
                if leftTime<=0 then
                     self.allAttackTankSlots[k]=nil
                     isOrderChange=true
                     G_SyncData()

                     dyTime=0
                     if leftTime<=0 then
                         dyTime=leftTime --当前队列完成 刷晚了，用户后台运行游戏可以导致此现象
                     end
                end
            end
            --如果是进攻军团城市的话，部队到达后30分钟内不允许强制返回部队
            if v.isGather==5 and v.isDef==0 and v.isHelp==nil and v.type==8 then
                local time=v.dist+1800
                if base.serverTime>=time then
                    local backFlag=self.backTroopsSlot[v.slotId] or false
                    if backFlag==false then
                        eventDispatcher:dispatchEvent("attackTankSlot.refreshSlot")
                    end
                    self.backTroopsSlot[v.slotId]=true
                else
                    self.backTroopsSlot[v.slotId]=false
                end
            else
                self.backTroopsSlot[v.slotId]=nil
            end
    end
    if(#needRefreshMineTb > 0)then
        eventDispatcher:dispatchEvent("worldScene.mineChange",needRefreshMineTb)
    end
    if isOrderChange==true then
        local newTab ={}
        for k,v in pairs(self.allAttackTankSlots) do
            table.insert(newTab,v);
        end
        self.allAttackTankSlots={}
        self.allAttackTankSlots=newTab
    end
    
    
end
--刷新对应的队列
function attackTankSoltVoApi:updateSlotByIdAndVo(id,vo)
    G_SyncData()
    for k,v in pairs(self.allAttackTankSlots) do
        local slotid="c"..v.slotId
        if slotid==id then
            v=nil
            local wslotVo=attackTankSoltVo:new();
            -- print("推推推推哦=",id,vo.targetid,vo.troops,vo.level,vo.type,vo.isGather,vo.st,vo.dist,vo.maxRes,vo.res,vo.gts,vo.ges,vo.bs,vo.tName,vo.isHelp,vo.vate)
            local helpSlotId=tonumber(RemoveFirstChar(id))
            wslotVo:initData(helpSlotId,vo)
            self.allAttackTankSlots[k]=wslotVo

        end
    end
end

-- 解析出当前行军路线的状态和时间数据
function attackTankSoltVoApi:getSlotStateAndTime(vo)
    if vo==nil then
        do return end
    end
    local attackVo = vo
    local slotState = 0
    local totalTime,leftTime = 0,0
    if attackVo.bs~=nil then
        slotState = 4 --回家航行
        totalTime=attackVo.bs-attackVo.st
        leftTime=attackVo.bs-base.serverTime
    elseif attackVo.isGather~=2 then
        if attackVo.isGather==0 or attackVo.isGather==1 then
            slotState = 1 -- 前进航行
            totalTime=attackVo.dist-attackVo.st
            leftTime=attackVo.dist-base.serverTime
            if leftTime<=0 then
                leftTime=0
            end
        elseif attackVo.isGather==3 or attackVo.isGather==4 or attackVo.isGather==5 then
            slotState = 3 -- 采集满 协防到达 待命状态
            leftTime=0
        end
    else
        slotState = 2 -- 采资源中
        totalTime=attackVo.ges-attackVo.gts
        leftTime=attackVo.ges-base.serverTime
        if leftTime<=0 then
            leftTime=0
        end
    end
    return slotState,leftTime,totalTime
end

function attackTankSoltVoApi:getSlotIndexById(slotId)
    for k,v in pairs(self.allAttackTankSlots) do
        if v.slotId==slotId then
            return k,v
        end
    end
    return nil
end

function attackTankSoltVoApi:updateAttackSlots(data)
    if data.troops~=nil and data.troops.attack~=nil then
        attackTankSoltVoApi:clear()
        local bSlot=data.troops.attack
        for k,v in pairs(attackTankSoltVoApi.refreshTime) do
            if bSlot["c"..k]==nil then
                attackTankSoltVoApi.refreshTime[k]=nil
            end
        end
        for k,v in pairs(attackTankSoltVoApi.goldMineRefreshTime) do
            if bSlot["c"..k]==nil then
                attackTankSoltVoApi.goldMineRefreshTime[k]=nil
            end
        end

        for k,v in pairs(bSlot) do
            local slotId=tonumber(RemoveFirstChar(k))
            attackTankSoltVoApi:add(slotId,v)
        end
        -- 出征队列刷新后，将队列按slotId排序 
        attackTankSoltVoApi:sortAllAttackTankSlots()
        if worldScene~=nil then
            worldScene:checkEndTankSlot()
        end
    end
    if data.alliancecity or data.acityuser then --更新军团城市的数据
        allianceCityVoApi:updateData(data,true)
    end
end

--如果是进攻军团城市的话，部队到达后30分钟内不允许强制返回部队
function attackTankSoltVoApi:isCanBackTroops(slotVo)
    if slotVo and slotVo.isGather==5 and slotVo.isDef==0 and slotVo.isHelp==nil and slotVo.type==8 then
        local time=slotVo.dist+1800
        if base.serverTime<time then
            return false
        end
    end
    return true
end