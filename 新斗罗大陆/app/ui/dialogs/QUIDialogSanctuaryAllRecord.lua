--
-- zxs
-- 精英赛战斗记录
--
local QUIDialog = import(".QUIDialog")
local QUIDialogSanctuaryAllRecord = class("QUIDialogSanctuaryAllRecord", QUIDialog)
local QUIWidgetSanctuaryPageGroup = import("..widgets.sanctuary.QUIWidgetSanctuaryPageGroup")
local QUIWidgetSanctuaryHead = import("..widgets.sanctuary.QUIWidgetSanctuaryHead")
local QReplayUtil = import("...utils.QReplayUtil")
local QUIViewController = import("..QUIViewController")

QUIDialogSanctuaryAllRecord.TAB_REPORTS_8 = "TAB_REPORTS_8"
QUIDialogSanctuaryAllRecord.TAB_REPORTS_64 = "TAB_REPORTS_64"

function QUIDialogSanctuaryAllRecord:ctor(options)
	local ccbFile = "ccb/Dialog_Sanctuary_zhanbao.ccbi"
	local callBacks = {
        {ccbCallbackName = "onTriggerReplay1", callback = handler(self, self._onTriggerReplay1)},
        {ccbCallbackName = "onTriggerReplay2", callback = handler(self, self._onTriggerReplay2)},
        {ccbCallbackName = "onTriggerReplay3", callback = handler(self, self._onTriggerReplay3)},
        {ccbCallbackName = "onTriggerReplay4", callback = handler(self, self._onTriggerReplay4)},
        {ccbCallbackName = "onTriggerReplay5", callback = handler(self, self._onTriggerReplay5)},
        {ccbCallbackName = "onTriggerReplay6", callback = handler(self, self._onTriggerReplay6)},
        {ccbCallbackName = "onTriggerReplay7", callback = handler(self, self._onTriggerReplay7)},
        {ccbCallbackName = "onTriggerReplay8", callback = handler(self, self._onTriggerReplay8)},
        {ccbCallbackName = "onTriggerLeft", callback = handler(self, self._onTriggerLeft)},
        {ccbCallbackName = "onTriggerRight", callback = handler(self, self._onTriggerRight)},
        {ccbCallbackName = "onTriggerReport8", callback = handler(self, self._onTriggerReport8)},
        {ccbCallbackName = "onTriggerReport64", callback = handler(self, self._onTriggerReport64)},
        {ccbCallbackName = "onTriggerClose", callback = handler(self, self._onTriggerClose)},
	}
	QUIDialogSanctuaryAllRecord.super.ctor(self,ccbFile,callBacks,options)
	self.isAnimation = true

	q.setButtonEnableShadow(self._ccbOwner.camera_1)
	q.setButtonEnableShadow(self._ccbOwner.camera_2)
	q.setButtonEnableShadow(self._ccbOwner.camera_3)
	q.setButtonEnableShadow(self._ccbOwner.camera_4)
	q.setButtonEnableShadow(self._ccbOwner.camera_5)
	q.setButtonEnableShadow(self._ccbOwner.camera_6)
	q.setButtonEnableShadow(self._ccbOwner.camera_7)
	q.setButtonEnableShadow(self._ccbOwner.camera_8)

	self._heads = {}
	self._heads[1] = {{pos = 1, camera = 1}, {pos = 9, line = 1, camera = 5}, {pos = 13, line = 9, camera = 7}, {pos = 15, line = 13}}
	self._heads[2] = {{pos = 2, camera = 1}, {pos = 9, line = 2, camera = 5}, {pos = 13, line = 9, camera = 7}, {pos = 15, line = 13}}
	self._heads[3] = {{pos = 3, camera = 2}, {pos = 10, line = 3, camera = 5}, {pos = 13, line = 10, camera = 7}, {pos = 15, line = 13}}
	self._heads[4] = {{pos = 4, camera = 2}, {pos = 10, line = 4, camera = 5}, {pos = 13, line = 10, camera = 7}, {pos = 15, line = 13}}
	self._heads[5] = {{pos = 5, camera = 3}, {pos = 11, line = 5, camera = 6}, {pos = 14, line = 11, camera = 7}, {pos = 15, line = 14}}
	self._heads[6] = {{pos = 6, camera = 3}, {pos = 11, line = 6, camera = 6}, {pos = 14, line = 11, camera = 7}, {pos = 15, line = 14}}
	self._heads[7] = {{pos = 7, camera = 4}, {pos = 12, line = 7, camera = 6}, {pos = 14, line = 12, camera = 7}, {pos = 15, line = 14}}
	self._heads[8] = {{pos = 8, camera = 4}, {pos = 12, line = 8, camera = 6}, {pos = 14, line = 12, camera = 7}, {pos = 15, line = 14}}

	self._report8 = nil
	self._report64 = nil
	self._selectTab = options.selectTab or QUIDialogSanctuaryAllRecord.TAB_REPORTS_64
	self:resetGroup()
	self:selectTabs()
