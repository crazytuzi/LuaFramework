require("app.cfg.hard_dungeon_stage_info")
require("app.cfg.hard_dungeon_chapter_info")
require("app.cfg.hard_dungeon_roit_info")
local storage = require("app.storage.storage")
local HardDungeonData =  class("HardDungeonData")
local BOXTYPE = require("app.const.BoxType")
local FunctionLevelConst = require("app.const.FunctionLevelConst")

function HardDungeonData:ctor()
    self.chapter = {}
    self.dungeonRankList = {}
    self.dungeonStarBounsList = nil
    self.self_rank = 0
    self._false_alert = {}
    
    -- 记录是否播放了新章节开启动画
    self.showNewChapterAction = false
    self.Status = 
    {
        STATUS_OPEN = 1,
        STATUS_CLOSE = 2
    }
    
    self.StageType = 
    {
        TYPE_KNIGHT = 1,    -- 武将
        TYPE_BOX = 2        -- 宝箱
        
    }
    
    -- 是否有新的章节开启
    self._openNewChapterId = 0

    -- 缓存上次新的关卡id
    self._openNewStageId = -1
    -- 当前关卡上一次星星数
    self._currStageLastStar = {starnum=-1,stageId = -1}
    
    self._date =  nil
    self._totalStar = 0
    self._restCost = 0
    self._fastExecuteCD = 0
    self._fastExecuteTime = 0
    self._stageId = 1
    self._chapterId = 1
    self._isRequestChapteList = false
    self:initChapterList()
    self.battleRes = nil
    self.isInit = false
    -- 是否触发叛军
    self.isRebel = false
    self.rebelData = {rebelId=0,rebelLevel=0}
    --@desc 由于战报发过来时，新关卡已经开启状态，需要记录上一个新开启关卡的id
    -- 记录上次新的关卡id 用于剧情对话
    self._stageLastNewId = 0
    self.mapLayerPosY = 100
    self.mapLayerScale = 1
    -- 记录当前当前章节位置在地图列表的位置
    self._cellIndex = -1
    self._cellPos = 0

    self._tAttackState = {
        _nChapterId = 0,
        _nStageId = 0,
        _nMapPosY = 0,
        _nMapScale = 1,
    }

    -- 精英暴动
    -- 初始化时服役器时间，为了不与副本章节冲突
    self._riotDate = nil
    -- 一天内总的暴动章节列表
    self._tRiotChapterList = {}
    -- 当前时间能够显示的暴动章节列表
    self._tShowedRiotChapterList = {}
    -- 如果该章节有敌方援军，进入的时候，是否默认打开layer, 默认不开
    self._isShowRiotGateLayer = false
    -- 记录RiotMainLayer出现在中间的次数，大于多少次后就只呆在屏幕下边
    self._nShowOnCenterCount = 0
    -- 当前能够显示的暴动章节数量，包括已经成功打过了的章节
    self._nShowedChapterCount = 0
    -- 记录关键时间点的时间戳
    self._tTimestampList = {}

    -- 记录玩家有没有进入过精英副本
    self._szStorgePath = "enteredHardDungeon.data"
end

-- 清除当前关卡星星数
function HardDungeonData:clearStar()
    self._currStageLastStar = {starnum=-1,stageId = -1}
end

function HardDungeonData:setRebelData(rebelId,rebelLevel)
    self.rebelData.rebelId = rebelId
    self.rebelData.rebelLevel = rebelLevel
end


function HardDungeonData:getRebelData()
    return self.rebelData
end

-- 设置当前map位置
function HardDungeonData:setMapLayerPosYAndScale(posY,scale)
    self.mapLayerPosY = posY
    self.mapLayerScale = scale
end

-- 得到当前maplayer位置
function HardDungeonData:getMapLayerPosYAndScale()
    return self.mapLayerPosY,self.mapLayerScale
end

-- 设置当前章节的位置
function HardDungeonData:setCellPos(cellIndex,cellPos)
    self._cellIndex = cellIndex
    self._cellPos = cellPos
end

-- 得到当前章节的位置
function HardDungeonData:getCellPos()
    return self._cellIndex,self._cellPos
end

-- 添加奖励
function HardDungeonData:addBattleRes(data)
    self.battleRes = data
end

