require("app.cfg.story_dungeon_info")
local StoryDungeonData = class("StoryDungeonData")
local StoryDungeonConst = require("app.const.StoryDungeonConst")

function StoryDungeonData:ctor()
    self.currField = nil -- 当前区域
    self._gateId = nil  
    self._bossId = nil
    self._date = nil 
    self._storyDungeonList = nil
    self._currStoryStatus = {
        dungeon_id = 0,
        barrier_id = 0,
        drop_awards = {},
        monster_awards = {}
    }
    self.execute_count = 0
    self._finishSanGuoZhi = nil
    
    
    -- 记录当前当前章节位置在地图列表的位置
    self._cellIndex = -1
    self._cellPos = 0

    -- 名将副本分为普通模式与史诗战役
    self._nBranch = StoryDungeonConst.BRANCH.NORMAL
end

-- 设置当前章节的位置
function StoryDungeonData:setCellPos(cellIndex,cellPos)
    self._cellIndex = cellIndex
    self._cellPos = cellPos
end

-- 得到当前章节的位置
function StoryDungeonData:getCellPos()
    return self._cellIndex,self._cellPos
end

 -- 添加剧情列表
function StoryDungeonData:addDungeonList(_data)
    
    self._date = G_ServerTime:getDate()
    
    if self._storyDungeonList == nil then self._storyDungeonList = {} end
    self.execute_count = _data.execute_count
    for k,v in pairs(_data.dungeons) do
        self:modifyStoryDungeon(v)
    end
end

-- 今日是否挑战过
function StoryDungeonData:isChallenge(storyId,barrierid)
    if self._storyDungeonList[storyId].played_barrier[barrierid] == true then
        return true
    else
        return false
    end
end

function StoryDungeonData:getDungeonList()
    return self._storyDungeonList
end
 -- 得到单个剧情信息
function StoryDungeonData:getStoryDungeon(id)
    if self._storyDungeonList == nil then
        return nil
    end
    
    for k,v in pairs(self._storyDungeonList) do
        if k == id then
            return v
        end
    end
    return nil
end

function StoryDungeonData:setCurrField(_fieldId)
    self.currField = _fieldId
end

-- 最新通关id
function StoryDungeonData:isPass(barrier_id)
    local info = story_barrier_info.get(barrier_id)
    if info then
        if self._storyDungeonList[info.dungeon] then
            if self._storyDungeonList[info.dungeon].is_finished == true or self._storyDungeonList[info.dungeon].barrier_id > barrier_id  then
                return true
            else
                return false
            end
        else
            return false
        end
    end
end

-- 修改当前副本状态
function StoryDungeonData:modifyStoryDungeon(data)
    if self._storyDungeonList[data.id] == nil then
        self._storyDungeonList[data.id] = {}
    end
    local tTemp = self._storyDungeonList[data.id]
    -- 当每一章节最后一个怪物首胜后，并且出现了首胜奖励界面，才算是真正的结束
    tTemp._isReallyFinished = tTemp.is_finished or false
    tTemp.barrier_id = data.barrier_id
    tTemp.is_finished = data.is_finished
    tTemp.is_entered = data.is_entered
    tTemp.has_award = data.has_award

    self.execute_count = data.execute_count
    tTemp.played_barrier = {}
    for i,j in pairs(data.played_barrier) do
        tTemp.played_barrier[j] = true
    end

--[[
    self._storyDungeonList[data.id] = {
        barrier_id = data.barrier_id,
        is_finished = data.is_finished,
        is_entered = data.is_entered,
        has_award = data.has_award
    }
    self.execute_count = data.execute_count
    self._storyDungeonList[data.id].played_barrier = {}
    for i,j in pairs(data.played_barrier) do
        self._storyDungeonList[data.id].played_barrier[j] = true
    end
    ]]
end

function StoryDungeonData:getCurrField()
    return self.currField
end

 -- 设置当前剧情状态
 function StoryDungeonData:setCurrStoryStatus(dungeon_id,barrier_id,drop_awards,monster_awards)
     self._currStoryStatus.dungeon_id = dungeon_id
     self._currStoryStatus.barrier_id = barrier_id
     for k,v in pairs(drop_awards) do
         table.insert(self._currStoryStatus.drop_awards,v)
     end
    for k,v in pairs(monster_awards) do
         table.insert(self._currStoryStatus.monster_awards,v)
     end
 end
 
-- 设置剧情关卡id
function StoryDungeonData:setCurrDungeonId(_id)
    
    -- 由于战报先发过来，后进行战斗 所以需要缓存进入战斗前的当前最新关卡Id
    -- 将最近使用的id 更新为最新开启的关卡id
   -- self.recentlyStageId = self.newestStageId
    self._gateId = _id
end

function StoryDungeonData:getCurrDungeonId()
    return self._gateId
end

-- 今日挑战次数
function StoryDungeonData:getExecutecount()
    return self.execute_count
end
-- 副本是否已开启
function StoryDungeonData:isOpenDungeon(dungeonId)
    if self._storyDungeonList == nil or self._storyDungeonList[dungeonId] == nil then
        return false
    else
        return true
    end
end

-- 设置选择当前武将id
function StoryDungeonData:setCurrBarrierId(_id)
    self._bossId = _id
end

function StoryDungeonData:getCurrBarrierId()
    return self._bossId
end

-- 三国志完成列表
function StoryDungeonData:addSanGuoZhiFinishList(_data)
    if self._finishSanGuoZhi == nil then self._finishSanGuoZhi = {} end
    for k,v in pairs(_data) do
        self._finishSanGuoZhi[v] = true
    end
end

function StoryDungeonData:addIdToSanGuoZhiFinishiList(_id)
    self._finishSanGuoZhi[_id] = true
end

function StoryDungeonData:getSanGuoZhiFinishList()
    return self._finishSanGuoZhi
end

-- 查看三国志是否完成
function StoryDungeonData:isFinishSanGuoZhi(id)
    return (self._finishSanGuoZhi[id] and true) or false
end


-- 查看是否有奖励领取
function StoryDungeonData:isHaveBouns()
    if self._storyDungeonList == nil then
        return false
    end
    for k,v in pairs(self._storyDungeonList) do
     local story_info = story_dungeon_info.get(k)
        if v.is_finished == true and v.has_award == false and story_info.type == 1 then
            return true
        end
    end
    return false
end

-- 是否有新开启副本
function StoryDungeonData:isNewDungeon()
    local _list = G_Me.storyDungeonData:getDungeonList()
    local showStoryTips = false
    if _list then
        for k,v in pairs(_list) do
            if v.is_entered == false then
                showStoryTips = true
                break
            end
        end
    end
    return showStoryTips
end

-- @desc 是否重新需要拉数据
function StoryDungeonData:isNeedRequestNewData()
    local dateTime = G_ServerTime:getDate()
    if dateTime ~= self._date  then
        return true
    else
        return false
    end
end

function StoryDungeonData:setBranch(nBranch)
    self._nBranch = nBranch
end

return StoryDungeonData

