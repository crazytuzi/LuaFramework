
local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetHeroInformation = class("QUIWidgetHeroInformation", QUIWidget)

local QSkeletonViewController = import("...controllers.QSkeletonViewController")
local QUIWidgetAnimationPlayer = import("..widgets.QUIWidgetAnimationPlayer")
local QNotificationCenter = import("...controllers.QNotificationCenter")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QUIWidgetActorDisplay = import(".actorDisplay.QUIWidgetActorDisplay")
local QUIWidgetHeroProfessionalIcon = import("..widgets.QUIWidgetHeroProfessionalIcon")

QUIWidgetHeroInformation.EVENT_BEGAIN = "HERO_EVENT_BEGAIN"
QUIWidgetHeroInformation.EVENT_END = "HERO_EVENT_END"
QUIWidgetHeroInformation.EVENT_CLICK = "HERO_EVENT_CLICK"

function QUIWidgetHeroInformation:ctor(options)
	if options == nil then options = {} end
	local ccbFile = "ccb/Widget_HeroInformation.ccbi" 
	if options.isSmall == true then
		ccbFile = "ccb/Widget_HeroInformation2.ccbi" 
	end
	local callBacks = {
        {ccbCallbackName = "onTriggerAvatar", callback = handler(self, QUIWidgetHeroInformation._onTriggerAvatar)},
    }
	QUIWidgetHeroInformation.super.ctor(self, ccbFile, callBacks, options)
	cc.GameObject.extend(self)
    self:addComponent("components.behavior.EventProtocol"):exportMethods()

    if options.parent then
    	self._ccbStar = options.parent._ccbOwner
    end
	self._actorId = options.actorId
	self._isAutoPlay = options.isAutoPlay == nil and true or options.isAutoPlay --是否点击之后就播放动作技能效果
	self._forceDonotShowStar = options.forceDonotShowStar
	self._effectPlay = false
 	self.promptTipIsOpen = false
 	self._starVeritcal = true
	self._avatarName = {}

	self._ccbOwner.node_avatar:setScaleX(-1)
	
	-- self._ccbOwner.tf_plus = setShadow5(self._ccbOwner.tf_plus)
	self._ccbOwner.hp:setVisible(false)
	self._ccbOwner.mp:setVisible(false)

	self._ccbOwner.node_godarm_info:setVisible(false)

	self._starPosX = self._ccbOwner.node_star:getPositionX()
	self._proVisible = true
	self:setStarVisible(false)
	self._startPosX = self._ccbOwner.nodeSmallStar:getPositionX()
	self._startPosY = self._ccbOwner.nodeSmallStar:getPositionY()

	if self.infoType == "QUIDialogTeamArrangement" or self.infoType == "QUIDialogMockTeamArrangement"  then
		self._ccbOwner.node_name:setVisible(false)
		self._ccbOwner.label_name:setVisible(false)
	else
		self._ccbOwner.node_name:setVisible(true)
		self._ccbOwner.label_name:setVisible(false)
	end
	if self._ccbStar then
		self._animationManager = tolua.cast(self._ccbStar.ccb_hero_star:getUserObject(), "CCBAnimationManager")
        self._animationManager:connectScriptHandler(function(animationName)
                self._starAnimation = animationName
            end)
	else
    	self._animationManager = tolua.cast(self._ccbView:getUserObject(), "CCBAnimationManager")
    end
end

function QUIWidgetHeroInformation:onEnter()
    self._ccbOwner.sprite_back:setTouchMode(cc.TOUCH_MODE_ONE_BY_ONE)
    self._ccbOwner.sprite_back:setTouchEnabled(true)
    self._ccbOwner.sprite_back:setTouchSwallowEnabled(false)
    self._ccbOwner.sprite_back:addNodeEventListener(cc.NODE_TOUCH_EVENT, handler(self, QUIWidgetHeroInformation._onTouch))
end

function QUIWidgetHeroInformation:onExit()
	self:removeAvatar()
	if self._battleHandler ~= nil then
	    scheduler.unscheduleGlobal(self._battleHandler)
	    self._battleHandler = nil
	end
    self._ccbOwner.sprite_back:setTouchEnabled(false)
    self._ccbOwner.sprite_back:removeNodeEventListenersByEvent(cc.NODE_TOUCH_EVENT)
    if self._effectShow ~= nil then
    	self._effectShow:disappear()
    end
    if self._animationManager ~= nil then
        self._animationManager:disconnectScriptHandler()
    end
    self:stopAutoPlay()
