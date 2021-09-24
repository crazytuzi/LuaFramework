tankVoApi={
    allTanks={},  -- 例如: [10001]={34,10,15}  34:该种船总数 10:正在改装的数量 15:损坏的数量
    defenseTanks={{},{},{},{},{},{}}, --[1]={10001,2} 10001:船只id 2:船只数量
    temDefenseTanks={{},{},{},{},{},{}},
    storyTanks={{},{},{},{},{},{}}, --[1]={10001,2} 10001:船只id 2:船只数量
    attackTanks={{},{},{},{},{},{}},
    allianceWarTanks={{},{},{},{},{},{}},
    allianceWarHoldTanks={{},{},{},{},{},{}},
    arenaTanks={{},{},{},{},{},{}}, --竞技场坦克
    serverWarFleetIndexTb={1,2,3},       --跨服个人战部队对应场次关系,{1,3,2}对应第1，3，2部队的顺序
    serverWarTanks1={{},{},{},{},{},{}}, --跨服个人战坦克第一场
    serverWarTanks2={{},{},{},{},{},{}}, --跨服个人战坦克第二场
    serverWarTanks3={{},{},{},{},{},{}}, --跨服个人战坦克第三场
    serverWarTeamTanks={{},{},{},{},{},{}}, --跨服军团战坦克
    expeditionTanks={{},{},{},{},{},{}}, --远征攻击坦克
    bossbattleTanks={{},{},{},{},{},{}}, --世界boss
    alienMinesTanks={{},{},{},{},{},{}}, --异星矿场

    worldWarTanks1={{},{},{},{},{},{}}, --世界争霸部队一
    worldWarTanks2={{},{},{},{},{},{}}, --世界争霸部队二
    worldWarTanks3={{},{},{},{},{},{}}, --世界争霸部队三
    worldWarTempTanks={{},{},{},{},{},{}}, --世界争霸当前部队阵型，不保存不变
    worldWarFleetIndexTb={1,2,3},       --部队对应场次关系,{1,3,2}对应第1，3，2部队的顺序

    localWarTanks={{},{},{},{},{},{}},  --区域战部队
    localWarCurTanks={{},{},{},{},{},{}},  --区域战当前战斗的剩余部队

    swAttackTanks={{},{},{},{},{},{}},   --超级武器攻击部队
    swDefenceTanks={{},{},{},{},{},{}},  --超级武器防守部队

    platWarTanks1={{},{},{},{},{},{}}, --平台对战部队一
    platWarTanks2={{},{},{},{},{},{}}, --平台对战部队二
    platWarTanks3={{},{},{},{},{},{}}, --平台对战部队三
    platWarTempTanks={{},{},{},{},{},{}}, --平台对战当前部队阵型，不保存不变
    platWarFleetIndexTb={},       --平台对战部队对应线路关系,如{2,5,3} 第一支部队对应线路2，第二支部队对应线路5，第三支部队对应线路3

    serverWarLocalTanks1={{},{},{},{},{},{}},  --群雄争霸预设部队一
    serverWarLocalTanks2={{},{},{},{},{},{}},  --群雄争霸预设部队二
    serverWarLocalTanks3={{},{},{},{},{},{}},  --群雄争霸预设部队三
    serverWarLocalCurTanks1={{},{},{},{},{},{}},  --群雄争霸当前部队一
    serverWarLocalCurTanks2={{},{},{},{},{},{}},  --群雄争霸当前部队二
    serverWarLocalCurTanks3={{},{},{},{},{},{}},  --群雄争霸当前部队三
    serverWarLocalTempTanks={{},{},{},{},{},{}}, --群雄争霸当前预设部队阵型，不保存不变

    newYearBossTanks={{},{},{},{},{},{}},   --除夕活动攻击boss部队
    allianceWar2CurTanks={{},{},{},{},{},{}},  --新军团战当前战斗的剩余部队
    allianceWar2Tanks={{},{},{},{},{},{}},     --新军团战预设部队
    dimensionalWarTanks={{},{},{},{},{},{}},   --异元战场报名部队

    localWarTempTanks={{},{},{},{},{},{}}, --区域战镜像，不保存不变
    allianceWar2TempTanks={{},{},{},{},{},{}}, --新军团战镜像，不保存不变
    dimensionalWarTempTanks={{},{},{},{},{},{}}, --异元战场镜像，不保存不变
    serverWarTeamCurTanks={{},{},{},{},{},{}}, --跨服军团战当前部队

    unlockBuildTankTb={}, --可以生产的坦克列表
    tflevelTb={}, --坦克工厂的等级

    believerTanks={{},{},{},{},{},{}}, --狂热集结部队坦克

    championshipWarPersonalTanks={{},{},{},{},{},{}}, --军团锦标赛军团战个人战布置的部队
    championshipWarTanks={{},{},{},{},{},{}}, --军团锦标赛军团战的个人参战部队
    championshipWarTempTanks={{},{},{},{},{},{}}, --军团锦标赛军团战的个人参战部队缓存
}
--获取所有坦克
function tankVoApi:getAllTanks()
    return self.allTanks
end

--获取所有的坦克类型及数量等信息（生产面板使用）
function tankVoApi:getAllTankTypeAndCoutByBid(bid)
    local bcfg=buildingCfg[6]
    local proSid=Split(bcfg.buildPropSids,",")
    local bvo=buildingVoApi:getBuildiingVoByBId(bid)


    local resultType={} -- 所有坦克的坦克id集合
    local resultLock={} -- 已解锁坦克存储为0，未解锁坦克存储需要的坦克工厂的等级
    local resultCount={} -- 坦克的当前数量
    for kk=1,#proSid do
        if kk%2==0 then
            table.insert(resultType,tonumber(proSid[kk]))
            if bvo.level>=tonumber(proSid[kk-1]) then --已解锁
                 table.insert(resultLock,0)
            else
                 table.insert(resultLock,tonumber(proSid[kk-1]))
            end
            if self.allTanks[tonumber(proSid[kk])]~=nil then
                table.insert(resultCount,self.allTanks[tonumber(proSid[kk])][1])
            else
                table.insert(resultCount,0)
            end
        end
    end
    --[[
    for k,v in pairs(resultType) do
        if v==10035 then
            table.remove(resultType,k)
        end
    end
    ]]
    local unlockTankTb=playerVoApi:getMaxLvByKey("unlockBuildForceIdStr")


    if(unlockTankTb)then
        for i=1,#resultType do
            for k,v in pairs(unlockTankTb) do
                if resultType[i] == v then
                    table.remove(resultType, i)
                end
            end
        end
    end    

    return resultType,resultLock,resultCount
end

--获取所有可以升级的坦克的类型及数量等信息（改装面板使用）
function tankVoApi:getAllUpgradeTankTypeAndCoutByBid(bid)
    local bcfg=buildingCfg[14]
    local proSid=Split(bcfg.buildPropSids,",")
    --local bvo=buildingVoApi:getBuildiingVoByBId(bid)
        local bvos=buildingVoApi:getBuildingVoByBtype(6)
    local bvo
    for k,v in pairs(bvos) do
        if bvo==nil then
            bvo=v
        elseif bvo.level<=v.level then
                bvo=v
            
        end
    end
    
    local resultType={}
    local resultLock={}
    local resultCount={}
    for kk=1,#proSid do
        if kk%2==0 then
            table.insert(resultType,tonumber(proSid[kk]))
            if bvo.level>=tonumber(proSid[kk-1]) then --已解锁
                 table.insert(resultLock,0)
            else
                 table.insert(resultLock,tonumber(proSid[kk-1]))
            end
            if self.allTanks[tonumber(proSid[kk])]~=nil then
                table.insert(resultCount,self.allTanks[tonumber(proSid[kk])][1])
            else
                table.insert(resultCount,0)
            end
        end
    end
    
    local unlockTankTb=playerVoApi:getMaxLvByKey("newTankBuilding")

    for i=1,#resultType do
        for k,v in pairs(unlockTankTb) do
            if resultType[i] == v then
               table.remove(resultType, i)
            end
        end

    end

    return resultType,resultLock,resultCount
end
--检查立即完成(生产面板使用)
function tankVoApi:checkSuperUpgradeBeforeSendServer(bid,slotId)
     local result,reason=true,nil  --reason 1:已经生产完成 2:宝石不足
    --检查生产队列状态
    if tankSlotVoApi:getSlotBySlotid(bid,slotId)==nil then
         result=false
         reason=1
    end
    --检查宝石数量
    local needNems=0
    if result==true then
        local leftT=tankSlotVoApi:getLeftTimeAndTotalTimeBySlotid(bid,slotId)
        needGems= TimeToGems(leftT)
        if needGems>playerVoApi:getGems() then
            result=false
            reason=2
        end
    end
    return result,reason

end
--立即完成(生产面板使用)
function tankVoApi:superProduce(bid,slotId)
   
   
    --local tslot=tankSlotVoApi:getSlotBySlotid(bid,slotId)
    --self:addTank(tslot.itemId,tslot.itemNum)--加入tankVoApi
    --tankSlotVoApi:cancleProduce(bid,slotId)

end
--检查立即完成资源或者队列在是否满足条件（改装面板使用）
function tankVoApi:checkUpgradeReBeforeSendServer(bid,slotId)
     local result,reason=true,nil  --reason 1:已经生产完成 2:宝石不足
    --检查生产队列状态
    if tankUpgradeSlotVoApi:getSlotBySlotid(bid,slotId)==nil then
         result=false
         reason=1
    end
    --检查宝石数量
    local needNems=0
    if result==true then
        local leftT=tankUpgradeSlotVoApi:getLeftTimeAndTotalTimeBySlotid(bid,slotId)
        needGems= TimeToGems(leftT)
        if needGems>playerVoApi:getGems() then
            result=false
            reason=2
        end
    end
    return result,reason

end
--立即完成（改装面板使用）
function tankVoApi:superUpgrade(bid,slotId)
   --[[
    smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("promptProduceFinish",{getlocal(tankCfg[tankUpgradeSlotVoApi:getSlotBySlotid(bid,slotId).itemId].name)}),28)
    local tslot=tankUpgradeSlotVoApi:getSlotBySlotid(bid,slotId)
    tankUpgradeSlotVoApi:cancleProduce(bid,slotId)
    ]]
    
end

--取消生产队列（生产面板使用）
function tankVoApi:cancleProduce(bid,slotId)

    tankSlotVoApi:cancleProduce(bid,slotId)
    
end

--取消改造队列（改造面板使用）
function tankVoApi:cancleUpgrade(bid,slotId)
    --[[
    local result,reason=true,nil   --reason  1:已经生产完成
    --检查生产队列状态
    if tankUpgradeSlotVoApi.allSlots[slotId]==nil then
        result=false
        reason=1
    end
        if result==true then
       
    end

    return result,reason]]
    
    tankUpgradeSlotVoApi:cancleProduce(bid,slotId)

end

--检测队列是否已满
function tankVoApi:checkIsFull(bid)
    local queueCfg=playerCfg.vipProuceQueue
    local queueNum=Split(queueCfg,",")[playerVoApi:getVipLevel()+1]
    if  SizeOfTable(tankSlotVoApi:getSoltByBid(bid))>=tonumber(queueNum) then
        return true
    end
    return false
end

--检查资源或者队列在是否满足条件(生产面板)
function tankVoApi:checkUpgradeBeforeSendServer(bid,itemId,count)
    local result=true
    local reason --1:资源不足 2:队列不足
    --检查资源
            local needR1=tonumber(tankCfg[itemId].metalConsume)*count
            local needR2=tonumber(tankCfg[itemId].oilConsume)*count
            local needR3=tonumber(tankCfg[itemId].siliconConsume)*count
            local needR4=tonumber(tankCfg[itemId].uraniumConsume)*count
    if needR1>playerVoApi:getR1() then
        result=false
        reason=1
    end
    if needR2>playerVoApi:getR2() then
        result=false
        reason=1
    end
    if needR3>playerVoApi:getR3() then
        result=false
        reason=1
    end
    if needR4>playerVoApi:getR4() then
        result=false
        reason=1
    end
    --检查队列
    if result==true then
        local queueCfg=playerCfg.vipProuceQueue
        local queueNum=Split(queueCfg,",")[playerVoApi:getVipLevel()+1]
        if  SizeOfTable(tankSlotVoApi:getSoltByBid(bid))>=tonumber(queueNum) then
             result=false
             reason=2
        end
    end
    
    return result,reason
    
end

--开始生产坦克   itemId:坦克类型Id  count:数量
function tankVoApi:startProduce(itemId,count)

    tankSlotVoApi:add(itemId,count,base.serverTime,base.serverTime)
    
end

--检查资源或者队列在是否满足条件(改装面板)
function tankVoApi:checkUpgradeResouceBeforeSendServer(bid,itemId,count)
     local result=true
    local reason --1:资源不足 2:队列不足 3:需要的低等级的坦克数量不足
    --检查资源
    local needR1=tonumber(tankCfg[itemId].upgradeMetalConsume)*count
    local needR2=tonumber(tankCfg[itemId].upgradeOilConsume)*count
    local needR3=tonumber(tankCfg[itemId].upgradeSiliconConsume)*count
    local needR4=tonumber(tankCfg[itemId].upgradeUraniumConsume)*count
    local needDT=count --需要的低等级的坦克数量
    if needR1>playerVoApi:getR1() then
        result=false
        reason=1
    end
    if needR2>playerVoApi:getR2() then
        result=false
        reason=1
    end
    if needR3>playerVoApi:getR3() then
        result=false
        reason=1
    end
    if needR4>playerVoApi:getR4() then
        result=false
        reason=1
    end

    local tankNum1 = self:getTankCountByItemId(itemId-1)
    local tankNum2 = self:getTankCountByItemId(itemId-1+40000)

    if tankNum1+tankNum2<needDT then
        result=false
        reason=3
    end

    --检查队列
    if result==true then
        local queueCfg=playerCfg.vipProuceQueue
        local queueNum=Split(queueCfg,",")[playerVoApi:getVipLevel()+1]
        if  SizeOfTable(tankUpgradeSlotVoApi:getSoltByBid(bid))>=tonumber(queueNum) then
             result=false
             reason=2
        end
    end
    
    return result,reason

