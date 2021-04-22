--
-- Author: wkwang
-- Date: 2014-08-14 15:26:46
-- 福利副本数据管理

local QBaseModel = import("...models.QBaseModel")
local QWelfareInstance = class("QWelfareInstance", QBaseModel)
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QVIPUtil = import("...utils.QVIPUtil")

QWelfareInstance.WEI_KAI_QI   = "0"
QWelfareInstance.KE_JIAO_ZHAN = "1"
QWelfareInstance.YI_TONG_GUAN = "2"

QWelfareInstance.WU_BAO_XIANG = "10"
QWelfareInstance.WEI_JI_HUO   = "11"
QWelfareInstance.KE_KAI_QI    = "12"
QWelfareInstance.YI_KAI_QI    = "13"

function QWelfareInstance:ctor()
    QWelfareInstance.super.ctor(self)
    --[[

    _welfareInfo = {
        1:{
            instance_id: map1_5
            int_instance_id: 100105
            instance_name: 哀嚎上
            instance_type: 5
            unlock_dungeon_id ：wailing_caverns_1
            unlock_instance_name ：哀嚎上（精英）
            file: ccb/Widget_EliteMap1.ccbi
            state:0 --非量表属性。0 - 未开启；1 - 可交战；2 - 已通关
            dungeons:{
                1:{
                    id: 257
                    dungeon_id: wailing_caverns_11_fuli
                    int_dungeon_id: 1030111
                    dungeon_type: 5
                    dungeon_isboss: false
                    monster_id: -1
                    unlock_team_level: 1
                    attack_num: 99
                    dungeon_icon: icon/head/ectoplasm.png
                    state:0 --非量表属性。0 - 未开启；1 - 可交战；2 - 已通关
                    boxState:0 --非量表属性。10 - 无宝箱；11 - 未激活；12 - 可开启；13 - 已开启
                }
                2:{
                    id: 257
                    dungeon_id: wailing_caverns_12_fuli
                    int_dungeon_id: 1030112
                    dungeon_type: 5
                    dungeon_isboss: true
                    monster_id: 40144
                    unlock_team_level: 1
                    attack_num: 99
                    dungeon_icon: icon/head/ectoplasm.png
                    state:0 --非量表属性。0 - 未开启；1 - 可交战；2 - 已通关
                    boxState:0 --非量表属性。10 - 无宝箱；11 - 未激活；12 - 可开启；13 - 已开启
                    lastPassAt:4123984712947
                    bossBoxOpened:true
                }
            }
            grottos:{
                1:{
                    id: 257
                    instance_id: map1_5
                    int_instance_id: 100105
                    instance_name: 哀嚎上
                    dungeon_id: wailing_caverns_11_fuli
                    int_dungeon_id: 1030111
                    dungeon_type: 6
                    dungeon_isboss: true
                    monster_id: -1
                    unlock_team_level: 1
                    unlock_dungeon_id ：wailing_caverns_1_fuli
                    attack_num: 99
                    dungeon_icon: icon/head/ectoplasm.png
                    file: ccb/Widget_EliteMap1.ccbi
                    state:0 --非量表属性。0 - 未开启；1 - 可交战；2 - 已通关
                } 
            }
        }
    }

    ]]
    self._welfareInfo = {}
    --[[

    _elitePassInfo = {
        1:{
            instance_id:map1_5
            int_instance_id:100105
            instance_name:哀嚎上
            dungeons:{
                1:1030101
                2:1030102
                3:1030103
                4:1030104
                5:1030105
            }
        }
    }

    ]]

    -- self._elitePassInfo

    --[[

     _normalAndElitePassInfo = {
        wailing_caverns_1:1446189553121
        wailing_caverns_2:1446189553121
    }

    ]]
    self._normalAndElitePassInfo = {}
    -- print("[Kumo] self._lastActiveInstance 初始化")
    self._lastActiveInstance = 0 -- 根据每个章节的解锁条件，当相应的精英副本通关，相应激活福利副本章节  0 - 没有已经开启的章节； 1 - _welfareInfo[1] 开启； 2 - _welfareInfo[2] 开启
    self._lastPassInstance = 0 -- 记录福利副本通关情况  0 - 没有全部通关的章节； 1 - _welfareInfo[1] 全部通关； 2 - _welfareInfo[2] 全部通关
    self._passCount = 0
    self._passProgress = 0
    self._totalInstanceCount = 0
    self.isShowInstanceRedPoint = false --主场景instance是否显示小红点
end

function QWelfareInstance:init()
    self._remoteProexy = cc.EventProxy.new(remote.user)
    self._remoteProexy:addEventListener(remote.user.EVENT_USER_PROP_CHANGE, function ()
        self:_checkWelfareUnlock()
    end)
    self:_initInstanceInfo()
end

function QWelfareInstance:disappear()
    if self._remoteProexy ~= nil then 
        self._remoteProexy:removeAllEventListeners()
        self._remoteProexy = nil
    end
end

