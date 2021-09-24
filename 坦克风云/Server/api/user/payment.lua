function api_user_payment(request)
    local response = {
        ret=-1,
        msg='error',
        data = {},
        cmd = "msg.pay",
    }

    local uid = request.uid
    local iapOrder = request.params.iapOrder
    local sandbox = request.params.sandbox

    if uid == nil or iapOrder == nil then
        response.ret = -102
        return response
    end

    local appStorePayMent = require "lib.payment_appstore"
    local result

    for i=1,3 do
        result = appStorePayMent:getOrderData(iapOrder,sandbox)
        if result and result.ret==0 then
            break
        end
        if result and result.ret==21007 then
            result = appStorePayMent:getOrderData(iapOrder,true)
        end
    end

    local uobjs
    local orderStr = appStorePayMent.iapOrder or 'null'

    if result and result.ret==0 then
        local ret,code = appStorePayMent:processOrder(uid)
        if not ret then
            appStorePayMent:payLog({uid=uid,msg="pay failed (processOrder)",code=code})
            response.ret = code
            sendMsgByUid(uid,json.encode(response))
            return response
        end

        uobjs = getUserObjs(uid)
        local mUserinfo = uobjs.getModel('userinfo')

        local addGemRet = true
        if mUserinfo.buygems == 0 then
            local firstChargeAward = copyTable(getConfig("firstCharge"))

            local zoneid = getZoneId()
            if firstChargeAward.additional and firstChargeAward.additional[zoneid] then
                local ts = getClientTs()            
                if ts >= (firstChargeAward.additional[zoneid].st or 0) and ts < (firstChargeAward.additional[zoneid].et or 0) then
                    firstChargeAward.userinfo_gems = firstChargeAward.userinfo_gems + firstChargeAward.additional[zoneid].value
                end
            end
            
            firstChargeAward.userinfo_gems = math.floor(firstChargeAward.userinfo_gems * appStorePayMent.num)

            addGemRet = takeReward(uid,firstChargeAward)

            local mBag = uobjs.getModel('bag')
            response.data.bag = mBag.toArray(true)
            -- addGemRet = mUserinfo.addResource({gems=appStorePayMent.num})
        end

        if (not addGemRet) or (not mUserinfo.addGem(appStorePayMent.num)) then
            appStorePayMent:payLog({uid=uid,msg="pay failed(add Gem .. award)",code=-130})
            response.ret = -130
            sendMsgByUid(uid,json.encode(response))
            return response
        end

        if uobjs.save() then
            processEventsAfterSave()
            
            if not appStorePayMent:updateOrderStatus() then
                appStorePayMent:payLog({uid=uid,msg="pay Success but order status update failed",code=-128})
            end

            response.data.userinfo = mUserinfo.toArray(true)
            response.data.payment = {}
            response.data.payment.itemId = appStorePayMent.GoodsId
            response.data.payment.GoodsCount = appStorePayMent.GoodsCount
            response.data.payment.num = appStorePayMent.num
            response.data.payment.orderId = appStorePayMent.ConsumeStreamId
            response.data.payment.amount = appStorePayMent.cost

            response.ret = 0
            response.msg = 'Success'
            sendMsgByUid(uid,json.encode(response))
            return response
        else
            appStorePayMent:payLog({uid=uid,msg="pay failed(save userinfo)",code=-130})
            response.ret = -130
            sendMsgByUid(uid,json.encode(response))
            return response
        end
    end

    appStorePayMent:payLog({uid=uid,msg="pay failed(getOrderData)",code=-126})
    sendMsgByUid(uid,json.encode(response))

    return response

end
