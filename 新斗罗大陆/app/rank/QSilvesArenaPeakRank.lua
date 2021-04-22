--
-- Kumo.Wang
-- 西尔维斯巅峰赛排行榜
-- 

local QBaseRank = import(".QBaseRank")
local QSilvesArenaPeakRank = class("QSilvesArenaPeakRank", QBaseRank)

local QUIWidgetWideRank = import("..ui.widgets.rank.QUIWidgetWideRank")
local QUIWidgetTeamMyRank = import("..ui.widgets.rank.QUIWidgetTeamMyRank")
local QUIWidgetRankStyleSilves = import("..ui.widgets.rank.QUIWidgetRankStyleSilves")
local QStaticDatabase = import("..controllers.QStaticDatabase")
local QUIWidgetMyRankStyleSilves = import("..ui.widgets.rank.QUIWidgetMyRankStyleSilves")
local QUIViewController = import("..ui.QUIViewController")

function QSilvesArenaPeakRank:ctor(options)
	QSilvesArenaPeakRank.super.ctor(self, options)
end

function QSilvesArenaPeakRank:needsUpdate( ... )
	return true
end

function QSilvesArenaPeakRank:update(success, fail)
	-- 需要修改数据接口
	app:getClient():top50RankRequest("SILVES_PEAK_SEASON_TOP16", remote.user.userId, function (data)
		if data.silvesArenaRankResponse == nil or data.silvesArenaRankResponse.teamRankInfo == nil then 
			self.super:update(fail)
			return 
		end
	
		self._list = nil
		self._list = clone(data.silvesArenaRankResponse.teamRankInfo)

		self._myInfo = data.silvesArenaRankResponse.myRankInfo

		if self._myInfo then
			local _totalForce, _totalNumber = remote.silvesArena:getTotalForceAndTotalNumberByTeamInfo(self._myInfo, true)
			if _totalForce and _totalNumber then
				self._myInfo.averageForce = _totalForce / _totalNumber
			else
				self._myInfo.averageForce = 0
			end
			self._myInfo.rank = self._myInfo.teamRank
		end
	

		for i,v in ipairs(self._list) do
			v.rank = v.teamRank or v.rank

			local isMe = false
			if not q.isEmpty(self._myInfo) then
				if v.teamId == self._myInfo.teamId then
					isMe = true
				end
			end
			local _totalForce, _totalNumber = remote.silvesArena:getTotalForceAndTotalNumberByTeamInfo(v, isMe)
			if _totalForce and _totalNumber then
				v.averageForce = _totalForce / _totalNumber
			else
				v.averageForce = 0
			end
		end

		table.sort(self._list, function (x, y)
			return x.teamRank < y.teamRank
		end)
		
		self.super:update(success)
	end, fail)
end

function QSilvesArenaPeakRank:getRankItem()
	local item = QUIWidgetWideRank.new()
	local style = QUIWidgetRankStyleSilves.new()
	item:setStyle(style)
	return item
end

function QSilvesArenaPeakRank:renderItem(item, index)
	local style = item:getStyle()
	local info = self._list[index]
	if style ~= nil and info ~= nil then
		style:setTFByIndex(1, (info.teamName or ""))
		local num, unit = q.convertLargerNumber(info.averageForce)
		local fightNum = num..(unit or "")

		style:setAvatarByIndex(info.leader.avatar, 1)
		style:setAvatarByIndex(info.member1.avatar, 2)
		style:setAvatarByIndex(info.member2.avatar, 3)

		-- style:setTFByIndex(2, "积分：")
		-- style:setTFByIndex(3, info.teamScore or 0)
		style:setTFByIndex(2, "平均战力：")
		style:setTFByIndex(3, fightNum or "")
		style:autoLayout()
	end
end

function QSilvesArenaPeakRank:getSelfItem()
	local myInfo = self:getMyInfo()
	if myInfo == nil then
		return 
	end
	local item = QUIWidgetTeamMyRank.new()
	item:setInfo(myInfo)
	local style = QUIWidgetMyRankStyleSilves.new()
	item:setStyle(style)
	
	local num, unit = q.convertLargerNumber(myInfo.averageForce)
	local fightNum = num..(unit or "")

	style:setTFByIndex(1, (myInfo.teamName or ""))

	style:setAvatarByIndex(myInfo.leader.avatar, 1)
	style:setAvatarByIndex(myInfo.member1.avatar, 2)
	style:setAvatarByIndex(myInfo.member2.avatar, 3)

	-- style:setTFByIndex(2, "积分：")
	-- style:setTFByIndex(3, myInfo.teamScore or 0)
	style:setTFByIndex(2, "平均战力：")
	style:setTFByIndex(3, fightNum or "")

	style:autoLayout()
	return item
end

function QSilvesArenaPeakRank:registerClick(listView, index)
	listView:registerClickHandler(index,"self",function ()
		return true
	end, nil, handler(self, self.clickHandler))
end

function QSilvesArenaPeakRank:clickHandler( x, y, touchNodeNode, list)
	local info = self._list[list:getCurTouchIndex()]
	if info ~= nil then
		local myInfo = self:getMyInfo()
		local teamId = info.teamId

		if teamId == nil then
			return
		end

		local _module = remote.silvesArena.BATTLEFORMATION_MODULE_RANK_NORMAL
		local state = remote.silvesArena:getCurState(true)
    	if state == remote.silvesArena.STATE_PLAY or state == remote.silvesArena.STATE_READY or remote.silvesArena:isTimeToHideThirdTeam() then
			_module = remote.silvesArena.BATTLEFORMATION_MODULE_RANK_PVP
		end
		if myInfo and myInfo.teamId == teamId then
			_module = remote.silvesArena.BATTLEFORMATION_MODULE_RANK_NORMAL
		end

		remote.silvesArena:silvesArenaQueryTeamFighterRequest(teamId, nil, function()
			if self.class then
				app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogSilvesBattleFormation",
					options = {teamId = teamId, module = _module}}, {isPopCurrentDialog = false})
			end
		end)
	end
end

return QSilvesArenaPeakRank