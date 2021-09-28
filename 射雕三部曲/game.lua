--[[
    文件名：game.lua
	描述：游戏进入加载配置及设置文件
	创建人：liaoyuangang
	创建时间：2016.3.29
-- ]]

local game = class("game")

function game:ctor()
    -- 移除所有事件注册
    if MQHandlerHelper:getInstance().removeAllEventHandler then
        MQHandlerHelper:getInstance():removeAllEventHandler()
    end

    self:init()
    self:checkGameVesion()
end

function game:init()
    require("common.Utf8")
    require("common.String")
    require("common.MqTime")
    require("common.MqMath")
    require("common.Adapter")
    require("common.Enums")
    require("common.CardNode")
    require("common.Figure")
    require("common.Ui")
    require("common.MqAudio")
    require("commonLayer.MsgBoxLayer")
    require("commonLayer.PopBgLayer")
    require("common.LayerManager")
    require("common.Utility")
    require("fightResult.ResultUtility")
    require("fightResult.CheckPve")
    require("fightResult.PvpResult")
    require("data.Language")
    require("data.LocalData")
    require("data.Player")
    require("Guide.GuideMgr")
    require("network.NetworkStates")
    require("network.SocketStates")
    require("network.HttpClient")
    require("network.SocketClient")
    Utility.launchStepInfo(2, 0, "game init")

    -- 游戏启动网络请求，仅调用一次
    if NeedLanchRequest then
        self:requestLanchTracking()
        NeedLanchRequest = false
    end
end

-- 检查游戏版本是否有变动，如果有变动则需要清空download目录中的内容（包含客户端版本号和通信版本号）
function game:checkGameVesion()
    -- 当前客户端版本号
    local currClientVer = IPlatform:getInstance():getConfigItem("ClientVersion");
    currClientVer = (currClientVer == "") and "0.0.1" or currClientVer
    local histClientVer = LocalData:getClientVersion() -- 上次登录客户端版本号
    -- 当前通信版本号
    local currGameVersion = IPlatform:getInstance():getConfigItem("Version")
    local histGameVersion = LocalData:getGameVersion() -- 上次登录的通信版本号

    local fileUtilsObj = cc.FileUtils:getInstance();
    local writeablePath = fileUtilsObj:getWritablePath()
    -- 如果当前版本号与历史版本号不一致，则需要清空Download
    if currClientVer ~= histClientVer or currGameVersion ~= histGameVersion then
        -- 删除在线更新的资源目录“Download”
        local tempStr = writeablePath .. "Download/"
        if fileUtilsObj:isDirectoryExist(tempStr) then
            fileUtilsObj:removeDirectory(tempStr)
        end
        -- 删除记录更新资源版本号的文件
        tempStr = writeablePath .. "UserData.txt"
        if fileUtilsObj:isFileExist(tempStr) then  -- 删除记录更新资源版本号的文件
            fileUtilsObj:removeFile(tempStr);
        end
        tempStr = writeablePath .. "versionData.txt"  --
        if fileUtilsObj:isFileExist(tempStr) then  -- 删除记录更新资源版本号的文件
            fileUtilsObj:removeFile(tempStr);
        end

        -- 把最新的版本号写入本地文件
        LocalData:saveVersion({clientVersion = currClientVer, gameVersion = currGameVersion})
    end
end

