local QUIWidgetRankBaseStyle = import(".QUIWidgetRankBaseStyle")
local QUIWidgetRankStyleApple = class("QUIWidgetRankStyleApple", QUIWidgetRankBaseStyle)

function QUIWidgetRankStyleApple:ctor(options)
	local ccbFile = "ccb/Widget_ArenaRank_StyleApple.ccbi"
	QUIWidgetRankStyleApple.super.ctor(self, ccbFile, callBacks, options)
end

function QUIWidgetRankStyleApple:autoLayout()
	local nodes = {}
	table.insert(nodes, self._ccbOwner.tf_3)
	table.insert(nodes, self._ccbOwner.sp_1)
	table.insert(nodes, self._ccbOwner.tf_4)
	table.insert(nodes, self._ccbOwner.tf_5)
	q.autoLayerNode(nodes, "x", 0)
	local nodes2 = {}
	table.insert(nodes2, self._ccbOwner.sp_soulTrial)
	table.insert(nodes2, self._ccbOwner.tf_1)
	table.insert(nodes2, self._ccbOwner.node_1)
	table.insert(nodes2, self._ccbOwner.tf_2)
	table.insert(nodes2, self._ccbOwner.tf_vip)
	q.autoLayerNode(nodes2, "x", 5)
end

return QUIWidgetRankStyleApple