function QWelfareInstance:_initInstanceInfo()
    self._config = QStaticDatabase:sharedDatabase():getMaps()
    -- table.sort( self._config, function(a, b) return a.id < b.id end ) --按照id升序
    self._isFirstWin = false
    -- print("[Kumo] welfareInfo's length is " .. table.nums(self._welfareInfo))
    if table.nums(self._welfareInfo) == 0 then
        local curInstanceID = -1
        local instanceTable = {}
        local total = table.nums(self._config)
        for i = 1, total, 1 do
            local config = self._config[tostring(i)]
            local curType = tonumber(config.dungeon_type)
            if curType == DUNGEON_TYPE.GROTTO or curType == DUNGEON_TYPE.WELFARE then
                config = q.cloneShrinkedObject(config)
                if curInstanceID ~= config.int_instance_id then
                    -- instance id 和前面一个config不一样
                    local isFind = false
                    if table.nums(self._welfareInfo) > 0 then
                        -- 先判断这个config的instance id之前有没有出现过，如果出现过，则直接加到info里去
                        for _, value in pairs(self._welfareInfo) do
                            if value.int_instance_id == config.int_instance_id then
                                self:_analyseConfigAboutInstance( value, config )
                                isFind = true
                                break
                            end
                        end
                    end
                    if not isFind then
                        -- 新的章节，重新建立一个新的table，或，第一次
                        if table.nums(instanceTable) > 0 then
                            table.insert(self._welfareInfo, instanceTable)
                        end
                        instanceTable = {}
                        curInstanceID = config.int_instance_id
                        self:_analyseConfigAboutInstance( instanceTable, config )
                    end
                else
                    self:_analyseConfigAboutInstance( instanceTable, config )
                end
            end
        end
        -- 最后一次
        if table.nums(instanceTable) > 0 then
            table.insert(self._welfareInfo, instanceTable)
            instanceTable = {}
        end
        -- QPrintTable(self._welfareInfo)
        -- print("The number in welfare map is : " .. table.nums(self._welfareInfo))
    end

    self:_checkWelfareUnlock(true)
end

-------------------------------------------------API-------------------------------------------------

function QWelfareInstance:getWelfareInfo( index )
    if not index or index == 0 then
        return self._welfareInfo
    else
        return self._welfareInfo[index]
    end
end

function QWelfareInstance:getLastActiveInstance()
    -- print("QWelfareInstance._lastActiveInstance = ".. self._lastActiveInstance)
    return self._lastActiveInstance
end

-- function QWelfareInstance:getLastPassInstance()
--     print("QWelfareInstance._lastPassInstance = ".. self._lastPassInstance)
--     return self._lastPassInstance
-- end

function QWelfareInstance:getCurrentInstanceIndex()
    if self._lastActiveInstance > self._lastPassInstance then
        return self._lastPassInstance + 1
    else
        return self._lastPassInstance
    end
end

function QWelfareInstance:getNextInstanceIndex()
    if self._lastActiveInstance > self._lastPassInstance then
        return self._lastPassInstance + 2
    else
        return self._lastPassInstance + 1
    end
end

function QWelfareInstance:getTotalOpenedInstanceCount()
    -- print(self._lastActiveInstance, self._lastPassInstance)
    if self._lastActiveInstance > self._lastPassInstance then
        return self._lastPassInstance + 1
    else
        return self._lastPassInstance
    end
end

function QWelfareInstance:getExplanationText( index )
    if index > self._totalInstanceCount then 
        print("无法搜索到第",index,"章节的信息，请检查量表！") 
        return "敬请期待"
    end
    local text = ""
    local str = ""
    print("开启条件的判断：", self._lastActiveInstance, self._lastPassInstance, index)
    if self._lastActiveInstance - self._lastPassInstance > 1 then
        -- str = self._welfareInfo[index - 1].instance_name
        return text
    else
        str = self._welfareInfo[index].unlock_instance_name
    end
    -- print(str, string.find(str, " "), string.len(str))
    local start = string.find(str, " ")
    start = (start or 0) + 1
    -- local len = string.len(str)
    text = "通关" .. string.sub(str, start, -1) .. "章节后开启"
    print(text)
    return text
end

function QWelfareInstance:getInstanceNameByIndex( index )
    return self._welfareInfo[index].instance_name
end

function QWelfareInstance:isThisInstanceAllPass( index )
    return self:_isThisInstanceAllPass( index )
end