end

function QUIWidgetHeroInformation:setAvatarByHeroInfo(heroInfo,actorId,scale)
	self._ccbOwner.professionalNode:setVisible(false)
	self._actorId = actorId

	self._effectTbl = {}
	self._effectPlay = false
	if self._handler ~= nil then
		scheduler.unscheduleGlobal(self._handler)
		self._handler = nil
	end
	if self._heroInfo ~= nil and self._heroInfo.actorId ~= nil and self._heroInfo.actorId ~= actorId then
		self._starNumber = nil
	end
    self:stopAutoPlay()

	self._heroInfo = heroInfo 
    self._heroDisplay = QStaticDatabase:sharedDatabase():getCharacterByID(actorId)

	self:removeAvatar()
	self._avatar = QUIWidgetActorDisplay.new(actorId, {heroInfo = heroInfo})

	--动作表
	self:setRandomActions()

	self._avatar:setScale(scale or 1)
	self._ccbOwner.node_avatar:addChild(self._avatar)

	--天赋职业
	-- self:setIcon()
	self:setName()
	local grade = self._heroDisplay.grade
	if self._heroInfo ~= nil then
		grade = self._heroInfo.grade
	end
	if grade ~= nil and not self._forceDonotShowStar then
		self:setStarVisible(true)
	    self:showStar(grade + 1 or 1)
	end
end

function QUIWidgetHeroInformation:setRandomActions()
	local actorSkinId
	local actionStr
	if self._heroInfo and self._heroInfo.skinId and self._heroInfo.skinId ~= 0 then
		actorSkinId = self._heroInfo.skinId 
	end
	if actorSkinId then
		local config = db:getHeroSkinConfigByID(actorSkinId)
		if config and config.information_action_skins then
			actionStr = config.information_action_skins
		end
	end
	if actionStr == nil and self._heroDisplay then
		actionStr = self._heroDisplay.information_action
	end
	--动作表
	self._avatarName = {}
	self._totalRate = 0
	if actionStr ~= nil then
		local actionArr = string.split(actionStr, ";")
		for _,value in pairs(actionArr) do
			local arr = string.split(value, ":")
			self._totalRate = self._totalRate + (tonumber(arr[2]) or 0)
			table.insert(self._avatarName, {name = arr[1], rate = tonumber(arr[2])})
		end
	end
end

function QUIWidgetHeroInformation:setProfession(profession, iconScale, textScale)
	self._ccbOwner.professionalNode:setVisible(profession ~= nil)

    if self._professionalIcon == nil then 
	    self._professionalIcon = QUIWidgetHeroProfessionalIcon.new()
	    self._ccbOwner.professionalNode:addChild(self._professionalIcon)
	end
    self._professionalIcon:setHero(self._actorId, true, iconScale)
end

function QUIWidgetHeroInformation:setProfessionPositionOffset(offsetX, offsetY)
	local posX = self._ccbOwner.professionalNode:getPositionX()
	local posY = self._ccbOwner.professionalNode:getPositionY()
	self._ccbOwner.professionalNode:setPosition(posX + offsetX, posY + offsetY)
end

--@qinyuanji, WOW-6733 太阳井的困难、普通、简单，顺序对调一下
function QUIWidgetHeroInformation:setHpMp(hpScale, mpScale)
	-- if hpScale then self._ccbOwner.hpBar:setScaleX(hpScale * 0.915) end
	-- if mpScale then self._ccbOwner.mpBar:setScaleX(mpScale * 0.94) end
	-- self._ccbOwner.hp:setVisible(hpScale ~= nil)
	-- self._ccbOwner.mp:setVisible(mpScale ~= nil)
	if hpScale then 
		if not self._hpBarClippingNode then
			self._hpBarClippingNode = q.newPercentBarClippingNode(self._ccbOwner.hpBar)
		end
		-- self._ccbOwner.hpBar:setScaleX(hpScale) 
		local stencil = self._hpBarClippingNode:getStencil()
		local totalStencilWidth = stencil:getContentSize().width * stencil:getScaleX()
		stencil:setPositionX(-totalStencilWidth + hpScale*totalStencilWidth)
	end

	
	if mpScale then 
		print("mpScale = "..mpScale)
		if not self._mpBarClippingNode then
			self._mpBarClippingNode = q.newPercentBarClippingNode(self._ccbOwner.mpBar)
		end
		-- self._ccbOwner.mpBar:setScaleX(mpScale * 1.037) 
		local stencil = self._mpBarClippingNode:getStencil()
		local totalStencilWidth = stencil:getContentSize().width * stencil:getScaleX()
		stencil:setPositionX(-totalStencilWidth + mpScale*totalStencilWidth)
	end
	self._ccbOwner.hp:setVisible(hpScale ~= nil)
	self._ccbOwner.mp:setVisible(mpScale ~= nil)
