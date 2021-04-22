
--
-- Author: Kumo.Wang
-- Date: Thu Apr 28 17:19:38 2016
--
local QUIDialog = import(".QUIDialog")
local QUIDialogGlyphUp = class("QUIDialogGlyphUp", QUIDialog)

local QUIWidgetGlyphClientCell = import("..widgets.QUIWidgetGlyphClientCell")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QQuickWay = import("...utils.QQuickWay")
local QNavigationController = import("...controllers.QNavigationController")
local QUIWidgetAnimationPlayer = import("..widgets.QUIWidgetAnimationPlayer")
local QUIViewController = import("..QUIViewController")
local QActorProp = import("...models.QActorProp")

QUIDialogGlyphUp.MIN_BET = 2
QUIDialogGlyphUp.MAX_BET = 5

function QUIDialogGlyphUp:ctor(options)
	local ccbFile = "ccb/Dialog_DiaoWen.ccbi"
    local callBacks = {
        {ccbCallbackName = "onTriggerClose", callback = handler(self, self._onTriggerClose)},
        {ccbCallbackName = "onTriggerOK", callback = handler(self, self._onTriggerOK)},
        {ccbCallbackName = "onTriggerAuto", callback = handler(self, self._onTriggerAuto)},
        {ccbCallbackName = "onTriggerSelected", callback = handler(self, self._onTriggerSelected)},
        {ccbCallbackName = "onTriggerFull", callback = handler(self, self._onTriggerFull)},
    }
    QUIDialogGlyphUp.super.ctor(self, ccbFile, callBacks, options)

    self.isAnimation = options.isAnimation == nil and true or false
    self._callBackFun = options.callBackFun

    self._ccbOwner.frame_tf_title:setString("体技升级")

    self._itemId = 800001 --体技晶石物品ID

	q.setButtonEnableShadow(self._ccbOwner.btn_ok)
	q.setButtonEnableShadow(self._ccbOwner.btn_full)
	q.setButtonEnableShadow(self._ccbOwner.btn_auto)

    self._skillId = options.skillId
    self._skillLevel = options.skillLevel or 1
    self._actorId = options.actorId
    self._curExp = 0
    self._nextExp = 0
    self._curLuckyValue = 0
    self._nextLuckyValue = 0
    self._singleExp = 0
    self._totalExp = 0

    self._progressEffectA = nil
    self._progressEffectB = nil
    self._curProgressState = 0 -- 进度条特效的状态，0 静态 1 动态
    self._progressAnimationIndex = 0

    self._isAutoState = false
    self._selectQuickUpgrade = false

    self._initTotalGreenScaleX = self._ccbOwner.node_green:getScaleX()
    -- self._initTotalGreenOpacityScaleX = self._ccbOwner.node_green_opacity:getScaleX()

    -- self._ccbOwner.tf_skill_name = setShadow5(self._ccbOwner.tf_skill_name)
    -- self._ccbOwner.tf_skill_level = setShadow5(self._ccbOwner.tf_skill_level)
    -- self._ccbOwner.tf_level_1 = setShadow5(self._ccbOwner.tf_level_1)
    -- setShadow5(self._ccbOwner.tf_explain_1)
    -- self._ccbOwner.tf_level_2 = setShadow5(self._ccbOwner.tf_level_2)
    -- setShadow5(self._ccbOwner.tf_explain_2)
    -- self._ccbOwner.tf_level_3 = setShadow5(self._ccbOwner.tf_level_3)
    -- setShadow5(self._ccbOwner.tf_explain_3)

    if not app.unlock:checkLock("UNLOCK_GLYPH_SYSTEMS_ONEKEY", false) then
    	self._ccbOwner.node_btn_full:setVisible(false)
    	self._ccbOwner.node_btn_ok:setPositionX(4)
    	self._ccbOwner.node_btn_ok:setVisible(true)
    	self._ccbOwner.node_client_5:setPositionX(156)
    	self._ccbOwner.node_client_6:setPositionX(246)    	
    	self._ccbOwner.node_client_5:setVisible(true)
    	self._ccbOwner.node_client_6:setVisible(true)    	
    	self._ccbOwner.node_visible_6:setPositionX(-26)
    	self._ccbOwner.node_select:setPositionX(105)
    else
    	self._ccbOwner.node_btn_full:setVisible(true)
    	self._ccbOwner.node_btn_full:setPositionX(380)
    	self._ccbOwner.node_btn_ok:setVisible(true)
    	self._ccbOwner.node_btn_ok:setPositionX(-46)
    	self._ccbOwner.node_client_5:setVisible(true)
    	self._ccbOwner.node_client_6:setVisible(true)
    	self._ccbOwner.node_client_5:setPositionX(124)
    	self._ccbOwner.node_client_6:setPositionX(206)
    	self._ccbOwner.node_visible_6:setPositionX(-176)
    	self._ccbOwner.node_select:setPositionX(-45)    	
    end

    self:_updateIcon()
    self:_updateInfo()
    self:_updateProgress()
    self:setSelectQuickUpGradeState()
end

function QUIDialogGlyphUp:viewDidAppear()
    QUIDialogGlyphUp.super.viewDidAppear(self)

    self.userProxy = cc.EventProxy.new(remote.user)
    self.userProxy:addEventListener(remote.user.EVENT_TIME_REFRESH, handler(self, self.onEvent))
end

