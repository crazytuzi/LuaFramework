-- @Author: liaoxianbo
-- @Date:   2019-09-18 14:30:16
-- @Last Modified by:   xurui
-- @Last Modified time: 2019-12-09 15:44:04
local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogOneClickGemStoneBreakThrough = class("QUIDialogOneClickGemStoneBreakThrough", QUIDialog)

local QNavigationController = import("...controllers.QNavigationController")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QUIViewController = import("..QUIViewController")
local QUIWidgetMasterCell = import("..widgets.QUIWidgetMasterCell")
local QUIHeroModel = import("...models.QUIHeroModel")
local QUIDialogHeroEquipmentDetail = import("..dialogs.QUIDialogHeroEquipmentDetail")
local QUIWidgetMasterPropClient = import("..widgets.QUIWidgetMasterPropClient")
local QQuickWay = import("...utils.QQuickWay")

function QUIDialogOneClickGemStoneBreakThrough:ctor(options)
	local ccbFile = "ccb/Dialog_suit_equip_strengthen.ccbi"
    local callBacks = {
		{ccbCallbackName = "onTriggerClose", callback = handler(self, self._onTriggerClose)},
		{ccbCallbackName = "onTriggerSelect", callback = handler(self, self._onTriggerSelect)},
		{ccbCallbackName = "onTriggerStrengthen", callback = handler(self, self._onTriggerStrengthen)},
    }
    QUIDialogOneClickGemStoneBreakThrough.super.ctor(self, ccbFile, callBacks, options)
    self.isAnimation = true

	cc.GameObject.extend(self)
	self:addComponent("components.behavior.EventProtocol"):exportMethods()

	self._gemstoneBox = {}
	self._currMasterInfo = {}
	self._nextMasterInfo = {}
	self._offersetLevel = 1
	self._isBreakThroughMax = app:getUserOperateRecord():getRecordByType("gemstone_yijiantupo_max") or false
	self._ccbOwner.sp_select_2:setVisible(self._isBreakThroughMax)
	self._ccbOwner.frame_tf_title:setString("魂骨突破")
	self._ccbOwner.tf_select:setString("突破到顶")

	self._callBack = options.callBack
	self._masterType = options.masterType
	self._actorId = options.actorId

	self._s_gemstone = false -- s魂骨需要升ss
	self._A_gemstone = false -- A魂骨只能突破到21级


    self:restAll()
end

function QUIDialogOneClickGemStoneBreakThrough:viewDidAppear()
	QUIDialogOneClickGemStoneBreakThrough.super.viewDidAppear(self)

	self:initInfo()
end

function QUIDialogOneClickGemStoneBreakThrough:viewWillDisappear()
  	QUIDialogOneClickGemStoneBreakThrough.super.viewWillDisappear(self)
end

function QUIDialogOneClickGemStoneBreakThrough:restAll()

	self._ccbOwner.node_master:removeAllChildren()
end

function QUIDialogOneClickGemStoneBreakThrough:initInfo( )
    self.heroUIModel = remote.herosUtil:getUIHeroByID(self._actorId)
	self._masterLevel = self.heroUIModel:getMasterLevelByType(self._masterType)
	self._breakLevel = self._masterLevel + 1
	self._itemId1 = 0
	self._itemId2 = 0
	self._breakPos = {}
	
	self:checkNeedMoney()
	self:setPropInfo()
	self:setBoxInfos()
end

