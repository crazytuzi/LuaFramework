-- 
-- Kumo.Wang
-- 弹框通知界面_有icon版
-- 

local QUIDialogPromptWithAward = import("..dialogs.QUIDialogPromptWithAward")
local QUIDialogDragonTrainBuffPrompt = class("QUIDialogDragonTrainBuffPrompt", QUIDialogPromptWithAward)

local QRichText = import("...utils.QRichText") 

function QUIDialogDragonTrainBuffPrompt:ctor(options)
    QUIDialogDragonTrainBuffPrompt.super.ctor(self, options)

    if options then
        self._buffIcon = options.buffIcon
    end

    if self._buffIcon then
        self._buffIcon:setVisible(false)
    end

    self._ccbOwner.node_award:removeAllChildren()
    if self._iconPath then
        self._icon = CCSprite:create(self._iconPath)
        if self._icon then
            self._ccbOwner.node_award:addChild(self._icon)
        end
    end
end

function QUIDialogDragonTrainBuffPrompt:_onTriggerClose()
    app.sound:playSound("common_close")

    local actionTime = 0.3

    if self:safeCheck() and self._buffIcon and self._icon then
        local buffPos = self._buffIcon:convertToWorldSpaceAR(ccp(0, 0))
        print("QUIDialogDragonTrainBuffPrompt:_onTriggerClose() ", buffPos.x, buffPos.y)
        local endPos = self._ccbOwner.node_award:convertToNodeSpace(buffPos)
        print("QUIDialogDragonTrainBuffPrompt:_onTriggerClose() ", endPos.x, endPos.y)

        local actions = CCArray:create()
        actions:addObject(CCFadeOut:create(actionTime))
        actions:addObject(CCScaleTo:create(actionTime, 0.5))
        actions:addObject(CCMoveTo:create(actionTime, endPos))
        self._icon:runAction(CCSpawn:create(actions))
    end

    scheduler.performWithDelayGlobal(function()
        if self:safeCheck() then
            if self._buffIcon then
                self._buffIcon:setVisible(true)
            end
            self:playEffectOut()
        end
    end, actionTime)
    
end

function QUIDialogDragonTrainBuffPrompt:viewAnimationOutHandler()
    self:popSelf()
end

return QUIDialogDragonTrainBuffPrompt