function game:run()
    -- 停止所有声音(更新再次调用时需要)
    MqAudio.stopMusicEffects()
    -- ”进入游戏“只调用一次
    IPlatform:getInstance():onEnter()
    local debug = IPlatform:getInstance():getConfigItem("Debug")
    if debug ~= "1" then
        dump = function(...) end
        print = function(...) end
        httpDataDump = function(...) end
        release_print = function(...) end
    end

    -- 注册后台、前台事件
    MQHandlerHelper:getInstance():addEventHandler("LUASCRIPT", function(eventName)
        if eventName == "applicationDidEnterBackground" then
            self:applicationDidEnterBackground()
        elseif eventName == "applicationWillEnterForeground" then
            self:applicationWillEnterForeground()
        elseif eventName == "KeyBack" then
            self:androidColseTopLayer()    
        end
    end)

    -- 添加ESC键功能，方便测试
    -- local function onKeyReleased(keyCode, event)
    --     -- dump(string.format("code: %d", keyCode))
    --     -- if keyCode == cc.KeyCode.KEY_BACK then
    --         self:androidColseTopLayer()
    --     -- end
    -- end
    -- local listener = cc.EventListenerKeyboard:create()
    -- listener:registerScriptHandler(onKeyReleased, cc.Handler.EVENT_KEYBOARD_PRESSED )
    -- local eventDispatcher = cc.Director:getInstance():getEventDispatcher()
    -- eventDispatcher:addEventListenerWithFixedPriority(listener, 1)

    -- 登录、登出监听事件
    MQHandlerHelper:getInstance():addEventHandler("LOGIN", function (jsonValue)
        Utility.launchStepInfo(3, 1, "login end")
        print("LOGIN:", jsonValue)
        -- 部分渠道需要的登录回调
        self:requestTracking()
        -- 登录成功，返回到服务器选择 {"uid":"21906036", "token":"bf72b3bcc2583a4b4fa4e5ba40c65f1b", "platformId":"118"}
        LayerManager.addLayer({name="login.StartGameLayer", data = {loginInfo = jsonValue}})
    end)
    MQHandlerHelper:getInstance():addEventHandler("LOGOUT", function(jsonValue)
        local updateResTable = nil
        if string.len(jsonValue) > 1 then
            updateResTable = json.decode(jsonValue)
            -- 防止其它字符串导致进入资源更新
            if not string.find(jsonValue, "ResourceVersionName") then
                updateResTable = nil
            end
        end
        -- Player数据清空
        Player:cleanCache()
        --清空聊天按钮
        if ChatBtnLayer then
            ChatBtnLayer:clearBtn()
        end

        -- 显示登录, 账号登录界面
        LayerManager.addLayer({name = "login.GameLoginLayer", data = {notAutoLogin = true}})
    end)

    -- 启动LOGO
    local thirdLogo1 = IPlatform:getInstance():getConfigItem("ThirdLogo1")
    local thirdLogo2 = IPlatform:getInstance():getConfigItem("ThirdLogo2")
    if thirdLogo1 and cc.FileUtils:getInstance():isFileExist(thirdLogo1) then
        LayerManager.addLayer({name = "login.GameBootLayer", data = {thirdLogo1, thirdLogo2}})
    else
        LayerManager.addLayer({name = "login.GameLoginLayer"})
    end
    Utility.launchStepInfo(2, 1, "game run")
end

function game:applicationDidEnterBackground()
    -- 重置在线奖励数据
    OnlineRewardObj:reset()

    local IsSupportVoice = IPlatform:getInstance():getConfigItem("IsSupportVoice") == "1"
    if IsSupportVoice then
        require("Chat.CloudVoiceMng")
        CloudVoiceMng:Pause()
    end

    --添加推送消息
    -- local settingData = LocalData:getSetting()
    -- if settingData.pushEnabled == true and Player:getCurrentTime() > 0 then
    --     -- 添加正点领取耐力体力推送
    --     local curTimeTable = os.date("*t", Player:getCurrentTime())
    --     local activityTime = 0
    --     local targetTimeTable = clone(curTimeTable)
    --     targetTimeTable.min = 0
    --     targetTimeTable.sec = 0
    --     if targetTimeTable.hour < 12 then
    --         -- 计算到12点的时间差
    --         targetTimeTable.hour = 12
    --     elseif targetTimeTable.hour < 18 then
    --         targetTimeTable.hour = 18
    --     elseif targetTimeTable.hour < 21 then
    --         targetTimeTable.hour = 21
    --     else
    --         -- 计算到第二天的12点的时间差
    --         targetTimeTable.hour = 12
    --         activityTime = 3600 * 24
    --     end
    --     activityTime = activityTime + os.time(targetTimeTable) - os.time(curTimeTable)
    --     print(activityTime, "activityTime")
    --     if activityTime > 0 then
    --         addLocalNotification(TR("夏雨荷已经准备好了至尊盛宴，享用至尊盛宴吧！"), activityTime)
    --     end
    -- end
end

