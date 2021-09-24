function model_userinfo(uid,data)
    -- the new instance
    local self = {
        -- public fields go in the instance table
        uid= uid,
        --username = os.time(), 
        nickname = "",
        pic=0,--头像
        bpic='',--头像框
        apic='',--挂件
        email = "",
        --password = "",
        hwid = "",
        level = 1,
        exp = 0,
        energy = 30,
        energycd = 0,
        extraenergy = 0,
        honors = 100, -- 声望
        reputation = 1000, -- 荣誉
        troops = 0,
        rank = 1,
        vip = 7,
        vippoint = 0,
        buygems = 0,
        usegems=0,
        bid="",        
        gems = 66000,
        cost  = 60000,   -- 累计充值
        gold = 5000,   
        r1 = 20000,
        r2 = 10000,
        r3 = 10000,
        r4 = 10000,
        buildingslots = 2,
        mapx = -1,  
        mapy = -1,
        regdate = 0,
        logindate  = 0,
        flags = {            
            event = {},            
            daily_award = 0,
            daily_lottery = {d1={ts=0,num=0,cfg=1},d2={ts=0,num=0,cfg=1},},
            daily_honors = 0,
            daily_buy_energy={ts=0,num=0},
            newuser_7d_award = {0,0,0,0,0,0,0},
            feeds_award = {ts=0,num=0},
            notice = {},
            fb = {
                us = 0,
                nt = { 0, 0, 0, 0, 0, 0, 0},
                dy = 0,
            },
            --vip礼包购买记录
            vf={},
            -- 漂浮物{时间戳, 拾取个数}
            floater = {0,0},
            lmail = 0, --锁定邮件数
            gsd=nil, -- 金币影子
            strongversion = nil --游戏强更版本号
        },
        piclist={},
        fc = 0,
        guest=0,
        grow=0,
        growrd=0,
        mc={},
        protect=0,
        alliance=0,
        alliancename='',
        tutorial = 0,
        rp=0, -- 军功值
        rpb=-1, -- 军功币
        drp=0, --每日军功值
        rpt=0, --上一次获取军功时间
        urt=0, --更新军衔时间
        updated_at=0,
        usegems_at=0, --跨服军团战退回军团资金的时间

        -- 审计
        ips = '',   -- 最近7天每天登陆的ip
        ip = '',    -- 最后一次登陆ip
        regip = '', -- 用户注册时的ip 
        buyts = 0,  -- 最后一次充值时间
        buyn = 0,   -- 累计购买次数
        freeg = 50,  -- 累计赠送金币数
        olt = 0,    -- 累计在线时长
        oltd = 0, --最近一天在线时长
        logdc = 0,  -- 累计登陆天数
        online_at = 0,
        deviceid = "", -- 设备id
        platid = "", -- 平台id
        channelid = "", --渠道id
        newstrongversion = 0, --统计用最新版本号
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

         if type(self.flags) ~= 'table' then
            self.flags = {
                event = {},            
                daily_award = 0,
                daily_lottery = {d1={ts=0,num=0,cfg=1},d2={ts=0,num=0,cfg=1},},
                daily_honors = 0,
                daily_buy_energy={ts=0,num=0},
                newuser_7d_award = {0,0,0,0,0,0,0},
                feeds_award = {ts=0,num=0},
                notice = 0,
            }
         end
         --重置在线礼包
        if self.flags.ol and self.flags.ol==1 then
            local ts = getWeeTs()
            self.flags.ol = {6, ts}
        end

        self.updateResources()
        self.updateEnergy()
        --军衔
        
        local cmdinfo = getRequestCmd()
        local urt = getWeeTs()+10800

        local ts = getClientTs()
        -- 今天没有刷新过，注册刷新
        if(self.urt+86400<=urt) and cmdinfo[1]~='cron.refnewrank' and ts>urt then
            self.updateNewRank(urt)    
            self.urt=urt  
        end

        if moduleIsEnabled('rpshop') == 1  then
            if self.rpb==-1 then
                self.rpb=self.rp
            end
        end

        self.checkCost()

        if not self.flags.gsd then self.flags.gsd = self.gems end

        return true
    end

    function self.toArray(format)
        local data = {}
            for k,v in pairs (self) do
                if type(v)~="function" and k~= 'updated_at' then
                    if format then
                        if k~= "password" and k~="ips" and k~="ip" and k~="freeg" and k~="logdc" and k~="online_at" and k~= "deviceid" and k~="platid" then
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

    function self.checkCost()
        -- rPay 修复充值的数据
        if not self.flags.rPay then
            self.flags.rPay = 1
            self.cost = 0
            self.buyn = 0

            if self.buygems > 0 then
                local db = getDbo()
                local sql = string.format("select sum(cost) as cost,count(cost) as count from tradelog where userid = '%d' limit 1",self.uid)
                local ret = db:getRow(sql)
                
                if ret then
                    local cost = tonumber(ret['cost']) or 0
                    if cost > 0 then
                        cost = math.floor(cost * 100) / 100 
                        self.buyn = ret['count']
                        self.cost = self.cost + cost
                    end
                end
            end
        end
    end

    function self.addCost(num)
        num = (tonumber(num) or 0)
        num = math.floor(num * 100) / 100 
        self.cost = self.cost + num
        self.buyn = self.buyn + 1
    end
  
    function self.checkResource(resources)
          if type(resources) ~= 'table' then return false end

          for k,v in pairs(resources) do
              if tonumber(self[k]) < v then
                  self[k] = tonumber(self[k])<0 and 0 or self[k]                  
                  return false
              end
          end

          return true      
    end
  
    function self.useResource(resources)
        if self.checkResource(resources) then
            for k,v in pairs (resources) do
                if k == 'gems' then  
		    local oldGems = self.gems
                    self[k] = self[k] - math.floor(math.abs(tonumber(v) or 0))
                    self.validateGems(oldGems,self.gems)
		    local cmd = getRequestCmd()
		    writeLog('消耗钻石调用了useResource'..self.uid..'cmd='..cmd[1],'gemuseResource')
                else
                    self[k] = self[k] - math.floor(math.abs(tonumber(v) or 0))
                end

                if self[k] < 0 then self[k] = 0 end
                if k=='reputation' then    
                    activity_setopt(uid,'personalHonor',{score=self[k]},true)
                end
                --许愿炉
                if k=='gold' then
                    activity_setopt(uid,'xuyuanlu',{action="useGold",gold=math.floor(math.abs(tonumber(v) or 0))})
                end
            end
            return true
        end
    end
  
    function self.useGem(num)
        
        num = math.ceil(math.abs(tonumber(num)))
        if self.checkResource({gems=num}) then
            local oldGems = self.gems
            self.gems = self.gems - num
            self.validateGems(oldGems,self.gems)

            -- 日常任务
            local uobjs = getUserObjs(self.uid) 
            local mDailyTask = uobjs.getModel('dailytask')
            mDailyTask.changeTaskNum(7)

            -- 活动
            activity_setopt(self.uid,'wheelFortune',{value=num},true)
            activity_setopt(self.uid,'wheelFortune2',{value=num},true)
            activity_setopt(self.uid,'qixi',{value=num},false)
            activity_setopt(self.uid,'leijixiaofei',{value=num},true)
            activity_setopt(self.uid, 'zongzizuozhan', {u=self.uid,e='b',num=num})

             -- 德国七日狂欢
            activity_setopt(self.uid,'sevendays',{act='sd22',v=0,n=num})
            -- 跨年福袋
            activity_setopt(self.uid,'luckybag',{act=3,n=num})
            -- 连续消费
            activity_setopt(self.uid,'lxxf',{act='xf',n=num})    
             -- 岁末回馈
            activity_setopt(self.uid,'feedback',{act='xf',num=num})

            -- 跨服战资比拼
            zzbpupdate(self.uid,{t='f4',n=num})

            -- 全民劳动
            activity_setopt(self.uid,'laborday',{act='task',t='xf',n=num})

            -- 世界杯_一球成名
            activity_setopt(self.uid,'oneshot',{act='cost',num=num})
            -- 新橙配馈赠
            activity_setopt(self.uid,'cpkznew',{act='cost',num=num})
            --海域航线
            activity_setopt(self.uid,'hyhx',{act='tk',type='xf',num=num})

            -- 国庆七天乐
            activity_setopt(self.uid,'nationalday2018',{act='tk',type='xf',num=num})
            -- 马力全开
            activity_setopt(self.uid,'mlqk',{act='tk',type='xf',num=num})

            return true
        end
    end

    --------------增加资源
    -- resources 资源table
    -- checkCapacity 是否检测容量
    function self.addResource(resources,checkCapacity,maxResource)
        if type(resources) == 'table' then
            if checkCapacity then
                local maxResource = maxResource or self.getMaxResource()
                for k,v in pairs(resources) do                                    
                    if self[k] and maxResource[k] and self[k] < maxResource[k] then
                        v = math.floor(math.abs(tonumber(v) or 0))
                        local res = self[k] + v
                        self[k] = res >= maxResource[k] and maxResource[k] or res
                    end
                end
                return true
            else
                for k,v in pairs(resources) do
                     v = tonumber(v) or 0
                     if self[k] and v > 0 then
                        local oldData = self[k]

                        v = math.floor(v)
                        self[k] = self[k] + v

                        if k == 'gems' then
                            self.validateGems(oldData,self.gems)
                            regActionLogs(uid,6,{action=602,item="",value=v,params={oldGems=oldData,gems=self.gems}})

                            -- 审计
                            self.freeg = (self.freeg or 0) + v

                            recordRequest(self.uid,'gem',{num=v})
                        end
                    end
                    if k=='reputation' then                        
                        activity_setopt(uid,'personalHonor',{score=self[k]},true)
                    end
                end
                return true
            end            
        end
    end
  
    function self.getMaxResource()
        local maxResource = {r1=0,r2=0,r3=0,r4=0,gold=0}

        local uobjs = getUserObjs(self.uid) 
        local mBuilding = uobjs.getModel('buildings')
        local buildings = mBuilding.toArray(true)
        local cfg = getConfig('building')
        
        if type(buildings) == 'table' then
            local buildType,buildLevel,capacity

            for k,v in pairs (buildings) do

                if k ~= 'queue' and k~='auto' and k~='auto_expire' then  
                    buildType = arrayGet(v,1,0)                    
                    buildLevel = arrayGet(v,2,0)
                    capacity = arrayGet(cfg,buildType..'>capacity>'..buildLevel,0)

                    -- 资源建筑自身有容量
                    -- 主城与仓库对所有资源有容量
                    -- 不提供存储的建筑无capacity字段
                    if capacity > 0 then
                        if buildType == 1 then
                            maxResource.r1 = maxResource.r1 + capacity
                        elseif buildType == 2 then
                            maxResource.r2 = maxResource.r2 + capacity
                        elseif buildType == 3 then
                            maxResource.r3 = maxResource.r3 + capacity
                        elseif buildType == 4 then
                            maxResource.r4 = maxResource.r4 + capacity
                        elseif buildType == 5 then
                            maxResource.gold = maxResource.gold + capacity
                        else 
                            maxResource.r1 = maxResource.r1 + capacity
                            maxResource.r2 = maxResource.r2 + capacity
                            maxResource.r3 = maxResource.r3 + capacity
                            maxResource.r4 = maxResource.r4 + capacity
                            maxResource.gold = maxResource.gold + capacity
                        end
                    end
                end

            end
        end

        -------------------- 科技 储存技术 加成 --------------------------

        local mTech = uobjs.getModel('techs')
        local techLevel = mTech.getTechLevel('t25')
        local techCfg = getConfig('tech')

        local player =getConfig('player') 
        local addition=(player.warehouseStorage[self.vip+1])  or 0
        local rate = 1 + arrayGet(techCfg,'t25>value>'..techLevel,0)/100+addition

        for k,v in pairs(maxResource) do
            maxResource[k] = v * rate
        end

        return maxResource
    end
  
    -- 经验增加
    function self.addExp(iExp)
        local version  =getVersionCfg()
        local tPlayerExpsCfg = getConfig('player.level_exps')
        local maxExp = tPlayerExpsCfg[version.roleMaxLevel]

	iExp = tonumber(iExp)    
        -- 全民劳动
        activity_setopt(self.uid,'laborday',{act='task',t='ep',n=iExp})  

        if self.exp >= maxExp then
            return true
        end

        --iExp = tonumber(iExp)        
        if iExp then
              iExp = math.floor(math.abs(iExp))              
              if iExp <= maxExp then
                  self.exp = self.exp + iExp
                  self.updateLevel()
                  activity_setopt(self.uid,'levelopen',{act='f2',exp=iExp})
              else
                  self.exp = maxExp
                  self.updateLevel()
                  activity_setopt(self.uid,'levelopen',{act='f2',exp=maxExp})
              end

              return true
        end
        
        writeLog(self.uid .. 'addExp invalid , exp:' .. (iExp or 'is nil'))
        return false
    end
  
    -- 等级更新
    function self.updateLevel()
        local tPlayerExpsCfg = getConfig('player.level_exps')
        local iNextXp = tPlayerExpsCfg[self.level +1]
        local mapUp = false

        if iNextXp and self.exp >= iNextXp then
              for k,v in pairs(tPlayerExpsCfg) do
                    iNextXp = tPlayerExpsCfg[k+1]
                    if iNextXp then                  
                        if self.exp >= v and self.exp < iNextXp then
                              self.level = k
                              mapUp = true
                              break
                        end
                    else
                        self.level = k
                        mapUp = true
                        break
                    end
              end
              --设置钢铁之心 之个人升级任务
              activity_setopt(self.uid,'heartOfIron',{ulevel=self.level})

              -- 德国七日狂欢
              activity_setopt(self.uid,'sevendays',{act='sd3',v=0,n=self.level})
        end

        if mapUp and self.tutorial == 10 and self.level >= 3 then
            -- 注册3级分配地图事件
            regEventBeforeSave(self.uid,'e4',{})

            if self.mapx > 0 and self.mapy > 0 then
                local mMap = require "lib.map"
                local mid = getMidByPos(self.mapx,self.mapy)
                mMap:update(mid,{level=self.level,rank=self.rank})
            end

            if self.alliance > 0 then
                regEventAfterSave(uid,'e4',{aid=self.alliance,level=self.level})
            end
        end
    end
    
    -- 刷新声望等级
    function self.updateHonorLevel()
        local level_exps = getConfig('player.honors')
        
        local m ,i,middle= 1,1,0
        local count = #level_exps
        local maxRound = count
        local exp = self.honors

        if exp >= level_exps[count] then
            return count   
        end

        if exp <= level_exps[1] then 
            return 1
        end

        while i<=count do
            middle = math.floor((count+i)/2)
            if exp > level_exps[middle] and exp < level_exps[middle+1] then
                return middle
            end

            if exp > level_exps[middle] then
                i = middle + 1
            elseif exp < level_exps[middle] then
                count = middle - 1
            else
                return middle
            end

            m = m+1
            if m > maxRound then
                return 1
            end
        end        
    end
    
    -- 增加声望
    function self.addHonor(num)
        local version  =getVersionCfg()
        local honorsCfg = getConfig('player.honors')
        local maxHonors = honorsCfg[version.roleMaxLevel]

        if self.honors >= maxHonors then
            return true
        end

        if num > 0 and num < 999999 then
            self.honors = math.floor(self.honors + num)
            if self.honors > maxHonors then self.honors = maxHonors end 
            return true
        end
    end

    function self.getLevel()
        self.updateLevel()
        return self.level
    end
    
    function self.getHonorLevel()
         return self.updateHonorLevel() or 0
    end

    -- 充值加钻石, 会累计vip
    function self.addGem(num)
        num = math.floor(tonumber(num) or 0)
        if num > 0 and num < 999999 then
            local oldGems = self.gems
            self.gems = self.gems + num
            self.buygems = self.buygems + num
            self.vip = self.updateVipLevel()
            self.buyts = getClientTs()
            activity_setopt(self.uid,'userVip',self.vip,true)

            -- actionLog
            regActionLogs(uid,6,{action=601,item="",value=num,params={oldGems=oldGems,gems=self.gems}})

            self.validateGems(oldGems,self.gems)

            recordRequest(self.uid,'gem',{num=num})
            
            return true
        end
    end

    -- 金矿金币增加
    function self.addGoldMineGems(gems)
        gems = math.floor(tonumber(gems) or 0)
        if gems < 0 then return end

        if not self.flags.goldMine then
            self.flags.goldMine = {0,0}
        end

        local ts = getClientTs()
        local weeTs = getWeeTs()

        if self.flags.goldMine[2] < weeTs then
            self.flags.goldMine[2] = ts
            self.flags.goldMine[1] = 0
        end 

        local goldMineCfg = getConfig("goldMineCfg")
        local canAddGems = goldMineCfg.dailyGemLimit - self.flags.goldMine[1]
        local maxGems = math.floor(goldMineCfg.exploitTime / goldMineCfg.resOutputCfg.u.gems.time)

        if gems > maxGems then
            gems = maxGems
        end

        if gems > canAddGems then
            gems = canAddGems
        end
        
        if gems > 0 then
            self.addResource({gems=gems})

            self.flags.goldMine[1] = self.flags.goldMine[1] + gems
        end

        return gems
    end

    function self.updateVipLevel()
        local gem4vip = getConfig('player.gem4vip')
       
        local m ,i,middle= 1,1,0
        local count = #gem4vip
        local maxRound = count
        local buygems = self.buygems + self.vippoint
        local version  =getVersionCfg()
        local maxvip = version.unlockVipLevel  or 9
        
        if buygems >= gem4vip[count] then
            return maxvip   
        end

        if buygems < gem4vip[1] then 
            return 0
        end

        while i<=count do
            middle = math.floor((count+i)/2)
            if buygems > gem4vip[middle] and buygems < gem4vip[middle+1] then
                if middle >maxvip then
                    middle=maxvip
                end
                return middle
            end
            if buygems > gem4vip[middle] then
                i = middle + 1
            elseif buygems < gem4vip[middle] then
                count = middle - 1
            else  
                if middle >maxvip then
                    middle=maxvip
                end
                return middle              
            end

            m = m+1
            if m > maxRound then
                return 1
            end
        end        
    end

    -- 刷新能量
    -- 每30分钟返回一滴
    function self.updateEnergy()
        local maxEnergy = self.getCurrentMaxEnergy()
        if self.energy >= maxEnergy then 
            self.energycd = 0 
        end

        local cell = 1800
        if self.energycd > 0 then            
            local ts = getClientTs()
            local time = ts - self.updated_at

            local currEnergycd = self.energycd - time
            if currEnergycd < 0 then currEnergycd = 0 end
            local recoverNum = math.ceil (self.energycd / cell) - math.ceil((currEnergycd)/cell)

            if recoverNum > 0 then
                self.energy = self.energy + recoverNum
                if self.energy > maxEnergy then self.energy = maxEnergy end
            end

            self.energycd = currEnergycd         
        end

        if self.energycd <= 0 and self.energy < maxEnergy then 
            self.energycd = (maxEnergy - self.energy) * cell
        end

    end

    -- 增加能量点数
    function self.addEnergy(num)
        local maxEnergy = self.getCurrentMaxEnergy()

        num = math.floor(tonumber(num) or 5)

        if num > 0 then
            self.energy = self.energy + num
            if self.energy >= maxEnergy then
                self.energycd = 0
            end
        end

    end
    --获取当前最大体力上限值
    function self.getCurrentMaxEnergy()
        local maxEnergy = 30
        if moduleIsEnabled('uel') ==1 then
            maxEnergy = maxEnergy + (self.extraenergy or 0)
        end

        return maxEnergy
    end

    -- 设置玩家额外的体力上限值
    function self.setExtraEnergy(num)
        num = tonumber(num) or 0
        if num ~= self.extraenergy then
            self.extraenergy = num
            self.updateEnergy()
        end
    end

    ------------使用能量
    -- num 数量
    function self.useEnergy(num)
        if num > 0 and num <= self.energy then
            local cell = 1800
            local maxEnergy = self.getCurrentMaxEnergy()
            self.energy = self.energy - num
            if self.energy < maxEnergy then
                self.energycd = self.energycd + num * cell
            else
                self.energycd = 0
            end
            -- 远洋征战 士气值
            activity_setopt(self.uid,'oceanmorale',{act='energy',num=num})

            -- 配件大回馈
            activity_setopt(self.uid,'pjdhk',{act='energy',num=num})
            -- 军火限购
            activity_setopt(self.uid,'jhxg',{act='energy',num=num})  

            -- 跨服战资比拼
            zzbpupdate(self.uid,{t='f2',n=num})

            regActionLogs(self.uid,4,{action=3,item='energy',value=num,params={c=self.energy}})
            return true
        end
    end

    --能量检测
    function self.checkEnergy(num)
        return (num>0 and num<=self.energy)
    end

    -- 是否刷新资源
    -- return nil | table
    function self.isUpdateResources()
        local maxResource = self.getMaxResource()
        local res,res1 = nil

        for k,v in pairs(maxResource) do                                    
            if self[k] and self[k] < v then
                if not res then res = {} end
                res[k] = 0
            end
        end

        return res,maxResource
    end

    ----------- 刷新最新资源
    function self.updateResources()
        local produceResources,maxResource = self.isUpdateResources()
        if not produceResources then
            return false
        end
        local arrayGet,pairs = arrayGet,pairs       

        local uobjs = getUserObjs(uid)
        local mBuilding = uobjs.getModel('buildings')
        local mTech = uobjs.getModel('techs')
        local mProp = uobjs.getModel('props')
        local mJob  = uobjs.getModel('jobs')
        -- 7 是生产资源加成
        local jobvalue =mJob.getjobaddvalue(7) -- 区域站生产资源加成
	
        local mBoom = uobjs.getModel('boom')
        
        local buildCfg = getConfig('building')
        local techCfg = getConfig('tech')
        local buildings = mBuilding.toArray(true)
        local ts = getClientTs()
        
        local mChallenge = uobjs.getModel('challenge')
        local challengeBuff = mChallenge.getChallengeBuff()   -- 关卡buff
        local challengeBuffCfg = getConfig("challengeTech")
        
        -- 战争雕像生产资源加速
        local mStatue  = uobjs.getModel('statue')
        local statuevalue = mStatue.getSkillValue('madeSpeed')

        -- 徽章加成
        local mBadge = uobjs.getModel('badge')
        local badgevalue = mBadge.resourceSpeed()

        -- 铁，油，硅，铀，金币
        local bResourceBuildingType = {[1]='r1',[2]='r2',[3]='r3',[4]='r4',[5]='gold'}
        local bResourceTechType = {t15='r1',t16='r2',t17='r3',t18='r4',t19='gold'}       
        local bBaseType2Res= {[201]='r1',[202]='r2',[203]='r3',[204]='r4',[205]='gold'}

        -- 生产总时间,按小时算，最后向下取整
        local produceTime = (self.updated_at > 0 and (ts - self.updated_at) or 0) / 3600

        if type(buildings) == 'table' and produceTime > 0 then            

            local function buildingProduce(mBuilding,buildings,buildCfg,produceTime,ts,bid,buildType)
                local iSlotKey = mBuilding.checkIdInSlots('building',bid)
                local iLevel = arrayGet(buildings,bid..'>2',1)
                local iResource = 0

                local iCompleteEt = arrayGet(mBuilding.queue[iSlotKey],'et')
                
                if iCompleteEt and iCompleteEt < ts and iCompleteEt > self.updated_at  then
                    -- 如果主城在升级完成的时间小于当前时间,
                    -- 则后部分资源为主城升级后的资源量      
                    local iUpGradeBeforeTs = (iCompleteEt - self.updated_at ) / 3600
                    local iUpGradeAfterTs = (ts - iCompleteEt) / 3600
                    
                    iResource = iResource + iUpGradeBeforeTs * arrayGet(buildCfg,buildType .. '>produceSpeed>'..iLevel,0)                
                    iResource = iResource + iUpGradeAfterTs * arrayGet(buildCfg,buildType .. '>produceSpeed>' .. (iLevel + 1),0)                
                elseif iLevel > 0 then
                    iResource = iResource + produceTime * arrayGet(buildCfg,buildType ..'>produceSpeed>'..iLevel,0)
                end

                return iResource
            end

            -------------------- 主城基础加成量-----------------------------------------------

            local iMainCityResource = buildingProduce(mBuilding,buildings,buildCfg,produceTime,ts,'b1',7)
            
            for k,v in pairs (produceResources) do
                produceResources[k] = iMainCityResource
            end

            -------------------- 资源建筑加成量-----------------------------------------------

            local buildType,rName

            for k,v in pairs (buildings) do
                buildType = arrayGet(v,1)
                rName = bResourceBuildingType[buildType]
                if  rName and produceResources[rName] then
                    produceResources[rName] = produceResources[rName] + buildingProduce(mBuilding,buildings,buildCfg,produceTime,ts,k,buildType)
                end
            end
            

            
            -- ---------------- 官职加成-----------------------------------------------------
            local jobProduceResources={}
            if jobvalue>0 then
                for k,v in pairs(produceResources) do
                    jobProduceResources[k]=v*jobvalue
                end
            end

            ------------------  战争雕像加成
            local statueProduceResources = {}
            if statuevalue > 0 then
                for k,v in pairs(produceResources) do
                    statueProduceResources[k] = v * statuevalue
                end
            end
            ------------------ 徽章加成   
            local badgeProduceResources={}
            if badgevalue>0 then
                for k,v in pairs(produceResources) do
                    badgeProduceResources[k]=v*badgevalue
                end
            end

            -------------------- 科技基础加成-----------------------------------------------

            local function techProduce(mTech,produceTime,iResource,ts,tid)
                
                -- 如果当前科技正在升级当中，获取其升级结束时间
                -- 有可能出现在等待队列中，科技中心是否正在升级中                
                local prevEt,iUpLevel,iGainRes = 0,0,0
                local iSlotKey = mTech.checkIdInSlots(tid)
                if iSlotKey then
                    
                    for i=1,iSlotKey do
                        if i == 1 then
                            prevEt = arrayGet(mTech.queue[i],'et')
                        else
                            local slotTid = arrayGet(mTech.queue[i],'id')
                            iUpLevel = 1 + mTech[slotTid]
                            local newTimeConsume = mTech.getUpLevelTimeConsume(slotTid,'b3',iUpLevel,prevEt)                            
                            prevEt = prevEt + newTimeConsume
                        end 
                    end
                end

                local iCompleteEt = prevEt
                local iLevel = arrayGet(mTech,tid,0)
                
                -- 科技出现在升级队列中,且已升级完成
                if iCompleteEt > 0  and iCompleteEt < ts and iCompleteEt > self.updated_at  then
                    local iUpGradeBeforeTs = (iCompleteEt - self.updated_at ) / 3600
                    local iUpGradeAfterTs = (ts - iCompleteEt) / 3600
                    iGainRes = iResource * (iUpGradeBeforeTs/produceTime) * arrayGet(techCfg[tid].value,iLevel) /100          
                    iGainRes = iResource * (iUpGradeAfterTs/produceTime) *  arrayGet(techCfg[tid].value,iLevel+1) /100
                elseif iLevel > 0 then
                    iGainRes = iGainRes + iResource * arrayGet(techCfg[tid].value,iLevel) /100
                end

                return iGainRes
            end

            local techs , rName= mTech.toArray(true)
            local techProduceResources = {}
            for k,v in pairs (techs) do
                rName = bResourceTechType[k]                
                if  rName and produceResources[rName] then
                    techProduceResources[rName] = techProduce(mTech,produceTime,produceResources[rName],ts,k)
                end
            end
            
            -------------------- 道具基础加成-----------------------------------------------

            local function propProduce(rate,st,et,iResource,produceTime,ts)

                local propTime,propRate= 0,rate                
                if ts < et then
                    if st < self.updated_at then
                        propTime = ts - self.updated_at
                    else
                        propTime = ts - st
                    end
                else
                    if st < self.updated_at then
                        propTime = et - self.updated_at
                    else
                        propTime = et - st
                    end
                end

                if propTime > 0 then
                    iResource =  iResource * (propTime/3600/produceTime)  * propRate
                end
                
                return iResource
            end
            
            local propCfg = getConfig('prop')
            local propSlots,useGetCrop = arrayGet(mProp,'info',{})
            local propProduceResources = {}
            for k,v in pairs(propSlots) do
                if type(v) == 'table' then
                    useGetCrop = propCfg[v.id].useGetCrop
                    if useGetCrop then
                        for m,n in pairs(useGetCrop) do
                            if produceResources[m] then
                                propProduceResources[m] = propProduce(n/100,v.st,v.et,produceResources[m],produceTime,ts)
                            end
                        end
                    end
                end
            end 

            local allianceWarProduceResources = {} 
            -- 军团战占据据点有加成
            if self.alliance > 0 then
                if moduleIsEnabled('alliancewar') == 1 or 1 then
                    local bonusRet = M_alliance.getalliancebonus{aid=self.alliance,uid=self.uid}
                    
                    if bonusRet and bonusRet.data and (bonusRet.data.y >= 1 or bonusRet.data.own_at) then
                        local ownAt = tonumber(bonusRet.data.own_at) or 0
                        local ownOver = ownAt + 86400
                        if ownAt > 0 and ownOver > self.updated_at then                            
                            local ownSt = ownAt > self.updated_at and ownAt or self.updated_at
                            local ownEt = ownOver >ts   and ts or ownOver
                            local totalProduceTime = produceTime * 3600
                            local inOwnTs = ownEt - ownSt
                            local addRate = inOwnTs / totalProduceTime
                            local ownid = tonumber(bonusRet.data.y)  
                            
                            local allianceWarCfg
                            if moduleIsEnabled('alliancewarnew') ~= 0 then
                                allianceWarCfg = getConfig('allianceWar2Cfg') 
                            else
                                allianceWarCfg = getConfig('allianceWarCfg') 
                            end

                            for k,v in pairs(produceResources) do          
                                if addRate > 0 and addRate <= 1 then      
                                    if (allianceWarCfg.resourceAddition[ownid]) then

                                         allianceWarProduceResources[k] = produceResources[k] * allianceWarCfg.resourceAddition[ownid]/100 * addRate
                                    end        
                                    
                                end
                            end
                        end
                    end
                end                
            end

            local challengeBuffProduceResources = {} 
            for k,v in pairs(challengeBuff or {}) do
                if challengeBuffCfg[k].baseType then
                    for _,rtype in ipairs(challengeBuffCfg[k].baseType) do
                        local rName = bBaseType2Res[rtype]
                        if produceResources[rName] then
                            challengeBuffProduceResources[rName] = produceResources[rName] * challengeBuffCfg[k].value[v]
                        end
                    end
                end
            end

            ----------------------活动加成------------------
            local acttiveProduceResources ={}
            -- 全民劳动
            local laborrate = activity_setopt(self.uid,'laborday',{act='upRate',n=2})
            if laborrate  then
                for k,v in pairs(produceResources) do
                    acttiveProduceResources[k]=v*laborrate
                end
            end

            -- 远洋征战
            local oceanExpBuff = self.getOceanExpeditionBuff("madeSpeed")
             
            local oceanProduceResources={}
            if oceanExpBuff>0 then
                for k,v in pairs(produceResources) do
                    oceanProduceResources[k]=v*oceanExpBuff
                end
            end
            
            for k,v in pairs(produceResources) do
                produceResources[k] = produceResources[k] + (techProduceResources[k] or 0) + (propProduceResources[k] or 0) + (allianceWarProduceResources[k] or 0) + (challengeBuffProduceResources[k] or 0) +(jobProduceResources[k] or 0) + (acttiveProduceResources[k] or 0) + (statueProduceResources[k] or 0) + (oceanProduceResources[k] or 0)
            end

            -- 用户连续5天不登陆游戏，资源产量将为原有产量的5%。（五天内为正常生产速度）
            local slowSt = self.logindate + 432000

            if ts > slowSt then
                if self.updated_at < slowSt then
                    local produceTimeTs = (self.updated_at > 0 and (ts - self.updated_at) or 0)
                    if produceTimeTs > 0 then
                        local usualTime = slowSt - self.updated_at
                        local slowTime = ts - slowSt 

                        local usualRate = usualTime / produceTimeTs
                        local slowRate = slowTime / produceTimeTs
                        
                        for k,v in pairs(produceResources) do                        
                            produceResources[k] = produceResources[k] * usualRate + produceResources[k] * slowRate * 0.05
                        end
                    end
                else
                    for k,v in pairs(produceResources) do                        
                        produceResources[k] = produceResources[k] * 0.05
                    end
                end
            end     

            -- 增产活动 ----------------------------
            local crystalHarvestActiveInfo = activity_setopt(uid,'crystalHarvest',{name='updateResources'})     

            if type(crystalHarvestActiveInfo) == "table" then
                local baseGoldGrow = crystalHarvestActiveInfo[1]
                local activeSt = crystalHarvestActiveInfo[2] > self.updated_at and crystalHarvestActiveInfo[2] or self.updated_at
                local activeEt = crystalHarvestActiveInfo[3] > ts  and ts or crystalHarvestActiveInfo[3]

                local totalProduceTime = produceTime * 3600
                local inActiveTs = activeEt - activeSt
                local addRate = inActiveTs / totalProduceTime
                
                for k,v in pairs(baseGoldGrow or {}) do
                    if produceResources[k] then                           
                        if addRate > 0 and addRate <= 1 then
                            produceResources[k] = produceResources[k] + produceResources[k] * (v-1) *  addRate                             
                        end               
                    end
                end                
            end 

            --繁荣度 全局生产加成
            local boomRate =  mBoom.effectBoom(2)
            for k, v in pairs( produceResources ) do 
                produceResources[k] = produceResources[k] + produceResources[k]* boomRate
            end

            self.addResource(produceResources,true,maxResource)
            
        end        
    end

    ------获取未保护的资源，侦察与掠夺时可用
    -- 影响因素：
    -- 仓库，读配置
    -- 科技（储存技术--每级增加5%的保护量），
    function self.getUnprotectedResource()        
        -- 未保护，已保护
        local res, proResource = {r1=0,r2=0,r3=0,r4=0,gold=0}, 0

        local uobjs = getUserObjs(self.uid) 
        local mBuilding = uobjs.getModel('buildings')
        local mTech = uobjs.getModel('techs')
        local mBoom = uobjs.getModel('boom')

        -- 仓库保护量
        proResource = mBuilding.getStoragesCapacity(self.vip)
        -- 储存技术保护量
        local rate = mTech.getTechRate('t25')
        proResource = proResource * rate

        local mJob =uobjs.getModel('jobs')
        -- 9 是奴隶资源仓库保护量减少
        local jobvalue =mJob.getjobaddvalue(9) -- 区域站减少资源保护量
        if jobvalue>0 then
            proResource=proResource*(1-jobvalue)
        end
        
        local arrayGet = arrayGet
        for k,v in pairs(res) do
            local unProtectRes = arrayGet(self,k,0) - proResource
            if unProtectRes > 0 then
                res[k] = math.floor((res[k] + unProtectRes) * 0.1)
                --繁荣度 提高掠夺值 
                res[k] = res[k] + math.floor(res[k] * mBoom.effectBoom(3))

            end

        end

        return res
    end

    -- 统御升级 (通用)
    -- 有书时优先使用书
    -- 无书时作用宝石
    function self.troopsLevelUp() 
        local uobjs = getUserObjs(self.uid)
        local mBag = uobjs.getModel('bag')

        local isUp,consumeN = false,0
        local propNums = mBag.getPropNums('p20')
        if (propNums > 0 and mBag.use('p20',1)) then
            isUp = 1
            consumeN = 1
        else
            local gemCost = getConfig("prop.p20.gemCost")
            if self.useGem(gemCost) then 
                isUp = 2
                consumeN = gemCost
            end
        end

        local upLevel = (self.troops or 0) + 1
        if isUp and upLevel <= self.level then
            local cfg = getConfig('player')
            local success = cfg.commander_success[self.troops + 1] or 0
            success=success+(cfg.commandedSpeed[self.vip+1]*success or 0)
            success = activity_setopt(uid,'luckUp',{name='troopsup',item='upRate',value=success}) or success

            setRandSeed()
            local randnum = rand(1,10000)
            
            if randnum <= success then
                self.troops = upLevel
                regEventBeforeSave(self.uid,'e1')

                -- 德国七日狂欢
                activity_setopt(self.uid,'sevendays',{act='sd4',v=0,n=self.troops})

                return 1,isUp,consumeN
            end
        end

        return 0,isUp,consumeN
    end

    -- 统御升级(祝福值， 平台)
    -- 有书时优先使用书
    -- 无书时作用宝石
    function self.troopsLevelUpByLuck()
        local uobjs = getUserObjs(self.uid)
        local mBag = uobjs.getModel('bag')

        local isUp,consumeN = false,0
        local propNums = mBag.getPropNums('p20')
        if (propNums > 0 and mBag.use('p20',1)) then
            isUp = 1
            consumeN = 1
        else
            local gemCost = getConfig("prop.p20.gemCost")
            if self.useGem(gemCost) then
                isUp = 2
                consumeN = gemCost
            end
        end
        local cfg = getConfig('player')
        self.flags.luck = (self.flags.luck or 0) + 10 + (math.ceil(10*cfg.commandedSpeed[self.vip+1]) or 0)
        local upLevel = (self.troops or 0) + 1
        if isUp and upLevel <= self.level then
            
            local maxLucky = cfg.commander_lucky_val[self.troops + 1] or cfg.commander_lucky_val[#cfg.commander_lucky_val]
            --local success = (0.7 * (maxLucky + self.flags.luck) / maxLucky^2) * 10000
            local success = ((self.flags.luck*200)^2/maxLucky^4)*10000
            -- success =success+(cfg.commandedSpeed[self.vip]*success or 0)
            -- print('success',success)
            success = activity_setopt(uid,'luckUp',{name='troopsup',item='upRate',value=success}) or success

            local run = 0
            setRandSeed()
            local randnum = rand(1,10000)

            if self.flags.luck >= 2*maxLucky then
                self.flags.luck = 0
                run = 1
            else
                if randnum <= success then
                    self.flags.luck = 0
                    run = 1
                end
            end

            if run == 1 then
                self.troops = upLevel
                regEventBeforeSave(self.uid,'e1')
                return 1,isUp,consumeN
            end
        end
        -- print('mod.troopslucky3',self.troopslucky)
        return 0,isUp,consumeN
    end

    -- 军衔升级
    -- 需要对应的人物等级
    -- 需要对应的金币
    function self.rankLevelUp()
        local cfg = getConfig("player")
        
        local upLevel = self.rank + 1
        local reqLevel = cfg.rank_up_level_req[upLevel]
        if self.level < reqLevel then 
            writeLog('need user level :' .. reqLevel) 
            return 0
        end

        local reqGold = cfg.rank_up_money_req[upLevel]
        if self.useResource({gold=reqGold}) then
            self.rank = self.rank + 1
            regEventAfterSave(uid,'e8',{})
            return 1
        end

        return 0
    end
   
    -- 每种资源每小时的生产速度
    function self.getProduceSpeed(rname)
        local produceSpeed = 0
        local produceSpeedByTech = 0
        local produceSpeedByProp = 0

        local uobjs = getUserObjs(self.uid) 
        local mBuilding = uobjs.getModel('buildings')
        local mTech = uobjs.getModel('techs')
        local mProp = uobjs.getModel('props')

        local mChallenge = uobjs.getModel('challenge')
        local challengeBuff = mChallenge.getChallengeBuff()   -- 关卡buff
        local challengeBuffCfg = getConfig("challengeTech")

        local buildCfg = getConfig('building')
        local techCfg = getConfig('tech')
        local propCfg = getConfig('prop')

        local mJob  = uobjs.getModel('jobs')
        local jobvalue =mJob.getjobaddvalue(7) -- 区域站生产资源加成

        -- 战争雕像生产资源加速
        local mStatue  = uobjs.getModel('statue')
        local statuevalue = mStatue.getSkillValue('madeSpeed')

        local pairs = pairs

        -- 建筑速度
        local buildings = mBuilding.toArray(true)
        local bResourceBuildingType = {r1=1,r2=2,r3=3,r4=4,gold=5}
        for k,v in pairs(buildings) do
            if type(v)=='table' and ( v[1] == bResourceBuildingType[rname] or v[1] == 7 ) then
                produceSpeed = produceSpeed + buildCfg[v[1]].produceSpeed[v[2]]
            end
        end

        local produceSpeedByJob=0
        if (tonumber(jobvalue) or 0) >0 then
            produceSpeedByJob=produceSpeed*jobvalue
        end

        local produceSpeedByStatue=0
        if (tonumber(statuevalue) or 0) >0 then
            produceSpeedByStatue=produceSpeed*statuevalue
        end

        -- 科技
        local bResourceTechType = {r1='t15',r2='t16',r3='t17',r4='t18',gold='t19'}
        local techLevel = mTech[bResourceTechType[rname]]
        local techRate = arrayGet(techCfg[bResourceTechType[rname]],'value>'..techLevel,0)/100 
        produceSpeedByTech = produceSpeed * techRate

        -- 道具
        local propSlots,useGetCrop = arrayGet(mProp,'info',{})
        for k,v in pairs(propSlots) do
            useGetCrop = propCfg[v.id].useGetCrop
            if useGetCrop then
                for m,n in pairs(useGetCrop) do
                    if m== rname then
                        produceSpeedByProp = produceSpeedByProp + produceSpeed * n/100
                    end
                end
            end
        end 

        local bBaseType2Res= {[201]='r1',[202]='r2',[203]='r3',[204]='r4',[205]='gold'}
        local challengeBuffSpeed = 0 
        for k,v in pairs(challengeBuff or {}) do
            if challengeBuffCfg[k].baseType then
                for _,rtype in ipairs(challengeBuffCfg[k].baseType) do                    
                    if rname == bBaseType2Res[rtype] then
                        challengeBuffSpeed = challengeBuffSpeed + produceSpeed * challengeBuffCfg[k].value[v]
                    end
                end
            end
        end
        
        produceSpeed = produceSpeed + produceSpeedByProp + produceSpeedByTech + challengeBuffSpeed + produceSpeedByJob + produceSpeedByStatue
        produceSpeed = math.floor(produceSpeed)
        
        return produceSpeed
    end


                                -- 每日物品--
    -------------------------------------------------------------

    -- 每日声望
    -- getType:
    --      1 1000金币 20声望
    --      2 10宝石 80声望
    --      3 40宝石 400声望
    --      4 90宝石 1000声望
    function self.dailyHonors(getType)
        local honorsCfg = getConfig('player.honors')
        if self.honors >= honorsCfg[#honorsCfg] then
            return true
        end
        
        local getTime = self.flags.daily_honors              
        local weeTs = getWeeTs()
       
        if getTime < weeTs then                     
            if getType == 1 then
                if self.useResource({gold=1000}) then 
                    self.addHonor(20)
                    self.flags.daily_honors = weeTs
                end
            elseif getType == 2 then
                if self.useGem(10) then 
                    self.addHonor(80) 
                    self.flags.daily_honors = weeTs
                end
            elseif getType == 3 then
                if self.useGem(40) then 
                    self.addHonor(400) 
                    self.flags.daily_honors = weeTs
                end
            elseif getType == 4 then
                if self.useGem(90) then 
                    self.addHonor(1000) 
                    self.flags.daily_honors = weeTs                    
                end
            end
        end
    end

    -- 高级抽奖
    function self.advancedLuckyGoods()
        local getType = 'd2'
        local weeTs = getWeeTs()
        local awards = {} 
        local iGems = 0
        local buyPropNums = 0
        local usePropNums = 0
        
        local lotteryInfo = arrayGet(self.flags.daily_lottery,getType)

        if not lotteryInfo then
            self.flags.daily_lottery[getType] = {ts=0,num=0,cfg=1}
            lotteryInfo = self.flags.daily_lottery[getType]
        end
        
        if not self.flags.daily_lottery[getType].cfg then
            self.flags.daily_lottery[getType].cfg = 1
        end
        local cfgVersion = self.flags.daily_lottery[getType].cfg
        if moduleIsEnabled('signupcfg') == 0  then
            cfgVersion = 1
        end
        local cfg = getConfig('lottery')[getType][cfgVersion]

        local isLottery = false
        local probabilityTable = 1
        local uobjs = getUserObjs(self.uid) 
        local mBag = uobjs.getModel('bag')
        

        -------------------- start vip新特权 高级抽奖免费每天免费一次 
        if moduleIsEnabled('vfn')== 1 and self.vip>0 then
                local vipRelatedCfg = getConfig('player.vipRelatedCfg')
                if type(vipRelatedCfg)=='table' then
                    local vip =vipRelatedCfg.freeSeniorLotteryNum[1]
                    if self.vip>=vip then
                        if lotteryInfo.ts<weeTs then
                            lotteryInfo.ts=0
                        end
                    end
                end 
                               
        end
        --------------------- end


        -- 免费抽奖
        if lotteryInfo.ts == 0 then
            isLottery = 3
            probabilityTable = 3
        else
            local propName, propNum = next(cfg.consume)
            usePropNums = propNum
            local hasNums = mBag.getPropNums(propName) or 0
            local n = propNum - hasNums
            if n > 0 then
                local propCfg = getConfig("prop")
                local gems = n * propCfg[propName].gemCost
                iGems = gems
                buyPropNums = n
                if (hasNums <= 0 or mBag.use(propName,hasNums)) and  self.useGem(gems) then
                    isLottery = 2          
                end
            elseif mBag.use(propName,propNum) then
                isLottery = 1
            end

            if lotteryInfo.num == 9 then
                probabilityTable = 2
            end
        end

        if isLottery then
            local rewardKey = self.getRewardByLucky(cfg.reward[probabilityTable],cfg.probability[probabilityTable])            
            local rewardNum = cfg.reward[probabilityTable][rewardKey][2]            
            local rewardName = cfg.reward[probabilityTable][rewardKey][1]
            
            self.takeReward(rewardName,rewardNum)
            awards = self.formatReward(rewardName,rewardNum)

            self.flags.daily_lottery[getType].ts = weeTs

            if self.flags.daily_lottery[getType].num >= 9 then
                self.flags.daily_lottery[getType].num = 0
            else
                self.flags.daily_lottery[getType].num = self.flags.daily_lottery[getType].num + 1
            end
        end

        -- 版号2额外增加点10000点水晶
        if getClientBH() >= 2 then
            self.addResource{gold=10000}
        end

        return awards,isLottery,iGems,buyPropNums,usePropNums
    end

    -- 普通抽奖
    function self.ordinaryLuckyGoods()     
        local getType = 'd1'
        local weeTs = getWeeTs()
        local ts = getClientTs()
        local awards = {} 
        local iGems = 0
        local buyPropNums = 0
        local usePropNums = 0

        local lotteryInfo = arrayGet(self.flags.daily_lottery,getType)

        if not lotteryInfo then
            self.flags.daily_lottery[getType] = {ts=0,num=0,cfg=1}
            lotteryInfo = self.flags.daily_lottery[getType]
        end
        if not self.flags.daily_lottery[getType].cfg then
            self.flags.daily_lottery[getType].cfg = 1
        end
        local cfgVersion = self.flags.daily_lottery[getType].cfg
        if moduleIsEnabled('signupcfg') == 0 then
            cfgVersion = 1
        end

        local cfg = getConfig('lottery')[getType][cfgVersion]
        local getTime = lotteryInfo.ts or 0

        -- 如果上次领取的时间戳小于今天凌晨，完成次数置空
        if  getTime < weeTs  then
            self.flags.daily_lottery[getType].num = 0
        end

        local isLottery = false
        local uobjs = getUserObjs(self.uid) 
        local mBag = uobjs.getModel('bag')

        -- 免费抽奖
        if self.flags.daily_lottery[getType].num == 0 then
            isLottery = 3
        else
            local propName, propNum = next(cfg.consume)
            usePropNums = propNum
            local hasNums = mBag.getPropNums(propName) or 0
            local n = propNum - hasNums
            buyPropNums = n
            if n > 0 then
                local propCfg = getConfig("prop")
                local gems = n * propCfg[propName].gemCost
                iGems = gems
                if (hasNums <= 0 or mBag.use(propName,hasNums)) and  self.useGem(gems) then
                    isLottery = 2          
                end
            elseif mBag.use(propName,propNum) then
                isLottery = 1
            end           
        end

        if isLottery then
            local rewardKey = self.getRewardByLucky(cfg.reward,cfg.probability)
            local rewardNum = cfg.reward[rewardKey][2]
            local rewardName = cfg.reward[rewardKey][1]
            self.takeReward(rewardName,rewardNum)
            awards = self.formatReward(rewardName,rewardNum)

            self.flags.daily_lottery[getType].ts = weeTs
            self.flags.daily_lottery[getType].num = self.flags.daily_lottery[getType].num + 1
        end
        
        -- 版号2额外增加点1000点水晶
        if getClientBH() >= 2 then
            self.addResource{gold=1000}
        end

        return awards,isLottery,iGems,buyPropNums,usePropNums
    end

    -- 随机获取物品
    -- reward 物品
    -- probability概率
    -- reward = {troops_a10001=1,prop_19=23},
    -- probability = {troops_a10001=1,prop_19=99},
    function self.getRewardByLucky(reward,probability)
        local randSeed = {}

        local pairs = pairs
        if type(probability) == 'table' then
            for k,v in pairs(probability) do
                for i=1,v do
                    table.insert(randSeed,k)
                end                
            end
        end
        
        local k = rand(1,#randSeed)

        return randSeed[k]
    end

    -- props_19=34
    function self.takeReward(reward,num)
        if num < 1 then return false end        
        return takeReward(self.uid,{[reward]=num})
    end

    -- 格式化
    function self.formatReward(reward,num)
        local format = {userinfo='u',props='p', accessory='e'}
        local formatReward = {u={},p={},e={},o={}}
        reward = reward:split('_') 
        local key = format[reward[1]] or 'o'

        formatReward[key] = {[reward[2]]=num}

        return formatReward
    end

    -- 每日购买能量
    -- 次数受VIP等级限制
    function self.buyEnergy()
        local cost = 5
        local flag = 0
        if moduleIsEnabled('uben') ==1 then
            cost = cost*2
            flag = 1
        end
        local ts = getClientTs()
        local weeTs = getWeeTs()

        if self.flags.daily_buy_energy.ts < weeTs then
            self.flags.daily_buy_energy.num = 0
        end 

        local nextNum = (self.flags.daily_buy_energy.num or 0) +1
        cost = cost * nextNum


        if self.flags.daily_buy_energy.num < (self.vip +1) and self.useGem(cost) then
            if flag==1 then
                self.addEnergy(10)
            else
                self.addEnergy()
            end

            self.flags.daily_buy_energy.ts = weeTs
            self.flags.daily_buy_energy.num = nextNum

            return true,cost,nextNum
        end

    end

    -- 晚上12点的时间戳
    -- function self.getWeeTs()
    --     local today = os.date("*t")
    --     local weeTs = os.time({year=today.year, month=today.month, day=today.day, hour=0,min=0,sec=0})
    --     return weeTs
    -- end

    -- 更新公告数据，如果关闭，将其记录删除
    function self.updateNotice(disabledNotices)
        if type(self.flags.notice) ~= 'table' then
            self.flags.notice = {}
            return true
        end

        if type(disabledNotices) == 'table' then
            for k,v in pairs(self.flags.notice) do
               if disabledNotices[v] then
                    table.remove(self.flags.notice,k)
               end
            end            
        end
    end

    -- 更新活动数据，如果关闭，将其记录删除
    -- function self.updateActive(disabledActives)
    --     if type(self.flags.active) == 'table' and type(disabledActives) == 'table' then
    --         for _,v in pairs(disabledActives) do
    --             if self.flags.active[v] then
    --                 table.remove(self.flags.active,v)
    --             end 
    --         end
    --     end
    -- end

    -- 设置审计相关的数据
    -- ips = '',   -- 最近7天每天登陆的ip
    --     ip = '',    -- 最后一次登陆ip
    -- ipsm 30天内每天登陆ip,只记最后一个
    --     buyts = 0,  -- 最后一次充值时间
    --     freeg = 0,  -- 累计赠送金币数
    --     olt = 0,    -- 累计在线时长
    --     logdc = 0,  -- 累计登陆天数
    function self.setAuditData(params)
        if params.action == 'login' then  
            if type(self.ips) ~= 'table' then self.ips = {} end
                        
            if getWeeTs() ~=  getWeeTs(self.logindate) then
                self.logdc = (self.logdc or 0) + 1
            end

            if params.request.client_ip then 
                if self.ip ~= params.request.client_ip then
                    self.ip = params.request.client_ip
                end

                local dayIp = {}
                local ipsLen = #self.ips

                local dayStr = getDateByTimeZone()

                if getWeeTs() ~=  getWeeTs(self.logindate) or ipsLen < 1 then
                    table.insert(dayIp,dayStr)
                    table.insert(dayIp,params.request.client_ip)
                    table.insert(self.ips,dayIp)
                    if ipsLen >= 7 then 
                        for i=ipsLen,7,-1 do
                            if self.ips[1] then table.remove(self.ips,1) end
                        end
                    end  
                else
                    self.ips[ipsLen] = self.ips[ipsLen] or dayIp   
                    if #self.ips[ipsLen] < 10 and not table.contains(self.ips[ipsLen],params.request.client_ip) then
                        table.insert(self.ips[ipsLen],params.request.client_ip)
                    end
                end
            end

        elseif params.action == 'online' then            
            local ts = getClientTs() 
            if not self.online_at or self.online_at == 0 then 
                self.online_at = ts
            end

            local times = ts - self.online_at
            weeTs = getWeeTs()
            -- 当天累计在线时长
            if self.online_at < weeTs then
                self.oltd = 0
            end

            if times <= 180 and times > 0 then
                self.olt = (self.olt or 0) + times     
                
                -- 在线时长奖励累计时间增加
                if self.flags.ol and type(self.flags.ol) == 'table' then
                    self.flags.ol[3] = (self.flags.ol[3] or 0) + times
                end         
            
                if self.online_at > weeTs then
                    self.oltd = (self.oltd or 0) + times
                end

                -- 在线送好礼活动累计时间增加   
                activity_setopt(uid,'onlineReward',{times=times})           
            end

            self.online_at = ts
        end
    end

    -- 用户第二天登录视为活跃用户
    function self.setIsActive()
        if (getWeeTs() - getWeeTs(self.regdate)) == 86400 then
            self.isactive = 1
        end
    end



    ---------------------------新的军衔系统----------------------------


     --每天刷新自己的军功和自己的军衔 
     --当前point大于minpoint算衰减值的时候
    function self.updateNewRank(cuuturt) 
        --print(getClientTs())
        local rankCfg =getConfig("rankCfg")

        if self.urt==0 then
            --print(self.rank)
            
            for ok,ov in pairs (rankCfg.rank) do
                if ov.id==self.rank then
                    self.rp=ov.point
                    break
                end
            end
            self.urt = getWeeTs() + 10800     
        end
        --算缩减值
        if self.rp>rankCfg.minPoint   then
            
            local oldurt=self.urt
            if oldurt==0 then  oldurt=cuuturt  end
           
            self.rp=rankCfg.minPoint+math.floor((self.rp-rankCfg.minPoint)*math.pow((1-rankCfg.pointDecrease),((cuuturt-oldurt)/86400)))

            if self.level < rankCfg.minlevel then
                self.updateRank(self.rp)
            end
        end
        --小于排行榜的时候刷一下军衔
        if self.rp< rankCfg.minRankPoint then
            self.updateRank(self.rp)
        end

        --[[local redis = getRedis()
        local key = "z"..getZoneId()..".refUserNewRank.ts."..cuuturt
        local refret=redis:get(key)
        -- 如果今天没有刷新最新的军衔  要执行一下跑今天前100
        if refret==nil or tonumber(refret)~=1 then
            --local cronParams = {cmd ="cron.refnewrank",params={uid=self.uid}}
            --if not (setGameCron(cronParams,5)) then
                --setGameCron(cronParams,5)
            --end 

        end--]]
        
        --战功大于前100需要的军衔 如果条件符合要刷新自己的军衔
        -- if self.rp> rankCfg.minRankPoint then
        --     local pointkey = "z"..getZoneId()..".minUserNewRankPoint"
        --     local todaypoint = redis:get(pointkey)
        --     --  自己的战功大于今天排名100名的战功要给自己换军衔
        --     if todaypoint ==nil or self.rp>tonumber(todaypoint) then
        --         local ranklist =getNewRankRanking(0,rankCfg.listLength-1)
        --         if next(ranklist) then
        --             for k,v in pairs (ranklist) do
        --                 if tonumber(v.uid) == uid then
        --                     local newRank = tonumber(v.rank)
        --                     for i=#rankCfg.rank,1,-1 do
        --                         local rv=rankCfg.rank[i]
        --                         if next(rv.ranking) then
        --                            if self.level>=rv.lv and self.rp >=rv.point and newRank <= rv.ranking[2] then
        --                                     self.setRank(rv.id)
        --                                     break
        --                             end
        --                         end 
        --                     end
        --                 end 
        --             end

        --         end
        --     end    
        -- end

        --清空当天的军工
        self.drp=0

    end


    -------------刷新自己的军衔
    function self.updateRank(point)
        local rankCfg =getConfig("rankCfg")
        local newrank=self.rank
        for k,v in pairs(rankCfg.rank) do
            if  point>=v.point and self.level>=v.lv then
                newrank=v.id
            end
        end
        self.setRank(newrank)
    end

    ---          修改地图上的军衔

    function self.setRank(rank)
        local oldrank = self.rank
        self.rank=rank
        if rank~=oldrank then
            if  self.tutorial == 10 and self.level >= 3 then
                -- 注册3级分配地图事件
                regEventBeforeSave(self.uid,'e4',{})

                if self.mapx > 0 and self.mapy > 0 then
                    local mMap = require "lib.map"
                    local mid = getMidByPos(self.mapx,self.mapy)
                    mMap:update(mid,{level=self.level,rank=self.rank})
                end

                if self.alliance > 0 then
                    regEventAfterSave(uid,'e4',{aid=self.alliance,level=self.level})
                end
            end
        end
    end
    ------------获取排名对应的军衔

    function self.getNewRankCfg(rank)
        local rankCfg =getConfig("rankCfg")
        local cfg = {}
        for k,v in pairs(rankCfg.rank) do
            if next(v.ranking) then
                --ptb:p(v.ranking)
                if v.ranking[1]<=rank and v.ranking[2]>= rank then
                    return v
                end
            end
        end
        return cfg 
    end


    function self.addRankPoint(point)
        self.rp=self.rp+point
        if  moduleIsEnabled('rpshop') == 1  then
            self.rpb=self.rpb+point
        end
        --月度将领
        activity_setopt(self.uid,'yuedujiangling',{action=1,num=point})
        -- 奔赴前线,获得军功
        activity_setopt(self.uid,'benfuqianxian',{tasks={t4=point}})

        self.drp=self.drp+point
        self.rpt=getClientTs()
        local rankCfg =getConfig("rankCfg")

        --刷新排行榜
        if (self.rp >= rankCfg.minRankPointRanking and self.level>=rankCfg.minlevelRanking) then
            setNewRankRanking(self.uid,self.rp)
        end
        
        --刷新军衔
        if (self.rp >= rankCfg.minRankPoint and self.level>=rankCfg.minlevel) then
            
            if self.rank<rankCfg.minRank then
                self.setRank(rankCfg.minRank)
            end
        else
            self.updateRank(self.rp)
            
        end

    end
    -------------------------新的军衔系统 end-------------------------

    -- 激活头像
    function self.activePic( pid )
        local cfg = getConfig('picListCfg.' .. pid)
        if not cfg then return false end

        --真实头像没开
        local pic = tonumber( string.sub(pid, 2, string.len(pid) ) )
        if pic > 100 and pic < 200 and moduleIsEnabled('pic', 'truepic') == 0 then
            return false
        end

        if self.isActivePic( pid ) then return true end       
        if cfg.level or cfg.vip then return true end

        table.insert(self.piclist, pid)         

        return true
    end

    -- 该头像是否激活
    function self.isActivePic( pid )
        local cfg = getConfig('picListCfg.' .. pid)
        if not cfg then return false end

        --真实头像没开
        local pic = tonumber( string.sub(pid, 2, string.len(pid) ) )
        if pic > 100 and pic < 200 and moduleIsEnabled('pic', 'truepic') == 0 then
            return false
        end

        --等级头像
        if cfg.old then
            return true
        elseif cfg.level and cfg.level <= self.level then
            return true
        elseif cfg.vip and cfg.vip <= self.vip then
            return true
        end

        return false 

    end

    -- 更换头像
    function self.changePic( pid )
        -- -- body
        -- if not self.isActivePic( pid ) then return false end

        self.pic =  tonumber(  string.sub(pid, 2, string.len(pid)) )

        if self.tutorial == 10 and self.level >= 3 then
            -- 注册3级分配地图事件
            regEventBeforeSave(self.uid,'e4',{})

            if self.mapx > 0 and self.mapy > 0 then
                local mMap = require "lib.map"
                local mid = getMidByPos(self.mapx,self.mapy)
                mMap:update(mid,{pic=self.pic})
            end

        end
        return true
    end

    --设置 头像框、挂件
    function self.setPic(pid,ty)
        if not self.isActpid(pid) then
            return false
        end

        if ty=='b' then
            self.bpic=pid
        elseif ty=='a' then
            self.apic=pid
        end

        if self.mapx > 0 and self.mapy > 0 then
            local mMap = require "lib.map"
            local mid = getMidByPos(self.mapx,self.mapy)
            mMap:update(mid,{bpic=self.bpic,apic=self.apic})
        end        
    
        return true
    end

    -- 判断头像、头像框、挂件、聊天气泡是否被激活 
    function self.isActpid(pid)
        if pid=='' then return true end
        if not self.checkpid(pid) then
            return false
        end

        local subp=string.sub(pid,1,1)
        local cfg ={}
        if subp=='p' then
            cfg= getConfig('picListCfg.' .. pid)
        else
            local py='' 
            if subp=='b' then
                py='box'
            elseif subp=='a' then
                py='add'
            elseif subp=='e' then
                py='bubble'
            end
        
            cfg= getConfig('playerPhotoOtherCfg.'..py..'.'..pid)
        end

        if  not cfg then
            return false
        end

        --等级头像
        if cfg.old then
            return true
        elseif cfg.level and cfg.level <= self.level then
            return true
        elseif cfg.vip and cfg.vip <= self.vip then
            return true
        elseif cfg.prop then
            local uobjs = getUserObjs(self.uid)
            local mPicstore= uobjs.getModel('picstore')
            if type(mPicstore[subp])~='table' then
                mPicstore[subp]={}
            end
            -- 优先判断永久图片库 再判断道具使用队列
            if type(mPicstore[subp])=='table' and table.contains(mPicstore[subp],pid) then
                return true
            else
                local mProp = uobjs.getModel('props')
                if  mProp.pidIsInUse(cfg.prop)  then
                    return true
                end
            end
        end

        return false
    end

    -- 检测类型是否正确
    function self.checkpid(pid)
        if pid=='p' then return false end
        if pid=='' then return true end-- 空值代表默认
        local subp=string.sub(pid,1,1)
        if not table.contains({"p","b","a","e"},subp) then
            return false
        end

        return true
    end
     
    -- 获取当前头像、头像框、挂件
    function self.getcurpic(pid)
        if self.isActpid(pid) then
            local subp=string.sub(pid,1,1)
            if subp=='p' then-- 头像没有前缀
                return tonumber(  string.sub(pid, 2, string.len(pid)) )
            end
            
            return pid
        end
        return ''
    end

    -- 道具cd刷新队列检测头像、头像框、挂件
    function self.listenpid(id)
        local propCfg = getConfig('prop')
        local cfg = propCfg[id]
        if cfg.useGetPic and cfg.useGetPic.durationTime and cfg.useGetPic.pid then
            local pic='p'..self.pic
            --头像
            if pic==cfg.useGetPic.pid then
                self.pic=1--如果过期，则使用默认
            end
            -- 头像框
            if self.bpic==cfg.useGetPic.pid then
                self.bpic=''
            end
            -- 挂件
            if self.apic==cfg.useGetPic.pid then
                self.apic=''
            end

            if self.mapx > 0 and self.mapy > 0 then
                local mMap = require "lib.map"
                local mid = getMidByPos(self.mapx,self.mapy)
                mMap:update(mid,{pic=self.pic,bpic=self.bpic,apic=self.apic})
            end                    
        end

    end

    -- 移动之前老玩家piclist值
    function self.movepiclist()
        local uobjs = getUserObjs(uid)
         local mPicstore= uobjs.getModel('picstore')
         if type(self.piclist)=='table' and next(self.piclist) then
            for k,v in pairs(self.piclist) do
                mPicstore.addpic(v)
            end
            self.piclist={}
         end  
    end

    -- 金币验证
    function self.validateGems(oldGems,newGems)
        -- gsd 金币影子
        if not self.flags.gsd then self.flags.gsd = oldGems end

        -- 数据库异常的金币记录日志
        if oldGems and self.flags.gsd ~= oldGems then
            writeLog({"usergem",getZoneId(),self.uid,self.flags.gsd,oldGems},"validator")
        end

        self.flags.gsd = newGems
    end

    -- 清除保护时间
    function self.clearProtect() 
        if self.protect > getClientTs() then
            self.protect = 0
            getUserObjs(self.uid).getModel('props').clearUsePropCd('p14')

            -- 更新地图
            local mid = getMidByPos(self.mapx,self.mapy)
            require("lib.map"):update(mid,{protect=self.protect})

            return true
        end
    end

    -- 战报中是否显示vip true显示
    function self.showvip()
        if type(self.flags)=='table' and type(self.flags.gameSetting)=='table' then
            if self.flags.gameSetting.s6 and self.flags.gameSetting.s6 == 0 then
                return -1
            end
        end

        return self.vip
    end

    -- param job 职位
    -- param et buff结束时间
    function self.setOceanExpeditionBuff(et,job)
        if et then
            self.flags.oceanBf = {et,job}
        end
    end

    function self.getOceanExpeditionBuff(buffKey)
        if self.flags.oceanBf and self.flags.oceanBf[1] then
            if os.time() < self.flags.oceanBf[1] then
                return getConfig("oceanExpedition").winnerBuff[buffKey] or 0
            end
        end
        return 0
    end

    function self.getOceanExpeditionBuffEt()
        return self.flags.oceanBf and self.flags.oceanBf[2] and self.flags.oceanBf[1]
    end

    -- 这里修复一下,如果没有昵称,用uid拼一个唯一的
    if self.nickname == "" then
        self.nickname = getZoneId() .. "@pl" .. uid
    end

    --玩家聊天发送招贤纳士次数
    -- act :1 查询数据 2发送一次
    function self.recruit(act,aid)
        if aid<=0 then
            return {},-1
        end
        local ts = getClientTs()
        local weeTs = getWeeTs()

        local redis =getRedis()
        local redkey ="zid."..getZoneId().."recruit_aid."..aid
        local data =redis:get(redkey)
        data =json.decode(data)
        if type (data)~="table" then data={} end
        if not data.t or tonumber(data.t)~=weeTs then
            data.t = weeTs
            data.n = 0
        end

        if act ==1 then
            return data,0
        end

        if act==2 then
            data.n = (tonumber(data.n) or 0) + 1
            if data.n>3 then
                return data,-121
            end

            jdata=json.encode(data)
            redis:set(redkey,jdata)
            redis:expireat(redkey,weeTs+86400)
            return data,0
        end
    end

    ----------------------------------------------------------------------------------------------------------------

    return self
end
