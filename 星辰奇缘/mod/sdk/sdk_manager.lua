-- sdk接口管理
-- 策略模式
--     如果是Android环境，使用SdkAndroidWrapper类
--     如果是IOS环境，使用SdkIOSWrapper类
-- @author huangyq

SdkManager = SdkManager or BaseClass()

function SdkManager:__init()
    if SdkManager.Instance then
        Log.Error("不可以对单例对象重复实例化")
        return
    end
    SdkManager.Instance = self

    self.platform = nil
    self.wrapper = nil
    if Application.platform == RuntimePlatform.IPhonePlayer then
        self.platform = RuntimePlatform.IPhonePlayer
        self.wrapper = SdkIOSWrapper.New()
    elseif Application.platform == RuntimePlatform.Android then
        self.platform = RuntimePlatform.Android
        self.wrapper = SdkAndroidWrapper.New()
    end

    self.IsLogin = false
    self.IsOpenMorePay = false
    self.faceBookQuantity = 0
    self.guid = 0
    self.age = 0
    self.IsBindPhone = false
end

function SdkManager:__delete()
    if self.wrapper ~= nil then
        self.wrapper:DeleteMe()
        self.wrapper = nil
    end
end

-----------------------------------------------------
-- 接口 ---------------------------------------------
-----------------------------------------------------
function SdkManager:RunSdk()
    Log.Debug("wang==>   RunSdk")

    -- wang 修改
    if self.wrapper ~= nil then
        return true
    else
        return false
    end
end

-- 显示登陆界面
function SdkManager:ShowLoginView()
    Log.Debug("wang==>   ShowLoginView")
    self.wrapper:ShowLoginView()
end

-- 预加载文件完成，打包登录面板
function SdkManager:OnPreloadCompleted()
    self.wrapper:OnPreloadCompleted()
end

-- 登录成功
function SdkManager:OnloginOnFinish(uid)
    self.wrapper:OnloginOnFinish(uid)
end

function SdkManager:OnloginOnFinishNew(account, uid, timestamp, sign, guid, cp_ext, isReward)
    if Application.platform == RuntimePlatform.Android then
        self.wrapper:OnloginOnFinishNew(account, uid, timestamp, sign, guid, cp_ext, isReward)
    else
        self.wrapper:OnloginOnFinishNew(account, uid, timestamp, sign, guid, cp_ext)
    end
end

-- 查询是否有更多充值方式
function SdkManager:GetIsOpenMorePay()
    if Application.platform == RuntimePlatform.IPhonePlayer then
    else
        self.wrapper:GetIsOpenMorePay()
    end
end
--是否显示更多充值按钮
function SdkManager:SetIsOpenMorePay(bo)
    print("SdkManager:SetIsOpenMorePay(bo)=======================================")
    print(bo)
    if Application.platform == RuntimePlatform.IPhonePlayer then
    else
        self.wrapper:SetIsOpenMorePay(bo)
    end
end

-- 切换游戏账号
function SdkManager:SetAutoLoginStauts()
    if Application.platform == RuntimePlatform.IPhonePlayer then
    else
        self.wrapper:SetAutoLoginStauts()
    end
end
--显示更多充值方式
function SdkManager:DoMorePay()
    if Application.platform == RuntimePlatform.IPhonePlayer then
    else
        self.wrapper:DoMorePay()
    end
end
-- 安卓跳转商店,去评论
function SdkManager:goGooglePlay()
    if Application.platform == RuntimePlatform.IPhonePlayer then
    else
        self.wrapper:goGooglePlay()
    end
end
--复制内容到剪贴板
function SdkManager:CopyContent(content)
    if Application.platform == RuntimePlatform.IPhonePlayer then
    else
        self.wrapper:CopyContent(content)
    end
end

-- 角色创建
function SdkManager:SendExtendDataRoleCreate(data)
    if Application.platform == RuntimePlatform.IPhonePlayer then
        self.wrapper:StatisticsInfo("RoleAdd", data)
    else
        self.wrapper:SendExtendDataRoleCreate(data)
    end
end

-- 角色登陆
function SdkManager:SendExtendDataRoleLogin(data)
    if Application.platform == RuntimePlatform.IPhonePlayer then
        self.wrapper:StatisticsInfo("RoleLogin", data)
    else
        self.wrapper:SendExtendDataRoleLogin(data)
    end
end

-- 角色升级接口
function SdkManager:SendExtendDataRoleLevelUpdate()
    if Application.platform == RuntimePlatform.IPhonePlayer then
        self.wrapper:StatisticsInfo("RoleLevel")
    else
        self.wrapper:SendExtendDataRoleLevelUpdate()
    end
end

-- 显示登陆界面
function SdkManager:OnShowLoginView()
    Log.Debug("wang==>   OnShowLoginView 11")
    self.wrapper:OnShowLoginView()
end
--eyou对接请求信息
function SdkManager:DoSomethingForEyou()
    self:startEyouService()
    self:getFaceBookQuantity()
    self:GetIsOpenMorePay()
