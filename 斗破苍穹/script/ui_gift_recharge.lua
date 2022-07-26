require"Lang"
require "net"
require "SDK"

UIGiftRecharge = {
    retList = nil,-- retList格式为  字典id_0;字典id_1;....最后没有分号 字典id后边的0和1：//0-未充过钱  1-充过钱
}
local scrollView = nil
local listItem = nil
local retListTab = nil

local function giftVipCallBack(pack)
    if pack.msgdata.int and pack.msgdata.int["1"] then
        dp.rechargeGold = pack.msgdata.int["1"]
    else
        return
    end
    UIManager.replaceScene("ui_gift_vip")
end

function UIGiftRecharge.init(...)
    local btn_close = ccui.Helper:seekNodeByName(UIGiftRecharge.Widget, "btn_close")
    local btn_sure = ccui.Helper:seekNodeByName(UIGiftRecharge.Widget, "btn_sure")
    local function TouchEvent(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            AudioEngine.playEffect("sound/button.mp3")
            if sender == btn_close then
                UIManager.popScene()
            elseif sender == btn_sure then
                utils.checkGOLD(0, giftVipCallBack)
            end
        end
    end
    btn_close:setPressedActionEnabled(true)
    btn_sure:setPressedActionEnabled(true)
    btn_close:addTouchEventListener(TouchEvent)
    btn_sure:addTouchEventListener(TouchEvent)
    scrollView = ccui.Helper:seekNodeByName(UIGiftRecharge.Widget, "view")
    listItem = scrollView:getChildByName("image_base_di")
end

-- FOR IOS
local EC_SUCCEED = 0
local EC_RESTORED = 1
local EC_USERCANCELLED = 2
local EC_DISALLOWED = 3
local EC_REQUESTERROR = 4
local EC_FAILED = 5

local function savePay(productID, userDatas, base64Receipt)
    local payStr = cc.UserDefault:getInstance():getStringForKey("iapPayData")
    if payStr ~= "" then
        payStr = payStr .. "^" .. productID .. "^" .. userDatas .. "^" .. base64Receipt
    else
        payStr = productID .. "^" .. userDatas .. "^" .. base64Receipt
    end
    cc.UserDefault:getInstance():setStringForKey("iapPayData", payStr)
end

local function doVerifyPay(productID, userDatas, base64Receipt)
    local ud = dp.getUserData()
    if (not ud) or(not SDK.getUserId()) then return end
    local http = cc.XMLHttpRequest:new()
    http.responseType = cc.XMLHTTPREQUEST_RESPONSE_STRING
    http:registerScriptHandler( function()
        if http.status == 200 then
            local payStr = cc.UserDefault:getInstance():getStringForKey("iapPayData")
            if payStr ~= "" then
                local newPay = { }
                local pay = utils.stringSplit(payStr, "%^")
                for i = 1, #pay, 3 do
                    if pay[i + 2] ~= base64Receipt then
                        table.insert(newPay, pay[i])
                        table.insert(newPay, pay[i + 1])
                        table.insert(newPay, pay[i + 2])
                    end
                end
                payStr = table.concat(newPay, "^", 1, #newPay)
                cc.UserDefault:getInstance():setStringForKey("iapPayData", payStr)
                UIGiftRecharge.checkPay()
            end
        elseif netIsConnected() then
            UIGiftRecharge.checkPay()
        end
    end )
    http:open("POST", SDK.getNotifyUri())
    http:setRequestHeader("Content-Type", "application/octet-stream")
    local di = SDK.getDeviceInfo()

    local channel_id = "yiyou"
    if di.packageName == "com.y2game.doupocangqiong" then
        channel_id = "iosy2game"
    elseif  di.packageName == "com.dpdl.20161009.zy" then
        channel_id = "iosy2gamenew"
    end

    http:send(
    "receipt=" .. utils.encodeURI(base64Receipt) ..
    "&product_id=3" ..
    "&server_id=" .. ud.serverId ..
    "&user_id=" .. SDK.getUserId() ..
    "&channel_id=" .. channel_id ..
    "&role_id=" .. ud.roleId ..
    "&role_name=" .. ud.roleName ..
    "&role_level=" .. ud.roleLevel ..
    "&device_os=" .. di.systemName ..
    "&device_mac=" .. di.macAddr ..
    "&idfa=" .. di.idfa ..
    "&app_product_id=" .. productID ..
    "&orderform=" .. userDatas
    )
end

local function onPay(params)
    if SDK.getChannel() == "iosy2game" or SDK.getChannel() == "iosy2gamenew"then
        cclog("ErrorCode: " .. params.errorCode)
        if params.errorCode == EC_SUCCEED or params.errorCode == EC_RESTORED then
            cclog("ProductID: " .. params.productID)
            cclog("UserDatas: " .. params.userDatas)
            savePay(params.productID, params.userDatas, params.base64Receipt)
            doVerifyPay(params.productID, params.userDatas, params.base64Receipt)
        elseif params.errorCode == EC_USERCANCELLED then
            cclog("1111")
        elseif params.errorCode == EC_DISALLOWED then
            cclog("222")
        elseif params.errorCode == EC_REQUESTERROR then
            cclog("333")
        elseif params.errorCode == EC_FAILED then
            cclog("444")
        end
        UIManager.hideLoading()
    else
        -- todo 不作处理
    end
end

UIGiftRecharge.onPay = onPay

-- 检测是否有未处理完的交易
function UIGiftRecharge.checkPay()
    if SDK.getChannel() == "qq" then
        local payStr = cc.UserDefault:getInstance():getStringForKey("qqPayData")
        local payStr1 = cc.UserDefault:getInstance():getStringForKey("qqPayData1")
        if payStr ~= "" then
            local pay = utils.stringSplit(payStr, "%^")          
            SDK.onPay( pay[1] )
            cc.JNIUtils:logAndroid( "save do pay11133334444:" .. pay[1]  )
        elseif payStr1 ~= "" then
            local pay = utils.stringSplit(payStr1, "%^")      
            local value = utils.stringSplit( pay[1] , "|" )   
            SDK.doSendOrderId( { value[ 1 ] , value[ 2 ] , value[ 3 ] } )
           cc.JNIUtils:logAndroid( "save do pay1113333:" .. payStr1  )
        end
        return
    end
    if device.platform ~= "ios" then return end

    local payStr = cc.UserDefault:getInstance():getStringForKey("iapPayData")
    if payStr ~= "" then
        local pay = utils.stringSplit(payStr, "%^")
        local productID = pay[1]
        local userDatas = pay[2]
        local base64Receipt = pay[3]
        doVerifyPay(productID, userDatas, base64Receipt)
    end
end

local requestingProduct -- 参见DictRecharge.lua

local function onGetOrderID(pack)
    -- todo check requestingProduct?
    local orderID = pack.msgdata.string["1"]
    local productID = requestingProduct.id
    local priceYUAN = requestingProduct.rmb
    local di = SDK.getDeviceInfo()

    local productNames = { Lang.ui_gift_recharge1, Lang.ui_gift_recharge2, Lang.ui_gift_recharge3, Lang.ui_gift_recharge4, Lang.ui_gift_recharge5, Lang.ui_gift_recharge6, Lang.ui_gift_recharge7, Lang.ui_gift_recharge8, Lang.ui_gift_recharge9 }

    if SDK.getChannel() == "dev" then
        -- SDK.doPay(string,onPay)
    elseif SDK.getChannel() == "uc" or SDK.getChannel() == "baidu" then
        local productName = productNames[productID] or "";
        local info = { productName, orderID, tostring(productID), tostring(priceYUAN) }
        SDK.doPay(info, onPay)
    elseif SDK.getChannel() == "yijie" then
        if di.packageName == "com.doupo.ewan" then
            local productName = "";
            if productID == 1 then
                productName = Lang.ui_gift_recharge10;
            elseif productID == 9 then  
                productName = Lang.ui_gift_recharge11;
            else
                productName = Lang.ui_gift_recharge12;
            end
            local info = { productName, orderID, tostring(1), tostring(priceYUAN) }
            SDK.doPay(info, onPay)
        elseif di.packageName == "com.doupo.mz" then
            local productName = "";
            if productID == 1 then
                productName = Lang.ui_gift_recharge13;
            elseif productID == 9 then
                productName = Lang.ui_gift_recharge14;
            else
                productName = Lang.ui_gift_recharge15;
            end
            local info = { productName, orderID, tostring(1), tostring(priceYUAN) }
            SDK.doPay(info, onPay)
        else
            local productName = productNames[productID] or "";
            local info = { productName, orderID, tostring(1), tostring(priceYUAN) }
            SDK.doPay(info, onPay)
        end
    elseif SDK.getChannel() == "y2game" then
        local productName = productNames[productID] or "";
        local info = { productName, orderID, requestingProduct.firstAmtDes, tostring(priceYUAN) }
        SDK.doPay(info, onPay)
    elseif SDK.getChannel() == "lianxiang" then
        local wareSids = { "4316", "4309", "4310", "4311", "4312", "4313", "4314", "4315", "4311" }
        local wareSid = wareSids[productID] or "";
        local info = { wareSid, orderID, tostring(productID), tostring(priceYUAN) }
        SDK.doPay(info, onPay)
    elseif SDK.getChannel() == "xiaomi" then
        local role = dp.getUserData()
        local info = { orderID, tostring(productID), tostring(priceYUAN), tostring(role.vipLevel), tostring(role.roleLevel), role.roleName, tostring(role.roleId), role.serverName }
        SDK.doPay(info, onPay)
    elseif SDK.getChannel() == "qq" then
        local role = dp.getUserData()
        cc.JNIUtils:logAndroid("qq doPay ---------------------------------")
        local info = { tostring(role.serverId), tostring(priceYUAN), orderID }
        SDK.doPay(info)
    elseif SDK.getChannel() == "360" then
        local role = dp.getUserData()
        local info = {
            tostring(priceYUAN),Lang.ui_gift_recharge16,tostring(productID),Lang.ui_gift_recharge17,
            role.roleName,tostring(role.roleId),orderID
        }
        SDK.doPay(info, onPay)
    elseif SDK.getChannel() == "huawei" then
        local role = dp.getUserData()
        local info = { tostring(priceYUAN), Lang.ui_gift_recharge18, Lang.ui_gift_recharge19, orderID, tostring(role.roleId) }
        SDK.doPay(info, onPay)
    elseif SDK.getChannel() == "oppo" then
        local info = { orderID, tostring(priceYUAN), Lang.ui_gift_recharge20, Lang.ui_gift_recharge21 }
        SDK.doPay(info, onPay)
    elseif SDK.getChannel() == "vivo" then
        local channelData = pack.msgdata.string["2"]
        local info = { Lang.ui_gift_recharge22, Lang.ui_gift_recharge23, channelData }
        SDK.doPay(info, onPay)
    elseif SDK.getChannel() == "jinli" then
        local channelData = pack.msgdata.string["2"]
        local info = { channelData }
        SDK.doPay(info, onPay)
    elseif SDK.getChannel() == "kupai" then
        local channelData = pack.msgdata.string["2"]
        local info = { channelData }
        SDK.doPay(info, onPay)
    elseif SDK.getChannel() == "iosy2game" or SDK.getChannel() == "iosy2gamenew" then
        UIManager.showLoading()
        SDK.doPay( { productID = requestingProduct.description, userDatas = orderID }, onPay)
    elseif SDK.getChannel() == "anysdk" then
        local role = dp.getUserData()
        local productName = productNames[productID] or "";
        SDK.doPay( { goodsID = tostring( productID ),productID = requestingProduct.description, userDatas = orderID, product_Name = productName, productPrice = tostring(priceYUAN), product_Count = "1", roleId = tostring(role.roleId), roleName = tostring(role.roleName), roleGrade = tostring(role.roleLevel), server_Id = tostring(role.serverId) }, onPay)
    end


    local productName = "";
    if device.platform == "ios" then
        if SDK.getChannel() == "anysdk" then
            productName = productNames[productID] or productName;
        else
            local productNames = { Lang.ui_gift_recharge24, Lang.ui_gift_recharge25, Lang.ui_gift_recharge26, Lang.ui_gift_recharge27, Lang.ui_gift_recharge28, Lang.ui_gift_recharge29, Lang.ui_gift_recharge30, Lang.ui_gift_recharge31, Lang.ui_gift_recharge32 }
            productName = productNames[productID] or productName;
        end
    else
        productName = productNames[productID] or productName;
    end
    local info = { productName, orderID, tostring(priceYUAN) }
    SDK.doPayTD(info)
    requestingProduct = nil
end

function UIGiftRecharge.doGetOrderID(product)
    requestingProduct = product
    if device.platform == "windows" then
        cclog("模拟器不支持支付")
    elseif device.platform == "android" or device.platform == "ios" then
        UIManager.showLoading()
        local pack = {
            header = StaticMsgRule.getOrder,
            msgdata =
            {
                int =
                {
                    rechargeId = product.id
                }
            }
        }
        netSendPackage(pack, onGetOrderID)
    end
end

local function setScrollViewItem(Item, obj)
    local ui_image = ccui.Helper:seekNodeByName(Item, "image_good")
    local ui_number = ccui.Helper:seekNodeByName(Item, "text_number")
    local ui_price = ccui.Helper:seekNodeByName(Item, "text_price")
    local ui_text_info = ccui.Helper:seekNodeByName(Item, "text_info")
    local ui_text_xiangou = ccui.Helper:seekNodeByName(Item, "text_xiangou")
    local imageName = DictUI[tostring(obj.uiId)].fileName
    ui_image:loadTexture("image/" .. imageName)
    ui_price:setString(obj.rmb .. Lang.ui_gift_recharge33)
    if SDK.getChannel() == "iosy2game" or SDK.getChannel() == "iosy2gamenew" then
        if obj.firstAmt == 0 then
            ui_number:setString(obj.rmb .. Lang.ui_gift_recharge34)
        else
            ui_number:setString(obj.rmb * 10 .. Lang.ui_gift_recharge35)
        end
    else
        ui_number:setString(obj.rmb * 10 .. Lang.ui_gift_recharge36)
    end
    if tonumber(retListTab[obj.id]) ~= 0 then
        ui_text_info:setString(obj.noFirstAmtDes)
        ui_text_xiangou:setVisible(false)
    elseif obj.firstAmt == -1 then
        ui_text_info:setString(obj.noFirstAmtDes)
        ui_text_xiangou:hide()
    else
        ui_text_info:setString(obj.firstAmtDes)
        if obj.id == 1 or obj.id == 9 then
            ui_text_xiangou:setVisible(false)
        else
            ui_text_xiangou:setVisible(true)
        end
    end
    if IOS_PREVIEW then
        ui_text_xiangou:setVisible(false)
    end
    Item:setEnabled(true)
    Item:setTouchEnabled(true)
    local function chargeEvent(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            if obj.id == 1 or obj.id == 9 then
                -- if device.platform == "ios" then
                local type = obj.id == 1 and UIActivityCard.SILVER_MONTH_CARD or UIActivityCard.GOLD_MONTH_CARD
                local name = obj.id == 1 and Lang.ui_gift_recharge37 or Lang.ui_gift_recharge38
                local instActivityObj = UIActivityCard.getMonthCardData(type)
                if instActivityObj then
                    local buyCount = (instActivityObj.string["8"] and instActivityObj.string["8"] ~= "") and tonumber(instActivityObj.string["8"]) or 0
                    if buyCount >= 99 then
                        UIManager.showToast(Lang.ui_gift_recharge39)
                    else
                        UIGiftRecharge.doGetOrderID(obj)
                    end
                    --[[
                    if instActivityObj.string["4"] == "" then
                        UIManager.showToast(Lang.ui_gift_recharge40 .. name .. Lang.ui_gift_recharge41)
                    else
                        if UIActivityPanel.isEndActivityByEndTime(instActivityObj.string["4"]) then
                            UIGiftRecharge.doGetOrderID(obj)
                        else
                            UIManager.showToast(Lang.ui_gift_recharge42 .. name .. Lang.ui_gift_recharge43)
                        end
                    end
                    --]]
                else
                    UIGiftRecharge.doGetOrderID(obj)
                end
                --  else
                --      UIGiftRecharge.doGetOrderID(obj)
                --      -- UIManager.showToast("暂未开放!")
                --  end
            else
                UIGiftRecharge.doGetOrderID(obj)
            end
        end
    end
    Item:addTouchEventListener(chargeEvent)
end

function UIGiftRecharge.setup(...)
    scrollView:removeAllChildren()
    -- if UIGiftVip.getState() then
    -- 	ccui.Helper:seekNodeByName(UIGiftRecharge.Widget, "image_hint"):setVisible(true)
    -- else
    ccui.Helper:seekNodeByName(UIGiftRecharge.Widget, "image_hint"):setVisible(false)
    -- end
    local currentVipNum = net.InstPlayer.int["19"]
    local nextVipNum = currentVipNum + 1
    local limit = nil
    if DictVIP[tostring(nextVipNum + 1)] then
        limit = DictVIP[tostring(nextVipNum + 1)].limit
    end
    local ui_label_vip = ccui.Helper:seekNodeByName(UIGiftRecharge.Widget, "text_vip")
    local ui_text_loading = ccui.Helper:seekNodeByName(UIGiftRecharge.Widget, "text_loading")
    local ui_loading = ccui.Helper:seekNodeByName(UIGiftRecharge.Widget, "bar_loading")
    local ui_image_gold = ccui.Helper:seekNodeByName(UIGiftRecharge.Widget, "image_gold")
    local ui_text_vip = ui_image_gold:getChildByName("text_vip")
    local ui_text_recharge = ui_image_gold:getChildByName("text_recharge")
    local ui_text_hint = ccui.Helper:seekNodeByName(UIGiftRecharge.Widget, "text_hint")
    ui_label_vip:setString(currentVipNum)
    if limit then
        ui_image_gold:setVisible(true)
        ui_text_hint:setVisible(false)
        ui_text_loading:setString(string.format("%d/%d", dp.rechargeGold, limit * 10))
        local number = dp.rechargeGold /(limit * 10) * 100
        if number > 100 then
            ui_loading:setPercent(100)
        else
            ui_loading:setPercent(number)
        end
        ui_text_vip:setString(string.format(Lang.ui_gift_recharge44, nextVipNum))
        ui_text_recharge:setString(string.format(Lang.ui_gift_recharge45, limit * 10 - dp.rechargeGold))
    else
        ui_text_loading:setString("MAX")
        ui_loading:setPercent(100)
        ui_image_gold:setVisible(false)
        ui_text_hint:setVisible(true)
    end
    if UIGiftRecharge.retList then
        retListTab = { }
        local _retListTab = utils.stringSplit(UIGiftRecharge.retList, ";")
        for key, obj in pairs(_retListTab) do
            local strTab = utils.stringSplit(obj, "_")
            table.insert(retListTab, strTab[1], strTab[2])
        end
    end
    local rechargeThing = { }

    for key, obj in pairs(DictRecharge) do
        table.insert(rechargeThing, obj)
    end
    utils.quickSort(rechargeThing, function(obj1, obj2)
        local rmb1 = obj1.firstAmt == 0 and obj1.rmb - 10000 or obj1.rmb
        local rmb2 = obj2.firstAmt == 0 and obj2.rmb - 10000 or obj2.rmb
        return rmb1 > rmb2
    end )
    utils.updateView(UIGiftRecharge, scrollView, listItem, rechargeThing, setScrollViewItem)
end

function UIGiftRecharge.free()
    scrollView:removeAllChildren()
    retListTab = nil
    UIGiftRecharge.retList = nil
end
