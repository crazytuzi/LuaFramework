-- @Author: liaoxianbo
-- @Date:   2019-06-21 11:48:23
-- @Last Modified by:   liaoxianbo
-- @Last Modified time: 2019-11-04 10:50:06
local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogBlackSoulSpiritDetail = class("QUIDialogBlackSoulSpiritDetail", QUIDialog)

local QNavigationController = import("...controllers.QNavigationController")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QUIViewController = import("..QUIViewController")
local QUIWidgetActorDisplay = import("..widgets.actorDisplay.QUIWidgetActorDisplay")

function QUIDialogBlackSoulSpiritDetail:ctor(options)
	local ccbFile = "ccb/Dialog_hunlingjieshao.ccbi"
    local callBacks = {
		{ccbCallbackName = "onTriggerClose", callback = handler(self, self._onTriggerClose)},
    }
    QUIDialogBlackSoulSpiritDetail.super.ctor(self, ccbFile, callBacks, options)
    self.isAnimation = true
    -- self._page = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
    -- self._page:setManyUIVisible()
    -- self._page:setScalingVisible(false)
    -- self._page.topBar:hideAll()

	cc.GameObject.extend(self)
	self:addComponent("components.behavior.EventProtocol"):exportMethods()

	CalculateUIBgSize(self._ccbOwner.sp_back_mark)
	
    if options then
    	self._callBack = options.callBack
    	self._id = options.id
    	self._sourList = options.soulSpiritList
    end
end

function QUIDialogBlackSoulSpiritDetail:viewDidAppear()
	QUIDialogBlackSoulSpiritDetail.super.viewDidAppear(self)

	-- self:addBackEvent(true)

	self:showSourSpritDetail()
	-- self._ccbOwner.node_hero:setVisible(false)
end

function QUIDialogBlackSoulSpiritDetail:showSourSpritDetail()
	local owner = self._ccbOwner
	local info = db:getCharacterByID(self._id)
	-- local dialogDisplay = db:getDialogDisplay()[tostring(self._id)]

	owner.tf_soul_name:setVisible(false)

	-- owner.node_hero:setVisible(false)

	if self._actorDisplay ~= nil then
		self._actorDisplay:removeFromParent()
		self._actorDisplay = nil
	end

	-- self._actorDisplay = QUIWidgetActorDisplay.new(info.id)
	-- self._actorDisplay:setAnchorPoint(ccp(0.5,0.5))
	-- self._actorDisplay:setScaleX(-1.5)
	-- self._actorDisplay:setScaleY(1.5)
	-- self._ccbOwner.node_actHero:addChild(self._actorDisplay)
	-- self._ccbOwner.node_actHero:setPosition(ccp(-200,-140))
	-- 半身像
	-- owner.node_hero:removeAllChildren()
	if info.visitingBigCard  then
		local sprite = owner.sp_hero
		local texture = CCTextureCache:sharedTextureCache():addImage(info.visitingBigCard)
		if texture then
			sprite:setTexture(texture)
		end

	end

	-- 品质
	local aptitudeInfo = QStaticDatabase:sharedDatabase():getActorSABC(self._id)
	q.setAptitudeShow(owner, aptitudeInfo.lower)

	owner.node_ditu:setVisible(false)
	owner.node_h:setVisible(true)
	if aptitudeInfo.lower == "s" then
		owner.sp_s:setVisible(true)
		owner.sp_a:setVisible(false)
	else
		owner.sp_s:setVisible(false)
		owner.sp_a:setVisible(true)		
	end
	-- if aptitudeInfo.lower == "a+" then
	-- 	owner.tf_boss_name:setPositionX(owner.tf_boss_name:getPositionX()+40)
	-- end
	
	--魂师名字
	if info.show_name then
		local spriteFrame = QSpriteFrameByPath(info.show_name)
		if spriteFrame then
			owner.tf_boss_name:setDisplayFrame(spriteFrame)
		end
	end

	--魂师定位
	if info.show_definition then
		local spriteFrame = QSpriteFrameByPath(info.show_definition)
		if spriteFrame then
			owner.sp_boss_des:setDisplayFrame(spriteFrame)
		end		
	end
	-- 攻略技巧
	if info.desc_1 then
		local tbl = string.split(info.desc_1, ";")
		local index = 1
		while true do
			local tf = self._ccbOwner["tf_boss_desc_"..index]
			if tf then
				if tbl[index] then
					tf:setString(index.."、"..tbl[index])
				else
					tf:setString("")
				end
				index = index + 1
			else
				break
			end
		end
		self._ccbOwner.node_boss_desc:setVisible(true)
	else
		self._ccbOwner.node_boss_desc:setVisible(false)
	end
end

function QUIDialogBlackSoulSpiritDetail:viewWillDisappear()
  	QUIDialogBlackSoulSpiritDetail.super.viewWillDisappear(self)

	-- self:removeBackEvent()
end

function QUIDialogBlackSoulSpiritDetail:_backClickHandler()
	self._ccbOwner.sp_back_mark:setVisible(false)
    self:_onTriggerClose()
	-- local animationManager = tolua.cast(self._view:getUserObject(), "CCBAnimationManager")
	-- animationManager:stopAnimation()
	-- animationManager:runAnimationsForSequenceNamed("end")
	-- animationManager:connectScriptHandler(function()
	-- 	self:_onTriggerClose()
	-- end)
end

function QUIDialogBlackSoulSpiritDetail:_onTriggerClose()
  	app.sound:playSound("common_close")
	self:playEffectOut()
end

function QUIDialogBlackSoulSpiritDetail:viewAnimationOutHandler()
	local callback = self._callBack

	self:popSelf()

	if callback then
		callback()
	end
end

return QUIDialogBlackSoulSpiritDetail
