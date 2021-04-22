local QUIWidgetRankBaseStyle = import(".QUIWidgetRankBaseStyle")
local QUIWidgetRankStyleBanana = class("QUIWidgetRankStyleBanana", QUIWidgetRankBaseStyle)

function QUIWidgetRankStyleBanana:ctor(options)
	local ccbFile = "ccb/Widget_ArenaRank_StyleBanana.ccbi"
	QUIWidgetRankStyleBanana.super.ctor(self, ccbFile, callBacks, options)
end

function QUIWidgetRankStyleBanana:autoLayout()
	local nodes = {}
	table.insert(nodes, self._ccbOwner.sp_soulTrial)
	table.insert(nodes, self._ccbOwner.tf_1)
	table.insert(nodes, self._ccbOwner.node_1)
	table.insert(nodes, self._ccbOwner.tf_2)
	table.insert(nodes, self._ccbOwner.tf_vip)
	q.autoLayerNode(nodes, "x", 5)

	local nodes2 = {}
	table.insert(nodes2, self._ccbOwner.tf_3)
	q.autoLayerNode(nodes2, "x", 5)
end

return QUIWidgetRankStyleBanana