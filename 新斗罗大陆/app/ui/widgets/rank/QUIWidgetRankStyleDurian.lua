local QUIWidgetRankBaseStyle = import(".QUIWidgetRankBaseStyle")
local QUIWidgetRankStyleDurian = class("QUIWidgetRankStyleDurian", QUIWidgetRankBaseStyle)

function QUIWidgetRankStyleDurian:ctor(options)
	local ccbFile = "ccb/Widget_ArenaRank_StyleDurian.ccbi"
	QUIWidgetRankStyleDurian.super.ctor(self, ccbFile, callBacks, options)

	self:setSpByIndex(1, false)
	self:setSpByIndex(2, false)
	self:setSpByIndex(3, false)
	self:setTFByIndex(8, "")
end

function QUIWidgetRankStyleDurian:autoLayout()
	local nodes = {}
	table.insert(nodes, self._ccbOwner.sp_soulTrial)
	table.insert(nodes, self._ccbOwner.tf_1)
	table.insert(nodes, self._ccbOwner.node_1)
	table.insert(nodes, self._ccbOwner.tf_2)
	table.insert(nodes, self._ccbOwner.tf_vip)
	q.autoLayerNode(nodes, "x", 5)

	local nodes2 = {}
	table.insert(nodes2, self._ccbOwner.tf_3)
	table.insert(nodes2, self._ccbOwner.tf_5)
	table.insert(nodes2, self._ccbOwner.tf_9)
	q.autoLayerNode(nodes2, "x", 5)

	local nodes3 = {}
	table.insert(nodes3, self._ccbOwner.tf_4)
	table.insert(nodes3, self._ccbOwner.tf_6)
	q.autoLayerNode(nodes3, "x", 5)
end

return QUIWidgetRankStyleDurian