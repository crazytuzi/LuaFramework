--
-- zxs
-- 精英赛我的战斗记录
--

local QUIDialog = import(".QUIDialog")
local QUIDialogSanctuaryMyRecord = class("QUIDialogSanctuaryMyRecord", QUIDialog)
local QUIWidgetSanctuaryMyRecord = import("..widgets.sanctuary.QUIWidgetSanctuaryMyRecord")
local QListView = import("...views.QListView")
local QReplayUtil = import("...utils.QReplayUtil")
local QUIViewController = import("..QUIViewController")

QUIDialogSanctuaryMyRecord.TAB_ELIMINATE = "TAB_ELIMINATE"
QUIDialogSanctuaryMyRecord.TAB_AUDITION = "TAB_AUDITION"

--初始化
function QUIDialogSanctuaryMyRecord:ctor(options)
	local ccbFile = "ccb/Dialog_Sanctuary_battlerecord.ccbi"
	local callBacks = {
        {ccbCallbackName = "onTriggerEliminate", callback = handler(self, self._onTriggerEliminate)},
        {ccbCallbackName = "onTriggerAudition", callback = handler(self, self._onTriggerAudition)},
        {ccbCallbackName = "onTriggerClose", callback = handler(self, self._onTriggerClose)},
	}
	QUIDialogSanctuaryMyRecord.super.ctor(self,ccbFile,callBacks,options)
	self.isAnimation = true

	self._allReports = options.reports or {}
	self._selectTab = options.selectTab or QUIDialogSanctuaryMyRecord.TAB_ELIMINATE
	self:selectTabs()
end

-- 重置所有
function QUIDialogSanctuaryMyRecord:resetAll()
	self._ccbOwner.btn_eliminate:setEnabled(true)
	self._ccbOwner.btn_eliminate:setHighlighted(false)
	self._ccbOwner.btn_audition:setEnabled(true)
	self._ccbOwner.btn_audition:setHighlighted(false)
	self._ccbOwner.sp_eliminate_tips:setVisible(false)
	self._ccbOwner.sp_audition_tips:setVisible(false)
end

function QUIDialogSanctuaryMyRecord:selectTabs()
	self:getOptions().selectTab = self._selectTab
	self:resetAll()
	
	self._data = {}
	if self._selectTab == QUIDialogSanctuaryMyRecord.TAB_ELIMINATE then
		self._ccbOwner.btn_eliminate:setEnabled(false)
		self._ccbOwner.btn_eliminate:setHighlighted(true)
		for i, report in ipairs(self._allReports) do
			if report.currRound >= remote.sanctuary.ROUND_64 then
				report.type = 1
				table.insert(self._data, report)
			end
		end
	elseif self._selectTab == QUIDialogSanctuaryMyRecord.TAB_AUDITION then
		self._ccbOwner.btn_audition:setEnabled(false)
		self._ccbOwner.btn_audition:setHighlighted(true)
		for i, report in ipairs(self._allReports) do
			if report.currRound < remote.sanctuary.ROUND_64 then
				report.type = 2
				table.insert(self._data, report)
			end
		end
	end
	local totalNumber = #self._data
	for i, v in pairs(self._data) do
		v.index = totalNumber - i + 1
	end
	self:initListView()
	self._ccbOwner.node_no:setVisible(not next(self._data))
end

