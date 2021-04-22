local QUIWidgetHeroHead = import("..widgets.QUIWidgetHeroHead")
local QUIWidgetQuickChangeTeamHead = class("QUIWidgetQuickChangeTeamHead", QUIWidgetHeroHead)

local QBaseArrangementWithDataHandle = import("...arrangement.QBaseArrangementWithDataHandle")


function QUIWidgetQuickChangeTeamHead:ctor(options)
	QUIWidgetQuickChangeTeamHead.super.ctor(self, options)

	self.tfLock = CCLabelTTF:create("0级\n开启", global.font_default, 26)
	self.tfLock:setColor(ccc3(205,177,139))
	self.tfLock:setPositionY(-5)
	self.tfLock:setVisible(false)
	self.tfLock:setPositionY(0)
	-- self.tfLock:setAlignment(ui.TEXT_ALIGN_CENTER)
	self:addChild(self.tfLock)

	self:moveDownTeam(-5)
	self._fIsLock = false
	self:setContentVisible(true)

	self._fPosition = 0
end

function QUIWidgetQuickChangeTeamHead:setLockLevel(locKlevel)
	self.tfLock:setString(locKlevel.."级\n开启")
	self.tfLock:setVisible(true)
end

function QUIWidgetQuickChangeTeamHead:setFormationInfo(info)
	self._info = info

	self._fTrialNum = self._info.trialNum
	self._fTeamIdx = self._info.index
	self._fOType =  self._info.oType % 100
	self.tfLock:setVisible(false)
	if self._fPosition == 0 then
		self._fPosition =  self._info.pos
	end
	-- QPrintTable(info)
	if info.oType < QBaseArrangementWithDataHandle.ELEMENT_TYPE.EMPTY_ELE_TYPE then
		self:setHeroInfo(info)
	elseif  info.oType < QBaseArrangementWithDataHandle.ELEMENT_TYPE.LOCK_ELE_TYPE then
		self:setEmptyByInfo(info)
	else
		self:setLockByInfo(info)
	end

	local type_ = self._info.oType % 100

	if type_== QBaseArrangementWithDataHandle.ELEMENT_TYPE.HERO_ELE_TYPE then
		self:showTeamLabel()
	elseif  type_ == QBaseArrangementWithDataHandle.ELEMENT_TYPE.SOUL_ELE_TYPE then
		self:showTeamSoulLabel()
	elseif  type_ == QBaseArrangementWithDataHandle.ELEMENT_TYPE.GODARM_ELE_TYPE then
		self:showTeamGodarmLabel()
	end

end

function QUIWidgetQuickChangeTeamHead:setHeadIndex(idx)
	self._idx = idx
end


function QUIWidgetQuickChangeTeamHead:getHeadIndex()
	return self._idx
end

function QUIWidgetQuickChangeTeamHead:setLockByInfo(info)
	self.tfLock:setString("未解锁\n魂师")
	if self._fOType == QBaseArrangementWithDataHandle.ELEMENT_TYPE.SOUL_ELE_TYPE then
		self.tfLock:setString("魂灵\n未解锁")
	elseif  self._fOType == QBaseArrangementWithDataHandle.ELEMENT_TYPE.GODARM_ELE_TYPE  then
		local str = "神器\n未解锁"
		self.tfLock:setString(str)			
	elseif self._fOType == QBaseArrangementWithDataHandle.ELEMENT_TYPE.HERO_ELE_TYPE  then
		local str = "主力\n未解锁"
		if self._fTeamIdx == 2 then
			str = "援助\n未解锁"
		end
		self.tfLock:setString(str)
	end
	self.tfLock:setVisible(true)
	self:resetAll()
	self:setTeam(0)

	self._fIsLock = true
end

function QUIWidgetQuickChangeTeamHead:setEmptyByInfo(info)

	self.tfLock:setString("未上阵\n魂师")
	if self._fOType == QBaseArrangementWithDataHandle.ELEMENT_TYPE.SOUL_ELE_TYPE then
		self.tfLock:setString("魂灵\n未上阵")
	elseif  self._fOType == QBaseArrangementWithDataHandle.ELEMENT_TYPE.GODARM_ELE_TYPE then
		local str = "神器\n未上阵"
		self.tfLock:setString(str)			
	elseif self._fOType == QBaseArrangementWithDataHandle.ELEMENT_TYPE.HERO_ELE_TYPE then
		local str = "主力\n未上阵"
		if self._fTeamIdx == 2 then
			str = "援助\n未上阵"
		end
		self.tfLock:setString(str)
	end
	self.tfLock:setVisible(true)
	self:resetAll()
	self:setTeam(0)
end

function QUIWidgetQuickChangeTeamHead:setIsLock(b)
	self._isLock = b
	self.tfLock:setVisible(b)
end

function QUIWidgetQuickChangeTeamHead:getIsLock()
	return self._isLock == true
end

function QUIWidgetQuickChangeTeamHead:setTeamIndexAndPos(teamIndex, teamPos)
	self._teamIndex = teamIndex
	self._teamPos = teamPos
end

function QUIWidgetQuickChangeTeamHead:getTeamIndexAndPos()
	return self._teamIndex, self._teamPos
end

function QUIWidgetQuickChangeTeamHead:showTeamLabel()
	self:setTeam(self._info.index)
end

function QUIWidgetQuickChangeTeamHead:showTeamSoulLabel()
	self:setTeam(self._info.index, true)
end

function QUIWidgetQuickChangeTeamHead:showTeamGodarmLabel()
	self:setTeam(self._fPosition, false,false,true)
end
return QUIWidgetQuickChangeTeamHead