end

function QUIWidgetHeroInformation:setAvatar(actorId,scale)
	self:setAvatarByHeroInfo(remote.herosUtil:getHeroByID(actorId),actorId, scale)
end

function QUIWidgetHeroInformation:setCollegeTrainAvatar(chapterId, actorId,scale)
	self:setAvatarByHeroInfo(remote.collegetrain:getHeroInfoById(chapterId,actorId),actorId, scale)
end

function QUIWidgetHeroInformation:setMockBattleAvatar(index_, actorId,scale)
	self:setAvatarByHeroInfo(remote.mockbattle:getCardInfoByIndex(index_),actorId, scale)
end


function QUIWidgetHeroInformation:setSoulSpirit(actorId,scaleX,scaleY)
	self._ccbOwner.professionalNode:setVisible(false)
	self._actorId = actorId
	self._effectTbl = {}
	self._effectPlay = false
	if self._handler ~= nil then
		scheduler.unscheduleGlobal(self._handler)
		self._handler = nil
	end

    self:stopAutoPlay()
	self:removeAvatar()
	self._avatar = QUIWidgetActorDisplay.new(actorId)
	--动作表
	self:setRandomActions()
	self._avatar:setScaleX(scaleX or 1)
	self._avatar:setScaleY(scaleY or 1)
	self._ccbOwner.node_avatar:addChild(self._avatar)

end


function QUIWidgetHeroInformation:setInfotype( type )
	self.infoType = type
	-- body
	if tostring(self.infoType) == "QUIDialogTeamArrangement" or tostring(self.infoType) == "QUIDialogCollegeTrainTeamArrangement" or self.infoType == "QUIDialogMockTeamArrangement" then
		self._ccbOwner.node_name:setVisible(false)
		self._ccbOwner.label_name:setVisible(false)
	else
		self._ccbOwner.node_name:setVisible(true)
		self._ccbOwner.label_name:setVisible(false)
	end
end

function QUIWidgetHeroInformation:setAvatarActorId( actorId )
	self._actorId = actorId
end

function QUIWidgetHeroInformation:getActorId()
	return self._actorId
end

function QUIWidgetHeroInformation:pauseAnimation()
	self._avatar:getActor():getSkeletonView():pauseAnimation()
end

function QUIWidgetHeroInformation:resumeAnimation()
	self._avatar:getActor():getSkeletonView():resumeAnimation()
end

function QUIWidgetHeroInformation:getActorView()
	return self._avatar:getActor():getSkeletonView()
end

function QUIWidgetHeroInformation:getAvatar()
	return self._avatar
end

function QUIWidgetHeroInformation:setNameColor(color)
	self._color = color
end

function QUIWidgetHeroInformation:setName()
	local fontColor = self._color or BREAKTHROUGH_COLOR_LIGHT["white"]
	local breakthroughLevel = 0
	local color = nil
	if self._heroInfo ~= nil then
		breakthroughLevel, color = remote.herosUtil:getBreakThrough(self._heroInfo.breakthrough)
	end
	if color ~= nil then
		fontColor = BREAKTHROUGH_COLOR_LIGHT[color]
	end
	self._ccbOwner.tf_name:setColor(fontColor)
	self._ccbOwner.tf_name = setShadowByFontColor(self._ccbOwner.tf_name, fontColor)

	local breakthroughLevelStr = ""
	if breakthroughLevel and breakthroughLevel > 0 then
		breakthroughLevelStr = "+"..tostring(breakthroughLevel)
		-- self._ccbOwner.tf_plus:setColor(BREAKTHROUGH_COLOR_LIGHT[color])
	end
	self._ccbOwner.tf_name:setString(string.format("%s%s", self._heroDisplay.name, breakthroughLevelStr))
	self._ccbOwner.label_name:setString(string.format("%s", self._heroDisplay.name))
	self._ccbOwner.tf_name:setScale(1)
	-- if self._ccbOwner.tf_name:getContentSize().width + self._ccbOwner.tf_name:getContentSize().width > 250 then
	-- 	self._ccbOwner.tf_name:setScale(0.85)
	-- end
end