---
-- @type chapter
-- @field #boolean _isOpen 章节是否开启
-- @field #table list stage列表
-- @field #number _currstar 当前星数
-- @field #boolean open_copperbox 是否开启铜箱
-- @field #boolean open_silverbox 是否开启银箱
-- @field #boolean open_goldbox 是否开启金箱
-- @field #boolean has_entered 
-- @field @number _currStageId 当前stage id

---
-- @type stage
-- @field #boolean _isOpen 是否开启
-- @field #number _star 星数
-- @field #string ico
-- @field #number _executeCount 扫荡次数
-- @field #boolean _isFinished
-- @field #number reset_cost 重置花费
-- @field #number reset_count 重置次数
-- @field #number index
-- @field #number gateType


-- 当前关卡是否得到更多星星数
function HardDungeonData:isNewStarNum()
    if self._currStageStar == -1 then
        return false
    end
    local starNum = self.chapter[self._chapterId].list[self:getCurrStageId()]._star
    local newStarNum = self._currStageStar == starNum
    --self._currStageStar = starNum
    return newStarNum
end

--@desc 设置当前关卡上一次星星数
function HardDungeonData:setCurrStageLastStar(num)
    if num == nil then
        num = 0
    end
    self._currStageLastStar.starnum = num
    self._currStageLastStar.stageId = self:getCurrStageId()
end

--@desc 得到当前关卡上一次星星数
function HardDungeonData:getCurrStageLastStar()
    if self:getCurrStageId() ~= self._currStageLastStar.stageId then
        return -1
    else
        return self._currStageLastStar.starnum
    end
end

function HardDungeonData:getbattleRes()
    return self.battleRes
end

function HardDungeonData:addToStarBounsListByData(data)
    if self.dungeonStarBounsList == nil then
        self.dungeonStarBounsList = {}
    end
    
    if data then
        for k,v in pairs(data) do
            self.dungeonStarBounsList[v] = true
        end
    end
end

-- 添加星数奖励到列表
function HardDungeonData:addToStarBounsList(_id)
    if self.dungeonStarBounsList == nil then
        self.dungeonStarBounsList = {}
    end
    self.dungeonStarBounsList[_id] = true
end

-- 设置第一次进入
function HardDungeonData:setFirstEnterChapter(data)
    self:addToChapterList(data.chapter)
end
-- 得到星数奖励列表
function HardDungeonData:getDungeonStarBounsList()
    return self.dungeonStarBounsList
end

-- 得到某个奖励是否领取
function HardDungeonData:getBounsById(_id)
    return self.dungeonStarBounsList[_id]
end

-- 完成关卡显示新开启章节动画
function HardDungeonData:finishNewChapterAction()
    self.showNewChapterAction  = true
end

function HardDungeonData:setChapterList(chapters)
    for i,v in ipairs(chapters) do
        local tChapterTmpl = hard_dungeon_chapter_info.get(v.id)
        if tChapterTmpl and tChapterTmpl.map > 0 then
            self:addToChapterList(v)
        end
    end
    if self.isInit == false then
        self._openNewStageId = self._stageLastNewId
        self.isInit = true
    end
end

function HardDungeonData:getNewChapterAction()
    return self.showNewChapterAction
end

function HardDungeonData:addToChapterList(data)
    self._date = G_ServerTime:getDate()
    self._isRequestChapteList = false
    if self.chapter[data.id]._currstar == nil then
        self.chapter[data.id]._currstar = 0
        self.showNewChapterAction  = false
    end
    self.chapter[data.id].open_copperbox = data.breward == 1 
    self.chapter[data.id].open_silverbox = data.sreward == 1 
    self.chapter[data.id].open_goldbox = data.greward == 1 
    self.chapter[data.id]._isOpen = true
    if self.chapter[data.id]._currStageId == nil  then
        self.chapter[data.id]._currStageId = 0
    end
    self.chapter[data.id].has_entered = data.has_entered
    for k,v in ipairs(data.stages) do
        if self.chapter[data.id].list[v.id] == nil then
            self.chapter[data.id].list[v.id] = {}
        end
        self.chapter[data.id].list[v.id]._isOpen = true
        self:addStage(data.id,v)
    end
