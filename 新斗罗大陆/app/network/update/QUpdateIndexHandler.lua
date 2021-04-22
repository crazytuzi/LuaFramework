local QUpdateBaseHandler = import(".QUpdateBaseHandler")
local QUpdateIndexHandler = class("QUpdateIndexHandler", QUpdateBaseHandler)

function QUpdateIndexHandler:ctor(options)
    QUpdateIndexHandler.super.ctor(self, options)
end

function QUpdateIndexHandler:startHandler( evt )
    QUpdateIndexHandler.super.startHandler(self, evt)
    -- print(evt.num)
end

function QUpdateIndexHandler:progressHandler( evt )
    QUpdateIndexHandler.super.progressHandler(self, evt)
    self:getManager():dispatchProgress({percent = evt.data.num, text = "下载文件列表。。。已完成"..evt.data.num.."%"})
end

function QUpdateIndexHandler:errorHandler( evt )
    QUpdateIndexHandler.super.errorHandler(self, evt)
    local eventNum = evt.data.error
    if eventNum == QDownloader.kNetwork or eventNum == QDownloader.kValidation then
        self:getManager():dispatchStatus("下载文件列表出错，即将重试！")
        scheduler.performWithDelayGlobal(function ( ... )
            self:getManager():downloadIndex()
        end, 1)
    else
        self:getManager():dispatchStatus("下载文件列表出错，即将跳过本次更新！")
        scheduler.performWithDelayGlobal(function ( ... )
            self:getManager():downloadComplete()
        end, 1)
    end
end

function QUpdateIndexHandler:completeHandler( ... )
    QUpdateIndexHandler.super.completeHandler(self, ...)
    self:getManager():checkIndex()
end

return QUpdateIndexHandler