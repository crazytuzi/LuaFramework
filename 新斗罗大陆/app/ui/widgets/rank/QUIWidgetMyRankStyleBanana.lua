local QUIWidgetRankBaseStyle = import(".QUIWidgetRankBaseStyle")
local QUIWidgetMyRankStyleBanana = class("QUIWidgetMyRankStyleBanana", QUIWidgetRankBaseStyle)

function QUIWidgetMyRankStyleBanana:ctor(options)
	local ccbFile = "ccb/Widget_ArenaRank_MyStyleBanana.ccbi"
	QUIWidgetMyRankStyleBanana.super.ctor(self, ccbFile, callBacks, options)
end

function QUIWidgetMyRankStyleBanana:autoLayout()
	local nodes = {}
	table.insert(nodes, self._ccbOwner.sp_soulTrial)
	table.insert(nodes, self._ccbOwner.tf_1)
	table.insert(nodes, self._ccbOwner.node_1)
	table.insert(nodes, self._ccbOwner.tf_2)
	q.autoLayerNode(nodes, "x", 5)
	local nodes2 = {}
	table.insert(nodes2, self._ccbOwner.tf_3)
	q.autoLayerNode(nodes2, "x", 5)
end

return QUIWidgetMyRankStyleBanana