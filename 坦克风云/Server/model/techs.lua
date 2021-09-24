function model_techs(uid,data)
    local self = {
        uid = uid, t1 = 0, t2 = 0, t3 = 0, t4 = 0, t5 = 0, t6 = 0, t7 = 0, t8 = 0, t9 = 0, t10 = 0, t11 = 0, t12 = 0, t13 = 0, t14 = 0, t15 = 0, t16 = 0, t17 = 0, t18 = 0, t19 = 0, t20 = 0, t21 = 0, t22 = 0, t23 = 0, t24 = 0, t25 = 0, t26 = 0, t27 = 0, t28 = 0, t29 = 0, t30 = 0, t31 = 0, t32 = 0,
        queue = {},
        updated_at = 0,
    }
    
  -- private fields are implemented using locals
  -- they are faster than table access, and are truly private, so the code that uses your class can't get them
  -- local test = uid

   function self.bind(data)
        if type(data) ~= 'table' then
            return false
        end
        
        for k,v in pairs (self) do
            local vType = type(v)
            if vType~="function" then
                if data[k] == nil then return false end
                if vType == 'number' then
                    self[k] = tonumber(data[k]) or data[k]
                else
                    self[k] = data[k]
                end
            end
        end

        return true
    end

  function self.toArray(format)
    local data = {}
        for k,v in pairs (self) do
            if type(v)~="function" and k~= 'uid' and k~= 'updated_at' then              
                if format then
                    if type(v) == 'table'  then
                        data[k] = v
                        -- if next(v) then data[k] = v end
                    elseif v ~= 0 and v~= '0' and v~='' then
                        data[k] = v
                    end
                else
                    data[k] = v
                end
            end
        end

    return data
