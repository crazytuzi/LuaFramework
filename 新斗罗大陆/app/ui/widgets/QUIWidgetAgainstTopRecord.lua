--
-- zxs
-- 统一战报
--
local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetAgainstTopRecord = class("QUIWidgetAgainstTopRecord", QUIWidget)
local QUIWidgetAvatar = import("..widgets.QUIWidgetAvatar")
local QUIWidgetFloorIcon = import("..widgets.QUIWidgetFloorIcon")

QUIWidgetAgainstTopRecord.EVENT_CLICK_TOP_RECORDE = "EVENT_CLICK_TOP_RECORDE"

function QUIWidgetAgainstTopRecord:ctor(options)
	local ccbFile = "ccb/Widget_TopRecord.ccbi"
	local callBacks = {
		{ccbCallbackName = "onTriggerClick", callback = handler(self, QUIWidgetAgainstTopRecord._onTriggerClick)},
	}
	QUIWidgetAgainstTopRecord.super.ctor(self, ccbFile, callBacks, options)

	cc.GameObject.extend(self)
	self:addComponent("components.behavior.EventProtocol"):exportMethods()
end

function QUIWidgetAgainstTopRecord:initGLLayer(glLayerIndex)
	self._glLayerIndex = glLayerIndex or 1

	return self._glLayerIndex
end

function QUIWidgetAgainstTopRecord:resetAll()
	self._ccbOwner.node_new:setVisible(false)
	self._ccbOwner.node_floor1:removeAllChildren()
	self._ccbOwner.node_floor2:removeAllChildren()
end

function QUIWidgetAgainstTopRecord:setInfo(info, reportType)
	self:resetAll()
	if not info then
		return
	end
	self._info = info
	self._param = info.param
	local paramTbl = string.split(info.param, ";")
	local userTbl1 = string.split(paramTbl[1], ":")
	local userTbl2 = string.split(paramTbl[2], ":")

	if not self._head1 then
		self._head1 = QUIWidgetAvatar.new()
		self._ccbOwner.node_head1:addChild(self._head1)
	end
	self._head1:setInfo(info.fighter1.avatar)
	self._head1:setSilvesArenaPeak(info.fighter1.championCount)
	self._ccbOwner.tf_name1:setString(info.fighter1.name or "")
	self._ccbOwner.tf_rank1:setString(userTbl1[1] or 1)

	if not self._head2 then
		self._head2 = QUIWidgetAvatar.new()
		self._ccbOwner.node_head2:addChild(self._head2)
	end
	self._head2:setInfo(info.fighter2.avatar)
	self._head2:setSilvesArenaPeak(info.fighter2.championCount)
	self._ccbOwner.tf_name2:setString(info.fighter2.name or "")
	self._ccbOwner.tf_rank2:setString(userTbl2[1] or 1)

	if (userTbl1[2] and userTbl2[2]) or reportType == REPORT_TYPE.FIGHT_CLUB then
		local iconType = "tower"
		local floor1 = tonumber(userTbl1[2])
		local floor2 = tonumber(userTbl2[2])
		if reportType == REPORT_TYPE.FIGHT_CLUB then
			iconType = "fightClub"
			floor1 = 6
			floor2 = 6
		end
		
		local floorIcon1 = QUIWidgetFloorIcon.new()
		floorIcon1:setInfo(floor1, iconType)
		floorIcon1:setScale(0.6)
		self._ccbOwner.node_floor1:addChild(floorIcon1)

		local floorIcon2 = QUIWidgetFloorIcon.new()
		floorIcon2:setInfo(floor2, iconType)
		floorIcon2:setScale(0.6)
		self._ccbOwner.node_floor2:addChild(floorIcon2)
	end

	local winNum = 0
	local loseNum = 0
	for i, v in pairs(info.scoreList or {}) do
		if v == true then
			winNum = winNum + 1
		else
			loseNum = loseNum + 1
		end
	end
    self._ccbOwner.sp_score1:setDisplayFrame(QSpriteFrameByKey("zhanbao_score", winNum+1))
    self._ccbOwner.sp_score2:setDisplayFrame(QSpriteFrameByKey("zhanbao_score", loseNum+1))

	self._ccbOwner.node_new:setVisible(info.isNew)
end

function QUIWidgetAgainstTopRecord:getContentSize()
	local size = self._ccbOwner.background:getContentSize()
	return CCSize(size.width, size.height+6)
end

function QUIWidgetAgainstTopRecord:_onTriggerClick()
	self:dispatchEvent({name = QUIWidgetAgainstTopRecord.EVENT_CLICK_TOP_RECORDE, info = self._info})
end

return QUIWidgetAgainstTopRecord