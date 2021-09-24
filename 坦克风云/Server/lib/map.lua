local model_map = {
    data = {},
    goldMine={},
}

model_map.arrayGet = arrayGet

function model_map:type2ResName(rType)
    rType = tonumber(rType)
    if rType == 1 then return 'r1' end
    if rType == 2 then return 'r2' end
    if rType == 3 then return 'r3' end
    if rType == 4 then return 'r4' end
    if rType == 5 then return 'gold' end
end

function model_map:getMapById(mid)
    mid = tonumber(mid)

    if not rawget(self.data,mid) then
        local db = getDbo()
        self.data[mid] = db:getRow("select * from map where id = :id",{id=mid})
        if self.data[mid].data and #self.data[mid].data > 0 then
            self.data[mid].data = json.decode(self.data[mid].data)
        else
            self.data[mid].data = {}
        end
    end
    
    return self.data[mid]
end

function model_map:getUserMap(uid)
    local db = getDbo()
    local data = db:getRow("select * from map where oid = :oid and type = 6",{oid=uid})

    return data
end

function model_map:update(mid,params,column)
    local db = getDbo()
    if not column then column = {} end
    params.id = mid
    table.insert(column,"id")

    local n = db:update('map',params,column)
    local ret = (tonumber(n) or 0) > 0 

    if not ret then
        local logstr = (getClientTs() or '' ).. '|' .. (db:getQueryString() or '') ..'|error:'.. (db:getError() or '') .. '|ret:' .. (n or '')  
        writeLog('map update failed:' .. logstr,'maperror') 
    end

    -- if type(params) == 'table' and self.data[mid] then
    if type(params) == 'table' and rawget(self.data,mid) then
        for k,v in pairs(params) do
            if k~='data' then
                self.data[mid][k] = v
            end
        end
    end
    -- self.data[mid] = nil

    return ret
end

function model_map:addexp(mid,addexp)
    local db = getDbo()
    local data=self:getMapById(mid)
    if type(data) == 'table' and next(data) then
        local exp=tonumber(data.exp)+addexp
        local n = db:update('map',{exp=exp},"id="..mid)    
        local ret = (tonumber(n) or 0) > 0 
        data.exp=exp
        if not ret then
            local logstr = (getClientTs() or '' ).. '|' .. (db:getQueryString() or '') ..'|error:'.. (db:getError() or '') .. '|ret:' .. (n or '')  
            writeLog('map update failed:' .. logstr,'maperror') 
        end
        return ret,data
    end
    
end

function model_map:getFormatField()
    return {name='',oid=0,exp=0,rank=0,type=0,level=0,power=0,alliance='',protect=0,data='',pic=0,boom=0,boom_max=0,boom_ts=0,alliancelogo='{}'}
end

-- 格式化岛屿
function model_map:format(mid,isClearing)
    local ret
    if isClearing then
        ret = self:update(mid,self:getFormatField())
    else
        ret = self:update(mid,{oid=0})
    end
    
    return ret
end

function model_map:changeOwner(mid,oid,setDataFlag,uid)
    local ret 

    --并发问题导致同一个岛屿有多个玩家打（隐形矿），撤兵的时候检查 占领者（参数uid）
    if tonumber(uid) then
        local map = self:getMapById(mid)
        if tonumber(map.oid) and tonumber(map.oid) ~= tonumber(uid) then
            return ret
        end
    end

    if setDataFlag and type(self.data[mid].data == 'table') then
        ret = self:update(mid,{oid=oid,data=json.encode(self.data[mid].data)})
    else
        ret = self:update(mid,{oid=oid})
    end

    return ret
end

function model_map:getGoldMine()
    if not next(self.goldMine) then
        local mGoldMine = require "model.goldmine"
        self.goldMine = mGoldMine.getGoldMineInfo()
    end

    return self.goldMine
end

function model_map:getMapLevel(maplevel,mapexp,mid)
    mapexp = tonumber(mapexp)
    -- 矿点升级需要计算一下矿点最新等级
    local oldlvl=maplevel
    if moduleIsEnabled('minellvl') == 1 then
        local goldMineCfg=getConfig('goldMineCfg')
        if  goldMineCfg.mineLvlExp[maplevel] then
            if mapexp>goldMineCfg.mineLvlExp[maplevel][1] then
                local addlvl=0
                for k,v in pairs (goldMineCfg.mineLvlExp[maplevel]) do
                    if  mapexp>v then
                        addlvl=k
                    end
                end
                if addlvl>0 then
                    maplevel=maplevel+addlvl*2
                end
            end

        end
    end

    local goldMineMap = model_map:getGoldMine()
    if goldMineMap[tostring(mid)] then
        maplevel = tonumber(goldMineMap[tostring(mid)][3])
    end

    return maplevel,oldlvl
end    

-- 获取防守舰队
function model_map:getDefenseFleet(mid)
    if not self.data[mid] then
        self:getMapById(mid)
    end

    local mapType = tonumber(self.data[mid].type) or 0
    if mapType < 1 or mapType > 5 then
        return {{},{},{},{},{},{},}
    end

    local goldMineMap = model_map:getGoldMine()
    if goldMineMap[tostring(mid)] then
        local mGoldMine = require "model.goldmine"
        return mGoldMine.getGoldMineTroops(goldMineMap[tostring(mid)][3],self.data[mid].data)
    end

    if self.data[mid] then
        local islandCfg = getConfig('island')
        -- local mapData = json.decode(self.data[mid].data) or {}
        local mapData = self.data[mid].data or {}
        local olvl =tonumber(self.data[mid].level)
        local mapLevel =self:getMapLevel(olvl,self.data[mid].exp or 0 )
        if mapLevel >tonumber(self.data[mid].level) and mapLevel<=50 then
            mapLevel=tonumber(self.data[mid].level)
        end
         
        if not mapData.troops then    
            mapData.troops = 1
        end

        local defenseFleet = islandCfg[mapLevel].troops[mapData.troops]        
        return copyTable(defenseFleet)
    end
