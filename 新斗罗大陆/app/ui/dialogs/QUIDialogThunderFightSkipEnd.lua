-- @Author: liaoxianbo
-- @Date:   2020-09-11 14:45:56
-- @Last Modified by:   liaoxianbo
-- @Last Modified time: 2020-09-15 17:44:46
local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogThunderFightSkipEnd = class("QUIDialogThunderFightSkipEnd", QUIDialog)

local QNavigationController = import("...controllers.QNavigationController")
local QUIViewController = import("..QUIViewController")
local QThunderDialogWin = import("..battle.result.dialogs.QThunderDialogWin")

function QUIDialogThunderFightSkipEnd:ctor(options)
	local ccbFile = "ccb/Dialog_dungeon_fight_end.ccbi"
    local callBacks = {
    }
    QUIDialogThunderFightSkipEnd.super.ctor(self, ccbFile, callBacks, options)
    self.isAnimation = true

	cc.GameObject.extend(self)
	self:addComponent("components.behavior.EventProtocol"):exportMethods()

    if options then
    	self._callBack = options.callBack
    	self._dungeonConfig = options.dungeonConfig
    	self._oldUser = options.oldUser
    	self._dungeonResult = options.result or {}
    end
	self._thunderMoney = {money = self._oldUser.money, thunderMoney = self._oldUser.thunderMoney}
    self:setInfo()
end

function QUIDialogThunderFightSkipEnd:viewDidAppear()
	QUIDialogThunderFightSkipEnd.super.viewDidAppear(self)

	self:addBackEvent(true)
end

function QUIDialogThunderFightSkipEnd:viewWillDisappear()
  	QUIDialogThunderFightSkipEnd.super.viewWillDisappear(self)

	self:removeBackEvent()
end

function QUIDialogThunderFightSkipEnd:setInfo()
	local dungeonConfig = self._dungeonConfig or {}
    self._teamName = dungeonConfig.teamName or remote.teamManager.THUNDER_TEAM
    local teamHero = remote.teamManager:getActorIdsByKey(self._teamName, 1)
    local heroTotalCount = #teamHero
    self._heroOldInfo = {}
    for i = 1, heroTotalCount, 1 do
        self._heroOldInfo[i] = remote.herosUtil:getHeroByID(teamHero[i])
    end

    local awards = {}
    local prizesThunderMoney = 0
    if self._dungeonResult.apiThunderFightEndResponse and self._dungeonResult.apiThunderFightEndResponse.luckyDraw ~= nil then
        local prizes = self._dungeonResult.apiThunderFightEndResponse.luckyDraw.prizes 
        if prizes ~= nil then
            for _, value in pairs(prizes) do
                if value.type == "THUNDER_MONEY" then
                    prizesThunderMoney = value.count
                end
            end
        end
    end

    --节假日活动掉落
    if self._dungeonResult and self._dungeonResult.extraExpItem and type(self._dungeonResult.extraExpItem) == "table" then
        for _, value in pairs(self._dungeonResult.extraExpItem) do
            table.insert(awards, {id = value.id, type = value.type, count = value.count or 0})
        end
    end

    local exp = 0
    local money = remote.user.money - self._thunderMoney.money
    local yield = self._dungeonResult.apiThunderFightEndResponse and (self._dungeonResult.apiThunderFightEndResponse.yield or 1) or 1
    local userComeBackRatio = self._dungeonResult.userComeBackRatio or 1
    local activityYield = remote.activity:getActivityMultipleYield(607)
    if userComeBackRatio > 0 then
        activityYield = (activityYield - 1) + (userComeBackRatio - 1) + 1
    end
    local dungeonId = dungeonConfig.dungeonId
    local thunderMoney = remote.user.thunderMoney - self._thunderMoney.thunderMoney - prizesThunderMoney
    if thunderMoney > 0 and dungeonConfig.waveType ~= "ELITE_WAVE" then
        table.insert(awards,{id = nil, type = ITEM_TYPE.THUNDER_MONEY, count = thunderMoney})
    end
    -- print(remote.activity:getActivityMultipleYield(607), userComeBackRatio, activityYield)
    local winNpc = dungeonConfig.oldThunderInfo[1].thunderEliteAlreadyWinNpc
    remote.thunder:setEliteBattleInfo(dungeonConfig.eliteWave, winNpc)

    local dialog = QThunderDialogWin.new({
        heroOldInfo = self._heroOldInfo,
        oldTeamLevel = self._oldUser.level,
        teamName = self._teamName,
        exp = exp,
        money = money, 
        timeType = "2",
        awards = awards, -- 奖励物品
        yield = yield, -- 战斗奖励翻倍
        activityYield = activityYield, -- 活动双倍
        dungeonId = dungeonId,
        isWin = true
        },self:getCallTbl())
	dialog._ccbOwner.node_btn_data:setVisible(false)
	dialog:setPositionX(0)
	dialog:setPositionY(0)
	self._ccbOwner.node_view:addChild(dialog)
end

function QUIDialogThunderFightSkipEnd:getCallTbl()
	local tbl = {}
	tbl.onChoose = handler(self, self._checkTeamUp)
	tbl.onNext = handler(self, self._onNext)
	return tbl
end

function QUIDialogThunderFightSkipEnd:_checkTeamUp( ... )
    local isTeam = remote.user:checkTeamUp(nil, function()
    	self:_onTriggerClose()
	end)
	if isTeam == false then
		self:_onTriggerClose()
	end
end

function QUIDialogThunderFightSkipEnd:_onNext()
	self:_onTriggerClose()
end

function QUIDialogThunderFightSkipEnd:_backClickHandler()
    self:_onTriggerClose()
end

function QUIDialogThunderFightSkipEnd:_onTriggerClose()
  	app.sound:playSound("common_close")
	app.sound:playMusic("main_interface")

	local callback = self._callBack
	self:popSelf()
	if callback then
		callback()
	end
end

return QUIDialogThunderFightSkipEnd
