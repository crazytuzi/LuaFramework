-- 
-- Kumo.Wang
-- Silves巅峰赛战报界面
--

local QUIDialog = import(".QUIDialog")
local QUIDialogSilvesArenaPeakBattleRecord = class("QUIDialogSilvesArenaPeakBattleRecord", QUIDialog)

local QReplayUtil = import("...utils.QReplayUtil")
local QUIViewController = import("..QUIViewController")

local QUIWidgetSilvesArenaPeakGroupClientCell = import("..widgets.QUIWidgetSilvesArenaPeakGroupClientCell")
local QUIWidgetSilvesArenaPeakThirdClientCell = import("..widgets.QUIWidgetSilvesArenaPeakThirdClientCell")
local QUIWidgetSilvesArenaPeakGroupBtn = import("..widgets.QUIWidgetSilvesArenaPeakGroupBtn")

QUIDialogSilvesArenaPeakBattleRecord.TAB_REPORTS_FOR_TOP_16 = "TAB_REPORTS_FOR_TOP_16"
QUIDialogSilvesArenaPeakBattleRecord.TAB_REPORTS_FOR_TOP_4 = "TAB_REPORTS_FOR_TOP_4"

function QUIDialogSilvesArenaPeakBattleRecord:ctor(options)
	local ccbFile = "ccb/Dialog_SilvesArena_Peak_BattleRecord.ccbi"
	local callBacks = {
        {ccbCallbackName = "onTriggerReportForTop16", callback = handler(self, self._onTriggerReportForTop16)},
        {ccbCallbackName = "onTriggerReportForTop4", callback = handler(self, self._onTriggerReportForTop4)},
        {ccbCallbackName = "onTriggerClose", callback = handler(self, self._onTriggerClose)},
	}
	QUIDialogSilvesArenaPeakBattleRecord.super.ctor(self,ccbFile,callBacks,options)
	self.isAnimation = true

	self._selectTab = options.selectTab or QUIDialogSilvesArenaPeakBattleRecord.TAB_REPORTS_FOR_TOP_16
	self:_selectTabs(true)
	self:_init()
end

function QUIDialogSilvesArenaPeakBattleRecord:_reset()
	self._ccbOwner.node_group_cell:removeAllChildren()
	self._ccbOwner.node_group_btn:removeAllChildren()
	self._ccbOwner.node_no:setVisible(false)
	self._ccbOwner.node_result_bg:setVisible(true)
end

