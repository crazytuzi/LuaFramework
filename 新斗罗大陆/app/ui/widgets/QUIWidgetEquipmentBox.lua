
local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetEquipmentBaseBox = import("..widgets.QUIWidgetEquipmentBaseBox")
local QUIWidgetEquipmentBox = class("QUIWidgetEquipmentBox", QUIWidgetEquipmentBaseBox)

local QStaticDatabase = import("...controllers.QStaticDatabase")
local QUIWidgetAnimationPlayer = import("..widgets.QUIWidgetAnimationPlayer")
local QUIWidgetEnchantStar = import("..widgets.QUIWidgetEnchantStar")

QUIWidgetEquipmentBox.EVENT_EQUIPMENT_BOX_CLICK = "EVENT_EQUIPMENT_BOX_CLICK"

function QUIWidgetEquipmentBox:ctor(options)
	local ccbFile = "ccb/Widget_EquipmentBox.ccbi"
	local callBacks = {
			{ccbCallbackName = "onTriggerTouch", callback = handler(self, QUIWidgetEquipmentBox._onTriggerTouch)},
		}
	QUIWidgetEquipmentBox.super.ctor(self, ccbFile, callBacks, options)

	cc.GameObject.extend(self)
    self:addComponent("components.behavior.EventProtocol"):exportMethods()

    self._isEnchantUnlock = false
    self._isEnhanceUnlock = false
	self:resetAll()
	self:setSelect(false)
	self:unlockHandler()
	self._ccbOwner.enchantNode:setVisible(false)
end

function QUIWidgetEquipmentBox:getName()
	return "QUIWidgetEquipmentBox"
end

--设置装备类型
function QUIWidgetEquipmentBox:setType(type)
	self._type = type
end

function QUIWidgetEquipmentBox:setSize(size)
	local selfSize = self._ccbOwner.node_kuang:getContentSize()
	self._ccbView:setScaleX(size.width/selfSize.width)
	self._ccbView:setScaleY(size.height/selfSize.height)
end

function QUIWidgetEquipmentBox:getContentSize()
	return self._ccbOwner.node_kuang:getContentSize()
end

function QUIWidgetEquipmentBox:setBoxScale(scale)
	self._ccbOwner.evolution_tips:setScale(0.8/scale)
	self._ccbOwner.enchant_tips:setScale(0.8/scale)
	self:setScale(scale)
end

function QUIWidgetEquipmentBox:showEnchantIcon(visible, level, scale)
	self._ccbOwner["enchant_star"]:setVisible(visible)
	if visible then
		self._ccbOwner["enchant_star"]:removeAllChildren()

		local enchantStar = QUIWidgetEnchantStar.new({number = level})
		self._ccbOwner["enchant_star"]:addChild(enchantStar)

		if level > 15 then 
			enchantStar:setPositionY(enchantStar:getPositionY() + 20)
			enchantStar:setPositionX(enchantStar:getPositionX() - 10)
		end

		if scale then
			enchantStar:setScale(scale)
		end
	end
end

function QUIWidgetEquipmentBox:showStrengthenLevelIcon(state, level) 
	self:setStrengthenNode(state)
    if state then
       self._ccbOwner.node_hero_level:setString(level or 0)
    end
end

function QUIWidgetEquipmentBox:setStrengthenNode(b)
	if self._isEnhanceUnlock == false then return end
   	self._ccbOwner.strengthen_node:setVisible(b)
end

function QUIWidgetEquipmentBox:setEnchantNode(b)
   --self._ccbOwner.enchantNode:setVisible(b)
end

--获取装备类型
function QUIWidgetEquipmentBox:getType()
	return self._type
end

--获取装备类型
function QUIWidgetEquipmentBox:getItemId()
	if self._itemInfo ~= nil then
		return self._itemInfo.id
	end
	return nil
end

function QUIWidgetEquipmentBox:setEquipmentInfo(itemInfo, actorId, equipInfo)
	if itemInfo ~= nil then
		self._itemInfo = itemInfo
		if equipInfo ~= nil then
			self._equipInfo = equipInfo
		else
			self._equipInfo = itemInfo
		end
		self:resetEffect()
		self._ccbOwner.node_icon:removeAllChildren()
		local icon = display.newSprite(self._itemInfo.icon)
		self._ccbOwner.node_icon:addChild(icon)
		local iconSize = icon:getContentSize()
		local selfSize = self._ccbOwner.node_kuang:getContentSize()
		icon:setScaleX(selfSize.width*self._ccbOwner.node_kuang:getScaleX()/iconSize.width)
		icon:setScaleY(selfSize.height*self._ccbOwner.node_kuang:getScaleY()/iconSize.height)
	end
