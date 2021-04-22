-- @Author: liaoxianbo
-- @Date:   2020-06-11 15:53:39
-- @Last Modified by:   liaoxianbo
-- @Last Modified time: 2020-06-19 12:06:25
local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetChatFaceCell = class("QUIWidgetChatFaceCell", QUIWidget)

local QNavigationController = import("...controllers.QNavigationController")
local QUIViewController = import("..QUIViewController")

QUIWidgetChatFaceCell.FACE_EVENT_CLICK = "FACE_EVENT_CLICK"

function QUIWidgetChatFaceCell:ctor(options)
	local ccbFile = "ccb/Widget_ChatFace_cell.ccbi"
    local callBacks = {
		{ccbCallbackName = "onFaceClick", callback = handler(self, self._onFaceClick)},
    }
    QUIWidgetChatFaceCell.super.ctor(self, ccbFile, callBacks, options)
  
	cc.GameObject.extend(self)
	self:addComponent("components.behavior.EventProtocol"):exportMethods()

end

function QUIWidgetChatFaceCell:onEnter()
end

function QUIWidgetChatFaceCell:onExit()
end

function QUIWidgetChatFaceCell:setFaceInfo(index,faceInfo)
	self._index = index
	self._faceInfo = faceInfo
	QSetDisplayFrameByPath(self._ccbOwner.sp_face,faceInfo)
end
function QUIWidgetChatFaceCell:_onFaceClick()
	self:dispatchEvent({name = QUIWidgetChatFaceCell.FACE_EVENT_CLICK, index = self._index})
end

function QUIWidgetChatFaceCell:getContentSize()
	return self._ccbOwner.node_size:getContentSize()
end

return QUIWidgetChatFaceCell
