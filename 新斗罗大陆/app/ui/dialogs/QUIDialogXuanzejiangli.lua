--[[	
	文件名称：QUIDialogXuanzejiangli.lua
	创建时间：2016-07-08 14:55:22
	作者：nieming
	描述：QUIDialogXuanzejiangli 用于多选一奖励领取
]]

local QUIDialog = import(".QUIDialog")
local QUIDialogXuanzejiangli = class("QUIDialogXuanzejiangli", QUIDialog)
local QNavigationController = import("...controllers.QNavigationController")
local QUIWidgetXuanzejiangli = import("..widgets.QUIWidgetXuanzejiangli")
local QListView = import("...views.QListView")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QUIViewController = import("..QUIViewController")
--[[
options:
	awards     奖励数组
	okCallBack 确定回调函数
	closeCallBack 
	explainStr 描述文字
	chooseType 1 自主选择 2 预览 3.活动批量兑换
	chooseNum  默认1 
	confirmText
	isNotShowHeroInfoPrompt    显示魂师介绍
	isMultiple 打开多个
	
]]

QUIDialogXuanzejiangli.SPECIAL_SOUL_ITEM = {1000259, 1000260, 17072, 1000177}

--初始化
function QUIDialogXuanzejiangli:ctor(options)
	options = options or {}
	self._isMultiple = options.isMultiple

	local ccbFile
	local callBacks
	if self._isMultiple then
		ccbFile = "Dialog_Xuanzejiangli_New.ccbi"
		callBacks = {
			{ccbCallbackName = "onTriggerOK", callback = handler(self, self._onTriggerOK)},
			{ccbCallbackName = "onTriggerClose", callback = handler(self, self._onTriggerClose)},
			{ccbCallbackName = "onPlus", callback = handler(self, self._onPlus)},
			{ccbCallbackName = "onSub", callback = handler(self, self._onSub)},
			{ccbCallbackName = "onPlusTen", callback = handler(self, self._onPlusTen)},
			{ccbCallbackName = "onSubTen", callback = handler(self, self._onSubTen)},
			{ccbCallbackName = "onMax", callback = handler(self, self._onMax)},
		}
	else
		ccbFile = "Dialog_xuanzejiangli.ccbi"
		callBacks = {
			{ccbCallbackName = "onTriggerOK", callback = handler(self, self._onTriggerOK)},
			{ccbCallbackName = "onTriggerClose", callback = handler(self, self._onTriggerClose)},
		}
	end
	QUIDialogXuanzejiangli.super.ctor(self,ccbFile,callBacks,options)
	self.isAnimation = true


	if self._isMultiple then
		q.setButtonEnableShadow(self._ccbOwner.btn_plusOne)
		q.setButtonEnableShadow(self._ccbOwner.btn_plusTen)
		q.setButtonEnableShadow(self._ccbOwner.btn_subOne)
		q.setButtonEnableShadow(self._ccbOwner.btn_subTen)
		q.setButtonEnableShadow(self._ccbOwner.btn_max)
	end

	self._ccbOwner.frame_tf_title:setString("选择奖励")
	self._okCallBack = options.okCallback
	self._onRewardCallBack = options.onRewardCallBack
	-- 檢查到遊戲中，沒有isFirstRecharge的參數傳入的情況
	self._isFirstRecharge = options.isFirstRecharge
	self._isItemChoose = options.isItemChoose

	if options.explainStr then
		self._ccbOwner.tf_explain:setString(options.explainStr)
	end
	if options.useTypes then
		if tonumber(options.useTypes[1]) == ITEM_USE_TYPE.OPEN then
			self._ccbOwner.tf_explain:setString("以下奖励全部领取")
		end
	end
	if options.confirmText then
		self._ccbOwner.confirmText:setString(options.confirmText)
	end
	if options.titleText then
		self._ccbOwner.frame_tf_title:setString(options.titleText)
	end
	if options.useLabel and self._isMultiple then
		self._ccbOwner.useLabel:setString(options.useLabel)
	end
	self._chooseType = options.chooseType or 1
	self._tipText = options.tipText
	
	if self._chooseType == 2 then
		self._ccbOwner.btn_ok:setVisible(false)
	end
	if options.showOkBtn == true then
		self._ccbOwner.btn_ok:setVisible(true)
	end 

	self._isNotShowHeroInfoPrompt = options.isNotShowHeroInfoPrompt

	self._chooseNum  = options.chooseNum or 1

	self._awards = {}
	if options.awards then
		for k, award in pairs(options.awards) do
			if not remote.items:checkHeroSwitch(award.id) then
				table.insert(self._awards, award)
			end
		end
		if self._isMultiple then
			self._maxOpenNum = options.maxOpenNum or 1
			self._maxExchangeNum = options.maxExchangeNum or 1
			self._curSelectNum = 1
			self:updateSelectNum()
		end
	elseif options.awardsId then
		local checkSpecialItem = function(awardId)
			for _, itemId in ipairs(QUIDialogXuanzejiangli.SPECIAL_SOUL_ITEM) do
				if awardId == tonumber(itemId) then
					return true
				end
			end
			return false
		end

		self._awardsId = options.awardsId
		self._showHeroTag = false
		local info = QStaticDatabase:sharedDatabase():getItemByID( options.awardsId )
		local awards = string.split(info.content, ";") or {}
		if checkSpecialItem(self._awardsId)then
			self._showHeroTag = true
			self._heroTagColors = FONTCOLOR_TO_OUTLINECOLOR[info.colour-1]
		end

		for k, v in pairs(awards) do
			local itemInfo = string.split(v, "^")
			local itemType = ITEM_TYPE.ITEM
			local itemId = itemInfo[1]
			local itemCount = tonumber(itemInfo[2])
			if not remote.items:checkHeroSwitch(itemId) then
				table.insert(self._awards, {id = itemId, count = itemCount, typeName = itemType})
			end
		end

		if self._isMultiple then
			self._itemNum = remote.items:getItemsNumByID(self._awardsId)
			self._maxOpenNum = self._itemNum
			if self._itemNum > 999 then
				self._maxOpenNum = 999
			end
			self._curSelectNum =1
			self:updateSelectNum()
		end
	end
	self._selectNum = options.selectNum or 0
	self._chooseIndex = {}
	for i, award in pairs(self._awards) do
		if i == self._selectNum then
			award.selected = true
			table.insert(self._chooseIndex, i)
		else
			award.selected = false
		end
	end
	if #self._awards < self._chooseNum then
		self._chooseNum = #self._awards
	end

	self:initListView()
