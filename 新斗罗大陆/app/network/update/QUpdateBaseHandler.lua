local QUpdateBaseHandler = class("QUpdateBaseHandler")

function QUpdateBaseHandler:ctor(options)
    self._manager = options.manager
end

function QUpdateBaseHandler:startHandler( ... )
    -- print("startHandler")
end

function QUpdateBaseHandler:progressHandler()
    -- print("progressHandler")
end

function QUpdateBaseHandler:errorHandler()
    -- print("errorHandler")
end

function QUpdateBaseHandler:completeHandler( ... )
    -- print("completeHandler")
end

function QUpdateBaseHandler:getManager( ... )
    return self._manager
end

return QUpdateBaseHandler