end

function QUIWidgetEquipmentBox:setColor(index)
	if index == nil then index = 0 end 
	-- index = index + 1
	self:_hideAllColor()
	if self._ccbOwner["break_"..index] then
		self._ccbOwner["break_"..index]:setVisible(true)
	end
end

function QUIWidgetEquipmentBox:showState(isGreen, isComposite)
	if isGreen == true then
		self._ccbOwner.sprite_greenplus:setVisible(true)
		if isComposite == true then
			self._ccbOwner.tf_composite_green:setVisible(true)
		else
			self._ccbOwner.tf_wear_green:setVisible(true)
	 	end 
	else
		self._ccbOwner.sprite_yellowplus:setVisible(true)
		if isComposite == true then
			self._ccbOwner.tf_composite_yellow:setVisible(true)
		else
			self._ccbOwner.tf_wear_yellow:setVisible(true)
	 	end
	end
end

function QUIWidgetEquipmentBox:showDrop(isCanDrop)
	if isCanDrop == true then
		self._ccbOwner.sprite_buleplus:setVisible(true)
		self._ccbOwner.tf_drop_yellow:setVisible(true)
	end
end

function QUIWidgetEquipmentBox:setEvolution(breakthrough)
	self:setColor(breakthrough)
end

--设置是否可以突破
function QUIWidgetEquipmentBox:showCanEvolution(b)
	self._ccbOwner.evolution_tips:setVisible(b)
end

--设置是否可以觉醒
function QUIWidgetEquipmentBox:showCanEnchant(b)
	self._ccbOwner.enchant_tips:setVisible(b)
end

--设置是否可以收集 就是掉落
function QUIWidgetEquipmentBox:showCanDrop(b)
	if self._animationDrop == nil and b == true then
		self._animationDrop = QUIWidget.new("ccb/effects/keshouji.ccbi")
		self._ccbOwner.node_effect:addChild(self._animationDrop)
	end
	if self._animationDrop ~= nil then
		self._animationDrop:setVisible(b)
	end
end

--设置是否可以挑战 可以收集 但是未通关
function QUIWidgetEquipmentBox:showCanChallenge(b)
	if self._animationChallenge == nil and b == true then
		-- self._animationChallenge = QUIWidget.new("ccb/effects/ketiaozhan.ccbi")
		self._animationChallenge = QUIWidget.new("ccb/effects/keshouji.ccbi")
		self._ccbOwner.node_effect:addChild(self._animationChallenge)
	end
	if self._animationChallenge ~= nil then
		self._animationChallenge:setVisible(b)
	end
end

--设置是否可以强化
-- @qinyuanji wow-6408 i.	强化不需要红点提示
function QUIWidgetEquipmentBox:showCanStrengthen(b)
	-- if self._animationStrengthen == nil and b == true then
	-- 	-- self._animationStrengthen = QUIWidget.new("ccb/effects/keqianghua_arrow.ccbi")
	-- 	CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("ui/common.plist")
	-- 	local spriteFrameName = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("dot.png")
	-- 	self._animationStrengthen = CCSprite:createWithSpriteFrame(spriteFrameName)
	-- 	self._animationStrengthen:setScale(0.8)
	-- 	-- self._ccbOwner.strengthen_effect:addChild(self._animationStrengthen)
	-- 	self._ccbOwner.dot_content:addChild(self._animationStrengthen)
	-- end
	-- if self._animationStrengthen ~= nil then 
	-- 	self._animationStrengthen:setVisible(b)
	-- end
end

--没有装备
function QUIWidgetEquipmentBox:showNoEquip(b)
	self._ccbOwner.node_no:setVisible(b)
end

--设置选中
function QUIWidgetEquipmentBox:setSelect(b)
	self._ccbOwner.node_select:setVisible(b)
end

--设置是否显示加号
function QUIWidgetEquipmentBox:setPlus(b)
  self._ccbOwner.plus:setVisible(b)
end

--设置是否动画
function QUIWidgetEquipmentBox:setEffect(b)
  self._ccbOwner.node_effect:setVisible(b)
end

--设置是否显示可强化动画
function QUIWidgetEquipmentBox:setStrengthenEffect(b)
  -- self._ccbOwner.dot_content:setVisible(b)
end