end

--describe：
function QUIDialogXuanzejiangli:_onTriggerOK(event)
	if q.buttonEventShadow(event, self._ccbOwner.bt_ok) == false then return end
	--代码
	app.sound:playSound("common_cancel")
	if self._chooseType == 2 then
		self:_onTriggerClose()
		return
	elseif self._chooseType == 3 then
		local onCallBack = self._okCallBack
		if onCallBack then
			app:getNavigationManager():popViewController(app.middleLayer, QNavigationController.POP_TOP_CONTROLLER)
			if onCallBack then
				onCallBack( self._curSelectNum or 1)
			end
		end
		return
	end
	
	local onCallBack = self._okCallBack
	local chooseIndexTable = self._chooseIndex
	local selectCount = self._curSelectNum or 1
	if #self._chooseIndex ~= self._chooseNum then
		local str = "请选择%d个奖励"
		if self._tipText then
			str = self._tipText 
		end
		app.tip:floatTip(string.format(str, self._chooseNum))
		return 
	end
	
	if onCallBack then
		app:getNavigationManager():popViewController(app.middleLayer, QNavigationController.POP_TOP_CONTROLLER)
		if onCallBack then
			onCallBack(chooseIndexTable, selectCount)
		end
	else
		self:getReward()
	end
	
end

function QUIDialogXuanzejiangli:checkItemAndTips(item_id)
	local headStatus,_type = remote.headProp:checkItemTitleOrFrameByItem(item_id)
	if headStatus ~= remote.headProp.ITEM_HEAD_NORMAL then
		if _type == remote.headProp.TITLE_TYPE then
			app.tip:floatTip("已拥有对应奖励，请魂师大人重新选择")
		elseif _type == remote.headProp.FRAME_TYPE then
			app.tip:floatTip("已拥有对应奖励，请魂师大人重新选择")
		end
		return false
	end
	return true
end