end

-- 重置所有
function QUIDialogSanctuaryAllRecord:resetAll()
	self._groupBtn = {}
	self._ccbOwner.node_group:removeAllChildren()
	self._ccbOwner.btn_report8:setEnabled(true)
	self._ccbOwner.btn_report8:setHighlighted(false)
	self._ccbOwner.btn_report64:setEnabled(true)
	self._ccbOwner.btn_report64:setHighlighted(false)
	self._ccbOwner.node_another:setVisible(false)
	self._ccbOwner.sp_group_first:setVisible(false)
	self._ccbOwner.sp_all_first:setVisible(false)
end

-- 重置小组
function QUIDialogSanctuaryAllRecord:resetGroup()
	local index = 1
	while self._ccbOwner["line_"..index] do
		self._ccbOwner["line_"..index]:setVisible(false)
		index = index + 1
	end

	index = 1
	while self._ccbOwner["head_"..index] do
		self._ccbOwner["head_"..index]:removeAllChildren()
		index = index + 1
	end

	index = 1
	while self._ccbOwner["camera_"..index] do
		self._ccbOwner["camera_"..index]:setVisible(false)
		index = index + 1
	end

	self._ccbOwner.head_another1:removeAllChildren()
	self._ccbOwner.head_another2:removeAllChildren()
end

function QUIDialogSanctuaryAllRecord:selectTabs()
	self:getOptions().selectTab = self._selectTab
	self:resetAll()

	if self._selectTab == QUIDialogSanctuaryAllRecord.TAB_REPORTS_8 then
		self._ccbOwner.btn_report8:setEnabled(false)
		self._ccbOwner.btn_report8:setHighlighted(true)
		self._ccbOwner.sp_all_first:setVisible(true)

		local callback = function()
			self:showEightInfo()
		end
		if self._report8 == nil then
			remote.sanctuary:sanctuaryWarGetSpecialReportRequest(true, function(data)
				if self:safeCheck() then
					self._report8 = data.sanctuaryWarInfoResponse.positions or {}
					for index, v in pairs(self._report8) do
						if v.currRound == remote.sanctuary.ROUND_8 then
							v.localRound = remote.sanctuary.POS_1
						elseif v.currRound == remote.sanctuary.ROUND_4 then
							v.localRound = remote.sanctuary.POS_2
						elseif v.currRound == remote.sanctuary.ROUND_2 then
							v.localRound = remote.sanctuary.POS_3
						elseif v.currRound == remote.sanctuary.ROUND_1 then
							v.localRound = remote.sanctuary.POS_4
						end
					end
					callback()
				end
			end)
		else
			callback()
		end
	elseif self._selectTab == QUIDialogSanctuaryAllRecord.TAB_REPORTS_64 then
		self._ccbOwner.btn_report64:setEnabled(false)
		self._ccbOwner.btn_report64:setHighlighted(true)
		self._ccbOwner.node_another:setVisible(false)
		self._ccbOwner.sp_group_first:setVisible(true)

		local callback = function()
			self:setGroupBtns()
			self:showGroupInfo()
		end
		if self._report64 == nil then
			remote.sanctuary:sanctuaryWarGetSpecialReportRequest(false, function(data)
				if self:safeCheck() then
					self._report64 = data.sanctuaryWarInfoResponse.positions or {}
					for index, v in pairs(self._report64) do
						if v.currRound == remote.sanctuary.ROUND_64 then
							v.localRound = remote.sanctuary.POS_1
						elseif v.currRound == remote.sanctuary.ROUND_32 then
							v.localRound = remote.sanctuary.POS_2
						elseif v.currRound == remote.sanctuary.ROUND_16 then
							v.localRound = remote.sanctuary.POS_3
						elseif v.currRound >= remote.sanctuary.ROUND_8 then
							v.localRound = remote.sanctuary.POS_4
						end
					end
					callback()
				end
			end)		
		else
			callback()
		end
	end
end

