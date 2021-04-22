
local QUIPage = import(".QUIPage")
local QUIPageEmpty = class("QUIPageEmpty", QUIPage)

function QUIPageEmpty:ctor(options)
    QUIPageEmpty.super.ctor(self, nil, nil, options)
    
    self._view = CCLayer:create()
end

return QUIPageEmpty