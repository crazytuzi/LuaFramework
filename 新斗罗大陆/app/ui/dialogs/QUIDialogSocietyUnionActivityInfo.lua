--
-- Author: Kumo.Wang
-- 宗門活躍詳細
--
local QUIDialog = import(".QUIDialog")
local QUIDialogSocietyUnionActivityInfo = class("QUIDialogSocietyUnionActivityInfo", QUIDialog)

local QNavigationController = import("...controllers.QNavigationController")
local QNotificationCenter = import("...controllers.QNotificationCenter")
local QUIViewController = import("..QUIViewController")
local QListView = import("...views.QListView")
local QStaticDatabase = import("...controllers.QStaticDatabase")

local QUIWidgetSocietyUnionActivityInfoCell = import("..widgets.QUIWidgetSocietyUnionActivityInfoCell")

function QUIDialogSocietyUnionActivityInfo:ctor(options)
	local ccbFile = "Dialog_Society_Activity_Info.ccbi"
	local callBacks = {}
	QUIDialogSocietyUnionActivityInfo.super.ctor(self,ccbFile,callBacks,options)
	self.isAnimation = true

	self._dataList = {}
	if options then
		self._dataList = options.data or {}
		self._userName = options.userName
	end

	self:_initListView()
end

function QUIDialogSocietyUnionActivityInfo:viewDidAppear()
	QUIDialogSocietyUnionActivityInfo.super.viewDidAppear(self)

	self:_init()
end

function QUIDialogSocietyUnionActivityInfo:viewWillDisappear()
	QUIDialogSocietyUnionActivityInfo.super.viewWillDisappear(self)
    
end

function QUIDialogSocietyUnionActivityInfo:_init()
	self._ccbOwner.tf_name:setString(self._userName or "")
	
	local config = QStaticDatabase.sharedDatabase():getStaticByName("sociaty_active")
	
	for _, value in pairs(config) do
		local isExist = false
		for _, data in ipairs(self._dataList) do
			if data.funcId == value.func_id then
				isExist = true
				data.name = value.name
			end
		end
		if not isExist then
			table.insert(self._dataList, {funcId = value.func_id, name = value.name, activeDegree = 0})
		end
	end

	table.sort(self._dataList, function(a, b)
			return a.funcId < b.funcId
		end)

	self:_initListView()
end

function QUIDialogSocietyUnionActivityInfo:_initListView( )
	if not self._listView then
	  	local cfg = {
	        renderItemCallBack = function( list, index, info )
	            local isCacheNode = true
	            local item = list:getItemFromCache()
	            local data = self._dataList[index]
	            if not item then  
	            	item = QUIWidgetSocietyUnionActivityInfoCell.new()      
	                isCacheNode = false
	            end
				item:setInfo(data, index)	
				info.item = item
				info.size = item:getContentSize()

	            return isCacheNode
	        end,
	     	isVertical = true,
	     	autoCenter = true,
	     	enableShadow = false,
	        totalNumber = #self._dataList,
		}  
		self._listView = QListView.new(self._ccbOwner.listView, cfg)
    else
    	self._listView:reload({totalNumber = #self._dataList})
    end
end

function QUIDialogSocietyUnionActivityInfo:close( )
	app.sound:playSound("common_cancel")
	self:playEffectOut()
end

function QUIDialogSocietyUnionActivityInfo:viewAnimationOutHandler()
    app:getNavigationManager():popViewController(app.middleLayer, QNavigationController.POP_TOP_CONTROLLER)
end

function QUIDialogSocietyUnionActivityInfo:_backClickHandler()
    self:close()
end

return QUIDialogSocietyUnionActivityInfo
