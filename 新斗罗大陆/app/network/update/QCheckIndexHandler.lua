-- @Author: Kai Wang
-- @Date:   2019-07-30 22:30:23
-- @Last Modified by:   Kai Wang
-- @Last Modified time: 2019-08-05 21:39:04
local QUpdateBaseHandler = import(".QUpdateBaseHandler")
local QCheckIndexHandler = class("QCheckIndexHandler", QUpdateBaseHandler)

function QCheckIndexHandler:ctor(options)
    QCheckIndexHandler.super.ctor(self, options)
end

function QCheckIndexHandler:startHandler(evt)
    QCheckIndexHandler.super.startHandler(self, evt)
end

function QCheckIndexHandler:progressHandler( evt )
    QCheckIndexHandler.super.progressHandler(self, evt)
    self:getManager():dispatchProgress({percent = evt.percent})
end

function QCheckIndexHandler:errorHandler( ... )
    QCheckIndexHandler.super.errorHandler(self, ...)
end

function QCheckIndexHandler:completeHandler( evt )
    QCheckIndexHandler.super.completeHandler(self, evt)
    local updateList = evt.list
    local totalSize = evt.totalSize
    local percount = evt.percount
    self:getManager():dispatchStatus("文件列表检查完成")
    if totalSize == 0 then
        self:getManager():downloadComplete(percount)
        return
    end
    local downloadSize = math.ceil(totalSize / 1024)
    local tipString = string.format("魂师大大，当前有%dKB更新，检测到您当前WLAN还未打开或连接，是否继续下载？", downloadSize)
    local downloadText = string.format("%dKB", downloadSize)
    if downloadSize > 1024 then
        downloadSize = totalSize / 1024 / 1024
        tipString = string.format("魂师大大，当前有%.1fMB更新，检测到您当前WLAN还未打开或连接，是否继续下载？", downloadSize)
        downloadText = string.format("%.1fMB", downloadSize)
    end
    -- print("downloadSize", downloadSize)
    if downloadSize > 1 then
        if CCNetwork:isLocalWiFiAvailable() == true then
            -- if self._loadingBar then
            --     self._loadingBar:setWifiTipsVisible(true)
            -- end
            -- confirmDownload(true)
            self:getManager():confirmDownload(updateList, totalSize)
        else
            app:alert({content=tipString, title="更新提示", 
                callback=function(state)
                    if state == ALERT_TYPE.CONFIRM then
                        self:getManager():confirmDownload(updateList, totalSize)
                    end
            end, isAnimation = false}, false, true)
        end
     
    else
        -- confirmDownload(false)
        self:getManager():confirmDownload(updateList, totalSize)
    end
end

return QCheckIndexHandler