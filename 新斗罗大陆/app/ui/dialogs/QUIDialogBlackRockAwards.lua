local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogBlackRockAwards = class("QUIDialogBlackRockAwards", QUIDialog)
local QUIWidgetBlackRockAwards = import("..widgets.blackrock.QUIWidgetBlackRockAwards")
local QListView = import("...views.QListView")

function QUIDialogBlackRockAwards:ctor(options)
	local ccbFile = "ccb/Dialog_Black_mountain_sanxing.ccbi"
	local callBacks = {
        {ccbCallbackName = "onTriggerClose", callback = handler(self, self._onTriggerClose)},
	}
	QUIDialogBlackRockAwards.super.ctor(self,ccbFile,callBacks,options)
	self.isAnimation = true

	self._list = {1,2,3,4,5,6}
	self:initListView()
end

function QUIDialogBlackRockAwards:initListView( ... )
	-- body
	if not self._listViewLayout then
		local cfg = {
			renderItemCallBack = handler(self, self.renderItemHandler),
	        enableShadow = false,
	      	ignoreCanDrag = true,
	        totalNumber = #self._list,
	        spaceY = 10,
	        curOriginOffset = 10,
	        curOffset = 10,
		}
		self._listViewLayout = QListView.new(self._ccbOwner.sheet_layout,cfg)
	else

		self._listViewLayout:reload({#self._list})
	end
end

function QUIDialogBlackRockAwards:renderItemHandler(list, index, info )
    local isCacheNode = true
    local itemData = self._list[index]

    local item = list:getItemFromCache()
    if not item then
    	item = QUIWidgetBlackRockAwards.new()
        isCacheNode = false
    end

    item:setInfo(itemData)
    info.item = item
    info.size = item:getContentSize()

    -- list:registerBtnHandler(index, list, handler(self, self.clickHandler))

    return isCacheNode
end

function QUIDialogBlackRockAwards:clickHandler(x, y, touchNode, listView )
	-- body
	app.sound:playSound("common_switch")
    local touchIndex = listView:getCurTouchIndex()
    print(touchIndex)
end

function QUIDialogBlackRockAwards:_onTriggerClose()
	-- body
	self:playEffectOut()
end

return QUIDialogBlackRockAwards