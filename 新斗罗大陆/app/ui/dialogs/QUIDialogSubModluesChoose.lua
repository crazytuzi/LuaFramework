-- 
-- Kumo.Wang
-- 功能模块——子模块选择界面
--

local QUIDialog = import(".QUIDialog")
local QUIDialogSubModluesChoose = class("QUIDialogSubModluesChoose", QUIDialog)

local QUIViewController = import("..QUIViewController")
local QListView = import("...views.QListView")

function QUIDialogSubModluesChoose:ctor(options)
	local ccbFile = "Dialog_SubModules_Choose.ccbi"
	local callBacks = {}
	QUIDialogSubModluesChoose.super.ctor(self,ccbFile,callBacks,options)

    CalculateUIBgSize(self._ccbOwner.node_bg, 1280)
    CalculateUIBgSize(self._ccbOwner.node_effect, 1280)
    
	local page = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
	if page.setAllUIVisible then page:setAllUIVisible(false) end
    if page.setScalingVisible then page:setScalingVisible(false) end

    self._ccbOwner.sheet_layout:setContentSize(CCSize(display.width, 600))

	self:init()
end

function QUIDialogSubModluesChoose:viewDidAppear()
	QUIDialogSubModluesChoose.super.viewDidAppear(self)
	self:addBackEvent(false)
end

function QUIDialogSubModluesChoose:viewWillDisappear()
	QUIDialogSubModluesChoose.super.viewWillDisappear(self)
	self:removeBackEvent()
end

function QUIDialogSubModluesChoose:init()
	self.data = {}

	self:initListView()
end

function QUIDialogSubModluesChoose:initListView()
	if not self._listViewLayout then
		local cfg = {
			renderItemCallBack = handler(self, self._renderItemHandler),
			isVertical = false,
	      	ignoreCanDrag = false,
	      	autoCenter = true,
	        totalNumber = #self.data,
	        scrollDelegate = handler(self, self._scrollDelegateHandler),
		}
		self._listViewLayout = QListView.new(self._ccbOwner.sheet_layout,cfg)
	else
		self._listViewLayout:reload({#self.data})
	end
end

function QUIDialogSubModluesChoose:_scrollDelegateHandler(x, y)
	-- print("[QListView scrollDelegate] ", x, y)
end

function QUIDialogSubModluesChoose:_renderItemHandler(list, index, info )
    local isCacheNode = true
    local itemData = self.data[index]

    local item = list:getItemFromCache()
    if not item then
    	local itemClassName = itemData.itemClassName
    	if itemClassName then
	    	local itemClass = import(app.packageRoot .. ".ui.widgets." .. itemClassName)
	    	item = itemClass.new()
	    end
        isCacheNode = false
    end

    item:setInfo(itemData)
    info.item = item
    info.size = item:getContentSize()

    local btnImg = item:getBtnImg()
 	list:registerBtnHandler(index, "btn_click", handler(self, self._onTriggerClick), nil, true, btnImg)

    return isCacheNode
end

function QUIDialogSubModluesChoose:_onTriggerClick( x, y, touchNode, listView )
	print("QUIDialogSubModluesChoose:_onTriggerClick() ")
    app.sound:playSound("common_small")
	local touchIndex = listView:getCurTouchIndex()
    local item = listView:getItemByIndex(touchIndex)
    if item and item.getInfo then
    	self:chooseModule(item:getInfo())
    end
end

-- 自行实现
function QUIDialogSubModluesChoose:chooseModule(info)
end

function QUIDialogSubModluesChoose:getListViewLayout()
	return self._listViewLayout
end

return QUIDialogSubModluesChoose
