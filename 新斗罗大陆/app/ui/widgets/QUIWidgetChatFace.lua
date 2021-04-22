-- @Author: liaoxianbo
-- @Date:   2020-06-11 15:53:08
-- @Last Modified by:   liaoxianbo
-- @Last Modified time: 2020-06-19 10:27:40
local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetChatFace = class("QUIWidgetChatFace", QUIWidget)

local QNavigationController = import("...controllers.QNavigationController")
local QUIViewController = import("..QUIViewController")
local QListView = import("...views.QListView")
local QUIWidgetChatFaceCell = import("..widgets.QUIWidgetChatFaceCell")

QUIWidgetChatFace.CHOOSE_FACE_EVENT_CLICK = "CHOOSE_FACE_EVENT_CLICK"
function QUIWidgetChatFace:ctor(options)
	local ccbFile = "ccb/Widget_ChatFace.ccbi"
    local callBacks = {
		{ccbCallbackName = "onTriggerClose", callback = handler(self, self._onTriggerClose)},
    }
    QUIWidgetChatFace.super.ctor(self, ccbFile, callBacks, options)
  
	cc.GameObject.extend(self)
	self:addComponent("components.behavior.EventProtocol"):exportMethods()

	self._facedata = QResPath("chat_face_path")
	-- self:initListView()
	-- self._startPosX = 40
	-- self._startPosY = -40
	-- self._spaceX = 65
	-- self._spaceY = 65
	self._ccbOwner.node_face:removeAllChildren()
	-- self:addFaceToNde()
end

function QUIWidgetChatFace:onEnter()
	self:initListView()
end

function QUIWidgetChatFace:addFaceToNde()
	for index,facePath in pairs(self._facedata) do
		local item = QUIWidgetChatFaceCell.new()
		item:addEventListener(QUIWidgetChatFaceCell.FACE_EVENT_CLICK, handler(self, self._clickFace))
		item:setFaceInfo(index,facePath)
		self._ccbOwner.node_face:addChild(item)

		item:setPosition(ccp(self._startPosX+self._spaceX*((index-1)%6),self._startPosY-self._spaceY*math.floor((index-1)/6)))
	end
end

function QUIWidgetChatFace:initListView()
	self._multiItems = 6
	if not self._listView then
		local cfg = {
			renderItemCallBack = handler(self, self._renderItemFunc),
	        isVertical = true,
	        multiItems = self._multiItems,
	        spaceX = 15,
	        spaceY = 15,
	        enableShadow = false,
	      	ignoreCanDrag = false,  
	        totalNumber = #self._facedata,
		}
		self._listView = QListView.new(self._ccbOwner.sheet_layout, cfg)
	else
		self._listView:reload({totalNumber = #self._facedata})
	end
end

function QUIWidgetChatFace:_renderItemFunc( list, index, info )
    local isCacheNode = true
    local itemData = self._facedata[index]
    local item = list:getItemFromCache()
    if not item then
		item = QUIWidgetChatFaceCell.new()
    	item:addEventListener(QUIWidgetChatFaceCell.FACE_EVENT_CLICK, handler(self, self._clickFace))
    	isCacheNode = false
    end
    item:setFaceInfo(index,itemData)
    info.item = item
    info.size = item:getContentSize()
   
    list:registerBtnHandler(index, "btn_face", "_onFaceClick") 

    return isCacheNode
end

function QUIWidgetChatFace:_clickFace(event)
	self:dispatchEvent({name = QUIWidgetChatFace.CHOOSE_FACE_EVENT_CLICK, index = event.index})
end

function QUIWidgetChatFace:onExit()
end

function QUIWidgetChatFace:getContentSize()
end

return QUIWidgetChatFace
