
local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogStormArenaChooseSeason = class("QUIDialogStormArenaChooseSeason", QUIDialog)

local QNavigationController = import("...controllers.QNavigationController")
local QUIViewController = import("..QUIViewController")
local QUIWidgetStormArenaChooseSeason = import("..widgets.QUIWidgetStormArenaChooseSeason")

QUIDialogStormArenaChooseSeason.EVENT_CILCK_CONFIRM = "EVENT_CILCK_CONFIRM"

function QUIDialogStormArenaChooseSeason:ctor(options)
	if not options then
  		options = {}
  	end
  	self._seasonInfo = remote.stormArena:getSeasonInfo() or {}
  	self._curSeasonNO = remote.stormArena.seasonNO
	self._seasonNum = #self._seasonInfo > 4 and 4 or #self._seasonInfo
	local ccbFile = "ccb/Dialog_GloryTower_saijixuanze.ccbi"
	if self._seasonNum == 4 then
		ccbFile = "ccb/Dialog_GloryTower_saijixuanze2.ccbi"
	end
	-- print("QUIDialogStormArenaChooseSeason:ctor() ", self._curSeasonNO, self._seasonNum)
	if self._curSeasonNO then
		if self._curSeasonNO == 0 and #self._seasonInfo > 0 then
			self._selectSeason = self._seasonInfo[1].seasonNO
		else
			self._selectSeason = self._curSeasonNO
		end
	else
		self._selectSeason = self._seasonInfo[#self._seasonInfo].seasonNO
	end

	local callBacks = {
		{ccbCallbackName = "onTriggerConfirm", callback = handler(self, self._onTriggerConfirm)},
		{ccbCallbackName = "onTriggerClose", callback = handler(self, self._onTriggerClose)},
	}
	QUIDialogStormArenaChooseSeason.super.ctor(self, ccbFile, callBacks, options)
	self.isAnimation = true
	
  	cc.GameObject.extend(self)
  	self:addComponent("components.behavior.EventProtocol"):exportMethods()
  	
  	self._ccbOwner.frame_tf_title:setString("赛季选择")

  	self:setSeasonInfo()
end

function QUIDialogStormArenaChooseSeason:setSeasonInfo()
	self._seasonItem = {}
	local realNum = 0
	for i, v in ipairs(self._seasonInfo) do
		self._seasonItem[i] = QUIWidgetStormArenaChooseSeason.new()
		self._ccbOwner["node_"..i]:addChild(self._seasonItem[i])
		self._seasonItem[i]:addEventListener(QUIWidgetStormArenaChooseSeason.EVENT_CLICK, handler(self, self._clickEvent))
		self._seasonItem[i]:setInfo(v, i)
		realNum = realNum + 1
		if self._seasonInfo[i].seasonNo == self._selectSeason then
			self._selectIndex = i
			self._seasonItem[i]:setSelectState(true)
		end 
	end
	
	if realNum <= 2 then
		for i = 1, realNum do
			local positionX = self._ccbOwner["node_"..i]:getPositionX()
			self._ccbOwner["node_"..i]:setPositionX(positionX + 220/realNum)
		end
	end
end

function QUIDialogStormArenaChooseSeason:_clickEvent(event)
	if event.index == nil then return end
	self._selectIndex = event.index
	for i = 1, self._seasonNum do
		self._seasonItem[i]:setSelectState(self._selectIndex == i)
	end
end

function QUIDialogStormArenaChooseSeason:_onTriggerConfirm(event)
	if q.buttonEventShadow(event, self._ccbOwner.btn_confirm) == false then return end
	if self._selectIndex == nil then
		app.tip:floatTip("请选择一个赛季！")
		return 
	end

    app.sound:playSound("common_small")
	self:dispatchEvent({name = QUIDialogStormArenaChooseSeason.EVENT_CILCK_CONFIRM, seasonInfo = self._seasonInfo[self._selectIndex]})
	self:selfClose()
end

function QUIDialogStormArenaChooseSeason:_onTriggerClose(event)
	if q.buttonEventShadow(event, self._ccbOwner.frame_btn_close) == false then return end
	app.sound:playSound("common_cancel")
	self:selfClose()
end

function QUIDialogStormArenaChooseSeason:_backClickHandler()
  self:_onTriggerClose()
end 

function QUIDialogStormArenaChooseSeason:selfClose()
	self:playEffectOut()
end 

function QUIDialogStormArenaChooseSeason:viewAnimationOutHandler()
    app:getNavigationManager():popViewController(app.middleLayer, QNavigationController.POP_TOP_CONTROLLER)
end

return QUIDialogStormArenaChooseSeason