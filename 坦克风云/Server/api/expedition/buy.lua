-- 远征军商店购买

function api_expedition_buy(request)
    local response = {
        ret=-1,
        msg='error',
        data = {},
    }

    local uid = request.uid
    local id  = tonumber(request.params.id) or 1
    local pid  = request.params.pid
    local count  = tonumber(request.params.count) 
    if uid ==nil or id==nil or pid==nil or count<0 then
        response.ret=-102
        return response
    end
    local uobjs = getUserObjs(uid)
    uobjs.load({"userinfo","userexpedition","hero","troops","bag"})
    local mUserExpedition = uobjs.getModel('userexpedition')
    local mUserinfo       = uobjs.getModel('userinfo')
    local mBag       = uobjs.getModel('bag')
    if moduleIsEnabled('expedition') == 0 or moduleIsEnabled('hero') == 0  then
      response.ret = -13000
      return response
    end
    local weets= getWeeTs()
    local ts   = getClientTs()
    if type(mUserExpedition.info.buy)~='table' then mUserExpedition.info.buy={}  end
    if type(mUserExpedition.info.shop)~='table' then mUserExpedition.info.shop={}  end
    
    local flag=table.contains(mUserExpedition.info.buy,id)
    if flag then
        response.ret=-13009
        return response
    end
    if type(mUserExpedition.info.shop[id])~='table' then
        response.ret=-102
        return response
    end 
    local item =mUserExpedition.info.shop[id]
    if item[1]~=pid or item[2]~=count then
        response.ret=-13010
        return response
    end
    local point=item[3]
    local reward={[item[1]]=count}

    if mUserExpedition.point< point or point<=0 then 
        response.ret=-13011
        return response
    end

    local ret = takeReward(uid,reward)
    if not ret then
        response.ret = -403
        return response
    end

    table.insert(mUserExpedition.info.buy,id)
    if not mUserExpedition.usePoint({p=point}) then
        response.ret= -1996
        return response
    end

    -- 中秋赏月活动埋点
    activity_setopt(uid, 'midautumn', {action='eu'})
    -- 国庆活动埋点
    activity_setopt(uid, 'nationalDay', {action='eu'})
    -- 春节攀升
    activity_setopt(uid, 'chunjiepansheng', {action='eu', num=count})

    if uobjs.save() then  
        response.ret = 0
        response.msg = 'Success'
    end

    
    return response 


end
