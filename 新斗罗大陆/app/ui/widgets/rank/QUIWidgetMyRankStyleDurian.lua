local QUIWidgetRankBaseStyle = import(".QUIWidgetRankBaseStyle")
local QUIWidgetMyRankStyleDurian = class("QUIWidgetMyRankStyleDurian", QUIWidgetRankBaseStyle)
local QStaticDatabase = import("....controllers.QStaticDatabase")
local QUIWidgetFloorIcon = import("...widgets.QUIWidgetFloorIcon")

function QUIWidgetMyRankStyleDurian:ctor(options)
	local ccbFile = "ccb/Widget_ArenaRank_MyStyleDurian.ccbi"
	QUIWidgetMyRankStyleDurian.super.ctor(self, ccbFile, callBacks, options)
end

function QUIWidgetMyRankStyleDurian:autoLayout()
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
	q.autoLayerNode(nodes2, "x", 5)
end

function QUIWidgetMyRankStyleDurian:setFloor(floor, scale, iconType)
	self._ccbOwner.node_floor:removeAllChildren()
	local floorIcon = QUIWidgetFloorIcon.new()
	floorIcon:setScale(scale or 1)
	floorIcon:setInfo(floor, iconType)
	self._ccbOwner.node_floor:addChild(floorIcon)
end


return QUIWidgetMyRankStyleDurian