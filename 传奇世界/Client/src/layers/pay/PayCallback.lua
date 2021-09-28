--
--支付相关callback
--
require "src/layers/pay/PayMsg"
require "src/PandoraFunction"

local function reportBuyDiamondEvent(result, errorCode)
    local LoginScene = require("src/login/LoginScene")

    local platform = "GUEST"
    if LoginScene.sdkPlatform == "qq" then
        platform = "QQ"
    elseif LoginScene.sdkPlatform == "wx" then
        platform = "WX"
    end

    local callbackTime = 0
    if callbackTab.startPayTimeCallback then
        callbackTime = os.clock() - callbackTab.startPayTimeCallback
        callbackTime = callbackTime * 1000
    end

    local MRoleStruct = require("src/layers/role/RoleStruct")

    sdkReportEvent("Service_Buydia", false, 
        "g_version", LoginScene.VERSION,
        "WorldID", callbackTab.worldId,
        "platform", platform,
        "openid", LoginScene.user_name,
        "game_level", MRoleStruct:getAttr(ROLE_LEVEL),
        "IsJailbreak", isJailbroken(),
        "buy_dia_channel", "formal",
        "buy_dia_id", callbackTab.productId,
        "pay_type_result", result,
        "callback_result", errorCode,
        "buy_quantity", callbackTab.money,
        "callback_time", callbackTime
    )
end

local function reportBuyGoldEvent()
    local LoginScene = require("src/login/LoginScene")

    local platform = "GUEST"
    if LoginScene.sdkPlatform == "qq" then
        platform = "QQ"
    elseif LoginScene.sdkPlatform == "wx" then
        platform = "WX"
    end

    local totalTime = 0
    if callbackTab.startPayTime then
        totalTime = os.clock() - callbackTab.startPayTime 
        totalTime = totalTime * 1000
    end

    sdkReportEvent("Service_Buygold", false, 
        "g_version", LoginScene.VERSION,
        "WorldID", callbackTab.worldId,
        "platform", platform,
        "openid", LoginScene.user_name,
        "buy_gold_channel", "formal",
        "buy_quantity", callbackTab.money,
        "buy_gold_id_time", totaltime
    )
end

function callbackTab.startPay(productId, money, worldId)
    callbackTab.productId = productId
    callbackTab.money = money
    callbackTab.worldId = worldId

    callbackTab.startPayTimeCallback = os.clock()
    callbackTab.startPayTime = callbackTab.startPayTimeCallback
end

--android pay callback
function callbackTab.midasPayCallBack(code, msg, num)
    print("callbackTab.midasPayCallBack", code, msg, num)

    payNetLoading(false)

    local payResult = "ERROR"

    local money = tonumber(num)
    if code == 0 and money > 0 then
        TIPS( { type = 1 , str = "支付成功, 请稍后查询结果", flag = 0 } )
        PayMsg.sendSdkPaySucess(money)
        payResult = "PAYSUCC"
    elseif code == -1 then
        TIPS( { type = 1 , str = "支付失败", flag = 1 } )
    elseif code == 2 then
        TIPS( { type = 1 , str = "支付取消", flag = 1 } )
        print("用户取消", msg, num)
        payResult = "CANCEL"
    else
        TIPS( { type = 1 , str = "支付失败 " .. code, flag = 1 } )
    end

    reportBuyDiamondEvent(payResult, code)
    callbackTab.startPayTimeCallback = os.clock()


end

function callbackTab.midasPayNeedLogin()
    print("midasPayNeedLogin")

    payNetLoading(false)
    TIPS( { type = 1 , str = "支付失败。登录过期, 请重新登录", flag = 1 } )

    reportBuyDiamondEvent("LoginExpiry", 0)
    callbackTab.startPayTimeCallback = os.clock()
end

--android qqvip pay callback
function callbackTab.midasQQVipPayCallBack(code, msg, num)
    print("callbackTab.midasQQVipPayCallBack", code, msg, num)

    local money = tonumber(num)
    if code == 0 and money > 0 then
        TIPS( { type = 1 , str = callbackTab.qqVipPayMsg .. "成功, 请稍后查询结果", flag = 0 } )
        require( "src/layers/qqMember/qqMemberLayer" ).onPay()
    elseif code == -1 then
        TIPS( { type = 1 , str = callbackTab.qqVipPayMsg .. "失败", flag = 1 } )
    elseif code == 2 then
        TIPS( { type = 1 , str = callbackTab.qqVipPayMsg .. "取消", flag = 1 } )
        print("用户取消", msg, num)
    else
        TIPS( { type = 1 , str = callbackTab.qqVipPayMsg .. "失败 " .. code, flag = 1 } )
    end
end

--ios pay callback

--下单成功回调
function callbackTab.onOrderSuccess(result, billno)
    print("callbackTab.onOrderSuccess", result, billno)

    reportBuyDiamondEvent("OrderFinish", 0)
    callbackTab.startPayTimeCallback = os.clock()
end

--下单失败回调
function callbackTab.onOrderFailure(code, errorMessage)
    print("callbackTab.onOrderFailure", code, errorMessage)

    payNetLoading(false)

    --1138 因风控原因的下单失败
    if code == 1138 then
        --米大师会弹框提示
        --MessageBox(errorMessage)
    else
        TIPS( { type = 1 , str = "支付失败", flag = 1 } )
    end

    reportBuyDiamondEvent("OrderFailue", code)
    callbackTab.startPayTimeCallback = os.clock()
end

