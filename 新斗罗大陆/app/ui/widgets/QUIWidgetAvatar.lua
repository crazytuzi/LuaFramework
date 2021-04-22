-- @Author: qinyuanji
-- @Date:   2016-08-26 15:13:30
-- @Last Modified by:   liaoxianbo
-- @Last Modified time: 2019-06-24 11:44:09
local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetAvatar = class("QUIWidgetAvatar", QUIWidget)

local QStaticDatabase = import("...controllers.QStaticDatabase")

QUIWidgetAvatar.CLICK = "AVATAR_CLICK"
local RADIUS = 48

function QUIWidgetAvatar:ctor(avatar, level, lock)
	local ccbFile = "ccb/Widget_Circle_head.ccbi"
	local callBacks = {
        {ccbCallbackName = "onTriggerClick", callback = handler(self, self._onTriggerClick)},
    }
	QUIWidgetAvatar.super.ctor(self, ccbFile, callBacks, options)
	
  	cc.GameObject.extend(self)
  	self:addComponent("components.behavior.EventProtocol"):exportMethods()

	self._isUnion = false
	self._ccbOwner.node_union:setVisible(false)
	self._ccbOwner.node_soulTrial:removeAllChildren()
	self._ccbOwner.node_special_info:setVisible(false)
	
	if avatar ~= nil then
		self:setInfo(avatar or -1, level, lock)
	end
end

function QUIWidgetAvatar:initGLLayer(glLayerIndex)
	self._glLayerIndex = glLayerIndex or 1
	self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.sp_bg, self._glLayerIndex)
	self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.is_select, self._glLayerIndex)
	self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.node_setting_select, self._glLayerIndex)
	self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.click_box, self._glLayerIndex)
	if self._bg then
		self._glLayerIndex = q.nodeAddGLLayer(self._bg, self._glLayerIndex)
	end
	if self._frameBottom then
		self._glLayerIndex = q.nodeAddGLLayer(self._frameBottom, self._glLayerIndex)
	end
	-- self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.tf_special_number, self._glLayerIndex)
	-- self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.sp_special_guan, self._glLayerIndex)
	if self._animationBottom then
		self._glLayerIndex = q.nodeAddGLLayer(self._animationBottom, self._glLayerIndex)
	end
	if self._avatar then
		self._glLayerIndex = q.nodeAddGLLayer(self._avatar, self._glLayerIndex)
	end
	if self._frame then
		self._glLayerIndex = q.nodeAddGLLayer(self._frame, self._glLayerIndex)
	end
	if self._animation then
		self._glLayerIndex = q.nodeAddGLLayer(self._animation, self._glLayerIndex)
	end
	if self._levelSp then
		self._glLayerIndex = q.nodeAddGLLayer(self._levelSp, self._glLayerIndex)
	end
	if self._level then
		self._glLayerIndex = q.nodeAddGLLayer(self._level, self._glLayerIndex)
	end
	if self._lockIcon then
		self._glLayerIndex = q.nodeAddGLLayer(self._lockIcon, self._glLayerIndex)
	end
	self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.tf_frame_name, self._glLayerIndex)
	self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.node_setting_use, self._glLayerIndex)
	self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.node_soulTrial, self._glLayerIndex)
	self._glLayerIndex = q.nodeAddGLLayer(self._soulIcon, self._glLayerIndex)

	return self._glLayerIndex
end

function QUIWidgetAvatar:onEnter()
end

function QUIWidgetAvatar:onExit()
end

function QUIWidgetAvatar:getDefaultAvatar(avatarId)
	return remote.headProp:getDefaultAvatar(avatarId)
end

function QUIWidgetAvatar:getDefaultFrame(frameId)
	return remote.headProp:getDefaultFrame(frameId)
end

-- avatar: avatarId + frameId
function QUIWidgetAvatar:setInfo(avatar, level, lock, index)
	self._index = index
	avatar = avatar or -1
	avatar = tonumber(avatar) or -1
	self._avatarId, self._frameId = remote.headProp:getAvatarFrameId(avatar)

	self:setAvatarType()
	self:updateFrameBg()
	self:updateFrameBottom(self._frameId)
	self:updateAvatar(self._avatarId)
	self:updateFrame(self._frameId)
	self:showLevel(level)
	self:showLock(lock)
end

-- avatar: avatarId + frameId
function QUIWidgetAvatar:setSpecialInfo(avatar, level, lock, index)
	self._index = index
	avatar = tonumber(avatar) or -1
	self._avatarId, self._frameId = remote.headProp:getAvatarFrameId(avatar)

	self:setAvatarType()
	self:updateFrameBg()
	self:updateAvatar(self._avatarId, true)
	self:updateFrameBottom(self._frameId)
	self:updateFrame(self._frameId)
	self:showLevel(level)
	self:showLock(lock)
