local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetEquipmentBaseBox = import("..widgets.QUIWidgetEquipmentBaseBox")
local QUIWidgetEquipmentSpecialBox = class("QUIWidgetEquipmentSpecialBox", QUIWidgetEquipmentBaseBox)

local QStaticDatabase = import("...controllers.QStaticDatabase")
local QUIWidgetAnimationPlayer = import("..widgets.QUIWidgetAnimationPlayer")
local QFullCircleUiMask = import("..battle.QFullCircleUiMask")
local QUIWidgetEnchantStar = import("..widgets.QUIWidgetEnchantStar")

QUIWidgetEquipmentSpecialBox.EVENT_EQUIPMENT_BOX_CLICK = "EVENT_EQUIPMENT_BOX_CLICK"

function QUIWidgetEquipmentSpecialBox:ctor(options)
	local ccbFile = "ccb/Widget_AccessoriesBox.ccbi"
	local callBacks = {
			{ccbCallbackName = "onTriggerTouch", callback = handler(self, QUIWidgetEquipmentSpecialBox._onTriggerTouch)},
		}
	QUIWidgetEquipmentSpecialBox.super.ctor(self, ccbFile, callBacks, options)

	cc.GameObject.extend(self)
    self:addComponent("components.behavior.EventProtocol"):exportMethods()

    self._isEnchantUnlock = false
    self._isEnhanceUnlock = false
	self:resetAll()
	self:setSelect(false)
	self:unlockHandler()
end

--设置装备类型
function QUIWidgetEquipmentSpecialBox:setType(_type)
	self._type = _type
	if _type == EQUIPMENT_TYPE.JEWELRY1 then
	    QSetDisplayFrameByPath(self._ccbOwner.node_kuang, "ui/common4/Hero_accessories_bj.png")
	elseif _type == EQUIPMENT_TYPE.JEWELRY2 then
		QSetDisplayFrameByPath(self._ccbOwner.node_kuang, "ui/common4/Hero_accessories_bj2.png")
	end
end

--获取装备类型
function QUIWidgetEquipmentSpecialBox:getType()
	return self._type
end

-- function QUIWidgetEquipmentSpecialBox:setSize(size)
-- 	local selfSize = self._ccbOwner.node_kuang:getContentSize()
-- 	self._ccbView:setScaleX(size.width/selfSize.width)
-- 	self._ccbView:setScaleY(size.height/selfSize.height)
-- end

-- function QUIWidgetEquipmentSpecialBox:getContentSize()
-- 	return self._ccbOwner.node_kuang:getContentSize()
-- end

function QUIWidgetEquipmentSpecialBox:setBoxScale(scale)
	self._ccbOwner.evolution_tips:setScale(0.8/scale)
	self._ccbOwner.enchant_tips:setScale(0.8/scale)
	self:setScale(scale)
end

function QUIWidgetEquipmentSpecialBox:showEnchantIcon(visible, level, scale)
	self._ccbOwner.enchant_star:setVisible(visible)
	if visible then
		self._ccbOwner.enchant_star:removeAllChildren()
		local enchantStar = QUIWidgetEnchantStar.new({number = level})
		self._ccbOwner.enchant_star:addChild(enchantStar)

		if level > 15 then 
			enchantStar:setPositionY(enchantStar:getPositionY() + 20)
			enchantStar:setPositionX(enchantStar:getPositionX() - 10)
		end

		if scale then
			enchantStar:setScale(scale)
		end
	end
end

function QUIWidgetEquipmentSpecialBox:showStrengthenLevelIcon(state, level) 
    if self._itemInfo == nil then return end
    
    if state then
        self._ccbOwner.node_level:setVisible(true)
       self._ccbOwner.node_hero_level:setString(level or 0)
    else
       self._ccbOwner.node_level:setVisible(false)
    end
end

function QUIWidgetEquipmentSpecialBox:setStrengthenNode(b)
   -- self._ccbOwner.node_level:setVisible(b)
