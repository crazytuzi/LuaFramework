local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetStoreBoss = class("QUIWidgetStoreBoss", QUIWidget)

local QStaticDatabase = import("...controllers.QStaticDatabase")

function QUIWidgetStoreBoss:ctor(options)
    local ccbFile = "ccb/Widget_shopboss.ccbi"
    local callBacks = {
        {ccbCallbackName = "onTirggerHeadClick", callback = handler(self, QUIWidgetStoreBoss._onTirggerHeadClick)}
    }
    QUIWidgetStoreBoss.super.ctor(self, ccbFile, callBacks, options)
  
    if options ~= nil then
        self.shopType = options.type
        self._noAuto = options.noAuto or false
    end
    self:resetAll()

    local npcInfo = QStaticDatabase.sharedDatabase():getShopNpcInfo(self.shopType)
    if npcInfo then
        self:setActorImage(npcInfo[1].show_hero)
    end
    if self._noAuto == false then
        self:showSpeakWord("welcome")
    end
end

function QUIWidgetStoreBoss:resetAll()
    self._ccbOwner.head_btn:setTouchSwallowEnabled(true)
  
    self.oldWordSize = self._ccbOwner.speak_word:getContentSize()
    self.oldWordBgSize = self._ccbOwner.speak_bg:getContentSize()
    self._ccbOwner.speak_word:setString("")
    self._ccbOwner.speak_node:setVisible(false)
end

function QUIWidgetStoreBoss:showSpeakWord(talkType, shopType)
    if self.actionHandler ~= nil then
        self._ccbOwner.speak_node:stopAction(self.actionHandler)
        self.actionHandler = nil
    end

    if shopType ~= nil then
        self.shopType = shopType
    end
    
    local talkWord = QStaticDatabase.sharedDatabase():getShopTalk(self.shopType, talkType)
    if talkWord == nil or next(talkWord) == nil then return end

    local nums = table.nums(talkWord)
    if nums ~= 0 then
        local num = math.random(nums)
        talkWord = talkWord[num]
    end
  
    self._ccbOwner.speak_node:setVisible(true)
    if talkWord == nil then
        self._ccbOwner.speak_node:setVisible(false)
    else
        self._ccbOwner.speak_word:setString(talkWord)
    end
  
  -- self.newWordSize = self._ccbOwner.speak_word:getContentSize()
  -- local change = self.oldWordSize.width - self.newWordSize.width + 10
  -- self._ccbOwner.speak_bg:setContentSize(CCSize(self.oldWordBgSize.width - change, self.oldWordBgSize.height))
  
    self:delayTimeClose()
end
--对话框延迟消失
function QUIWidgetStoreBoss:delayTimeClose()
    local delayTime = 1
  
    self._ccbOwner.speak_node:setCascadeOpacityEnabled(true)
    self._ccbOwner.speak_node:setOpacity(255)
    local delay = CCDelayTime:create(delayTime)
    local fadeOut = CCFadeOut:create(delayTime)
    local callFunc = CCCallFunc:create(function()
        self.actionHandler = nil
    end)
    local array = CCArray:create()
    array:addObject(delay)
    array:addObject(fadeOut)
    array:addObject(callFunc)
    local ccsequence = CCSequence:create(array)
    self.actionHandler = self._ccbOwner.speak_node:runAction(ccsequence)
end

--根据不同商店显示不同NPC
function QUIWidgetStoreBoss:setActorImage(imageFile)
    if imageFile == nil then
        self._ccbOwner.node_head:setVisible(false)
        return
    end
    self._ccbOwner.node_head:setTexture(CCTextureCache:sharedTextureCache():addImage(imageFile))
end

function QUIWidgetStoreBoss:setTalkWordPosition(offsetX, offsetY)
    local position = ccp(self._ccbOwner.speak_node:getPosition())
    self._ccbOwner.speak_node:setPosition(ccp(position.x + offsetX, position.y + offsetY))
end

function QUIWidgetStoreBoss:_onTirggerHeadClick()
    self:showSpeakWord("touch")
end

return QUIWidgetStoreBoss 