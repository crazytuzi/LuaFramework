local QUIWidgetBaseMyRank = import(".QUIWidgetBaseMyRank")
local QUIWidgetTeamMyRank = class("QUIWidgetTeamMyRank", QUIWidgetBaseMyRank)
local QUIWidgetMyRankStyleApple = import(".QUIWidgetMyRankStyleApple")

function QUIWidgetTeamMyRank:ctor(options)
	QUIWidgetTeamMyRank.super.ctor(self, options)
end

function QUIWidgetTeamMyRank:setInfo(info)
	if info == nil then
		return
	end
	self:setRank(info.rank, info.lastRank)
	-- if self._style == nil then
	-- 	self._style = QUIWidgetMyRankStyleApple.new()
	-- 	local size = self:getContentSize()
	-- 	self._style:setPosition(ccp(361, -30))
	-- 	self._ccbOwner.node_content:addChild(self._style)
	-- end
	-- self._style:setTFByIndex(1, "LV."..(info.level or "0"))
end

return QUIWidgetTeamMyRank