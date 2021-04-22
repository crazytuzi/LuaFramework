

local QUIWidget = import("..QUIWidget")
local QUIWidgetSkeletonActor = class("QUIWidgetSkeletonActor", QUIWidget)

local QStaticDatabase = import("....controllers.QStaticDatabase")
local QSkeletonViewController = import("....controllers.QSkeletonViewController")
local QUIWidgetSkeletonEffect = import(".QUIWidgetSkeletonEffect")

QUIWidgetSkeletonActor.ANIMATION_FINISHED_EVENT = "ANIMATION_FINISHED_EVENT"

function QUIWidgetSkeletonActor:ctor(actorId, options)
	-- add 
	cc.GameObject.extend(self)
	self:addComponent("components.behavior.EventProtocol"):exportMethods()

	QUIWidgetSkeletonActor.super.ctor(self, nil, nil, options)

	self._actorId = actorId
    local staticDatabase = QStaticDatabase:sharedDatabase() 
    local character = staticDatabase:getCharacterByID(self._actorId)
	self._actorDisplay = staticDatabase:getCharacterDisplayByID(character.display_id)

    self._actorFile = options.actorFile
    self._actorScale = options.actorScale
    if self._actorDisplay.information_action or (options ~= nil and options.isUI == true) then
	    self._actorView = QSkeletonViewController:sharedSkeletonViewController():createUISkeletonActorWithFile(self._actorFile, false)
    else
        self._actorView = QSkeletonViewController:sharedSkeletonViewController():createSkeletonActorWithFile(self._actorFile, character.npc_type == NPC_TYPE.HERO, false)
    end
	self._actorView:setSkeletonScaleX(self._actorScale)
	self._actorView:setSkeletonScaleY(self._actorScale)

    if self._actorDisplay.weapon_file ~= nil then
        local parentBone = self._actorView:getParentBoneName(DUMMY.WEAPON)
        self._actorView:replaceSlotWithFile(self._actorDisplay.weapon_file, parentBone, ROOT_BONE, EFFECT_ANIMATION)
    end

    local replaceBone = self._actorDisplay.replace_bone
    local replaceFile = self._actorDisplay.replace_file
    if replaceBone ~= nil and replaceFile ~= nil then
        self._actorView:replaceSlotWithFile(replaceFile, replaceBone, ROOT_BONE, EFFECT_ANIMATION)
    end
    
	self:addChild(self._actorView)

    self._enchantEffects = {}
    self._enchantDummies = {}
    self._attachEffectList = {}
    self:_processAdditionalEffects(options)
	self:playAnimation(ANIMATION.STAND)
end

function QUIWidgetSkeletonActor:onCleanup()
    for _, effect in ipairs(self._enchantEffects or {}) do
        effect:onCleanup()
        effect:release()
    end
    self._enchantEffects = {}

    for _, effect in ipairs(self._attachEffectList) do
        effect:onCleanup()
        effect:release()
    end
    self._attachEffectList = {}

    QSkeletonViewController:sharedSkeletonViewController():removeSkeletonActor(self._actorView)
    self._actorView = nil
end

function QUIWidgetSkeletonActor:onEnter()
	self._actorView:connectAnimationEventSignal(handler(self, self._onActorAnimationEvent))
end

function QUIWidgetSkeletonActor:onExit()
	self._actorView:disconnectAnimationEventSignal()
end

function QUIWidgetSkeletonActor:getSkeletonView()
    return self._actorView
end

function QUIWidgetSkeletonActor:_onActorAnimationEvent(eventType, trackIndex, animationName, loopCount)
    if eventType == SP_ANIMATION_END or eventType == SP_ANIMATION_COMPLETE then
    	self:dispatchEvent({name = self.ANIMATION_FINISHED_EVENT, trackIndex = trackIndex, animationName = animationName, loopCount = loopCount, eventType = eventType})
    end

    if eventType == SP_ANIMATION_END or eventType == SP_ANIMATION_COMPLETE then
        
    elseif eventType == SP_ANIMATION_START then
        self._currentAnimation = animationName
    end
end

function QUIWidgetSkeletonActor:resetActor()
	self._actorView:resetActorWithAnimation(ANIMATION.STAND, true)
end

function QUIWidgetSkeletonActor:playAnimation(animation, isLoop)
	if animation == nil then
		return
	end

    if isLoop == nil then
        isLoop = false
    end

	if isLoop == false and (animation == ANIMATION.STAND or animation == ANIMATION.WALK) then
		isLoop = true
	end
	self._actorView:playAnimation(animation, isLoop)
	self._currentAnimation = animation
end

