-- 
-- Kumo.Wang
-- 押注界面
--

local QUIDialogStake = import(".QUIDialogStake")
local QUIDialogSilvesArenaPeakStake = class("QUIDialogSilvesArenaPeakStake", QUIDialogStake)
local QUIWidgetAvatar = import("..widgets.QUIWidgetAvatar")
local QUIViewController = import("...ui.QUIViewController")
local QReplayUtil = import("...utils.QReplayUtil")
local QQuickWay = import("...utils.QQuickWay")

-- 注意，比分顺序： 2:0 2:1 1:2 0:2
function QUIDialogSilvesArenaPeakStake:ctor(options)
	QUIDialogSilvesArenaPeakStake.super.ctor(self, options)

	local index = 1 
	while true do
		local sp = self._ccbOwner["sp_icon_"..index]
		if sp then
			local info = remote.items:getWalletByType(ITEM_TYPE.SILVESARENA_SHOP_GOLD)
			if info ~= nil and info.alphaIcon ~= nil then
				local texture = CCTextureCache:sharedTextureCache():addImage(info.alphaIcon)
				if texture then
				    local size = texture:getContentSize()
				    local rect = CCRectMake(0, 3, size.width, size.height)
					sp:setTexture(texture)
					sp:setTextureRect(rect)
				end 
			end
			index = index + 1
		else
			break
		end
	end
end

function QUIDialogSilvesArenaPeakStake:updateInfo()
	self._fighter1 = self._player1.leader
    self._fighter2 = self._player2.leader

    QUIDialogSilvesArenaPeakStake.super.updateInfo(self)
end

function QUIDialogSilvesArenaPeakStake:updatePlayer()
	if not self._player1 or not self._player2 then return end

	local isMe1 = remote.silvesArena.myTeamInfo and self._player1.teamId == remote.silvesArena.myTeamInfo.teamId
	local totalForce1, totalNumber1 = remote.silvesArena:getTotalForceAndTotalNumberByTeamInfo(self._player1, isMe1)
	if totalForce1 and totalNumber1 then
	    local num1, unit1 = q.convertLargerNumber(totalForce1/totalNumber1)
		self._ccbOwner.tf_force1:setString( num1..(unit1 or "") )
	else
		self._ccbOwner.tf_force1:setString(0)
	end

	self._ccbOwner.tf_name1:setString(self._player1.teamName)

	local avatar1 = QUIWidgetAvatar.new(self._fighter1.avatar)
	avatar1:setSilvesArenaPeak(self._fighter1.championCount)
    self._ccbOwner.node_head1:addChild(avatar1)

	local isMe2 = remote.silvesArena.myTeamInfo and self._player2.teamId == remote.silvesArena.myTeamInfo.teamId
	local totalForce2, totalNumber2 = remote.silvesArena:getTotalForceAndTotalNumberByTeamInfo(self._player2, isMe2)
	if totalForce2 and totalNumber2 then
	    local num2, unit2 = q.convertLargerNumber(totalForce2/totalNumber2)
		self._ccbOwner.tf_force2:setString( num2..(unit2 or "") )
	else
		self._ccbOwner.tf_force2:setString(0)
	end

	self._ccbOwner.tf_name2:setString(self._player2.teamName)
	
	local avatar2 = QUIWidgetAvatar.new(self._fighter2.avatar)
	avatar2:setSilvesArenaPeak(self._fighter2.championCount)
    avatar2:setScaleX(-1)
    self._ccbOwner.node_head2:addChild(avatar2)
end

