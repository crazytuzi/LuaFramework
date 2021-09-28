--[[
    filename:
    description:
    date: 2016.05.10

    author: 杨科
    email:  h3rvgo@gmail.com
-- ]]

local EVENT_CODE = cc.EventAssetsManagerEx.EventCode

local RESULT = {
    eFailed   = -1,
    eUpToDate = 1,
    eSuccess  = 0,
}

local MANIFEST_FILE = "project.manifest"
local STORAGE_PATH = cc.FileUtils:getInstance():getWritablePath()
if cc.Application:getInstance():getTargetPlatform() == cc.PLATFORM_OS_MAC then
    STORAGE_PATH = STORAGE_PATH .. "shediao/"
end
STORAGE_PATH = STORAGE_PATH .. "Download/"

local UpdateResourceLayer = class("UpdateResourceLayer", function()
    return display.newLayer(cc.c4b(0, 0, 0, 140))
end)

--[[
params:
{
    ResourceVersionName
    Url
}
--]]
function UpdateResourceLayer:ctor(params)
    Utility.launchStepInfo(3, 2, "update beg")
    --dump(params)
    release_print("ResourceVersionName: " .. params["ResourceVersionName"])
    release_print("Url:  " .. params["Url"])
    self.params = params

    ui.registerSwallowTouch({node=self})

    math.newrandomseed()

    local am_ = require("login.AssetsMgr").new{
        manifest = MANIFEST_FILE,
        storage  = STORAGE_PATH,
        max_thread = 10,
    }
    self.am_ = am_
    self.am_:setPackageUrl(params["Url"], params["ResourceVersionName"])

    -- 添加enterTransitionFinish事件
    local function onNodeEvent(event)
        if "enterTransitionFinish" == event then
            return self.onEnterTransitionFinish and self:onEnterTransitionFinish()
        end
    end
    self:registerScriptHandler(onNodeEvent)

    -- 失败文件个数
    self.failedCnt_ = 0
    self.failedFiles_ = {}

    self:createUI(params)
end


-- 初始化界面
function UpdateResourceLayer:createUI(params)
    -- 进度条
    self.mProgressBar = require("common.ProgressBar").new({
        bgImage = "zr_14.png",
        barImage = "zr_15.png",
        currValue = 100,
        maxValue=  100,
        needLabel = true,
        color = Enums.Color.eWhite,
    })
    self.mProgressBar:setPosition(display.cx, display.cy - 450 * Adapter.MinScale)
    self.mProgressBar:setScale(Adapter.MinScale)
    self:addChild(self.mProgressBar)

    --下载状态
    self.label_state = cc.Label:createWithSystemFont("", _FONT_PANGWA, 26 * Adapter.MinScale)
    self.label_state:setPosition(display.cx, display.cy - 480 * Adapter.MinScale)
    self.label_state:setColor(cc.c3b(255, 255, 255))
    self:addChild(self.label_state)

    -- 大小
    self.label_size = cc.Label:createWithSystemFont("", _FONT_PANGWA, 26 * Adapter.MinScale)
    self.label_size:setAnchorPoint(cc.p(1, 0.5))
    self.label_size:setPosition(display.cx + 280 * Adapter.MinScale, display.cy - 480 * Adapter.MinScale)
    self.label_size:setColor(cc.c3b(255, 255, 255))
    self:addChild(self.label_size)

    -- 速度
    self.label_speed = cc.Label:createWithSystemFont("", _FONT_PANGWA, 26 * Adapter.MinScale)
    self.label_speed:setAnchorPoint(cc.p(1, 0.5))
    self.label_speed:setPosition(display.cx + 280 * Adapter.MinScale, display.cy - 420 * Adapter.MinScale)
    self.label_speed:setColor(cc.c3b(255, 255, 255))
    self:addChild(self.label_speed)

    self.speed = {
        downloadSize_ = 0,
        lastSize_ = 0,
        outtime_ = 0,
        lasttime_ = 0,
    }
    self.label_speed:scheduleUpdateWithPriorityLua(function(delta)
        self.speed.outtime_ = self.speed.outtime_ + delta

        local outime = self.speed.outtime_ - self.speed.lasttime_
        if outime >= 1 then
            local speed = (self.speed.downloadSize_ - self.speed.lastSize_) / outime
            if speed < 0 then
                speed = 0
            end
            local s = Utility.btyeToViewStr(speed)
            self.label_speed:setString(s .. "/s")

            self.speed.lastSize_ = self.speed.downloadSize_
            self.speed.lasttime_ = self.speed.outtime_
        end
    end, 1)

    -- 显示版本号label
    local label = ui.newLabel({
        text  = TR("版本号:%s(%s)"
            , IPlatform:getInstance():getConfigItem("ClientVersion")
            , string.sub(LocalData:getResourceName(), 12, 20)),
        size  = 20 * Adapter.MinScale,
        color = cc.c3b(255, 255, 255),
    })
    label:setAnchorPoint(cc.p(1, 0))
    label:setPosition(cc.p(display.cx + 320 * Adapter.MinScale, 0))
    self:addChild(label)

    -- 绑定响应
    for k, v in pairs(EVENT_CODE) do
        if self["on_" .. k] then
            self.am_:on(v, function(...)
                if tolua.isnull(self) then
                    return
                end
                self["on_" .. k](self, ...)
            end)
        end
    end
