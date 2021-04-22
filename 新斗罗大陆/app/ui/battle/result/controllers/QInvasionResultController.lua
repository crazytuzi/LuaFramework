-- @Author: xurui
-- @Date:   2017-04-27 11:04:57
-- @Last Modified by:   xurui
-- @Last Modified time: 2019-09-06 16:48:24
local QBaseResultController = import(".QBaseResultController")
local QInvasionResultController = class("QInvasionResultController", QBaseResultController)

local QRebelDialogWin = import("..dialogs.QRebelDialogWin")

function QInvasionResultController:ctor(options)
end

function QInvasionResultController:requestResult(isWin)
	self._isWin = isWin
    local battleScene = self:getScene()
	local dungeonConfig = battleScene:getDungeonConfig()


    self.intrusion_money = remote.user.intrusion_money
    remote.invasion:invasionEndRequest(hp, dungeonConfig.invasion.userId, dungeonConfig.verifyKey, false, function (data)
        dungeonConfig.fightEndResponse = data
        self:setResponse(data)

        remote.activity:updateLocalDataByType(531, 1)
        remote.user:addPropNumForKey("c_fortressFightCount")

        app.taskEvent:updateTaskEventProgress(app.taskEvent.INVATION_EVENT, 1, false, true)
    end, function(data)
        self:requestFail(data)
        if data.error == "INTRUSION_BOSS_NOT_EXIST" then
            dungeonConfig.invasion.bossId = 0 
            remote.invasion:getInvasionRequest()
        else
            remote.invasion:setInvasionUpdate(true)
        end
    end, false)
end

function QInvasionResultController:fightEndHandler()
    local battleScene = self:getScene()
    local dungeonConfig = battleScene:getDungeonConfig()

    local meritorious = (remote.invasion:getSelfInvasion().allHurt or 0) - (remote.invasion:getSelfOldInvasion().allHurt or 0)
    local userComeBackRatio = self.response.userComeBackRatio or 1
    local activityYield = 1
    if userComeBackRatio > 0 then
        activityYield = userComeBackRatio
    end
    remote.activity:updateLocalDataByType(700, meritorious)
    -- remote.trailer:updateTaskProgressByTaskId("4000019", 1)
    
    battleScene.curModalDialog = QRebelDialogWin.new({
        damage = self.response.userIntrusionResponse.deltaBossHp or 0, --造成伤害
        meritorious = (remote.invasion:getSelfInvasion().allHurt or 0) - (remote.invasion:getSelfOldInvasion().allHurt or 0), --获得功勋
        meritOldRank = dungeonConfig.rebelMeritRank , --功勋名次左
        meritNewRank = remote.invasion:getSelfInvasion().allHurtRank, --功勋名次右
        damageOldRank = dungeonConfig.rebelDamageRank, --伤害名次左
        damageNewRank = remote.invasion:getSelfInvasion().maxHurtRank, --伤害名次右
        baseRebelToken = math.floor(dungeonConfig.rebelToken * 50 * self.response.userIntrusionResponse.criticalHit), --基础获得
        addRebelToken = (remote.user.intrusion_money or 0) - (self.intrusion_money or 0), --总共获得
        activityYield = activityYield,
        isWin = true,
        intrusionFightEndAward = self.response.intrusionFightEndAward
    }, self:getCallTbl())
end

return QInvasionResultController