function QUIWidgetHeroInformation:setGodarmInfo(godarmId)
	local godarmConfig = db:getCharacterByID(godarmId)
	if godarmConfig then
		self._ccbOwner.node_godarm_info:setScale(1/0.82)
		self._ccbOwner.node_godarm_info:setVisible(true)
	    local aptitudeInfo = db:getActorSABC(godarmId)
	    self._ccbOwner.tf_godarm_name:setString(godarmConfig.name or "") 

	    local fontColor = UNITY_COLOR_LIGHT[aptitudeInfo.color]
		self._ccbOwner.tf_godarm_name:setColor(fontColor)
	    self._ccbOwner.tf_godarm_name = setShadowByFontColor(self._ccbOwner.tf_godarm_name, fontColor)


		local jobIconPath = remote.godarm:getGodarmJobPath(godarmConfig.label)
		if jobIconPath then
			QSetDisplaySpriteByPath(self._ccbOwner.sp_godarm_label,jobIconPath)
		end
		local labelPositionX = self._ccbOwner.tf_godarm_name:getPositionX()
		self._ccbOwner.sp_godarm_label:setPositionX(labelPositionX - self._ccbOwner.tf_godarm_name:getContentSize().width/2 - self._ccbOwner.sp_godarm_label:getContentSize().width/2)
		self._ccbOwner.node_avatar:setPositionY(-78)
		self._ccbOwner.node_avatar:setScaleX(-0.6)
		self._ccbOwner.node_avatar:setScaleY(0.6)
	end	
end

function QUIWidgetHeroInformation:hideGodarmInfo()
	self._ccbOwner.node_godarm_info:setVisible(false)
	self._ccbOwner.node_avatar:setScaleX(-1)
	self._ccbOwner.node_avatar:setScaleY(1)
	self._ccbOwner.node_avatar:setPositionY(-105)
end

function QUIWidgetHeroInformation:showGodarmInfo()
	self._ccbOwner.node_godarm_info:setVisible(true)
	self._ccbOwner.node_avatar:setPositionY(-78)
	self._ccbOwner.node_avatar:setScaleX(-0.6)
	self._ccbOwner.node_avatar:setScaleY(0.6)
end

function QUIWidgetHeroInformation:getActorName( )
	-- body
	if self._heroDisplay then
		return self._heroDisplay.name
	end
	return ""
end

function QUIWidgetHeroInformation:showStar(number)
	local function addByOne(n)
		return n >= 0 and n + 1 or n - 1
	end
	local starNum, iconPath = remote.herosUtil:getStarIconByStarNum(number)
	if starNum == nil then return end

	if iconPath == "ui/common/one_star.png" then
		iconPath = "ui/common/one_star2.png"
	end
	local index = 3
	local ti = 0

	if self._ccbStar then
		for i = 1, 5 do
			self._ccbStar["heroStar_sprite_star" .. i]:setVisible(false)
		end
		self._ccbStar.heroStar_nodeBigStar:setVisible(false)
		for i = 1, starNum do
			local displayFrame = QSpriteFrameByPath(iconPath)
			if displayFrame then
				self._ccbStar["heroStar_sprite_star" .. index]:setDisplayFrame(displayFrame)
			end

			self._ccbStar["heroStar_sprite_star" .. index]:setVisible(true)
			ti = -addByOne(ti)
			index = index + ti
		end
		self._ccbStar.heroStar_nodeSmallStar:setVisible(true)
	else
		local offset = 0 
		if math.fmod(starNum, 2) == 0 then
			offset = 15
		end 
		for i = 1, 5 do
			self._ccbOwner["sprite_star" .. i]:setVisible(false)
		end
		self._ccbOwner.nodeBigStar:setVisible(false)
		for i = 1, starNum do
			local displayFrame = QSpriteFrameByPath(iconPath)
			if displayFrame then
				self._ccbOwner["sprite_star" .. index]:setDisplayFrame(displayFrame)
			end

			self._ccbOwner["sprite_star" .. index]:setVisible(true)
			ti = -addByOne(ti)
			index = index + ti
		end

		if self._starVeritcal then
	    	self._ccbOwner.nodeSmallStar:setPositionY(self._startPosX+offset)  --xurui:这里有问题，必须用 startPosX 才能正常显示
	    else
	    	self._ccbOwner.nodeSmallStar:setPositionX(self._startPosX+offset)
		end
		self._ccbOwner.nodeSmallStar:setVisible(true)
	end

	if self._starNumber ~= nil and number > self._starNumber and number > GRAD_MAX then
		if self._starNumber == GRAD_MAX or self._starNumber == GRAD_MAX+5 then
            self._animationManager:runAnimationsForSequenceNamed("change")

	        local starNum2, iconPath2, plist2 = remote.herosUtil:getStarIconByStarNum(number-1)
	 	
	 		if self._ccbStar then
				for i = 1, 5 do
					local displayFrame = QSpriteFrameByPath(iconPath2)
					if displayFrame then
						self._ccbStar["heroStar_star_effect" .. i]:setDisplayFrame(displayFrame)
					end
					self._ccbStar["heroStar_star_effect" .. i]:setVisible(true)
				end
				self._ccbStar.heroStar_nodeBigStar:setVisible(true)
				self._ccbStar.heroStar_nodeSmallStar:setVisible(false)

				local displayFrame = QSpriteFrameByPath(iconPath)
				if displayFrame then
					self._ccbStar["heroStar_big_sprite"]:setDisplayFrame(displayFrame)
				end
			else
				for i = 1, 5 do
					local displayFrame = QSpriteFrameByPath(iconPath2)
					if displayFrame then
						self._ccbOwner["star_effect" .. i]:setDisplayFrame(displayFrame)
					end
					self._ccbOwner["star_effect" .. i]:setVisible(true)
				end
				self._ccbOwner.nodeBigStar:setVisible(true)
				self._ccbOwner.nodeSmallStar:setVisible(false)

				local displayFrame = QSpriteFrameByPath(iconPath)
				if displayFrame then
					self._ccbOwner["big_sprite"]:setDisplayFrame(displayFrame)
				end
			end
		else
			if self._ccbStar and self._starAnimation == "change" then
            	self._animationManager:runAnimationsForSequenceNamed("normal")
			end
		end
	else
		if self._ccbStar then
			self._animationManager:runAnimationsForSequenceNamed("normal")
		else
			self._animationManager:runAnimationsForSequenceNamed("Default Timeline")
		end
	end

	self._starNumber = number
