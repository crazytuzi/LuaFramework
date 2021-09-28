--[[
    文件名：StartGameLayer.lua
    描述：开始游戏界面
    创建人：heguanghui
    创建时间：2017.3.6
-- ]]

local StartGameLayer = class("StartGameLayer", function(params)
    return display.newLayer()
end)

-- 是否已经预加载配置文件和通用图片资源
local HadPreLoadResource = false

--[[
-- 参数 params＝ {
        loginInfo = userId, -- 登录信息
        testLoginData = nil, -- 试登录数据
    }
 ]]
function StartGameLayer:ctor(params)
    --dump(params, "StartGameLayer:ctor params is:")
    self.mServerInfoList = {}

    if params.loginInfo then  -- 如果 loginInfo 不为nil，说明玩家刚才执行了账户登录，需要清空缓存的账户登录数据
        local tempData = json.decode(params.loginInfo)
        local partnerId = IPlatform:getInstance():getConfigItem("PartnerID")
        Player:setUserLoginInfo({
            PartnerId = tostring(tempData.platformId or partnerId),
        }, true)

        self.mLoginInfo = params.loginInfo
    elseif params.testLoginData then  -- 试登录数据
        Player:setUserLoginInfo({}, true)
        self.mTestLoginData = params.testLoginData
    end

    -- 创建背景layer
    local tempLayer = require("login.LoginBgLayer"):create()
    self:addChild(tempLayer)

    -- 创建该页面的父节点
    self.mParentLayer = ui.newStdLayer()
    self:addChild(self.mParentLayer)

    -- 创建页面控件
    self:initUI()

    -- 创建试登录打开暗门相关逻辑
    local tempLayer = ui.createTestTrapdoor()
    self:addChild(tempLayer)
end

