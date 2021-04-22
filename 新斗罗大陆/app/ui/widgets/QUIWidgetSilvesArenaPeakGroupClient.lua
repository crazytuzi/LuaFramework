--
-- Kumo.Wang
-- 西尔维斯大斗魂场巅峰赛小组赛界面
--

local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetSilvesArenaPeakGroupClient = class("QUIWidgetSilvesArenaPeakGroupClient", QUIWidget)

local QUIViewController = import("..QUIViewController")
local QUIWidgetSilvesArenaPeakGroupClientCell = import(".QUIWidgetSilvesArenaPeakGroupClientCell")
local QUIWidgetSilvesArenaPeakGroupBtn = import(".QUIWidgetSilvesArenaPeakGroupBtn")

QUIWidgetSilvesArenaPeakGroupClient.EVENT_CLIENT = "QUIWidgetSilvesArenaPeakGroupClient.EVENT_CLIENT"

function QUIWidgetSilvesArenaPeakGroupClient:ctor(options)
	local ccbFile = "ccb/Widget_SilvesArena_Peak_Group.ccbi"
  	local callBacks = {}
	QUIWidgetSilvesArenaPeakGroupClient.super.ctor(self,ccbFile,callBacks,options)
	cc.GameObject.extend(self)
  	self:addComponent("components.behavior.EventProtocol"):exportMethods()

	self:_init()
end

function QUIWidgetSilvesArenaPeakGroupClient:onEnter()
	QUIWidgetSilvesArenaPeakGroupClient.super.onEnter(self)
	
	self._silvesArenaProxy = cc.EventProxy.new(remote.silvesArena)
    self._silvesArenaProxy:addEventListener(remote.silvesArena.STATE_UPDATE, handler(self, self.update))

	self:update()
end

function QUIWidgetSilvesArenaPeakGroupClient:onExit()
	QUIWidgetSilvesArenaPeakGroupClient.super.onExit(self)

	if self._silvesArenaProxy then
		self._silvesArenaProxy:removeAllEventListeners()
	end
end

function QUIWidgetSilvesArenaPeakGroupClient:getClassName()
	return "QUIWidgetSilvesArenaPeakGroupClient"
end

function QUIWidgetSilvesArenaPeakGroupClient:update()
	if not self._ccbView then return end
	if q.isEmpty(remote.silvesArena.peakTeamInfo) then return end

	local peakState = remote.silvesArena:getCurPeakState()
	local curRefreshIndex = 0
	if peakState == remote.silvesArena.PEAK_READY_TO_16
		or peakState == remote.silvesArena.PEAK_WAIT_TO_16
		or peakState == remote.silvesArena.PEAK_16_IN_8 then

		curRefreshIndex = 1
	elseif peakState == remote.silvesArena.PEAK_8_IN_4 then
		curRefreshIndex = 2
	end

	if self._curRefreshIndex ~= nil and self._curRefreshIndex == curRefreshIndex then return end
	self._curRefreshIndex = curRefreshIndex

	self._curIndex = 1
	self._myGroupIndex = 0
	self._groupData = {}
	table.sort(remote.silvesArena.peakTeamInfo, function(a, b)
		return a.position < b.position
	end)
	local groupIndex = 1
	for i = 1, #remote.silvesArena.peakTeamInfo, 1 do
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

	if self._cellWidget then 
		self._cellWidget:update(self._groupData[self._curIndex])
	end
end

function QUIWidgetSilvesArenaPeakGroupClient:_reset()
	self._ccbOwner.node_group_cell:removeAllChildren()
	self._ccbOwner.node_group_btn:removeAllChildren()
end

function QUIWidgetSilvesArenaPeakGroupClient:_init()
	self:_reset()

	self._groupSize = 4 -- 一组4人（取决于ccb）

	if q.isEmpty(remote.silvesArena.peakTeamInfo) then return end

	self._cellWidget = QUIWidgetSilvesArenaPeakGroupClientCell.new()
	self._cellWidget:addEventListener(QUIWidgetSilvesArenaPeakGroupClientCell.EVENT_RIGHT, handler(self, self._onCellEvent))
	self._cellWidget:addEventListener(QUIWidgetSilvesArenaPeakGroupClientCell.EVENT_LEFT, handler(self, self._onCellEvent))
	self._cellWidget:addEventListener(QUIWidgetSilvesArenaPeakGroupClientCell.EVENT_REPLAY, handler(self, self._onCellEvent))
	self._cellWidget:setSmall()
	self._ccbOwner.node_group_cell:addChild(self._cellWidget)

	self:update()

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

function QUIWidgetSilvesArenaPeakGroupClient:_onBtnClick(event)
	if not event or not event.index then return end
	print("[QUIWidgetSilvesArenaPeakGroupClient:_onBtnClick()] ", event.index, self._curIndex)
	if event.index == self._curIndex then return end

	self._curIndex = event.index

	for _, btn in pairs(self._btnCells) do
		btn:update(self._curIndex)
	end

	if self._cellWidget then 
		self._cellWidget:update(self._groupData[self._curIndex])
	end
end

function QUIWidgetSilvesArenaPeakGroupClient:_onCellEvent(event)
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
	        battleReport.reportType = reportType
	        battleReport.matchingId = matchingId
	        battleReport.reportIdList = reportIdList
	        battleReport.fightAt = lastfightAt
	        
	        app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogSilvesArenaRecordDetail",
	            options = {info = battleReport, isFight = isFight, showShare = false}}, {isPopCurrentDialog = false})
	    end)
	end
end

return QUIWidgetSilvesArenaPeakGroupClient