function QUIDialogSanctuaryAllRecord:showEightInfo()
	self:resetGroup()
	self._players = self._report8
	if #self._players == 0 then
		self._ccbOwner.node_client:setVisible(false)
		self._ccbOwner.node_no:setVisible(true)
	else
		self._ccbOwner.node_client:setVisible(true)
		self._ccbOwner.node_no:setVisible(false)
	end
	
	self._topLocalRound = remote.sanctuary.POS_1
	self._topCurRound = remote.sanctuary.ROUND_8
	for i, player in pairs(self._players) do
		if player.localRound > self._topLocalRound then
			self._topLocalRound = player.localRound
		end
		if player.currRound > self._topCurRound then
			self._topCurRound = player.currRound
		end
	end

	for i, player in pairs(self._players) do
		self:showHeadByInfo(player, true)

		-- 处理第三名第四名--需要冠军已经出现
		if player.currRound == remote.sanctuary.ROUND_4 and self._topCurRound == remote.sanctuary.ROUND_1 then
			self._ccbOwner["camera_8"]:setVisible(true)
			self._ccbOwner.node_another:setVisible(true)

			local isFail = not player.thirdIsWin
			if isFail then
				local head = QUIWidgetSanctuaryHead.new()
				self._ccbOwner.head_another2:addChild(head)
				head:setInfo(player, isFail, true)
				head:setHeadFlipX()
				
				-- 季军赛标记
				player.isThirdRound = true
			else
				local head = QUIWidgetSanctuaryHead.new()
				self._ccbOwner.head_another1:addChild(head)
				head:setInfo(player, isFail, true)
			end
		end
	end
end

--刷新数据
function QUIDialogSanctuaryAllRecord:setGroupBtns()
	local totalPage, myIndex = self:getTotalAndMyPage()
	self._totalPage = totalPage
	self._currentIndex = myIndex

	local options = self:getOptions()
	if options.currentIndex then
		self._currentIndex = options.currentIndex
	end
	if self._currentIndex == 0 then
		self._currentIndex = 1
	end
	if self._currentIndex > self._totalPage then
		self._currentIndex = self._totalPage
	end

	local width = 65
	local startPosX = -self._totalPage*width/2 - width/2
	for index = 1, self._totalPage do
		self._groupBtn[index] = QUIWidgetSanctuaryPageGroup.new()
		self._groupBtn[index]:addEventListener(QUIWidgetSanctuaryPageGroup.EVENT_GROUP_CLICK, handler(self, self._groupClickHandler))
		self._groupBtn[index]:setPositionX(startPosX+index*width)
		self._groupBtn[index]:setIndex(index)
		self._groupBtn[index]:setIsSelf(myIndex == index)
		self._ccbOwner.node_group:addChild(self._groupBtn[index])
	end
end

--显示界面的信息
function QUIDialogSanctuaryAllRecord:showGroupInfo()
	self:getOptions().currentIndex = self._currentIndex

	self:resetGroup()
	self._players = self:getInfoByPage(self._currentIndex)
	if #self._players == 0 then
		self._ccbOwner.node_client:setVisible(false)
		self._ccbOwner.node_no:setVisible(true)
	else
		self._ccbOwner.node_client:setVisible(true)
		self._ccbOwner.node_no:setVisible(false)
	end
	
	self._topLocalRound = remote.sanctuary.POS_1
	local maxForce = 0
	for i, player in pairs(self._players) do
		if player.localRound > self._topLocalRound then
			self._topLocalRound = player.localRound
		end
		if player.fighter.force > maxForce then
			maxForce = player.fighter.force
		end
	end
	for i, player in pairs(self._players) do
		local isTopForce = player.fighter.force == maxForce
		self:showHeadByInfo(player, false, isTopForce)
	end
	for index = 1, self._totalPage do
		self._groupBtn[index]:setIsSelected(index == self._currentIndex)
	end
end

function QUIDialogSanctuaryAllRecord:getTotalAndMyPage()
	local maxPos = 1
	local myIndex = 0
	for _,v in pairs(self._report64) do
		maxPos = math.max(v.position, maxPos)
		if v.fighter.userId == remote.user.userId then
			myIndex = math.ceil(v.position/8)
		end
	end
	return math.ceil(maxPos/8), myIndex
end

--根据页签获取数据
function QUIDialogSanctuaryAllRecord:getInfoByPage(index)
	local players = {}
	local startIndex = (index-1)*8+1
	for _, v in pairs(self._report64) do
		if startIndex <= v.position and v.position < startIndex + 8 then
			table.insert(players, v)
		end
	end
	return players
end