end

function UpdateResourceLayer:onEnterTransitionFinish()
    if not self.mOnEnterTransitionFinished then
        self.mOnEnterTransitionFinished = true

        self.failedFiles_ = {}
        self.failedCnt_ = 0
        self.speed = {
            downloadSize_ = 0,
            lastSize_ = 0,
            outtime_ = 0,
            lasttime_ = 0,
        }

        self.label_state:setString(TR("正在获取更新列表"))
        self.am_:update()
    end
end


-------------- 事件 --------------

-- 有新版本
function UpdateResourceLayer:on_NEW_VERSION_FOUND(event)
    local version = self.am_:getRemoteManifest():getVersion()
    --dump(version, "Remote Manifest Version")

    self.label_state:setString(TR("解析中"))
    self.am_:update()
end

-- 已最新，无需更新
function UpdateResourceLayer:on_ALREADY_UP_TO_DATE(...)
    if self.params.onEnd then
        self.params.onEnd(RESULT.eUpToDate, event)
    end
    self:reboot()
end

-- 找不到本地版本文件
function UpdateResourceLayer:on_ERROR_NO_LOCAL_MANIFEST(...)
    self:onFailed(...)
    local tips = {
        TR("本地配置文件丢失"),
        TR("本地配置文件在躲猫猫"),
    }
    self:tips(tips[math.random(1, #tips)])
end

-- 版本文件解析错误
function UpdateResourceLayer:on_ERROR_PARSE_MANIFEST(...)
    self:onFailed(...)
    local tips = {
        TR("配置文件解析出错"),
        TR("配置文件又调皮了"),
    }
    self:tips(tips[math.random(1, #tips)])
end

-- 下载远程版本文件失败
function UpdateResourceLayer:on_ERROR_DOWNLOAD_MANIFEST(...)
    self:onFailed(...)
    local tips = {
        TR("配置文件下载出错"),
        TR("远程配置文件也爱躲猫猫"),
        TR("服务器正在打瞌睡"),
    }
    self:tips(tips[math.random(1, #tips)])
end

-- 更新结果：失败
function UpdateResourceLayer:on_UPDATE_FAILED(...)
    local fails = self.failedFiles_

    self.retryCnt_ = self.retryCnt_ or 0

    local function retry(outtime)
        self.failedCnt_ = 0
        self.failedFiles_ = {}
        self.am_:downloadFailedAssets(outtime or 30)
    end

    for k, v in pairs(fails or {}) do
        release_print("失败文件: " .. v)
    end

    if self.retryCnt_ < 3 then
        self.retryCnt_ = self.retryCnt_ + 1

        release_print("自动重试: " .. self.retryCnt_)
        retry(15)
    else
        self:onFailed(...)

        local tips = {
            TR("更新有点小问题，%s个文件未完成", self.failedCnt_),
            TR("这不是一次完美的更新，有个%s个文件未完成", self.failedCnt_),
            TR("如果给我再来一次的机会...我会把另外%s个文件撩到手", self.failedCnt_),
        }
        self:tips(tips[math.random(1, #tips)], nil, function()
            self.label_state:setString(TR("下载中"))
            self.retryCnt_ = 0
            retry(30)
        end)
    end
end

-- 更新结果：成功
function UpdateResourceLayer:on_UPDATE_FINISHED(event)
    Utility.launchStepInfo(3, 3, "update end")
    self.label_state:setString(TR("更新完成"))
    if self.params.onEnd then
        self.params.onEnd(RESULT.eSuccess, event)
    end

    self:reboot()
end

-- 更新过程：单个文件成功
function UpdateResourceLayer:on_ASSET_UPDATED(event)
end

-- 更新过程：单个文件更新失败
function UpdateResourceLayer:on_ERROR_UPDATING(event)
    self.failedCnt_ = self.failedCnt_ + 1

    local assetId = event:getAssetId()
    table.insert(self.failedFiles_, assetId)
end

-- 更新过程：解压失败
function UpdateResourceLayer:on_ERROR_DECOMPRESS(...)
    self:onFailed(...)
end


-- 更新过程：进度
function UpdateResourceLayer:on_UPDATE_PROGRESSION(event)
    local assetId = event:getAssetId()
    local percent = event:getPercent()
    local strInfo = ""

    if assetId == cc.AssetsManagerExStatic.VERSION_ID then
        strInfo = string.format("Version file: %d%%", percent)
    elseif assetId == cc.AssetsManagerExStatic.MANIFEST_ID then
        self.label_state:setString(TR("正在获取更新列表 %d%%", percent))
        strInfo = string.format("Manifest file: %.02f%%", percent)
    else
        self.label_state:setString(TR("下载中"))
        strInfo = string.format("%s %d%%", assetId, percent)

        local total = event:getTotalSize()
        local done = percent * total / 100
        if done >= (self.speed.downloadSize_ or 0) then
            self.speed.downloadSize_ = done

            local _, readableTotal = Utility.btyeToViewStr(total)
            local _, readableDone = Utility.btyeToViewStr(done, nil, readableTotal[2])

            self.label_size:setString(string.format("%.02f/%.02f %s",
                readableDone[1], readableTotal[1], readableTotal[2]))
            self.mProgressBar:setCurrValue(percent)
        end
    end
    --dump(strInfo, "UPDATE_PROGRESSION")
end


-----------
function UpdateResourceLayer:onFailed(event)
    self.label_state:setString(TR("更新中断<%s>", event:getEventCode()))
end

function UpdateResourceLayer:tips(text, left, right)
    local hintStr = string.format("%s\n%s", text, self:genMotion())
    local okBtnInfo = {
        text = TR("重新下载"),
        clickAction = function(layerObj, btnObj)
            local params = self.params
            self.am_:release()
            LayerManager.removeLayer(layerObj)

            -- 先删除再跳转界面
            LayerManager.addLayer({
                name = "login.UpdateResourceLayer",
                data = params,
                cleanUp = false
            })
        end
    }
    local cancelBtnInfo = {
        text = TR("清理缓存"),
        clickAction = function(layerObj, btnObj)
            if cc.FileUtils:getInstance():isDirectoryExist(STORAGE_PATH) then
                cc.FileUtils:getInstance():removeDirectory(STORAGE_PATH)
            end
            LayerManager.removeLayer(layerObj)

            self:reboot()
        end
    }
    MsgBoxLayer.addOKLayer(hintStr, TR("提示"), {okBtnInfo, cancelBtnInfo})
end

function UpdateResourceLayer:genMotion()
    local MOTIONS = {
        TR("o_O"),
        TR("x_x"),
        TR("+_+"),
        TR("- -."),
        TR("(- -)"),
        TR("- -#"),
        TR("- -!"),
        TR("@_@"),
        TR("\\\\(ToT)//"),
    }

    return MOTIONS[math.random(1, #MOTIONS)]
end


function UpdateResourceLayer:reboot()
    self.am_:release()
    Utility.performWithDelay(self, function( ... )
        --清空spine资源(假如当前场景有spine正在引用，则该资源不会释放。
        --    如果这个更新包需要更新该资源，则会出现动画错乱的情况。)
        if skeletonCache_clear then
            skeletonCache_clear()
        end

        --清空缓存
        cc.Director:getInstance():purgeCachedData()

        -- 直接进入游戏
        clearRequireList()
        require("main")
    end , 0)
end

return UpdateResourceLayer
