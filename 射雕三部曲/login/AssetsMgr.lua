-- AssetsManagerEx = cc.AssetsManagerEx:create("http://127.0.0.1/freshman.manifest")

local AssetsMgr = class("AssetsMgr", function(params)
    if params.max_thread then
        return cc.AssetsManagerEx:create(params.manifest, params.storage, params.max_thread)
    else
        return cc.AssetsManagerEx:create(params.manifest, params.storage)
    end
end)

--[[
params:
{
    manifest:       manifest文件路径
    storage:        更新存储路径
    max_thread:     最大下载线程数
}
--]]
function AssetsMgr:ctor()
    self.listeners_ = {}

    self:retain()

    local eventCode = cc.EventAssetsManagerEx.EventCode

    local assetsListener = {
        -- 没有本地版本文件
        [eventCode.ERROR_NO_LOCAL_MANIFEST] = function(...)
            local cb = self.listeners_[tostring(eventCode.ERROR_NO_LOCAL_MANIFEST)]
            return cb and cb(...)
        end,
        -- 下载远程版本文件失败
        [eventCode.ERROR_DOWNLOAD_MANIFEST] = function(...)
            local cb = self.listeners_[tostring(eventCode.ERROR_DOWNLOAD_MANIFEST)]
            return cb and cb(...)
        end,
        -- 解析版本文件错误
        [eventCode.ERROR_PARSE_MANIFEST] = function(...)
            local cb = self.listeners_[tostring(eventCode.ERROR_PARSE_MANIFEST)]
            return cb and cb(...)
        end,
        -- 有新版本
        [eventCode.NEW_VERSION_FOUND] = function(...)
            local cb = self.listeners_[tostring(eventCode.NEW_VERSION_FOUND)]
            return cb and cb(...)
        end,
        -- 已最新
        [eventCode.ALREADY_UP_TO_DATE] = function(...)
            local cb = self.listeners_[tostring(eventCode.ALREADY_UP_TO_DATE)]
            return cb and cb(...)
        end,
        -- 正在更新
        [eventCode.UPDATE_PROGRESSION] = function(...)
            local cb = self.listeners_[tostring(eventCode.UPDATE_PROGRESSION)]
            return cb and cb(...)

            --dump("UPDATE_PROGRESSION", "cc.EventAssetsManagerEx")
            -- local assetId = event:getAssetId()
            -- local percent = event:getPercent()
            -- local strInfo = ""

            -- if assetId == cc.AssetsManagerExStatic.VERSION_ID then
            --     strInfo = string.format("Version file: %d%%", percent)
            -- elseif assetId == cc.AssetsManagerExStatic.MANIFEST_ID then
            --     strInfo = string.format("Manifest file: %d%%", percent)
            -- else
            --     strInfo = string.format("%d%%", percent)
            -- end
            --dump(strInfo, "UPDATE_PROGRESSION")
        end,
        -- 某个文件更新成功
        [eventCode.ASSET_UPDATED] = function(...)
            local cb = self.listeners_[tostring(eventCode.ASSET_UPDATED)]
            return cb and cb(...)
        end,
        -- 更新过程中失败
        [eventCode.ERROR_UPDATING] = function(...)
            local cb = self.listeners_[tostring(eventCode.ERROR_UPDATING)]
            return cb and cb(...)
        end,
        -- 更新完成
        [eventCode.UPDATE_FINISHED] = function(...)
            local cb = self.listeners_[tostring(eventCode.UPDATE_FINISHED)]
            return cb and cb(...)
        end,
        -- 更新失败
        [eventCode.UPDATE_FAILED] = function(...)
            local cb = self.listeners_[tostring(eventCode.UPDATE_FAILED)]
            return cb and cb(...)
        end,
        -- 解压失败
        [eventCode.ERROR_DECOMPRESS] = function(...)
            local cb = self.listeners_[tostring(eventCode.ERROR_DECOMPRESS)]
            return cb and cb(...)
        end,
    }

    local eventListener = cc.EventListenerAssetsManagerEx:create(self, function(...)
        if tolua.isnull(self) then
            return
        end

        local event = ({...})[1]
        local eventCode = event:getEventCode()
        if eventCode then
            local cb = self.listeners_[tostring(eventCode)]
            return cb and cb(...)
        end
    end)

    cc.Director:getInstance():getEventDispatcher()
        :addEventListenerWithFixedPriority(eventListener, -1)
end


function AssetsMgr:retry()
    return self:downloadFailedAssets()
end

-- 监听某项事件
function AssetsMgr:on(eventCode, cb)
    self.listeners_[tostring(eventCode)] = cb
    return self
end

return AssetsMgr
