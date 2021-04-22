-- @Author: xurui
-- @Date:   2019-08-07 15:45:28
-- @Last Modified by:   DELL
-- @Last Modified time: 2020-04-03 19:10:00
local QBaseSecretary = import(".QBaseSecretary")
local QTreasueBarSecretary = class("QTreasueBarSecretary", QBaseSecretary)

function QTreasueBarSecretary:ctor(options)
	QTreasueBarSecretary.super.ctor(self, options)

    self._activity = ACTIVITY_DUNGEON_TYPE.TREASURE_BAY
end

function QTreasueBarSecretary:executeSecretary()
    local maxCount = remote.activityInstance:getAttackMaxCountByType(self._activity)
    self:activityTrainBay(maxCount)
end

function QTreasueBarSecretary:getNameStr(taskId, idCount, logNum)
    local dungenMap = remote.activityInstance:getDungeonByIntId(idCount) or {}
    local dungenConfig = db:getDungeonConfigByIntID(idCount) or {}
    local name1 = dungenMap.instance_name or idCount
    local name2 = dungenConfig.name or ""
    nameStr = name1..name2

    return nameStr
end

-- 金币海湾
function QTreasueBarSecretary:activityTrainBay(num)
    if num <= 0 then
        remote.secretary:nextTaskRunning()
        return
    end
    if self:checkSecretaryIsComplete() then
        remote.secretary:nextTaskRunning()
        return
    end

    local callback = function(data)   
        if data.secretaryItemsLogResponse then    
            remote.secretary:updateSecretaryLog(data) 
            remote.activity:updateLocalDataByType(555, 1)
            remote.union.unionActive:updateActiveTaskProgress(20004, 6)
        end
        self:activityTrainBay(num-1)
    end

    local curSetting = remote.secretary:getSettingBySecretaryId(self._config.id)
    local isAutoEnergy = curSetting.isOpen or false
    -- 获取已通过的最大关卡
    local curDungeon = nil
    local config = remote.activityInstance:getInstanceListById(self._activity)
    for i, dungeon in pairs(config) do
        local passInfo = remote.activityInstance:getPassInfoById(dungeon.dungeon_id)
        if passInfo and passInfo.star == 3 then
            curDungeon = dungeon
        end
    end

    if curDungeon and remote.secretary:checkEnergy() then
        local battleType = BattleTypeEnum.DUNGEON_ACTIVITY
        app:getClient():fightActivityDungeonQuickRequest(battleType, curDungeon.dungeon_id, 1, true, callback)
    else
        remote.secretary:nextTaskRunning()
    end
end

function QTreasueBarSecretary:checkSecretaryIsComplete()
    local maxCount = remote.activityInstance:getAttackMaxCountByType(self._activity)
    local attackCount = remote.activityInstance:getAttackCountByType(self._activity)
    return attackCount >= maxCount
end

return QTreasueBarSecretary