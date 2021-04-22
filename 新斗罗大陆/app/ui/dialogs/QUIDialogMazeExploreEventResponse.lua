-- @Author: liaoxianbo
-- @Date:   2020-08-04 11:55:34
-- @Last Modified by:   liaoxianbo
-- @Last Modified time: 2020-08-21 18:12:48
local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogMazeExploreEventResponse = class("QUIDialogMazeExploreEventResponse", QUIDialog)

local QNavigationController = import("...controllers.QNavigationController")
local QUIViewController = import("..QUIViewController")
local QRichText = import("...utils.QRichText")

function QUIDialogMazeExploreEventResponse:ctor(options)
	local ccbFile = "ccb/Dialog_MazeExplore_Event_type.ccbi"
    local callBacks = {
		{ccbCallbackName = "onTriggerClose", callback = handler(self, self._onTriggerClose)},
		{ccbCallbackName = "onTriggerOk", callback = handler(self, self._onTriggerOk)},
		{ccbCallbackName = "onTriggerChooseLeft", callback = handler(self, self._onTriggerChooseLeft)},
		{ccbCallbackName = "onTriggerChooseRight", callback = handler(self, self._onTriggerChooseRight)},
    }
    QUIDialogMazeExploreEventResponse.super.ctor(self, ccbFile, callBacks, options)
    self.isAnimation = true

	cc.GameObject.extend(self)
	self:addComponent("components.behavior.EventProtocol"):exportMethods()

	q.setButtonEnableShadow(self._ccbOwner.btn_action_one)
	q.setButtonEnableShadow(self._ccbOwner.btn_action_two1)
	q.setButtonEnableShadow(self._ccbOwner.btn_action_two2)
	
	self._closeCallBack = options.callBack
	self._leftCallBack = options.leftCallBack
	self._rightCallBack = options.rightCallBack
	self._tfOkBtn = options.tfOkBtn
	self._tfleftBtn = options.tfleftBtn
	self._tfrightBtn = options.tfrightBtn
	self._isShowCost = options.isShowCost or false
	self._allKeyCount = options.allKeyCount or 0
	self._costKeyCount = options.costKeyCount or 1
	self._textContent = options.textContent or {}
	self._costDes = options.costDes or "消耗数量"
	self._walletType = options.walletType or ITEM_TYPE.MAZE_EXPLORE_KEY
	self._pic = options.pic
	self:initView()
end

function QUIDialogMazeExploreEventResponse:viewDidAppear()
	QUIDialogMazeExploreEventResponse.super.viewDidAppear(self)

	-- self:addBackEvent(false)
end

function QUIDialogMazeExploreEventResponse:viewWillDisappear()
  	QUIDialogMazeExploreEventResponse.super.viewWillDisappear(self)

	-- self:removeBackEvent()
end

function QUIDialogMazeExploreEventResponse:resetAll( )
	self._ccbOwner.tf_text_content:setVisible(false)
	self._ccbOwner.btn_one:setVisible(false)
	self._ccbOwner.btn_two_1:setVisible(false)
	self._ccbOwner.btn_two_2:setVisible(false)
	self._ccbOwner.node_key:setVisible(false)
	
	self._ccbOwner.node_text:removeAllChildren()
end

function QUIDialogMazeExploreEventResponse:initView()
	self:resetAll()
	local richText = QRichText.new(self._textContent,480)
	richText:setAnchorPoint(ccp(0, 1))
	self._ccbOwner.node_text:addChild(richText)

	self._ccbOwner.tf_cost_des:setString(self._costDes)

	self._ccbOwner.node_key:setVisible(self._isShowCost)

	if self._pic then
		QSetDisplayFrameByPath(self._ccbOwner.sp_leftPic,self._pic)
	-- 	self._ccbOwner.sp_leftPic:setPositionY(33)
	-- else
	-- 	self._ccbOwner.sp_leftPic:setPositionY(-17)
	end
	if self._tfleftBtn then
		self._ccbOwner.btn_two_1:setVisible(true)
		self._ccbOwner.tf_two1:setString(self._tfleftBtn) 
	end

	if self._tfrightBtn then
		self._ccbOwner.btn_two_2:setVisible(true)
		self._ccbOwner.tf_two2:setString(self._tfrightBtn) 
	end

	if self._tfOkBtn then
		self._ccbOwner.btn_one:setVisible(true)
		self._ccbOwner.tf_one:setString(self._tfOkBtn) 
	end	
	local colors = self._costKeyCount > self._allKeyCount and COLORS.N or COLORS.c
	self._ccbOwner.tf_costkeyNum:setString("/"..self._costKeyCount)
	self._ccbOwner.tf_allkeyNum:setColor(colors)
	self._ccbOwner.tf_allkeyNum:setString(self._allKeyCount)
	local info = remote.items:getWalletByType(self._walletType)
	if info and info.alphaIcon then
		QSetDisplayFrameByPath(self._ccbOwner.sp_key,info.alphaIcon)
	end

end

function QUIDialogMazeExploreEventResponse:_onTriggerOk( )
	
	app:getNavigationManager():popViewController(app.middleLayer, QNavigationController.POP_TOP_CONTROLLER, nil)
	if self._closeCallBack then
		self._closeCallBack()
	end
end

function QUIDialogMazeExploreEventResponse:_onTriggerChooseLeft( )

	app:getNavigationManager():popViewController(app.middleLayer, QNavigationController.POP_TOP_CONTROLLER, nil)
	if self._leftCallBack then
		self._leftCallBack()
	end

end

function QUIDialogMazeExploreEventResponse:_onTriggerChooseRight( )
	app:getNavigationManager():popViewController(app.middleLayer, QNavigationController.POP_TOP_CONTROLLER, nil)

	if self._rightCallBack then
		self._rightCallBack()
	end
end

function QUIDialogMazeExploreEventResponse:_onTriggerClose()
  	app.sound:playSound("common_close")
	self:playEffectOut()
end

return QUIDialogMazeExploreEventResponse
