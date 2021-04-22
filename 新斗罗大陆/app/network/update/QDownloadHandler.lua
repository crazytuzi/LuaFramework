-- @Author: Kai Wang
-- @Date:   2019-07-30 23:03:08
-- @Last Modified by:   Kai Wang
-- @Last Modified time: 2019-09-03 17:27:42
local QUpdateBaseHandler = import(".QUpdateBaseHandler")
local QDownloadHandler = class("QDownloadHandler", QUpdateBaseHandler)

function QDownloadHandler:ctor(options)
    QDownloadHandler.super.ctor(self, options)
    self._errorList = {}
    self._failList = {}
    self._retry = 0
end

function QDownloadHandler:startHandler( evt )
    QDownloadHandler.super.startHandler(self, evt)
    self:getManager():dispatchStatus(evt.fileName)
end

function QDownloadHandler:progressHandler( evt )
    QDownloadHandler.super.progressHandler(self, evt)
    self:getManager():dispatchProgress({currentSize = evt.currentSize, totalSize = evt.totalSize, percent = 100*evt.currentSize/evt.totalSize})
end

function QDownloadHandler:errorHandler( evt )
    QDownloadHandler.super.errorHandler(self, evt)
    local eventNum = evt.data.error
    if eventNum == QDownloader.kNetwork or eventNum == QDownloader.kValidation then
        -- self:getManager():downloadIndex()
        table.insert(self._errorList, evt.data.info)
    else
        table.insert(self._failList, evt.data.info)
    end
end

function QDownloadHandler:completeHandler( evt )
    QDownloadHandler.super.completeHandler(self, evt)
    if #self._failList > 0 or #self._errorList > 0 then
        self:getManager():dispatchStatus("更新文件出错，即将跳过本次更新！")
        scheduler.performWithDelayGlobal(function ( ... )
            self:getManager():downloadComplete()
        end, 1)
        return
    end
    -- print("error count", #self._errorList)
    -- if #self._errorList > 0 then
    --     self._retry = self._retry + 1
    --     self:getManager():dispatchStatus(#self._errorList.."个文件更新失败，准备重试！")
    --     scheduler.performWithDelayGlobal(function ( ... )
    --         -- self:getManager():downloadComplete()
    --         local totalSize = 0
    --         for i,v in ipairs(self._errorList) do
    --             totalSize = totalSize + v.gz
    --         end
    --         local adapter = self:getManager():getAdapter()
    --         if adapter then
    --             adapter:downloadByList(self._errorList, self._retry)
    --         end
    --     end, 1)
    --     return
    -- end
    self:getManager():clearTempIndex()
    local count = evt.count
    local handle
    handle = scheduler.performWithDelayGlobal(function(dt)
            scheduler.unscheduleGlobal(handle)
            -- self:getManager():downloadComplete(count)
            self:getManager():downloadComplete(count)
        end, 0)
end

return QDownloadHandler