local QUIWidgetHeroHead = import("..widgets.QUIWidgetHeroHead")
local QUIWidgetStormQuickChangeTeamHead = class("QUIWidgetStormQuickChangeTeamHead", QUIWidgetHeroHead)

function QUIWidgetStormQuickChangeTeamHead:ctor(options)
	QUIWidgetStormQuickChangeTeamHead.super.ctor(self, options)

	self.tfLock = CCLabelTTF:create("0级\n开启", global.font_default, 26)
	self.tfLock:setColor(ccc3(205,177,139))
	self.tfLock:setPositionY(-5)
	self.tfLock:setVisible(false)
	self.tfLock:setPositionY(0)
	-- self.tfLock:setAlignment(ui.TEXT_ALIGN_CENTER)
	self:addChild(self.tfLock)

	self:moveDownTeam(-5)

	self:setContentVisible(true)
end

function QUIWidgetStormQuickChangeTeamHead:setLockLevel(locKlevel)
	self.tfLock:setString(locKlevel.."级\n开启")
	self.tfLock:setVisible(true)
end

function QUIWidgetStormQuickChangeTeamHead:setEmpty(stated, teamIndex, isSoul, isGodarm,isMount)
	if stated == nil then stated = true end

	if stated == false then
		self.tfLock:setVisible(false)
	else
		self.tfLock:setString("未上阵\n魂师")
		if isSoul then
			local str = "魂灵\n未上阵"
			self.tfLock:setString(str)
		elseif isGodarm then
			local str = "神器\n未上阵"
			self.tfLock:setString(str)			
		elseif isMount then
			local str = "暗器\n未上阵"
			self.tfLock:setString(str)	
		elseif teamIndex then
			local str = "主力\n未上阵"
			if teamIndex == 2 then
				str = "援助\n未上阵"
			end
			self.tfLock:setString(str)
		end
		self.tfLock:setVisible(true)
		self:resetAll()
		self:setTeam(0)
	end
end

function QUIWidgetStormQuickChangeTeamHead:setIsLock(b)
	self._isLock = b
	self.tfLock:setVisible(b)
end

function QUIWidgetStormQuickChangeTeamHead:getIsLock()
	return self._isLock == true
end

function QUIWidgetStormQuickChangeTeamHead:setTeamIndexAndPos(teamIndex, teamPos)
	self._teamIndex = teamIndex
	self._teamPos = teamPos
end

function QUIWidgetStormQuickChangeTeamHead:getTeamIndexAndPos()
	return self._teamIndex, self._teamPos
end

function QUIWidgetStormQuickChangeTeamHead:showTeamLabel()
	self:setTeam(self._teamIndex)
end

function QUIWidgetStormQuickChangeTeamHead:showTeamSoulLabel()
	self:setTeam(self._teamIndex, true)
end

function QUIWidgetStormQuickChangeTeamHead:showTeamGodarmLabel()
	self:setTeam(self._teamPos, false,false,true)
end
return QUIWidgetStormQuickChangeTeamHead