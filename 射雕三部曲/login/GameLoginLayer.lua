--[[
    文件名：GameLoginLayer.lua
	描述：游戏登录Layer
    创建人：heguanghui
    创建时间：2017.3.6
-- ]]

-- require("common.LoadingWait")
-- require("Network.HttpClient")
local scheduler = cc.Director:getInstance():getScheduler()

local autoLoginSchedule = nil -- 延迟自动登录的计时器

local GameLoginLayer = class("GameLoginLayer", function(params)
    return display.newLayer()
end)

-- 构造函数
--[[
    params:
    Table params:
    {
        notAutoLogin    -- 是否取消自动登录，可选参数，默认为false
    }
--]]
function GameLoginLayer:ctor(params)
     --创建背景layer
     local bgLayer = require("login.LoginBgLayer"):create()
     self:addChild(bgLayer)

     -- 创建该页面的父节点
     self.mParentLayer = ui.newStdLayer()
     self:addChild(self.mParentLayer)

    Player:cleanCache()  -- 这样做的目的是考虑重新登录的情况
    local channel = IPlatform:getInstance():getConfigItem("Channel")
    self.mIsMqkk = (not channel or channel == "" or string.lower(channel) == "mqkk")
    self.notAutoLogin = (params and params.notAutoLogin) or false

    if self.mIsMqkk then
        self:createMqkkUI()
    else
        self:createThirdPlatformUI()
    end

    -- 创建试登录打开暗门相关逻辑
    local tempLayer = ui.createTestTrapdoor()
    self:addChild(tempLayer)
end

-- 创建摩奇卡卡账户登录相关控件
function GameLoginLayer:createMqkkUI()
    self.mPasswardChange = false
    self.mLoginInfo = LocalData:getLoginAccount() or {}

    local function pswEditBoxTextEventHandle(event,pSender)
        if event == "began" then
            self.mPasswardChange = true
        end
    end

    --账号
    self.mEmailEditBox = ui.newEditBox({
        image = "dl_02.png",
        size = cc.size(350, 56),
        fontSize = 26,
        fontColor = Enums.Color.eNormalWhite,
    })
    self.mEmailEditBox:setPosition(cc.p(320, 450))
    self.mEmailEditBox:setPlaceHolder(TR("账号"))
    self.mParentLayer:addChild(self.mEmailEditBox)

    --密码
    self.mPswEditBox = ui.newEditBox({
        image = "dl_02.png",
        size = cc.size(350, 56),
        fontSize = 24,
        fontColor = Enums.Color.eNormalWhite,
    })
    self.mPswEditBox:setInputFlag(0)
    self.mPswEditBox:setPosition(cc.p(320, 380))
    self.mPswEditBox:setPlaceHolder(TR("密码"))
    self.mPswEditBox:registerScriptEditBoxHandler(pswEditBoxTextEventHandle)
    self.mParentLayer:addChild(self.mPswEditBox)

    if self.mLoginInfo then
        self.mEmailEditBox:setText(self.mLoginInfo.account)
        self.mPswEditBox:setText(self.mLoginInfo.verify)
    end

    -- 登 录
    local loginBtn = ui.newButton({
        normalImage = "c_28.png",
        text = TR("登录"),
        position = cc.p(450, 280),
        clickAction = function()
            if not string.isEmail(self.mEmailEditBox:getText()) then
                ui.showFlashView({parent = self, image = nil, text = TR("账号输入有误！")})
                return
            end
            if not string.isValided(self.mPswEditBox:getText()) then
                ui.showFlashView({parent = self, image = nil, text = TR("密码输入错误！")})
                return
            end
            local loginInfo = {}
            loginInfo.account = self.mEmailEditBox:getText()
            if self.mLoginInfo and self.mPasswardChange == false then
                loginInfo.verify = self.mLoginInfo.verify
            else
                loginInfo.verify = string.md5Content(self.mPswEditBox:getText())
            end
            self:requestAccountLogin(loginInfo)
        end,
    })
    self.mParentLayer:addChild(loginBtn)

    -- 注册账号
    local tempBtn = ui.newButton({
        normalImage = "c_28.png",
        text = TR("注册"),
        position = cc.p(200, 280),
        clickAction = function()
            -- LayerManager.addLayer({name = "login.UpdateResourceLayer", data = {ResourceVersionName = "aaa", Url = "wwww.baidu.com"}})

            LayerManager.addLayer({name = "login.RegisterLayer"})
        end,
    })
    self.mParentLayer:addChild(tempBtn)

    -- 延时自动登录
    if not self.notAutoLogin and string.isEmail(self.mEmailEditBox:getText()) and string.isValided(self.mPswEditBox:getText()) then
        Utility.performWithDelay(loginBtn, loginBtn.mClickAction, 0.5)
    end
end

function GameLoginLayer:createThirdPlatformUI()
    -- 登 录
    local tempBtn = ui.newButton({
        normalImage = "c_28.png",
        text = TR("登录"),
        position = cc.p(320, 100),
        clickAction = function()
            Utility.launchStepInfo(3, 0, "login beg")
            IPlatform:getInstance():login()
        end,
    })
    self.mParentLayer:addChild(tempBtn)