end
-- 启动eyou服务
function SdkManager:startEyouService()
    if Application.platform == RuntimePlatform.IPhonePlayer then
    else
        self.wrapper:startEyouService()
    end
end
-- 查询facebook活动数量
function SdkManager:getFaceBookQuantity()
    if Application.platform == RuntimePlatform.IPhonePlayer then
    else
        self.wrapper:getFaceBookQuantity()
    end
end
-- 回调facebook活动数量
function SdkManager:setFaceBookQuantity(quantity)
    if Application.platform == RuntimePlatform.IPhonePlayer then
    else
        self.wrapper:setFaceBookQuantity(quantity)
    end
end
-- 进入Facebook活动页面
function SdkManager:startForGiftFaceBook()
    if Application.platform == RuntimePlatform.IPhonePlayer then
    else
        self.wrapper:startForGiftFaceBook()
    end
end

function SdkManager:OnRelogin()
    if Application.platform == RuntimePlatform.IPhonePlayer then
    else
        self.wrapper:OnRelogin("Show")
    end
end

function SdkManager:OnShowLoginViewOnRelogin()
    if Application.platform == RuntimePlatform.Android then
        LoginManager.Instance.model:InitMainUI()
        LuaTimer.Add(500, function() self.wrapper:OnShowLoginView() end)
    elseif Application.platform == RuntimePlatform.IPhonePlayer then
        LoginManager.Instance.model:InitMainUI()
        LuaTimer.Add(500, function() self.wrapper:OnShowLoginView() end)
    end
end

-- 充值
function SdkManager:ShowChargeView(productId, amount, gold, extInfo)
    if BaseUtils.IsExperienceSrv() then
        NoticeManager.Instance:FloatTipsByString("请下载正式包再进行充值")
        return
    end

    -- 渠道id
    local platformId = ctx.PlatformChanleId

    -- 充值阻止列表
    self.blockList = self.blockList or {
        [58] = 1,       -- 酷狗
        [123] = 1,      -- 芒果
        [76] = 1,       -- 搜狗
        [122] = 1,       -- pptv
        [110] = 1,       -- 乐视
        [124] = 1,       -- 努比亚
    }

    if self.blockList[platformId] == 1 or
        RoleManager.Instance.RoleData.platform == "qq"
        then
        NoticeManager.Instance:FloatTipsByString(TI18N("充值功能已关闭"))
        return
    end

    if RoleManager.Instance:CanIRecharge(amount) then
        if Application.platform == RuntimePlatform.IPhonePlayer then
            productId = ShopManager.Instance:ReplaceProductId(productId)
            self.wrapper:Buy(productId, amount, gold, extInfo)
        else
            self.wrapper:ShowChargeView(amount,productId,gold, extInfo)
        end
    end
end

-- 打开输入法面板
function SdkManager:ShowInputDialog(fromId, keyboardType, x, y, fontSize, gravity, width, text)
    if Application.platform == RuntimePlatform.Android then
        self.wrapper:ShowInputDialog(fromId, keyboardType, x, y, fontSize, gravity, width, text)
    end
end
function SdkManager:ShowInputDialogWhite(fromId, keyboardType, x, y, fontSize, gravity, width, text)
    if Application.platform == RuntimePlatform.Android then
        self.wrapper:ShowInputDialogWhite(fromId, keyboardType, x, y, fontSize, gravity, width, text)
    end
end

function SdkManager:OnInputDialogClose(fromId, actionType, text)
    EventMgr.Instance:Fire(event_name.input_dialog_callback, fromId, actionType, text)
end

function SdkManager:GetDeviceIdIMEI()
    if Application.platform == RuntimePlatform.Android or Application.platform == RuntimePlatform.IPhonePlayer then
        return self.wrapper:GetDeviceIdIMEI() or ""
    end
    return "10000"
end

-- ------------------------------------------------------
-- 以下是eyou简体版新增接口
-- hosr  2016-06-03
-- ------------------------------------------------------
-- 切换账号
function SdkManager:ChangeAccount()
    if BaseUtils.GetLocation() == KvData.localtion_type.sg then
        if Application.platform == RuntimePlatform.IPhonePlayer then
            -- ios sdk 这边要在切换账号的时候，把自动登陆的标志修改为false
            self.wrapper:ChangeAccount()
        elseif Application.platform == RuntimePlatform.Android then
            -- 安卓按需处理
            self.wrapper:SetAutoLoginStauts()
        end
        LoginManager.Instance:ReturnToShowSdkLogin()
    elseif ctx.PlatformChanleId == 110 or ctx.PlatformChanleId == 33 then
        LoginManager.Instance:ReturnToShowSdkLogin()
    end
end

-- 更多充值方式
function SdkManager:OpenMorePay()
    if BaseUtils.GetLocation() == KvData.localtion_type.sg then
        if Application.platform == RuntimePlatform.IPhonePlayer then
            self.wrapper:OpenMorePay()
        elseif Application.platform == RuntimePlatform.Android then
            self.wrapper:DoMorePay()
        end
    end
