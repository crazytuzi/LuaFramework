-- @Author: liaoxianbo
-- @Date:   2019-06-03 10:02:24
-- @Last Modified by:   zhouxiaoshu
-- @Last Modified time: 2019-11-04 10:38:59
local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogShowVipDailyGift = class("QUIDialogShowVipDailyGift", QUIDialog)

local QNavigationController = import("...controllers.QNavigationController")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QUIViewController = import("..QUIViewController")
local QListView = import("...views.QListView")
local QUIWidgetActivityVipDailyGiftYl = import("..widgets.QUIWidgetActivityVipDailyGiftYl")
local QUIWidgetItemsBox = import("..widgets.QUIWidgetItemsBox")

function QUIDialogShowVipDailyGift:ctor(options)
	local ccbFile = "ccb/Dialog_Activity_flyl.ccbi"
    local callBacks = {
		{ccbCallbackName = "onTriggerClose", callback = handler(self, self._onTriggerClose)},
    }
    QUIDialogShowVipDailyGift.super.ctor(self, ccbFile, callBacks, options)
    self.isAnimation = true

	cc.GameObject.extend(self)
	self:addComponent("components.behavior.EventProtocol"):exportMethods()

    if options then
    	self._callBack = options.callBack
    end
    self._listView = nil

    local curentvipLevel = app.vipUtil:VIPLevel()
    local maxVipLevel = app.vipUtil:getMaxLevel()

    local curentVipInfo = db:getVipGiftDailyListByLevel(curentvipLevel)
    local vipgiftList = db:getVipGiftDailyList()
    self._vipWardsInfo = {}
    table.insert(self._vipWardsInfo,curentVipInfo)
    for ii = curentvipLevel+1,maxVipLevel do
    	local vipInfo = db:getVipGiftDailyListByLevel(ii)
    	if vipInfo then
    		table.insert(self._vipWardsInfo,vipInfo)
    	end
    end

    for ii = 0,curentvipLevel-1 do
    	local vipInfo = db:getVipGiftDailyListByLevel(ii)
    	if vipInfo then
    		table.insert(self._vipWardsInfo,vipInfo)
    	end    	
    end

    self:initListView()

end

function QUIDialogShowVipDailyGift:viewDidAppear()
	QUIDialogShowVipDailyGift.super.viewDidAppear(self)
	self._ccbOwner.frame_tf_title:setString("福利预览")
end

function QUIDialogShowVipDailyGift:viewWillDisappear()
  	QUIDialogShowVipDailyGift.super.viewWillDisappear(self)
end

function QUIDialogShowVipDailyGift:initListView()
	if not self._listView then
		local cfg = {
			renderItemCallBack = function( list, index, info )
	            -- body
	            local isCacheNode = true
	            local itemData = self._vipWardsInfo[index]
	            local items = list:getItemFromCache()
	            if not items then
            		items = QUIWidgetActivityVipDailyGiftYl.new()
	            	isCacheNode = false
	            end
	            items:setDataInfo(itemData,self)
	            info.item = items
	            info.size = items:getContentSize()

                items:registerItemBoxPrompt(index, list)
                list:registerTouchHandler(index,"onTouchListView")

	            return isCacheNode
	        end,
	        isChildOfListView = true,
	        isVertical = true,
	        enableShadow = false,
	      	ignoreCanDrag = true,
	        spaceY = -2,
	        contentOffsetX = 6,
	        curOriginOffset = -3,
	        curOffset = 10,
	        totalNumber = #self._vipWardsInfo,
		}
		self._listView = QListView.new(self._ccbOwner.sheet_layout,cfg)
	else
		self._listView:reload({totalNumber = #self._vipWardsInfo})
	end
end

function QUIDialogShowVipDailyGift:getContentListView( )
	return self._listView
end

function QUIDialogShowVipDailyGift:_backClickHandler()
    self:_onTriggerClose()
end

function QUIDialogShowVipDailyGift:_onTriggerClose(event)
    if q.buttonEventShadow(event, self._ccbOwner.btn_close) == false then return end
  	app.sound:playSound("common_close")
	self:playEffectOut()
end

function QUIDialogShowVipDailyGift:viewAnimationOutHandler()
	local callback = self._callBack

	self:popSelf()

	if callback then
		callback()
	end
end

return QUIDialogShowVipDailyGift
