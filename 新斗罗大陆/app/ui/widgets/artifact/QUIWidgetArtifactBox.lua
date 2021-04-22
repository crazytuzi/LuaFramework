-- 
-- 武魂真身icon
-- zxs
--

local QUIWidget = import("...widgets.QUIWidget")
local QUIWidgetArtifactBox = class("QUIWidgetArtifactBox", QUIWidget)

local QUIWidgetItemsBox = import("...widgets.QUIWidgetItemsBox")
local QUIWidgetHeroHeadStar = import("...widgets.QUIWidgetHeroHeadStar")
local QUIViewController = import("...QUIViewController")

QUIWidgetArtifactBox.ARTIFACT_EVENT_CLICK = "ARTIFACT_EVENT_CLICK"

function QUIWidgetArtifactBox:ctor(options)
	local ccbFile = "ccb/Widget_weapon_box.ccbi"
	local callBacks = {
        {ccbCallbackName = "onTriggerClick", callback = handler(self, self._onTriggerClick)},
    }
	QUIWidgetArtifactBox.super.ctor(self, ccbFile, callBacks, options)

	cc.GameObject.extend(self)
    self:addComponent("components.behavior.EventProtocol"):exportMethods()

	self._star = QUIWidgetHeroHeadStar.new({})
	self._ccbOwner.node_star:setScale(0.8)
	self._ccbOwner.node_star:addChild(self._star)

	self._lockConfig = app.unlock:getConfigByKey("UNLOCK_ARTIFACT")
	local lockStr = self._lockConfig.hero_level.."级\n开启"
	self._ccbOwner.tf_lock:setString(lockStr)

	self:resetAll()
end

function QUIWidgetArtifactBox:resetAll()
	self._ccbOwner.node_level:setVisible(false)
	self._ccbOwner.node_star:setVisible(false)
	self._ccbOwner.node_plus:setVisible(false)
	self._ccbOwner.node_talent:setVisible(false)
	self._ccbOwner.sp_red_tips:setVisible(false)
	self._ccbOwner.sp_select:setVisible(false)
	self._ccbOwner.sp_mount_icon:setVisible(false)
	self._ccbOwner.sp_artifact_icon:setVisible(true)
	self._ccbOwner.tf_lock:setVisible(true)
	self._ccbOwner.node_icon:removeAllChildren()
	self._ccbOwner.node_pingzhi:removeAllChildren()
	self._ccbOwner.tf_plus_tips:setString("")

	self:addSpriteFrame(self._ccbOwner.node_rect, QUIWidgetItemsBox.color_frame["default"][1])
end

function QUIWidgetArtifactBox:setHighlightedSelectState(state)
    if state == nil then state = false end
    
    self._ccbOwner.sp_select:setVisible(state)
end

--设置魂师
function QUIWidgetArtifactBox:setHero(actorId, isPreview)
	self._actorId = actorId
	self._artifactId = remote.artifact:getArtiactByActorId(actorId)
	self:refreshBox(isPreview)
	self:checkTips()
end

--刷新格子
function QUIWidgetArtifactBox:refreshBox(isPreview)
	self._heroInfo = remote.herosUtil:getHeroByID(self._actorId)
	-- QKumo(self._heroInfo)
	if not self._heroInfo then
		return
	end
	if self._lockConfig.hero_level > self._heroInfo.level then
		self:resetAll()
		local lockStr = self._lockConfig.hero_level.."级\n开启"
		self._ccbOwner.tf_lock:setString(lockStr)
	else
		self:setArtifactInfo(self._heroInfo.artifact, isPreview)
	end
end

function QUIWidgetArtifactBox:setNoWearTips()
	self:showRedTips(false)
	self._ccbOwner.tf_lock:setString("未觉醒")
	self._ccbOwner.node_plus:setVisible(false)
end

function QUIWidgetArtifactBox:setGrade(grade)
	self._star:setStar(grade)
end

function QUIWidgetArtifactBox:setStarVisible(b)
	self._ccbOwner.node_star:setVisible(b)