function QUIDialogGlyphUp:viewAnimationInHandler()
	-- app.tip:floatTip("报BUG的时候，请附上这个截图 ==>"..self._actorId.." : "..self._skillId)
end

function QUIDialogGlyphUp:viewWillDisappear()
    QUIDialogGlyphUp.super.viewWillDisappear(self)

    self.userProxy:removeAllEventListeners()

    if self._scheduler then
		scheduler.unscheduleGlobal(self._scheduler)
		self._scheduler = nil
	end

	if self._delay then
		scheduler.unscheduleGlobal(self._delay)
		self._delay = nil
	end

	if self._autoScheduler then
		scheduler.unscheduleGlobal(self._autoScheduler)
		self._autoScheduler = nil
	end

	if self._updateProgressDelayGlobal then
		scheduler.unscheduleGlobal(self._updateProgressDelayGlobal)
		self._updateProgressDelayGlobal = nil
	end

	if self._onkeyFullScheduler then
		scheduler.unscheduleGlobal(self._onkeyFullScheduler)
		self._onkeyFullScheduler = nil
	end
end

function QUIDialogGlyphUp:onEvent( event )
	if event.time == 5 then
		-- 记录下每天5点刷新的时候的系统时间
		self._refreshTime = q.serverTime()
	end
end

function QUIDialogGlyphUp:_updateIcon()
	self._skillIcon = QUIWidgetGlyphClientCell.new()
	self._skillIcon:setSkill( self._skillId, self._skillLevel )
	self._skillIcon:setLevelVisible(false)
	self._skillIcon:setNameVisible(false)
	self._skillIcon:setEnabled(false)
	self._ccbOwner.node_skill_icon:addChild( self._skillIcon )
end

