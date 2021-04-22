local QUIWidgetBaseRank = import(".QUIWidgetBaseRank")
local QUIWidgetTeamRank = class("QUIWidgetTeamRank", QUIWidgetBaseRank)

function QUIWidgetTeamRank:ctor(options)
	QUIWidgetTeamRank.super.ctor(self, options)
end

function QUIWidgetTeamRank:setInfo(info)
	self:setRank(info.rank)
end

return QUIWidgetTeamRank