end

function QUIWidgetHeroInformation:setPromptIsOpen(value)
    self.promptTipIsOpen = value
end

--设置是否背后的圈圈
function QUIWidgetHeroInformation:setBackgroundVisible(b)
	self._ccbOwner.sp_bg:setVisible(b)
end

--设置是否显示名称
function QUIWidgetHeroInformation:setNameVisible(b, frameStatus)
	--self._ccbOwner.node_name:setVisible(b)
	if self.infoType == "QUIDialogTeamArrangement" then
		self._ccbOwner.label_name:setVisible(b)
	else
		self._ccbOwner.node_name:setVisible(b)
	end
	
	if frameStatus == nil then
		frameStatus = true
	end
	self._ccbOwner.sp_frame:setVisible(frameStatus)
end

--设置是否显示avatar
function QUIWidgetHeroInformation:setAvatarVisible(b)
	self._ccbOwner.node_avatar:setVisible(b)
end

--设置是否显示星星
function QUIWidgetHeroInformation:setStarVisible(b)
	if self._ccbStar then 
		self._ccbStar.heroStar_node_star:setVisible(b)
		self._ccbOwner.node_star:setVisible(false)
		return 
	end
	self._ccbOwner.node_star:setVisible(b)
end

--设置星星 scale
function QUIWidgetHeroInformation:setStarScale(scale)
	if self._ccbStar then 
		self._ccbStar.heroStar_node_star:setScale(scale)
	else
		self._ccbOwner.node_star:setScale(scale)
	end
end

--修改星星的父节点 用于修改星星的显示层级
function QUIWidgetHeroInformation:changeStarNodeParent(parent)
	if self._ccbStar then return end
	self._ccbOwner.node_star:removeFromParentAndCleanup(false)
	parent:addChild(self._ccbOwner.node_star)
end

--修改名字的父节点 用于修改名字的显示层级
function QUIWidgetHeroInformation:changeNameNodeParent(parent)
	self._ccbOwner.node_name:setVisible(false)
	self._ccbOwner.tf_name:removeFromParentAndCleanup(false)
	parent:addChild(self._ccbOwner.tf_name)
end

function QUIWidgetHeroInformation:setStarPositionOffset(offsetX, offsetY)
	if self._ccbStar then return end
	local posX = self._ccbOwner.node_star:getPositionX()
	local posY = self._ccbOwner.node_star:getPositionY()
	self._ccbOwner.node_star:setPosition(posX + offsetX, posY + offsetY)
end