function QUIDialogGlyphUp:_updateInfo()
	local heroInfo = remote.herosUtil:getHeroByID(self._actorId)
	if heroInfo and heroInfo.glyphs then
		for _, value in pairs(heroInfo.glyphs) do
			if value.glyphId == self._skillId then
				if self._refreshTime and value.lastImproveAt < self._refreshTime then
					-- 当天5点刷新之前的数据
					self._curLuckyValue = 0
				else
					self._curLuckyValue = value.luckyValue or 0
				end
				self._curExp = value.exp or 0
				if not value.level or value.level == 0 then
					self._skillLevel = 1
				else
					self._skillLevel = value.level
				end
			end
		end
	end

	-- print("[Kumo] QUIDialogGlyphUp:_updateInfo() : ", self._skillId, self._skillLevel)
	local skillConfig = QStaticDatabase.sharedDatabase():getGlyphSkillByIdAndLevel(self._skillId, self._skillLevel)
	local skillNextConfig = QStaticDatabase.sharedDatabase():getGlyphSkillByIdAndLevel(self._skillId, self._skillLevel + 1)
	local skillConfigs = QStaticDatabase.sharedDatabase():getGlyphSkillsBySkillID(self._skillId)
	local luckyLevel = "低"

	self._singleExp = skillConfig.single_exp
	luckyLevel = self:_getLuckyLevel( self._curLuckyValue ) 

	self._ccbOwner.tf_skill_name:setString( skillConfig.glyph_name )
	self._ccbOwner.tf_skill_level:setString( "LV."..self._skillLevel )
	local nw = self._ccbOwner.tf_skill_name:getContentSize().width
	local px = self._ccbOwner.tf_skill_name:getPositionX()
	-- self._ccbOwner.tf_skill_level:setPositionX(px + nw + 10)
	local lw = self._ccbOwner.tf_skill_level:getContentSize().width

	if skillNextConfig then
		-- print("[Kumo] QUIDialogGlyphUp:_updateInfo() : AAAAAAA", self._skillId, self._skillLevel)
		self._ccbOwner.node_visible_1and2:setVisible( true )
		self._ccbOwner.node_client_3:setVisible( false )
		self._ccbOwner.node_visible_4:setVisible( true )
		self._ccbOwner.node_visible_5:setVisible( true )
		self._ccbOwner.node_visible_6:setVisible( true )
		local quickUpGrade = app.unlock:checkLock("UNLOCK_GLYPH_SYSTEMS_UPNOW")
		self._ccbOwner.node_select:setVisible(quickUpGrade)
		self._ccbOwner.node_auto_effect:setVisible(false)

		if quickUpGrade and not app:getUserData():getValueForKey("UNLOCK_GLYPH_SYSTEMS_UPNOW"..remote.user.userId) then
			self._ccbOwner.node_auto_effect:setVisible(true)
		end


		if self._isAutoState then
			self._ccbOwner.tf_auto:setString("停  止")
		else
			self._ccbOwner.tf_auto:setString("一键升级")
		end

		self._ccbOwner.tf_single_exp:setString( self._singleExp )
		self._ccbOwner.tf_lucky_level:setString( luckyLevel )
		self._ccbOwner.tf_lucky_value:setString( self._curLuckyValue )

		self._ccbOwner.tf_level_1:setString( self._skillLevel.."级效果" )
		local str1 = self:_getExplainBySkillConfig(skillConfig,12)
		-- self._ccbOwner.tf_explain_1:setString( skillConfig.level_describle )
		self._ccbOwner.tf_explain_1:setString( str1 )

		self._ccbOwner.tf_level_2:setString( (self._skillLevel + 1).."级效果" )
		local str2 = self:_getExplainBySkillConfig(skillNextConfig,12)
		-- self._ccbOwner.tf_explain_2:setString( skillNextConfig.level_describle )
		self._ccbOwner.tf_explain_2:setString( str2 )

		self._price = skillConfig.single_num
		self._ccbOwner.tf_price_5:setString( skillConfig.single_num )
		self._soulPrice = skillConfig.soul_money
		self._ccbOwner.tf_price_6:setString( skillConfig.soul_money )

		self._ccbOwner.tf_skill_max_level:setString( "（等级上限："..#skillConfigs.."）" )
		self._ccbOwner.tf_skill_max_level:setPositionX(px + nw + lw + 20)

		local posX = self._ccbOwner.tf_lucky_value:getPositionX()
		local w = self._ccbOwner.tf_lucky_value:getContentSize().width
		self._ccbOwner.tf_reset:setPositionX(posX + w)
	else
		-- print("[Kumo] QUIDialogGlyphUp:_updateInfo() : BBBBBBBB", self._skillId, self._skillLevel)
		self._isMaxLevel = true
		makeNodeFromNormalToGray(self._ccbOwner.node_btn_ok)

		self._ccbOwner.node_visible_1and2:setVisible( false )
		self._ccbOwner.node_client_3:setVisible( true )
		self._ccbOwner.node_visible_4:setVisible( false )
		self._ccbOwner.node_visible_5:setVisible( false )
		self._ccbOwner.node_visible_6:setVisible( false )
		self._ccbOwner.node_select:setVisible(false)

		self._ccbOwner.tf_level_3:setString( self._skillLevel.."级效果" )
		local str3 = self:_getExplainBySkillConfig(skillConfig , 24)
		-- self._ccbOwner.tf_explain_3:setString( skillConfig.level_describle )
		self._ccbOwner.tf_explain_3:setString( str3 )

		self._ccbOwner.tf_skill_max_level:setString( "（已达到上限）" )
		self._ccbOwner.tf_skill_max_level:setPositionX(px + nw + lw + 20)
	end
end

function QUIDialogGlyphUp:_getExplainBySkillConfig( skillLevelConfig ,max_text_num)
	local tbl = {}
	local str = ""

	-- local findMagicKey = 0
	-- local findPhysicsKey = 0
	for name, filed in pairs(QActorProp._field) do
		if skillLevelConfig[name] then
			-- print("[Kumo] QUIDialogGlyphUp:_getExplainBySkillConfig() ", name, skillLevelConfig[name], skillLevelConfig.glyph_level, skillLevelConfig.glyph_name)
			local strName = filed.name
			-- print(strName)
			-- if string.find(strName, "魔法") then
				-- findMagicKey = findMagicKey + 1
			strName = string.gsub(strName, "法术", "")
			strName = string.gsub(strName, "法防", "防御")
			-- end
			-- if string.find(strName, "物理") then
				-- findPhysicsKey = findPhysicsKey + 1
			strName = string.gsub(strName, "物理", "")
			strName = string.gsub(strName, "物防", "防御")
			-- end
			strName = string.gsub(strName, "百分比", "")
			strName = string.gsub(strName, "全队PVP", "PVP")
			-- print(strName)
			local strNum = tostring(skillLevelConfig[name])
			-- print(string.find(strNum, "%."))
			if string.find(strNum, "%.") then
				-- 数据是百分比
				strNum = (skillLevelConfig[name] * 100).."%"
			end

			-- 防止重复，同时，让类似魔法防御和物理防御这样的成对属性合并成防御属性
			local isNew = true
			for _, value in pairs(tbl) do
				-- print("[Kumo] QUIDialogGlyphUp:_getExplainBySkillConfig() ", value, strName, strNum, string.len(strName))
				if string.len(strName) < max_text_num then
					-- 不换行
					if value == strName.." + "..strNum then
						-- print("==================> isNew = false")
						isNew = false
					end
				else
					-- 换行
					if value == strName.."\n + "..strNum then
						-- print("==================> isNew = false")
						isNew = false
					end
				end
			end

			if isNew then
				if string.len(strName) < max_text_num then
					-- 不换行
					table.insert(tbl, strName.." + "..strNum)
				else
					-- 换行
					table.insert(tbl, strName.."\n + "..strNum)
				end
			end
		end
	end

	for index, value in pairs(tbl) do
		if index == #tbl then
			str = str..value
			break
		end
		str = str..value.."\n"
	end

	-- return tbl
	return str
end

function QUIDialogGlyphUp:_updateProgress()
	if self._isMaxLevel then
		self._ccbOwner.tf_progress:setString( "" )
		self._ccbOwner.node_green:setScaleX( self._initTotalGreenScaleX )
		-- self._ccbOwner.node_green_opacity:setScaleX( self._initTotalGreenOpacityScaleX )
		self:_updateNodeGuangPostion()
		if self._curProgressState == 1 or not self._progressEffectA then
			self._curProgressState = 0
			self._progressEffectA = self:_addGreenEffectA()
			self._progressEffectB = nil
		end
	else
		local skillConfig = QStaticDatabase.sharedDatabase():getGlyphSkillByIdAndLevel(self._skillId, self._skillLevel)
		self._totalExp = skillConfig.total_exp
		self._singleExp = skillConfig.single_exp

		local heroInfo = remote.herosUtil:getHeroByID(self._actorId)
		if heroInfo and heroInfo.glyphs then
			for _, value in pairs(heroInfo.glyphs) do
				if value.glyphId == self._skillId then
					self._curExp = value.exp or 0
				end
			end
		end

		self._ccbOwner.tf_progress:setString( self._curExp.."/"..self._totalExp )

		local greenX = self._curExp / self._totalExp * self._initTotalGreenScaleX
		self._ccbOwner.node_green:setScaleX( greenX )
		self:_updateNodeGuangPostion()
		if self._curProgressState == 1 or not self._progressEffectA then
			self._curProgressState = 0
			self._progressEffectA = self:_addGreenEffectA()
			self._progressEffectB = nil
		end

		local goalExp = self._curExp + self._singleExp
		if goalExp > self._totalExp then
			goalExp = self._totalExp
		end
		-- local greenOpacityX = goalExp / self._totalExp * self._initTotalGreenOpacityScaleX
		-- self._ccbOwner.node_green_opacity:setScaleX( greenOpacityX )
	end
end

function QUIDialogGlyphUp:_getLuckyLevel( luckyValue )
	local str = ""

	if not self._luckyLeveTbl or not self._addNum or not self._intervalNum then
		local convertStr = QStaticDatabase.sharedDatabase():getConfigurationValue("GLYPH_LUCKY")
		local levelC = QStaticDatabase.sharedDatabase():getConfigurationValue("GLYPH_LUCKY_C")
		local levelB = QStaticDatabase.sharedDatabase():getConfigurationValue("GLYPH_LUCKY_B")
		local levelA = QStaticDatabase.sharedDatabase():getConfigurationValue("GLYPH_LUCKY_A")
		local levelS = QStaticDatabase.sharedDatabase():getConfigurationValue("GLYPH_LUCKY_S")

		-- local convertTbl = self:_analysisStr(convertStr)
		-- local tmpStr = string.gsub(convertTbl[1], "%%", "")
		-- self._addNum = tonumber(tmpStr)
		-- self._intervalNum = tonumber(convertTbl[2])

		self._addNum = 1
		self._intervalNum = tonumber(convertStr)
		self._luckyLeveTbl = {self:_analysisStr(levelC), self:_analysisStr(levelB), self:_analysisStr(levelA), self:_analysisStr(levelS)}
		-- QPrintTable(self._luckyLeveTbl)
	end
	
	local skillConfig = QStaticDatabase.sharedDatabase():getGlyphSkillByIdAndLevel(self._skillId, self._skillLevel)

	local lv = math.floor(luckyValue / self._intervalNum) * self._addNum + skillConfig.probability_of_success * 100
	-- print("[Kumo] QUIDialogGlyphUp:_getLuckyLevel ", luckyValue, self._intervalNum, self._addNum, skillConfig.probability_of_success * 100, lv)

	for _, value in pairs(self._luckyLeveTbl) do
		if lv >= tonumber(value[1]) and lv <= tonumber(value[2]) then
			str = value[3]
			return str
		end
	end

	return str
end

function QUIDialogGlyphUp:_analysisStr( str )
	local tbl = {}

	local tmpTbl = string.split(str, ":")
	for _, value in pairs(tmpTbl) do
		if string.find(value, ",") then
			tbl = string.split(value, ",")
		else
			table.insert(tbl, value)
		end
	end

	table.sort(tbl, function(a,b) 
			if tonumber(a) and tonumber(b) then
				return tonumber(a) < tonumber(b) 
			else
				return a < b
			end
		end )

	return tbl
end

function QUIDialogGlyphUp:_onTriggerFull( event )

	if self._isLock then return end
	if self._isOneKeyFull then return end

	local glyphsMoney = remote.user:getPropForKey("glyphMoney")
	local soulMoney = remote.user:getPropForKey("soulMoney")

	if glyphsMoney < self._price then
		QQuickWay:addQuickWay(QQuickWay.RESOUCE_DROP_WAY, ITEM_TYPE.GLYPH_MONEY)
		return
	elseif soulMoney < self._soulPrice then
		QQuickWay:addQuickWay(QQuickWay.RESOUCE_DROP_WAY, ITEM_TYPE.SOULMONEY)
		return
	end
	local configirm = function()
		self:_updateProgress()
		self._isOneKeyFull = true
		app:getClient():heroGlyphImproveFullRequest(self._actorId, self._skillId, self:safeHandler(function ( response )
			remote.user:addPropNumForKey("todayGlyphImproveCount")
			self:_responseHandler( response )
			if response.heroGlyphImproveResult then
				self:_showQuickUpGradeEffect(response.heroGlyphImproveResult)
			end		
			self:_showEffect()
			
			if self._onkeyFullScheduler then
				scheduler.unscheduleGlobal(self._onkeyFullScheduler)
				self._onkeyFullScheduler = nil
			end

			self._onkeyFullScheduler = scheduler.performWithDelayGlobal(function ()
				self._isOneKeyFull = false
			end, 2)
		end),self:safeHandler(function()
			self._isOneKeyFull = false
		end))
	end

	local isTips = app:getUserOperateRecord():getRecordByType("GLYPHUP_ONEKEY_FULL")
	if isTips then
		configirm()
	else
		local contentStr = "一键升满将消耗大量体技石和灵魂石将体技升级到最大等级，您确定吗?"
		app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogComCheckAlert", 
			options={dailyTimeType = "GLYPHUP_ONEKEY_FULL", tipsType = "FOREVER", richTextContent = {{oType = "font", content =contentStr, size = 20, color = COLORS.j},}, 
				okBtnText = "确 定", cancleBtnText = "取 消", callBack = configirm }}, {isPopCurrentDialog = false})			
	end

