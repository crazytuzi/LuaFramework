-- Filename: FindTreasureData.lua
-- Author: bzx
-- Date: 2014-06-14
-- Purpose: 寻龙探宝工具类

module("FindTreasureData", package.seeall)

require "db/DB_Explore_long_event"
require "db/DB_Explore_long_event_shop"
require "db/DB_Normal_config"
require "db/DB_Item_normal"
require "db/DB_Explore_long"
local _map_info
local _rows = 7
local _cols
local _formation_info
local _formation_remain_hp
local _move_data
local _aiDoData
local _mapDb = parseDB(DB_Explore_long.getDataById(1))
local _fightBossResult
local _itemResetCount = 0

function parseMapInfo(map_info)
    _map_info = map_info
    _map_info.posid = tonumber(_map_info.posid) + 1
    _map_info.floor = tonumber(_map_info.floor)
    _map_info.resetnum = tonumber(_map_info.resetnum)
    _map_info.act = tonumber(_map_info.act)
    _map_info.point = tonumber(_map_info.point) or 0
    _map_info.hppool = tonumber(_map_info.hppool)
    _map_info.total_point = tonumber(_map_info.total_point)
    _map_info.buyactnum = tonumber(_map_info.buyactnum)
    _map_info.buyhpnum = tonumber(_map_info.buyhpnum)
    _map_info.free_reset_num = tonumber(_map_info.free_reset_num)
    _map_info.free_ai_num = tonumber(_map_info.free_ai_num)
    _map_info.once_max_point = tonumber(_map_info.once_max_point) or 0
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
        if event_info.eid == 18000 then
            print(_map_info.posid, i - 1)
        end
        if event_info.eid == 18000 and _map_info.posid == i then
            event_info.status = {"1", "0", "0", "1"}
        end

        if event_db.exploreType == 8 and _map_info.posid == i then
            local armyids = getTrialArmyIds(event_db.id)
            if #armyids <= tonumber(_move_data.other.defeated or -1) + 1 then
                event_info.status = {"1", "0", "0", "1"}
            end
        end
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
    print("aaaaaaaaaaaa")
    -- print("getTotalPoint: ",_map_info.total_point,_map_info.point)
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

function getMapDb( ... )
    return _mapDb
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

function addPoint(add_point)
    _map_info.point = _map_info.point + add_point
    _map_info.total_point = _map_info.total_point + add_point
end

function getHightestPoint( ... )
    print("===========")
    print(_map_info.point, _map_info.once_max_point)
    local hightest = _map_info.once_max_point
    if hightest < _map_info.point then
        hightest = _map_info.point
    end
    return hightest
end

function isFirstTime( ... )
    local key = getFirstTimeKey()
    local localGetMap = CCUserDefault:sharedUserDefault():getBoolForKey(key)
    return getHightestPoint() == 0 and localGetMap == false
end

function getFirstTimeKey( ... )
    return string.format("dragon.getMap%s%s", tostring(UserModel.getUserUid()), tostring(ServerList.getSelectServerInfo().group))
end

function setFirstTime( isFirstTime )
    local key = getFirstTimeKey()
    if isFirstTime == false then
        CCUserDefault:sharedUserDefault():setBoolForKey(key, true)
    else
        CCUserDefault:sharedUserDefault():setBoolForKey(key, false)
    end
    CCUserDefault:sharedUserDefault():flush()
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

function getFightBossResult(  )
    return _fightBossResult
end

function setFightBossResult( fightBossResult )
    _fightBossResult = fightBossResult
end

function getMoveData()
   return _move_data
end

function setAiDoData(aiDoData)
    _aiDoData = aiDoData
end

function getAiDoData(  )
    return _aiDoData
end

-- 地图
function handleGetMap( dictData )
    parseMapInfo(dictData.ret)
end