function QUIDialogOneClickGemStoneBreakThrough:checkNeedMoney()
	local allNeedMoney = 0
	local allItemCount1 = 0
	local allItemCount2 = 0

	local breakLevel = self._masterLevel + 1
	if self._isBreakThroughMax then
		breakLevel = 999
	end

	-- 突破等级map
	local gemstoneConfigMap = {}
	for i = 1, 4 do
		local genstoneInfo = self.heroUIModel:getGemstoneInfoByPos(i)
		local gemstoneConfig = db:getGemstoneBreakThrough(genstoneInfo.info.itemId)

		gemstoneConfigMap[i] = {}
		for _, config in pairs(gemstoneConfig) do
			gemstoneConfigMap[i][config.break_level] = config
			if config.component_id_1 and config.component_id_2 then
				self._itemId1 = config.component_id_1
				self._itemId2 = config.component_id_2
			end
		end
	end
	local curItemCount1 = remote.items:getItemsNumByID(self._itemId1)
	local curItemCount2 = remote.items:getItemsNumByID(self._itemId2)
	
	local cannotType = 0
	local canBreak = false
	for level = self._masterLevel + 1, breakLevel do
		-- 每一个等级都看下四个魂骨能否突破
		local isEnough = false
		local levelMoney = 0
		local levelItemCount1 = 0
		local levelItemCount2 = 0
		for i = 1, 4 do
			local config = gemstoneConfigMap[i][level]
			local genstoneInfo = self.heroUIModel:getGemstoneInfoByPos(i)
			if not config then
				if (genstoneInfo.info.godLevel or 1) < GEMSTONE_MAXADVANCED_LEVEL  then
					self._A_gemstone = true
				end
				isEnough = false
				break
			else
				if (genstoneInfo.info.godLevel or 1) < GEMSTONE_MAXADVANCED_LEVEL and (genstoneInfo.info.mix_level or 0) <= 0 and level > S_GEMSTONE_MAXEVOLUTION_LEVEL then
					self._s_gemstone = true
					isEnough = false
					break
				-- 需要突破，检测材料是否充足
				elseif genstoneInfo.info.craftLevel < config.break_level then
					levelMoney = levelMoney + config.price
					levelItemCount1 = levelItemCount1 + config.component_num_1
					levelItemCount2 = levelItemCount2 + config.component_num_2
					-- 不能突破的原因
					if allNeedMoney + levelMoney > remote.user.money then
						cannotType = 1
						isEnough = false
					elseif allItemCount1 + levelItemCount1 > curItemCount1 then
						cannotType = 2
						isEnough = false
					elseif allItemCount2 + levelItemCount2 > curItemCount2 then
						cannotType = 3
						isEnough = false
					else
						isEnough = true
						self._breakPos[i] = true
					end

				end
			end
		end
		
		-- 所有都能突破才继续
		if isEnough then
			canBreak = true
			allNeedMoney = allNeedMoney + levelMoney
			allItemCount1 = allItemCount1 + levelItemCount1
			allItemCount2 = allItemCount2 + levelItemCount2
			self._breakLevel = level
			print("_breakLevel  "..level)
		else
			break
		end
	end

	self._canBreak = canBreak
	self._ccbOwner.confirmText:setString("确 定")
	if canBreak then
		local num, unit = q.convertLargerNumber(allNeedMoney)
		local num1, unit1 = q.convertLargerNumber(allItemCount1)
		local num2, unit2 = q.convertLargerNumber(allItemCount2)
    	local level, color = remote.herosUtil:getBreakThrough(self._breakLevel)
    	local colorFont = q.convertColorToWord(color)
    	if level > 0 then
    		colorFont = colorFont.."+"..level
    	end
		self._ccbOwner.tf_tips:setString("消耗"..num..unit.."金魂币，"..num1..unit1.."魂骨突破石，"..num2..unit2.."魂骨精华将魂骨突破至"..colorFont.."效果")
		self._ccbOwner.confirmText:setString("突 破")
		self._canBreak = true
	elseif cannotType == 1 then
		self._ccbOwner.tf_tips:setString("魂骨强化所需金魂币不足，快去获取更多金魂币吧")
		self._needType = "money"
	elseif cannotType == 2 then
		self._ccbOwner.tf_tips:setString("魂骨突破所需魂骨突破石不足，快去获取更多魂骨突破石吧")
		self._needType = self._itemId1
	elseif cannotType == 3 then
		self._ccbOwner.tf_tips:setString("魂骨突破所需魂骨精华不足，快去获取吧")
		self._needType = self._itemId2
	elseif self._s_gemstone or self._A_gemstone then
		self._ccbOwner.tf_tips:setString("已经突破到顶级")
		self:setButtonEnabled(true)
		self._ccbOwner.confirmText:disableOutline()		
	elseif allNeedMoney <= 0 then
		self._ccbOwner.tf_tips:setString("已经突破到顶级")
		self:setButtonEnabled(false)
		self._ccbOwner.confirmText:disableOutline()
	end
end

function QUIDialogOneClickGemStoneBreakThrough:setButtonEnabled(state)
	if state == false then
		makeNodeFromNormalToGray(self._ccbOwner.btn_buy)
		self._ccbOwner.confirmText:disableOutline()
		self._ccbOwner.bt_confirm:setEnabled(false)
	elseif state then
		makeNodeFromGrayToNormal(self._ccbOwner.btn_buy)
		self._ccbOwner.confirmText:enableOutline()
		self._ccbOwner.bt_confirm:setEnabled(true)
	end
end

function QUIDialogOneClickGemStoneBreakThrough:setBoxInfos()
	self._gemstoneBox = {}
	for i = 1, 4 do
		self._gemstoneBox[i] = QUIWidgetMasterCell.new()
		self._ccbOwner["box_node"..i]:removeAllChildren()
		self._ccbOwner["box_node"..i]:addChild(self._gemstoneBox[i])
		local genstoneInfo = self.heroUIModel:getGemstoneInfoByPos(i)
		if genstoneInfo.info ~= nil then
			local canStrengthen = false 
			if genstoneInfo.info.craftLevel < self._breakLevel then
				canStrengthen = true
			end

			local itemInfo = db:getItemByID(genstoneInfo.info.itemId)
			self._gemstoneBox[i]:setType(i)
			self._gemstoneBox[i]:setItemInfo(itemInfo, genstoneInfo, self._nextMasterInfo, self._masterType, canStrengthen)
		else
			self._gemstoneBox[i]:showEmpty(self._nextMasterInfo)
		end
	end
