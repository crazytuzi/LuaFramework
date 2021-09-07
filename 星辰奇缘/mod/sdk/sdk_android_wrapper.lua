-- Android Sdk相关
--
SdkAndroidWrapper = SdkAndroidWrapper or BaseClass()

function SdkAndroidWrapper:__init()
    self.sdkGo = GameObject("SdkGameObject")
    self.sdkGo.name = "SdkGameObject"
    GameObject.DontDestroyOnLoad(self.sdkGo)
    self.SdkBridge = self.sdkGo:AddComponent("KKKAndroidBehaviour")
    self.diamondText = TI18N("钻石")
end

function SdkAndroidWrapper:__delete()
end

function SdkAndroidWrapper:OnPreloadCompleted()
    SdkManager.Instance.IsLogin = true
    if BaseUtils.IsExperienceSrv() then
        return
    end

    BaseUtils.NewPlayerImport(KvData.newPlayerImportStepType.open_sdk)
    Log.Debug("wang==>   OnPreloadCompleted  ShowLoginView")
    self.SdkBridge:ShowLoginView()
end

function SdkAndroidWrapper:OnloginOnFinish(uid)
    LoginManager.Instance.loginInfo.account = uid
    if SdkManager.Instance.IsLogin then
        PlayerPrefs.SetString("last_account", uid)
        ModuleManager.Instance:Login()
        SdkManager.Instance.IsLogin = false
    else
        if uid ~= nil and uid ~= "" and uid ~= "null" then
            PlayerPrefs.SetString("last_account", uid)
            SdkManager.Instance.IsLogin = false
            LoginManager.Instance.model:InitMainUI()
            LoginManager.Instance.model:SetAccountByCookie()
        end
    end
end

function SdkAndroidWrapper:OnloginOnFinishNew(account, uid, timestamp, sign, guid, cp_ext, pReward)
    local isReward = false
    if pReward ~= nil and pReward == "true" then
        isReward = true
    end
    LoginManager.Instance.loginInfo.account = account
    LoginManager.Instance.loginInfo.uid =uid
    LoginManager.Instance.loginInfo.timestamp = timestamp
    LoginManager.Instance.loginInfo.sign = sign
    LoginManager.Instance.loginInfo.guid = guid
    LoginManager.Instance.loginInfo.cp_ext = cp_ext
    SdkManager.Instance.guid = guid
    
    if SdkManager.Instance.IsLogin then
        PlayerPrefs.SetString("last_account", account)
        ModuleManager.Instance:Login()
        SdkManager.Instance.IsLogin = false
    else
        if uid ~= nil and uid ~= "" and uid ~= "null" then
            PlayerPrefs.SetString("last_account", account)
            SdkManager.Instance.IsLogin = false
            LoginManager.Instance.model:InitMainUI()
            LoginManager.Instance.model:SetAccountByCookie()
        end
    end

    if ctx.PlatformChanleId == 12 then
        local versionNum = BaseUtils.CSVersionToNum()
        if versionNum > 10602 then
            self.SdkBridge:GetVIPGrade()
        end
    end

    BaseUtils.NewPlayerImport(KvData.newPlayerImportStepType.reg_acc)
end

--查询是否显示更多充值
function SdkAndroidWrapper:GetIsOpenMorePay()
    self.SdkBridge:GetIsOpenMorePay()
end
-- sdk回调, 是否显示更多充值按钮
function SdkAndroidWrapper:SetIsOpenMorePay(bo)
    if bo == "true" then
        SdkManager.Instance.IsOpenMorePay = true
    else
        SdkManager.Instance.IsOpenMorePay = false
    end
end
-- 启动eyou服务
function SdkAndroidWrapper:startEyouService()
    local roleData = RoleManager.Instance.RoleData
    local paramTable = {}
    paramTable["serverId"] = tostring(roleData.zone_id) -- roleData.platform .. "_" .. tostring(roleData.zone_id)
    paramTable["roleId"] = tostring(roleData.id)
    self.SdkBridge:startEyouService(paramTable)
