tankUpgradeSlotVoApi={
     allSlots={},
     allSlotsFirst={},
     allSlotsSecond={}
}

--后台返回数据初始化队列
function tankUpgradeSlotVoApi:init(slotTbs)


end

function tankUpgradeSlotVoApi:produceSuccess(bid,v)

        smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("promptProduceFinish",{getlocal(tankCfg[v.itemId].name)}),28)
                 G_SyncData() --前台自己完成后需要和后台同步下
     --tankVoApi:addTank(v.itemId,v.itemNum)
     self:getSoltByBid(bid)[v.slotId]=nil
end

function tankUpgradeSlotVoApi:judgeAndShowSlot(bid,tb)--同步之前判断后台先完成 然后飘板

    if bid==13 then
        if SizeOfTable(tb)~=SizeOfTable(self.allSlotsFirst) then
            for k,v in pairs(self.allSlotsFirst) do
                if tb[k]==nil then

                    if v~=nil then
                        self:produceSuccess(bid,v)
                    end
                end
            end
        end

    end

end

function tankUpgradeSlotVoApi:getSoltByBid(bid)
    
    if bid==13 then
        return self.allSlotsFirst;
    end
    
end

function tankUpgradeSlotVoApi:clear(bid)
    if bid==13 then
        for k,v in pairs(self.allSlotsFirst) do
             v=nil
        end
        self.allSlotsFirst=nil
        self.allSlotsFirst={}
    end
    
    
end

--添加改装队列
function tankUpgradeSlotVoApi:add(bid,slotId,itemId,itemNum,st,et,addTime,timeConsume)
    local solts=self:getSoltByBid(bid)
    local wslotVo=tankUpgradeSlotVo:new()
    local status
    if et==nil then
        status=2
    else
        status=1
    end
    if et~=nil then
        G_pushMessage(getlocal("produce_finish",{getlocal(tankCfg[itemId].name)}),et-base.serverTime,"t"..bid.."_"..slotId,G_TankUpgradeTag)
    end
    wslotVo:initData(slotId,itemId,itemNum,status,st,et,addTime,timeConsume)
    solts[slotId]=wslotVo
end

--根据队列ID获取生产剩余时间
function tankUpgradeSlotVoApi:getLeftTimeAndTotalTimeBySlotid(bid,slotId)
    local solts=self:getSoltByBid(bid) 
    local slotVo=solts[slotId]
    local totalTime=tonumber(tankCfg[slotVo.itemId].timeConsume)*tonumber(slotVo.itemNum)
    
    if slotVo.et~=nil then
        return (slotVo.et-base.serverTime),(slotVo.et-slotVo.st)
    else
        return totalTime,totalTime
    end
end



function tankUpgradeSlotVoApi:getSlotBySlotid(bid,slotId)
    local solts=self:getSoltByBid(bid)
    return solts[slotId]
end
--取消物品生产
function tankUpgradeSlotVoApi:cancleProduce(bid,slotId)
    local solts=self:getSoltByBid(bid)
    solts[slotId]=nil
end

--按照添加先后顺序获取所有队列
function tankUpgradeSlotVoApi:getAllSolts(bid)
    local solts=self:getSoltByBid(bid)
    
    local result={}
    local retTb={}
    for k,v in pairs(solts) do
         if v.et~=nil then
            table.insert(retTb,v)
         else
            table.insert(result,v)
         end
    end

    table.sort(result,function(a,b) return a.addTime<b.addTime end)
    
    for k,v in pairs(result) do
         table.insert(retTb,v)
    end
    
    return retTb

end

function tankSlotVoApi:getSlotId(bid)
    local solts=self:getSoltByBid(bid)
    for kk=1,100 do
        if solts[kk]==null then
             return kk
        end
    end
end
function tankUpgradeSlotVoApi:tick()
    self:tick1()
end

function tankUpgradeSlotVoApi:tick1()
    if SizeOfTable(self.allSlotsFirst)==0 then
        do
            return
        end
    end
    local dyTime=0
    local runNextSlot=false
    local hasUpgradeSlot=false
    
    for k,v in pairs(self.allSlotsFirst) do
        if v.status==1 then
            hasUpgradeSlot=true

            local leftTime,totalTime=self:getLeftTimeAndTotalTimeBySlotid(13,tonumber(v.slotId))

            local name,pic,desc,id,index,eType,equipId,bgname = getItem(v.itemId,"o")
            local num=tonumber(v.itemNum)
            local award={type="o",key="a" .. v.itemId,pic=pic,name=name,num=num,desc=desc,id=id,bgname=bgname}
            local reward={award}


            if leftTime<=0 then --当前队列生产完成
               smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("promptProduceFinish",{getlocal(tankCfg[v.itemId].name)}),28,nil,nil,reward)
               G_cancelPush("t".."13".."_"..v.slotId,G_TankUpgradeTag)
               if v~=nil then
                 tankVoApi:addUpgradedTank(v.itemId-1,v.itemNum) --加入
               end
               G_SyncData() --前台自己完成后需要和后台同步下
                 self:getSoltByBid(13)[v.slotId]=nil
                 dyTime=0
                 if leftTime<=0 then
                     dyTime=leftTime --当前队列生产完成 刷晚了，用户后台运行游戏可以导致此现象
                 end
                 runNextSlot=true
            end
        end
    end
     if hasUpgradeSlot==false or runNextSlot==true then
         runNextSlot=false
         local waitSlots=self:getAllSolts(13)
         for k,v in pairs(waitSlots) do
             if v.status==2 then
                 v.st=base.serverTime
                 v.status=1
                 v.et=v.st+v.timeConsume
                 do
                     return
                 end
             end
         end
     end


end

function tankUpgradeSlotVoApi:getCurProduceSlot(bid)
    
    if bid==13 then
        for k,v in pairs(self.allSlotsFirst) do
             if v.status==1 then
                do
                    return v
                end
             end
        end
    end
    
end