end

function QUIDialogGlyphUp:_onTriggerOK(event)
    app.sound:playSound("equipment_enhance")
	
	if self._isLevelUp or self._isMaxLevel or event then 
		if self._autoScheduler then
			scheduler.unscheduleGlobal(self._autoScheduler)
			self._autoScheduler = nil
		end
		self._isAutoState = false
		self._ccbOwner.tf_auto:setString("一键升级")
	end

	if self._isLock then return end
	if self._isOneKeyFull then return end

	-- local num = remote.items:getItemsNumByID(self._itemId)
	local glyphsMoney = remote.user:getPropForKey("glyphMoney")
	local soulMoney = remote.user:getPropForKey("soulMoney")
	-- print("[Kumo] glyphsMoney : ", glyphsMoney, "  soulMoney : ", soulMoney)
	if glyphsMoney >= self._price and soulMoney >= self._soulPrice then
		if self._delay then
			scheduler.unscheduleGlobal(self._delay)
			self._delay = nil
		end
		self._isLock = true
		if not self._isAutoState and event then
			self._ccbOwner.btn_ok:setEnabled(false)
			makeNodeFromNormalToGray(self._ccbOwner.node_btn_ok)
		end
		self._delay = scheduler.performWithDelayGlobal(function ()
			if self._delay then
				scheduler.unscheduleGlobal(self._delay)
				self._delay = nil
			end
			self._isLock = false
			self._ccbOwner.btn_ok:setEnabled(true)
			makeNodeFromGrayToNormal(self._ccbOwner.node_btn_ok)
		end, 10)
		if self._updateProgressDelayGlobal then
			scheduler.unscheduleGlobal(self._updateProgressDelayGlobal)
			self._updateProgressDelayGlobal = nil
		end
		self:_updateProgress()
		app:getClient():heroGlyphImproveRequest(self._actorId, self._skillId, false, self:safeHandler(function ( response )
			remote.user:addPropNumForKey("todayGlyphImproveCount")
			self:_responseHandler( response )
			self:_showEffect()
		end))
	else
		if glyphsMoney < self._price then
    		QQuickWay:addQuickWay(QQuickWay.RESOUCE_DROP_WAY, ITEM_TYPE.GLYPH_MONEY)
		elseif soulMoney < self._soulPrice then
    		QQuickWay:addQuickWay(QQuickWay.RESOUCE_DROP_WAY, ITEM_TYPE.SOULMONEY)
		end
		if self._autoScheduler then
			scheduler.unscheduleGlobal(self._autoScheduler)
			self._autoScheduler = nil
		end
		self._isAutoState = false
		self._ccbOwner.tf_auto:setString("一键升级")
	end
