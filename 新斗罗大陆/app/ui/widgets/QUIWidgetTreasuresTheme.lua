--
-- Kumo.Wang
-- 资源夺宝主题
--

local QUIWidget = import(".QUIWidget")
local QUIWidgetTreasuresTheme = class("QUIWidgetTreasuresTheme", QUIWidget)

local QUIViewController = import("..QUIViewController")
local QNotificationCenter = import("...controllers.QNotificationCenter")

QUIWidgetTreasuresTheme.EVENT_CLICK = "QUIWIDGETTREASURESTHEME.EVENT_CLICK"

function QUIWidgetTreasuresTheme:ctor(options)
	local ccbFile = "ccb/Widget_Treasures_Theme.ccbi"
	local callBacks = {
        -- {ccbCallbackName = "onTriggerMinus", callback = handler(self, self._onTriggerMinus)},
    }
	QUIWidgetTreasuresTheme.super.ctor(self, ccbFile, callBacks, options)

	cc.GameObject.extend(self)
    self:addComponent("components.behavior.EventProtocol"):exportMethods()
    
    if options then
    	self._themeType = options.themeType or 2
    end

    self._resourceTreasuresModule = remote.activityRounds:getRoundInfoByType(remote.activityRounds.LuckyType.RESOURCE_TREASURES)

    self:resetAll()
end

function QUIWidgetTreasuresTheme:resetAll()
	self._ccbOwner.node_bg:removeAllChildren()
	local path = QResPath("resource_treasures_theme_none")
	local sp = CCSprite:create(path)
	self._ccbOwner.node_bg:addChild(sp)
	self._ccbOwner.node_bg:setVisible(true)

	self._ccbOwner.node_add:removeAllChildren()
	path = QResPath("silves_arena_big_add")
	sp = CCSprite:create(path)
	self._ccbOwner.node_add:addChild(sp)
	self._ccbOwner.node_add:setVisible(true)

	self._ccbOwner.node_icon:removeAllChildren()
	self._ccbOwner.node_title:removeAllChildren()
	if self._themeType == self._resourceTreasuresModule.SENIOR_THEME then
		path = QResPath("resource_treasures_theme_title")[1]
	else
		path = QResPath("resource_treasures_theme_title")[2]
	end
	sp = CCSprite:create(path)
	self._ccbOwner.node_title:addChild(sp)
	self._ccbOwner.node_title:setVisible(true)

	self._ccbOwner.node_change:setVisible(false)

	self._ccbOwner.tf_theme_name:setVisible(false)
end

function QUIWidgetTreasuresTheme:getContentSize()
	return self._ccbOwner.node_size:getContentSize()
end

function QUIWidgetTreasuresTheme:onEnter()
	self._ccbOwner.node_size:setTouchEnabled(true)
	self._ccbOwner.node_size:setTouchMode(cc.TOUCH_MODE_ONE_BY_ONE)
	self._ccbOwner.node_size:setTouchSwallowEnabled(true)
	self._ccbOwner.node_size:addNodeEventListener(cc.NODE_TOUCH_EVENT, handler(self, self._onTouch))
end

function QUIWidgetTreasuresTheme:onExit()
	self._ccbOwner.node_size:setTouchEnabled(false)
	self._ccbOwner.node_size:removeNodeEventListenersByEvent(cc.NODE_TOUCH_EVENT)
end

--设置icon
function QUIWidgetTreasuresTheme:setItemIcon(respath)
	if respath then
		if self.icon == nil then
			self.icon = CCSprite:create()
			self._ccbOwner.node_icon:addChild(self.icon)
		end

		self.icon:setVisible(true)
		self.icon:setScale(1)
		self.icon:setTexture(CCTextureCache:sharedTextureCache():addImage(respath))
		
		setNodeShaderProgram(self.icon, qShader.CC_ProgramPositionTextureColor)
		self.icon:setOpacity(1 * 255)
		
		local size = self.icon:getContentSize()
		local targetSize = self._ccbOwner.node_icon_size:getContentSize()
		local targetScaleX = self._ccbOwner.node_icon_size:getScaleX()
		local targetScaleY = self._ccbOwner.node_icon_size:getScaleY()
		if size.width ~= targetSize.width then
			self.icon:setScaleX(targetSize.width * targetScaleX/size.width)
		end
		if size.height ~= targetSize.height then
			self.icon:setScaleY(targetSize.height * targetScaleY/size.height)
		end

		self._ccbOwner.node_change:setVisible(true)
	end
end

function QUIWidgetTreasuresTheme:setThemeName( nameStr )
	if not nameStr or nameStr == "" then
		self._ccbOwner.tf_theme_name:setVisible(false)
	else
		self._ccbOwner.tf_theme_name:setString(nameStr)
		self._ccbOwner.tf_theme_name:setVisible(true)
	end
	self._ccbOwner.node_title:setVisible(false)
end

function QUIWidgetTreasuresTheme:setHideTips()
	self._ccbOwner.node_change:setVisible(false)
end

function QUIWidgetTreasuresTheme:_onTouch(event)
	print(event.name)
	if event.name == "began" then 
		return true
	elseif event.name == "ended" or event.name == "cancelled" then 
		self:_onTriggerClick()
	end
end

function QUIWidgetTreasuresTheme:_onTriggerClick()
	self:dispatchEvent({name = QUIWidgetTreasuresTheme.EVENT_CLICK, themeType = self._themeType})
end

return QUIWidgetTreasuresTheme