end

    
 -- 是否需要请求主线副本列表
 function HardDungeonData:isNeedRequestChapter()
     return self._isRequestChapteList 
 end
 
 -- 是否第一次进入
 function HardDungeonData:isFirstEnter(chapterId)
     if self.chapter[chapterId].has_entered == nil then
         return false
     else
         return self.chapter[chapterId].has_entered
     end
 end
 
 function HardDungeonData:getBoxStuatus(chapterid)
     return self.chapter[chapterid].open_copperbox,self.chapter[chapterid].open_silverbox,self.chapter[chapterid].open_goldbox
 end
 
 -- 副本是否已开启
 -- param chapterId 章节id dungeonId 副本id
function HardDungeonData:isOpenDungeon(chapterId,dungeonId)
    if self.chapter[chapterId] == nil or not self.chapter[chapterId].list[dungeonId] then
        return  false
    end
    
    if self:isOpenChpater(chapterId) == true then
        return self.chapter[chapterId].list[dungeonId]._isOpen
    else    
        return false
    end
end

 -- 宝箱已领取
 function HardDungeonData:setBoxIsOpen(chapterid,_type)
     if _type == BOXTYPE.COPPERBOX then
         self.chapter[chapterid].open_copperbox = true
     elseif _type == BOXTYPE.SIVLERBOX then
         self.chapter[chapterid].open_silverbox = true
    elseif _type == BOXTYPE.GOLDBOX then
         self.chapter[chapterid].open_goldbox = true
     end
 end
 
 -- 副本排行榜
 function HardDungeonData:addDungeonRankList(data) 
    self.dungeonRankList = {}
    for k,v in pairs(data) do
        self.dungeonRankList[v.rank] = {name = v.name,star = v.star}
    end
end

 function HardDungeonData:getDungeonRankList() 
     return self.dungeonRankList
end
 
-- @desc 检测是否有新开启章节
function HardDungeonData:getOpenNewChapterId()
    return self._openNewChapterId
end

-- @desc 清除新开启章节标记
function HardDungeonData:clearOpenNewChapterId()
    self._openNewChapterId = 0
end

-- @desc 清除新开启关卡标记
function HardDungeonData:clearOpenNewStageId()
    self._stageLastNewId = self._openNewStageId
end

-- @desc 得到新开启关卡
function HardDungeonData:getOpenNewStageId()
    return self._openNewStageId
end

function HardDungeonData:isNewStage()
    return self._openNewStageId ~= self._stageLastNewId
end

function HardDungeonData:getFalseAlert(stageId)
    local _stageData = hard_dungeon_stage_info.get(stageId)
    local _dungeonInfo = G_GlobalFunc.getHardDungeonData(_stageData.value)
    if not _dungeonInfo then
        return nil
    end
    local chapterId = self:getCurrChapterId()
    if self.chapter[chapterId] and self.chapter[chapterId].list ~= nil then
        if self.chapter[chapterId].list[stageId]  and self.chapter[chapterId].list[stageId]._star 
            and self.chapter[chapterId].list[stageId]._star>0 then
            return "0"
        end
    end
--    return _dungeonInfo.alert_name or ""
    return "0"
end

-- @desc 添加新的关卡
function HardDungeonData:addNewStage(chapterId,data)
    if type(chapterId) ~= "number" or type(data) ~= "table" then 
        return 
    end
    
    if self.chapter[chapterId]._isOpen == nil then
        self._openNewChapterId = chapterId
        self.showNewChapterAction  = false
    end
    if self.chapter[chapterId]._isOpen == true then
        self._openNewStageId = data.id
    end

    if self.chapter[chapterId].list[data.id] == nil then
        self.chapter[chapterId].list[data.id] = {}
    end

    self:addStage(chapterId,data)
end

function HardDungeonData:getAlert(id)
    if not self._false_alert[id] or self._false_alert[id] == "0" then
        return nil 
    end
    return GlobalFunc.lua_string_split(self._false_alert[id],",")
end
 
