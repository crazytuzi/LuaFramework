--
-- 老玩家回归（老服）
-- Kumo.Wang
--

local QPlayerRecallAwardUtil = class("QPlayerRecallAwardUtil")

local QUIViewController = import("..ui.QUIViewController")
local QVIPUtil = import(".QVIPUtil")
local QStaticDatabase = import("..controllers.QStaticDatabase")
local QQuickWay = import("..utils.QQuickWay")
local QListView = import("..views.QListView")
local QUIWidgetPlayerRecallAwardCell = import("..ui.widgets.QUIWidgetPlayerRecallAwardCell")

function QPlayerRecallAwardUtil:ctor(options)
	self._data = remote.playerRecall:getAwardConfigList()
end

function QPlayerRecallAwardUtil:setView(contentNode)
	self._contentNode = contentNode
	self:_initListView()
end

function QPlayerRecallAwardUtil:removeListView()
	if self._listView then
        self._listView:clear()
        self._listView:unscheduleUpdate()
        self._listView = nil
    end
end

function QPlayerRecallAwardUtil:update()
	self:_initListView()
end

function QPlayerRecallAwardUtil:_initListView()
	if self._listView == nil then
		local cfg = {
			renderItemCallBack = handler(self, self._renderItemCallBack),
			isVertical = false,
	     	ignoreCanDrag = false,
	        spaceX = 0,
	        totalNumber = #self._data
		}
		self._listView = QListView.new(self._contentNode, cfg)
	else
		self._listView:reload({totalNumber = #self._data})
	end
end

function QPlayerRecallAwardUtil:_renderItemCallBack(list, index, info)
    local isCacheNode = true
  	local data = self._data[index]
    local item = list:getItemFromCache()
    if not item then	       	
    	item = QUIWidgetPlayerRecallAwardCell.new()
        isCacheNode = false
    end
    item:setInfo(data)
    info.item = item
    info.size = item:getContentSize()
	list:registerTouchHandler(index, "onTouchListView")
    list:registerClickHandler(index, "self", function()
     		return true
     	end, nil, handler(self, self._onClickItem))

    return isCacheNode
end

function QPlayerRecallAwardUtil:_onClickItem( x, y, touchNodeNode, list )
	local index = list:getCurTouchIndex()
	print("index = ", index)
	local info = self._data[index]

	local playerRecallInfo = remote.playerRecall:getInfo()
	local curTaskInfo = playerRecallInfo[tostring(info.id)]
	local isReady = info.day <= playerRecallInfo.login_days
	local isComplete = info.complete_count <= (curTaskInfo and curTaskInfo.awardCount or 0)

	if isReady and not isComplete then
		remote.playerRecall:playerComeBackCompleteRequest(info.type, info.id)
	end
end

return QPlayerRecallAwardUtil
