--
-- Created by IntelliJ IDEA.
-- User: 004
-- Date: 13-11-11
-- Time: 下午6:58
-- To change this template use File | Settings | File Templates.
--

require("network.NetworkHelper")
require("utility.CCBReaderLoad")
require("constant.ZipLoader")
require("gamecommon")
require("lfs")
require("data.data_serverurl_serverurl")

local UpdatingScene = class("UpdatingScene", function()
    return display.newScene("UpdatingScene")
end)

--更新完成
local function onUpdateOver()

end

function UpdatingScene:onExit()
    CCTextureCache:sharedTextureCache():removeAllTextures()
end

function UpdatingScene:ctor(newVerID, url)
    local bgSprite = display.newSprite("jpg_bg/gamelogo.jpg")

    if (display.widthInPixels / display.heightInPixels) == 0.75 then
        bgSprite:setPosition(display.cx, display.height*0.55)
        bgSprite:setScale(0.9)
    elseif(display.widthInPixels == 640 and display.heightInPixels == 960) then
        bgSprite:setPosition(display.cx, display.height*0.55)
    else
        bgSprite:setPosition(display.cx, display.cy)
    end
    
    self:addChild(bgSprite)

    local label = ui.newTTFLabel({
        text = "正在更新",
        align = ui.TEXT_ALIGN_CENTER,
        x = display.cx,
        y = display.cy,
        size = 26,
        font = "fonts/FZCuYuan-M03S.ttf"
    })
    self:addChild(label)

    self.label = ui.newTTFLabel({
        text = "",
        align = ui.TEXT_ALIGN_CENTER,
        x = display.cx,
        y = display.height * 0.35,
        size = 35
    })
    self:addChild(self.label)
    self:update(newVerID, url)
end


function UpdatingScene:refresh(curLen, maxLen)
    self._rootnode["percentLabel"]:setString(string.format("%.2fM", curLen / 1024 / 1024))
    self._rootnode["maxLabel"]:setString(string.format("/%.2fM", maxLen / 1024 / 1024))
end


--更新[从网络下载更新资源]
function UpdatingScene:update(newVerID, url)
--  结果
    local curLen = 0
    local maxLen = 0
    local respData = ""

    local function updateZIP()
        local updatePackage = {
--            "framework.",
            "config",
            "app.",
            "network.",
            "sdk.",
            "update.",
            "utility.",
            "data."
--            "constant"
        }
        local tmpKey = {}
        for _, v in ipairs(updatePackage) do
            for k, _ in pairs(package.preload) do
                if string.find(k, v) then
                    table.insert(tmpKey, k)
                end
            end
        end
        for _, v in ipairs(tmpKey) do
            package.preload[v] = nil
            package.loaded[v] = nil
        end

--        ziploader("game/framework.zip")
        ziploader("game/app.zip")
        ziploader("game/sdk.zip")
        ziploader("game/update.zip")
        ziploader("game/utility.zip")
        ziploader("game/network.zip")
        ziploader("game/data.zip")
--        ziploader("game/constant.zip")

--        dump(_G)
--        dump(package.loaded)
    end

    local rootpath = CCFileUtils:sharedFileUtils():getWritablePath() .. "updateres/"
    local function mkResDir()
        ziploader("game/app.zip")
        local dirs = require("app.dirs")
        for k, v in ipairs(dirs) do
            if io.exists(rootpath .. v) ~= true then
                lfs.mkdir(rootpath .. v)
            end
        end
    end

    local function saveNewRes()
--      1、创建更新根目录
        if io.exists(rootpath) ~= true then
            lfs.mkdir(rootpath)
        end

--      2、创建代码路径
        if io.exists(rootpath .. 'game/') ~= true then
            lfs.mkdir(rootpath .. 'game/')
        end

--      3、创建所有目录
        local fileInfo = gamecommon.unzipbuff(respData, string.len(respData))
        for _, v in ipairs(fileInfo) do
            if string.find(v.name, "game/app.zip") then
                io.writefile(rootpath .. v.name, v.buff, "wb")
                package.preload["app.dirs"] = nil
                package.loaded["app.dirs"] = nil
                break
            end
        end

        mkResDir()