end

function QUIDialogGlyphUp:_onTriggerAuto(event)
    if not app:getUserData():getValueForKey("UNLOCK_GLYPH_SYSTEMS_UPNOW"..remote.user.userId) then
        app:getUserData():setValueForKey("UNLOCK_GLYPH_SYSTEMS_UPNOW"..remote.user.userId, "true")
		self._ccbOwner.node_auto_effect:setVisible(false)
    end 
    if self._isOneKeyFull then return end
    print("QUIDialogGlyphUp:_onTriggerAuto")
	if self._isAutoState then
		-- 已经处于自动升级状态
		if self._autoScheduler then
			scheduler.unscheduleGlobal(self._autoScheduler)
			self._autoScheduler = nil
		end
		self._isAutoState = false
		self._ccbOwner.tf_auto:setString("一键升级")
	else
		-- 开始自动升级
		if self._selectQuickUpgrade then
			self:startQuickUpgrade()
		else
			self:_onTriggerOK()
			self._autoScheduler = scheduler.scheduleGlobal(function()
					self:_onTriggerOK()
				end, 0.5)
			self._isAutoState = true
			self._ccbOwner.tf_auto:setString("停  止")
		end
	end
end

function QUIDialogGlyphUp:startQuickUpgrade()
	if self._isLock or self._isMaxLevel then return end
	
    app.sound:playSound("equipment_enhance")

	local glyphsMoney = remote.user:getPropForKey("glyphMoney")
	local soulMoney = remote.user:getPropForKey("soulMoney")
	-- print("[Kumo] glyphsMoney : ", glyphsMoney, "  soulMoney : ", soulMoney)
	if glyphsMoney >= self._price and soulMoney >= self._soulPrice then
		if self._delay then
			scheduler.unscheduleGlobal(self._delay)
			self._delay = nil
		end
		self._isLock = true
		self:_updateProgress()
		app:getClient():heroGlyphImproveRequest(self._actorId, self._skillId, true, self:safeHandler(function ( response )
			remote.user:addPropNumForKey("todayGlyphImproveCount")
			self:_responseHandler( response )
			if response.heroGlyphImproveResult then
				self:_showQuickUpGradeEffect(response.heroGlyphImproveResult)
			end

			self._delay = scheduler.performWithDelayGlobal(function ()
				if self._delay then
					scheduler.unscheduleGlobal(self._delay)
					self._delay = nil
				end
				self._isLock = false
			end, 3)
		end),function()
			self._isLock = false
		end)
	else
		if glyphsMoney < self._price then
    		QQuickWay:addQuickWay(QQuickWay.RESOUCE_DROP_WAY, ITEM_TYPE.GLYPH_MONEY)
		elseif soulMoney < self._soulPrice then
    		QQuickWay:addQuickWay(QQuickWay.RESOUCE_DROP_WAY, ITEM_TYPE.SOULMONEY)
		end
	end
