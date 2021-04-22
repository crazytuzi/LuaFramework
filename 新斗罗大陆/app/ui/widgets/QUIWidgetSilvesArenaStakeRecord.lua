-- 
-- Kumo.Wang
-- Silves押注记录界面Cell
--

local QUIWidget = import("..QUIWidget")
local QUIWidgetSilvesArenaStakeRecord = class("QUIWidgetSilvesArenaStakeRecord", QUIWidget)

local QUIWidgetAvatar = import("..QUIWidgetAvatar")
local QUIViewController = import("..QUIViewController")

function QUIWidgetSilvesArenaStakeRecord:ctor(options)
	local ccbFile = "ccb/Widget_SilvesArena_Stake_Record.ccbi"
	local callBacks = {}
	QUIWidgetSilvesArenaStakeRecord.super.ctor(self,ccbFile,callBacks,options)
end

function QUIWidgetSilvesArenaStakeRecord:onEnter()
	QUIWidgetSilvesArenaStakeRecord.super.onEnter(self)
end

function QUIWidgetSilvesArenaStakeRecord:onExit()
	QUIWidgetSilvesArenaStakeRecord.super.onExit(self)
end

function QUIWidgetSilvesArenaStakeRecord:resetData()
	for i = 0, 2 do
		self._ccbOwner["sp_flag_"..i]:setVisible(false)
	end
	self._ccbOwner.node_head_11:removeAllChildren()
	self._ccbOwner.node_head_12:removeAllChildren()
	self._ccbOwner.node_head_13:removeAllChildren()
	self._ccbOwner.node_head_21:removeAllChildren()
	self._ccbOwner.node_head_22:removeAllChildren()
	self._ccbOwner.node_head_23:removeAllChildren()
	self._ccbOwner.tf_name_1:setString("")
	self._ccbOwner.tf_name_2:setString("")
	self._ccbOwner.tf_score:setString("")
	self._ccbOwner.tf_reward:setString(0)
	self._ccbOwner.tf_bet_num:setString(0)
	self._ccbOwner.node_reward:setVisible(false)
	self._ccbOwner.btn_detail:setVisible(false)
end

--刷新数据
function QUIWidgetSilvesArenaStakeRecord:setInfo(info)
	self:resetData()
	self._info = info

	self._ccbOwner.tf_name_1:setString(info.team1.teamName)
	self._ccbOwner.tf_name_2:setString(info.team2.teamName)

	local avatar11 = QUIWidgetAvatar.new(info.team1.leader.avatar)
	avatar11:setSilvesArenaPeak(info.team1.leader.championCount)
    self._ccbOwner.node_head_11:addChild(avatar11)
    local avatar12 = QUIWidgetAvatar.new(info.team1.member1.avatar)
    avatar12:setSilvesArenaPeak(info.team1.member1.championCount)
    self._ccbOwner.node_head_12:addChild(avatar12)
    local avatar13 = QUIWidgetAvatar.new(info.team1.member2.avatar)
    avatar13:setSilvesArenaPeak(info.team1.member2.championCount)
    self._ccbOwner.node_head_13:addChild(avatar13)

	local avatar21 = QUIWidgetAvatar.new(info.team2.leader.avatar)
	avatar21:setSilvesArenaPeak(info.team2.leader.championCount)
    avatar21:setScaleX(-1)
    self._ccbOwner.node_head_21:addChild(avatar21)
    local avatar22 = QUIWidgetAvatar.new(info.team2.member1.avatar)
    avatar22:setSilvesArenaPeak(info.team2.member1.championCount)
    avatar22:setScaleX(-1)
    self._ccbOwner.node_head_22:addChild(avatar22)
    local avatar23 = QUIWidgetAvatar.new(info.team2.member2.avatar)
    avatar23:setSilvesArenaPeak(info.team2.member2.championCount)
    avatar23:setScaleX(-1)
    self._ccbOwner.node_head_23:addChild(avatar23)

    local score = remote.silvesArena.PEAK_SCORE_LIST[info.myScoreId]
	self._ccbOwner.tf_score:setString(score[1].." : "..score[2])

	self._ccbOwner.tf_bet_num:setString(info.localInfo.myBetNum)
	self._ccbOwner["sp_flag_"..info.localInfo.bingoState]:setVisible(true)

	if info.localInfo.bingoState == 1 then
		self._ccbOwner.node_reward:setVisible(true)
		self._ccbOwner.tf_reward:setString(info.localInfo.canGetNum)
		self._ccbOwner.tf_reward_name:setString("收益：")
	elseif info.localInfo.bingoState == 0 then
		self._ccbOwner.node_reward:setVisible(true)
		self._ccbOwner.tf_reward:setString(info.localInfo.canGetNum)
		self._ccbOwner.tf_reward_name:setString("预计：")
	end

	self._ccbOwner.btn_detail:setVisible(info.localInfo.bingoState ~= 0)
end

function QUIWidgetSilvesArenaStakeRecord:getContentSize()
	return self._ccbOwner.node_size:getContentSize()
end

function QUIWidgetSilvesArenaStakeRecord:_onTriggerDetail()
	if q.isEmpty(self._info) or q.isEmpty(self._info.team1) or q.isEmpty(self._info.team2) or not self._info.team1.teamId or not self._info.team2.teamId then return end

	remote.silvesArena:silvesPeakGetBattleInfoRequest(self._info.team1.teamId, self._info.team2.teamId, function ( data )
        local battleReport = data.silvesArenaInfoResponse.battleReport
        local lastfightAt = 0
        for i, v in ipairs(battleReport) do
            if v.fightersData then
                local content = crypto.decodeBase64(v.fightersData)
                local replayInfo = app:getProtocol():decodeBufferToMessage("cc.qidea.wow.client.battle.ReplayInfo", content)

                v.replayInfo = replayInfo
            end
            if lastfightAt == 0 or lastfightAt < v.fightAt then
                lastfightAt = v.fightAt
            end
            QKumo(v.replayInfo)
        end
        battleReport.reportType = REPORT_TYPE.SILVES_ARENA
        battleReport.matchingId = matchingId
        battleReport.reportIdList = reportIdList
        battleReport.fightAt = lastfightAt
        
        app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogSilvesArenaRecordDetail",
            options = {info = battleReport, isFight = isFight, showShare = false}}, {isPopCurrentDialog = false})
    end)
end

return QUIWidgetSilvesArenaStakeRecord