--苹果支付成功回调
function callbackTab.onIAPPaySuccess()
    print("callbackTab.onIAPPaySuccess")

    reportBuyDiamondEvent("IAPPayFinish", 0)
    callbackTab.startPayTimeCallback = os.clock()
end

--苹果支付失败回调
function callbackTab.onIAPPayFailure(code, errorString)
    print("callbackTab.onIAPPayFailure", code, errorString)

    payNetLoading(false)
    TIPS( { type = 1 , str = "支付失败", flag = 1 } )

    reportBuyDiamondEvent("IAPPayFailue", code)
    callbackTab.startPayTimeCallback = os.clock()
end

--发货成功回调
function callbackTab.onDistributeGoodsSuccess(isReprovide, money)
    print("callbackTab.onDistributeGoodsSuccess", isReprovide, money)

    payNetLoading(false)

    --todo 补发测试
    local count = tonumber(money)
    if isReprovide == 0 and count > 0 then
        TIPS( { type = 1 , str = "支付成功, 请稍后查询结果", flag = 0 } )
        PayMsg.sendSdkPaySucess(count)
    end

    reportBuyDiamondEvent("DistributeGoodsFinish", 0)
    callbackTab.startPayTimeCallback = os.clock()

    reportBuyGoldEvent()
end

--发货失败回调
function callbackTab.onDistributeGoodsFailure(code, errorMessage)
    print("callbackTab.onDistributeGoodsFailure", code, errorMessage)

    payNetLoading(false)

    --1139 因风控原因的拒绝发货， 不封号
    --1140 因风控原因的拒绝发货， 并封号
    --1141 因风控原因的继续发货， 但封号
    if code == 1139 or code == 1140 or code == 1141 then
        --米大师会弹框提示
        --MessageBox(errorMessage)
    else
        TIPS( { type = 1 , str = "支付成功, 请稍后查询结果", flag = 0 } )
    end

    reportBuyDiamondEvent("DistributeGoodsFailue", code)
    callbackTab.startPayTimeCallback = os.clock()
end

--补发货成功回调(针对非消耗性商品)
function callbackTab.onRestorableProductRestoreSuccess()
    print("callbackTab.onRestorableProductRestoreSuccess")

    reportBuyDiamondEvent("ReDistributeGoodsFinish", 0)
    callbackTab.startPayTimeCallback = os.clock()
end

--补发货失败回调(针对非消耗性商品)
function callbackTab.onRestorableProductRestoreFailure(code, errorMessage)
    print("callbackTab.onRestorableProductRestoreFailure", code, errorMessage)

    reportBuyDiamondEvent("ReDistributeGoodsFailue", code)
    callbackTab.startPayTimeCallback = os.clock()
end

function callbackTab.onGetRestorableProductFailure(code, errorString)
    print("callbackTab.onGetRestorableProductFailure", code, errorString)

    reportBuyDiamondEvent("GetRestorableProductFailue", code)
    callbackTab.startPayTimeCallback = os.clock()
end

--拉取产品信息失败回调此接口，目前errorString暂时为空，code始终为-1（1.0.1版本）
function callbackTab.onGetProductInfoFailure(code, errorString)
    TIPS( { type = 1 , str = "支付失败", flag = 1 } )
    payNetLoading(false)
    print("callbackTab.onGetProductInfoFailure", code, errorString)

    reportBuyDiamondEvent("GetProductInfoFailue", code)
    callbackTab.startPayTimeCallback = os.clock()
end

--网络错误，参数：具体在进行哪一步的时候发生网络错误
--1.下单 2 苹果支付 3 发货
function callbackTab.onNetWorkError(state)
    print("callbackTab.onNetWorkError", state)

    payNetLoading(false)

    if state == 1 or state == 2 then
        TIPS( { type = 1 , str = "支付失败, 网络异常, 请稍后再试", flag = 1 } )
    else
        TIPS( { type = 1 , str = "支付成功, 请稍后查询结果", flag = 0 } )
    end

    reportBuyDiamondEvent("NetWorkError", state)
    callbackTab.startPayTimeCallback = os.clock()
end

function callbackTab.onLoginExpiry()
    print("callbackTab.onLoginExpiry")

    payNetLoading(false)
    TIPS( { type = 1 , str = "支付失败。登录过期, 请重新登录", flag = 1 } )

    reportBuyDiamondEvent("LoginExpiry", 0)
    callbackTab.startPayTimeCallback = os.clock()
end

function callbackTab.canShowLoadingNow()
    print("callbackTab.canShowLoadingNow")
end

--参数输入错误，打印log的回调
function callbackTab.onParameterWrong(result, errorMsg)
    print("callbackTab.onParameterWrong", result, errorMsg)
    payNetLoading(false)

    reportBuyDiamondEvent("onParameterWrong", 0)
    callbackTab.startPayTimeCallback = os.clock()
end

--获取推荐个数列表
function callbackTab.onGetRecommendedListSucceeded(recommendedListJsonString)
    print("callbackTab.onGetRecommendedListSucceeded", recommendedListJsonString)
end

function callbackTab.onGetRecommendedListFailure(errorCode, errorMsg)
    print("callbackTab.onGetRecommendedListFailure", errorCode, errorMsg)
end

function callbackTab.notSupportIapPay()
    print("callbackTab.notSupportIapPay")

    payNetLoading(false)
    TIPS( { type = 1 , str = "现在不能充值", flag = 1 } )

    reportBuyDiamondEvent("NotSupportIapPay", 0)
    callbackTab.startPayTimeCallback = os.clock()
end
