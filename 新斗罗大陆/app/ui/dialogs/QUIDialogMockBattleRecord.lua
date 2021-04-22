local QUIDialog = import(".QUIDialog")
local QUIDialogMockBattleRecord = class("QUIDialogMockBattleRecord", QUIDialog)
local QUIWidgetAgainstRecord = import("..widgets.QUIWidgetAgainstRecord")
local QUIWidgetMockBattleRecordTurnCell = import("..widgets.QUIWidgetMockBattleRecordTurnCell")
local QListView = import("...views.QListView")
local QReplayUtil = import("...utils.QReplayUtil")
local QUIViewController = import("..QUIViewController")

QUIDialogMockBattleRecord.TAB_NORMAL = "TAB_NORMAL"
QUIDialogMockBattleRecord.TAB_TURN = "TAB_TURN"

function QUIDialogMockBattleRecord:ctor(options)
	local ccbFile = "ccb/Dialog_MockBattle_Record.ccbi"
	local callBacks = {
		{ccbCallbackName = "onTriggerClose", callback = handler(self, self._onTriggerClose)},
		{ccbCallbackName = "onTriggerNormal", callback = handler(self, self._onTriggerNormal)},
		{ccbCallbackName = "onTriggerTurn", callback = handler(self, self._onTriggerTurn)},
	}
	QUIDialogMockBattleRecord.super.ctor(self,ccbFile,callBacks,options)
	self.isAnimation = true

	self._selectTab = options.selectTab or QUIDialogMockBattleRecord.TAB_NORMAL
	self._reportType = options.reportType
	self._normalData = {}
	self._turnData = {}
	self._data = {}
	self._ccbOwner.frame_tf_title:setString("战 报")
	self._ccbOwner.node_no:setVisible(false)

	self:initListView()
	self:selectTabs()
end 


function QUIDialogMockBattleRecord:viewDidAppear()
    QUIDialogMockBattleRecord.super.viewDidAppear(self)
	-- self:initListView()
	-- self:selectTabs()
    self:addBackEvent(false)
end

function QUIDialogMockBattleRecord:viewAnimationInHandler()
	--代码
	
	self:initListView()
	self:selectTabs()
end

function QUIDialogMockBattleRecord:viewWillDisappear()
    QUIDialogMockBattleRecord.super.viewWillDisappear(self)
    self:removeBackEvent()
end


-- 重置按钮
function QUIDialogMockBattleRecord:resetAll()
	self._ccbOwner.btn_normal:setEnabled(true)
	self._ccbOwner.btn_normal:setHighlighted(false)
	self._ccbOwner.btn_turn:setEnabled(true)
	self._ccbOwner.btn_turn:setHighlighted(false)
	self._ccbOwner.sp_normal_tips:setVisible(false)
	self._ccbOwner.sp_turn_tips:setVisible(false)
end

function QUIDialogMockBattleRecord:selectTabs()
	self:getOptions().selectTab = self._selectTab
	self:resetAll()
	self._data = {}

	local callback = function()
		if not self:safeCheck() then
			return
		end

		if self._selectTab == QUIDialogMockBattleRecord.TAB_NORMAL then
			self._data = self._normalData
			table.sort(self._data, function (x, y)
				if x.time and y.time then
					return x.time > y.time
				else
					return x.createdAt > y.createdAt
				end
			end)
		else
			self._data = self._turnData
			table.sort(self._data, function (x, y)
				if x.roundId and y.roundId then
					return x.roundId > y.roundId
				else
					return false
				end
			end)
		end


		if self._listView then
			self._listView:clear()
		end
		self:initListView()
	end

	if self._selectTab == QUIDialogMockBattleRecord.TAB_NORMAL then
		self._ccbOwner.node_turn:setVisible(false)
		self._ccbOwner.btn_normal:setEnabled(false)
		self._ccbOwner.btn_normal:setHighlighted(true)
		self:initNormalAgainstType(callback)
	elseif self._selectTab == QUIDialogMockBattleRecord.TAB_TURN then
		self._ccbOwner.node_turn:setVisible(true)
		self._ccbOwner.btn_turn:setEnabled(false)
		self._ccbOwner.btn_turn:setHighlighted(true)
		self:initTurnAgainstType(callback)
	end
