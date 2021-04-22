--
-- Author: xurui
-- Date: 2016-07-25 15:58:50
--
local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogChooseBackPack = class("QUIDialogChooseBackPack", QUIDialog)

local QUIWidgetBackPackBar = import("..widgets.QUIWidgetBackPackBar")
local QNavigationController = import("...controllers.QNavigationController")
local QUIViewController = import("..QUIViewController")
local QListView = import("...views.QListView")

function QUIDialogChooseBackPack:ctor(options)
	local ccbFile = "ccb/Dialog_Baoshi_Packsack_info.ccbi"
	local callBacks = {
		{ccbCallbackName = "onTriggerClose", callback = handler(self, self._onTriggerClose)},
	}
	QUIDialogChooseBackPack.super.ctor(self, ccbFile, callBacks, options)
	local page = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
	page:setManyUIVisible()
    CalculateUIBgSize(self._ccbOwner.sp_background)

	self._backPackBar = {}
	self._packs = options.packs

	self._size = CCSize(display.ui_width ,display.ui_height) 
	self._ccbOwner.sheet:setPositionX(-self._size.width/2)
    self._ccbOwner.sheet_layout:setContentSize(CCSize(self._size.width, 500) )
	

	self._backBoxAniamtion = false
end

function QUIDialogChooseBackPack:viewDidAppear()
	QUIDialogChooseBackPack.super.viewDidAppear(self)
	
	self:addBackEvent(true)
end


function QUIDialogChooseBackPack:viewAnimationInHandler()
	QUIDialogChooseBackPack.super.viewAnimationInHandler(self)
	self:setBackPackBar()
end

function QUIDialogChooseBackPack:viewWillDisappear()
	QUIDialogChooseBackPack.super.viewWillDisappear(self)

	self:removeBackEvent()

	if self._checkItemScheduler ~= nil then
		scheduler.unscheduleGlobal(self._checkItemScheduler)
		self._checkItemScheduler = nil
	end

	if self._timeScheduler2 ~= nil then
		scheduler.unscheduleGlobal(self._timeScheduler2)
		self._timeScheduler2 = nil
	end
end

function QUIDialogChooseBackPack:setBackPackBar()
	self:initListBackPackView()
	self:showMoveDirecTion(true)
end

function QUIDialogChooseBackPack:showMoveDirecTion(isright)
	local isCanDrag = self._listView:getCanDrag()
	print("isCanDrag-----",isCanDrag)
	if not isCanDrag then
		self._ccbOwner.node_right:setVisible(false)
		self._ccbOwner.node_left:setVisible(false)
		return
	end	

	self._ccbOwner.node_right:setVisible(isright)
	self._ccbOwner.node_left:setVisible(not isright)
