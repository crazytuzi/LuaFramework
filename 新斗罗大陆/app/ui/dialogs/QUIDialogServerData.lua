--
-- Kumo.Wang
-- 资源夺宝最近一次转盘后端数据
--

local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogServerData = class("QUIDialogServerData", QUIDialog)

local QNavigationController = import("...controllers.QNavigationController")
local QUIViewController = import("..QUIViewController")
local QUIGestureRecognizer = import("..QUIGestureRecognizer")

function QUIDialogServerData:ctor(options)
	local ccbFile = "ccb/Dialog_Float_Tips.ccbi"
	local callBack = {}
	QUIDialogServerData.super.ctor(self, ccbFile, callBack, options)

	self.isAnimation = true --是否动画显示

	if options then
		self._data = options.data
	end

    self:_init()
end

function QUIDialogServerData:viewDidAppear()
	QUIDialogServerData.super.viewDidAppear(self)
   
    self._touchLayer = QUIGestureRecognizer.new()
    self._touchLayer:attachToNode(self:getView(), display.width, display.height, -display.width/2, -display.height/2, handler(self, self.onTouchEvent))
    self._touchLayer:enable()
    self._touchLayer:addEventListener(QUIGestureRecognizer.EVENT_SLIDE_GESTURE, handler(self, self.onTouchEvent))
end

function QUIDialogServerData:viewWillDisappear()
	QUIDialogServerData.super.viewWillDisappear(self)
	
	self._touchLayer:removeAllEventListeners()
    self._touchLayer:disable()
    self._touchLayer:detach()
end

function QUIDialogServerData:_init()
	self._ccbOwner.float_tips:setContentSize(CCSize(display.width, display.height))
	self._ccbOwner.words1:setString("")
	self._ccbOwner.words1:setFontSize(10)
end

function QUIDialogServerData:_getDataStr( t, p )
    if t ~= nil and type(t) == "table" then
    	local p = p or " "
    	self._ccbOwner.words1:setString(self._ccbOwner.words1:getString().."\n"..p.."{")
        for k, v in pairs(t) do
            if type(v) == "table" then
            	self._ccbOwner.words1:setString(self._ccbOwner.words1:getString().."\n"..p..p..tostring(k) .. ": ")
                self:_getDataStr(v, p..p)
            else
                local str = tostring(v)
                str = string.gsub(str,"%%", "%%%%")
                self._ccbOwner.words1:setString(self._ccbOwner.words1:getString().."\n" ..p..p.. tostring(k) .. ": " .. str)
            end
        end
	    self._ccbOwner.words1:setString(self._ccbOwner.words1:getString().."\n"..p..p.."}")
    end
end


-- 处理各种touch event
function QUIDialogServerData:onTouchEvent(event)
    if event == nil or event.name == nil then
        return
    end
    if event.name == QUIGestureRecognizer.EVENT_SLIDE_GESTURE then
        -- self._page:endMove(event.distance.y)
    elseif event.name == "began" then
        self._startY = event.y
        self._pageY = self._ccbOwner.words1:getPositionY()
    elseif event.name == "moved" then
        local offsetY = self._pageY + event.y - self._startY
        self._ccbOwner.words1:setPositionY(offsetY)
    elseif event.name == "ended" then
    end
end

function QUIDialogServerData:_backClickHandler()
    self:playEffectOut()
end

function QUIDialogServerData:viewAnimationOutHandler()
    app:getNavigationManager():popViewController(app.middleLayer, QNavigationController.POP_SPECIFIC_CONTROLLER, nil, self)
end

return QUIDialogServerData