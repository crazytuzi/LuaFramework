function model_buildings(uid,data)
local self = {
    uid = uid, 
    b1 = {7,1}, b2 = {}, b3 = {}, b4 = {}, b5 = {}, b6 = {}, b11 = {6,1}, b12 = {}, b13 = {}, b16 = {}, b17 = {}, b18 = {}, b19 = {}, b20 = {}, b21 = {}, b22 = {}, b23 = {}, b24 = {}, b25 = {}, b26 = {}, b27 = {}, b28 = {}, b29 = {}, b30 = {}, b31 = {}, b32 = {}, b33 = {}, b34 = {}, b35 = {}, b36 = {}, b37 = {}, b38 = {}, b39 = {}, b40 = {}, b41 = {}, b42 = {}, b43 = {}, b44 = {}, b46 = {}, b47 = {}, b48 = {}, b49 = {}, b50 = {}, b51 = {},b106 = {},
    queue={},
    updated_at = 0,
    auto = 0,
    auto_expire = 0,

}
    
  -- private fields are implemented using locals
  -- they are faster than table access, and are truly private, so the code that uses your class can't get them
  -- local test = uid
  
   function self.bind(data)
        if type(data) ~= 'table' then
            return false 
        end
        
        data.auto = data.auto or 0
        data.auto_expire = data.auto_expire or 0
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

        if #self.b11 < 1 then
            self.b11 = {6, 1}
        end

        return true
    end
  
    function self.toArray(format)    
        local data = {}
        for k,v in pairs (self) do
            if type(v)~="function" and k~= 'uid' and k~= 'updated_at' then              
                if format then
                    if k=='queue' then
                        data[k] = v
                    elseif type(v) == 'table'  then
                        if next(v) then data[k] = v end
                    elseif v ~= 0 and v~= '0' and v~='' then
                        data[k] = v
                    end
                                            
                else
                    data[k] = v
                end
            end
        end

        if moduleIsEnabled("auto_build") ~= 1 then
            data.auto = nil
            data.auto_expire = nil
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
  
    function self.update()      
        if type(self.queue) == 'table' then  
            local ts = getClientTs()
                for k,v in pairs (self.queue) do
                    if type(v) == 'table' and type(self[v.id]) ~= nil then    
                        local et = tonumber(v.et) or 0
                        if et > 0 and et <= ts then    
                            self.openSlot(k)
                            self.levelUp(v.id,v.type)
                        end
                    else
                        table.remove(self.queue,k)
                    end    
                end
        end
    end
        
    -- 升级
    function self.levelUp(bid,buildType)
        if type(self[bid]) == 'table' then
            self[bid][2] = 1+ (self[bid][2] or 0)
            -- 0升到1，即建造时无建筑类别，此时写入建筑类别
            if not self[bid][1] then
                self[bid][1] = buildType
            end

            --主基地等级活动
            if(bid=='b1')then
                activity_setopt(self.uid,'baseLeveling',self[bid][2],true) 
                activity_setopt(self.uid,'bindbaseLeveling',self[bid][2]) 
                -- 设置钢铁之心  主基地升级任务
                activity_setopt(self.uid,'heartOfIron',{blevel=self[bid][2]}) 
                -- 百级开启 
                activity_setopt(self.uid,'levelopen',{act='f1',level=self[bid][2]})
            end
            if(bid=='b3')then
                -- 百级开启 
                activity_setopt(self.uid,'levelopen',{act='f3',level=self[bid][2]})
            end

            -- 日常任务
            local uobjs = getUserObjs(self.uid)

            -- 主城达到设定等级 体力上限值增加5点 更新此时体力恢复cd值
            if bid =='b1' and buildType==7  and moduleIsEnabled('uel') ==1 then
                local mainCityEnergy = getConfig('player.mainCityEnergy')
                if table.contains(mainCityEnergy.level, self.b1[2]) then
                    local extraEnergy = self.getExtraEnergy()
                    local mUserinfo = uobjs.getModel('userinfo')
                    mUserinfo.setExtraEnergy(extraEnergy)
                end
            end

            -- 德国七日狂欢
            activity_setopt(self.uid,'sevendays',{act='sd2',v=self,n=1})


            local mDailyTask = uobjs.getModel('dailytask')
            mDailyTask.changeTaskNum1("s1002")
            --新的日常任务检测
            mDailyTask.changeNewTaskNum('s103',1)

            --更新繁荣度最大值
            local mBoom = uobjs.getModel('boom')
            mBoom.calcBoom_max()

            -- 解锁飞机
            if bid =='b106' then
                local mPlane = uobjs.getModel('plane')
                mPlane.setLevel(self[bid][2])
            end

            -- 跨服战资比拼 指挥中心
            if bid == 'b1' then
                zzbpupdate(self.uid,{t='f5',n=self[bid][2]})
            end

            -- 跨服战资比拼 科技中心
            if bid == 'b3' then
                zzbpupdate(self.uid,{t='f6',n=self[bid][2]})
            end
           

        end
    end
        
    function self.remove(bid,buildType)
        if type(self[bid]) == 'table' and self[bid][1] == buildType then
            local cfg = getConfig('building.'..buildType)
            if cfg.isRemove == 'true' then            
                if self.checkIdInSlots(bid) then 
                    return false,-3002
                else
                    self[bid] = {}
                    return true
                end
            else
                return false,-3001
            end
        end
    end
    
    function self.getLevel(bid)
        self.update()
        return type(self[bid]) == 'table' and self[bid][2] or 0
    end

    function self.getMainCityLevel()
        return self.getLevel('b1')
    end

    -- 仓库容量
    -- 仓库保护量，超出此量的资源，在玩家攻打成功时将被掠夺
    function self.getStoragesCapacity(vip)
        local uservip = vip or 0
        local catpcity = 0
        local cfg = getConfig('building.10')

        local arrayGet = arrayGet
        local storageLevel = arrayGet(self.b4,2,0)
        catpcity = catpcity + arrayGet(cfg,'capacity>'..storageLevel,0)

        storageLevel = arrayGet(self.b5,2,0)
        catpcity = catpcity + arrayGet(cfg,'capacity>'..storageLevel,0)

        -------------------- start vip新特权 仓库保护量增加
        if moduleIsEnabled('vps') == 1 and uservip>0 then
                local vipRelatedCfg = getConfig('player.vipRelatedCfg')
                if type(vipRelatedCfg)=='table' then
                    local vip =vipRelatedCfg.protectResources[1]
                    if uservip>=vip then
                        catpcity=catpcity*vipRelatedCfg.protectResources[2]
                    end
                end 
                               
        end
        --------------------- end
        
        return catpcity
    end

    -- 建筑是否解锁
    -- return bool
    function self.buildingIsUnlock(bid,buildType)
        local baseLevel = self.getMainCityLevel()
        local cfg = getConfig("homeCfg")

        local isUnlock = false
        if type(cfg.indexForBuildType[bid]) == 'table' then
 
            for k,v in pairs(cfg.indexForBuildType[bid]) do
                if v == buildType then isUnlock = true ; break end
            end
        else
            if cfg.indexForBuildType[bid] == buildType then
                isUnlock = true
            end
        end

        return isUnlock and cfg.pIndexArrayByLevel[bid] <= baseLevel
    end

    -- 指定的造船厂是否已解锁指定的船只
    -- aid 船名
    -- return bool
    function self.shipIsUnlock(aid,bid)    
        local shipyardLevel = self.getLevel(bid)
        local cfg = getConfig("building.6.buildPropSids")
        return cfg[aid] and cfg[aid] <= shipyardLevel
    end

    -- 科技院是否解锁此科技
    -- tid 科技id
    -- return bool
    function self.techIsUnlock(tid)
        local buildingLevel = self.getLevel('b3')
        local cfg = getConfig("building.8.buildPropSids")
        return cfg[tid] and cfg[tid] <= buildingLevel
    end

    -- 在改装厂中是否解锁
    -- aid 船名
    -- bid 地块名，改装厂有可能会扩展出第二个,改装厂中解锁的船只按最高等级的造船厂算
    -- return bool
    function self.shipUpIsUnlock(aid,bid)        
        local shipyardLevel1 = self.getLevel('b11')
        local shipyardLevel2 = self.getLevel('b12',1)
        local shipyardLevel = shipyardLevel1 > shipyardLevel2 and shipyardLevel1 or shipyardLevel2
        local cfg = getConfig("building.14.buildPropSids")
        return cfg[aid] and cfg[aid] <= shipyardLevel
    end

    -- 联盟建筑是否解锁
    function self.allianceIsUnlock()
        return self.buildingIsUnlock('b7',15)
    end    

    --队列操作------------------------------------------------------------------------------

    -- 使用队列
    function self.useSlot(slotInfo)
        assert2(not self.checkIdInSlots(slotInfo.id),'Being upgraded')
        local slot = self.getOpenSlot(slotType)

        if slot then
            for k,v in pairs (slotInfo) do
                  slot[k] = v
            end

            table.insert(self.queue,slot)
            return true
        end

        return false
    end   

    -- 验证当前bid是否在队列中
    function self.checkIdInSlots(bid)
        for k,v in pairs(self.queue) do
            if v.id == bid then return k end
        end
        return false
    end

    -- 获取打开未使用的slot
    function self.getOpenSlot()
        local uobjs = getUserObjs(uid)        
        local mUserinfo = uobjs.getModel('userinfo')

        local iSlotNums = mUserinfo.buildingslots
        local iCurrSlotNums = table.length(self.queue)    

        assert2(iCurrSlotNums < iSlotNums,'no open slot')

        local cfg = getConfig('player')
        local iVipLevel = mUserinfo.vip or 0
        local currMaxSlots = cfg.vip4BuildQueue[iVipLevel + 1] or mUserinfo.buildingslots
        if iSlotNums > currMaxSlots then 
            mUserinfo.buildingslots = currMaxSlots
        end

        local newSlot = {}
        newSlot.slotid = self.getSlotId()

        return newSlot
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

    -- 打开队列
    function self.openSlot(slotName) 
        if self.queue[slotName] then
            local hid = self.queue[slotName].hid or 0
            self.delhelpinfo(hid)                           
            table.remove(self.queue,slotName)
            return true
        end
        return false
    end

   --是否队列已满
    function self.isSlotFull()
        local uobjs = getUserObjs(uid)
        local mUserinfo = uobjs.getModel('userinfo')
        local cfg = getConfig('player')
        local iVipLevel = mUserinfo.vip or 0
        local iSlotNums = mUserinfo.buildingslots
        local currMaxSlots = cfg.vip4BuildQueue[iVipLevel + 1] or iSlotNums
        if iSlotNums > currMaxSlots then
            mUserinfo.buildingslots = currMaxSlots
        end

        local iSlotNums = mUserinfo.buildingslots
        local iCurrSlotNums = table.length(self.queue)
        return iCurrSlotNums >= iSlotNums
    end

    --自动升级
    function self.autoUpgrade()
        self.update()
        local uobjs = getUserObjs(uid)
        local mUserinfo = uobjs.getModel('userinfo')
        local mTech = uobjs.getModel('techs')
        local mUseractive = uobjs.getModel('useractive')

        local baseLevel = self.b1[2]
        local homeCfg = getConfig("homeCfg")
        local buildIds = table.keys(homeCfg.indexForBuildType)
        table.sort(buildIds,function(a,b) return tonumber(string.sub(a, 2)) < tonumber(string.sub(b, 2)) end)

        --writeLog('auto','error')
        --填充队列
        while true do
            if self.isSlotFull() then
                break
            end

            local found = false
            local bid
            local discount = 1

            local versionLevel = getVersionCfg().buildingMaxLevel

            --排序建筑顺序
            for _,i in pairs(buildIds) do
                local tempBid = i
                local tempBInfo = self[tempBid]

                if type(tempBInfo)=='table' and next(tempBInfo) then
                    -- 不在升级中
                    local cfg = getConfig('building')[tempBInfo[1]]
                    local localDiscount = 1
                    if  not self.checkIdInSlots(tempBid) then
                        local currLevel = self[tempBid][2] or 0
                        -- 当前地块等级小于最大等级 大于0级
                        if currLevel>0 and currLevel  < cfg.maxLevel then
                            local upLevel = 1 + currLevel

                            -- if tempBInfo[1] == 7 then
                            --     local activStatus = mUseractive.getActiveStatus('commandcentrelevelup')
                            --     if activStatus == 1 then -- 活动检测
                            --         local activeParams = {buildType=tempBInfo[1],level=upLevel}
                            --         local tmpdiscount = activity_setopt(uid,'commandcentrelevelup',activeParams)
                            --         if tmpdiscount > 0 and tmpdiscount < 1 then
                            --             localDiscount = tmpdiscount
                            --         end
                            --     end
                            -- end

                            --特殊处理其他建筑,建筑等级限制
                            if (tempBid=='b1' and baseLevel<versionLevel) or (tempBid~='b1' and currLevel<baseLevel) then
                                found = true

                                --排序
                                local priorityFunction = function(bid1,bid2)
                                    assert(bid1 and bid2,'bid1 and bid2 should be not null')

                                    if self[bid2][2] < self[bid1][2] then
                                        return true
                                    end

                                    if self[bid2][2] == self[bid1][2] then
                                        local cfg1 = getConfig('building')[self[bid1][1]]
                                        local cfg2 = getConfig('building')[self[bid2][1]]
                                        if cfg1.sortId > cfg2.sortId then
                                            return true
                                        end
                                    end
                                    return false
                                end

                                if not bid or priorityFunction(bid,tempBid) then
                                    --判断资源足够

                                    local bRes = {}
                                    bRes.r1 = cfg.metalConsumeArray[upLevel] * localDiscount
                                    bRes.r2 = cfg.oilConsumeArray[upLevel] * localDiscount
                                    bRes.r3 = cfg.siliconConsumeArray[upLevel] * localDiscount
                                    bRes.r4 = cfg.uraniumConsumeArray[upLevel] * localDiscount
                                    bRes.gold = cfg.moneyConsumeArray[upLevel] * localDiscount

                                    -- 是否够资源
                                    if mUserinfo.checkResource(bRes) then
                                        bid = tempBid
                                        discount = localDiscount
                                    end
                                end
                            end
                        end
                    end
                end
            end

            if found and bid == nil then
                -- writeLog('found but no enough resource','error')
                break
            else
                if bid then
                    --升级建筑
                    local ts = getClientTs()
                    local cfg = getConfig('building')[self[bid][1]]

                    local currLevel = self[bid][2] or 0
                    local upLevel = 1 + currLevel
                    local iConsumeTime = cfg.timeConsumeArray[upLevel]
                     -- 科技影响
                    local techLevel =  tonumber(mTech.getTechLevel('t23'))
                    --  区域战职位
                    local mJob =uobjs.getModel('jobs')
                    local mSequip =uobjs.getModel('sequip')
                    -- 1 就是建筑加速
                    local value =mJob.getjobaddvalue(1)            
                    local equipvalue = mSequip.skillAttr('s304', 0) -- 急速建造 提高建造速度X

                    -- 战争雕像建造加速
                    local mStatue  = uobjs.getModel('statue')
                    local statuevalue = mStatue.getSkillValue('buildSpeed') or 0
                    -- 远洋征战
                    local oceanExpBuff = mUserinfo.getOceanExpeditionBuff("buildSpeed") 

                    iConsumeTime = iConsumeTime /(1+techLevel*0.05 + value + equipvalue + statuevalue + oceanExpBuff)

                    local bSlotInfo = {st=ts,id=bid,type=self[bid][1]}
                    bSlotInfo.et = ts+iConsumeTime  * discount
                    bSlotInfo.dis = discount

                    local bRes = {}
                    bRes.r1 = cfg.metalConsumeArray[upLevel] * discount
                    bRes.r2 = cfg.oilConsumeArray[upLevel] * discount
                    bRes.r3 = cfg.siliconConsumeArray[upLevel] * discount
                    bRes.r4 = cfg.uraniumConsumeArray[upLevel] * discount
                    bRes.gold = cfg.moneyConsumeArray[upLevel] * discount

                    --self.useSlot(bSlotInfo)


                    --消耗资源
                    if mUserinfo.useResource(bRes) then
                        -- 使用队列
                        self.useSlot(bSlotInfo)
                    else
                        writeLog('auto upgrade failed '..bid,'auto_building')
                        break
                    end

                else
                   break
                end
            end
        end

    end

     -- 升级后或者取消删除自己的帮助信息
    function self.delhelpinfo(hid)
        if hid~=nil and tonumber(hid)>0 then
            ALLIANCEHELP = require "lib.alliancehelp"
            ALLIANCEHELP:del(hid)
            regSendMsg(self.uid,"msg.event",{helpdel={del=hid}})
        end
    end

    -- 道具加速
    function self.speedupTime(bid, discInter)
        local iSlotKey = self.checkIdInSlots(bid)
        if not iSlotKey or type(self.queue[iSlotKey]) ~= 'table' then return false end

        self.queue[iSlotKey].et = self.queue[iSlotKey].et - discInter
        self.queue[iSlotKey].st = self.queue[iSlotKey].st - discInter
        if self.queue[iSlotKey].et <= getClientTs() then
            self.queue[iSlotKey].et = getClientTs()
            self.update()
        end

        return true
    end

    -- 获取主城的体力上限加成
    function self.getExtraEnergy()
        local mainCityEnergy = getConfig('player.mainCityEnergy')
        if type(mainCityEnergy.level) =='table' then
            for i=#mainCityEnergy.level,1,-1 do
                if self.b1[2] >= mainCityEnergy.level[i] then
                    return mainCityEnergy.energy[i]
                end
            end
        end
        return 0
    end

    -----------------------------------------------------------
        
    return self
end    
