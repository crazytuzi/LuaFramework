--[[
    极品融合器(军团)
    每个合成系统字段的长度是按当时开发时的数据设置的
    如果后边要新增可合成的配置，需要调整数据库对应字面的长度
]]
local function model_amixer(self)
    -- 固定写法 ------------

    self._initPrivate{
        dbData={ -- 初始化的数据
            aid=0,
            sequip={},  -- 超级装备
            armor={},   -- 海兵方阵 
            accessory={},   -- 配件
            alienweapon={}, -- 异星武器
            items={},   -- 合成的珍品
            itime={},   -- 珍品产出时间 [1548507307,1548507307...]
            ptime=0,    -- 最近一次合成时间 productionTime
            status=0,   -- 融合器状态，0无需合成1需要进行合成
            updated_at=0,   -- 更新时间
        },
        pkName = "aid", -- 主键名
        tableName = "amixer", -- 表名
    }

    -- ----------------
    -- 数据格式说明：
    --[[
        "sequip": {     // 物品ID及对应的数量
                "s10001": 6, 
                "s10002": 9
            },

        items = {
            {"s10001",1,1001892}, -- 物品id,对应的时间key(itime[]),分配的用户id
            {"s10002",2},   -- 第三位为空表示未分配
        }
    ]]

    local consts = {
        MATERIA_LMAX_COUNT = 9999999, -- 单个物品可注入的原料上限
    }

    function self.toArray()
        return self._getData()
    end

    function self.init()
    end

    function self.setStatus(materialNum)
        if materialNum>= getConfig("bestMixer").main.mergeRate then
            self.status = 1
        end
    end

    function self.getSequip()
        return self.sequip
    end

    function self.addSequip(id,num)
        if num <= 0 then return false end

        self.sequip[id] = (self.sequip[id] or 0) + math.floor(num)
        if self.sequip[id] > consts.MATERIA_LMAX_COUNT then
            return false
        end

        self.setStatus(self.sequip[id])
        return true
    end

    function self.getArmor()
        return self.armor
    end

    function self.addArmor(id,num)
        if num <= 0 then return false end

        self.armor[id] = (self.armor[id] or 0) + math.floor(num)
        if self.armor[id] > consts.MATERIA_LMAX_COUNT then
            return false
        end

        self.setStatus(self.armor[id])
        return true
    end

    function self.getAccessory()
        return self.accessory
    end

    function self.addAccessory(id,num)
        if num <= 0 then return false end

        self.accessory[id] = (self.accessory[id] or 0) + math.floor(num)
        if self.accessory[id] > consts.MATERIA_LMAX_COUNT then
            return false
        end

        self.setStatus(self.accessory[id])
        return true
    end

    function self.getAlienWeapon()
        return self.alienweapon
    end

    function self.addAlienWeapon(id,num)
        if num <= 0 then return false end

        self.alienweapon[id] = (self.alienweapon[id] or 0) + math.floor(num)
        if self.alienweapon[id] > consts.MATERIA_LMAX_COUNT then
            return false
        end

        self.setStatus(self.alienweapon[id])
        return true
    end

    function self.getItems()
        return self.items
    end

    function self.getItemByIdx(idx)
        return self.items[idx]
    end

    function self.getItemOwner(item)
        return tonumber(item[3])
    end

    function self.getItemId(item)
        return item[1]
    end

    -- 获取生产时间
    function self.getItemPtime(item)
        return self.itime[item[2]] 
    end

    function self.setItemOwner(item,uid)
        item[3] = uid
    end

    function self.addItem(itemId,tsKey)
        table.insert(self.items,{itemId,tsKey})
        return #self.items
    end

    function self.delItem(idx)
        table.remove(self.items,idx)
    end

    function self.setMaterial(id,num)
        local bestMixerCfg = getConfig("bestMixer")
        if bestMixerCfg.itemList[id] then
            if bestMixerCfg.itemList[id].type == 1 then
                self.sequip[id] = num
            elseif bestMixerCfg.itemList[id].type == 2 then
                self.armor[id] = num
            elseif bestMixerCfg.itemList[id].type == 3 then
                self.accessory[id] = num
            elseif bestMixerCfg.itemList[id].type == 4 then
                self.alienweapon[id] = num
            end
        end
    end

    local function getRequestInfoCacheKey(aid)
        return string.format("z%d.amixer.item.request.%d.%s",getZoneId(),aid,getWeeTs())
    end

    function self.itemRequest(itemInfo,aid,uid)
        local cacheKey = getRequestInfoCacheKey(aid)
        local redis = getRedis()
        redis:hsetnx(cacheKey,uid,tostring(itemInfo))
        redis:expire(cacheKey,86400)
    end

    function self.hasItemRequest(aid,uid)
        return getRedis():hget(getRequestInfoCacheKey(aid),uid)
    end

    function self.getItemRequestInfo(aid)
        aid = aid or self.aid
        return getRedis():hgetall(getRequestInfoCacheKey(aid))
    end

    function self.getItime()
        return self.itime
    end

    function self.setItime()
        local weets = getWeeTs()

        if #self.itime < 3 then
            table.insert(self.itime,weets)
            return #self.itime
        end

        for k,v in pairs(self.itime) do
            -- 已过期的时间值会这被置为0,返回当前位置
            if v == 0 then
                self.itime[k] = weets
                return k
            elseif v == weets then
                return k
            end
        end
    end

    function self.setPtime()
        self.ptime = getWeeTs()
    end

    function self.cleanExpiredItem()
        local bestMixerCfg = getConfig("bestMixer")
        local expireTs = bestMixerCfg.main.privilegeTime + bestMixerCfg.main.buyTime

        -- 这里考虑一下跨时区问题少算俩小时能保证过期
        -- 保证定时要在指定时间执行
        expireTs = expireTs - 7200

        local n = 0 -- 过期珍品数
        local aPoint = 0    -- 军团资金

        local itemsLog = {}
        local ts = os.time()

        for k,v in pairs(self.itime) do
            if (v + expireTs) < ts then
                local items = self.getItems()
                for i=#items,1,-1 do
                    if items[i][2] == k then
                        local itemId = self.getItemId(items[i])
                        itemsLog[itemId] = (itemsLog[itemId] or 0) + 1

                        aPoint = aPoint + bestMixerCfg.itemList[itemId].wealth2
                        n = n + 1
                        table.remove(items)
                    end
                end

                -- 约定把过期的时间内容置为0
                self.itime[k] = 0
            end
        end

        -- 极品融合器
        regKfkLogs(self.aid,'amixer',{
                notUser=true,
                addition={
                    {desc="过期珍品",value=itemsLog}
                }
            }
        )

        -- 增加军团资金，加操作日志
        if n > 0 then
            M_alliance.addacpoint{
                method=10,
                aid=self.aid,
                point=aPoint,
            }

            writeLog({self.aid,itemsLog})

            self.setItemLog{
                aid = self.aid,
                type = 3,
                content = tostring(n) .. "-" .. tostring(aPoint),
            }
        end
    end

    -- 消耗源料
    local function consumeMaterial(material,itemId,num)
        material[itemId] = material[itemId] - num
        if material[itemId] <= 0 then
            material[itemId] = nil
        end
    end

    local function produceLog(itemsLog)
        writeLog({self.aid,itemsLog})

        if next(itemsLog) then
            regKfkLogs(self.aid,'amixer',{
                    notUser=true,
                    addition={
                        {desc="生产珍品",value=itemsLog}
                    }
                }
            )
        end
    end

    --  --生产排序（1-超级装备，2-海兵方阵，3-配件，4-异星武器）
    -- productSort={1,3,2,4},
    function self.produce()
        self.setPtime()

        local bestMixerCfg = getConfig("bestMixer")
        local bags = bestMixerCfg.main.goodsNumLimit - #self.items
        if bags <= 0 then
            writeLog({self.aid,"goods full"})
            return nil
        end

        local allMaterial = {
            self.getSequip(),
            self.getAccessory(),
            self.getArmor(),
            self.getAlienWeapon(),
        }

        local tsKey = self.setItime()
        if not tsKey then
            writeLog({self.aid, "not tsKey", self.getItime()})
            return nil
        end

        local itemsLog = {}
        local isFull = false

        for idx,material in pairs(allMaterial) do
            for _, itemId in pairs(bestMixerCfg.sortList[idx]) do
                if material[itemId] and material[itemId] >= bestMixerCfg.main.mergeRate then
                    local itemNum = math.floor(material[itemId] / bestMixerCfg.main.mergeRate)
                    if itemNum > bags then
                        itemNum = bags
                    end

                    consumeMaterial(material,itemId,itemNum * bestMixerCfg.main.mergeRate)

                    -- 记个产出日志
                    itemsLog[itemId] = itemNum

                    for i=1,itemNum do
                        -- 珍品库满了,直接退出
                        if self.addItem(itemId,tsKey) >= bestMixerCfg.main.goodsNumLimit then
                            produceLog(itemsLog)
                            return itemsLog
                        end
                    end
                end
            end
        end

        produceLog(itemsLog)

        self.status = 0

        if #self.items > 0 then
            self.status = 1
        end

        for idx,material in pairs(allMaterial) do
            for _, itemId in pairs(bestMixerCfg.sortList[idx]) do
                if material[itemId] and material[itemId] >= bestMixerCfg.main.mergeRate then
                    self.status = 1
                    return
                end
            end
        end
    end

    function self.getAllAmixerData()
        local db = getDbo()
        local weets = getWeeTs()
        -- TODO TEST
        -- local sql = string.format("select aid from amixer",weets)

        local sql = string.format("select aid from amixer where aid > 0 and ptime < %d and status = 1",weets)
        return db:getAllRows(sql)
    end

    function self.setItemLog(log)
        log.aid = self.aid
        log.updated_at = os.time()
        getDbo():insert("amixerlog",log)
    end

    function self.getItemLog(aid)
        local sql = string.format("select * from amixerlog where aid = %d order by updated_at desc limit 30",aid)
        local result = getDbo():getAllRows(sql)
        local log = {}
        for k,v in pairs(result) do
            table.insert(log,{tonumber(v.updated_at),tonumber(v.type),v.content})
        end
        return log
    end

    function self.save()
        return self._save()
    end

    return self
end

return model_amixer