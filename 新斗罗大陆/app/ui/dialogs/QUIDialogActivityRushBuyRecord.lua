--[[	
	文件名称：QUIDialogActivityRushBuyRecord.lua
	创建时间：2017-02-14 17:24:42
	作者：nieming
	描述：QUIDialogActivityRushBuyRecord
]]

local QUIDialog = import(".QUIDialog")
local QUIDialogActivityRushBuyRecord = class("QUIDialogActivityRushBuyRecord", QUIDialog)
local QNavigationController = import("...controllers.QNavigationController")
local QListView = import("...views.QListView")
local QRichText = import("...utils.QRichText")
local QUIWidgetRushBuyNumItem = import("..widgets.QUIWidgetRushBuyNumItem")
local QUIWidgetRushBuyRecord = import("..widgets.QUIWidgetRushBuyRecord")
local QUIWidgetQlistviewItem = import("..widgets.QUIWidgetQlistviewItem")


--初始化
function QUIDialogActivityRushBuyRecord:ctor(options)
	local ccbFile = "Dialog_SixYuan_Buylog.ccbi"
	local callBacks = {
		{ccbCallbackName = "onTriggleMyNumTab", callback = handler(self, QUIDialogActivityRushBuyRecord._onTriggleMyNumTab)},
		{ccbCallbackName = "onTriggleRecordTab", callback = handler(self, QUIDialogActivityRushBuyRecord._onTriggleRecordTab)},
		{ccbCallbackName = "onTriggerClose", callback = handler(self, QUIDialogActivityRushBuyRecord._onTriggerClose)},
	}
	QUIDialogActivityRushBuyRecord.super.ctor(self,ccbFile,callBacks,options)
	--代码
	self.isAnimation = true
	self._curTab = 1
	if not options then
		options = {}
	end
	self._myNums = options.myNums or {}
	self._totalNums = options.totalNums or 0
	self._issue = options.issue or 0
	self:onTab1()
end


