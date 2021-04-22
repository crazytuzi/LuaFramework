--
-- Author: Kumo.Wang
-- 图鉴列表cell
--

local QUIWidget = import(".QUIWidget")
local QUIWidgetHandBookCellNew = class("QUIWidgetHandBookCellNew", QUIWidget)

local QUIWidgetAnimationPlayer = import("..widgets.QUIWidgetAnimationPlayer")
local QUIWidgetHeroProfessionalIcon = import("..widgets.QUIWidgetHeroProfessionalIcon")

QUIWidgetHandBookCellNew.EVENT_HERO_FRAMES_CLICK = "EVENT_HERO_FRAMES_CLICK"

function QUIWidgetHandBookCellNew:ctor(options)
	local ccbFile = "ccb/Widget_Handbook_Cell_New.ccbi"
	local callBacks = {}
	QUIWidgetHandBookCellNew.super.ctor(self,ccbFile,callBacks,options)
end

function QUIWidgetHandBookCellNew:onEnter()
end

function QUIWidgetHandBookCellNew:onExit()
end

function QUIWidgetHandBookCellNew:getContentSize()
	return self._ccbOwner.node_size:getContentSize()
end

function QUIWidgetHandBookCellNew:getActorId()
	return self._actorId
end

--刷新当前信息显示
function QUIWidgetHandBookCellNew:refreshInfo(callback)
	self:setInfo({actorId = self._actorId, curSelectedActorId = self._curSelectedActorId, isRefresh = true, callback = callback})
end

function QUIWidgetHandBookCellNew:setInfo(param)
	self._actorId = tonumber(param.actorId) or 0
	self._curSelectedActorId = tonumber(param.curSelectedActorId)
	self._isRefresh = param.isRefresh or false
	self._callback = param.callback
	self._handBookType = remote.handBook:getHandBookTypeByActorID(self._actorId)
	self._aptitudeInfo = remote.handBook:getHeroAptitudeInfoByActorID(self._actorId)
	self._heroHandBookConfig = remote.handBook:getHeroHandBookConfigByActorID(self._actorId)
	self._handbookState = remote.handBook:getHandbookStateByActorID(self._actorId)

	self._ccbOwner.ccb_selected_effect:setVisible(self._curSelectedActorId == self._actorId)

	self._ccbOwner.node_active_effect:removeAllChildren()

	self:_setHeroInfo()
end

function QUIWidgetHandBookCellNew:_setHeroInfo()
	local heroInfo = remote.handBook:getHeroInfoByActorID(self._actorId)
	if heroInfo then
		self._ccbOwner.tf_hero_name:setString(heroInfo.name)
		self._ccbOwner.tf_hero_name:setVisible(true)
		self:_setHeroCard()
	else
		self._ccbOwner.tf_hero_name:setVisible(false)
	end

	if self._isRefresh and self._ccbOwner.ly_mask:isVisible() and not (self._handbookState == remote.handBook.STATE_NONE or self._handbookState == remote.handBook.STATE_ACTIVATION) then
		print("刷光，之后隐藏遮罩")
		-- 刷光，之后隐藏遮罩
		self._ccbOwner.node_active_effect:removeAllChildren()
		local ccbFile = "ccb/effects/tupo.ccbi"
		local effectShow = QUIWidgetAnimationPlayer.new()
		self._ccbOwner.node_active_effect:addChild( effectShow )
		effectShow:playAnimation(ccbFile, function()
				scheduler.performWithDelayGlobal(function()
					if self._ccbView then
						self._ccbOwner.ly_mask:setVisible( false )
						if self._callback then
							self._callback()
						end
					end
				end, 0.5)
			end, function()  
				effectShow:disappear()
			end)
	else
		self._ccbOwner.ly_mask:setVisible( self._handbookState == remote.handBook.STATE_NONE or self._handbookState == remote.handBook.STATE_ACTIVATION )
	end

	local isRedTips, isShowRedTips, isShowArrowTips = remote.handBook:isRedTipsForHeroHandbook(self._actorId)
	print(heroInfo.name, self._actorId, isRedTips, isShowRedTips, isShowArrowTips, self._handbookState)
	self._ccbOwner.node_tips:setVisible(isRedTips)
	self._ccbOwner.sp_red_tips:setVisible(isShowRedTips)
	
	-- 这里的图几表示图鉴等级（升星）
	local aptitudeInfo = remote.handBook:getHeroAptitudeInfoByActorID(self._actorId)
    if aptitudeInfo.aptitude <= APTITUDE.S then
        self._ccbOwner.sp_god_level:setVisible(false)
    else
		local gradeLevel = remote.handBook:getHandbookLevelByActorID(self._actorId)
	    if gradeLevel >= 0 then
	        local path = nil
			if gradeLevel == 0 then
				path = QResPath("handbook_level_0")
			else
				path = QResPath("handbook_level")[gradeLevel]
			end
			QSetDisplayFrameByPath(self._ccbOwner.sp_god_level, path)
			self._ccbOwner.sp_god_level:setVisible(true)
	    else
	        self._ccbOwner.sp_god_level:setVisible(false)
	    end
   	end

    local bTLevel = remote.handBook:getHandbookBreakthroughLevelByActorID(self._actorId)
    if bTLevel > 0 then
        self._ccbOwner.tf_bt_level:setString(bTLevel)
        self._ccbOwner.node_bt_level:setVisible(true)
    else
        self._ccbOwner.node_bt_level:setVisible(false)
    end

	-- local godSkillLevel = remote.herosUtil:getGodSkillLevelByActorId(self._actorId)
	-- if godSkillLevel >= 0 then
	-- 	local path = nil
	-- 	if godSkillLevel == 0 then
	-- 		path = QResPath("god_skill_0")
	-- 	else
	-- 		path = QResPath("god_skill")[godSkillLevel]
	-- 	end
	-- 	QSetDisplayFrameByPath(self._ccbOwner.sp_god_level, path)
	-- 	self._ccbOwner.sp_god_level:setVisible(true)
	-- else
	-- 	self._ccbOwner.sp_god_level:setVisible(false)
	-- end
	-- self:_setProfession()
	self:_setSABC()
	-- self:_autoLayout()
