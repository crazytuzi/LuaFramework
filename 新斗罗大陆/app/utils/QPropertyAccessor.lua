
local Component =  require(cc.PACKAGE_NAME .. ".cc.components.Component")
local QPropertyAccessor = class("QPropertyAccessor", Component)

function QPropertyAccessor:ctor()
    QPropertyAccessor.super.ctor(self, "QPropertyAccessor")
end

function QPropertyAccessor:get(propName)
    local values = self:getProperties({propName})
    if values[propName] == nil then
        printError(propName .. " does not exists!")
        return nil
    end

    return values[propName]
end

function QPropertyAccessor:set(propName, propValue)
    local value = {}
    value[propName] = propValue
    self:setProperties(value)
end

function QPropertyAccessor:exportMethods()
    self:exportMethods_({
        "get",
        "set",
    })
    return self
end

return QPropertyAccessor