function QUIDialogXuanzejiangli:initListView(  )
	-- body
	local function onSelectBtn( x, y, touchNode, listView)
		-- body
		app.sound:playSound("common_small")
		local touchIndex = listView:getCurTouchIndex()
		local info = self._awards[touchIndex]
		local itemType, itemName = remote.items:getItemType(info.id or info.typeName)
		if not self:checkItemAndTips(info.id) then
			return
		end

		if self._isItemChoose then
			if itemType ~= nil and itemType ~= ITEM_TYPE.ITEM then
				local num = remote.user[itemType] or 0
				if num and num < info.count then
					app.tip:floatTip((itemName or "资源").."不足！")
					return
				end
				local canBuyNum = math.floor(num/info.count)
				self._maxOpenNum = math.min(canBuyNum, self._maxExchangeNum) 
			else
				local num = remote.items:getItemsNumByID(info.id) or 0
				if num < info.count then
					app.tip:floatTip("兑换道具不足！")
					return
				end
				local canBuyNum = math.floor(num/info.count)
				self._maxOpenNum = math.min(canBuyNum, self._maxExchangeNum)
			end
			self._curSelectNum = 1
		end

		self:updateSelectNum()

		if self._chooseNum == 1 then
			for k, v in pairs(self._awards) do
				if touchIndex == k then
					v.selected = true
				else
					v.selected = false
				end
			end
			self._chooseIndex[1] = touchIndex
		else
			if self._awards[touchIndex].selected then
				self._awards[touchIndex].selected = false
			else
				self._awards[touchIndex].selected = true
			end
			self._chooseIndex = {}
			for k, v in pairs(self._awards) do
				if v.selected then
					table.insert(self._chooseIndex, k)
				end
			end
		end
		listView:refreshData()
	end

	local curOriginOffset = 15
	local curOffset = 0
	local spaceX = 15
	local autoCenterOffset = 0
	local autoCenter = false
	if #self._awards < 4 then
		autoCenter = true
		autoCenterOffset = -15
	elseif #self._awards > 4 then
		curOriginOffset = 0
		spaceX = 6
		curOffset = 36
	elseif not self._isMultiple then
		curOriginOffset = 5
		spaceX = 15
	end

	if not self._listView then
		-- printTable(self._awards)
	  	local cfg = {
	        renderItemCallBack = function( list, index, info )
	            -- body
	            local isCacheNode = true
	            local item = list:getItemFromCache()
	            local data = self._awards[index]
	            if not item then  
	            	item = QUIWidgetXuanzejiangli.new()       
	                isCacheNode = false
	            end
	            info.item = item
	            info.size = item:getContentSize()
				item:setInfo(data, self._chooseType, self._isItemChoose, self._showHeroTag, self._heroTagColors)	
				if not self._isNotShowHeroInfoPrompt then
					list:registerItemBoxPrompt(index, 1, item._itemBox,-1, "showItemInfo")
				else
					list:registerItemBoxPrompt(index, 1, item._itemBox,-1)
				end
				list:registerBtnHandler(index,"selectBtn", onSelectBtn)

	            return isCacheNode
	        end,
	     	isVertical = false,
	     	autoCenter = autoCenter,
	     	curOffset = curOffset,
	     	autoCenterOffset = autoCenterOffset,
	     	curOriginOffset = curOriginOffset,
	     	enableShadow = false,
	     	spaceX = spaceX,
	     	leftShadow = self._ccbOwner.left_shadow,
	     	rightShadow = self._ccbOwner.right_shadow,

	        totalNumber = #self._awards,
		}  
		self._listView = QListView.new(self._ccbOwner.listViewLayout,cfg)
    else
    	self._listView:reload({totalNumber = #self._awards})
    end

end


--describe：
function QUIDialogXuanzejiangli:_onTriggerClose(event)
	if q.buttonEventShadow(event, self._ccbOwner.frame_btn_close) == false then return end
	--代码
	app.sound:playSound("common_cancel")
	if self._calculatorScheduler then
		scheduler.unscheduleGlobal(self._calculatorScheduler)
		self._calculatorScheduler = nil
	end
	self:playEffectOut()

	self:close()
end

--describe：关闭对话框
function QUIDialogXuanzejiangli:close( )

	if self._onRewardCallBack then
		self._onRewardCallBack()
	end
	local page = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
	if page.class.__cname == "QUIPageMainMenu" then
		printInfo("call QUIPageMainMenu function checkGuiad()")
		page:checkGuiad()
	end
end


function QUIDialogXuanzejiangli:viewDidAppear()
	QUIDialogXuanzejiangli.super.viewDidAppear(self)
	--代码
end

function QUIDialogXuanzejiangli:viewWillDisappear()
	QUIDialogXuanzejiangli.super.viewWillDisappear(self)
	--代码
end

function QUIDialogXuanzejiangli:viewAnimationOutHandler()
	app:getNavigationManager():popViewController(app.middleLayer, QNavigationController.POP_TOP_CONTROLLER)
	--代码
end

function QUIDialogXuanzejiangli:getReward( )
	-- body
	local chooseIndex = self._chooseIndex[1] or 1
	local chooseItem = self._awards[chooseIndex]

	local numCount =1
	if self._isMultiple then
		chooseItem.count = chooseItem.count * self._curSelectNum
		numCount = self._curSelectNum
	end


	if self._awardsId and chooseItem then
		app:getNavigationManager():popViewController(app.middleLayer, QNavigationController.POP_TOP_CONTROLLER)
		if self._isFirstRecharge then
			app:getClient():getFirstRecharge(function (...)
				app:getClient():chooseItemPackage(self._awardsId, chooseItem.id, numCount, function(data)
				local awards
				if tonumber(chooseItem.id) then
					awards = {chooseItem}
				else
					awards = data.prizes
				end
				app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogAwardsAlert",
					options = {awards = awards, callBack = function()
						if self:safeCheck() then
							self:close()
						end
					end }},{isPopCurrentDialog = false})
				end)
			end)
		else
			app:getClient():chooseItemPackage(self._awardsId, chooseItem.id, numCount, function(data)
				local awards
				if tonumber(chooseItem.id) then
					awards = {chooseItem}
				else
					awards = data.prizes
				end
				
				app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogAwardsAlert",
					options = {awards = awards, callBack = function()
						if self:safeCheck() then
							self:close()
						end
					end }},{isPopCurrentDialog = false})
			end)
		end
		
	end
