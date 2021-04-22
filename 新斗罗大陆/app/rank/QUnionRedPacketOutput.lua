--
-- Author: Kumo
-- Date: 2015-01-15 
-- 宗门红包发包排行版
-- 

local QBaseRank = import(".QBaseRank")
local QUnionRedPacketOutput = class("QUnionRedPacketOutput", QBaseRank)
local QUIWidgetTeamRank = import("..ui.widgets.rank.QUIWidgetTeamRank")
local QUIWidgetTeamMyRank = import("..ui.widgets.rank.QUIWidgetTeamMyRank")
local QUIWidgetRankStyleApple = import("..ui.widgets.rank.QUIWidgetRankStyleApple")
local QUIWidgetMyRankStyleApple = import("..ui.widgets.rank.QUIWidgetMyRankStyleApple")
local QStaticDatabase = import("..controllers.QStaticDatabase")

function QUnionRedPacketOutput:ctor(options)
	QUnionRedPacketOutput.super.ctor(self, options)
end

function QUnionRedPacketOutput:update(success, fail)
	app:getClient():top50RankRequest("SEND_REDPACKET_NUM_TOP_50", remote.user.userId, function (data)
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

function QUnionRedPacketOutput:getRankItem()
	local item = QUIWidgetTeamRank.new()
	local style = QUIWidgetRankStyleApple.new()
	item:setStyle(style)
	return item
end

function QUnionRedPacketOutput:renderItem(item, index)
	local style = item:getStyle()
	local info = self._list[index]
	if style ~= nil and info ~= nil then
		style:setSoulTrial(info.soulTrial)
		style:setTFByIndex(1, "LV."..(info.level or "0"))
		style:setTFByIndex(2, (info.name or ""))
		style:setTFByIndex(3, "发放钻石：")
		style:setTFByIndex(4, (info.weekSendRedpacketNum or ""))
		style:setVIP(info.vip or 0)
		style:setAvatar(info.avatar)
		local path = remote.items:getWalletByType("token").alphaIcon
		local spf = QSpriteFrameByPath(path)
		style:setSpSpriteFrameByIndex(1, spf, 0.5)
		-- style:setSpByIndex(1, false)
		style:setBadgeWithPassCount(style:getNodeByIndex(1), info.nightmareDungeonPassCount or 0)
		-- local famousPersonValue = db:getFamousPersonValueByRank("mrt_dj", index) or 0
		-- style:setTFByIndex(5, "  名人堂积分："..famousPersonValue)
		style:setTFByIndex(5, "")

		style:autoLayout()
	end
end

function QUnionRedPacketOutput:registerClick(listView, index)
	listView:registerClickHandler(index,"self",function ()
		return true
	end, nil, handler(self, self.clickHandler))
end

function QUnionRedPacketOutput:clickHandler( x, y, touchNodeNode, list)
	local info = self._list[list:getCurTouchIndex()]
	if info ~= nil then
		self:queryFighterWithRank(info.userId, {})
	end
end

function QUnionRedPacketOutput:getSelfItem()
	local myInfo = self:getMyInfo()
	if myInfo == nil then
		return 
	end
	local item = QUIWidgetTeamMyRank.new()
	item:setInfo(myInfo)
	local style = QUIWidgetMyRankStyleApple.new()
	item:setStyle(style)

	style:setSoulTrial(myInfo.soulTrial)
	style:setTFByIndex(1, "LV."..(myInfo.level or "0"))
	style:setTFByIndex(2, (myInfo.name or ""))
	style:setAvatar(myInfo.avatar)
	style:setBadgeWithPassCount(style:getNodeByIndex(1), myInfo.nightmareDungeonPassCount or 0)
	style:setTFByIndex(3, "发放钻石：")
	local path = remote.items:getWalletByType("token").alphaIcon
	local spf = QSpriteFrameByPath(path)
	style:setSpSpriteFrameByIndex(1, spf, 0.5)
	-- style:setSpByIndex(1, false)
	style:setTFByIndex(4, (myInfo.weekSendRedpacketNum or ""))
	-- local famousPersonValue = db:getFamousPersonValueByRank("mrt_dj", myInfo.rank) or 0
	-- style:setTFByIndex(5, "  名人堂积分："..famousPersonValue)
	style:setTFByIndex(5, "")

	style:autoLayout()
	return item
end



return QUnionRedPacketOutput
