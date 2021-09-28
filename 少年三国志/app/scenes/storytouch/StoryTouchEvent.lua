require("app.cfg.story_touch_info")
require("app.cfg.story_dungeon_touch_info")
local _storyDungeonConst = require("app.const.StoryDungeonConst")
 local BattleLayer = require "app.scenes.battle.BattleLayer"
local StoryTouchEvent = {}


-- @desc查找首次进入是否有剧情,有剧情则显示剧情
-- @param Id 副本id
-- @param _storyDungeonConst 剧情触发条件
-- @param _touchType        剧情触发类型
-- @param monsterId         怪物id
function StoryTouchEvent.isHaveStory(storyType,Id,_storyDungeonConst,_touchType,monsterId,_stageId)
    local storage = require("app.storage.storage")
    function flushUserData(_data)
        if storyType ~= _storyDungeonConst.STORYTYPE.TYPE_NEWGUIDE then
            storage.save(storage.rolePath("storytalk.data"),_data)
        end
        return _data
    end

    local data = nil
    if storyType == _storyDungeonConst.STORYTYPE.TYPE_DUNGEON then
        -- 已经打过 不触发剧情
        if _stageId < G_Me.dungeonData:getStageNewId() then
            return
        end
    end

    data = story_touch_info.get(_touchType, Id,storyType)
    if data then
        -- 查找是否已经显示过对话 只记录当前关卡对话
        local info = storage.load(storage.rolePath("storytalk.data"))
        if info == nil then -- 新的副本
            info = flushUserData({})
        end

        function initdata(id)
            info["type_" .. storyType] = {
                ["id"] = id,
                ["firstEnter"] = false,       --首次进入副本触发
                ["passDugneon"] = false,      -- 首次通关副本
                ["deadmonsterId"] = 0,        -- 杀死某个怪物
                ["move1"] = false,            -- 移动一波后触发  
                ["move2"] = false,            -- 移动两波后触发  
                ["outside_finish"] = false,   -- 进入战斗后立刻触发
                ["outside_finish2"] = false,   -- 进入战斗第二波移动后触发
                ["firstattackid"] = 0         -- 首次攻击
                }
        end

        if info["type_" .. storyType]  == nil then
            initdata(0) 
            flushUserData(info["type_" .. storyType])               -- 首次攻击触发  
        end
        -- 一个新的剧情对话
        if info["type_" .. storyType].id ~=  Id then
            initdata(Id) 
            flushUserData(info["type_" .. storyType])               -- 首次攻击触发  
        end

        if _touchType ==  _storyDungeonConst.TOUCHTYPE.TYPE_FIRSTENTER then -- 首次进入
            if info["type_" .. storyType].firstEnter == true  then return false end
        elseif _touchType ==  _storyDungeonConst.TOUCHTYPE.TYPE_KILLMONSTER then    -- 击杀某怪物
            if info["type_" .. storyType].deadmonsterId == monsterId  then return false end
        elseif _touchType ==  _storyDungeonConst.TOUCHTYPE.TYPE_BATTLE_MOVE_FINISH1 then    -- 移动一波后触发
            if info["type_" .. storyType].move1 == true  then return false end
        elseif _touchType ==  _storyDungeonConst.TOUCHTYPE.TYPE_BATTLE_MOVE_FINISH2 then     -- 移动两波后触发
            if info["type_" .. storyType].move2 == true  then return false end
        elseif _touchType ==  _storyDungeonConst.TOUCHTYPE.TYPE_OUTSIDE_FINISH then    -- 进入战斗后立刻触发
            if info["type_" .. storyType].outside_finish == true  then return false end
        elseif _touchType ==  _storyDungeonConst.TOUCHTYPE.TYPE_OUTSIDE_FINISH2 then    -- 进入战斗第二波移动后触发
            if info["type_" .. storyType].outside_finish2 == true  then return false end
        elseif _touchType ==  _storyDungeonConst.TOUCHTYPE.TYPE_BATTLE_FIRSTATTACK then     -- 首次攻击
            if info["type_" .. storyType].firstattackid == monsterId  then return false end              
        else
            if info["type_" .. storyType].passDugneon == true  then return false end                    -- 首次通关副本
        end

        if  storyType == _storyDungeonConst.STORYTYPE.TYPE_STORYDUGEON then
            -- 已经打过 不触发剧情
            if G_Me.storyDungeonData._nBranch == _storyDungeonConst.BRANCH.NORMAL then
                if G_Me.storyDungeonData:isPass(_stageId) then
                    return
                end
            elseif G_Me.storyDungeonData._nBranch == _storyDungeonConst.BRANCH.EPIC_WAR then
                if G_Me.storyDungeonData:isPass(_stageId) and info["type_" .. storyType].passDugneon then
                    return
                end
            end
        end
 
        if _touchType ==  _storyDungeonConst.TOUCHTYPE.TYPE_FIRSTENTER then -- 首次进入
            info["type_" .. storyType].firstEnter = true
        elseif _touchType ==  _storyDungeonConst.TOUCHTYPE.TYPE_KILLMONSTER then    -- 击杀某怪物
            if data.monster_id and data.monster_id == monsterId then
                info["type_" .. storyType].deadmonsterId = monsterId
            else
                return false
            end
        elseif _touchType ==  _storyDungeonConst.TOUCHTYPE.TYPE_BATTLE_MOVE_FINISH1 then    -- 移动一波后触发
            info["type_" .. storyType].move1 = true 
        elseif _touchType ==  _storyDungeonConst.TOUCHTYPE.TYPE_BATTLE_MOVE_FINISH2 then     -- 移动两波后触发
            info["type_" .. storyType].move2 = true 
        elseif _touchType ==  _storyDungeonConst.TOUCHTYPE.TYPE_OUTSIDE_FINISH then    -- 进入战斗后立刻触发
           info["type_" .. storyType].outside_finish = true  
        elseif _touchType ==  _storyDungeonConst.TOUCHTYPE.TYPE_OUTSIDE_FINISH2 then    -- 进入战斗第二波移动后触发
           info["type_" .. storyType].outside_finish2 = true  
        elseif _touchType ==  _storyDungeonConst.TOUCHTYPE.TYPE_BATTLE_FIRSTATTACK then     -- 首次攻击
            info["type_" .. storyType].firstattackid = monsterId
        else
            info["type_" .. storyType].passDugneon = true -- 通关某副本
        end

        flushUserData(info)
        return true, data.story_id
    end
    return false