end

--describe：
function QUIDialogXuanzejiangli:_onPlus(event)
	-- if q.buttonEventShadow(event,self._ccbOwner.btn_plusOne) == false then return end
    app.sound:playSound("common_increase")
	if self._curSelectNum < self._maxOpenNum then
		self._curSelectNum = self._curSelectNum + 1
		self:updateSelectNum()
	end
end

function  QUIDialogXuanzejiangli:_onPlusTen(event)
	-- if q.buttonEventShadow(event,self._ccbOwner.btn_plusTen) == false then return end
	if tonumber(event) == CCControlEventTouchDown then
		self:_onDownHandler(10)
	else
    	app.sound:playSound("common_increase")
		self:_onUpHandler(10)
	end
end

function QUIDialogXuanzejiangli:_onMax(event)
	-- if q.buttonEventShadow(event,self._ccbOwner.btn_max) == false then return end
    app.sound:playSound("common_small")

    self._curSelectNum = self._maxOpenNum
	self:updateSelectNum()
end

--describe：
function QUIDialogXuanzejiangli:_onSub(event)
	-- if q.buttonEventShadow(event,self._ccbOwner.btn_subOne) == false then return end
    app.sound:playSound("common_increase")
	if self._curSelectNum > 1 then
		self._curSelectNum = self._curSelectNum - 1
		self:updateSelectNum()
	end
end

function  QUIDialogXuanzejiangli:_onSubTen(event)
	-- if q.buttonEventShadow(event,self._ccbOwner.btn_subTen) == false then return end
	if tonumber(event) == CCControlEventTouchDown then
		self:_onDownHandler(-10)
	else
    	app.sound:playSound("common_increase")
		self:_onUpHandler(-10)
	end
end

function QUIDialogXuanzejiangli:_onUpHandler(num)
	self._isDown = false	
	self._isUp = true
	self:_subBuyNums(num)
end

function QUIDialogXuanzejiangli:_onDownHandler(num)
	self._isDown = true
	self._isUp = false
	if self._calculatorScheduler then
		scheduler.unscheduleGlobal(self._calculatorScheduler)
		self._calculatorScheduler = nil
	end
	self._calculatorScheduler = scheduler.performWithDelayGlobal(function()
			self:_subBuyNums(num)
		end, 0.5)
end

function QUIDialogXuanzejiangli:_subBuyNums(num)
	if self._calculatorScheduler then
		scheduler.unscheduleGlobal(self._calculatorScheduler)
		self._calculatorScheduler = nil
	end

	if self._isDown or self._isUp then
		if self._curSelectNum + num <= 0 then 
			self._curSelectNum = 1
		elseif self._curSelectNum + num > self._maxOpenNum then 
			self._curSelectNum = self._maxOpenNum
		elseif self._curSelectNum == 1 and num == 10 then
			self._curSelectNum = 10
		else
			self._curSelectNum = self._curSelectNum + num
		end

		self:updateSelectNum()

		if self._isUp then return end
		self._calculatorScheduler = scheduler.performWithDelayGlobal(function()
			self:_subBuyNums(num)
		end, 0.05)
	end
end


function QUIDialogXuanzejiangli:updateSelectNum( ... )
	-- body
	if self._ccbOwner.tf_item_num then
		self._ccbOwner.tf_item_num:setString(string.format("%d/%d",self._curSelectNum, self._maxOpenNum))
	end

end
--describe：viewAnimationInHandler 
--function QUIDialogXuanzejiangli:viewAnimationInHandler()
	----代码
--end

--describe：点击Dialog外  事件处理 
--function QUIDialogXuanzejiangli:_backClickHandler()
	----代码
--end

return QUIDialogXuanzejiangli
