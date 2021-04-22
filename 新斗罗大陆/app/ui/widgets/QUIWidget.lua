
local QUIWidget = class("QUIWidget", function()
    return display.newNode()
end)

function QUIWidget:ctor(ccbFile, callBacks, options)
	self._ccbOwner = {}
    self._options = options

    if callBacks ~= nil then
        self:_setCCBOwnerValue(callBacks)
    end

    if ccbFile ~= nil then
        -- print("cur ccbi = "..ccbFile.."*******************************************")


        if not ENABLE_CCB_TO_LUA then
            if app.ccbNodeCache ~= nil then
                self._ccbView = app.ccbNodeCache:loadCCBI(ccbFile, self._ccbOwner)
            else
                self._ccbView = CCBuilderReaderLoad(ccbFile, CCBProxy:create(), self._ccbOwner)
            end
        else
            self._ccbView = CCBuilderReaderLoad(ccbFile, CCBProxy:create(), self._ccbOwner)
        end
        if self._ccbView == nil then
            assert(false, "load ccb file:" .. ccbFile .. " faild!")
        end
        self:addChild(self._ccbView)
    end

    self:setNodeEventEnabled(true)
end

function QUIWidget:getView()
    return self
end

function QUIWidget:getCCBView()
    return self._ccbView
end

function QUIWidget:onEnter()

end

function QUIWidget:onExit()
    
end

function QUIWidget:safeCheck()
    return self ~= nil
end

function QUIWidget:getOptions()
    return self._options
end

function QUIWidget:setOptions(options)
    self._options = options
end

function QUIWidget:_setCCBOwnerValue(callbacks)
    if callbacks == nil then
        return
    end

    for i, v in ipairs(callbacks) do
        local ccbCallbackName = v.ccbCallbackName
        local callback = v.callback
        if ccbCallbackName ~= nil and callback ~= nil then
            self._ccbOwner[ccbCallbackName] = callback
        end
    end
end

return QUIWidget