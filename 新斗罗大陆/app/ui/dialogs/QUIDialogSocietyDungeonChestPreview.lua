--
-- Author: Kumo.Wang
-- Date: Wed Jun  1 17:54:13 2016
--
local QUIDialog = import(".QUIDialog")
local QUIDialogSocietyDungeonChestPreview = class("QUIDialogSocietyDungeonChestPreview", QUIDialog)

local QNavigationController = import("...controllers.QNavigationController")
local QUIWidgetSocietyDungeonPreviewChest = import("..widgets.QUIWidgetSocietyDungeonPreviewChest")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QScrollView = import("...views.QScrollView")

local CHEST_LINEDISTANCE = 30
local CHEST_ROWDISTANCE = 30
local MAX_CHEST_ROW = 5
local BTN_COUNT = 6

function QUIDialogSocietyDungeonChestPreview:ctor(options)
	local ccbFile = "ccb/Dialog_society_baoxiang_yulan.ccbi"
	local callBacks = {
		{ccbCallbackName = "onTriggerClick", callback = handler(self, QUIDialogSocietyDungeonChestPreview._onTriggerClick)},
		{ccbCallbackName = "onTriggerClose", callback = handler(self, QUIDialogSocietyDungeonChestPreview._onTriggerClose)},
	}
	QUIDialogSocietyDungeonChestPreview.super.ctor(self, ccbFile, callBacks, options)
	self._ccbOwner.frame_tf_title:setString("奖励预览")
	self.isAnimation = true
	cc.GameObject.extend(self)
	self:addComponent("components.behavior.EventProtocol"):exportMethods()

	self._chapter = options.chapter
	self._wave = options.wave or 1

	self._bossList = {}
	self._chestList = {}
	self._awardList = {}
	self._induceAwardList = {}

	self._totalChestHeight = 0
	self._totalChestWidth = 0

    ------------------------------------------------------------------------------------------------------------------------------------

	self._height = self._ccbOwner.sheet_layout_award:getContentSize().height
    self._width = self._ccbOwner.sheet_layout_award:getContentSize().width

    self._scrollAwardView = QScrollView.new(self._ccbOwner.sheet_award, CCSize(self._width, self._height), { sensitiveDistance = 10})
    self._scrollAwardViewProxy = cc.EventProxy.new(self._scrollAwardView)
    self._scrollAwardViewProxy:addEventListener(QScrollView.GESTURE_MOVING, handler(self, self._onAwardEvent))
    self._scrollAwardViewProxy:addEventListener(QScrollView.GESTURE_END, handler(self, self._onAwardEvent))
    self._scrollAwardViewProxy:addEventListener(QScrollView.GESTURE_BEGAN, handler(self, self._onAwardEvent))
    self._scrollAwardView:setVerticalBounce(true)
    self._scrollAwardView:setGradient(false)

	------------------------------------------------------------------------------------------------------------------------------------

	self:_init()
end

function QUIDialogSocietyDungeonChestPreview:viewAnimationOutHandler()
	app:getNavigationManager():popViewController(app.middleLayer, QNavigationController.POP_TOP_CONTROLLER)
end

function QUIDialogSocietyDungeonChestPreview:viewDidAppear()
	QUIDialogSocietyDungeonChestPreview.super.viewDidAppear(self)

end

function QUIDialogSocietyDungeonChestPreview:viewWillDisappear()
	QUIDialogSocietyDungeonChestPreview.super.viewWillDisappear(self)

	if self._scheduler then
		scheduler.unscheduleGlobal(self._scheduler)
		self._scheduler = nil
	end

	self._scrollAwardViewProxy:removeAllEventListeners()
end

function QUIDialogSocietyDungeonChestPreview:_backClickHandler()
	self:_onTriggerClose()
end

function QUIDialogSocietyDungeonChestPreview:_onTriggerClose(e)
	if q.buttonEventShadow(e, self._ccbOwner.frame_btn_close) == false then return end
	app.sound:playSound("common_cancel")
   	self:playEffectOut()
end

function QUIDialogSocietyDungeonChestPreview:_onTriggerClick(e, target)
	if q.buttonEventShadow(e, target) == false then return end
	for i = 1, BTN_COUNT, 1 do
		if target == self._ccbOwner["btn_award_"..i] then
			if self._wave ~= i then
				self._wave = i
				self:_initChestList()
			end
			self:_updateTitle()
		end
	end
end

function QUIDialogSocietyDungeonChestPreview:_onAwardEvent( event )
	if event.name == QScrollView.GESTURE_BEGAN then
	elseif event.name == QScrollView.GESTURE_MOVING then
		self._isMoving = true
	elseif event.name == QScrollView.GESTURE_END then
		scheduler.performWithDelayGlobal(function()
			self._isMoving = false
			end, 0.1)
	end
end