function QUIDialogSilvesArenaPeakBattleRecord:_init()
	self:_reset()

	self._groupSize = 4 -- 一组4人（取决于ccb）

	if q.isEmpty(remote.silvesArena.peakTeamInfo) then 
		self._ccbOwner.node_no:setVisible(true)
		self._ccbOwner.node_group_cell:setVisible(false)
		self._ccbOwner.node_group_btn:setVisible(false)
		self._ccbOwner.node_result_bg:setVisible(false)
		return 
	end

	self._cellWidget = QUIWidgetSilvesArenaPeakGroupClientCell.new()
	self._cellWidget:addEventListener(QUIWidgetSilvesArenaPeakGroupClientCell.EVENT_RIGHT, handler(self, self._onCellEvent))
	self._cellWidget:addEventListener(QUIWidgetSilvesArenaPeakGroupClientCell.EVENT_LEFT, handler(self, self._onCellEvent))
	self._cellWidget:addEventListener(QUIWidgetSilvesArenaPeakGroupClientCell.EVENT_REPLAY, handler(self, self._onCellEvent))
	self._ccbOwner.node_group_cell:addChild(self._cellWidget)

	self._thirdWidget = QUIWidgetSilvesArenaPeakThirdClientCell.new()
	self._thirdWidget:addEventListener(QUIWidgetSilvesArenaPeakThirdClientCell.EVENT_REPLAY, handler(self, self._onThirdEvent))
	self._ccbOwner.node_group_cell:addChild(self._thirdWidget)
	self._thirdWidget:setPositionY(-140)

	self:_update()

	self._btnCells = {}
	for index = 1, #self._groupData, 1 do
		if not self._btnCells[index] then
			self._btnCells[index] = QUIWidgetSilvesArenaPeakGroupBtn.new({index = index, myGroupIndex = self._myGroupIndex})
			self._btnCells[index]:addEventListener(QUIWidgetSilvesArenaPeakGroupBtn.EVENT_CLICK, handler(self, self._onBtnClick))
			self._ccbOwner.node_group_btn:addChild(self._btnCells[index])
			self._btnCells[index]:setPositionX(self._btnCells[index]:getContentSize().width * (index - 1) + self._btnCells[index]:getContentSize().width / 2)
		end
		if self._btnCells[index] then
			self._btnCells[index]:update(self._curIndex)
		end
	end

	self._ccbOwner.node_group_btn:setPositionX(- self._btnCells[1]:getContentSize().width * #self._btnCells / 2)
end

function QUIDialogSilvesArenaPeakBattleRecord:_update()
	if q.isEmpty(remote.silvesArena.peakTeamInfo) then return end

	if self._selectTab == QUIDialogSilvesArenaPeakBattleRecord.TAB_REPORTS_FOR_TOP_16 then
		self._minRound = 1 -- 最小轮次
		self._thirdWidget:setVisible(false)
		self._cellWidget:setNormal()
		self._ccbOwner.node_group_btn:setVisible(true)
		self._ccbOwner.sp_group_first:setVisible(true)
		self._ccbOwner.sp_all_first:setVisible(false)
	elseif self._selectTab == QUIDialogSilvesArenaPeakBattleRecord.TAB_REPORTS_FOR_TOP_4 then
		self._minRound = 3 -- 最小轮次
		self._thirdWidget:setVisible(true)
		self._cellWidget:setSmall()
		self._ccbOwner.node_group_btn:setVisible(false)
		self._ccbOwner.sp_group_first:setVisible(false)
		self._ccbOwner.sp_all_first:setVisible(true)
	end

	self._curIndex = 1
	self._myGroupIndex = 0
	self._groupData = {}
	self._thirdData = {}
	table.sort(remote.silvesArena.peakTeamInfo, function(a, b)
		return a.position < b.position
	end)
	local groupIndex = 1
	for i = 1, #remote.silvesArena.peakTeamInfo, 1 do
		if remote.silvesArena.peakTeamInfo[i].currRound >= self._minRound then
			if remote.silvesArena.peakTeamInfo[i].currRound == self._minRound then
				table.insert(self._thirdData, remote.silvesArena.peakTeamInfo[i])
			end
			if not self._groupData[groupIndex] then
				self._groupData[groupIndex] = {}
			end
			table.insert(self._groupData[groupIndex], remote.silvesArena.peakTeamInfo[i])
			if remote.silvesArena.peakTeamInfo[i].teamId == remote.silvesArena.myTeamInfo.teamId then
				self._myGroupIndex = groupIndex
			end

			if #self._groupData[groupIndex] >= self._groupSize then
				groupIndex = groupIndex + 1
			end
		end
	end

	if q.isEmpty(self._groupData) then
		self._ccbOwner.node_no:setVisible(true)
		self._ccbOwner.node_group_cell:setVisible(false)
		self._ccbOwner.node_group_btn:setVisible(false)
		self._ccbOwner.node_result_bg:setVisible(false)
		return 
	else
		self._ccbOwner.node_no:setVisible(false)
		self._ccbOwner.node_group_cell:setVisible(true)
		self._ccbOwner.node_result_bg:setVisible(true)
	end

	if self._cellWidget then 
		self._cellWidget:update(self._groupData[self._curIndex], self._minRound)
	end

	if self._thirdWidget and #self._thirdData == 2 then
		self._thirdWidget:update(self._thirdData)
	end
end

function QUIDialogSilvesArenaPeakBattleRecord:_onBtnClick(event)
	if not event or not event.index then return end
	print("[QUIDialogSilvesArenaPeakBattleRecord:_onBtnClick()] ", event.index, self._curIndex)
	if event.index == self._curIndex then return end

	self._curIndex = event.index

	for _, btn in pairs(self._btnCells) do
		btn:update(self._curIndex)
	end

	if self._cellWidget then 
		self._cellWidget:update(self._groupData[self._curIndex], self._minRound)
	end
end

function QUIDialogSilvesArenaPeakBattleRecord:_onCellEvent(event)
	if not event then return end

	print("event.name = ", event.name)
	if event.name == QUIWidgetSilvesArenaPeakGroupClientCell.EVENT_RIGHT then
		local curIndex = self._curIndex + 1
		if curIndex > #self._btnCells then curIndex = #self._btnCells end
		self:_onBtnClick({index = curIndex})
	elseif event.name == QUIWidgetSilvesArenaPeakGroupClientCell.EVENT_LEFT then
		local curIndex = self._curIndex - 1
		if curIndex < 1 then curIndex = 1 end
		self:_onBtnClick({index = curIndex})
	elseif event.name == QUIWidgetSilvesArenaPeakGroupClientCell.EVENT_REPLAY then
		local teamIdList = event.teamIdList
		if not teamIdList or #teamIdList < 2 then return end
		remote.silvesArena:silvesPeakGetBattleInfoRequest(teamIdList[1], teamIdList[2], function ( data )
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
end

function QUIDialogSilvesArenaPeakBattleRecord:_onThirdEvent(event)
	if not event then return end

	print("event.name = ", event.name)
	if event.name == QUIWidgetSilvesArenaPeakThirdClientCell.EVENT_REPLAY then
		local teamIdList = event.teamIdList
		if not teamIdList or #teamIdList < 2 then return end
		remote.silvesArena:silvesPeakGetBattleInfoRequest(teamIdList[1], teamIdList[2], function ( data )
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
end

function QUIDialogSilvesArenaPeakBattleRecord:_selectTabs(isSkip)
	self:getOptions().selectTab = self._selectTab

	if self._selectTab == QUIDialogSilvesArenaPeakBattleRecord.TAB_REPORTS_FOR_TOP_16 then
		self._ccbOwner.btn_report_for_top_4:setEnabled(true)
		self._ccbOwner.btn_report_for_top_4:setHighlighted(false)
		self._ccbOwner.btn_report_for_top_16:setEnabled(false)
		self._ccbOwner.btn_report_for_top_16:setHighlighted(true)
	elseif self._selectTab == QUIDialogSilvesArenaPeakBattleRecord.TAB_REPORTS_FOR_TOP_4 then
		self._ccbOwner.btn_report_for_top_4:setEnabled(false)
		self._ccbOwner.btn_report_for_top_4:setHighlighted(true)
		self._ccbOwner.btn_report_for_top_16:setEnabled(true)
		self._ccbOwner.btn_report_for_top_16:setHighlighted(false)
	end

	if not isSkip then
		self:_update()

		if not q.isEmpty(self._btnCells) then
			for _, btn in pairs(self._btnCells) do
				btn:update(self._curIndex)
			end
		end
	end
end

function QUIDialogSilvesArenaPeakBattleRecord:_onTriggerReportForTop16(e)
	if self._selectTab == QUIDialogSilvesArenaPeakBattleRecord.TAB_REPORTS_FOR_TOP_16 then return end
    app.sound:playSound("common_switch")

	self._selectTab = QUIDialogSilvesArenaPeakBattleRecord.TAB_REPORTS_FOR_TOP_16
	self:_selectTabs()
end

function QUIDialogSilvesArenaPeakBattleRecord:_onTriggerReportForTop4(e)
	if self._selectTab == QUIDialogSilvesArenaPeakBattleRecord.TAB_REPORTS_FOR_TOP_4 then return end
    app.sound:playSound("common_switch")

	self._selectTab = QUIDialogSilvesArenaPeakBattleRecord.TAB_REPORTS_FOR_TOP_4
	self:_selectTabs()
end

function QUIDialogSilvesArenaPeakBattleRecord:_onTriggerClose(event)
    if q.buttonEventShadow(event, self._ccbOwner.frame_btn_close) == false then return end		
    app.sound:playSound("common_cancel")
    self:playEffectOut()
end

return QUIDialogSilvesArenaPeakBattleRecord