function HardDungeonData:addStage(chapterId,data)
    local _stage_info = hard_dungeon_stage_info.get( data and data.id or 0)
    -- self:resetAlert()
    -- local false_alert = "0"
    if _stage_info then
        self._false_alert[data.id or 0] = self:getFalseAlert(data.id) 
    end
    if _stage_info then
        self.chapter[chapterId]._isOpen = true
        if self.chapter[chapterId].list == nil then
            self.chapter[chapterId].list = {}
        end
        if self.chapter[chapterId]._currstar and _stage_info.type == self.StageType.TYPE_KNIGHT and self._totalStar and data.star then

            if self.chapter[chapterId].list[data.id]  and self.chapter[chapterId].list[data.id]._star then -- 添加星数
                self._totalStar = self._totalStar + data.star - self.chapter[chapterId].list[data.id]._star
                self.chapter[chapterId]._currstar = self.chapter[chapterId]._currstar + data.star - self.chapter[chapterId].list[data.id]._star
            else
                self._totalStar = self._totalStar + data.star
                self.chapter[chapterId]._currstar = self.chapter[chapterId]._currstar + data.star
            end
        end
        if _stage_info.type == self.StageType.TYPE_BOX then -- 宝箱 宝箱开启状态
            self.chapter[chapterId].list[data.id].ico = G_Path.getBoxPic(2)   
        end

        if self.chapter[chapterId]._currstar == nil then self.chapter[chapterId]._currstar = 0 end

        self.chapter[chapterId].list[data.id]._executeCount = data.execute_count
        self.chapter[chapterId].list[data.id]._star = data.star
        self.chapter[chapterId].list[data.id]._isFinished = data.is_finished
        self.chapter[chapterId].list[data.id]._isOpen = true
        self.chapter[chapterId].list[data.id].reset_cost = data.reset_cost
        self.chapter[chapterId].list[data.id].reset_count = data.reset_count
        -- self.chapter[chapterId].list[data.id].false_alert = false_alert
        if self.chapter[chapterId]._currStageId == nil then self.chapter[chapterId]._currStageId = 0 end
        

        -- 上一次缓存关卡id 应该小于最新的id
        if self._openNewStageId == -1 then
            if self._stageLastNewId < data.id then
                self._stageLastNewId = data.id
            end
        else
             if self._openNewStageId < data.id  then
                self._openNewStageId = data.id
             end
        end

    end
end 
 
-- 得到最新通关id
function HardDungeonData:getStageNewId()
    return self._stageLastNewId
end
 -- 设置副本信息   
function HardDungeonData:setDungeonData(totalStar,fast_execute_cd,fast_execute_time)
    self._currDungeonStar = totalStar
    self._fastExecuteCD = fast_execute_cd
    self._fastExecuteTime = fast_execute_time
end
 
-- 得到总星数
function HardDungeonData:getAllStar() return self._totalStar end
-- 我的排名    
function HardDungeonData:getMyRank() return self.self_rank end

function HardDungeonData:setMyRank(_rank) self.self_rank = _rank end

-- 得到当前总星数
function HardDungeonData:getCurrDungeonTotalStar(chapterId) return self.chapter[chapterId]._currstar end

-- 得到扫荡次数
function HardDungeonData:getFastExecuteCD() return self._fastExecuteCD end

function HardDungeonData:setFastExecuteCD(_value)  self._fastExecuteCD = _value end

function HardDungeonData:getFastExecuteTime()  return  self._fastExecuteTime end

function HardDungeonData:setFastExecuteTime(_value)  self._fastExecuteTime = _value end

function HardDungeonData:getChapterStar(chapterId)  
    return self.chapter[chapterId]._currstar 
end

-- 得到重置副本消耗
function HardDungeonData:getRestCost()    return self._restCost end
function HardDungeonData:setRestCost(_value)    self._restCost = _value end

-- 添加副本到当前所属章节
function HardDungeonData:initChapterList()
    local chapterid = 0
    for i=1,hard_dungeon_stage_info.getLength() do
        local stage_info = hard_dungeon_stage_info.indexOf(i)
        if stage_info.chapter_id ~= chapterid then
            chapterid = stage_info.chapter_id

            local tChapterTmpl = hard_dungeon_chapter_info.get(chapterid)
            if tChapterTmpl and tChapterTmpl.map == 0 then
                break
            end

            if self.chapter[chapterid] == nil then
                self.chapter[chapterid] = {}
                self.chapter[chapterid].list = {}
            end
        end
        self.chapter[chapterid].list[stage_info.id] = setmetatable({}, stage_info)
        if stage_info.type == self.StageType.TYPE_BOX then  -- 宝箱关闭状态
            self.chapter[chapterid].list[stage_info.id].ico = G_Path.getBoxPic(1)  
        else
            self.chapter[chapterid].list[stage_info.id].ico = G_Path.getKnightPic(stage_info.image)  
        end
        self.chapter[chapterid].list[stage_info.id].index = stage_info.index
        self.chapter[chapterid].list[stage_info.id]._isOpen = false
        self.chapter[chapterid].list[stage_info.id].gateType = stage_info.type
    end
