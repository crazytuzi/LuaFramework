----------------------------------------------------
---- A星寻路
---- @author whjing2011@gmail.com
------------------------------------------------------
local LR_COST = 10        -- 左右移动代价
local TB_COST = 10        -- 上下移动代价
local DIAG_COST = 14      -- 对角线代价
local JUNC_COST = 1000    -- 连接点代价
local SHOW_UI = false     -- 是否显示UI
local SHOW_TXT = false    -- 显示寻路文本
local NOT_BLOCK = false   -- 是否无视不可行走区域
local abs = math.abs      -- 频繁使用函数加载为局部变量
local round = GameMath.round
Astar = Astar or BaseClass()

Astar.celltype = {
    normal = 0,           -- 普通可行走区域
    block  = 1,           -- 不可行走区域
    alpha  = 2,           -- 透明区域  
    water  = 3,           -- 水区域
    snow   = 4,           -- 雪地
    grass  = 5,           -- 草地
    desert = 6,           -- 沙漠
}

function Astar:__init()
	if Astar.Instance ~= nil then
		error("[Astar] accempt to create a singleton twice!")
		return
	end
    self.show_ui = SHOW_UI
    self.open = Heap.New('f')          -- 开启列表
    -- self.open = GbTree.New()        -- 开启列表
    self.all_point = {}                -- 所有已访问点
    self.block = {}                    -- 阻挡区域
    self.max_x = 0                     -- 最大X坐标
    self.max_y = 0                     -- 最大Y坐标
    self.dynamic_block = {}            -- 动态阻挡区域
    self.junction = {}                 -- 连通点
    self.start_point = cc.p(0,0)       -- 起点
    self.end_point = cc.p(0,0)         -- 终点
    self.path = nil                    -- 寻路路径
end

function Astar:getInstance()
    if Astar.Instance == nil then
        Astar.Instance = Astar.New()
    end
    return Astar.Instance
end

-- 重置
function Astar:reset()
    self.all_point = {}
    self.path = nil
    self.open:clear()
end

-- 清空所有
function Astar:clear()
    self:reset()
    self.block = {}            -- 阻挡区域
    self.max_x = 0             -- 最大X坐标
    self.max_y = 0             -- 最大Y坐标
    self.dynamic_block = {}    -- 动态阻挡区域
    self.junction = {}         -- 连通点
end

function Astar:setBlock(block)
    self.block = block
    self.max_y = #block
    self.max_x = #block[1] or 0
    self:showUI()
end

function Astar:setMax(max_x, max_y)
    self.max_x = max_x
    self.max_y = max_y
end

function Astar:setDynamicBlock(block)
    self.dynamic_block = block
end

function Astar:setJunction(junction)
    self.junction = junction
end

function Astar:calcH(sx, sy, tx, ty)
    local dx = abs(sx - tx) * LR_COST
    local dy = abs(sy - ty) * TB_COST
    return dx + dy
end

function Astar:calc_key(point)
    return point
end

function Astar:new_point(x, y, parent, dir, cost)
    if parent == nil then
        return self:calc_key({x = x, y = y, g = 0, h = 0, f = 0, n = 0, dir = DirType.None})
    else 
        local g = parent.g + cost
        local h = self:calcH(x, y, self.end_point.x, self.end_point.y)
        return self:calc_key({x = x, y = y, g = g, h = h, f = g + h, parent = parent, dir = dir, n = parent.n + 1})
    end
end

function Astar:isSamePoint(p1, p2)
    if p1 == nil or p2 == nil then return end
    return p1.x == p2.x and p1.y == p2.y
end

