local QBaseRank = import(".QBaseRank")
local QSparFieldRank = class("QSparFieldRank", QBaseRank)
local QStaticDatabase = import("..controllers.QStaticDatabase")
local QUIWidgetTeamRank = import("..ui.widgets.rank.QUIWidgetTeamRank")
local QUIWidgetTeamMyRank = import("..ui.widgets.rank.QUIWidgetTeamMyRank")
local QUIWidgetRankStyleApple = import("..ui.widgets.rank.QUIWidgetRankStyleApple")
local QUIWidgetMyRankStyleApple = import("..ui.widgets.rank.QUIWidgetMyRankStyleApple")

function QSparFieldRank:ctor(options)
	QSparFieldRank.super.ctor(self, options)
end

function QSparFieldRank:needsUpdate( ... )
	return true
end

function QSparFieldRank:update(success, fail)
	app:getClient():top50RankRequest("SPAR_FIELD_TOTAL_STAR_RANK_TOP_50", remote.user.userId, function (data)
	if data.rankings == nil or data.rankings.top50 == nil then 
		self.super:update(fail)
		return 
	end

	self._list = nil
	self._list = clone(data.rankings.top50)
	for k, v in ipairs(self._list) do
		local starConfig = QStaticDatabase:sharedDatabase():getSparFieldLevelByStarCount(v.sparFieldTotalStarCount)
		if starConfig == nil then 
			starConfig = {}
		end
		v.sparLevel = starConfig.lev or 0
	end
	table.sort(self._list, function (x, y)
		return x.rank < y.rank
	end)
	self._myInfo = data.rankings.myself
	local starConfig = QStaticDatabase:sharedDatabase():getSparFieldLevelByStarCount(self._myInfo.sparFieldTotalStarCount)
	if starConfig == nil then 
		starConfig = {}
	end
	self._myInfo.sparLevel = starConfig.lev or 0

	self.super:update(success)
end, fail)
end

function QSparFieldRank:getRankItem()
	local item = QUIWidgetTeamRank.new()
	local style = QUIWidgetRankStyleApple.new()
	item:setStyle(style)
	return item
end

function QSparFieldRank:renderItem(item, index)
	local style = item:getStyle()
	local info = self._list[index]
	if style ~= nil and info ~= nil then
		style:setTFByIndex(1, "LV."..(info.level or "0"))
		style:setTFByIndex(2, (info.name or ""))
		style:setTFByIndex(3, "探索等级：")
		style:setVIP(info.vip or 0)
		style:setBadgeWithPassCount(style:getNodeByIndex(1), info.nightmareDungeonPassCount or 0)
		style:setAvatar(info.avatar)
		style:autoLayout()
		local sp1 = style:getChildByName("sp_1")
		local tf3 = style:getChildByName("tf_3")
		local tf4 = style:getChildByName("tf_4")

		tf4:setString(info.sparLevel.."  ("..info.sparFieldTotalStarCount.." ")
		tf4:setPositionX(tf3:getContentSize().width + tf3:getPositionX() )
		sp1:setPositionX(tf4:getContentSize().width + tf4:getPositionX() + 7)
		sp1:setPositionY(-31)
		tf4:setString(info.sparLevel.."  ("..info.sparFieldTotalStarCount.."     )")
	end
end

function QSparFieldRank:getSelfItem()
	local myInfo = self:getMyInfo()
	if myInfo == nil then
		return 
	end
	local item = QUIWidgetTeamMyRank.new()
	item:setInfo(myInfo)
	local style = QUIWidgetMyRankStyleApple.new()
	item:setStyle(style)

	style:setTFByIndex(1, "LV."..(myInfo.level or "0"))
	style:setTFByIndex(2, (myInfo.name or ""))
	style:setAvatar(myInfo.avatar)
	style:setBadgeWithPassCount(style:getNodeByIndex(1), myInfo.nightmareDungeonPassCount or 0)
	style:setTFByIndex(3, "探索等级：")
	style:autoLayout()
	local sp1 = style:getChildByName("sp_1")
	local tf3 = style:getChildByName("tf_3")
	local tf4 = style:getChildByName("tf_4")

	tf4:setString(myInfo.sparLevel.."  ("..myInfo.sparFieldTotalStarCount.." ")
	tf4:setPositionX(tf3:getContentSize().width + tf3:getPositionX() )
	sp1:setPositionX(tf4:getContentSize().width + tf4:getPositionX() + 7)
	tf4:setString(myInfo.sparLevel.."  ("..myInfo.sparFieldTotalStarCount.."     )")
	return item
end

return QSparFieldRank