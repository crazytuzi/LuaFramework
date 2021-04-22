--
-- Kumo
-- 图鉴BBS, 我的排行信息
--

local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetHandBookRankMyRank = class("QUIWidgetHandBookRankMyRank", QUIWidget)

local QUIWidgetAvatar = import("..widgets.QUIWidgetAvatar")

function QUIWidgetHandBookRankMyRank:ctor(options)
	local ccbFile = "ccb/Widget_HandBook_MyRank.ccbi"
	local callBack = {
		{ccbCallbackName = "", callback = handler(self, self._)},
	}
	QUIWidgetHandBookRankMyRank.super.ctor(self, ccbFile, callBack, options)

	cc.GameObject.extend(self)
	self:addComponent("components.behavior.EventProtocol"):exportMethods()
end

function QUIWidgetHandBookRankMyRank:onEnter()
end

function QUIWidgetHandBookRankMyRank:onExit()
end

function QUIWidgetHandBookRankMyRank:setInfo(info)
	self._info = info

	if self._info.rank then
		self._ccbOwner.rank:setString(self._info.rank)
		self._ccbOwner.rank:setVisible(true)
		self._ccbOwner.noRank:setVisible(false)
	else
		self._ccbOwner.rank:setVisible(false)
		self._ccbOwner.noRank:setVisible(true)
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

	local contrastValue = (self._info.rank or 0) - (self._info.lastRank or 0)
	local arrowStr = "green"
	if contrastValue >= 0 then
		arrowStr = "red"
	end
	self._ccbOwner.sp_arrow_green:setVisible(arrowStr == "green")
	self._ccbOwner.sp_arrow_red:setVisible(arrowStr == "red")
	
	self._ccbOwner.tf_contrast_value:setString(math.abs(contrastValue))
	self:autoLayout(arrowStr)
end

function QUIWidgetHandBookRankMyRank:autoLayout(arrowStr)
	local nodes = {}
	table.insert(nodes, self._ccbOwner.sp_soulTrial)
	table.insert(nodes, self._ccbOwner.level)
	table.insert(nodes, self._ccbOwner.nickName)
	table.insert(nodes, self._ccbOwner.vip)
	q.autoLayerNode(nodes, "x", 0)
	local nodes2 = {}
	table.insert(nodes2, self._ccbOwner.tf_force_name)
	table.insert(nodes2, self._ccbOwner.tf_force_value)
	table.insert(nodes2, self._ccbOwner.tf_contrast_name)
	table.insert(nodes2, self._ccbOwner["sp_arrow_"..arrowStr])
	table.insert(nodes2, self._ccbOwner.tf_contrast_value)
	q.autoLayerNode(nodes2, "x", 5)
end

return QUIWidgetHandBookRankMyRank