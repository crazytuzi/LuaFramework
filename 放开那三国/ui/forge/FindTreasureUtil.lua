-- Filename: FindTreasureUtil.lua
-- Author: bzx
-- Date: 2014-06-14
-- Purpose: 寻龙探宝工具类

module("FindTreasureUtil", package.seeall)

require "db/DB_Explore_long_event"

local _map_info
local _rows = 7
local _cols
local _formation_info
local _formation_remain_hp
local _move_data

function parseMapInfo(map_info)
    _map_info = map_info
    _map_info.posid = tonumber(_map_info.posid) + 1
    _map_info.floor = tonumber(_map_info.floor)
    _map_info.resetnum = tonumber(_map_info.resetnum)
    _map_info.act = tonumber(_map_info.act)
    _map_info.point = tonumber(_map_info.point)
    _map_info.hppool = tonumber(_map_info.hppool)
    _map_info.total_point = tonumber(_map_info.total_point)
    _map_info.buyactnum = tonumber(_map_info.buyactnum)
    _map_info.buyhpnum = tonumber(_map_info.buyhpnum)
    _map_info.free_reset_num = tonumber(_map_info.free_reset_num)
    _map_info.free_ai_num = tonumber(_map_info.free_ai_num)
    print("hasmove=", _map_info.hasmove)
    print("reset_fucn=", _map_info.free_reset_num)
    _move_data = {}
    _move_data.other = _map_info.movedata
    print("mapInfo")
    print_t(_map_info.movedata)
    local block_count = #_map_info.map
    _cols = math.ceil(block_count / _rows)
    _map_info.block_count = block_count
    for i = 1, #_map_info.map do
        local event_info = _map_info.map[i]
        event_info.eid = tonumber(event_info.eid)
        event_info.status = event_info.status
        print("eventid = ", event_info.eid)
        local event_db = parseDB(DB_Explore_long_event.getDataById(event_info.eid))
        -- display -- 0消失 1强制显示 2有迷雾, 3没有迷雾且不强制显示
        if event_info.status[1] == "1" then  -- 事件触发了
            if event_info.eid ~= 0 then
                event_info.display = 0
            else
                event_info.display = 1
            end
        elseif event_info.status[1] == "0" then -- 事件没有触发
            if event_info.status[2] == "1" then -- 炸掉了
                event_info.display = 0
            end
            if event_info.display == nil then
                if event_db.isShow == 1 then
                    event_info.display = 1
                else
                    event_info.display = 2
                end
            end
        end
        if event_db.exploreConditions[1] == 9 and event_info.status[1] == "1" then -- 指路
            showAllBlock()
            --[[
            local display_index = event_db.exploreConditions[2]
            if _map_info.map[display_index - 1].display ~= 0 then
                _map_info.map[display_index - 1].display = 1
            end
            --]]
        end
    end
    setPlayerIndex(_map_info.posid)
    return _map_info
end

function getMapInfo()
    return _map_info
end

function getTotalPoint()
    --print("getTotalPoint: ",_map_info.total_point,_map_info.point)
    return _map_info.total_point
end

function setPlayerIndex(index)
    local directions = {1, 2, 3, 4, 6, 7, 8, 9}
    for i = 1, #directions do
        local direction = directions[i]
        local block_index = getIndexByDirection(direction, _map_info.posid)
        if block_index ~= nil then
            if _map_info.map[block_index].display == 3 then
                _map_info.map[block_index].display = 2
            end
        end
    end
    _map_info.posid = index
    
    for i = 1, #directions do
        local direction = directions[i]
        local block_index = getIndexByDirection(direction, _map_info.posid)
        if block_index ~= nil then
            if _map_info.map[block_index].display == 2 then
                _map_info.map[block_index].display = 3
            end
        end
    end
end

function getIndexByDirection(direction, refer_index)
    local index = nil
    if direction == 1 then
        index = refer_index - _rows - 1
    elseif direction == 2 then
        index = refer_index - _rows
    elseif direction == 3 then
        index = refer_index - _rows + 1
    elseif direction == 4 then
        index = refer_index - 1
    elseif direction == 6 then
        index = refer_index + 1
    elseif direction == 7 then
        index = refer_index + _rows - 1
    elseif direction == 8 then
        index = refer_index + _rows
    elseif direction == 9 then
        index = refer_index + _rows + 1
    end
    if index >= 1 and index <= #_map_info.map then
        local direction_temp = getRelativePosition(index, refer_index)
        if direction_temp == direction then
            return index
        end
    end
