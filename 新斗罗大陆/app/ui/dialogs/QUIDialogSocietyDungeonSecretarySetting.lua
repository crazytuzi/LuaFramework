--
-- Kumo.Wang
-- 小助手——军团副本的集火设定界面
--
local QUIDialog = import(".QUIDialog")
local QUIDialogSocietyDungeonSecretarySetting = class("QUIDialogSocietyDungeonSecretarySetting", QUIDialog)

local QUIWidgetSocietyDungeonBoss = import("..widgets.QUIWidgetSocietyDungeonBoss")
local QUIWidgetSocietyDungeonMap = import("..widgets.QUIWidgetSocietyDungeonMap")
local QVIPUtil = import("...utils.QVIPUtil")

function QUIDialogSocietyDungeonSecretarySetting:ctor(options)
	local ccbFile = "ccb/Dialog_Secretary_zm_fb.ccbi"
	local callBacks = {
		{ccbCallbackName = "onTriggerOK", callback = handler(self, self._onTriggerOK)},
		{ccbCallbackName = "onTriggerPlus", callback = handler(self, self._onTriggerPlus)},
		{ccbCallbackName = "onTriggerSub", callback = handler(self, self._onTriggerSub)},
		{ccbCallbackName = "onTriggerClose", callback = handler(self, self._onTriggerClose)},
	}
	QUIDialogSocietyDungeonSecretarySetting.super.ctor(self, ccbFile, callBacks, options)
	self.isAnimation = true

    q.setButtonEnableShadow(self._ccbOwner.btn_plus)
    q.setButtonEnableShadow(self._ccbOwner.btn_sub)
    q.setButtonEnableShadow(self._ccbOwner.btn_ok)
    q.setButtonEnableShadow(self._ccbOwner.btn_close)

	self._setId = options.setId
	self._callback = options.callback

	self._setting = remote.secretary:getSettingBySecretaryId(self._setId) or {}

	self:_init()
end

function QUIDialogSocietyDungeonSecretarySetting:viewDidAppear()
	QUIDialogSocietyDungeonSecretarySetting.super.viewDidAppear(self)
end

function QUIDialogSocietyDungeonSecretarySetting:viewWillDisappear()
	QUIDialogSocietyDungeonSecretarySetting.super.viewWillDisappear(self)
end

function QUIDialogSocietyDungeonSecretarySetting:_onTriggerOK()
	app.sound:playSound("common_small")
	self._setting.count = self._count
	if self._callback then
		self._callback(self._setId, self._setting)
	end
	self:playEffectOut()
end

function QUIDialogSocietyDungeonSecretarySetting:_onTriggerPlus()
	app.sound:playSound("common_small")
	self._count = self._count + 1
	if self._count > self._maxCount then
		self._count = self._maxCount
	end
	self:_updateCount()
end

function QUIDialogSocietyDungeonSecretarySetting:_onTriggerSub()
	app.sound:playSound("common_small")
	self._count = self._count - 1
	if self._count < 0 then
		self._count = 0
	end
	self:_updateCount()
end

function QUIDialogSocietyDungeonSecretarySetting:_onTriggerClose()
	app.sound:playSound("common_small")
	self:playEffectOut()
end

function QUIDialogSocietyDungeonSecretarySetting:_init()
	self._freeCount = remote.union:getSocietyFreeCount()

	local curVipBuyCount = QVIPUtil:getCountByWordField("sociaty_chapter_times") -- 玩家当前vip等级购买次数上限
	print("curVipBuyCount = ", curVipBuyCount)
	local userConsortia = remote.user:getPropForKey("userConsortia")
	self._preBuyCount = 0 -- 当日已经购买过的次数
	if userConsortia.consortia_boss_buy_at ~= nil and q.refreshTime(remote.user.c_systemRefreshTime) > userConsortia.consortia_boss_buy_at then
		self._preBuyCount = 0
	else
		self._preBuyCount = userConsortia.consortia_boss_buy_count or 0
	end
	print("self._preBuyCount = ", self._preBuyCount)
	self._preFightCount = 0 -- 当日已经使用过的次数(要接后端数据)
	if userConsortia.consortia_boss_fight_at ~= nil and q.refreshTime(remote.user.c_systemRefreshTime) > userConsortia.consortia_boss_fight_at then
		self._preFightCount = 0
	else
		self._preFightCount = userConsortia.consortia_boss_daily_fight_count or 0
	end
	print("self._preFightCount = ", self._preFightCount)
	self._maxCount = self._freeCount + curVipBuyCount

	local setConfig = remote.secretary:getMySecretaryConfigById(self._setId)
	local defaultCount = setConfig.defaultCount or 9
    local config = app.unlock:getConfigByKey("UNLOCK_ZONGMENFUBEN_CD")
    if remote.user.dailyTeamLevel < config.team_level then
        defaultCount = 5
    end
	self._count = self._setting.count or defaultCount -- 注意：这里的次数，是当日宗门副本需要打到的次数，并非本次扫荡的次数（比如先手动打了n次，这里设置m次，那么小助手实际扫荡次数为m-n次）

	self:_updateCount()
	self:_updateInit()