function QUIDialogActivityRushBuyRecord:onTab1(  )
	-- body
	self._ccbOwner.myNumsTabLabel:setVisible(true)

	self._ccbOwner.myRecordTabLabel:setVisible(false)

	self._ccbOwner.myRecordTab:setHighlighted(false)
	self._ccbOwner.myNumTab:setHighlighted(true)
	self._ccbOwner.recordTitle:setVisible(false)

	if #self._myNums == 0 then
		self._ccbOwner.emptyRecord:setVisible(true)
	else
		self._ccbOwner.emptyRecord:setVisible(false)
	end

	self._ccbOwner.myNumParentNode:setVisible(true)
	
	if not self._richText then
		self._richText = QRichText.new()
		self._ccbOwner.labelRichText:addChild(self._richText)
	end
	local config = {
		{oType = "font", content = string.format("本期共%s个号码， 您已获取", self._totalNums),size = 22,color = ccc3(255,255,255)},
		{oType = "font", content = #self._myNums,size = 22,color = ccc3(255,255,0)},
		{oType = "font", content = string.format("个"),size = 22,color = ccc3(255,255,255)},
	}
	self._richText:setString(config)

	if self._myNumListView then
		self._myNumListView:setVisible(true)
		self:initMyNumListView()
	end

	if self._myRecordListView then
		self._myRecordListView:setVisible(false)	
	end

end

function QUIDialogActivityRushBuyRecord:onTab2(  )
	-- body
	self._ccbOwner.myNumsTabLabel:setVisible(false)
	self._ccbOwner.myRecordTabLabel:setVisible(true)
	self._ccbOwner.myRecordTab:setHighlighted(true)
	self._ccbOwner.myNumTab:setHighlighted(false)
	self._ccbOwner.recordTitle:setVisible(true)

	if self._myNumListView then
		self._myNumListView:setVisible(false)
	end

	if self._logs then
		if #self._logs == 0 then
			self._ccbOwner.emptyRecord:setVisible(true)
		else
			self._ccbOwner.emptyRecord:setVisible(false)
		end

	else
		self._ccbOwner.emptyRecord:setVisible(false)
	end

	self._ccbOwner.myNumParentNode:setVisible(false)

	if self._myRecordListView then
		self._myRecordListView:setVisible(true)
		self:initMyRecordListView()
	end

end

--describe：
function QUIDialogActivityRushBuyRecord:_onTriggleMyNumTab()
	--代码
	if self._curTab == 1 then
		self._ccbOwner.myNumTab:setHighlighted(true)
		return 
	end
	app.sound:playSound("common_switch")
	self._curTab = 1
	self:onTab1()
end

--describe：
function QUIDialogActivityRushBuyRecord:_onTriggleRecordTab()
	--代码
	if self._curTab == 2 then
		self._ccbOwner.myRecordTab:setHighlighted(true)
		return 
	end
	app.sound:playSound("common_switch")
	self._curTab = 2
	self:onTab2()
	if not self._logs then
		local imp = remote.activityRounds:getRushBuy()
		if imp then
			imp:requestMyLogs(self._issue, function( data )
				self._logs = data
				self:initMyRecordListView()
				self:onTab2()
			end)
		end
	end
end

function QUIDialogActivityRushBuyRecord:initMyNumListView(  )
	-- body
	if not self._myNumListView then
		local cfg = {
	        renderItemCallBack = function( list, index, info )
	            -- body
	            local isCacheNode = true
	            local itemData = self._myNums[index]
	            local item = list:getItemFromCache()
	            if not item then
	                item = QUIWidgetQlistviewItem.new()
	                isCacheNode = false
	            end

	           	self:setItemInfo(item, tonumber(itemData) or 0)


	            info.item = item
	            info.size = CCSizeMake(100,100)
	            return isCacheNode
	        end,
	        multiItems = 5,
	        spaceX = 15,
	        spaceY = 15,
	        enableShadow = false,
	        totalNumber = #self._myNums 
 		}
 		self._myNumListView = QListView.new(self._ccbOwner.shortListView, cfg)  	
	else
		self._myNumListView:reload({totalNumber = #self._myNums})
	end

end

function QUIDialogActivityRushBuyRecord:setItemInfo( item, itemData )
	if not item._itemNode then
		item._itemNode = QUIWidgetRushBuyNumItem.new()
		item._itemNode:setPosition(ccp(100/2,100/2))
		item._ccbOwner.parentNode:addChild(item._itemNode)
		item._ccbOwner.parentNode:setContentSize(CCSizeMake(100,100))
	end
	item._itemNode:setInfo(itemData, true)
end


function QUIDialogActivityRushBuyRecord:initMyRecordListView(  )
	-- body
	if not self._myRecordListView then
		local cfg = {
	        renderItemCallBack = function( list, index, info )
	            -- body
	            local isCacheNode = true
	            local itemData = self._logs[index]
	            local item = list:getItemFromCache()
	            if not item then
	                item = QUIWidgetRushBuyRecord.new()
	                isCacheNode = false
	            end
	           	item:setInfo(itemData, index)
	            info.item = item
	            info.size = item:getContentSize()
	            return isCacheNode
	        end,
	        -- curOriginOffset = 10,
	        -- multiItems = 5,
	        -- spaceX = 15,
	        -- spaceY = 15,
	        enableShadow = false,
	        totalNumber = #self._logs or 0
 		}
 		self._myRecordListView = QListView.new(self._ccbOwner.longListView, cfg)  	
	else
		self._myRecordListView:reload({totalNumber = #self._logs})
	end
end


--describe：
function QUIDialogActivityRushBuyRecord:_onTriggerClose()
	--代码
	self:close()
end

--describe：关闭对话框
function QUIDialogActivityRushBuyRecord:close( )
	app.sound:playSound("common_cancel")
	self:playEffectOut()
end

function QUIDialogActivityRushBuyRecord:viewDidAppear()
	QUIDialogActivityRushBuyRecord.super.viewDidAppear(self)
	--代码
	
end

function QUIDialogActivityRushBuyRecord:viewWillDisappear()
	QUIDialogActivityRushBuyRecord.super.viewWillDisappear(self)
	--代码
end

function QUIDialogActivityRushBuyRecord:viewAnimationOutHandler()
	app:getNavigationManager():popViewController(app.middleLayer, QNavigationController.POP_TOP_CONTROLLER)
	--代码
end

function QUIDialogActivityRushBuyRecord:viewAnimationInHandler()
	--代码
	self:initMyNumListView()
	-- self:getScoreRankData()
end

--describe：viewAnimationInHandler 
--function QUIDialogActivityRushBuyRecord:viewAnimationInHandler()
	----代码
--end

--describe：点击Dialog外  事件处理 
--function QUIDialogActivityRushBuyRecord:_backClickHandler()
	----代码
--end

return QUIDialogActivityRushBuyRecord