end

function QUIDialogGlyphUp:_showQuickUpGradeEffect(data)
	local fontColor = {
		["green"] = { ["color"] = ccc3(174, 251, 82), ["outlineColor"] = ccc3(53, 30, 13)},
		["gold"] = { ["color"] = ccc3(255, 240, 0), ["outlineColor"] = ccc3(146, 65, 0)},
		["yellow"] = { ["color"] = ccc3(255, 255, 0), ["outlineColor"] = ccc3(53, 30, 13)},
		["gray"] = { ["color"] = ccc3(205, 204, 206), ["outlineColor"] = ccc3(53, 30, 13)}
	}
	local ccbFile = "ccb/effects/Widget_glyph_quick_upgrade_success.ccbi"

	local successNum = data.successTimes or 0
	local failNum = data.failTimes or 0
	local upgradeNum = successNum + failNum
	local critNum = 0
	local superCritNum = 0
	for _, value in pairs(data.crit or {}) do
		if value == self.MIN_BET then
			critNum = critNum + 1
		elseif value == self.MAX_BET then
			superCritNum = superCritNum + 1
		end
	end

	local luckyValue = data.luckyValue or 0
	local allFail = false
	if successNum == 0 and failNum > 0 then
		allFail = false
	end
	local glyphMoney = data.consumeGlyph or 0
	local soulMoney = data.consumeSoul or 0

    local aniPlayer = QUIWidgetAnimationPlayer.new()
	self:getView():addChild(aniPlayer)
    aniPlayer:playAnimation(ccbFile, function ( ccbOwner )
    	for i = 1, 4 do
    		ccbOwner["node_"..i]:setVisible(false)
    	end

    	local index = 1
    	local setStrFunc = function(str, fontColor)
    		ccbOwner["node_"..index]:setVisible(true)
    		ccbOwner["tf_num_"..index]:setColor(fontColor.color)
			setShadow5(ccbOwner["tf_num_"..index], fontColor.outlineColor)
    		ccbOwner["tf_num_"..index]:setString(str)
    		index = index + 1
    	end

    	setStrFunc(string.format("共尝试了%s次", upgradeNum), fontColor.yellow)
    	if critNum and critNum > 0 then
    		setStrFunc(string.format("暴击%s次", critNum), fontColor.gold)
    	end
    	if superCritNum and superCritNum > 0 then
    		setStrFunc(string.format("大暴击%s次", superCritNum), fontColor.gold)
    	end
    	if allFail then
    		setStrFunc(string.format("幸运+%s", luckyValue), fontColor.green)
    	end

    	self._showProgressEffect = false
    	self:_showProgressUp()
    end, function ()
    end)
end

function QUIDialogGlyphUp:_onTriggerSelected(event)
	self._selectQuickUpgrade = not self._selectQuickUpgrade

	self:setSelectQuickUpGradeState()
end

function QUIDialogGlyphUp:setSelectQuickUpGradeState()
	self._ccbOwner.btn_select:setHighlighted(not self._selectQuickUpgrade)
end

function QUIDialogGlyphUp:_showEffect()
	-- local ccbFile = "ccb/effects/diaowen_jindutiao_daiji.ccbi"
 --    local aniPlayer = QUIWidgetAnimationPlayer.new()
 --    self._ccbOwner.node_progress_effect:addChild(aniPlayer)
 --    aniPlayer:playAnimation(ccbFile, nil, function ()
    	if self._isSucceed or self._isLevelUp then
    		self:_showProgressUp()
    	else
    		self:_showLost()
    	end
    -- end)
end

function QUIDialogGlyphUp:_showProgressUp()
	-- print("[Kumo] QUIDialogGlyphUp:_showProgressUp ", self._nextExp, self._curExp, self._singleExp)
	self._progressAnimationIndex = 0

	if self._scheduler then
		scheduler.unscheduleGlobal(self._scheduler)
		self._scheduler = nil
	end
	self._scheduler = scheduler.scheduleGlobal(self:safeHandler( handler(self, self._progressAnimation) ), 0)
end

