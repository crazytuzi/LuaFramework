--
-- Kumo.Wang
-- 西尔维斯大斗魂场战斗总结算——非战斗里面
--

local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogSilvesArenaEnding = class("QUIDialogSilvesArenaEnding", QUIDialog)

local QUIWidgetAvatar = import("..widgets.QUIWidgetAvatar")
local QRichText = import("...utils.QRichText")
local QUIViewController = import("...ui.QUIViewController")

function QUIDialogSilvesArenaEnding:ctor(options)
	local ccbFile = "ccb/Dialog_SilvesArena_Ending.ccbi"
	local callBacks = {
		{ccbCallbackName = "onTriggerNext", callback = handler(self, QUIDialogSilvesArenaEnding._onTriggerNext)},
		{ccbCallbackName = "onTriggerData", callback = handler(self, QUIDialogSilvesArenaEnding._onTriggerData)},
	}
    QUIDialogSilvesArenaEnding.super.ctor(self, ccbFile, callBacks, options)

    CalculateUIBgSize(self._ccbOwner.ly_bg)
	
	local isWin = false
	local curIndex = 0
    local addScore = options.addScore or 0
    self._statsDataList = options.statsDataList
	self._callback = options.callback

	if not q.isEmpty(remote.silvesArena.fightInfo.endInfo) then
		curIndex = #remote.silvesArena.fightInfo.endInfo
	end

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

		isWin = score_1 > score_2
	end
	
	self._ccbOwner.node_title_win:setVisible(isWin)
	self._ccbOwner.node_title_lose:setVisible(not isWin)

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
    if addScore then
    	local _addScore = ""
    	local addScoreColor = ""
    	if addScore > 0 then
    		_addScore = "+"..addScore
    		addScoreColor = COLORS.c
    	else
    		_addScore = addScore
    		addScoreColor = COLORS.e
    	end
    	local preScore = remote.silvesArena.myTeamInfo.teamScore - addScore
    	local richTextNode = QRichText.new()
        richTextNode:setString({
            {oType = "font", content = "小队积分",size = 20,color = COLORS.b},
            {oType = "font", content = preScore.."（", size = 20,color = COLORS.b},
            {oType = "font", content = _addScore, size = 20,color = addScoreColor},
            {oType = "font", content = "）", size = 20,color = COLORS.b},
        })
        richTextNode:setAnchorPoint(ccp(0.5, 0.5))
        self._ccbOwner.node_rtf_score:addChild(richTextNode)
    end

  	if isWin then
		self._audioHandler = app.sound:playSound("battle_complete")
	else
		self._audioHandler = app.sound:playSound("battle_failed")
	end
	
	self._openTime = q.time()
end

function QUIDialogSilvesArenaEnding:onEnter()
end

function QUIDialogSilvesArenaEnding:onExit()
end

function QUIDialogSilvesArenaEnding:_onTriggerNext(event)
    if q.buttonEventShadow(event, self._ccbOwner.btn_next) == false then return end
  	app.sound:playSound("common_small")
	self:playEffectOut()
end

function QUIDialogSilvesArenaEnding:_backClickHandler()
	if q.time() - self._openTime > 3.5 then
		self:playEffectOut()
  	end
end

function QUIDialogSilvesArenaEnding:_onTriggerData(event)
    if q.buttonEventShadow(event, self._ccbOwner.btn_data) == false then return end
    app.sound:playSound("common_small")
    app:getNavigationManager():pushViewController(app.topLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogSilvesFightDataRecord", 
    	options = {isSkipBattle = true, statsDataList = self._statsDataList}}, {isPopCurrentDialog = true})
end


function QUIDialogSilvesArenaEnding:viewAnimationOutHandler()
	self:popSelf()

	if self._callback then
		self._callback()
	end
end

return QUIDialogSilvesArenaEnding