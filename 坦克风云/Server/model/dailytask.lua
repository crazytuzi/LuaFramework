function model_dailytask(uid,data)
    local self = {
        uid = uid,
        info = {t={},n=0,r=0,c=0,i=0,ts=0,s5=0}, -- s5获得五星的次数
        newinfo={},
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

        self.dailyRefresh()

        return true
    end

    function self.toArray(format)        
        local data = {}
        for k,v in pairs (self) do
            if type(v)~="function" and k~= 'uid' and k~= 'updated_at'  then              
                if format then
                    if type(v) == 'table'  then
                        if next(v) then data[k] = v end
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

     function self.toArrayNew(format)        
        local data = {}
        for k,v in pairs (self) do
            if type(v)~="function" and k~= 'uid' and k~= 'updated_at' and k~= 'newinfo' then              
                if format then
                    if type(v) == 'table'  then
                        if next(v) then data[k] = v end
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

    -- 获取重置的时间戳
    function self.getResetTs()
        -- return getWeeTs() + 10800
        return getWeeTs()
    end

    -- 使用宝石刷新任务
    function self.useGemRefresh(cost)
        local cost = cost or 8
        local uobjs = getUserObjs(self.uid) 
        local mUserinfo = uobjs.getModel('userinfo')
        if mUserinfo.useGem(cost) then
            self.refresh()
        end
    end

    -- 每日一刷
    function self.dailyRefresh()
        if type(self.info) ~= 'table' then
            self.info = {t={},n=0,r=0,c=0,i=0,s5=0,ts=0}
        end

        -- 每日重置次数清零
        local weeTs = getWeeTs()
        local resetTs = self.getResetTs()
        if self.info.ts < resetTs then
            -- self.info.r = 0  -- 重置次数
            -- self.info.n = 0  -- 完成次数
            -- self.info.ts = weeTs

            self.info.t = {} -- 任务情况
            self.info.c = 0 -- 活跃点数
            self.info.r1 = {} -- 活跃任务领取信息
            self.info.ts = resetTs -- 上次刷新时间
        end

        -- if table.length(self.info.t) < 1 then        
        --     self.refresh()
        -- end

        if type(self.newinfo) ~= 'table' then
            self.newinfo = {}
        end

        if table.length(self.newinfo) < 1 or self.newinfo.ts< weeTs then        
            self.refreshnew()
        end
    end

    --新的任务每日一刷
    function self.refreshnew()
        -- 每日所有任务已完成次数都刷新
        local weeTs = getWeeTs()
        local ts = getClientTs()
        local cfg = getConfig('dailytasknew')
        if  table.length(self.newinfo) < 1 then
            --一个人任务都没有就初始化一下
            self.newinfo.t={}
            
            for k,v in pairs(cfg.t) do
                if v.isUrgency==nil then
                    self.newinfo.t[k]={}
                    self.newinfo.t[k].s=v.conditions
                    self.newinfo.t[k].n=0
                end
                
            end

        else
            for k,v in pairs(cfg.t) do
                if type(self.newinfo.t[k])=='table' then
                    self.newinfo.t[k].n=0
                    self.newinfo.t[k].s=v.conditions
                    if self.newinfo.t[k].r ==1 then
                        self.newinfo.t[k].r=0
                    end

                    if v.ts~=nil and v.ts>0  and v.ts>ts then
                        self.newinfo.t[k]=nil
                    end

                else
                    if v.isUrgency==nil then
                        self.newinfo.t[k]={}
                        self.newinfo.t[k].s=v.conditions
                        self.newinfo.t[k].n=0
                    end
                end

            end

        end

        self.newinfo.ts = weeTs  
        self.newinfo.uc = 0
    end

    ----------添加紧急任务
    function self.addUrgencyTask(tid,uselvl)

        local uc =self.newinfo.uc or 0
        if uc >=3 then
            return true
        end

        local dailycfg = getConfig('dailytasknew')
        local cfg = dailycfg.t
        local ts = getClientTs()

        if type(self.newinfo.t[tid])=='table' and cfg[tid] then

            if self.newinfo.t[tid].ts>ts then
                return false
            end
        else
            if not cfg[tid] then
                return false
            end
        end

        self.newinfo.t[tid]={}
        self.newinfo.t[tid].s=cfg[tid].conditions
        self.newinfo.t[tid].n=0
        local l =dailycfg['get'..tid](uselvl) 
        if l<0 then
            l=1
        end
        self.newinfo.t[tid].l= l
        self.newinfo.t[tid].ts=ts+cfg[tid].time
        self.newinfo.uc =uc+1

        return true

    end

    function self.refresh()       
        setRandSeed()
        
        local taskTypeSeed = {1,2,3,4,5,6,7} 
        local taskType = {}
        local cfg = getConfig('dailytask')
        
        local i,randnum = 1
        while i<=5 do
            randnum = rand(1,  #taskTypeSeed)            
            table.insert(taskType,taskTypeSeed[randnum])
            table.remove(taskTypeSeed,randnum)
            i=i+1
        end

        -- star 
        local odds = {25,30,30,12,3}
        local seedArr = {}
        for k,v in pairs(odds) do
            for i=1,v do
                table.insert(seedArr,k)
            end
        end

        --seedArr = table.rand(seedArr)

        local taskStar,m = {},#seedArr
        local star,randnum

        -- 刷新次数+1
        self.info.i = (self.info.i or 0) %6 + 1
        i=1
        while i<=5 do
            if self.info.i == 6 and self.info.s5 < 1 then
                star = 5
            else
                randnum = rand(1,m)
                star = seedArr[randnum]                
            end
            if star == 5 then self.info.s5 = (self.info.s5 or 0) + 1 end
            table.insert(taskStar,star)
            i = i + 1
        end
        
        local task = {}
        for k,v in pairs(taskType) do
            local tid = cfg.r[v][taskStar[k]]
            task[tid] = {s=taskStar[k],n=0}
        end

        if self.info.i == 6 then self.info.s5 = 0 end
        self.info.t = task 
        self.info.c = 0
    end

    ------ 选择任务----------
    function self.select(tid)
        if arrayGet(self.info.t,tid) then
            self.info.c = tid
            self.info.t[tid].n = 0
            return 1
        end

        return 0
    end

    -- 放弃
    function self.cancel(tid)
        if self.info.c == tid and self.info.t[tid] then
            self.info.c =0
            self.info.t[tid].n=0
            return 1
        end

        return 0
    end

    -- 重置任务
    -- vip4TaskRestQueue={1,2,3,4,5,6,7,8,9,10},
    function self.reset() 
        local flag = 0
     
        local uobjs = getUserObjs(self.uid) 
        local mUserinfo = uobjs.getModel('userinfo')

        local tmpKey = mUserinfo.vip+1
        -- 重置次数与vip有关
        local cfg = getConfig("player.vip4TaskRestQueue")
        if self.info.r >= cfg[tmpKey] then 
            writeLog('reset num invalid:'.. self.info.r)
            return flag
        end

        local cost = 28        
        if mUserinfo.useGem(cost) then
            -- 完成次数为5时才能重置
            local dailyNum = 5
            if self.info.n == dailyNum then 
                self.info.r=self.info.r+1
                self.info.n = 0
                self.info.c = 0
                flag = 1
            end
        end

        return flag,cost
    end

    function self.checkSend(type)
        local sendGroup = {[4]=1,[5]=1,[6]=1,[7]=1}
        return sendGroup[group]
    end

    -- 检测任务
    -- 任务type为-1时不检测类型
    function self.changeTaskNum(tType,num)
        -- 新改版的任务废弃
        -- local cfg = getConfig('dailytask.t')
        -- local tid = self.info.c
        -- num = num or 1

        -- if cfg[tid] and tType == cfg[tid].type then
        --     for k,v in pairs (cfg[tid].conditions) do
        --         if self.info.t[tid] and self.info.t[tid].n < self.info.t[tid].s then
        --             self.info.t[tid].n = self.info.t[tid].n + num                    
        --             regEvents("dailytask",1)
        --         end
        --     end
        -- end
    end

    -- 改版后的原每日任务
    function self.changeTaskNum1(taskId,num)
        if not switchIsEnabled("ndtk") then return end

        num = num or 1
        local cfg = getConfig('dailyTask2')
        if cfg.task[taskId] then
            if not self.info.t[taskId] then self.info.t[taskId] = 0 end
            -- writeLog({taskId,num,self.info.t[taskId],cfg.task[taskId].condition},'task')

            -- 未完成,并且开关开启
            if self.info.t[taskId] < cfg.task[taskId].condition then
                local uobjs = getUserObjs(self.uid) 
                local mUserinfo = uobjs.getModel('userinfo')

                -- 达到任务开放等级
                if mUserinfo.level >= cfg.task[taskId].needLv then
                    self.info.t[taskId] = self.info.t[taskId] + num

                    -- 任务完成,添加活跃度
                    if self.info.t[taskId] >= cfg.task[taskId].condition then
                        self.info.t[taskId] = cfg.task[taskId].condition
                    end

                    regEvents("dailytask",1)
                end
            end
        end
    end

    -- 活跃积分
    function self.addActivePoint( point )
        self.info.c = (self.info.c or 0) + point
    end

    -- 检测新任务
    -- 任务id   完成的次数
    function self.changeNewTaskNum(tid,num)
        local cfg = getConfig('dailytasknew.t')
        local flag = false
        if type(self.newinfo.t[tid])=='table' and cfg[tid] then
            if self.newinfo.t[tid] and self.newinfo.t[tid].n < self.newinfo.t[tid].s then
                self.newinfo.t[tid].n = self.newinfo.t[tid].n + num 
                flag=true
                if  cfg[tid].target ~=nil and self.newinfo.t[tid].n >= self.newinfo.t[tid].s then
                    local target = cfg[tid].target
                    if type(self.newinfo.t[target])=='table' and cfg[target] then
                        if self.newinfo.t[target] and self.newinfo.t[target].n < self.newinfo.t[target].s then
                            self.newinfo.t[target].n = self.newinfo.t[target].n + 1
                        end
                    end
                    
                end                
                regEvents("dailytask",1)
            end
        end
        return flag
    end
    --检测紧急任务完成
    function self.changeNewUrgencyTaskNum(tid,lvl)
         local dailycfg = getConfig('dailytasknew')
         local cfg=dailycfg.t

         if type(self.newinfo.t[tid])=='table' and cfg[tid] then
            local ts = getClientTs()
            if self.newinfo.t[tid].ts<ts then
                self.newinfo.t[tid]=nil
                return  true
            end
            if self.newinfo.t[tid] and self.newinfo.t[tid].n < self.newinfo.t[tid].s then
                if lvl< self.newinfo.t[tid].l then
                    return true
                end
                self.newinfo.t[tid].n = self.newinfo.t[tid].n + 1 
                if  cfg[tid].target ~=nil then
                    local target = cfg[tid].target
                    if type(self.newinfo.t[target])=='table' and cfg[target] then
                        if self.newinfo.t[target] and self.newinfo.t[target].n < self.newinfo.t[target].s then
                            self.newinfo.t[target].n = self.newinfo.t[target].n + 1
                        end
                    end
                    
                end                
                regEvents("dailytask",1)
            end
        end
    end


    --获取是否有奖励的标识
    function self.getRewardFlag()
        local flag = 0
        if type(self.newinfo.t)=='table' then

            for k,v in pairs(self.newinfo.t) do
                if v.n>=v.s then

                    if v.r==nil or v.r==0 then
                        flag=1
                        break
                    end
                end
            end
        end

        return flag
    end

    function self.finish(tid,isUseGem)
        local flag,cost = 0,0
        local cfg = getConfig("dailytask")

        if self.info.n < 5 and self.info.t[tid] then
            local isFinish = false
            if self.info.t[tid].n >= self.info.t[tid].s then
                isFinish = true
            elseif isUseGem == 1 then
                cost = 5 * self.info.t[tid].s
                local uobjs = getUserObjs(self.uid) 
                local mUserinfo = uobjs.getModel('userinfo')
                if mUserinfo.useGem(cost) then
                    isFinish = true
                end
            end
            if isFinish then
                -- 奖励
                takeReward(self.uid,cfg.t[tid].award)
                self.refresh()
                self.info.n = (self.info.n or 0 ) + 1
                self.info.c = 0
                flag = 1
            end
        end

        return flag,cost
    end

    --新任务完成领取奖励
    function self.finishnew(tid,isUseGem,userlvl)
        local flag,cost,rais = 0,0,-1
        local cfg = getConfig("dailytasknew")
        if  self.newinfo.t[tid] then
            local isFinish = false
            if self.newinfo.t[tid].n >= self.newinfo.t[tid].s then
                isFinish = true
            end

            local r = self.newinfo.t[tid].r or 0
            if r==1 then
                isFinish=false
            end
            if isFinish then
                -- 奖励
                takeReward(self.uid,cfg.t[tid].award)
                if cfg.t[tid].raising~=nil then
                    local uobjs = getUserObjs(self.uid)  
                    local mUserinfo = uobjs.getModel('userinfo')
                    if mUserinfo.alliance>0 then

                       
                        local execRet,code = M_alliance.addacpoint{uid=uid,aid=mUserinfo.alliance,point=cfg.t[tid].raising,method=1,ts=getWeeTs()}
                        if execRet then
                            rais=1
                        end
                    end
                end
                flag = 1
                if cfg.t[tid].isUrgency==1 then
                    self.newinfo.t[tid]=nil
                end
                
            end
        end
        if flag==1 and cfg.t[tid].isUrgency==nil then
            --随机10%的概率加紧急任务
            setRandSeed()
            local randnum = rand(1,100)
            if randnum<=cfg.r then
                local id = rand(1,2)
                self.addUrgencyTask('s'..id,userlvl)
            end
            self.newinfo.t[tid].r=1
            local ts = getClientTs()
            self.newinfo.ts=ts
        end

        return flag,cost,rais
    
    end
    ------------------------------------------------------------------------------------

   

    return self
end	

