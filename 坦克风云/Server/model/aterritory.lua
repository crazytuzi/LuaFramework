-- 军团公海领地
local function model_aterritory(self)
    -- 固定写法 ------------
    local private = {
        dbData={ -- 初始化的数据
            aid=0,
            mapx=-1,
            mapy=-1,
            status=0,--基地挂起状态
            level = 0,-- 领地等级
            b1 = {lv=0}, --主基地   lv:等级 hp:耐久度
            b2 = {lv=0}, --仓库
            b3 = {lv=0}, --控制台
            b4 = {lv=0,q=1}, --铀矿  q品质
            b5 = {lv=0,q=1}, --天然气
            b6 = {lv=0}, --炮台1
            b7 = {lv=0}, --炮台2
            b8 = {lv=0}, --炮台3
            b9 = {lv=0}, --炮台4
            r1 = 0, --铁
            r2 = 0, --铝
            r3 = 0, --钛
            r4 = 0, --石油
            r6 = 0, --铀
            r7 = 0, --天然气
            score = 0,  --积分
            dev_point= 10000,-- 发展值
            power =  0,  --控制台能量
            daypower = 0,--每日获得能量值
            killcount =  0, --击杀海盗
            kill_at = 0 ,--击杀海盗重置时间标识
            bqueue={},--建造队列
            task = {tk={},upt=0,l={},rn=0}, --军团任务 更新时间 可选发布列表  军团长刷新次数
            minerefresh = {n=0,t=0,qr=0}, --特殊矿刷新 n当天已经刷新的次数 t上次刷新的时间 是否军团长确认发布
            mt = 0 , --领地迁移时间
            ct = 0 ,-- 领地创建时间
            warscore = 0, -- 领海战积分
            warstatus = 0, -- 2是失败
            war_at = 0, -- 上次领海战的时间
            apply = 0, -- 报名标识1是报名
            apply_at = 0, -- 报名时间
            main_power = 0, -- 维护所需要的控制台能量
            main_point= 10000, -- 维护时的发展值
            maintained_at = 0, -- 维护时间(每天维护一次)
            updated_at=0,
        },
        pkName = "aid", -- 主键名
        tableName = "territory", -- 表名
    }

    self._initPrivate(private)

    -- ----------------

    -- 领地地图类型
    local MAPTYPE = 9

    -- 领地的各种状态
    local TERRITORYSTATUS = {
        LOCKED=0, -- 锁定(挂起)
        NORMAL=1, -- 正常
        DESTROY=2, -- 已被摧毁
    }

    function self.init()
        self.checkbqueue()
        self.resetWarData()
    end

    function self.toArray()
        return self._getData()
    end

    -- 检测是否有未处理的建造队列
    function self.checkbqueue()
        if type(self.bqueue) == 'table' then
            local ts = getClientTs()
            for i=#self.bqueue,1,-1 do
                if type(self.bqueue[i])=='table' and type(self.bqueue[i].id) ~= nil then
                    local et = tonumber(self.bqueue[i].et) or 0
                    -- 多加30秒处理
                    if et > 0 and et + 30 <= ts then
                        local cronParams = {cmd="territory.ckbqueue",params={aid=self.aid}}
                        setGameCron(cronParams, 1)
                    end
                end
            end
        end
    end

    -- 更新建造队列
    function self.update()
        local updata = {}
        if type(self.bqueue) == 'table' then
            local ts = os.time()
            for i=#self.bqueue,1,-1 do
                if type(self.bqueue[i])=='table' and type(self.bqueue[i].id) ~= nil then
                    local et = tonumber(self.bqueue[i].et) or 0
                    if et > 0 and et <= ts then
                        local id = self.bqueue[i].id
                        self.openSlot(i)
                        local uplv = self.levelUp(id)

                        table.insert(updata,{bid=id,lv=uplv})
                         -- 特殊矿等级等于控制台等级
                        if id=='b3' then
                            self.b4.lv = self.b3.lv
                            self.b5.lv = self.b3.lv

                            table.insert(updata,{bid="b4",lv=uplv})
                            table.insert(updata,{bid="b5",lv=uplv})
                        end
                        -- 领地等级=主基地等级
                        if id=='b1' then
                            self.level = self.b1.lv
                        end
                    end
                else
                    table.remove(self.bqueue,i)
                end
            end
        end

        return updata
    end

    -- 格式化数据
    function self.formatedata()
        local formdata = {
            buildings={},
        }
        local property = self.toArray()
        local allianceBuidCfg = getConfig('allianceBuid')

        for k,v in pairs(allianceBuidCfg.btype) do
            formdata.buildings[k] = property[k]
            formdata.buildings[k].type = v
        end

        for k,v in pairs(property) do
            if not allianceBuidCfg.btype[k] then
                 formdata[k] = v
            end
        end 

        return formdata
    end

    --  建筑升级
    function self.levelUp(bid)
        if self[bid] then
            self[bid].lv = (self[bid].lv or 0) + 1

            if bid=='b1' then
                self.level = self.b1.lv
            end

            return self[bid].lv
        end
    end

    -- 结束队列
    function self.openSlot(slotName) 
        if self.bqueue[slotName] then
            table.remove(self.bqueue,slotName)
            return true
        end
        return false
    end

    -- 获取建筑等级
    function self.getLevel(bid)
        return type(self[bid]) == 'table' and self[bid].lv or 0
    end

    -- 获取主基地的的等级
    function self.getMainLevel()
        return self.getLevel('b1')
    end

    function self.mainLevelUp()
        return self.levelUp("b1")
    end

    -- 建筑是否解锁
    function self.buildingIsUnlock(bid)
        local baseLevel = self.getMainLevel()
        -- local cfg = getConfig("homeCfg")
        -- 需要配置
        local isUnlock = false

        --return isUnlock and cfg.pIndexArrayByLevel[bid] <= baseLevel
        return true
    end

    -- 使用队列
    function self.useSlot(slotInfo)
        assert2(not self.checkIdInSlots(slotInfo.id),'Being upgraded')
        local slot = self.getOpenSlot()

        if slot then
            for k,v in pairs (slotInfo) do
                  slot[k] = v
            end

            table.insert(self.bqueue,slot)
            return true
        end

        return false
    end

    -- 验证当前bid是否在队列中
    function self.checkIdInSlots(bid)
        for k,v in pairs(self.bqueue) do
            if v.id == bid then return k end
        end
        return false
    end

    -- 创建队列
    function self.getOpenSlot()
        local slotNums = 2 -- 建造队列数需要在配置文件中配置
        local curSlotNums = table.length(self.bqueue)    
        assert2(curSlotNums < slotNums,'no open slot')

        local newSlot = {}
        newSlot.slotid = self.getSlotId()

        return newSlot
    end

    -- 生成slot的唯一标识
    function self.getSlotId()
        if type(self.bqueue) == 'table' then
            local ids = {}

            for k,v in pairs(self.bqueue) do
                ids[v.slotid] = 1
            end

            for i=1,100 do 
                if not ids[i] then return i end
            end
        end

        return 1
    end

    --是否队列已满
    function self.isSlotFull()
        local iSlotNums = 2 -- 建造队列数需要在配置文件中配置
        local iCurrSlotNums = table.length(self.bqueue)
        return iCurrSlotNums >= iSlotNums
    end

    -- 增加资源
    function self.addR1(r)
        self.r1 = self.r1 + r
    end

    -- 增加资源
    -- resources 资源table
    -- checkCapacity 是否检测容量
    function self.addResource(resources,checkCapacity,maxResource)
        if type(resources) == 'table' then
            for k,v in pairs(resources) do
                 v = tonumber(v) or 0
                 local keys = k:split('_')
                 if #keys>=2 then
                    if self[keys[2]] and v > 0 then
                         v = math.floor(v)
                        self[keys[2]] = self[keys[2]] + v
                    end
                 else
                    if self[k] and v > 0 then
                        v = math.floor(v)
                        self[k] = self[k] + v
                    end

                 end
            end

            -- 当前仓库等级 取基础资源上限值  超上限就不加
            local lv = self.b2.lv==0 and 1 or self.b2.lv
            local reslimit = {
                r1="storageSteel",
                r2="storageAl",
                r3="storageTi",
                r4="storageOil",
                r6="storageUr",
                r7="storageGas",
            }

            local allianceBuildCfg = getConfig("allianceBuid")
            for k,v in pairs(reslimit) do
                if self[k]>allianceBuildCfg.buildValue[2][v][lv] then
                    self[k] = allianceBuildCfg.buildValue[2][v][lv]
                end
            end

            return true
        end
    end

    -- 获取仓库总存量
    -- storageSteel:钢铁储存,storageSteel:铝矿储存,storageTi:钛矿储存,storageOil:石油储存,storageUr:铀储存,storageGas:天然气储存
    function self.getStorageCapacity(resource)
        local capacity = 0

        local keys = {
            r1="storageSteel",
            r2="storageAl",
            r3="storageTi",
            r4="storageOil",
            r6="storageUr",
            r7="storageGas",
        }

        local buildType = 2
        local allianceBuildCfg = getConfig("allianceBuid")

        for bid,btype in pairs(allianceBuildCfg.btype) do
            if btype == buildType then
                local lv = self.getLevel(bid)
                if lv > 0 then
                    if resource then
                        capacity = capacity + allianceBuildCfg.buildValue[buildType][keys[resource]][lv]
                    else
                        for _,key in pairs(keys) do
                            capacity = capacity + allianceBuildCfg.buildValue[buildType][key][lv]
                        end
                    end
                end
            end
        end
            
        return capacity
    end

    -- 消耗资源  如果有涉及到军团资金 要再判断
    function self.useResource(resources)
        if self.checkResource(resources) then
            for k,v in pairs (resources) do
                -- if k == 'gems' then
                --     local oldGems = self.gems
                --     self[k] = self[k] - math.floor(math.abs(tonumber(v) or 0))
                --     self.validateGems(oldGems,self.gems)
                -- else
                --     self[k] = self[k] - math.floor(math.abs(tonumber(v) or 0))
                -- end

                self[k] = self[k] - math.floor(math.abs(tonumber(v) or 0))

                if self[k] < 0 then self[k] = 0 end
            end
            return true
        end        
    end

    -- 判断资源 当前没有金币判断哦
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

    -- 根据中心坐标获取领地的地图信息,顺序是按b1-b9
    -- param x int 中心坐标x
    -- param y int 中心坐标y
    function self.getTerritoryMapByPos(x,y)
        local mapIds = {}
        -- local mapPos = {
        --     {-1,-1},{0,-1},{1,-1},
        --     {-1,0},{0,0},{1,0},
        --     {-1,1},{0,1},{1,1},
        -- }
        -- b1-b9
        -- local mapPos = {
        --     {0,0},{1,0},{-1,0},{0,-1},{0,1},{-1,-1},{1,-1},{-1,1},{1,1}
        -- }

        local allianceBuildCfg = getConfig("allianceBuid")
        local mapPos = copyTable(allianceBuildCfg.buildPos)
        
        for i=1,#mapPos do
            mapPos[i][1] = mapPos[i][1] + x
            mapPos[i][2] = mapPos[i][2] + y
            mapIds[i] = getMidByPos(mapPos[i][1],mapPos[i][2])
        end

        return mapPos,mapIds
    end

    -- 对领地的所有地块加锁
    -- 如果基中一个地块加锁失败,需要把已加锁的地块解锁
    -- param mapIds 领地占领的地图ID
    function self.territoryMapLock(mapIds)
        local lockedId = {}
        for k,v in pairs(mapIds) do
            if not commonLock(tostring(v),"maplock") then
                break
            end

            table.insert(lockedId,v)
        end

        if #lockedId ~= #mapIds then
            self.territoryMapUnlock(lockedId)
            lockedId = nil
            return false
        end
        
        return true
    end

    -- 解锁领地占用的地块
    function self.territoryMapUnlock(mapIds)
        for _,n in pairs(mapIds) do
            commonUnlock(tostring(n),"maplock")
        end
    end

    -- 获取领地占用的地图数据
    -- param table 地图id
    function self.getTerritoryMapData(mapIds)
        local db = getDbo()
        local idWhere = table.concat(mapIds,",")
        local result = db:getAllRows(string.format("select id,type,level,exp,oid,name,x,y from map where type > 0 and id in (%s)",idWhere))

        return result
    end

    function self.getMinimapCacheKey()
        return string.format("z%s.territory.minimap",getZoneId())
    end

    function self.formatMinimapKey(x,y)
        return string.format("%s,%s",x,y)
    end

    --[[
        小地图增加领地数据,客户端显示时按排行榜的顺序来显示
        小地图只会存放出现在排行榜中的军团领地坐标

        param int x 坐标 
        param int y
        param int ranking 在排行榜中的排名
    ]]
    function self.addMinimap(x,y,ranking)
        if tonumber(x) > 0 and tonumber(y) > 0 then
            local cacheKey = self.getMinimapCacheKey()
            local redis = getRedis()
            redis:zadd(cacheKey,ranking,self.formatMinimapKey(x,y))
        end
    end

    -- 删除小地图数据
    function self.delMinimap(x,y)
        if x and y then
            return getRedis():zrem(self.getMinimapCacheKey(),self.formatMinimapKey(x,y))
        else
            return getRedis():del(self.getMinimapCacheKey())
        end
    end

    -- 按给定的区间获取小地图数据
    function self.getMinimapDataByRange(start,stop)
        local cacheKey = self.getMinimapCacheKey()
        return getRedis():zrange(cacheKey,start,stop)
    end

    -- 按给定的坐标攻取小地图数据
    function self.getMinimapDataByPos(x,y)
        return getRedis():zscore(self.getMinimapCacheKey(),self.formatMinimapKey(x,y))
    end

    -- 更新领地在小地图中的数据
    function self.updateMinimapData(x1,y1,x2,y2)
        local ranking = self.getMinimapDataByPos(x1,y1)
        if ranking then
            self.delMinimap(x1,y1)
            if x2 > 0 and y2 > 0 then
                self.addMinimap(x2,y2,ranking)
            end
        end
    end

    -- 设置领地中心坐标
    function self.setPos(x,y)
        if x ~= self.mapx or y ~= self.mapy then
            self.updateMinimapData(self.mapx,self.mapy,x,y)
            self.mapx = x
            self.mapy = y
        end
    end

    -- 获取领地中心坐标
    function self.getPos()
        if self.mapx ~= -1 and self.mapy ~= -1 then
            return {self.mapx,self.mapy}
        end
    end

    --[[
        生成地图的类型和等级标识
        param int mapType 地图类型
        param int mapLevel 地图等级
        return int
    ]]
    function self.buildTypeAndLevelNum(mapType,mapLevel)
        if mapType < 6 then
            return bit32.bor(mapType,bit32.lshift(mapLevel,3))
        end
    end

    -- 解析地图的类型和等级
    function self.parseTypeAndLevelNum(num)
        return bit32.band(num,7),bit32.rshift(num,3)
    end

    --[[
        获取指定资源建筑的资源生产速度(采集用)
        速度与建筑的品质和等级及采集时的时间(判断是否处于双倍内和减半时间)有关

        param int bid 建筑id
        return int 采集速度
    ]]
    function self.getResourceProduceSpeed(bid)
        local allianceBuildCfg = getConfig("allianceBuid")
        local mineType = allianceBuildCfg.btype[bid]
        local mineQuality = self[bid].q
        local mineLevel = self.getLevel(bid)
        
        local speed = allianceBuildCfg.buildValue[mineType][mineQuality][mineLevel]
        if self.isDoubleCollectTime() then
            speed = speed * 2
        elseif self.isLossCollectTime() then
            speed = speed * 0.5
        end

        local per = self.getDevelopmentRatio()
        if per > 0 then
            speed = speed * per
        end

        return speed
    end

    -- 获取地块产出的资源名
    function self.getResourceNameByBid(bid)
        local t = {
            b4="r6",
            b5="r7",
        }
        return t[bid]
    end

    -- 判断地块是否是资源岛
    function self.isResourceIsland(bid)
        return self.getResourceNameByBid(bid) and true or false
    end

    -- 获取领地发展比
    function self.getDevelopmentRatio(point)
        local allianceCityCfg = getConfig("allianceCity")
        local per = (point or self.dev_point)/allianceCityCfg.Prosperous

        if per > 1 then 
            per = 1
        elseif per < 0 then
            per = 0
        end

        return per
    end

    --[[
        判断给定坐标是否位于领地的buff区域
        praam int x
        param int y
        return bool
    ]]
    function self.inTerritoryBuffArea(x,y)
        if x and y then
            local mainLevel = self.getMainLevel()
            local allianceBuildCfg = getConfig("allianceBuid")
            local buildType = allianceBuildCfg.btype.b1
            local rangeVal = allianceBuildCfg.buildValue[buildType].range[mainLevel]
            if rangeVal then
                rangeVal = rangeVal / 2
                return (math.abs(x-self.mapx) < rangeVal) and (math.abs(y-self.mapy) < rangeVal)
            end
        end
    end

    --[[
        获取军团领地区域提供的BUFF
        return table
            ["dmg"] = 0.2,
            ["maxhp"] = 0.2,
    ]]
    function self.getTerritoryAreaBuff(x,y)
        if self.isNormal() and self.inTerritoryBuffArea(x,y) then
            local allianceCityCfg = getConfig("allianceCity")
            local per = self.getDevelopmentRatio()
            if per > 0 then
                return {dmg=allianceCityCfg.areaBuff[1]*per},allianceCityCfg.areaBuff[2]*per
            end
        end
    end

    --[[
        获取军团领地建筑提供的BUFF
        return table：
            ["dmg"] = 0.004,
            ["evade"] = 0.0025,
            ["accuracy"] = 0.0025,
            ["maxhp"] = 0.004,
    ]]
    function self.getTerritoryBuildBuff()
        if not self.isEmpty() then
            local buff = {}

            local buffKeys = {
                buff1 = {"dmg","maxhp"},
                buff3 = {"evade","accuracy"},
            }

            local per = self.getDevelopmentRatio()
            if per > 0 then
                local allianceBuildCfg = getConfig("allianceBuid")
                for k,v in pairs(allianceBuildCfg.btype) do
                    if allianceBuildCfg.buildValue[v] then
                        for buffKey,buffVal in pairs(buffKeys) do
                            if allianceBuildCfg.buildValue[v][buffKey] then
                                local lv = self.getLevel(k)
                                if allianceBuildCfg.buildValue[v][buffKey][lv] then
                                    for m,attribute in pairs(buffVal) do
                                        buff[attribute] = (buff[attribute] or 0) + allianceBuildCfg.buildValue[v][buffKey][lv][m] * per
                                    end
                                end
                            end
                        end
                    end
                end

                return buff
            end
        end
    end

    --[[
        获取载重BUFF
        return int
    ]]
    function self.getTerritoryCapacityBuff()
        if not self.isEmpty() then
            local per = self.getDevelopmentRatio()
            if per > 0 then
                local buffKey= "buff2"
                local allianceBuildCfg = getConfig("allianceBuid")
                for k,v in pairs(allianceBuildCfg.btype) do
                    if allianceBuildCfg.buildValue[v] and allianceBuildCfg.buildValue[v][buffKey] then
                        local lv = self.getLevel(k)
                        if allianceBuildCfg.buildValue[v][buffKey][lv] then
                            return allianceBuildCfg.buildValue[v][buffKey][lv] * per
                        end
                    end
                end
            end
        end
    end

    --[[
        更新领地地图的建筑等级

        param string bid 建筑标
        param table data key-value 地图中对应的字段和值
        return bool
    ]]
    function self.updateTerritoryMap(bid,data)
        if self.getPos() then
            local territoryPos,territoryMapIds = self.getTerritoryMapByPos(self.mapx,self.mapy)
            local id = tonumber(string.sub(bid, 2))
            local mid = territoryMapIds[id]
        
            if mid then
                local p = {
                    boom_ts=os.time(),
                    type=MAPTYPE,
                    oid=self.aid
                }

                for k,v in pairs(data) do
                    p[k] = v
                end

                local mMap = require 'lib.map'
                return mMap:update(mid,p,{"type","oid"})
            end
        end

        return true
    end

    function self.updateTerritoryMapLevel(bid,level)
        return self.updateTerritoryMap(bid,{level=level})
    end

    -- 更新军团名字
    function self.updateAllianceName(name)
        -- return self.updateTerritoryMap("b1",{alliance=name})

        if self.getPos() then
            local territoryPos,territoryMapIds = self.getTerritoryMapByPos(self.mapx,self.mapy)
            if type(territoryMapIds) == "table" then
                local mapData = self.getTerritoryMapData(territoryMapIds)
                if type(mapData) == "table" then
                    local db = getDbo()
                    db.conn:setautocommit(false)

                    local mMap = require 'lib.map'
                    for k,v in pairs(mapData) do
                        if tonumber(v.type) == MAPTYPE and tonumber(v.oid) == self.aid then
                            if not mMap:update(tonumber(v.id),{alliance=name}) then
                                db.conn:rollback()
                                return false
                            end
                        end
                    end
                    
                    if db.conn:commit() then
                        return true
                    end
                end
            end
        end

        return true
    end

    -- 领地建筑升级的广播(世界地图有显示)
    function self.upgradeBroadcast(bid,level)
        local territoryPos = self.getTerritoryMapByPos(self.mapx,self.mapy)
        local id = tonumber(string.sub(bid, 2))
        local data = {{MAPTYPE,bid,"",level,territoryPos[id][1],territoryPos[id][2],self.aid}}

        -- 客户端需求,如果是b2升级的话需要把b3的信息给推给客户端
        if bid == "b2" then
            table.insert(data,{MAPTYPE,"b3","",self.getLevel("b3"),territoryPos[3][1],territoryPos[3][2],self.aid})
        end

        local msg = {
            content = {
                params=data,
                ts = getClientTs(),
                contentType = 4,
                type=152,
            },
            type = "chat",
        }
        sendMessage(msg)
    end

    -- 领地挂起的广播(世界地图有显示)
    function self.territoryLockBroadcast(x,y)
        local territoryPos = self.getTerritoryMapByPos(x or self.mapx,y or self.mapy)
        if territoryPos then
            local msg = {
                content = {
                    params=territoryPos,
                    ts = getClientTs(),
                    contentType = 4,
                    type=153,
                },
                type = "chat",
            }
            sendMessage(msg)
        end
    end

    --[[
        在世界地图上创建领地
        
        param table mapIds 占用的所有地块ID
        param table mapPos 占用的所有地块坐标
        param string allianceName 军团名
        param table 占用的矿点数据信息(类型和等级)
        return table 领地的详细数据
    ]]
    function self.createTerritory(mapIds,mapPos,allianceName,resultMine)
        local territoryMapInfo = {}
        local values = {
            name=0, -- 记录建筑标识b1-b9
            exp=0, -- 存放原矿的类型和等级
            oid=self.aid, -- 军团id
            type=MAPTYPE, -- 地块类型
            level=0, -- 地块对应的建筑的等级
            alliance=allianceName, -- 军团名
        }

        -- 创建后主基地要为1级
        if self.getMainLevel() == 0 then
            self.mainLevelUp()
        end

        local db = getDbo()
        for k,v in pairs(mapIds) do
            local bid = "b" .. tostring(k)
            values.id = v
            values.level = self.getLevel(bid)
            values.name = bid
            values.exp = resultMine[v] or 0
            
            local n = db:update("map",values,{"id"})
            if not n or n < 1 then
                return false
            end

            -- 类型,建筑标识,军团名,建筑等级,x坐标,y坐标,军团id
            table.insert(territoryMapInfo,{values.type,values.name,values.alliance,values.level,mapPos[k][1],mapPos[k][2],self.aid})
        end

        -- 设置领地主城坐标及状态
        local baseBid = 1 -- b1
        self.setPos(mapPos[baseBid][1],mapPos[baseBid][2])
        self.status = TERRITORYSTATUS.NORMAL

        -- 设置创建时间和搬迁时间
        local ts = getClientTs()
        self.mt = ts
        if self.ct == 0 then
            self.ct = ts
        end

        return territoryMapInfo
    end

    --[[ 
        清除领地地图数据
        领地占领的所有地图数据中有可能有被毁掉的矿(该矿的exp字段记录),在清理后需要进行还原

        param table mapData 领地占有的所有详细地块数据
        return table 本次还原的矿信息
    ]]
    function self.clearTerritoryMap(mapData)
        -- 记录本次在清理领地地图的基础上还原的矿(需要广播给世界)
        local originalMine = {}

        if type(mapData) == "table" then
            local mMap = require 'lib.map'
            local field = mMap:getFormatField()

            for k,v in pairs(mapData) do
                if tonumber(v.type) == MAPTYPE and tonumber(v.oid) == self.aid then
                    local flag = false

                    -- exp记录了该矿原始信息,需要进行还原
                    if tonumber(v.exp) > 0 then
                        local oldType,oldLevel = self.parseTypeAndLevelNum(tonumber(v.exp))
                        if (oldType > 0 and oldType < 5) and (oldLevel <= 30) then
                            local p = copyTable(field)
                            p.type = oldType
                            p.level = oldLevel

                            if not mMap:update(tonumber(v.id),p) then
                                return false
                            end

                            table.insert(originalMine,{tonumber(v.id),tonumber(v.x),tonumber(v.y),oldType,oldLevel})
                            flag = true
                        end
                    end

                    if not flag then
                        if not mMap:update(tonumber(v.id),field) then
                            return false
                        end
                    end
                end
            end
        end

        return originalMine
    end

    -- 领地采集的部队返回
    -- 注册了一个3秒后执行的API来处理
    function self.territoryFleetBack(aid)
        local cronParams = {cmd ="territory.set.fleetBack",params={aid=self.aid},uid=self.aid}
        setGameCron(cronParams,3)
    end

    -- 迁城冷却(不能在短时间内多次迁城)
    function self.moveCollDown()
        return getClientTs() - self.mt > getConfig('allianceCity').moveTime
    end

    -- 是否是空(没有加载到领地数据)
    function self.isEmpty()
        return self._isEmpty()
    end

    -- 是否已被挂起
    function self.isLocked()
        return self.status == TERRITORYSTATUS.LOCKED
    end

    -- 是否已被摧毁(收回)
    function self.isDestroy()
        return self.status == TERRITORYSTATUS.DESTROY
    end

    -- 是否正常
    function self.isNormal()
        return self.status == TERRITORYSTATUS.NORMAL
    end

    -- 领地锁定(挂起)
    function self.lock()
        if self.status ~= TERRITORYSTATUS.LOCKED then
            self.status = TERRITORYSTATUS.LOCKED
            local oldPos = self.getPos()
            if oldPos then
                local oldTerritoryPos,oldTerritoryMapIds = self.getTerritoryMapByPos(oldPos[1],oldPos[2])
                local oldMapData = self.getTerritoryMapData(oldTerritoryMapIds)
                
                if not self.clearTerritoryMap(oldMapData) then
                    return false
                end

                self.setPos(-1,-1)
            end

            -- 领地部队返回
            self.territoryFleetBack()
            self.mailNotify(70)

            -- 如果已经报名领海战
            if self.checkApplyOfWar() then
                self.apply = 0
                self.apply_at = 0

                -- 由于领地挂起，你的军团报名被取消 
                self.mailNotify(73)
            end

            return true
        end
    end

    -- 领地解锁
    function self.unlock()
        self.status = TERRITORYSTATUS.NORMAL
    end

    function self.saveData()
        return self._save()
    end

    --  增加能量值
    function self.addPower(num)
        local abCfg = getConfig('allianceBuid')

        local lv = 1
        if self.b3.lv>1 then
            lv = self.b3.lv
        end

        local powerlimit =  abCfg.buildValue[3].energyLimit[lv]
        self.power = self.power + num
        self.daypower = self.daypower + num
        if self.power > powerlimit then
            self.power = powerlimit
        end
        return true
    end

    -- 扣除能量
    function self.subPower(num)
        assert(num > 0,"invalid num:" .. tostring(num))
        if self.power >= num then
            self.power = self.power - num
            return true
        end
    end

     -- 获得击杀海盗数量前10
    function self.killlist()
        local list = {}
        -- 判断是否是新一周的数据
         if not self.isNormal() then return list end

        local ts= getClientTs()
        local weeTs = getWeeTs()
        local allianceBuidCfg = getConfig('allianceCity')

        local weekday=tonumber(getDateByTimeZone(ts,"%w"))
        if weekday == 0 then weekday =7  end

        -- 以上周结束时为标识
        local lastInit = weeTs-(weekday-1)*86400-2*3600
        if weekday ==7 and ts>weeTs + 22*3600 then
            lastInit = weeTs + 22*3600
        end
        local redis = getRedis()
        local key = "z"..getZoneId()..".territory.acrank"..lastInit
        local result = redis:get(key)
   
        --result = {}--TODO
        if type(result) == "table" and next(result) then
            list=result
        else
            local db = getDbo()
            local result = db:getAllRows(string.format("select aid,killcount from territory where kill_at="..lastInit.." and killcount>0 order by killcount desc limit 10"))
            if type(result)=='table' and next(result) then
                local aidlist = {}
                for k,v in pairs(result) do
                    table.insert(aidlist,v.aid)
                end


               local setRet,code=M_alliance.getalliancesname{aids=json.encode(aidlist)}
               if type(setRet['data'])=='table' and next(setRet['data']) then
                    local tmp = {}
                    for k,v in pairs(setRet['data']) do
                        tmp[v.aid] = v.name
                    end
                    local i = 1
                    for k,v in pairs(result) do
                         table.insert(list,{i,v.aid,tmp[v.aid],v.killcount})
                         i=i+1
                    end
                    redis:set(key,json.encode(list))
                    redis:expireat(key,lastInit+7*86400)                
                end
            end

            --没有就是空列表
        end

        return list
    end

    -- 摧毁军团领地
    -- 发展值为0/军团解散
    function self.destroy()
        self.status = TERRITORYSTATUS.DESTROY
        self.setPos(-1,-1)
        self._delCache()
        local db = getDbo()
        local ret = db:query(string.format("delete from %s where aid = '%d' limit 1",private.tableName,db:escape(self.aid)))
        if ret and ret > 0 then
            self.mailNotify(71)
            return ture
        end
    end

    -- 邮件通知军团全体成员
    function self.mailNotify(mailType)
        local execRet, code = M_alliance.getMemberList{aid=self.aid}
        if execRet and execRet.data and execRet.data.members then
            local content = json.encode({type=mailType})
            for k,v in pairs(execRet.data.members) do
                local uid = tonumber(v.uid) or 0
                if uid > 0 then
                    MAIL:mailSent(uid,1,uid,'','',mailType,content,1,0)
                end
            end
        end
    end

    -- 扣除发展值
    function self.subDevPoint(point)
        if self.dev_point > 0 or self.isNormal() then
            self.dev_point = self.dev_point - point

            if self.dev_point < 0 then
                self.dev_point = 0
            end

            local allianceCityCfg = getConfig("allianceCity")
            if self.dev_point > 0 and self.dev_point < allianceCityCfg.cityStopValue then
                self.lock()
            elseif self.dev_point <= allianceCityCfg.cityDown then
                self.destroy()
            end
        end 
    end     

    -- 增加发展值
    function self.addDevPoint(point)
        self.dev_point = self.dev_point + point

        local allianceCityCfg = getConfig("allianceCity")
        if self.dev_point > allianceCityCfg.Prosperous then
            self.dev_point = allianceCityCfg.Prosperous
        end

        if self.dev_point >= allianceCityCfg.cityStopValue then
            self.unlock()
        end

        return self.dev_point
    end

    -- 恢复发展值
    function self.recoveryDevPoint()
        self.addDevPoint(getConfig('allianceCity').Prosperous)
    end

    function self.getDevPoint()
        return self.dev_point
    end

    -- 获取未维护的所有军团领地的aid集合
    function self.getUnmaintainedAids()
        local db = getDbo()
        local ts = getWeeTs() + 7200 -- 时间戳用凌晨2点的,避免冬夏令时切换带来的问题
        local sql = string.format("select aid from %s where maintained_at < :ts limit 1000",private.tableName)
        return db:getAllRows(sql,{ts=ts})
    end

    -- 刷新特殊矿品质 -- 注：维护 定时脚本中需要调用该方法
    function self.randmine()
        local cfg = getConfig('allianceBuid')
        local lv = 1
        if self.b3.lv > 0 then 
            lv = self.b3.lv
        else
            self.b4.q =1
            self.b5.q =1
            return true
        end
        local r1 = randVal(cfg.buildValue[3].rand[lv])
        self.b4.q =  cfg.buildValue[3].mineQuality[lv][r1]
        local r2 = randVal(cfg.buildValue[3].rand[lv])
        self.b5.q = cfg.buildValue[3].mineQuality[lv][r2]

        self.minerefresh.qr = 0 -- 是否确认刷新的矿品质
        writeLog('刷新了矿的品质aid='..self.aid..'b4='..self.b4.q..'b5='..self.b5.q,'territory')

        return true
    end

    -- 军团长确认刷新矿品质
    function self.setmine()
        self.minerefresh.qr = 1
        return true
    end

    -- 领地是否处于维护时间段内
    function self.maintenance()
        local ts= getClientTs()
        local weeTs = getWeeTs()

        local allianceCityCfg = getConfig('allianceCity') 
        local st = allianceCityCfg.mainTime[1][1]*3600 + allianceCityCfg.mainTime[1][2]*60
        local et= allianceCityCfg.mainTime[2][1]*3600 + allianceCityCfg.mainTime[2][2]*60

        if ts>=weeTs+st and ts<=weeTs+et then
            return true
        end

        return false
    end

    -- 时间点是否是锁定采集时间
    function self.isLockCollectTime(ts)
        if not ts then ts = getClientTs() end
        local weeTs = getWeeTs(ts)

        local allianceCityCfg = getConfig('allianceCity')

        local st = weeTs + allianceCityCfg.lockCollect[1][1]*3600 + allianceCityCfg.lockCollect[1][2]*60
        local et= weeTs + allianceCityCfg.lockCollect[2][1]*3600 + allianceCityCfg.lockCollect[2][2]*60

        if ts>=st and ts<=et then
            if ts> allianceCityCfg.mainTime[2][1]*3600 + allianceCityCfg.mainTime[2][2]*60 and  self.minerefresh.qr == 1 then
                --不在维护时间内 如果军团长在锁定时间内提前确定矿品质 则可以采集
                return false
            end
            return true
        end
    end

    -- 时间点是否是加倍时间
    function self.isDoubleCollectTime(ts)
        if not ts then ts = getClientTs() end
        local weeTs = getWeeTs(ts)
        local allianceCityCfg = getConfig('allianceCity') 
        for k,v in pairs(allianceCityCfg.doubleCollect) do
            local st = weeTs + v[1][1]*3600 + v[1][2]*60
            local et = weeTs + v[2][1]*3600 + v[2][2]*60

            if ts >= st and ts <= et then
                return true
            end
        end
    end

    -- 时间点是否是减半时间
    function self.isLossCollectTime(ts)
        if not ts then ts = getClientTs() end
        local weeTs = getWeeTs(ts)
        local allianceCityCfg = getConfig('allianceCity') 
        local st = weeTs + allianceCityCfg.lossCollect[1][1]*3600 + allianceCityCfg.lossCollect[1][2]*60
        local et = weeTs + allianceCityCfg.lossCollect[2][1]*3600 + allianceCityCfg.lossCollect[2][2]*60

        if ts >= st and ts <= et then
            return true
        end
    end

    function self.setMaintenanceValues()
        local allianceCityCfg = getConfig("allianceCity")
        local allianceBuildCfg = getConfig("allianceBuid")

        -- 令天需要消耗的能量(配置)
        local energyCost = 0
        for bid,btype in pairs(allianceBuildCfg.btype) do
            if allianceBuildCfg.buildValue[btype] and allianceBuildCfg.buildValue[btype].energyCost then
                local lv = self.getLevel(bid)
                energyCost = energyCost + (allianceBuildCfg.buildValue[btype].energyCost[lv] or 0)
            end
        end

        -- 现在的繁荣度百分比
        local prosperousPer = self.getDevelopmentRatio()
        local intervalValue = 0
        for k,v in pairs(allianceCityCfg.Interval) do
            if prosperousPer <= v[1] and prosperousPer >= v[2] then
                intervalValue = allianceCityCfg.IntervalValue[k]
                break
            end 
        end

        -- 今天需要消耗的实际能量受现在的繁荣度百分比影响
        self.main_power = math.floor(energyCost * intervalValue)
        self.main_point = self.dev_point

        -- print(self.power,energyCost,intervalValue,energyCost * intervalValue)
    end

    -- 获取维护消耗
    function self.getMaintenanceCost()
        local allianceCityCfg = getConfig("allianceCity")

        -- 今天损失的能量百分比=1-今天得到的能量/昨天需要消耗的能量
        local energyPer = 0
        if self.main_power > 0 then
            energyPer = 1 - self.daypower/self.main_power
            if energyPer < 0 then energyPer = 0 end
        end

        local proIntervalValue = 0
        local prosperousPer = self.getDevelopmentRatio(self.main_point)
        for k,v in pairs(allianceCityCfg.proInterval) do
            if prosperousPer <= v[1] and prosperousPer >= v[2] then
                proIntervalValue = allianceCityCfg.proIntervalValue[k]
                break
            end 
        end

        -- 今天损失的能量百分比=1-今天得到的能量/今天需要消耗的能量///////////////今天的繁荣度=昨天的繁荣度百分比-今天损失的能量百分比*昨天区间的系数
        local cost = self.main_point - ( prosperousPer - energyPer * proIntervalValue ) * allianceCityCfg.Prosperous
        cost = math.ceil(cost)

        if cost < 0 then
            cost = 0
        end

        return cost
    end

    -- 获取恢复消耗
    -- 维护幂系数(1-当前百分比)*mainValue * ( 等级 ^ Value )math.pow
    -- param int costType 1是钻石消耗,2是资金消耗
    function self.getRecoveryCost(costType)
        local allianceCityCfg = getConfig("allianceCity")
        if self.dev_point >= allianceCityCfg.cityStopValue and not self.getPos() then
            return 0
        end

        local developPer = (allianceCityCfg.Prosperous-self.dev_point)/allianceCityCfg.Prosperous
        local mainLevel = self.getMainLevel()
        local cost = developPer * allianceCityCfg.mainValue *  math.pow(mainLevel,allianceCityCfg.Value)
        cost = math.ceil(cost)
        
        if costType == 2 then
            cost = cost * allianceCityCfg.recoveryCost
        end

        return cost
    end

    -- 获取搬家的消耗
    function self.getMoveCost()
        local allianceCityCfg = getConfig("allianceCity")
        return math.ceil(allianceCityCfg.moveCost * self.getMainLevel())
    end

    -- 获取创建领地的消耗
    function self.getBuildCost()
        return getConfig("allianceCity").buildCost
    end

    -- 获取移除矿点所需花费
    function self.getRemoveIslandCost(islandLv)
        return math.ceil(getConfig("allianceCity").killMine * tonumber(islandLv))
    end

      -- 更新击杀海盗
    function self.upKill(num)
        if not self.isNormal() then return false end

        local ts= os.time()
        local weeTs = getWeeTs()
        local allianceBuidCfg = getConfig('allianceCity')

        local weekday=tonumber(getDateByTimeZone(ts,"%w"))
        if weekday == 0 then weekday =7  end

        local sttime = weeTs+allianceBuidCfg.settlementTime[2]*3600+allianceBuidCfg.settlementTime[3]*60
        local edtime = weeTs + 22*3600

        -- 领奖期间不更新击杀数（保证排行榜不发生变化）
        if weekday ==  allianceBuidCfg.settlementTime[1] and ts>sttime and ts<edtime then
            return false
        end

        -- 如果不是上周的22点 需要重置数据
        local lastInit = weeTs-(weekday-1)*86400-2*3600
        if weekday == 7 and ts>weeTs + 22*3600 then
            lastInit = edtime
        end

        if self.kill_at ~= lastInit  then
            self.killcount = 0
            self.kill_at = lastInit
        end

        local curkill = self.memkill(lastInit)
        self.killcount =  curkill + num

        local redis = getRedis()
        local key = "z"..getZoneId()..".territory.acrank"..lastInit
        local result = redis:del(key)

        return true
    end

    -- 排行榜 是否处于领奖期间
    function self.rewardtime()
        local ts= getClientTs()
        local weeTs = getWeeTs()
        local allianceCityCfg = getConfig('allianceCity')

        local weekday=tonumber(getDateByTimeZone(ts,"%w"))
        if weekday == 0 then weekday =7  end

        local sttime = weeTs+allianceCityCfg.settlementTime[2]*3600+allianceCityCfg.settlementTime[3]*60
        local edtime = weeTs + 22*3600

        -- 在领奖期间 并且是在本轮排行榜
        local lastInit = weeTs-(weekday-1)*86400-2*3600
        if weekday ==  allianceCityCfg.settlementTime[1] and ts>sttime and ts<edtime then
             if self.kill_at == lastInit  then
                 return true,lastInit
             end
        end

        return false,lastInit
    end

    -- 军团可发布任务列表
    function self.tasklist()
        local flag =  false
        local ts= getClientTs()
        local weeTs = getWeeTs()
        local allianceCityCfg = getConfig('allianceCity')
        if not self.task.upt then self.task.upt=0 end

        local flagtime = weeTs + allianceCityCfg.pubTaskTime[1]*3600
        local refreshtime = 0 -- 刷新时间标识
        -- 获取刷新时间标识
        if ts > weeTs and ts < flagtime then
            refreshtime = flagtime-86400
        else
            refreshtime = flagtime
        end

        if self.task.upt ~= refreshtime then
            local tidtab = {}
            self.task.l={}
            -- 重新分配刷新列表
            for k,v in pairs(allianceCityCfg.task.taskList[2]) do
                local alTask = randVal(v.ratio)
                local tid = k..'_'..alTask
                self.task.l[tid] = self.taskCon(tid)

                table.insert(tidtab,tid)
            end
            self.task.upt = refreshtime
            self.task.rn = 0

             self.task.tk = {}
             setRandSeed()
             local rd = rand(1,#tidtab)
             local tid =tidtab[rd]
             local keys = tid:split('_')

            self.task.tk.tid = tid
            if tonumber(keys[1])==5 then
                self.task.tk.cur = {r1=0,r2=0,r3=0,r4=0}
            else
                self.task.tk.cur = 0
            end

            self.task.auto = 0

            self.task.tk.con = self.taskCon(tid)
            flag =   true
        end

        return self.task,flag
    end

    -- 计算任务完成条件
    -- keys 任务编号
    function self.taskCon(tid)
        local keys = tid:split('_')
        local allianceCityCfg = getConfig('allianceCity')
        local allianceBuidCfg = getConfig('allianceBuid')
        local taskinfo = allianceCityCfg.task.taskList[2][tonumber(keys[1])].list[tonumber(keys[2])]
  
        local finish = 99999999
         -- 1 军团累计采集天然气资源总量达一定数量   天然气矿等级对应的矿点产出*基础系数
        if tonumber(keys[1])==1 then
            local lv = self.b5.lv>0 and self.b5.lv or 1
            finish = math.floor(allianceBuidCfg.buildValue[5][3][lv]*taskinfo[1]) 
        end
        -- 2 军团累计采集铀资源总量达一定数量       铀矿等级对应的矿点产出*基础系数
        if tonumber(keys[1])==2 then
            local lv = self.b4.lv>0 and self.b4.lv or 1
            finish = math.floor(allianceBuidCfg.buildValue[4][3][lv]*taskinfo[1]) 
        end
        -- 3 军团累计为控制台注入一定数量的能量     (基础+主基地等级)*(7.2+(主基地等级-1)*0.384)
        if tonumber(keys[1])==3 then
            local lv = self.b1.lv>0 and self.b1.lv or 1
            finish = math.floor((taskinfo[1]+lv)*(7.2+(lv-1)*0.384))
        end
        -- 4 军团累计产生军团一定数量贡献        基础*(7.2+(主基地等级-1)*0.384)
        if tonumber(keys[1])==4 then
            local lv = self.b1.lv>0 and self.b1.lv or 1
            finish = math.floor(taskinfo[1]*(7.2+(lv-1)*0.384))
        end
        -- 5 军团累计采集四项基础资源一定数量       基础*(7.2+(主基地等级-1)*0.384)
        if tonumber(keys[1])==5 then
            local lv = self.b1.lv > 0 and self.b1.lv or 1
            finish = math.floor(taskinfo[1]*(7.2+(lv-1)*0.384))
        end

        return finish

    end

    -- 军团长刷新军团任务列表
    function self.rfTask()
        local ts= getClientTs()
        local weeTs = getWeeTs()        
        local allianceCityCfg = getConfig('allianceCity')

        self.task.l={}
        -- 重新分配刷新列表
        for k,v in pairs(allianceCityCfg.task.taskList[2]) do
            local alTask = randVal(v.ratio)
            local tid = k..'_'..alTask
            self.task.l[tid] = self.taskCon(tid)
            --table.insert(self.task.l,tid)
        end

        self.task.rn = (self.task.rn or 0) + 1

        -- 刷新的时候把默认的任务完成条件也刷新 因为有可能建筑等级有变化 导致完成任务条件也有变化
        self.task.tk.con = self.taskCon(self.task.tk.tid)

        return true
    end

    -- 发布军团任务
    function self.pubTask(tid)
        local allianceCityCfg = getConfig('allianceCity')
        local keys = tid:split('_')

        if type(allianceCityCfg.task.taskList[2][tonumber(keys[1])].list[tonumber(keys[2])])~='table' then
            return false
        end

        self.task.tk = {}
        self.task.tk.tid = tid
        if tonumber(keys[1])==5 then
            self.task.tk.cur = {r1=0,r2=0,r3=0,r4=0}
        else
            self.task.tk.cur = 0
        end

        self.task.auto = 1 -- 是通过军团长手动发布的
        self.task.tk.con = self.taskCon(tid)

        return true
    end

    -- 更新军团任务进度
    function self.uptask(params)
        local weeTs = getWeeTs()
        local ts= getClientTs()
        local allianceCityCfg = getConfig('allianceCity')
  
        if type(self.task.tk)~='table' or not next(self.task.tk) then
            local task,falg = self.tasklist()
            if not task then
                return false
            end
        end

        if self.maintenance() then
            return false
        end
      
        local sttime = weeTs + allianceCityCfg.pubTaskTime[1]*3600+allianceCityCfg.pubTaskTime[2]*60
        local edtime = weeTs + allianceCityCfg.realPubTaskTime[1]*3600+allianceCityCfg.realPubTaskTime[2]*60

        -- 发布期间任务不计数 如果已发布则可以计数
        if ts>sttime and ts<edtime then
            if self.task.auto == 0 then
                return false
            end      
        end

        if not self.isNormal() then return false end

        -- 军团任务类型
        -- 1 军团累计采集天然气资源总量达一定数量
        -- 2 军团累计采集铀资源总量达一定数量
        -- 3 军团累计为控制台注入一定数量的能量
        -- 4 军团累计产生军团一定数量的贡献
        -- 5 军团累计采集四项基础资源一定数量
 
        local tid = self.task.tk.tid
        local keys = tid:split('_')

        -- 任务是否在应用中
        if params.act ~= tonumber(keys[1]) then return false end
        local t = {}
        if tonumber(keys[1])==5 then
            -- 添加四种基础资源 按采集的百分比
            local resourceCfg = {r1=true,r2=true,r3=true,r4=true}
            for k,v in pairs(params.val) do
                if resourceCfg[k] then
                    t[k] = math.floor( v * allianceCityCfg.collectResValue )
                end
            end

            for i=1,4 do
                self.task.tk.cur['r'..i] = self.task.tk.cur['r'..i] + (t['r'..i] or 0)
            end
        else
            self.task.tk.cur = self.task.tk.cur + params.num
        end

        -- 成员任务贡献度
        if params.u>0 then
            local uobjs = getUserObjs(params.u)
            local mAtmember = uobjs.getModel('atmember')
            -- 如果记录时间 跟军团任务刷新时间不同 需要重置
            if type(mAtmember.atcontri)~='table' then
                mAtmember.atcontri = {t=0,n=0}
            end
            if mAtmember.atcontri.t ~= self.task.upt then
                mAtmember.atcontri.t = self.task.upt
                mAtmember.atcontri.n = 0
                mAtmember.atcontri.ts = ts -- 用于判断贡献先后顺序
            end

            if params.act==5 then
                if next(t) then
                    for i=1,4 do
                        mAtmember.atcontri.n =mAtmember.atcontri.n + (t['r'..i] or 0)
                    end
                end
            else
                mAtmember.atcontri.n = mAtmember.atcontri.n + params.num
            end
        end

        return true
    end

    -- 获取记录分配信息的缓存key
    local function getAllottedCachekey()
        return string.format("z%s.territory.allotMembers.%s.%s",getZoneId(),self.aid,getWeeTs())
    end

    -- 设置分配成员标识
    function self.setAllotMember(member)
        local cacheKey = getAllottedCachekey()
        local redis = getRedis()
        local ret = redis:sadd(cacheKey,member)
        if ret > 0 then
            redis:expire(cacheKey,86400)
            return true
        end
    end

    -- 已分配的人员
    function self.countAllotMembers()
        return getRedis():scard(getAllottedCachekey())
    end

    -- 获取所有已分配的成员列表
    function self.getAlllotMembers()
        return getRedis():smembers(getAllottedCachekey())
    end

    -- 领地排行榜
    function self.rank()
        local list = {}
        local redis = getRedis()
        local key = "z"..getZoneId()..".territorylevel.rank"
        local result = redis:get(key)

        if type(result) == "table" and next(result) then
            list=result
        else
            local db = getDbo()
            local result = db:getAllRows(string.format("select aid,level,mapx,mapy from territory where  status=1 order by level desc,ct desc limit 180"))
            if type(result)=='table' and next(result) then
                local aidlist = {}
                for k,v in pairs(result) do
                    table.insert(aidlist,v.aid)
                end

               local setRet,code=M_alliance.getalliancesname{aids=json.encode(aidlist)}
               if type(setRet['data'])=='table' and next(setRet['data']) then
                    local tmp = {}
                    for k,v in pairs(setRet['data']) do
                        tmp[v.aid] = v.name
                    end

                    -- 删除小地图数据,从排行榜数据重新生成
                    self.delMinimap()

                    local i = 1
                    for k,v in pairs(result) do
                         table.insert(list,{i,v.level,tmp[v.aid],v.aid})
                         i=i+1
                         self.addMinimap(v.mapx,v.mapy,i)
                    end

                    local ts= getClientTs()
                    local weeTs = getWeeTs()
                    local refreshT = 0
                    if ts<weeTs+6*3600 then
                        refreshT = weeTs+6*3600
                    else
                        refreshT = weeTs+30*3600
                    end

                    redis:set(key,json.encode(list))
                    redis:expireat(key,refreshT)
                end
            end
        end

        return list
    end

    -- 捐献采集的野矿资源
    function self.donateCollectResource(resources)
        local resourceCfg = {r1=true,r2=true,r3=true,r4=true}
        local allianceCityCfg = getConfig("allianceCity")

        local t = {}
        for k,v in pairs(resources) do
            if resourceCfg[k] then
                t[k] = math.floor( v * allianceCityCfg.collectResValue )
            end
        end

        if next(t) then
            self.addResource(t)
        end
    end

    -- 删除击杀海盗排行榜 领地排行榜 缓存
    function self.delrank()
        local redis = getRedis()
        local redkeys=redis:keys("z"..getZoneId()..".territory.acrank*")
        if type(redkeys)=='table' and next(redkeys) then
            for k,v in pairs(redkeys) do
                redis:del(v)
            end
        end

        local key = "z"..getZoneId()..".territorylevel.rank"
        redis:del(key)
    end
    
    -- 清除每日相关的数据
    function self.cleanDailyData()
        self.daypower = 0
    end

    -- 列取当前军团任务贡献列表
    function self.atcontrilist()
        local list = {}
        local ts= getClientTs()
        local weeTs = getWeeTs()
        local allianceCityCfg = getConfig('allianceCity')
        local flagtime = weeTs + allianceCityCfg.pubTaskTime[1]*3600
        local refreshtime = 0 -- 刷新时间标识
        -- 获取刷新时间标识
        if ts > weeTs and ts < flagtime then
            refreshtime = flagtime-86400
        else
            refreshtime = flagtime
        end

        if self.task.upt~=refreshtime then return list end

        local tid = self.task.tk.tid
        local keys = tid:split('_')

        local curval = 0
        if tonumber(keys[1])==5 then   
            for i=1,4 do
                curval = curval + (self.task.tk.cur['r'..i] or 0)
            end
        else
            curval = self.task.tk.cur
        end

        local con = self.task.tk.con

        local cup = 0
        local db = getDbo()
        local result = db:getAllRows(string.format("select uid,atcontri from atmember where  aid="..self.aid))
        if type(result)=='table' and next(result) then
            local tmplist = {}
            for k,v in pairs(result) do
                local uobjs = getUserObjs(tonumber(v.uid))
                local mUserinfo = uobjs.getModel('userinfo')
                local atcontri = {}
                if v.atcontri =='' or not v.atcontri then
                    atcontri = {n=0,t=0,ts=0}
                else
                    atcontri = json.decode(v.atcontri)
                end

                if tonumber(atcontri.t)~=refreshtime then
                    table.insert(tmplist,{v.uid,mUserinfo.nickname,0,ts})
                else
                    local percent = 0
                    if con > 0  then
                        local val = tonumber(atcontri.n)/con
                        percent = tonumber(string.format("%.3f", val))*100 
                        if percent > 100 then
                            percent = 100
                        end
                    end
                    local upt = atcontri.ts or ts
     
                    table.insert(tmplist,{v.uid,mUserinfo.nickname,percent,upt})
                end      
            end
      
            -- 排序 按照先做出任务贡献的玩家(时间)
            table.sort( tmplist,function ( a,b )  
                -- body  
                if a[4]==b[4] then  
                    return a[4] < b [4] 
                end  
              
                return a[4] < b[4]  
            end ) 

            for k,v in pairs(tmplist) do 
                local p = v[3]
                if cup + v[3] >= 100 then
                    if cup < 100 then
                        p = 100 - cup
                    else
                        p = 0
                    end
                end

                table.insert(list,{v[1],v[2],p,v[4]})
                cup = cup + p
            end
            -- 按照贡献的最终百分比排序
            table.sort( list,function ( a,b )  
                -- body  
                if a[3]==b[3] then  
                    return a[3] > b [3] 
                end  
              
                return a[3] > b[3]  
            end ) 
        end

        return list
    end
    

    -- 检测 炮台建造队列（只能有一个）
    function self.checkBattery()
        local bTypeCfg = getConfig('allianceBuid.btype')
        for k,v in pairs(self.bqueue) do
            if bTypeCfg[v.id] == 6 then
                return true
            end
        end
        return false
    end

    -- 领地建筑升级加速(使用加速道具)
    --
    function self.buildSpeedUp(bid,discInter,lt)
        local iSlotKey = self.checkIdInSlots(bid)
        if not iSlotKey or type(self.bqueue[iSlotKey]) ~= 'table' then return -8450 end

        -- 加速失败
        local lefttime = self.bqueue[iSlotKey].et - getClientTs()
        --writeLog('领地建筑加速:uid'..'bid='..bid..'lt='..lt..'left='..lefttime,"territory")
        if lt-lefttime > 30 then
            return -8450
        end

        self.bqueue[iSlotKey].et = self.bqueue[iSlotKey].et - discInter
        self.bqueue[iSlotKey].st = self.bqueue[iSlotKey].st - discInter
        if self.bqueue[iSlotKey].et <= getClientTs() then
            self.bqueue[iSlotKey].et = getClientTs()
            local cronParams = {cmd="territory.ckbqueue",params={aid=self.aid}}
            if not setGameCron(cronParams,0) then
                return -1
            end
        end

        return 0
    end
        
    -- 重置领海战数据
    function self.resetWarData()
        if self.war_at > 0 then
            local warTime = self.getWarTime()
            if self.war_at < warTime.warSt then
                self.warscore = 0
                self.warstatus = 0
                self.war_at = 0
            end
        end
    end

    -- 检测战争状态
    -- warFlag 1是进攻，2是驻守
    function self.checkTimeOfWar(warFlag)
        if switchIsEnabled('allianceDomain2') then
            local ts = os.time()
            local warTime = self.getWarTime()

            if warFlag == 2 then
                return ts > warTime.beginSt and ts < warTime.battleEt
            end

            return ts > warTime.battleSt and ts < warTime.battleEt
        end
    end

    -- 检测参战等级
    function self.checkLevelOfWar()
        return self.level >= getConfig('allianceDomainWar').leveliLimit
    end

    -- 检测参与战争的岛
    function self.checkIslandOfWar(bid)
        return bid ~= "b4" and bid ~= "b5"
    end

    -- 检测战争状态
    function self.checkStatusOfWar()
        return self.warstatus == 0
    end

    -- 报名参战
    function self.applyForWar()
        if not self.checkApplyOfWar() then
            self.apply = 1
            self.apply_at = getClientTs()

            -- 军团报名成功
            self.mailNotify(74)
        end
    end

    -- 检测报名
    function self.checkApplyOfWar()
        if self.apply_at > 0 then
            local warTime = self.getWarTime()
            local applySt = warTime.warSt - ( (7-2) * 86400)
            local ts = getClientTs()
            if self.apply_at < applySt or ( self.apply_at < warTime.beginSt and ts > (warTime.clearingEt + 86400) )  then
                self.apply = 0
                self.apply_at = 0
            end
        end

        return self.apply == 1
    end

    function self.setWarStatus(status)
        self.warstatus = status
        self.war_at = getClientTs()
    end

    function self.getWarTime()
        local st,et

        local ts = os.time()
        local weeTs = getWeeTs(ts)

        -- weekday (3) [0-6 = Sunday-Saturday]
        local today = tonumber(getDateByTimeZone(ts,"%w"))
        if today < 6 then
            st = weeTs - (today+1) * 86400
        else
            st = weeTs
        end

        et = st + 7*86400 -1

        local cfg = getConfig('allianceDomainWar')
        local battleSt = st + cfg.beginTime[2]*3600 + cfg.beginTime[3]*60 
        local battleEt = st + cfg.endTime[2]*3600 + cfg.endTime[3]*60 -- 战斗结束时间

        return {
            warSt = st, -- 海战开始时间(包括准备时间，从这个点开始上一期的数据要清掉了)
            warEt = et, -- 海战结束时间(排行榜和领奖时间到此为止)
            beginSt = battleSt - cfg.enterTime * 60, -- 战备开始时间
            battleSt = battleSt, -- 战斗开始时间
            battleEt = battleEt, -- 战斗结束时间
            clearingEt = battleEt + cfg.downTime*60, -- 结算完成时间 
        }
    end

    -- 获取领海战积分
    -- 本期要清除上一期的积分
    function self.getWarScore()
        return self.warscore
    end

    -- 设置领海战积分
    -- 积分会保留到下期开战前(一周)
    function self.setWarScore(score)
        score = math.floor(tonumber(score))
        if score > 0 then
            self.warscore = score
            self.war_at = getClientTs()
        end
    end

    function self.getMainPosByBidPos(bid,pos)
        local id = tonumber(string.sub(bid, 2))
        local buildPos = getConfig("allianceBuid").buildPos
        local mainPos = {pos[1] - buildPos[id][1],pos[2] - buildPos[id][2]}

        return mainPos
    end

    -- 根据领地编号和坐标，获取炮台地图数据
    -- 炮塔等级为0时是未建造，不会返回
    -- param string bid b1-b9
    -- param table pos 领地坐标
    -- return table {id,id...}
    function self.getTurretMapByBidPos(bid,pos)
        local mainPos = self.getMainPosByBidPos(bid,pos)

        local _,mapIds = self.getTerritoryMapByPos(mainPos[1],mainPos[2])
        
        local turretMap = {}
        for k,v in pairs(getConfig("allianceBuid").btype) do
            if v == 6 then
                if self.getLevel(k) > 0 then
                    table.insert(turretMap,mapIds[tonumber(string.sub(k, 2))])
                    -- turretMap[k] = mapIds[tonumber(string.sub(k, 2))]
                end
            end
        end

        return turretMap
    end

    -- 成员击杀的海盗数
    function self.memkill(lastInit)
        local killnum = 0
        local db = getDbo()
        local result = db:getRow("select sum(`killcount`) as total from atmember where kill_at="..lastInit.." and aid="..self.aid)
        if type(result) == 'table' and next(result) then
            killnum = result.total
        end

        return killnum
    end

    return self
end

return model_aterritory