function QUIWidgetHeroInformation:setSabcPosition(offsetX, offsetY)
	local posX = self._ccbOwner.effect_pingzhi:getPositionX()
	local posY = self._ccbOwner.effect_pingzhi:getPositionY()
	local posX1 = self._ccbOwner.node_pingzhi:getPositionX()
	local posY1 = self._ccbOwner.node_pingzhi:getPositionY()
	self._ccbOwner.effect_pingzhi:setPosition(posX + offsetX, posY + offsetY)
	self._ccbOwner.node_pingzhi:setPosition(posX1 + offsetX, posY1 + offsetY)
end

--设置是否显示SABC
function QUIWidgetHeroInformation:setSabcVisible(b, isEffect, aptitude)
	if isEffect then
		local ccbFile = "ccb/effects/Hero_pingzhi_big.ccbi"
		local ani = QUIWidgetAnimationPlayer.new()
		self._ccbOwner.effect_pingzhi:addChild(ani)
		self._ccbOwner.node_pingzhi:setVisible(true)
		self._ccbOwner.text_pingzhi:setVisible(true)
		self._ccbOwner.node_sabc:setVisible(false)
		-- self._ccbOwner.node_word:setVisible(false)
		self._ccbOwner.effect_pingzhi:setVisible(true)
		ani:playAnimation(ccbFile, function(ccbOwner)
			local aptitudeInfo = db:getActorSABC(self._actorId)
    		q.setAptitudeShow(ccbOwner, aptitudeInfo.lower)
			if aptitudeInfo.lower == "a+" then
				self._ccbOwner.node_word:setPositionX(self._ccbOwner.node_word:getPositionX()+25)
			end

			app.sound:playSound("common_star")
		end, function()
			-- self._ccbOwner.node_sabc:setVisible(true)
			-- self._ccbOwner.effect_pingzhi:setVisible(false)
		end, false)
	else
		self._ccbOwner.node_pingzhi:setVisible(b)
		if self._ccbOwner.text_pingzhi then self._ccbOwner.text_pingzhi:setVisible(b) end
		if self._ccbOwner.node_word then self._ccbOwner.node_word:setVisible(b) end
		if self._ccbOwner.node_sabc then self._ccbOwner.node_sabc:setVisible(b) end
	end
end

function QUIWidgetHeroInformation:setSabcValue( aptitude )
	local aptitudeInfo = db:getActorSABC(self._actorId)
    q.setAptitudeShow(self._ccbOwner, aptitudeInfo.lower)
end

-- function QUIWidgetHeroInformation:setProPositionOffset(offsetX, offsetY)
-- 	local posX = self._ccbOwner.node_pro:getPositionX()
-- 	local posY = self._ccbOwner.node_pro:getPositionY()
-- 	self._ccbOwner.node_pro:setPosition(posX + offsetX, posY + offsetY)
-- end

function QUIWidgetHeroInformation:setNamePositionOffset(offsetX, offsetY)
	if self.infoType == "QUIDialogTeamArrangement" then
		local posX = self._ccbOwner.label_name:getPositionX()
		local posY = self._ccbOwner.label_name:getPositionY()
		self._ccbOwner.label_name:setPosition(posX + offsetX, posY + offsetY)
	else
		local posX = self._ccbOwner.node_name:getPositionX()
		local posY = self._ccbOwner.node_name:getPositionY()
		self._ccbOwner.node_name:setPosition(posX + offsetX, posY + offsetY)
	end
end

function QUIWidgetHeroInformation:setNameScale(scale)
	if self.infoType == "QUIDialogTeamArrangement" then
		self._ccbOwner.label_name:setScale(scale)
	else
		self._ccbOwner.node_name:setScale(scale)
	end
end

function QUIWidgetHeroInformation:setAvatarPositionOffset(offsetX, offsetY)
	local posX = self._ccbOwner.node_avatar:getPositionX()
	local posY = self._ccbOwner.node_avatar:getPositionY()
	self._ccbOwner.node_avatar:setPosition(posX + offsetX, posY + offsetY)
end

--显示特效
function QUIWidgetHeroInformation:avatarPlayAnimation(value, isPalySound, callback)
	if value == ANIMATION_EFFECT.VICTORY and self._avatarName[1] then
		value = self._avatarName[1].name
	elseif value == ANIMATION_EFFECT.WALK and self._avatarName[2] then
		value = self._avatarName[2].name
	end
	if self._avatar ~= nil then
		self._avatar:displayWithBehavior(value)
		self._avatar:setDisplayBehaviorCallback(callback)
		if isPalySound ~= nil or isPalySound == true then
			self:playSound(value)
		end
	end
