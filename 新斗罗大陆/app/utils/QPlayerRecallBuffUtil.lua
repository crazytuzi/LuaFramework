--
-- 老玩家回归（老服）
-- Kumo.Wang
--

local QPlayerRecallBuffUtil = class("QPlayerRecallBuffUtil")

local QUIViewController = import("..ui.QUIViewController")
local QVIPUtil = import(".QVIPUtil")
local QStaticDatabase = import("..controllers.QStaticDatabase")
local QQuickWay = import("..utils.QQuickWay")
local QListView = import("..views.QListView")
local QUIWidgetPlayerRecallBuffCell = import("..ui.widgets.QUIWidgetPlayerRecallBuffCell")

function QPlayerRecallBuffUtil:ctor(options)
	self._data = remote.playerRecall:getBuffConfigList()
end

function QPlayerRecallBuffUtil:setView(contentNode)
	self._contentNode = contentNode
	self:_initListView()
end

function QPlayerRecallBuffUtil:removeListView()
	if self._listView then
        self._listView:clear()
        self._listView:unscheduleUpdate()
        self._listView = nil
    end
end

function QPlayerRecallBuffUtil:_initListView()
	if self._listView == nil then
		local cfg = {
			renderItemCallBack = handler(self, self._renderItemCallBack),
			isVertical = false,
	     	ignoreCanDrag = true,
	        spaceX = 5,
	        totalNumber = #self._data
		}
		self._listView = QListView.new(self._contentNode, cfg)
	else
		self._listView:reload({totalNumber = #self._data})
	end
end

function QPlayerRecallBuffUtil:_renderItemCallBack(list, index, info)
    local isCacheNode = true
  	local data = self._data[index]
    local item = list:getItemFromCache()
    if not item then	       	
    	item = QUIWidgetPlayerRecallBuffCell.new()
        isCacheNode = false
    end
    item:setInfo(data)
    info.item = item
    info.size = item:getContentSize()
    list:registerBtnHandler(index, "btn_ok", "onTriggerOK")

    return isCacheNode
end

return QPlayerRecallBuffUtil