function QUIWidgetSkeletonActor:attachEffect(effectID, frontEffect, backEffect)
	if effectID == nil then
		return false
	end

	if frontEffect == nil and backEffect == nil then
		return false
	end

	local dummy = QStaticDatabase.sharedDatabase():getEffectDummyByID(effectID)
    local isFlipWithActor = QStaticDatabase.sharedDatabase():getEffectIsFlipWithActorByID(effectID)
    if frontEffect ~= nil then
    	self:_attachEffectToDummy(dummy, frontEffect, false, isFlipWithActor, effectID)
    end
    if backEffect ~= nil then
    	self:_attachEffectToDummy(dummy, backEffect, true, isFlipWithActor, effectID)
    end

    return true
end

function QUIWidgetSkeletonActor:_attachEffectToDummy(dummy, effectView, isBackSide, isFlipWithActor, effectID)
    if effectView == nil then
        return
    end

    dummy = dummy or DUMMY.BOTTOM
    if dummy == DUMMY.BOTTOM or dummy == DUMMY.TOP or dummy == DUMMY.CENTER then
        self._actorView:attachNodeToBone(nil, effectView, isBackSide, isFlipWithActor)
        local actorScale = self._actorScale
        if effectView:getSkeletonView() ~= nil then
            local skeletonPositionX, skeletonPositionY = effectView:getSkeletonView():getPosition()
            if dummy == DUMMY.TOP then
                if isFlipWithActor == true then
                    skeletonPositionY = skeletonPositionY + self._actorDisplay.selected_rect_height
                else
                    skeletonPositionY = skeletonPositionY + self._actorDisplay.selected_rect_height * actorScale
                end
            elseif dummy == DUMMY.CENTER then
                if isFlipWithActor == true then
                    skeletonPositionY = skeletonPositionY + self._actorDisplay.selected_rect_height * 0.5
                else
                    skeletonPositionY = skeletonPositionY + self._actorDisplay.selected_rect_height * 0.5 * actorScale
                end
            end
            effectView:getSkeletonView():setPosition(skeletonPositionX, skeletonPositionY)
        end
    else
        if self._actorView:isBoneExist(dummy) == false then
            assert(false, "Bone node not found: <" .. dummy .. "> does not exist in the bone provided by <" .. self._actorDisplay.id .. "> (character_display) provides. The effect is <" .. effectView._effectID .. ".".. effectView._frontAndBack .. ">")
        end
        local config = QStaticDatabase.sharedDatabase():getEffectConfigByID(effectID)
        if config.replace then
            if self._actorView.replaceSlotWithSkeletonAnimation2 then
                local hue = math.floor(((config.hue or 0) + 180) / 360 * 255)
                local saturation = ((config.saturation or 0) + 1) / 2 * 255
                local intensity = ((config.intensity or 0) + 1) / 2 * 255
                self._actorView:replaceSlotWithSkeletonAnimation2(effectView:getSkeletonView(), self:_getReplaceBoneName(config, dummy), ROOT_BONE, "", 
                                                                    config.offset_x or 0, config.offset_y or 0, config.scale or 1.0, config.rotation or 0.0,
                                                                    config.is_hsi_enabled or false, ccc4(hue, saturation, intensity, 0))
            else
                self._actorView:replaceSlotWithSkeletonAnimation(effectView:getSkeletonView(), self:_getReplaceBoneName(config, dummy), ROOT_BONE, "")
            end
        else
            self._actorView:attachNodeToBone(dummy, effectView, isBackSide, isFlipWithActor)
        end
    end

end

function QUIWidgetSkeletonActor:setOpacity( ... )
    self._actorView:setOpacity( ... )
end

