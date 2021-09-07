-- -----------------------------------------
-- SDK相关api接口处理
-- @author yeahoo2000@gmail.com
-- -----------------------------------------

SdkIOSWrapper = SdkIOSWrapper or BaseClass()

function SdkIOSWrapper:__init()
    if SdkIOSWrapper.Instance then
        Log.Error("不可以对单例对象重复实例化")
        return
    end
    SdkIOSWrapper.Instance = self
    -- IOS平台才启用SDK
    self.repeatCount = 0 -- 失败重试次数
    if Application.platform == RuntimePlatform.IPhonePlayer then
        self.go = GameObject("KKKSdkGameObject")
        self.go.name = "KKKSdkGameObject"
        GameObject.DontDestroyOnLoad(self.go)
        self.bridge = self.go:AddComponent(KKKSdk)
    end
end

function SdkIOSWrapper:__delete()
    print("SdkIOSWrapper销毁")
end

-- 预加载完成，显示登录界面
function SdkIOSWrapper:OnPreloadCompleted()
    BaseUtils.NewPlayerImport(KvData.newPlayerImportStepType.open_sdk)
    
    if CSVersion.Version > "3.4.0" and BaseUtils.IsIosVest() then -- 版本号大于3.4.0的马甲包，sdk初始化放到预加载前
        if self.ready then -- 如果预加载完成时，sdk已经初始化完，弹出登录界面
            self:ShowLoginView()
        end
    else
        self.repeatCount = 0
        self:Start()
    end
end

-- 马甲包预先启动3kwan SDK
function SdkIOSWrapper:IosVestSDKInit()
    if CSVersion.Version > "3.4.0" and BaseUtils.IsIosVest() then -- 版本号大于3.4.0的马甲包，sdk初始化放到预加载前
        if not self.ready then
            self:Start()
        end
    end
end

-- 启动3kwan SDK
function SdkIOSWrapper:Start()
    self.repeatCount = self.repeatCount + 1
    if self.repeatCount > 3 then
        NoticeManager.Instance:FloatTipsByString(TI18N("登陆初始化失败，请尝试切换网络环境并重启游戏"))
        return
    end

    -- 初始化完成回调处理
    local callback = function(error)
        if error ~= "" then
            print("SDK初始化失败: " .. error)
            self:Start()
            return
        end

        self.ready = true -- 3K Sdk 已经初始化完毕

        if CSVersion.Version > "3.4.0" and BaseUtils.IsIosVest() then -- 版本号大于3.4.0的马甲包，sdk初始化放到预加载前
            if PreloadManager.Instance.finish then -- 如果预加载完了，sdk都还没初始化完成，等sdk初始化完成后弹出登录界面
                self:ShowLoginView()
            end
        else
            self:ShowLoginView()
        end
    end

    local config = {
        -- 是否开启SDK的调试模式
        debugMode = false,
        -- SDK的UI是否允许自动旋转
        autoRotate = true,
        -- 是否显示悬浮图标
        canShowFloatIcon = true,
    }

    if BaseUtils.IsVerify then
        config.canShowFloatIcon = false
    end

    self.bridge:SDKInit(config, callback)
end

-- 显示登录界面
function SdkIOSWrapper:ShowLoginView()
    if self.ready ~= true then return end -- sdk未初始化，直接忽略

    if CSVersion.Version > "2.8.0" then
        -- 登录完成回调处理
        local callback = function(error, userid, username, guid, age)
            if error ~= "" then
                print("登录失败: " .. error)
                return
            end

            SdkManager.Instance.guid = guid
            -- print("登录成功, userid:" .. userid .. " username:" .. username)
            PlayerPrefs.SetString("last_account", userid .. "_" .. ctx.PlatformChanleId)
            ModuleManager.Instance:Login()
        end
        self.bridge:ShowLoginView(callback)
    else
        -- 登录完成回调处理
        local callback = function(error, userid, username)
            if error ~= "" then
                print("登录失败: " .. error)
                return
            end

            SdkManager.Instance.guid = 0
            -- print("登录成功, userid:" .. userid .. " username:" .. username)
            PlayerPrefs.SetString("last_account", userid .. "_" .. ctx.PlatformChanleId)
            ModuleManager.Instance:Login()
        end
        self.bridge:ShowLoginView(callback)
    end

    BaseUtils.NewPlayerImport(KvData.newPlayerImportStepType.reg_acc)
end

function SdkIOSWrapper:OnShowLoginView()
    self:ShowLoginView()
end

-- 注销与切换帐号
function SdkIOSWrapper:Logout()
    if self.ready ~= true then return end
    self.repeatCount = 0
    self.bridge:Logout()
end