function QUIDialogSocietyDungeonChestPreview:_init()
	for i = 1, BTN_COUNT, 1 do
		self._ccbOwner["node_btn_"..i]:setVisible(false)
	end
	self._ccbOwner.tf_info:setString("")

	self._firstNodeBtnX = -278
	self._firstNodeBtnY = 197

	self:_initTitle()
	self:_initChestList()

	-- 和时间有关的数据
	self:_updateTime()
	self._scheduler = scheduler.scheduleGlobal(function ()
		self:_updateTime()
	end, 1)
end

function QUIDialogSocietyDungeonChestPreview:_initTitle()
	local bossList = remote.union:getConsortiaBossList(self._chapter)
	if not bossList or #bossList == 0 then return end
	table.sort(bossList, function(a, b)
			return a.wave < b.wave
		end)
	local index = 0
	-- 这里的宝箱不是每个boss都有，标号也不是连续的，所以标签按钮，根据第一个按钮在ccb里的位置，其他的挨着排。
	for _, value in pairs(bossList) do
		local scoietyWaveConfig = QStaticDatabase.sharedDatabase():getScoietyWave(value.wave, value.chapter)
		if scoietyWaveConfig and scoietyWaveConfig.sociaty_box then
			local chapter = value.chapter
			local wave = value.wave
			local scoietyWaveConfig = QStaticDatabase.sharedDatabase():getScoietyWave(wave, chapter)
			local character = QStaticDatabase.sharedDatabase():getCharacterByID(scoietyWaveConfig.boss)

			self._ccbOwner["node_btn_"..wave]:setVisible(true)
			self._ccbOwner["tf_name_"..wave]:setString(character.name)
			self:_autoFontSize(self._ccbOwner["tf_name_"..wave])
			self._ccbOwner["btn_award_"..wave]:setVisible(true)
			self._ccbOwner["node_btn_"..wave]:setPosition(self._firstNodeBtnX + index * 130, self._firstNodeBtnY)
			index = index + 1
		end
	end

	self:_updateTitle()
end

function QUIDialogSocietyDungeonChestPreview:_autoFontSize(node)
	local nodeWidth = node:getContentSize().width
	print(nodeWidth, nodeWidth, nodeWidth, nodeWidth, nodeWidth)
	node:setScale(1)
	local maxWidth = 120
	if nodeWidth > maxWidth then
		node:setScale(1 - (nodeWidth - maxWidth)/maxWidth)
	end
end

function QUIDialogSocietyDungeonChestPreview:_initChestList()
	local row = 0
	local height = 0
	local width = 0
	local line = 0
	self._totalChestHeight = 0
	self._totalChestWidth = 0
	self._awardList = {}
	self._chestList = {}
	self._scrollAwardView:clear()
	
	self._awardList = remote.union:analyseAwards(self._wave, self._chapter)
	if not self._awardList or #self._awardList == 0 then return end
	-- QPrintTable(self._awardList)
	local effectCount = 0
	for _, award in pairs(self._awardList) do
		local itemId = 0
		local itemType = ""
		if tonumber(award.idOrType) then
			itemId = award.idOrType
			itemType = ITEM_TYPE.ITEM
		else
			itemId = nil
			itemType = award.idOrType
		end

		local isEffect = false
		if effectCount < 2 then
			isEffect = true
			effectCount = effectCount + 1
		end
		local chest = QUIWidgetSocietyDungeonPreviewChest.new( {itemId = itemId, itemType = itemType, itemCount = tonumber(award.itemCount), maxCount = tonumber(award.chestCount), isEffect = isEffect} )
		self._scrollAwardView:addItemBox(chest)
		table.insert( self._chestList, chest )

		height = chest:getHeight()
		width = chest:getWidth()
		local positionX = 15 + (width + CHEST_ROWDISTANCE) * row
		local positionY = -30 - ((height + CHEST_LINEDISTANCE) * line)
		chest:setPosition(ccp(positionX, positionY))

		row = row + 1
		if row % MAX_CHEST_ROW == 0 then
			line = line + 1
			row = 0
		end
	end
	if row == 0 and line > 0 then
		line = line - 1
	end
	self._totalChestHeight = self._totalChestHeight + 30 + (height + CHEST_LINEDISTANCE) * (line + 1)
	self._totalChestWidth = self._width
	self._scrollAwardView:setRect(0, -self._totalChestHeight, 0, -self._totalChestWidth)

	self:_updateChest()
end

