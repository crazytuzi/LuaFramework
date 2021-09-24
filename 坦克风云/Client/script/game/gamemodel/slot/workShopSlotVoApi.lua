workShopSlotVoApi={
     allSlots={}
}

--后台返回数据初始化队列
function workShopSlotVoApi:init(slotTbs)


end

function workShopSlotVoApi:produceSuccess(v)
    
    local pid="p"..v.itemId
     smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(400,300),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("promptProduceFinish",{getlocal(propCfg[pid].name)}),25)
     self.allSlots[v.slotId]=nil
end

function workShopSlotVoApi:judgeAndShowSlot(tb)--同步之前判断后台先完成 然后飘板

        if SizeOfTable(tb)~=SizeOfTable(self.allSlots) then
            for k,v in pairs(self.allSlots) do
                if tb[k]==nil then

                    if v~=nil then
                        self:produceSuccess(v)
                    end
                end
            end
        end

end

--添加生产队列
function workShopSlotVoApi:add(slotId,itemId,itemNum,st,et,addTime,timeConsume)
    local wslotVo=workShopSlotVo:new()
    local status
    if et==nil then
        status=2
    else
        status=1
    end
    if et~=nil then
        local pid="p"..itemId
        G_pushMessage(getlocal("produce_finish",{getlocal(propCfg[pid].name)}),et-base.serverTime,"p".."_"..slotId,G_ItemProduceTag)
    end
    wslotVo:initData(slotId,itemId,itemNum,status,st,et,addTime,timeConsume)
    self.allSlots[slotId]=wslotVo
end

--根据队列ID获取生产剩余时间
function workShopSlotVoApi:getLeftTimeAndTotalTimeBySlotid(slotId)
    local slotVo=self.allSlots[slotId]
    local pid="p"..slotVo.itemId
    local totalTime=tonumber(propCfg[pid].timeConsume)*tonumber(slotVo.itemNum)
    if slotVo.et~=nil then
        return (slotVo.et-base.serverTime),totalTime
    else
        return totalTime,totalTime
    end
end



function workShopSlotVoApi:getSlotBySlotid(slotId)
    return self.allSlots[slotId]
end
--取消物品生产
function workShopSlotVoApi:cancleProduce(slotId)
    self.allSlots[slotId]=nil
end

--按照添加先后顺序获取所有队列
function workShopSlotVoApi:getAllSolts()
    local result={}
    local retTb={}
    for k,v in pairs(self.allSlots) do
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
--取出正在建造队列
function workShopSlotVoApi:getProductSolt()
    for k,v in pairs(self.allSlots) do
         if v.status==1 then
            do
                return v
            end
         end
    end

end

function workShopSlotVoApi:clear()
    for k,v in pairs(self.allSlots) do
         v=nil
    end
    self.allSlots=nil
    self.allSlots={}
end

function workShopSlotVoApi:getSlotId()
    for kk=1,100 do
        if self.allSlots[kk]==null then
             return kk
        end
    end
end


function workShopSlotVoApi:tick()
    
    if SizeOfTable(self.allSlots)==0 then
        do
            return
        end
    end

    local dyTime=0
    local runNextSlot=false
    local hasUpgradeSlot=false
    for k,v in pairs(self.allSlots) do
        if v.status==1 then
            hasUpgradeSlot=true

            local leftTime,totalTime=self:getLeftTimeAndTotalTimeBySlotid(tonumber(v.slotId))



            if leftTime<=0 then --当前队列生产完成
                local pid="p"..v.itemId

                local name,pic,desc,id,index,eType,equipId,bgname = getItem(v.itemId,"p")
                local num=tonumber(v.itemNum)
                local award={type="p",key=pid,pic=pic,name=name,num=num,desc=desc,id=id,bgname=bgname}
                local reward={award}

                smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("promptProduceFinish",{getlocal(propCfg[pid].name)}),28,nil,nil,reward)
                 G_cancelPush("p".."_"..v.slotId,G_ItemProduceTag)
                 bagVoApi:addBag(v.itemId,v.itemNum) --加入背包
                 G_SyncData() --前台自己完成后需要和后台同步下
                 self.allSlots[v.slotId]=nil
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
         local waitSlots=self:getAllSolts()
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