function Astar:autoCheck(point)
    if not self:isBlock(point.x, point.y) then 
        return point
    elseif not self:isBlock(point.x + 1, point.y) then 
        return {x = point.x + 1, y = point.y}
    elseif not self:isBlock(point.x - 1, point.y) then 
        return {x = point.x - 1, y = point.y}
    elseif not self:isBlock(point.x, point.y + 1) then 
        return {x = point.x, y = point.y + 1}
    elseif not self:isBlock(point.x, point.y - 1) then 
        return {x = point.x, y = point.y - 1}
    elseif not self:isBlock(point.x + 2, point.y) then 
        return {x = point.x + 2, y = point.y}
    elseif not self:isBlock(point.x - 2, point.y) then 
        return {x = point.x - 2, y = point.y}
    elseif not self:isBlock(point.x, point.y + 2) then 
        return {x = point.x, y = point.y + 2}
    elseif not self:isBlock(point.x, point.y - 2) then 
        return {x = point.x, y = point.y - 2}
    end
    return nil
end

function Astar:find(start_point, end_point)
    if end_point == nil then return end
    if self:isSamePoint(start_point, end_point) then return end
    if self.path and self:isSamePoint(self.start_point, start_point) and self:isSamePoint(self.end_point, end_point) then return true end
    local end_x = end_point.x
    local end_y = end_point.y
    self:reset()
    if self:isBlock(end_x, end_y) then 
        print("目标点为不可行走区域", end_x, end_y, self.max_x, self.max_y)
        return false
    end
    start_point_new = self:autoCheck(start_point)
    if start_point_new == nil and math.max(math.abs(start_point.x - end_x), math.abs(start_point.y - end_y)) < 8 then 
        print("起始点在不可行走区域", start_point.x, start_point.y, self.max_x, self.max_y)
        self.path = {x = end_x, y = end_y, parent = start_point}
        return true
    elseif start_point_new == nil then 
        print("起始点在不可行走区域", start_point.x, start_point.y, self.max_x, self.max_y)
        return false
    end
    if self:isSamePoint(start_point_new, end_point) then return end
    local start_time = os.clock()
    self.start_point = start_point
    self.end_point = end_point
    local point = self:new_point(start_point_new.x, start_point_new.y)
    local key, parent, nextList, x, y, dir, cost, g
    local open = self.open
    local all_point = self.all_point
    open:insert(point)
    while not open:IsEmpty() do
        parent = open:take_smallest()
        parent.close = 1
        nextList = self:nextPos(parent.x, parent.y, parent.dir)
        for _, test in pairs(nextList) do 
            x = test[1]
            y = test[2]
            dir = test[3]
            cost = test[4]
            if all_point[x] and all_point[x][y] then -- 之前访问过了
                point = all_point[x][y]
                g = parent.g + cost 
                if point.close == nil and g < point.g then -- 还在开启状态 G值较小 更新信息
                    point.g = g
                    point.f = point.g + point.h
                    point.parent = parent
                    point.dir = dir
                    point.n = parent.n + 1
                end
            elseif x == end_x and y == end_y then -- 目标点
                self.path = self:new_point(x, y, parent, dir, cost)
                self:showUI()
                all_point = {}
                open:clear()
                return true
            elseif not self:isBlock(x, y) then -- 可行走 -- 之前未访问过
                point = self:new_point(x, y, parent, dir, cost)
                if all_point[x] == nil then 
                    all_point[x] = {}
                end
                all_point[x][y] = point
                open:insert(point)
            end
        end
    end
    self.path = point
    self:showUI()
    self:reset()
    return false
end

function Astar:isBlock(x, y)
    if x < 1 or x > self.max_x then -- 超出范围
        return true
    elseif y < 1 or y > self.max_y then -- 超出范围
        return true
    elseif NOT_BLOCK then
        return false
    else
        local flag = self.block[y][x]
        if self:isNotBlock(flag) then
            return false
        elseif Astar.celltype.block == 1 or flag == nil then -- 不可行走
            return true 
        else -- 动态切换区域
            flag = self.dynamic_block[flag]
            return flag == nil or flag == Astar.celltype.block
        end
    end
end

--[[
    可行走区域
    0 普通可行走
    2 透明区域
    3 水区域
    4 雪地
    5 草地
    6 沙漠
]]
function Astar:isNotBlock(flag)
    return flag == Astar.celltype.normal or flag == Astar.celltype.alpha or flag == Astar.celltype.water or flag == Astar.celltype.snow or flag == Astar.celltype.grass or flag == Astar.celltype.desert