-- 移动
function handleMove( dictData, nextPlayerIndex)
    if dictData.ret == "" then
        dictData.ret = {}
    end
    dictData.ret = dictData.ret or {}
    local mapInfo = _map_info
    local event_info = mapInfo.map[nextPlayerIndex]
    local event_db = parseDB(DB_Explore_long_event.getDataById(event_info.eid))
    if dictData.ret.point == nil then
        if event_db.exploreConditions[1] == 10 and event_info.status[1] ~= "1" and event_info.status[2] ~= "1" then
            mapInfo.point = mapInfo.point + event_db.integralReward[2]
        end
    end
    mapInfo.hasmove = "1"
    if event_db.id == 18000 then
        event_info.status[1] = "1"
        event_info.status[4] = "1"
    end
    if dictData.ret.act ~= nil then
        _map_info.act = tonumber(dictData.ret.act)
    end
    if dictData.ret.hppool ~= nil then
        _map_info.hppool = tonumber(dictData.ret.hppool)
    end
    if dictData.ret.point ~= nil then
        _map_info.point = tonumber(dictData.ret.point)
    end
    if dictData.ret.total_point ~= nil then
        _map_info.total_point = tonumber(dictData.ret.total_point)
    end
    _move_data = dictData.ret
    _move_data.other = _move_data.other or {}
end

function isFreeAutoFind( ... )
    return LoyaltyData.isFunOpen(2)
end

function getExtraPoint( ... )
    require "script/ui/star/loyalty/LoyaltyData"
    require "db/DB_Hall_loyalty"
    local extraPoint = 0
    -- 聚义堂额外积分
    local dataArray = DB_Hall_loyalty.getArrDataByField("type", 1)
    for i = 1, #dataArray do
        if LoyaltyData.isFunOpen(1, dataArray[i].id) then
            local point = tonumber(dataArray[i].num)
            extraPoint = extraPoint + point
        end
    end

    return extraPoint
end

function getShopData( eventDb )
    local shopData = {}
    local goodsId = parseField(eventDb.goodsid, 1)
    _move_data.other.bought = _move_data.other.bought or {}
    for i = 1, #goodsId do
        local data = {}
        data.id = goodsId[i]
        local bought = false
        for ii = 1, #_move_data.other.bought do
            if tonumber(_move_data.other.bought[ii]) == i - 1 then
                bought = true
                break
            end
        end
        data.bought = bought
        table.insert(shopData, data)
    end
    return shopData
end

function getTrialArmyIds( eventId )
    local eventDb = DB_Explore_long_event.getDataById(eventId)
    local armyids = parseField(eventDb.armyid, 1)
    return armyids
end

function getDropItem(dictData)
    local items = {}
    if dictData.ret.other.drop == nil  or dictData.ret.other.drop.item == nil then
        return items
    end
    for k, v in pairs(dictData.ret.other.drop.item) do
        local item = {}
        item.item_template_id = tonumber(k)
        item.item_num = tonumber(v)
        table.insert(items, item)
    end
    return items
end

function initItemResetCount( ... )
    local resetItemInfo = FindTreasureData.getResetItemInfo()
    _itemResetCount = math.floor(ItemUtil.getCacheItemNumBy(resetItemInfo[1]) / resetItemInfo[2])
    return _itemResetCount
end

function addItemResetCount( p_count )
    _itemResetCount = _itemResetCount + p_count
end

function getItemResetCount( ... )
    return _itemResetCount
end

function getResetItemInfo( ... )
    local normalConfigDb = DB_Normal_config.getDataById(1)
    local resetItemInfo = parseField(normalConfigDb.long_return)
    return resetItemInfo
end

-- 选择试炼模式的积分条件
function getHightModePoinCondition( ... )
    return DB_Normal_config.getDataById(1).explorelongtestneed
end

-- 自动寻路
function handleAutoMove( dictData )
end

