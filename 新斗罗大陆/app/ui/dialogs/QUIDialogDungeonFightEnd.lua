-- @Author: xurui
-- @Date:   2020-04-17 11:59:32
-- @Last Modified by:   xurui
-- @Last Modified time: 2020-05-01 12:51:23
local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogDungeonFightEnd = class("QUIDialogDungeonFightEnd", QUIDialog)

local QNavigationController = import("...controllers.QNavigationController")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QUIViewController = import("..QUIViewController")
local QBattleDialogFightEnd = import("..battle.result.dialogs.QBattleDialogFightEnd")

function QUIDialogDungeonFightEnd:ctor(options)
	local ccbFile = "ccb/Dialog_dungeon_fight_end.ccbi"
    local callBacks = {
    }
    QUIDialogDungeonFightEnd.super.ctor(self, ccbFile, callBacks, options)
    self.isAnimation = true

	cc.GameObject.extend(self)
	self:addComponent("components.behavior.EventProtocol"):exportMethods()

    if options then
    	self._callBack = options.callBack
    	self._dungeonConfig = options.dungeonConfig
    	self._oldUser = options.oldUser
    	self._dungeonResult = options.result or {}
    end

    self:setInfo()
end

function QUIDialogDungeonFightEnd:viewDidAppear()
	QUIDialogDungeonFightEnd.super.viewDidAppear(self)

	self:addBackEvent(true)
end

function QUIDialogDungeonFightEnd:viewWillDisappear()
  	QUIDialogDungeonFightEnd.super.viewWillDisappear(self)

	self:removeBackEvent()
end

function QUIDialogDungeonFightEnd:setInfo()
	local dungeonConfig = clone(self._dungeonConfig or {})
	
	local heroInfos, count = remote.herosUtil:getMaxForceHeros()
	self._heroInfo = {}
	if count > 4 then count = 4 end
	for i = 1, count, 1 do
	  	self._heroInfo[i] = remote.herosUtil:getHeroByID(heroInfos[i].id)
	end

	local exp = QStaticDatabase:sharedDatabase():getTeamConfigByTeamLevel(remote.user.level).hero_exp / count
    dungeonConfig.heroExp = math.floor(dungeonConfig.hero_exp * exp)
    if self._dungeonResult.batchAwards then
    	dungeonConfig.awards = self._dungeonResult.batchAwards[1].awards
	end
	dungeonConfig.isActiveDungeon = true
	dungeonConfig.title = "三星（跳过战斗默认最高奖励）"
	dungeonConfig.prizeWheelMoneyGot = self._dungeonResult.prizeWheelMoneyGot

	local options = {
			config = dungeonConfig, 
			teamName = remote.teamManager.INSTANCE_TEAM,
			timeType = "2",
			isWin = true, 
			star = 3, 
			isExpMoneyScore = true, 
			exp = 0, 
			money = 0, 
			score = 0, 
			isHero = true,
			isAward = true,
			oldTeamLevel = self._oldUser.level,
			heroOldInfo = self._heroInfo,
			stores = self._dungeonResult.shops, 
			invasion = self._dungeonResult.userIntrusionResponse, 
			extAward = self._dungeonResult.extraExpItem,
			isQuickPass = true,
		}
	local dialog = QBattleDialogFightEnd.new(options, self:getCallTbl())
	dialog._ccbOwner.node_btn_data:setVisible(false)
	dialog:setPositionX(0)
	dialog:setPositionY(0)
	self._ccbOwner.node_view:addChild(dialog)
end

function QUIDialogDungeonFightEnd:getCallTbl()
	local tbl = {}
	tbl.onChoose = handler(self, self._checkTeamUp)
	tbl.onNext = handler(self, self._onNext)
	return tbl
end

function QUIDialogDungeonFightEnd:_checkTeamUp( ... )
    local isTeam = remote.user:checkTeamUp(nil, function()
    	self:_onTriggerClose()
	end)
	if isTeam == false then
		self:_onTriggerClose()
	end
end

function QUIDialogDungeonFightEnd:_onNext()
	self:_onTriggerClose()
end

function QUIDialogDungeonFightEnd:_backClickHandler()
    self:_onTriggerClose()
end

function QUIDialogDungeonFightEnd:_onTriggerClose()
  	app.sound:playSound("common_close")
	app.sound:playMusic("main_interface")

	local callback = self._callBack
	self:popSelf()
	if callback then
		callback()
	end
end

return QUIDialogDungeonFightEnd
