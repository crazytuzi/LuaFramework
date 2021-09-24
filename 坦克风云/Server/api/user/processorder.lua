function api_user_processorder(request)    
    local response = {
        ret=-1,
        msg='error',
        data = {},
        cmd = "msg.pay",
    }

    local platform = request.params.platform or getConfig('base.AppPlatform')

    if platform == nil then
        response.ret = -102
        return response
    end

    -- 支付类型，对应php脚本时用的    
    local payType = {
        google='google',
        apple='apple',
        kuaiyong='kuaiyong',
    }
   
   local appStorePayMent = require "lib.paycenter"    
   appStorePayMent.request = request
   appStorePayMent.platform = platform
   local updateConditions = {}

    -- apple支付
    -- 直拉去php的paycenter获取信息
    -- 如果有sendbox参数，表示是测试，否则请求appstore的正式地址，
    local function pay_apple(request)     
        local orderId = request.params.orderId    
        local num = request.params.num

        if orderId == nil or num == nil then
            response.ret = -102
            return false
        end

        appStorePayMent.ConsumeStreamId = orderId
        appStorePayMent.GoodsCount = num

        return true
    end

    -- google支付
    local function pay_google(request)
        local orderId = request.params.orderId
  
        if orderId == nil then
            response.ret = -102
            return false
        end

        appStorePayMent.ConsumeStreamId = orderId
       
       return true
    end

    local function pay_kuaiyong(request)
        local dealseq = request.params.dealseq
        local orderId = request.params.orderId 
  
        if dealseq == nil or orderId == nil then
            response.ret = -102
            return false
        end

        appStorePayMent.ConsumeStreamId = dealseq
        updateConditions.comment = orderId

       return true
    end

     local function pay_qihoo(request)
        local app_order_id = request.params.app_order_id
        local orderId = request.params.odder_id 
  
        if app_order_id == nil or orderId == nil then
            response.ret = -102
            return false
        end

        appStorePayMent.ConsumeStreamId = app_order_id
        updateConditions.comment = orderId

       return true
    end

    local function pay_memoriki(request)
        local orderId = request.params.orderId
  
        if orderId == nil then
            response.ret = -102
            return false
        end

        appStorePayMent.ConsumeStreamId = orderId

       return true
    end

    local function pay_efun(request)
       local app_order_id = request.params.app_order_id
       local orderId = request.params.odder_id 
 
       if app_order_id == nil or orderId == nil then
           response.ret = -102
           return false
       end

       appStorePayMent.ConsumeStreamId = app_order_id
       updateConditions.comment = orderId
       appStorePayMent.extra_num = request.params.extra_num 

      return true
   end
    -- 按平台支付

    if platform == 'apple' then
        if not pay_apple(request) then
            return response
        end
    elseif platform == 'googleplay' then
         if not pay_google(request) then
            return response
        end
    elseif platform == 'kuaiyong' then
        if not pay_kuaiyong(request) then
            return response
        end
    elseif platform == 'qihoo' then
         if not pay_qihoo(request) then
            return response
        end
    elseif platform == 'memoriki' then
         if not pay_memoriki(request) then            
            return response
        end
    elseif platform == 'efun' then
         if not pay_efun(request) then            
            return response
        end
    else
        return response
    end
    
    local ret,code = appStorePayMent:processOrder()
    local uid = tonumber(request.uid)
    uid = uid or appStorePayMent.uid

    if not ret then
        appStorePayMent:payLog({uid=uid,msg="pay failed (processOrder)",code=code})
        response.ret = code
        sendMsgByUid(uid,json.encode(response))
        return response
    end
        
    local uobjs = getUserObjs(uid)
    local mUserinfo = uobjs.getModel('userinfo')

    local addGemRet = true
    if mUserinfo.buygems == 0 then
        local firstChargeAward = copyTable(getConfig("firstCharge"))
        local firstExtraNum

        local zoneid = getZoneId()
        if firstChargeAward.additional and firstChargeAward.additional[zoneid] then
            local ts = getClientTs()            
            if ts >= (firstChargeAward.additional[zoneid].st or 0) and ts < (firstChargeAward.additional[zoneid].et or 0) then                
                firstExtraNum = math.floor(firstChargeAward.additional[zoneid].value * appStorePayMent.num)
            end
        end
        
        activity_setopt(uid,'firstRecharge',{num=appStorePayMent.num})
        
        if firstExtraNum and firstExtraNum > 0 then
            --addGemRet = mUserinfo.addResource({gems=firstExtraNum})
        end
    else
        local uobjs = getUserObjs(uid)
        local mUseractive = uobjs.getModel('useractive')

        if (mUseractive.info.firstRecharge and (mUseractive.info.firstRecharge.c or 0) < 0) or (mUserinfo.buygems > 0 and not mUseractive.info.firstRecharge ) then
            activity_setopt(uid,'rechargeDouble',{num=appStorePayMent.num})
            --战备军需
            activity_setopt(uid,'rechargeFight',{num=gold_num})            
        end
    end

    activity_setopt(uid,'dayRecharge',{num=appStorePayMent.num})
    activity_setopt(uid,'bindDayRecharge',{num=appStorePayMent.num})
    activity_setopt(uid,'dayRechargeForEquip',{num=appStorePayMent.num})
    activity_setopt(uid,'totalRecharge',{num=appStorePayMent.num})
    activity_setopt(uid,'bindTotalRecharge',{num=appStorePayMent.num})
    activity_setopt(uid,'totalRecharge2',{num=appStorePayMent.num})
    activity_setopt(uid,'rechargeRebate',{num=appStorePayMent.num})
    --基金
    activity_setopt(uid,'userFund',{num=appStorePayMent.num})


    -- 投资计划
    activity_setopt(uid,'investPlan',{num=appStorePayMent.num})

    --VIP总动员活动
    activity_setopt(uid,'vipAction',{num=appStorePayMent.num})
    
    if (not addGemRet) or (not mUserinfo.addGem(appStorePayMent.num)) then
        appStorePayMent:payLog({uid=uid,msg="pay failed(add Gem .. award)",code=-130})
        response.ret = -130
        sendMsgByUid(uid,json.encode(response))
        return response
    end        

    if uobjs.save() then
        processEventsAfterSave()

        if not appStorePayMent:updateOrderStatus(updateConditions) then
            appStorePayMent:payLog({uid=uid,msg="pay Success but order status update failed",code=-128})
        end

        response.data.userinfo = mUserinfo.toArray(true)
        response.data.payment = {}
        response.data.payment.itemId = appStorePayMent.GoodsId
        response.data.payment.token = appStorePayMent.token
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
    
    appStorePayMent:payLog({uid=uid,msg="pay failed(getOrderData)",code=-126})
    sendMsgByUid(uid,json.encode(response))

    return response
end
