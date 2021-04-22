
local QUIWidget = import("...widgets.QUIWidget")
local QUIWidgetUnionDragonTrainBall = class("QUIWidgetUnionDragonTrainBall", QUIWidget)

local QUIWidgetFcaAnimation = import("...widgets.actorDisplay.QUIWidgetFcaAnimation")
local QUIWidgetAnimationPlayer = import("...widgets.QUIWidgetAnimationPlayer")

function QUIWidgetUnionDragonTrainBall:ctor(options)
	local ccbFile = "ccb/Widget_Society_Dragon_Task_Ball.ccbi"
	local callBacks = {
	}
	QUIWidgetUnionDragonTrainBall.super.ctor(self, ccbFile, callBacks, options)

	self._minProgressY = -50
	self._maxProgressY = 50

	self._id = options.id

	self:_init()
end

function QUIWidgetUnionDragonTrainBall:onEnter()
	QUIWidgetUnionDragonTrainBall.super.onEnter(self)
end

function QUIWidgetUnionDragonTrainBall:onExit()
    QUIWidgetUnionDragonTrainBall.super.onExit(self)

    if self._effect ~= nil then 
		self._effect:disappear()
		self._effect:removeFromParent()
		self._effect = nil
	end
end

function QUIWidgetUnionDragonTrainBall:_resetAll()
	self._ccbOwner.sp_selected:setVisible(false)
	self._ccbOwner.tf_progress:setVisible(false)
	self._ccbOwner.node_name:setVisible(false)
end

function QUIWidgetUnionDragonTrainBall:_init()
	self:_resetAll()

	-- 球的遮罩初始化
	local ccclippingNode = CCClippingNode:create()
	local maskDrawNode = CCDrawNode:create()
	maskDrawNode:drawCircle(45)
	ccclippingNode:setStencil(maskDrawNode)
	maskDrawNode:setPosition(0, -2)
	if not self._fcaAnimation then
		self._fcaAnimation = QUIWidgetFcaAnimation.new("fca/zongmengqiu_1", "res")
	end
	ccclippingNode:addChild(self._fcaAnimation)
	self._ccbOwner.node_ball:addChild(ccclippingNode)
 	self._fcaAnimation:playAnimation("animation", true)

	-- 名字初始化
	local taskInfo = remote.dragon:getTaskInfoById( self._id )
	if taskInfo then
		self._ccbOwner.tf_name:setString(taskInfo.name)
		self._ccbOwner.node_name:setVisible(true)
	end

	-- 动态更新的部分
	self:update()
end

function QUIWidgetUnionDragonTrainBall:update()
	-- 选择状态
	self._ccbOwner.sp_selected:setVisible(remote.dragon.selectTaskId == self._id)
	if remote.dragon.isSelectedTask then
		self._ccbOwner.sp_an:setVisible(remote.dragon.selectTaskId ~= self._id)
	else
		self._ccbOwner.sp_an:setVisible(false)
	end
	
	-- 进度数显
	local curProgressNumber, lastCurProgressNumber = remote.dragon:getTaskCurProgressById( self._id )
	local maxProgressNumber = remote.dragon:getTaskMaxProgressNumber()
	self._ccbOwner.tf_progress:setString(curProgressNumber.."/"..maxProgressNumber)
	self._ccbOwner.tf_progress:setVisible(true)

	-- 进度图显
	if not self._progressStep or self._progressStep == 0 then
		local totalStep = self._maxProgressY - self._minProgressY
		self._progressStep = totalStep / maxProgressNumber
	end
	self._fcaAnimation:setPositionY(self._minProgressY + self._progressStep * curProgressNumber)

	if remote.dragon.selectTaskId == self._id and remote.dragon.multipleId and remote.dragon.multipleId > 0 and lastCurProgressNumber ~= curProgressNumber then
		local taskMultipleInfo = remote.dragon:getTaskMultipleInfoByIndex(remote.dragon.multipleId)
		local difference = curProgressNumber - lastCurProgressNumber
		if taskMultipleInfo then
			self:_showEffect(taskMultipleInfo.multiple, difference)
		end
	end
end

function QUIWidgetUnionDragonTrainBall:_showEffect(multiple, difference)
	local addNum = remote.dragon.TASK_BASE_EXP * multiple
	if addNum > difference then
		addNum = difference
	end
	self:_showTipsAnimation(addNum)
end

function QUIWidgetUnionDragonTrainBall:_showTipsAnimation(value)
	if self._effect ~= nil then 
		self._effect:disappear()
		self._effect:removeFromParent()
		self._effect = nil
	end

	local effectName = remote.dragon:getNumChangeCcbPath(value)
	if effectName then
		local content = (value > 0) and ("+ " .. value) or value
		self._effect = QUIWidgetAnimationPlayer.new()
		self:addChild(self._effect)
		self._effect:setPosition(ccp(0, 20))
		self._effect:playAnimation(effectName, function(ccbOwner)
			ccbOwner.content:setString(content)
		end, function()
        	self._effect:disappear()
        end)
	end
end

return QUIWidgetUnionDragonTrainBall