end

function bomb(index)
    print("index=", index)
    local event_db = parseDB(DB_Explore_long_event.getDataById(_map_info.map[index].eid))
    local directions = {}
    local bomb_direction = event_db.exploreConditions[2]
    if bomb_direction  == 1 then
        directions = {4}
    elseif bomb_direction  == 2 then
        directions = {4, 8}
    elseif bomb_direction  == 3 then
        directions = {4, 8, 6}
    elseif bomb_direction  == 4 then
        directions = {4, 8, 6, 2}
    end
    for i = 1, #directions do
        local direction = directions[i]
        local bomb_index = getIndexByDirection(direction, index)
        if bomb_index >= 1 and bomb_index <= #_map_info.map then
            local direction_temp = getRelativePosition(bomb_index, index)
            if direction_temp == direction then
                _map_info.map[bomb_index].display = 0
                _map_info.map[bomb_index].status[2] = "1"
            end
        end
    end
end

function getRelativePosition(index, refer_index)
    local row, col = getMapPosition(index)
    local refer_row, refer_col = getMapPosition(refer_index)
    local row_delta = row - refer_row
    local col_delta = col - refer_col
    local distance = math.pow(row_delta, 2) + math.pow(col_delta, 2)
    local direction = nil
    if distance <= math.pow(1.5, 2) then
        direction = (col_delta + 1) * 3 - row_delta + 2
    end
    return direction
end

function getMapPosition(index)
    local col = math.floor((index - 1) / _rows) + 1
    local row = _rows - (index - 1) % _rows
    return row, col
end

function getIndex(col, row)
    local index = -1
    if col >= 1 and col <= _cols and row >= 1 and row <= _rows then
        index = col * _rows - row + 1
    end
    return index
end

function getCols()
    return _cols
end

function getRows()
    return _rows
end

function setFormationInfo(formation_info)
    _formation_info = formation_info
    _formation_remain_hp = 0
    for k, v in pairs(_formation_info.arrHero) do
        local hero_info = v
        _formation_remain_hp = _formation_remain_hp + tonumber(hero_info.currHp)
    end
    _formation_remain_hp = _formation_remain_hp
end

function getFormationMaxHp()
    local max_hp = 0
    for k, v in pairs(_formation_info.arrHero) do
        local hero_info = v
        max_hp = max_hp + tonumber(hero_info.maxHp)
    end
    return max_hp
end

function refreshFormationHp(cur_hp)
    _formation_remain_hp = 0
    for k, v in pairs(_formation_info.arrHero) do
        local hero_info = v
        if cur_hp[hero_info.hid] ~= nil then
            hero_info.curHp = cur_hp[hero_info.hid]
            _formation_remain_hp = _formation_remain_hp + tonumber(cur_hp[hero_info.hid])
            print(tonumber(cur_hp[hero_info.hid]))
        end
    end
end

function getFormationInfo()
    return _formation_info
end

function getFormationHp()
    return _formation_remain_hp
end

function setFormationHp(formation_remain_hp)
    _formation_remain_hp = formation_remain_hp
end

function handleMove(data)
    local ret = false
    if data.act ~= nil then
        _map_info.act = tonumber(data.act)
        ret = true
    end
    if data.hppool ~= nil then
        _map_info.hppool = tonumber(data.hppool)
        ret = true
    end
    if data.point ~= nil then
        _map_info.point = tonumber(data.point)
        ret = true
    end
    if data.total_point ~= nil then
        _map_info.total_point = tonumber(data.total_point)
        ret = true
    end
    _move_data = data
    return ret
end

function addPoint(add_point)
    _map_info.point = _map_info.point + add_point
    _map_info.total_point = _map_info.total_point + add_point
end

function subPoint(sub_point)
    _map_info.total_point = _map_info.total_point - sub_point
end

function setHpPool(hp_pool)
    _map_info.hppool = hp_pool
end

function showAllBlock()
     for i = 1, #_map_info.map do
        local event_info = _map_info.map[i]
        event_info.eid = tonumber(event_info.eid)
        event_info.status = event_info.status
        local event_db = parseDB(DB_Explore_long_event.getDataById(event_info.eid))
        -- display -- 0消失 1强制显示 2有迷雾, 3没有迷雾且不强制显示
        if event_info.status[1] ~= "1" and event_info.status[2] ~= "1" then
            event_info.display = 1
        end
    end
end

function getMoveData()
   return _move_data
end