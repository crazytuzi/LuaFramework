function model_props(uid,data)
    local self = {
        uid = uid,
        info = {},
        allianceinfo = {    -- 记录军团商店信息（购买的）
            a={},   -- 珍品购买信息
            p={},   -- 普通商品购买信息
            s={},   -- 领地商店
        }, 
        shop={}, -- 商店够买记录
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
                elseif vType == 'table' and type(data[k]) ~= 'table' then
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
                    if format and k ~= 'allianceinfo' then
                        if type(v) == 'table'  then
                            data[k] = v
                            --if next(v) then data[k] = v end
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
      
    -- timeType 加工厂与坦克厂表示时间的字段不一样
    function self.getUpLevelTimeConsume(id,bid,startTime)
        local uobjs = getUserObjs(self.uid)
        local mBuilding = uobjs.getModel('buildings')
        local mJob  = uobjs.getModel('jobs')
        -- 8 是生产道具加少时间
        local jobvalue =mJob.getjobaddvalue(8) -- 区域站生产道具加少时间
        
        local iSlotKey = mBuilding.checkIdInSlots('building',bid)        
        local bLevel , iConsumeTime= arrayGet(mBuilding[bid],2,0) 
        local cfg = getConfig('prop.' .. id)
        local timeValue = arrayGet(cfg,'timeConsume')
        
        if iSlotKey and type(mBuilding.queue[iSlotKey]) == 'table' then
            local iBuildSlotEt = mBuilding.queue[iSlotKey].et            
            startTime = startTime or 0
            if startTime >= iBuildSlotEt then
                 iConsumeTime = getbuildQueueRate(bLevel+ 1,timeValue,0,jobvalue)       
            end
        end

        if not iConsumeTime then iConsumeTime = getbuildQueueRate(bLevel,timeValue,0,jobvalue)   end        
        return assert2(iConsumeTime, 'get new slot ConsumeTime failed ')
    end

    function self.update()
        local uobjs = getUserObjs(self.uid)        
        local mBag = uobjs.getModel('bag')

        local slots = self.queue
        local ts = getClientTs()

         -- 先更新下除队列1之外，其它队列的的消耗时间(科技院是否新升级了)
        if type(self.queue) == 'table' then
            local prevEt = 0            
                for k,v in pairs (self.queue) do
                    if k == 1 then
                        prevEt = v.et
                    elseif type(v) == 'table' and self.isAbleProduce(v.id) then
                        local newTimeConsume = self.getUpLevelTimeConsume(v.id,'b6',prevEt) * v.nums
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
                    if type(v) == 'table' and self.isAbleProduce(v.id) then
                        local et = tonumber(v.et) or 0
                        local st = tonumber(v.st) or 0

                        if et > 0 and et <= ts then                        
                            self.openSlot(k) 
                            mBag.add(v.id,v.nums)   
                            return refresh()
                        end
                     end
                end
            end 

            refresh()
    end

    function self.speedup(pid,nums,slotid)
        self.update()

        local uobjs = getUserObjs(self.uid)         
         local mUserinfo = uobjs.getModel('userinfo') 

         -- 占用的卡槽位置
         local iSlotKey = self.checkIdInSlots(slotid)
         
         if type(self.queue[iSlotKey]) == 'table' then
           
             local st = tonumber(self.queue[iSlotKey].st) or 0
             local et = tonumber(self.queue[iSlotKey].et) or 0
            
            if st > 0 and et >= 0 then                             
                -- todo 宝石计算 
                local currentTs = getClientTs()                 
                local surplusTime = et - currentTs
                local iGems = speedConsumeGems(surplusTime)
                --活动检测
                iGems = activity_setopt(self.uid,'speedupdisc',{speedtype="prop", gems=iGems},false,iGems)

                -- 使用资源
                if  mUserinfo.useGem(iGems) then    
                    local mBag = uobjs.getModel('bag')
                    mBag.add(pid,self.queue[iSlotKey].nums)         
                    self.openSlot(iSlotKey)
                    return iGems,nums,et
                end  
            end   
        end
    end    

    function self.cancel(pid,nums,slotid)
        self.update()

        local uobjs = getUserObjs(self.uid)
        local iSlotKey = self.checkIdInSlots(slotid)
        local bSlot = self.queue[iSlotKey]

        if type(bSlot) == 'table' then                
                local cfg = getConfig('prop.' .. pid)
                local rate = getResRate4Cancel(bSlot.st,bSlot.et)
                
                -- todo 返还资源公式 返还值=升级完成剩余时间 / 总时间*升级所需资源                
                if cfg then                    
                    local bResources = {}
                    bResources.gold = cfg.moneyConsume * rate * bSlot.nums
                    local propConsume = arrayGet(cfg,'propConsume')
                    
                    -- 返还其它需要的道具
                    if type(propConsume) == 'table' then
                        local mBag = uobjs.getModel('bag')
                        local pNum = math.floor(propConsume[2]*bSlot.nums*rate)
                        mBag.add(propConsume[1],pNum)
                    end

                    local mUserinfo = uobjs.getModel('userinfo')
                    if mUserinfo.addResource(bResources) and self.openSlot(iSlotKey) then 
                        return true,bSlot.et
                    end
                end
            end

        return false
    end
    
    function self.usePropSlot(pid,slot)
        local slotInfo = copyTab(slot)
        if type(slotInfo) == 'table' then
            local iUsedSlotKey =  self.pidIsInUse(pid)
            if iUsedSlotKey then
                local isNew = self.info[iUsedSlotKey].et < slotInfo.st
                for k,v in pairs(slotInfo) do
                    if k == 'st' then
                        if isNew then self.info[iUsedSlotKey][k] = v    end
                    elseif k == 'et' then
                         if isNew then  
                            self.info[iUsedSlotKey][k] = v  
                         else
                            self.info[iUsedSlotKey][k] = self.info[iUsedSlotKey][k] + (slotInfo.et - slotInfo.st) 
                        end
                    else
                        self.info[iUsedSlotKey][k] = v
                    end
                end
            else
                local propCfg = getConfig('prop')
                if propCfg[pid].buffid and propCfg[pid].buffType and propCfg[pid].buffLevel then
                    for k,v in pairs(self.info) do
                        if propCfg[pid].buffType == propCfg[v.id].buffType and propCfg[pid].buffLevel > propCfg[v.id].buffLevel then
                            self.info[k] = slotInfo
                            return true
                        end
                    end     
                end  

                table.insert(self.info,slotInfo)         
            end

            return true
        end

        return false
    end 

    function self.pidIsInUse(pid)
        if type(self.info) == 'table' then            
            for k,v in pairs(self.info) do
                if type(v) == 'table' and v.id then 
                    if v.id == pid and (tonumber(v.et) or 0) > getClientTs() then return tonumber(k) end
                else
                    table.remove(self.info,k)
                    return self.pidIsInUse(pid)
                end
            end
        end

        return false
    end

    function self.isAbleProduce(pid)
        local uobjs = getUserObjs(self.uid)
        local mUserinfo = uobjs.getModel('userinfo')
        local prop = {p5=true,p6=true,p7=true,p8=true,p9=true,p10=true,p13=true,p3417=true}
        -------------------- start vip新特权 装置车间增加可制造物品
        if moduleIsEnabled('vap') == 1 and mUserinfo.vip>0 then
                local vipRelatedCfg = getConfig('player.vipRelatedCfg')
                if type(vipRelatedCfg)=='table' then
                    local vip =vipRelatedCfg.addCreateProps[1]
                    if mUserinfo.vip>=vip then
                        if type(vipRelatedCfg.addCreateProps[2])=='table' then
                            for k,v in pairs(vipRelatedCfg.addCreateProps[2]) do
                                prop[v]=true
                            end
                        end
                    end
                end 

        end
        --------------------- end
        return prop[pid]
    end

    -- 刷新使用的道具CD时间
    function self.updateUsePropCd()
        if type(self.info) == 'table' then
            local ts = getClientTs()
            for k,v in pairs(self.info) do
                if type(v) == 'table' then
                    if v.et  < ts then
                        table.remove(self.info,k)
                        if v.id then--v.id 道具编号
                            local uobjs = getUserObjs(self.uid)
                            local mUserinfo = uobjs.getModel('userinfo')
                            -- 同步玩家的头像 、头像框、挂件
                            mUserinfo.listenpid(v.id)
                        end

                        return self.updateUsePropCd()
                    end
                else
                    table.remove(self.info,k)
                    return self.updateUsePropCd()
                end
            end
        end
    end

    -- 清除道具的使用状态
    function self.clearUsePropCd(pid)
        if type(self.info) == 'table' then
            for k,v in pairs(self.info) do
                if type(v) == 'table' and v.id == pid then
                    table.remove(self.info,k)
                    return true
                end
            end
        end
    end

    --队列操作------------------------------------------------------------

    -- 使用队列
    function self.useSlot(slotInfo)
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

    -- 是否能使用
    function self.checkPropCanUse(pid)
        local propCfg = getConfig('prop')

        if propCfg[pid].isUseable ~= 'true' then
            return false
        end

        if propCfg[pid].buffid and propCfg[pid].buffType and propCfg[pid].buffLevel then
            for _,v in pairs(self.info or {}) do 
                if type(propCfg[pid].buffid) == 'table' then
                    for _,n in ipairs(propCfg[pid].buffid) do
                        if propCfg[n].buffType == propCfg[v.id].buffType and propCfg[n].buffLevel < propCfg[v.id].buffLevel then
                            return false
                        end
                    end
                else
                    if propCfg[pid].buffType == propCfg[v.id].buffType and propCfg[pid].buffLevel < propCfg[v.id].buffLevel then
                        return false
                    end
                end
            end
        end

        return true
    end
    --  info中相同ty标识且时间没到期的的数量
    function self.tyInUse(ty)
        local tmp={}
        local info={}
        if type(self.info) == 'table' then
            for k,v in pairs(self.info) do
                if type(v) == 'table' and v.ty and (tonumber(v.et) or 0) > getClientTs() then
                    if v.ty==ty then 
                        if not table.contains(tmp,v.id) then
                            table.insert(tmp,v.id)
                            table.insert(info,v)
                        end
                    end
                end
            end
        end

        return tmp,info
    end
    -- 获取使用中的数据
    function self.getInUseBypid(pid)
        local r={id=pid,st=0,et=0}
        if type(self.info) == 'table' then            
            for k,v in pairs(self.info) do
                 if type(v) == 'table' and (tonumber(v.et) or 0) > getClientTs() then
                    if v.id == pid  then return v end
                 else
                    table.remove(self.info,k)
                 end
            end
        end

        return r
    end

    -- 获取道具cd队列中所有关于头像、头像框、挂件的数据
    function self.getAllp()
        local r={}
        if type(self.info) == 'table' then            
            for k,v in pairs(self.info) do
                 if type(v) == 'table' and v.pid and (tonumber(v.et) or 0) > getClientTs() then
                    if table.contains({"p","b","a","e"},v.ty) then
                        r[v.pid]=v.et
                    end
                 end
            end
        end

        return r
    end


    ----------------------------------------------------------------------

    if type(self.info) ~= 'table' then
        self.info = {}
    end

    return self
end    

