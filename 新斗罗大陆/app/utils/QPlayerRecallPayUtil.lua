--
-- 老玩家回归（老服）
-- Kumo.Wang
--

local QPlayerRecallPayUtil = class("QPlayerRecallPayUtil")

local QUIViewController = import("..ui.QUIViewController")
local QVIPUtil = import(".QVIPUtil")
local QStaticDatabase = import("..controllers.QStaticDatabase")
local QQuickWay = import("..utils.QQuickWay")
local QListView = import("..views.QListView")
local QUIWidgetPlayerRecallPayCell = import("..ui.widgets.QUIWidgetPlayerRecallPayCell")

function QPlayerRecallPayUtil:ctor(options)
	self._data = remote.playerRecall:getPayConfigList()
	remote.playerRecall.donotShowPayRedTip = true
end

function QPlayerRecallPayUtil:setView(contentNode)
	QPrintTable(self._data)
	self._contentNode = contentNode
	self:_initListView()
end

function QPlayerRecallPayUtil:removeListView()
	if self._listView then
        self._listView:clear()
        self._listView:unscheduleUpdate()
        self._listView = nil
    end
end

function QPlayerRecallPayUtil:update()
	self._data = remote.playerRecall:getPayConfigList()
	self:_initListView()
end

function QPlayerRecallPayUtil:_initListView()
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

function QPlayerRecallPayUtil:_renderItemCallBack(list, index, info)
    local isCacheNode = true
  	local data = self._data[index]
    local item = list:getItemFromCache()
    if not item then	       	
    	item = QUIWidgetPlayerRecallPayCell.new()
        isCacheNode = false
    end
    item:setInfo(data)
    info.item = item
    info.size = item:getContentSize()
	list:registerTouchHandler(index, "onTouchListView")
    list:registerBtnHandler(index, "btn_ok", "onTriggerOK")
    list:registerBtnHandler(index, "btn_prompt", "onTriggerPrompt")

    return isCacheNode
end

return QPlayerRecallPayUtil