-- 创建页面控件
function StartGameLayer:initUI()
    -- 显示已选中服务器（是一个按钮，点击可以打开服务器列表）
    local tempBtn = ui.newButton({
        normalImage = "dl_02.png",
        text = "",
        size = cc.size(350, 50),
        -- textColor = cc.c3b(0x2F, 0x3F,0x61),
        textColor = Enums.Color.eNormalWhite,
        outlineColor = Enums.Color.eBlack,
        clickAction = function()
            local function callServerListLayer()
                if not self.mServerInfoList or #self.mServerInfoList == 0 then
                    ui.showFlashView({parent = self, text = TR("未获取到服务器列表")})
                    return
                end

                LayerManager.addLayer({name = "login.ServerListLayer",
                    cleanUp = false,
                    data = {srvInfoList = self.mServerInfoList,
                        historyServerIdList = self.mHistoryServerIdList,
                        callback = function(server)
                            if not server then
                                return
                            end
                            self.mSelectServer = server
                            Player:setSelectServer(self.mSelectServer)
                            self:refreshServerInfo()
                        end
                    }
                })
            end

            -- 当玩家点击服务器列表时，每次都获取服务器最新的列表信息
            if self.mTestLoginData then
                self:requestTestServerList(callServerListLayer)
            else
                self:requestServerList(callServerListLayer)
            end
        end,
    })
    tempBtn:setPosition(320, 300)
    self.mParentLayer:addChild(tempBtn)
    self.mSelSvrBtn = tempBtn

    -- 开始按钮
    local tempBtn = ui.newButton({
        normalImage = "xdl_06.png",
        position = cc.p(320, 220),
        text = TR(""),
        clickAction = function()
            if not self.mSelectServer then
                ui.showFlashView({parent = self, image = nil,text = TR("请先选择登录的服务器！")})
                return
            end

            -- 请求登陆游戏服务器
            local function callLogin()
                Utility.launchStepInfo(4, 0, "click start game")
                if self.mTestLoginData then
                    self:requestTestLogin()
                else
                    if IPlatform:getInstance():getConfigItem("Channel") == "MQKK" or device.platform ~= "ios" then
                        self:requestLogin()
                    else
                        -- 繁体版加sdk验证服务器开关
                        print("开始隆中服务器验证")
                        local serveridVerify = {
                            ServerID = tostring(self.mSelectServer.ServerID)
                        }
                        local jstr = json.encode(serveridVerify)

                        IPlatform:getInstance():invoke("ServerIDVerify",jstr, function(jsonStr) 
                            local data = cjson.decode(jsonStr)
                            if data["ret"] == "0" then
                                print("隆中服务器验证===成功")
                                self:requestLogin()
                            else
                                --失败
                                print("隆中服务器验证===失败")
                                ui.showFlashView(TR("该区暂未开启！！"))
                            end
                        end)
                    end
                    
                end
            end

            if self.mSelectServer.ServerState ~= 1 then
                self:requestServerList(function()
                    local tempState = self.mSelectServer.ServerState
                    -- 刷新后服务器状态变为正常了，请求登陆游戏服务器
                    if tempState == 1 then
                        callLogin()
                        return
                    end

                    -- 刷新后服务器还是维护状态，就提示玩家正在维护
                    local hintStr = self.mSelectServer.MaintainMessage
                    if not hintStr or hintStr == "" then
                        hintStr = TR("服务器正在维护, 请稍候再试！")
                    end
                    ui.showFlashView({text = hintStr})
                end)
                return
            end

            -- 请求登陆游戏服务器
            callLogin()
        end
    })
    self.mParentLayer:addChild(tempBtn)

    -- 切换帐号(非内测包不显示切换帐号，在SDK中切换)
    local loginBtn = ui.newButton({
        normalImage = "gd_09.png",
        position = cc.p(75, 215),
        clickAction = function()
            if IPlatform:getInstance():getConfigItem("Channel") == "MQKK" then
                LayerManager.addLayer({name = "login.GameLoginLayer", data = {notAutoLogin = true}})
            else
                IPlatform:getInstance():logout()
            end
        end
    })
    self.mParentLayer:addChild(loginBtn)

    -- 客服中心按钮
    local customerBtn = ui.newButton({
            normalImage = "hyzx_02.png",
            position = cc.p(565, 215),
            clickAction = function()
                IPlatform:getInstance():invoke("OpenGDCustomerService", "", function() end)
            end
        })
    self.mParentLayer:addChild(customerBtn)

    -- 创建版本号信息
    -- 游戏版本号
    local gameVer = IPlatform:getInstance():getConfigItem("ClientVersion");
    local tempList = string.splitBySep(gameVer, "_")
    local tempLabel = ui.newLabel({
        text = TR("游戏版本:%s", tempList[1] or ""),
        size = 20,
    })
    tempLabel:setAnchorPoint(cc.p(1, 0.5))
    tempLabel:setPosition(635, 75)
    self.mParentLayer:addChild(tempLabel)
    -- 通信版本号
    local version = IPlatform:getInstance():getConfigItem("Version")
    local tempLabel = ui.newLabel({
        text = TR("通信版本:%s", version),
        size = 20,
    })
    tempLabel:setAnchorPoint(cc.p(1, 0.5))
    tempLabel:setPosition(635, 50)
    self.mParentLayer:addChild(tempLabel)
    -- 资源版本号
    local rvLabel = ui.newLabel({
        text = TR("资源版本:%s", LocalData:getResourceName()),
        size = 20,
    })
    rvLabel:setAnchorPoint(cc.p(1, 0.5))
    rvLabel:setPosition(635, 25)
    self.mParentLayer:addChild(rvLabel)

    --左下角图片展示
    local configPartnerId = IPlatform:getInstance():getConfigItem("PartnerID")
    if configPartnerId == "800" or configPartnerId == "500" or configPartnerId == "400" then
        local tempPic = ui.newSprite("xdl_09.png")
        tempPic:setAnchorPoint(0, 0)
        tempPic:setPosition(10, 40)
        self.mParentLayer:addChild(tempPic)
    end


    -- 出版提示
    local hintLabel = ui.newLabel({
            text = TR("金庸正版授權 完美世界研發\n蘇州天魂與香港晶綺聯合發行"),
            color = cc.c3b(0xa9, 0x84, 0xb8),
            size = 20,
        })
    hintLabel:setAnchorPoint(cc.p(0, 0.5))
    hintLabel:setPosition(5, 67)
    self.mParentLayer:addChild(hintLabel)
