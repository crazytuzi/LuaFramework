
local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetHeroIntroduce = class("QUIWidgetHeroIntroduce", QUIWidget)

local QStaticDatabase = import("...controllers.QStaticDatabase")
local QUIGestureRecognizer = import("..QUIGestureRecognizer")
local QUIViewController = import("..QUIViewController")

function QUIWidgetHeroIntroduce:ctor(options)
	local ccbFile = "ccb/Widget_HeroIntreduce.ccbi"
	local callBacks = {
        {ccbCallbackName = "onTriggerGenre", callback = handler(self, self._onTriggerGenre)},
        {ccbCallbackName = "onTriggerPropInfo", callback = handler(self, self._onTriggerPropInfo)},
        {ccbCallbackName = "onTriggerPropInfo2", callback = handler(self, self._onTriggerPropInfo2)},
    }
	QUIWidgetHeroIntroduce.super.ctor(self, ccbFile, callBacks, options)

    self._pageWidth = self._ccbOwner.node_mask:getContentSize().width
    self._pageHeight = self._ccbOwner.node_mask:getContentSize().height
    self._pageContent = self._ccbOwner.node_info
    self._orginalPosition = ccp(self._pageContent:getPosition())

    local layerColor = CCLayerColor:create(ccc4(0,0,0,150),self._pageWidth,self._pageHeight)
    local ccclippingNode = CCClippingNode:create()
    layerColor:setPositionX(self._ccbOwner.node_mask:getPositionX())
    layerColor:setPositionY(self._ccbOwner.node_mask:getPositionY())
    ccclippingNode:setStencil(layerColor)
    self._pageContent:removeFromParent()
    ccclippingNode:addChild(self._pageContent)

    self._ccbOwner.node_mask:getParent():addChild(ccclippingNode)

    self._ccbOwner.node_scroll:setVisible(false)
    self._ccbOwner.node_shadow_bottom:setVisible(true)
    self._ccbOwner.node_shadow_top:setVisible(false)

    self._totalHeight = 1255
    self._ccbOwner.node_hero_introduce:setPositionY(-1145)
    if ENABLE_PVP_FORCE then
        self._totalHeight = 1430
        self._ccbOwner.node_hero_introduce:setPositionY(-1350)
    end
end

function QUIWidgetHeroIntroduce:onEnter()
    self._touchLayer = QUIGestureRecognizer.new()
    self._touchLayer:attachToNode(self._ccbOwner.node_mask:getParent(),self._pageWidth, self._pageHeight, -self._pageWidth/2, 
    -self._pageHeight/2, handler(self, self.onTouchEvent))
    self._touchLayer:enable()
    self._touchLayer:addEventListener(QUIGestureRecognizer.EVENT_SLIDE_GESTURE, handler(self, self.onTouchEvent))
end

function QUIWidgetHeroIntroduce:onExit()
    if self._handler ~= nil then
        scheduler.unscheduleGlobal(self._handler)
        self._handler = nil
    end
    self._touchLayer:removeAllEventListeners()
    self._touchLayer:disable()
    self._touchLayer:detach()
end

-- 处理各种touch event
function QUIWidgetHeroIntroduce:onTouchEvent(event)
    if event == nil or event.name == nil then
        return
    end
    if event.name == QUIGestureRecognizer.EVENT_SLIDE_GESTURE then
        -- self._page:endMove(event.distance.y)
    elseif event.name == "began" then
        self._startY = event.y
        self._pageY = self._pageContent:getPositionY()
    elseif event.name == "moved" then
        local offsetY = self._pageY + event.y - self._startY
        if offsetY < self._orginalPosition.y then
            self._ccbOwner.node_shadow_bottom:setVisible(true)
            self._ccbOwner.node_shadow_top:setVisible(false)
            offsetY = self._orginalPosition.y
        elseif offsetY > (self._totalHeight - self._pageHeight + self._orginalPosition.y) then
            offsetY = (self._totalHeight - self._pageHeight + self._orginalPosition.y)
            self._ccbOwner.node_shadow_bottom:setVisible(false)
            self._ccbOwner.node_shadow_top:setVisible(true)
        else
        self._ccbOwner.node_shadow_bottom:setVisible(true)
        self._ccbOwner.node_shadow_top:setVisible(true)
        end
        self._pageContent:setPositionY(offsetY)
    elseif event.name == "ended" then
    end