end
function QUIDialogChooseBackPack:initListBackPackView()
	local barNum = #self._packs
	local spaceX = 70
	local curOriginOffset = 40
	if barNum == 2 then
		spaceX= 220
		curOriginOffset = 40	
	elseif barNum == 3 then
		spaceX= 110
		curOriginOffset = 30			
	elseif barNum == 4 then
		spaceX= 40
		curOriginOffset = 20
	else
		spaceX= 70
		curOriginOffset = 50
	end

    local _scrollEndCallback
    local _scrollBeginCallback
    local _scrollMogveinggCallback
    _scrollEndCallback = function ()
    	print("_scrollEndCallback")
        if self:safeCheck() then
            self:showMoveDirecTion(false)
        end
    end

    _scrollBeginCallback = function ()
    	print("_scrollBeginCallback")
        if self:safeCheck() then
            self:showMoveDirecTion(true)
        end
    end
    _scrollMogveinggCallback = function(isleft,offestY)
    	if self:safeCheck() then
    		local isCanDrag = self._listView:getCanDrag()
    		if isCanDrag and math.abs(offestY) > 70 then
				self._ccbOwner.node_right:setVisible(true)
				self._ccbOwner.node_left:setVisible(true)
			end
    	end
    end

	if not self._listView then
		local cfg = {
			renderItemCallBack = function( list, index, info )
	            -- body
	            local isCacheNode = true
	            local itemData = self._packs[index]
	            local item = list:getItemFromCache()
	            if not item then
	            	item = QUIWidgetBackPackBar.new({index = itemData})
	            	isCacheNode = false
	            end
	            info.item = item
	            info.size = item:getContentSize()
	            list:registerTouchHandler(index,"onTouchListView")
	            list:registerBtnHandler(index, "btn_click", handler(self, self._onBackPackBarClick))
	            return isCacheNode
	        end,
	        curOriginOffset = curOriginOffset,
	        spaceX = spaceX,
	        enableShadow = false,
	        isVertical = false,
	        scrollEndCallBack = _scrollEndCallback,
            scrollBeginCallBack = _scrollBeginCallback,
            scrollMogveinggCallback = _scrollMogveinggCallback,
	        totalNumber = #self._packs,
	        autoCenter = true,
		}
		self._listView = QListView.new(self._ccbOwner.sheet_layout,cfg)
	else
		self._listView:reload({totalNumber = #self._packs})
	end	

	self:itemBoxRunOutAction()
end

function QUIDialogChooseBackPack:itemBoxRunOutAction()
	if self._backBoxAniamtion == true then return end
	self._listView:setCanNotTouchMove(true)
	self._itemBoxAniamtion = true
	for index = 1,#self._packs do
		local itemBox1
		if self._listView then
			itemBox1 = self._listView:getItemByIndex(index)
		end
		if itemBox1 ~= nil then
			local posx,posy = itemBox1:getPosition()
			itemBox1:setPosition(ccp(posx,posy+600))	
		end
	end

	self.func1 = function()
		self._checkItemScheduler = scheduler.performWithDelayGlobal(function()
			if self:safeCheck() then
				self:itemBoxRunInAction()
			end
		end, 0.02)
	end
	self.func1()
end 

function QUIDialogChooseBackPack:itemBoxRunInAction()
	self._backBoxAniamtion = true
	self.time = 0.15
	local index = 1
	self.func2 = function()
		if index <= #self._packs then
			local itemBox1 = self._listView:getItemByIndex(index)
			if itemBox1 ~= nil then
				local array1 = CCArray:create()
				array1:addObject(CCCallFunc:create(function()
						makeNodeFadeToOpacity(itemBox1, self.time)
				    end))
				array1:addObject(CCEaseSineOut:create(CCMoveBy:create(self.time, ccp(0,-600))))

				local array2 = CCArray:create()
				array2:addObject(CCSpawn:create(array1))
				itemBox1:runAction(CCSequence:create(array2))
			end
			index = index + 1
			self._timeScheduler2 = scheduler.performWithDelayGlobal(self.func2, 0.05)
		else
			self.func3 = function()
				self._timeScheduler1 = scheduler.performWithDelayGlobal(function()
					if self:safeCheck() then
						self._backBoxAniamtion = false
						self._listView:setCanNotTouchMove(false)
					end
				end, 0.1)
			end
			self.func3()

		end
	end
	self.func2()
end 

function QUIDialogChooseBackPack:_onBackPackBarClick(x, y, touchNode, listView )
	if self._backBoxAniamtion == true then return end
	app.sound:playSound("common_common")
	local touchIndex = listView:getCurTouchIndex()
    local item = listView:getItemByIndex(touchIndex)
    if item then
    	local index = item:getIndex()
		if index == 1 then
	        return app:getNavigationManager():pushViewController(app.mainUILayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogBackpack", options = {packs = self._packs}})
		elseif index == 2 then
	        return app:getNavigationManager():pushViewController(app.mainUILayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogGemstoneBackpack", options = {packs = self._packs}})
	    elseif index == 3 then
	        return app:getNavigationManager():pushViewController(app.mainUILayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogSoulSpiritBackpack", options = {packs = self._packs}})
	    elseif index == 4 then
	        return app:getNavigationManager():pushViewController(app.mainUILayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogGodarmBackpack", options = {packs = self._packs}})
	    elseif index == 5 then
	        return app:getNavigationManager():pushViewController(app.mainUILayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogMagicHerbBackpack", options = {packs = self._packs}})        
	    end	
    end
end
function QUIDialogChooseBackPack:_onTriggerClose(e)
    if e ~= nil then
        app.sound:playSound("common_cancel")
    end
	self:playEffectOut()
end

function QUIDialogChooseBackPack:viewAnimationOutHandler()
	app:getNavigationManager():popViewController(app.mainUILayer, QNavigationController.POP_TOP_CONTROLLER)
end

function QUIDialogChooseBackPack:onTriggerBackHandler(tag)
	self:_onTriggerBack()
end

function QUIDialogChooseBackPack:onTriggerHomeHandler(tag)
	self:_onTriggerHome()
end

-- 返回上一级
function QUIDialogChooseBackPack:_onTriggerBack(tag, menuItem)
	app:getNavigationManager():popViewController(app.mainUILayer, QNavigationController.POP_TOP_CONTROLLER)
end

-- 返回主界面
function QUIDialogChooseBackPack:_onTriggerHome(tag, menuItem)
	app:getNavigationManager():popViewController(app.mainUILayer, QNavigationController.POP_TO_CURRENT_PAGE)
end

return QUIDialogChooseBackPack