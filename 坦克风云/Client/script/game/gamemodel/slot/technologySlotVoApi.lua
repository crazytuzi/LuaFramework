technologySlotVoApi={
     allSlots={},
     flag=1,
}

function technologySlotVoApi:clear()
    for k,v in pairs(self.allSlots) do
         v=nil
    end
    self.allSlots=nil
    self.allSlots={}
    self.flag=1
end

function technologySlotVoApi:getAllSlots()
    return self.allSlots
end
function technologySlotVoApi:getFlag()
    return self.flag
end
function technologySlotVoApi:setFlag(flag)
    self.flag=flag
end

--检测队列是否已满
function technologySlotVoApi:checkIsFull()
    local queueCfg=playerCfg.vipProuceQueue
    local queueNum=Split(queueCfg,",")[playerVoApi:getVipLevel()+1]
    if  SizeOfTable(self.allSlots)>=tonumber(queueNum) then
        do
            return true
        end
    end
    return false
end

function technologySlotVoApi:add(tid,st,et,tc,slotid,hid)
    --local queueCfg=playerCfg.vipProuceQueue
    --[[
            local queueNum=Split(queueCfg,",")[playerVoApi:getVipLevel()+1]
            if  SizeOfTable(self.allSlots)>=tonumber(queueNum) then
                do
                    return false
                end
            end
    ]]
    local techSlotVo=technologySlotVo:new()
    local status
    local tvo=technologyVoApi:getTechVoByTId(tid)
    if  et==nil then
        status=2

    else
        status=1
         G_pushMessage(getlocal("produce_finish1",{getlocal(techCfg[tvo.id].name),"("..G_LV()..(tvo.level+1)..")"}),et-base.serverTime,"tc"..tvo.id,G_TechUpgradeTag)
    end
    tvo.status=status
    tvo.isFinishedUpgrade=false
    techSlotVo:initData(tid,st,et,status,st,tc,slotid,hid)
    self.allSlots[tid]=techSlotVo
end

--初始化科技升级队列slotTb={{tid,st,status}}
function technologySlotVoApi:init(slotTb)
   for k,v in pairs(slotTb) do
        local techSlotVo=technologySlotVo:new()
        techSlotVo:initData(v[1],v[2],v[3],v[4])
        self.allSlots[v[1]]=techSlotVo
   end
   --table.sort(self.allSlots,function(a,b) return (a.st < b.st) end)
end

function technologySlotVoApi:getSlotByTid(tid)
    return self.allSlots[tid]
    --[[
    for k,v in pairs(self.allSlots) do
         if v.tid==tid then
             return v
         end
    end
    ]]
end
--刷新队列
function technologySlotVoApi:tick()
    
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
            local tvo=technologyVoApi:getTechVoByTId(v.tid)
            local tCfg=techCfg[k]
            local totalTime=v.timeConsume 
            --tonumber(Split(tCfg.timeConsumeArray,",")[tvo.level+1])
            --local hasUpgradeTime=base.serverTime-v.st+dyTime
            if base.serverTime>=v.et then --当前队列升级完成
                
                smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("promptResearchFinish",{getlocal(techCfg[v.tid].name)}),28)
                 technologyVoApi:upgradeSuccess(k)

                 self.allSlots[k]=nil
                 tvo.status=0
                 tvo.isFinishedUpgrade=true

                 runNextSlot=true
                 G_SyncData() --前台自己完成后需要和后台同步下
            end
        end
        --[[
        else --等待队列
            if runNextSlot==true then
                 local tvo=technologyVoApi:getTechVoByTId(v.tid)
                 runNextSlot=false
                 v.status=1
                 tvo.status=1
                 tvo.isFinishedUpgrade=false
                 v.st=base.serverTime
            end
        end
        ]]
    end
     if hasUpgradeSlot==false or runNextSlot==true then
         runNextSlot=false
         local waitSlots=self:getAllSlotSortBySt()
         for k,v in pairs(waitSlots) do
             if v.status==2 then
                 local tvo=technologyVoApi:getTechVoByTId(v.tid)
                 tvo.status=1
                 tvo.isFinishedUpgrade=false
                 v.status=1
                 v.st=base.serverTime 
                 v.et=v.st+v.timeConsume
                 do
                     return
                 end
             end
         end
     end
end

function technologySlotVoApi:getAllSlotSortBySt()
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

function technologySlotVoApi:cancleByTid(tid)
    self.allSlots[tid]=nil
    self:tick()
end

function technologySlotVoApi:getCurProduceSlot()
    for k,v in pairs(self.allSlots) do
        if v.status==1 then
            do
                return technologyVoApi:getTechVoByTId(v.tid)
            end
        end
    end
end

--免费加速某个科技队列
function technologySlotVoApi:freeAccHandler(techId,callback)
    if techId then
        local function superServerHandler(fn,data)
            if base:checkServerData(data)==true then
                technologyVoApi:superUpgrade(techId)
                if callback then
                    callback()
                end
            end
        end
        socketHelper:freeUpgradeTech(techId,superServerHandler)
    end
end