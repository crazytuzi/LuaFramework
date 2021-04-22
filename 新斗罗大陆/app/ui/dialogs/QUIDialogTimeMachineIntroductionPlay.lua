-- @Author: liaoxianbo
-- @Date:   2019-07-26 15:31:32
-- @Last Modified by:   liaoxianbo
-- @Last Modified time: 2019-11-01 17:40:23
local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogTimeMachineIntroductionPlay = class("QUIDialogTimeMachineIntroductionPlay", QUIDialog)

local QNavigationController = import("...controllers.QNavigationController")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QUIViewController = import("..QUIViewController")
local QUIWidgetTimeMachineIntroductionPlay = import("..widgets.QUIWidgetTimeMachineIntroductionPlay")
local QListView = import("...views.QListView")

function QUIDialogTimeMachineIntroductionPlay:ctor(options)
	local ccbFile = "ccb/Dialog_Timemachine_skill.ccbi"
    local callBacks = {
		{ccbCallbackName = "onTriggerClose", callback = handler(self, self._onTriggerClose)},
    }
    QUIDialogTimeMachineIntroductionPlay.super.ctor(self, ccbFile, callBacks, options)
    self.isAnimation = true

	cc.GameObject.extend(self)
	self:addComponent("components.behavior.EventProtocol"):exportMethods()

	self.instanceId = options.instanceId
    if options then
    	self._callBack = options.callBack
    end
    self:_init()
    self._ccbOwner.frame_tf_title:setString("宝屋情报")
end

function QUIDialogTimeMachineIntroductionPlay:viewDidAppear()
	QUIDialogTimeMachineIntroductionPlay.super.viewDidAppear(self)

	self:addBackEvent(true)
end

function QUIDialogTimeMachineIntroductionPlay:viewWillDisappear()
  	QUIDialogTimeMachineIntroductionPlay.super.viewWillDisappear(self)

	self:removeBackEvent()
end

function QUIDialogTimeMachineIntroductionPlay:_init()
	self._introductionTable = {}
	table.insert(self._introductionTable,{title="战斗目标",content = "限定时间内，消灭怪物越多，获得奖励越多。消灭全部怪物即为通关。"})
	table.insert(self._introductionTable,{title="战斗技巧",content = "消灭精英怪物可获得特殊支援效果，请合理选择战斗策略！"})
    self:_initPageSwipe()
end

function QUIDialogTimeMachineIntroductionPlay:_initPageSwipe()
    if not self._contentListView then
        local cfg = {
            renderItemCallBack = handler(self,self._reandFunHandler),
            ignoreCanDrag = true,
            isVertical = true,
            enableShadow = false,
            totalNumber = #self._introductionTable,
        }  
        self._contentListView = QListView.new(self._ccbOwner.sheet_layout, cfg)
    else
        -- self._contentListView:reload({totalNumber = #self._itemList})
        self._contentListView:refreshData()
    end
end

function QUIDialogTimeMachineIntroductionPlay:_reandFunHandler( list, index, info )
    local isCacheNode = true
    local data = self._introductionTable[index]
    local item = list:getItemFromCache()
    if not item then
        item = QUIWidgetTimeMachineIntroductionPlay.new()
        isCacheNode = false
    end
    item:init( data ) 
    info.item = item
    info.size = item:getContentSize()

    return isCacheNode
end

function QUIDialogTimeMachineIntroductionPlay:_backClickHandler()
    self:_onTriggerClose()
end

function QUIDialogTimeMachineIntroductionPlay:_onTriggerClose()
  	app.sound:playSound("common_close")
	self:playEffectOut()
end

function QUIDialogTimeMachineIntroductionPlay:viewAnimationOutHandler()
	local callback = self._callBack

	self:popSelf()

	if callback then
		callback()
	end
end

return QUIDialogTimeMachineIntroductionPlay
