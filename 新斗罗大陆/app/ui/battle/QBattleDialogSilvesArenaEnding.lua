--
-- Kumo.Wang
-- 西尔维斯大斗魂场战斗总结算
--

local QBattleDialog = import("...QBattleDialog")
local QBattleDialogSilvesArenaEnding = class("QBattleDialogSilvesArenaEnding", QBattleDialog)

local QBattleDialogSilvesFightDataRecord = import(".QBattleDialogSilvesFightDataRecord")
local QUIWidgetAvatar = import("....widgets.QUIWidgetAvatar")
local QRichText = import("...utils.QRichText")

function QBattleDialogSilvesArenaEnding:ctor(options, owner)
	local ccbFile = "ccb/Dialog_SilvesArena_Ending.ccbi"
	local callBacks = {
		{ccbCallbackName = "onTriggerNext", callback = handler(self, QBattleDialogSilvesArenaEnding._onTriggerNext)},
		{ccbCallbackName = "onTriggerData", callback = handler(self, QBattleDialogSilvesArenaEnding._onTriggerData)},
	}
	if owner == nil then 
		owner = {}
	end

	self:setNodeEventEnabled(true)
	QBattleDialogSilvesArenaEnding.super.ctor(self,ccbFile,owner,callBacks)

    CalculateUIBgSize(self._ccbOwner.ly_bg)
	
	self._isWin = options.isWin
	local curIndex = options.index
	self._callback = options.callback

    local dungeonConfig = app.battle:getDungeonConfig()
    local teamInfo = {hero = {}, enemy = {}}

	if q.isEmpty(remote.silvesArena.fightInfo) then
		self:_onTriggerNext()
	else
		local attackFightInfo = remote.silvesArena.fightInfo.attackFightInfo or {}
		for _, info in pairs(attackFightInfo) do
			-- if info.silvesArenaFightPos <= curIndex then
				table.insert(teamInfo.hero, info)
			-- end
		end

		local defenseFightInfo = remote.silvesArena.fightInfo.defenseFightInfo or {}
		for _, info in pairs(defenseFightInfo) do
			-- if info.silvesArenaFightPos <= curIndex then
				table.insert(teamInfo.enemy, info)
			-- end
		end
	end
	-- QKumo(teamInfo)
	if q.isEmpty(teamInfo) or q.isEmpty(teamInfo.hero) or q.isEmpty(teamInfo.enemy) then
		self:_onTriggerNext()
		return
	end

	self._ccbOwner.node_title_win:setVisible(self._isWin)
	self._ccbOwner.node_title_lose:setVisible(not self._isWin)

	if q.isEmpty(remote.silvesArena.fightInfo.scoreList) then
		self:_onTriggerNext()
	else
		local score_1 = 0
		local score_2 = 0

		for i = 1, curIndex, 1 do
			local score = remote.silvesArena.fightInfo.scoreList[i] or 0
			if score then
				if score == 1 then
					score_1 = score_1 + 1
				end
				if score == 0 then
					score_2 = score_2 + 1
				end
			end
		end

		self._ccbOwner.firstCup:setString(score_1)
		self._ccbOwner.secondCup:setString(score_2)
	end
	
	self._ccbOwner.team1Name:setString(remote.silvesArena.fightInfo.team1Name or "")
	self._ccbOwner.team2Name:setString(remote.silvesArena.fightInfo.team2Name or "")

	for i, info in ipairs(teamInfo.hero) do
		self._ccbOwner["team1Head"..i]:removeAllChildren()
		local avatar = QUIWidgetAvatar.new(info.avatar)
		avatar:setSilvesArenaPeak(info.championCount)
   		self._ccbOwner["team1Head"..i]:addChild(avatar)
	end
	for i, info in ipairs(teamInfo.enemy) do
		self._ccbOwner["team2Head"..i]:removeAllChildren()
		local avatar = QUIWidgetAvatar.new(info.avatar)
		avatar:setSilvesArenaPeak(info.championCount)
		avatar:setScaleX(-1)
   		self._ccbOwner["team2Head"..i]:addChild(avatar)
	end
		
	self._ccbOwner.node_rtf_score:removeAllChildren()
    if dungeonConfig.fightEndAddScore then
    	local addScore = ""
    	local addScoreColor = ""
    	if dungeonConfig.fightEndAddScore > 0 then
    		addScore = "+"..dungeonConfig.fightEndAddScore
    		addScoreColor = COLORS.c
    	else
    		addScore = dungeonConfig.fightEndAddScore
    		addScoreColor = COLORS.e
    	end
    	local preScore = remote.silvesArena.myTeamInfo.teamScore - dungeonConfig.fightEndAddScore
    	local richTextNode = QRichText.new()
        richTextNode:setString({
            {oType = "font", content = "小队积分",size = 20,color = COLORS.b},
            {oType = "font", content = preScore.."（", size = 20,color = COLORS.b},
            {oType = "font", content = addScore, size = 20,color = addScoreColor},
            {oType = "font", content = "）", size = 20,color = COLORS.b},
        })
        richTextNode:setAnchorPoint(ccp(0.5, 0.5))
        self._ccbOwner.node_rtf_score:addChild(richTextNode)
    end

  	if self._isWin then
		self._audioHandler = app.sound:playSound("battle_complete")
	else
		self._audioHandler = app.sound:playSound("battle_failed")
	end

    audio.stopBackgroundMusic()
	
	self._openTime = q.time()
end

function QBattleDialogSilvesArenaEnding:onEnter()
end

function QBattleDialogSilvesArenaEnding:onExit()
end

function QBattleDialogSilvesArenaEnding:_onTriggerNext(event)
    if q.buttonEventShadow(event, self._ccbOwner.btn_next) == false then return end
  	app.sound:playSound("common_item")
	self:onClose()
end

function QBattleDialogSilvesArenaEnding:_backClickHandler()
	if q.time() - self._openTime > 3.5 then
		self:onClose()
  	end
end

function QBattleDialogSilvesArenaEnding:onClose()
	if self._callback then
		print("QBattleDialogSilvesArenaEnding:onClose()")
		self._callback()
	end
	self._ccbOwner:onNext()
	audio.stopSound(self._audioHandler)
end

function QBattleDialogSilvesArenaEnding:_onTriggerData(event)
    if q.buttonEventShadow(event, self._ccbOwner.btn_data) == false then return end
    app.sound:playSound("common_small")
    QBattleDialogSilvesFightDataRecord.new() 
end

return QBattleDialogSilvesArenaEnding