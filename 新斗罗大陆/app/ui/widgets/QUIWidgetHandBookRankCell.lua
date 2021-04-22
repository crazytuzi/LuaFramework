--
-- Kumo
-- 图鉴BBS, 排行榜cell
--

local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetHandBookRankCell = class("QUIWidgetHandBookRankCell", QUIWidget)

local QUIWidgetAvatar = import("..widgets.QUIWidgetAvatar")

function QUIWidgetHandBookRankCell:ctor(options)
	local ccbFile = "ccb/Widget_HandBook_RankCell.ccbi"
	local callBack = {}
	QUIWidgetHandBookRankCell.super.ctor(self, ccbFile, callBack, options)

	cc.GameObject.extend(self)
	self:addComponent("components.behavior.EventProtocol"):exportMethods()
end

function QUIWidgetHandBookRankCell:onEnter()
end

function QUIWidgetHandBookRankCell:onExit()
end

function QUIWidgetHandBookRankCell:setInfo(info, index)
	self._info = info

	self._ccbOwner.first:setVisible(self._info.rank == 1)
	self._ccbOwner.second:setVisible(self._info.rank == 2)
	self._ccbOwner.third:setVisible(self._info.rank == 3)
	self._ccbOwner.other:setVisible(self._info.rank > 3)
	if self._info.rank > 3 then
		self._ccbOwner.other:setString(self._info.rank)
	end
	self._ccbOwner.node_headPicture:removeAllChildren()
	local avatar = QUIWidgetAvatar.new(self._info.avatar)
	avatar:setSilvesArenaPeak(self._info.championCount)
    self._ccbOwner.node_headPicture:addChild(avatar)

	local _, frame = remote.soulTrial:getSoulTrialTitleSpAndFrame(self._info.soulTrial)
	if frame then
		self._ccbOwner.sp_soulTrial:setDisplayFrame(frame)
		self._ccbOwner.sp_soulTrial:setVisible(true)
	else
		self._ccbOwner.sp_soulTrial:setVisible(false)
	end

	self._ccbOwner.level:setString("LV."..self._info.level)
	self._ccbOwner.nickName:setString(self._info.name)
	self._ccbOwner.vip:setString("VIP "..self._info.vip)

	local num,unit = q.convertLargerNumber(self._info.force)
	self._ccbOwner.tf_force_value:setString(num..(unit or ""))

	self:autoLayout()
end


function QUIWidgetHandBookRankCell:autoLayout()
	local nodes = {}
	table.insert(nodes, self._ccbOwner.sp_soulTrial)
	table.insert(nodes, self._ccbOwner.level)
	table.insert(nodes, self._ccbOwner.nickName)
	table.insert(nodes, self._ccbOwner.vip)
	q.autoLayerNode(nodes, "x", 0)
	-- local nodes2 = {}
	-- table.insert(nodes2, self._ccbOwner.sp_soulTrial)
	-- table.insert(nodes2, self._ccbOwner.tf_1)
	-- table.insert(nodes2, self._ccbOwner.node_1)
	-- table.insert(nodes2, self._ccbOwner.tf_2)
	-- table.insert(nodes2, self._ccbOwner.tf_vip)
	-- q.autoLayerNode(nodes2, "x", 5)
end

function QUIWidgetHandBookRankCell:getContentSize()
	return self._ccbOwner.cellsize:getContentSize()
end

return QUIWidgetHandBookRankCell