end

function QUIDialogOneClickGemStoneBreakThrough:setPropInfo()
	local offersetLevel = self._breakLevel - self._masterLevel 
	print("offersetLevel  "..offersetLevel)
	self._currMasterInfo, self._nextMasterInfo, self._isMax = db:getStrengthenMasterByMasterLevel(self._masterType, self._masterLevel, offersetLevel)

	if self._propClient == nil then
		self._propClient = QUIWidgetMasterPropClient.new()
		self._ccbOwner.node_master:addChild(self._propClient)
	end
	self._propClient:setClientInfo(self._masterLevel, self._isMax, self._currMasterInfo, self._nextMasterInfo, self._masterType, true)
end 


function QUIDialogOneClickGemStoneBreakThrough:_onTriggerSelect()
	local btnState = self._ccbOwner.sp_select_2:isVisible()

	self._ccbOwner.sp_select_2:setVisible(not btnState)
	self._isBreakThroughMax = not btnState
	app:getUserOperateRecord():setRecordByType("gemstone_yijiantupo_max", not btnState)

	self:initInfo()
end

function QUIDialogOneClickGemStoneBreakThrough:_onTriggerStrengthen(event)
	if q.buttonEventShadow(event, self._ccbOwner.bt_confirm) == false then return end

	if not self._canBreak then 
		if self._A_gemstone then
			app.tip:floatTip("S级以下魂骨已达突破上限")
		elseif self._s_gemstone then
			app.tip:floatTip("S魂骨突破等级已达上限，需要升阶为SS魂骨或SS+魂骨才可突破上限")	
		elseif self._needType == "money" then
			QQuickWay:addQuickWay(QQuickWay.RESOUCE_DROP_WAY, ITEM_TYPE.MONEY)
		else
			QQuickWay:addQuickWay(QQuickWay.ITEM_DROP_WAY, self._needType)
		end
		return
	end

	local actorId = self._actorId
	local isTop = self._isBreakThroughMax
	local breakPos = {}
	for i, v in pairs(self._breakPos) do
		table.insert(breakPos, i)
	end
	table.sort(breakPos)

	local oldUIModel = clone(remote.herosUtil:getUIHeroByID(actorId))
	remote.gemstone:gemstoneOneKeyCraftRequest(actorId, isTop, function(data)
		self:initInfo()
		local newUIModel = remote.herosUtil:getUIHeroByID(actorId)

		local masterCallback = function()
			local oldBreakMaster = oldUIModel:getMasterLevelByType(QUIHeroModel.GEMSTONE_BREAK_MASTER)
			local newBreakMaster = newUIModel:getMasterLevelByType(QUIHeroModel.GEMSTONE_BREAK_MASTER)
			if newBreakMaster > oldBreakMaster then
				app.master:upGradeGemstoneMaster(oldBreakMaster, newBreakMaster, QUIHeroModel.GEMSTONE_BREAK_MASTER, actorId)
			end	
			remote.herosUtil:dispatchEvent({name = remote.herosUtil.EVENT_REFESH_BATTLE_FORCE})
		end

		local index = 1
		local callback
		callback = function()
			local successTip = app.master.GEMSTONE_BREAK_TIP
			local pos = breakPos[index]
			if pos and app.master:getMasterShowState(successTip) then
	    		app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogGemstoneBreakthroughSuccess", 
	        		options = {oldUIModel = oldUIModel, newUIModel = newUIModel, pos = pos, successTip = successTip, callback = callback}}, {isPopCurrentDialog = false})
		    else
		    	masterCallback()
		    end
			index = index + 1
		end

		callback()
	end)
end

function QUIDialogOneClickGemStoneBreakThrough:_backClickHandler()
  	app.sound:playSound("common_close")
	self:playEffectOut()
end

function QUIDialogOneClickGemStoneBreakThrough:_onTriggerClose(event)
	if q.buttonEventShadow(event,self._ccbOwner.btn_close) == false then return end
  	app.sound:playSound("common_close")
	self:playEffectOut()
end

function QUIDialogOneClickGemStoneBreakThrough:viewAnimationOutHandler()
	local callback = self._callBack

	self:popSelf()

	if callback then
		callback()
	end
end

return QUIDialogOneClickGemStoneBreakThrough

