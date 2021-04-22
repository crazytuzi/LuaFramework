
local QUIWidget = import("...widgets.QUIWidget")
local QUIWidgetDragonWarHistoryGlory = class("QUIWidgetDragonWarHistoryGlory", QUIWidget)

local QUIWidgetFcaAnimation = import("...widgets.actorDisplay.QUIWidgetFcaAnimation")
local QUIWidgetFloorIcon = import("...widgets.QUIWidgetFloorIcon")

function QUIWidgetDragonWarHistoryGlory:ctor(options)
	local ccbFile = "ccb/Widget_DragonWar_ryq.ccbi"
	local callBacks = {
        {ccbCallbackName = "onTriggerVisit", callback = handler(self, self._onTriggerVisit)},
    }
	QUIWidgetDragonWarHistoryGlory.super.ctor(self, ccbFile, callBacks, options)

  	cc.GameObject.extend(self)
  	self:addComponent("components.behavior.EventProtocol"):exportMethods()
end

function QUIWidgetDragonWarHistoryGlory:resetAll()
  	for i = 1, 3 do
  		self._ccbOwner["no_effect_"..i]:setVisible(false)
  		self._ccbOwner["effect_"..i]:setVisible(false)
  	end
    self._ccbOwner.tf_user_name:setString("")
  	self._ccbOwner.node_floor:removeAllChildren()
    self._ccbOwner.avatar:removeAllChildren()
end

function QUIWidgetDragonWarHistoryGlory:setFighterInfo(fighter, index)
  	self:resetAll()
	self._ccbOwner["node_chair"..index]:setVisible(true)
    self._ccbOwner["no_effect_"..index]:setVisible(true)
    self._ccbOwner["effect_"..index]:setVisible(true)

    self._fighter = fighter
    if not fighter then
        return
    end

    self._ccbOwner["no_effect_"..index]:setVisible(false)
    local dragonConfig = db:getUnionDragonConfigById(self._fighter.dragonId)
    local levelName = "LV."..self._fighter.dragonLevel.." "..(dragonConfig.dragon_name or "")
    self._ccbOwner.tf_union_name:setString(levelName)
	self._ccbOwner.tf_user_name:setString(self._fighter.consortiaName or "")
	self._ccbOwner.tf_server_name:setString(self._fighter.gameAreaName or "")
	self._ccbOwner.tf_score:setString(self._fighter.score or 1)
	self._ccbOwner.tf_rank:setString(index)

    if dragonConfig.fca then
        self._avatar = QUIWidgetFcaAnimation.new(dragonConfig.fca, "actor", {backSoulShowEffect = dragonConfig.effect})
        self._avatar:setScaleX(-global.dragon_spine_scale)
        self._avatar:setScaleY(global.dragon_spine_scale)
        self._avatar:setPositionY(global.dragon_spine_offsetY)
        self._ccbOwner.avatar:addChild(self._avatar)
        self._ccbOwner.avatar:setScale(0.8)
    end

	-- set icon
	local floorIcon = QUIWidgetFloorIcon.new({isLarge = true})
	floorIcon:setInfo(self._fighter.floor, "unionDragonWar")
	self._ccbOwner.node_floor:setScale(0.5)
	self._ccbOwner.node_floor:addChild(floorIcon)
end

function QUIWidgetDragonWarHistoryGlory:_onTriggerVisit()
end

return QUIWidgetDragonWarHistoryGlory