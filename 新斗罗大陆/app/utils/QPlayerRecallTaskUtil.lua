--
-- 老玩家回归（老服）
-- Kumo.Wang
--

local QPlayerRecallTaskUtil = class("QPlayerRecallTaskUtil")

local QUIViewController = import("..ui.QUIViewController")
local QVIPUtil = import(".QVIPUtil")
local QStaticDatabase = import("..controllers.QStaticDatabase")
local QQuickWay = import("..utils.QQuickWay")
local QListView = import("..views.QListView")
local QUIWidgetPlayerRecallTaskCell = import("..ui.widgets.QUIWidgetPlayerRecallTaskCell")

function QPlayerRecallTaskUtil:ctor(options)
	self._data = remote.playerRecall:getTaskConfigList()
end

function QPlayerRecallTaskUtil:setView(contentNode)
	-- QPrintTable(self._data)
	self._contentNode = contentNode
	self:_initListView()
end

function QPlayerRecallTaskUtil:removeListView()
	if self._listView then
        self._listView:clear()
        self._listView:unscheduleUpdate()
        self._listView = nil
    end
end

function QPlayerRecallTaskUtil:update()
	self._data = remote.playerRecall:getTaskConfigList()
	self:_initListView()
end

function QPlayerRecallTaskUtil:_initListView()
	if self._listView == nil then
		local cfg = {
			renderItemCallBack = handler(self, self._renderItemCallBack),
			isVertical = true,
	     	ignoreCanDrag = true,
	        spaceY = 0,
	        totalNumber = #self._data
		}
		self._listView = QListView.new(self._contentNode, cfg)
	else
		self._listView:reload({totalNumber = #self._data})
	end
end

function QPlayerRecallTaskUtil:_renderItemCallBack(list, index, info)
    local isCacheNode = true
  	local data = self._data[index]
    local item = list:getItemFromCache()
    if not item then	       	
    	item = QUIWidgetPlayerRecallTaskCell.new()
        isCacheNode = false
    end
    item:setInfo(data)
    info.item = item
    info.size = item:getContentSize()
	list:registerTouchHandler(index, "onTouchListView")
    list:registerBtnHandler(index, "btn_ok", "onTriggerOK")
    list:registerBtnHandler(index, "btn_go", "onTriggerGo")
    
    return isCacheNode
end

return QPlayerRecallTaskUtil