end

function GameLoginLayer:onEnterTransitionFinish()
    
    --判断是否需要解压分包
    local fileUtils = cc.FileUtils:getInstance()
    local obbFilePath = IPlatform:getInstance():getConfigItem("ObbMain")

    if fileUtils:isFileExist(obbFilePath) then  --
        local downloadPath = fileUtils:getWritablePath() .. "Download/"
        if not fileUtils:isDirectoryExist(downloadPath) then
            fileUtils:createDirectory(downloadPath)
        end
        if not fileUtils:isFileExist(downloadPath .. "obbhaveUnzip") then  -- 需要重新解压obb包
            IPlatform:getInstance():invoke("SdkIsInit",jstr, function(jsonStr) 
                local data = cjson.decode(jsonStr)
                    if data["ret"] == "0" then
                        self:unzipObbFile(obbFilePath, downloadPath)
                    else
                        self:autoLogin()
                    end
                end)
            return
        end
    end

    self:autoLogin()
end

--- ==================== 服务器数据请求相关 =======================

--- 摩奇卡卡帐号服务器帐号登录
function GameLoginLayer:requestAccountLogin(loginInfo)
    self.mLoginInfo = loginInfo

    HttpClient:request({
        svrType = HttpSvrType.eMqkkAccount,
        urlName = "login",
        svrMethodData = {email = loginInfo.account, pwd = loginInfo.verify},
        useUnzip = false,
        callback = handler(self, self.responseAccountLogin),
        callbackNode = self,
    })
end

-- 摩奇卡卡帐号服务器登录结果处理
function GameLoginLayer:responseAccountLogin(response)
    if response.State ~= 1 then
        return
    end
    if not Utility.valueIsEmpty(response.Result.UserID) then
        -- 保存账号信息
        LocalData:saveLoginAccount(self.mLoginInfo)

        local tempParams = {
            loginInfo = json.encode({sessionId = response.Result.UserID}),
        }
        LayerManager.addLayer({name = "login.StartGameLayer", data = tempParams})
    end
end

function GameLoginLayer:unzipObbFile(obbFilePath, destPath)
    local tempLayer = cc.LayerColor:create(cc.c4b(0, 0, 0, 168))
    tempLayer:setPosition(display.cx, display.cy)
    tempLayer:setAnchorPoint(cc.p(0.5, 0.5))
    tempLayer:setContentSize(cc.size(640, 1136))
    tempLayer:setIgnoreAnchorPointForPosition(false)
    tempLayer:setScale(Adapter.MinScale)
    self:addChild(tempLayer, 1024)

    -- 提示信息
    local hintLabel = ui.newLabel({
        text = TR("正在解壓資源，請稍後..."),
        size = 30,
        outlineSize = 2,
        outlineColor = Enums.Color.eBlack,
        x = 320,
        y = 218,
    })
    tempLayer:addChild(hintLabel)

    -- 进度条
    local tempProgBar = require("common.ProgressBar"):create({
        bgImage = "hj_6.png",
        barImage = "hj_7.png",
        currValue = 0,
        maxValue = 100,
        needLabel = true,
        percentView = false,
        size = 20,
        color = Enums.Color.eWhite,
    })
    tempProgBar:setPosition(cc.p(320, 168))
    tempLayer:addChild(tempProgBar)

    -- 处理触摸事件
    local tempListener = cc.EventListenerTouchOneByOne:create()
    tempListener:setSwallowTouches(true)
    tempListener:registerScriptHandler(function(touch, event)
        return true
    end, cc.Handler.EVENT_TOUCH_BEGAN)
    local eventDispatcher = self:getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(tempListener, tempLayer)

    local upzipObj
    local function unzipListener(type ,value, count)
        dump({type, value}, "unzipListener  type, value:")
        if type == "unzipSuccess" then  -- 解压成功
            LocalData:saveDataToFile("Download/obbhaveUnzip", " ")  -- 写入解压成功标记文件
            tempLayer:removeFromParent()

            self:autoLogin()
        elseif type == "unzipFailed" then -- 解压失败
            tempLayer:removeFromParent()
            -- Todo
        elseif type == "unzip" then
            tempProgBar:setCurrValue(value)
        end
    end

    upzipObj = UnzipFile:new(unzipListener)
    upzipObj:unzip(obbFilePath, destPath)
    tempLayer:addChild(upzipObj)
end

function GameLoginLayer:autoLogin()
    if not autoLoginSchedule and not self.mIsMqkk and LocalData:isAutoLogin() then
        ui.lockLayer()
        autoLoginSchedule = scheduler:scheduleScriptFunc(function()
            scheduler:unscheduleScriptEntry(autoLoginSchedule)
            autoLoginSchedule = nil

            Utility.launchStepInfo(3, 0, "login beg")
            IPlatform:getInstance():login()
            LocalData:setAutoLogined()

            ui.unlockLayer()
        end, 0.2, false)
    end
end

return GameLoginLayer
