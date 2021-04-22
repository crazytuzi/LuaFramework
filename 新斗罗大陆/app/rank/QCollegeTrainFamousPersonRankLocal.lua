-- @Author: liaoxianbo
-- @Date:   2019-12-26 12:01:44
-- @Last Modified by:   liaoxianbo
-- @Last Modified time: 2019-12-28 10:12:27

local QBaseRank = import(".QBaseRank")
local QCollegeTrainFamousPersonRankLocal = class("QCollegeTrainFamousPersonRankLocal", QBaseRank)
local QUIWidgetTeamRank = import("..ui.widgets.rank.QUIWidgetTeamRank")
local QUIWidgetTeamMyRank = import("..ui.widgets.rank.QUIWidgetTeamMyRank")
local QUIWidgetRankStyleApple = import("..ui.widgets.rank.QUIWidgetRankStyleApple")
local QUIWidgetMyRankStyleApple = import("..ui.widgets.rank.QUIWidgetMyRankStyleApple")
local QStaticDatabase = import("..controllers.QStaticDatabase")

function QCollegeTrainFamousPersonRankLocal:ctor(options)
	QCollegeTrainFamousPersonRankLocal.super.ctor(self, options)
end

function QCollegeTrainFamousPersonRankLocal:_unpdateChapterInfo(selectInfo)
	self._btninfo = selectInfo
end

-- 本服
function QCollegeTrainFamousPersonRankLocal:update(success, fail)
	--TODO: add response list
	app:getClient():top50RankCollegeTrainRequest("COLLEGE_TRAIN_ENV_HALL_TOP_3", remote.user.userId, nil, function (data)
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

function QCollegeTrainFamousPersonRankLocal:getRankItem()
	local item = QUIWidgetTeamRank.new()
	local style = QUIWidgetRankStyleApple.new()
	item:setStyle(style)
	return item
end

function QCollegeTrainFamousPersonRankLocal:renderItem(item, index)
	local style = item:getStyle()
	local info = self._list[index]
	if style ~= nil and info ~= nil then
		style:setSoulTrial(info.soulTrial)
		style:setTFByIndex(1, "LV."..(info.level or "0"))
		style:setTFByIndex(2, (info.name or ""))
		style:setVIP(info.vip or 0)
		style:setTFByIndex(3, "宗门：")

		-- local passTime = q.timeToHourMinuteSecond(tonumber(info.passTime or 0),true)
		style:setTFByIndex(4, "【"..(info.consortiaName or "无").."】")
		style:setAvatar(info.avatar)
		style:setSpByIndex(1, false)
		style:setBadgeWithPassCount(style:getNodeByIndex(1), info.nightmareDungeonPassCount or 0)
		local famousPersonValue = info.celebrityHallInteral --db:getFamousPersonValueByRank("college_train", index) or 0
		style:setTFByIndex(5, " 竞速积分："..famousPersonValue)
		style:autoLayout()
	end
end

function QCollegeTrainFamousPersonRankLocal:registerClick(listView, index)
	listView:registerClickHandler(index,"self",function ()
		return true
	end, nil, handler(self, self.clickHandler))
end

function QCollegeTrainFamousPersonRankLocal:clickHandler( x, y, touchNodeNode, list )
	-- local info = self._list[list:getCurTouchIndex()]
	-- if info ~= nil then 
	-- 	local options = {}
	-- 	options.isPVP = true
	-- 	self:queryFighterWithRank(info.userId, options)
	-- end
end

function QCollegeTrainFamousPersonRankLocal:getSelfItem()
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

	-- style:setTFByIndex(3, "宗门：")
	-- -- local passTime = q.timeToHourMinuteSecond(tonumber(myInfo.passTime or 0),true)
	-- style:setTFByIndex(4, "【"..(myInfo.consortiaName or "无").."】")
	-- local famousPersonValue = myInfo.celebrityHallInteral or 0 --db:getFamousPersonValueByRank("college_train", myInfo.rank) or 0
	-- style:setTFByIndex(5, "  竞速积分："..famousPersonValue)

	local famousPersonValue = myInfo.celebrityHallInteral or 0 
	
	if myInfo.consortiaName and famousPersonValue > 0 then
		style:setTFByIndex(3, "宗门：")
		style:setTFByIndex(4, "【"..(myInfo.consortiaName or "无").."】")
		style:setTFByIndex(5, "  竞速积分："..famousPersonValue)
	else
		style:setTFByIndex(4, "未上榜")
		style:setTFByIndex(5, "")
	end

	style:setSpByIndex(1, false)
	style:autoLayout()
	return item
end

return QCollegeTrainFamousPersonRankLocal