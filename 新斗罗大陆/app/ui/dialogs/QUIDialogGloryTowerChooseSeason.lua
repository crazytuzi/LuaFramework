-- @Author: xurui
-- @Date:   2016-08-19 17:08:50
-- @Last Modified by:   xurui
-- @Last Modified time: 2019-10-30 16:35:25
local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogGloryTowerChooseSeason = class("QUIDialogGloryTowerChooseSeason", QUIDialog)

local QNavigationController = import("...controllers.QNavigationController")
local QUIViewController = import("..QUIViewController")
local QUIWidgetGloryTowerChooseSeason = import("..widgets.QUIWidgetGloryTowerChooseSeason")

QUIDialogGloryTowerChooseSeason.EVENT_CILCK_CONFIRM = "EVENT_CILCK_CONFIRM"

function QUIDialogGloryTowerChooseSeason:ctor(options)
	
	if not options then
  		options = {}
  	end
  	self._seasonInfo = options.data or {}
	self._seasonNum = #self._seasonInfo > 4 and 4 or #self._seasonInfo
	local ccbFile = "ccb/Dialog_GloryTower_saijixuanze.ccbi"
	if self._seasonNum == 4 then
		ccbFile = "ccb/Dialog_GloryTower_saijixuanze2.ccbi"
	end

	if options.seasonNO then
		if options.seasonNO == 0 then
			self._selectSeason = self._seasonInfo[1].seasonNO
		else
			self._selectSeason = options.seasonNO
		end
	else
		self._selectSeason = self._seasonInfo[#self._seasonInfo].seasonNO
	end

	local callBacks = {
		{ccbCallbackName = "onTriggerConfirm", callback = handler(self, self._onTriggerConfirm)},
		{ccbCallbackName = "onTriggerClose", callback = handler(self, self._onTriggerClose)},
	}
	QUIDialogGloryTowerChooseSeason.super.ctor(self, ccbFile, callBacks, options)
	self.isAnimation = true
	
  	cc.GameObject.extend(self)
  	self:addComponent("components.behavior.EventProtocol"):exportMethods()

  	self._ccbOwner.frame_tf_title:setString("赛季选择")
  	
  	self:setSeasonInfo()
end

function QUIDialogGloryTowerChooseSeason:setSeasonInfo()
	self._seasonItem = {}

	local realNum = 0
	for i,v in ipairs(self._seasonInfo) do
		self._seasonItem[i] = QUIWidgetGloryTowerChooseSeason.new()
		self._ccbOwner["node_"..i]:addChild(self._seasonItem[i])
		self._seasonItem[i]:addEventListener(QUIWidgetGloryTowerChooseSeason.EVENT_CLICK, handler(self, self._clickEvent))
		self._seasonItem[i]:setInfo(self._seasonInfo[i], i)
		realNum = realNum + 1
		if self._seasonInfo[i].seasonNO == self._selectSeason then
			self._selectIndex = i
			self._seasonItem[i]:setSelectState(true)
		end
	end
	if realNum == 1 then
		self._ccbOwner["node_1"]:setPositionX(self._ccbOwner["node_2"]:getPositionX())
	elseif realNum == 2 then
		for i = 1, realNum do
			local positionX = self._ccbOwner["node_"..i]:getPositionX()
			self._ccbOwner["node_"..i]:setPositionX(positionX + 110)
		end
	end
end

function QUIDialogGloryTowerChooseSeason:_clickEvent(event)
	if event.index == nil then return end
	self._selectIndex = event.index
	for i = 1, self._seasonNum do
		self._seasonItem[i]:setSelectState(self._selectIndex == i)
	end
end

function QUIDialogGloryTowerChooseSeason:_onTriggerConfirm(event) 
	if q.buttonEventShadow(event, self._ccbOwner.btn_confirm) == false then return end
	if self._selectIndex == nil then
		app.tip:floatTip("请选择一个赛季！")
		return 
	end

    app.sound:playSound("common_small")
	self:dispatchEvent({name = QUIDialogGloryTowerChooseSeason.EVENT_CILCK_CONFIRM, seasonInfo = self._seasonInfo[self._selectIndex]})
	self:selfClose()
end

function QUIDialogGloryTowerChooseSeason:_onTriggerClose(event)
	if q.buttonEventShadow(event, self._ccbOwner.frame_btn_close) == false then return end
	app.sound:playSound("common_cancel")
	self:selfClose()
end

function QUIDialogGloryTowerChooseSeason:_backClickHandler()
  self:_onTriggerClose()
end 

function QUIDialogGloryTowerChooseSeason:selfClose()
	self:playEffectOut()
end 

function QUIDialogGloryTowerChooseSeason:viewAnimationOutHandler()
    app:getNavigationManager():popViewController(app.middleLayer, QNavigationController.POP_TOP_CONTROLLER)
end

return QUIDialogGloryTowerChooseSeason