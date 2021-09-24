local model_map = {
    data = {}
}

model_map.arrayGet = arrayGet
model_map.tableName = 'alienmap'

function model_map:getMapById(mid)
    mid = tonumber(mid)

    if not rawget(self.data,mid) then
        local db = getDbo()
        self.data[mid] = db:getRow("select * from " .. self.tableName .. " where id = :id",{id=mid})
        if self.data[mid].data and #self.data[mid].data > 0 then
            self.data[mid].data = json.decode(self.data[mid].data)
        else
            self.data[mid].data = {}
        end
    end
    
    return self.data[mid]
end

function model_map:update(mid,params)
    local db = getDbo()
    local n = db:update(self.tableName,params,"id="..mid)
    local ret = (tonumber(n) or 0) > 0 

    if not ret then
        local logstr = (getClientTs() or '' ).. '|' .. (db:getQueryString() or '') ..'|error:'.. (db:getError() or '') .. '|ret:' .. (n or '')  
        writeLog('map update failed:' .. logstr,'alienmaperror') 
    end

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

function model_map:changeAlienMapOwner(mid,oid,setDataFlag,name,alliance,fight)
    local info = {oid=oid}

    -- 如果是异星矿山更换占领者，直接刷新一下保护时间
    if oid > 0 then
        info.protect = getClientTs() + getConfig("alienMineCfg.protectTime")
    end
    
    if name then
        info.name = name
    end

    if alliance then 
        info.alliance = alliance 
    end

    -- if fight then
    --     info.power = fight
    -- end

    if setDataFlag and type(self.data[mid].data == 'table') then
        info.data = json.encode(self.data[mid].data)
    end

    if oid <= 0 then
        info = {name='',oid=0,rank=0,power=0,alliance='',protect=0,pic=0}
    end

    return self:update(mid,info)
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

    if self.data[mid] then
        local islandCfg = getConfig('island')
        -- local mapData = json.decode(self.data[mid].data) or {}
        local mapData = self.data[mid].data or {}
        local mapLevel = tonumber(self.data[mid].level)
        
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

function model_map:resetData()
    self.data = {}
end 

local meta = {
        __index = function(tb, key)
                return model_map:getMapById(key)
        end 
}

setmetatable(model_map.data, meta)

return model_map