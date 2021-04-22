
local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetTutorialDialogue = class("QUIWidgetTutorialDialogue", QUIWidget)
local QRichText = import("...utils.QRichText")
local QUIWidgetActorDisplay = import(".actorDisplay.QUIWidgetActorDisplay")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QUIViewController = import("..QUIViewController")

local leftPositionX = display.cx
local leftPositionY = 300

local rightPositionX = display.cx
local rightPositionY = 300

local defaultFontSize = 30

function QUIWidgetTutorialDialogue:ctor(options)
	-- local ccbFile = "ccb/Widget_NewPlayer.ccbi"
	-- if options.isLeftSide == false then
	-- 	ccbFile = "ccb/Widget_NewPlayer2.ccbi"
	-- end
	local ccbFile = "ccb/Widget_TutorialDialogue.ccbi"
	local callbacks = {}
	QUIWidgetTutorialDialogue.super.ctor(self, ccbFile, callbacks, options)
	if options ~= nil then
        self._isLeftSide = options.isLeftSide
	end
	self._typeKey = "_right"
	if self._isLeftSide then
		self._typeKey = "_left"
	end
	self._ccbOwner.node_left:setVisible(false)
	self._ccbOwner.node_right:setVisible(false)
	self._ccbOwner["node"..self._typeKey]:setVisible(true)
	self._animationManager = tolua.cast(self._ccbView:getUserObject(), "CCBAnimationManager")

	self._maxWidth = 603 -- dialog max width( 如果会溢出则换行显示，如果换行仍会移除，则换屏显示)
	self._height = 110
	self._isShowWords = false
	
	if self._isLeftSide then
		self:getView():setPosition(leftPositionX,leftPositionY)
	else
		self:getView():setPosition(rightPositionX,rightPositionY)
	end

	self._sound = options.sound
	self._isSay = options.isSay ~= nil and true or false
	self._text = options.text
	self._sayFun = options.sayFun
	self:addWord(self._text, self._sayFun)
	if options.heroId then
		local heroInfo = QStaticDatabase:sharedDatabase():getCharacterByID(tostring(options.heroId))
		self:setTitleName(heroInfo.title or "")
	else
		self:setTitleName("")
	end
	self._ccbOwner["label_name"..self._typeKey]:setString(options.name or "泰兰德")

	local fullLabelWidth = self._ccbOwner["label_name"..self._typeKey]:getContentSize().width + self._ccbOwner["label_name_title"..self._typeKey]:getContentSize().width
	-- if fullLabelWidth + 120 > self._ccbOwner.background:getContentSize().width then
    	self._ccbOwner["background"..self._typeKey]:setPreferredSize(CCSize(fullLabelWidth + 200, self._ccbOwner["background"..self._typeKey]:getContentSize().height))
    -- end
    -- QPrintTable(options)
    local avatarKey = options.avatarKey or "sp#jm_xiaowu"
    if string.find(avatarKey, "sp#") then
    	avatarKey = string.gsub(avatarKey, "sp#", "")
    	local dialogDisplay = QStaticDatabase.sharedDatabase():getDialogDisplay()[tostring(options.heroId)]
    	local card = "icon/hero_card/art_snts.png"
    	local x = 0
		local y = 0
		local scale = 1
		local rotation = 0
		local turn = 1
    	if dialogDisplay and dialogDisplay[avatarKey.."_card"] then
			card = dialogDisplay[avatarKey.."_card"]
			x = dialogDisplay[avatarKey.."_x"]
			y = dialogDisplay[avatarKey.."_y"]
			scale = dialogDisplay[avatarKey.."_scale"]
			rotation = dialogDisplay[avatarKey.."_rotation"]
			turn = dialogDisplay[avatarKey.."_isturn"]
		end
		local frame = QSpriteFrameByPath(card)
		if frame then
			self._ccbOwner["sprite_icon"..self._typeKey]:setDisplayFrame(frame)
			self._ccbOwner["sprite_icon"..self._typeKey]:setPosition(x, y)
			self._ccbOwner["sprite_icon"..self._typeKey]:setScaleX(scale*turn)
			self._ccbOwner["sprite_icon"..self._typeKey]:setScaleY(scale)
			self._ccbOwner["sprite_icon"..self._typeKey]:setRotation(rotation)
			self._ccbOwner["sprite_icon"..self._typeKey]:setVisible(true)
			self._ccbOwner["node_avatar"..self._typeKey]:setVisible(false)
		else
			assert(false, "<<<"..card..">>>not exist!")
		end
	else
		avatarKey = string.gsub(avatarKey, "av#", "")
		self._avatar = QSkeletonActor:create(avatarKey)
	    self._avatar:playAnimation("animation", true)
	    self._avatar:setPositionY(-20)
		self._ccbOwner["node_avatar"..self._typeKey]:addChild(self._avatar)
		if options.isLeftSide == false then
			self._avatar:setScaleX(-0.3)
		else
			self._avatar:setScaleX(0.3)
		end
		self._avatar:setScaleY(0.3)
		self._ccbOwner["sprite_icon"..self._typeKey]:setVisible(false)
		self._ccbOwner["node_avatar"..self._typeKey]:setVisible(true)
	end
