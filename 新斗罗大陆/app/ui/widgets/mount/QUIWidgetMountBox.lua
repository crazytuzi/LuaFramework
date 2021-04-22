-- 暗器格子
-- zxs

local QUIWidget = import("...widgets.QUIWidget")
local QUIWidgetMountBox = class("QUIWidgetMountBox", QUIWidget)

local QUIWidgetItemsBox = import("...widgets.QUIWidgetItemsBox")
local QUIWidgetHeroHeadStar = import("...widgets.QUIWidgetHeroHeadStar")
local QUIViewController = import("...QUIViewController")

QUIWidgetMountBox.MOUNT_EVENT_CLICK = "MOUNT_EVENT_CLICK"

function QUIWidgetMountBox:ctor(options)
	local ccbFile = "ccb/Widget_weapon_box.ccbi"
	local callBacks = {
        {ccbCallbackName = "onTriggerClick", callback = handler(self, self._onTriggerClick)},
    }
	QUIWidgetMountBox.super.ctor(self, ccbFile, callBacks, options)

	cc.GameObject.extend(self)
    self:addComponent("components.behavior.EventProtocol"):exportMethods()

	self._star = QUIWidgetHeroHeadStar.new({})
	self._ccbOwner.node_star:setScale(0.8)
	self._ccbOwner.node_star:addChild(self._star)

	self._lockConfig = app.unlock:getConfigByKey("UNLOCK_ZUOQI")
	local lockStr = self._lockConfig.hero_level.."级\n开启"
	self._ccbOwner.tf_lock:setString(lockStr)

	self:resetAll()
end

function QUIWidgetMountBox:resetAll()
	self._ccbOwner.node_level:setVisible(false)
	self._ccbOwner.node_star:setVisible(false)
	self._ccbOwner.node_plus:setVisible(false)
	self._ccbOwner.node_talent:setVisible(false)
	self._ccbOwner.sp_red_tips:setVisible(false)
	self._ccbOwner.sp_select:setVisible(false)
	self._ccbOwner.sp_mount_icon:setVisible(true)
	self._ccbOwner.sp_artifact_icon:setVisible(false)
	self._ccbOwner.tf_lock:setVisible(true)
	self._ccbOwner.node_icon:removeAllChildren()
	self._ccbOwner.node_pingzhi:removeAllChildren()
	self._ccbOwner.node_dress:setVisible(false)
	self._ccbOwner.node_grave:setVisible(false)

	self:addSpriteFrame(self._ccbOwner.node_rect, QUIWidgetItemsBox.color_frame["default"][1])
end

function QUIWidgetMountBox:setHighlightedSelectState(state)
    if state == nil then state = false end
    
    self._ccbOwner.sp_select:setVisible(state)
end

--设置魂师
function QUIWidgetMountBox:setHero(actorId)
	self._actorId = actorId
	self:refreshBox()
	self:checkTips()
end

--刷新格子
function QUIWidgetMountBox:refreshBox()
	self._heroInfo = remote.herosUtil:getHeroByID(self._actorId)
	if self._lockConfig.hero_level > self._heroInfo.level then
		self:resetAll()
		local lockStr = self._lockConfig.hero_level.."级\n开启"
		self._ccbOwner.tf_lock:setString(lockStr)
	else
		self:setMountInfo(self._heroInfo.zuoqi)
	end
end

function QUIWidgetMountBox:setNoWearTips()
	self:showRedTips(false)
	self._ccbOwner.tf_lock:setString("未装备")
	self._ccbOwner.node_plus:setVisible(false)
end

function QUIWidgetMountBox:setNoDressTips()
	self:showRedTips(false)
	self._ccbOwner.tf_lock:setVisible(false)
	self._ccbOwner.node_plus:setVisible(false)
	self._ccbOwner.node_talent:setVisible(true)
end

function QUIWidgetMountBox:setGrade(grade)
	if self._mountInfo and self._mountInfo.zuoqiId then
		self._characterConfig = db:getCharacterByID(self._mountInfo.zuoqiId)
		if self._characterConfig and self._characterConfig.aptitude == APTITUDE.SSR  then
			if grade == 0 then
	    		self._star:setEmptyStar()
	    	else
	    		self._star:setStar((grade or 1))
	    	end
	    else
	    	self._star:setStar((grade or 0) + 1)
		end
	end
end

function QUIWidgetMountBox:setStarVisible(b)
	self._ccbOwner.node_star:setVisible(b)
end

function QUIWidgetMountBox:checkTips()
	local uiHeroModel = remote.herosUtil:getUIHeroByID(self._actorId)
	local isTips = uiHeroModel:checkHerosMountRedTips() or uiHeroModel:getMountDressingTip() or uiHeroModel:getMountGraveTip()
	self:showRedTips(isTips)
end

function QUIWidgetMountBox:showRedTips(b)
	self._ccbOwner.sp_red_tips:setVisible(b)
