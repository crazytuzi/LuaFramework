workShopApi={
    unlockPropTb={}, --解锁的可以制造的道具
    lastVipLv=-1, --上一次的vip等级，因为玩家初始vip是0，所以该值默认是-1
}


function workShopApi:getWorkShopResources()

    local propTb=Split(buildingCfg[9].buildPropSids,",")
    
    local resultTb={}
    
    for k,v in pairs(propTb) do
        local pid="p"..v
         table.insert(resultTb,propCfg[pid])
    end

    --vip开关新增道具开关
    local vipPrivilegeSwitch=base.vipPrivilegeSwitch
    local vipRelatedCfg=playerCfg.vipRelatedCfg
    if vipPrivilegeSwitch and vipPrivilegeSwitch.vap==1 then
        if vipRelatedCfg and vipRelatedCfg.addCreateProps and vipRelatedCfg.addCreateProps[1] and vipRelatedCfg.addCreateProps[2] then
            if playerVoApi:getVipLevel()>=vipRelatedCfg.addCreateProps[1] then
                for k,v in pairs(vipRelatedCfg.addCreateProps[2]) do
                    local pid=v
                    table.insert(resultTb,propCfg[pid])
                end
            end
        end
    end

    return resultTb
end
--检查加速资源或者队列在是否满足条件
function workShopApi:checkSuperProduceBeforeSendServer(slotId)
    local result,reason=true,nil  --reason 1:已经生产完成 2:宝石不足
    --检查生产队列状态
    if workShopSlotVoApi:getSlotBySlotid(slotId)==nil then
         result=false
         reason=1
    end
    --检查宝石数量
    local needNems=0
    if result==true then
        local leftT=workShopSlotVoApi:getLeftTimeAndTotalTimeBySlotid(slotId)
        needGems= TimeToGems(leftT)
        if needGems>playerVoApi:getGems() then
            result=false
            reason=2
        end
    end
    return result,reason

end

function workShopApi:superProduce(slotId)
    --移除生产队列
    --[[
    local item=workShopSlotVoApi:getSlotBySlotid(slotId)
    smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("promptProduceFinish",{getlocal(propCfg[tonumber(item.itemId)].name)}),30)
    workShopSlotVoApi:cancleProduce(slotId)
    ]]

end
--检查取消资源或者队列在是否满足条件
function workShopApi:checkCancleProduceBeforeSendServer(slotId)
 local result,reason=true,nil   --reason  1:已经生产完成
    --检查生产队列状态
    if workShopSlotVoApi.allSlots[slotId]==nil then
        result=false
        reason=1
    end
    if result==true then

        --退还部分资源
        local leftTime,totalTime=workShopSlotVoApi:getLeftTimeAndTotalTimeBySlotid(slotId)
        if leftTime<0 then
             result=false
             reason=1
        end
        if result==true then
            --[[
            local thRate=leftTime/totalTime
            local slotVo=workShopSlotVoApi:getSlotBySlotid(slotId)
            local count=slotVo.itemNum
            local pid="p"..slotVo.itemId
            local needGold=tonumber(propCfg[pid].moneyConsume)*count
            local needXZ=tonumber(Split(propCfg[pid].propConsume,",")[2])*count
            local thGold=math.ceil(thRate*needGold)
            --local thXZ=math.ceil(thRate*needXZ)
            playerVoApi:useResource(0,0,0,0,-thGold,0)
            --bagVoApi:addBag(tonumber(Split(propCfg[slotVo.itemId].propConsume,",")[1]),needXZ)
            ]]
        end
    end
    return result,reason
end
--取消生产队列
function workShopApi:cancleProduce(slotId)

    workShopSlotVoApi:cancleProduce(slotId)
    
end
--检查资源或者队列在是否满足条件
function workShopApi:checkUpgradeBeforeSendServer(itemId,count)
    local result=true
    local reason --1:金币不足 2:勋章不足 3:队列不足
    --检查资源
    local pid="p"..itemId
    local needGold=tonumber(propCfg[pid].moneyConsume)*count
    local needXZ=tonumber(propCfg[pid].propConsume[2])*count
    if needGold>playerVoApi:getGold() then
         result=false
         reason=1
    end
    
    if result==true then
        if needXZ>bagVoApi:getItemNumId(19) then
             result=false
             reason=2
        end
    end
    --检查队列
    if result==true then
        local queueCfg=playerCfg.vipProuceQueue
        
        local queueNum=Split(queueCfg,",")[playerVoApi:getVipLevel()+1]
        if  SizeOfTable(workShopSlotVoApi.allSlots)>=tonumber(queueNum) then
             result=false
             reason=3
        end
    end
    return result,reason;

end

--检测队列是否已满
function workShopApi:checkIsFull()
    local queueCfg=playerCfg.vipProuceQueue
    local queueNum=Split(queueCfg,",")[playerVoApi:getVipLevel()+1]
    if  SizeOfTable(workShopSlotVoApi.allSlots)>=tonumber(queueNum) then
        return true
    end
    return false
end

--itemId:物品Id
function workShopApi:startProduce(itemId,count)
    local result=true
    local reason --1:金币不足 2:勋章不足 3:队列不足
    --检查资源
    local pid="p"..itemId
    local needGold=tonumber(propCfg[pid].moneyConsume)*count
    local needXZ=tonumber(Split(propCfg[pid].propConsume,",")[2])*count
    if needGold>playerVoApi:getGold() then
         result=false
         reason=1
    end
    
    if result==true then
        if needXZ>bagVoApi:getItemNumId(tonumber(Split(propCfg[pid].propConsume,",")[1])) then
             result=false
             reason=2
        end
    end
    --检查队列
    if result==true then
        local queueCfg=playerCfg.vipProuceQueue
        local queueNum=Split(queueCfg,",")[playerVoApi:getVipLevel()+1]
        if  SizeOfTable(workShopSlotVoApi.allSlots)>=tonumber(queueNum) then
             result=false
             reason=3
        end
    end

    --扣资源
    if result==true then
        playerVoApi:useResource(0,0,0,0,needGold,0)
        bagVoApi:useItemNumId(itemId,needXZ)
    end
    --添加队列
    if result==true then
        workShopSlotVoApi:add(itemId,count,base.serverTime,base.serverTime)
    end
    return result,reason
end

function workShopApi:updateUnlockProps()
    if self.lastVipLv<playerVoApi:getVipLevel() then
        self.unlockPropTb=self:getWorkShopResources()
        self.lastVipLv=playerVoApi:getVipLevel()
    end
end

--是否有道具可以制造
function workShopApi:hasPropCanMake()
    for k,v in pairs(self.unlockPropTb) do
        local result=self:checkUpgradeBeforeSendServer(v.sid,1)
        if result==true then
            return true
        end
    end
    return false
end

function workShopApi:clear()
    self.unlockPropTb={}
    self.lastVipLv=-1
end