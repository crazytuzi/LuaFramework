--
-- zxs
-- 
-- 
local QUIDialog = import(".QUIDialog")
local QUIDialogDungeonChapterPassSuccess = class("QUIDialogDungeonChapterPassSuccess", QUIDialog)

local QNavigationController = import("...controllers.QNavigationController")
local QRichText = import("...utils.QRichText")
local QUIWidgetAnimationPlayer = import("..widgets.QUIWidgetAnimationPlayer")
local QStaticDatabase = import("...controllers.QStaticDatabase")

local maxWidth = 580 -- dialog max width( 如果会溢出则换行显示，如果换行仍会移除，则换屏显示)

function QUIDialogDungeonChapterPassSuccess:ctor(options) 
 	local ccbFile = "ccb/Dialog_xuzhang_over.ccbi"
	local callBacks = {
	}

	QUIDialogDungeonChapterPassSuccess.super.ctor(self, ccbFile, callBacks, options)
	self.isAnimation = options.isAnimation == nil and true or false
	
	self._callback = options.callback

	self.currentIndex = options.currentIndex
    local plotConfigs = QStaticDatabase.sharedDatabase():getDungeonSummaryPlot(self.currentIndex)
    if plotConfigs then
        self:setPlotBgImage(plotConfigs.end_pitcure)
        -- self:addWord(plotConfigs.end_plot,options.sayFun)
        self._isEnd = false
        RunActionDelayTime(self:getView(), function()
            self:addWord(plotConfigs.end_plot, self:getOptions().sayFun)
            self._isEnd = true
        end, 2)
    end

	-- self._isSay = options.isSay ~= nil and true or false
    self._isSay = true
    self._ccbOwner.tf_title:setString(options.title or "")
end

function QUIDialogDungeonChapterPassSuccess:addWord(word, callFun)
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

function QUIDialogDungeonChapterPassSuccess:say()
    if self._isSaying == true or self._isSay == false then return end

    self._isSaying = true
    self._sayWord = ""
    self._sayPosition = 1
    self._startPosition = 1
    self._lineNum = 1

    self:sayWord()
end

function QUIDialogDungeonChapterPassSuccess:sayWord()
    local delayTime = TUTORIAL_ONEWORD_TIME

    if self._isSaying == true then
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
        if str == "\\" and str2 == "n" then
            self._sayWord =  self._sayWord .. str2
            self._sayPosition = self._sayPosition + 1
        elseif str == "#" and str2 == "#" then
            self._sayWord =  self._sayWord .. str2
            self._sayPosition = self._sayPosition + 1
        else

            self:showWords(self._sayWord)
        end

        self._sayPosition = self._sayPosition + 1
    end

    if self._sayPosition <= #self._word then
        self:removeHandler()
        self._timehandler = scheduler.performWithDelayGlobal(function()
                if self.sayWord then
                    self:sayWord()
                end
            end, delayTime)
    else
        if self._isSaying then
            self:_showPassAnimation()
        end
        self._isSaying = false
        if self._sayFun ~= nil then
            self._sayFun()
            self:stopSay()
        end
    end
end

function QUIDialogDungeonChapterPassSuccess:stopSay()
    self._sayFun = nil
    self._isSaying = false
    self:removeHandler()
end  

function QUIDialogDungeonChapterPassSuccess:removeHandler( ... )
    if self._timehandler ~= nil then
        scheduler.unscheduleGlobal(self._timehandler)
        self._timehandler = nil
    end
end

function QUIDialogDungeonChapterPassSuccess:_showPassAnimation()
    local ccbFile = "ccb/effects/tongguangaizhang_1.ccbi"
    local aniPlayer = QUIWidgetAnimationPlayer.new()
    self._ccbOwner.title_node:addChild(aniPlayer)
    aniPlayer:playAnimation(ccbFile, nil, nil, false)
end

function QUIDialogDungeonChapterPassSuccess:showWords(words)
    if nil == self._colorfulText then
        self._colorfulText = QRichText.new(words, maxWidth, {stringType = 1, defaultColor = ccc3(255, 255, 255), defaultSize = 28, lineSpacing = 15, strokeColor = ccc3(66,29,28)})
        self._colorfulText:setAnchorPoint(0, 1)
        self._colorfulText:setPositionX(-maxWidth/2)
        self._ccbOwner.textNode:addChild(self._colorfulText)
    else
        if self._colorfulText.setString ~= nil then
            self._colorfulText:setString(words)
        end
    end
end

function QUIDialogDungeonChapterPassSuccess:setPlotBgImage(imageFile)
    if imageFile == nil then
        return
    end
    local sprite = CCSprite:create(imageFile)
    if sprite then
        self._ccbOwner.sp_bg:setDisplayFrame(sprite:getDisplayFrame())
    end
end

function QUIDialogDungeonChapterPassSuccess:viewDidAppear()
    QUIDialogDungeonChapterPassSuccess.super.viewDidAppear(self)
end

function QUIDialogDungeonChapterPassSuccess:viewWillDisappear()
    QUIDialogDungeonChapterPassSuccess.super.viewWillDisappear(self)

    self:stopSay()
end


function QUIDialogDungeonChapterPassSuccess:_backClickHandler()
    -- if self._isSaying then
    --     self:stopSay()
    --     self:showWords(self._word)
    --     self:_showPassAnimation()
    -- else
    --     self:_onTriggerClose()
    -- end
    if self._isSaying then
        self:stopSay()
        self:showWords(self._word)
        self:_showPassAnimation()
    elseif self._isEnd then
        self:_onTriggerClose()
    end
end

function QUIDialogDungeonChapterPassSuccess:_onTriggerClose()
    app.sound:playSound("common_close")
    self:removeHandler()
    local callback = self._callback
    self:popSelf()
    if callback then
        callback()
    end
end

return QUIDialogDungeonChapterPassSuccess