end
--开始改装坦克   itemId:坦克类型Id  count:数量
function tankVoApi:startUpgrade(itemId,count)
   
    tankUpgradeSlotVoApi:add(itemId,count,base.serverTime,base.serverTime)

end


function tankVoApi:clearTanks()
    for k,v in pairs(self.allTanks) do
         v=nil
    end
    self.allTanks=nil
    self.allTanks={}

end

function tankVoApi:clear()
    self:clearTanksTbByType(1)
    self:clearTanksTbByType(3)
    self:clearTanksTbByType(2)
    self:clearTanks()
    self:clearTanksTbByType(5)
    for i=1,35 do
        self:clearTanksTbByType(i)
    end
    self:clearTanksTbByType(37)
    self:clearTanksTbByType(12)
    for i=38,39 do --军团锦标赛部队清理
        self:clearTanksTbByType(i)
    end
    self.worldWarTempTanks={}
    self.worldWarFleetIndexTb={1,2,3}
    self.platWarTempTanks={}
    self.platWarFleetIndexTb={}
    self.serverWarLocalTempTanks={}
    self.serverWarFleetIndexTb={1,2,3}
    self.localWarTempTanks={}
    self.allianceWar2TempTanks={}
    self.dimensionalWarTempTanks={}
    self.serverWarTeamCurTanks={}
    self.unlockBuildTankTb={}
    self.tflevelTb={}
    self.championshipWarTempTanks={}
    self.prodamagedTanks = nil
end

--生产完后添加坦克
function tankVoApi:addTank(itemId,count,isRefresh)
    if(itemId and count)then
        if self.allTanks[itemId]==nil then
             self.allTanks[itemId]={count}
        else
             self.allTanks[itemId][1]=self.allTanks[itemId][1]+count
        end
        if(tankCfg[itemId].inWarehouse)then
            eventDispatcher:dispatchEvent("tank.addToWarehouse")
            if FuncSwitchApi:isEnabled("diku_repair") == false then
                tankWarehouseScene:checkNewTank(itemId)
            end
        end
        if isRefresh==true then
            portScene:initTanks()
        end
    end
end

function tankVoApi:refreshUpgradedTanks(itemId,count)
    if self.allTanks[itemId-1]~=nil then
        if #self.allTanks[itemId-1]>0 then
             self.allTanks[itemId-1][1]=self.allTanks[itemId-1][1]-count
        end
    end
    portScene:initTanks()

end

--改装完后添加添加坦克

function tankVoApi:addUpgradedTank(itemId,count)

    --添加改装后的
    if self.allTanks[itemId+1]==nil then
         self.allTanks[itemId+1]={count}
    else
         self.allTanks[itemId+1][1]=self.allTanks[itemId+1][1]+count
    end
    if(tankCfg[itemId].inWarehouse)then
        eventDispatcher:dispatchEvent("tank.addToWarehouse")
    end
    portScene:initTanks()
end

function tankVoApi:getTankCountByItemId(itemId)
    if self.allTanks[itemId]~=nil then
        return self.allTanks[itemId][1]
    else
        return 0
    end
end
--取改装坦克所需要的资源
function tankVoApi:getUpgradedTankResources(id)
    local r1,r2,r3,r4,UpgradedTime=0,0,0,0,0;
    r1=tonumber(tankCfg[id].upgradeMetalConsume)
    r2=tonumber(tankCfg[id].upgradeOilConsume)
    r3=tonumber(tankCfg[id].upgradeSiliconConsume)
    r4=tonumber(tankCfg[id].upgradeUraniumConsume)
    UpgradedTime=tonumber(tankCfg[id].upgradeTimeConsume)
    
    return r1,r2,r3,r4,UpgradedTime;
end
--取建造坦克所需要的资源
function tankVoApi:getProduceTankResources(id)
    local r1,r2,r3,r4,UpgradedTime=0,0,0,0,0;
    r1=tonumber(tankCfg[id].metalConsume)
    r2=tonumber(tankCfg[id].oilConsume)
    r3=tonumber(tankCfg[id].siliconConsume)
    r4=tonumber(tankCfg[id].uraniumConsume)
    UpgradedTime=tonumber(tankCfg[id].timeConsume)

    return r1,r2,r3,r4,UpgradedTime;
end
--取加成的各项数值攻击血量等
function tankVoApi:getTankAddProperty(id)
    --异星科技属性加成
    --精准,闪避,暴击,装甲,攻击力,生命值,暴击伤害增加,暴击伤害减少,防护,击破,增加技能等级
    local accurateAlienAdd,avoidAlienAdd,criticalAlienAdd,decriticalAlienAdd,baseAttackAlienAdd,baseLifeAlienAdd,critDmgAlienAdd,decritDmgAlienAdd,armorAlienAdd,penetrateAlienAdd,skillAlienAdd=0,0,0,0,0,0,0,0,0,0,0
    if base.alien==1 and base.richMineOpen==1 and alienTechVoApi and alienTechVoApi.getAlienAddAttr then
        accurateAlienAdd,avoidAlienAdd,criticalAlienAdd,decriticalAlienAdd,baseAttackAlienAdd,baseLifeAlienAdd,critDmgAlienAdd,decritDmgAlienAdd,armorAlienAdd,penetrateAlienAdd,skillAlienAdd=alienTechVoApi:getAlienAddAttr(id)
    end

    local baseAttack=tonumber(tankCfg[id].attack)+baseAttackAlienAdd
    local baseLife=tonumber(tankCfg[id].life)+baseLifeAlienAdd
    local attack,life,accurate,avoid,critical,decritical,armor,penetrate,critDmg,decritDmg,baseAttackAdd,baseLifeAdd,skillAdd=0,0,0,0,0,0,0,0,0,0,0,0,0;

    local tankType=tonumber(tankCfg[id].type)
    for sid,sVo in pairs(skillVoApi:getAllSkills()) do
        local flag=false
        for k,v in pairs(sVo.cfg.skillBaseType) do
            if(v==tankType)then
                flag=true
                break
            end
        end
        if(flag)then
            local attributeType=sVo.cfg.attributeType
            local addValue=skillVoApi:getSkillAddPerById(sid)
            if(attributeType==100)then
                attack=addValue*tonumber(baseAttack)
            elseif(attributeType==102)then
                accurate=addValue*100
            elseif(attributeType==103)then
                avoid=addValue*100
            elseif(attributeType==104)then
                critical=addValue*100
            elseif(attributeType==105)then
                decritical=addValue*100
            elseif(attributeType==106)then
                critical=addValue*100
            elseif(attributeType==107)then
                decritical=addValue*100
            elseif(attributeType==108)then
                life=addValue*tonumber(baseLife)
            elseif(attributeType==109)then
            elseif(attributeType==110)then
                critDmg=addValue*100
            elseif(attributeType==111)then
                decritDmg=addValue*100
            elseif(attributeType==201)then
                armor=addValue
            elseif(attributeType==202)then
                penetrate=addValue
            end
        end
    end

    local per=0
    local addPerZ1=0
    local addPerZ2=0
    if tankCfg[id].type=="1" then
        addPerZ1=technologyVoApi:getAddPerById(1)
        addPerZ2=technologyVoApi:getAddPerById(2)
    elseif tankCfg[id].type=="2" then
        addPerZ1=technologyVoApi:getAddPerById(3)
        addPerZ2=technologyVoApi:getAddPerById(4)
        
    elseif tankCfg[id].type=="4" then
        addPerZ1=technologyVoApi:getAddPerById(5)
        addPerZ2=technologyVoApi:getAddPerById(6)
    elseif tankCfg[id].type=="8" then
        addPerZ1=technologyVoApi:getAddPerById(7)
        addPerZ2=technologyVoApi:getAddPerById(8)
    end
    
    attack=attack + addPerZ1*tonumber(baseAttack)/100
    life=life + addPerZ2*tonumber(baseLife)/100
    
    local alliacnePer1,alliacnePer2,alliacnePer3,alliacnePer4=0,0,0,0
    if allianceSkillVoApi:getSkillLevel(11)>0 then
        alliacnePer1=tonumber(allianceSkillCfg[11]["value"][allianceSkillVoApi:getSkillLevel(11)])
    end
    if allianceSkillVoApi:getSkillLevel(12)>0 then
        alliacnePer2=tonumber(allianceSkillCfg[12]["value"][allianceSkillVoApi:getSkillLevel(12)])
    end
    if allianceSkillVoApi:getSkillLevel(13)>0 then
        alliacnePer3=tonumber(allianceSkillCfg[13]["value"][allianceSkillVoApi:getSkillLevel(13)])
    end
    if allianceSkillVoApi:getSkillLevel(14)>0 then
        alliacnePer4=tonumber(allianceSkillCfg[14]["value"][allianceSkillVoApi:getSkillLevel(14)])
    end

    accurate=accurate + alliacnePer1
    avoid=avoid + alliacnePer2
    critical=critical + alliacnePer3
    decritical=decritical + alliacnePer4

    --配件关卡科技和军衔属性加成
    local attackAdd,lifeAdd,accurateAdd,avoidAdd,criticalAdd,decriticalAdd,armorAdd,penetrateAdd,critAccesoryAdd,decritAccesoryAdd=self:getTankAddNum(id,baseAttackAlienAdd,baseLifeAlienAdd)
    attack=attack+attackAdd
    life=life+lifeAdd
    accurate=accurate+accurateAdd+accurateAlienAdd
    avoid=avoid+avoidAdd+avoidAlienAdd
    critical=critical+criticalAdd+criticalAlienAdd
    decritical=decritical+decriticalAdd+decriticalAlienAdd
    armor=armor+armorAdd+armorAlienAdd
    penetrate=penetrate+penetrateAdd+penetrateAlienAdd
    critDmg=critDmg+critDmgAlienAdd+critAccesoryAdd
    decritDmg=decritDmg+decritDmgAlienAdd+decritAccesoryAdd
    baseAttackAdd=baseAttackAdd+baseAttackAlienAdd
    baseLifeAdd=baseLifeAdd+baseLifeAlienAdd
    skillAdd=skillAdd+skillAlienAdd

    if base.isAf == 1 then
        -- 军团旗帜属性添加
        local allianceAddAttr = allianceVoApi:getFlagUnLockAttr()
        if allianceAddAttr and next(allianceAddAttr) and allianceAddAttr["106"] and allianceAddAttr["106"] > 0 then
            -- 暴击
            critical = allianceAddAttr["106"] + critical
        end
        if allianceAddAttr and next(allianceAddAttr) and allianceAddAttr["107"] and allianceAddAttr["107"] > 0 then
            -- 装甲
            decritical = allianceAddAttr["107"] + decritical
        end
        if allianceAddAttr and type(allianceAddAttr)=="table" then
            accurate = (allianceAddAttr["102"] or 0) + accurate --精准
            avoid = (allianceAddAttr["103"] or 0) + avoid --闪避
        end
    end
    if base.isSkin then
        --闪避，精准,暴击,装甲,击破,防护
        dodge, precision, crit, armorNew, breaks, protection = buildDecorateVoApi:getTankPropertyAdding()
        avoid      = avoid + dodge
        accurate   = accurate + precision
        critical   = critical + crit
        decritical = decritical + armorNew
        penetrate  = penetrate + breaks
        armor      = armor + protection
    end

    local skinAttriTb = tankSkinVoApi:getAttributeByTankId(id) or {} --坦克皮肤属性总加成
    attack=attack+(skinAttriTb["dmg"] or 0) --攻击
    life=life+(skinAttriTb["maxhp"] or 0) --血量
    accurate=accurate+(skinAttriTb["accuracy"] or 0) --精准
    avoid=avoid+(skinAttriTb["evade"] or 0) --闪避
    critical=critical+(skinAttriTb["crit"] or 0) --暴击
    decritical=decritical+(skinAttriTb["decritical"] or 0) --装甲
    armor=armor+(skinAttriTb["armor"] or 0) --防护
    decritical=decritical+(skinAttriTb["anticrit"] or 0) --装甲
    decritDmg=decritDmg+(skinAttriTb["decritDmg"] or 0) --韧性
    critDmg=critDmg+(skinAttriTb["critDmg"] or 0) --暴伤
    penetrate=penetrate+(skinAttriTb["arp"] or 0) --击破

    --//////////// 【战略中心技能属性】 start
    for i = 1, 2 do
        local scAddValue
        if i == 1 then
            scAddValue = strategyCenterVoApi:getAttributeValue(1)--基础属性
        else
            if tankCfg[id].type == "1" then --坦克
                scAddValue = strategyCenterVoApi:getAttributeValue(4)--坦克属性增加
            elseif tankCfg[id].type == "2" then --歼击车
                scAddValue = strategyCenterVoApi:getAttributeValue(7)--歼击车属性增加
            elseif tankCfg[id].type == "4" then --自行火炮
                scAddValue = strategyCenterVoApi:getAttributeValue(5)--火炮属性增加
            elseif tankCfg[id].type == "8" then --火箭车
                scAddValue = strategyCenterVoApi:getAttributeValue(6)--火箭车属性增加
            end
        end
        if scAddValue then
            if scAddValue["atk"] then --攻击
                if scAddValue["atk"].percent == 1 then
                    attack = attack + baseAttack * (scAddValue["atk"].value or 0)
                else
                    attack = attack + (scAddValue["atk"].value or 0)
                end
            end
            if scAddValue["hp"] then --血量
                if scAddValue["hp"].percent == 1 then
                    life = life + baseLife * (scAddValue["hp"].value or 0)
                else
                    life = life + (scAddValue["hp"].value or 0)
                end
            end
            if scAddValue["accuracy"] then --精准
                if scAddValue["accuracy"].percent == 1 then
                    accurate = accurate + (scAddValue["accuracy"].value or 0) * 100
                else
                    accurate = accurate + (scAddValue["accuracy"].value or 0)
                end
            end
            if scAddValue["evade"] then --闪避
                if scAddValue["evade"].percent == 1 then
                    avoid = avoid + (scAddValue["evade"].value or 0) *100
                else
                    avoid = avoid + (scAddValue["evade"].value or 0)
                end
            end
            if scAddValue["crit"] then --暴击
                if scAddValue["crit"].percent == 1 then
                    critical = critical + (scAddValue["crit"].value or 0) * 100
                else
                    critical = critical + (scAddValue["crit"].value or 0)
                end
            end
            if scAddValue["anticrit"] then --装甲
                if scAddValue["anticrit"].percent == 1 then
                    decritical = decritical + (scAddValue["anticrit"].value or 0) * 100
                else
                    decritical = decritical + (scAddValue["anticrit"].value or 0)
                end
            end
            if scAddValue["arp"] then --击破
                if scAddValue["arp"].percent == 1 then
                    penetrate = penetrate + penetrate * (scAddValue["arp"].value or 0)
                else
                    penetrate = penetrate + (scAddValue["arp"].value or 0)
                end
            end
            if scAddValue["armor"] then --防护
                if scAddValue["armor"].percent == 1 then
                    armor = armor + armor * (scAddValue["armor"].value or 0)
                else
                    armor = armor + (scAddValue["armor"].value or 0)
                end
            end
            if scAddValue["critDmg"] then --暴伤
                if scAddValue["critDmg"].percent == 1 then
                    critDmg = critDmg + (scAddValue["critDmg"].value or 0) * 100
                else
                    critDmg = critDmg + (scAddValue["critDmg"].value or 0)
                end
            end
            if scAddValue["hlp"] then --韧性
                if scAddValue["hlp"].percent == 1 then
                    decritDmg = decritDmg + (scAddValue["hlp"].value or 0) * 100
                else
                    decritDmg = decritDmg + (scAddValue["hlp"].value or 0)
                end
            end
        end
    end
    --//////////// 【战略中心技能属性】 end

    return attack,life,accurate,avoid,critical,decritical,armor,penetrate,critDmg,decritDmg,baseAttackAdd,baseLifeAdd,skillAdd;
