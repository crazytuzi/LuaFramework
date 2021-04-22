--[[	
	文件名称：QUIDialogDivinationAchievecard.lua
	创建时间：2016-10-27 19:07:38
	作者：nieming
	描述：QUIDialogDivinationAchievecard
]]

local QUIDialog = import(".QUIDialog")
local QUIDialogDivinationAchievecard = class("QUIDialogDivinationAchievecard", QUIDialog)
local QNavigationController = import("...controllers.QNavigationController")
local QListView = import("...views.QListView")
local QUIWidgetDivinationNumItem = import("..widgets.QUIWidgetDivinationNumItem")
local QUIWidgetQlistviewItem = import("..widgets.QUIWidgetQlistviewItem")
local QUIWidgetItemsBox = import("..widgets.QUIWidgetItemsBox")
--初始化
function QUIDialogDivinationAchievecard:ctor(options)
	local ccbFile = "Dialog_Zhanbu_AchieveCard.ccbi"
	local callBacks = {
	}
	QUIDialogDivinationAchievecard.super.ctor(self,ccbFile,callBacks,options)
	--代码
	if not options then
		options = {}
	end

	self._handlers = {}
	self._data = options.data
	self._oldData = options.oldData or {}
	self.isInAnimation = true
	self._cellSize = {width = 130, height = 120}
	-- self._data.divineResultList = {}
	-- for i =1 , 20 do
	-- 		table.insert( self._data.divineResultList , {
	-- 		resultType = "AWARD_TYPE",
	-- 		resultInfo = "52^2"
	-- 	})
	-- end

	-- for i =1, 7 do
	-- 		table.insert( self._data.divineResultList , {
	-- 		resultType = "NUMBER_TYPE",
	-- 		resultInfo = "52"
	-- 	})
	-- end

	if self._data.divineResultList then 
		self._multiItems = 5
		local len = #self._data.divineResultList
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
	end
	self._curIndex = 1;
	self._ccbOwner.touchScreenLabel:setString("点击屏幕跳过动画")
end


function QUIDialogDivinationAchievecard:setItemInfo( item, itemData )
	-- body
	-- item._ccbOwner.parentNode:removeAllChildrenWithCleanup();
	-- item._itemNode = nil
	if itemData.resultType == "NUMBER_TYPE" then
		if not item._itemNode then
			item._itemNode = QUIWidgetDivinationNumItem.new()
			item._itemNode:setPosition(ccp(self._cellSize.width/2,self._cellSize.height/2))
			item._ccbOwner.parentNode:addChild(item._itemNode)
			item._ccbOwner.parentNode:setContentSize(CCSizeMake(self._cellSize.width,self._cellSize.height))
		end
		item._itemNode:setInfo(tonumber(itemData.resultInfo), true)
	elseif itemData.resultType == "AWARD_TYPE" then
		if not item._itemNode then
			item._itemNode = QUIWidgetItemsBox.new()
			item._itemNode:setPosition(ccp(self._cellSize.width/2,self._cellSize.height/2))
			item._itemNode:setNeedshadow( false )
			item._ccbOwner.parentNode:addChild(item._itemNode)
			item._ccbOwner.parentNode:setContentSize(CCSizeMake(self._cellSize.width,self._cellSize.height))
		end
		if itemData.resultInfo then
			local items = string.split(itemData.resultInfo, ";") or {}
			if #items >=1 then
				local iteminfo = items[1]
				local obj = string.split(iteminfo, "^")
		        if #obj == 2 then
		        	local itemType = remote.items:getItemType(obj[1]) or ITEM_TYPE.ITEM
					if itemType ~= nil and itemType ~= ITEM_TYPE.ITEM then
						item._itemNode:setGoodsInfo(obj[1], itemType, tonumber(obj[2]))
					else
						item._itemNode:setGoodsInfo(tonumber(obj[1]), ITEM_TYPE.ITEM, tonumber(obj[2]))
					end
		        end
			end
		end
	end
	if item._itemNode then
		if itemData.isVisible then
			item._itemNode:setVisible(true)
		else
			item._itemNode:setVisible(false)
		end
	end
end


function QUIDialogDivinationAchievecard:initListView(  )
	-- body
end

--describe：关闭对话框
function QUIDialogDivinationAchievecard:close( )
	self:playEffectOut()
end

function QUIDialogDivinationAchievecard:createAction( pos )
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
    					local itemData = self._data.divineResultList[self._curIndex]
    					if listViewItem and itemData then
    						if listViewItem._itemNode then
								itemData.isVisible = true
								listViewItem._itemNode:setVisible(true)
							
							end
    					end
    					if self._curIndex < #self._data.divineResultList then
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