end

function Astar:isAlpha(x, y)
    return self.block[y] and self.block[y][x] == Astar.celltype.alpha
end

--[[
    当前各自行走状态
]]
function Astar:type(x, y)
    if self.block[y] then
        return self.block[y][x]
    end
    return Astar.celltype.normal
end

-- 随机生成一个可行走点
function Astar:rand()
    local p1 = {x = math.random(1, self.max_x), y = math.random(1, self.max_y)}
    if self:isBlock(p1.x, p1.y) then
        return self:rand()
    end
    return p1
end

-- 随机生成一个可行走点 
function Astar:randNextPoint(p, r, nowP)
    local p1 = {x = p.x + math.random(-r.x, r.x), y = p.y + math.random(-r.y, r.y)}
    if self:isBlock(p1.x, p1.y) then
        return nil
    elseif nowP and self:lineInBlock(nowP, p1) then  -- 要求与当前点的直线不存在不可行走区域
        return nil
    end
    return p1
end

function Astar:getPath(clear)
    local path = {}
    local point = self.path
    while point do 
        table.insert(path, {x = point.x, y = point.y})
        point = point.parent
    end
    if clear then
        self:reset()
    end
    return path
end

-- 通过floyd算法优化路径，使路径平滑
function Astar:floyd(clear)
    local path = self:getPath(clear)
    local len = #path
    if len > 2 then 
        local dx1, dy1 = self:getNodeDistance(path[1], path[2])
        local i = 3
        while i <= len do 
            local dx2, dy2 = self:getNodeDistance(path[i-1], path[i])
            if dx1 == dx2 and dy1 == dy2 then
                table.remove(path, i - 1)
                len = len - 1
            else
                i = i + 1
                dx1 = dx2
                dy1 = dy2
            end
        end
        i = 3
        while i <= len do 
            if self:lineInBlock(path[i-2], path[i]) then 
                i = i + 1
            else
                table.remove(path, i - 1)
                len = len - 1
            end
        end
    end
    return path
end

function Astar:lineInBlock(p1, p2)
    local dx = p1.x - p2.x
    local dy = p1.y - p2.y
    local n = math.max(abs(dx), abs(dy))
    local x = dx / n
    local y = dy / n
    for i = 1, n do 
        local px = round(p1.x - x * i) 
        local py = round(p1.y - y * i)
        if px == p1.x and py == p1.y then
        elseif px == p2.x and py == p2.y then
        elseif self:isBlock(px, py) then
            return true
        end
    end 
    return false
end

function Astar:hasBlock(plist)
    for _, p in pairs(plist) do 
        if self:isBlock(p.x, p.y) then 
            return true
        end
    end
    return false
end

-- 获取2点间距离
function Astar:getNodeDistance(p1, p2)
    local dx = p1.x - p2.x
    local dy = p1.y - p2.y
    return dx, dy
end

-- 计算目标点
function Astar:targetPos(p1, p2)
    local maxx = p2.x
    local minx = maxx - 50
    if p2.x < p1.x then
        minx = p2.x
        maxx = minx + 50
    end
    local maxy = p2.y
    local miny = maxy - 50
    if p2.y < p1.y then
        miny = p2.y
        maxy = miny + 50
    end
    local num,px,py = 0
    while num < 3 do
        px = math.random(minx, maxx)
        py = math.random(miny, maxy)
        if not self:isBlock(TileUtil.changeXToTile(px), TileUtil.changeYToTile(py)) then
            return cc.p(px, py)
        end
        num = num + 1
    end
    return p2
end