end

-- 打开facebook活动
function SdkManager:OpenFacebook()
    if BaseUtils.GetLocation() == KvData.localtion_type.sg then
        if Application.platform == RuntimePlatform.IPhonePlayer then
            self.wrapper:OpenFacebook()
        elseif Application.platform == RuntimePlatform.Android then
            self.wrapper:startForGiftFaceBook()
        end
    end
end

-- 查看facebook活动状态
function SdkManager:CheckFacebook()
    if BaseUtils.GetLocation() == KvData.localtion_type.sg then
        if Application.platform == RuntimePlatform.IPhonePlayer then
            return self.wrapper:CheckFacebook()
        elseif Application.platform == RuntimePlatform.Android then
            return SdkManager.Instance.faceBookQuantity
        end
    end
    return 0
end

-- 检查是否显示更多充值
function SdkManager:CheckMorePay()
    if BaseUtils.GetLocation() == KvData.localtion_type.sg then
        if Application.platform == RuntimePlatform.IPhonePlayer then
            return self.wrapper:CheckMorePay()
        elseif Application.platform == RuntimePlatform.Android then
            return SdkManager.Instance.IsOpenMorePay
        end
    end
    return false
end

-- 打开游戏应用商店连接
function SdkManager:OpenGameLink()
    if BaseUtils.GetLocation() == KvData.localtion_type.sg then
        if Application.platform == RuntimePlatform.IPhonePlayer then
            self.wrapper:OpenGameLink()
        elseif Application.platform == RuntimePlatform.Android then
            self.wrapper:goGooglePlay()
        end
    end
end

-- 复制内容到剪贴板
function SdkManager:CopyContent(content)
    if BaseUtils.GetLocation() == KvData.localtion_type.sg then
        if Application.platform == RuntimePlatform.IPhonePlayer then
        elseif Application.platform == RuntimePlatform.Android then
            self.wrapper:CopyContent(content)
        end
    end
end

function SdkManager:OpenOnlineGmWindow(url)
    if Application.platform == RuntimePlatform.IPhonePlayer then
        self.wrapper:SDKOpenUrl(url)
    elseif Application.platform == RuntimePlatform.Android then
        self.wrapper:OpenOnlineGmWindow(url)
    end
end


function SdkManager:CheckRealName()
    if Application.platform == RuntimePlatform.IPhonePlayer then
        
    elseif Application.platform == RuntimePlatform.Android then
        self.age = tonumber(self.wrapper:getUserAge())
    end
end

function SdkManager:OpenRealNameWindow()
    if Application.platform == RuntimePlatform.IPhonePlayer then
        self.wrapper:OpenRealNameWindow()
    elseif Application.platform == RuntimePlatform.Android then
        self.wrapper:OpenRealNameWindow()
    end
end

function SdkManager:CheckBindPhone()
    if Application.platform == RuntimePlatform.IPhonePlayer then
        -- self.IsBindPhone = self.wrapper:CheckBindPhone()
    elseif Application.platform == RuntimePlatform.Android then
        -- self.IsBindPhone = self.wrapper:CheckBindPhone()
    end
end

function SdkManager:OpenBindPhoneWindow()
    if Application.platform == RuntimePlatform.IPhonePlayer then
        -- self.wrapper:OpenBindPhoneWindow()
    elseif Application.platform == RuntimePlatform.Android then
        -- self.wrapper:OpenBindPhoneWindow()
    end
end

function SdkManager:SetAge(age)
    self.age = tonumber(age)
end

function SdkManager:OnRealNameReturn(age)
    -- age为字符串类型
    -- onFailure 失败 
    if "onFailure" ~= age then
        self.age = tonumber(age)
        if self.age ~= 0 then
            BibleManager.Instance:OnRetrun()
        end
    end
end

function SdkManager:OnBindPhoneReturn(param)
    -- param为字符串类型
    -- onFailure 失败 1 成功   
end

function SdkManager:IsOpenRealName()
    if Application.platform == RuntimePlatform.IPhonePlayer then
        return self.wrapper:IsOpenRealName()
    elseif Application.platform == RuntimePlatform.Android then
        return self.wrapper:IsOpenRealName()
    end
    return false
end

function SdkManager:GetLoadingPageBg()
    if Application.platform == RuntimePlatform.IPhonePlayer then
        return self.wrapper:GetLoadingPageBgPath()
    elseif Application.platform == RuntimePlatform.Android then
        return "loading_page_bg"
    end
    return false
end

function SdkManager:GetLogoShow()
    if Application.platform == RuntimePlatform.IPhonePlayer then
        return self.wrapper:GetLogoShow()
    elseif Application.platform == RuntimePlatform.Android then
        return true
    end
    return true
end

function SdkManager:IosVestSDKInit()
    if Application.platform == RuntimePlatform.IPhonePlayer then
        self.wrapper:IosVestSDKInit()
    elseif Application.platform == RuntimePlatform.Android then
    end
end