end

--获取配件关卡科技和军衔对坦克属性加成数据,{攻击，血量，精准，闪避，暴击，装甲，防护，击破}
function tankVoApi:getTankAddNum(id,baseAttackAlienAdd,baseLifeAlienAdd)
    local baseAttack=tonumber(tankCfg[id].attack)
    local baseLife=tonumber(tankCfg[id].life)
    if baseAttackAlienAdd and tonumber(baseAttackAlienAdd) then
        baseAttack=baseAttack+tonumber(baseAttackAlienAdd)
    end
    if baseLifeAlienAdd and tonumber(baseLifeAlienAdd) then
        baseLife=baseLife+tonumber(baseLifeAlienAdd)
    end

    local attackAdd,lifeAdd,accurateAdd,avoidAdd,criticalAdd,decriticalAdd,armorAdd,penetrateAdd,critAccesoryAdd,decritAccesoryAdd=0,0,0,0,0,0,0,0,0,0
    --配件对坦克属性加成数据
    if base.ifAccessoryOpen==1 then
        if id and accessoryVoApi then
            if tankCfg and tankCfg[id] and tankCfg[id].type then
                local equipAddTab=accessoryVoApi:getTankAttAdd(tankCfg[id].type)
                local eAttackAdd=tonumber(equipAddTab[1]) or 0
                local eLifeAdd=tonumber(equipAddTab[2]) or 0
                local eArmorAdd=tonumber(equipAddTab[3]) or 0
                local ePenetrateAdd=tonumber(equipAddTab[4]) or 0
                critAccesoryAdd=tonumber(equipAddTab[5]) or 0
                decritAccesoryAdd=tonumber(equipAddTab[6]) or 0
                eAttackAdd=(eAttackAdd/100)*baseAttack
                eLifeAdd=(eLifeAdd/100)*baseLife
                --保留2位小数
                eAttackAdd=G_keepNumber(eAttackAdd,2)
                eLifeAdd=G_keepNumber(eLifeAdd,2)

                attackAdd=attackAdd+eAttackAdd
                lifeAdd=lifeAdd+eLifeAdd
                armorAdd=armorAdd+eArmorAdd
                penetrateAdd=penetrateAdd+ePenetrateAdd
            end
        end
    end

    --关卡科技对坦克属性加成数据,{资源，攻击，血量，精准，闪避，暴击，装甲}
    if checkPointVoApi then
        local techAddTab=checkPointVoApi:getTechAddNum()
        if techAddTab and SizeOfTable(techAddTab)>0 then
            local techAttackAdd=G_keepNumber((tonumber(techAddTab[2]) or 0)*baseAttack,2)
            local techLifeAdd=G_keepNumber((tonumber(techAddTab[3]) or 0)*baseLife,2)
            local techAccurateAdd=tonumber(techAddTab[4])*100 or 0
            local techAvoidAdd=tonumber(techAddTab[5])*100 or 0
            local techCriticalAdd=tonumber(techAddTab[6])*100 or 0
            local techDeCriticalAdd=tonumber(techAddTab[7])*100 or 0

            attackAdd=attackAdd+techAttackAdd
            lifeAdd=lifeAdd+techLifeAdd
            accurateAdd=accurateAdd+techAccurateAdd
            avoidAdd=avoidAdd+techAvoidAdd
            criticalAdd=criticalAdd+techCriticalAdd
            decriticalAdd=decriticalAdd+techDeCriticalAdd
        end
    end

    --军衔对于属性的加成 
    local rankAttAdd=playerVoApi:getRankAttAdd()
    local rankAttackAdd
    local rankHpAdd
    if(rankAttAdd[1])then
        rankAttackAdd=G_keepNumber(baseAttack*rankAttAdd[1],2)
    else
        rankAttackAdd=0
    end
    if(rankAttAdd[2])then
        rankHpAdd=G_keepNumber(baseLife*rankAttAdd[2],2)
    else
        rankHpAdd=0
    end
    attackAdd=attackAdd+rankAttackAdd
    lifeAdd=lifeAdd+rankHpAdd
    return attackAdd,lifeAdd,accurateAdd,avoidAdd,criticalAdd,decriticalAdd,armorAdd,penetrateAdd,critAccesoryAdd,decritAccesoryAdd
end


--取所有现在拥有的坦克按从牛逼到二逼的顺序排列(不包含已经出征的坦克)
function tankVoApi:getAllTanksInByType(type)
    local tankTb={}
    --type 1:进攻坦克 2:关卡坦克 3:防守坦克 4:军团战 5:竞技场 7,8,9:跨服个人战第1,2,3场 12:世界boss，13，14，15：世界争霸部队1，2，3
    if type==1 then
        tankTb=self.attackTanks
    elseif type==2 then
        tankTb=self.storyTanks
    elseif type==3 then
        tankTb=self.defenseTanks
    elseif type==4 then
        tankTb=self.allianceWarTanks
    elseif type==5 then
        tankTb=self.arenaTanks
    elseif type==12 then
        tankTb=self.bossbattleTanks
    elseif type==7 or type==8 or type==9 then --3场坦克不能复用
        for i=1,3 do
            -- if type-6~=i then
                if self["serverWarTanks"..i] then
                    for k,v in pairs(self["serverWarTanks"..i]) do
                        if v and v[1] and v[2] and v[2]>0 then
                            local isHas=false
                            for m,n in pairs(tankTb) do
                                if n and n[1] and n[2] and v[1]==n[1] then
                                    tankTb[m][2]=tankTb[m][2]+v[2]
                                    isHas=true
                                end 
                            end
                            if isHas==false then
                                table.insert(tankTb,{v[1],v[2]})
                            end
                        end
                    end
                end
            -- end
        end
    elseif type==10 then
        tankTb=self.serverWarTeamTanks
    elseif type==11 then
        tankTb=self.expeditionTanks
    elseif type==13 then
        tankTb=self.worldWarTanks1
    elseif type==14 then
        tankTb=self.worldWarTanks2
    elseif type==15 then
        tankTb=self.worldWarTanks3
    -- elseif type==13 or type==14 or type==15 then
    --     local index=type-12
    --     if self["worldWarTanks"..index] then
    --         for k,v in pairs(self["worldWarTanks"..index]) do
    --             if v and v[1] and v[2] and v[2]>0 then

    --             end
    --         end
    --     end
    elseif type==16 then
        tankTb=self.alienMinesTanks
    elseif type==17 then
        tankTb=self.localWarTanks
    elseif type==18 then
        tankTb=self.localWarCurTanks
    elseif type==19 then
        tankTb=self.swAttackTanks
    elseif type==20 then
        tankTb=self.swDefenceTanks
    elseif type==21 then
        tankTb=self.platWarTanks1
    elseif type==22 then
        tankTb=self.platWarTanks2
    elseif type==23 then
        tankTb=self.platWarTanks3
    elseif type==24 then
        tankTb=self.serverWarLocalTanks1
    elseif type==25 then
        tankTb=self.serverWarLocalTanks2
    elseif type==26 then
        tankTb=self.serverWarLocalTanks3
    elseif type==27 then
        tankTb=self.serverWarLocalCurTanks1
    elseif type==28 then
        tankTb=self.serverWarLocalCurTanks2
    elseif type==29 then
        tankTb=self.serverWarLocalCurTanks3
    elseif type==30 then
        tankTb=self.newYearBossTanks
    elseif type==31 then
        tankTb=self.allianceWar2CurTanks
    elseif type==32 then
        tankTb=self.allianceWar2Tanks
    elseif type==33 then
        tankTb=self.dimensionalWarTanks
    elseif type==34 then
        tankTb=self.serverWarTeamCurTanks
    elseif type==38 then
        tankTb=self.championshipWarPersonalTanks
    elseif type==39 then
        tankTb=self.championshipWarTanks
    end

    
    local tab={}
    local num=0;

    if type==11 then
        local tTb = G_clone(self.allTanks)
        for k,v in pairs(tTb) do
            num=v[1]
            local tb1,tb2=expeditionVoApi:getDeadTank()
            local dnum=tb2["a"..k]
            if dnum~=nil then
                v[1]=v[1]-dnum
                if v[1]<0 then
                    v[1]=0
                end
            end
        end


        for k,v in pairs(tTb) do
             if #tankTb~=0 then
                num=v[1];
                for i,j in pairs(tankTb) do
                    if j[1]==k then
                        num=num-j[2]
                    end
                end
                if num~=0 then
                    tab[k]={num}
                end
            else
                tab[k]=v
            end
      
        end
    elseif type==13 or type==14 or type==15 or type==21 or type==22 or type==23 or type==24 or type==25 or type==26 or type==39 then
        local tTempTanks
        local rate=1
        if type==13 or type==14 or type==15 then
            tTempTanks=self:getWorldWarTempTanks()
            if worldWarCfg and worldWarCfg.tankeTransRate then
                rate=worldWarCfg.tankeTransRate
            end
        elseif type==21 or type==22 or type==23 then
            tTempTanks=self:getPlatWarTempTanks()
            if platWarCfg and platWarCfg.tankeTransRate then
                rate=platWarCfg.tankeTransRate
            end
        elseif type==24 or type==25 or type==26 then
            tTempTanks=self:getServerWarLocalTempTanks()
            if serverWarLocalCfg and serverWarLocalCfg.tankeTransRate then
                rate=serverWarLocalCfg.tankeTransRate
            end
        elseif type==39 then --军团锦标赛军团战个人设置部队
            tTempTanks=self.championshipWarTempTanks
            if championshipWarVoApi then
                local warCfg=championshipWarVoApi:getWarCfg()
                if warCfg and warCfg.tankeTransRate then
                    rate=warCfg.tankeTransRate
                end
            end
        end
        local allTb = G_clone(self.allTanks)
        for k,v in pairs(allTb) do
            v[1]=v[1]*rate
        end
        if tTempTanks then
            for k,v in pairs(tTempTanks) do
                if v and v[1] and v[2] then
                    local tid=v[1]
                    local num=tonumber(v[2]) or 0
                    if allTb[tid] then
                        if allTb[tid][1] then
                            allTb[tid][1]=allTb[tid][1]+num
                        else
                            allTb[tid][1]=num
                        end
                    else
                        allTb[tid]={num}
                    end
                end
            end
        end
        for k,v in pairs(allTb) do
            num=v[1]
            if #tankTb~=0 then
                for i,j in pairs(tankTb) do
                    if j[1]==k then
                        -- num=num-math.ceil(j[2]/rate)*rate
                        num=num-j[2]
                    end
                end
                if num~=0 then
                    tab[k]={num}
                end
            else
                tab[k]={num}
            end
        end
    elseif type==17 or type==32 or type==33 then
        local allTb = G_clone(self.allTanks)
        local tTempTanks
        local rate=1
        if type==17 then
            tTempTanks=self:getLocalWarTempTanks()
            if localWarCfg and localWarCfg.tankeTransRate then
                rate=localWarCfg.tankeTransRate
            end
        elseif type==32 then
            tTempTanks=self:getAllianceWar2TempTanks()
            if allianceWar2Cfg and allianceWar2Cfg.tankeTransRate then
                rate=allianceWar2Cfg.tankeTransRate
            end
        elseif type==33 then
            tTempTanks=self:getDimensionalWarTempTanks()
            if userWarCfg and userWarCfg.tankeTransRate then
                rate=userWarCfg.tankeTransRate
            end
        end
        for k,v in pairs(allTb) do
            v[1]=v[1]*rate
        end
        if tTempTanks then
            for k,v in pairs(tTempTanks) do
                if v and v[1] and v[2] then
                    local tid=v[1]
                    local num=tonumber(v[2]) or 0
                    if allTb[tid] then
                        if allTb[tid][1] then
                            allTb[tid][1]=allTb[tid][1]+num
                        else
                            allTb[tid][1]=num
                        end
                    else
                        allTb[tid]={num}
                    end
                end
            end
        end
        for k,v in pairs(allTb) do
            num=v[1]
            if #tankTb~=0 then
                for i,j in pairs(tankTb) do
                    if j[1]==k then
                        -- num=num-math.ceil(j[2]/rate)*rate
                        num=num-j[2]
                    end
                end
                if num~=0 then
                    tab[k]={num}
                end
            else
                tab[k]={num}
            end
        end
    else
        for k,v in pairs(self.allTanks) do
        
            if #tankTb~=0 then

                num=v[1];
                for i,j in pairs(tankTb) do
                    if j[1]==k then
                        num=num-j[2]
                    end
                end
                if num~=0 then
                    tab[k]={num}
                end
            else
                tab[k]=v
            end
        end
    end

    
    
        
    local keyTb={}
    local keyTb2={}
    for k,v in pairs(tab) do
        table.insert(keyTb,{key=k})
    end
    local bcfg=buildingCfg[6]
    local proSid=Split(bcfg.buildPropSids,",")
    local resultType={}
    for kk=1,#proSid do
        if kk%2==0 then
            table.insert(resultType,tonumber(proSid[kk]))
        end
    end
    for kk=1,#playerCfg.addedTanks do
        table.insert(resultType,tonumber(playerCfg.addedTanks[kk]))
    end

    for kk=#resultType,1,-1 do
        
        for k,v in pairs(keyTb) do
            local yinsheId = G_pickedList(v.key)
            if tonumber(resultType[kk])==yinsheId and tab[v.key][1]>0 then
                local sortId=tonumber(tankCfg[v.key].sortId)
                table.insert(keyTb2,{v,sortId})
                
            end
        end
    end

    --按sortId排序
    local sortTb=function(a,b)
        return a[2]>b[2]
    end
    table.sort(keyTb2,sortTb)
    local tempTb={}
    for k,v in pairs(keyTb2) do
        table.insert(tempTb,v[1])
    end


    return tempTb,tab