end

function QUIDialogMockBattleRecord:initNormalAgainstType(callback)
	-- 已经拉取过数据了
	if next(self._normalData) then
		callback()
		return
	end

	remote.mockbattle:mockBattleGetFightHistoryRequest(function(data)
		local fightReprts = data.mockBattleUserInfoResponse.reports or {}
		for _, v in pairs(fightReprts) do
			local me = v.fighter1
			local rival = v.fighter2
			local result = v.scoreList[1]
			if me.userId ~= remote.user.userId then
				me, rival = rival, me
				result = not result
			end
			local info = {}
			info.type = REPORT_TYPE.MOCK_BATTLE
			info.userId = rival.userId
			info.nickname = rival.name
			info.level = rival.level
			info.result = result
			info.isInitiative = v.fighter1.userId == remote.user.userId
			info.avatar = rival.avatar
			info.time = v.fightAt
			info.reportId = v.reportId
			info.vip = rival.vip
			info.enemy_data = clone(rival)
			table.insert(self._normalData, info)
		end
		--QPrintTable(self._normalData)
		callback()
	end)
end

function QUIDialogMockBattleRecord:initTurnAgainstType(callback)
	-- 已经拉取过数据了
	if next(self._turnData) then
		callback()
		return
	end

	remote.mockbattle:mockBattleGetBattleInfoListRequest(function()
		local totleRoundInfos = remote.mockbattle:getMockBattleTotleRoundInfos()
		local cur_round = 0
		local cur_roundinfo = remote.mockbattle:getMockBattleRoundInfo()
		if next(cur_roundinfo) and cur_roundinfo.isEnd == false then
			cur_round = cur_roundinfo.roundId
		end

		if next(totleRoundInfos) then
			for i,v in ipairs(totleRoundInfos) do
				if cur_round ~= v.roundId then
					local turn_data = {roundId = v.roundId  or 1, winCount = v.winCount  or 0 , loseCount = v.loseCount or 0, reward = v.reward or {}}
					table.insert(self._turnData, turn_data)
				end
			end
		end
		callback()

	end)

end

