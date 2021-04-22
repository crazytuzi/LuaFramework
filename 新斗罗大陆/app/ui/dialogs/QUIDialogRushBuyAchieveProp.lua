--[[	
	文件名称：QUIDialogRushBuyAchieveProp.lua
	创建时间：2017-2-14 19:07:38
	作者：nieming
	描述：QUIDialogRushBuyAchieveProp
]]

local QUIDialog = import(".QUIDialog")
local QUIDialogRushBuyAchieveProp = class("QUIDialogRushBuyAchieveProp", QUIDialog)
local QNavigationController = import("...controllers.QNavigationController")
local QListView = import("...views.QListView")
local QUIWidgetRushBuyNumItem = import("..widgets.QUIWidgetRushBuyNumItem")
local QUIWidgetQlistviewItem = import("..widgets.QUIWidgetQlistviewItem")
local QRichText = import("...utils.QRichText") 
-- local QUIWidgetItemsBox = import("..widgets.QUIWidgetItemsBox")
--初始化
function QUIDialogRushBuyAchieveProp:ctor(options)
	local ccbFile = "ccb/Dialog_Rush_Buy_AchieveProp.ccbi"
	local callBacks = {
	}
	QUIDialogRushBuyAchieveProp.super.ctor(self,ccbFile,callBacks,options)
	--代码
	if not options then
		options = {}
	end

	self._data = options.data
	-- self._oldData = options.oldData or {}
	self.isInAnimation = true
	self._cellSize = {width = 130, height = 120}
	

	if self._data then 
		self._multiItems = 5
		local len = #self._data
		local lineNum = math.ceil(len / self._multiItems)
		if len <= self._multiItems then
			local width = len * (self._cellSize.width)
			local height = (self._cellSize.height)
			self._ccbOwner.listView:setContentSize(width, height)
			self._ccbOwner.listView:setPosition(ccp(-width/2, -height/2))
		elseif len <= 2 * self._multiItems then
			self._multiItems = math.ceil(len / 2)
			local width = self._multiItems * (self._cellSize.width )
			local height = 2 * (self._cellSize.height )
			self._ccbOwner.listView:setContentSize(width, height)
			self._ccbOwner.listView:setPosition(ccp(-width/2, -height/2))
		else
			local width = 640
			local height = 280
			self._ccbOwner.listView:setContentSize(width, height)
			self._ccbOwner.listView:setPosition(ccp(-width/2, -height/2))
		end

		self._buyRichText = QRichText.new({
			 {oType = "font", content = "恭喜您获得",size = 26,color = ccc3(253,231,169)},
	         {oType = "font", content = len,size = 26,color = ccc3(255,255,0)},
	          {oType = "font", content = "个夺宝号码",size = 26,color = ccc3(253,231,169)},
			})

		self._ccbOwner.richText:addChild(self._buyRichText)

	end
	self._curIndex = 1;
	self._ccbOwner.touchScreenLabel:setString("点击屏幕跳过动画")

end


function QUIDialogRushBuyAchieveProp:setItemInfo( item, itemData )
	if not item._itemNode then
		item._itemNode = QUIWidgetRushBuyNumItem.new()
		item._itemNode:setPosition(ccp(self._cellSize.width/2,self._cellSize.height/2))
		item._ccbOwner.parentNode:addChild(item._itemNode)
		item._ccbOwner.parentNode:setContentSize(CCSizeMake(self._cellSize.width,self._cellSize.height))
	end
	item._itemNode:setInfo(itemData.num)

	if item._itemNode then
		if itemData.isVisible then
			item._itemNode:setVisible(true)
		else
			item._itemNode:setVisible(false)
		end
	end
end


function QUIDialogRushBuyAchieveProp:initListView(  )
	-- body
end

--describe：关闭对话框
function QUIDialogRushBuyAchieveProp:close( )
	self:playEffectOut()
end