end

function QUIWidgetHeroIntroduce:setHero(hero)
    self._totalHeight = 1255
    self._ccbOwner.node_hero_introduce:setPositionY(-1155)
    if ENABLE_PVP_FORCE then
        self._totalHeight = 1430
        self._ccbOwner.node_hero_introduce:setPositionY(-1350)
    end
    self._heroID = hero.actorId
    local actor = remote.herosUtil:createSelfHeroByActorId(self._heroID)
    local heroModel = actor:getActorPropInfo()

    self:setText("tf_attack_grow", string.format("%0.2f", heroModel:getAttackGrow()))--math.floor(heroProp.attack_grow))
    self:setText("tf_hp_grow", string.format("%0.2f", heroModel:getHpGrow()))--math.floor(heroProp.hp_grow))
    self:setText("tf_magic_grow", string.format("%0.1f", heroModel:getArmorMagicGrow()))
    self:setText("tf_physical_grow", string.format("%0.1f", heroModel:getArmorPhysicalGrow()))
    self:setText("tf_hp", math.floor(heroModel:getMaxHp())) 
    self:setText("tf_attack", math.floor(heroModel:getMaxAttack()))
    self:setText("tf_physicalresist", math.floor(heroModel:getMaxArmorPhysical()))
    self:setText("tf_magicresist", math.floor(heroModel:getMaxArmorMagic()))
    self:setText("tf_physical_penetration", math.floor(heroModel:getMaxPhysicalPenetration()))
    self:setText("tf_magic_penetration", math.floor(heroModel:getMaxMagicPenetration())) 
    self:setText("tf_hit", string.format("%0.1f", heroModel:getMaxHit()))
    self:setText("tf_crit", string.format("%0.1f", heroModel:getMaxCrit()))
    self:setText("tf_cri_reduce", string.format("%0.1f", heroModel:getMaxCriReduce()))
    self:setText("tf_dodge", string.format("%0.1f", heroModel:getMaxDodge()))
    self:setText("tf_block", string.format("%0.1f", heroModel:getMaxBlock()))
    self:setText("tf_haste", string.format("%0.1f", heroModel:getMaxHaste()))
    self:setText("tf_physical_damage_percent_attack", string.format("%0.1f%%", heroModel:getPhysicalDamagePercentAttack() * 100))
    self:setText("tf_physical_damage_percent_beattack_reduce", string.format("%0.1f%%", heroModel:getPhysicalDamagePercentBeattackReduceTotal() * 100))
    self:setText("tf_magic_damage_percent_attack", string.format("%0.1f%%", heroModel:getMagicDamagePercentAttack() * 100))
    self:setText("tf_magic_damage_percent_beattack_reduce", string.format("%0.1f%%", heroModel:getMagicDamagePercentBeattackReduceTotal() * 100))

    if ENABLE_PVP_FORCE then -- 这里pvp只显示个人的，目前只有体技有
        --pvp梳理后 显示所以的pvp属性 下面先注释
        -- local glyphProp = heroModel:getGlyphProp()
        -- self:setText("tf_pvp_physical_damage_percent_attack", string.format("%0.1f%%", (glyphProp.pvp_physical_damage_percent_attack or 0) * 100))
        -- self:setText("tf_pvp_physical_damage_percent_beattack_reduce", string.format("%0.1f%%", (glyphProp.pvp_physical_damage_percent_beattack_reduce or 0) * 100))  
        -- self:setText("tf_pvp_magic_damage_percent_attack", string.format("%0.1f%%", (glyphProp.pvp_magic_damage_percent_attack or 0) * 100))  
        -- self:setText("tf_pvp_magic_damage_percent_beattack_reduce", string.format("%0.1f%%", (glyphProp.pvp_magic_damage_percent_beattack_reduce or 0) * 100)) 

        self:setText("tf_pvp_physical_damage_percent_attack", string.format("%0.1f%%", ((heroModel:getPVPPhysicalAttackPercent()or 0)  - (heroModel:getArchaeologyPVPPhysicalAttackPercent()or 0)) * 100))
        self:setText("tf_pvp_physical_damage_percent_beattack_reduce", string.format("%0.1f%%", ((heroModel:getPVPPhysicalReducePercent() or 0) - (heroModel:getArchaeologyPVPPhysicalReducePercent() or 0)) * 100))  
        self:setText("tf_pvp_magic_damage_percent_attack", string.format("%0.1f%%", ((heroModel:getPVPMagicAttackPercent() or 0) - (heroModel:getArchaeologyPVPMagicAttackPercent() or 0)) * 100))  
        self:setText("tf_pvp_magic_damage_percent_beattack_reduce", string.format("%0.1f%%", ((heroModel:getPVPMagicReducePercent() or 0) - (heroModel:getArchaeologyPVPMagicReducePercent() or 0)) * 100)) 
        
    else
        self._ccbOwner.node_pvp_prop:setVisible(false)
    end

    -- 新增破擊、治療、受療
    self:setText("tf_wreck", math.floor(heroModel:getMaxWreck()))
    self:setText("tf_treat", string.format("%0.1f%%", heroModel:getMagicTreatPercentAttack() * 100))
    self:setText("tf_be_treat", string.format("%0.1f%%", heroModel:getMagicTreatPercentBeattackTotal() * 100))
    self:setText("tf_soul_damage_percent_attack", string.format("%0.1f%%", heroModel:getSoulDamageAttackTotal() * 100))
    self:setText("tf_soul_damage_percent_beattack_reduce", string.format("%0.1f%%", heroModel:getSoulDamageBeattackReduceTotal() * 100))
    --[[
        by Kumo
        显示流派信息
        Fri Mar  4 19:23:11 2016
    ]]
    local genreText = self:_getHeroGenre( hero.actorId )
    if genreText then
        self._ccbOwner.tf_genre:setString(genreText)
    else
        self._ccbOwner.tf_genre:setString("无流派")
    end

    local heroDisplay = QStaticDatabase:sharedDatabase():getCharacterByID(hero.actorId)
    if nil ~= heroDisplay then  
        self:setText("tf_hero_introduce", tostring(heroDisplay.brief or "该魂师暂时没有介绍。"))
        self:setText("tf_hero_desc", tostring(heroDisplay.role_definition or ""))
    end

    self._totalHeight = self._totalHeight + self._ccbOwner.tf_hero_desc:getContentSize().height

    -- 这里改成流派显示了。by Kumo Fri Mar  4 19:36:30 2016
    -- self._ccbOwner.tf_genre:setString(heroInfo.talent_name)
