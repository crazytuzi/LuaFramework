
local QUIViewController = class("QUIViewController")

QUIViewController.TYPE_PAGE = "UI_TYPE_PAGE"
QUIViewController.TYPE_DIALOG = "UI_TYPE_DIALOG"

local __scheduler = scheduler
local function _defaultDecorate(listener)
    return listener
end
local function _createScheduler(decorate)
    if decorate == nil then
        decorate = _defaultDecorate
    end
    local handles = {}
    return {
        scheduleUpdateGlobal = function(listener)
            local handle = __scheduler.scheduleUpdateGlobal(decorate(listener))
            handles[handles] = handle
            return handle
        end,
        scheduleGlobal = function(listener, interval)
            local handle = __scheduler.scheduleGlobal(decorate(listener), interval)
            handles[handles] = handle
            return handle
        end,
        performWithDelayGlobal = function(listener, time)
            local handle = __scheduler.performWithDelayGlobal(decorate(listener), time)
            handles[handles] = handle
            return handle
        end,
        unscheduleGlobal = function(handle)
            __scheduler.unscheduleGlobal(handle)
            handles[handle] = nil
        end,
        unscheduleAll = function(handle)
            for _, handle in ipairs(handles) do
                __scheduler.unscheduleGlobal(handle)
            end
            handles = {}
        end,
    }
end

-- callbacks is table like: {{ccbCallbackName=name, callBack=function}}
-- function can be get like: handler(self, ClassName.function)
function QUIViewController:ctor(type, ccbFile, callbacks, options)
    self.__type = type
    self._ccbOwner = {}

    if callbacks ~= nil then
        self:_setCCBOwnerValue(callbacks)
    end

    if ccbFile ~= nil then
        local proxy = CCBProxy:create()
        self._view = CCBuilderReaderLoad(ccbFile, proxy, self._ccbOwner)
        if self._view == nil then
            assert(false, "load ccb file:" .. ccbFile .. " faild!")
        end
    else
        self._view = CCNode:create()
    end

    self._parentViewController = nil
    self._subViewControllers = {}
end

function QUIViewController:getType()
    return self.__type
end

function QUIViewController:getView()
    return self._view
end

function QUIViewController:setParentController(controller)
    if controller == nil then
        return
    end

    self._parentViewController = controller
end

function QUIViewController:getParentController()
    return self._parentViewController
end

function QUIViewController:getNodeFromName(name)
    local node = self._ccbOwner[name]
    
    if node ~= nil then
        if type(node) == "function" then
            node = nil
        end
    end

    return node
end

function QUIViewController:addSubViewController(controller)
    if controller == nil or controller:getView() == nil then
        return
    end

    if controller:getParentController() ~= nil then
        assert(false, "controller is already have parent!")
        return
    end

    controller:viewWillAppear()
    controller:setParentController(self)
    table.insert(self._subViewControllers, controller)
    self:_addViewSubView(controller:getView())
    controller:viewDidAppear()
end

function QUIViewController:removeSubViewController(controller)
    if controller == nil or controller:getView() == nil then
        return
    end

    for i, v in ipairs(self._subViewControllers) do
        if controller == v then
            controller:viewWillDisappear()
            self:_removeViewSubView(controller:getView())
            controller:setParentController(nil)
            table.remove(self._subViewControllers, i)
            controller:viewDidDisappear()
            break
        end
    end
end

function QUIViewController:removeFromParentController()
    if self._parentViewController == nil then
        return
    end

    self._parentViewController:removeSubViewController(self)
end

function QUIViewController:getSubViewControllersCount()
    return #self._subViewControllers
end

function QUIViewController:viewWillAppear()

end

function QUIViewController:viewDidAppear()
    print("[INFO] >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>")
    print("[INFO] Enter instance:" .. self.__cname)
    print("[INFO] <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<")

    self._appear = true
end

function QUIViewController:viewWillDisappear()
    
end

function QUIViewController:viewDidDisappear()
    print("[INFO] >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>")
    print("[INFO] Exit instance:" .. self.__cname)
    print("[INFO] <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<")
    if self.__scheduler then
        self.__scheduler.unscheduleAll()
    end
    self._appear = false
end

function QUIViewController:_addViewSubView(view)
    if view == nil then
        return
    end

    if self._view == nil then
        assert(false, "self view is invalid!")
        return
    end

    self._view:addChild(view)
end

function QUIViewController:_removeViewSubView(view)
    if view == nil then
        return
    end

    if self._view == nil then
        assert(false, "self view is invalid!")
        return
    end

    self._view:removeChild(view, true)
end

function QUIViewController:_setCCBOwnerValue(callbacks)
    if callbacks == nil then
        return
    end

    for i, v in ipairs(callbacks) do
        local ccbCallbackName = v.ccbCallbackName
        local callback = v.callback
        local publicCallback = function(...)
            self:_onTrigger(callback, ...) 
        end
        if ccbCallbackName ~= nil and callback ~= nil then
            if v.isGroup then
                self._ccbOwner[ccbCallbackName] = {callback = publicCallback, isGroup = v.isGroup}
            else
                self._ccbOwner[ccbCallbackName] = publicCallback
            end
        end
    end
end

function QUIViewController:_onTrigger(callback, ...)
    callback(...)
end

function QUIViewController:hide()
    local view = self:getView()
    if view ~= nil then
        view:setVisible(false)
    end
end

function QUIViewController:show()
    local view = self:getView()
    if view ~= nil then
        view:setVisible(true)
    end
end

function QUIViewController:safeHandler(func)
    return function(...)
        if not self._appear then
            return
        elseif func and type(func) == "function" then
            func(...)
        end
    end
end

function QUIViewController:safeCheck()
    return self._appear == true
end

function QUIViewController:getScheduler()
    if self.__controllerScheduler == nil then
        self.__controllerScheduler = _createScheduler(
            function(listener)
                return function(...)
                    if self:safeCheck() and listener then
                        listener(...)
                    end
                end
            end)
    end
    return self.__controllerScheduler
end

return QUIViewController