-- 查找下一个传送门
function Astar.nextDoor(sMapId, tMapId)
    local doors = Astar.findDoor(sMapId, tMapId)
    return doors and doors[#doors] or nil
end

-- 踢地图传送门
function Astar.findDoor(sMapId, tMapId)
    if sMapId == tMapId then return nil end
    if not Config.Map[sMapId] then return nil end
    if not Config.Map[tMapId] then return nil end
    local elemL = {} 
    for id, vo in pairs(Config.Map[sMapId].unit_list) do
        table.insert(elemL, {id, vo})
    end
    local elem, elemData,mapid
    local maps = {}
    maps[sMapId] = 1
    while(next(elemL)) do
        elem = table.remove(elemL, 1)
        elemData = Config.UnitData.data_unit(elem[2][1])
        if elemData and elemData.sub_type == 102 then 
            local elem_id = elem[2][1]
            mapid = Config.MapUnit[elem_id][1]
            if mapid == tMapId then
                elemL = {}
                while true do

                    local vo = UnitVo.New()
                    vo.battle_id = 1
                    vo.id        = elem.id
                    vo.base_id   = elem.id
                    vo.type      = UnitVo.Type.DOOR
                    vo.x         = elem[2][2]
                    vo.y         = elem[2][3]
                    table.insert(elemL, vo)
                    elem = elem[3]
                    if elem == nil then return elemL end
                end
            elseif not maps[mapid] and Config.Map[mapid] then
                maps[mapid] = 1
                for id, vo in pairs(Config.Map[mapid].unit_list) do
                    table.insert(elemL, {id, vo, elem})
                end
            end
        end
    end
    return nil
end

function Astar:nextPos(x, y, dir)
    if dir == DirType.Top then
        return {
            {x, y - 1, DirType.Top, TB_COST}
            ,{x - 1, y - 1, DirType.LeftTop, DIAG_COST}
            ,{x + 1, y - 1, DirType.RightTop, DIAG_COST}
            ,{x - 1, y, DirType.Left, LR_COST}
            ,{x + 1, y, DirType.Right, LR_COST}
        }
    elseif dir == DirType.Bottom then
        return {
            {x, y + 1, DirType.Bottom, TB_COST}
            ,{x - 1, y + 1, DirType.LeftBottom, DIAG_COST}
            ,{x + 1, y + 1, DirType.RightBottom, DIAG_COST}
            ,{x - 1, y, DirType.Left, LR_COST}
            ,{x + 1, y, DirType.Right, LR_COST}
        }
    elseif dir == DirType.Left then
        return {
            {x - 1, y, DirType.Left, LR_COST}
            ,{x - 1, y - 1, DirType.LeftTop, DIAG_COST}
            ,{x - 1, y + 1, DirType.LeftBottom, DIAG_COST}
            ,{x, y - 1, DirType.Top, TB_COST}
            ,{x, y + 1, DirType.Bottom, TB_COST}
        }
    elseif dir == DirType.Right then
        return {
            {x + 1, y, DirType.Right, LR_COST}
            ,{x + 1, y - 1, DirType.RightTop, DIAG_COST}
            ,{x + 1, y + 1, DirType.RightBottom, DIAG_COST}
            ,{x, y - 1, DirType.Top, TB_COST}
            ,{x, y + 1, DirType.Bottom, TB_COST}
        }
    elseif dir == DirType.LeftTop then
        return {
            {x - 1, y - 1, DirType.LeftTop, DIAG_COST}
            ,{x - 1, y, DirType.Left, LR_COST}
            ,{x, y - 1, DirType.Top, TB_COST}
            ,{x - 1, y + 1, DirType.LeftBottom, DIAG_COST}
            ,{x + 1, y - 1, DirType.RightTop, DIAG_COST}
        }
    elseif dir == DirType.RightTop then
        return {
            {x + 1, y - 1, DirType.RightTop, DIAG_COST}
            ,{x + 1, y, DirType.Right, LR_COST}
            ,{x, y - 1, DirType.Top, TB_COST}
            ,{x - 1, y - 1, DirType.LeftTop, DIAG_COST}
            ,{x + 1, y + 1, DirType.RightBottom, DIAG_COST}
        }
    elseif dir == DirType.LeftBottom then
        return {
            {x - 1, y + 1, DirType.LeftBottom, DIAG_COST}
            ,{x - 1, y, DirType.Left, LR_COST}
            ,{x, y + 1, DirType.Bottom, TB_COST}
            ,{x - 1, y - 1, DirType.LeftTop, DIAG_COST}
            ,{x + 1, y + 1, DirType.RightBottom, DIAG_COST}
        }
    elseif dir == DirType.RightBottom then
        return {
            {x + 1, y + 1, DirType.RightBottom, DIAG_COST}
            ,{x + 1, y, DirType.Right, LR_COST}
            ,{x, y + 1, DirType.Bottom, TB_COST}
            ,{x - 1, y + 1, DirType.LeftBottom, DIAG_COST}
            ,{x + 1, y - 1, DirType.RightTop, DIAG_COST}
        }
    else
        return {
            {x - 1, y, DirType.Left, LR_COST}
            ,{x + 1, y, DirType.Right, LR_COST}
            ,{x, y - 1, DirType.Top, TB_COST}
            ,{x, y + 1, DirType.Bottom, TB_COST}
            ,{x - 1, y - 1, DirType.LeftTop, DIAG_COST}
            ,{x - 1, y + 1, DirType.LeftBottom, DIAG_COST}
            ,{x + 1, y - 1, DirType.RightTop, DIAG_COST}
            ,{x + 1, y + 1, DirType.RightBottom, DIAG_COST}
        }
    end
end

function Astar:print()
    local point = self.path
    while point do 
        Debug.log("x="..point.x, "y="..point.y, "n="..point.n, "dir="..point.dir, "g="..point.g)
        point = point.parent
    end
end

function Astar:showUI()
    if not self.show_ui then return end
    if not self.layer then 
        self.layer = ccui.Widget:create()
    end
    local path1 = self:getPath()
    local path2 = self:floyd()
    local function isPath(path, x, y)
        for _, p in pairs(path) do 
            if p.x == x and y == p.y then
                return p
            end
        end
        return false
    end
    self.layer:removeAllChildren()
    local drawline = cc.DrawNode:create()
    self.layer:addChild(drawline)
    local w, h = TileUtil.tileWidth, TileUtil.tileHeight
    local linecolor = cc.c4f(0, 0, 0.8, 0.5)
    for y = 1, self.max_y do 
        drawline:drawLine(cc.p(0,y*h), cc.p(self.max_x*w, y*h), linecolor)
    end
    for x = 1, self.max_x do 
        drawline:drawLine(cc.p(x*w, 0), cc.p(x*w, self.max_y*h), linecolor)
    end
    local color,p,txt
    for y, v in pairs(self.block) do
        for x, i in pairs(v) do
            color = nil -- cc.c4f(0, 0, 0, 0)
            p = nil
            if isPath(path2, x, y) then 
                color = cc.c4f(0, 1, 0, 0.7)
                p = self.all_point[x] and self.all_point[x][y] or nil
            elseif isPath(path1, x, y) then 
                color = cc.c4f(0, 1, 0, 0.2)
                p = self.all_point[x][y]
            elseif self.all_point[x] and self.all_point[x][y] then
                p = self.all_point[x][y]
                if p.close then 
                    color = cc.c4f(1, 1, 0, 0.6)
                else
                    color = cc.c4f(0, 0, 1, 0.5)
                end
            elseif self:isBlock(x, y) then 
                color = cc.c4f(1, 0, 0, 0.4)
            end
            if color then
                drawline:drawSolidRect(cc.p((x -1) * w, (y-1) * h), cc.p(x*w, y*h), color)
            end
            if SHOW_TXT and p then
                txt = createWithSystemFont("", DEFAULT_FONT, 10)
                self.layer:addChild(txt)
                txt:setString(p.f.."_"..p.n)
                txt:setAnchorPoint(0, 0)
                txt:setPosition((x-1)*w + 1, (y-1)*h+2)
            end
        end
    end
end
