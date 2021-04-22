--[[	
	文件名称：QUIDialogBaseHelp.lua
	创建时间：2016-07-30 19:21:53
	作者：nieming
	描述：QUIDialogBaseHelp
]]

local QUIDialog = import(".QUIDialog")
local QUIDialogBaseHelp = class("QUIDialogBaseHelp", QUIDialog)
local QNavigationController = import("...controllers.QNavigationController")
local QListView = import("...views.QListView")
local QRichText = import("...utils.QRichText")
local QUIWidgetHelpDescribe = import("..widgets.QUIWidgetHelpDescribe")
--初始化
function QUIDialogBaseHelp:ctor(options)
	local ccbFile = "Dialog_Base_Help.ccbi"
	local callBacks = {
		{ccbCallbackName = "onTriggerClose", callback = handler(self, self._onTriggerClose)},
		{ccbCallbackName = "onTriggerRule", callback = handler(self, self._onTriggerRule)},
	}
	QUIDialogBaseHelp.super.ctor(self,ccbFile,callBacks,options)
	--代码
	self.isAnimation = true

	self:initData()

    self._ccbOwner.frame_tf_title:setString("帮  助")
	self._ccbOwner.node_rule:setVisible(false)
end


function QUIDialogBaseHelp:initData(  )
	-- body

end


function QUIDialogBaseHelp:initDataAtAnimationIn(  )
	-- body

end

function QUIDialogBaseHelp:initListView( ... )
	
end

function QUIDialogBaseHelp:setShowRule( bShow )
	self._ccbOwner.node_rule:setVisible(bShow)
end

--rule
function QUIDialogBaseHelp:_onTriggerRule(event)
	if q.buttonEventShadow(event, self._ccbOwner.btn_rule) == false then return end
	app.sound:playSound("common_cancel")
	self:showRule()
end

--describe：
function QUIDialogBaseHelp:_onTriggerClose(event)
	if q.buttonEventShadow(event, self._ccbOwner.btn_close) == false then return end
	--代码
	app.sound:playSound("common_cancel")
	self:close()
end

function QUIDialogBaseHelp:showRule( )
end

--describe：关闭对话框
function QUIDialogBaseHelp:close( )
	self:playEffectOut()
end

function QUIDialogBaseHelp:viewDidAppear()
	QUIDialogBaseHelp.super.viewDidAppear(self)
	--代码
end

function QUIDialogBaseHelp:viewWillDisappear()
	QUIDialogBaseHelp.super.viewWillDisappear(self)
	--代码
	
end


function QUIDialogBaseHelp:viewAnimationOutHandler()
	app:getNavigationManager():popViewController(app.middleLayer, QNavigationController.POP_TOP_CONTROLLER)
	--代码
end

--describe：viewAnimationInHandler 
function QUIDialogBaseHelp:viewAnimationInHandler()
	--代码
	self:initDataAtAnimationIn()
	self:initListView()
	
end

--describe：点击Dialog外  事件处理 
function QUIDialogBaseHelp:_backClickHandler()
	--代码
	app.sound:playSound("common_cancel")
	self:close()
end

return QUIDialogBaseHelp