end
function QUIWidgetTutorialDialogue:setTitleName(title)
	if title and title ~= "" then
        self._ccbOwner["label_name_title"..self._typeKey]:setString(title)
    else
       self._ccbOwner["label_name_title"..self._typeKey]:setString("")
       self._ccbOwner["label_name"..self._typeKey]:setPositionX(self._ccbOwner["background"..self._typeKey]:getPositionX())
       self._ccbOwner["label_name"..self._typeKey]:setAnchorPoint(0.5,0.5)
    end
end

function QUIWidgetTutorialDialogue:onEnter()
	self._animationManager:runAnimationsForSequenceNamed("appear")
    self._animationManager:connectScriptHandler(function(name)
        if name == "appear" then
        	self._isShowWords = true
        	self._animationManager:runAnimationsForSequenceNamed("normal")
        end
    end)
end

function QUIWidgetTutorialDialogue:onExit()
	self:stopSay()
 	if self._animationManager ~= nil then
        self._animationManager:disconnectScriptHandler()
    end
end

function QUIWidgetTutorialDialogue:runStartAnimation()
	local position1 = ccp(0, leftPositionY)
	local position2 = ccp(0, leftPositionY)
	if self._isLeftSide == true then
		position1.x = display.cx - 20
		position2.x = display.cx
	else
		position1.x = display.cx + 20
		position2.x = display.cx
	end
	local moveTo1 = CCMoveTo:create(0.08, position1)
	local moveTo2 = CCMoveTo:create(0.08, position2)
	local callFunc = CCCallFunc:create(function()
		end)
	local actionArrayIn = CCArray:create()
	actionArrayIn:addObject(moveTo1)
	actionArrayIn:addObject(moveTo2)
	actionArrayIn:addObject(callFunc)
	local ccsequence = CCSequence:create(actionArrayIn)
	self:getView():runAction(ccsequence)
end

function QUIWidgetTutorialDialogue:addWord(word,callFun)
	self._word = word
	self._sayFun = callFun
	self._isSaying = false

	if self._word ~= nil and self._isSay == false then
        self:showWords(self._word)
	else
		self:say()
	end
	if self._sayFun ~= nil then
		self._sayFun()
	end
end

function QUIWidgetTutorialDialogue:updateSound(sound)
	if sound then
		self._isPlaySound = false
		self._sound = sound
    end
end

function QUIWidgetTutorialDialogue:say()
	if self._isSaying == true or self._isSay == false then return end
	self._isSaying = true
	self._sayWord = ""
	self._sayPosition = 1
	self._startPosition = 1
	self._lineNum = 1
	self:sayWord()