end

function StoryTouchEvent.BattleEvent(event,...)
    local monsterid = 0
    local touchtype = nil
    if event == BattleLayer.BATTLE_SOMEONE_DEAD then
        local params = {...}
        if params[1] == 2 then
            monsterid = params[2]
            touchtype = _storyDungeonConst.TOUCHTYPE.TYPE_KILLMONSTER
        end
    elseif event == BattleLayer.BATTLE_MOVE_FROM_OUTSIDE_FINISH then -- 首次进入战斗
         touchtype = _storyDungeonConst.TOUCHTYPE.TYPE_OUTSIDE_FINISH
    elseif event == BattleLayer.BATTLE_SOMEONE_ATTACK then                     -- 某个角色攻击
        local params = {...}
        if params[1] == 2 then
            monsterid = params[3] 
            touchtype = _storyDungeonConst.TOUCHTYPE.TYPE_OUTSIDE_FINISH
        end
    elseif event == BattleLayer.BATTLE_MOVE_FINISH then                     -- 战斗波数移动结束
        local params = {...}
         if params[1] == 2 then             -- 第二波
            touchtype = _storyDungeonConst.TOUCHTYPE.TYPE_BATTLE_MOVE_FINISH1
         elseif params[1] == 3 then     -- 第三波
            touchtype = _storyDungeonConst.TOUCHTYPE.TYPE_BATTLE_MOVE_FINISH2
         end
    end

    return monsterid,touchtype
end

return StoryTouchEvent

