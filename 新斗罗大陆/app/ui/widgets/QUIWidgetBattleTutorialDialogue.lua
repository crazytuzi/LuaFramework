
local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetBattleTutorialDialogue = class("QUIWidgetBattleTutorialDialogue", QUIWidget)
local QRichText = import("...utils.QRichText")
local QSkeletonViewController = import("...controllers.QSkeletonViewController")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QUIViewController = import("..QUIViewController")

local leftPositionX = display.cx
local leftPositionY = display.cy

local rightPositionX = display.cx
local rightPositionY = display.cy

local defaultFontSize = 30

function QUIWidgetBattleTutorialDialogue:ctor(options)
	-- local ccbFile = "ccb/Widget_NewPlayer_1.ccbi"
 --    if options.isLeftSide == false then
 --        ccbFile = "ccb/Widget_NewPlayer2_1.ccbi"
 --    end
    local ccbFile = "ccb/Widget_BattleTutorialDialogue.ccbi"
	local callbacks = {}
	QUIWidgetBattleTutorialDialogue.super.ctor(self, ccbFile, callbacks, options)
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
    self._isLeftSide = options.isLeftSide
    self:sayByDefault()
    if options.isLeftSide == true then
        self:setPosition(leftPositionX,leftPositionY)
    else
        self:setPosition(rightPositionX,rightPositionY)
    end
    self._isSay = options.isSay ~= nil and true or false
    self:setTitleName(options.titleName)
end

function QUIWidgetBattleTutorialDialogue:onEnter()
    self._animationManager:runAnimationsForSequenceNamed("appear")
    self._animationManager:connectScriptHandler(function(name)
        if name == "appear" then
            self._isShowWords = true
            self._animationManager:runAnimationsForSequenceNamed("normal")
        end
    end)
end

function QUIWidgetBattleTutorialDialogue:onExit()
    self:stopSay()
    if self._animationManager ~= nil then
        self._animationManager:disconnectScriptHandler()
    end
end

function QUIWidgetBattleTutorialDialogue:sayByDefault( ... )
    local options = self:getOptions()
    self:addWord(options.text, options.sayFun, options.name)
end

function QUIWidgetBattleTutorialDialogue:checkIsSameByOptions(options)
    local selfOptions = self:getOptions()
    for k,t in pairs(options) do
        if selfOptions[k] ~= options[k] then
            return false
        end
    end
    return true
end

function QUIWidgetBattleTutorialDialogue:addWord(word, callFun, name)
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

    if name and self._name ~= name then
        self._name = name
        self._ccbOwner["label_name"..self._typeKey]:setString(self._name)
        local fullLabelWidth = self._ccbOwner["label_name"..self._typeKey]:getContentSize().width + self._ccbOwner["label_name_title"..self._typeKey]:getContentSize().width
        -- if fullLabelWidth + 120 > self._ccbOwner.background:getContentSize().width then
            self._ccbOwner["background"..self._typeKey]:setPreferredSize(CCSize(fullLabelWidth + 200, self._ccbOwner["background"..self._typeKey]:getContentSize().height))
        -- end
    end

end

function QUIWidgetBattleTutorialDialogue:say()
    if self._isSaying == true or self._isSay == false then return end

    self._isSaying = true
    self._sayWord = ""
    self._sayPosition = 1
    self._startPosition = 1
    self._lineNum = 1

    self:sayWord()
end

function QUIWidgetBattleTutorialDialogue:sayWord()
    local delayTime = TUTORIAL_ONEWORD_TIME

    if self._isSaying == true and self._isShowWords then
        local c = string.sub(self._word, self._sayPosition, self._sayPosition)
        local b = string.byte(c)
        local str = c
        local str2 = string.sub(self._word, self._sayPosition + 1, self._sayPosition + 1)

        if b > 128 then
            str = string.sub(self._word, self._sayPosition, self._sayPosition + 2)
            self._sayPosition = self._sayPosition + 2
            self._sayWord =  self._sayWord .. str
        else
            self._sayWord =  self._sayWord .. c
        end

        -- ##c 代表文字的颜色，不做处理不显示
        if str == "\n" then
            if self._lineNum >= 3 and #self._word > self._sayPosition then
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
            end, delayTime)
    else
        self._isSaying = false

        if self._sayFun ~= nil then
            self._sayFun()
            self:stopSay()
        end
    end
end

function QUIWidgetBattleTutorialDialogue:stopSay()
    self._sayFun = nil
    self._isSaying = false
    if self._time ~= nil then
        scheduler.unscheduleGlobal(self._time)
    end
end

function QUIWidgetBattleTutorialDialogue:showWords(words)
    if self._colorfulText == nil then
        self._colorfulText = QRichText.new("", self._maxWidth, {stringType = 1,defaultColor = COLORS.j, defaultSize = defaultFontSize})

        self._colorfulText:setString(self._word)
        local height = self._colorfulText:getCascadeBoundingBox().size.height
        print("QUIWidgetBattleTutorialDialogue:showWords(words) ", height)
        self._colorfulText:setPositionY(height/2)
        self._colorfulText:setAnchorPoint(0, 1)
        self._colorfulText:setString("")
        
        self._ccbOwner["textNode"..self._typeKey]:addChild(self._colorfulText)
    end
    self._colorfulText:setString(words)
