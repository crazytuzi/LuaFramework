function model_task(uid,data)
    local self = {
        uid = uid,
        info = {
            t232={t=0,v=1,c=0},
            t1000={t=11,v=1,c=0},
        },
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
                            if next(v) then
                                if k == 'info' then
                                    data[k] = self.initTaskByGroup(0)
                                else                                
                                    data[k] = v 
                                end
                            end
                        elseif v ~= 0 and v~= '0' and v~='' then
                            data[k] = v
                        end
                    else
                        data[k] = v
                    end
                end
            end
            if type(data.info) == 'table' and format then 
                local versionCfg
                for k,v in pairs(data.info) do 
                    local tid = tonumber(string.sub(k,2))
                    if tid and tid > 3000 then
                        versionCfg = versionCfg or getVersionCfg()
                        if versionCfg.buildingMaxLevel < 70 then
                            data.info[k] = nil
                        end
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

    function self.finish(taskid)
        local flag = false
        local cfg = getConfig("task")

        if self.info[taskid] and self.info[taskid].c >= self.info[taskid].v then

            self.info[taskid] = nil

            -- 解锁 
            for k,v in pairs(cfg[taskid].unlock) do
                self.unlock(v,cfg)
            end

            -- 奖励
            takeReward(self.uid,cfg[taskid].award)
            self.check()
            flag = true
        end

        return flag
    end

    -- 更新隐藏任务
    function self.updateHideTask()        
        if type(self.info) == 'table' then
            local cfg = getConfig("task")
            for k,v in pairs(self.info) do
                if cfg[k] and self.info[k].t == 11 and self.info[k] and self.info[k].c >= self.info[k].v then
                    for _,tid in pairs(cfg[k].unlock) do
                        self.unlock(tid,cfg)
                    end
                    self.info[k] = nil
                end
            end
        end        
    end

    function self.checkSend(group)
        local sendGroup = {[2]=1,[3]=1,[4]=1,[5]=1,[19]=1,[20]=1,[21]=1}
        return sendGroup[group]
    end

    -- 检测
    function self.check()
        local isSendMsg = false -- 是否推消息       
        
        local cfg = getConfig("task")        
        local task = self.format()
        local uobjs = getUserObjs(self.uid) 

        for k,v in pairs(task) do
            -- 生产速度
            if k == 'resource' then
                local mUserinfo = uobjs.getModel('userinfo')
                --
                for taskid,taskinfo in pairs(v) do
                    local group = cfg[taskid].group or 0
                    if self.info[taskid].c < self.info[taskid].v then
                        local oldNum = self.info[taskid].c

                        self.info[taskid].c = mUserinfo.getProduceSpeed(taskinfo.resourcetype) or 0

                        if oldNum ~= self.info[taskid].c then 
                            isSendMsg = true
                        end
                    end
                end
            end

            -- 建筑任务
            if k == 'buildings' then                
                local mBuilding = uobjs.getModel('buildings')
                local hasNum = false                
                local buildings = mBuilding.toArray(true)
                for m,n in pairs(v) do 
                    if self.info[m].c < self.info[m].v then
                        local oldNum = self.info[m].c
                        for bid,build in pairs(buildings) do
                            if type(build)=='table' and build[1] == n.buildingType then
                                -- 拥有的建筑数量
                                if self.info[m].t == 1 then 
                                    if not hasNum then 
                                        self.info[m].c = 0 
                                        hasNum = true
                                    end
                                    self.info[m].c = self.info[m].c  + 1                                    
                               elseif (build[2] or 0) > self.info[m].c then
                                    self.info[m].c = build[2]
                                end
                            end
                        end
                        if oldNum ~= self.info[m].c then 
                                isSendMsg = true
                        end
                    end
                end                    
            end

            -- 角色任务
            if k == 'userinfo' then
                local mUserinfo = uobjs.getModel('userinfo')
                for m,n in pairs(v) do 
                    local group = cfg[m].group or 0
                    for filed,value in pairs(n) do
                        if self.info[m].c < self.info[m].v  then
                            local oldNum = self.info[m].c

                            if filed == 'honors' then
                                self.info[m].c = mUserinfo.updateHonorLevel()
                            else
                                self.info[m].c = mUserinfo[filed] or 0
                            end

                            if oldNum ~= self.info[m].c then 
                                isSendMsg = true
                            end
                        end
                    end
                end
            end

            -- 关卡任务
            if k == 'challenge' then
                local mChallenge = uobjs.getModel('challenge')
                for m,n in pairs(v) do
                    local group = cfg[m].group or 0
                    if mChallenge.info['s'..n] and mChallenge.info['s'..n].s > 0 and self.info[m].c < self.info[m].v then
                        local oldNum = self.info[m].c          

                        self.info[m].c = n or 0

                        if oldNum ~= self.info[m].c then 
                                isSendMsg = true
                        end
                    end
                end
            end

            -- 军队
            if k == 'troops' then
                for m,n in pairs(v) do
                    local group = cfg[m].group or 0
                    local mTroop = uobjs.getModel('troops')
                    if self.info[m].c  < self.info[m].v then
                        local oldNum = self.info[m].c          

                        self.info[m].c = mTroop.troops[n.tanksid] or 0

                        if oldNum ~= self.info[m].c then 
                                isSendMsg = true
                        end
                    end
                end
            end

        end
        
        -- 自动更新隐藏任务
        self.updateHideTask()
        
        if isSendMsg then
            regEvents("task",1)
        end

    end

    -- 攻打岛屿任务检测
    -- 攻击类型，与攻击的等级 1岛，2玩家
    function self.attackTaskCheck(attType,value)
        local task = self.format()

        if task.attack then
            for k,v in pairs(task.attack) do
                if attType == v.type then
                    if v.level and value >= v.level then
                        self.info[k].c = value or 0
                        regEvents("task",1)
                    elseif v.num then
                        self.info[k].c = (self.info[k].c or 0) + 1
                        regEvents("task",1)
                    end
                end
            end
        end
    end

    -- 整理接受的任务格式
    function self.format()        
        local pairs = pairs        
        local cfg = getConfig("task")   
        local groupTask = self.initTaskByGroup()

        local task = {}
        for k,_ in pairs(groupTask) do
            if arrayGet(cfg,k..'>conditions') then
                for m,n in pairs(cfg[k].conditions) do
                    if not task[m] then task[m] = {} end
                    task[m][k] = n
                end
            end
        end

        return task
    end

    -- 将任务分组
    function self.initTaskByGroup(getHide)
        local cfg = getConfig("task") 
        local hideTaskType = 11
        getHide = getHide or 1

        -- 分组
        local group = {}
        for k,v in pairs(self.info) do
            if cfg[k] then
                if not group[cfg[k].group] then group[cfg[k].group] = {} end
                if getHide == 1 then
                    table.insert(group[cfg[k].group],k)
                elseif cfg[k].type ~= hideTaskType then
                    table.insert(group[cfg[k].group],k)
                end
            end
        end

        local initTask = {}
        
        for k,v in pairs(group) do
            if next(v) then
                if table.length(v) > 1 then
                    table.sort(v,function(a,b) return tonumber(a:sub(2))<tonumber(b:sub(2))  end)                
                end

                initTask[v[1]] = self.info[v[1]]
            end
        end

        return initTask
    end

    -- 解锁
    function self.unlock(tid,cfg)
        if not cfg then cfg = getConfig("task") end
        if cfg[tid] and not self.info[tid] then
            self.info[tid] = {t=0,v=0,c=0}  -- t type 标识 v=value完成任务的值 c=current当前完成的值 
            if cfg[tid].type == 11 then self.info[tid].t = cfg[tid].type end
            for k,v in pairs (cfg[tid].conditions) do
                if k=='buildings' then
                    if not v.level then
                        self.info[tid].v = v.num
                        self.info[tid].t=1
                    else
                        self.info[tid].v = v.level
                    end
                    return true               
                elseif k=='userinfo' then
                    _,self.info[tid].v = next(v)
                    return true
                elseif k=='attack' then
                    self.info[tid].v = v.level or v.num
                elseif k == 'challenge' then
                    self.info[tid].v = v
                elseif k == 'troops' then
                    self.info[tid].v = v.num
                elseif k=='resource' then
                    self.info[tid].v = v.num
                end
            end
        end 
    end

    -- 新增的任务
    function self.setNewTask()
        if type(self.info) == 'table' then            
            local uobjs = getUserObjs(self.uid) 

            local mBuilding = uobjs.getModel('buildings')
            if mBuilding.getMainCityLevel() == 70 and not self.info.t5311 then
                self.unlock("t5311")
            elseif mBuilding.getMainCityLevel() == 80 and not self.info.t5321 then
                self.unlock("t5321")
            elseif mBuilding.getMainCityLevel() == 90 and not self.info.t5331 then
                self.unlock("t5331")
            elseif mBuilding.getMainCityLevel() == 100 and not self.info.t5341 then
                self.unlock("t5341")
            end

            -- local mChallenge = uobjs.getModel('challenge')
            -- if mChallenge.info.s240 and (tonumber(mChallenge.info.s240.s) or 0) > 0 and not self.info.t4165 then
            --    self.unlock("t4165")
            -- end
        end
    end

    if self.info=="" then
        self.info = {}
    end

    if not next(self.info) then
        self.info = {
            t232={t=0,v=1,c=0},
            t1000={t=11,v=1,c=0},
        }
    end

    return self
end