-- 购买钻石
-- 参数说明: productId:商品id amout:金额 gold:获得的游戏币数量, callbackInfo额外的信息（字符串）
function SdkIOSWrapper:Buy(productId, amount, gold, callbackInfo)
    if self.ready ~= true then return end -- sdk未初始化，直接忽略
    -- DramaManager.Instance.model.dramaMask.gameObject:SetActive(true) -- 启用mask，防止用户误点击

    callbackInfo = callbackInfo or ""
    -- 购买完成回调处理
    local callback = function(error)
        -- DramaManager.Instance.model.dramaMask.gameObject:SetActive(false) -- 关闭mask
        if error ~= "" then
            print("购买失败，原因: " .. error)
            NoticeManager.Instance:FloatTipsByString(TI18N("购买失败，原因: ") .. error)
        else
            print("购买成功")
        end
    end

    local role = RoleManager.Instance.RoleData;
    local notifyURL = nil
    for i,v in ipairs(ServerConfig.charge_list) do
        if v.platform == role.platform then
            notifyURL = v.path
        end
    end
    if notifyURL == nil then
        NoticeManager.Instance:FloatTipsByString(TI18N("获取充值地址失败，请稍后重试"))
        return
    end
    notifyURL = string.gsub(notifyURL, "{num}", tostring(role.zone_id))

    if BaseUtils.GetGameName() == "mhbb3d" then
        notifyURL = string.gsub(notifyURL, "3kw", "fish")        
    end

    local ids = {}
    local iosList = DataRecharge.data_ios
    if BaseUtils.IsNewIosVest() then -- 新马甲包计费点从协议获取
        iosList = ShopManager.Instance.model.iosVestRechargeData 
    end
    for i,v in pairs(iosList) do
        if v.game_name == BaseUtils.GetGameName() then
            table.insert(ids,v.tag)
        end
    end

    local serverId = self:GetServerFullId(role.zone_id, role.platform)
    if BaseUtils.GetLocation() == KvData.localtion_type.cn then
        serverId = BaseUtils.GetServerId(role)
        if callbackInfo == nil or callbackInfo == "" then
            callbackInfo = BaseUtils.ToBase64(role.platform)
        else
            callbackInfo = BaseUtils.ToBase64(role.platform  .. "$$" .. callbackInfo)
        end
    else
        if callbackInfo == nil or callbackInfo == "" then
            callbackInfo = ""
        else
            callbackInfo = BaseUtils.ToBase64(callbackInfo)
        end
    end
    -- if BaseUtils.GetLocation() == KvData.localtion_type.sg then
    --     ids = {
    --         "com.eyougame.mhqy.199",
    --         "com.eyougame.mhqy.499",
    --         "com.eyougame.mhqy.1599",
    --         "com.eyougame.mhqy.3099",
    --         "com.eyougame.mhqy.4999",
    --         "com.eyougame.mhqy.9999",
    --         "com.eyougame.mhqy.1099",
    --         "com.eyougame.mhqy.2099",
    --         "com.eyougame.mhqy.7999",
    --         "com.eyougame.mhqy.099",
    --         "com.eyougame.mhqy.299",
    --         "com.eyougame.mhqy.399",
    --         "com.eyougame.mhqy.799",
    --         "com.eyougame.mhqy.1699",
    --     }
    -- else
    --     ids = {
    --         "StardustRomance3K60",
    --         "StardustRomance3K120",
    --         "StardustRomance3K250",
    --         "StardustRomance3K300",
    --         "StardustRomance3K500",
    --         "StardustRomance3K680",
    --         "StardustRomance3K880",
    --         "StardustRomance3K980",
    --         "StardustRomance3K1380",
    --         "StardustRomance3K1880",
    --         "StardustRomance3K1980",
    --         "StardustRomance3K2980",
    --         "StardustRomance3K3880",
    --         "StardustRomance3K4880",
    --         "StardustRomance3K5180",
    --         "StardustRomance3K6480",
    --         "StardustRomance3K10",
    --         "StardustRomance3K30",
    --         "StardustRomance3K80",
    --         "StardustRomance3K180",
    --         "StardustRomance3K280",
    --         "StardustRomance3K5880",
    --         "StardustRomance3K8980",
    --     }
    -- end
    --

    local config = {
        -- 角色ID
        roleId = tostring(role.id),
        -- 角色名
        roleName = tostring(role.name),
        -- 角色等级
        roleLevel = tostring(role.lev),
        -- 服务器ID
        serverId = serverId,
        -- 服务器名称
        serverName = self:GetServerName(role.zone_id, role.platform),
        -- 订单标题
        orderTitle = string.format(TI18N("购买 %s 钻石"), tostring(gold)),
        -- 支付结果接收地址(服务端)
        notifyURL = notifyURL,
        -- 该字段将随结果原样返回
        userInfo = callbackInfo,
        -- 充值金额
        amount = amount,
        -- 商品ID
        productId = productId,
        -- 商品ID组，苹果后台申请的道具ID
        identifiers = ids,
        -- 仅当接入3k渠道，并且不接入登录时才需要传入此参数
        customUId = "",
    }
    -- TODO:开启点击mask
    self.bridge:Pay(config, callback)
end

-- 显示帐号中心
function SdkIOSWrapper:ShowAccountCenter()
    self.bridge:ShowAccountCenter()
end

-- 显示SDK悬浮图标(登录后会自动显示)
function SdkIOSWrapper:ShowAssistiveTouch()
    self.bridge:ShowAssistiveTouch()
end