end

function QUIWidgetHeroInformation:isAvatarPlayingAnimation()
	return self._avatar ~= nil and self._avatar:isActorPlaying()
end

function QUIWidgetHeroInformation:getNameTF()
	if self.infoType == "QUIDialogTeamArrangement" then
		return self._ccbOwner.label_name
	else
		return self._ccbOwner.tf_name
	end
end

function QUIWidgetHeroInformation:setAutoStand(b)
	if self._avatar ~= nil then
		self._avatar:setAutoStand(b)
	end
end

function QUIWidgetHeroInformation:setTouchNodeStatus(status)
	if status ~= nil then
		self._ccbOwner.sprite_back:setVisible(status)
		self._ccbOwner.btn_click:setVisible(status)
	end
end

function QUIWidgetHeroInformation:setTouchNodeRect(preferredSize)
	if preferredSize ~= nil then
		self._ccbOwner.btn_click:setPreferredSize(preferredSize)
	end
end

function QUIWidgetHeroInformation:playSound(value)
	if self._avatarSound ~= nil then
		app.sound:stopSound(self._avatarSound)
		self._avatarSound = nil
	end

    local cheer, walk
    if self._heroInfo and self._heroInfo.skinId then
    	local skinConfig = db:getHeroSkinConfigByID(self._heroInfo.skinId)
    	cheer = skinConfig.cheer
    	walk = skinConfig.walk
    end
    if not cheer then
    	cheer = self._heroDisplay.cheer
    end
    if not walk then
    	walk = self._heroDisplay.walk
    end

	if value == ANIMATION_EFFECT.VICTORY and cheer then
    	self._avatarSound = app.sound:playSound(cheer)
    elseif value == ANIMATION_EFFECT.WALK and walk then
    	self._avatarSound = app.sound:playSound(walk)
	end
end

--升级效果
function QUIWidgetHeroInformation:playLevelUp()
	app.sound:playSound("hero_up")
	if self._effectShow == nil then
		self._effectShow = QUIWidgetAnimationPlayer.new()
		self:addChild(self._effectShow)
		self._effectShow:playAnimation("ccb/effects/HeroUpgarde.ccbi",nil,nil,false)
	else
		self._effectShow:playByName("Default Timeline")
	end
	self:resetAutoPlay()
	self:avatarPlayAnimation(ANIMATION_EFFECT.VICTORY)
end

--显示特效
function QUIWidgetHeroInformation:playPropEffect(value)
	if self._effectTbl == nil then
		self._effectTbl = {}
	end
	-- if string.find(value, "等级") ~= nil then 
	table.insert(self._effectTbl, value)
	self._timeDelay = 0.3
	if (2/#self._effectTbl) < self._timeDelay then
		self._timeDelay = 2/#self._effectTbl
	end
	if self._effectPlay == false then
		self._effectPlay = true
		self._handler = scheduler.performWithDelayGlobal(handler(self,self._playPropEffect),self._timeDelay)
	end
	-- end
end

function QUIWidgetHeroInformation:_playPropEffect()
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
		end, function()
			effect:removeFromParentAndCleanup(true)
		end)
end

function QUIWidgetHeroInformation:_onTouch(event)
  if event.name == "began" then
  	if self.promptTipIsOpen == true then
    	QNotificationCenter.sharedNotificationCenter():dispatchEvent({name = QUIWidgetHeroInformation.EVENT_BEGAIN , eventTarget = self, actorId = self._heroInfo.actorId})
    	return true
    end
  elseif event.name == "ended" or event.name == "cancelled" then
  	if self.promptTipIsOpen == true then
   		QNotificationCenter.sharedNotificationCenter():dispatchEvent({name = QUIWidgetHeroInformation.EVENT_END , eventTarget = self})
    	return true
	end
  end
end

--[[
	更换魂师Avatar
]]
function QUIWidgetHeroInformation:_onTriggerAvatar()
	self:dispatchEvent({name = QUIWidgetHeroInformation.EVENT_CLICK, currentTarget = self})
	if self._isAutoPlay == false then return end
	self:randomPlayAvatar()
	self:resetAutoPlay()

	-- 连续点击十下角色开启“跳过战斗”
	if remote and DEBUG_SKIP_BATTLE == false then
		if self._debug_skip_battle_click_count == nil then
			self._debug_skip_battle_click_count = 1
			self._debug_skip_battle_click_time = q.time()
		else
			self._debug_skip_battle_click_count = self._debug_skip_battle_click_count + 1
		end
		if q.time() - self._debug_skip_battle_click_time > 5.0 then
			self._debug_skip_battle_click_count = nil
			self._debug_skip_battle_click_time = nil
		elseif self._debug_skip_battle_click_count >= 10 then
			DEBUG_SKIP_BATTLE = true
			self._debug_skip_battle_click_count = nil
			self._debug_skip_battle_click_time = nil
		end
	end