end
-- 查询facebook活动数量
function SdkAndroidWrapper:getFaceBookQuantity()
    local roleData = RoleManager.Instance.RoleData
    local paramTable = {}
    paramTable["serverId"] = tostring(roleData.zone_id) -- roleData.platform .. "_" .. tostring(roleData.zone_id)
    paramTable["roleId"] = tostring(roleData.id)
    self.SdkBridge:getFaceBookQuantity(paramTable)
end
-- 回调facebook活动数量
function SdkAndroidWrapper:setFaceBookQuantity(quantity)
    SdkManager.Instance.faceBookQuantity = tonumber(quantity)
end
-- 进入Facebook活动页面
function SdkAndroidWrapper:startForGiftFaceBook()
    local roleData = RoleManager.Instance.RoleData
    local paramTable = {}
    paramTable["serverId"] = tostring(roleData.zone_id) -- roleData.platform .. "_" .. tostring(roleData.zone_id)
    paramTable["roleId"] = tostring(roleData.id)
    self.SdkBridge:startForGiftFaceBook(paramTable)
end
-- --是否显示更多充值按钮
-- function SdkAndroidWrapper:IsOpenMorePay()
--     return SdkManager.Instance.IsOpenMorePay
-- end
--显示更多充值方式
function SdkAndroidWrapper:DoMorePay()
    local roleData = RoleManager.Instance.RoleData
    local paramTable = {}
    paramTable["serverId"] = tostring(roleData.zone_id) -- roleData.platform .. "_" .. tostring(roleData.zone_id)
    paramTable["roleId"] = tostring(roleData.id)
    self.SdkBridge:DoMorePay(paramTable)
end
-- 切换游戏账号
function SdkAndroidWrapper:SetAutoLoginStauts()
    self.SdkBridge:SetAutoLoginStauts()
end
-- 安卓跳转商店,去评论
function SdkAndroidWrapper:goGooglePlay()
    self.SdkBridge:goGooglePlay()
end
--复制内容到剪贴板
function SdkAndroidWrapper:CopyContent(content)
    local paramTable = {}
    paramTable["content"] = content
    self.SdkBridge:CopyContent(paramTable)
end

-- 创建角色接口
function SdkAndroidWrapper:SendExtendDataRoleCreate(data)
    local extendData = {}
    extendData["roleId"] = tostring(data.id)
    extendData["roleName"] = data.name
    extendData["roleLevel"] = tostring(data.lev)
    extendData["serverId"] = tostring(BaseUtils.GetServerId(data))
    extendData["serverName"] = self:GetServerName(data.zone_id, data.platform)
    extendData["vipLevel"] = tostring(data.vip_lev)
    extendData["userMoney"] = tostring(data.gold)
    extendData["time_reg"] = tostring(data.time_reg)
    extendData["resversion"] = tostring(ctx.ResVersion)
    extendData["sociatylevel"] = ""
    extendData["petlevel"] = ""

    self.SdkBridge:SendExtendDataRoleCreate(extendData)
end

-- 角色登录接口
function SdkAndroidWrapper:SendExtendDataRoleLogin(data)
    local extendData = {}
    extendData["roleId"] = tostring(data.id)
    extendData["roleName"] = data.name
    extendData["roleLevel"] = tostring(data.lev)
    extendData["serverId"] = tostring(BaseUtils.GetServerId(data))
    extendData["serverName"] = self:GetServerName(data.zone_id, data.platform)
    extendData["vipLevel"] = tostring(data.vip_lev)
    extendData["userMoney"] = tostring(data.gold)
    extendData["time_reg"] = tostring(data.time_reg)
    extendData["resversion"] = tostring(ctx.ResVersion)
    extendData["sociatylevel"] = ""
    extendData["petlevel"] = ""
    self.SdkBridge:SendExtendDataRoleLogin(extendData)
end

-- 角色升级接口
function SdkAndroidWrapper:SendExtendDataRoleLevelUpdate()
    local extendData = self:GetRoleExtendData()
    self.SdkBridge:SendExtendDataRoleLevelUpdate(extendData)
