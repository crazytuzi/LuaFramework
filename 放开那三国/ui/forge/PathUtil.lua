-- Filename: PathUtil.lua
-- Author: bzx
-- Date: 2014-07-01
-- Purpose: 寻路

module("PathUtil", package.seeall)

local _map_data         -- 地图数据
local _open_list        -- 开放节点
local _open_map         -- 开放节点，为了提高性能而加
local _close_map        -- 关闭节点
local _deleget          -- 代理
local _dest_point       -- 目标点
local _start_point      -- 起点
local _path             -- 路径

-- 寻找路径
--[[
deleget = {
    g = function(point1, point2)
        -- add your code
        -- 返回点point1到点point2的实际代价
    end
    h = function(point1, point2)
        -- add your code
        -- 返回点point1到点point2的估算代价
    end
    getValue = function(j, i)
        -- 返回地图中第i行，第j列的数据 1为障碍物，0为非障碍物
    end
    width -- 地图宽度
    height -- 地图高度
}
--]]
function findPath(deleget, start_point, dest_point)
    _deleget = deleget
    _dest_point = dest_point
    _start_point = start_point
    init()
    while not table.isEmpty(_open_list) do
        local cur_point = _open_list[1]
        table.remove(_open_list, 1)
        _open_map[cur_point.key] = nil
        if isEqual(cur_point, dest_point) then
            return makePath(cur_point)
        else
            _close_map[cur_point.key] = cur_point
            local next_points = getNextPoints(cur_point)
            for i = 1, #next_points do
                local next_point = next_points[i]
                if _open_map[next_point.key] == nil and _close_map[next_point.key] == nil and isObstacle(next_point) == false then
                    _open_map[next_point.key] = next_point
                    table.insert(_open_list, next_point)
                end
            end
            table.sort(_open_list, compareF)
        end
    end
    return nil
end

function init()
    _open_list = {}
    _open_map = {}
    _close_map = {}
    _path = {}
    _map_data = {}
    for i = 1, _deleget.height do
        _map_data[i] = {}
        for j = 1, _deleget.width do
            local value = _deleget.getValue(j, i)
            _map_data[i][j] = value
        end
    end
    _open_map[getKey(_start_point)] = _start_point
    table.insert(_open_list, _start_point)
end

function createPoint(x, y)
    local point = {
        ["x"] = x,
        ["y"] = y,
        ["last"] = nil,
        ["g_value"] = 0,
        ["h_value"] = 0,
        ["f_value"] = 0
    }
    point["key"] = getKey(point)
    return point
end

-- 得到下一个可以移动的点
-- @param point 当前所在点
function getNextPoints(point)
    local next_points = {}
    for i = 1, #_deleget.directions do
        local offset = _deleget.directions[i]
        local next_point = createPoint(point.x + offset[1], point.y + offset[2])
        next_point["last"] = point
        if next_point.x >= 1 and next_point.x <= _deleget.width and next_point.y >= 1 and next_point.y <= _deleget.height then
            next_point["g_value"] = _deleget.g(point, next_point)
            next_point["h_value"] = _deleget.h(point, _dest_point)--math.abs(next_points.x - _dest_point.x) + math.abs(next_points.y - _dest_point.y)
            next_point["f_value"] = next_point.g_value + next_point.h_value
            table.insert(next_points, next_point)
        end
    end
    return next_points
end

-- 得到路径
-- @param end_point 目标点
function makePath(end_point)
    _path = {}
    local point = end_point
    while point.last ~= nil do
        table.insert(_path, createPoint(point.x, point.y))
        point = point.last
    end
    local start_point = point
    table.insert(_path, start_point)
    return _path
end

-- 两个点的代价比较器
function compareF(point1, point2)
    return point1.f_value < point2.f_value
end

-- 是否是障碍物
function isObstacle(point)
    local value = _map_data[point.y][point.x]
    if value == 1 then
        return true
    end
    return false
end

-- 两个点是否是同一个点
function isEqual(point1, point2)
    return point1.key == point2.key
end

-- 根据点得到点的key
function getKey(point)
    local key =  string.format("%d,%d", point.x, point.y)
    return key
end