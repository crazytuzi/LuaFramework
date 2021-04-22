--[[	
	文件名称：QUIDialogGloryarenaYaoqing.lua
	创建时间：2016-08-23 17:09:35
	作者：nieming
	描述：QUIDialogGloryarenaYaoqing
]]

local QUIDialog = import(".QUIDialog")
local QUIDialogGloryarenaYaoqing = class("QUIDialogGloryarenaYaoqing", QUIDialog)
local QNavigationController = import("...controllers.QNavigationController")
local QRichText = import("...utils.QRichText")
local QStaticDatabase = import("...controllers.QStaticDatabase")
--初始化
function QUIDialogGloryarenaYaoqing:ctor(options)
	local ccbFile = "Dialog_GloryArena_yaoqing.ccbi"
	local callBacks = {
		{ccbCallbackName = "onTriggerAccept", callback = handler(self, QUIDialogGloryarenaYaoqing._onTriggerAccept)},
	}
	QUIDialogGloryarenaYaoqing.super.ctor(self,ccbFile,callBacks,options)
	--代码
	self.isAnimation = true

	CalculateUIBgSize(self._ccbOwner.ly_bg)

	self._richText = QRichText.new(nil, 400, {lineSpacing = 5})
	self._richText:setAnchorPoint(ccp(0,1))
	self._ccbOwner.richText:addChild(self._richText)
	if not options then
		options = {}
	end
	self._rank = options.rank or 0
	self._floor = options.floor or 0
	self:setInfo()
end

function QUIDialogGloryarenaYaoqing:setInfo( ... )
	-- body
	local curState,isEnd, leftTime, nextOpenTiersTime, nextOpenFightTime = remote.tower:updateTowerTime()
	local cfg = {}

	local condition = QStaticDatabase.sharedDatabase():getConfigurationValue("COMPETION_CONDITION_1") or ""
	local conditionArray = string.split(condition, ";")
	local rankCondition = 0
	local floorCondition = 0

	if conditionArray and #conditionArray == 2 then
		rankCondition = tonumber(conditionArray[1])
		floorCondition = tonumber(conditionArray[2])
	end


	table.insert(cfg, {oType = "font", content = "截至本周五,",size = 22,color = ccc3(249,211,169)})
	local isHavaRank = false

	if self._rank <= rankCondition and self._rank ~= 0 then
		table.insert(cfg, {oType = "font", content = "你在斗魂场中位居",size = 22,color = ccc3(249,211,169)})
		table.insert(cfg, {oType = "font", content = string.format("第%d名", self._rank),size = 22,color = COLORS.b})
		isHavaRank = true
	end

	if self._floor >= floorCondition then
		local config = QStaticDatabase:sharedDatabase():getGloryTower(self._floor or 0) or {}
		if not isHavaRank then
			table.insert(cfg, {oType = "font", content = "你在荣耀段位赛中达到",size = 22,color = ccc3(249,211,169)})

		else
			table.insert(cfg, {oType = "font", content = ",荣耀段位赛中达到",size = 22,color = ccc3(249,211,169)})
		end
		table.insert(cfg, {oType = "font", content = config.name,size = 22,color = COLORS.b})

	end
	table.insert(cfg, {oType = "font", content = ",实力超群,特邀请您参加",size = 22,color = ccc3(249,211,169)})
	table.insert(cfg, {oType = "font", content = "荣耀争霸赛",size = 22,color = COLORS.b})
	table.insert(cfg, {oType = "font", content = "！",size = 22,color = ccc3(249,211,169)})
	self._richText:setString(cfg)

	self._leftTime = leftTime
	self._ccbOwner.time:setString(q.timeToDayHourMinute(self._leftTime))
end



function QUIDialogGloryarenaYaoqing:updateTime(  )
	-- body
	if self._leftTime > 0 then
		self._leftTime = self._leftTime - 1
	end
	self._ccbOwner.time:setString(q.timeToDayHourMinute(self._leftTime))
end

--describe：
function QUIDialogGloryarenaYaoqing:_onTriggerAccept(event)
	if q.buttonEventShadow(event, self._ccbOwner.btn_accept) == false then return end
	--代码
	app:getNavigationManager():popViewController(app.middleLayer, QNavigationController.POP_TOP_CONTROLLER)
	remote.tower:openGloryTower()
end

--describe：关闭对话框
function QUIDialogGloryarenaYaoqing:close( )
	self:playEffectOut()
end



function QUIDialogGloryarenaYaoqing:viewDidAppear()
	QUIDialogGloryarenaYaoqing.super.viewDidAppear(self)
	--代码
	self._timeUpdateScheduler = scheduler.scheduleGlobal(handler(self, self.updateTime),1)
end

function QUIDialogGloryarenaYaoqing:viewWillDisappear()
	QUIDialogGloryarenaYaoqing.super.viewWillDisappear(self)
	--代码
	
	if self._timeUpdateScheduler then
		scheduler.unscheduleGlobal(self._timeUpdateScheduler)
	end
end

function QUIDialogGloryarenaYaoqing:viewAnimationOutHandler()
	app:getNavigationManager():popViewController(app.middleLayer, QNavigationController.POP_TOP_CONTROLLER)
	--代码

end

--describe：viewAnimationInHandler 
--function QUIDialogGloryarenaYaoqing:viewAnimationInHandler()
	----代码
--end


--describe：点击Dialog外  事件处理 
function QUIDialogGloryarenaYaoqing:_backClickHandler()
	--代码
	self:close()
end

return QUIDialogGloryarenaYaoqing