end


-- 副本ID
function HardDungeonData:setCurrChapterId(_id)
    if _id ~= self._chapterId then
        self:clearStar()
    end

    if _id ~= nil and _id > 0 then
        self._chapterId = _id    
    end
    assert(self._chapterId > 0)
end
function HardDungeonData:getCurrChapterId()      return self._chapterId   end

-- 关卡ID
function HardDungeonData:setCurrStageId(_id)
    if self.chapter[self:getCurrChapterId()] == nil then
        self.chapter[self:getCurrChapterId()] = {}
    end
    self.chapter[self:getCurrChapterId()]._currStageId = _id    
end

function HardDungeonData:getCurrStageId()      return self.chapter[self:getCurrChapterId()]._currStageId   end

function HardDungeonData:getCurrChapterStageList(chapterId)
    return self.chapter[chapterId].list
end

-- @desc 检查章节是否开启
function HardDungeonData:isOpenChpater(chapterId)
    
    if self.chapter[chapterId] == nil then return false end
    return (self.chapter[chapterId]._isOpen and true) or false
end

function HardDungeonData:getStageById(_id)
    if self.chapter[self:getCurrChapterId()] == nil then
        return nil
    end
    return self.chapter[self:getCurrChapterId()].list[_id]
end

function HardDungeonData:getStageData(chapterId,_id)
    if self.chapter[chapterId] == nil then
        return nil
    end

    return self.chapter[chapterId].list[_id]
end
-- @desc 是否重新需要拉数据
function HardDungeonData:isNeedRequestNewData()
    local dateTime = G_ServerTime:getDate()
    if dateTime ~= self._date  then
        return true
    else
        return false
    end
end

function HardDungeonData:_hasUnclaimedBoxEachChapter(data)
    local _isOpenCopperbox, _isOpenSilverbox, _isOpenGoldbox = false, false, false
    local totalStar = 0
    totalStar = G_Me.hardDungeonData:getChapterStar(data.id)
    _isOpenCopperbox, _isOpenSilverbox, _isOpenGoldbox = G_Me.hardDungeonData:getBoxStuatus(data.id)

    local list = G_Me.hardDungeonData:getCurrChapterStageList(data.id)
    for k, v in pairs(list) do
        if v.gateType == 2 then
            local _stageinfo = hard_dungeon_stage_info.get(k)
            if _stageinfo then
                local statge_data = G_Me.hardDungeonData:getStageData(data.id, _stageinfo.premise_id)
                if statge_data._star and statge_data._star > 0 and not v._isFinished then
                        return true
                end
            end
        end
    end

    -- 铜宝箱是否有奖励
    if _isOpenCopperbox == false then
        if totalStar >= data.copperbox_star then
            return true
        end
    end

    -- 银宝箱是否有奖励
    if _isOpenSilverbox == false then
        if totalStar >= data.silverbox_star then
            return true
        end
    end

    -- 金宝箱
    if _isOpenGoldbox == false then
        if totalStar >= data.goldbox_star then
            return true
        end
    end

    return false
end

-- 判断有章节有没有宝箱未领取（包括章节和stage宝箱）
function HardDungeonData:hasUnclaimedBox()
    local tChapterList = G_Me.hardDungeonData.chapter
    for key, val in pairs(tChapterList) do
        local nChapterId = key
        if G_Me.hardDungeonData:isOpenChpater(nChapterId) then
            local tChapterTmpl = hard_dungeon_chapter_info.get(nChapterId)
            if self:_hasUnclaimedBoxEachChapter(tChapterTmpl) then
                return true
            end
        end
    end
    return false
end

function HardDungeonData:isOnSweepStatus(chapterId, stageId)
    if type(chapterId) ~= "number" or type(stageId) ~= "number" then
        return false
    end
    if not self:isOpenChpater(chapterId) then
        return false
    else
        if self.chapter[chapterId].list then
            local tStage = self.chapter[chapterId].list[stageId]
            if tStage then
                if tStage._star and tStage._star == 3 then
                    return true
                else
                    return false
                end
            else
                return false
            end
        else
            return false
        end
    end
end

-- 精英暴动
---------------------------------------------------------------------------
-- 为了跨天重新去服务器拉取数据
function HardDungeonData:setRiotDate(date)
    self._riotDate = date 