--根据单个信息显示头像
function QUIDialogSanctuaryAllRecord:showHeadByInfo(player, isEight, isTopForce)
	if player == nil or player.fighter == nil then
		return 
	end

	local headFun = function (player, headConfig, posId, index)
		local head = QUIWidgetSanctuaryHead.new()
		self._ccbOwner["head_"..headConfig.pos]:addChild(head)

		local isFail = nil
		if self._topLocalRound > posId then
			if posId == player.localRound and not player.ifNextRound then
				isFail = true
			else
				isFail = false
			end
		end
		head:setInfo(player, isFail, false)
		if posId < remote.sanctuary.POS_4 then
			head:setIsTopForce(isTopForce)
		end

		if headConfig.line then
			self._ccbOwner["line_"..headConfig.line]:setVisible(true)
		end

		if index > 4 then
			head:setHeadFlipX()
		end
		
		-- 标记对应放大镜
		player.camera = 0
		if isFail and headConfig.camera then
			player.camera = headConfig.camera
			self._ccbOwner["camera_"..headConfig.camera]:setVisible(true)
		end
	end

	local index = 1
	if isEight then
		index = math.floor((player.position-1)/8)+1
	else
		index = (player.position-1)%8+1
	end
	if player.localRound >= remote.sanctuary.POS_1 then
		headFun(player, self._heads[index][1], remote.sanctuary.POS_1, index)
	end
	if player.localRound >= remote.sanctuary.POS_2 then
		headFun(player, self._heads[index][2], remote.sanctuary.POS_2, index)
	end
	if player.localRound >= remote.sanctuary.POS_3 then
		headFun(player, self._heads[index][3], remote.sanctuary.POS_3, index)
	end
	if player.localRound >= remote.sanctuary.POS_4 then
		headFun(player, self._heads[index][4], remote.sanctuary.POS_4, index)
	end	
end

--播放战斗回放通过index
function QUIDialogSanctuaryAllRecord:playBattleByIndex(index)
	-- 对应放大镜
	local battleInfo = nil
	for i, player in pairs(self._players) do
		if player.camera == index then
			battleInfo = player
			break
		end
		-- 季军赛
		if player.isThirdRound and index == 8 then
			battleInfo = player
			break
		end
	end
	if battleInfo ~= nil then
		-- 季军赛特殊处理
		local isThirdRound = false
		local isEightReport = false
		if index == 8 then
			isThirdRound = true
		end
		if self._selectTab == QUIDialogSanctuaryAllRecord.TAB_REPORTS_8 then
			isEightReport = true
		end
		remote.sanctuary:sanctuaryWarGetReportRequest(battleInfo.currRound, battleInfo.fighter.userId, true, isEightReport, isThirdRound, function (data)
			local reports = data.sanctuaryWarGetReportResponse.reports or {}
			if reports[1] then
				app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogSanctuaryRecordDetail", 
					options = {report = reports[1]}}, {isPopCurrentDialog = false})
			end
		end)
	else
		app.tip:floatTip("没有可用的战报~")
	end
end

function QUIDialogSanctuaryAllRecord:_onTriggerReplay1(e)
	self:playBattleByIndex(1)
end

function QUIDialogSanctuaryAllRecord:_onTriggerReplay2(e)
	self:playBattleByIndex(2)
end

function QUIDialogSanctuaryAllRecord:_onTriggerReplay3(e)
	self:playBattleByIndex(3)
end

function QUIDialogSanctuaryAllRecord:_onTriggerReplay4(e)
	self:playBattleByIndex(4)
end

function QUIDialogSanctuaryAllRecord:_onTriggerReplay5(e)
	self:playBattleByIndex(5)
end

function QUIDialogSanctuaryAllRecord:_onTriggerReplay6(e)
	self:playBattleByIndex(6)
end

function QUIDialogSanctuaryAllRecord:_onTriggerReplay7(e)
	self:playBattleByIndex(7)
end

function QUIDialogSanctuaryAllRecord:_onTriggerReplay8(e)
	self:playBattleByIndex(8)
end

function QUIDialogSanctuaryAllRecord:_onTriggerLeft(e)
	self._currentIndex = self._currentIndex - 1
	if self._currentIndex < 1 then
		self._currentIndex = self._totalPage
	end
	self:showGroupInfo()
end

function QUIDialogSanctuaryAllRecord:_onTriggerRight(e)
	self._currentIndex = self._currentIndex + 1
	if self._currentIndex > self._totalPage then
		self._currentIndex = 1
	end
	self:showGroupInfo()
end

function QUIDialogSanctuaryAllRecord:_onTriggerReport8(e)
	if self._selectTab == QUIDialogSanctuaryAllRecord.TAB_REPORTS_8 then return end
    app.sound:playSound("common_switch")

	self._selectTab = QUIDialogSanctuaryAllRecord.TAB_REPORTS_8
	self:selectTabs()
end

function QUIDialogSanctuaryAllRecord:_onTriggerReport64(e)
	if self._selectTab == QUIDialogSanctuaryAllRecord.TAB_REPORTS_64 then return end
    app.sound:playSound("common_switch")

	self._selectTab = QUIDialogSanctuaryAllRecord.TAB_REPORTS_64
	self:selectTabs()
end

function QUIDialogSanctuaryAllRecord:_groupClickHandler(event)
	self._currentIndex = event.index
	self:showGroupInfo()
end

function QUIDialogSanctuaryAllRecord:_onTriggerClose(event)
    if q.buttonEventShadow(event, self._ccbOwner.frame_btn_close) == false then return end		
    app.sound:playSound("common_cancel")
    self:playEffectOut()
end

return QUIDialogSanctuaryAllRecord