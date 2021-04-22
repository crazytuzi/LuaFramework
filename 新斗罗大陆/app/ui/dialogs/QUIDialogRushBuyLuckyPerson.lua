--[[	
	文件名称：QUIDialogRushBuyLuckyPerson.lua
	创建时间：2017-02-15 11:13:43
	作者：nieming
	描述：QUIDialogRushBuyLuckyPerson
]]

local QUIDialog = import(".QUIDialog")
local QUIDialogRushBuyLuckyPerson = class("QUIDialogRushBuyLuckyPerson", QUIDialog)
local QNavigationController = import("...controllers.QNavigationController")
local QListView = import("...views.QListView")
local QUIWidgetRushBuyLuckyPerson = import("..widgets.QUIWidgetRushBuyLuckyPerson")
--初始化
function QUIDialogRushBuyLuckyPerson:ctor(options)
	local ccbFile = "Dialog_SixYuan_list.ccbi"
	local callBacks = {
		{ccbCallbackName = "onTriggerClose", callback = handler(self, QUIDialogRushBuyLuckyPerson._onTriggerClose)},
	}
	QUIDialogRushBuyLuckyPerson.super.ctor(self,ccbFile,callBacks,options)

	self.isAnimation = true
	if not options then
		options = {}
	end
	self._data = options.data or {}

	self._ccbOwner.empty:setVisible(#self._data == 0)
	if options.title then
		self._ccbOwner.title:setString(options.title)
	end
end

--describe：
function QUIDialogRushBuyLuckyPerson:_onTriggerClose()
	--代码
	self:close()
end

--describe：关闭对话框
function QUIDialogRushBuyLuckyPerson:close( )
	app.sound:playSound("common_cancel")
	self:playEffectOut()
end

function QUIDialogRushBuyLuckyPerson:viewDidAppear()
	QUIDialogRushBuyLuckyPerson.super.viewDidAppear(self)
	--代码
end

function QUIDialogRushBuyLuckyPerson:viewWillDisappear()
	QUIDialogRushBuyLuckyPerson.super.viewWillDisappear(self)
	--代码
end

function QUIDialogRushBuyLuckyPerson:viewAnimationOutHandler()
	app:getNavigationManager():popViewController(app.middleLayer, QNavigationController.POP_TOP_CONTROLLER)
	--代码
end

function QUIDialogRushBuyLuckyPerson:initListView( ... )
	-- body
	if not self._myRecordListView then
		local cfg = {
	        renderItemCallBack = function( list, index, info )
	            -- body
	            local isCacheNode = true
	            local itemData = self._data[index]
	            local item = list:getItemFromCache()
	            if not item then
	                item = QUIWidgetRushBuyLuckyPerson.new()
	                isCacheNode = false
	            end
	           	item:setInfo(itemData)
	            info.item = item
	            info.size = item:getContentSize()

	            list:registerItemBoxPrompt(index, 1, item._itembox)
	            return isCacheNode
	        end,
	        topShadow = self._ccbOwner.topShadow,
	        bottomShadow = self._ccbOwner.bottomShadow,
	        -- multiItems = 5,
	        -- spaceX = 15,
	        spaceY = 6,
	        -- enableShadow = false,
	        totalNumber = #self._data or 0
 		}
 		self._myRecordListView = QListView.new(self._ccbOwner.listViewLayout, cfg)  	
	else
		self._myRecordListView:reload({totalNumber = #self._data})
	end
end
--describe：viewAnimationInHandler 
function QUIDialogRushBuyLuckyPerson:viewAnimationInHandler()
	--代码
	if #self._data == 0 then
		return
	end
	self:initListView()
end

--describe：点击Dialog外  事件处理 
function QUIDialogRushBuyLuckyPerson:_backClickHandler()
	--代码
	self:close()
end

return QUIDialogRushBuyLuckyPerson