function QUIWidgetSkeletonActor:_processAdditionalEffects(options)
    if not ENABLE_ENCHANT_EFFECT then
        return
    end

    local staticDatabase = QStaticDatabase:sharedDatabase() 
    local character = staticDatabase:getCharacterByID(self._actorId)
    local skinId = nil
    local config = nil
    if options.heroInfo then
        skinId = options.heroInfo.skinId
        config = staticDatabase:getHeroSkinConfigByID(skinId)
    end

    local function createAddtionalEffect(effects)
        for _, effectID in ipairs(effects) do
            if effectID ~= "" then
                local frontEffect, backEffect = QUIWidgetSkeletonEffect.createEffectByID(effectID, {})
                self:attachEffect(effectID, frontEffect, backEffect)
                if frontEffect then
                    frontEffect:retain()
                    frontEffect:playAnimation(frontEffect:getPlayAnimationName(), true)
                    table.insert(self._attachEffectList, frontEffect)
                end
                if backEffect then
                    backEffect:retain()
                    backEffect:playAnimation(backEffect:getPlayAnimationName(), true)
                    table.insert(self._attachEffectList, backEffect)
                end
            end
        end
    end
    local effects = string.split((config and config.skins_additional_effects) or character.additional_effects or "", ";")
    local uiEffects = string.split((config and config.skins_additional_effects_ui) or character.additional_effects_ui or "", ";")

    createAddtionalEffect(effects)
    createAddtionalEffect(uiEffects)

    if not options.heroInfo then
        return
    end
    local effect, enchant_effect = nil, nil
    if config then effect = config.skins_enchant_effect end
    if effect ~= nil then enchant_effect = effect else enchant_effect = self._actorDisplay.enchant_effect end

    if options and enchant_effect ~= nil then
        local enchant_effects = string.split(enchant_effect, ";")
        if options.isSelf or options.heroInfo then
            -- get weapon enchant level
            local heroInfo = options.heroInfo or remote.herosUtil:getHeroByID(self._actorDisplay.id)
            if heroInfo then
                local breakConfig = staticDatabase:getBreakthroughByTalent(self._actorDisplay.talent)
                local weaponEquipment = nil
                for _, breakInfo in pairs(breakConfig) do
                    for _, equipment in ipairs(heroInfo.equipments or {}) do
                        if breakInfo[EQUIPMENT_TYPE.WEAPON] == equipment.itemId then
                            weaponEquipment = equipment
                            break
                        end
                    end
                end
                if weaponEquipment then
                    local enchant_level = weaponEquipment.enchants or 0
                    self._weaponEnchantLevel = enchant_level
                    if enchant_level >= 1 and enchant_level < 3 then
                        enchant_level = 1
                    elseif enchant_level >= 3 and enchant_level < 5 then
                        enchant_level = 2
                    elseif enchant_level >= 5 then
                        enchant_level = 3
                    end
                    if enchant_effects[enchant_level] then
                        for _, effect in ipairs(self._enchantEffects or {}) do
                            effect:onCleanup()
                            effect:release()
                        end
                        self._enchantEffects = {}
                        self._enchantDummies = {}
                        local effects = string.split(enchant_effects[enchant_level], ",")
                        for _, effectID in ipairs(effects) do
                            local frontEffect, backEffect = QUIWidgetSkeletonEffect.createEffectByID(effectID, {})
                            self:attachEffect(effectID, frontEffect, backEffect)
                            if frontEffect then
                                frontEffect:playAnimation(EFFECT_ANIMATION, true)
                                frontEffect:retain()
                            end
                            if backEffect then
                                backEffect:retain()
                                backEffect:playAnimation(EFFECT_ANIMATION, true)
                            end
                            table.insert(self._enchantEffects, frontEffect)
                            table.insert(self._enchantEffects, backEffect)
                            local config = staticDatabase:getEffectConfigByID(effectID)
                            table.insert(self._enchantDummies, config.replace or config.dummy)
                        end
                    end
                end
            end
        end
    end
end

function QUIWidgetSkeletonActor:isEnchantEffectOutdated()
    if not ENABLE_ENCHANT_EFFECT or self._actorDisplay.enchant_effect == nil then
        return false
    end

    local staticDatabase = QStaticDatabase:sharedDatabase() 
    local heroInfo = self:getOptions().heroInfo or remote.herosUtil:getHeroByID(self._actorDisplay.id)
    local breakConfig = staticDatabase:getBreakthroughByTalent(self._actorDisplay.talent)
    local weaponEquipment = nil
    for _, breakInfo in pairs(breakConfig) do
        for _, equipment in ipairs(heroInfo.equipments or {}) do
            if breakInfo[EQUIPMENT_TYPE.WEAPON] == equipment.itemId then
                weaponEquipment = equipment
                break
            end
        end
    end
    if weaponEquipment and (weaponEquipment.enchants or 0) ~= self._weaponEnchantLevel then
        return true
    else
        return false
    end
end

function QUIWidgetSkeletonActor:setEnchantEffectsOpacity(opacity)
    if self._enchantEffects then
        for _, effect in ipairs(self._enchantEffects) do
            effect:setOpacity(opacity)
        end
    end
end

function QUIWidgetSkeletonActor:getEnchantDummies()
    return self._enchantDummies
end

function QUIWidgetSkeletonActor:_getReplaceBoneName(config, dummy)
    if type(config.replace) == "string" then
        return config.replace
    else 
        return self._actorView:getParentBoneName(dummy)
    end
end

function QUIWidgetSkeletonActor:getActorID()
    return self._actorId
end

function QUIWidgetSkeletonActor:getActorFile()
    return self._actorFile, self._actorScale
end

return QUIWidgetSkeletonActor