end

--取出坦克载重量
function tankVoApi:getAttackTanksCarryResource(tankTb)-- 部队数量，军团科技，军团旗帜，个人技能
    local carryResource=0
    if SizeOfTable(tankTb)>0 then
        for k,v in pairs(tankTb) do
            if v~=nil and SizeOfTable(v)>0 then
                carryResource=carryResource+tankCfg[v[1]].carryResource*v[2]
            end
        end
    end
    
    local perAllianceSkill=0
    if allianceSkillVoApi:getSkillLevel(5)>0 then
        perAllianceSkill=tonumber(allianceSkillCfg[5]["capacityValue"][allianceSkillVoApi:getSkillLevel(5)])
    end

    local flagAddValue = 0
    if base.isAf == 1 then
        -- 军团旗帜属性添加
        local allianceAddAttr = allianceVoApi:getFlagUnLockAttr()
        if allianceAddAttr and next(allianceAddAttr) and allianceAddAttr["1001"] and allianceAddAttr["1001"] > 0 then
            -- 载重
            flagAddValue = allianceAddAttr["1001"]
        end
    end
    local pskillAdd = planeRefitVoApi:getSkvByType(60) --战机改装技能加成
    carryResource=carryResource*(100+perAllianceSkill+flagAddValue+pskillAdd*100)/100
    local skillAdd=skillVoApi:getSkillAddPerById("s202")
    if(skillAdd>0)then
        carryResource=carryResource*(1 + skillAdd)
    end

    return carryResource;
end

--清理修理的坦克
function tankVoApi:clearRepairTanks()
    for k,v in pairs(self.allTanks) do
        v[3]=0
    end
end

--添加需要修理的坦克
function tankVoApi:setRepairTanks(id,num)
    
    if self.allTanks[id]==nil then
        self.allTanks[id]={0,0,num}
    else
        self.allTanks[id][3]=num
    end
    
    
end
--取出需要修理的坦克
function tankVoApi:getRepairTanks()
    local repairTanks={}
    
    for k,v in pairs(self.allTanks) do
        if v[3]~=nil and v[3]>0 then
            table.insert(repairTanks,{k,v[3]})
        end
    end
    return repairTanks

end

--更改固定防守坦克
function tankVoApi:setTemDefenseTanks(id,tid,num)
    if num and num==0 then
        self.temDefenseTanks[id]={}
    else
        self.temDefenseTanks[id]={tid,num}
    end
end
--清空固定防守坦克
function tankVoApi:clearTemDefenseTanks()
    self.temDefenseTanks={}
    self.temDefenseTanks={{},{},{},{},{},{}}
end
--取出固定防守坦克
function tankVoApi:getTemDefenseTanks()

    return self.temDefenseTanks;
end

--计算最大战斗力公式
function tankVoApi:getBestTanksFighting(id,num)
    local fightAll=0
    fightAll=self:getSingleTankFighting(id)*math.pow(num,0.7)
    return fightAll
end

--取出当前拥有的单体战斗力最高的坦克
--return tankID or nil, nil表示没有坦克
function tankVoApi:getBestTankOwn()
    local bestPower=0
    local bestID
    for k,v in pairs(self.allTanks) do
        local fight=self:getBestTanksFighting(k,1)
        if(fight>bestPower)then
            bestPower=fight
            bestID=k
        end
    end
    return bestID
end

--type:7,8,9   个人跨服战，本场比赛可以选择的坦克
function tankVoApi:getServerWarTanksByType(type)
    local tankTb={}
    for i=1,3 do
        if type-6~=i then
            if self["serverWarTanks"..i] then
                for k,v in pairs(self["serverWarTanks"..i]) do
                    if v and v[1] and v[2] and v[2]>0 then
                        local isHas=false
                        for m,n in pairs(tankTb) do
                            if n and n[1] and n[2] and v[1]==n[1] then
                                tankTb[m][2]=tankTb[m][2]+v[2]
                                isHas=true
                            end 
                        end
                        if isHas==false then
                            table.insert(tankTb,{v[1],v[2]})
                        end
                    end
                end
            end
        end
    end 
    local tab={}
    local num=0;
    for k,v in pairs(self.allTanks) do
        
        if #tankTb~=0 then
            num=v[1];
            for i,j in pairs(tankTb) do
                if j[1]==k then
                    num=num-j[2]
                end
            end
            if num~=0 then
                tab[k]={num}
            end
        else
            tab[k]=v
        end
    end
    return tab
end

--取出最大战斗力坦克队列
--type:7,8,9 个人跨服战坦克，3场不能复用
function tankVoApi:getBestTanks(tType)
    -- 判断军徽开关，选择强度最高的军徽
    local maxEmblemID = nil
    if emblemVoApi:checkIfHadEquip()==true then
        maxEmblemID = emblemVoApi:getMaxStrongEquip(tType)
        emblemVoApi:setTmpEquip(maxEmblemID,tType)
    end
    -- 判断飞机开关，选择强度最高的飞机
    local maxPlanePos = nil
    if base.plane==1 and planeVoApi:getPlaneTotalNum()>0 then
        maxPlanePos = planeVoApi:getMaxStrongEquip(tType)
        planeVoApi:setTmpEquip(maxPlanePos,tType)
    end
    local bestAirshipId = airShipVoApi:getBestAirship(tType)
    airShipVoApi:setTempLineupId(bestAirshipId, tType)
    -- local lasttime = G_getCurDeviceMillTime()
    -- print("获取最大战力坦克列表开始时间==========",lasttime)
    local bestTab={}

    local temTanks={}
    if tType and (tType==7 or tType==8 or tType==9) then
        temTanks=self:getServerWarTanksByType(tType)
    elseif tType and tType==11 then
        local tab={}
        local num=0;
        for k,v in pairs(self.allTanks) do
            num=v[1];
            local tb1,tb2=expeditionVoApi:getDeadTank()
            local dnum=tb2["a"..k]
            if dnum~=nil then
                num=num-dnum
                if num<0 then
                    num=0
                end
            end
            if num~=0 then
                tab[k]={num}
            end

        end
        temTanks=tab
    elseif tType and (tType==13 or tType==14 or tType==15 or tType==21 or tType==22 or tType==23 or tType==24 or tType==25 or tType==26 ) then --世界争霸和平台战 最大数量为坦克数量*配置比例
        local rate=1
        local tTempTanks
        if tType==13 or tType==14 or tType==15 then
        if worldWarCfg and worldWarCfg.tankeTransRate then
                rate=tonumber(worldWarCfg.tankeTransRate)
            end
            tTempTanks=self:getWorldWarTempTanks()
        elseif tType==21 or tType==22 or tType==23 then
            if platWarCfg and platWarCfg.tankeTransRate then
                rate=tonumber(platWarCfg.tankeTransRate)
            end
            tTempTanks=self:getPlatWarTempTanks()
        elseif tType==24 or tType==25 or tType==26 then
            if serverWarLocalCfg and serverWarLocalCfg.tankeTransRate then
                rate=tonumber(serverWarLocalCfg.tankeTransRate)
            end
            tTempTanks=self:getServerWarLocalTempTanks()
        end
        if tTempTanks and rate then
            temTanks=G_clone(self.allTanks)
            for k,v in pairs(temTanks) do
                temTanks[k][1]=temTanks[k][1]*rate
            end
            for k,v in pairs(tTempTanks) do
                if v and v[1] and v[2] then
                    local tid=v[1]
                    local num=tonumber(v[2])
                    if temTanks[tid] and temTanks[tid][1] then
                        temTanks[tid][1]=temTanks[tid][1]+num
                    else
                        if temTanks[tid]==nil then
                            temTanks[tid]={}
                        end
                        temTanks[tid][1]=num
                    end
                end
            end
        else
            temTanks=self.allTanks
        end
    elseif tType and (tType==17 or tType==32 or tType==33 or tType==39) then --区域战，军团战，异元战场报名，军团锦标赛军团战个人报名：最大数量为坦克数量*配置比例
        local rate=1
        if tType==17 then
            if localWarCfg and localWarCfg.tankeTransRate then
                rate=tonumber(localWarCfg.tankeTransRate)
            end
        elseif tType==32 then
            if allianceWar2Cfg and allianceWar2Cfg.tankeTransRate then
                rate=tonumber(allianceWar2Cfg.tankeTransRate)
            end
        elseif tType==33 then
            if userWarCfg and userWarCfg.tankeTransRate then
                rate=tonumber(userWarCfg.tankeTransRate)
            end
        elseif tType==39 then --军团锦标赛军团战个人设置部队
            if championshipWarVoApi then
                local warCfg=championshipWarVoApi:getWarCfg()
                if warCfg and warCfg.tankeTransRate then
                    rate=tonumber(warCfg.tankeTransRate)
                end
            end
        end
        if rate then
            temTanks=G_clone(self.allTanks)
            for k,v in pairs(temTanks) do
                temTanks[k][1]=temTanks[k][1]*rate
            end
        else
            temTanks=self.allTanks
        end
    else
        temTanks=self.allTanks
    end
    local num=playerVoApi:getTotalTroops(tType)
    local singleTankFighting={}
    for k,v in pairs(temTanks) do
        singleTankFighting[k]=self:getSingleTankFighting(k)
        local numTank=v[1]
        if numTank>num then
            local count=math.floor(numTank/num)
            if count>6 then
                count=6
            end
            for i=1,count,1 do
                table.insert(bestTab, {k,num,math.pow(num,0.7)*singleTankFighting[k]})
            end
            local otherCount=numTank%num
            if otherCount>0 then
                table.insert(bestTab, {k,otherCount,math.pow(otherCount,0.7)*singleTankFighting[k]})
            end
            

        else
            if numTank>0 then
                table.insert(bestTab, {k,numTank,math.pow(numTank,0.7)*singleTankFighting[k]})
            end
        end
    end
    -- local bestTab2={}
    
    -- for k,v in pairs(bestTab) do
    --     -- local fight=self:getBestTanksFighting(v[1],v[2])
    --     local fight=math.pow(v[2],0.7)*singleTankFighting[v[1]]
    --     table.insert(bestTab2, {v[1],v[2],fight})
    -- end
    local typeTb=self:getAllTankTypeAndCoutByBid(11)
    

    local sortTb=function(a,b)
        return a[3]>b[3]
    --[[
        if a[3]>b[3] then
            do
            return a[3]>b[3]
            end
        elseif a[3]==b[3] then
            local idx1,idx2
            for k,v in pairs(typeTb) do
                if a[1]==v then
                    idx1=k;
                end
                if b[1]==v then
                    idx2=k
                end
            end
            
            if idx1>=idx2 then
                do
                return a[1]>b[1]
                end
            else
                do
                return a[1]<b[1]
                end
            end
        
        else
            do
            return a[3]<b[3]
            end
        
        end

        ]]--
    end
    table.sort(bestTab,sortTb)

    
    local resultTb={}
    for k,v in pairs(bestTab) do
        if k<=6 and v[2]>0 then
            table.insert(resultTb,k,v)
        end
    
    end

    local heroTb=heroVoApi:bestHero(tType,resultTb)


    local AITroops=AITroopsFleetVoApi:bestAITroops(tType, resultTb)
    -- local curtime = G_getCurDeviceMillTime()
    -- print("获取最大战力坦克列表结束时间==========",curtime)
    -- print("获取最大战力坦克列表总耗时间==========",curtime-lasttime)

    
    return resultTb,heroTb,maxEmblemID,maxPlanePos,AITroops,bestAirshipId