function QUIDialogMockBattleRecord:initListView()
	self._ccbOwner.node_no:setVisible(not next(self._data))

	if self._selectTab == QUIDialogMockBattleRecord.TAB_NORMAL then
		self._ccbOwner.sheet_layout:setPositionY(-427)
		self._ccbOwner.sheet_layout:setContentSize(CCSize(678,432))

	else
		self._ccbOwner.sheet_layout:setPositionY(-427)
		self._ccbOwner.sheet_layout:setContentSize(CCSize(678,400))
			
	end
	if self._listView then
		self._listView:setContentSize(self._ccbOwner.sheet_layout:getContentSize())
		self._listView:resetTouchRect()
	end

	if not self._listView then
		local cfg = {
			renderItemCallBack = handler(self, self._renderItemFunc),
	        curOriginOffset = 0,
	        isVertical = true,
	        enableShadow = true,
	      	ignoreCanDrag = true,
	      	spaceY = -8,
	        totalNumber = #self._data,
		}
		self._listView = QListView.new(self._ccbOwner.sheet_layout,cfg)
	else
		self._listView:reload({totalNumber = #self._data})
	end

end

function QUIDialogMockBattleRecord:_renderItemFunc( list, index, info )
    -- body
    local isCacheNode = true
    local itemData = self._data[index]
    local item = list:getItemFromCache(self._selectTab)
    if not item then
    	if self._selectTab == QUIDialogMockBattleRecord.TAB_NORMAL then
	    	item = QUIWidgetAgainstRecord.new()
			item:addEventListener(QUIWidgetAgainstRecord.EVENT_CLICK_HEAD, handler(self, self.itemClickHandler))
			item:addEventListener(QUIWidgetAgainstRecord.EVENT_CLICK_RECORDE, handler(self, self.itemClickHandler))
			item:addEventListener(QUIWidgetAgainstRecord.EVENT_CLICK_SHARED, handler(self, self.itemClickHandler))
			item:addEventListener(QUIWidgetAgainstRecord.EVENT_CLICK_REPLAY, handler(self, self.itemClickHandler))
		else
			item = QUIWidgetMockBattleRecordTurnCell.new()
			print("self._selectTab ~= QUIDialogMockBattleRecord.TAB_NORMAL")
		end
    	isCacheNode = false
    end
    item:setInfo(itemData, self._reportType)
    item:initGLLayer()
    info.tag = self._selectTab
    info.item = item
    info.size = item:getContentSize()

    if self._selectTab == QUIDialogMockBattleRecord.TAB_NORMAL then 
	    list:registerBtnHandler(index, "btn_head", "_onTriggerHead", nil, true)
	    list:registerBtnHandler(index, "btn_detail", "_onTriggerDetail", nil, true)
	    list:registerBtnHandler(index, "btn_share", "_onTriggerShare", nil, true)
	    list:registerBtnHandler(index, "btn_replay", "_onTriggerReplay", nil, true)
		print("self._selectTab == QUIDialogMockBattleRecord.TAB_NORMAL")
	end

    return isCacheNode
end

function QUIDialogMockBattleRecord:itemClickHandler(event)
	print("QUIDialogMockBattleRecord:itemClickHandler")
	if not event.name then
		return
	end

	local info = event.info
	local userId = info.userId
	local reportType = info.type
	local reportId = info.reportId


	if event.name == QUIWidgetAgainstRecord.EVENT_CLICK_HEAD then
		self:_onClickIcon(info.enemy_data)
	elseif event.name == QUIWidgetAgainstRecord.EVENT_CLICK_SHARED then
		local rivalName = info.nickname
		QReplayUtil:getReplayInfo(reportId, function (data)
			app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogReplayShare", 
				options = {rivalName = rivalName, myNickName = remote.user.nickname, replayId = reportId, replayType = reportType}}, {isPopCurrentDialog = false})
		end, nil, reportType)

	elseif event.name == QUIWidgetAgainstRecord.EVENT_CLICK_REPLAY then
		QReplayUtil:getReplayInfo(reportId, function (data)
			QReplayUtil:downloadReplay(reportId, function (replay)
				QReplayUtil:play(replay, data.scoreList, data.fightReportStats, true)
			end, nil, reportType)
		end, nil, reportType)
	end
end