end

function QUIWidgetAvatar:setAvatarType()
end

function QUIWidgetAvatar:updateAvatar(avatarId, isClipping)
	if self._avatar then
		self._avatar:removeFromParent()
		self._avatar = nil
	end

	local avatarConfig = self:getDefaultAvatar(avatarId)
    local texture = CCTextureCache:sharedTextureCache():addImage(avatarConfig.icon)
    if texture and avatarId ~= 0 then
    	self._avatar = CCSprite:createWithTexture(texture)
		if not self._isUnion then
			self._avatar:setPositionY(15)
		end
		if isClipping then
   			local size = self._ccbOwner.node_icon_size:getContentSize()
			local ccclippingNode = CCClippingNode:create()
		    local layer = CCLayerColor:create(ccc4(100, 0, 0, 0), size.width, size.height)
		    layer:setPosition(-size.width/2, -size.height/2)
		    ccclippingNode:setStencil(layer)
		    ccclippingNode:addChild(self._avatar)
		    self._ccbOwner.node_avatar:addChild(layer)
		    self._ccbOwner.node_avatar:addChild(ccclippingNode)
		else
			self._ccbOwner.node_avatar:addChild(self._avatar)
		end
    end

    self._avatarId = avatarId
end

function QUIWidgetAvatar:updateFrameBg()
	if not self._bg then
	 	local iconPath = QResPath("default_user_avatar")
	    iconPath = QSpriteFrameByPath(iconPath[1])
		self._bg = CCSprite:createWithSpriteFrame(iconPath)
		self._ccbOwner.node_avatar:addChild(self._bg)
	end

	self._bg:setVisible( not self._isUnion )
end

function QUIWidgetAvatar:updateFrameBottom(frameId)
	if self._frameBottom then
		self._frameBottom:removeFromParent()
		self._frameBottom = nil
	end

	local frameConfig = self:getDefaultFrame(frameId)
	if not frameConfig.icon_bottom then return end

    local texture = CCTextureCache:sharedTextureCache():addImage(frameConfig.icon_bottom)
    if texture then
        self._frameBottom = CCSprite:createWithTexture(texture)
        if not self._isUnion then
        	self._frameBottom:setPositionY(15)
        end
        self._ccbOwner.node_avatar:addChild(self._frameBottom)
        self._frameId = frameId
    end

    self:showAnimationBottom(frameConfig.animationBottom)
end

function QUIWidgetAvatar:setSilvesArenaPeak(championCount)
	-- if self._frameId and self._frameId == 810000 and championCount and championCount >= 1 then
	-- 	self._ccbOwner.tf_special_number:setString(winCount)
	-- 	self._ccbOwner.node_special_info:setVisible(true)
	-- 	if not self._isUnion then
 --        	self._ccbOwner.node_special_info:setPositionY(15)
 --        end
	-- else
	-- 	self._ccbOwner.node_special_info:setVisible(false)
	-- end
end

function QUIWidgetAvatar:updateFrame(frameId)
	if self._frame then
		self._frame:removeFromParent()
		self._frame = nil
	end
	
	local frameConfig = self:getDefaultFrame(frameId)
    local texture = CCTextureCache:sharedTextureCache():addImage(frameConfig.icon)
    if texture then
        self._frame = CCSprite:createWithTexture(texture)
        self._ccbOwner.node_avatar:addChild(self._frame)
        if self._frameBottom then
        	if not self._isUnion then
        		self._frame:setPositionY(15)
        	end
        end
    end

    self:showAnimation(frameConfig.animation)
    self._frameId = frameId
end

function QUIWidgetAvatar:showLevel(level)
	if level and level > 0 then
		self._levelString = level
		if self._level then
			self._level:removeFromParent()
			self._level = nil 
		end
		
		local levelSp = CCSprite:create()
		levelSp:setPosition(-51, 30)
	    local frame = QResPath(self._masterType.."icon")
	    frame = QSpriteFrameByPath(frame[1])
	    if frame then
			levelSp:addChild(CCSprite:createWithSpriteFrame(frame))
		end
		self._level = ui.newBMFontLabel({
		    text = "0",
		    font = "font/FontHeroHeadLevel.fnt",
		})
		self._level:setGap(-2)
		levelSp:addChild(self._level)
		self._level:setString(level)
		self._ccbOwner.node_avatar:addChild(levelSp)
		self._levelSp = levelSp
	else
		if self._level then
			self._level:removeFromParent()
			self._level = nil 
		end
	end
end

