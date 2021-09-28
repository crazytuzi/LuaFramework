
module ("PayMsg", package.seeall)

local function onPayParamsError(buff)
    print("onPayParamsError")
    g_msgHandlerInst:sendNetDataByTable(TPAY_CS_UPDATE_PARAMS, "TPayUpdateParams", {openKey=sdkGetOpenId(), payToken=sdkGetPayToken(),pf=sdkGetPf(), pfKey=sdkGetPfKey()})
end

local function onPaySuccess(buff)
    local t = g_msgHandlerInst:convertBufferToTable("TPayCZSucessRet", buff)
    print("paySucess", t.money)
    --cc.UserDefault:getInstance():setIntegerForKey("pay" .. sdkGetOpenId() .. tostring(userInfo.serverId) .. "_" .. tostring(userInfo.currRoleStaticId), 0)
    --TIPS( { type = 1 , str = "支付成功 获得 " .. t.money .. " 元宝" } )
end

function sendSdkPaySucess(money)
    print("sendSdkPaySucess", money)
    g_msgHandlerInst:sendNetDataByTable(TPAY_CS_CZSUCESS, "TPayCZSucess", {openKey=sdkGetOpenId(), payToken=sdkGetPayToken(),pf=sdkGetPf(), pfKey=sdkGetPfKey(),money=money})
    --cc.UserDefault:getInstance():setIntegerForKey("pay" .. sdkGetOpenId() .. tostring(userInfo.serverId) .. "_" .. tostring(userInfo.currRoleStaticId), money)
end

function checkPayResult()
    print("checkPayResult")
    --local money = cc.UserDefault:getInstance():getIntegerForKey("pay" .. sdkGetOpenId() .. tostring(userInfo.serverId) .. "_" .. tostring(userInfo.currRoleStaticId), 0)
    --if money and money > 0 then
    --    sendSdkPaySucess(money)
    --end
end

g_msgHandlerInst:registerMsgHandler(TPAY_SC_NOTIFY_PARAMS_ERROR, onPayParamsError)
g_msgHandlerInst:registerMsgHandler(TPAY_SC_CZSUCESS_RET, onPaySuccess)