end

--取出最大战力表（按格式）
function tankVoApi:getBestTankTb()
    local tankTb={{},{},{},{},{},{}}
    local bestTb=self:getBestTanks()
    for k,v in pairs(bestTb) do
        tankTb[k][1]=v[1]
        tankTb[k][2]=v[2]
    end
    return tankTb
end



--军团板子是否该显示叹号
function tankVoApi:checkIsIconShow()
    local num1=0
    for k,v in pairs(self.allianceWarHoldTanks) do
        if v[1]==nil then
            num1=num1+1
        end
    end
    local num2=0
    for k,v in pairs(self.allianceWarTanks) do
        if v[1]==nil then
            num2=num2+1
        end
    end
    if num1==6 and num2==6 then
        return true
    else
        return false
    end
end




--获取基地里面的坦克
function tankVoApi:getAllTanksInBase()
    local baseTanks={}
    for k,v in pairs(self.allTanks) do
        if(tankCfg[k].inWarehouse~=true)then
            baseTanks[k]=v
        end
    end
    return baseTanks
end

-- (精英坦克和普通坦克重合，只在坦克info中区别数量)
function tankVoApi:getTanksInBase()
    local baseTanks=self:getAllTanksInBase()
    local putongTanks = {}
    for k,v in pairs(baseTanks) do
        if k==G_pickedList(k) then
            local danduV = G_clone(v)
            danduV[1]=danduV[1]+self:getTankCountByItemId(k+40000)
            putongTanks[k]=danduV
        else
            local tid = G_pickedList(k)
            if self:getTankCountByItemId(tid)==0 then
                local danduV = G_clone(v)
                putongTanks[tid]=danduV
            end
        end
    end
    return putongTanks
end

--获取地库里面的坦克
function tankVoApi:getAllTanksInWarehouse()
    local warehouseTanks={}
    for k,v in pairs(self.allTanks) do
        if(tankCfg[k].inWarehouse)then
            warehouseTanks[k]=v
        end
    end
    return warehouseTanks
end

-- (精英坦克和普通坦克重合，只在坦克info中区别数量)
function tankVoApi:getTanksInWarehouse()
    local warehouseTanks=self:getAllTanksInWarehouse()
    local putongTanks = {}
    for k,v in pairs(warehouseTanks) do
        if k==G_pickedList(k) then
            local danduV = G_clone(v)
            danduV[1]=danduV[1]+self:getTankCountByItemId(k+40000)
            putongTanks[k]=danduV
        else
            local tid = G_pickedList(k)
            if self:getTankCountByItemId(tid)==0 then
                local danduV = G_clone(v)
                putongTanks[tid]=danduV
            end
        end
    end
    return putongTanks
end

--获取坦克工厂对应等级解锁的坦克
function tankVoApi:getUnlockTankByBarrackLv(level)
    local bcfg=buildingCfg[6]
    local proSid=Split(bcfg.buildPropSids,",")
    for kk=1,#proSid do
        if kk%2==0 then
            if level and tonumber(proSid[kk-1])==tonumber(level) then
                return tonumber(proSid[kk])
            end
        end
    end
    return nil
end

--获取玩家可以制造的战斗力最高的坦克
function tankVoApi:getBestTankCanProduce()
    local bVo=buildingVoApi:getBuildingVoByLevel(6)
    if(bVo==nil)then
        return nil
    end
    local allTanks,lockTanks,countTanks=self:getAllTankTypeAndCoutByBid(bVo.id)
    local maxPower=0
    local maxID
    for k,v in pairs(allTanks) do
        if(lockTanks[k]==0)then
            local power=self:getBestTanksFighting(v,1)
            if(power>=maxPower)then
                maxPower=power
                maxID=v
            end
        end
    end
    return maxID,maxPower
end

--type 1:防守坦克 3:关卡坦克
--清空坦克tb
function tankVoApi:clearTanksTbByType(type)
    if type==1 then
        self.defenseTanks={}
        self.defenseTanks={{},{},{},{},{},{}}
    elseif type==2 then
        self.attackTanks={}
        self.attackTanks={{},{},{},{},{},{}}
    elseif type==3 then
        self.storyTanks={}
        self.storyTanks={{},{},{},{},{},{}}
    elseif type==4 then
        self.allianceWarTanks={}
        self.allianceWarTanks={{},{},{},{},{},{}}
    elseif type==5 then
        self.arenaTanks={}
        self.arenaTanks={{},{},{},{},{},{}}
    elseif type==6 then
        self.allianceWarHoldTanks={}
        self.allianceWarHoldTanks={{},{},{},{},{},{}}
    elseif type==7 then
        self.serverWarTanks1={}
        self.serverWarTanks1={{},{},{},{},{},{}}
    elseif type==8 then
        self.serverWarTanks2={}
        self.serverWarTanks2={{},{},{},{},{},{}}
    elseif type==9 then
        self.serverWarTanks3={}
        self.serverWarTanks3={{},{},{},{},{},{}}
    elseif type==10 then
        self.serverWarTeamTanks={}
        self.serverWarTeamTanks={{},{},{},{},{},{}}
    elseif type==11 then
        self.expeditionTanks={}
        self.expeditionTanks={{},{},{},{},{},{}}
    elseif type==12 then
        self.bossbattleTanks={}
        self.bossbattleTanks={{},{},{},{},{},{}}
    elseif type==13 then
        self.worldWarTanks1={}
        self.worldWarTanks1={{},{},{},{},{},{}}
    elseif type==14 then
        self.worldWarTanks2={}
        self.worldWarTanks2={{},{},{},{},{},{}}
    elseif type==15 then
        self.worldWarTanks3={}
        self.worldWarTanks3={{},{},{},{},{},{}}
    elseif type==16 then
        self.alienMinesTanks={}
        self.alienMinesTanks={{},{},{},{},{},{}}
    elseif type==17 then
        self.localWarTanks={}
        self.localWarTanks={{},{},{},{},{},{}}
    elseif type==18 then
        self.localWarCurTanks={}
        self.localWarCurTanks={{},{},{},{},{},{}}
    elseif type==19 then
        self.swAttackTanks={}
        self.swAttackTanks={{},{},{},{},{},{}}
    elseif type==20 then
        self.swDefenceTanks={}
        self.swDefenceTanks={{},{},{},{},{},{}}
    elseif type==21 then
        self.platWarTanks1={}
        self.platWarTanks1={{},{},{},{},{},{}}
    elseif type==22 then
        self.platWarTanks2={}
        self.platWarTanks2={{},{},{},{},{},{}}
    elseif type==23 then
        self.platWarTanks3={}
        self.platWarTanks3={{},{},{},{},{},{}}
    elseif type==24 then
        self.serverWarLocalTanks1={}
        self.serverWarLocalTanks1={{},{},{},{},{},{}}
    elseif type==25 then
        self.serverWarLocalTanks2={}
        self.serverWarLocalTanks2={{},{},{},{},{},{}}
    elseif type==26 then
        self.serverWarLocalTanks3={}
        self.serverWarLocalTanks3={{},{},{},{},{},{}}
    elseif type==27 then
        self.serverWarLocalCurTanks1={}
        self.serverWarLocalCurTanks1={{},{},{},{},{},{}}
    elseif type==28 then
        self.serverWarLocalCurTanks2={}
        self.serverWarLocalCurTanks2={{},{},{},{},{},{}}
    elseif type==29 then
        self.serverWarLocalCurTanks3={}
        self.serverWarLocalCurTanks3={{},{},{},{},{},{}}
    elseif type==30 then
        self.newYearBossTanks={}
        self.newYearBossTanks={{},{},{},{},{},{}}
    elseif type==31 then
        self.allianceWar2CurTanks={}
        self.allianceWar2CurTanks={{},{},{},{},{},{}}
    elseif type==32 then
        self.allianceWar2Tanks={}
        self.allianceWar2Tanks={{},{},{},{},{},{}}
    elseif type==33 then
        self.dimensionalWarTanks={}
        self.dimensionalWarTanks={{},{},{},{},{},{}}
    elseif type==34 then
        self.serverWarTeamCurTanks={}
        self.serverWarTeamCurTanks={{},{},{},{},{},{}}
    elseif type==35 then -- 领土争夺战 防守
        ltzdzFightApi:clearTanksTbByType(type)
    elseif type==36 then -- 领土争夺战 进攻
        ltzdzFightApi:clearTanksTbByType(type)
    elseif type==37 then --狂热集结挑战部队
        self.believerTanks={}
        self.believerTanks={{},{},{},{},{},{}}
    elseif type==38 then
        self.championshipWarPersonalTanks={}
        self.championshipWarPersonalTanks={{},{},{},{},{},{}}
    elseif type==39 then
        self.championshipWarTanks={}
        self.championshipWarTanks={{},{},{},{},{},{}}
    end
end

--取出坦克tb
function tankVoApi:getTanksTbByType(type)
    if type==1 then
        return self.defenseTanks
    elseif type==2 then
        return self.attackTanks
    elseif type==3 then
        return self.storyTanks
    elseif type==4 then
        return self.allianceWarTanks
    elseif type==5 then
        return self.arenaTanks
    elseif type==6 then
        return self.allianceWarHoldTanks
    elseif type==7 then
        return self.serverWarTanks1
    elseif type==8 then
        return self.serverWarTanks2
    elseif type==9 then
        return self.serverWarTanks3
    elseif type==10 then
        return self.serverWarTeamTanks
    elseif type==11 then
        return self.expeditionTanks
    elseif type==12 then
        return self.bossbattleTanks
    elseif type==13 then
        return self.worldWarTanks1
    elseif type==14 then
        return self.worldWarTanks2
    elseif type==15 then
        return self.worldWarTanks3
    elseif type==16 then
        return self.alienMinesTanks
    elseif type==17 then
        return self.localWarTanks
    elseif type==18 then
        return self.localWarCurTanks
    elseif type==19 then
        return self.swAttackTanks
    elseif type==20 then
        return self.swDefenceTanks
    elseif type==21 then
        return self.platWarTanks1
    elseif type==22 then
        return self.platWarTanks2
    elseif type==23 then
        return self.platWarTanks3
    elseif type==24 then
        return self.serverWarLocalTanks1
    elseif type==25 then
        return self.serverWarLocalTanks2
    elseif type==26 then
        return self.serverWarLocalTanks3
    elseif type==27 then
        return self.serverWarLocalCurTanks1
    elseif type==28 then
        return self.serverWarLocalCurTanks2
    elseif type==29 then
        return self.serverWarLocalCurTanks3
    elseif type==30 then
        return self.newYearBossTanks
    elseif type==31 then
        return self.allianceWar2CurTanks
    elseif type==32 then
        return self.allianceWar2Tanks
    elseif type==33 then
        return self.dimensionalWarTanks
    elseif type==34 then
        return self.serverWarTeamCurTanks
    elseif type==35 then -- 领土争夺战 防守
        return ltzdzFightApi:getTanksTbByType(type)
    elseif type==36 then -- 领土争夺战 进攻
        return ltzdzFightApi:getTanksTbByType(type)
    elseif type==37 then --狂热集结挑战部队
        return self.believerTanks
    elseif type==38 then --军团锦标赛个人战部队
        return self.championshipWarPersonalTanks
    elseif type==39 then --军团锦标赛军团战个人部队
        return self.championshipWarTanks
    end
end

--更改坦克tb
function tankVoApi:setTanksByType(type,id,tid,num)
    if type==1 then
        self.defenseTanks[id]={tid,num}
    elseif type==2 then
        self.attackTanks[id]={tid,num}
    elseif type==3 then
        self.storyTanks[id]={tid,num}
    elseif type==4 then
        self.allianceWarTanks[id]={tid,num}
    elseif type==5 then
        self.arenaTanks[id]={tid,num}
    elseif type==6 then
        self.allianceWarHoldTanks[id]={tid,num}
    elseif type==7 then
        self.serverWarTanks1[id]={tid,num}
    elseif type==8 then
        self.serverWarTanks2[id]={tid,num}
    elseif type==9 then
        self.serverWarTanks3[id]={tid,num}
    elseif type==10 then
        self.serverWarTeamTanks[id]={tid,num}
    elseif type==11 then
        self.expeditionTanks[id]={tid,num}
    elseif type==12 then
        self.bossbattleTanks[id]={tid,num}
    elseif type==13 then
        self.worldWarTanks1[id]={tid,num}
    elseif type==14 then
        self.worldWarTanks2[id]={tid,num}
    elseif type==15 then
        self.worldWarTanks3[id]={tid,num}
    elseif type==16 then
        self.alienMinesTanks[id]={tid,num}
    elseif type==17 then
        self.localWarTanks[id]={tid,num}
    elseif type==18 then
        self.localWarCurTanks[id]={tid,num}
    elseif type==19 then
        self.swAttackTanks[id]={tid,num}
    elseif type==20 then
        self.swDefenceTanks[id]={tid,num}
    elseif type==21 then
        self.platWarTanks1[id]={tid,num}
    elseif type==22 then
        self.platWarTanks2[id]={tid,num}
    elseif type==23 then
        self.platWarTanks3[id]={tid,num}
    elseif type==24 then
        self.serverWarLocalTanks1[id]={tid,num}
    elseif type==25 then
        self.serverWarLocalTanks2[id]={tid,num}        
    elseif type==26 then
        self.serverWarLocalTanks3[id]={tid,num}
    elseif type==27 then
        self.serverWarLocalCurTanks1[id]={tid,num}
    elseif type==28 then
        self.serverWarLocalCurTanks2[id]={tid,num}
    elseif type==29 then
        self.serverWarLocalCurTanks3[id]={tid,num}
    elseif type==30 then
        self.newYearBossTanks[id]={tid,num}
    elseif type==31 then
        self.allianceWar2CurTanks[id]={tid,num}
    elseif type==32 then
        self.allianceWar2Tanks[id]={tid,num}
    elseif type==33 then
        self.dimensionalWarTanks[id]={tid,num}
    elseif type==34 then
        self.serverWarTeamCurTanks[id]={tid,num}
    elseif type==35 then -- 领土争夺战 --进攻
        ltzdzFightApi:setTanksByType(type,id,tid,num)
    elseif type==36 then -- 领土争夺战 --防守（需要城的id）
        ltzdzFightApi:setTanksByType(type,id,tid,num)
    elseif type==37 then --狂热集结挑战部队
        self.believerTanks[id]={tid,num}
    elseif type==38 then --军团锦标赛个人战部队
        self.championshipWarPersonalTanks[id]={tid,num}
    elseif type==39 then --军团锦标赛军团战个人参战部队
        self.championshipWarTanks[id]={tid,num}
    end
