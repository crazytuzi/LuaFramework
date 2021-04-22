
local QUIWidget = import("...widgets.QUIWidget")
local QUIWidgetUnionDragonTrainChange = class("QUIWidgetUnionDragonTrainChange", QUIWidget)

QUIWidgetUnionDragonTrainChange.EVENT_CLICK_CARD = "EVENT_CLICK_CARD" 
QUIWidgetUnionDragonTrainChange.EVENT_CLICK_INFO = "EVENT_CLICK_INFO" 

function QUIWidgetUnionDragonTrainChange:ctor(options)
	local ccbFile = "ccb/Widget_society_dragontrain_illusion.ccbi"
	local callBacks = {
        {ccbCallbackName = "onTriggerClick", callback = handler(self, self._onTriggerClick)},
		{ccbCallbackName = "onTriggerVisit", callback = handler(self, self._onTriggerVisit)},
	}
	QUIWidgetUnionDragonTrainChange.super.ctor(self, ccbFile, callBacks, options)
	
  	cc.GameObject.extend(self)
  	self:addComponent("components.behavior.EventProtocol"):exportMethods()
end

function QUIWidgetUnionDragonTrainChange:resetAll()
    self._ccbOwner.sp_select:setVisible(false)
    self._ccbOwner.node_select:setVisible(false)
    self._ccbOwner.node_buy:setVisible(false)
    self._ccbOwner.node_shadow:setVisible(false)
    self._ccbOwner.node_name:setVisible(true)
    self._ccbOwner.sp_card1:setVisible(false)
    self._ccbOwner.sp_card2:setVisible(false)
    self._ccbOwner.btn_visit:setVisible(false)
end

function QUIWidgetUnionDragonTrainChange:setInfo(info, dragonType)
    self:resetAll()
    local dragon = info.dragon
    self._dragonId = dragon.dragon_id
    
    if dragonType == remote.dragon.TYPE_WEAPON then
        self._ccbOwner.sp_card1:setVisible(true)
    else
        self._ccbOwner.sp_card2:setVisible(true)
    end
    if self._dragonId == 10000 then
        self._ccbOwner.node_shadow:setVisible(true)
        self._ccbOwner.node_name:setVisible(false)
        return
    end

    self._ccbOwner.btn_visit:setVisible(true)
	self._ccbOwner.tf_name:setString(dragon.dragon_name or "")
    self._ccbOwner.node_avatar:removeAllChildren()
    if dragon.card then
        local sprite = CCSprite:create(dragon.card)
        self._ccbOwner.node_avatar:addChild(sprite)
    end

    if info.isLock then
       self._ccbOwner.node_buy:setVisible(true)
       self._ccbOwner.node_shadow:setVisible(true)
	   self._ccbOwner.tf_pay:setString(dragon.token_cost or "0")
    elseif info.isUse then
        self._ccbOwner.node_select:setVisible(true)
        self._ccbOwner.tf_tips:setString("使用中")
    else
        self._ccbOwner.node_select:setVisible(true)
        self._ccbOwner.tf_tips:setString("宗主、副宗主可进行幻化")
    end
    self._ccbOwner.sp_select:setVisible(info.isSelect or false)
end

function QUIWidgetUnionDragonTrainChange:_onTriggerClick()
    if self._dragonId ~= 10000 then
	   self:dispatchEvent({name = QUIWidgetUnionDragonTrainChange.EVENT_CLICK_CARD, dragonId = self._dragonId})
    end
end

function QUIWidgetUnionDragonTrainChange:_onTriggerVisit()
    if self._dragonId ~= 10000 then
        self:dispatchEvent({name = QUIWidgetUnionDragonTrainChange.EVENT_CLICK_INFO, dragonId = self._dragonId})
    end
end

function QUIWidgetUnionDragonTrainChange:getContentSize()
    return self._ccbOwner.card_size:getContentSize()
end

return QUIWidgetUnionDragonTrainChange
