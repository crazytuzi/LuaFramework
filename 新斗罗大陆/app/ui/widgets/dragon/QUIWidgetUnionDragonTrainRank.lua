local QUIWidget = import("..QUIWidget")
local QUIWidgetUnionDragonTrainRank = class("QUIWidgetUnionDragonTrainRank", QUIWidget)
local QUIWidgetRankStyleCherry = import("..rank.QUIWidgetRankStyleCherry")

function QUIWidgetUnionDragonTrainRank:ctor(options)
	local ccbFile = "ccb/Widget_ArenaRank_Base.ccbi"
	QUIWidgetUnionDragonTrainRank.super.ctor(self, ccbFile, callBacks, options)

	local style = QUIWidgetRankStyleCherry.new()
    -- style:setPosition(ccp(361, -30))
    self:setStyle(style)
end

function QUIWidgetUnionDragonTrainRank:setInfo(info, index)
	self:setRank(index)

	local style = self:getStyle()
	if style ~= nil and info ~= nil then
		style:setTFByIndex(1, "LV."..(info.level or "0"))
		style:setTFByIndex(2, (info.name or ""))
		style:setAvatar(info.avatar)
		style:setVIP(info.vip)
		style:setTFByIndex(3, "累计贡献武魂经验：")
		style:setTFByIndex(5, info.dragonContribution or 0)
		style:setTFByIndex(4, "")
		style:setTFByIndex(6, "")
		style:autoLayout()
	end
end

function QUIWidgetUnionDragonTrainRank:setStyle(style)
	if self._style ~= nil then
		self._style:removeFromParent()
		self._style = nil
	end
	self._style = style
	self._ccbOwner.node_content:addChild(self._style)
end

function QUIWidgetUnionDragonTrainRank:getStyle()
	return self._style
end

function QUIWidgetUnionDragonTrainRank:setRank(rank)
	self._ccbOwner.sp_first:setVisible(rank == 1)
	self._ccbOwner.sp_second:setVisible(rank == 2)
	self._ccbOwner.sp_third:setVisible(rank == 3)
	self._ccbOwner.tf_other:setVisible(rank > 3)
	if rank > 3 then
		self._ccbOwner.tf_other:setString(rank)
	end
end

function QUIWidgetUnionDragonTrainRank:getContentSize()
	return self._ccbOwner.normal_banner:getContentSize()
end
return QUIWidgetUnionDragonTrainRank