function QUIWidgetAvatar:showLock(visible)
	if visible then
		self._locked = true
		if self._lockIcon then
			self._lockIcon:removeFromParent()
			self._lockIcon = nil
		end

	    local iconPath = QResPath("default_user_avatar_lock")
	    iconPath = QSpriteFrameByPath(iconPath[1])
		self._lockIcon = CCSprite:createWithSpriteFrame(iconPath)
		self._lockIcon:setScale(0.4)
		self._lockIcon:setPosition(ccp(-36, 40))
		self._ccbOwner.node_avatar:addChild(self._lockIcon)
	else
		self._locked = false
		if self._lockIcon then
			self._lockIcon:removeFromParent()
			self._lockIcon = nil
		end
	end
end

function QUIWidgetAvatar:showAnimationBottom(animation)
	if animation then
		local ccbFile = animation
		if self._animationBottom then
			self._animationBottom:removeFromParent()
			self._animationBottom = nil
		end

		local proxy = CCBProxy:create()
		local ccbOwner = {}
	    self._animationBottom = CCBuilderReaderLoad(ccbFile, proxy, ccbOwner)
	    self._ccbOwner.node_avatar:addChild(self._animationBottom)
	    if not self._isUnion then
    		self._animationBottom:setPositionY(5)
    	end
	else
		if self._animationBottom then
			self._animationBottom:removeFromParent()
			self._animationBottom = nil 
		end
	end
end

function QUIWidgetAvatar:showAnimation(animation)
	if animation then
		local ccbFile = animation
		if self._animation then
			self._animation:removeFromParent()
			self._animation = nil
		end

		local proxy = CCBProxy:create()
		local ccbOwner = {}
	    self._animation = CCBuilderReaderLoad(ccbFile, proxy, ccbOwner)
	    self._ccbOwner.node_avatar:addChild(self._animation)
	    if not self._isUnion then
    		self._animation:setPositionY(5)
    	end
	else
		if self._animation then
			self._animation:removeFromParent()
			self._animation = nil 
		end
	end
end

function QUIWidgetAvatar:setSelectState(state)	
	if state == nil then state = false end
	self._ccbOwner.is_select:setVisible(state)
end

function QUIWidgetAvatar:setUseState(state)	
	if state == nil then state = false end
	self._ccbOwner.node_setting_use:setVisible(state)
end


function QUIWidgetAvatar:getContentSize()
	return self._ccbOwner.node_size:getContentSize()
end

function QUIWidgetAvatar:getFrameId()
	return self._frameId
end

function QUIWidgetAvatar:getAvatarId()
	return self._avatarId
end

function QUIWidgetAvatar:_onTriggerClick(event)
	self:dispatchEvent({name = QUIWidgetAvatar.CLICK, avatar = remote.headProp:getAvatar(self._avatarId, self._frameId), locked = self._locked or false,
		level = self._levelString or -1, index = self._index})
end

function QUIWidgetAvatar:setSoulTrial( soulTrial, headScale, headPos, gapY )
	if not soulTrial or soulTrial == 0 then 
		self:_resetSoulTrial()
		return 
	end
	
	local gapY = gapY or 15
	local _, passChapter = remote.soulTrial:getCurChapter( soulTrial )
	local curBossConfig = remote.soulTrial:getBossConfigByChapter( passChapter )
	local url = curBossConfig.title_icon3

	if not url then
		self:_resetSoulTrial()
		return
	end

	local sprite = CCSprite:create(url)
	local headScale = headScale or 1
	local headPos = headPos or ccp(0, 0)
	if sprite then
		self._ccbOwner.node_normalAvatar:setScale(headScale)
		self._ccbOwner.node_normalAvatar:setPosition(headPos)
		self._ccbOwner.node_normalAvatar:setVisible(true)

		local size = self._ccbOwner.node_icon_size:getContentSize()
		local stPos = ccp(headPos.x, headPos.y -(size.height*headScale/2 + gapY))
		self._ccbOwner.node_soulTrial:removeAllChildren()
		self._ccbOwner.node_soulTrial:addChild(sprite)
		self._ccbOwner.node_soulTrial:setPosition(stPos)
		self._ccbOwner.node_soulTrial:setVisible(true)

		self._soulIcon = sprite
	else
		self:_resetSoulTrial()
	end
end

function QUIWidgetAvatar:setScaleX(scale)
	self._avatar:setScaleX(scale)
end

function QUIWidgetAvatar:setEnabledClick(flag)
	self._ccbOwner.click_box:setTouchEnabled(flag)
end
function QUIWidgetAvatar:_resetSoulTrial()
	self._ccbOwner.node_normalAvatar:setScale(1)
	self._ccbOwner.node_normalAvatar:setPosition(0, 0)
	self._ccbOwner.node_normalAvatar:setVisible(true)
	self._ccbOwner.node_soulTrial:setVisible(false)
end

return QUIWidgetAvatar