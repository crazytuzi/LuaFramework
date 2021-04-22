-- @Author: xurui
-- @Date:   2019-01-16 18:25:53
-- @Last Modified by:   xurui
-- @Last Modified time: 2019-01-25 14:22:07
local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogHeroSkinTip = class("QUIDialogHeroSkinTip", QUIDialog)

local QNavigationController = import("...controllers.QNavigationController")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QUIViewController = import("..QUIViewController")

function QUIDialogHeroSkinTip:ctor(options)
	local ccbFile = "ccb/Dialog_jinengxinxi.ccbi"
    local callBacks = {
		{ccbCallbackName = "onTriggerClose", callback = handler(self, self._onTriggerClose)},
    }
    QUIDialogHeroSkinTip.super.ctor(self, ccbFile, callBacks, options)
    self.isAnimation = true

	cc.GameObject.extend(self)
	self:addComponent("components.behavior.EventProtocol"):exportMethods()

    if options then
    	self._callBack = options.callBack
    	self._skinId = options.skinId
    	self._heroId = options.heroId
    end

    self._ccbOwner.node_type:setVisible(false)
    self._ccbOwner.node_line:setVisible(false)
    self._ccbOwner.node_damage:setVisible(false)
    self.size = self._ccbOwner.skill_bg:getContentSize()
end

function QUIDialogHeroSkinTip:viewDidAppear()
	QUIDialogHeroSkinTip.super.viewDidAppear(self)

	self:setSkinInfo()
end

function QUIDialogHeroSkinTip:viewWillDisappear()
  	QUIDialogHeroSkinTip.super.viewWillDisappear(self)
end

function QUIDialogHeroSkinTip:setSkinInfo()
	self._skinInfo = remote.heroSkin:getHeroSkinBySkinId(self._heroId, self._skinId)

	self._ccbOwner.tf_desc_title:setString("皮肤故事")

    self._ccbOwner.skill_name:setString(self._skinInfo.skins_name or "")
    self._ccbOwner.skill_name:setPositionY(-32)
    self._ccbOwner.skill_dec:setString(self._skinInfo.skins_story or "")

    local descHeight = self._ccbOwner.skill_dec:getContentSize().height
    self._ccbOwner.skill_bg:setContentSize(CCSize(self.size.width, self.size.height - 100 + descHeight))

    if self._skinInfo.skins_head_icon then
    	self:setIconPath(self._skinInfo.skins_head_icon)
    end
end

function QUIDialogHeroSkinTip:setIconPath(path)
    if self._skillIcon == nil then
        self._skillIcon = CCSprite:create()
        self._ccbOwner.node_icon:addChild(self._skillIcon)
    end
    self._skillIcon:setTexture(CCTextureCache:sharedTextureCache():addImage(path))
end

function QUIDialogHeroSkinTip:_backClickHandler()
    self:_onTriggerClose()
end

function QUIDialogHeroSkinTip:_onTriggerClose()
  	app.sound:playSound("common_close")
	self:playEffectOut()
end

function QUIDialogHeroSkinTip:viewAnimationOutHandler()
	local callback = self._callBack

	self:popSelf()

	if callback then
		callback()
	end
end

return QUIDialogHeroSkinTip