function QUIDialogSilvesArenaPeakStake:_onTriggerBet()
	app.sound:playSound("common_confirm")

	local peakState = remote.silvesArena:getCurPeakState()
	if peakState ~= remote.silvesArena.PEAK_WAIT_TO_4 and peakState ~= remote.silvesArena.PEAK_WAIT_TO_FINAL then
		app.tip:floatTip("押注时间不对")
		return
	end
	
	local peakState = remote.silvesArena:getCurPeakState()
	local isCan = false
	if peakState == remote.silvesArena.PEAK_READY_TO_4
		or peakState == remote.silvesArena.PEAK_WAIT_TO_4
		or peakState == remote.silvesArena.PEAK_READY_TO_FINAL
		or peakState == remote.silvesArena.PEAK_WAIT_TO_FINAL then

		isCan = true
	end

	if isCan then
		if self._selectNum == 0 then 
			app.tip:floatTip("未选择押注比分")
			return
		end
		if self._nums == 0 then 
			app.tip:floatTip("购买数量不能为0")
			return
		end

		if self._betInfo and self._betInfo.myScoreId and self._betInfo.myScoreId ~= 0 then 
			app.tip:floatTip("魂师大人，本次比赛您已经押过注了~")
			return
		end

		local haveNums = remote.user[ITEM_TYPE.SILVESARENA_SHOP_GOLD] or 0
		if haveNums < self._nums then
			QQuickWay:addQuickWay(QQuickWay.RESOUCE_DROP_WAY, ITEM_TYPE.SILVESARENA_SHOP_GOLD, nil, nil, false)
			return
		end

		if not self._player1 or not self._player1.teamId or not self._player2 or not self._player2.teamId then return end

		remote.silvesArena:silvesPeakBetRequest(self._player1.teamId, self._player2.teamId, self._nums, self._selectNum, function()
				app.tip:floatTip("押注成功~")
				remote.silvesArena:silvesPeakGetMyBetInfoRequest()
				self:playEffectOut()
			end)
	else
		app.tip:floatTip("押注时间已过~")
		self:playEffectOut()
	end
end

-- 查询阵容对比
function QUIDialogSilvesArenaPeakStake:_onTriggerVisit()
    app.sound:playSound("common_small")
	if not self._player1 or not self._player1.teamId or not self._player2 or not self._player2.teamId then return end

	remote.silvesArena:silvesArenaQueryTeamFighterRequest(self._player1.teamId, self._player2.teamId, function ( data )
        if data.silvesArenaInfoResponse and data.silvesArenaInfoResponse.teamInfoList and data.silvesArenaInfoResponse.teamInfoList.teamInfo then
        	app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogSilvesArenaStakeTeamDetail",
            	options = {teamInfo = data.silvesArenaInfoResponse.teamInfoList.teamInfo}}, {isPopCurrentDialog = false})
        end
    end)
end

function QUIDialogSilvesArenaPeakStake:_onTriggerVisit1()
    app.sound:playSound("common_small")
	if not self._player1 or not self._player1.teamId then
		return
	end

	-- local _module = remote.silvesArena.BATTLEFORMATION_MODULE_RANK_PVP
	-- local isMe = self._player1.teamId == remote.silvesArena.myTeamInfo.teamId
	-- if isMe then
		_module = remote.silvesArena.BATTLEFORMATION_MODULE_RANK_NORMAL
	-- end
	remote.silvesArena:silvesArenaQueryTeamFighterRequest(self._player1.teamId, nil, function()
		if self:safeCheck() then
			app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogSilvesBattleFormation",
				options = {teamId = self._player1.teamId, module = _module}}, {isPopCurrentDialog = false})
		end
	end)
end

function QUIDialogSilvesArenaPeakStake:_onTriggerVisit2()
    app.sound:playSound("common_small")
	if not self._player2 or not self._player2.teamId then
		return
	end

	-- local _module = remote.silvesArena.BATTLEFORMATION_MODULE_RANK_PVP
	-- local isMe = self._player2.teamId == remote.silvesArena.myTeamInfo.teamId
	-- if isMe then
		_module = remote.silvesArena.BATTLEFORMATION_MODULE_RANK_NORMAL
	-- end
	remote.silvesArena:silvesArenaQueryTeamFighterRequest(self._player2.teamId, nil, function()
		if self:safeCheck() then
			app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogSilvesBattleFormation",
				options = {teamId = self._player2.teamId, module = _module}}, {isPopCurrentDialog = false})
		end
	end)
end

return QUIDialogSilvesArenaPeakStake
