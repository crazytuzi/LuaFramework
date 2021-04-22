local QUIWidgetRankBaseStyle = import(".QUIWidgetRankBaseStyle")
local QUIWidgetRankStyleEmblic = class("QUIWidgetRankStyleEmblic", QUIWidgetRankBaseStyle)

function QUIWidgetRankStyleEmblic:ctor(options)
	local ccbFile = "ccb/Widget_ArenaRank_StyleEmblic.ccbi"
	QUIWidgetRankStyleEmblic.super.ctor(self, ccbFile, callBacks, options)

	self:setSpByIndex(2, false)
	self:setSpByIndex(3, false)
	self:setTFByIndex(8, "")
end

function QUIWidgetRankStyleEmblic:autoLayout()
	local nodes = {}
	table.insert(nodes, self._ccbOwner.tf_1)
	table.insert(nodes, self._ccbOwner.node_1)
	table.insert(nodes, self._ccbOwner.tf_2)
	q.autoLayerNode(nodes, "x", 5)
	local nodes2 = {}
	table.insert(nodes2, self._ccbOwner.tf_4)
	table.insert(nodes2, self._ccbOwner.tf_6)
	table.insert(nodes2, self._ccbOwner.tf_7)
	table.insert(nodes2, self._ccbOwner.tf_8)
	q.autoLayerNode(nodes2, "x", 5)
	
	local nodes3 = {}
	table.insert(nodes3, self._ccbOwner.tf_3)
	table.insert(nodes3, self._ccbOwner.tf_5)
	q.autoLayerNode(nodes3, "x", 5)

end

return QUIWidgetRankStyleEmblic