-- 隐藏SDK悬浮图标
function SdkIOSWrapper:HideAssistiveTouch()
    self.bridge:HideAssistiveTouch()
end

-- 统计接口
-- 参数说明:
-- "RoleAdd": 角色新增
-- "RoleLogin": 角色登录
-- "RoleLevel": 角色升级
function SdkIOSWrapper:StatisticsInfo(type, role)
    if self.ready ~= true then
        return -- sdk未初始化，直接忽略
    end

    if nil == role then
        role = RoleManager.Instance.RoleData;
    end

    local guild_name = ""
    local guild_id = ""
    local fc = "0"
    local vip_lev = "0"
    if GuildManager.Instance.model ~= nil and GuildManager.Instance.model.my_guild_data ~= nil then
        guild_id = GuildManager.Instance.model.my_guild_data.GuildId
        guild_name = GuildManager.Instance.model.my_guild_data.Name
    end

    if role.fc ~= nil then
        fc = role.fc
    end

    if role.vip_lev ~= nil then
        vip_lev = role.vip_lev
    end

    local serverId = self:GetServerFullId(role.zone_id, role.platform)
    if BaseUtils.GetLocation() == KvData.localtion_type.sg then
        serverId = tostring(role.zone_id)
    elseif BaseUtils.GetLocation() == KvData.localtion_type.cn then
        serverId = tostring(BaseUtils.GetServerId(role))
    end

    local config = {
        statisticsType = type,
        roleId = tostring(role.id),
        roleName = tostring(role.name),
        roleLevel = tostring(role.lev),
        serverId = serverId,
        serverName = self:GetServerName(role.zone_id, role.platform),
        vipLevel = tostring(vip_lev),
        balance = tostring(role.gold),
        roleCTime = tostring(role.time_reg),
        resversion = tostring(ctx.ResVersion),

        guild_name = tostring(guild_name),
        guild_id = tostring(guild_id),
        fighting = tostring(fc),
    }
    self.bridge:StatisticsInfo(config)
end

function SdkIOSWrapper:GetServerFullId(zoneId, platform)
    return platform .. "_" .. zoneId
end

function SdkIOSWrapper:GetServerName(zoneId, platform)
    local list = ServerConfig.servers
    for _, data in ipairs(list) do
        if data.zone_id == zoneId and data.platform == platform then
            return data.name
        end
    end
    return TI18N("未知服")
end

function SdkIOSWrapper:GetDeviceIdIMEI()
    local versionNum = BaseUtils.CSVersionToNum()
    if versionNum <= 10201 then
        return GameContext.GetInstance().GeTuiClient
    else
        return GameContext.GetInstance():GetIDFA()
    end
end

-- 通用打开sdk内部连接接口
function SdkIOSWrapper:SDKOpenUrl(url)
    if BaseUtils.GetLocation() == KvData.localtion_type.cn then
        local versionNum = BaseUtils.CSVersionToNum()
        if versionNum > 20607 then
            self.bridge:SDK_OpenUrl(url)
        end
    end
end

-- ------------------------------------------------------
-- 以下是eyou简体版新增接口
-- hosr  2016-06-03
-- ------------------------------------------------------
-- 切换账号
function SdkIOSWrapper:ChangeAccount()
    self.bridge:ChangeAccount()
end

-- 更多充值方式
function SdkIOSWrapper:CheckMorePay()
    return self.bridge:CheckMorePay()
end

function SdkIOSWrapper:OpenMorePay()
    return self.bridge:OpenMorePay()
end

-- 查看facebook活动状态
function SdkIOSWrapper:CheckFacebook()
    return self.bridge:CheckFacebook()
end

function SdkIOSWrapper:OpenFacebook()
    return self.bridge:OpenFacebook()
end

function SdkIOSWrapper:OpenGameLink()
    return self.bridge:OpenGameLink()
end

function SdkIOSWrapper:SetShareCallback(call)
    self.bridge.shareCallback = call
end

function SdkIOSWrapper:OpenRealNameWindow()
    if CSVersion.Version > "2.8.5" then
        self.bridge:OpenRealNameWindow()
    end
end

function SdkIOSWrapper:OpenBindPhoneWindow()
    if CSVersion.Version > "2.8.5" then
        self.bridge:OpenBindPhoneWindow()
    end
end

function SdkIOSWrapper:CheckBindPhone()
    if CSVersion.Version > "2.8.5" then
        return self.bridge:CheckBindPhone()
    else
        return false
    end
end

function SdkIOSWrapper:IsOpenRealName()
    return CSVersion.Version > "2.8.5"
end

function SdkIOSWrapper:GetLoadingPageBgPath()
    local versionNum = BaseUtils.CSVersionToNum()
    if versionNum <= 30000 or versionNum == 90909 then
        return "loading_page_bg"
    else
        return KKKSdk.GetLoadingPageBg()
    end
end

function SdkIOSWrapper:GetLogoShow()
    local versionNum = BaseUtils.CSVersionToNum()
    if versionNum < 30100 or versionNum == 90909 then
        return true
    else
        return KKKSdk.SDK_GetLogoShow()
    end
end