end

--删除坦克tb
function tankVoApi:deleteTanksTbByType(type,id)
    if type==1 then
        self.defenseTanks[id]=nil
        self.defenseTanks[id]={}
    elseif type==2 then
        self.attackTanks[id]=nil
        self.attackTanks[id]={}
    elseif type==3 then
        self.storyTanks[id]=nil
        self.storyTanks[id]={}
    elseif type==4 then
        self.allianceWarTanks[id]=nil
        self.allianceWarTanks[id]={}

    elseif type==5 then
        self.arenaTanks[id]=nil
        self.arenaTanks[id]={}
    elseif type==6 then
        self.allianceWarHoldTanks[id]=nil
        self.allianceWarHoldTanks[id]={}
    elseif type==7 then
        self.serverWarTanks1[id]=nil
        self.serverWarTanks1[id]={}
    elseif type==8 then
        self.serverWarTanks2[id]=nil
        self.serverWarTanks2[id]={}
    elseif type==9 then
        self.serverWarTanks3[id]=nil
        self.serverWarTanks3[id]={}
    elseif type==10 then
        self.serverWarTeamTanks[id]=nil
        self.serverWarTeamTanks[id]={}
    elseif type==11 then
        self.expeditionTanks[id]=nil
        self.expeditionTanks[id]={}  
    elseif type==12 then
        self.bossbattleTanks[id]=nil
        self.bossbattleTanks[id]={}
    elseif type==13 then
        self.worldWarTanks1[id]=nil
        self.worldWarTanks1[id]={}
    elseif type==14 then
        self.worldWarTanks2[id]=nil
        self.worldWarTanks2[id]={}
    elseif type==15 then
        self.worldWarTanks3[id]=nil
        self.worldWarTanks3[id]={}
    elseif type==16 then
        self.alienMinesTanks[id]=nil
        self.alienMinesTanks[id]={}
    elseif type==17 then
        self.localWarTanks[id]=nil
        self.localWarTanks[id]={}
    elseif type==18 then
        self.localWarCurTanks[id]=nil
        self.localWarCurTanks[id]={}
    elseif type==19 then
        self.swAttackTanks[id]=nil
        self.swAttackTanks[id]={}
    elseif type==20 then
        self.swDefenceTanks[id]=nil
        self.swDefenceTanks[id]={}
    elseif type==21 then
        self.platWarTanks1[id]=nil
        self.platWarTanks1[id]={}
    elseif type==22 then
        self.platWarTanks2[id]=nil
        self.platWarTanks2[id]={}
    elseif type==23 then
        self.platWarTanks3[id]=nil
        self.platWarTanks3[id]={}
    elseif type==24 then
        self.serverWarLocalTanks1[id]=nil
        self.serverWarLocalTanks1[id]={}
    elseif type==25 then
        self.serverWarLocalTanks2[id]=nil
        self.serverWarLocalTanks2[id]={}
    elseif type==26 then
        self.serverWarLocalTanks3[id]=nil
        self.serverWarLocalTanks3[id]={}
    elseif type==27 then
        self.serverWarLocalCurTanks1[id]=nil
        self.serverWarLocalCurTanks1[id]={}
    elseif type==28 then
        self.serverWarLocalCurTanks2[id]=nil
        self.serverWarLocalCurTanks2[id]={}
    elseif type==29 then
        self.serverWarLocalCurTanks3[id]=nil
        self.serverWarLocalCurTanks3[id]={}
    elseif type==30 then
        self.newYearBossTanks[id]=nil
        self.newYearBossTanks[id]={}
    elseif type==31 then
        self.allianceWar2CurTanks[id]=nil
        self.allianceWar2CurTanks[id]={}
    elseif type==32 then
        self.allianceWar2Tanks[id]=nil
        self.allianceWar2Tanks[id]={}
    elseif type==33 then
        self.dimensionalWarTanks[id]=nil
        self.dimensionalWarTanks[id]={}
    elseif type==34 then
        self.serverWarTeamCurTanks[id]=nil
        self.serverWarTeamCurTanks[id]={}
    elseif type==35 then -- 领土争夺战 防守
        ltzdzFightApi:deleteTanksTbByType(type,id)
    elseif type==36 then -- 进攻
        ltzdzFightApi:deleteTanksTbByType(type,id)
    elseif type==37 then --狂热集结挑战部队
        self.believerTanks[id]=nil
        self.believerTanks[id]={}
    elseif type==38 then --军团锦标赛个人战部队
        self.championshipWarPersonalTanks[id]=nil
        self.championshipWarPersonalTanks[id]={}
    elseif type==39 then --军团锦标赛军团战个人部队
        self.championshipWarTanks[id]=nil
        self.championshipWarTanks[id]={}
    end
end

--部队对应场次关系,如{1,3,2} 第一场对应部队1的，第二场对应部队3，第三场对应部队2
function tankVoApi:getServerWarFleetIndexTb()
    return self.serverWarFleetIndexTb
end
function tankVoApi:setServerWarFleetIndexTb(fleetIndexTb)
    self.serverWarFleetIndexTb=fleetIndexTb
end
function tankVoApi:getServerWarFleetIndex(index)
    return self.serverWarFleetIndexTb[index]
end
--index1和index2场的部队调换，如把第1场和第2场的部队调换
function tankVoApi:setServerWarFleetIndex(index1,index2,fleetIndexTb)
    if fleetIndexTb then
        local temp=fleetIndexTb[index2]
        fleetIndexTb[index2]=fleetIndexTb[index1]
        fleetIndexTb[index1]=temp
    else
        local temp=self:getServerWarFleetIndex(index2)
        self.serverWarFleetIndexTb[index2]=self:getServerWarFleetIndex(index1)
        self.serverWarFleetIndexTb[index1]=temp
    end
end
--根据场次取部队
function tankVoApi:getServerWarFleetByIndex(index,fleetIndexTab)
    local idx=self:getServerWarFleetIndex(index)
    if fleetIndexTab and fleetIndexTab[index] then
        idx=fleetIndexTab[index]
    end
    return self["serverWarTanks"..idx]
end
--设置哪一场的部队
function tankVoApi:setServerWarFleetByIndex(index,fleetInfo,fleetIndexTab)
    local idx=self:getServerWarFleetIndex(index)
    if fleetIndexTab and fleetIndexTab[index] then
        idx=fleetIndexTab[index]
    end
    self["serverWarTanks"..idx]=fleetInfo
end
--显示1~6位置第一个有tank的tankId
--根据场次取部队
function tankVoApi:getFirstTankIdByIndex(index,fleetIndexTab)
    local tankId=nil
    local tanksTab=self:getServerWarFleetByIndex(index,fleetIndexTab)
    if tanksTab then
        for k,v in pairs(tanksTab) do
            if v and v[1] then
                tankId=v[1]
                break
            end
        end
    end
    return tankId
end
--世界争霸是否至少设置一支部队
function tankVoApi:serverWarIsSetFleet()
    local isSet=false
    for i=1,3 do
        if self["serverWarTanks"..i] then
            local serverWarTanks=self["serverWarTanks"..i]
            for k,v in pairs(serverWarTanks) do
                if v and SizeOfTable(v)>0 then
                    isSet=true
                end
            end
        end
    end
    return isSet
end
function tankVoApi:serverWarAllSetFleet()
    local isSet=true
    for i=1,3 do
        if self["serverWarTanks"..i] then
            local tanks=self["serverWarTanks"..i]
            if SizeOfTable(tanks)==0 then
                isSet=false
            elseif SizeOfTable(tanks)>0 then
                local tempIsSet=false
                for k,v in pairs(tanks) do
                    if v and SizeOfTable(v)>0 then
                        tempIsSet=true
                    end
                end
                if tempIsSet==false then
                    isSet=false
                end
            end
        end
    end
    return isSet
end

function tankVoApi:serverWarTeamIsSetFleet()
    local isSet=true
    if self.serverWarTeamTanks then
        local tanks=self.serverWarTeamTanks
        if SizeOfTable(tanks)==0 then
            isSet=false
        elseif SizeOfTable(tanks)>0 then
            local tempIsSet=false
            for k,v in pairs(tanks) do
                if v and SizeOfTable(v)>0 then
                    tempIsSet=true
                end
            end
            if tempIsSet==false then
                isSet=false
            end
        end
    end
    return isSet
end

function tankVoApi:getProductTime(tankid,bid)
    local alienTechSpeedUp=0
    local alienTechBuffer=0
    if tankid and base.richMineOpen==1 and base.alien==1 and alienTechVoApi and alienTechVoApi.getProduceSpeedUpTb then
        local speedUpTb=alienTechVoApi:getProduceSpeedUpTb()
        local techId=speedUpTb["a"..tankid]
        local tLevel=alienTechVoApi:getTechLevel(techId) or 0
        if alienTechCfg and alienTechCfg.talent and alienTechCfg.talent[techId] and alienTechCfg.talent[techId][alienTechCfg.keyCfg.value] and techId and tLevel>0 then
            local valueTb=alienTechCfg.talent[techId][alienTechCfg.keyCfg.value]
            if valueTb[tLevel] and valueTb[tLevel][200] then
                alienTechSpeedUp=valueTb[tLevel][200] or 0
            end
        end
    end
    if tankid and base.richMineOpen==1 and base.alien==1 and alienTechVoApi and alienTechVoApi.getBufferLv then
        local level,subTime=alienTechVoApi:getBufferLv("a"..tankid)
        alienTechBuffer=subTime
    end
    print("vip====?",playerVoApi:getVipLevel())
    local productTankSpeed=playerCfg.productTankSpeed[playerVoApi:getVipLevel()+1]
    --区域战buff
    local buffValue=0
    if localWarVoApi then
        local buffType=6
        local buffTab=localWarVoApi:getSelfOffice()
        if G_getHasValue(buffTab,buffType)==true then
            buffValue=G_getLocalWarBuffValue(buffType)
        end
    end
    --军徽技能提升
    local emblemValue = 0
    if base.emblemSwitch == 1 then
        emblemValue = emblemVoApi:getSkillValue(2)
    end
    --三周活动七重福利所加的buff
    local threeYearAdd=0
    if acThreeYearVoApi then
        threeYearAdd=acThreeYearVoApi:getBuffAdded(2)
    end
    local citySkillBuff=allianceCityVoApi:getSkill6TankBuff(tankid) --军团城市科研“军团编制”技能加成
    local scAddValueTb = strategyCenterVoApi:getAttributeValue(3) --战略中心"坦克制造速度增加百分比"技能加成
    local scAddValue = 0
    if scAddValueTb and scAddValueTb["tankSpeed"] and scAddValueTb["tankSpeed"].value then
        scAddValue = scAddValueTb["tankSpeed"].value
    end
    local battleBuff, skillBuff = warStatueVoApi:getTotalWarStatueAddedBuff("productTankSpeed")
    local warStatueBuff = skillBuff.productTankSpeed or 0 --战争塑像的加成

    --战争飞艇系统运输艇的加成    
    productTankSpeed = productTankSpeed + (airShipVoApi:getCurAirShipProperty(1)[1] or 0)

    local timeConsume=math.ceil((tonumber(tankCfg[tankid].timeConsume)-alienTechSpeedUp)/(1+(buildingVoApi:getBuildiingVoByBId(bid).level-1)*0.05+productTankSpeed+buffValue+emblemValue+threeYearAdd+citySkillBuff+alienTechBuffer+scAddValue+warStatueBuff));

    return timeConsume
end