--全部置空
function QUIWidgetEquipmentBox:resetAll()
	self._itemInfo = nil
	self:_hideAllColor() 
	self._ccbOwner.sprite_yellowplus:setVisible(false)
	self._ccbOwner.sprite_greenplus:setVisible(false)
	self._ccbOwner.sprite_buleplus:setVisible(false)
	self._ccbOwner.tf_composite_green:setVisible(false)
	self._ccbOwner.tf_composite_yellow:setVisible(false)
	self._ccbOwner.tf_wear_green:setVisible(false)
	self._ccbOwner.tf_wear_yellow:setVisible(false)
	self._ccbOwner.tf_drop_yellow:setVisible(false)
	self._ccbOwner.node_no:setVisible(false)
	-- self._ccbOwner.node_select:setVisible(false)
	self._ccbOwner.strengthen_node:setVisible(false)
	self._ccbOwner.node_icon:removeAllChildren()
	self:showCanEvolution(false)
	self:showCanDrop(false)
	self:showCanChallenge(false)
	self:showStrengthenLevelIcon(false)
	self:resetEffect()
end

function QUIWidgetEquipmentBox:resetEffect()
	if self._handler ~= nil then
		scheduler.unscheduleGlobal(self._handler)
		self._handler = nil
	end
	self._effectTbl = {}
	self._effectPlay = false
end

function QUIWidgetEquipmentBox:_hideAllColor()
	local i = 1
	while true do
		local node = self._ccbOwner["break_"..i]
		if node ~= nil then
			node:setVisible(false)
		else
			break
		end
		i = i + 1
	end
end

function QUIWidgetEquipmentBox:onEnter()
	self._userProxy = cc.EventProxy.new(remote.user)
	self._userProxy:addEventListener(remote.user.EVENT_USER_PROP_CHANGE, handler(self, self.unlockHandler))
	self._remoteProxy = cc.EventProxy.new(remote)
	self._remoteProxy:addEventListener(remote.DUNGEON_UPDATE_EVENT, handler(self, self.unlockHandler))
end

function QUIWidgetEquipmentBox:unlockHandler(event)
	if self.class == nil then return end

	if self._isEnchantUnlock ~= true or self._isEnhanceUnlock ~= true then
		local unlockValue = QStaticDatabase:sharedDatabase():getConfiguration()
		if self._isEnchantUnlock ~= true then
			self._isEnchantUnlock = app.unlock:getUnlockEnchant()
		  	self:setEnchantNode(self._isEnchantUnlock)
	  	end
		if self._isEnhanceUnlock ~= true then
			self._isEnhanceUnlock = app.unlock:getUnlockEnhance()
		  	self:setStrengthenNode(self._isEnhanceUnlock)
	  	end
  	end
end

function QUIWidgetEquipmentBox:onExit()
	if self._handler ~= nil then
		scheduler.unscheduleGlobal(self._handler)
		self._handler = nil
	end
	self._userProxy:removeAllEventListeners()
	self._remoteProxy:removeAllEventListeners()
end

--显示特效
function QUIWidgetEquipmentBox:playPropEffect(value)
	if self._effectTbl == nil then
		self._effectTbl = {}
	end
	table.insert(self._effectTbl, value)
	self._timeDelay = 0.3
	if (2/#self._effectTbl) < self._timeDelay then
		self._timeDelay = 2/#self._effectTbl
	end
	if self._effectPlay == false then
		self._effectPlay = true
		self._handler = scheduler.performWithDelayGlobal(handler(self,self._playPropEffect),self._timeDelay)
	end
end

function QUIWidgetEquipmentBox:_playPropEffect()
	if self._effectTbl == nil or #self._effectTbl == 0 then
		self._effectPlay = false
		if self._handler ~= nil then
			scheduler.unscheduleGlobal(self._handler)
			self._handler = nil
		end
		return 
	else
		self._handler = scheduler.performWithDelayGlobal(handler(self,self._playPropEffect),self._timeDelay)
	end
	local value = self._effectTbl[1]
	table.remove(self._effectTbl,1)

	local effect = QUIWidgetAnimationPlayer.new()
	effect:setPosition(0,20)
	self:addChild(effect)
	effect:playAnimation("ccb/Widget_tips.ccbi", function(ccbOwner)
			ccbOwner.tf_value:setString(value)
        end,function()
        	effect:removeFromParentAndCleanup(true)
        end)
end

function QUIWidgetEquipmentBox:_onTriggerTouch()
	if self._itemInfo then
		self:dispatchEvent({name = QUIWidgetEquipmentBox.EVENT_EQUIPMENT_BOX_CLICK, info = self._itemInfo, type = self._type})
	end
end

return QUIWidgetEquipmentBox