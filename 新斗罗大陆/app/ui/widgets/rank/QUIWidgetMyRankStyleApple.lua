local QUIWidgetRankBaseStyle = import(".QUIWidgetRankBaseStyle")
local QUIWidgetMyRankStyleApple = class("QUIWidgetMyRankStyleApple", QUIWidgetRankBaseStyle)

function QUIWidgetMyRankStyleApple:ctor(options)
	local ccbFile = "ccb/Widget_ArenaRank_MyStyleApple.ccbi"
	QUIWidgetMyRankStyleApple.super.ctor(self, ccbFile, callBacks, options)
end

function QUIWidgetMyRankStyleApple:autoLayout()
	local nodes = {}
	table.insert(nodes, self._ccbOwner.sp_soulTrial)
	table.insert(nodes, self._ccbOwner.tf_1)
	table.insert(nodes, self._ccbOwner.node_1)
	table.insert(nodes, self._ccbOwner.tf_2)
	q.autoLayerNode(nodes, "x", 5)
	
	local nodes2 = {}
	table.insert(nodes2, self._ccbOwner.tf_3)
	table.insert(nodes2, self._ccbOwner.sp_1)
	table.insert(nodes2, self._ccbOwner.tf_4)
	table.insert(nodes2, self._ccbOwner.tf_5)
	q.autoLayerNode(nodes2, "x", 0)
end

function QUIWidgetMyRankStyleApple:setHideStart(flag)
	self._ccbOwner.sp_1:setVisible(not flag)
end
return QUIWidgetMyRankStyleApple