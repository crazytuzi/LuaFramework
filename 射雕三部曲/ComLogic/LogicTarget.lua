local mapPos = {
    {10 ,11 ,12 },
    {7  ,8  ,9  },
    {13 ,14 ,15 },
    {1  ,2  ,3  },
    {4  ,5  ,6  },
}

local reverseMap = {
    [1]  = {y = 4, x = 1},
    [2]  = {y = 4, x = 2},
    [3]  = {y = 4, x = 3},
    [4]  = {y = 5, x = 1},
    [5]  = {y = 5, x = 2},
    [6]  = {y = 5, x = 3},
    [7]  = {y = 2, x = 1},
    [8]  = {y = 2, x = 2},
    [9]  = {y = 2, x = 3},
    [10] = {y = 1, x = 1},
    [11] = {y = 1, x = 2},
    [12] = {y = 1, x = 3},
}

local Middle_Row = 3
local Limit_left = 1
local Limit_right = 3

local LogicTarget = class("LogicTarget" , function(params)
    return {data = params.data}
end)

local function checkEnemy(pos)
    return ld.getStandType(pos) == ld.HeroStandType.eEnemy
end

local function checkExsit(pos , n_table)
    for i , v in ipairs(n_table) do
        if v == pos then
            return true
        end
    end
    return false
end

--遍历行(取一个)
local function walk_row_once(coords , target)
    if checkExsit(mapPos[coords.y][coords.x] , target) then
        return mapPos[coords.y][coords.x]
    end
    local offset = 1
    local left = false
    local right = false
    while(true) do
        if coords.x - offset < Limit_left then
            left = true
        else
            left = false
            if checkExsit(mapPos[coords.y][coords.x - offset] , target) then
                return mapPos[coords.y][coords.x - offset]
            end
        end
        if coords.x + offset > Limit_right then
            right = true
        else
            right = false
            if checkExsit(mapPos[coords.y][coords.x + offset] , target) then
                return mapPos[coords.y][coords.x + offset]
            end
        end
        if left and right then
            break
        end
        offset = offset + 1
    end
    return nil
end

--遍历行
local function walk_row(coords_y , target)
    local ret = {}
    for i , v in ipairs(mapPos[coords_y]) do
        if checkExsit(v , target) then
            table.insert( ret, v )
        end
    end
    return ret
end