end

-- 进入该页面的函数
function StartGameLayer:onEnterTransitionFinish()
    if self.mTestLoginData then
        self:requestTestServerList(function()
            self:preLoadResource()
        end)
    else
        self:requestServerList(function()
            self:preLoadResource()
        end)
    end
end

-- 配置文件和图片资源预加载
function StartGameLayer:preLoadResource()
    if HadPreLoadResource then
        return
    end

    self.mParentLayer:setVisible(false)
    local preLayer = require("login.PreLoadLayer"):create({endCallback = function()
        self.mParentLayer:setVisible(true)
        HadPreLoadResource = true
    end})
    self:addChild(preLayer)
end

-- 刷新选中服务器信息
--[[
-- 服务器状态：
    ServerState: 服务器状态（1：正常，2：维护）
    ServerHeat: 服务器热度 （1: 正常, 2: 新服, 3: 推荐）
]]
function StartGameLayer:refreshServerInfo()
    local tempInfo = self.mSelectServer or {}
    local statusStr = TR("(正常)")
    if tempInfo.ServerState == 2 then
        statusStr = TR("(维护)")
    else -- 正常状态下的热度状态
        if tempInfo.ServerHeat == 2 then
            statusStr = TR("(新服)")
        elseif tempInfo.ServerHeat == 3 then
            statusStr = TR("(推荐)")
        end
    end

    local serverName = tempInfo.ServerName or ""

    self.mSelSvrBtn:setTitleText(statusStr .. serverName)
end

-- 选择默认游戏服务器
function StartGameLayer:selectDefaultServer()
    if not self.mServerInfoList or #self.mServerInfoList == 0 then
        return
    end

    -- 如果之前已经选择过服务器, 优先显示之前选中的服务器
    if next(self.mSelectServer or {}) then
        for _, item in pairs(self.mServerInfoList) do
            if item.ServerGroupID == self.mSelectServer.ServerGroupID then
                return item
            end
        end
    end

    -- 首先查找最近访问服务器
    if self.mHistoryServerIdList and #self.mHistoryServerIdList > 0 then
        local otherDefault = nil
        local tempId = tonumber(self.mHistoryServerIdList[1])
        for _, item in ipairs(self.mServerInfoList) do
            if item.ServerID == tempId then
                return item
            end
            if not otherDefault then
                if item.ServerState == 1 and item.ServerHeat == 2 then
                    otherDefault = item
                end
            end
        end
        if otherDefault then
            return otherDefault
        end
    end
    -- 假如 热门：4 正常：1 新服：2 推荐：3
    -- 按推荐顺序排序（推荐>新服>热门>正常）
    table.sort(self.mServerInfoList, function (item1, item2)
        -- 服务器是否可以登录
        if item1.ServerState ~= item2.ServerState then
            return item1.ServerState == 1
        end

        -- 服务器推荐
        if item1.ServerHeat ~= item2.ServerHeat then
            if item1.ServerHeat > 3 then
                return item2.ServerHeat <= 1
            elseif item2.ServerHeat > 3 then
                return item1.ServerHeat > 1
            end
            
            return item1.ServerHeat > item2.ServerHeat
        end

        return false
    end)
    -- 返回第一个服务器(推荐)
    return self.mServerInfoList[1]
end