function QUIDialogDivinationAchievecard:playEffect(  )
	-- bodynd
	
	if self._data.divineResultList and self._itemList then 
		local itemData = self._data.divineResultList[self._curIndex]
		local listViewItem = self._itemList:getItemByIndex(self._curIndex)
		if itemData and listViewItem and listViewItem._itemNode then
			local tempPos = self._ccbOwner.tempItemNode:convertToNodeSpace(listViewItem:convertToWorldSpace(ccp(0,0)))
			self._ccbOwner.tempItemNode:removeAllChildrenWithCleanup(true)
			local item

			if itemData.resultType == "NUMBER_TYPE" then
				item = QUIWidgetDivinationNumItem.new()
				item:setInfo(tonumber(itemData.resultInfo), true)
			elseif itemData.resultType == "AWARD_TYPE" then
				item = QUIWidgetItemsBox.new()
				if itemData.resultInfo then
					local items = string.split(itemData.resultInfo, ";") or {}
					if #items >=1 then
						local iteminfo = items[1]
						local obj = string.split(iteminfo, "^")
				        if #obj == 2 then
				        	local itemType = remote.items:getItemType(obj[1]) or ITEM_TYPE.ITEM
							if itemType ~= nil and itemType ~= ITEM_TYPE.ITEM then
								item:setGoodsInfo(obj[1], itemType, tonumber(obj[2]))
							else
								item:setGoodsInfo(tonumber(obj[1]), ITEM_TYPE.ITEM, tonumber(obj[2]))
							end
				        end
					end
				end
				item:setNeedshadow( false )
			end
			self._ccbOwner.tempItemNode:addChild(item)
			local action = self:createAction(tempPos)
			item:runAction(action)
			self._curActionItem = item
		end
	end
end

function QUIDialogDivinationAchievecard:viewDidAppear()
	QUIDialogDivinationAchievecard.super.viewDidAppear(self)
	--代码
	if self._data.divineResultList then
		  	
		self._ccbOwner.tf_count:setString(#self._data.divineResultList)
		local temp = {}
		local divinationScore = 0
		for k, v in pairs(self._data.divineResultList) do
			if v.resultType == "NUMBER_TYPE" then
				divinationScore = divinationScore + 1
				table.insert(temp, 1, v)
			else
				table.insert(temp, divinationScore + 1, v)
			end
		end
		self._data.divineResultList = temp
		
		self._ccbOwner.activeNumCount:setString(divinationScore)

		local cfg = {
	        renderItemCallBack = function( list, index, info )
	            -- body
	            local isCacheNode = true
	            local itemData = self._data.divineResultList[index]
	            local item = list:getItemFromCache(itemData.resultType)
	            if not item then
	                item = QUIWidgetQlistviewItem.new()
	                isCacheNode = false
	            end
	           	self:setItemInfo(item, itemData)
	           	info.tag = itemData.resultType
	            info.item = item
	            info.size = CCSizeMake(self._cellSize.width,self._cellSize.height)
	            if itemData.resultType == "AWARD_TYPE" then
	            	list:registerItemBoxPrompt(index, 1, item._itemNode)
	            end
	            -- list:registerBtnHandler(index,"btnChooseServer", "_onTriggerChoose" )
	            return isCacheNode
	        end,
	        multiItems = self._multiItems,
	        spaceX = self._spaceX,
	        spaceY = self._spaceY,
	        -- enableShadow = false,
	        totalNumber = #self._data.divineResultList
 		}
 		self._itemList = QListView.new(self._ccbOwner.listView, cfg)  	
 		self._itemList:setShieldTouch(true)

	 	local handler = scheduler.performWithDelayGlobal(function()
	            app.sound:playSound("common_bright")
	        end, 0.5)
		table.insert(self._handlers, handler)
		local handler = scheduler.performWithDelayGlobal(function (  )
			-- body
			self.isInAnimation = nil
			self._playAction = true
			self:playEffect()
		end,2.6)	
		table.insert(self._handlers, handler)
	end 

end

function QUIDialogDivinationAchievecard:viewWillDisappear()
	QUIDialogDivinationAchievecard.super.viewWillDisappear(self)
	for _,handler in ipairs(self._handlers) do
		scheduler.unscheduleGlobal(handler)
	end
	self._handlers = {}
end

function QUIDialogDivinationAchievecard:viewAnimationOutHandler()
	app:getNavigationManager():popViewController(app.middleLayer, QNavigationController.POP_TOP_CONTROLLER)
	--代码
end

--describe：viewAnimationInHandler 
--function QUIDialogDivinationAchievecard:viewAnimationInHandler()
	----代码
--end

--describe：点击Dialog外  事件处理 
function QUIDialogDivinationAchievecard:_backClickHandler()
	--代码
	if self._playAction  then
		self._itemList:setShieldTouch(nil)
		self._itemList:stopScrollToPosScheduler(true)
		self._ccbOwner.tempItemNode:removeAllChildrenWithCleanup(true)
		self._curActionItem = nil
		self._playAction = nil
		self._ccbOwner.touchScreenLabel:setString("点击屏幕退出")
		for k, v in pairs(self._data.divineResultList) do
			v.isVisible = true
		end
		self._itemList:refreshData()
		return 
	end
	if not self.isInAnimation then
		self:close()
		remote.activityRounds:dispatchEvent({name = remote.activityRounds.DIVINATION_UPDATE, data = self._data})
	end
end

return QUIDialogDivinationAchievecard