-- 自动探宝
function handleAiDo( dictData, autoGoldCount, autoActCount, selectedBoxIndex, selectedFloorIndex )
    UserModel.addGoldNumber(-autoGoldCount)
    local data = dictData.ret
    data.act = autoActCount
    data.selected_box_index = selectedBoxIndex
    data.selected_floor_start_index = selectedFloorIndex
    data.selected_floor_end_index = selectedFloorIndex
    FindTreasureData.setAiDoData(data)
end

-- 重置
function handleReset( dictData )
    parseMapInfo(dictData.ret)
    local mapInfo = _map_info
    if mapInfo.resetnum > 0 then
        UserModel.addGoldNumber(-_mapDb.resetPay)
    end
end

-- 买血
function handleBuyHp( dictData, mapDb, buyHpGoldCount )
    local mapInfo = FindTreasureData.getMapInfo()
    UserModel.addGoldNumber(-buyHpGoldCount)
    mapInfo.hppool = tonumber(dictData.ret)
    mapInfo.buyhpnum = mapInfo.buyhpnum + 1
    if mapInfo.hppool == 0 then
        FindTreasureData.setFormationHp(mapDb.hpPay[2] / 100 * FindTreasureData.getFormationMaxHp())
    end
end

-- 贿赂
function handleBribe( dictData, event )
    UserModel.addGoldNumber(-event.completePay)
    FindTreasureData.addPoint(event.integralReward[8][2])
end

-- 买行动力
function handleBuyAct( dictData, buyActTotalGoldCount, buyActCount )
    UserModel.addGoldNumber(-buyActTotalGoldCount)
    local mapInfo = getMapInfo()
    mapInfo.act = mapInfo.act + buyActCount
    mapInfo.buyactnum = mapInfo.buyactnum + buyActCount
end

-- 战斗
function handleFight( dictData )
    setHpPool(tonumber(dictData.ret.hppool))
    refreshFormationHp(dictData.ret.arrhp)
end

-- 获取阵型
function handleGetUserBf( dictData, resetData )
    setFormationInfo(dictData.ret)
    if resetData ~= nil then
        parseMapInfo(resetData.dictData.ret)
    end
end

-- 一键答题
function handleOnekey( dictData, event )
    UserModel.addGoldNumber(-event.completePay)
    addPoint(event.integralReward[1][2])
end

-- 答题
function handleAnswer( dictData, event )
    local add_point = 0
    if dictData.ret == "true" or dictData.ret == true then
        add_point = event.integralReward[1][2]
    elseif dictData.ret == "false" or dictData.ret == true then
        add_point = event.integralReward[2][2]
    end
    addPoint(add_point)
    return add_point
end

-- 跳过
function handleSkip( dictData )
    local eventInfo = _map_info.map[_map_info.posid]
    print("handleSkip")
    print_t(eventInfo)
    eventInfo.status[4] = "1"
    print_t(eventInfo)
end

-- 购买商品
function handleBuyGood(dictData, eventShopDb)
    UserModel.addGoldNumber(-eventShopDb.nowcost)
    addPoint(eventShopDb.eachpoint)
end

-- 捐献物品
function handleContribute( dictData, eventShopDb, itemId, itemCount)
    _move_data.other.conNum = tonumber(_move_data.other.conNum) + 1
    addPoint(eventShopDb.eachpoint)
    ItemUtil.addItemCountByID(itemId, -itemCount)
end

-- 打试炼boss
function handleFightBoss( dictData, bossIndex,eventDb)
    local isWin = dictData.ret.atkRet.server.appraisal ~= "E" and dictData.ret.atkRet.server.appraisal ~= "F"
    if isWin == true then
        handleDirectBoss(bossIndex, eventDb)
    end
end

-- 试炼直接胜利
function handleDirectBoss(bossIndex, eventDb)
    _move_data.other.defeated = bossIndex
    _map_info.act = parseField(eventDb.bosscost, 1)[bossIndex]
    _map_info.point = parseField(eventDb.bossscore, 1)[_curIndex]
end
-- 进入试炼
function handleTrial( dictData )
    handleGetMap(dictData)
end
