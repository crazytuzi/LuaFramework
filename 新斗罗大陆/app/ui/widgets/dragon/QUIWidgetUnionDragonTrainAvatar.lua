
local QUIWidget = import("...widgets.QUIWidget")
local QUIWidgetUnionDragonTrainAvatar = class("QUIWidgetUnionDragonTrainAvatar", QUIWidget)
local QUIWidgetFcaAnimation = import("...widgets.actorDisplay.QUIWidgetFcaAnimation")

QUIWidgetUnionDragonTrainAvatar.EVENT_CLICK = "EVENT_CLICK" 

function QUIWidgetUnionDragonTrainAvatar:ctor(options)
	local ccbFile = "ccb/Widget_society_dragontrain_avatar.ccbi"
	local callBacks = {
        {ccbCallbackName = "onTriggerClick", callback = handler(self, self._onTriggerClick)},
	}
	QUIWidgetUnionDragonTrainAvatar.super.ctor(self, ccbFile, callBacks, options)
	
  	cc.GameObject.extend(self)
  	self:addComponent("components.behavior.EventProtocol"):exportMethods()

    self._isInUnion = false
    self:resetAll()
end

function QUIWidgetUnionDragonTrainAvatar:resetAll()
    self._ccbOwner.node_avatar:removeAllChildren()
    self._ccbOwner.node_base:removeAllChildren()
    self._ccbOwner.effect:removeAllChildren()
    self._ccbOwner.effect:setVisible(false)
end

function QUIWidgetUnionDragonTrainAvatar:setEffectVisible(flag)
    self._ccbOwner.effect:setVisible(true)
end

function QUIWidgetUnionDragonTrainAvatar:setInfo(dragonInfo)
    self:resetAll()
    local dragonConfig = db:getUnionDragonConfigById(dragonInfo.dragonId)
    local dragonSkills = db:getUnionDragonSkillById(dragonInfo.dragonId, dragonInfo.level)
    local bigLevel = 0
    for i, skill in pairs(dragonSkills) do
        if dragonInfo.level >= skill.dragon_level then
            bigLevel = bigLevel + 1
            if bigLevel == 4 then
                break
            end
        end
    end
    
    local resConfig = QResPath("dragon_level_effect")[bigLevel]
    if dragonConfig.type == remote.dragon.TYPE_WEAPON then
        local sprite = CCSprite:create(resConfig[1])
        self._ccbOwner.node_base:addChild(sprite)
        self._ccbOwner.effect:setPositionY(65)
    else
        local sprite = CCSprite:create(resConfig[2])
        self._ccbOwner.node_base:addChild(sprite)
        self._ccbOwner.effect:setPositionY(25)
    end

    if resConfig[3] then
        local avatar = QUIWidgetFcaAnimation.new(resConfig[3], "res")
        self._ccbOwner.effect:addChild(avatar)
    end

    if dragonConfig.fca then
        self._avatar = QUIWidgetFcaAnimation.new(dragonConfig.fca, "actor", {backSoulShowEffect = dragonConfig.effect})
        self._avatar:setScaleX(-global.dragon_spine_scale)
        self._avatar:setScaleY(global.dragon_spine_scale)
        self._avatar:setPositionY(global.dragon_spine_offsetY)
        self._ccbOwner.node_avatar:addChild(self._avatar)
    end
end

function QUIWidgetUnionDragonTrainAvatar:setWarInfo(dragonInfo)
    self:resetAll()
    local dragonConfig = db:getUnionDragonConfigById(dragonInfo.dragonId)
    if dragonConfig.fca then
        self._avatar = QUIWidgetFcaAnimation.new(dragonConfig.fca, "actor", {backSoulShowEffect = dragonConfig.effect})
        self._avatar:setScaleX(-global.dragon_spine_scale)
        self._avatar:setScaleY(global.dragon_spine_scale)
        self._avatar:setPositionY(global.dragon_spine_offsetY)
        self._ccbOwner.node_avatar:addChild(self._avatar)
    end
end

function QUIWidgetUnionDragonTrainAvatar:setInUnion(isInUnion)
    self._isInUnion = isInUnion
end

function QUIWidgetUnionDragonTrainAvatar:showDefault()
    self:resetAll()
    local resConfig = QResPath("dragon_level_effect")[1]
    local sprite = CCSprite:create(resConfig[1])
    self._ccbOwner.node_base:addChild(sprite)
end

function QUIWidgetUnionDragonTrainAvatar:_onTriggerClick(event)
    if self._isInUnion then
        local node = self._ccbOwner.btn_click
        local config = app.unlock:getConfigByKey("SOCIATY_DRAGON")
        if remote.union.consortia.level + 2 >= (config.sociaty_level or 0) then
            node = self._ccbOwner.node_base
        end
        if q.buttonEvent(event, node) == false then return end
        self:dispatchEvent({name = QUIWidgetUnionDragonTrainAvatar.EVENT_CLICK})
    end
end

return QUIWidgetUnionDragonTrainAvatar
