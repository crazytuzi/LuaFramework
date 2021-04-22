-- 
-- Kumo.Wang
-- 西尔维斯战报查看界面
--

local QUIDialog = import(".QUIDialog")
local QUIDialogSilvesArenaBattleRecord = class("QUIDialogSilvesArenaBattleRecord", QUIDialog)

local QListView = import("...views.QListView")
local QReplayUtil = import("...utils.QReplayUtil")
local QUIViewController = import("..QUIViewController")

local QUIWidgetSilvesArenaBattleRecord = import("..widgets.QUIWidgetSilvesArenaBattleRecord")

QUIDialogSilvesArenaBattleRecord.TAB_ATTACK = "TAB_ATTACK"
QUIDialogSilvesArenaBattleRecord.TAB_DEFENSE = "TAB_DEFENSE"

function QUIDialogSilvesArenaBattleRecord:ctor(options)
	local ccbFile = "ccb/Dialog_SilvesArena_Battle_Record.ccbi"

	local callBacks = {
		{ccbCallbackName = "onTriggerClose", callback = handler(self, self._onTriggerClose)},
		{ccbCallbackName = "onTriggerAttack", callback = handler(self, self._onTriggerAttack)},
		{ccbCallbackName = "onTriggerDefense", callback = handler(self, self._onTriggerDefense)},
	}
	QUIDialogSilvesArenaBattleRecord.super.ctor(self,ccbFile,callBacks,options)

	self.isAnimation = true

	self._ccbOwner.frame_tf_title:setString("战 报")

	self._selectTab = options.selectTab or QUIDialogSilvesArenaBattleRecord.TAB_ATTACK
	self._reportType = options.reportType
	self._attackData = {}
	self._defenseData = {}
	self._data = {}

	self:resetAll()
end 

function QUIDialogSilvesArenaBattleRecord:viewAnimationInHandler()
    QUIDialogSilvesArenaBattleRecord.super.viewAnimationInHandler(self)
    
    self:_selectTabs()
end

-- 重置按钮
function QUIDialogSilvesArenaBattleRecord:resetAll()
	self._ccbOwner.btn_attack:setEnabled(true)
	self._ccbOwner.btn_attack:setHighlighted(false)
	self._ccbOwner.btn_defense:setEnabled(true)
	self._ccbOwner.btn_defense:setHighlighted(false)
	self._ccbOwner.sp_attack_tips:setVisible(false)
	self._ccbOwner.sp_defense_tips:setVisible(false)
end

function QUIDialogSilvesArenaBattleRecord:_selectTabs()
	self:getOptions().selectTab = self._selectTab
	self._data = {}

	local callback = function()
		if self:safeCheck() then
			if self._selectTab == QUIDialogSilvesArenaBattleRecord.TAB_ATTACK then
				self._data = self._attackData
			else
				self._data = self._defenseData
			end

			table.sort(self._data, function (x, y)
				if x.fightAt and y.fightAt then
					return x.fightAt > y.fightAt
				else
					return x.createdAt > y.createdAt
				end
			end)

			if self._listViewLayout then
				self._listViewLayout:clear(true)
				self._listViewLayout = nil
			end

			self:_initListView()
		end
	end

	if self._selectTab == QUIDialogSilvesArenaBattleRecord.TAB_ATTACK then
		self._ccbOwner.btn_attack:setEnabled(false)
		self._ccbOwner.btn_attack:setHighlighted(true)
		self._ccbOwner.btn_defense:setEnabled(true)
		self._ccbOwner.btn_defense:setHighlighted(false)
		self:_updateListData(1, callback)
	elseif self._selectTab == QUIDialogSilvesArenaBattleRecord.TAB_DEFENSE then
		self._ccbOwner.btn_attack:setEnabled(true)
		self._ccbOwner.btn_attack:setHighlighted(false)
		self._ccbOwner.btn_defense:setEnabled(false)
		self._ccbOwner.btn_defense:setHighlighted(true)
		self:_updateListData(0, callback)
	end
end

-- @historyType:  0:防守记录; 1:进攻记录
function QUIDialogSilvesArenaBattleRecord:_updateListData(historyType, callback)
	-- 已经拉取过数据了
	if historyType == 1 then
		if next(self._attackData) then
			callback()
			return
		end
	else
		if next(self._defenseData) then
			callback()
			return
		end
	end

	remote.silvesArena:silvesArenaTeamHistoryRequest(historyType, function(data)
		if self:safeCheck() then
			local fightReprts = data.silvesArenaInfoResponse.battleHistoryList or {}
			for _, v in pairs(fightReprts) do
				local fighterList = v.team2fighterList
				local isWin = v.success

				local info = {}
				info.type = REPORT_TYPE.SILVES_ARENA
				info.isWin = isWin

				info.playerInfoList = {}
				for i,v in ipairs(fighterList) do
					if v then
						local playerInfo = {}
						playerInfo.userId = v.userId
						playerInfo.level = v.level
						playerInfo.vip = v.vip
						playerInfo.avatar = v.avatar
						table.insert(info.playerInfoList, playerInfo)
					end
				end

				info.matchingId = v.matchingId
				info.nickname = v.team2Name

				info.fightAt = v.fightAt
				info.reportIdList = v.reportIdList
				info.isAttack = historyType == 1
				info.addScore = v.team1AddScore

				if historyType == 1 then
					table.insert(self._attackData, info)
				else
					table.insert(self._defenseData, info)
				end
			end

			callback()
		end
	end)