end
function SdkAndroidWrapper:GetRoleExtendData()
    local roleData = RoleManager.Instance.RoleData
    -- local accountInfo = mod_role.role_info
    -- local asset = mod_role.role_assets
    local extendData = {}
    extendData["roleId"] = tostring(roleData.id)
    extendData["roleName"] = roleData.name
    extendData["roleLevel"] = tostring(roleData.lev)
    extendData["serverId"] = tostring(BaseUtils.GetServerId(roleData))
    extendData["serverName"] = self:GetServerName(roleData.zone_id, roleData.platform)
    extendData["vipLevel"] = "1"
    extendData["userMoney"] = tostring(roleData.gold)
    extendData["time_reg"] = tostring(roleData.time_reg)
    extendData["resversion"] = tostring(ctx.ResVersion)
    extendData["sociatylevel"] = ""
    extendData["petlevel"] = ""
    return extendData
end

-- 显示登陆接口
function SdkAndroidWrapper:OnShowLoginView()
    SdkManager.Instance.IsLogin = true
    Log.Debug("wang==>   OnShowLoginView")
    self.SdkBridge:OnShowLoginView()
end

function SdkAndroidWrapper:OnRelogin(reloginFlag)
    -- body
    self.SdkBridge:OnRelogin(reloginFlag)
end

-- 充值
-- extInfo 额外的信息（字符串）
function SdkAndroidWrapper:ShowChargeView(amount,productId,gold, extInfo)

    local roleData = RoleManager.Instance.RoleData
    -- local accountInfo = mod_role.role_info
    -- local asset = mod_role.role_assets
    local cburl = nil
    for i,v in ipairs(ServerConfig.charge_list) do
        if v.platform == roleData.platform then
            cburl = v.path
        end
    end
    if cburl == nil then
        NoticeManager.Instance:FloatTipsByString(TI18N("获取充值地址失败，请稍后重试"))
        return
    end
    cburl = string.gsub(cburl, "{num}", tostring(roleData.zone_id))

    if BaseUtils.GetLocation() == KvData.localtion_type.sg then
        self:eyouRecharge(amount,cburl,productId,gold,extInfo)
    else
        self:normalRecharge(amount,cburl,extInfo)
    end
end
--国服普通的安卓充值入口
function SdkAndroidWrapper:normalRecharge(amount,cburl,callbackInfo)
    local roleData = RoleManager.Instance.RoleData
    if callbackInfo == nil or callbackInfo == "" then
        callbackInfo = BaseUtils.ToBase64(roleData.platform)
    else
        callbackInfo = BaseUtils.ToBase64(roleData.platform .. "$$" .. callbackInfo)
    end

    local chargeMount = tostring((amount * 10))
    if ctx.PlatformChanleId == 76 then
        chargeMount = "0"
    end

    local guildName = roleData.guild_name
    if guildName == nil or guildName == "" then
        guildName = "none"
    end

    local paramTable = {}
    paramTable["amount"] = amount * 100
    -- paramTable["productId"] = "659865656565"
    paramTable["productId"] = self:GetProductId(amount)
    paramTable["productName"] = self.diamondText
    paramTable["callbackURL"] = cburl
    paramTable["callbackInfo"] = callbackInfo
    paramTable["des"] = tostring((amount * 10)) .. self.diamondText
    paramTable["chargeMount"] = chargeMount
    paramTable["serverId"] = tostring(BaseUtils.GetServerId(roleData))
    paramTable["serverName"] = self:GetServerName(roleData.zone_id, roleData.platform)
    paramTable["roleName"] = roleData.name
    paramTable["roleId"] = tostring(roleData.id)
    paramTable["rate"] = "10"
    paramTable["roleLevel"] = tostring(roleData.lev)
    paramTable["sociaty"] = tostring(guildName)
    paramTable["lastMoney"] = tostring(roleData.gold)
    paramTable["vipLevel"] = "1"
    paramTable["ctext"] = ""
    paramTable["openKkkWebPay"] = false
    paramTable["sociatylevel"] = ""
    paramTable["petlevel"] = ""
    self.SdkBridge:ShowChargeView(paramTable)
