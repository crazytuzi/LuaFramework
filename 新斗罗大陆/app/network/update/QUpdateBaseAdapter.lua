-- @Author: Kai Wang
-- @Date:   2019-07-30 10:29:43
-- @Last Modified by:   Kai Wang
-- @Last Modified time: 2019-08-02 14:10:27
local QUpdateBaseAdapter = class("QUpdateBaseAdapter")

QUpdateBaseAdapter.EVENT_UPDATE_START = "UPDATE_ADAPTER_EVENT_UPDATE_START"
QUpdateBaseAdapter.EVENT_UPDATE_PROGRESS = "UPDATE_ADAPTER_EVENT_UPDATE_PROGRESS"
QUpdateBaseAdapter.EVENT_UPDATE_ERROR = "UPDATE_ADAPTER_EVENT_UPDATE_ERROR"
QUpdateBaseAdapter.EVENT_UPDATE_COMPLETE = "UPDATE_ADAPTER_EVENT_UPDATE_COMPLETE"

function QUpdateBaseAdapter:ctor(options)
    cc(self):addComponent("components.behavior.EventProtocol"):exportMethods()
end

function QUpdateBaseAdapter:isDisableDownload( ... )
    return false
end

function QUpdateBaseAdapter:downloadFile( ... )
    -- print("downloadFile", ... )
end

function QUpdateBaseAdapter:downloadContent( ... )
    -- body
end

function QUpdateBaseAdapter:checkIndex( ... )
    -- print("checkIndex", ... )
end

--[[
    销毁，移除时必须调用
]]
function QUpdateBaseAdapter:dispose( ... )
    -- body
end

return QUpdateBaseAdapter