end

function QUIDialogSilvesArenaBattleRecord:_initListView()
	if next(self._data) then
		self._ccbOwner.node_no:setVisible(false)

		if not self._listViewLayout then
			local cfg = {
				renderItemCallBack = handler(self, self._renderItemFunc),
		        curOriginOffset = 0,
		        isVertical = true,
		        enableShadow = true,
		      	ignoreCanDrag = true,
		      	spaceY = 0,
		        totalNumber = #self._data,
			}
			self._listViewLayout = QListView.new(self._ccbOwner.sheet_layout, cfg)
		else
			self._listViewLayout:reload({totalNumber = #self._data})
		end
	else
		if self._listViewLayout then
			self._listViewLayout:clear(true)
			self._listViewLayout = nil
		end

		self._ccbOwner.node_no:setVisible(true)
	end
end

function QUIDialogSilvesArenaBattleRecord:_renderItemFunc( list, index, info )
    local isCacheNode = true
    local itemData = self._data[index]
    local item = list:getItemFromCache(self._selectTab)
    if not item then
		item = QUIWidgetSilvesArenaBattleRecord.new()
		
		item:addEventListener(QUIWidgetSilvesArenaBattleRecord.EVENT_CLICK_HEAD, handler(self, self.itemClickHandler))
		item:addEventListener(QUIWidgetSilvesArenaBattleRecord.EVENT_CLICK_RECORDE, handler(self, self.itemClickHandler))
		item:addEventListener(QUIWidgetSilvesArenaBattleRecord.EVENT_CLICK_SHARED, handler(self, self.itemClickHandler))
		item:addEventListener(QUIWidgetSilvesArenaBattleRecord.EVENT_CLICK_REPLAY, handler(self, self.itemClickHandler))

    	isCacheNode = false
    end
    item:setInfo(itemData, self._reportType, self._selectTab)
    item:initGLLayer()
    info.item = item
    info.size = item:getContentSize()

	list:registerBtnHandler(index, "btn_head1", "_onTriggerHead1")
	list:registerBtnHandler(index, "btn_head2", "_onTriggerHead2")
	list:registerBtnHandler(index, "btn_head3", "_onTriggerHead3")
	list:registerBtnHandler(index, "btn_detail", "_onTriggerDetail", nil, true)
	list:registerBtnHandler(index, "btn_share", "_onTriggerShare", nil, true)
	list:registerBtnHandler(index, "btn_replay", "_onTriggerReplay", nil, true)

    return isCacheNode
end

function QUIDialogSilvesArenaBattleRecord:itemClickHandler(event)
	if not event.name then
		return
	end

	local info = event.info
	local reportType = info.type or self._reportType

	if event.name == QUIWidgetSilvesArenaBattleRecord.EVENT_CLICK_HEAD then
		local playerInfoList = info.playerInfoList
		local index = event.index
		local userId = playerInfoList[index].userId

		remote.silvesArena:silvesLookUserDetail(userId)
	elseif event.name == QUIWidgetSilvesArenaBattleRecord.EVENT_CLICK_SHARED then
		local isFight = self._selectTab == QUIDialogSilvesArenaBattleRecord.TAB_ATTACK
		local matchingId = info.matchingId
		local reportIdList = info.reportIdList

		remote.silvesArena:silvesShareFightBatter(reportType, isFight, matchingId, reportIdList)
	elseif event.name == QUIWidgetSilvesArenaBattleRecord.EVENT_CLICK_RECORDE then
		local reportIdList = info.reportIdList
		local matchingId = info.matchingId

		local isFight = self._selectTab == QUIDialogSilvesArenaBattleRecord.TAB_ATTACK
		remote.silvesArena:silvesLookHistoryDetail(reportType, reportIdList, matchingId, isFight)
	end
end

function QUIDialogSilvesArenaBattleRecord:_onTriggerAttack(event)
	if self._selectTab == QUIDialogSilvesArenaBattleRecord.TAB_ATTACK then return end
    app.sound:playSound("common_switch")

	self._selectTab = QUIDialogSilvesArenaBattleRecord.TAB_ATTACK
	self:_selectTabs()
end

function QUIDialogSilvesArenaBattleRecord:_onTriggerDefense(event)
	if self._selectTab == QUIDialogSilvesArenaBattleRecord.TAB_DEFENSE then return end
    app.sound:playSound("common_switch")

	self._selectTab = QUIDialogSilvesArenaBattleRecord.TAB_DEFENSE
	self:_selectTabs()
end

function QUIDialogSilvesArenaBattleRecord:_backClickHandler()
    self:playEffectOut()
end

function QUIDialogSilvesArenaBattleRecord:_onTriggerClose(event)
	if q.buttonEventShadow(event, self._ccbOwner.frame_btn_close) == false then return end
	app.sound:playSound("common_cancel")
	self:playEffectOut()
end


return QUIDialogSilvesArenaBattleRecord