function QWelfareInstance:getCurrentDungeonID()
    local currentIndex = self:getCurrentInstanceIndex()
    local dungeons = self._welfareInfo[currentIndex].dungeons
    for i = 1, table.nums(dungeons), 1 do
        if dungeons[i].state == QWelfareInstance.WEI_KAI_QI then
            if i > 1 then return dungeons[i - 1].dungeon_id end
            return dungeons[i].dungeon_id
        end
    end
    return dungeons[#dungeons].dungeon_id --最后一关，已经开启了，但没有通关的时候。
end

function QWelfareInstance:getFirstWinConfig()
    local currentIndex = self:getCurrentInstanceIndex()
    local dungeons = self._welfareInfo[currentIndex].dungeons
    local id = ""
    -- QPrintTable(dungeons)
    for i = 1, table.nums(dungeons), 1 do
        if dungeons[i].state == QWelfareInstance.KE_JIAO_ZHAN then
            if i > 1 then 
                id = dungeons[i - 1].dungeon_id 
            else
                local dg = self._welfareInfo[currentIndex - 1].dungeons
                -- QPrintTable(dg)
                id = dg[#dg].dungeon_id
            end
        end
    end
    if id == "" then
        id = dungeons[#dungeons].dungeon_id --最后一关，已经开启了，但没有通关的时候。
    end
    
    -- print("[Kumo] id : ", id)
    return QStaticDatabase.sharedDatabase():getDungeonConfigByID(id).fd_item
end

function QWelfareInstance:getDungeonTypeByDungeonID( dungeon_id )
    for _, value in pairs(self._config or {}) do
        if dungeon_id == value.dungeon_id then
            return value.dungeon_type
        end 
    end

    return nil
end

function QWelfareInstance:getIntDungeonIDByDungeonID( dungeon_id )
    for _, value in pairs(self._config) do
        if dungeon_id == value.dungeon_id then
            return value.int_dungeon_id
        end 
    end
end

function QWelfareInstance:isFirstWin()
    return self._isFirstWin
end

function QWelfareInstance:isBattleWin()
    return self._isBattleWin
end

function QWelfareInstance:setIsFirstWin( b )
    self._isFirstWin = b
end

function QWelfareInstance:setBattleEnd( b )
    self._isBattleEnd = b --是否刚战斗结束
end

function QWelfareInstance:setBattleWin( b )
    self._isBattleWin = b
end

function QWelfareInstance:getBattleEnd()
    return self._isBattleEnd
end

function QWelfareInstance:canBattle()
    local leftCount = QVIPUtil:getWelfareCount() - self:getPassCount()
    if remote.activity:checkMonthCardActive(2) then
        leftCount = leftCount + 1
    end
    if leftCount > 0 then
        return true
    end
    return false
end

function QWelfareInstance:isBossBoxOpened( int_dungeon_id )
    for _, instance in pairs(self._welfareInfo) do
        for _, dungeon in pairs(instance.dungeons) do
            if dungeon.int_dungeon_id == int_dungeon_id then
                if dungeon.bossBoxOpened or dungeon.boxState == QWelfareInstance.YI_KAI_QI then
                    return true
                end
                return false
            end
        end
    end
end

function QWelfareInstance:getProgressByIndex( index )
    local totalDungeons = #self._welfareInfo[index].dungeons
    local passDungeonCount = 0
    for _, dungeon in pairs(self._welfareInfo[index].dungeons) do
        if dungeon.state == QWelfareInstance.YI_TONG_GUAN then
            passDungeonCount = passDungeonCount + 1
        end
    end

    return passDungeonCount, totalDungeons
end

function QWelfareInstance:getPassCount()
    return self._passCount
end

--[[
    检查index所指的的章节是否存在
]]
function QWelfareInstance:isInstanceExistence( index )
    self._totalInstanceCount = #self._welfareInfo
    if index > self._totalInstanceCount then return false end
    return true
end

--[[
    功能：计算史诗副本是否要显示小红点
    返回类型：boolean
]]
function QWelfareInstance:isShowRedPoint()
    if app.unlock:getUnlockWelfare() == false then return false end
    if self._lastActiveInstance == 0 then return false end
    if self._passCount < QVIPUtil:getWelfareCount() then return true end
    local _, boo = self:getDungeonRedPointList()
    return boo
end

--[[
    功能：计算福利副本一级地图里小红点
    返回类型：table，boolean
]]
function QWelfareInstance:getDungeonRedPointList()
    local tbl = {}
    local isFind = false
    for i = 1, self._lastActiveInstance, 1 do
        tbl[i] = false
        for _, dungeon in pairs(self._welfareInfo[i].dungeons) do
            if dungeon.boxState == QWelfareInstance.KE_KAI_QI then
               tbl[i] = true
               isFind = true
               break
            end
        end
    end
    -- print("福利副本一级地图小红点列表")
    -- printTable(tbl, "*")
    return tbl, isFind
end

-------------------------------------------------逻辑模块-------------------------------------------------

--[[
    普通或精英副本信息变动时更新
    QRemote:updateDate中被调用

    info = {
        1: 
        {
            lastPassAt: 1446186505915
            star: 3
            id: wailing_caverns_10
            todayPass: 1
            todayReset: 0
            bossBoxOpened: false
            starPos: 1;2;3;
        }
    }

]]   
function QWelfareInstance:updateInstanceInfo(infos)   
    local info = {}
    if infos ~= nil then 
        info = clone(infos)
    end 
    if info then
        table.sort( info, function(a, b) return a.lastPassAt < b.lastPassAt end )
    end
    local value
    if table.nums(self._normalAndElitePassInfo) == 0 then
        while true do
            value = table.remove(info, 1)
            if not value then break end
            if value.id ~= nil then
                self._normalAndElitePassInfo[value.id] = value.lastPassAt
                self:_updateWelfareInfoState( value.id, nil, value.lastPassAt, value.bossBoxOpened )
            end
        end
    else
        value = table.remove(info, #info)
        if value and value.id ~= nil then
            self._normalAndElitePassInfo[value.id] = value.lastPassAt
            self:_updateWelfareInfoState( value.id, nil, value.lastPassAt, value.bossBoxOpened )
        end
    end
    
    -- printTable(self._normalAndElitePassInfo, "*")
    self._totalInstanceCount = #self._welfareInfo
    self:_checkWelfareUnlock(true)
    self.isShowInstanceRedPoint = self:isShowRedPoint()
end

function QWelfareInstance:_updateElitePassInfo( dungeon_id )
    -- for _, value in pairs(self._config) do
    --     if dungeon_id == value.dungeon_id and value.dungeon_type == DUNGEON_TYPE.ELITE then
    --         self:analyseElitePassInfo( value )
    --         return true
    --     end
    -- end
end

--[[
    检查福利本是否解锁
]]
function QWelfareInstance:_checkWelfareUnlock(isForce)
    return app.unlock:getUnlockWelfare()
end

--[[
    通关一个福利副本，更新下状态，DUNGEON_TYPE.WELFARE 的时候，每次副本战斗结束的时候，调用更新，包括洞穴
    @dungeon_id 新通关的关卡的dungeon_id

    state:0 --非量表属性。0 - 未开启；1 - 可交战；2 - 已通关
]]
function QWelfareInstance:_updateWelfareInfoState( dungeon_id, dungeon_type, lastPassAt, bossBoxOpened )
    -- print("QWelfareInstance:_updateWelfareInfoState >>>>>>>>>>>>>")
    -- print("lastActive, lastPass, dungeon_id, dungeon_type", self._lastActiveInstance, self._lastPassInstance, dungeon_id, dungeon_type)
    -- print("QWelfareInstance:_updateWelfareInfoState <<<<<<<<<<<<<")
    if not dungeon_id then return end
    local dungeonType = dungeon_type or self:getDungeonTypeByDungeonID( dungeon_id )
    if not dungeonType or dungeonType == DUNGEON_TYPE.NORMAL then return end

    local start = self._lastPassInstance
    -- print(start, table.nums(self._welfareInfo))
    for i = start, table.nums(self._welfareInfo), 1 do
        -- 已经全部通关的章节不参与遍历
        if i ~=0 then
            if dungeonType == DUNGEON_TYPE.ELITE then
                if dungeon_id == self._welfareInfo[i].unlock_dungeon_id then
                    if self._welfareInfo[i].state == QWelfareInstance.WEI_KAI_QI then
                        self._welfareInfo[i].state = QWelfareInstance.KE_JIAO_ZHAN
                    end
                    if self._welfareInfo[i].dungeons[1].state == QWelfareInstance.WEI_KAI_QI then
                        self._welfareInfo[i].dungeons[1].state = QWelfareInstance.KE_JIAO_ZHAN
                    end
                    if i > self._lastActiveInstance then
                        print("[Kumo] self._lastActiveInstance ", i, dungeonType, dungeon_id)
                        self._lastActiveInstance = i
                    end
                    return
                end
            elseif dungeonType == DUNGEON_TYPE.WELFARE then
                for index, dungeon in pairs(self._welfareInfo[i].dungeons) do
                    if dungeon_id == dungeon.dungeon_id then
                        dungeon.state = QWelfareInstance.YI_TONG_GUAN
                        dungeon.lastPassAt = lastPassAt
                        if dungeon.dungeon_isboss then
                            dungeon.bossBoxOpened = bossBoxOpened
                        end
                         if self:_isThisInstanceAllPass( i ) then 
                            -- 最后一关必是BOSS关卡，所以每过一个BOSS关卡，就检查一下是否全部通关
                            self._welfareInfo[i].state = QWelfareInstance.YI_TONG_GUAN 
                            self._lastPassInstance = i
                        else
                            if self._welfareInfo[i].dungeons[index + 1] and self._welfareInfo[i].dungeons[index + 1].state == QWelfareInstance.WEI_KAI_QI then
                                self._welfareInfo[i].dungeons[index + 1].state = QWelfareInstance.KE_JIAO_ZHAN
                            end
                        end
                        return
                    end
                end
            elseif dungeonType == DUNGEON_TYPE.GROTTO then
                for _, grotto in pairs(self._welfareInfo[i].grottos) do
                    if dungeon_id == grotto.dungeon_id then
                        grotto.state = QWelfareInstance.YI_TONG_GUAN
                        return
                    end
                end
            end
        end
    end
end

--[[
    更新福利副本各个关卡的状态
    @passProgress 副本通关情况 存的是最远的int_dungeon_id

    self._lastActiveInstance -- 0 - 没有已经开启的章节； 1 - _welfareInfo[1] 开启； 2 - _welfareInfo[2] 开启
    self._lastPassInstance -- 0 - 没有全部通关的章节； 1 - _welfareInfo[1] 全部通关； 2 - _welfareInfo[2] 全部通关

    state:0 --非量表属性。0 - 未开启；1 - 可交战；2 - 已通关
]]
function QWelfareInstance:updateAllWelfareInfoState( passProgress )
    if not passProgress or passProgress == 0 then return end
    for i, instance in ipairs(self._welfareInfo) do
        for index, dungeon in pairs(instance.dungeons) do
            if tonumber(dungeon.int_dungeon_id) <= tonumber(passProgress) then
                --已经通关
                dungeon.state = QWelfareInstance.YI_TONG_GUAN
                if dungeon.dungeon_isboss then dungeon.boxState = QWelfareInstance.KE_KAI_QI end
                
                if not dungeon.lastPassAt then dungeon.lastPassAt = 1 end

               if self:_isThisInstanceAllPass( i ) then 
                    -- 最后一关必是BOSS关卡，所以每过一个BOSS关卡，就检查一下是否全部通关
                    instance.state = QWelfareInstance.YI_TONG_GUAN 
                    self._lastPassInstance = i
                else
                    instance.state = QWelfareInstance.KE_JIAO_ZHAN
                    if instance.dungeons[index + 1] and instance.dungeons[index + 1].state == QWelfareInstance.WEI_KAI_QI then
                        instance.dungeons[index + 1].state = QWelfareInstance.KE_JIAO_ZHAN
                    end
                end
            end
        end
    end
end

--[[
    更新洞穴副本的状态
    @specialPassInfo 特殊副本通关情况 用";"号隔开,存的是int_dungeon_id

    state:0 --非量表属性。0 - 未开启；1 - 可交战；2 - 已通关
]]
function QWelfareInstance:updateGrottoInfo( specialPassInfo )
    if not specialPassInfo or specialPassInfo == "" then return end
    local tbl = string.split(specialPassInfo, ";")
    for _, instance in pairs(self._welfareInfo) do
        for _, grotto in pairs(instance.grottos) do
            for i, value in pairs(tbl) do
                if tonumber(value) == tonumber(grotto.int_dungeon_id) then
                    grotto.state = QWelfareInstance.YI_TONG_GUAN
                    print("[Kumo] 恭喜！ " .. grotto.instance_name .. " 的洞穴已经通关 ！")
                    table.remove(tbl, i)
                    if table.nums(tbl) == 0 then return end
                    break
                end 
            end
        end
    end   
end

--[[
    更新各个关卡BOSS宝箱状态
    @bossBoxInfo boss宝箱领取信息 用";"号隔开,存的是int_dungeon_id

    boxState:0 --非量表属性。10 - 无宝箱；11 - 未激活；12 - 可开启；13 - 已开启
]]
function QWelfareInstance:updateBossBoxInfo( bossBoxInfo )
    if not bossBoxInfo or bossBoxInfo == "" then return end
    local tbl = string.split(bossBoxInfo, ";")
    for _, instance in pairs(self._welfareInfo) do
        for _, dungeon in pairs(instance.dungeons) do
            for i, value in pairs(tbl) do
                if tonumber(value) == tonumber(dungeon.int_dungeon_id) then
                    dungeon.boxState = QWelfareInstance.YI_KAI_QI
                    dungeon.bossBoxOpened = true
                    table.remove(tbl, i)
                    if table.nums(tbl) == 0 then return end
                    break
                end 
            end
        end
    end 
end

--[[
    更新失败次数
]]
function QWelfareInstance:updateFailCount(failCount)
    self._failCount = failCount
end

--[[
    获取失败次数
]]
function QWelfareInstance:getLostCount()
    return self._failCount or 0
end

-------------------------------------------------工具模块-------------------------------------------------

--[[
    分析整理章节相关的量表
    @state:0 --非量表属性。0 - 未开启；1 - 可交战；2 - 已交战
]]
function QWelfareInstance:_analyseConfigAboutInstance( instanceTable, config )
    local dungeonTable = {}
    local grottoTable = {}
    if table.nums(instanceTable) == 0 then
        instanceTable.instance_id = config.instance_id
        instanceTable.int_instance_id = config.int_instance_id
        instanceTable.instance_name = config.instance_name
        instanceTable.instance_type = DUNGEON_TYPE.WELFARE
        instanceTable.file = config.file
        instanceTable.state = QWelfareInstance.WEI_KAI_QI
        instanceTable.unlock_dungeon_id = config.unlock_dungeon_id or ""
        instanceTable.unlock_instance_name = self:_getUnlockInstanceName( config.unlock_dungeon_id )
        instanceTable.dungeons = {}
        instanceTable.grottos = {}
        self:_analyseConfigAboutDungeonOrGrotto(instanceTable, config)
    else
        self:_analyseConfigAboutDungeonOrGrotto(instanceTable, config)
    end
end

--[[
    分析整理关卡或洞穴相关的量表
    @state:0 --非量表属性。 0 - 未开启；1 - 可交战；2 - 已通关
    @boxState:0 --非量表属性。0 - 无宝箱；1 - 未激活；2 - 可开启；3 - 已开启
]]
function QWelfareInstance:_analyseConfigAboutDungeonOrGrotto( instanceTable, config )
    local curTbl = {}
    curTbl.id = config.id
    curTbl.dungeon_id = config.dungeon_id
    curTbl.int_dungeon_id = config.int_dungeon_id
    curTbl.dungeon_type = config.dungeon_type
    curTbl.dungeon_isboss = config.dungeon_isboss
    curTbl.box_coordinate = config.box_coordinate
    curTbl.boss_size = config.boss_size  
    curTbl.stars_high = config.stars_high   
    curTbl.word_x = config.word_x
    curTbl.word_y = config.word_y
    curTbl.monster_id = config.monster_id or -1
    curTbl.unlock_team_level = config.unlock_team_level
    curTbl.attack_num = config.attack_num
    curTbl.dungeon_icon = config.dungeon_icon
    curTbl.state = QWelfareInstance.WEI_KAI_QI
    
    if tonumber(config.dungeon_type) == DUNGEON_TYPE.WELFARE then
        if config.dungeon_isboss then
            curTbl.boxState = QWelfareInstance.WEI_JI_HUO
        else
            curTbl.boxState = QWelfareInstance.WU_BAO_XIANG
        end

        table.insert(instanceTable.dungeons, curTbl)
    elseif tonumber(config.dungeon_type) == DUNGEON_TYPE.GROTTO then
        curTbl.instance_id = config.instance_id
        curTbl.int_instance_id = config.int_instance_id
        curTbl.instance_name = config.instance_name
        curTbl.file = config.file
        curTbl.unlock_dungeon_id = config.unlock_dungeon_id or ""

        table.insert(instanceTable.grottos, curTbl)
    end
end

function QWelfareInstance:_analyseElitePassInfo( eliteInstance, isForce )
    -- local tbl = {}
    -- if table.nums(self._elitePassInfo) == 0 or isForce then
    --     tbl.instance_id = eliteInstance.instance_id
    --     tbl.int_instance_id = eliteInstance.int_instance_id
    --     tbl.instance_name = eliteInstance.instance_name
    --     tbl.dungeons = {}
    --     table.insert(tbl.dungeons, eliteInstance.int_dungeon_id)
    --     table.insert(self._elitePassInfo, tbl)
    -- else
    --     local isFind = false
    --     for _, value in pairs(self._elitePassInfo) do
    --         if value.int_instance_id == eliteInstance.int_instance_id then
    --             table.insert(value.dungeons, eliteInstance.int_dungeon_id)
    --             return
    --         end
    --     end
    --     if not isFind then
    --         self:analyseElitePassInfo( eliteInstance, true )
    --     end
    -- end
end

--[[
    判断指定章节是否全部通关

    @index 章节的序列号，即 self._welfareInfo 的key

    state:0 --非量表属性。 0 - 未开启；1 - 可交战；2 - 已通关
]]
function QWelfareInstance:_isThisInstanceAllPass( index )
    if index == 0 or index > table.nums(self._welfareInfo) then return false end
    if self._lastPassInstance >= index then return true end
    if self._welfareInfo[index].state == QWelfareInstance.YI_TONG_GUAN then return true end
    local isAllPass = false
    for _, dungeon in pairs(self._welfareInfo[index].dungeons) do
        if dungeon.state ~= QWelfareInstance.YI_TONG_GUAN then
            isAllPass = false
            return isAllPass
        else
            isAllPass = true
        end
    end
    return isAllPass
end

--[[
    通过unlock_dungeon_id所记录的数据（即解锁章节的dungeon_id）找到解锁关卡所在的章节，然后获取该章节的instance_name
]]
function QWelfareInstance:_getUnlockInstanceName( unlock_dungeon_id )
    if not unlock_dungeon_id or unlock_dungeon_id == "" then return "未知章节" end
    for _, value in pairs(self._config) do
        if unlock_dungeon_id == value.dungeon_id then
            return value.instance_name
        end 
    end

    return "未知章节"
end


-- function QWelfareInstance:_isFirstPass( int_dungeon_id )
--     local start = self._lastActiveInstance
--     for i = start, table.nums(self._welfareInfo), 1 do
--         for _, dungeon in pairs(self._welfareInfo[i].dungeons) do
--             if int_dungeon_id == dungeon.int_dungeon_id then
--                 if dungeon.state ~= QWelfareInstance.YI_TONG_GUAN then
--                     return true
--                 end
--                 return false
--             end
--         end
--     end
--     return false
-- end

-------------------------------------------------数据请求模块-------------------------------------------------

--[[
    数据返回处理函数
]]
function QWelfareInstance:_responseHandler(response, success)
    printTableWithColor(PRINT_FRONT_COLOR_DARK_GREEN, nil, response)
    local data
    if response.welfareDungeonInfo ~= nil then
        data = response.welfareDungeonInfo
        -- printTable(data, "*")
        self._passCount = data.passCount
        remote.user:update({todayWelfareCount = self._passCount})
        remote.task:setPropNumForKey("todayWelfareCount", self._passCount)
        self._passProgress = data.passProgress or 0
        self:updateAllWelfareInfoState(data.passProgress)
        self:updateGrottoInfo(data.specialPassInfo)
        self:updateBossBoxInfo(data.bossBoxInfo)
        self:updateFailCount(data.failCount)
    end

--[[
[INFO] response:
{
    error: NO_ERROR
    loginPort: 46135
    api: WELFARE_FIGHT_START
    serverTime: 1447253988836
    key: 168
    awards: 
    {
        1: 
        {
            type: SOUL_MONEY
            count: 82
        }
        2: 
        {
            type: MONEY
            count: 840
        }
        3: 
        {
            type: TEAM_EXP
            count: 6
        }
    }
}
]]
    if response.api == "GLOBAL_FIGHT_START" then 
        -- print(remote.user:getPropForKey("token"), remote.user:getPropForKey("money"))
        self._isBattleWin = false
        self._isBattleEnd = false
    end

    if response.api == "GLOBAL_FIGHT_END" then
        self._isBattleWin = true
        -- local tbl = {}
        -- if self._isFirstWin then
        --     tbl.money = response.money
        --     -- tbl.money = self._moneyCount + remote.user:getPropForKey(ITEM_TYPE.MONEY)
        --     tbl.token = response.token
        --     -- tbl.token = self._tokenCount + remote.user:getPropForKey(ITEM_TYPE.TOKEN_MONEY)
        --     remote.user:update(tbl)
        -- else
        --     tbl.money = response.money
        --     -- tbl.money = self._moneyCount + remote.user:getPropForKey(ITEM_TYPE.MONEY)
        --     remote.user:update(tbl)
        -- end
    end
--[[
[INFO] response:
{
    error: NO_ERROR
    loginPort: 42574
    wallet: 
    {
        towerMoney: 0
        archaeologyMoney: 4
        materialMoney: 0
        money: 47650
        token: 3421
        glyphsMoney: 0
        thunderMoney: 1770
        arenaMoney: 996
        intrusion_token: 10
        trainMoney: 5
        consortiaMoney: 1355
        soulMoney: 744
        sunwellMoney: 1460
        intrusion_money: 0
    }
    api: OPEN_WELFARE_BOSS_BOX
    welfareDungeonInfo: 
    {
        passCount: 1
        passProgress: 1030212
        specialPassInfo: 
        bossBoxInfo: ;1030104;1030108;1030112;1030204;1030208;1030212
    }
    serverTime: 1446642089852
    key: 43
    apiDungeonBossBoxResponse: 
    {
        luckyDraw: 
        {
            prizes: 
            {
                1: 
                {
                    type: ITEM
                    count: 5
                    id: 131001
                }
                2: 
                {
                    type: MONEY
                    count: 7500
                    id: 0
                }
                3: 
                {
                    type: SOUL_MONEY
                    count: 110
                    id: 0
                }
            }
            items: 
            {
                1: 
                {
                    type: 131001
                    count: 16
                }
            }
        }
    }
}
]]
    if response.api == "OPEN_WELFARE_BOSS_BOX" then
        self._isBattleWin = false
        self._isBattleEnd = false
        local tbl = {}
        if response.wallet then tbl.wallet = response.wallet end
        if response.apiDungeonBossBoxResponse and response.apiDungeonBossBoxResponse.luckyDraw then
            tbl.luckyDraw = response.apiDungeonBossBoxResponse.luckyDraw
            if response.apiDungeonBossBoxResponse.luckyDraw.items then remote.items:setItems(response.apiDungeonBossBoxResponse.luckyDraw.items) end
        end
        remote.user:update(tbl)
        if response.error == "NO_ERROR" then
            app.taskEvent:updateTaskEventProgress(app.taskEvent.WELFARE_DUNGEON_REWARD_COUNT_EVENT, 1)
        end
    end
--[[
 {
     energy: 111
     level: 90
     batchAwards: 
     {
         1: 
         {
             awards: 
             {
                 1: 
                 {
                     type: SOUL_MONEY
                     count: 54
                 }
                 2: 
                 {
                     type: MONEY
                     count: 5340
                 }
                 3: 
                 {
                     type: TEAM_EXP
                     count: 6
                 }
             }
         }
     }
     energyRefreshedAt: 1453211376000
     extraExpItem: 
     {
         1: 
         {
             type: ITEM
             count: 5
             id: 4
         }
         2: 
         {
             type: ITEM
             count: 1
             id: 3
         }
     }
     token: 3500
     money: 62113762
     error: NO_ERROR
     items: 
     {
         1: 
         {
             type: 3
             count: 121
         }
         2: 
         {
             type: 4
             count: 183
         }
     }
     wallet: 
     {
         soulMoney: 3184
     }
     exp: 414
     api: WELFARE_QUICK_FIGHT
     serverTime: 1453211491394
     key: 18
     welfareDungeonInfo: 
     {
         passCount: 2
     }
 }
]]
    -- if response.api == "WELFARE_QUICK_FIGHT" then
    if response.api == "GLOBAL_FIGHT_QUICK" then
        self._isBattleWin = false
        self._isBattleEnd = false
        self._passCount = response.welfareDungeonInfo.passCount
        remote.user:update({todayWelfareCount = self._passCount})
        remote.task:setPropNumForKey("todayWelfareCount", self._passCount)

        local tbl = {}
        if response.wallet then tbl.wallet = response.wallet end
        remote.user:update(tbl)
    end
    if response.api == "WELFARE_MAP_ENTER" then
        remote.task:updateUserWeekTaskInfoCount("todayWelfareCount")
    end



    if success then success(response) end
end

--[[
	请求福利副本信息
    response{
        passCount: 0
        passProgress: 0
        specialPassInfo: 
        bossBoxInfo: 
    }
]]
function QWelfareInstance:welfareInfoRequets(success, fail, status)
    if self:_checkWelfareUnlock() == false then return end
    local request = {api = "WELFARE_MAP_ENTER"}
    local successCallback = function (response)
        self:_responseHandler(response, success)
    end
    app:getClient():requestPackageHandler("WELFARE_MAP_ENTER", request, successCallback, fail)
end

--[[
	请求福利副本战斗开始
    required int32 dungeonId = 1;                                               // 开始
    repeated string heros = 2;                                                  // 参与战斗的魂师
    repeated string assistHeros = 3;                                            // 辅助魂师
]]
function QWelfareInstance:welfareFightStartRequest(battleType, dungeonId, battleFormation, success, fail, status)
    if self:canBattle() == false then app:alert({content="今日挑战次数已满",title="系统提示",callBack=nil,comfirmBack=nil}) end

    local dungeonId = self:getIntDungeonIDByDungeonID( dungeonId )
    if self._passProgress < dungeonId then
        self._isFirstWin = true
    end
    local welfareFightStartRequest = {dungeonId = dungeonId}
    local gfStartRequest = {battleType = battleType, battleFormation = battleFormation, welfareFightStartRequest = welfareFightStartRequest}

    local request = {api = "GLOBAL_FIGHT_START", gfStartRequest = gfStartRequest}
    local successCallback = function (response)
        self:_responseHandler(response, success)
    end
    app:getClient():requestPackageHandler("GLOBAL_FIGHT_START", request, successCallback, fail)
end

--[[
	请求福利副本战斗结束
    optional int64 start_at = 1 [default = 0];                                  // 打斗开始时间
    optional int64 end_at = 2 [default = 0];                                    // 打斗结束时间
    optional int32 dungeon_id = 3 [default = 0];                                // 打斗的关卡ID
]]
function QWelfareInstance:welfareFightSuccessRequest(battleType, start_at, end_at, dungeon_id, battleKey, success, fail, status)
    local dungeonId = self:getIntDungeonIDByDungeonID( dungeon_id )
    local welfareFightSuccessRequest = {start_at = start_at, end_at = end_at, dungeon_id = dungeonId}
    local content = readFromBinaryFile("last.reppb")
    local fightReportData = crypto.encodeBase64(content)
    welfareFightSuccessRequest.battleVerify = q.battleVerifyHandler(battleKey)
    
    local gfEndRequest = {battleType = battleType,battleVerify = welfareFightSuccessRequest.battleVerify,isQuick = false, isWin = true,
                        fightReportData = fightReportData, welfareFightSuccessRequest = welfareFightSuccessRequest}
    local request = {api = "GLOBAL_FIGHT_END", gfEndRequest = gfEndRequest}
    local successCallback = function (response)
        self:_responseHandler(response, success)
    end
    app:getClient():requestPackageHandler("GLOBAL_FIGHT_END", request, successCallback, fail)
end

--[[
	福利副本开宝箱
]]
function QWelfareInstance:openWelfareBossBoxRequest(dungeonId, success, fail, status)
    local openWelfareBossBoxRequest = {dungeonId = dungeonId}
    local request = {api = "OPEN_WELFARE_BOSS_BOX", openWelfareBossBoxRequest = openWelfareBossBoxRequest}
    local successCallback = function (response)
        self:_responseHandler(response,success)
    end
    app:getClient():requestPackageHandler("OPEN_WELFARE_BOSS_BOX", request, successCallback, fail)
end

--[[
/**
 * 成功扫荡一个福利副本
    required int32 dungeon_id = 1;                                              // 扫荡的关卡ID
    required int32 count = 2;                                                   // 扫荡次数
    optional bool isSkip = 2;                                                   // 是否跳过战斗
 */
--]]
function QWelfareInstance:welfareQuickFightRequest(battleType, dungeonId, count, isSkip, battleFormation, success, fail, status)
    dungeonId = QStaticDatabase:sharedDatabase():convertDungeonID(dungeonId)
    local welfareQuickFightRequest = {dungeon_id = dungeonId, count = count}
    local gfQuickRequest = {battleType = battleType,welfareQuickFightRequest = welfareQuickFightRequest, isSkip = isSkip}
    local request = {api = "GLOBAL_FIGHT_QUICK", gfQuickRequest = gfQuickRequest, battleFormation = battleFormation}
    local successCallback = function (response)
        self:_responseHandler(response,success)
    end
    app:getClient():requestPackageHandler("GLOBAL_FIGHT_QUICK", request, successCallback, fail)
end

return QWelfareInstance