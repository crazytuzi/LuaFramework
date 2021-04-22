--
-- Author: Kumo.Wang
-- Date: 
-- 精炼替换提示框
--
local QUIDialog = import(".QUIDialog")
local QUIDialogSpecialRefineReplaceAlert = class("QUIDialogSpecialRefineReplaceAlert", QUIDialog)

local QNavigationController = import("...controllers.QNavigationController")
local QQuickWay = import("...utils.QQuickWay")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QActorProp = import("...models.QActorProp")

function QUIDialogSpecialRefineReplaceAlert:ctor(options)
	local ccbFile = "ccb/Dialog_refine_zhufu2.ccbi"
    local callBacks = {
    	{ccbCallbackName = "onTriggerClose", callback = handler(self, self._onTriggerClose)},	
        {ccbCallbackName = "onTriggerOK", callback = handler(self, self._onTriggerOK)},
    }
    QUIDialogSpecialRefineReplaceAlert.super.ctor(self, ccbFile, callBacks, options)
    local page = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
    page:setManyUIVisible()
    page.topBar:showWithRefine()
    self.isAnimation = true
    self._actorId = options.actorId
    self._index = options.index

    self._comfirmBack = options.comfirmBack
    self._callBack = options.callBack
    self._isComfirm = false

    self:_init()
end

function QUIDialogSpecialRefineReplaceAlert:viewDidAppear()
    QUIDialogSpecialRefineReplaceAlert.super.viewDidAppear(self)
end

function QUIDialogSpecialRefineReplaceAlert:viewWillDisappear()
    QUIDialogSpecialRefineReplaceAlert.super.viewWillDisappear(self)
end

function QUIDialogSpecialRefineReplaceAlert:viewAnimationOutHandler()
	app:getNavigationManager():popViewController(app.topLayer, QNavigationController.POP_TOP_CONTROLLER)

	if self._isComfirm then
		if self._comfirmBack ~= nil then
			self._comfirmBack()
		end
	else
		if self._callBack ~= nil then
			self._callBack()
		end
	end
end

function QUIDialogSpecialRefineReplaceAlert:_onTriggerOK()
	app.sound:playSound("common_small")
	app:getClient():refineAdvanceHeroApplyRequest( self._actorId, function (response)
			self._isComfirm = true
	        self:_onTriggerClose()
	    end)
end

function QUIDialogSpecialRefineReplaceAlert:_init()
	local heroInfo = remote.herosUtil:getHeroByID(self._actorId)
	if not heroInfo.refineHeroInfo then
		local refineHeroInfo = remote.herosUtil:getHeroRefineInfoByID(self._actorId)
		if refineHeroInfo then
			heroInfo.refineHeroInfo = {}
			heroInfo.refineHeroInfo = { openGrid = refineHeroInfo.openGrid, refineAttrsPre = refineHeroInfo.refineAttrsPre }
		end
	end
	-- 设置属性的名字和值
	local buffConfig = QStaticDatabase.sharedDatabase():getRefineBuffConfig()

	if heroInfo.refineAttrs then
		local isFind = false
		for _, value in pairs( heroInfo.refineAttrs ) do
			if value.grid == self._index then
				isFind = true
				local buffName = QActorProp._field[ value.attribute ].refineName or QActorProp._field[ value.attribute ].name
				buffName = string.gsub(buffName, "百分比", "")
				buffName = string.gsub(buffName, "玩家对战", "PVP")
				if not buffConfig[ value.attribute ] then
					self._ccbOwner.tf_buff_now:setString(value.attribute)
					return
				end
				local isPercentage = (buffConfig[ value.attribute ].show_model == "2" or buffConfig[ value.attribute ].show_model == 2)-- 1: 绝对值； 2： 百分比
				local buffValue = ""
				local color = QIDEA_QUALITY_COLOR.GREEN
				if isPercentage then
					buffValue = string.format("%.2f", (value.refineValue * 100)).."%"
				else
					buffValue = value.refineValue
				end
				color = self:_getColor( value.attribute, value.refineValue )
				self._ccbOwner.tf_buff_now:setString(buffName.."+"..buffValue)
				self._ccbOwner.tf_buff_now:setColor( color )
			end
		end

		if not isFind then
			self._ccbOwner.tf_buff_now:setString("未洗炼")
			self._ccbOwner.tf_buff_now:setColor(UNITY_COLOR_LIGHT.gray)
		end
	else
		self._ccbOwner.tf_buff_now:setString("未洗炼")
		self._ccbOwner.tf_buff_now:setColor(UNITY_COLOR_LIGHT.gray)
	end

	if heroInfo.refineHeroInfo and heroInfo.refineHeroInfo.refineAttrsAdvancePre then
		for _, value in pairs( heroInfo.refineHeroInfo.refineAttrsAdvancePre ) do
			if value.grid == self._index then
				local buffName = QActorProp._field[ value.attribute ].refineName or QActorProp._field[ value.attribute ].name
				buffName = string.gsub(buffName, "百分比", "")
				buffName = string.gsub(buffName, "玩家对战", "PVP")
				if not buffConfig[ value.attribute ] then
					self._ccbOwner.tf_buff_will:setString(value.attribute)
					return
				end
				local isPercentage = (buffConfig[ value.attribute ].show_model == "2" or buffConfig[ value.attribute ].show_model == 2)-- 1: 绝对值； 2： 百分比
				local buffValue = ""
				local color = QIDEA_QUALITY_COLOR.GREEN
				if isPercentage then
					buffValue = string.format("%.2f", (value.refineValue * 100)).."%"
				else
					buffValue = value.refineValue
				end
				color = self:_getColor( value.attribute, value.refineValue )
				self._ccbOwner.tf_buff_will:setString(buffName.."+"..buffValue)
				self._ccbOwner.tf_buff_will:setColor( color )
			end
		end
	end

	self:_updateInfo()
