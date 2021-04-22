
local QMountSkillView = class("QMountSkillView", function()
    return display.newNode()
end)

function QMountSkillView:ctor(options)
    local ccbFile = "ccb/effects/zuoqi_charu_r.ccbi"
    local proxy = CCBProxy:create()
    self._ccbOwner = {}        
    local ccbView = CCBuilderReaderLoad(ccbFile, proxy, self._ccbOwner)
    if ccbView == nil then
        assert(false, "load ccb file:" .. ccbFile .. " faild!")
    end
    self:addChild(ccbView)

    ccbView:setVisible(false)
    self._ccbView = ccbView
    ccbFile = "ccb/Battle_ss_skill.ccbi"
    local proxy = CCBProxy:create()
    self._super_ccbOwner = {}        
    local ccbView = CCBuilderReaderLoad(ccbFile, proxy, self._super_ccbOwner)
    if ccbView == nil then
        assert(false, "load ccb file:" .. ccbFile .. " faild!")
    end
    self:addChild(ccbView)
    ccbView:setVisible(false)
    self._super_ccbView = ccbView
	self._isAvailable = true
	
end

function QMountSkillView:playAnimation(portraitFile, labelFile, isSuperHero)
    if portraitFile == nil then
        return
    end
    self._super_ccbView:setVisible(isSuperHero)
    self._ccbView:setVisible(not isSuperHero)
    local ccbView = isSuperHero and self._super_ccbView or self._ccbView
    local ccbOwner = isSuperHero and self._super_ccbOwner or self._ccbOwner
	local texture = CCTextureCache:sharedTextureCache():addImage(portraitFile)
	if texture then
        local size = texture:getContentSize()
        local rect = CCRectMake(0, 0, size.width, size.height)
        ccbOwner.sprite_portrait:setDisplayFrame(CCSpriteFrame:createWithTexture(texture, rect))
        local animationManager = tolua.cast(ccbView:getUserObject(), "CCBAnimationManager")
        if animationManager ~= nil then
        	animationManager:stopAnimation()
            animationManager:runAnimationsForSequenceNamed("Default Timeline")
	        animationManager:connectScriptHandler(function(...)
	            animationManager:disconnectScriptHandler()
	            self._isAvailable = true
	            ccbView:setVisible(false)
	        end)
	        self._isAvailable = false
	        ccbView:setVisible(true)
        end
	end
    if labelFile == nil then
        return
    end
    local texture = CCTextureCache:sharedTextureCache():addImage(labelFile)
    if texture then
        local size = texture:getContentSize()
        local rect = CCRectMake(0, 0, size.width, size.height)
        ccbOwner.sprite_skill:setDisplayFrame(CCSpriteFrame:createWithTexture(texture, rect))
    end
end

function QMountSkillView:isAvailable()
	return self._isAvailable
end

function QMountSkillView:purge()
    local animationManager = tolua.cast(self._ccbView:getUserObject(), "CCBAnimationManager")
    if animationManager then
    	animationManager:stopAnimation()
    	animationManager:disconnectScriptHandler()
    end
    local animationManager = tolua.cast(self._super_ccbView:getUserObject(), "CCBAnimationManager")
    if animationManager then
        animationManager:stopAnimation()
        animationManager:disconnectScriptHandler()
    end
end

local _setScaleX = CCNode.setScaleX
function QMountSkillView:setScaleX(scaleX)
    _setScaleX(self, scaleX)
    self._ccbOwner.sprite_skill:setScaleX((scaleX > 0) and 1 or -1)
    self._super_ccbOwner.sprite_skill:setScaleX((scaleX > 0) and 1 or -1)
end

return QMountSkillView