end

-- 设置防守舰队
function model_map:setDefenseFleet(mid)
    if not self.data[mid] then
        self:getMapById(mid)
    end

    local mapType = tonumber(self.data[mid].type) or 0
    if mapType < 1 or mapType > 5 then
        return false
    end

    local islandCfg = getConfig('island')
    local mapLevel = tonumber(self.data[mid].level)
    -- local mapData = json.decode(self.data[mid].data) or {}
    local mapData = self.data[mid].data
    local currTroops = mapData.troops or 0
    local cfgTroops = islandCfg[mapLevel].troops    

    -- local tNum = table.length(cfgTroops)
    local tNum = 4
    local seed = {}
    for i=1,tNum do
        seed[i] = i
    end

    if currTroops > 0 then
        table.remove(seed,currTroops)
    end

    if tNum > 0 then
        setRandSeed()
        local n = rand(1,tNum-1)
        n = seed[n]
        local newDefenseFleet = cfgTroops[n]
        if type (newDefenseFleet) == 'table' then            
            mapData.troops = n
            -- self:update(mid,{data=json.encode(mapData)})
        end
    end
end

-- 设置保护时间
-- num 保护的时间秒数
function model_map:setProtectTime(uid,num)
    num = math.floor(num or 0)
    if num > 0 then
        local ts = getClientTs()
        local uobjs = getUserObjs(uid)
        local mUserinfo = uobjs.getModel('userinfo')
        if mUserinfo.protect > ts then
            mUserinfo.protect = mUserinfo.protect + num
        else
            mUserinfo.protect  = ts + num
        end
        local mid = getMidByPos(mUserinfo.mapx,mUserinfo.mapy)
        return self:update(mid,{protect = mUserinfo.protect})
    end
end

-- 清除保护时间
function model_map:resetProtectTime(uid)
    local uobjs = getUserObjs(uid)
    local mUserinfo = uobjs.getModel('userinfo')
    mUserinfo.protect = 0
    local mid = getMidByPos(mUserinfo.mapx,mUserinfo.mapy)
    return self:update(mid,{protect = mUserinfo.protect})
end 

-- 更新基地外观
function model_map:refreshBaseSkin(uid)
    local uobjs = getUserObjs(uid)
    local mUserinfo = uobjs.getModel('userinfo')
    if type(mUserinfo.flags.skin) ~= 'table' then
        return false
    end
    local isActive = 1 -- 激活状态
    if type(mUserinfo.flags.gameSetting) == 'table' and mUserinfo.flags.gameSetting["s5"] == 0 then
        isActive = 0 -- 玩家关闭了外观
    end
    local params = {skin = copyTable(mUserinfo.flags.skin)}
    table.insert(params.skin, isActive) 
    local mid = getMidByPos(mUserinfo.mapx,mUserinfo.mapy)
    return self:update(mid,{data = params})
end

function model_map:resetData()
    self.data = {}
    self.goldMine = {}
end 

function model_map:getHeatLevel(mid)
    local lv = 0

    if self.data[mid].data.heat and (self.data[mid].data.heat.point or 0) > 0 then
        local heatCfg = getConfig('mapHeat')
        for k,v in ipairs(heatCfg.point4Lv) do
            if self.data[mid].data.heat.point > v then
                lv = k
            else
                break
            end
        end
    end

    return lv
end

function model_map:decrHeatPoint(mid)
    if self.data[mid].data.heat then
        local heatCfg = getConfig('mapHeat')
        if self.data[mid].data.heat.point > 0 then
            self.data[mid].data.heat.point = math.floor(self.data[mid].data.heat.point - self.data[mid].data.heat.point * heatCfg.lossValue)
            return true
        end
    end
end

-- 刷新热度
function model_map:refreshHeat(mid)
    if not self.data[mid] then
        self:getMapById(mid)
    end

    local ts = getClientTs()

    if not self.data[mid].data.heat or not self.data[mid].data.heat.ts then
        self.data[mid].data.heat = {
            ts=ts,
            point=0,
        }
    else
        local heatCfg = getConfig('mapHeat')
        local upTime = ts - (self.data[mid].data.heat.ts or 0) 
        self.data[mid].data.heat.ts = ts

        if upTime < ts then
            if (tonumber(self.data[mid].oid) or 0) > 0 then
                local maxHeat = heatCfg.maxHeat[#heatCfg.maxHeat]
                if self.data[mid].data.heat.point < maxHeat then
                    local upPoint = math.floor(upTime / heatCfg.pointIncrSpeed)
                    self.data[mid].data.heat.point = (self.data[mid].data.heat.point or 0) + upPoint
                    
                    if self.data[mid].data.heat.point > maxHeat then
                        self.data[mid].data.heat.point = maxHeat
                    end
                end
            else
                if self.data[mid].data.heat.point > 0 or 1 then
                    local dePoint = math.floor(upTime / heatCfg.pointDecrSpeed)
                    self.data[mid].data.heat.point = (self.data[mid].data.heat.point or 0) - dePoint
                    if self.data[mid].data.heat.point < 0 then 
                        self.data[mid].data.heat.point = 0 
                    end
                end
            end
        end
    end
end

local meta = {
        __index = function(tb, key)
                return model_map:getMapById(key)
        end 
}

setmetatable(model_map.data, meta)

return model_map