-- 在线更新提示
function StartGameLayer:showResUpdateHint(resourceList)
    local tempData = {
        title = TR("资源更新"),
        msgText = TR("有新的资源需要更新，是否立即下载"),
        btnInfos = {
            {    -- 退出按钮
                text = TR("退出"),
                clickAction = function()
                    IPlatform:getInstance():destroy()
                end
            },
            {
                text = TR("确定"),
                clickAction = function(layerObj, btnObj)
                    LayerManager.removeLayer(layerObj)
                    LayerManager.addLayer({name = "login.UpdateResourceLayer", data = resourceList, cleanUp = false})
                end
            },
        }
    }

    -- 检查是否支持预先获取更新大小
    local MANIFEST_FILE = "project.manifest"
    local STORAGE_PATH = cc.FileUtils:getInstance():getWritablePath()
    if cc.Application:getInstance():getTargetPlatform() == cc.PLATFORM_OS_MAC then
        STORAGE_PATH = STORAGE_PATH .. "shediao/"
    end
    STORAGE_PATH = STORAGE_PATH .. "Download/"
    local am_ = require("login.AssetsMgr").new{
        manifest = MANIFEST_FILE,
        storage  = STORAGE_PATH,
        max_thread = 10,
    }

    local tipsLayer = LayerManager.addLayer({
        name    = "commonLayer.MsgBoxLayer",
        data    = tempData,
        cleanUp = false,
        zOrder  = Enums.ZOrderType.eNetErrorMsg,
    })
    if am_.preDownloadManifest then
        local boxHintLabel = tipsLayer:getMsgLabel()

        am_:setPackageUrl(resourceList["Url"], resourceList["ResourceVersionName"])
        boxHintLabel:setString(TR("正在检查更新"))
        for k, v in pairs(tipsLayer:getBottomBtns() or {}) do
            v:setVisible(false)
        end

        local function set_visible()
            for k, v in pairs(tipsLayer:getBottomBtns() or {}) do
                v:setVisible(true)
            end
        end
        am_
            :on(cc.EventAssetsManagerEx.EventCode.UPDATE_PROGRESSION, function(event)
                if tolua.isnull(tipsLayer) then
                    return
                end
                local assetId = event:getAssetId()
                local percent = event:getPercent()

                if assetId == cc.AssetsManagerExStatic.MANIFEST_ID then
                    boxHintLabel:setString(TR("正在检查更新 %d%%", percent))
                end
            end)
            :on(cc.EventAssetsManagerEx.EventCode.NEW_VERSION_FOUND, function()
                if tolua.isnull(tipsLayer) then
                    return
                end

                local bytes = am_:getDownloadSize()
                boxHintLabel:setString(TR("有新的资源需要更新（%s），是否立即下载", Utility.btyeToViewStr(bytes)))
                set_visible()
                am_:release()
            end)
            :on(cc.EventAssetsManagerEx.EventCode.ALREADY_UP_TO_DATE, function()
                if tolua.isnull(tipsLayer) then
                    return
                end

                LayerManager.removeLayer(tipsLayer)
                am_:release()
            end)
            :on(cc.EventAssetsManagerEx.EventCode.ERROR_DOWNLOAD_MANIFEST, function()
                if tolua.isnull(tipsLayer) then
                    return
                end

                boxHintLabel:setString(TR("有新的资源需要更新，是否立即下载"))
                set_visible()
                am_:release()
            end)
            :preDownloadManifest()
    else
        am_:release()
    end
end

-- 播放取名前的战斗
function StartGameLayer:playRoleBeforeFight()
    LayerManager.addLayer({name = "login.RoleCreateLayer", data = {}})
    -- 播放第一场战斗
    -- local battleData = require("ComBattle.BattleGuideConfig.BattleScript0000")
    -- LayerManager.addLayer {
    --     name = "ComBattle.BattleLayer",
    --     data = {
    --         data = battleData,
    --         skip = {
    --             viewable = true,
    --             clickable = function()
    --                 return true
    --             end,
    --             executable = function()
    --                 return true
    --             end
    --         },
    --         callback = function(ret)
    --             LayerManager.addLayer({name = "login.RoleCreateLayer", data = {}})
    --         end
    --     },
    -- }
