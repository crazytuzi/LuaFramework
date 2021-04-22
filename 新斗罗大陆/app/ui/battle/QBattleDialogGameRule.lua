
local QBattleDialog = import(".QBattleDialog")
local QBattleDialogGameRule = class(".QBattleDialogGameRule", QBattleDialog)

function QBattleDialogGameRule:ctor(ccbi, closeCallback)
	self._closeCallback = closeCallback
	QBattleDialogGameRule.super.ctor(self, ccbi)

	local ccbNode =  tolua.cast(self:getChildren():objectAtIndex(1), "CCNode")
	ccbNode:retain()
	ccbNode:removeFromParentAndCleanup(false)

	local ccbProxy = CCBProxy:create()
    local ccbOwner = {}
    local animationNode = CCBuilderReaderLoad("ccb/QDialog.ccbi", ccbProxy, ccbOwner)

    ccbOwner.dialogTarget:addChild(ccbNode)
    ccbNode:release()
    self:addChild(animationNode)

    if app.scene:getActiveDungeonInstanceId() == ACTIVITY_DUNGEON_TYPE.TREASURE_BAY then
        self._ccbOwner.label_experience:setVisible(false)
    elseif app.scene:getActiveDungeonInstanceId() == ACTIVITY_DUNGEON_TYPE.BLACK_IRON_BAR then
        self._ccbOwner.label_money:setVisible(false)
    else
        self._ccbOwner.label_experience:setVisible(false)
        self._ccbOwner.label_money:setVisible(false)
    end

    self._animationManager = tolua.cast(animationNode:getUserObject(), "CCBAnimationManager")
    self._animationManager:runAnimationsForSequenceNamed("showDialogScale")

    scheduler.performWithDelayGlobal(function()
        if self.close and not self._closed then
            self:close()
        end
    end, 2)
end

function QBattleDialogGameRule:close()
    if not self._closed then
        self._animationManager:runAnimationsForSequenceNamed("hideDialogScale")
        self._animationManager:connectScriptHandler(function(animationName)
            self._animationManager:disconnectScriptHandler()
            if self._closeCallback then
    	    	self._closeCallback()
    	    end
    		QBattleDialogGameRule.super.close(self)
        end)
        self._closed = true
    end
end

function QBattleDialogGameRule:_backClickHandler()
    self:close()
end

return QBattleDialogGameRule