function QUIDialogRushBuyAchieveProp:createAction( pos )
	-- body

	local actionTime = 0.1
	local actionArrayIn = CCArray:create()
    actionArrayIn:addObject(CCMoveTo:create(actionTime, pos))
    actionArrayIn:addObject(CCScaleTo:create(actionTime, 1, 1))
    actionArrayIn:addObject(CCRotateBy:create(actionTime, -360))
  
    local array = CCArray:create()
    array:addObject(CCSpawn:create(actionArrayIn))
    array:addObject(CCCallFunc:create(function() 
    					local listViewItem = self._itemList:getItemByIndex(self._curIndex)
    					local itemData = self._data[self._curIndex]
    					if listViewItem and itemData then
    						if listViewItem._itemNode then
								itemData.isVisible = true
								listViewItem._itemNode:setVisible(true)		
							end
    					end
    					if self._curIndex < #self._data then
    						self._curIndex = self._curIndex + 1
    						if self._multiItems * 2 <= self._curIndex and  self._curIndex % self._multiItems == 1 then
    							self._ccbOwner.tempItemNode:removeAllChildrenWithCleanup(true)
    							self._itemList:startScrollToPosScheduler(120, 0.15, true, function ()
									self:playEffect()
								end,true)

    						else
    							self._ccbOwner.tempItemNode:removeAllChildrenWithCleanup(true)

    							self:playEffect()
    						end
    						
    					else
    						self._itemList:setShieldTouch(nil)
    						self._ccbOwner.tempItemNode:removeAllChildrenWithCleanup(true)
    						self._curActionItem = nil
    						self._playAction = nil
    						self._ccbOwner.touchScreenLabel:setString("点击屏幕退出")
    					end

    					
                    end))
    local action = CCSequence:create(array)
    return action
end

function QUIDialogRushBuyAchieveProp:playEffect(  )
	-- bodynd
	
	if self._data and self._itemList then 
		local itemData = self._data[self._curIndex]
		local listViewItem = self._itemList:getItemByIndex(self._curIndex)
		if itemData and listViewItem and listViewItem._itemNode then
			local tempPos = self._ccbOwner.tempItemNode:convertToNodeSpace(listViewItem:convertToWorldSpace(ccp(0,0)))
			self._ccbOwner.tempItemNode:removeAllChildrenWithCleanup(true)
			local item = QUIWidgetRushBuyNumItem.new()
			item:setInfo(tonumber(itemData.num))
			
			self._ccbOwner.tempItemNode:addChild(item)
			local action = self:createAction(tempPos)
			
			item:runAction(action)
			self._curActionItem = item
		end
	end
end

function QUIDialogRushBuyAchieveProp:viewDidAppear()
	QUIDialogRushBuyAchieveProp.super.viewDidAppear(self)
	--代码
	if self._data then
		local temp = {}
		for k, v in pairs(self._data) do
			table.insert( temp, {num = tonumber(v) or 0} )
		end
		self._data = temp
		
		local cfg = {
	        renderItemCallBack = function( list, index, info )
	            -- body
	            local isCacheNode = true
	            local itemData = self._data[index]
	            local item = list:getItemFromCache()
	            if not item then
	                item = QUIWidgetQlistviewItem.new()
	                isCacheNode = false
	            end
	           	self:setItemInfo(item, itemData)
	            info.item = item
	            info.size = CCSizeMake(self._cellSize.width,self._cellSize.height)
	            -- list:registerBtnHandler(index,"btnChooseServer", "_onTriggerChoose" )
	            return isCacheNode
	        end,
	        multiItems = self._multiItems,
	        spaceX = self._spaceX,
	        spaceY = self._spaceY,
	        -- enableShadow = false,
	        totalNumber = #self._data
 		}
 		self._itemList = QListView.new(self._ccbOwner.listView, cfg)  	
 		self._itemList:setShieldTouch(true)

	 	scheduler.performWithDelayGlobal(function()
	            app.sound:playSound("common_bright")
	        end, 0.1)
		scheduler.performWithDelayGlobal(function (  )
			-- body
			self.isInAnimation = nil
			self._playAction = true
			self:playEffect()
		end,0.5)	
	end 
end

function QUIDialogRushBuyAchieveProp:viewWillDisappear()
	QUIDialogRushBuyAchieveProp.super.viewWillDisappear(self)
	--代码
end

function QUIDialogRushBuyAchieveProp:viewAnimationOutHandler()
	app:getNavigationManager():popViewController(app.middleLayer, QNavigationController.POP_TOP_CONTROLLER)
	--代码
end

--describe：viewAnimationInHandler 
--function QUIDialogRushBuyAchieveProp:viewAnimationInHandler()
	----代码
--end

--describe：点击Dialog外  事件处理 
function QUIDialogRushBuyAchieveProp:_backClickHandler()
	--代码
	if self._playAction  then
		self._itemList:setShieldTouch(nil)
		self._itemList:stopScrollToPosScheduler(true)
		self._ccbOwner.tempItemNode:removeAllChildrenWithCleanup(true)
		self._curActionItem = nil
		self._playAction = nil
		self._ccbOwner.touchScreenLabel:setString("点击屏幕退出")
		for k, v in pairs(self._data) do
			v.isVisible = true
		end
		self._itemList:refreshData()
		return 
	end
	if not self.isInAnimation then
		self:close()
	end
end

return QUIDialogRushBuyAchieveProp
