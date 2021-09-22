--region GameUpdate.lua
--Date 2016/6/24
--此文件由[BabeLua]插件自动生成.

GameUpdate = class("GameUpdate")

function GameUpdate:ctor()
     
end

function GameUpdate:initParams(params)
    params = params or {};
    local fn = function ()  end;

    params.onFindNewVersion = params.onFindNewVersion or fn;
    params.onProgress = params.onProgress or fn;
    params.onSuccess = params.onSuccess or fn;
    params.onAlreadyUpdate = params.onAlreadyUpdate or fn;
    params.onError = params.onError or fn;
    return params;
end

function GameUpdate:initSearchPath(params)
    local url1 = cc.FileUtils:getInstance():getWritablePath()..params.rootPath..params.updateName;
    local url2 = cc.FileUtils:getInstance():getWritablePath()..params.rootPath..params.updateName..'/'.."resource";
    local url3 = cc.FileUtils:getInstance():getWritablePath()..params.rootPath..params.updateName..'/'.."script";

    cc.FileUtils:getInstance():addSearchPath(url1, true);
    cc.FileUtils:getInstance():addSearchPath(url2, true);
    cc.FileUtils:getInstance():addSearchPath(url3, true);
end

function GameUpdate:clearAssets(am, listener)
    am:release();
    cc.Director:getInstance():getEventDispatcher():removeEventListener(listener)
end

function GameUpdate:update(params)
    local params = self:initParams(params);
    self:initSearchPath(params);

    local listener = nil;
    local storagePath = cc.FileUtils:getInstance():getWritablePath()..params.rootPath;
    local am = cc.AssetsManagerEx:create(params.localManifest, storagePath, params.packageUrl, params.rootPath, params.versionFileName, params.projectFileName)
    am:retain()

    if device.platform == "android" then
        am:setMaxConcurrentTask(2);
    end

    if not am:getLocalManifest():isLoaded() then
        -- print("Fail to update assets, step skipped.")
        params.onError();
    else
        local function onUpdateEvent(event)
            local eventCode = event:getEventCode()
            if eventCode == cc.EventAssetsManagerEx.EventCode.NEW_VERSION_FOUND then
                print("－－－－－－－－发现新版本，需要更新－－－－－－－－")
                local assetId = event:getAssetId()
                print("－－－－－－－－assetId = "..assetId)
                print("－－－－－－－－fileSize = "..event:getTotalBytes())
                params.onFindNewVersion(am);

            elseif eventCode == cc.EventAssetsManagerEx.EventCode.UPDATE_PROGRESSION then
                local assetId = event:getAssetId()
                local percent = event:getPercent()
                percent = percent * 100;
                local strInfo = ""

                if assetId == cc.AssetsManagerExStatic.VERSION_ID then
                    strInfo = string.format("Version file: %d%%", percent)
                elseif assetId == cc.AssetsManagerExStatic.MANIFEST_ID then
                    strInfo = string.format("Manifest file: %d%%", percent)
                else
                    strInfo = string.format("------%d%%------", percent)
                    print(strInfo)
                    params.onProgress(percent);
                end
               -- print(strInfo);

            elseif eventCode == cc.EventAssetsManagerEx.EventCode.BEGIN_DECOMPRESS then
                params.onProgress(100);

            elseif eventCode == cc.EventAssetsManagerEx.EventCode.ALREADY_UP_TO_DATE then
                -- print("already update finished.")
                self:clearAssets(am, listener);
                params.onAlreadyUpdate();

            elseif eventCode == cc.EventAssetsManagerEx.EventCode.UPDATE_FINISHED then
                -- print("Update finished.")
                self:clearAssets(am, listener);
                params.onSuccess();

            elseif eventCode == cc.EventAssetsManagerEx.EventCode.ERROR_DOWNLOAD_MANIFEST then
                -- print("Fail to download manifest file, update skipped.")
                self:clearAssets(am, listener);
                params.onError("下载版本文件出错");
            elseif eventCode == cc.EventAssetsManagerEx.EventCode.ERROR_PARSE_MANIFEST then
                -- print("Fail to download manifest file, update skipped.")
                self:clearAssets(am, listener);
                params.onError("解析版本文件出错");

            elseif eventCode == cc.EventAssetsManagerEx.EventCode.ERROR_NO_LOCAL_MANIFEST then
                -- print("No local manifest file found, skip assets update.")
                self:clearAssets(am, listener);
                params.onError("获取不到本地版本文件");

            elseif eventCode == cc.EventAssetsManagerEx.EventCode.UPDATE_FAILED then
                am:downloadFailedAssets(); --下载出错了， 继续下载未下载的文件。

            elseif eventCode == cc.EventAssetsManagerEx.EventCode.ERROR_UPDATING then
                -- print("Asset ", event:getAssetId(), ", ", event:getMessage())
                -- if event:getErrorCode() == self.EventCode.NETWORK then
                    -- am:removeCacheFile()
                    -- self:clearAssets(am, listener);
                    -- params.onError("网络错误");
                    print("-----下载文件出错: "..event:getMessage())
					params.onError(event:getMessage());
                -- end
            elseif eventCode == cc.EventAssetsManagerEx.EventCode.ASSET_UPDATED then
               
            elseif eventCode == cc.EventAssetsManagerEx.EventCode.ERROR_DECOMPRESS then
				params.onError("更新内容解压失败:"..event:getMessage());               
			else
				params.onError("未定义错误,错误代码:"..eventCode);
            end
        end
        listener = cc.EventListenerAssetsManagerEx:create(am,onUpdateEvent)
        cc.Director:getInstance():getEventDispatcher():addEventListenerWithFixedPriority(listener, 1)
        am:checkUpdate()
        --am:update()
    end
end

GameUpdate.create = function ()
    GameUpdate.it = GameUpdate.it or GameUpdate.new();
    return GameUpdate.it;
end