function tankVoApi:getTankUpgradeTime(tankid,bid)
    local alienTechSpeedUp=0
    if tankid and base.richMineOpen==1 and base.alien==1 and alienTechVoApi and alienTechVoApi.getProduceSpeedUpTb then
        local speedUpTb=alienTechVoApi:getProduceSpeedUpTb()
        local techId=speedUpTb["a"..tankid]
        local tLevel=alienTechVoApi:getTechLevel(techId) or 0
        if alienTechCfg and alienTechCfg.talent and alienTechCfg.talent[techId] and alienTechCfg.talent[techId][alienTechCfg.keyCfg.value] and techId and tLevel>0 then
            local valueTb=alienTechCfg.talent[techId][alienTechCfg.keyCfg.value]
            if valueTb[tLevel] and valueTb[tLevel][200] then
                alienTechSpeedUp=valueTb[tLevel][200] or 0
            end
        end
    end
    local alienTechBuffer=0
    if tankid and base.richMineOpen==1 and base.alien==1 and alienTechVoApi and alienTechVoApi.getBufferLv then
        local level,subTime=alienTechVoApi:getBufferLv("a"..tankid)
        alienTechBuffer=subTime
    end
    local refitTankSpeed=playerCfg.refitTankSpeed[playerVoApi:getVipLevel()+1]
    --区域战buff
    local buffValue=0
    if localWarVoApi then
        local buffType=6
        local buffTab=localWarVoApi:getSelfOffice()
        if G_getHasValue(buffTab,buffType)==true then
            buffValue=G_getLocalWarBuffValue(buffType)
        end
    end
    --超级装备技能提升
    local emblemValue = 0
    if base.emblemSwitch == 1 then
        emblemValue = emblemVoApi:getSkillValue(3)
    end
    local threeYearAdd=0
    if acThreeYearVoApi then
        threeYearAdd=acThreeYearVoApi:getBuffAdded(2)
    end
    local citySkillBuff=allianceCityVoApi:getSkill6TankBuff(tankid) --军团城市科研“军团编制”技能加成
    local battleBuff, skillBuff = warStatueVoApi:getTotalWarStatueAddedBuff("refitTankSpeed")
    local warStatueBuff = skillBuff.refitTankSpeed or 0 --战争塑像的加成

    refitTankSpeed = refitTankSpeed + (airShipVoApi:getCurAirShipProperty(1)[2] or 0) --战争飞艇加成
      
    local timeConsume=math.ceil((tonumber(tankCfg[tankid].upgradeTimeConsume)-alienTechSpeedUp)/(1+(buildingVoApi:getBuildiingVoByBId(bid).level-1)*0.05+refitTankSpeed+buffValue+emblemValue+threeYearAdd+citySkillBuff+alienTechBuffer+warStatueBuff));

    return timeConsume
end

-------------------世界争霸以下-------------------
--部队对应场次关系,如{1,3,2} 第一场对应部队1的，第二场对应部队3，第三场对应部队2
function tankVoApi:getFleetIndexTb()
    return self.worldWarFleetIndexTb
end
function tankVoApi:setFleetIndexTb(fleetIndexTb)
    self.worldWarFleetIndexTb=fleetIndexTb
end
function tankVoApi:getFleetIndex(index)
    return self.worldWarFleetIndexTb[index]
end
--index1和index2场的部队调换，如把第1场和第2场的部队调换
function tankVoApi:setFleetIndex(index1,index2,fleetIndexTb)
    if fleetIndexTb then
        local temp=fleetIndexTb[index2]
        fleetIndexTb[index2]=fleetIndexTb[index1]
        fleetIndexTb[index1]=temp
    else
        local temp=self:getFleetIndex(index2)
        self.worldWarFleetIndexTb[index2]=self:getFleetIndex(index1)
        self.worldWarFleetIndexTb[index1]=temp
    end
end
--根据场次取部队
function tankVoApi:getFleetByIndex(index,fleetIndexTab)
    local idx=self:getFleetIndex(index)
    if fleetIndexTab and fleetIndexTab[index] then
        idx=fleetIndexTab[index]
    end
    return self["worldWarTanks"..idx]
end
--设置哪一场的部队
function tankVoApi:setFleetByIndex(index,fleetInfo,fleetIndexTab)
    local idx=self:getFleetIndex(index)
    if fleetIndexTab and fleetIndexTab[index] then
        idx=fleetIndexTab[index]
    end
    self["worldWarTanks"..idx]=fleetInfo
end
--世界争霸是否至少设置一支部队
function tankVoApi:worldWarIsSetFleet()
    local isSet=false
    for i=1,3 do
        if self["worldWarTanks"..i] then
            local worldWarTanks=self["worldWarTanks"..i]
            for k,v in pairs(worldWarTanks) do
                if v and SizeOfTable(v)>0 then
                    isSet=true
                end
            end
        end
    end
    return isSet
end
--世界争霸扣除坦克数
--oldTanks：原有阵型，newTanks：新阵型
function tankVoApi:worldWarCostTanks(oldTanks,newTanks)
    local showCostTanks={}
    local costTanks={}
    local isSame=true
    for k,v in pairs(newTanks) do
        if v and v[1] and v[2] then
            local tid=v[1]
            local num=v[2]
            if num and num>0 then
                if costTanks[tid] then
                    costTanks[tid]=costTanks[tid]+num
                else
                    costTanks[tid]=num
                end
            end
        end
    end
    for k,v in pairs(oldTanks) do
        if newTanks[k] then
            local newTank=newTanks[k]
            if v[1]~=newTank[1] or v[2]~=newTank[2] then
                isSame=false
            end
        else
            isSame=false
        end
        if v and v[1] and v[2] then
            local tid=v[1]
            local num=v[2]
            if costTanks[tid] then
                costTanks[tid]=costTanks[tid]-num
                if costTanks[tid]<0 then
                    costTanks[tid]=0
                end
            end
        end
    end
    for k,v in pairs(costTanks) do
        if v and v>0 then
            table.insert(showCostTanks,{k,v})
        end
    end
    if showCostTanks and SizeOfTable(showCostTanks)>0 then
        local function sortFunc(a,b)
            if a and b and a[1] and b[1] then
                local aid=(tonumber(a[1]) or tonumber(RemoveFirstChar(a[1])))
                local bid=(tonumber(b[1]) or tonumber(RemoveFirstChar(b[1])))
                return tonumber(tankCfg[aid].sortId)>tonumber(tankCfg[bid].sortId)
            end
        end
        table.sort(showCostTanks,sortFunc)
    end
    return showCostTanks,isSame
end
--显示1~6位置第一个有tank的tankId
--根据场次取部队
function tankVoApi:getTankIdByIndex(index,fleetIndexTab)
    local tankId=nil
    local tanksTab=self:getFleetByIndex(index,fleetIndexTab)
    if tanksTab then
        for k,v in pairs(tanksTab) do
            if v and v[1] then
                tankId=v[1]
                break
            end
        end
    end
    return tankId
end

function tankVoApi:getWorldWarTempTanks()
    if self.worldWarTempTanks then
        return self.worldWarTempTanks
    else
        return {}
    end
end
function tankVoApi:setWorldWarTempTanks(worldWarTempTanks)
    self.worldWarTempTanks=G_clone(worldWarTempTanks)
end
-------------------世界争霸以上-------------------
function tankVoApi:isHasTank()
    if SizeOfTable(self.allTanks)>0 then
        return true
    else
        return false
    end

end


--扣除坦克数
--oldTanks：原有阵型，newTanks：新阵型
function tankVoApi:setFleetCostTanks(oldTanks,newTanks)
    local showCostTanks={}
    local costTanks={}
    local isSame=true
    for k,v in pairs(newTanks) do
        if v and v[1] and v[2] then
            local tid=v[1]
            local num=v[2]
            if num and num>0 then
                if costTanks[tid] then
                    costTanks[tid]=costTanks[tid]+num
                else
                    costTanks[tid]=num
                end
            end
        end
    end
    for k,v in pairs(oldTanks) do
        if newTanks[k] then
            local newTank=newTanks[k]
            if v[1]~=newTank[1] or v[2]~=newTank[2] then
                isSame=false
            end
        else
            isSame=false
        end
        if v and v[1] and v[2] then
            local tid=v[1]
            local num=v[2]
            if costTanks[tid] then
                costTanks[tid]=costTanks[tid]-num
                if costTanks[tid]<0 then
                    costTanks[tid]=0
                end
            end
        end
    end
    for k,v in pairs(costTanks) do
        if v and v>0 then
            table.insert(showCostTanks,{k,v})
        end
    end
    if showCostTanks and SizeOfTable(showCostTanks)>0 then
        local function sortFunc(a,b)
            if a and b and a[1] and b[1] then
                local aid=(tonumber(a[1]) or tonumber(RemoveFirstChar(a[1])))
                local bid=(tonumber(b[1]) or tonumber(RemoveFirstChar(b[1])))
                return tonumber(tankCfg[aid].sortId)>tonumber(tankCfg[bid].sortId)
            end
        end
        table.sort(showCostTanks,sortFunc)
    end
    return showCostTanks,isSame
end



-------------------平台战以下-------------------
--部队对应场次关系,如{2,5,3} 第一支部队对应线路2，第二支部队对应线路5，第三支部队对应线路3
function tankVoApi:getPlatWarFleetIndexTb()
    return self.platWarFleetIndexTb
end
function tankVoApi:setPlatWarFleetIndexTb(fleetIndexTb)
    self.platWarFleetIndexTb=fleetIndexTb
end
function tankVoApi:getPlatWarFleetIndex(index)
    return self.platWarFleetIndexTb[index]
end
function tankVoApi:setPlatWarFleetIndex(index,value)
    if self.platWarFleetIndexTb and value then
        -- local indexTb=self:getPlatWarFleetIndexTb()
        -- local tempIndex
        -- for k,v in pairs(indexTb) do
        --     if v and v==value then
        --         if k==index then
        --         else
        --             tempIndex=k
        --         end
        --     end
        -- end
        -- local tempValue=self:getPlatWarFleetIndex(index)
        -- if tempIndex then
        --     self.platWarFleetIndexTb[tempIndex]=tempValue
        -- end
        self.platWarFleetIndexTb[index]=value
    end
end
--是否3支部队都设置了
function tankVoApi:platWarIsAllSetFleet()
    local isAllSet=true
    for i=1,3 do
        local isSet=false
        if self["platWarTanks"..i] then
            local platWarTanks=self["platWarTanks"..i]
            for k,v in pairs(platWarTanks) do
                if v and SizeOfTable(v)>0 then
                    isSet=true
                end
            end
        end
        if isSet==false then
            isAllSet=false
        end
    end
    return isAllSet
end
--显示1~6位置第一个有tank的tankId
--根据场次取部队
function tankVoApi:getPlatWarTankIdByIndex(index)
    local tankId=nil
    if self["platWarTanks"..index] then
        local platWarTanks=self["platWarTanks"..index]
        for k,v in pairs(platWarTanks) do
            if v and v[1] then
                tankId=v[1]
                break
            end
        end
    end
    return tankId
end

function tankVoApi:getPlatWarTempTanks()
    if self.platWarTempTanks then
        return self.platWarTempTanks
    else
        return {}
    end
end
function tankVoApi:setPlatWarTempTanks(tempTanks)
    self.platWarTempTanks=G_clone(tempTanks)
end
-------------------平台战以上-------------------

-- 普通坦克升级成精英坦克面板
function tankVoApi:showTankUpgrade(layerNum,data,callBack)
    require "luascript/script/game/scene/gamedialog/commonUpEliteSmallDialog"
    local dialog = commonUpEliteSmallDialog:new(data)
    dialog:init(layerNum,callBack)
end

--获取单个坦克的战斗力，这个方法与上面的getBestTanksFighting的区别是与后台逻辑保持一致
function tankVoApi:getSingleTankFighting(tankID)
    local fighting=tonumber(tankCfg[tankID].fighting)
    local per = {}
    local tankType = tonumber(tankCfg[tankID].type)
    --技能加成
    for key,cfg in pairs(playerSkillCfg.skillList) do
        local flag=false
        for k,v in pairs(cfg.skillBaseType) do
            if(v==tankType)then
                flag=true
                break
            end
        end
        if(flag)then
            local attributeType = tonumber(cfg.attributeType)
            if(attributeType)then
                if(attributeType==201 or attributeType==202)then
                    per[attributeType] = (per[attributeType] or 1) + skillVoApi:getSkillAddPerById(key)/200
                else
                    per[attributeType] = (per[attributeType] or 1) + skillVoApi:getSkillAddPerById(key)/4
                end
            end
        end
    end
    --军团技能加成，只有11~14才加战斗力
    for i=1,4 do
        local id=10 + i
        local lv=allianceSkillVoApi:getSkillLevel(id)
        if(lv>0)then
            local attributeType=tonumber(allianceSkillCfg[id]["attributeType"])
            per[attributeType] = (per[attributeType] or 1) +  tonumber(allianceSkillCfg[id]["value"][lv])/400
        end
    end
    --科技加成
    for key,cfg in pairs(techCfg) do
        if(cfg.baseType==tankType)then
            local attributeType = tonumber(cfg.attributeType)
            per[attributeType] = (per[attributeType] or 1) +  technologyVoApi:getAddPerById(cfg.sid)/400
        end
    end
    --配件加成
    if(base.ifAccessoryOpen==1)then
        local acc2TankType = {[1]=1,[2]=2,[4]=3,[8]=4}
        local accAttMap={[1]=100,[2]=108,[3]=201,[4]=202,[5]=110,[6]=111,[7]=211,[8]=212,[9]=213,[10]=214,[11]=221,[12]=222,[13]=223,[14]=224}
        local accAtt=accessoryVoApi:getTankAttAdd(tankType)
        for key,value in pairs(accAtt) do
            local attributeType=accAttMap[key]
            if(attributeType==201 or attributeType==202)then
                per[attributeType] = (per[attributeType] or 1) + value/200
            elseif(attributeType==110 or attributeType==111 or attributeType==100 or attributeType==108)then
                per[attributeType] = (per[attributeType] or 1) + value/400
            --这几个属性不算战斗力
            elseif(attributeType==211 or attributeType==212 or attributeType==213 or attributeType==214 or attributeType==221 or attributeType==222 or attributeType==223 or attributeType==224)then
            else
                per[attributeType] = (per[attributeType] or 1) + value/4
            end
        end
    end
    --军衔加成
    if(playerVoApi:getRank()>0 and rankCfg.rank[playerVoApi:getRank()])then
        per[100] = (per[100] or 1) + (rankCfg.rank[playerVoApi:getRank()].attAdd[1])/4
        per[108] = (per[108] or 1) + (rankCfg.rank[playerVoApi:getRank()].attAdd[2])/4
    end
    --关卡buff加成
    local checkpointAdd=checkPointVoApi:getTechAddNum()
    for cid,addvalue in pairs(checkpointAdd) do
        local attributeType=challengeTechCfg["c"..cid].attributeType
        if(attributeType)then
            per[attributeType] = (per[attributeType] or 1) +  addvalue/4
        end
    end
    --异星科技加成
    local accuracy,evade,crit,anticrit,dmg,maxhp,critDmg,decritDmg,armor,arp,skill=0,0,0,0,0,0,0,0,0,0,0
    if base.alien==1 and base.richMineOpen==1 and alienTechVoApi and alienTechVoApi.getAlienAddAttr then
        accuracy,evade,crit,anticrit,dmg,maxhp,critDmg,decritDmg,armor,arp,skill=alienTechVoApi:getAlienAddAttr(tankID)
    end
    local life=tonumber(tankCfg[tankID].life)
    local attack=tonumber(tankCfg[tankID].attack)
    per[102]=(per[102] or 1) + accuracy/400/100
    per[103]=(per[103] or 1) + evade/400/100
    per[104]=(per[104] or 1) + crit/400/100
    per[105]=(per[105] or 1) + anticrit/400/100
    per[100]=(per[100] or 1) + dmg/attack/4
    per[108]=(per[108] or 1) + maxhp/life/4
    per[110]=(per[110] or 1) + critDmg/5/100
    per[111]=(per[111] or 1) + decritDmg/5/100
    per[201]=(per[201] or 1) + armor/400
    per[202]=(per[202] or 1) + arp/400
    if(skill>0)then
        per["skill"]=1 + 0.2
    end
    local tPer=1
    for k,v in pairs(per) do
        tPer=tPer*v
    end
    return fighting*tPer