function QUIDialogGlyphUp:_progressAnimation()
	local addNum = 0
	-- local step = math.floor(self._totalExp / 100)
	-- if step == 0 then
	-- 	step = 1
	-- end
	local step = self._totalExp / 100 * 3 
	-- local step = 1 
	local greenX = 0
	if self._isLevelUp then
		addNum = self._totalExp - self._curExp
	else
		addNum = self._nextExp - self._curExp
	end
	
	if addNum <= 0 then return end

	self._progressAnimationIndex = self._progressAnimationIndex + step
	if self._progressAnimationIndex > addNum then
		scheduler.unscheduleGlobal(self._scheduler)
		self._scheduler = nil
		greenX = (self._curExp + addNum) / self._totalExp * self._initTotalGreenScaleX
		self._ccbOwner.node_green:setScaleX( greenX )
		self:_updateNodeGuangPostion()
		if self._curProgressState == 1 or not self._progressEffectA then
			self._curProgressState = 0
			self._progressEffectA = self:_addGreenEffectA()
			self._progressEffectB = nil
		end

		if self._showProgressEffect ~= false then
			if addNum == self._singleExp then
				-- app.tip:floatTip("体技经验+"..addNum)
				self:_showExpOrLuckyValue(true, addNum)
			else
				if addNum == self._singleExp * QUIDialogGlyphUp.MIN_BET then
					-- app.tip:floatTip("暴击！体技经验+"..addNum)
					self:_showBet(false, addNum)
				elseif addNum == self._singleExp * QUIDialogGlyphUp.MAX_BET then
					-- app.tip:floatTip("大暴击！体技经验+"..addNum)
					self:_showBet(true, addNum)
				elseif self._isLevelUp then
					if addNum < self._singleExp then
						-- app.tip:floatTip("体技经验+"..addNum)
						self:_showExpOrLuckyValue(true, addNum)
					elseif addNum < self._singleExp * QUIDialogGlyphUp.MIN_BET then
						-- app.tip:floatTip("暴击！体技经验+"..addNum)
						self:_showBet(false, addNum)
					elseif addNum < self._singleExp * QUIDialogGlyphUp.MAX_BET then
						-- app.tip:floatTip("大暴击！体技经验+"..addNum)
						self:_showBet(true, addNum)
					else
						print("体技经验增加（"..self._curExp.." : "..self._nextExp.." : "..self._totalExp.." : "..addNum.." : "..self._singleExp.."）异常，请检查是否有这样的暴击率")
						-- app.tip:floatTip("体技经验增加（"..self._curExp.." : "..self._nextExp.." : "..self._totalExp.." : "..addNum.." : "..self._singleExp.."）异常，请检查是否有这样的暴击率")
					end
				else
					print("体技经验增加（"..self._curExp.." : "..self._nextExp.." : "..self._totalExp.." : "..addNum.." : "..self._singleExp.."）异常，请检查是否有这样的暴击率")
					-- app.tip:floatTip("体技经验增加（"..self._curExp.." : "..self._nextExp.." : "..self._totalExp.." : "..addNum.." : "..self._singleExp.."）异常，请检查是否有这样的暴击率")
				end
			end
		end

    	self._showProgressEffect = nil
		if self._isLevelUp then
			self:_showLevelUp() 
		else
			self:_addEffectWillOver() --不等动画直接可以下次升级
		end
	else
		greenX = (self._curExp + self._progressAnimationIndex) / self._totalExp * self._initTotalGreenScaleX
		self._ccbOwner.node_green:setScaleX( greenX )

		self:_updateNodeGuangPostion()
		if self._curProgressState == 0 or not self._progressEffectB then
			self._curProgressState = 1
			self._progressEffectB = self:_addGreenEffectB()
			self._progressEffectA = nil
		end
	end
end

function QUIDialogGlyphUp:_showLevelUp()
	local ccbFile = "ccb/effects/diaowen_shengji_chenggong.ccbi"
    local aniPlayer = QUIWidgetAnimationPlayer.new()
    self._ccbOwner.node_icon:addChild(aniPlayer)
    aniPlayer:playAnimation(ccbFile, nil, function ()

    	local successTip = app.master.GLYPH_LEVEL_UP
		if app.master:getMasterShowState(successTip) then
	    	app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass="QUIDialogGlyphLevelUp", 
	            options = {skillId = self._skillId, oldLevel = self._skillLevel, addlevel = self._offersetLevel, aniPlayer = aniPlayer, successTip = successTip, callBack = handler(self, QUIDialogGlyphUp._addEffectWillOver)}}, {isPopCurrentDialog = false} )
	    else
	    	self:_addEffectWillOver()
	    end
    end)
end

function QUIDialogGlyphUp:_showLost()
	-- local ccbFile = "ccb/effects/diaowen_shengji_shibai.ccbi"
 --    local aniPlayer = QUIWidgetAnimationPlayer.new()
 --    self._ccbOwner.node_progress_effect:addChild(aniPlayer)
 --    aniPlayer:playAnimation(ccbFile, nil, function ()
    	-- app.tip:floatTip("幸运值+"..(self._nextLuckyValue - self._curLuckyValue))
    	self:_showExpOrLuckyValue(false, self._nextLuckyValue - self._curLuckyValue)
    -- end)

    self:_addEffectWillOver() --不等动画直接可以下次升级
end

function QUIDialogGlyphUp:_showExpOrLuckyValue( isSucceed, addNum )
	local ccbFile = "ccb/effects/dianwen_chengg.ccbi"
    local aniPlayer = QUIWidgetAnimationPlayer.new()
    if self._ccbOwner.node_client_4 then
    	self._ccbOwner.node_client_4:addChild(aniPlayer)
	    aniPlayer:playAnimation(ccbFile, function ( ccbOwner )
	    	if isSucceed then
	    		ccbOwner.tf_name_success:setString("经验增加成功")
	    		ccbOwner.tf_name_lost:setString("")
	    		-- 体技
	    		ccbOwner.tf_num:setString("经验 + "..addNum)
	    	else
	    		ccbOwner.tf_name_lost:setString("经验增加失败")
	    		ccbOwner.tf_name_success:setString("")
	    		ccbOwner.tf_num:setString("幸运值 + "..addNum)
	    	end
	    end, function ()
	    	-- self:_addEffectWillOver()
	    end)
	end
end