end

  function self.getKeys()
      local data = {}
      for k,v in pairs (self) do
          if type(v)~="function" then
              table.insert(data,k)
          end
      end
      return data
  end
  
    function self.upgrade(tid)
        self.update()

        local uobjs = getUserObjs(self.uid)   
        local mUserinfo = uobjs.getModel('userinfo')        
        local mBuilding = uobjs.getModel('buildings')

        -- 科技是否解锁
        assert2 (mBuilding.techIsUnlock(tid), 'the tech not unlock:'.. tid)

        local cfg = getConfig('tech.' .. tid) 
        local iMaxLevel = tonumber(cfg.maxLevel) or 60
        local iUpLevel = 1 + self[tid]

        -- todo 科技与声望与最大等级限制    
        if iUpLevel <= iMaxLevel and iUpLevel <=  mBuilding.getLevel('b3') and iUpLevel <= mUserinfo.getHonorLevel()   then
            -- todo 建筑等级对速度有影响
            local iConsumeTime = self.getUpLevelTimeConsume(tid,'b3',iUpLevel)
            
            local ts = getClientTs()
            local bSlotInfo = {st=ts,id=tid}
            bSlotInfo.et = iConsumeTime + ts 
            bSlotInfo.timeConsume = iConsumeTime

            if self.useSlot(bSlotInfo) then
                local bRes = {}
                bRes.r1 = cfg.metalConsumeArray[iUpLevel] 
                bRes.r2 = cfg.oilConsumeArray[iUpLevel]
                bRes.r3 = cfg.siliconConsumeArray[iUpLevel]
                bRes.r4 = cfg.uraniumConsumeArray[iUpLevel]
                bRes.gold = cfg.moneyConsumeArray[iUpLevel]
                
                -- 使用资源
                if mUserinfo.useResource(bRes) then
                    return true,bSlotInfo.et,iUpLevel
                end
            end
        end

        return false
    end

    function self.update()        
        local ts = getClientTs()
        local iUpLevel

        -- 先更新下除队列1之外，其它队列的的消耗时间(科技院是否新升级了)
        if type(self.queue) == 'table' then
            local prevEt = 0
            for k,v in pairs (self.queue) do
                if k == 1 then
                    prevEt = v.et
                elseif type(v) == 'table' and self[v.id] ~= nil then
                    iUpLevel = 1 + self[v.id]
                    local newTimeConsume = self.getUpLevelTimeConsume(v.id,'b3',iUpLevel,prevEt)
                    self.queue[k].timeConsume = newTimeConsume
                    prevEt = prevEt + newTimeConsume
                else
                    table.remove(self.queue,k)
                end
            end
        end

        -- 刷新队列
        local refresh
        refresh = function()
            for k,v in pairs (self.queue) do
                if type(v) == 'table' and self[v.id] ~= nil then
                    local et = tonumber(v.et) or 0
                    local st = tonumber(v.st) or 0
                    iUpLevel = 1 + self[v.id]

                    if et > 0 and et <= ts then                        
                        self.openSlot(k)
                        self.levelUp(v.id)
                        return refresh()
                    end
                 end
            end
        end 

        refresh()

    end

    function self.getUpLevelTimeConsume(id,bid,iUpLevel,startTime)        
        local uobjs = getUserObjs(self.uid)
        local mBuilding = uobjs.getModel('buildings')
        local mUserinfo = uobjs.getModel('userinfo')
        local mSequip = uobjs.getModel('sequip') 
        local vip = mUserinfo.vip
        local player =getConfig('player') 
        local addition=(player.tecSpeed[vip+1])  or 0
        local iSlotKey = mBuilding.checkIdInSlots(bid)
        local bLevel , iConsumeTime= arrayGet(mBuilding[bid],2,0)
        local cfg = getConfig('tech.' .. id)
        local mJob =uobjs.getModel('jobs')
        -- 2 是升级科技减少时间
        local jobvalue =mJob.getjobaddvalue(2) -- 区域站减少时间
        -- 战争雕像科技加速
        local mStatue = uobjs.getModel('statue')
        jobvalue = (jobvalue or 0) + (mStatue.getSkillValue('studySpeed') or 0)
        local equipvalue = mSequip.skillAttr('s301', 0) -- 急速科技 
        -- 远洋征战
        local oceanExpBuff = mUserinfo.getOceanExpeditionBuff("studySpeed") 
        if iSlotKey and type(mBuilding.queue[iSlotKey]) == 'table' then
            local iBuildSlotEt = mBuilding.queue[iSlotKey].et
            startTime = startTime or 0
            if startTime >= iBuildSlotEt then
                 iConsumeTime = getbuildQueueRate(bLevel+ 1,cfg.timeConsumeArray[iUpLevel],addition,jobvalue,equipvalue,oceanExpBuff)            
            end
        end

        if not iConsumeTime then iConsumeTime = getbuildQueueRate(bLevel,cfg.timeConsumeArray[iUpLevel],addition,jobvalue,equipvalue,oceanExpBuff)   end
        
        return assert2(iConsumeTime,'get new slot ConsumeTime failed ')
    end

    function self.speedup(slotid)        
        self.update()

        local uobjs = getUserObjs(self.uid)
        local mUserinfo = uobjs.getModel('userinfo') 

         -- 占用的卡槽位置
         local iSlotKey = self.checkIdInSlots(slotid)
         
         if type(self.queue[iSlotKey]) == 'table' then
            local et = tonumber(self.queue[iSlotKey].et) or 0
            
            if et > 0 then
                -- todo 宝石计算 
                local currentTs = getClientTs()                 
                local remainsecs = et - currentTs
                local iGems = speedConsumeGems(remainsecs)
                --活动检测
                iGems = activity_setopt(self.uid,'speedupdisc',{speedtype="tech", gems=iGems},false,iGems)

                -- 使用资源
                if  mUserinfo.useGem(iGems) then
                    local tid = self.queue[iSlotKey].id
                    self.levelUp(self.queue[iSlotKey].id)
                    self.openSlot(iSlotKey)
                    return tid,iGems,et                
                end  
            end   
        end
    end    

    function self.speedupTime(slotid, discInter)
        self.update()

        local iSlotKey = self.checkIdInSlots(slotid)
        if type(self.queue[iSlotKey]) ~= 'table' then
            return false
        end

        self.queue[iSlotKey].et = self.queue[iSlotKey].et - discInter
        self.queue[iSlotKey].st = self.queue[iSlotKey].st - discInter
        if self.queue[iSlotKey].et <= getClientTs() then
            self.queue[iSlotKey].et = getClientTs()
            self.update()
        end
        
        return true
    end

    function self.cancel(slotid)
        self.update()    

        local iSlotKey = self.checkIdInSlots(slotid)
        local bSlot = self.queue[iSlotKey]
        
        if type(bSlot) == 'table' then                
                local cfg = getConfig('tech.' .. bSlot.id)
                local rate = getResRate4Cancel(bSlot.st,bSlot.et)                
                
                -- todo 返还资源公式 返还值=升级完成剩余时间 / 总时间*升级所需资源                
                if cfg then 
                    local upLevel = 1 + (tonumber(self[bSlot.id]) or 0)
                    local bRes = {}
                    bRes.r1 = rate * cfg.metalConsumeArray[upLevel]
                    bRes.r2 = rate * cfg.oilConsumeArray[upLevel]
                    bRes.r3 = rate * cfg.siliconConsumeArray[upLevel]
                    bRes.r4 = rate * cfg.uraniumConsumeArray[upLevel]
                    bRes.gold = rate * cfg.moneyConsumeArray[upLevel]

                    local uobjs = getUserObjs(self.uid)
                    local mUserinfo = uobjs.getModel('userinfo')
                    if mUserinfo.addResource(bRes) and self.openSlot(iSlotKey) then          
                        return true,bSlot.et,bSlot.id
                    end
                end
            end

        return false
    end
    
    function self.levelUp(tid)
        if self[tid] then
            self[tid] = 1 + (tonumber(self[tid]) or 0)

            -- 设置钢铁之心 之科技的等级
            activity_setopt(self.uid,'heartOfIron',{tech=self[tid]})
            -- 百级开启
            activity_setopt(self.uid,'levelopen',{act='f5',level=self[tid]})
            -- 战力刷新
            regEventBeforeSave(self.uid,'e1')
            
            --日常任务
            local uobjs = getUserObjs(self.uid)
            local mDailyTask = uobjs.getModel('dailytask')
            mDailyTask.changeTaskNum1("s1003")
            --新的日常任务检测
            mDailyTask.changeNewTaskNum('s104',1)
        end
    end

    function self.getTechLevel(tid)
        self.update()
        return self[tid] or 0
    end

    -- 加成的百分比
    function self.getTechRate(tid)
        local rate = 1
        local cfg = getConfig('tech.'..tid..'.value')
        local value = arrayGet(cfg,self[tid],0)
        
        return rate + value/100
    end

    --队列操作------------------------------------------------------------

        -- 验证当前bid是否在队列中
    function self.checktidInSlots(tid)
        for k,v in pairs(self.queue) do
            if v.id == tid then return k end
        end
        return false
    end

    -- 使用队列
    function self.useSlot(slotInfo)
        assert2(not self.checktidInSlots(slotInfo.id),'Being upgraded')
        local slot , wait = self.getOpenSlot()

            if slot then
            if type(slotInfo) == 'table' then                    
                      for k,v in pairs (slotInfo) do
                          if k == 'et' then
                            -- 如果是等待队列，不设置结束时间
                              if not wait then slot[k] = v end
                          else
                              slot[k] = v
                          end
                      end
                end

            table.insert(self.queue,slot)
            return true
        end

        return false
    end   

    function self.getOpenSlot()
        local uobjs = getUserObjs(self.uid)
        local mUserinfo = uobjs.getModel('userinfo') 
                
        local cfg = getConfig('player.vipProuceQueue')
        local vipLevel = arrayGet(mUserinfo,'vip',0) + 1

        -- 检测当前拥有的队列数            
        local iSlotNums = cfg[vipLevel] or 1
        local iCurrSlotNums = table.length(self.queue)

        assert2(iCurrSlotNums < iSlotNums,'no open slot')

        local newSlot = {}
        newSlot.slotid = self.getSlotId()
        return newSlot , iCurrSlotNums > 0
    end

    -- 打开队列
    function self.openSlot(slotName)
        if self.queue[slotName] then
            local et = self.queue[slotName].et or 0
            local hid = self.queue[slotName].hid or 0
            self.delhelpinfo(hid)

            local ts = getClientTs()
            local nextSt = ts >= et and et or ts

            table.remove(self.queue,slotName)

            if et > 0 then
                for k,v in ipairs(self.queue) do
                    self.queue[k].st = nextSt
                    self.queue[k].et = nextSt + self.queue[k].timeConsume
                    break       
                end
            end

            return true
        end

        return false
  end


    -- 升级的id是否已经出现在了序列中
    -- return false|slotkey
    function self.checkIdInSlots(slotid)                   
        for k,v in pairs(self.queue) do
            if v.slotid == slotid then return tonumber(k) end
        end
        return false
    end

    -- 生成slot的唯一标识
    function self.getSlotId()
        if type(self.queue) == 'table' then
            local ids = {}

            for k,v in pairs(self.queue) do
                ids[v.slotid] = 1
            end

            for i=1,100 do 
                if not ids[i] then return i end
            end
        end

        return 1
    end

    -- 升级后或者取消删除自己的帮助信息
    function self.delhelpinfo(hid)
        if hid~=nil and tonumber(hid)>0 then
            ALLIANCEHELP = require "lib.alliancehelp"
            ALLIANCEHELP:del(hid)
            regSendMsg(self.uid,"msg.event",{helpdel={del=hid}})
        end
    end
    --------------------------------------------------------------
    
    return self
end    
