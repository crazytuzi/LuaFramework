
local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetHeroProfessionalIcon = class("QUIWidgetHeroProfessionalIcon", QUIWidget)

local QStaticDatabase = import("...controllers.QStaticDatabase")

QUIWidgetHeroProfessionalIcon.Icon_Type1 = 1
QUIWidgetHeroProfessionalIcon.Icon_Type2 = 2
QUIWidgetHeroProfessionalIcon.Icon_Type3 = 3
QUIWidgetHeroProfessionalIcon.Icon_Type4 = 4


function QUIWidgetHeroProfessionalIcon:ctor(options)
	local ccbFile = "ccb/Widget_ProfessionalIcon.ccbi"
	QUIWidgetHeroProfessionalIcon.super.ctor(self,ccbFile,callBacks,options)
end

function QUIWidgetHeroProfessionalIcon:initGLLayer(glLayerIndex)
	self._glLayerIndex = glLayerIndex or 1
	self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.sp_health, self._glLayerIndex)
	self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.sp_t, self._glLayerIndex)
	self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.sp_dps_p, self._glLayerIndex)
	self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.sp_dps_m, self._glLayerIndex)
	return self._glLayerIndex
end

function QUIWidgetHeroProfessionalIcon:setHero(actorId, showName, scale)
	if showName == nil then showName = false end

	local characher = QStaticDatabase:sharedDatabase():getCharacterByID(actorId)
	self:hideAllIcon()
	if characher.func_icon == 't' then
		self._ccbOwner.node_hero_professional_t:setVisible(true)
		self._ccbOwner.sp_t_name:setVisible(showName)
	elseif characher.func_icon == 'dps_p' then
			self._ccbOwner.node_hero_professional_dps_p:setVisible(true)
			self._ccbOwner.sp_dps_p_name:setVisible(showName)
	elseif characher.func_icon == 'dps_m' then
			self._ccbOwner.node_hero_professional_dps_m:setVisible(true)
			self._ccbOwner.sp_dps_m_name:setVisible(showName)
	elseif characher.func_icon == 'health' then
		self._ccbOwner.node_hero_professional_health:setVisible(true)
		self._ccbOwner.sp_health_name:setVisible(showName)
	end

	if scale then
		self:setScale(scale)
	end
end


function QUIWidgetHeroProfessionalIcon:setType(icon_type, showName, scale)
	if showName == nil then showName = false end

	self:hideAllIcon()
	if icon_type == HERO_TALENT.TANK then
		self._ccbOwner.node_hero_professional_t:setVisible(true)
		self._ccbOwner.sp_t_name:setVisible(showName)
	elseif icon_type == HERO_TALENT.DPS_PHYSISC then
		self._ccbOwner.node_hero_professional_dps_p:setVisible(true)
		self._ccbOwner.sp_dps_p_name:setVisible(showName)
	elseif icon_type == HERO_TALENT.DPS_MAGIC then
		self._ccbOwner.node_hero_professional_dps_m:setVisible(true)
		self._ccbOwner.sp_dps_m_name:setVisible(showName)
	elseif icon_type == HERO_TALENT.HEALTH then
		self._ccbOwner.node_hero_professional_health:setVisible(true)
		self._ccbOwner.sp_health_name:setVisible(showName)
	end

	if scale then
		self:setScale(scale)
	end
end


function QUIWidgetHeroProfessionalIcon:hideAllIcon()
	self._ccbOwner.node_hero_professional_t:setVisible(false)
	self._ccbOwner.node_hero_professional_dps_p:setVisible(false)
	self._ccbOwner.node_hero_professional_health:setVisible(false)
	self._ccbOwner.node_hero_professional_dps_m:setVisible(false) 
	self._ccbOwner.node_hero_professional_health:setVisible(false)
end

function QUIWidgetHeroProfessionalIcon:getContentSize()
	return self._ccbOwner.sp_health:getContentSize()
end

return QUIWidgetHeroProfessionalIcon

