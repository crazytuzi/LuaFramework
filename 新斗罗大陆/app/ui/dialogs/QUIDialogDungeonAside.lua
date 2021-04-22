--
-- Author: Kumo
-- Date: 2017-12-12 14:08:11
--
local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogDungeonAside = class("QUIDialogDungeonAside", QUIDialog)

local QNavigationController = import("...controllers.QNavigationController")
local QRichText = import("...utils.QRichText")

local maxWidth = 580 -- dialog max width( 如果会溢出则换行显示，如果换行仍会移除，则换屏显示)
local defaultFontSize = 32
local defaultFontColor = ccc3(255, 245, 230)
local defaultStrokeColor = ccc3(48, 13, 0)

function QUIDialogDungeonAside:ctor(options) 
 	local ccbFile = "ccb/Dialog_xuzhang_start.ccbi" 
	local callBacks = {
	    {ccbCallbackName = "onTriggerChangePage", callback = handler(self, QUIDialogDungeonAside._onTriggerChangePage)},
	}
	QUIDialogDungeonAside.super.ctor(self, ccbFile, callBacks, options)
	self.isAnimation = false
	
    self._callback = options.callback
	self._isSay = options.isSay ~= nil and true or false

    self._isEnd = false
    RunActionDelayTime(self:getView(), function()
        self:addWord(self:getOptions().text, self:getOptions().sayFun)
        remote.flag:set(remote.flag.FLAG_DUNGEON_ASIDE, self:getOptions().index)
        self._isEnd = true
    end, 2)

    self:setPlotBgImage(options.config)
    self._ccbOwner.tf_title:setString(options.title or "")
end

function QUIDialogDungeonAside:viewDidAppear()
    QUIDialogDungeonAside.super.viewDidAppear(self)

end

function QUIDialogDungeonAside:viewWillDisappear()
    QUIDialogDungeonAside.super.viewWillDisappear(self)

    if self._time ~= nil then
        scheduler.unscheduleGlobal(self._time)
        self._time = nil
    end
end

function QUIDialogDungeonAside:addWord(word, callFun)
    self._word = "    "..word
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

function QUIDialogDungeonAside:say()
    if self._isSaying == true or self._isSay == false then return end

    self._isSaying = true
    self._sayWord = ""
    self._sayPosition = 1
    self._startPosition = 1
    self._lineNum = 1

    self:sayWord()
end

function QUIDialogDungeonAside:sayWord()
    local delayTime = TUTORIAL_ONEWORD_TIME/2

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
        -- print("str = "..str)
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
        if self._sayFun ~= nil then
            self._sayFun()
        end
        self:stopSay()
    end
end

function QUIDialogDungeonAside:stopSay()
    self._sayFun = nil
    self._isSaying = false
    if self._time ~= nil then
        scheduler.unscheduleGlobal(self._time)
    end
end

function QUIDialogDungeonAside:showWords(words)
    if self._colorfulText == nil then
        self._colorfulText = QRichText.new("", maxWidth, {stringType = 1, defaultColor = ccc3(255, 255, 255), defaultSize = 28, lineSpacing = 15, strokeColor = ccc3(66,29,28)})
        local height = self._colorfulText:getCascadeBoundingBox().size.height
        self._colorfulText:setPosition(-maxWidth/2, -height/2)
        self._colorfulText:setAnchorPoint(0, 1)
        self._ccbOwner.textNode:addChild(self._colorfulText)
    end
    self._colorfulText:setString(words)
end

function QUIDialogDungeonAside:setPlotBgImage(config)
    if config == nil then
        return
    end
    local sprite = CCSprite:create(config.start_pitcure)
    if sprite then
        self._ccbOwner.sp_bg:setDisplayFrame(sprite:getDisplayFrame())
        CalculateUIBgSize(self._ccbOwner.sp_bg)
        -- local position = ccp(self._ccbOwner.sp_bg:getPosition())
        -- self._ccbOwner.sp_bg:setPosition(position.x+(config.pitcure_x or 0), position.y+(config.pitcure_y or 0))
        -- self._ccbOwner.sp_bg:setScale(config.pitcure_scale or 1)
        -- if config.pitcure_isturn then
        --     self._ccbOwner.sp_bg:setScaleX(self._ccbOwner.sp_bg:getScaleX() * -1)
        -- end
    end
end

function QUIDialogDungeonAside:_onTriggerChangePage()
    self:_backClickHandler()
end

function QUIDialogDungeonAside:_backClickHandler()
    if self._isSaying then
        self:stopSay()
        self:showWords(self._word)
    elseif self._isEnd then
        self:_onTriggerClose()
    end
end

function QUIDialogDungeonAside:_onTriggerClose()
    self:popSelf()
    if self._callback then
        self._callback()
    end
end

return QUIDialogDungeonAside