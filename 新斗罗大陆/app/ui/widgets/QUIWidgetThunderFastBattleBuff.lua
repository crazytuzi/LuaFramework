local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetThunderFastBattleBuff = class("..widgets.QUIWidgetThunderFastBattleBuff", QUIWidget)
local QUIWidgetItemsBox = import("..widgets.QUIWidgetItemsBox")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QUIWidgetAnimationPlayer = import("..widgets.QUIWidgetAnimationPlayer")

function QUIWidgetThunderFastBattleBuff:ctor(options)
	local ccbFile = "ccb/Widget_EliteBattleAgain_thunderking2.ccbi"
	local callbacks = {}
	--设置该节点启用enter事件
	self:setNodeEventEnabled(true)
	QUIWidgetThunderFastBattleBuff.super.ctor(self, ccbFile, callbacks, options)
	self._ccbOwner.node_tips:setVisible(false)
	self._itemsBox = {}
end

function QUIWidgetThunderFastBattleBuff:getHeight()
	return self._ccbOwner.node_size:getContentSize().height
end

function QUIWidgetThunderFastBattleBuff:getWidth()
	return self._ccbOwner.node_size:getContentSize().width
end

function QUIWidgetThunderFastBattleBuff:setTitle(str)
	self._ccbOwner.tf_title:setString(str)
end

function QUIWidgetThunderFastBattleBuff:setInfo(buffIndex)
	local buffConfig = QStaticDatabase:sharedDatabase():getThunderBuffById(buffIndex)
	self._ccbOwner.tf_value:setString(string.format("%s＋%d%%", buffConfig.buff_type, buffConfig.buff_num))
	self._ccbOwner.tf_star:setString(buffConfig.star)
end

function QUIWidgetThunderFastBattleBuff:startAnimation(callFunc)
	self._animationEndCallback = callFunc
    local animationManager = tolua.cast(self:getCCBView():getUserObject(), "CCBAnimationManager")
    animationManager:runAnimationsForSequenceNamed("scaleAnimation")
    animationManager:connectScriptHandler(function(animationName)
    	animationManager:disconnectScriptHandler()
        self:_startPlayItemAnimation()
    end)
end

function QUIWidgetThunderFastBattleBuff:_startPlayItemAnimation()
	self._ccbOwner.node_tips:setVisible(true)
	if self._animationEndCallback ~= nil then
		self._animationEndCallback()
	end
end

function QUIWidgetThunderFastBattleBuff:showByNoAnimation()
	self._ccbOwner.node_tips:setVisible(true)
end

return QUIWidgetThunderFastBattleBuff