end

--- ==================== 服务器数据请求相关 =======================
-- 获取服务器列表的数据请求
function StartGameLayer:requestServerList(afterResponse)
    local platform = IPlatform:getInstance()
    local loginInfo = Player:getUserLoginInfo()
    local tempPartnerID = loginInfo and loginInfo.PartnerId
    local randNum = MqMath.random()
    local gameVersion = platform:getConfigItem("Version")
    local userInfo = Player:getUserLoginInfo()
    local userID = userInfo and userInfo.UserID

    local loginInfoStr
    if not userID then
        local infoIsTable = type(self.mLoginInfo) == "table"
        loginInfoStr = infoIsTable and json.encode(self.mLoginInfo) or self.mLoginInfo
    end
    local encryptStr = tempPartnerID..gameVersion..tostring(randNum)..platform:getConfigItem("LoginKey")

    local tempData = {}
    tempData.gameID = 0
    tempData.PartnerID = tempPartnerID
    tempData.GameVersionID = gameVersion
    tempData.RandNum = randNum
    tempData.EncryptedString = string.md5Content(encryptStr)
    tempData.ResourceVersionName = LocalData:getResourceName()
    tempData.UserID = userID
    tempData.LoginInfo = loginInfoStr or ""

    HttpClient:request({
        svrType = HttpSvrType.eManageCenter,
        urlName = "login",
        svrMethodData = tempData,
        useDecrypt = false,
        callback = function(value)
            self:responseServerList(value, afterResponse)
        end,
        callbackNode = self,
    })
end

-- 获取服务器列表返回的数据处理
function StartGameLayer:responseServerList(value, afterResponse)
    -- local value =  {
    --     Message = "HaveNewResource",
    --     Data = {
    --         Resource = {
    --             {
    --                 ResourceVersionID = 5,
    --                 MD5 = "2E604FE993F7036A5DEDFBC942D387C8",
    --                 IfDelete = 0,
    --                 Url = "http://resource.dzz.moqikaka.com/20160324-125600-b3a35920-53e60333-1.zip",
    --                 IfRestart = 0,
    --                 Size = 28629260,
    --             },
    --             {
    --                 ResourceVersionID = 6,
    --                 MD5 = "CF1DF4A25644FB97B18DE54A06A5BA68",
    --                 IfDelete = 0,
    --                 Url = "http://resource.dzz.moqikaka.com/20160324-145537-5b8fda5b-4fe76cf7-1.zip",
    --                 IfRestart = 0,
    --                 Size = 2573396,
    --             },
    --         },
    --         Server = {
    --         },
    --     },
    --     Code = 6,
    -- }

    if value.Code == 0 then -- 获取数据成功
         -- 最近访问服务器列表Id
        self.mHistoryServerIdList = value.Data.ServerHistory
        -- 排序服务器列表
        self.mServerInfoList = value.Data.Server

        -- 缓存账户登录相关信息
        if value.Data.UserInfo then
            Player:setUserLoginInfo(value.Data.UserInfo)
        end
        -- 获取默认选中的服务器列表
        self.mSelectServer = self:selectDefaultServer()

        if self.mSelectServer then
            Player:setSelectServer(self.mSelectServer)
            self:refreshServerInfo()
        end

        -- 判断是否有在线资源更新
        if afterResponse then
            afterResponse()
        end

        -- 天魂调idfa接口
        if not LocalData:getGameDataValue("LoginSendIDFATH") then
            self:requestTHTracking()
            LocalData:saveGameDataValue("LoginSendIDFATH", true)
        end

    elseif value.Code == 6 then  -- 有资源更新
        self:showResUpdateHint(value.Data.Resource)
    else
        local tempStr = NetworkStates.server[value.Code] or TR("未知错误，错误码：%d", value.Code or value.Status)
        local okBtnInfo = {
            text = TR("重试"),
            needCloseBtn = false,
            clickAction = function(msgLayer, btnObj)
                LayerManager.removeLayer(msgLayer)

                if self.mTestLoginData then
                    LayerManager.addLayer({name = "login.TestLoginLayer",})
                else
                    self:requestServerList(afterResponse)
                end
            end
        }
        MsgBoxLayer.addOKLayer(tempStr, TR("提示"), {okBtnInfo})
    end