end

function QUIWidgetTutorialDialogue:sayWord()
	local delayTime = TUTORIAL_ONEWORD_TIME
	if self._isSaying == true and self._isShowWords then
		local c = string.sub(self._word,self._sayPosition,self._sayPosition)
		local b = string.byte(c)
		local str = c
        local str2 = string.sub(self._word, self._sayPosition + 1, self._sayPosition + 1)

		if b > 128 then
			str = string.sub(self._word,self._sayPosition,self._sayPosition + 2)
			self._sayPosition = self._sayPosition + 2
			self._sayWord =  self._sayWord .. str
		else
			self._sayWord =  self._sayWord .. c
		end

		if str == "\n" then
			if self._lineNum >= 2 and #self._word > self._sayPosition then
				self._startPosition = self._sayPosition + 1
				self._sayWord = ""
				self._lineNum = 1
				delayTime = 0.1
			else
				self._lineNum = self._lineNum + 1
			end
        elseif str == "#" and str2 == "#" then
            self._sayWord =  self._sayWord .. str2
            self._sayPosition = self._sayPosition + 1
		else
            self:showWords(self._sayWord)
		end

		self._sayPosition = self._sayPosition + 1
	end

	if self._sayPosition <= #self._word then
		self._time = scheduler.performWithDelayGlobal(function()
			if self.sayWord then -- self is a CCObject not retained in lua space, it might just had had been released and disposed here
				self:sayWord()
			end
		end,delayTime)
	else
		self._isSaying = false
		if self._sayFun ~= nil then
			self._sayFun()
			self:stopSay()
		end
	end
end

function QUIWidgetTutorialDialogue:stopSay()
	self._sayFun = nil
	self._isSaying = false
	if self._time ~= nil then
		scheduler.unscheduleGlobal(self._time)
	end
end

function QUIWidgetTutorialDialogue:showWords(words)
    if self._sound and not self._isPlaySound then
    	self._isPlaySound = true
    	if app.sound.tutorialSoundHandle then
    		app.sound:stopSound(app.sound.tutorialSoundHandle)
    	end
    	app.sound:playSound(self._sound)
    end
    if self._colorfulText == nil then
        self._colorfulText = QRichText.new("", self._maxWidth, {stringType = 1, defaultColor = COLORS.j, defaultSize = defaultFontSize})

        self._colorfulText:setString(self._word)
        local height = self._colorfulText:getCascadeBoundingBox().size.height
        print("QUIWidgetTutorialDialogue:showWords(words) ", height)
    	self._colorfulText:setPositionY(height/2)
    	self._colorfulText:setAnchorPoint(0, 1)
    	self._colorfulText:setString("")
    	
        self._ccbOwner["textNode"..self._typeKey]:addChild(self._colorfulText)
    end
    self._colorfulText:setString(words)
end

function QUIWidgetTutorialDialogue:_getTotalWordLen(word)
	local w = q.wordLen(self._word, defaultFontSize, defaultFontSize/2)
	local w1 = q.wordLen("##o", defaultFontSize, defaultFontSize/2)
	local tbl = string.split(self._word, "##")
	local totalWordLen = w - (#tbl - 1)*w1

	return totalWordLen
end

--将所有文字一次性打印出来
function QUIWidgetTutorialDialogue:printAllWord(word)
	if self._isSaying ~= false then
		self:stopSay()
	end

	if self._animationManager then
		self._animationManager:runAnimationsForSequenceNamed("normal")
	end
    self:showWords(word or self._word)
end

function QUIWidgetTutorialDialogue:setActorImage(imageFile)
	-- if imageFile == nil then
	-- 	return
	-- end
	-- self._ccbOwner["sprite_icon"..self._typeKey]:setTexture(CCTextureCache:sharedTextureCache():addImage(imageFile))
end

return QUIWidgetTutorialDialogue
