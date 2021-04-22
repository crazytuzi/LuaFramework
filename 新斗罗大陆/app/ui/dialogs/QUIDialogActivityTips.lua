--
-- Author: wkwang
-- Date: 2014-12-10 15:08:20
--
local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogActivityTips = class("QUIDialogActivityTips", QUIDialog)

local QStaticDatabase = import("...controllers.QStaticDatabase")
local QUIWidgetItemsBox = import("..widgets.QUIWidgetItemsBox")
local QNavigationController = import("...controllers.QNavigationController")

function QUIDialogActivityTips:ctor(options)
 	local ccbFile = "ccb/Dialog_activityTips.ccbi"
    local callBacks = {}
    QUIDialogActivityTips.super.ctor(self, ccbFile, callBacks, options)
    self.isAnimation = true

    self._instanceId = options.instanceId

	local list = remote.activityInstance:getInstanceListById(self._instanceId)
	if #list > 0 then
		self._ccbOwner.node_tips:setVisible(true)
		self._ccbOwner.tf_title:setString(list[1].instance_name)
		self._ccbOwner.tf_info:setString(list[1].instance_introduce or "")
		local dropItems = list[1].drop_item or ""
		local dropItems = string.split(dropItems, ";")
		self._items = {}
		for _,id in pairs(dropItems) do
	        self:_setBoxInfo(id,ITEM_TYPE.ITEM,0)
		end
	end
end

function QUIDialogActivityTips:_setBoxInfo(itemID,itemType,num)
	local itemConfig = QStaticDatabase:sharedDatabase():getItemByID(itemID)
	if itemConfig == nil then return end
	local box = QUIWidgetItemsBox.new()
    box:setGoodsInfo(itemID,itemType,num)
    box:setPosition(58 * #self._items, 0)
    box:setScale(0.6)
    -- box:setPromptIsOpen(true)
    self._ccbOwner.node_items:addChild(box)
	table.insert(self._items, box)
end

function QUIDialogActivityTips:_backClickHandler()
    self:close()
end

function QUIDialogActivityTips:close()
	self:playEffectOut()
end

function QUIDialogActivityTips:viewAnimationOutHandler()
	app:getNavigationManager():popViewController(app.middleLayer, QNavigationController.POP_TOP_CONTROLLER)
end

return QUIDialogActivityTips