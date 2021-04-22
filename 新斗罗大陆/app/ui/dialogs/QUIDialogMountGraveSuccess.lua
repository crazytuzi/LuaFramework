-- @Author: liaoxianbo
-- @Date:   2020-10-28 20:05:17
-- @Last Modified by:   liaoxianbo
-- @Last Modified time: 2020-10-30 09:13:03
local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogMountGraveSuccess = class("QUIDialogMountGraveSuccess", QUIDialog)

local QNavigationController = import("...controllers.QNavigationController")
local QUIViewController = import("..QUIViewController")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QUIWidgetEquipmentAvatar = import("...widgets.QUIWidgetEquipmentAvatar")
local QUIWidgetTitelEffect = import("..widgets.QUIWidgetTitelEffect")

function QUIDialogMountGraveSuccess:ctor(options)
	local ccbFile = "ccb/Dialog_SparAbsorbSuccess.ccbi"
	local callBack = {
		{ccbCallbackName = "onTriggerClose", 	callback = handler(self, self._onTriggerClose)},
		-- {ccbCallbackName = "onTriggerSelected", callback = handler(self, self._onTriggerSelected)},
	}
	QUIDialogMountGraveSuccess.super.ctor(self, ccbFile, callBack, options)

	cc.GameObject.extend(self)
	self:addComponent("components.behavior.EventProtocol"):exportMethods()

	local titleWidget = QUIWidgetTitelEffect.new()
	self._ccbOwner.node_title_effect:addChild(titleWidget)
	
    self.isAnimation = true --是否动画显示
	local page = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
	page.topBar:setAllSound(false)

    self._isEnd = false
	self.mountID = options.mountID
	self.callback = options.callback
	self.oldmountInfo = options.oldmountInfo
	self.newMountInfo = options.newMountInfo
	-- self._successTip = options.successTip
	-- self._isSelected = false

	self._oldProp = {}
	self._newProp = {}

	app.sound:playSound("task_complete")

	QSetDisplayFrameByPath(self._ccbOwner.sp_title,QResPath("grave_moun_titile_path")[1])
	self._ccbOwner.node_select:setVisible(false)
	-- self._ccbOwner.node_select:setVisible(app.master:showMasterSelect(self._successTip))
 --    self._ccbOwner.tf_show_tips:setString(app.master:getMasterShowTips())
 --    self:showSelectState()

end

function QUIDialogMountGraveSuccess:viewDidAppear()
	QUIDialogMountGraveSuccess.super.viewDidAppear(self)

	self:setMountPropInfo()

    self._animationManager = tolua.cast(self._view:getUserObject(), "CCBAnimationManager")
    self._animationManager:runAnimationsForSequenceNamed("1")
    self._animationManager:connectScriptHandler(handler(self, self.viewAnimationEndHandler))
end

function QUIDialogMountGraveSuccess:viewWillDisappear()
	QUIDialogMountGraveSuccess.super.viewWillDisappear(self)
end

function QUIDialogMountGraveSuccess:viewAnimationEndHandler(name)
	self._isEnd = true
end


function QUIDialogMountGraveSuccess:setMountPropInfo()
	if self._mountOldItem == nil then
		self._mountOldItem = QUIWidgetEquipmentAvatar.new()
		self._mountOldItem:setPositionY(20)
		self._ccbOwner.old_head:addChild(self._mountOldItem)
		self._mountOldItem:stopAction()
	end
	self._mountOldItem:setMountInfo(self.oldmountInfo,self.oldmountInfo.grade)
	self._mountOldItem:hideAllColor()

	if self._mountNewItem == nil then
		self._mountNewItem = QUIWidgetEquipmentAvatar.new()
		self._mountNewItem:setPositionY(20)
		self._ccbOwner.new_head:addChild(self._mountNewItem)
		self._mountNewItem:stopAction()
	end
	self._mountNewItem:setMountInfo(self.newMountInfo,self.newMountInfo.grade)
	self._mountNewItem:hideAllColor()

	local graveLv1 = self.oldmountInfo.grave_level  or 0
	local graveLv2 = self.newMountInfo.grave_level  or 1

	local itemConfig = db:getCharacterByID(self.mountID)
	self._ccbOwner.oldName:setString((itemConfig.name or "").." +"..graveLv1)
	self._ccbOwner.newName:setString((itemConfig.name or "").." +"..graveLv2)

	local fontColor = QIDEA_QUALITY_COLOR[remote.mount:getColorByMountId(self.mountID)] or COLORS.b
	self._ccbOwner.oldName:setColor(fontColor)
	self._ccbOwner.oldName = setShadowByFontColor(self._ccbOwner.oldName, fontColor)
	self._ccbOwner.oldName:setPositionY(-40)

	self._ccbOwner.newName:setColor(fontColor)
	self._ccbOwner.newName = setShadowByFontColor(self._ccbOwner.newName, fontColor)
	self._ccbOwner.newName:setPositionY(-40)

	local graveConfig1 = remote.mount:getGraveInfoByAptitudeLv(itemConfig.aptitude, graveLv1 )
	local graveConfig2 = remote.mount:getGraveInfoByAptitudeLv(itemConfig.aptitude, graveLv2 )

	if q.isEmpty(graveConfig1) == false then
		self._oldProp = remote.mount:getUISinglePropInfo(graveConfig1)
	end
	if q.isEmpty(graveConfig2) == false then
		self._newProp = remote.mount:getUISinglePropInfo(graveConfig2)
	end

	for i = 1, 8 do
		if self._newProp[i] then
			self._ccbOwner["node_title_"..i]:setString(self._newProp[i].name.."：")
			self._ccbOwner["tf_new_value_"..i]:setString(self._newProp[i].value)
			if self._oldProp[i] then
				self._ccbOwner["tf_old_value_"..i]:setString(self._oldProp[i].value)
			else
				self._ccbOwner["tf_old_value_"..i]:setString(0)
			end
		else
			self._ccbOwner["node_prop_"..i]:setVisible(false)
		end
	end
end

function QUIDialogMountGraveSuccess:showSelectState()
    self._ccbOwner.btn_select:setHighlighted(not self._isSelected)
end

function QUIDialogMountGraveSuccess:_onTriggerSelected()
    self._isSelected = not self._isSelected
    self:showSelectState()
end

function QUIDialogMountGraveSuccess:_backClickHandler()
    self:_onTriggerClose()
end

function QUIDialogMountGraveSuccess:_onTriggerClose()
	if self._isEnd == true then
		self:playEffectOut()
	end
end

function QUIDialogMountGraveSuccess:viewAnimationOutHandler()
	local callback = self.callback

	-- if self._isSelected then
 --        app.master:setMasterShowState(self._successTip)
 --    end


	self:popSelf()
    if callback ~= nil then
    	callback()
    end
end

return QUIDialogMountGraveSuccess