end

function QUIWidgetMountBox:setTipsScale(scale)
	self._ccbOwner.sp_red_tips:setScale(scale)
end

function QUIWidgetMountBox:isShowLevel(isVisible)
	self._ccbOwner.node_level:setVisible(isVisible)
end

function QUIWidgetMountBox:setMountInfo(mountInfo)
	self:resetAll()
	self._mountInfo = mountInfo
	if self._mountInfo == nil then
		self._ccbOwner.node_plus:setVisible(true)
		self._ccbOwner.tf_plus_tips:setString("可装备")
		self._ccbOwner.tf_lock:setString("")
	else
		self._ccbOwner.tf_lock:setVisible(false)
		self:setGoodsInfo(self._mountInfo.zuoqiId, ITEM_TYPE.ZUOQI)
		self._ccbOwner.node_level:setVisible(true)
		self._ccbOwner.tf_level:setString(self._mountInfo.enhanceLevel)

		self._ccbOwner.node_star:setVisible(true)
		-- self._star:setStar(self._mountInfo.grade+1)

		local characher = db:getCharacterByID(self._mountInfo.zuoqiId)
		local sabcInfo = db:getSABCByQuality(characher.aptitude)
		self:showSabc(sabcInfo.lower)

		if characher.aptitude == APTITUDE.SSR then
			if self._mountInfo.grade == 0 then
				self._star:setEmptyStar()
			else
				self._star:setStar(self._mountInfo.grade)
			end
		else
			self._star:setStar(self._mountInfo.grade+1)
		end		
	end
end

--当作暗器来显示
function QUIWidgetMountBox:setGoodsInfo(itemID)
	local heroDisplay = db:getCharacterByID(itemID)
	if nil ~= heroDisplay then 
		self:setItemIcon(heroDisplay.icon)
		for _,value in ipairs(HERO_SABC) do
	        if value.aptitude == tonumber(heroDisplay.aptitude) then
	        	local colour = value.color or "default"
	        	self:addSpriteFrame(self._ccbOwner.node_rect, QUIWidgetItemsBox.color_frame[colour][1])
				break
	        end
	    end
	end
end

function QUIWidgetMountBox:showSabc( quality )
	local icon = CCSprite:create(QResPath("itemBoxPingZhi_"..quality))
	if icon then
		if quality == "a+" or quality == "ss" then
			icon:setPositionX(10)
		end
		self._ccbOwner.node_pingzhi:addChild(icon)
	end
end

function QUIWidgetMountBox:addSpriteFrame(sp, frameName)
	if string.find(frameName, "%.plist") ~= nil then
		sp:setDisplayFrame(QSpriteFrameByPath(frameName))
	else
		local texture = CCTextureCache:sharedTextureCache():addImage(frameName)
		sp:setTexture(texture)
		local size = texture:getContentSize()
		local rect = CCRectMake(0, 0, size.width, size.height)
		sp:setTextureRect(rect)
	end
end

--设置icon
function QUIWidgetMountBox:setItemIcon(respath)
	if respath~=nil and #respath > 0 then
		local icon = CCSprite:create()
		self._ccbOwner.node_icon:addChild(icon)
		icon:setTexture(CCTextureCache:sharedTextureCache():addImage(respath))
		icon:setScale(1)
		local size = self._ccbOwner.sp_bg:getContentSize()
		icon:setScale(size.width/icon:getContentSize().width)
	end
end

--设置icon
function QUIWidgetMountBox:showDressMountLevel()
	self._ccbOwner.node_dress:setVisible(false)
	local grade
	if self._mountInfo and self._mountInfo.wearZuoqiInfo then
		grade = self._mountInfo.wearZuoqiInfo.grade
	end
	if grade == nil then
		return
	end

	local iconPath = QResPath("mount_dress_star")[grade+1]
	if iconPath then
		local texture = CCTextureCache:sharedTextureCache():addImage(iconPath)
		self._ccbOwner.sp_dress_level:setTexture(texture)
		self._ccbOwner.node_dress:setVisible(true)
	end
end

--设置雕刻等级
function QUIWidgetMountBox:showGraveMountLevel()
	print("设置雕刻等级----")
	self._ccbOwner.node_grave:setVisible(false)
	QPrintTable(self._mountInfo)
	local graveLevel = 0
	if self._mountInfo then
		graveLevel = self._mountInfo.grave_level or 0
	end
	if graveLevel > 0 then
		self._ccbOwner.tf_grave_level:setString("刻"..graveLevel)
		self._ccbOwner.node_grave:setVisible(true)
	end

	
end

function QUIWidgetMountBox:_onTriggerClick()
	local mountId = nil
	if self._mountInfo ~= nil then
		mountId = self._mountInfo.zuoqiId
	end
	self:dispatchEvent({name = QUIWidgetMountBox.MOUNT_EVENT_CLICK, mountId = mountId})
end

return QUIWidgetMountBox