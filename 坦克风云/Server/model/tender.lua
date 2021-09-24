-- 补给舰,补给船,超时空补给舰
function model_tender(uid,data)
    local self = {
        uid = uid,
        level = 0, -- 补给舰等级
        enhancelvl = 0, -- 补给舰强化等级
        exp = 0, -- 补给舰可使用的经验值
        bag = {}, -- 补给品背包
        weight = 0, -- 已使用的背包重量
        strength = 0, -- 补给舰强度()
        material = {}, -- 材料
        task = {}, -- 分配到的任务
        taskcd = 0, -- 任务刷新倒计时
        buycount = 0, -- 购买任务的次数
        queue = {}, -- 补给品生产队列
        used = {},  -- 已使用的补给品
        shop = {}, -- 商店限购信息
        day_at = 0, -- 当日时间戳,以此为依据跨天清数据
        updated_at=0,
    }

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
                elseif vType == 'table' then
                    if type(data[k]) ~= "table" then return false end
                    self[k] = data[k]
                else
                    self[k] = data[k]
                end
            end
        end

        -- 重置与天相关的数据
        local weeTs = getWeeTs()
        if self.day_at < weeTs then
            self.resetDailyData()
            self.day_at = weeTs
        end

        -- 任务CD时间
        self.checkTaskCD()

        return true
    end

    function self.toArray(format)
        local data = {}
        for k,v in pairs (self) do
            if type(v)~="function" and k~= 'uid' and k~= 'updated_at' then
                data[k] = v
            end
        end

        return data
    end

    local function getComposeCfg(quality)
        local tenderCfg = getConfig("tenderSkill")
        return tenderCfg.compose[quality]
    end

    -- 统一添加奖励格式形式的物品
    -- 优先先判断全字段,长字串
    function self.addResource(column,num)
        column = tostring(column)

        if column == "exp" then
            return self.addExp(num) -- 经验
        elseif column:startswith("x") then
            return self.addMaterial({[column]=num}) -- 材料
        elseif column:startswith("h") then
            return self.addSupply(column,num) -- 补给品
        end
    end

    -- 检测任务倒计时
    function self.checkTaskCD()
        local ts = getClientTs()

        if self.taskcd > 0 and self.taskcd <= ts then
            local lastTs = self.taskcd
            self.addTask(self.genCommonTask())
            self.clearTaskCD()

            if not self.taskQueueIsFull() then
                self.setTaskCD(lastTs)
                return self.checkTaskCD()
            end

            return 
        end

        if self.taskQueueIsFull() then
            self.clearTaskCD()
        end
    end

    -- 设置任务计时
    function self.setTaskCD(st)
        self.taskcd = ( st or getClientTs()) + getConfig("tender").main.addTaskTime
    end

    -- 开始刷下一个任务的倒计时
    -- TODO 升VIP后调用
    function self.startTaskCD()
        if not self.taskQueueIsFull() and self.taskcd == 0 then
            self.setTaskCD()
        end
    end

    -- 清除任务计时
    function self.clearTaskCD()
        self.taskcd = 0
    end

    -- 重置当天所有数据
    function self.resetDailyData()
        self.buycount = 0
        self.shop = {}
    end

    function self.getLevel()
        return self.level
    end

    function self.getEnhancelvl()
        return self.enhancelvl
    end

    -- 等级提升
    function self.levelUp()
        self.level = self.level + 1
        self.reCalcBuildingStrength()
        return self.level
    end

    -- 强化等级提升
    function self.enhanceLvlUp()
        self.enhancelvl = self.enhancelvl + 1
        self.recalcUsedSupplyStrength()
    end

    -- 加经验值
    function self.addExp(exp)
        if exp <= 0 then return false end
        self.exp = math.floor(self.exp + exp)
        return true
    end

    -- 使用经验
    function self.useExp(exp)
        if exp > 0 then
            exp = math.ceil(exp)
            if self.exp >= exp then
                self.exp = self.exp - exp
                return self.exp
            end
        end
    end

    -- 获取背包剩余的重量
    function self.getRemainWeight()
        return getConfig("tender").main.maxWeight - self.weight
    end

    -- 合成补给品
    function self.composeSupply(quality)
        local tenderCfg = getConfig("tenderSkill")
        local composeCfg = tenderCfg.compose[quality]

        if not composeCfg then return nil end

        local supply = {quality,0,0}

        setRandSeed()
        local attNum = 0
        if composeCfg.attNum[1] == composeCfg.attNum[2] then
            attNum = composeCfg.attNum[1]
        else
            attNum = rand(composeCfg.attNum[1],composeCfg.attNum[2])
        end

        if #composeCfg.attContain == attNum then
            supply[2] = bit32.lshift(1,attNum) - 1
        else
            local keys = table.keys(composeCfg.attContain)
            local len = #composeCfg.attContain

            for i=1,attNum do
                local n = rand(1,len)
                supply[2] = bit32.bor(supply[2],bit32.lshift(1,keys[n]-1))
                keys[n] = keys[len]
                len = len - 1
            end
        end

        if composeCfg.skillPool then
            supply[3] = getRewardByPool(tenderCfg.skillPool[composeCfg.skillPool])[1]
        end

        return supply
    end

    -- 获取补给品的战斗属性
    function self.getSupplyAttributes(supply)
        local attributes = {}
        local composeCfg = getComposeCfg(supply[1])
        local intensifyAttrCfg = {}
        if self.enhancelvl > 0 then
            intensifyAttrCfg = getConfig("tender").intensify[self.enhancelvl].attMulPlus
        end

        for k,v in pairs(composeCfg.attContain) do
            k = bit32.lshift(1,k-1)
            if bit32.band(supply[2],k) == k then
                if intensifyAttrCfg[v] then
                    attributes[v] = composeCfg.attMul + intensifyAttrCfg[v]
                else
                    attributes[v] = composeCfg.attMul
                end
            end
        end

        return attributes
    end

    -- 直接添加补给品成品到背包
    function self.addSupplyToBag(supply)
        local composeCfg = getComposeCfg(supply[1])
        if composeCfg.supWeight > self.getRemainWeight() then
            return false
        end

        -- 背包上限
        if #self.bag >= 90 then
            return false
        end

        table.insert(self.bag,supply)
        self.weight = self.weight + composeCfg.supWeight
        return true
    end

    -- 增加补给品
    function self.addSupply(quality,num)
        num = math.floor(num or 1)
        if num < 1 then return false end

        for i=1,num do
            if not self.addSupplyToBag(self.composeSupply(quality)) then
                return false
            end
        end

        regKfkLogs(self.uid,'tender',{
                addition={
                    {desc="增加补级品",value={quality,num}}
                }
            }
        )  

        return true
    end

    -- 删除补给品
    function self.rmSupply(index,weight)
        if self.bag[index] then
            if not weight then
                local composeCfg = getComposeCfg(self.bag[index][1])
                weight = composeCfg.supWeight
            end

            self.bag[index] = self.bag[#self.bag]
            self.weight = self.weight - weight
            if self.weight < 0 then
                self.weight = 0
            end

            local supplyInfo = table.remove(self.bag)

            regKfkLogs(self.uid,'tender',{
                    addition={
                        {desc="消耗补级品",value=supplyInfo}
                    }
                }
            )  
        end
    end

    -- 使用补给品
    function self.useSupply(index)
        if self.bag[index] then
            local composeCfg = getComposeCfg(self.bag[index][1])
            self.used = {self.bag[index],os.time() + composeCfg.duration,0} -- 补给品,过期时间
            self.rmSupply(index,composeCfg.supWeight)
            self.recalcUsedSupplyStrength()
        end
    end

    function self.checkSupply(index,quality)
        return self.bag[index] and self.bag[index][1] == quality
    end

    function self.productionQueueIsFull()
        return #self.queue >= getConfig("tender").main.produceLine
    end

    -- 增加一个生产补给品的队列
    -- 品质,生产完成时间
    function self.productionQueueAdd(quality,timeConsume)
        if #self.queue == 0 then
            table.insert(self.queue,{quality,getClientTs() + timeConsume})
        else
            table.insert(self.queue,{quality})
        end
    end

    local function getProduceConsumeTs(quality)
        return getConfig("tenderSkill").compose[quality].lastTime
    end

    function self.refreshProductionQueueTs()
        if #self.queue > 1 then
            local ts = getClientTs()
            for i=2,#self.queue do
                if self.queue[i-1][2] > ts then break end

                if not self.queue[i][2] then
                    self.setProductionTime(i,self.queue[i-1][2] + getProduceConsumeTs(self.queue[i][1]))
                end
            end
        end
    end

    function self.productionQueueGet(index)
        self.refreshProductionQueueTs()
        return self.queue[index]
    end

    function self.productionQueueRemove(index)
        if self.queue[index] then 
            -- 要保证删除的队列是刷新过的
            -- self.refreshProductionQueueTs()

            -- 已经开始
            if self.queue[index][2] then
                local nextIdx = index+1
                if self.queue[nextIdx] and not self.queue[nextIdx][2] then
                    self.setProductionTime(nextIdx)
                end
            end

            table.remove(self.queue,index) 
        end
    end

    -- 设置生产时间
    function self.setProductionTime(index,ts)
        if self.queue[index] then
            ts = ts or (getClientTs() + getProduceConsumeTs(self.queue[index][1]))
            self.queue[index][2] = ts
        end
    end

    -- 增加材料
    function self.addMaterial(items)
        if type(items) ~= 'table' then return false end

        for k,v in pairs(items) do
            v = math.floor(v)
            if v > 0 then
                self.material[k] = (self.material[k] or 0) + v
            end
        end

        regKfkLogs(self.uid,'tender',{
                addition={
                    {desc="增加补给舰材料",value=items}
                }
            }
        )

        return true
    end

    -- 使用材料
    function self.useMaterial(items)
        if type(items) ~= 'table' then return false end

        for k,v in pairs(items) do
            v = math.ceil(v)

            if v <= 0 then
                return false, k
            end

            if not self.material[k] then 
                return false, k
            end

            if self.material[k] < v then
                return false, k
            end

            self.material[k] = self.material[k] - v
            if self.material[k] <= 0 then
                self.material[k] = nil
            end
        end

        regKfkLogs(self.uid,'tender',{
                addition={
                    {desc="消耗补给舰材料",value=items}
                }
            }
        )

        return true
    end

    function self.getMaterialNum(id)
        return self.material[id] or 0
    end

    -- 任务队列是否已满
    -- return bool
    function self.taskQueueIsFull()
        local tenderCfg = getConfig("tender")
        local vipLevel = getUserObjs(self.uid).getModel('userinfo').vip
        local taskSlot = tenderCfg.main.taskPlace[vipLevel] or tenderCfg.main.taskPlace[0]

        return #self.task >= taskSlot
    end

    -- 初始化一个任务
    local function initTaskInfo(taskId)
        -- 任务ID,是否普通0是普通,1是高级的,任务完成时间(0表示还未开始)
        return {taskId,0,0}
    end

    -- 排除池子里指定的值
    local function exceptPoolValue(pool,value)
        local tb = copyTable(pool)
        for k,v in pairs(tb[3]) do
            if v == value then
                table.remove(tb[3],k)
                table.remove(tb[2],k)
            end
        end

        return tb
    end

    local function genTask(taskPool)
        local taskInfo = getRewardByPool(taskPool)
        if type(taskInfo) == "table" and taskInfo[1] then
            return initTaskInfo(taskInfo[1])
        end
    end

    -- 生成普通任务
    function self.genCommonTask(exceptTask)
        local taskPool =  getConfig("tender").taskPool.tp1
        if exceptTask then
            taskPool = exceptPoolValue(taskPool,exceptTask[1])
        end

        return genTask(taskPool)
    end

    -- 生成高级任务
    function self.genAdvancedTask(exceptTask)
        local taskPool =  getConfig("tender").taskPool.tp2
        if exceptTask then
            taskPool = exceptPoolValue(taskPool,exceptTask[1])
        end

        -- 置上高级任务的标识
        local taskInfo = genTask(taskPool)
        taskInfo[2] = 1

        return taskInfo
    end

    -- 增加任务
    function self.addTask(task)
        if self.taskQueueIsFull() then return false end

        if type(task) == "string" then
            table.insert(self.task,initTaskInfo(task))
        else
            table.insert(self.task,task)
        end

        -- 任务队列满了,清除CD时间
        if self.taskQueueIsFull() then
            self.clearTaskCD()
        end

        return true
    end

    -- 替换任务
    function self.replaceTask(index,task)
        self.task[index] = task
    end

    -- 移除任务
    function self.removeTask(index)
        if self.task[index] then
            table.remove(self.task,index)
            self.startTaskCD()
        end
    end

    -- 获取队列中的指定任务
    function self.getTask(index,taskId)
        if not taskId then
            return self.task[index]
        end

        if self.task[index] and self.task[index][1] == taskId then
            return self.task[index]
        end
    end

    -- 是否是普通任务
    function self.isCommonTask(taskInfo)
        return taskInfo[2] == 0
    end

    -- 任务开始
    function self.taskStart(task)
        if task and task[3] then
            local taskCfg = getConfig("tender").taskList[task[1]]
            task[3] = getClientTs() + taskCfg.timeNeed

            -- 新优化1：悬赏任务，完成的悬赏任务，根据完成时间置顶；
            table.sort(self.task,function(a,b)
                local m = a[3]
                local n = b[3]

                if m == 0 then m = 3000000000 end
                if n == 0 then n = 3000000000 end

                return m < n 
            end)
        end
    end

    -- 任务已经开始
    function self.taskIsStart(task)
        return task[3] > 0
    end

    -- 任务是否完成
    function self.taskIsCompleted(task)
        return self.taskIsStart(task) and task[3] <= getClientTs()
    end

    -- 增加购买次数
    function self.incrBuyCount()
        self.buycount = self.buycount + 1
        return self.buycount
    end

    -- 商店购买设置次数
    function self.setShop(item,num)
        if num < 0 then return end
        self.shop[item] = (self.shop[item] or 0) + math.ceil(num)
    end

    -- 获取商品购买次数
    function self.getShopItem(item)
        return self.shop[item] or 0
    end

    -- 获取正在使用的补给品
    function self.getUsedSupply()
        if next(self.used) and self.used[2] > os.time() then
            return self.used[1],self.used[3]
        end
    end

    function self.setUsedSupplyStrength(strength)
        self.used[3] = strength
    end

    -- 重新计算使用中的补给品的强度
    function self.recalcUsedSupplyStrength()
        local supply = self.getUsedSupply()
        if supply then
            local tenderCfg = getConfig("tender")
            local tenderSkillCfg = getConfig("tenderSkill")

            local strength = 0

            -- 强化等级强度
            if tenderCfg.intensify[self.enhancelvl] then
                strength = strength + tenderCfg.intensify[self.enhancelvl].strength
            end

            -- 补给品强度为属性条数乘以基数值
            if tenderSkillCfg.compose[supply[1]] then
                local perStr = tenderSkillCfg.compose[supply[1]].perStr
                local m = supply[2]
                while m > 0 do
                    m = bit32.band(m,m-1)
                    strength = strength + perStr
                end
            end

            -- 技能强度
            if supply[3] ~= 0 then
                strength = strength + tenderSkillCfg.skill[supply[3]].strength
            end

            self.setUsedSupplyStrength(strength)
        end
    end

    -- 获取建筑强度(补给舰的强度+强化等级强度)
    function self.getBuildingStrength()
        return self.strength
    end

    function self.reCalcBuildingStrength()
        local strength = 0
        local tenderCfg = getConfig("tender")
        if tenderCfg.level[self.level] then
            strength = strength + tenderCfg.level[self.level].strength
        end

        if tenderCfg.intensify[self.enhancelvl] then
            strength = strength + tenderCfg.intensify[self.enhancelvl].strength
        end

        self.strength = strength
    end

    -- 战斗属性
    function self.getBattleAttributes()
        if self.level > 0 then
            local attributes,sid
            local tenderCfg = getConfig("tender")

            -- 有使用的补给品
            local supply = self.getUsedSupply()
            if supply then
                attributes = {}
                local supplyAttrs = self.getSupplyAttributes(supply)
                for k,v in pairs(tenderCfg.level[self.level].attUp) do
                    if supplyAttrs[k] then
                        attributes[k] = v * supplyAttrs[k]
                    else
                        attributes[k] = v
                    end
                end

                -- 补给品的技能
                if supply[3] and supply[3] ~= 0 then
                    sid = supply[3]
                    local skillCfg = getConfig("tenderSkill").skill
                    if not skillCfg[sid].ability then
                        if type(skillCfg[sid].attType) == "table" then
                            for k,v in pairs(skillCfg[sid].attType) do
                                attributes[v] = ( attributes[v] or 0 ) + skillCfg[sid].value[k]
                            end
                        elseif skillCfg[sid].attType then
                            attributes[skillCfg[sid].attType] = ( attributes[skillCfg[sid].attType] or 0 ) + skillCfg[sid].value
                        end

                        -- 先手值,先手值在配置中给独立出来了
                        -- 有的技能即加先手值,但其它的属性需要条件判断
                        if skillCfg[sid].first then
                            attributes.first = skillCfg[sid].first
                        end
                    end
                end
            else
                attributes = tenderCfg.level[self.level].attUp
            end

            return attributes,sid,self.formatUsedInfoForBattle()
        end
    end

    -- 战斗信息
    function self.formatUsedInfoForBattle()
        local info
        local supply,supplyStrength = self.getUsedSupply()
        local buildingStrength = self.getBuildingStrength()
        if supply then
            info = {self.level,self.enhancelvl,buildingStrength+supplyStrength,supply[1],supply[2],supply[3],supplyStrength}
        else
            info = {self.level,self.enhancelvl,buildingStrength}
        end
        return table.concat(info,'-')
    end

    return self
end
