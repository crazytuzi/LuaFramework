local QUIWidgetHeroInfoMax = import("..widgets.QUIWidgetHeroInfoMax")
local QUIWidgetHeroEquipmentEnchantMax = class("QUIWidgetHeroEquipmentEnchantMax", QUIWidgetHeroInfoMax)
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QUIWidgetEnchantStar = import("..widgets.QUIWidgetEnchantStar")
local QColorLabel = import("...utils.QColorLabel")
local QUIViewController = import("..QUIViewController")
local QQuickWay = import("...utils.QQuickWay")
local QScrollView = import("...views.QScrollView") 
local QRichText = import("...utils.QRichText")

QUIWidgetHeroEquipmentEnchantMax.ENCHANT_RESET_EVENT = "ENCHANT_RESET_EVENT"

function QUIWidgetHeroEquipmentEnchantMax:ctor(options)
	local callBacks = {
			{ccbCallbackName = "onTriggerReset", callback = handler(self, QUIWidgetHeroEquipmentEnchantMax._onTriggerReset)},
		}
	QUIWidgetHeroEquipmentEnchantMax.super.ctor(self, options, callBacks)
	self._ccbOwner.tf_item_name:setPositionY(self.posY)
end


function QUIWidgetHeroEquipmentEnchantMax:setInfo(actorId, itemId)
	self._actorId = actorId
	self._itemId = itemId
	self._ccbOwner.btn_reset:setVisible(true)
	self:resetAll()
	local itemConfig = QStaticDatabase:sharedDatabase():getItemByID(itemId)
	local enchant = remote.herosUtil:getWearByItem(actorId, itemId)
	local enchantConfig = QStaticDatabase:sharedDatabase():getEnchant(itemConfig.id, (enchant.enchants or 0), actorId)
	self:setProp(enchantConfig)
	self:setEquipment(actorId, itemId)

	self._ccbOwner.node_line:setVisible(true)
	if self._skillNode == nil then
		self._skillNode = CCNode:create()
		self._ccbOwner.node_content:addChild(self._skillNode)
		self._skillNode:setPosition(ccp(175, -50))
	else
		self._skillNode:removeAllChildren()
	end
	
	if enchantConfig.skill_show ~= nil then
		if self._enchantStar == nil then
			self._enchantStar = QUIWidgetEnchantStar.new({number = 0})
			self._enchantStar:setPosition(-60, 130)
			self:getView():addChild(self._enchantStar)
		end

		self:setMaxSpByPlist(nil, QResPath("up_grade_max"))
		self._ccbOwner.node_max:setPositionY(-100)

		local sp_bg = CCScale9Sprite:create("ui/update_common/common_paper_line.png")
		sp_bg:setContentSize(CCSize(550, 110))
		sp_bg:setPosition(ccp(8, 0))
		self._skillNode:addChild(sp_bg)

		sp_bg:setInsetLeft(10)
		sp_bg:setInsetTop(40)
		sp_bg:setInsetRight(10)
		sp_bg:setInsetBottom(10)

	
		local itemContentSize = CCSize(360, 69)
		self._skillDescribe = CCNode:create()
		self._skillDescribe:setPosition(ccp(-140, 19))
		self._skillNode:addChild(self._skillDescribe)
		
    	self._scrollView = QScrollView.new(self._skillDescribe, itemContentSize, {bufferMode = 1})
    	self._scrollView:setVerticalBounce(true)

		local desc = QColorLabel.replaceColorSign(enchantConfig.describe, false)
	    local strArr  = string.split(desc,"\n") or {}
	    local textNode = CCNode:create()
	    local height = 0
	    for i, v in pairs(strArr) do
	        local richText = QRichText.new(v, 360, {stringType = 1, defaultColor = GAME_COLOR_LIGHT.normal, defaultSize = 22})
	        richText:setAnchorPoint(ccp(0, 1))
	        richText:setPositionY(-height)
	        textNode:addChild(richText)
	        height = height + richText:getContentSize().height
	    end
	    textNode:setContentSize(CCSize(360, height))
	    textNode:setPositionY(-5)
		self._scrollView:addItemBox(textNode)
		self._scrollView:setRect(0, -height-5, 0, 0)

		local descTF = CCLabelTTF:create("觉醒可提升属性", global.font_default, 22)
		descTF:setColor(ccc3(134,84,54))
		descTF:setPosition(ccp(0, 35))
		self._skillNode:addChild(descTF)

		local skillConfig = QStaticDatabase:sharedDatabase():getSkillByID(enchantConfig.skill_show)
		local skillNameTF = CCLabelTTF:create(skillConfig.name.."：", global.font_default, 22)
		skillNameTF:setColor(ccc3(134,84,54))
		skillNameTF:setPosition(ccp(-198, 0))
		self._skillNode:addChild(skillNameTF)

	    local button = CCControlButton:create("", global.font_zhcn, 26)
	    button:setPreferredSize(CCSize(30, 30))
	    local normal = QSpriteFrameByPath(QResPath("maginifier"))
	    button:setBackgroundSpriteFrameForState(normal, 1)
	    button:setBackgroundSpriteFrameForState(normal, 2)
	    button:setBackgroundSpriteFrameForState(normal, 4)
	    button:setZoomOnTouchDown(false)
	    button:setAnchorPoint(ccp(0.5, 0.5))
	    button:addHandleOfControlEvent(function (e)
			app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogEnchantInfo", 
			options = {actorId = actorId, itemId = itemId, level = (enchant.enchants or 0)}}, {isPopCurrentDialog = false})

	    end, 32)
	    button:setPosition(ccp(245, 36))
		self._skillNode:addChild(button)

		self._ccbOwner.node_line:setVisible(false)
		self._ccbOwner.btn_reset:setPositionY(-82)
	end
end

function QUIWidgetHeroEquipmentEnchantMax:_onTriggerReset(event)
	if q.buttonEventShadow(event, self._ccbOwner.btn_reset) == false then return end
	if remote.user.token < 30 then
		QQuickWay:addQuickWay(QQuickWay.TOKEN_DROP_WAY, nil)
	else
		app:alert({content = "##n花费##e30钻石##n，摘除这件装备上的##e所有觉醒材料##n？摘除后，返还##e全部觉醒材料##n。", title = "系统提示", 
	        callback = function(callType)
	        	if callType == ALERT_TYPE.CONFIRM then
		            self:dispatchEvent({name = QUIWidgetHeroEquipmentEnchantMax.ENCHANT_RESET_EVENT, actorId = self._actorId, itemId = self._itemId})
		        end
	        end, isAnimation = true, colorful = true}, true, true)
	end
end

return QUIWidgetHeroEquipmentEnchantMax