end

-- @desc 是否重新需要拉数据
function HardDungeonData:isNeedRequestRiotChapterList()
    local dateTime = G_ServerTime:getDate()
    if dateTime ~= self._riotDate then
        return true
    else
        return false
    end
    return false
end

-- 记录每天总的暴动章节列表
-- riotChapters, ChapterRoit结构数据
function HardDungeonData:storeRiotChapterList(riotChapters)
    self._riotDate = G_ServerTime:getDate()
    self._tRiotChapterList = {}
    for key, val in pairs(riotChapters) do
        local riot = val
        local tRiotChapter = {}
        tRiotChapter._nChapterId = riot.ch_id
        tRiotChapter._nOpenTime = riot.open_time
        tRiotChapter._nRiotId = riot.roit_id
        tRiotChapter._isFinished = riot.is_finish
        table.insert(self._tRiotChapterList, tRiotChapter)
    end

    self:getShowedRiotChapterList()
end

-- 获取当前时间需要显示的暴动章节列表
function HardDungeonData:getShowedRiotChapterList()
    assert(self._tRiotChapterList ~= nil)
    self._tShowedRiotChapterList = {}
    local nCurTime = G_ServerTime:getTime()
    for key, val in pairs(self._tRiotChapterList) do
        local tRiotChapter = val
        if nCurTime >= tRiotChapter._nOpenTime then
            table.insert(self._tShowedRiotChapterList, tRiotChapter)
        end
    end

    local function sortFunc(tRiotChapter1, tRiotChapter2)
        return tRiotChapter1._nChapterId < tRiotChapter2._nChapterId
    end
    table.sort(self._tShowedRiotChapterList, sortFunc)

    return self._tShowedRiotChapterList
end

-- 更新
function HardDungeonData:updateRiotChapter(riot)
    local nChapterId = riot.ch_id
    local tRiotChapter = self:getRiotChapterById(nChapterId)
    if tRiotChapter then
        tRiotChapter._nChapterId = riot.ch_id
        tRiotChapter._nOpenTime = riot.open_time
        tRiotChapter._nRiotId = riot.roit_id
        tRiotChapter._isFinished = riot.is_finish
    end
end

-- 从已经开启的暴动章节列表中，根据章节id, 拿到相应的章节数据，可能为空
function HardDungeonData:getRiotChapterById(nChapterId)
    self:getShowedRiotChapterList()
    local tRiotChapter = nil
    if type(nChapterId) ~= "number" or nChapterId <= 0 then
        return tRiotChapter
    end
    for key, val in pairs(self._tShowedRiotChapterList) do
        local tRiot = val
        if nChapterId == tRiot._nChapterId then
            tRiotChapter = tRiot
            break
        end
    end

    return tRiotChapter
end

function HardDungeonData:storeRiotBattleResult(buff)
    self._tRiotBattleResult = buff
end

function HardDungeonData:getRiotBattleResult()
    return self._tRiotBattleResult
end

function HardDungeonData:setShowRiotGateLayer(isOpen)
    self._isShowRiotGateLayer = isOpen or false
end
function HardDungeonData:getShowRiotGateLayer()
    local isShow = self._isShowRiotGateLayer or false
    self._isShowRiotGateLayer = false
    return isShow
end


-- 当前时间有敌方援军吗，并且是活着的
function HardDungeonData:curTimeExistRiotsAlive()
    self:getShowedRiotChapterList()
    if table.nums(self._tShowedRiotChapterList) == 0 then
        return false
    end
    for key, val in pairs(self._tShowedRiotChapterList) do
        local tRiotChapter = val
        if not tRiotChapter._isFinished then
            return true
        end
    end
    return false
end

-- 检查这个章节有没有暴动事件
function HardDungeonData:checkExistRiotById(nChapterId)
    local isExist = false
    if not self._tShowedRiotChapterList then
        return isExist
    end
    if table.nums(self._tShowedRiotChapterList) == 0 then
        return isExist
    end
    local tRiotChapter = self:getRiotChapterById(nChapterId) 
    if not tRiotChapter then
        return isExist
    elseif tRiotChapter and tRiotChapter._isFinished then
        return isExist
    elseif tRiotChapter and not tRiotChapter._isFinished then
        isExist = true
        return isExist
    end
    return isExist
end