end

function QUIWidgetEquipmentSpecialBox:setEnchantNode(b)
   -- self._ccbOwner.enchantNode:setVisible(b)
end

--获取装备类型
function QUIWidgetEquipmentSpecialBox:getItemId()
	if self._itemInfo ~= nil then
		return self._itemInfo.id
	end
	return nil
end

function QUIWidgetEquipmentSpecialBox:setEquipmentInfo(itemInfo)
	if itemInfo ~= nil then
		self._itemInfo = itemInfo
		if equipInfo ~= nil then
			self._equipInfo = equipInfo
		else
			self._equipInfo = itemInfo
		end
		self:resetEffect()
		self._ccbOwner.node_icon:removeAllChildren()
		local size = self._ccbOwner.node_kuang:getContentSize()
		local scale = self._ccbOwner.node_kuang:getScale()
	    self._iconContent = CCNode:create()
	    local ccclippingNode = QFullCircleUiMask.new()
	    ccclippingNode:setRadius(scale * size.width/2)
	    ccclippingNode:addChild(self._iconContent)
	    self._ccbOwner.node_icon:addChild(ccclippingNode)
		local icon = display.newSprite(self._itemInfo.icon)
		self._iconContent:addChild(icon)
		local iconSize = icon:getContentSize()
		local selfSize = self._ccbOwner.node_kuang:getContentSize()
		icon:setScaleX(selfSize.width*self._ccbOwner.node_kuang:getScaleX()/iconSize.width)
		icon:setScaleY(selfSize.height*self._ccbOwner.node_kuang:getScaleY()/iconSize.height)
	end
end

function QUIWidgetEquipmentSpecialBox:setColor(index)
	if index == nil then index = 0 end 
	-- index = index + 1
	self:_hideAllColor()
	if self._ccbOwner["break_"..index] then
		self._ccbOwner["break_"..index]:setVisible(true)
		self._ccbOwner.normal:setVisible(false)
	end
end

function QUIWidgetEquipmentSpecialBox:showState(isGreen, isComposite)
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

function QUIWidgetEquipmentSpecialBox:showDrop(isCanDrop)
	if isCanDrop == true then
		self._ccbOwner.sprite_buleplus:setVisible(true)
		self._ccbOwner.tf_drop_yellow:setVisible(true)
	end
end

function QUIWidgetEquipmentSpecialBox:setEvolution(breakthrough)
	self:setColor(breakthrough)
end

--设置是否可以突破
function QUIWidgetEquipmentSpecialBox:showCanEvolution(b)
	self._ccbOwner.evolution_tips:setVisible(b)
end

--设置是否可以觉醒
function QUIWidgetEquipmentSpecialBox:showCanEnchant(b)
	self._ccbOwner.enchant_tips:setVisible(b)
end

function QUIWidgetEquipmentSpecialBox:hideRedTips()
	self._ccbOwner.evolution_tips:setVisible(false)
	self._ccbOwner.enchant_tips:setVisible(false)
end

--设置是否可以收集 就是掉落
function QUIWidgetEquipmentSpecialBox:showCanDrop(b)
	if self._animationDrop == nil and b == true then
		self._animationDrop = QUIWidget.new("ccb/effects/keshouji.ccbi")
		self._ccbOwner.node_effect:addChild(self._animationDrop)
	end
	if self._animationDrop ~= nil then
		self._animationDrop:setVisible(b)
	end
end

--设置是否可以挑战 可以收集 但是为通关
function QUIWidgetEquipmentSpecialBox:showCanChallenge(b)
	if self._animationChallenge == nil and b == true then
		self._animationChallenge = QUIWidget.new("ccb/effects/keshouji.ccbi")
		-- self._animationChallenge = QUIWidget.new("ccb/effects/ketiaozhan.ccbi")
		self._ccbOwner.node_effect:addChild(self._animationChallenge)
	end
	if self._animationChallenge ~= nil then
		self._animationChallenge:setVisible(b)
	end