function QUIDialogSanctuaryMyRecord:initListView()
	-- body
	if not self._listView then
		local cfg = {
			renderItemCallBack = function( list, index, info )
	            -- body
	            local isCacheNode = true
	            local itemData = self._data[index]
	            local item = list:getItemFromCache(itemData.oType)
	            if not item then
	            	item = QUIWidgetSanctuaryMyRecord.new()
            		item:addEventListener(QUIWidgetSanctuaryMyRecord.EVENT_CLICK_RECORDE, handler(self, self.itemClickHandler))
            		item:addEventListener(QUIWidgetSanctuaryMyRecord.EVENT_CLICK_SHARED, handler(self, self.itemClickHandler))
            		item:addEventListener(QUIWidgetSanctuaryMyRecord.EVENT_CLICK_REPLAY, handler(self, self.itemClickHandler))
	            	isCacheNode = false
	            end
	            item:setInfo(itemData)
	            item:initGLLayer()
	            info.item = item
	            info.size = item:getContentSize()

	            list:registerBtnHandler(index, "btn_record", "_onTriggerRecord", nil, true)
                list:registerBtnHandler(index, "btn_share", "_onTriggerShare", nil, true)
                list:registerBtnHandler(index, "btn_replay", "_onTriggerReplay", nil, true)

	            return isCacheNode
	        end,
	        curOriginOffset = 0,
	        enableShadow = true,
	      	ignoreCanDrag = true,
	        totalNumber = #self._data,
		}
		self._listView = QListView.new(self._ccbOwner.sheet_layout, cfg)
	else
		self._listView:reload({totalNumber = #self._data})
	end
end

function QUIDialogSanctuaryMyRecord:itemClickHandler(event)
	if not event.name then
		return
	end

	local info = event.info
	if event.name == QUIWidgetSanctuaryMyRecord.EVENT_CLICK_SHARED then
		local rivalName = event.rivalName
		QReplayUtil:getReplayInfo(info.reportId, function (data)
			app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogReplayShare", 
				options = {rivalName = rivalName, myNickName = remote.user.nickname, replayId = info.reportId, replayType = REPORT_TYPE.SANCTUARY_WAR}}, {isPopCurrentDialog = false})
		end, nil, REPORT_TYPE.SANCTUARY_WAR)

	elseif event.name == QUIWidgetSanctuaryMyRecord.EVENT_CLICK_REPLAY then
		QReplayUtil:getReplayInfo(info.reportId, function (data)
			QReplayUtil:downloadReplay(info.reportId, function (replay)
				QReplayUtil:play(replay,data.scoreList, data.fightReportStats, true)
			end, nil, REPORT_TYPE.SANCTUARY_WAR)
		end, nil, REPORT_TYPE.SANCTUARY_WAR)

	elseif event.name == QUIWidgetSanctuaryMyRecord.EVENT_CLICK_RECORDE then
		remote.sanctuary:sanctuaryWarQueryFighterRequest(event.userId, function(data)
			local fighter = data.sanctuaryWarQueryFighterResponse.fighter or {}
			QReplayUtil:getReplayInfo(info.reportId, function (data)
				local scoreList = {}
				local scoreTable = string.split(info.scoreInfo, ";")
		        for i, v in pairs(scoreTable) do
		            if tonumber(v) == 1 then
		                scoreList[#scoreList+1] = true
		            else
		                scoreList[#scoreList+1] = false
		            end
		        end
				local detailInfo = {}
				detailInfo.isInitiative = info.fighter1.userId == remote.user.userId
				detailInfo.scoreList = scoreList
				detailInfo.fighter = fighter
				detailInfo.replayInfo = data
				app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogAgainstRecordDetail",
		    		options = {info = detailInfo}}, {isPopCurrentDialog = false})
			end, nil, REPORT_TYPE.SANCTUARY_WAR)
		end)	
	end
end

function QUIDialogSanctuaryMyRecord:_onTriggerEliminate(e)
	if self._selectTab == QUIDialogSanctuaryMyRecord.TAB_ELIMINATE then return end
    app.sound:playSound("common_switch")

	self._selectTab = QUIDialogSanctuaryMyRecord.TAB_ELIMINATE
	self:selectTabs()
end

function QUIDialogSanctuaryMyRecord:_onTriggerAudition(e)
	if self._selectTab == QUIDialogSanctuaryMyRecord.TAB_AUDITION then return end
    app.sound:playSound("common_switch")

	self._selectTab = QUIDialogSanctuaryMyRecord.TAB_AUDITION
	self:selectTabs()
end

function QUIDialogSanctuaryMyRecord:_onTriggerClose(event)
	if q.buttonEventShadow(event, self._ccbOwner.frame_btn_close) == false then return end
    app.sound:playSound("common_cancel")
    self:playEffectOut()
end

function QUIDialogSanctuaryMyRecord:_backClickHandler()
	self:playEffectOut()
end

return QUIDialogSanctuaryMyRecord