function QUIDialogMockBattleRecord:_onClickIcon(enemy_data)
	if enemy_data == nil or next(enemy_data) == nil  then return end

   	local enemy_battleInfo = enemy_data.battleInfo or {}
	local fighter = enemy_data or {}

	local main_4hero = enemy_battleInfo.mainHeroIds or {}
	local sub_4hero = enemy_battleInfo.sub1HeroIds or {}
	local wear_4hero = enemy_battleInfo.wearInfo or {}
	local soulSpiritId = enemy_battleInfo.soulSpiritId or 0
	

    local heros_ = {}
    local subheros_ = {}
    local sub2heros_ = {}
    local sub3heros_ = {}
    local mounts_ = {}
    local godArm1List = {}


	local enemy_battleInfo = enemy_data.battleInfo or {}
	local enemy_info = enemy_data.fighter or {}
	local main_4hero = enemy_battleInfo.mainHeroIds or {}
	local sub_4hero = enemy_battleInfo.sub1HeroIds or {}
	local wear_4hero = enemy_battleInfo.wearInfo or {}
	local soulSpiritId = enemy_battleInfo.soulSpiritId or 0
	local godArmIdList = enemy_battleInfo.godArmIdList or {}

	for i, id in pairs(main_4hero) do
		local data_ = remote.mockbattle:getCardInfoByIndex(id)
		table.insert(heros_,data_)
	end
	for i, id in pairs(sub_4hero) do
		local data_ = remote.mockbattle:getCardInfoByIndex(id)
		table.insert(subheros_,data_)
	end
	if soulSpiritId ~= 0 then
			local data_ = remote.mockbattle:getCardInfoByIndex(soulSpiritId)
		table.insert(heros_,data_)
	end
	for i, value in pairs(wear_4hero) do
		local data_ = remote.mockbattle:getCardInfoByIndex(value.zuoqiId)
		table.insert(mounts_,data_)
	end
	for i, id in pairs(godArmIdList) do
		local data_ = remote.mockbattle:getCardInfoByIndex(id)
		table.insert(godArm1List,data_)
	end

	if not q.isEmpty(enemy_data.battleInfo2) then 
		local enemy_battleInfo = enemy_data.battleInfo2 or {}
		local enemy_info = enemy_data.fighter or {}
		local main_4hero = enemy_battleInfo.mainHeroIds or {}
		local sub_4hero = enemy_battleInfo.sub1HeroIds or {}
		local wear_4hero = enemy_battleInfo.wearInfo or {}
		local soulSpiritId = enemy_battleInfo.soulSpiritId or 0
		local godArmIdList = enemy_battleInfo.godArmIdList or {}

		for i, id in pairs(main_4hero) do
			local data_ = remote.mockbattle:getCardInfoByIndex(id)
			table.insert(heros_,data_)
		end
		for i, id in pairs(sub_4hero) do
			local data_ = remote.mockbattle:getCardInfoByIndex(id)
			table.insert(subheros_,data_)
		end
		if soulSpiritId ~= 0 then
				local data_ = remote.mockbattle:getCardInfoByIndex(soulSpiritId)
			table.insert(heros_,data_)
		end
		for i, value in pairs(wear_4hero) do
			local data_ = remote.mockbattle:getCardInfoByIndex(value.zuoqiId)
			table.insert(mounts_,data_)
		end
		for i, id in pairs(godArmIdList) do
			local data_ = remote.mockbattle:getCardInfoByIndex(id)
			table.insert(godArm1List,data_)
		end
	end


    local options_ = {fighter = fighter, isPVP = true ,heros = heros_ ,subheros = subheros_ 
    ,sub2heros = sub2heros_ ,sub3heros = sub3heros_ ,mounts = mounts_ ,godArm1List = godArm1List ,model = GAME_MODEL.MOCKBATTLE ,forceTitle="胜场 :" , isPVP = false , force = fighter.winCount or 0 }

	app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogPlayerInfo",
   		options = options_ }, {isPopCurrentDialog = false})
end


function QUIDialogMockBattleRecord:_onTriggerNormal(event)
	if self._selectTab == QUIDialogMockBattleRecord.TAB_NORMAL then return end
    app.sound:playSound("common_switch")
	self._selectTab = QUIDialogMockBattleRecord.TAB_NORMAL
	self:selectTabs()
end

function QUIDialogMockBattleRecord:_onTriggerTurn(event)
	if self._selectTab == QUIDialogMockBattleRecord.TAB_TURN then return end
    app.sound:playSound("common_switch")
	self._selectTab = QUIDialogMockBattleRecord.TAB_TURN
	self:selectTabs()
end

function QUIDialogMockBattleRecord:_backClickHandler()
    self:playEffectOut()
end

function QUIDialogMockBattleRecord:_onTriggerClose(event)
	if q.buttonEventShadow(event, self._ccbOwner.frame_btn_close) == false then return end
	app.sound:playSound("common_cancel")
    self:playEffectOut()
end

return QUIDialogMockBattleRecord