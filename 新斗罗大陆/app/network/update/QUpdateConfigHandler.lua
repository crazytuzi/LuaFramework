local QUpdateBaseHandler = import(".QUpdateBaseHandler")
local QUpdateConfigHandler = class("QUpdateConfigHandler", QUpdateBaseHandler)

function QUpdateConfigHandler:ctor(options)
    QUpdateConfigHandler.super.ctor(self, options)
end

function QUpdateConfigHandler:startHandler( ... )
    QUpdateConfigHandler.super.startHandler(self, ...)
end

function QUpdateConfigHandler:progressHandler( ... )
    QUpdateConfigHandler.super.progressHandler(self, ...)
end

function QUpdateConfigHandler:errorHandler( ... )
    QUpdateConfigHandler.super.errorHandler(self, ...)
end

function QUpdateConfigHandler:completeHandler( ... )
    QUpdateConfigHandler.super.completeHandler(self, ...)
    self:getManager():checkVersion()
end

return QUpdateConfigHandler