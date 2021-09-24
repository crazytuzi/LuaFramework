function model_troops(uid,data)
    local self = {
        uid = uid,
        troops = {a10001 = 0, a10002 = 0, a10003 = 3, a10004= 0, a10005= 0, a10011= 0, a10012= 0, a10013= 0, a10014= 0, a10015= 0,  a10021= 0, a10022= 0, a10023= 0, a10024= 0, a10025= 0, a10031= 0, a10032= 0, a10033= 2, a10034= 0, a10035= 0,a10043=0,a10053=0,a10063=0,a10073=0,a10082=0,a10006=0,a10016=0,a10026=0,a10036=0,a10093=0,a10044=0,a10103=0,a10054=0,a10113=0,a10123=0,a10064=0,a10074=0,a10007=0,a10017=0,a10027=0,a10037=0,a10074=0,a10083=0,a10094=0,a10114=0,a10124=0,a20153=0,a20154=0,a10045,a20055,a20065,a10075,a10084,a10095,a10135,a10145,a20115,a20125,a20155,},
        damaged = { a10001 = 0, a10002 = 0, a10003 = 0, a10004= 0, a10005= 0, a10011= 0, a10012= 0, a10013= 0, a10014= 0, a10015= 0,  a10021= 0, a10022= 0, a10023= 0, a10024= 0, a10025= 0, a10031= 0, a10032= 0, a10033= 0, a10034= 0, a10035= 0,a10043=0,a10053=0,a10063=0,a10073=0,a10082=0,a10006=0,a10016=0,a10026=0,a10036=0,a10093=0,a10044=0,a10103=0,a10054=0,a10113=0,a10123=0,a10064=0,a10074=0,a10007=0,a10017=0,a10027=0,a10037=0,a10074=0,a10083=0,a10094=0,a10114=0,a10124=0,a20153=0,a20154=0,a10045,a20055,a20065,a10075,a10084,a10095,a10135,a10145,a20115,a20125,a20155,},
        defense = {},
        helpdefense = {c=nil,list={}},
        attack= {},
        alliancewar={},
        invade={},
        queue = {tank1={},tank2={},tankdiy1={}},
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
        
        local repairTankids ={a10001 = 0, a10002 = 0, a10003 = 0, a10004= 0, a10005= 0, a10011= 0, a10012= 0, a10013= 0, a10014= 0, a10015= 0,  a10021= 0, a10022= 0, a10023= 0, a10024= 0, a10025= 0, a10031= 0, a10032= 0, a10033= 0, a10034= 0, a10035= 0,a10043=0,a10053=0,a10063=0,a10073=0,a10082=0,a10006=0,a10016=0,a10026=0,a10036=0,a10093=0,a10044=0,a10103=0,a10054=0,a10113=0,a10123=0,a10064=0,a10074=0,a10007=0,a10017=0,a10027=0,a10037=0,a10074=0,a10083=0,a10094=0,a10114=0,a10124=0, a10043=0,a10053=0,a10063=0,a10073=0,a10082=0,a10006=0,a10016=0,a10026=0,a10036=0,a10093=0,a10044=0,a10103=0,a10054=0,a10113=0,a10123=0,a10064=0,a10074=0,a10007=0,a10017=0,a10027=0,a10037=0,a10074=0,a10083=0,a10094=0,a10114=0,a10124=0}

        for k,v in pairs(repairTankids) do
            if not self.troops[k] then
                self.troops[k] = v
            end

            if not self.damaged[k] then
                self.damaged[k] = v
            end
        end
        

        if type(self.invade) ~= 'table' then
            self.invade = {}
        end

        if type(self.alliancewar) ~= 'table' then
            self.alliancewar = {}
        end

        self.updateAttack(true)

        return true
    end

    function self.toArray(format)
          local data = {}
              for k,v in pairs (self) do
                  if type(v)~="function" and k~= 'uid' and k~= 'updated_at' then              
                      if format then
                          if type(v) == 'table'  then
                                    if k == 'defense' then
                                        data[k] = self.getDefenseFleet()
                                    elseif k=='queue' then
                                        data[k] = v
                                  elseif next(v) then 
                                        data[k] = {}
                                        for m,n in pairs(v) do
                                            if n ~= 0 then data[k][m] = n end
                                        end
                                    else
                                        data[k] = v
                                  end
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

      -- 获取部队
    function self.getTroops()
        local data = {}
        if type(self.troops) ~= 'table' then self.troops = {} end

        for k,v in pairs(self.troops) do
            if v ~= 0 then
                data[k] = v
            end
        end

        return data
    end

    -- 获取损坏的部队
    function self.getDamagedTroops()
        local data = {}
        if type(self.damaged) ~= 'table' then self.damaged = {} end

        for k,v in pairs(self.damaged) do
            if v ~= 0 then
                data[k] = v
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

    -----------------------------------------------------------------------------------------------------------------------
    --
    --  坦克操作
    --
    -----------------------------------------------------------------------------------------------------------------------
    
    ----- 刷新队列    
    function self.update()
        -- 所有的队列名
        local  allQname = self.bid2Qname()        
        local uobjs = getUserObjs(self.uid) 

        local ts = getClientTs(true)
        local queue = self.queue

        for bid,qName in pairs(allQname) do
            local slots = queue[qName] or {}

            -- 坦克改装厂与制造厂配制标识不一样
            local sTimeType = self.qName2TimeType(qName)

            -- 先更新下除队列1之外，其它队列的的消耗时间(科技院是否新升级了)
            if type(slots) == 'table' then
                local prevEt = 0  -- 队列列表中，前一个队列的结束时间
                for k,v in pairs (slots) do
                    if k == 1 then
                        prevEt = v.et   -- 第一个队列，无需等待
                    elseif type(v) == 'table' and v.id ~= nil then
                        local newTimeConsume = self.getUpLevelTimeConsume(v.id,bid,sTimeType,prevEt) * v.nums
                        queue[qName][k].timeConsume = newTimeConsume
                        prevEt = prevEt + newTimeConsume
                    else
                        table.remove(queue[qName],k)    -- 清除此队列
                    end
                end
            end

            -- 刷新队列
            local refresh
            refresh = function()
                for k,v in pairs (slots) do
                    if type(v) == 'table' and v.id ~= nil then
                        local et = tonumber(v.et) or 0
                        local st = tonumber(v.st) or 0

                        if et > 0 and et <= ts then 
                            self.openSlot(k,qName)
                            --军备换代
                            if qName == 'tankdiy1' then
                                v = activity_setopt(self.uid, "armamentsUpdate1", {type=1, v=v}) or v
                                v = activity_setopt(self.uid, "armamentsUpdate2", {type=1, v=v}) or v

                                -- 跨服战资比拼
                                zzbpupdate(self.uid,{t='f8',id=v.id,n=v.nums})
                            end
                            self.incrTanks(v.id,v.nums)
                              
                            --self.troops[v.id] = self.troops[v.id] + v.nums
                            -- 活动 军备竞赛收集龙珠
                            activity_setopt(self.uid,'armsRace',{[v.id]=v.nums})

                            ----5.1钛矿丰收周
                            activity_setopt(self.uid,'taibumperweek',{t=v.nums})
                            -- 日常任务
                            local mDailyTask = uobjs.getModel('dailytask')
                            mDailyTask.changeTaskNum1("s1001",v.nums)
                            --新的日常任务检测
                            mDailyTask.changeNewTaskNum('s102',v.nums)
                          
                            if qName ~= 'tankdiy1' then
                                --writeLog('造船:'..self.uid..' task=f7 id='..v.id..'n='..v.nums,'zzbp') 
                                -- 跨服战资比拼
                                zzbpupdate(self.uid,{t='f7',id=v.id,n=v.nums})

                                -- 远洋征战 士气值
                                activity_setopt(self.uid,'oceanmorale',{act='proShip',id=v.id,num=v.nums})
                            end

                            return refresh()
                        end
                     end
                end
            end 

            refresh()

        end
    end

    -- 升级需要消耗的时间（建筑等级有加成）
    -- timeType 改装厂与坦克工厂表示时间的字段在配制文件中是不一样的
    -- id 坦克标识
    -- bid 建筑标识
    -- [startTime] 起始时间
    function self.getUpLevelTimeConsume(id,bid,timeType,startTime)
        local uobjs = getUserObjs(self.uid)  
        local mBuilding = uobjs.getModel('buildings')
        local mUserinfo = uobjs.getModel('userinfo')
        local mAlien = uobjs.getModel('alien')
        local mJob  = uobjs.getModel('jobs')
        local mSequip = uobjs.getModel('sequip')
        -- 6 是生产坦克时间减少
        local jobvalue =mJob.getjobaddvalue(6) -- 区域站生产坦克减少
        local vip = mUserinfo.vip
        local cfg = getConfig('tank.' .. id)
        local player =getConfig('player') 
        local addition=0
        local equipvalue = 0
        if timeType=='timeConsume' then
            addition=(player.productTankSpeed[vip+1])  or 0
            equipvalue = mSequip.skillAttr('s302', 0) -- 急速生产
        else
            addition=(player.refitTankSpeed[vip+1])  or 0
            equipvalue = mSequip.skillAttr('s303', 0) -- 急速改造
        end

        local iSlotKey = mBuilding.checkIdInSlots(bid)
        local bLevel , iConsumeTime= arrayGet(mBuilding[bid],2,0) 
        local timeValue = arrayGet(cfg,timeType)
        local ailenConsumeTime=mAlien.getTankSpeedTime(id)
        timeValue=timeValue-ailenConsumeTime
        if timeValue <0 then
            timeValue=0
        end

        
        -- 建筑出现在升级序列中的位置,
        if iSlotKey and type(mBuilding.queue[iSlotKey]) == 'table' then
            local iBuildSlotEt = mBuilding.queue[iSlotKey].et
            
            -- 如果有起始时间，并且起始时间大于了建筑升级结束的时间，
            -- 按公式获取在当前建筑等级下生产兵种所需要的时间
            startTime = startTime or 0
            if startTime >= iBuildSlotEt then
                 iConsumeTime = getbuildQueueRate(bLevel+1,timeValue,addition,jobvalue,equipvalue)
            end
        end

        if not iConsumeTime then 
            iConsumeTime = getbuildQueueRate(bLevel,timeValue,addition,jobvalue,equipvalue)   
        end

        if iConsumeTime then
            return iConsumeTime
        end

        writeLog("get new slot ConsumeTime failed")
        tankError({code=-2004})
    end

    -- 取消队列中的任务
    function self.cancel(bid,slotid)
        self.update()

        local qName = self.bid2Qname(bid)        
        local iSlotKey = self.checkIdInSlots(slotid,qName)
        local bSlot = self.queue[qName][iSlotKey]
        
        if type(bSlot) == 'table' then
                local aid = assert2(bSlot.id,'aid invalid')
                local nums = assert2(bSlot.nums,'num invalid')
                local cfg = getConfig('tank.' .. aid)
                
                local rate = getResRate4Cancel(bSlot.st,bSlot.et)     

                local bRes = {}
                bRes.r1 = rate * nums * cfg.metalConsume
                bRes.r2 = rate * nums * cfg.oilConsume
                bRes.r3 = rate * nums * cfg.siliconConsume
                bRes.r4 = rate * nums * cfg.uraniumConsume
                
                local uobjs = getUserObjs(self.uid)
                local mUserinfo = uobjs.getModel('userinfo')
                if mUserinfo.addResource(bRes) and self.openSlot(iSlotKey,qName) then    
                    return true
                end
            end

        return false
    end
    
    -----------------------------------------------------------------------------------------------------------------------
    --
    --  改装厂
    --
    -----------------------------------------------------------------------------------------------------------------------

    -- 刷新改装厂队列
    function self.upgradeupdate()
        self.update()
    end

    -- 按bid获取队列名称
    function self.bid2Qname(bid)
        local bidQname = {b11='tank1',b12='tank2',b13='tankdiy1'}
        if not bid then return bidQname end
        return assert2(bidQname[bid],'not find queue name :' .. bid)
    end

    -- 按队列名称获取配制文件中的时间字段
    function self.qName2TimeType(qName)
        local q2Type = {
            tankdiy1='upgradeTimeConsume',
            tank1='timeConsume',
            tank2='timeConsume'
        }
        if not qName then return q2Type end
        return assert2(q2Type[qName],'not find timeType :' .. qName)
    end

    ---------消耗坦克-------
    function self.consumeTanks(tid,num,isDefense)
        num = math.floor(num)
        if num >= 0 and self.troops[tid] then
            local n = self.troops[tid] - num 
            if n < 0 then 
                writeLog(self.uid .. ': not enough tank' .. tid) 
                return false                
            end
            self.troops[tid] = n

            -- if self.troops[tid] == 0 then
            --     self.troops[tid] = nil
            -- end

            regEventBeforeSave(self.uid,'e1')

            if isDefense then
                self.updateDefenseFleet(tid,num)
            else
                self.updateDefenseFleet()
            end

            return true
        end

        writeLog(self.uid .. ':consume tank tid invalid')
        return false
    end

    --------坦克量增加-------
    function self.incrTanks(tid,num)
        if not self.troops[tid] then 
            self.troops[tid] = 0 
        end

        num = math.floor(num)
        if num > 0 and self.troops[tid] then
            self.troops[tid] = self.troops[tid] + num
            regEventBeforeSave(self.uid,'e1')
             -- 设置钢铁之心 之重型的数量
            activity_setopt(self.uid,'heartOfIron',{[tid]=self.troops[tid]})
            -- 德国七日狂欢
            activity_setopt(self.uid,'sevendays',{act='addtank',v=0,n=self.troops})

            return true
        end
    end

    -- 所有的坦克，出战与在家的，计算战力的时候用 + 护航队列
    function self.formatTotalTroopsByType()
        local totalTroops = {}
        if type(self.troops) == 'table' then
            for k,v in pairs(self.troops) do
                v = v or 0
                if v > 0 then
                    totalTroops[k] = (totalTroops[k] or 0) + v
                end
            end
        end

        if type(self.attack) == 'table' then
            for _,v in pairs(self.attack) do
                if type(v) == 'table' and type(v.troops) == 'table' then
                    for _,n in pairs(v.troops) do
                        if type(n) == 'table' and next(n) then
                            totalTroops[n[1]] = (totalTroops[n[1]] or 0) + (tonumber(n[2]) or 0)
                        end
                    end
                end
            end
        end

        local uobjs = getUserObjs(self.uid)
        local mAweapon = uobjs.getModel('alienweapon')
        if type(mAweapon.trade) == 'table' and next(mAweapon.trade) then
            for _, v in pairs(mAweapon.trade) do
                if type(v) == 'table' and type(v.orgtroops) == 'table' then
                    for _,n in pairs(v.orgtroops) do
                        if type(n) == 'table' and next(n) then
                            totalTroops[n[1]] = (totalTroops[n[1]] or 0) + (tonumber(n[2]) or 0)
                        end
                    end
                end
            end
        end

        return totalTroops
    end

    -----------------------------------------------------------------------------------------------------------------------
    --
    --  防守舰队
    --
    -----------------------------------------------------------------------------------------------------------------------

    ----------------------设置防守舰队---------------------
    function self.setDefenseFleet(fleetInfo)        
        if type(fleetInfo) == 'table' then
	    local flag = false
            if type(self.defense)=='table' and next(self.defense) then
                flag = true
            end
            self.defense = self.updateFleetInfo(fleetInfo)
	     regKfkLogs(self.uid,'tankChange',{
                    addition={
                        {desc="时间", value=getClientTs()},
                        {desc="部队",value=self.defense},
                        {desc="之前是否设置",value=flag},
                    }
                }
            ) 
            return true 
        end
    end

    -- 更新防守方案
    function self.updateDefenseFleet(aid,num)
        local uobjs = getUserObjs(self.uid)
        local mUserinfo = uobjs.getModel('userinfo')
        -- local autoDefence = arrayGet(mUserinfo.flags,'gameSetting>s4',1)
        local mSequip = uobjs.getModel('sequip')
        local equipid = mSequip.getEquipFleet('d',1)
        local autoDefence = 0

        if tonumber(autoDefence) == 0 then
            if self.troops[aid] and num > 0 then  
                local max_troops = self.getMaxBattleTroops(equipid)
                for k,v in pairs(self.defense) do
                    if v[1] == aid then
                        local n = v[2] - num
                        if n < 0 then
                            num = num - v[2]
                            n = 0
                            self.defense[k][2] = n
                        else
                            self.defense[k][2] = n
                            --检测带兵量 繁荣度
                            if n > max_troops then
                                self.defense[k][2] = max_troops
                            end
                            break
                        end                        
                    end 
                end
            else
                self.defense = self.updateFleetInfo(self.defense)
            end
        end
        
    end

    ---------fleetInfo:{{a10001=10},{a10002=10},{a10003=10}}
    -- 刷新舰队信息
    function self.updateFleetInfo(fleetInfo)
        self.update()

        local uobjs = getUserObjs(self.uid)
        local mSequip = uobjs.getModel('sequip')
        local equipid = mSequip.getEquipFleet('d',1)

        local currentFleet = {}
        local num, tmp = 0, {}
        local max_troops = self.getMaxBattleTroops(equipid)
        if type(fleetInfo) == 'table' then
            for m,n in pairs(fleetInfo) do
                currentFleet[m] = {}
                if type(n)=='table' and next(n) then
                    if not tmp[n[1]] then tmp[n[1]] =  self.troops[n[1]] or 0 end
                    num = tmp[n[1]] or 0
                    num = num >= n[2] and n[2] or num
                    --带兵量会下降，需要检测带兵量 繁荣度
                    if num > max_troops then num = max_troops end
                    currentFleet[m] = {n[1],num}
                    tmp[n[1]] = tmp[n[1]] - num
                end
            end
        end

        return currentFleet
    end

    -- 获取防守舰队
    function self.getDefenseFleet()
        if type(self.defense) ~= 'table' then
            self.defense = {}
        end

        return self.updateFleetInfo(self.defense)
    end

    -----------------------------------------------------------------------------------------------------------------------
    --
    --  损坏的舰队
    --
    -----------------------------------------------------------------------------------------------------------------------

    --------损坏的坦克量增加-------
    function self.incrDamagedTanks(aid,num)
        num = math.floor(tonumber(num) or 0)
        if not self.damaged[aid] then self.damaged[aid] = 0 end
        if num > 0 and self.damaged[aid] then
            self.damaged[aid] = self.damaged[aid] + num
        end
    end

    -- 修复坦克
    function self.repairTanks(aid,num)
        num = math.floor(tonumber(num) or 0)
        if num > 0 and self.damaged[aid] then
            if num > self.damaged[aid] then
                num = self.damaged[aid]
            end
            self.damaged[aid] = self.damaged[aid] - num
            self.incrTanks(aid,num)

            -- if self.damaged[aid] == 0 then
            --     self.damaged[aid] = nil
            -- end
            return true
        end
    end

    -----------------------------------------------------------------------------------------------------------------------
    --
    --  舰队操作
    --
    -----------------------------------------------------------------------------------------------------------------------
    function self.addAttackFleet(cronId,fightFleet)
        if not self.attack[cronId] then
            self.attack[cronId] = fightFleet
            return true
        end
    end

    -- 检测定时舰队的状态
    function self.checkCronFleetStatus(cid)
        local status = 0
        if not self.attack[cid] then
            status = -1
        elseif type(self.attack[cid]) == 'table' then
            if self.attack[cid].bs then 
                status = 1  -- 回家途中
            elseif self.attack[cid].gts then 
                status = self.attack[cid].isGather  -- 采集状态
            elseif self.attack[cid].isHelp == 1 and isGather ~= 0 then
                status = self.attack[cid].isGather
            elseif self.attack[cid].seaWarFlag then
                -- 0是出发中,非0表示已经到达
                status = self.attack[cid].isGather or 0
            end
        end

        return status
    end

    -- 出战舰队的ID
    function self.getAttackFleetId()
        local key = string.sub(os.time(),-6)
        local count = table.length(self.attack)
        key = tonumber(key .. count)

        return key
    end

    -- 舰队返回
    -- params boolean notTimeConsume 无消耗时间，直接回家，异星地图中玩家来去都不需要消耗时间
    function self.fleetBack(cid,notTimeConsume)
        local arrayGet = arrayGet
        local ts = getClientTs()
        
        -- self.updateAttack()
        
        if type(self.attack[cid]) == 'table' and not self.attack[cid].bs then
            local uobjs = getUserObjs(self.uid)
            local mTech = uobjs.getModel('techs')
            local mUserinfo = uobjs.getModel('userinfo')
            local vip  = mUserinfo.vip
            local player =getConfig('player') 
            local addition=(player.marchSpeed[vip+1])  or 0
            local mProp = uobjs.getModel('props')
            local techLevel = mTech.getTechLevel('t22')
            local propCfg = getConfig('prop')
            local mJob =uobjs.getModel('jobs')
            local mStatue = uobjs.getModel('statue')
            -- 3 是行军速度减少时间
            local jobvalue =mJob.getjobaddvalue(3) -- 区域站减少时间
            -- 战争雕像减少行军时间
            jobvalue = jobvalue + (mStatue.getSkillValue('moveSpeed') or 0)

            local asaddition = 0
            if self.attack[cid].isHelp == 1 and mUserinfo.alliance>0 then
                local allAllianceSkills = M_alliance.getAllianceSkills{aid=mUserinfo.alliance}
                if type(allAllianceSkills) == 'table' then
                    if allAllianceSkills.s15~=nil and allAllianceSkills.s15>0 then
                        allianceSkillCfg = getConfig("allianceSkillCfg.s15")
                        if allianceSkillCfg.batterValue[allAllianceSkills.s15] then
                            asaddition=allianceSkillCfg.batterValue[allAllianceSkills.s15]/100
                        end
                    end
                end

            end

            local timeConsume = 0

            if not notTimeConsume then
                local oceanExpBuff = mUserinfo.getOceanExpeditionBuff("moveSpeed")
                -- 行军速度
                timeConsume = marchTimeConsume(self.attack[cid].targetid,{mUserinfo.mapx,mUserinfo.mapy},techLevel,addition,asaddition,jobvalue,oceanExpBuff)

                -- 道具 13号道具 急速行军
                -- local propSlotKey = mProp.pidIsInUse('p13')
                -- if propSlotKey then
                --     if mProp.info[propSlotKey].et > ts then
                --         timeConsume = timeConsume * 0.5
                --     end
                -- end
                for k,v in pairs(mProp.info or {}) do 
                    if v.et > ts and propCfg[v.id] and propCfg[v.id].useGetCrop and propCfg[v.id].useGetCrop.sailingTime then
                        timeConsume = math.ceil(timeConsume * propCfg[v.id].useGetCrop.sailingTime)
                        break
                    end
                end

                -- 全民劳动
                local laborRate = activity_setopt(self.uid,'laborday',{act='upRate',n=4})
                if laborRate then
                    timeConsume =math.ceil(timeConsume/(1+laborRate))
                end

            end

            if self.attack[cid].type == 9 then
                self.gatherTerritoryResources(cid,mUserinfo)
            else
                self.gatherResouces(cid,mUserinfo.level)
                -- 世界等级 和矿点升级
                local mapLevel = tonumber(self.attack[cid].level) 
                local oldmapLvl= tonumber(self.attack[cid].olvl) or  tonumber(self.attack[cid].level) 
                local hour=math.floor((self.attack[cid].wkts or 0)/getConfig('goldMineCfg.upgradeTime'))
                if hour>0  then
                    -- 世界升级
                    local worldLvl=0
                    local version  =getVersionCfg()
                    if moduleIsEnabled('wl')== 1 and self.attack[cid].mid~=nil then
                        local MaxLevel=tonumber(version.roleMaxLevel)-20
                        worldLvl=getWorldLevel()
                        local addrate=mUserinfo.level - worldLvl -20
                        if addrate>0 then
                            local addexp=math.min(math.floor(addrate) * hour , 96)
                            local lvl,exp=addWorldLevelExp(addexp,MaxLevel)
                            regSendMsg(self.uid,'worldlvl.change',{lvl=lvl,exp=exp})
                        end
                    end
                    -- 矿点升级
                    if self.attack[cid].mid~=nil and  moduleIsEnabled('minellvl') == 1 then
                        local mineLvl=getConfig('goldMineCfg.mineLvl')
                        local maxMaplvl=mineLvl[version.roleMaxLevel][oldmapLvl] or mapLevel
                        if mapLevel<worldLvl and mapLevel<maxMaplvl then
                            local mMap = require "lib.map"
                            local ret,mapdata=mMap:addexp(self.attack[cid].mid,hour)
                            if ret then
                                regSendMsg(self.uid,'map.change',{exp=mapdata.exp,x=mapdata.x,y=mapdata.y,mid=self.attack[cid].mid})
                            end
                        end
                    end  
                end
            end

            if timeConsume > 10 then timeConsume = timeConsume - 10 end
            self.attack[cid].st = ts
            self.attack[cid].bs = ts + timeConsume

            if not self.attack[cid].alienMine and not self.attack[cid].seaWarFlag then
                local params = {cmd ="troop.arrivebase",uid=self.uid,params={cid=cid}}
                if timeConsume > 0 then
                    local ret = setGameCron(params,timeConsume)
                end
            end

            return true
        end
    end

    -- 采集的资源
    function self.gatherResouces(cid)
       if type(self.attack[cid]) == 'table' and self.attack[cid].isGather == 2 and self.attack[cid].bs == nil then
            if self.attack[cid].type == 9 then
                return self.gatherTerritoryResources(cid)
            end

            local ts = getClientTs()
            local gts = arrayGet(self.attack[cid],'gts') 

            -- 金矿时间已经到了
            if type(self.attack[cid].goldMine) == 'table' and self.attack[cid].goldMine[2] <= ts then
                ts = self.attack[cid].goldMine[2]
            end

            -- 采集时间
            local gatherTime = 0

            -- 如果是异星矿场来采集，需要判断当前时间是否在矿场开放时间内
            -- 防止有部队系统没有及时拉回家，而多算
            -- 有可能会跨天，计算时间时以部队当天的时间为准
            if self.attack[cid].alienMine == 1 then
                local weets = getWeeTs(self.attack[cid].dist)
                local alienMineCfg = getConfig("alienMineCfg")
                local startTime = weets + alienMineCfg.startTime[1] * 3600 + alienMineCfg.startTime[2] * 60
                local endTime = weets + alienMineCfg.endTime[1]*3600 + alienMineCfg.endTime[2]*60

                local alienMineGatherSt = gts
                local alienMineGatherTs = ts

                if alienMineGatherSt < startTime then 
                    alienMineGatherSt =  startTime 
                end

                if alienMineGatherTs > (endTime + 25) then 
                    alienMineGatherTs = endTime 

                    -- 如果当前采集时间大于了关闭时间，应该把部队返回家了
                    self.attack[cid].bs = alienMineGatherTs
                    local mMap = require "lib.alienmap"
                    mMap:changeAlienMapOwner(self.attack[cid].mid,0)
                end

                gatherTime = alienMineGatherTs - alienMineGatherSt

            else
                gatherTime = gts and (ts - gts) or 0 
            end
            
            if gatherTime <= 0 then return end
            
            if not self.attack[cid].res then self.attack[cid].res = {} end
            
            for k,v in pairs(self.attack[cid].maxRes) do
                local mapCfg = getConfig('map')
                local mapLevel = tonumber(self.attack[cid].level)          
                local mapType = tonumber(self.attack[cid].type)
                local speed = mapCfg[mapType][mapLevel].resource
                
                --驱鬼大战
                if self.attack[cid].vate then
                    speed = speed + math.ceil(self.attack[cid].vate * speed)
                end

                local proRes = gatherTime * speed / 3600
                local currRes = arrayGet(self.attack[cid].res,k,0)

                if proRes > 0 then                    
                    local info=activity_setopt(uid,"hardGetRich",{getvalue=1},true)
                    if info~=nil and info[1]>0 then
                        proRes=proRes+math.floor(proRes*info[1])
                    end  
                    
                end

                local totalRes = math.floor(proRes + currRes)
                self.attack[cid].res[k] = totalRes > v and v or totalRes                    
                self.attack[cid].gts = ts
                self.attack[cid].wkts = (self.attack[cid].wkts or 0) + gatherTime

                -- 已采满
                if self.attack[cid].res[k] == v then
                    self.attack[cid].isGather = 3
                end
            end
            
        end
    end

    -- 金矿产生的金币
    function self.gatherGoldMineGems(gatherInfo)
        local mineExpireTs = gatherInfo.goldMine[2]
        local ts = getClientTs()

        -- 如果当前时间大于金矿消失时间,取金矿消失时间
        if mineExpireTs < ts then
            ts = mineExpireTs
        end

        -- 金矿采集时间
        local gatherTime = ts - gatherInfo.gts1

        local goldMineCfg = getConfig("goldMineCfg")
        if gatherTime > goldMineCfg.resOutputCfg.u.gems.time then
            local gems = math.floor(gatherTime/goldMineCfg.resOutputCfg.u.gems.time)

            if gems > 0 then
                -- 产出金币的时间以实际产出金币重新计算
                gatherInfo.gts1 = gatherInfo.gts1 + (goldMineCfg.resOutputCfg.u.gems.time * gems)
                gatherInfo.gems = (gatherInfo.gems or 0) + gems

                -- 出bug不能无限产出金币
                local maxGems = math.floor(goldMineCfg.exploitTime / goldMineCfg.resOutputCfg.u.gems.time)
                if gatherInfo.gems > maxGems then
                    gatherInfo.gems = maxGems
                end
            end
        end
    end

    -- 军团领地资源采集
    function self.gatherTerritoryResources(cid,mUserinfo)
        if self.attack[cid].seaWarFlag then return end

        local ts = getClientTs()
        
        -- 采集完毕已回到主基地
        if self.attack[cid].bs and self.attack[cid].bs > 0 and self.attack[cid].bs < ts then
            local v = self.attack[cid]
            
            if v.troops then
                for m,n in pairs(v.troops) do
                    if n[1] and n[2] then
                        self.incrTanks(n[1],n[2])
                    end
                end
            end    

            -- kafkaLog
            local storeTroops = self.getStoreTroopsByFleet(v.troops)
            regKfkLogs(uid,'tankChange',{
                    addition={
                        {desc="id", value=cid},
                        {desc="返回",value=v.troops},
                        {desc="留存",value=storeTroops},
                        {desc="目标",value=v.targetid},
                    }
                }
            ) 
            
            if self.attack[cid].gts1 then
                local uobjs = getUserObjs(self.uid)
                if not mUserinfo then
                    mUserinfo=uobjs.getModel('userinfo')
                end

                -- 采集持续的时间会转化为对应的领地公海币
                local seacoin = 0
                local duration = self.attack[cid].st - self.attack[cid].gts1
                if duration > 0 then
                    seacoin = uobjs.getModel('atmember').setCollectedTime(self.attack[cid].gts1,duration)
                end

                -- 公海币
                local p = v
                if seacoin > 0 then
                    p = copyTable(v)
                    p.res.g1 = seacoin
                end

                -- 返回报告
                regEventsAfterSave(self.uid,'arrivebase',{
                    func=self.backReport,
                    params={
                            info=p,
                            nickname=mUserinfo.nickname,
                        }
                    }
                )
            end
            
            self.setCleanAttackByCid(cid)

        elseif self.attack[cid].isGather == 2 then
            local gts = arrayGet(self.attack[cid],'gts') 

            -- 最多只让采集固定的时间
            if self.attack[cid].ges <= ts then
                ts = self.attack[cid].ges
            end

            -- 采集时间
            local gatherTime = gts and (ts - gts) or 0
            if gatherTime > 0 then
                for k,v in pairs(self.attack[cid].maxRes) do
                    local proRes = gatherTime * self.attack[cid].speed / 3600
                    local currRes = arrayGet(self.attack[cid].res,k,0)
                    local totalRes = math.ceil(proRes + currRes)
                    self.attack[cid].res[k] = totalRes > v and v or totalRes                 
                    self.attack[cid].gts = ts

                    -- 已采满
                    if self.attack[cid].res[k] == v then
                        self.attack[cid].isGather = 3
                    end
                end
            end

            -- 超过最长采集时间60秒后,需要再次设置定时返回
            if self.attack[cid].ges <= (ts - 60) then
                self.setGoldMineBackCron(os.time()+5,cid)
            end
        end
    end

    -- 返回到家报告
    function self.backReport(uid,troopInfo,gatherBoom,nickname,alienRes)
        local mail_title =  "4-"..troopInfo.type

        local _,maxRes
        if type(troopInfo.maxRes) == 'table' then
            _,maxRes = next(troopInfo.maxRes)
        end

        local mail_content={
            type=4, --4是到家报告
            resource={
                collect=troopInfo.res,
                alienRes=alienRes,
            },
            rLv=(troopInfo.heatLv or 0),
            info={
                place=troopInfo.targetid,
                islandType = troopInfo.type,
                islandLevel = troopInfo.level,
                boom=gatherBoom,
                fleetload= maxRes, --部队载重
                time=getClientTs(), --返回时间
            }
        }

        if troopInfo.goldMine then
            mail_content.goldMineLv=troopInfo.goldMine[3] -- 金矿等级
            mail_content.goldLeftTime=troopInfo.goldMine[2] -- 金矿消失时间
            mail_content.resource.gems=troopInfo.gems -- 采集的金币

        -- 军团领地
        elseif tonumber(troopInfo.type) == 9 then
            mail_content.resource = {
                ad = troopInfo.res
            }
        end
        
        -- 三周年 冲破噩梦
        if type(troopInfo.cpem)=='table' and next(troopInfo.cpem) then
            mail_content.resource.cpem = troopInfo.cpem
        end

        MAIL:mailSent(uid,1,uid,'',nickname,mail_title,mail_content,2,0)
    end

    function self.updateAttack(autoInit)  
        self.updateHelpDefence() 
        self.updateAllianceWarTroops()

         if type(self.attack) == 'table' then

            local uobjs = getUserObjs(self.uid)
            local mUserinfo=uobjs.getModel('userinfo')
            local alliancResource={}
            local processAlienmineInfo = {}

            local ig = 0
            for k,v in pairs (self.attack) do
                if type(v) ~= 'table' then
                    self.attack[k] = nil
                elseif tonumber(v.type) == 9 and not v.seaWarFlag then
                    self.gatherTerritoryResources(k,mUserinfo)
                else
                    local bs = v.bs or 0 
                    local ts = getClientTs()

                    -- 金矿
                    if type(v.goldMine) == 'table' and bs == 0 then
                        self.gatherGoldMineGems(v)

                        -- 多个金矿同时没有回家的时候防止定时并发返回,只在初建MODEL的时候检查一次
                        ig = ig + 1
                        if autoInit and (v.goldMine[2]+15) <= ts and not v.repair then
                            self.setGoldMineBackCron(ts+5+ig,k)
                            v.repair = 1
                        end
                    end

                    if bs ~= 0 and bs <= ts then

                        local gatherBoom = 0
                        local gatherInfo = copyTable(v)
                        local collectAlienRes = {}

                        if v.res then
                            mUserinfo.addResource(v.res,true)

                            if moduleIsEnabled('boom') == 1 then
                                mBoom = uobjs.getModel('boom')
                                mBoom.update() --哦！ 获得繁荣度
                                gatherBoom = mBoom.addBoom(2, v.res) --哦！ 获得繁荣度
                            end

                            if v.goldMine then
                                local res,count = next(v.res)
                                -- 异星科技没有开放不能加异星资源
                                if  mUserinfo.level>=moduleIsEnabled('al') then
                                    collectAlienRes = self.goldAddAlien(res,count,v.AcRate,false,1)
                                end
                                
                                gatherInfo.gems = mUserinfo.addGoldMineGems(v.gems)
                            end
                            
                            -- 打人跟异星矿山不算活动
                            if tonumber(v.type)~=6 and not v.alienMine then
                                --强媳妇不算牛逼
                                activity_setopt(self.uid,"hardGetRich",v.res,true)
                                --圣诞狂欢活动
                                activity_setopt(self.uid,"shengdankuanghuan",{res=v.res,category="resource"})
                                --许愿炉活动
                                activity_setopt(self.uid,"xuyuanlu",{res=v.res,action="getresource"})
                                --5.1钛矿丰收周
                                activity_setopt(self.uid,"taibumperweek",{res=v.res})
                                --百服活动
                                activity_setopt(self.uid,"hundredactive",{res=v.res})
                                -- 圣诞大作战（2015）
                                activity_setopt(self.uid,"christmasfight",{res=v.res},true) 

                                -- 国庆七天乐
                                activity_setopt(self.uid,'nationalday2018',{act='tk',type='cj2',num=v.res}) 
                                -- 感恩节拼图
                                activity_setopt(self.uid,'gejpt',{act='tk',type='cj2',num=v.res})
                                -- 马力全开
                                activity_setopt(self.uid,'mlqk',{act='tk',type='cj2',num=v.res})

                                -- 三周年-冲破噩梦-炮弹搜索
                                local cpem = activity_setopt(self.uid,'cpem',{type='cj',num=v.res})  
                                if type(cpem)=='table' and next(cpem) then
                                    gatherInfo.cpem = cpem
                                end                             
                                for rk,rv in  pairs(v.res) do
                                    local rv = math.floor(math.abs(tonumber(rv) or 0))
                                    alliancResource[rk]=(alliancResource[rk] or 0) +rv
                                end

                                if mUserinfo.alliance > 0 then
                                    local mAterritory = getModelObjs("aterritory",mUserinfo.alliance,false,true)
                                    if mAterritory then
                                        local eventSet
                                        if mAterritory.isNormal() then
                                            mAterritory.donateCollectResource(v.res)
                                            eventSet = true
                                        end

                                        if mAterritory.uptask({act=5,val=v.res,u=mUserinfo.uid}) then
                                            writeLog('军团领地任务uid='..self.uid..'资源='..json.encode(v.res),"territory_uptask")
                                            eventSet = true
                                        end

                                        if eventSet then
                                            regEventAfterSave(self.uid,'e10',{aid=mUserinfo.alliance})
                                        end
                                    else
                                        writeLog('军团领地任务失败uid='..self.uid..'资源='..json.encode(v.res),"territory_uptask")
                                    end

                                    local mAtmember = uobjs.getModel('atmember')
                                    mAtmember.uptask({act=3,val=v.res,aid=mUserinfo.alliance})
                                end

                                -- 开启异星科技时要加道具
                                if not v.goldMine  and   not v.alienMine and moduleIsEnabled('alien') == 1 and mUserinfo.level>=moduleIsEnabled('al') then
                                    local level =v.heatLv or 0
                                    local res,count = next(v.res)
                                    collectAlienRes = self.goldAddAlien(nil,count,v.AcRate,false,2,level)
                                end
                            end
                        
                            -- 如果是异星矿场，按采集的资源比例兑换成相应的异星资源
                            if v.alienMine then
                                local alienMineCfg = getConfig("alienMineCfg")
                                local mapType = tonumber(v.type)
                                local alienResName = alienMineCfg.collect[mapType].res

                                local alienResValue = 0
                                for _,resnum in pairs(v.res or {}) do
                                   alienResValue = alienResValue + math.floor(resnum * alienMineCfg.collect[mapType].rate)
                                end

                                local alienMineBattleInfo = self.getAlienMineBattleInfo()
                                local userDailyAlineRes = tonumber(alienMineBattleInfo[alienResName]) or 0
                                local userCanGatherRes = alienMineCfg.collect[mapType].max - userDailyAlineRes
                                
                                if userCanGatherRes >= 0 then
                                    if alienResValue > userCanGatherRes then
                                        local tmpLog = {
                                            msg = 'alienResValue error',
                                            alienResValue = alienResValue,
                                            userCanGatherRes = userCanGatherRes,
                                            userDailyAlineRes = userDailyAlineRes,
                                            maxRes = alienMineCfg.collect[mapType].max,
                                        }
                                        writeLog(tmpLog,"alienmineResErr")

                                        alienResValue = userCanGatherRes
                                    end
                                    
                                    userDailyAlineRes = userDailyAlineRes + alienResValue

                                    -- setMineCount
                                    local mAlien = uobjs.getModel('alien')
                                    local addRet = mAlien.addMineProp(alienResName,alienResValue)

                                    if not addRet then
                                        local tmpLog = {
                                            msg = 'addMineProp error',
                                            alienResValue = alienResValue,
                                            userCanGatherRes = userCanGatherRes,
                                            userDailyAlineRes = userDailyAlineRes,
                                            maxRes = alienMineCfg.collect[mapType].max,
                                        }
                                        writeLog(tmpLog,"alienmineResErr")
                                    end
                                    
                                    regSendMsg(self.uid,"alien.resource.push",{prop=mAlien.prop})
                                    local alienResPoint = math.floor(alienMineCfg.resToPoint[alienResName] * alienResValue)

                                    -- 今天采集的才计入每日采集总量中
                                    if getWeeTs(v.dist) == getWeeTs() then
                                        mAlien.setMineCount(alienResPoint)
                                        table.insert(processAlienmineInfo,{mCount=mAlien.m_count,alliance=mUserinfo.alliance,point=alienResPoint,fleetInfo=v})
                                        
                                        -- local tmpLog = {
                                        --     dist = v.dist,
                                        --     getdist = getWeeTs(v.dist),
                                        --     getts = getWeeTs(),
                                        --     cid = k,
                                        --     cmd = getRequestCmd(),
                                        -- }
                                        -- writeLog(tmpLog,"cnmcc")

                                        alienMineBattleInfo[alienResName] = userDailyAlineRes
                                        self.setAllienMineBattleInfo(alienMineBattleInfo)
                                    else
                                        local tmpLog = {
                                            msg = 'not today',
                                            alienResValue = alienResValue,
                                            alienResPoint = alienResPoint,
                                            userCanGatherRes = userCanGatherRes,
                                            userDailyAlineRes = userDailyAlineRes,
                                            maxRes = alienMineCfg.collect[mapType].max,
                                            alieninfo = {mCount=mAlien.m_count,alliance=mUserinfo.alliance,point=alienResPoint}
                                        }
                                        writeLog(tmpLog,"alienmineResErr")
                                    end
                                end
                            end
                        end

                        if v.troops then
                            for m,n in pairs(v.troops) do
                                if n[1] and n[2] then
                                    self.incrTanks(n[1],n[2])
                                end
                            end
                        end    

                        -- kafkaLog
                        local storeTroops = self.getStoreTroopsByFleet(v.troops)
                        regKfkLogs(uid,'tankChange',{
                                addition={
                                    {desc="id", value=k},
                                    {desc="返回",value=v.troops},
                                    {desc="留存",value=storeTroops},
                                    {desc="目标",value=v.targetid},
                                }
                            }
                        ) 

                        self.setCleanAttackByCid(k)

                        -- 只有打野岛和有采集行为的部队才发采集报告
                        if not v.alienMine and v.type ~= 6 and (v.isGather == 2 or v.isGather == 3) then
                            -- 返回报告
                            regEventsAfterSave(self.uid,'arrivebase',{
                                func=self.backReport,
                                params={
                                        info=gatherInfo,
                                        boom=gatherBoom,
                                        nickname=mUserinfo.nickname,
                                        collectAlienRes=collectAlienRes,
                                    }
                                }
                            )
                        end

                    elseif v.isGather == 2 then
                        self.gatherResouces(k,mUserinfo.level)
                    elseif v.isHelp == 1 and bs == 0 then
                        if ts >= v.dist and v.isGather == 0 then
                            v.isGather = 4
                        end
                    end 
                end
            end

            if #processAlienmineInfo > 0 then
                regEventsAfterSave(self.uid,'e9',processAlienmineInfo)
            end

            -- 军团活跃
            if next(alliancResource) then
                if mUserinfo.alliance>0 then
                    local allianceActive = getConfig("alliance.allianceActive")
                    local weeTs = getWeeTs()
                    local execRet, code = M_alliance.setResource{uid=uid,weet=weeTs,aid=mUserinfo.alliance,res=json.encode(alliancResource)}
                    if execRet and execRet.alliance_members and execRet.alliance_ainfo then
                       local pushData = {ainfo = execRet.alliance_ainfo,}
                       for k,v in pairs(execRet.alliance_members) do
                           local mid = tonumber(v.uid) or 0
                           if mid > 0 then
                               regSendMsg(mid,'push.alliance.setResource',pushData)
                           end
                       end
                    end
                        --测试通过要干掉
                        --if not execRet then
                          --  response.ret = code
                            --return response
                        --end
                end
            end
        end
    end

    function self.updateHelpDefence()  
         if type(self.helpdefense) == 'table' and type(self.helpdefense.list) == 'table' then
            local ts = getClientTs()

            for k,v in pairs (self.helpdefense.list) do

                if type(v) ~= 'table' then
                    self.helpdefense.list[k] = nil
                elseif v.status == 0 and v.ts <= ts then
                    self.helpdefense.list[k].status = 1
                end

            end 
        end
        
    end

    -- 定时任务
    function self.setGameCron(uid,targetid,delay_time)
        local cronid = self.getAttackFleetId()   
        local zoneid = getZoneId()
        local params = {cronid=cronid,target = targetid,attacker=uid,zoneid=zoneid}
        params = json.encode(params)

        local scheduleJob = getConfig("config.z".. zoneid ..".scheduleJob")

        local haricot = require "lib.haricot"
        local bs = haricot.new(scheduleJob.host, scheduleJob.port)
        bs:use('battle')
        local exec = bs:put(0, delay_time, 1, params)
        bs:disconnect()
        if exec then
            return 'c'..cronid
        end
        
        -- local strHttp = 'http://localhost:8310/addjob/?ts='.. ts .. '&params=' .. params..'&zoneid='..getZoneId()
        -- local http = require("socket.http")
        -- local ret, e = http.request(strHttp)

        -- if tonumber(e) == 200 then
        --     ret = json.decode(ret)
        --     return 'c'..cronid
        -- end
        
        return false
    end

    -- 根据cronId获取舰队
    function self.getFleetByCron(cronId)
        return arrayGet(self.attack,cronId) 
    end
    -- 清除出战队列
    function self.setCleanAttackByCid(cronId)
        if self.attack[cronId]~=nil then
            local uobjs = getUserObjs(self.uid)
            local mHero  = uobjs.getModel('hero')
            mHero.releaseHero('a',cronId)

            local mSequip = uobjs.getModel('sequip')
            mSequip.releaseEquip('a',cronId)
            local mPlane = uobjs.getModel('plane')
            mPlane.releasePlane('a',cronId)

            self.attack[cronId]=nil
        end
    end

    -- 根据cronId获取舰队带兵量
    function self.getFleetTroopsByCron(cronId)
        local fleet = self.getFleetByCron(cronId)
        if fleet then
            return fleet.troops
        end
    end

    ----------按地图Id获取当前正在此岛上采资源的舰队
    function self.getGatherFleetByMid(mid)
        self.updateAttack()
        local pos = getPosByMid(mid)

        if type(self.attack) == 'table' then
            local pairs = pairs
            for k,v in pairs(self.attack) do
                if pos.x == arrayGet(v.targetid,1) and pos.y == arrayGet(v.targetid,2) and (v.isGather == 2 or v.isGather == 3) and not v.bs then
                    return v,k
                end
            end
        end
    end

    function self.getGatherFleetByAlienMineMid(mid)
        self.updateAttack()

        if type(self.attack) == 'table' then
            local pairs = pairs
            for k,v in pairs(self.attack) do
                if tonumber(v.mid) == tonumber(mid) and (v.isGather == 2 or v.isGather == 3) and v.alienMine then
                    return v,k
                end
            end
        end
    end

    ---------当前拥有的舰队数量
    function self.getFleetNums()
        return table.length(self.attack)
    end

    -------舰队数量是否合法
    -- 统御等级与基础带兵量
    function self.checkFleetInfo(fleetInfo,dietroops,equip)

        self.update()

        if type(fleetInfo) ~= 'table' then
            writeLog(self.uid .. ': fleet invalid')
            return false
        end

        local totalFleetInfo = {}
        local maxNum = self.getMaxBattleTroops(equip)
        
        for m,n in pairs(fleetInfo) do 
            if type(n) == 'table' and next(n) then
                local currtroops = arrayGet(n,2,0)

                totalFleetInfo[n[1]] = (totalFleetInfo[n[1]] or 0) + currtroops               
                
                -- 最大带兵量检测
                if currtroops > maxNum then
                    return false
                end    
            end
        end

        local num = 0

        for k,v in pairs(totalFleetInfo) do    
            num = arrayGet(self.troops,k,0)
            if type(dietroops) =='table' and dietroops[k]~=nil and dietroops[k]>0 then
                num=num-dietroops[k]
            end 

            if num < v then
                -- writeLog(self.uid .. ': not enough tank : '.. k)
                return false
            end
        end
        
        return true
    end


    --  世界大战检测兵力
    function self.checkWorldWarFleetInfo(fleetInfo,equip)

        if type(fleetInfo) ~= 'table' then
            writeLog(self.uid .. ': fleet invalid')
            return false
        end

        local totalFleetInfo = {}
        local maxNum = self.getMaxBattleTroops(equip)
        
        for m,n in pairs(fleetInfo) do 
            if type(n) == 'table' and next(n) then
                local currtroops = arrayGet(n,2,0)
                totalFleetInfo[n[1]] = (totalFleetInfo[n[1]] or 0) + currtroops               
                
                -- 最大带兵量检测
                if currtroops > maxNum then
                    writeLog(self.uid .. ': overstep max nums')
                    return false
                end    
            end
        end
        return true
    end

    -- 世界大战计算出坦克的具体值

    function self.getFleetdata(fleetInfo1,fleetInfo2,fleetInfo3,heros,line,btype,equip,plane)
        local uobjs = getUserObjs(self.uid)
        local mUserinfo = uobjs.getModel('userinfo')
        local params = {}
        local flag={2,2,2}
        local sevCfg=getConfig("worldWarCfg")
        local fleetInfo=sevCfg.troops
        if (type(fleetInfo1)=='table' and not next(fleetInfo1)) or fleetInfo1==nil then
            fleetInfo1=fleetInfo 
            flag[1]=1
        end
        if (type(fleetInfo2)=='table' and not next(fleetInfo2)) or fleetInfo2 ==nil then
            fleetInfo2=fleetInfo
            flag[2]=1
        end
        if (type(fleetInfo3)=='table' and not next(fleetInfo3))  or fleetInfo3==nil then
            fleetInfo3=fleetInfo
            flag[3]=1
        end
        if type(equip) ~= 'table' then
            equip = {0,0,0}
        end
        if type(plane) ~= 'table' then
            plane = {0,0,0}
        end

        local hero1 =heros[1]
        local hero2 =heros[2]   
        local hero3 =heros[3]

        local equip1 = equip[1]
        local equip2 = equip[2]
        local equip3 = equip[3]
        local plane1 = plane[1]
        local plane2 = plane[2]
        local plane3 = plane[3]

        if type(line)=='table' and next(line) then
            hero1 =heros[line[1]]
            hero2 =heros[line[2]]   
            hero3 =heros[line[3]]

            equip1=equip[line[1]]
            equip2=equip[line[2]]
            equip3=equip[line[3]]
            plane1=plane[line[1]]
            plane2=plane[line[2]]
            plane3=plane[line[3]]
        end  

        local fleetInfo1,accessoryEffectValue1,herosinfo1,planevalue1 =self.initFleetAttribute(fleetInfo1,12,{hero=hero1,equip=equip1,plane=plane1})
        local fleetInfo2,accessoryEffectValue2,herosinfo2,planevalue2 =self.initFleetAttribute(fleetInfo2,12,{hero=hero2,equip=equip2,plane=plane2})
        local fleetInfo3,accessoryEffectValue3,herosinfo3,planevalue3 =self.initFleetAttribute(fleetInfo3,12,{hero=hero3,equip=equip3,plane=plane3})
        local keys={}
        for i=1,6 do
            if type(fleetInfo1[i])=='table' and next(fleetInfo1[i]) then
                local isHero = false
                for k,v in pairs (fleetInfo1[i]) do   
                    table.insert(keys,k)
                    if k == 'hero' then isHero = true end
                end 
                if not isHero then table.insert(keys,'hero') end
                break
            end
        end
    
        params[1]=keys
        params[2]={}
        params[3]={}
        params[4]={equip1, equip2, equip3}
        params[5]={planevalue1, planevalue2, planevalue3}
        table.insert(params[3],herosinfo1[1])
        table.insert(params[3],herosinfo2[1])
        table.insert(params[3],herosinfo3[1])
        local troops = {}
        for i=1,3 do
            for k,v in pairs(keys) do
                local  attfleetInfo = {}
                if(i==1) then
                    attfleetInfo=fleetInfo1
                end
                if(i==2) then
                    attfleetInfo=fleetInfo2
                end
                if(i==3) then
                     attfleetInfo=fleetInfo3
                end
                for k1,v1 in pairs(attfleetInfo)  do
                    if type (troops[i]) ~='table' then troops[i]={} end
                    if type (troops[i][k1])~='table' then troops[i][k1]={}  end
                    if next(v1) then 
                        troops[i][k1][k]=v1[v]
                    end
                    
                end
                if btype=='areateamwar' then
                    if flag[i]==1 then
                        troops[i]={}
                    end
                end
            end
        end

        params[2]=troops
        return params,flag,{{accessoryEffectValue1,herosinfo1,planevalue1},{accessoryEffectValue2,herosinfo2,planevalue2},{accessoryEffectValue3,herosinfo3,planevalue3}}
    end

    --
    function self.getbinfo(fleetInfo1)
        local params={}
        local keys={}
        local troops = {}
        for i=1,6 do
            if type(fleetInfo1[i])=='table' and next(fleetInfo1[i]) then
                local isHero = false
                for k,v in pairs (fleetInfo1[i]) do   
                    table.insert(keys,k)
                    if k == 'hero' then isHero = true end
                end 
                if not isHero then table.insert(keys,'hero') end
                break
            end
        end
    
        params[1]=keys
        params[2]={}
        for k,v in pairs(keys) do
                for k1,v1 in pairs(fleetInfo1)  do
                    if type (troops[k1])~='table' then troops[k1]={}  end
                    if next(v1) then 
                        troops[k1][k]=v1[v]
                    end
                    
                end
        end

        params[2]=troops

        return params
    end


    -- 获取最大出兵量
    function self.getMaxBattleTroops(equip)
        local maxTroops = 0

        local uobjs = getUserObjs(self.uid)
        local mUserinfo = uobjs.getModel('userinfo')
        local mBoom = uobjs.getModel('boom')
        local mSequip = uobjs.getModel('sequip')
        local mStatue = uobjs.getModel('statue')
        local cfg = getConfig('player')
        local rankCfg = getConfig('rankCfg')

        -- 基础带兵量+统御带兵量+军衔带兵量+繁荣度带兵量
        maxTroops = maxTroops + arrayGet(cfg.troops,mUserinfo.level,0)
        maxTroops = maxTroops + arrayGet(cfg.commander_troops,mUserinfo.troops,0)
        for k,v in pairs(rankCfg.rank) do
            if v.id==mUserinfo.rank then
                maxTroops = maxTroops + (v.troops or 0) 
                break
            end
        end
        
        maxTroops = maxTroops + mBoom.effectBoom(1) -- 繁荣度

        if equip then
            maxTroops = maxTroops + mSequip.sequipAttr(equip, true)
        end

        -- 战争雕像带兵量加成
        if switchIsEnabled('statue') then
            maxTroops = maxTroops + (mStatue.getSkillValue('add') or 0)
        end

        -- 装甲矩阵对部队的加成
        maxTroops = maxTroops + uobjs.getModel('armor').getTroopsAdd()

        return maxTroops
    end

    --[[
        初始化出战队列
        battleType
            1是攻击关卡(补给线/超级装备关卡),2是攻击精英关卡,3守卫基地,4是军团关卡
            5是军团战,6关卡防守,7攻击远征,8攻击野矿
    ]]
    function self.initFleetAttribute(fleetInfo,battleType,params)
        if type(fleetInfo) == 'table' then 

            local uobjs = getUserObjs(self.uid)
            local mUserinfo = uobjs.getModel('userinfo') 
            local mTech = uobjs.getModel('techs')
            local mSkill = uobjs.getModel('skills')
            local mProp = uobjs.getModel('props')
            local mAccessory = uobjs.getModel('accessory')
            local mChallenge = uobjs.getModel('challenge')
            local mHero = uobjs.getModel('hero')
            local mAlien = uobjs.getModel('alien')
            local mSequip = uobjs.getModel('sequip')
            local mAweapon = uobjs.getModel('alienweapon')
            local mArmor = uobjs.getModel('armor')
            local mPlane = uobjs.getModel('plane')
            local mTender = uobjs.getModel('tender')
            local armorAttribute=mArmor.getUsedArmorAttribute()

            local mBadge = uobjs.getModel('badge')
            local badgeAttribute = mBadge.getUsedAttribute()

            local alienTechAddValue, alienTechAddValue1 =  mAlien.getAttrValueByTroops(fleetInfo)
            local allianceWarBuff
            if battleType == 5 then
                local mUserAllianceWar = uobjs.getModel('useralliancewar') 
                allianceWarBuff = mUserAllianceWar.getBattleBuff(1)
            end
            local addRate = 0
            if battleType == 11 or battleType == 5 then -- 区域战、军团战、异元战场、军事演习的战斗中
                addRate = mSequip.dySkillAttr(params.equip ,'s306', 0)
            elseif battleType == 12 then -- 跨服战、军团跨服战、世界争霸战斗
                addRate = mSequip.dySkillAttr(params.equip ,'s307', 0)
            end
            if addRate > 0 then
                params.equipskill={dmg=addRate}
            end

            mTech.update()

            local accessoryEffectValue = mAccessory.getUsedAccessoryFighting() -- 战力分值
            local accessoryAttribute,accessorySuccinctAttribute,accessoryTech = mAccessory.getUsedAccessoryAttribute() --装备

            -- 军团技能
            local allianceSkills            
            if mUserinfo.alliance and mUserinfo.alliance > 0 then
                local allAllianceSkills = M_alliance.getAllianceSkills{aid=mUserinfo.alliance}
                if type(allAllianceSkills) == 'table' and next(allAllianceSkills) then
                    allianceSkills = allAllianceSkills
                end
            end
             
             -- 超级装备
            local eAttr = nil
            if type(params) == 'table' and params.equip then
                local first = mSequip.dySkillAttr(params.equip, 's2', 0)  --克敌机先 先手值增加X

                eAttr = mSequip.sequipAttr(params.equip)
                if type(eAttr) ~= 'table' then 
                    eAttr = {} 
                end

                if first>0 then
                    eAttr.first = (eAttr.first or 0) + first
                end 
            end

            local aheros={}
            local herosvalue = 0   
            local planevalue = 0
            -- 参数
            local initParams = {
                accessory=accessoryAttribute,
                accessorySuccinctAttribute=accessorySuccinctAttribute,
                accessoryTechSkill=accessoryTech,
                allianceWarBuff=allianceWarBuff,  
                rank = mUserinfo.rank,
                attackBossBuff=params.attactBossBuff,
                alienTechAddValue = alienTechAddValue,
                alienTechAddValue1 = alienTechAddValue1,
                equip=eAttr,
                aweapon=mAweapon.weaponAttr(),
                aweaponSkill = mAweapon.getWeaponSkill(),
                armor=armorAttribute,
                playerSkill=mSkill.getNewSkill(),
                badge = badgeAttribute,
            }
            if type(params)=='table' and params.hero~=nil then
                if type(params.hero)=='table' and next(params.hero) then
                    local attr,hero,value=mHero.getAttHerosAttribute(params.hero)
                    initParams.heros= attr
                    aheros=hero
                    herosvalue=value
                end
            end

            -- 关卡奖励的BUFF
            local challengeBuff = mChallenge.getChallengeBuff() or {}
            if next(challengeBuff) then initParams.challengeBuff = challengeBuff end

            -- 军团领地buff加成
            if mUserinfo.alliance > 0 then
                local territoryBuff = {}
                local mTerritory = getModelObjs("aterritory",mUserinfo.alliance,true)

                -- 领地建筑提供的固定加成值
                local buildBuff = mTerritory.getTerritoryBuildBuff()
                if buildBuff then
                    territoryBuff = buildBuff
                end

                -- 如果野外战斗地点处于军团领地范围内,还有额外buff加成
                if params.place then
                    local areaBuff = mTerritory.getTerritoryAreaBuff(params.place[1],params.place[2])
                    if areaBuff then
                        for k,v in pairs(areaBuff) do
                            territoryBuff[k] = (territoryBuff[k] or 0) + v
                        end
                    end

                    params.place = nil
                end

                if next(territoryBuff) then
                    initParams.territoryBuff = territoryBuff
                end
            end

            if type(params) == 'table' then
                for k,v in pairs(params) do 
                    if k ~= 'equip' then
                        initParams[k] = v
                    end
                end
            end
            
            -- 飞机加成
            local planeId=0
            if params and params.plane then
                planeId=params.plane
                params.plane=nil
            else
                planeId = mPlane.getBringPlaneId(true)    
            end

            if  planeId and planeId>0 then
                local planeid,planeSkillAttrs=mPlane.getSkillAttrs(planeId)
                planevalue=mPlane.getPlanePoint(planeId)
                initParams.planeSkills={planeid,planeSkillAttrs,mPlane.level}
                planeId=planeid
            else
                planeId=0 
            end

            -- 补给舰属性加成及技能
            initParams.tenderAttrs,initParams.tenderSkill,initParams.tenderInfo = mTender.getBattleAttributes()

            -- 战争雕像
            local mStatue = uobjs.getModel('statue')
            initParams.statue = mStatue.getSkillAttrs()

            -- 道具信息
            local propSlots = {}
            if battleType ~= 7 then
                propSlots = mProp.info
            end
            fleetInfo = initTankAttribute(fleetInfo,mTech,mSkill,propSlots,allianceSkills,battleType,initParams)

            return fleetInfo,accessoryEffectValue,{aheros,herosvalue},{planeId,planevalue}
        end
    end

    -- 清除警报
    function self.clearAlarm(cronId,mapx,mapy)
        if type(self.invade) == 'table' then
            if self.invade[cronId] then
                self.invade[cronId] = nil
            end
            local ts = getClientTs()
            for k,v in pairs(self.invade) do
                if (v.ts or 0) <= ts then
                    self.invade[k] = nil
                elseif (mapx and mapy) and v.place[1] == mapx and v.place[2] == mapy then
                    self.invade[k] = nil
                end
            end
        end
    end

     --队列操作------------------------------------------------------------

    -- 使用队列
    function self.useSlot(slotInfo,qName)
        local slot , wait = self.getOpenSlot(qName)

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

            table.insert(self.queue[qName],slot)
            return true
        end

        return false
    end   

    function self.getOpenSlot(qName)
        local uobjs = getUserObjs(self.uid)
        local mUserinfo = uobjs.getModel('userinfo') 
                
        local cfg = getConfig('player.vipProuceQueue')
        local vipLevel = arrayGet(mUserinfo,'vip',0) + 1

        -- 检测当前拥有的队列数            
        local iSlotNums = cfg[vipLevel] or 1
        local iCurrSlotNums = table.length(self.queue[qName])

        assert2(iCurrSlotNums < iSlotNums,'no open slot')

        local newSlot = {}
        newSlot.slotid = self.getSlotId(qName)
        return newSlot , iCurrSlotNums > 0
    end

    -- 打开队列
    function self.openSlot(slotName,qName)
        if self.queue[qName][slotName] then
            local et = self.queue[qName][slotName].et or 0
            local ts = getClientTs()
            local nextSt = ts >= et and et or ts
            
            table.remove(self.queue[qName],slotName)

            if et > 0 then
                for k,v in ipairs(self.queue[qName]) do
                    self.queue[qName][k].st = nextSt
                    self.queue[qName][k].et = nextSt + self.queue[qName][k].timeConsume
                    break       
                end
            end

            return true
        end

        return false
    end

    -- 升级的id是否已经出现在了序列中
    -- return false|slotkey
    function self.checkIdInSlots(slotid,qName)
        if type (self.queue[qName] == 'table') then
            for k,v in pairs(self.queue[qName]) do
                if v.slotid == slotid then return tonumber(k) end
            end
        end
        return false
    end

    -- 生成slot的唯一标识
    function self.getSlotId(qName)
        if type(self.queue[qName]) == 'table' then
            local ids = {}

            for k,v in pairs(self.queue[qName]) do
                ids[v.slotid] = 1
            end

            for i=1,100 do 
                if not ids[i] then return i end
            end
        end

        return 1
    end

    function self.setHDefenceStatus(cronid,status,hUid,hName,stats,hMtroops)
        local ts = getClientTs()

        if type(self.helpdefense) ~= 'table' then
            self.helpdefense = {}
        end

        if type(self.helpdefense.list) ~= 'table' then
            self.helpdefense.list = {}
        end

        if type(self.helpdefense.list[cronid]) ~= 'table' then
            self.helpdefense.list[cronid] = {ts=ts,uid=hUid,name=hName}
        end

        if self.helpdefense.list[cronid].status == 0 and status == 1 then
            self.helpdefense.list[cronid].ts = ts
        end

        if status == 2 then
            if self.helpdefense.c then
                self.helpdefense.list[self.helpdefense.c].status = 1
            end

            self.helpdefense.c = cronid
        elseif self.helpdefense.list[cronid].status == 2 and status == 1 then
            self.helpdefense.c = nil
        end

        self.helpdefense.list[cronid].status = status
        --自己设置过协防守部队的自动状态
        
        if stats~=nil and stats>=1 then
            hMtroops.setTroopsStatus(cronid,4)
            --替换比自己战力高的部队
            if  stats==3 then
                if self.helpdefense.c and self.helpdefense.list[self.helpdefense.c] then
                    local oldpower =self.helpdefense.list[self.helpdefense.c].power or 0
                    local newpower =self.helpdefense.list[cronid].power or 0
                    if newpower>=oldpower then
                        stats=2
                    end
                else
                    stats=2
                end
            end
            -- 替换现有的部队
            local currHuobjs,currHMtroops,currCid
            if stats==2 then
                if self.helpdefense.c and self.helpdefense.list[self.helpdefense.c] then
                    currCid = self.helpdefense.c
                    if self.helpdefense.list[currCid].uid==hUid then
                        currHMtroops=hMtroops
                    else
                        currHuobjs = getUserObjs(self.helpdefense.list[currCid].uid)
                        currHMtroops = currHuobjs.getModel('troops')
                    end
                    currHMtroops.setTroopsStatus(currCid,4)
                    self.helpdefense.list[self.helpdefense.c].status=1
                end

                -- 驻防状态
                hMtroops.setTroopsStatus(cronid,5)
                self.helpdefense.list[cronid].status = 2
                self.helpdefense.c = cronid
            end

            if currHuobjs and currHuobjs.save() then
                currHMtroops.sendAttackTroopsMsgByUid(currCid)
            end
        end
        return true
    end


     --计算总的坦克
    function self.checkFleetInfoStats(troops)
        local fleetInfo ={}
        if type(troops)~='table' then  return false  end 
        for k,v in pairs (troops) do
            if next(v) then
                for k1,v1 in pairs(v) do
                    if next(v1) then
                        fleetInfo[v1[1]]=(fleetInfo[v1[1]] or 0)+v1[2]
                    end
                    
                end
            end
        end
        
        if next(fleetInfo) then
            for k,v in pairs(fleetInfo) do
                if self.troops[k]==nil  or  self.troops[k] < v then
                    return false
                end

            end

        end
        return true
    end




    function self.setTroopsStatus(cronId,status)
        if type(self.attack) == 'table' and type(self.attack[cronId]) == 'table' then
            self.attack[cronId].isGather = status

            return true
        end
    end

    -- 获取当前的协防部队
    function self.getHelpDefenceTroops()
        local hCid = arrayGet(self.helpdefense,'c')
        if hCid then
            return hCid,self.helpdefense.list[hCid]
        end
    end

    -- 清除所有协防部队，给别人驻防的部队也拉回来
    function self.clearHelpDefence(cid)
        if type(self.helpdefense) == 'table' and type(self.helpdefense.list) == 'table' then
            local ts = getClientTs()

            if cid then
                if self.helpdefense.list[cid] then
                    local curruid=self.helpdefense.list[cid].uid                                       
                    self.helpdefense.list[cid] = nil

                    if self.helpdefense.c == cid then
                        self.helpdefense.c = nil
                        -- 状态自动的，要补充协防部队
                        if type(self.helpdefense.list)=='table' and next(self.helpdefense.list) then
                            local uobjs = getUserObjs(self.uid)
                            local mUserinfo = uobjs.getModel('userinfo')
                            local stats     =mUserinfo.flags.sadf or 1
                            local p=0
                            if stats>1 then
                                local newcid
                                for k,v in pairs(self.helpdefense.list) do
                                    if v.status~=0 then
                                        local power =v.power or 0
                                        if power>=p then
                                            newcid=k
                                            p=power
                                        end
                                    end
                                end
                                if newcid then

                                    local currHuobjs = getUserObjs(self.helpdefense.list[newcid].uid)
                                    local currHMtroops = currHuobjs.getModel('troops')
                                    self.helpdefense.c =newcid
                                    self.helpdefense.list[newcid].status=2
                                    currHMtroops.setTroopsStatus(newcid,5)
                                    local newuid=self.helpdefense.list[newcid].uid
                                    currHMtroops.sendAttackTroopsMsgByUid(newcid) 
                                    if newuid~=curruid and currHuobjs.save() then
                                    end
                                end
                            end


                        end
                    end

                    return true
                end
            else
                -- for k,v in pairs(self.helpdefense.list) do
                --     if k and v.uid then
                --         if v.status ~= 0 then
                --             local uobjs = getUserObjs(v.uid) 
                --             local mTroops = uobjs.getModel('troops')
                --             mTroops.fleetBack(k)

                --             if uobjs.save() then
                --                 self.sendAttackTroopsMsgByUid(k)
                --             end
                --         end
                --     end
                -- end

                -- for k,v in pairs(self.attack) do
                --     if k and v.isHelp == 1 and (tonumber(v.dist) or 0 <= ts) then
                --         self.fleetBack(k)
                --         if v.tUid then
                --             local memberuobjs = getUserObjs(v.tUid)
                --             memberuobjs.load({"userinfo", "techs", "troops", "props","bag","skills","buildings","dailytask","task"})
                --             local memberMTroop = uobjs.getModel('troops')

                --             if memberMTroop.clearHelpDefence(k)  and memberuobjs.save() then
                --                 memberMTroop.sendHelpDefenseMsgByUid()
                --             end
                --         end
                --     end
                -- end

                self.helpdefense = {c=nil,list={}}

                return true
            end
        end        
    end

    function self.sendHelpDefenseMsgByUid()
        local response = {
                data=self.helpdefense or {},
                ret=0,
                cmd="msg.helpdefense",
                ts = getClientTs(),
            }
            
            sendMsgByUid(self.uid,json.encode(response))  
    end

    function self.sendAttackTroopsMsgByUid(cid)
        local response = {
            data={[cid]=self.attack[cid]},
            ret=0,
            cmd="msg.helptroops",
            ts = getClientTs(),
        }

        sendMsgByUid(self.uid,json.encode(response))
    end

    --------- 是否有协防的部队
    function self.hasHelpFleet()
        if type(self.attack) == 'table' then
            for k,v in pairs(self.attack) do
                if v.isHelp == 1 then
                    return true
                end
            end
        end

        if type(self.helpdefense) == 'table' and type(self.helpdefense.list) == 'table' then
            for k,v in pairs(self.helpdefense.list) do
                if v.status ~= 0 then
                    return true
                end
            end
        end
    end

    -- 是否有在异星矿场中采集的部队
    function self.hasAlienmineFleet()
        if type(self.attack) == 'table' then
            for k,v in pairs(self.attack) do
                if v.alienMine then
                    return true
                end
            end
        end
    end

    -- 协防部队数
    function self.getHelpDefenceNums()
        local n = 0
        if type(self.helpdefense) == 'table' and type(self.helpdefense.list) == 'table' then
            for k,v in pairs(self.helpdefense.list) do
                if v.status ~= 0 then
                    n = n + 1
                end
            end
        end

        return n
    end

    -- 根据allianceWarId获取军团阵地驻守的兵力
    -- params allianceWarId 军团战斗Id
    -- params cacheTroops 缓存中的部队数，
        -- 在占领阵地的时候，会先写缓存，后写数据库，有可能出现缓存写入成功，而数据库写入失败的情况，
        -- 此时需要校对缓存数据和用户实际数据
        -- 用户部队很可能拉出去干别的了,以用户实际数据进行计算
    function self.getFleetTroopsByAllianceWarId(allianceWarId,cacheTroops)
        if type(self.alliancewar) == 'table' and type(self.alliancewar.troops) == 'table' then
            local fleetInfo = {}
            local num = 0
            for m,n in ipairs(self.alliancewar.troops) do
                fleetInfo[m] = n
                if next(n) and (tonumber(n[2]) or 0) > 0 then                    
                    num = num + n[2]
                end
            end

            if num > 0 then
                return fleetInfo
            end
        end
    end

    function self.setFleetTroopsByAllianceWarId(troopsInfo)
        if type(troopsInfo) == "table" then
            --军团战失败人 解锁英雄
            if not next(troopsInfo) then
                local uobjs = getUserObjs(self.uid)
                local mHero =  uobjs.getModel('hero')
                mHero.releaseHero('l',1)
            end
            self.alliancewar = troopsInfo
            return true
        end        
    end

    -- 更新战斗部队
    -- params notCheck true 不与缓存校验 false需要与缓存校验 
    function self.updateAllianceWarTroops(notCheck)
        if type(self.alliancewar) == 'table' and next(self.alliancewar) then 
            local result = {}
            local mAllianceWar = require "model.alliancewar"

            if not notCheck and self.alliancewar.positionId and self.alliancewar.placeId and self.alliancewar.warId then
                local key = mAllianceWar:getCacheKey(self.alliancewar.positionId,self.alliancewar.placeId,self.alliancewar.warId)
                if key then
                    local redis = getRedis()
                    result = redis:get(key) 
                end

                if result then
                    result = json.decode(result) or {}
                end                
            end
            
            result = result or {}
            
            local repair = false

            if tonumber(result.oid) ~= self.uid or tonumber(result.warId) ~= self.alliancewar.warId then  
                repair = true               
            else
                local opents = {}
                local ts = getClientTs()
                local delay = 15

                if self.alliancewar.positionId and self.alliancewar.positionId > 0 and self.alliancewar.positionId <= 8 then
                    local mAllianceWar = require "model.alliancewar"
                    opents = mAllianceWar:getWarOpenTs(self.alliancewar.positionId,self.alliancewar.warId)
                end

                -- 如果战场已经结束两分钟，并且可以结算的话，先不修复数据
                -- 如果不能结算，表示已经结算过了，需要修复数据
                if opents.et and opents.et < (ts - delay) then
                    repair = true
                    
                    -- endStats 有值表示可以结算
                    local endStats,endCode = M_alliance.getbattlestatus{warId=self.alliancewar.warId}
                    
                    -- 如果可以结算，先不修数据
                    if endStats then
                        writeLog('repair true','repair')

                        local cronParams = {
                            cmd = 'alliancewar.getwarpoint',
                            params={
                                positionId=self.alliancewar.positionId,
                                warId=self.alliancewar.warId,
                            }
                        }

                        setGameCron(cronParams,5)

                        repair = false
                    end
                end
            end

            if repair then
                 if type(self.alliancewar.troops) == 'table' then
                    for m,n in pairs(self.alliancewar.troops) do
                        if n[1] and n[2] then
                            self.incrTanks(n[1],n[2])
                        end
                    end
                end

                -- kafkaLog
                local storeTroops = self.getStoreTroopsByFleet(self.alliancewar.troops)
                regKfkLogs(self.uid,'tankChange',{
                        addition={
                            {desc="军团战返回",value=self.alliancewar.troops},
                            {desc="留存",value=storeTroops},
                        }
                    }
                ) 

                local uobjs = getUserObjs(self.uid)
                local mHero =  uobjs.getModel('hero')
                mHero.releaseHero('l',1)
                self.alliancewar = {}
            end

        end
    end

    -- 设置异星矿场信息
    function self.setAllienMineBattleInfo(params)
        local redis = getRedis()
        if type(params) == 'table' then
            local cacheKey = "alienmine.info." .. self.uid
            redis:hmset(cacheKey,params)
            redis:expire(cacheKey,86400)
        end
    end

    -- 获取异星矿场信息
    function self.getAlienMineBattleInfo()
        local defaultInfo = {
            dailyOccupyNum=0,
            dailyRobNum=0,
            r1=0,
            r2=0,
            r3=0,
            updated_at=getClientTs(),
            setGameCron=0, -- 用这个判断是否设置过回家定时
        }

        local redis = getRedis()
        local cacheKey = "alienmine.info." .. self.uid
        local info = redis:hgetall(cacheKey)

        if type(info) ~= 'table' or not next(info) or (tonumber(info.updated_at) or 0) < getWeeTs() then
            info = defaultInfo
        end

        for k,v in pairs(defaultInfo) do
            if info[k] then
                info[k] = tonumber(info[k]) or 0
            else
                info[k] = v
            end
        end

        return info
    end

    function self.getStoreTroopsByFleet(fleetInfo)
        local storeTroops = {}
        local storeDamaged = {}
        
        for k,v in pairs(fleetInfo) do
            if type(v) == 'table' then
                if v[1] and v[2] > 0 then 
                    storeTroops[v[1]] = self.troops[v[1]] or 0
                    storeDamaged[v[1]] = self.damaged[v[1]] or 0
                end
            else
                if v > 0 then
                    storeTroops[k] = self.troops[k] or 0
                    storeDamaged[k] = self.damaged[k] or 0
                end
            end
        end

        return storeTroops,storeDamaged
    end

    -- 返回格式化数据 一组部队的 
    function self.gettroopsinfo(fleet,hero,equip, battleType,plane) 
        if not next(fleet) then
            return {}
        end
        local fleetInfo1,accessoryEffectValue1,herosinfo1,planevalue1 =self.initFleetAttribute(fleet, battleType or 0,{hero=hero,equip=equip,plane=plane})
        local result={{},{},{}}
        local keys={}
        for i=1,6 do
            if type(fleetInfo1[i])=='table' and next(fleetInfo1[i]) then
                local isHero = false
                for k,v in pairs (fleetInfo1[i]) do   
                    table.insert(keys,k)
                    if k == 'hero' then isHero = true end
                end 
                if not isHero then table.insert(keys,'hero') end
                break
            end
        end
        result[1]=keys
        table.insert(result[3],herosinfo1[1])
        local troops = {}
        for k,v in pairs(keys) do
            local  attfleetInfo = fleetInfo1
                for k1,v1 in pairs(attfleetInfo)  do
                    if type (troops[1]) ~='table' then troops[1]={} end
                    if type (troops[1][k1])~='table' then troops[1][k1]={}  end
                    if next(v1) then 
                        troops[1][k1][k]=v1[v]
                    end
                    
                end
        end
        result[2]=troops
        local uobjs = getUserObjs(self.uid)
        local mSequip = uobjs.getModel('sequip')
        result[4] =mSequip.formEquip(equip) -- 新增超级装备信息
        result[5] = planevalue1 -- 飞机信息
        --result[4]={accessoryEffectValue1,herosinfo1}
        return result,{accessoryEffectValue1,herosinfo1,planevalue1}
    end
    --   金矿系统增加额外异星资源
    --    res  资源类型
    --    count 资源数量
    --    AcRate  活动加成数据
    --    get  true 是获取  false  是添加
    --    rtype  =1 是金矿 ＝2 普通的   
    --    level  富矿等级
    function self.goldAddAlien(res,count,AcRate,get,rtype,level)
        local uobjs = getUserObjs(self.uid)
        local mAlien= uobjs.getModel('alien')
        local mUserinfo=uobjs.getModel('userinfo')
        local result={}
        if moduleIsEnabled('alien') ~= 1 or  mUserinfo.level<moduleIsEnabled('al') then
            return result
        end
        -- 金矿
        if rtype==1 then
            local collect=getConfig('alienTechCfg.collectLimit')
            local count =count
            local resOutputCfg=getConfig('goldMineCfg.resOutputCfg')
            if resOutputCfg.r  then
                local push=false
                for k,v in pairs (resOutputCfg.r) do
                    local pid=k
                    local maxLv =collect[pid] or 0
                    local num =count*v.speed
                    local maxnums =maxLv*mUserinfo.level
                    local baseMaxNums = maxnums
                    if type(AcRate)=='table' then
                        if AcRate[2]~=nil and AcRate[2]>0 then
                            num=num+num*AcRate[2]
                        end
                        if AcRate[1]~=nil and AcRate[1]>0 then
                            maxnums=maxnums+baseMaxNums*AcRate[1]
                        end
                    end

                    -- 战争塑像增加异星资源采集上限
                    maxnums = maxnums + baseMaxNums * (uobjs.getModel('statue').getSkillValue('alienCollectLimit') or 0)

                    num=math.floor(num)
                    local addnum=mAlien.getDayadd(pid)
                    local nums =maxnums-addnum
                    if nums<=num then
                        num=nums
                    end
                    if num>0 then
                        if get==false then
                            mAlien.addProp(pid,num)
                            -- 节日花朵
                            activity_setopt(self.uid,'jrhd',{act="tk",pid=pid,id="jh",num=num})
                            push=true
                        end
                        result[pid]=(result[pid] or 0)+num
                    end
                end
                if push==true and get==false then
                    local tmp={prop=mAlien.prop,pinfo=mAlien.pinfo}
                    regSendMsg(self.uid,"alien.resource.push",tmp)
                end
            end 
        else -- 普通矿
            local level =level or 0
            local collect=getConfig('alienTechCfg.collect')
            local pid =collect[level+1].res
            local rate =collect[level+1].rate
            local maxLv =collect[level+1].maxLv
            local count =count          
            local num =count*rate
            local maxnums =maxLv*mUserinfo.level
            local baseMaxNums = maxnums
                  
            if type(AcRate)=='table' then
                if AcRate[2]~=nil and AcRate[2]>0 then
                    num=num+num*AcRate[2]
                end
                if AcRate[1]~=nil and AcRate[1]>0 then
                    maxnums=maxnums+baseMaxNums*AcRate[1]
                end
            end

            -- 战争塑像增加异星资源采集上限
            maxnums = maxnums + baseMaxNums * (uobjs.getModel('statue').getSkillValue('alienCollectLimit') or 0)

            num=math.floor(num)
            local addnum=mAlien.getDayadd(pid)
            local nums =maxnums-addnum
            if nums<=num then
                num=nums
            end
            if num>0 then
                if get==false then
                    mAlien.addProp(pid,num)
                    -- 节日花朵
                    activity_setopt(self.uid,'jrhd',{act="tk",pid=pid,id="jh",num=num})
                    local tmp={prop=mAlien.prop,pinfo=mAlien.pinfo}
                    regSendMsg(self.uid,"alien.resource.push",tmp)
                end
                result[pid]=(result[pid] or 0)+num
            end        
        end       
        return result
    end


    -- 获取活动的异星资源加成
    function self.getActiveAlienRate()
        local acrate=activity_setopt(self.uid,'alienbumperweek',{rate=1})
        local result=nil
        if type(acrate)=='table' and next(acrate) then
            if type(result)~='table' then  result={}   end
            if acrate[2]~=nil and acrate[2]>0 then
                result[2]=(result[2] or 0)+acrate[2]
            end
            if acrate[1]~=nil and acrate[1]>0 then
                result[1]=(result[1] or 0)+acrate[1]
            end
        end
        local acrate1=activity_setopt(self.uid,'yichujifa',{rate=1})
        if type(acrate1)=='table' and next(acrate1)  then
            if type(result)~='table' then  result={}   end
            if acrate1[2]~=nil and acrate1[2]>0 then
                result[2]=(result[2] or 0)+acrate1[2]
            end
            if acrate1[1]~=nil and acrate1[1]>0 then
                result[1]=(result[1] or 0)+acrate1[1]
            end
        end
        return  result       
    end

	function self.setGoldMineBackCron(backTime,cronId)
        local ts = getClientTs()
        if ts < backTime then
            local delayTs = backTime - ts
            local cid = string.sub(cronId,2)
            local params = {cmd ="troop.back",uid=self.uid,params={cid=cid}}
            local ret = setGameCron(params,delayTs)
        end
    end

    -- 获取可以被雷达检索到的部队
    function self.getCanScanTroop()
        local data = {}

        local ts = getClientTs()
        for cid,v in pairs(self.attack) do
            if type(v) == 'table' and not v.bs and (v.isGather == 2 or v.isGather == 3) and not v.alienMine and not v.isHelp then 
                local d = copyTable(v)
                d.cid = cid
                table.insert(data,d)
            end
        end

        return data
    end
        
    --舰队一键返航
    function self.fleetBackAll(isTimeConsume)
        
        for cid, v in pairs(self.attack) do

            self.fleetBack(cid, isTimeConsume)
            -- 岛屿被释放   
            if type(self.attack[cid]) == 'table' then
                if self.attack[cid].type ~= 6 then
                    local mid = getMidByPos(self.attack[cid].targetid[1],self.attack[cid].targetid[2])
                    local mMap = require "lib.map"
                    mMap:refreshHeat(mid)
                    mMap:decrHeatPoint(mid)

                    local troopInfoByTurkeyActive =  activity_setopt(uid,'jidongbudui',
                        {setMapTroops=true,mlv=self.attack[cid].level,index={self.attack[cid].targetid[1],self.attack[cid].targetid[2]}})
                    if type(troopInfoByTurkeyActive) == 'table' then
                        if not mMap.data[mid].data then mMap.data[mid].data = {} end
                        mMap.data[mid].data.troops=troopInfoByTurkeyActive.troop
                    end
                    mMap:changeOwner(mid,0,true)

                    -- 解除舰队来袭
                    self.clearAlarm(0,self.attack[cid].targetid[1],self.attack[cid].targetid[2])

                elseif self.attack[cid].isHelp == 1 and self.attack[cid].tUid then
                    local memberuobjs = getUserObjs(self.attack[cid].tUid)
                    memberuobjs.load({"userinfo", "techs", "troops", "props","bag","skills","buildings","dailytask","task"})

                    local memberself = memberuobjs.getModel('troops')
                    local memeMUserinfo = memberuobjs.getModel('userinfo')

                    memberself.clearHelpDefence(cid) 

                    if memberuobjs.save() then
                        local mail_title =  "3-6"
                        local mail_content={
                            type = 3,
                            info = {
                                place = target,
                                name  = '',
                                islandType = targetType,
                                level = maplevel,
                                rettype = 8,
                            }
                        }

                        MAIL:mailSent(memeMUserinfo.uid,1,memeMUserinfo.uid,'',memeMUserinfo.nickname,mail_title,mail_content,2,0)
                        memberself.sendHelpDefenseMsgByUid()
                    end
                end
            end

        end

        self.updateAttack()
        return true
    end

    -- 加速造船
    function self.speedupTime(slotid, bid, discInter)
        local qName = self.bid2Qname(bid)
        local iSlotKey = self.checkIdInSlots(slotid,qName)

        if not self.queue[qName] or not self.queue[qName][iSlotKey] then
            return false
        end

        self.queue[qName][iSlotKey].et = self.queue[qName][iSlotKey].et - discInter
        self.queue[qName][iSlotKey].st = self.queue[qName][iSlotKey].st - discInter
        if self.queue[qName][iSlotKey].et <= getClientTs() then
            self.queue[qName][iSlotKey].et = getClientTs()
            self.update()
        end
        return true
    end

    -- 军团领地内的部队返回
    function self.territoryFleetBack(territoryIslandType)
        local territoryResources
        for cid, v in pairs(self.attack) do
            if tonumber(v.type) == territoryIslandType and not v.seaWarFlag then
                if self.fleetBack(cid) then
                    territoryResources = v.maxRes
                    break
                end
            end
        end
        return territoryResources
    end

    -- 检测海战舰队数量
    function self.checkSeaWarFleetCount()
        local n = 0
        for k, v in pairs(self.attack) do
            if v.seaWarFlag then
                n = n + 1
            end
        end
        return n
    end

    function self.seaWarFleetBack(flag)
        local fleets = {}
        for cid, v in pairs(self.attack) do
            if v.seaWarFlag == flag and not v.bs and v.isGather > 0 then
                if self.fleetBack(cid)  then
                    table.insert(fleets,{mid=v.mid,aid=v.oid,bid=v.mType,uid=self.uid,cronId=cid})
                end
            end
        end
        return fleets
    end

    function self.seaWarFleetAttackSpeedUp(cronId,rate)
        if rate >= 1 then return false end

        if self.checkCronFleetStatus(cronId) ~= 0 then
            return false
        end

        local fleetInfo = self.getFleetByCron(cronId)
        local ts = os.time()
        local sec = fleetInfo.dist - ts
        if sec >= 5 then
            fleetInfo.dist = fleetInfo.dist - math.floor(sec * rate)
            local newWorkId = loadModel("lib.seawar").changeCronDealy(fleetInfo.workId,fleetInfo.dist-ts)
            if newWorkId then
                fleetInfo.workId = newWorkId
                return true
            else
                local cronParams = {
                    cmd = "territory.seawar.attack",
                    uid=self.uid,
                    params = {
                        cronId=cronId,
                        target = fleetInfo.targetid ,
                        attacker=self.uid,
                    }
                }

                local ret,workId = setGameCron(cronParams,fleetInfo.dist-ts)
                if ret then 
                    fleetInfo.workId = workId
                    return true
                end
            end
        end
    end

    function self.seaWarFleetBackSpeedUp(cronId,rate)
        if rate >= 1 then return false end

        local fleetInfo = self.getFleetByCron(cronId)
        if not fleetInfo or not fleetInfo.seaWarFlag or not fleetInfo.bs then
            return false
        end

        local ts = os.time()
        local sec = fleetInfo.bs - ts
        if sec >= 5 then
            fleetInfo.bs = fleetInfo.bs - math.floor(sec * rate)
        else
            fleetInfo.bs = ts
            self.updateAttack()
        end

        return true
    end

    ----------------------------------------------------------------------

    return self
end 