end

function QUIWidgetHeroInformation:resetAutoPlay()
	self:stopAutoPlay()
	if self._sec ~= nil then
		self:startAutoPlay(self._sec)
	end
end

function QUIWidgetHeroInformation:startAutoPlay(sec)
	if self._isAutoPlay == false then return end
	self._sec = sec
	self._autoPlayHandler = scheduler.scheduleGlobal(function ()
		if self._avatar:isActorPlaying() == false then
			if math.random() > 0.5 then
				self:avatarPlayAnimation(ANIMATION_EFFECT.VICTORY)
			else
				self:avatarPlayAnimation(ANIMATION_EFFECT.WALK)
			end
		end
	end,sec)
end

function QUIWidgetHeroInformation:stopAutoPlay()
	if self._autoPlayHandler ~= nil then
		scheduler.unscheduleGlobal(self._autoPlayHandler)
		self._autoPlayHandler = nil
	end
end

function QUIWidgetHeroInformation:walkToTagetPos(displacement,callbackMove,callbackIn)
	if self._isAutoPlay == false then return end
	if self._avatar == nil then return end
	local posx,posy = self._avatar:getPosition()
	if callbackMove then
		callbackMove()
	end
	local moveEnd = function()
		if callbackIn then
			callbackIn()
		end
		self._avatar:setPosition(ccp(posx,posy))
	end

	self._avatar:walktoBySpeed(ccp(posx-displacement,posy),moveEnd)

end
function QUIWidgetHeroInformation:randomPlayAvatar()
	if #self._avatarName == 0 or self._totalRate == 0 then return end
	local num = math.random(self._totalRate)
	local rate = 0
	local actionName = nil
	for _,value in pairs(self._avatarName) do
		if num < (rate + value.rate) then
			actionName = value.name
			break
		end
		rate = rate + value.rate
	end
	if actionName ~= nil then
		self:avatarPlayAnimation(actionName, true)
	end
end

function QUIWidgetHeroInformation:removeAvatar()
	if self._avatar ~= nil then
		self._ccbOwner.node_avatar:removeAllChildren()
		self._avatar = nil
	end
end

function QUIWidgetHeroInformation:playChestAnimation(callback)
	if self._avatar ~= nil then
		self._avatar:playChestAnimation(callback)
	end
end

function QUIWidgetHeroInformation:setSoulTrial( soulTrial, posY )
	self._ccbOwner.node_soulTrial:removeAllChildren()
	if not soulTrial or soulTrial == 0 then return end
	local posY = posY or 70
	
	local _, passChapter = remote.soulTrial:getCurChapter( soulTrial )
	local curBossConfig = remote.soulTrial:getBossConfigByChapter( passChapter )

	if curBossConfig and curBossConfig.title_icon1 and curBossConfig.title_icon2 then
		local kuang = CCSprite:create(curBossConfig.title_icon2)
		if kuang then
			self._ccbOwner.node_soulTrial:addChild(kuang)
		end
		local sprite = CCSprite:create(curBossConfig.title_icon1)
		if sprite then
			self._ccbOwner.node_soulTrial:addChild(sprite)
		end
	end
	self._ccbOwner.node_soulTrial:setPositionY(posY)
end

function QUIWidgetHeroInformation:setSocietyOfficialPosition( sprite )
	self._ccbOwner.node_society_op:removeAllChildren()
	if not sprite then return end
	self._ccbOwner.node_society_op:addChild(sprite)
	self._ccbOwner.node_society_op:setVisible(true)
end

function QUIWidgetHeroInformation:setSOPOffset(offsetX, offsetY)
	local posX = self._ccbOwner.node_society_op:getPositionX()
	local posY = self._ccbOwner.node_society_op:getPositionY()
	self._ccbOwner.node_society_op:setPosition(posX + offsetX, posY + offsetY)
end

function QUIWidgetHeroInformation:setStarVertical(isVertical)
	if isVertical == nil then isVertical = true end
	self._starVeritcal = isVertical
end

return QUIWidgetHeroInformation