function game:applicationWillEnterForeground()
    require("data.Player")
    require("common.Utility")
    if Player:dataIsInitiated() then -- 如果已经登录了，需要同步服务器数据
        Utility.syncAvatarData()
    end

    local IsSupportVoice = IPlatform:getInstance():getConfigItem("IsSupportVoice") == "1"
    if IsSupportVoice then
        require("Chat.CloudVoiceMng")
        CloudVoiceMng:Resume()
    end
end

-- 为某些渠道请求额外的接口
function game:requestTracking()
    local configPartnerId = IPlatform:getInstance():getConfigItem("PartnerID")
    if configPartnerId == "6666005" then
        local idfa = IPlatform:getInstance():getDeviceUUID()
        local md5Sign = string.md5Content(configPartnerId .. idfa .. os.date("%Y-%m-%d", os.time()))
        -- 无回调请求
        local xhr = cc.XMLHttpRequest:new()
        xhr.responseType = cc.XMLHTTPREQUEST_RESPONSE_STRING
        xhr:open("GET", string.format("http://tracking.moqikaka.com/PuZanAD/Send?partnerid=%s&idfa=%s&sign=%s", configPartnerId, idfa, md5Sign))
        xhr:setUnzip(false)
        xhr:send()
    end
end

-- 进入游戏调用接口，仅调用一次
function game:requestLanchTracking()
    local platform = IPlatform:getInstance()
    local configPartnerId = platform:getConfigItem("PartnerID")
    if configPartnerId == "6666005" or configPartnerId == "6666007" or configPartnerId == "6666015" then
        local postAdSrc = "HY"
        if configPartnerId == "6666005" then
            postAdSrc = "sddx6-2"
        end
        -- 组装post数据
        local postTable = {AdSrc = postAdSrc, 
            AppId = "sdyxz001ios",
            MAC = platform:getDeviceMAC(), 
            DeviceId = platform:getDeviceUUID(),}
        -- 无回调请求
        local xhr = cc.XMLHttpRequest:new()
        xhr.responseType = cc.XMLHTTPREQUEST_RESPONSE_STRING
        xhr:open("POST", "http://hotcloud.moqikaka.com/API/register?")
        xhr:setUnzip(false)
        xhr:send(cjson.encode(postTable))
    end
end

function game:androidColseTopLayer()
    local function isCloseImageName(image)
        local imageTable = {"c_29.png", "c_175.png"}
        for _,v in ipairs(imageTable) do
            if v == image then
                return true
            end
        end
        return false
    end
    local function findLayerCloseButton(parent, count)
        if parent.normalImage and isCloseImageName(parent.normalImage) and parent.mClickAction then
            parent.mClickAction(parent)
            return true
        end
        if parent:getChildren() and count < 3 then
            for i, v in ipairs(parent:getChildren()) do
                if findLayerCloseButton(v, count + 1) then
                    return true
                end
            end
        end
    end
    local function isNeedChangeToHome(name)
        local changeList = {"team.TeamLayer", "battle.BattleMainLayer", "activity.ActivityMainLayer", "recharge.FirstRechargeLayer"}
        for _,v in ipairs(changeList) do
            if v == name then
                return true
            end
        end
        return false
    end
    -- 新手引导中不触发back
    local curScene = display.getRunningScene()
    local isInGuide = Guide.manager:isInGuide()
    -- 战斗中toplayer为空(battlescene未使用layermanger管理)
    if not tolua.isnull(LayerManager.getTopLayer()) and not isInGuide and not HttpClient.mIsRequesting then
        if isNeedChangeToHome(LayerManager.getTopCleanLayerName()) then
            -- 部分界面默认返回到首页
            LayerManager.addLayer({name = "home.HomeLayer", isRootLayer = true})
        elseif not findLayerCloseButton(LayerManager.getTopLayer(), 0) then
            MsgBoxLayer.addOKCancelLayer(
                TR("退出游戏？"),
                TR("提示"),
                {
                    text = TR("确定"),
                    clickAction = function(layerObj, btnObj)
                        cc.Director:getInstance():endToLua()
                    end
                },
                {
                    text = TR("取消")
                }
            )
        end
    end
end

return game
