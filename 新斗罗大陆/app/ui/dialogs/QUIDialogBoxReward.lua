--[[	
	文件名称：QUIDialogBoxReward.lua
	创建时间：2016-07-27 15:10:38
	作者：nieming
	描述：QUIDialogBoxReward
]]

local QUIDialog = import(".QUIDialog")
local QUIDialogBoxReward = class("QUIDialogBoxReward", QUIDialog)
local QNavigationController = import("...controllers.QNavigationController")
local QRichText = import("...utils.QRichText")
local QListView = import("...views.QListView")
local QUIWidgetQlistviewItem = import("..widgets.QUIWidgetQlistviewItem")
local QUIWidgetItemsBox = import("..widgets.QUIWidgetItemsBox")

--初始化
function QUIDialogBoxReward:ctor(options)
	local ccbFile = "Dialog_Box_Reward.ccbi"
	local callBacks = {
		{ccbCallbackName = "onTriggerConfirm", callback = handler(self, QUIDialogBoxReward._onTriggerConfirm)},
	
	}
	QUIDialogBoxReward.super.ctor(self,ccbFile,callBacks,options)
	--代码
	if not options then
		options = {}
	end
	self.isAnimation = true
    q.setButtonEnableShadow(self._ccbOwner.btn_ok)

	self._title = options.title or "宝箱奖励"
	self._richTextConfig = options.richTextConfig or {}

	self._awards = options.awards or {}

	self._ccbOwner.frame_tf_title:setString(self._title)

	self._richtext = QRichText.new(self._richTextConfig, 500,{ autoCenter = true })
	self._ccbOwner.richText:addChild(self._richtext)

	self:initListView()

end

--describe：
function QUIDialogBoxReward:_onTriggerConfirm()
	--代码
	app.sound:playSound("common_cancel")
	self:close()
end


function QUIDialogBoxReward:initListView( )
	-- body
	if not self._listView then
		-- printTable(self._awards)
	  	local cfg = {
	        renderItemCallBack = function( list, index, info )
	            -- body
	            local isCacheNode = true
	            local item = list:getItemFromCache()
	            local data = self._awards[index]
	            if not item then  
	            	item = QUIWidgetQlistviewItem.new()      
	                isCacheNode = false
	            end
				self:setItemInfo(item,data,index)	
				info.item = item
				info.size = item._ccbOwner.parentNode:getContentSize()

				list:registerItemBoxPrompt(index, 1, item._itemBox)

	            return isCacheNode
	        end,
	     	isVertical = false,
	     	autoCenter = true,
	     	autoCenterOffset = -5,
	     	enableShadow = false,
	     	spaceX = 10,
	        totalNumber = #self._awards,
		}  
		self._listView = QListView.new(self._ccbOwner.listViewLayout,cfg)
    else
    	self._listView:reload({totalNumber = #self._awards})
    end
end


function QUIDialogBoxReward:setItemInfo( item, data, index )
	-- body
	if not item._itemBox then
		item._itemBox = QUIWidgetItemsBox.new()
		-- item._itemBox:setScale(0.8)
		item._itemBox:setPosition(ccp(50,57))
		item._ccbOwner.parentNode:addChild(item._itemBox)
		item._ccbOwner.parentNode:setContentSize(CCSizeMake(100,110))
	end
	local id = data.id 
	local count = tonumber(data.count)
	local itemType = remote.items:getItemType(id)
	if itemType ~= nil and itemType ~= ITEM_TYPE.ITEM then
		item._itemBox:setGoodsInfo(id, itemType, count)
	else
		item._itemBox:setGoodsInfo(tonumber(id), ITEM_TYPE.ITEM, count)
	end

end

--describe：关闭对话框
function QUIDialogBoxReward:close( )
	self:playEffectOut()
end

--describe：viewAnimationOutHandler 
function QUIDialogBoxReward:viewAnimationOutHandler()
	--代码
end

function QUIDialogBoxReward:viewDidAppear()
	QUIDialogBoxReward.super.viewDidAppear(self)
	--代码
end

function QUIDialogBoxReward:viewWillDisappear()
	QUIDialogBoxReward.super.viewWillDisappear(self)
	--代码
end

function QUIDialogBoxReward:viewAnimationOutHandler()
	app:getNavigationManager():popViewController(app.middleLayer, QNavigationController.POP_TOP_CONTROLLER)
	--代码

end

--describe：viewAnimationInHandler 
--function QUIDialogBoxReward:viewAnimationInHandler()
	----代码
--end

--describe：点击Dialog外  事件处理 
function QUIDialogBoxReward:_backClickHandler()
	--代码
	app.sound:playSound("common_cancel")
	self:close()
end

return QUIDialogBoxReward
