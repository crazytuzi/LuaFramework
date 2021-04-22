local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetHeroImageCard = class("QUIWidgetHeroImageCard", QUIWidget)
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QUIWidgetHeroQuality = import(".QUIWidgetHeroQuality")
local QUIWidgetHeroProfessionalIcon = import("..widgets.QUIWidgetHeroProfessionalIcon")

function QUIWidgetHeroImageCard:ctor(options)
	local ccbFile = "ccb/Widget_jz_tujian.ccbi"
	local callBack = {
	}
	QUIWidgetHeroImageCard.super.ctor(self, ccbFile, callBack, options)

	-- cc.GameObject.extend(self)
	-- self:addComponent("components.behavior.EventProtocol"):exportMethods()

	self._sabc = QUIWidgetHeroQuality.new()
	self._ccbOwner.pingzhi_icon:addChild(self._sabc)
end

function QUIWidgetHeroImageCard:setHeroInfo(actorId)
	self._actorId = actorId
	self._ccbOwner.node_boss_name:removeAllChildren()

    local characherConfig = QStaticDatabase:sharedDatabase():getCharacterByID(self._actorId)

    if characherConfig.card then
    	self._ccbOwner.sp_background:setTexture(CCTextureCache:sharedTextureCache():addImage(characherConfig.card))
        CalculateUIBgSize(self._ccbOwner.sp_background)
    end
    local aptitudeInfo = QStaticDatabase:sharedDatabase():getActorSABC(self._actorId)
    self._sabc:setQuality(aptitudeInfo.lower)
    if characherConfig.show_name then
    	self._ccbOwner.node_boss_name:addChild(CCSprite:create(characherConfig.show_name))
    end
    self._ccbOwner.tf_boss_type:setString(characherConfig.title or "")


    if self._professionalIcon == nil then 
        self._professionalIcon = QUIWidgetHeroProfessionalIcon.new()
        self._ccbOwner.profession_icon:addChild(self._professionalIcon)
    end
    self._professionalIcon:setHero(self._actorId)


    self._ccbOwner.tf_hero_desc:setString(characherConfig.role_definition or "")

    self:setSkillInfo()
end

function QUIWidgetHeroImageCard:setSkillInfo()

    local slotIds = {3,4,5,6,7}
    for i,v in ipairs(slotIds) do
        local skillId = QStaticDatabase:sharedDatabase():getSkillByActorAndSlot(self._actorId, v)
        self:setSkillBox(i, skillId)
    end

end

function QUIWidgetHeroImageCard:setSkillBox(index, skillId)
	local skillInfo = QStaticDatabase:sharedDatabase():getSkillByID(skillId)
    if self._ccbOwner["node_icon"..index] then
    	self._ccbOwner["node_icon"..index]:removeAllChildren()
    	self._ccbOwner["node_icon"..index]:addChild(CCSprite:create(skillInfo.icon))
    end
    if self._ccbOwner["tf_skill_name"..index] then
    	self._ccbOwner["tf_skill_name"..index]:setString(skillInfo.name)
    end
    if index == 1 then
        local skillDesc = q.getSkillMainDesc(skillInfo.description or "")
        skillDesc = string.gsub(skillDesc or "", "##%a+", "")
    	self._ccbOwner["tf_skill_desc"]:setString(skillDesc)
    end
end

return QUIWidgetHeroImageCard