end

function QUIWidgetArtifactBox:checkTips()
	local uiHeroModel = remote.herosUtil:getUIHeroByID(self._actorId)
	self:showRedTips(uiHeroModel:checkHerosArtifactRedTips())
end

function QUIWidgetArtifactBox:showRedTips(b)
	self._ccbOwner.sp_red_tips:setVisible(b)
end

function QUIWidgetArtifactBox:setTipsScale(scale)
	self._ccbOwner.sp_red_tips:setScale(scale)
end

function QUIWidgetArtifactBox:isShowLevel(isVisible)
	self._ccbOwner.node_level:setVisible(isVisible)
end

function QUIWidgetArtifactBox:setArtifactInfo(artifactInfo, isPreview)
	self:resetAll()
	self._artifactInfo = artifactInfo
	if self._artifactInfo == nil and not isPreview then
		self._ccbOwner.node_plus:setVisible(true)
		local uiHeroModel = remote.herosUtil:getUIHeroByID(self._actorId)
		if uiHeroModel:getArtifactState() == remote.artifact.STATE_CAN_WEAR then
			self._ccbOwner.tf_plus_tips:setString("可觉醒")
		else
			self._ccbOwner.tf_plus_tips:setString("可获得")
		end
		self._ccbOwner.tf_lock:setString("")
	else
		self._ccbOwner.tf_lock:setVisible(false)
		if self._artifactInfo then
			self:setGrade(self._artifactInfo.artifactBreakthrough or 0)
			self._ccbOwner.tf_level:setString(self._artifactInfo.artifactLevel or 1)
		else
			self:setGrade(0)
			self._ccbOwner.tf_level:setString(1)
		end
		self:setGoodsInfo(self._actorId, self._artifactId)
		self._ccbOwner.node_level:setVisible(true)
		self._ccbOwner.node_star:setVisible(true)

		local characher = db:getCharacterByID(self._actorId)
		local sabcInfo = db:getSABCByQuality(characher.aptitude)
		self:showSabc(sabcInfo.lower)
	end
end

--当作来显示
function QUIWidgetArtifactBox:setGoodsInfo(actorId, itemId)
	local itemInfo = db:getItemByID(itemId)
	if itemInfo then 
		self:setItemIcon(itemInfo.icon)
	end
	local heroDisplay = db:getCharacterByID(actorId)
	if heroDisplay then 
		for _,value in ipairs(HERO_SABC) do
	        if value.aptitude == tonumber(heroDisplay.aptitude) then
	        	local colour = value.color or "default"
	        	self:addSpriteFrame(self._ccbOwner.node_rect, QUIWidgetItemsBox.color_frame[colour][1])
				break
	        end
	    end
	end
end

function QUIWidgetArtifactBox:showSabc( quality )
	local icon = CCSprite:create(QResPath("itemBoxPingZhi_"..quality))
	if icon then
		if quality == "a+" or quality == "ss" then
			icon:setPositionX(10)
		end
		self._ccbOwner.node_pingzhi:addChild(icon)
	end
end

function QUIWidgetArtifactBox:addSpriteFrame(sp, frameName)
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
function QUIWidgetArtifactBox:setItemIcon(respath)
	if respath~=nil and #respath > 0 then
		local icon = CCSprite:create()
		self._ccbOwner.node_icon:addChild(icon)
		icon:setTexture(CCTextureCache:sharedTextureCache():addImage(respath))
		icon:setScale(1)
		local size = self._ccbOwner.sp_bg:getContentSize()
		icon:setScale(size.width/icon:getContentSize().width)
	end
end

function QUIWidgetArtifactBox:_onTriggerClick()
	local artifactId = nil
	if self._artifactInfo ~= nil then
		artifactId = self._artifactInfo.artifactId
	end
	self:dispatchEvent({name = QUIWidgetArtifactBox.ARTIFACT_EVENT_CLICK, artifactId = artifactId})
end

return QUIWidgetArtifactBox