end

-- 获取试登录的服务器列表
function StartGameLayer:requestTestServerList(afterResponse)
    local partnerID = self.mTestLoginData.partnerId
    local gameVersion = self.mTestLoginData.versionId
    local randNum = math.random(99, 9999)
    local encryptStr = partnerID..gameVersion..tostring(randNum)..self.mTestLoginData.loginKey

    local tempData = {}
    tempData.gameID = 0
    tempData.PartnerID = partnerID
    tempData.GameVersionID = gameVersion
    tempData.UserID = self.mTestLoginData.userId
    tempData.RandNum = tostring(randNum)
    tempData.EncryptedString = string.md5Content(encryptStr)
    tempData.ResourceVersionName = LocalData:getResourceName()

    HttpClient:request({
        svrType = HttpSvrType.eManageCenter,
        urlName = "login",
        svrMethodData = tempData,
        useDecrypt = false,
        callback = function(value)
            self:responseServerList(value, afterResponse)
        end,
        callbackNode = self,
    })
end

-- 玩家登录游戏服务器数据请求
function StartGameLayer:requestLogin()
    local userLoginInfo = Player:getUserLoginInfo()
    local platform = IPlatform:getInstance()
    local partnerId = userLoginInfo and userLoginInfo.PartnerId
    local serverId = self.mSelectServer.ServerID
    local randNum = math.random(99, 9999)
    local loginKey = platform:getConfigItem("LoginKey")
    local osType = platform:getOSType()
    local osVersion = platform:getOSVersion()
    local encryptedStr = string.md5Content(partnerId..serverId..randNum..loginKey)

    local function networkRequestLogin(openId, isQQ)
        local userInfo = Player:getUserLoginInfo()
        local userExtraData = userInfo.ExtraData
        if not userExtraData then
            userInfo.ExtraData = {}
        elseif type(userExtraData) == "string" then
            userInfo.ExtraData = cjson.decode(userExtraData)
        end
        userInfo.ExtraData.OpenId = openId
        userInfo.ExtraData.LoginType = isQQ
        local sendExtra = cjson.encode(userInfo.ExtraData)
        local tempData = {osType, osVersion, randNum, encryptedStr, userInfo.LoginInfo or "", userInfo.UserID or "", sendExtra}
    
        HttpClient:request({
            svrType = HttpSvrType.eGame,
            moduleName = "Player",
            methodName = "Login",
            svrMethodData = tempData,
            callback = function(response)
                self:responseLogin(response)
            end,
            callbackNode = self,
        })
    end
    -- 判断是否是手Q登录
    local loginParams = type(self.mLoginInfo) == "table" and self.mLoginInfo or cjson.decode(self.mLoginInfo)
    if loginParams.type == "QQ" then
        self:requestQQInfo(networkRequestLogin)
    else
        networkRequestLogin("", 0)
    end
end

-- 玩家登录游戏服务器返回的数据处理
function StartGameLayer:responseLogin(response)
    -- 登录游戏服务器失败
    if not response or response.Status ~= 0 then
        return
    end
    if not response.Value then
        ui.showFlashView(TR("服务器返回登录数据为空"))
        return
    end

    PlayerAttrObj:setPlayerInfo(response.Value)

    if response.Value.IsNewPlayer then -- 新玩家
        self:playRoleBeforeFight()
    else -- 获取玩家初始化数据
        self:requestInitData()
    end
    Utility.launchStepInfo(4, 1, "step over")
end