end

function QUIDialogSpecialRefineReplaceAlert:_getColor( attribute, value )
	value = (math.floor(value * 100000 + 0.5))/100000
	local buffConfig = QStaticDatabase.sharedDatabase():getRefineBuffConfig()
	local config = buffConfig[ attribute ]
	local multiple = tonumber( config.multiple )
	if config then
		local tbl = self:_analysisScope( config.value_green )
		if value >= tonumber(tbl[1])/multiple and value < tonumber(tbl[2])/multiple then
			return QIDEA_QUALITY_COLOR.GREEN
		end

		tbl = self:_analysisScope( config.value_blue )
		if value >= tonumber(tbl[1])/multiple and value < tonumber(tbl[2])/multiple then
			return QIDEA_QUALITY_COLOR.BLUE
		end

		tbl = self:_analysisScope( config.value_purple )
		if value >= tonumber(tbl[1])/multiple and value < tonumber(tbl[2])/multiple then
			return QIDEA_QUALITY_COLOR.PURPLE
		end

		tbl = self:_analysisScope( config.value_orange )
		if value >= tonumber(tbl[1])/multiple and value < tonumber(tbl[2])/multiple then
			return QIDEA_QUALITY_COLOR.ORANGE
		end

		tbl = self:_analysisScope( config.value_red )
		if value >= tonumber(tbl[1])/multiple --[[and value <= tonumber(tbl[2])/multiple ]]then
			return QIDEA_QUALITY_COLOR.RED, true
		end
	end

	return QIDEA_QUALITY_COLOR.GREEN
end

-- str = "1,15",
function QUIDialogSpecialRefineReplaceAlert:_analysisScope( str )
	if not str or str == "" then return {} end

	local tbl = string.split( str, "," ) or {}
	-- QPrintTable( tbl )
	table.sort( tbl, function( a, b )
			return tonumber(a) < tonumber(b)
		end)

	return tbl
end


function QUIDialogSpecialRefineReplaceAlert:_updateInfo()
	local heroInfo = clone(remote.herosUtil:getHeroByID(self._actorId))
	if not heroInfo.refineHeroInfo then
		local refineHeroInfo = remote.herosUtil:getHeroRefineInfoByID(self._actorId)
		if refineHeroInfo then
			heroInfo.refineHeroInfo = {}
			heroInfo.refineHeroInfo = { openGrid = refineHeroInfo.openGrid, refineAttrsPre = refineHeroInfo.refineAttrsPre }
		end
	end
	local ap = remote.herosUtil:createHeroProp(heroInfo)
	local forceNow = ap:getBattleForce(true)
	ap:removeRefineProp()
	local forceBase = ap:getBattleForce(true)
	local willProp = self:_getWillRefineProp()
	ap:addWillRefineProp( willProp )
	local forceWill = ap:getBattleForce(true)
	ap:removeRefineProp()
	ap:addRefineProp()
	local numNow, unitNow = q.convertLargerNumber( forceNow - forceBase )
	self._ccbOwner.tf_force_now:setString(numNow..(unitNow or ""))

	local numWill, unitWill = q.convertLargerNumber( forceWill - forceBase )
	self._ccbOwner.tf_force_will:setString(numWill..(unitWill or ""))

	if forceNow < forceWill then
		self._ccbOwner.ccb_up:setVisible(true)
		self._ccbOwner.ccb_down:setVisible(false)
	elseif forceNow > forceWill then
		self._ccbOwner.ccb_up:setVisible(false)
		self._ccbOwner.ccb_down:setVisible(true)
	else
		self._ccbOwner.ccb_up:setVisible(false)
		self._ccbOwner.ccb_down:setVisible(false)
	end
end

function QUIDialogSpecialRefineReplaceAlert:_getWillRefineProp()
	local heroInfo = remote.herosUtil:getHeroByID( self._actorId ) 
	if not heroInfo.refineHeroInfo then
		local refineHeroInfo = remote.herosUtil:getHeroRefineInfoByID(self._actorId)
		if refineHeroInfo then
			heroInfo.refineHeroInfo = {}
			heroInfo.refineHeroInfo = { openGrid = refineHeroInfo.openGrid, refineAttrsPre = refineHeroInfo.refineAttrsPre }
		end
	end
	if not heroInfo.refineHeroInfo then return {} end
	local nowProp = heroInfo.refineAttrs or {}
	local advanceProp = heroInfo.refineHeroInfo.refineAttrsAdvancePre or {}
	local tbl = {}
	for _, value in pairs(nowProp) do
		if value.grid ~= self._index then
			table.insert(tbl, value)
		end
	end

	for _, value in pairs(advanceProp) do
		if value.grid == self._index then
			table.insert(tbl, value)
		end
	end

	return tbl
end

-- function QUIDialogSpecialRefineReplaceAlert:_backClickHandler()
-- 	self:_onTriggerClose()
-- end

function QUIDialogSpecialRefineReplaceAlert:_onTriggerClose()
	app.sound:playSound("common_cancel")
	self:playEffectOut()
end

return QUIDialogSpecialRefineReplaceAlert