end

function QUIDialogSocietyDungeonSecretarySetting:_updateCount()
	self._ccbOwner.tf_count:setString(self._count.."/"..self._maxCount)

	local curBuyCount = self._count - self._freeCount - self._preBuyCount
	printInfo("~~~~~` curBuyCount == %s ~~~~~~~", curBuyCount)
	printInfo("~~~~~` self._count == %s ~~~~~~~", self._count)
	printInfo("~~~~~` self._freeCount == %s ~~~~~~~", self._freeCount)
	printInfo("~~~~~` self._preBuyCount == %s ~~~~~~~", self._preBuyCount)
	local cost = 0
	for i = 1, curBuyCount, 1 do
		local num = i + self._preBuyCount
		local config = db:getTokenConsume("sociaty_chapter_times", num)
		cost = cost + (config.money_num or 0)
	end

	self._ccbOwner.tf_cost:setString(cost)
end

function QUIDialogSocietyDungeonSecretarySetting:_updateInit()
	self._chapter = remote.union:getShowChapter()
	if self._chapter <= 0 then
		remote.union:setShowChapter(remote.union:getFightChapter())
		self._chapter = remote.union:getFightChapter()
	end
	self._bossList = {}
	local scoietyChapterConfig = db:getScoietyChapter(self._chapter)
	self._scoietyChapterConfig = {}
	local mapIndex = 0
	for _, config in ipairs(scoietyChapterConfig) do
		self._scoietyChapterConfig[config.wave] = config
		if config.color_type then
			mapIndex = config.color_type
		end
	end
	-- QPrintTable(self._scoietyChapterConfig)
	self:_initMap(mapIndex)
end

function QUIDialogSocietyDungeonSecretarySetting:_initMap(mapIndex)
	self._map = QUIWidgetSocietyDungeonMap.new( { mapIndex = mapIndex } ) 
	if not self._map then
		mapIndex = 1
		self._map = QUIWidgetSocietyDungeonMap.new( { mapIndex = mapIndex } ) 
	end
	self._ccbOwner.node_map:addChild( self._map )
	self:_autoScaleMap( self._map )
	self:_initBossInfo()
end

function QUIDialogSocietyDungeonSecretarySetting:_autoScaleMap( widgetMap )
	local mapWidth = widgetMap:getMapWidth()
	local thisWidth = self._ccbOwner.layer_bj:getContentSize().width*self._ccbOwner.layer_bj:getScaleX()
	local mapScale = thisWidth/mapWidth
	widgetMap:setScale(mapScale)
end