-- 玩家试登录游戏服务器的数据请求
function StartGameLayer:requestTestLogin()
    local platform = IPlatform:getInstance()
    local osType = platform:getOSType()
    local osVersion = platform:getOSVersion()

    local partnerId = self.mTestLoginData.partnerId
    local serverId = self.mSelectServer.ServerID
    local randNum = math.random(99, 9999)
    local loginKey = self.mTestLoginData.loginKey
    local encryptedString = string.md5Content(partnerId..serverId..randNum..loginKey)

    local requestData = {
        osType,
        osVersion,
        randNum,
        encryptedString,
        self.mTestLoginData.userId,
        self.mTestLoginData.playerName
    }

    HttpClient:request({
        svrType = HttpSvrType.eGame,
        moduleName = "Player",
        methodName = "Login_ForTest",
        svrMethodData = requestData,
        callback = function(response)
            self:responseLogin(response)
        end,
        callbackNode = self,
    })
end

-- 获取玩家初始化数据的数据请求
function StartGameLayer:requestInitData()
    HttpClient:request({
        svrType = HttpSvrType.eGame,
        moduleName = "Player",
        methodName = "GetInitData",
        svrMethodData = {},
        callbackNode = self,
        callback = function(response)
            if not response or response.Status ~= 0 then
                return
            end

            Player:updateInitData(response.Value)

            -- 给平台设置进入游戏的统计信息
            Utility.cpInvoke("EnterGame")

            -- 进入引导
            Guide.manager:enterGame()
        end,
    })
end

-- 获取手Q玩家的信息
function StartGameLayer:requestQQInfo(callback)
    local isSvip = false
    -- 获取手Qid回调
    local function openIdCallBack(jsonStr)
        local data = cjson.decode(jsonStr)
        callback(data.openId, isSvip and 2 or 1)
    end
    -- 获取手Qsvip回调
    local function svipCallBack(jsonStr)
        local data = cjson.decode(jsonStr)
        isSvip = data["ret"] == "0"
        -- 请求openid
        IPlatform:getInstance():invoke("GetQQOpenId","", openIdCallBack)
    end
    IPlatform:getInstance():invoke("GetSvipInfo","", svipCallBack)
end

-- 天魂要求idfa接口
function StartGameLayer:requestTHTracking()
    local platform = IPlatform:getInstance()
    local configPartnerId = platform:getConfigItem("PartnerID")
    if configPartnerId == "6666014" or configPartnerId == "6666016" then
        -- 无回调请求(发送天魂)
        local xhr1 = cc.XMLHttpRequest:new()
        xhr1.responseType = cc.XMLHTTPREQUEST_RESPONSE_STRING
        xhr1:open("GET", string.format("http://operation.fx_sdmqapi.moqikaka.com/advert/click?source=%s&appid=%s&idfa=%s&callback=%s&parameter=%s", configPartnerId, 1412638034, platform:getDeviceUUID(), "", 1))
        xhr1:setUnzip(false)
        xhr1:send()
        -- 请求获取回调地址
        local xhr2 = cc.XMLHttpRequest:new()
        xhr2.responseType = cc.XMLHTTPREQUEST_RESPONSE_STRING
        xhr2:open("GET", string.format("http://operation.fx_sdmqapi.moqikaka.com/advert/callbackUrl?appid=%s&idfa=%s&parameter=%s", 1412638034, platform:getDeviceUUID(), 0))
        xhr2:setUnzip(false)

        xhr2:registerScriptHandler(function(event)
        	print("event", event)
            if event == "SUCCESS" then
                response = cjson.decode(xhr2.response)
                dump(response)
                if response.callback and response.callback ~= "" then
                    local xhr3 = cc.XMLHttpRequest:new()
                    xhr3.responseType = cc.XMLHTTPREQUEST_RESPONSE_STRING
                    xhr3:open("GET", response.callback)
                    xhr3:setUnzip(false)
                    xhr3:send()
                end
            elseif event == "ERROR" then    -- 重发
                xhr1:send()
                xhr2:send()
            end
        end)
        xhr2:send()
    end
end

return StartGameLayer
