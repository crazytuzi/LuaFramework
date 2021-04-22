-- @Author: liaoxianbo
-- @Date:   2019-12-20 14:48:55
-- @Last Modified by:   liaoxianbo
-- @Last Modified time: 2019-12-26 16:12:57

local QBaseRank = import(".QBaseRank")
local QCollegeTrainHallTopRank = class("QCollegeTrainHallTopRank", QBaseRank)
local QUIWidgetTeamRank = import("..ui.widgets.rank.QUIWidgetTeamRank")
local QUIWidgetTeamMyRank = import("..ui.widgets.rank.QUIWidgetTeamMyRank")
local QUIWidgetRankStyleApple = import("..ui.widgets.rank.QUIWidgetRankStyleApple")
local QUIWidgetMyRankStyleApple = import("..ui.widgets.rank.QUIWidgetMyRankStyleApple")
local QStaticDatabase = import("..controllers.QStaticDatabase")

function QCollegeTrainHallTopRank:ctor(options)
	QCollegeTrainHallTopRank.super.ctor(self, options)
end

function QCollegeTrainHallTopRank:_unpdateChapterInfo(selectInfo)
	self._btninfo = selectInfo
end

-- 本服
function QCollegeTrainHallTopRank:update(success, fail)
	--TODO: add response list
	app:getClient():top50RankCollegeTrainRequest("COLLEGE_TRAIN_TOP_50", remote.user.userId, self._btninfo.chapterId, function (data)
		if data.rankings == nil or data.rankings.top50 == nil then 
			self.super:update(fail)
			return 
		end

		self._list = nil
		self._list = clone(data.rankings.top50)
		table.sort(self._list, function (x, y)
			return x.rank < y.rank
		end)
		self._myInfo = data.rankings.myself

		self.super:update(success)
	end, fail)
end

function QCollegeTrainHallTopRank:getRankItem()
	local item = QUIWidgetTeamRank.new()
	local style = QUIWidgetRankStyleApple.new()
	item:setStyle(style)
	return item
end

function QCollegeTrainHallTopRank:renderItem(item, index)
	local style = item:getStyle()
	local info = self._list[index]
	if style ~= nil and info ~= nil then
		style:setSoulTrial(info.soulTrial)
		style:setTFByIndex(1, "LV."..(info.level or "0"))
		style:setTFByIndex(2, (info.name or ""))
		style:setVIP(info.vip or 0)
		style:setTFByIndex(3, "通关时间：")

		-- local passTime = q.timeToHourMinuteSecond(tonumber(info.passTime or 0),true)
		local passTime = string.format("%0.2f", tonumber(info.passTime or 0) / 1000.0 )		
		style:setTFByIndex(4, passTime)
		style:setAvatar(info.avatar)
		style:setSpByIndex(1, false)
		style:setBadgeWithPassCount(style:getNodeByIndex(1), info.nightmareDungeonPassCount or 0)
		local famousPersonValue = db:getFamousPersonValueByRank("college_train", index) or 0
		style:setTFByIndex(5, " 竞速积分："..famousPersonValue)
		style:autoLayout()
	end
end

function QCollegeTrainHallTopRank:registerClick(listView, index)
	listView:registerClickHandler(index,"self",function ()
		return true
	end, nil, handler(self, self.clickHandler))
end

function QCollegeTrainHallTopRank:clickHandler( x, y, touchNodeNode, list )
	-- local info = self._list[list:getCurTouchIndex()]
	-- if info ~= nil then 
	-- 	local options = {}
	-- 	options.isPVP = true
	-- 	self:queryFighterWithRank(info.userId, options)
	-- end
end

function QCollegeTrainHallTopRank:getSelfItem()
	local myInfo = self:getMyInfo()
	if myInfo == nil then
		return 
	end
	local item = QUIWidgetTeamMyRank.new({config = self._config})
	item:setInfo(myInfo)
	item:showAwardButton()
	local style = QUIWidgetMyRankStyleApple.new()
	item:setStyle(style)

	style:setSoulTrial(myInfo.soulTrial)
	style:setTFByIndex(1, "LV."..(myInfo.level or "0"))
	style:setTFByIndex(2, (myInfo.name or ""))
	style:setAvatar(myInfo.avatar)
	style:setBadgeWithPassCount(style:getNodeByIndex(1), myInfo.nightmareDungeonPassCount or 0)

	local famousPersonValue = db:getFamousPersonValueByRank("college_train", myInfo.rank) or 0
	if myInfo.passTime then
		style:setTFByIndex(3, "通关时间：")
		local passTime = string.format("%0.2f", tonumber(myInfo.passTime or 0) / 1000.0 )	
		style:setTFByIndex(4, passTime)
		style:setTFByIndex(5, "  竞速积分："..famousPersonValue)
	else
		style:setTFByIndex(3, "未通关")
		style:setTFByIndex(5, "")
	end	
	style:setSpByIndex(1, false)
	style:autoLayout()
	return item
end

return QCollegeTrainHallTopRank