function QUIDialogGlyphUp:_showBet( isMaxBet, addNum )
	local ccbFile = "ccb/effects/diaowen_baoji.ccbi"
    local aniPlayer = QUIWidgetAnimationPlayer.new()
    self._ccbOwner.node_client_4:addChild(aniPlayer)
    aniPlayer:playAnimation(ccbFile, function ( ccbOwner )
    	ccbOwner.node_dabaoji:setVisible(isMaxBet)
		ccbOwner.node_baoji:setVisible(not isMaxBet)
		ccbOwner.tf_num:setString("经验 + "..addNum)
    end, function ()
    	-- self:_addEffectWillOver()
    end)
end

function QUIDialogGlyphUp:_addEffectWillOver()
	print("[Kumo] QUIDialogGlyphUp:_addEffectWillOver()")
	self._nextExp = 0
	self._nextLuckyValue = 0
	self._isSucceed = false
	self._isLevelUp = false

	self:_updateInfo()

	if self._updateProgressDelayGlobal then
		scheduler.unscheduleGlobal(self._updateProgressDelayGlobal)
		self._updateProgressDelayGlobal = nil
	end
	self._updateProgressDelayGlobal = scheduler.performWithDelayGlobal(function ()
		self:_updateProgress()
	end, 0.5)
	
	if self._delay then
		scheduler.unscheduleGlobal(self._delay)
		self._delay = nil
	end

	self._isLock = false
	self._ccbOwner.btn_ok:setEnabled(true)
	makeNodeFromGrayToNormal(self._ccbOwner.node_btn_ok)
end

function QUIDialogGlyphUp:_responseHandler( response )
	-- QPrintTable(response)
	for _, hero in pairs(response.heros) do
		if hero.actorId == self._actorId then
			for _, value in pairs(hero.glyphs) do
				if value.glyphId == self._skillId then
					self._nextExp = 0
					self._nextLuckyValue = 0
					if value.level == self._skillLevel then
						--未升级
						if self._curExp == value.exp then
							--失败
							-- print("失败")
							self._isSucceed = false
							self._nextLuckyValue = value.luckyValue
						else
							--成功
							-- print("成功")
							self._isSucceed = true
							self._nextExp = value.exp
						end
					else
						--已升级
						-- print("升级")
						self._isLevelUp = true
						self._offersetLevel = value.level - self._skillLevel
						remote.user:sendEventGlyphLevelUp(hero.actorId, value.glyphId, value.level)
						remote:dispatchEvent({name = remote.HERO_UPDATE_EVENT})
					end	
				end
			end
		end
	end
end

function QUIDialogGlyphUp:_updateNodeGuangPostion()
	local x = self._ccbOwner.node_green:getPositionX()
	local w = self._ccbOwner.node_green:getScaleX() * self._ccbOwner.node_green:getContentSize().width
	self._ccbOwner.node_guang:setPositionX( x + w )
end

-- 进度条特效A：静止状态时候的特效
function QUIDialogGlyphUp:_addGreenEffectA()
	self._ccbOwner.node_guang:removeAllChildren()

	local ccbFile = "ccb/effects/jyt_jt_2.ccbi"
    local aniPlayer = QUIWidgetAnimationPlayer.new()
    self._ccbOwner.node_guang:addChild(aniPlayer)
    aniPlayer:playAnimation(ccbFile, nil, nil, false)

    return aniPlayer
end

-- 进度条特效B：运动状态时候的特效
function QUIDialogGlyphUp:_addGreenEffectB()
	self._ccbOwner.node_guang:removeAllChildren()

	local ccbFile = "ccb/effects/jyt_dt_1.ccbi"
    local aniPlayer = QUIWidgetAnimationPlayer.new()
    self._ccbOwner.node_guang:addChild(aniPlayer)
    aniPlayer:playAnimation(ccbFile, nil, nil, false)

    return aniPlayer
end

function QUIDialogGlyphUp:_backClickHandler()
    self:_onTriggerClose()
end

-- function QUIDialogGlyphUp:_checkClose()
-- 	if self._autoScheduler then
-- 		scheduler.unscheduleGlobal(self._autoScheduler)
-- 		self._autoScheduler = nil
-- 	end
-- 	self._isAutoState = false
-- 	self._ccbOwner.tf_auto:setString("一键升级")
-- 	app:alert({content = "您正在一键升级中，确定要关闭吗？", title = "系统提示", 
--         comfirmBack = function()
--         	self:playEffectOut()
--         end, callBack = function() 
--         	self:_onTriggerOK()
-- 			self._autoScheduler = scheduler.scheduleGlobal(function()
-- 					self:_onTriggerOK()
-- 				end, 0.5)
-- 			self._isAutoState = true
-- 			self._ccbOwner.tf_auto:setString("停  止")
--         end, isAnimation = false}, true, true)   
-- end

function QUIDialogGlyphUp:_onTriggerClose(event)
	if q.buttonEventShadow(event, self._ccbOwner.frame_btn_close) == false then return end
	app.sound:playSound("common_cancel")
	-- 不用改 ———— by 柯浩
	-- if self._isAutoState then
	-- 	self:_checkClose()
	-- 	return
	-- end
	if self._isLock then return end
   	self:playEffectOut()
end

function QUIDialogGlyphUp:viewAnimationOutHandler()
    local callback = self._callBackFun
    app:getNavigationManager():popViewController(app.middleLayer, QNavigationController.POP_TOP_CONTROLLER)
    if callback ~= nil then
    	callback()
    end
end

return QUIDialogGlyphUp