end

function QUIWidgetBattleTutorialDialogue:_getTotalWordLen(word)
    local w = q.wordLen(self._word, defaultFontSize, defaultFontSize/2)
    local w1 = q.wordLen("##o", defaultFontSize, defaultFontSize/2)
    local tbl = string.split(self._word, "##")
    local totalWordLen = w - (#tbl - 1)*w1

    return totalWordLen
end

function QUIWidgetBattleTutorialDialogue:setActorImage(imageFile)
    if imageFile == nil then
        return
    end
    local sprite = CCSprite:create(imageFile)
    --测试阶段防错 debug
    if sprite == nil then
        print("[qsy] QUIWidgetBattleTutorialDialogue:setActorImage() ---> imageFile = ", imageFile, "     is not complete")

        imageFile= "ui/"..imageFile..".png"
        sprite = CCSprite:create(imageFile)
    end
    if sprite then
        self._ccbOwner["sprite_icon"..self._typeKey]:setDisplayFrame(sprite:getDisplayFrame())
    end
    print("[Kumo] QUIWidgetBattleTutorialDialogue:setActorImage() ---> size = ", self._ccbOwner["sprite_icon"..self._typeKey]:getContentSize().width, self._ccbOwner["sprite_icon"..self._typeKey]:getContentSize().height)

    local dialogDisplayConfigs = QStaticDatabase.sharedDatabase():getDialogDisplay()
    local actorId = 0
    for _, value in pairs(dialogDisplayConfigs) do
        if self._isLeftSide and value.talkLeft_card == imageFile then
            actorId = value.id
        elseif not self._isLeftSide and value.talkRight_card == imageFile then
            actorId = value.id
        end
    end
    print("[Kumo] QUIWidgetBattleTutorialDialogue:setActorImage() ---> imageFile = ", imageFile, "      actorId = ", actorId)
    if actorId > 0 then
        local dialogDisplay = QStaticDatabase.sharedDatabase():getDialogDisplay()[tostring(actorId)]
        local x = 0
        local y = 0
        local scale = 1
        local rotation = 0
        local turn = 1
        if self._isLeftSide then
            x = -311
            y = -173
            scale = 0.7
            rotation = 0
            if dialogDisplay and dialogDisplay.talkLeft_card then
                x = dialogDisplay.talkLeft_x
                y = dialogDisplay.talkLeft_y
                scale = dialogDisplay.talkLeft_scale
                rotation = dialogDisplay.talkLeft_rotation
                turn = dialogDisplay.talkLeft_isturn
                print("[Kumo] QUIWidgetBattleTutorialDialogue:setActorImage() ---> x,y,s,r = ", x, y, scale, rotation)
            else
                assert(false, "<<<"..dialogDisplay.talkLeft_card..">>>not exist!")
            end
        else
            -- x = 311
            -- y = -173
            -- scale = 0.7
            -- rotation = 0
            if dialogDisplay and dialogDisplay.talkRight_card then
                x = dialogDisplay.talkRight_x
                y = dialogDisplay.talkRight_y
                scale = dialogDisplay.talkRight_scale
                rotation = dialogDisplay.talkRight_rotation
                turn = dialogDisplay.talkRight_isturn
            else
                assert(false, "<<<"..dialogDisplay.talkRight_card..">>>not exist!")
            end
        end
        self._ccbOwner["sprite_icon"..self._typeKey]:setPosition(x, y)
        self._ccbOwner["sprite_icon"..self._typeKey]:setScaleX(scale*turn)
        self._ccbOwner["sprite_icon"..self._typeKey]:setScaleY(scale)
        self._ccbOwner["sprite_icon"..self._typeKey]:setRotation(rotation)
    end
end

--将所有文字一次性打印出来
function QUIWidgetBattleTutorialDialogue:printAllWord(word)
    if self._isSaying ~= false then
        self:stopSay()
    end

    self:showWords(word or self._word)
end

function QUIWidgetBattleTutorialDialogue:setName(name)
    if name then 
        self._ccbOwner["label_name"..self._typeKey]:setString(name)
        local fullLabelWidth = self._ccbOwner["label_name"..self._typeKey]:getContentSize().width + self._ccbOwner["label_name_title"..self._typeKey]:getContentSize().width
        -- if fullLabelWidth + 120 > self._ccbOwner.background:getContentSize().width then
            self._ccbOwner["background"..self._typeKey]:setPreferredSize(CCSize(fullLabelWidth + 200, self._ccbOwner["background"..self._typeKey]:getContentSize().height))
        -- end
    end
end
function QUIWidgetBattleTutorialDialogue:setTitleName(title)
    if title and title ~= "" then
        self._ccbOwner["label_name_title"..self._typeKey]:setString(title)
    else
       self._ccbOwner["label_name_title"..self._typeKey]:setString("")
       self._ccbOwner["label_name"..self._typeKey]:setPositionX(self._ccbOwner["background"..self._typeKey]:getPositionX())
       self._ccbOwner["label_name"..self._typeKey]:setAnchorPoint(0.5,0.5)
    end
end

return QUIWidgetBattleTutorialDialogue