end
--eyou 的安卓充值入口
function SdkAndroidWrapper:eyouRecharge(amount,cburl,productId,gold,callbackInfo)
    local roleData = RoleManager.Instance.RoleData
    callbackInfo = callbackInfo or ""
    local paramTable = {}
    paramTable["amount"] = amount
    -- paramTable["productId"] = "659865656565"
    paramTable["productId"] = productId -- self:GetProductId(amount)
    paramTable["productName"] = self.diamondText
    paramTable["callbackURL"] = cburl
    paramTable["callbackInfo"] = callbackInfo
    paramTable["des"] = tostring(gold) .. self.diamondText
    paramTable["chargeMount"] = tostring((amount / 100))
    paramTable["serverId"] = tostring(roleData.zone_id)
    paramTable["serverName"] = self:GetServerName(roleData.zone_id, roleData.platform)
    paramTable["roleName"] = roleData.name
    paramTable["roleId"] = tostring(roleData.id)
    paramTable["rate"] = "10"
    paramTable["roleLevel"] = tostring(roleData.lev)
    paramTable["sociaty"] = tostring(roleData.guild_name)
    paramTable["lastMoney"] = tostring(roleData.gold)
    paramTable["vipLevel"] = "1"
    paramTable["ctext"] = string.format("1020_%s_%s_%s_%s",paramTable["serverId"],paramTable["roleId"],tostring(roleData.platform),tostring(BaseUtils.BASE_TIME))
    self.SdkBridge:ShowChargeView(paramTable)
end

-- 打开输入面板
function SdkAndroidWrapper:ShowInputDialog(fromId, keyboardType, x, y, fontSize, gravity, width, text)
    self.SdkBridge:ShowInputDialog(fromId, keyboardType, x, y, fontSize, gravity, width, text)
end
function SdkAndroidWrapper:ShowInputDialogWhite(fromId, keyboardType, x, y, fontSize, gravity, width, text)
    self.SdkBridge:ShowInputDialogWhite(fromId, keyboardType, x, y, fontSize, gravity, width, text)
end

-----------------------------------------------------------------------------
function SdkAndroidWrapper:GetServerName(zoneId, platform)
    local list = ServerConfig.servers
    for _, data in ipairs(list) do
        if data.zone_id == zoneId and data.platform == platform then
            return data.name
        end
    end
    return TI18N("未知服")
end

function SdkAndroidWrapper:GetServerHost(zoneId, platform)
    local list = ServerConfig.servers
    for _, data in ipairs(list) do
        if data.zone_id == zoneId and data.platform == platform then
            return data.host
        end
    end
    return TI18N("未知服")
end

-- 获取IMEI码 10000为默认值，可视为无效值
function SdkAndroidWrapper:GetDeviceIdIMEI()
    local versionNum = BaseUtils.CSVersionToNum()
    if versionNum <= 10201 then
        return GameContext.GetInstance().GeTuiClient
    else
        return self.SdkBridge:GetDeviceIdIMEI()
    end
end

-- 获取商品编号
function SdkAndroidWrapper:GetProductId(amount)
    local platformId = ctx.PlatformChanleId
    local defaultProductId = "None"
    if DataRecharge.data_androidwithid[platformId] ~= nil then
        for k,v in pairs(DataRecharge.data_androidwithid[platformId].id2item) do
            if v[2] == amount then
                defaultProductId = tostring(v[1])
                break
            end
        end
    end
    return defaultProductId
end

function SdkAndroidWrapper:OpenOnlineGmWindow(url)
    if BaseUtils.IsExperienceSrv() then
        return
    end
    self.SdkBridge:OpenOnlineGmWindow(url)
end

function SdkAndroidWrapper:OpenRealNameWindow()
    if BaseUtils.CSVersionToNum() > 10608 then
        self.SdkBridge:OpenRealNameWindow()
    end
end

function SdkAndroidWrapper:OpenBindPhoneWindow()
    if BaseUtils.CSVersionToNum() > 10608 then
        self.SdkBridge:OpenBindPhoneWindow()
    end
end

function SdkAndroidWrapper:getUserAge()
    if BaseUtils.CSVersionToNum() > 10608 then
        return self.SdkBridge:getUserAge()
    else
        return 0
    end
end

function SdkAndroidWrapper:CheckBindPhone()
    if BaseUtils.CSVersionToNum() > 10608 then
        return self.SdkBridge:CheckBindPhone()
    else
        return false
    end
end

function SdkAndroidWrapper:IsOpenRealName()
    if BaseUtils.IsMixPlatformChanle() then
        return false
    end
    local versionNum = BaseUtils.CSVersionToNum()
    return versionNum > 10608
end