--      4、更新
        for k, v in ipairs(fileInfo) do
            io.writefile(rootpath .. v.name, v.buff, "wb")
        end
    end

--  请求成功
    local function onSuccess()
        --保存最新资源
        saveNewRes()
        updateZIP()

        saveversion(newVerID)

        local channelID = checkint(CSDKShell.getChannelID())
        NetworkHelper.request(data_serverurl_serverurl[channelID].versionUrl, {
            ac = "dwsuf",
            channel = CSDKShell.getChannelID(),
            version = getlocalversion()
        }, function(data)
        end, "GET")

        self:refresh(curLen, maxLen)
        show_tip_label("更新成功")
        --保存版本号

        self:performWithDelay(function()
            CCTextureCache:sharedTextureCache():removeAllTextures()
            local scene = require("app.scenes.VersionCheckScene").new()
            display.replaceScene(scene, "fade", 0.5)
        end, 1)
    end

--  更新失败
    local function onFailed()
        show_tip_label("网络错误，请重试......")
        self:performWithDelay(function()
            local scene = require("app.scenes.VersionCheckScene").new()
            display.replaceScene(scene, "fade", 0.5)
        end, 1)
    end
    self:removeChildByTag(100)

    local proxy = CCBProxy:create()
    self._rootnode = {}
    local node = CCBuilderReaderLoad("public/loading.ccbi", proxy, self._rootnode)
    node:setPosition(display.cx, display.cy)
    self:addChild(node)
    node:setTag(100)

    local sz = self._rootnode["loadingBar"]:getContentSize()
    local loadingBar = display.newSprite("ui_common/common_loading_tiao.png")
    loadingBar:setTextureRect(CCRectMake(0, 0, 0, sz.height))
    local _, posY = self._rootnode["loadingBar"]:getPosition()
    loadingBar:setAnchorPoint(ccp(0, 0.5))
    loadingBar:setPosition(display.cx - sz.width / 2, posY)
    node:addChild(loadingBar)

--  正在更新
    local function onProgress()
        loadingBar:setTextureRect(CCRectMake(0, 0, sz.width * (curLen / maxLen), sz.height))
        if self._rootnode["animNode"]:getPositionX() < sz.width * (curLen / maxLen) then
            self._rootnode["animNode"]:setPositionX(sz.width * (curLen / maxLen))
        end

        self:refresh(curLen, maxLen)
    end

--  开始更新
    local downloadFromServer
    downloadFromServer = function(downurl)
        NetworkHelper.download(downurl, function(data)

            if data.name == "inprogress" then
                curLen = data.dlnow
                maxLen = data.dltotal
                onProgress()

            elseif data.name == "completed" then
--              URL重定向
                if data.request:getResponseStatusCode() ~= 200 then
                    if math.floor(data.request:getResponseStatusCode() / 100) == 3 then
                        local tmpUrl
                        local headers = string.split(data.request:getResponseHeadersString(), "\r\n")
                        for k, v in ipairs(headers) do
                            local i, j = string.find(v, "Location: ")
                            if i and j then
                                tmpUrl = string.sub(v, j + 1)
                                break
                            end
                        end

                        if tmpUrl then
                            downloadFromServer(tmpUrl)
--                            self:update(newVerID, tmpUrl)
                        end
                    else
                        onFailed()
                    end
                else
--                    dump(string.split(data.request:getResponseHeadersString(), "\r\n"))
--                    local path = CCFileUtils:sharedFileUtils():getWritablePath() .. "aaa.zip"
--                    local writeLen = data.request:saveResponseData(path)
                    local realLen = data.request:getResponseDataLength()
                    curLen = realLen
                    maxLen = realLen

                    respData = data.request:getResponseData()
                    onSuccess()
                end
            elseif data.name == "failed" then
                printf("aaaa   error:" .. data.request:getErrorMessage())
                onFailed()
            end

        end, "GET")
    end

    downloadFromServer(url)
end

return UpdatingScene