end


-------------------群雄争霸以下-------------------
-- function tankVoApi:getServerWarLocalFleetByIndex(index)
--     return self["serverWarLocalTanks"..index]
-- end
-- function tankVoApi:setServerWarLocalFleetByIndex(index,value)
--     if self["serverWarLocalTanks"..index] and value then
--         -- local indexTb=self:getPlatWarFleetIndexTb()
--         -- local tempIndex
--         -- for k,v in pairs(indexTb) do
--         --     if v and v==value then
--         --         if k==index then
--         --         else
--         --             tempIndex=k
--         --         end
--         --     end
--         -- end
--         -- local tempValue=self:getPlatWarFleetIndex(index)
--         -- if tempIndex then
--         --     self.platWarFleetIndexTb[tempIndex]=tempValue
--         -- end
--         self["serverWarLocalTanks"..index]=value
--     end
-- end
function tankVoApi:getServerWarLocalTempTanks()
    if self.serverWarLocalTempTanks then
        return self.serverWarLocalTempTanks
    else
        return {}
    end
end
function tankVoApi:setServerWarLocalTempTanks(tempTanks)
    self.serverWarLocalTempTanks=G_clone(tempTanks)
end
--3支部队设置情况
--返回：isAllSet是否都设置了，isSetOne至少了设置一个
function tankVoApi:serverWarLocalIsAllSetFleet()
    local isAllSet,isSetOne=true,false
    for i=1,3 do
        local isSet=false
        if self["serverWarLocalTanks"..i] then
            local serverWarLocalTanks=self["serverWarLocalTanks"..i]
            for k,v in pairs(serverWarLocalTanks) do
                if v and SizeOfTable(v)>0 then
                    isSet=true
                    isSetOne=true
                end
            end
        end
        if isSet==false then
            isAllSet=false
        end
    end
    return isAllSet,isSetOne
end
-------------------群雄争霸以上-------------------


function tankVoApi:getAllianceWar2TempTanks()
    if self.allianceWar2TempTanks then
        return self.allianceWar2TempTanks
    else
        return {}
    end
end

function tankVoApi:setAllianceWar2TempTanks(tempTanks)
    self.allianceWar2TempTanks=G_clone(tempTanks)
end

function tankVoApi:getLocalWarTempTanks()
    if self.localWarTempTanks then
        return self.localWarTempTanks
    else
        return {}
    end
end

function tankVoApi:setLocalWarTempTanks(tempTanks)
    self.localWarTempTanks=G_clone(tempTanks)
end

function tankVoApi:getDimensionalWarTempTanks()
    if self.dimensionalWarTempTanks then
        return self.dimensionalWarTempTanks
    else
        return {}
    end
end

function tankVoApi:setDimensionalWarTempTanks(tempTanks)
    self.dimensionalWarTempTanks=G_clone(tempTanks)
end

---------------------------------------------------------

function tankVoApi:exchangeTanksByType(type,id1,id2)
    if type==3 then
        local tempTab = self.storyTanks
        local tab1 = G_clone(tempTab[id1])
        tempTab[id1] = tempTab[id2]
        tempTab[id2] = tab1
    else
        local tempTab = self:getTanksTbByType(type)
        local tab1 = G_clone(tempTab[id1])
        tempTab[id1] = tempTab[id2]
        tempTab[id2] = tab1
    end
end

function tankVoApi:showTankBuffSmallDialog(bgSrc,size,fullRect,inRect,content,istouch,isuseami,layerNum,callBackHandler,isAutoSize,speciaTb)
    require "luascript/script/game/scene/gamedialog/warDialog/tankBuffSmallDialog"
    local dialog=tankBuffSmallDialog:new()
    dialog:init(bgSrc,size,fullRect,inRect,content,istouch,isuseami,layerNum,callBackHandler,isAutoSize,speciaTb)
    return dialog
end

--获取可用的坦克数量（排除掉已经派出去的坦克）
function tankVoApi:getAvailableTankCount(tankId)
    local attTab=self:getTanksTbByType(2)
    local attTankNumTb={}
    for k,v in pairs(attTab) do
        if(v[1] and v[2])then
            local key=tonumber(v[1])
            if(attTankNumTb[key])then
                attTankNumTb[key]=attTankNumTb[key]+tonumber(v[2])
            else
                attTankNumTb[key]=tonumber(v[2])
            end
        end
    end
    local allTankTb=self:getAllTanks()
    if allTankTb[tankId] and attTankNumTb and attTankNumTb[tankId] then
        return tonumber(allTankTb[tankId][1])-attTankNumTb[tankId]
    elseif allTankTb[tankId] then
        return tonumber(allTankTb[tankId][1]) or 0
    end
    return 0
end

function tankVoApi:updateUnlockBuildTanks(bid)
    local bvo=buildingVoApi:getBuildiingVoByBId(bid)
    local tflv=self.tflevelTb[bid]
    if tflv==nil or tonumber(tflv)<tonumber(bvo.level) then
        local bcfg=buildingCfg[6]
        local proSid=Split(bcfg.buildPropSids,",")
        local tankTb={} -- 已解锁坦克存储为坦克的id
        for kk=1,#proSid do
            if kk%2==0 then
                if bvo.level>=tonumber(proSid[kk-1]) then --已解锁
                     table.insert(tankTb,proSid[kk])
                end
            end
        end
        self.unlockBuildTankTb[bid]=tankTb
        self.tflevelTb[bid]=bvo.level
    end
end

function tankVoApi:hasTankCanBuild(bid)
    local tankTb=self.unlockBuildTankTb[bid] or {}
    for k,tankId in pairs(tankTb) do
        local result=tankVoApi:checkUpgradeBeforeSendServer(bid,tonumber(tankId),1)
        if result==true then
            return true
        end
    end
    return false
end

function tankVoApi:setChampionshipWarTempTanks(tempTanks)
    self.championshipWarTempTanks=tempTanks
end

--根据坦克id来获取坦克icon显示的纹理名称
--params：tankId：坦克id，btype 战斗类型（在某些情况下可不传）
function tankVoApi:getTankIconSpByBattleType(btype,tankId,callback)
    local skinList,skinId
    local isCheckSelf = true
    if tankSkinVoApi:checkBattleType(btype)==true then
        skinList = tankSkinVoApi:getTempTankSkinList(btype)
        isCheckSelf = false
    elseif btype==35 or btype==36 then --领土争夺战
        skinList = ltzdzFightApi:getTankSkinList()
        isCheckSelf = false
    end
    if skinList then
        skinId = skinList[tankSkinVoApi:convertTankId(tankId)]
    end
    -- print("btype,tankId,skinId,isCheckSelf--->",btype,tankId,skinId,isCheckSelf)
    local iconSp = tankVoApi:getTankIconSp(tankId,skinId,callback,isCheckSelf)
    return iconSp
end

--获取坦克icon纹理名称，如果装扮了皮肤则显示皮肤icon，如果没有则显示默认icon;newSkinId:皮肤id，如果没有，默认取自身的skinId
--s0也表示没有装扮皮肤，显示默认
--isCheckSelf：标识是否需要取玩家自身的坦克装扮
function tankVoApi:getTankIconPic(tankId,newSkinId,isCheckSelf)
    local tid=tonumber(tankId) and tonumber(tankId) or tonumber(RemoveFirstChar(tankId))
    if base.tskinSwitch==0 then
        do return tankCfg[tid].icon,nil end
    end
    local flag = isCheckSelf==nil and true or isCheckSelf
    local pic
    local skinId = newSkinId
    if flag==true and skinId==nil then
        skinId = tankSkinVoApi:getEquipSkinByTankId(tid) --如果该坦克装扮了皮肤则替换成皮肤的icon
    end
    if skinId then --有装扮皮肤
        if tankSkinVoApi:isSkinOpen(skinId)==true then
            pic = tankSkinVoApi:getTankSkinIconPic(skinId)
        end
    end
    return pic or tankCfg[tid].icon,skinId
end

function tankVoApi:getTankIconSp(tankId,newSkinId,callback,isCheckSelf)
    local tankPic,skinId = self:getTankIconPic(tankId,newSkinId,isCheckSelf)
    local function touchCall(object,name,tag)
        if callback then
            callback(object,name,tag)
        end
    end
    if (not skinId) or tankSkinVoApi:isSkinOpen(skinId)==false then--默认坦克icon
        local tankIconSp=LuaCCSprite:createWithSpriteFrameName(tankPic,touchCall)
        return tankIconSp
    else
        local tankSp  = CCSprite:createWithSpriteFrameName(tankPic)
        local subSize = 4--默认像素边界
        local tankBg  = "tskin_bg1.png"--默认背景图

        local tankIconSp=LuaCCSprite:createWithSpriteFrameName(tankBg,touchCall)
        tankSp:setScale((tankIconSp:getContentSize().width - subSize) / tankSp:getContentSize().width)
        tankSp:setTag(158)
        tankSp:setPosition(getCenterPoint(tankIconSp))
        tankIconSp:addChild(tankSp)
        return tankIconSp
    end
end


function tankVoApi:showTankWarehouseDialog(layerNum,tabNum)
    local tankWarehouseDialog=require "luascript/script/game/scene/gamedialog/tankWarehouse/tankWarehouseDialog"
    local wd = tankWarehouseDialog:new()
    local warehouseLayer=wd:createView(layerNum,tabNum)
    sceneGame:addChild(warehouseLayer,layerNum)
end

--获取坦克修复消耗
function tankVoApi:getTankRepairCost(tankId,tankNum)
    local totalCrystalCost = 0 --水晶总消耗
    local totalGemCost = 0 --金币总消耗
    local repairRate = 0
    local vo = activityVoApi:getActivityVo("baifudali")
    if vo and activityVoApi:isStart(vo) == true then
        repairRate = vo.repairRate
    end
    local glodCost = tonumber(tankCfg[tankId].glodCost) * tankNum
    local gemCost = math.ceil(tonumber(tankCfg[tankId].gemCost) * tankNum)
    if repairRate then
        glodCost = math.ceil(glodCost * (1 - repairRate))
        gemCost = math.ceil(gemCost * (1 - repairRate))
    end
    --玩家如果添加了高阶维修的军团科技，水晶修理费用随科技等级的提高而减少
    repairRate = allianceSkillVoApi:getGoldRepairRate()
    glodCost = math.ceil(glodCost * repairRate)
    --角色技能，减少修坦克消耗
    local skillReduce = skillVoApi:getSkillAddPerById("s302")
    glodCost = math.ceil(glodCost*(1 - skillReduce))
    totalCrystalCost = totalCrystalCost + glodCost
    totalGemCost = totalGemCost + gemCost

    --勇往直前活动, 水晶修理费用减少50%
    local vo = activityVoApi:getActivityVo("yongwangzhiqian")
    local ywzq2018Vo = activityVoApi:getActivityVo("ywzq")
    if vo and activityVoApi:isStart(vo) then
        totalCrystalCost = totalCrystalCost * vo.activeRes
    elseif ywzq2018Vo and activityVoApi:isStart(ywzq2018Vo) then
        totalCrystalCost = totalCrystalCost * ywzq2018Vo.activeRes
    end

    --主基地装扮减少的水晶修理费用
    if buildDecorateVoApi and buildDecorateVoApi.declineGoldCost and base.isSkin == 1 then
        totalCrystalCost = math.ceil(totalCrystalCost * (1 - buildDecorateVoApi:declineGoldCost()))
    end

    return totalCrystalCost, totalGemCost
end

function tankVoApi:tankRepair(repairType,tankId,tankNum,callback)
    local function repairCallBack(fn,data)
        local ret,sData = base:checkServerData(data)
        if ret==true then
            if callback then
                callback()
            end 
        end
    end
    socketHelper:repairTanks(repairType,tankId,tankNum,repairCallBack)
end

function tankVoApi:setProdamagedTanks(prodamaged)
    self.prodamagedTanks=prodamaged or {}
end

function tankVoApi:clearProdamagedTanks()
    self.prodamagedTanks = {}
end

function tankVoApi:getProdamagedTankNum(tankId)
    if self.prodamagedTanks and self.prodamagedTanks["a"..tankId] then
        return tonumber(self.prodamagedTanks["a"..tankId])
    end
    return 0
end