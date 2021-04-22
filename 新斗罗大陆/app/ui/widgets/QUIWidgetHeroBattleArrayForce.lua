local QUIWidget = import(".QUIWidget")
local QUIWidgetHeroBattleArrayForce = class("QUIWidgetHeroBattleArrayForce", QUIWidget)
local QTextFiledScrollUtils = import("...utils.QTextFiledScrollUtils")

QUIWidgetHeroBattleArrayForce.EVENT_CLICK_PVP_BUTTON = "EVENT_CLICK_PVP_BUTTON"

function QUIWidgetHeroBattleArrayForce:ctor(options)
	local ccbFile = "ccb/Widget_Defense_team.ccbi"

	if options._type == 1 then
		ccbFile = "ccb/Widget_HeroBattleArray_SingleForce.ccbi"
	end
	local callBacks = {
		{ccbCallbackName = "onTriggerClickPVP", callback = handler(self, self._onTriggerClickPVP)},
	}
	QUIWidgetHeroBattleArrayForce.super.ctor(self, ccbFile, callBacks, options)

  cc.GameObject.extend(self)
  self:addComponent("components.behavior.EventProtocol"):exportMethods()


  self._curType = options._type or 1
  self._tfForce = nil
  if self._curType ~= 1 then
    self._ccbOwner.widget_node_team:setVisible(false)
    self._ccbOwner.sp_inherit:setVisible(false)
    self._ccbOwner.tf_inherit_force:setVisible(false)
    self._tfForce = self._ccbOwner.tf_defens_force
    self._ccbOwner.node_pvp:setPositionX(420)
  else
    self._tfForce = self._ccbOwner.force
    --buff控件先不开启
    self._ccbOwner.node_buff_up:setVisible(false)
  end

end

function QUIWidgetHeroBattleArrayForce:onEnter()
	self._forceUpdate = QTextFiledScrollUtils.new()
end


function QUIWidgetHeroBattleArrayForce:onExit()
	if self._forceUpdate then
		self._forceUpdate:stopUpdate()
		self._forceUpdate = nil
	end
end

function QUIWidgetHeroBattleArrayForce:setForce(curforce)

  if self._forceUpdate then
    self._forceUpdate:stopUpdate()
  end
  
	self._force = curforce
	self:_onForceUpdate(curforce)
end


function QUIWidgetHeroBattleArrayForce:palyForceAction(curforce)
	local change = curforce - self._force
	if curforce ~= self._force then
		self:nodeEffect(self._tfForce)
	end

	self._forceUpdate:addUpdate(self._force, curforce, handler(self, self._onForceUpdate), NUMBER_TIME)
	if self._force > 0 then 
		self:playForceEffect(change)
	end
	self._force = curforce

end

function QUIWidgetHeroBattleArrayForce:addNodeEffect(change)


end

function QUIWidgetHeroBattleArrayForce:nodeEffect(node)
	if node ~= nil then
	    local actionArrayIn = CCArray:create()
        actionArrayIn:addObject(CCScaleTo:create(0.23, 2))
        actionArrayIn:addObject(CCScaleTo:create(0.23, 1))
	    local ccsequence = CCSequence:create(actionArrayIn)
		node:runAction(ccsequence)
	end
end

function QUIWidgetHeroBattleArrayForce:playForceEffect(change)
	if not self._ccbOwner.node_battle then return end

    if change ~= 0 then 
    	local effectName
      if change > 0 then
        effectName = "effects/Tips_add.ccbi"
      elseif change < 0 then 
        effectName = "effects/Tips_Decrease.ccbi"
      end
      local numEffect = QUIWidgetAnimationPlayer.new()
      self._ccbOwner.node_battle:addChild(numEffect)
      numEffect:playAnimation(effectName, function(ccbOwner)
      		if self:safeCheck() then
	            if change < 0 then
	              ccbOwner.content:setString(" -" .. math.abs(change))
	            else
	              ccbOwner.content:setString(" +" .. math.abs(change))
	            end
	        end
          end)
    end
end

function QUIWidgetHeroBattleArrayForce:_onForceUpdate(value)
    local word = nil
    if value >= 1000000 then
      word = tostring(math.floor(value/10000)).."万"
    else
      word = math.floor(value)
    end
    self._tfForce:setString(word)
    local fontInfo = db:getForceColorByForce(value,true)
    if fontInfo ~= nil then
		local color = string.split(fontInfo.force_color, ";")
		self._tfForce:setColor(ccc3(color[1], color[2], color[3]))
    end
end

function QUIWidgetHeroBattleArrayForce:_onTriggerClickPVP(event)
    app.sound:playSound("common_small")
     self:dispatchEvent({name = QUIWidgetHeroBattleArrayForce.EVENT_CLICK_PVP_BUTTON})
end


return QUIWidgetHeroBattleArrayForce
