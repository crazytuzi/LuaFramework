-- @Author: xurui
-- @Date:   2019-12-09 11:06:37
-- @Last Modified by:   xurui
-- @Last Modified time: 2019-12-12 19:24:23
local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogMaterialRecycleSelect = class("QUIDialogMaterialRecycleSelect", QUIDialog)

local QNavigationController = import("...controllers.QNavigationController")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QUIViewController = import("..QUIViewController")
local QScrollView = import("...views.QScrollView") 
local QUIWidgetSecretarySettingTitle = import("..widgets.QUIWidgetSecretarySettingTitle")
local QUIWidgetSecretarySettingSelect = import("..widgets.QUIWidgetSecretarySettingSelect")
local QUIWidgetSecretarySetting = import("..widgets.QUIWidgetSecretarySetting")

function QUIDialogMaterialRecycleSelect:ctor(options)
	local ccbFile = "ccb/Dialog_Secretary_setting.ccbi"
    local callBacks = {
		{ccbCallbackName = "onTriggerClose", callback = handler(self, self._onTriggerClose)},
		{ccbCallbackName = "onTriggerOk", callback = handler(self, self._onTriggerOk)},
		{ccbCallbackName = "onTriggerCancel", callback = handler(self, self._onTriggerCancel)},
    }
    QUIDialogMaterialRecycleSelect.super.ctor(self, ccbFile, callBacks, options)
    self.isAnimation = true

	cc.GameObject.extend(self)
	self:addComponent("components.behavior.EventProtocol"):exportMethods()

    q.setButtonEnableShadow(self._ccbOwner.btn_ok)
    q.setButtonEnableShadow(self._ccbOwner.btn_cancel)
    q.setButtonEnableShadow(self._ccbOwner.btn_close)
    self._ccbOwner.frame_tf_title:setString("自动分解")
    self._ccbOwner.tf_tips:setVisible(false)

    if options then
    	self._callBack = options.callBack
    end
  	self._selectMaterialNum = app:getUserOperateRecord():getRecordByType("material_recycle_sleect_1")
  	self._saveSoulMaterial = app:getUserOperateRecord():getRecordByType("material_recycle_sleect_2")
  	self._selectMaterialNum = self._selectMaterialNum == nil and 0 or tonumber(self._selectMaterialNum)
  	self._saveSoulMaterial = self._saveSoulMaterial == nil and 0 or tonumber(self._saveSoulMaterial)

    self:initScrollView()
end

function QUIDialogMaterialRecycleSelect:viewDidAppear()
	QUIDialogMaterialRecycleSelect.super.viewDidAppear(self)

	self:setInfo()
end

function QUIDialogMaterialRecycleSelect:viewWillDisappear()
  	QUIDialogMaterialRecycleSelect.super.viewWillDisappear(self)
end

function QUIDialogMaterialRecycleSelect:initScrollView()
	self._sheetSize = self._ccbOwner.sheet_layout:getContentSize()

	self._scrollView = QScrollView.new(self._ccbOwner.sheet, self._sheetSize, {sensitiveDistance = 10})
	self._scrollView:setVerticalBounce(true)
end

function QUIDialogMaterialRecycleSelect:setInfo()
	local widgets = {}
	local titleWidget1 = QUIWidgetSecretarySettingTitle.new()
	titleWidget1:setInfo("保留设置")
	titleWidget1:setPositionX(-10)
	local titleHeight = titleWidget1:getContentSize().height
	table.insert(widgets, titleWidget1)

	local totalHeight = titleHeight
	self._selectWidget = QUIWidgetSecretarySettingSelect.new()
	self._selectWidget:setTitleDesc("将按设置保留主力魂师不需要的材料，剩余全部分解", "剩余每种道具保留的数量：")
	self._selectWidget:setInfo(nil, self._selectMaterialNum)
	self._selectWidget:setPositionY(-totalHeight)
	self._selectWidget:setPositionX(-10)
	table.insert(widgets, self._selectWidget)
	totalHeight =  totalHeight + self._selectWidget:getContentSize().height + 10

	local info = { desc = "魂环全部保留"}
	self._saveSoulWidget = QUIWidgetSecretarySetting.new()
    self._saveSoulWidget:addEventListener(QUIWidgetSecretarySetting.EVENT_SELECT_CLICK, handler(self, self.eventClickHandler))
	self._saveSoulWidget:setInfo(info)
	self._saveSoulWidget:setSelected(false)
	self._saveSoulWidget:setPositionY(-totalHeight)
	self._saveSoulWidget:setPositionX(160)
	self._saveSoulWidget:setSelected(self._saveSoulMaterial == 1)
	totalHeight =  totalHeight + self._saveSoulWidget:getContentSize().height
	table.insert(widgets, self._saveSoulWidget)


	for _, widget in ipairs(widgets) do
		self._scrollView:addItemBox(widget)
	end
	self._scrollView:setRect(0, -totalHeight, 0, self._sheetSize.width)
end

function QUIDialogMaterialRecycleSelect:eventClickHandler(event)
	if event.name == QUIWidgetSecretarySetting.EVENT_SELECT_CLICK then
		self._saveSoulMaterial = self._saveSoulMaterial == 0 and 1 or 0

		self._saveSoulWidget:setSelected(self._saveSoulMaterial == 1)
	end
end

function QUIDialogMaterialRecycleSelect:_onTriggerOk()
    app.sound:playSound("common_switch")

  	if self._selectWidget then
  		self._selectMaterialNum = self._selectWidget:getCurNum()
  	end
  	app:getUserOperateRecord():setRecordByType("material_recycle_sleect_1", tostring(self._selectMaterialNum))
  	app:getUserOperateRecord():setRecordByType("material_recycle_sleect_2", tostring(self._saveSoulMaterial))

    self:playEffectOut()
end

function QUIDialogMaterialRecycleSelect:_onTriggerCancel()
    app.sound:playSound("common_switch")

    self:_onTriggerClose()
end

function QUIDialogMaterialRecycleSelect:_backClickHandler()
    self:_onTriggerCancel()
end

function QUIDialogMaterialRecycleSelect:_onTriggerClose()
  	app.sound:playSound("common_close")

    self._selectMaterialNum = -1
    self._saveSoulMaterial = 0
	self:playEffectOut()
end

function QUIDialogMaterialRecycleSelect:viewAnimationOutHandler()
	local callback = self._callBack

	self:popSelf()

	if callback then
		callback(self._selectMaterialNum, self._saveSoulMaterial == 1)
	end
end

return QUIDialogMaterialRecycleSelect