-- 检查是否有新的暴动章节能够打了
function HardDungeonData:checkShowedChapterCountAdded()
    self:getShowedRiotChapterList()
    local nCount = 0
    if not self._tShowedRiotChapterList then
        self._nShowedChapterCount = nCount
        return false
    end
    nCount = table.nums(self._tShowedRiotChapterList)
    if nCount == 0 then
        self._nShowedChapterCount = nCount
        return false
    end
    if nCount > self._nShowedChapterCount then
        self._nShowedChapterCount = nCount
        return true
    end
    return false
end

function HardDungeonData:setShowOnCenterCount(nCount)
    self._nShowOnCenterCount = nCount or 0
end

function HardDungeonData:getShowOnCenterCount()
    local isAdded = self:checkShowedChapterCountAdded()
    if isAdded then
        -- 能显示的章节增加了，则
        self._nShowOnCenterCount = 0
    end
    return self._nShowOnCenterCount or 1
end

function HardDungeonData:getTimestampList()
    self._tTimestampList = {}
    for key, val in pairs(self._tRiotChapterList) do
        local tRiotChapter = val
        local nTimestamp = tRiotChapter._nOpenTime
        table.insert(self._tTimestampList, nTimestamp)
    end

    return self._tTimestampList
end

function HardDungeonData:getNextTimestamp(nCurTime)
    self:getTimestampList()
    local function sortFunc(nStamp1, nStamp2)
        return nStamp1 < nStamp2
    end
    table.sort(self._tTimestampList, sortFunc)
    for i=1, table.nums(self._tTimestampList) do
        local nTimestamp = self._tTimestampList[i]
        if nTimestamp > nCurTime then
            return nTimestamp
        end
    end
    return nil
end

-- 是否是点击了头像进入关卡界面打暴动boss的，做一个标记
function HardDungeonData:setEnterFlag(flag)
    self._bFlag = flag or false
end

function HardDungeonData:getEnterFlag()
    return self._bFlag or false
end

-- 玩家是否到达50级开启了精英副本，并且没有进入过，显示一个红点进行提示
-- 0==未进入过，1表示进入过
function HardDungeonData:recordHardDungeonEntered()
    -- 写入本地数据
    local tLocalData = storage.load(storage.rolePath(self._szStorgePath))
    if tLocalData == nil then
        tLocalData = {}
        tLocalData._nEnterFlag = 1
        storage.save(storage.rolePath(self._szStorgePath), tLocalData)
    else
        if tLocalData._nEnterFlag and tLocalData._nEnterFlag == 0 then
            tLocalData._nEnterFlag = 1
            storage.save(storage.rolePath(self._szStorgePath), tLocalData)
        end
    end
end

function HardDungeonData:isEnteredHardDungeon()
    if not G_moduleUnlock:isModuleUnlock(FunctionLevelConst.HARDDUNGEON) then
        return true
    end
    -- 读取本地数据
    local tLocalData = storage.load(storage.rolePath(self._szStorgePath))
    if tLocalData == nil then
        tLocalData = {}
        tLocalData._nEnterFlag = 0
        storage.save(storage.rolePath(self._szStorgePath), tLocalData)
        return false
    end

    if tLocalData._nEnterFlag == 0 then
        return false
    elseif tLocalData._nEnterFlag == 1 then
        return true
    end

    return true
end

-- 获得一个stage的挑战次数，包括最大能够挑战的次数
function HardDungeonData:getCurAndMaxChallengeTimes(nChapterId, nStageId)
    if type(nChapterId) ~= "number" or type(nStageId) ~= "number" then
        assert(false, "error chapter id or stage id ...")
        return 0, 0
    end

    local nCurTimes = 0
    local nMaxTimes = 0

    -- 获得该stage当前的可挑战次数
    local tChapter = self.chapter[nChapterId]
    if tChapter then
        local tStage = tChapter.list[nStageId]
        if tStage then
            nCurTimes = tStage._executeCount or 0
        end
    end

    -- 获得该stage最大的可挑战次数
    local tStageTmpl = hard_dungeon_stage_info.get(nStageId)
    if tStageTmpl then
        local tDungeonTmpl = G_GlobalFunc.getHardDungeonData(tStageTmpl.value)
        if tDungeonTmpl then
            nMaxTimes = tDungeonTmpl.num or 0
        end
    end

    return nCurTimes, nMaxTimes
end

return HardDungeonData

