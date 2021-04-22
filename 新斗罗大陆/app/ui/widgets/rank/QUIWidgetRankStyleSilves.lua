-- dsl
-- 2020-06-02

local QUIWidgetRankBaseStyle = import(".QUIWidgetRankBaseStyle")
local QUIWidgetRankStyleSilves = class("QUIWidgetRankStyleSilves", QUIWidgetRankBaseStyle)

function QUIWidgetRankStyleSilves:ctor(options)
	local ccbFile = "ccb/Widget_ArenaRank_SilvesArena.ccbi"
	QUIWidgetRankStyleSilves.super.ctor(self, ccbFile, callBacks, options)

	-- self:setSpByIndex(1, false)
	-- self:setSpByIndex(2, false)
	-- self:setSpByIndex(3, false)
	-- self:setTFByIndex(8, "")
end

function QUIWidgetRankStyleSilves:autoLayout()
	local nodes = {}
	table.insert(nodes, self._ccbOwner.tf_1)
	q.autoLayerNode(nodes, "x", 5)

	local nodes2 = {}
	table.insert(nodes2, self._ccbOwner.tf_2)
	table.insert(nodes2, self._ccbOwner.tf_3)
	q.autoLayerNode(nodes2, "x", 5)

	local nodes3 = {}
	table.insert(nodes3, self._ccbOwner.tf_4)
	table.insert(nodes3, self._ccbOwner.tf_5)
	q.autoLayerNode(nodes3, "x", 5)
end

return QUIWidgetRankStyleSilves