function QUIDialogSocietyDungeonSecretarySetting:_initBossInfo()
	if self._bossList and #self._bossList > 0 then
		for _, value in pairs(self._bossList) do
			value:removeFromParentAndCleanup(true)
			value:removeAllEventListeners()
			value:cleanUp()
			value = nil
		end
		self._bossList = {}
	end

	local bossList = remote.union:getConsortiaBossList(self._chapter)
	-- QPrintTable(bossList)
	if not bossList or #bossList == 0 then return end
	-- 設置默認
	for _, bossInfo in ipairs(bossList) do
		local settingKey = remote.secretary:composeSettingKey(bossInfo.chapter, bossInfo.wave)
		if not self._setting[settingKey] then
			self._setting[settingKey] = FOUNDER_TIME
		end
	end
	table.sort(bossList, function(a, b)
			local aKey = remote.secretary:composeSettingKey(a.chapter, a.wave)
			local bKey = remote.secretary:composeSettingKey(b.chapter, b.wave)
			if self._setting[aKey] ~= FOUNDER_TIME and self._setting[bKey] == FOUNDER_TIME then
                return true
            elseif self._setting[aKey] == FOUNDER_TIME and self._setting[bKey] ~= FOUNDER_TIME then
                return false
            elseif self._setting[aKey] ~= FOUNDER_TIME and self._setting[bKey] ~= FOUNDER_TIME and self._setting[aKey] ~= self._setting[bKey] then
                return self._setting[aKey] < self._setting[bKey]
            else
                return a.wave < b.wave
            end
		end)
	local focuseIndex = 0
	for _, value in ipairs(bossList) do
		value.isSetting = true
		local boss = QUIWidgetSocietyDungeonBoss.new(value)
		boss:addEventListener(QUIWidgetSocietyDungeonBoss.EVENT_CLICK, handler(self, self._onEvent))
		boss:setRecommend(false)

		local config = self._scoietyChapterConfig[value.wave]
		local settingKey = remote.secretary:composeSettingKey(value.chapter, value.wave)
		if config and config.wave_pre then
			-- 有前置關卡
			local preSettingKey = remote.secretary:composeSettingKey(value.chapter, config.wave_pre)
			if self._setting[preSettingKey] ~= FOUNDER_TIME then 
				-- 前置關卡已設置
				if self._setting[settingKey] ~= FOUNDER_TIME then
					focuseIndex = focuseIndex + 1
					boss:setFocuseNum(focuseIndex)
				else
					boss:setFocuseNum("")
				end
				boss:makeColorNormal()
			else
				-- 前置關卡未設置
				self._setting[settingKey] = FOUNDER_TIME
				boss:setFocuseNum("")
				boss:makeColorGray()
			end
		else
			-- 無前置關卡
			if self._setting[settingKey] ~= FOUNDER_TIME then
				focuseIndex = focuseIndex + 1
				boss:setFocuseNum(focuseIndex)
			else
				boss:setFocuseNum("")
			end
			boss:makeColorNormal()
		end

		local bossNode = self._map:getBossNodeByIndex(value.wave)
		if bossNode then
			bossNode:removeAllChildren()
			bossNode:addChild(boss)
			bossNode:setVisible(true)
		end
		self._bossList[value.wave] = boss
	end
end

function QUIDialogSocietyDungeonSecretarySetting:_onEvent( event )
	-- print("QUIDialogSocietyDungeonSecretarySetting:_onEvent()", event.name)
	if event.name == QUIWidgetSocietyDungeonBoss.EVENT_CLICK then
		local curTime = q.serverTime()*1000
		local settingKey = remote.secretary:composeSettingKey(event.chapter, event.wave)
		if self._setting[settingKey] and self._setting[settingKey] ~= FOUNDER_TIME then
			self._setting[settingKey] = FOUNDER_TIME
		else
			self._setting[settingKey] = curTime
		end

		local bossList = remote.union:getConsortiaBossList(self._chapter)
		if not bossList or #bossList == 0 then return end
		table.sort(bossList, function(a, b)
				local aKey = remote.secretary:composeSettingKey(a.chapter, a.wave)
				local bKey = remote.secretary:composeSettingKey(b.chapter, b.wave)
				if self._setting[aKey] ~= FOUNDER_TIME and self._setting[bKey] == FOUNDER_TIME then
                    return true
                elseif self._setting[aKey] == FOUNDER_TIME and self._setting[bKey] ~= FOUNDER_TIME then
                    return false
                elseif self._setting[aKey] ~= FOUNDER_TIME and self._setting[bKey] ~= FOUNDER_TIME and self._setting[aKey] ~= self._setting[bKey] then
                    return self._setting[aKey] < self._setting[bKey]
                else
                    return a.wave < b.wave
                end
			end)
		-- QPrintTable(bossList)
		local focuseIndex = 0
		for _, value in ipairs(bossList) do
			local settingKey = remote.secretary:composeSettingKey(value.chapter, value.wave)
			local boss = self._bossList[value.wave]
			if boss then
				local config = self._scoietyChapterConfig[value.wave]
				local settingKey = remote.secretary:composeSettingKey(value.chapter, value.wave)
				if config and config.wave_pre then
					-- 有前置關卡
					local preSettingKey = remote.secretary:composeSettingKey(value.chapter, config.wave_pre)
					if self._setting[preSettingKey] ~= FOUNDER_TIME then 
						-- 前置關卡已設置
						if self._setting[settingKey] ~= FOUNDER_TIME then
							focuseIndex = focuseIndex + 1
							boss:setFocuseNum(focuseIndex)
						else
							boss:setFocuseNum("")
						end
						boss:makeColorNormal()
					else
						-- 前置關卡未設置
						self._setting[settingKey] = FOUNDER_TIME
						boss:setFocuseNum("")
						boss:makeColorGray()
					end
				else
					-- 無前置關卡
					if self._setting[settingKey] ~= FOUNDER_TIME then
						focuseIndex = focuseIndex + 1
						boss:setFocuseNum(focuseIndex)
					else
						boss:setFocuseNum("")
					end
					boss:makeColorNormal()
				end
			end
		end
	end
end

return QUIDialogSocietyDungeonSecretarySetting