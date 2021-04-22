-- @Author: xurui
-- @Date:   2019-09-06 10:44:07
-- @Last Modified by:   liaoxianbo
-- @Last Modified time: 2020-02-24 15:35:59
local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogUserProtocol = class("QUIDialogUserProtocol", QUIDialog)

local QNavigationController = import("...controllers.QNavigationController")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QUIViewController = import("..QUIViewController")

local QListView = import("...views.QListView")
local QUIWidgetHelpDescribe = import("..widgets.QUIWidgetHelpDescribe")
local QUIWidgetBaseHelpTitle = import("..widgets.QUIWidgetBaseHelpTitle")
local QUIWidgetBaseHelpAward = import("..widgets.QUIWidgetBaseHelpAward")
local QUIWidgetQlistviewItem = import("..widgets.QUIWidgetQlistviewItem")
local QUIWidgetBaseHelpLine = import("..widgets.QUIWidgetBaseHelpLine")

function QUIDialogUserProtocol:ctor(options)
	local ccbFile = "ccb/Dialog_Yonghuxieyi.ccbi"
    local callBacks = {
		{ccbCallbackName = "onTriggerClose", callback = handler(self, self._onTriggerClose)},
    }
    QUIDialogUserProtocol.super.ctor(self, ccbFile, callBacks, options)

	cc.GameObject.extend(self)
	self:addComponent("components.behavior.EventProtocol"):exportMethods()

	q.setButtonEnableShadow(self._ccbOwner.btn_know)
	
    if options then
    	self._callBack = options.callBack
    end
end

function QUIDialogUserProtocol:viewDidAppear()
	QUIDialogUserProtocol.super.viewDidAppear(self)

	self:initData()
end

function QUIDialogUserProtocol:viewWillDisappear()
  	QUIDialogUserProtocol.super.viewWillDisappear(self)
end

function QUIDialogUserProtocol:initData()
	local data = {}
	self._data = data
	table.insert(data, {oType = "describe", info = {
			helpType = "user_agreement",widthLimit = 865
		}})

	self:initListView()
end

function QUIDialogUserProtocol:initListView( ... )
	-- body
	if not self._listViewLayout then
		local cfg = {
			renderItemCallBack = function( list, index, info )
	            -- body
	            local isCacheNode = true
	            local itemData = self._data[index]
	            local item = list:getItemFromCache(itemData.oType)
	            if not item then
	            	if itemData.oType == "describe" then
	            		item = QUIWidgetHelpDescribe.new()
	            	elseif itemData.oType == "title" then
	            		item = QUIWidgetBaseHelpTitle.new()
	            	elseif itemData.oType == "award" then
	            		item = QUIWidgetBaseHelpAward.new()
	            	elseif itemData.oType == "line" then
	            		item = QUIWidgetBaseHelpLine.new()
	            	elseif itemData.oType == "empty" then
	            		item = QUIWidgetQlistviewItem.new()
	            	end
	            	isCacheNode = false
	            end
	            if itemData.oType == "empty" then
	            	item:setContentSize(CCSizeMake(0, itemData.height))
	            elseif itemData.oType == "describe" then
	            	item:setInfo(itemData.info or {}, itemData.customStr)
	            else
	            	item:setInfo(itemData.info)
	            end
	           
	            info.item = item
	            info.size = item:getContentSize()
	            return isCacheNode
	        end,
	        curOriginOffset = 15,
	        enableShadow = false,
	      	ignoreCanDrag = true,
	        totalNumber = #self._data,
		}
		self._listViewLayout = QListView.new(self._ccbOwner.desc_sheet_layout,cfg)
	else

		self._listViewLayout:reload({#self._data})
	end
end

function QUIDialogUserProtocol:_onTriggerClose()
  	app.sound:playSound("common_close")
	self:popSelf()
end

return QUIDialogUserProtocol