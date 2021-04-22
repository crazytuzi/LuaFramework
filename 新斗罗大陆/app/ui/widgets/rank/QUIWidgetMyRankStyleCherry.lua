local QUIWidgetRankBaseStyle = import(".QUIWidgetRankBaseStyle")
local QUIWidgetMyRankStyleCherry = class("QUIWidgetMyRankStyleCherry", QUIWidgetRankBaseStyle)

function QUIWidgetMyRankStyleCherry:ctor(options)
	local ccbFile = "ccb/Widget_ArenaRank_MyStyleCherry.ccbi"
	QUIWidgetMyRankStyleCherry.super.ctor(self, ccbFile, callBacks, options)
end

function QUIWidgetMyRankStyleCherry:autoLayout()
	local nodes = {}
	table.insert(nodes, self._ccbOwner.sp_soulTrial)
	table.insert(nodes, self._ccbOwner.tf_1)
	table.insert(nodes, self._ccbOwner.node_1)
	table.insert(nodes, self._ccbOwner.tf_2)
	q.autoLayerNode(nodes, "x", 5)
	local nodes2 = {}
	table.insert(nodes2, self._ccbOwner.tf_3)
	table.insert(nodes2, self._ccbOwner.tf_4)
	table.insert(nodes2, self._ccbOwner.tf_5)
	table.insert(nodes2, self._ccbOwner.tf_6)
	table.insert(nodes2, self._ccbOwner.tf_7)
	q.autoLayerNode(nodes2, "x", 5)
end

return QUIWidgetMyRankStyleCherry