-- 一些时间上的设定
-- 10:00 ~ 22:00 可击杀BOSS
-- 10:00 ~ 5:00 击杀BOSS之后可以领取宝箱
-- 5:00 刷新宝箱
-- 总结下来，宝箱的领取条件只有一个，BOSS死亡！
function QUIDialogSocietyDungeonChestPreview:_updateTime()
	if (not remote.user.userConsortia.consortiaId or remote.user.userConsortia.consortiaId == "") then return end
	
	local curTimeTbl = q.date("*t", q.serverTime())
	local startTime = remote.union:getSocietyDungeonStartTime()
	local endTime = remote.union:getSocietyDungeonEndTime()
	if curTimeTbl.hour < startTime or curTimeTbl.hour >= endTime then
		-- self._ccbOwner.tf_info:setString("宗门副本挑战时间为 10：00 至 22：00")
		self._ccbOwner.tf_info:setString(startTime.."：00～"..endTime.."：00内，每击杀一个BOSS，都可开启一份宝藏，宗门成员可从对应奖励中随机抽取一种")
	else
		-- local isDead = self:_isBossDead()
		local maxH = endTime - 1
		local h,m,s = 0,0,0
		h = maxH - curTimeTbl.hour
		m = 59 - curTimeTbl.min
		s = 60 - curTimeTbl.sec
		local timeStr = string.format("%02d:%02d:%02d", h, m, s)
		-- print("===============")
		-- print(string.format("%02d:%02d:%02d", curTimeTbl.hour, curTimeTbl.min, curTimeTbl.sec))
		-- print(timeStr)
		-- print("===============")
		self._ccbOwner.tf_info:setString(timeStr.."内，每击杀一个BOSS，都可开启一份宝藏，宗门成员可从对应奖励中随机抽取一种")
		-- if isDead then
		-- 	self._ccbOwner.tf_info:setString("每日5点重置，请尽快领取")
			
		-- else
		-- 	self._ccbOwner.tf_info:setString(timeStr.."内击杀，可以领取")
		-- end
	end
end

function QUIDialogSocietyDungeonChestPreview:_updateTitle()
	for i = 1, BTN_COUNT, 1 do
		self._ccbOwner["btn_award_"..i]:setHighlighted(false)
		self._ccbOwner["tf_name_"..i]:setColor(COLORS.T)
		if self._wave == i then
			self._ccbOwner["btn_award_"..i]:setHighlighted(true)
			self._ccbOwner["tf_name_"..i]:setColor(COLORS.S)
		end
	end
end

function QUIDialogSocietyDungeonChestPreview:_updateChest()
	local bossList = remote.union:getConsortiaBossList(self._chapter)

	for _, boss in pairs(bossList) do
		if boss.wave == self._wave then
			if boss.bossAwardList and #boss.bossAwardList > 0 then
				-- 有宝箱被开启
				self:_induceAwards(boss.bossAwardList)
				for _, chest in pairs(self._chestList) do
					local key = chest:getKey()
					-- QPrintTable(self._induceAwardList)
					-- print("[Kumo] QUIDialogSocietyDungeonChestPreview:_updateChest()  key ", key)
					if self._induceAwardList[key] then
						chest:update(self._induceAwardList[key])
					end
				end
			end
		end
	end
end


function QUIDialogSocietyDungeonChestPreview:_isBossDead()
	local bossList = remote.union:getConsortiaBossList(self._chapter)

	if not bossList or #bossList == 0 then return false end

	for _, boss in pairs(bossList) do
		if boss.wave == self._wave and boss.bossHp == 0 then
			return true
		else
			return false
		end
	end

	return false
end

function QUIDialogSocietyDungeonChestPreview:_isInTheTime()
	local curTimeTbl = q.date("*t", q.serverTime())
	local startTime = remote.union:getSocietyDungeonStartTime()
	if curTimeTbl.hour < startTime and curTimeTbl.hour >= 5 then
		return false
	else
		return true
	end
end

-- function QUIDialogSocietyDungeonChestPreview:_analyseAwards()
-- 	local tbl = {}
-- 	local scoietyWaveConfig = QStaticDatabase.sharedDatabase():getScoietyWave(self._wave, self._chapter)
-- 	local a = string.split(scoietyWaveConfig.sociaty_box, ";") -- {id^itemCount:chestCount}
-- 	-- QPrintTable(a)
-- 	-- print("========")
-- 	for _, i in pairs(a) do
-- 		local b = string.split(i, ":") -- {id^itemCount} {chestCount}
-- 		-- QPrintTable(b)
-- 		tbl = {}
-- 		for _, j in pairs(b) do
-- 			local s, e = string.find(j, "%^")
-- 			-- print("s, e", j, s, e)
-- 			if s then
-- 				local idOrType = string.sub(j, 1, s - 1)
-- 				local itemCount = string.sub(j, e + 1)
-- 				tbl["idOrType"] = idOrType
-- 				tbl["itemCount"] = itemCount
-- 			else
-- 				tbl["chestCount"] = j
-- 			end
-- 		end
-- 		table.insert(self._awardList, tbl)
-- 	end
-- 	-- print("========")
-- 	-- QPrintTable(self._awardList)
-- 	-- print("========")
-- end

function QUIDialogSocietyDungeonChestPreview:_induceAwards( bossAwardList )
	self._induceAwardList = {}
	local tbl = {}

	for _, chest in pairs(bossAwardList) do
		if not tbl[chest.award] then
			tbl[chest.award] = 1
		else
			tbl[chest.award] = tbl[chest.award] + 1
		end
	end

	self._induceAwardList = tbl
end

return QUIDialogSocietyDungeonChestPreview