end

--设置是否可以强化
function QUIWidgetEquipmentSpecialBox:showCanStrengthen(b)
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
function QUIWidgetEquipmentSpecialBox:showNoEquip(b)
	self._ccbOwner.node_no:setVisible(b)
end

--设置选中
function QUIWidgetEquipmentSpecialBox:setSelect(b)
	self._ccbOwner.node_select:setVisible(b)
end

--设置是否显示加号
function QUIWidgetEquipmentSpecialBox:setPlus(b)
  self._ccbOwner.plus:setVisible(b)
end

--设置是否动画
function QUIWidgetEquipmentSpecialBox:setEffect(b)
  self._ccbOwner.node_effect:setVisible(b)
end

--设置是否显示可强化动画
function QUIWidgetEquipmentSpecialBox:setStrengthenEffect(b)
  self._ccbOwner.strengthen_effect:setVisible(b)
end

--设置是否解锁
function QUIWidgetEquipmentSpecialBox:setIsLock(b)
  	self._isLock = b
  	self._ccbOwner.node_lock:setVisible(b)
end

--全部置空
function QUIWidgetEquipmentSpecialBox:resetAll()
	self._itemInfo = nil
	self:_hideAllColor() 
	if self._iconContent ~= nil then
		self._iconContent:removeAllChildren()
	end
  	self._ccbOwner.node_lock:setVisible(false)
  	self._ccbOwner.enchant_star:setVisible(false) 
   	self._ccbOwner.node_level:setVisible(false)
	self:showCanEvolution(false)
	self:showCanDrop(false)
	self:showCanChallenge(false)
	self:showStrengthenLevelIcon(false)
	self:resetEffect()
	self:hideRedTips()
end

function QUIWidgetEquipmentSpecialBox:resetEffect()
	if self._handler ~= nil then
		scheduler.unscheduleGlobal(self._handler)
		self._handler = nil
	end
	self._effectTbl = {}
	self._effectPlay = false
end

function QUIWidgetEquipmentSpecialBox:_hideAllColor()
	local i = 0
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

function QUIWidgetEquipmentSpecialBox:onEnter()
	-- self._userProxy = cc.EventProxy.new(remote.user)
	-- self._userProxy:addEventListener(remote.user.EVENT_USER_PROP_CHANGE, handler(self, self.unlockHandler))
end

function QUIWidgetEquipmentSpecialBox:unlockHandler(event)
	-- if self._isEnchantUnlock ~= true or self._isEnhanceUnlock ~= true then
	-- 	local unlockValue = QStaticDatabase:sharedDatabase():getConfiguration()
	-- 	if self._isEnchantUnlock ~= true then
	-- 		self._isEnchantUnlock = app.unlock:getUnlockEnchant()
	-- 	  	self:setEnchantNode(self._isEnchantUnlock)
	--   	end
	-- 	if self._isEnhanceUnlock ~= true then
	-- 		self._isEnhanceUnlock = app.unlock:getUnlockEnhance()
	-- 	  	self:setStrengthenNode(self._isEnhanceUnlock)
	--   	end
 --  	end
end

function QUIWidgetEquipmentSpecialBox:onExit()
	-- if self._handler ~= nil then
	-- 	scheduler.unscheduleGlobal(self._handler)
	-- 	self._handler = nil
	-- end
	-- self._userProxy:removeAllEventListeners()
end

--显示特效
function QUIWidgetEquipmentSpecialBox:playPropEffect(value)
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

function QUIWidgetEquipmentSpecialBox:_playPropEffect()
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

function QUIWidgetEquipmentSpecialBox:_onTriggerTouch()
	self:dispatchEvent({name = QUIWidgetEquipmentSpecialBox.EVENT_EQUIPMENT_BOX_CLICK, info = self._itemInfo, type = self._type})
end

return QUIWidgetEquipmentSpecialBox