end

-- function QUIWidgetHandBookCellNew:_setProfession()
-- 	if self._handBookType == remote.handBook.OFFLINE_HERO then return end
-- 	if self._actorId == nil then return end

--     if self._professionalIcon == nil then 
-- 	    self._professionalIcon = QUIWidgetHeroProfessionalIcon.new()
-- 	    self._ccbOwner.node_hero_profession:addChild(self._professionalIcon)
-- 	end
-- 	self._spriteIconWidth = self._professionalIcon:getContentSize().width
--     self._professionalIcon:setHero(self._actorId)
-- end

-- function QUIWidgetHandBookCellNew:_autoLayout()
-- 	if self._spriteIconWidth then
-- 		local tfWidth = self._ccbOwner.tf_hero_name:getContentSize().width

-- 		self._ccbOwner.tf_hero_name:setPositionX(self._spriteIconWidth/2)
-- 		self._ccbOwner.node_hero_profession:setPositionX(self._ccbOwner.tf_hero_name:getPositionX() - tfWidth/2 - self._spriteIconWidth/2)
-- 	end
-- end

function QUIWidgetHandBookCellNew:_setSABC()
	self._ccbOwner.node_aptitude:setVisible(false)
	if self._handBookType == remote.handBook.OFFLINE_HERO then return end

	if self._aptitudeInfo and self._aptitudeInfo.lower then
    	q.setAptitudeShow(self._ccbOwner, self._aptitudeInfo.lower)
		self._ccbOwner.node_aptitude:setVisible(true)
	end
end

function QUIWidgetHandBookCellNew:_setHeroCard( isSketch )
    self._ccbOwner.node_card:removeAllChildren()

	local sprite = CCSprite:create()
	local size = self._ccbOwner.card_size:getContentSize()
    local ccclippingNode = CCClippingNode:create()
    local layer = CCLayerColor:create(ccc4(0, 0, 0, 0), size.width, size.height)
    layer:setPosition(-size.width/2, -size.height/2)
    ccclippingNode:setAlphaThreshold(1)
    ccclippingNode:setStencil(layer)
    ccclippingNode:addChild(sprite)
    self._ccbOwner.node_card:addChild(ccclippingNode)

    if isSketch or self._handBookType == remote.handBook.OFFLINE_HERO then
    	local sexBoo = self._heroHandBookConfig.sex == 1 and true or false
	    local maskPath = remote.handBook:getSketchByBoo(sexBoo)
	    if maskPath then
	    	local frame = QSpriteFrameByPath(_cardPath)
			sprite:setDisplayFrame(frame)
		end
    else
    	local _heroInfo = remote.herosUtil:getHeroByID(self._actorId)
    	local _cardPath = ""
		-- if _heroInfo and _heroInfo.skinId and _heroInfo.skinId > 0 then
		-- 	local skinConfig = remote.heroSkin:getHeroSkinBySkinId(self._actorId, _heroInfo.skinId)
	 --        if skinConfig.skins_handBook then
	 --        	-- print("use skin handBookCard", self._actorId, skinConfig.skins_name)
	 --        	_cardPath = skinConfig.skins_handBook
	 --        	local frame = QSpriteFrameByPath(_cardPath)
	 --        	if frame then
		-- 			sprite:setDisplayFrame(frame)
		-- 		end
		-- 		if skinConfig.handBook_display then
		-- 			local skinDisplaySetConfig = remote.heroSkin:getSkinDisplaySetConfigById(skinConfig.handBook_display)
		-- 			local _isturn = skinDisplaySetConfig.isturn or 1
		-- 			if skinDisplaySetConfig.x then
		-- 				sprite:setPositionX(skinDisplaySetConfig.x)
		-- 			end
		-- 			if skinDisplaySetConfig.y then
		-- 				sprite:setPositionY(skinDisplaySetConfig.y)
		-- 			end
		-- 			if skinDisplaySetConfig.scale then
		-- 				sprite:setScaleX(_isturn * skinDisplaySetConfig.scale)
		-- 				sprite:setScaleY(skinDisplaySetConfig.scale)
		-- 			end
		-- 			if skinDisplaySetConfig.rotation then
		-- 				sprite:setRotation(skinDisplaySetConfig.rotation)
		-- 			end
		-- 		end
	 --        end
		-- end
		if _cardPath == "" then
			local dialogDisplay = remote.handBook:getDialogDisplayByActorID(self._actorId)
	    	if dialogDisplay and dialogDisplay.handBook_card then
	    		_cardPath = dialogDisplay.handBook_card
	    		local frame = QSpriteFrameByPath(_cardPath)
				sprite:setDisplayFrame(frame)
				sprite:setPosition(dialogDisplay.handBook_x, dialogDisplay.handBook_y)
				sprite:setScaleX(dialogDisplay.handBook_isturn * dialogDisplay.handBook_scale)
				sprite:setScaleY(dialogDisplay.handBook_scale)
				sprite:setRotation(dialogDisplay.handBook_rotation)
			else
				self:_setHeroCard(true)
				return
			end
		end
    end
end

return QUIWidgetHandBookCellNew