end

function QUIWidgetHeroIntroduce:setText(name, text)
	if self._ccbOwner[name] then
		self._ccbOwner[name]:setString(text)
	end
end

-- function QUIWidgetHeroIntroduce:setSkillIcon(respath)
	-- if respath then
	-- 	local texture = CCTextureCache:sharedTextureCache():addImage(respath)
	-- 	self._ccbOwner.node_skill:setTexture(texture)
	--     local size = texture:getContentSize()
	--     local rect = CCRectMake(0, 0, size.width, size.height)
	--     self._ccbOwner.node_skill:setTextureRect(rect)
	-- end
-- end

function QUIWidgetHeroIntroduce:_getHeroGenre( actorId )
    local text, index = QStaticDatabase:sharedDatabase():getHeroGenreById(actorId)
    self._genreIndex = index
    return text
end

function QUIWidgetHeroIntroduce:_onTriggerGenre(event)
    if q.buttonEventShadow(event, self._ccbOwner.btn_genre) == false then return end
    app.sound:playSound("common_small")
    app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogHeroDetailInfoNew", 
        options = {actorId = self._heroID}}, {isPopCurrentDialog = false})
end

function QUIWidgetHeroIntroduce:_onTriggerPropInfo(event)
    if q.buttonEventShadow(event, self._ccbOwner.btn_prop) == false then return end
    app.sound:playSound("common_small")
    app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogHeroPropHelp",
        options = {helpType = "quality_help"}})
end

function QUIWidgetHeroIntroduce:_onTriggerPropInfo2(event)
    if q.buttonEventShadow(event, self._ccbOwner.btn_prop2) == false then return end
    app.sound:playSound("common_small")
    app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogHeroPropHelp",
        options = {helpType = "help_advanced_properties"}})
end

return QUIWidgetHeroIntroduce