--遍历列
local function walk_col(tmp_coords , target)
    local ret = {}
    local coords = clone(tmp_coords)
    if coords.y > Middle_Row then
        repeat
            if checkExsit(mapPos[coords.y][coords.x] , target) then
                table.insert(ret , mapPos[coords.y][coords.x])
            end
            coords.y = coords.y + 1
        until(coords.y > #mapPos)
    else
        repeat
            if checkExsit(mapPos[coords.y][coords.x] , target) then
                table.insert(ret , mapPos[coords.y][coords.x])
            end
            coords.y = coords.y - 1
        until(coords.y == 0)
    end
    return ret
end
----------------------------------------------------
--单前
local function SingleFront(params)
    if checkEnemy(params.posId) then
        local coords = clone(reverseMap[params.posId])
        coords.y = Middle_Row + 1
        repeat
            local ret = walk_row_once(coords , params.target)
            if ret then
                return {ret}
            end
            coords.y = coords.y + 1
        until(coords.y > #mapPos)
    else
        local coords = clone(reverseMap[params.posId])
        coords.y = Middle_Row - 1
        repeat
            local ret = walk_row_once(coords , params.target)
            if ret then
                return {ret}
            end
            coords.y = coords.y - 1
        until(coords.y == 0)
    end
end

--单后
local function SingleBack(params)
    if not checkEnemy(params.posId) then
        local coords = clone(reverseMap[params.posId])
        coords.y = 1
        repeat
            local ret = walk_row_once(coords , params.target)
            if ret then
                return {ret}
            end
            coords.y = coords.y + 1
        until(coords.y == Middle_Row)
    else
        local coords = clone(reverseMap[params.posId])
        coords.y = #mapPos
        repeat
            local ret = walk_row_once(coords , params.target)
            if ret then
                return {ret}
            end
            coords.y = coords.y - 1
        until(coords.y == Middle_Row)
    end
    --error
end

--前排
local function RowFront(params)
    local standtype = nil
    for i , v in ipairs(params.target) do
        if not standtype then
            standtype = ld.getStandType(v)
        else
            if standtype ~= ld.getStandType(v) then
                error(TR("第一个目标条件不是一个队伍，不能选取前排目标"))
            end
        end
    end
    if standtype == ld.HeroStandType.eTeammate then
        local coords_y = Middle_Row + 1
        repeat
            local ret = walk_row(coords_y , params.target)
            if #ret ~= 0 then
                return ret
            end
            coords_y = coords_y + 1
        until(coords_y > #mapPos)
    elseif standtype == ld.HeroStandType.eEnemy then
        local coords_y = Middle_Row - 1
        repeat
            local ret = walk_row(coords_y , params.target)
            if #ret ~= 0 then
                return ret
            end
            coords_y = coords_y - 1
        until(coords_y == 0)
    end
end

--后排
local function RowBack(params)
    local standtype = nil
    for i , v in ipairs(params.target) do
        if not standtype then
            standtype = ld.getStandType(v)
        else
            if standtype ~= ld.getStandType(v) then
                error(TR("第一个目标条件不是一个队伍，不能选取后排目标"))
            end
        end
    end
    if standtype == ld.HeroStandType.eTeammate then
        local coords_y = #mapPos
        repeat
            local ret = walk_row(coords_y , params.target)
            if #ret ~= 0 then
                return ret
            end
            coords_y = coords_y - 1
        until(coords_y == Middle_Row)
    elseif standtype == ld.HeroStandType.eEnemy then
        local coords_y = 1
        repeat
            local ret = walk_row(coords_y , params.target)
            if #ret ~= 0 then
                return ret
            end
            coords_y = coords_y + 1
        until(coords_y == Middle_Row)
    end
end

--竖排
local function OneColumn(params)
    if checkEnemy(params.posId) then
        local coords = clone(reverseMap[params.posId])
        coords.y = Middle_Row + 1
        local tmp = SingleFront(params)
        coords = clone(reverseMap[tmp[1]])
        return walk_col(coords , params.target)
    else
        local coords = clone(reverseMap[params.posId])
        coords.y = Middle_Row - 1
        local tmp = SingleFront(params)
        coords = clone(reverseMap[tmp[1]])
        return walk_col(coords , params.target)
    end
    --error
end

--随机(默认对方随机)
function LogicTarget:Random(params)
    local ret = {}
    while(#params.target ~= 0) do
        local n = self.data.rand:random(1, #params.target)
        table.insert(ret , params.target[n])
        table.remove(params.target , n)
    end
    return ret
end

--生命值最高
function LogicTarget:HPMax(params)
    table.sort(params.target , function(v1 , v2)
        if self.data:getHero(v1).HP == self.data:getHero(v2).HP then
            return false
        end
        if self.data:getHero(v1).HP > self.data:getHero(v2).HP then
            return true
        end
    end)
    return params.target
end

--生命值最低
function LogicTarget:HPMin(params)
    table.sort(params.target , function(v1 , v2)
        if self.data:getHero(v1).HP == self.data:getHero(v2).HP then
            return false
        end
        if self.data:getHero(v1).HP < self.data:getHero(v2).HP then
            return true
        end
    end)
    return params.target
end

--怒气最高
function LogicTarget:RPMax(params)
    table.sort(params.target , function(v1 , v2)
        if self.data:getHero(v1).RP == self.data:getHero(v2).RP then
            return false
        end
        if self.data:getHero(v1).RP > self.data:getHero(v2).RP then
            return true
        end
    end)
    return params.target
end

--怒气最低
function LogicTarget:RPMin(params)
    table.sort(params.target , function(v1 , v2)
        if self.data:getHero(v1).RP == self.data:getHero(v2).RP then
            return false
        end
        if self.data:getHero(v1).RP < self.data:getHero(v2).RP then
            return true
        end
    end)
    return params.target
end

--损血最多
function LogicTarget:HPLossMax(params)
    table.sort(params.target , function(v1 , v2)
        local h1 = self.data:getHero(v1)
        local h2 = self.data:getHero(v2)
        if h1.TotalHp - h1.HP == h2.TotalHp - h2.HP then
            return false
        end
        if h1.TotalHp - h1.HP > h2.TotalHp - h2.HP then
            return true
        end
    end)
    return params.target
end

--战力最高
function LogicTarget:FightingForceMax(params)
    error(TR("还未实现"))
end

--溅射范围
function LogicTarget:SputteringRange(params)
    local ret = {}
    for i , v in ipairs(params.target) do
        local coords = reverseMap[v]
        if mapPos[coords.y + 1] then
            table.insert(ret , mapPos[coords.y + 1][coords.x])
        end
        if mapPos[coords.y - 1] then
            table.insert(ret , mapPos[coords.y - 1][coords.x])
        end
        table.insert(ret , mapPos[coords.y][coords.x + 1])
        table.insert(ret , mapPos[coords.y][coords.x - 1])
    end

    for i = #ret , 1 , -1 do
        if checkExsit(ret[i] , params.target) then
            table.remove(ret , i)
        end
        local k = self.data:getHero(ret[i])
        if (not k) or (not k:checkAlive()) then
            table.remove(ret , i)
        end
    end
    return ret
end

local TargetType_S1 = {
    eTarget = 0,        --目标
    eFormationSelf = 1, --我方全体
    eFormationEnemy = 2,    --敌方全体
    eSelf = 3,      --自身
    eNotSelf = 4,   --我方除自己
    eDeadSelf = 5,--我方死亡目标
    eSamePos = 6,  --对位
}

local TargetType_S2 = {
    eNone = 0,      --无
    eSingleFront = 1, --单前(敌方)
    eSingleBack = 2, --单后(敌方)
    eRowFront = 3, --前排
    eRowBack = 4, --后排
    eOneColumn = 5, --竖排(敌方)
    eAll = 6, --全体
    eRandom = 7, --随机
    eHPMax = 8, --生命最高
    eHPMin = 9, --生命最低
    eRPMax = 10, --怒气最高
    eRPMin = 11, --怒气最低
    eHPLossMax = 12, --损血最多
    eFightingForceMax = 13, --战力最高
    eSputteringRange = 14, --溅射范围
}

--[[
    params:
        type
        posId
        target
    return:
        table
]]
function LogicTarget:select1(params)
    if params.type == TargetType_S1.eSelf then
        return {params.posId}
    elseif params.type == TargetType_S1.eNotSelf then
        local ret = {}
        for i , v in ld.pairsByKeys(self.data:getHeroList()) do
            if v:checkAlive() and (ld.getStandType(params.posId) == ld.getStandType(i)) and (i ~= params.posId) then
                table.insert(ret , i)
            end
        end
        return ret
    elseif params.type == TargetType_S1.eFormationSelf then
        local ret = {}
        for i , v in ld.pairsByKeys(self.data:getHeroList()) do
            if v:checkAlive() and ld.getStandType(params.posId) == ld.getStandType(i) then
                table.insert(ret , i)
            end
        end
        return ret
    elseif params.type == TargetType_S1.eFormationEnemy then
        local ret = {}
        for i , v in ld.pairsByKeys(self.data:getHeroList()) do
            if v:checkAlive() and ld.getStandType(params.posId) ~= ld.getStandType(i) then
                table.insert(ret , i)
            end
        end
        return ret
    elseif params.type == TargetType_S1.eTarget then
        if type(params.target) == "number" then
            return {params.target}
        elseif type(params.target) == "table" then
            return clone(params.target)
        end
        return {}
    elseif params.type == TargetType_S1.eDeadSelf then
        local ret = {}
        for i , v in ld.pairsByKeys(self.data:getHeroList()) do
            if (not v:checkAlive()) and (ld.getStandType(params.posId) == ld.getStandType(i)) then
                table.insert(ret , i)
            end
        end
        return ret
    elseif params.type == TargetType_S1.eSamePos then
        --对位
        local ret = {}
        local p = (params.posId - 6 > 0) and (params.posId - 6) or (params.posId + 6)
        local k = self.data:getHero(p)
        if (not k) or (not k:checkAlive()) then
            local tmp = {}
            for m , n in ld.pairsByKeys(self.data:getHeroList()) do
                if n:checkAlive() and ld.getStandType(params.posId) ~= ld.getStandType(m) then
                    table.insert(tmp , m)
                end
            end
            local s = SingleFront({posId = params.posId , target = tmp})
            if s then
                for m , n in ipairs(s) do
                    table.insert(ret , n)
                end
            end
        else
            table.insert(ret , p)
        end
        return ret
    end
end

--[[
    params:
        type
        posId
        target
    return
        table
]]
function LogicTarget:select2(params)
    if #params.target == 0 then
        return params.target
    end

    if params.type == TargetType_S2.eNone then
        return params.target
    elseif params.type == TargetType_S2.eSingleFront then
        return SingleFront(params)
    elseif params.type == TargetType_S2.eSingleBack then
        return SingleBack(params)
    elseif params.type == TargetType_S2.eRowFront then
        return RowFront(params)
    elseif params.type == TargetType_S2.eRowBack then
        return RowBack(params)
    elseif params.type == TargetType_S2.eOneColumn then
        return OneColumn(params)
    elseif params.type == TargetType_S2.eAll then
        return params.target
    elseif params.type == TargetType_S2.eRandom then
        return self:Random(params)
    elseif params.type == TargetType_S2.eHPMax then
        return self:HPMax(params)
    elseif params.type == TargetType_S2.eHPMin then
        return self:HPMin(params)
    elseif params.type == TargetType_S2.eRPMax then
        return self:RPMax(params)
    elseif params.type == TargetType_S2.eRPMin then
        return self:RPMin(params)
    elseif params.type == TargetType_S2.eHPLossMax then
        return self:HPLossMax(params)
    elseif params.type == TargetType_S2.eFightingForceMax then
        return self:FightingForceMax(params)
    elseif params.type == TargetType_S2.eSputteringRange then
        return self:SputteringRange(params)
    end
    return {}
end

--[[
    params:
        target
        num
    return
        table
]]
function LogicTarget:select3(params)
    params.num = (params.num == 0) and 6 or params.num
    if #params.target <= params.num then
        return params.target
    end

    local ret = {}
    for i , v in ipairs(params.target) do
        if #ret < params.num then
            table.insert(ret , v)
        else
            break
        end
    end
    return ret
end

--[[
    params:
        type1       条件1
        type2       条件2
        extend      --人数
        target      --buff用，技能的目标列表
        posId       --攻击者位置
    return:
        table
]]
function LogicTarget:getTarget(params)
    local ret = self:select1({type = params.type1 , target = params.target , posId = params.posId})
    ret = self:select2({type = params.type2 , target = ret , posId = params.posId})
    if not ret then
        dump(params)
        error(TR("目标选择配置错误！"))
    end
    return self:select3({target = ret , num = params.extend})
end

return LogicTarget