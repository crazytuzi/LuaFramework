-- @Author: qinsiyang
-- @Date:   2019-11-20 17:27:58
-- 模拟战赛季满胜弹出界面
-- 
local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogMockBattleFullWin = class("QUIDialogMockBattleFullWin", QUIDialog)
local QRichText = import("...utils.QRichText")
local QUIWidgetFcaAnimation = import("..widgets.actorDisplay.QUIWidgetFcaAnimation")


function QUIDialogMockBattleFullWin:ctor(options)
	local ccbFile = "ccb/Dialog_MockBattle_FullWin.ccbi"
    local callBacks = {
		{ccbCallbackName = "onTriggerClose", callback = handler(self, self._onTriggerClose)},
		{ccbCallbackName = "onTriggerLeft", callback = handler(self, self._onTriggerClickLeft)},
		{ccbCallbackName = "onTriggerRight", callback = handler(self, self._onTriggerClickRight)},
    }

    QUIDialogMockBattleFullWin.super.ctor(self, ccbFile, callBacks, options)
	--self._isTouchSwallow = false
	if options.callback then
		self._callback = options.callback
	end
    self.isAnimation = true
  
end

function QUIDialogMockBattleFullWin:viewDidAppear()
	QUIDialogMockBattleFullWin.super.viewDidAppear(self)
	self:selfInfo()
end

function QUIDialogMockBattleFullWin:viewWillDisappear()
  	QUIDialogMockBattleFullWin.super.viewWillDisappear(self)

end


function QUIDialogMockBattleFullWin:selfInfo()
	local  max_win_num , max_lose_num  = remote.mockbattle:getMockBattleMaxWinAndLoseNum()
	self:updateNumPic(self._ccbOwner.node_num,max_win_num,0)
		local dur1 = q.flashFrameTransferDur(7)
		local dur2 = q.flashFrameTransferDur(5)
	

	self._ccbOwner.node_score:setScale(0.7)
	local arr = CCArray:create()
	arr:addObject(CCScaleTo:create(dur1, 1.2 ))
	arr:addObject(CCScaleTo:create(dur2, 1 ))
	self._ccbOwner.node_score:runAction(CCSequence:create(arr))

	local fcaAnimation = QUIWidgetFcaAnimation.new("fca/dsmnz_bao_1", "res")
	fcaAnimation:setScale(1.5)
    self._ccbOwner.node_effect:addChild(fcaAnimation)
    fcaAnimation:playAnimation("animation", false)
    fcaAnimation:setEndCallback(function( )
        fcaAnimation:removeFromParent()
    end)
end



function QUIDialogMockBattleFullWin:updateNumPic(node_ , num , anchor) --anchor -1:left 0 : mid 1:right
	local num_table = {}
	num = tonumber(num)
	while num >= 10 do
		table.insert(num_table, num % 10 )
		num = math.floor(num / 10)
	end
	table.insert(num_table, num )
	local num_node = CCNode:create()
	local width = 0
	for i,value in pairs(num_table) do
		local sprite = CCSprite:create(QResPath("mockbattle_num")[value + 1])
		sprite:setAnchorPoint(ccp(1, 0.5))
		sprite:setPositionX(- width)
		width = width + sprite:getContentSize().width 
		num_node:addChild(sprite)
	end

	if anchor  then
		if anchor == -1 then
			num_node:setPositionX(width) 
		elseif anchor == 0 then
			num_node:setPositionX( width * 0.5) 
		elseif anchor == 1 then
			num_node:setPositionX(0) 
		end
	else
		num_node:setPositionX(  width * 0.5) 
	end

	node_:removeAllChildren()
	node_:addChild(num_node)
end



function QUIDialogMockBattleFullWin:_backClickHandler()
    self:_onTriggerClose()
end

function QUIDialogMockBattleFullWin:_onTriggerClose()
  	app.sound:playSound("common_close")
	self:playEffectOut() 
end

return QUIDialogMockBattleFullWin