-- 领取关卡奖励

function api_expedition_reward(request)
    local response = {
        ret=-1,
        msg='error',
        data = {},
    }

    local uid = request.uid
    local id  = tonumber(request.params.id) or 1
    if uid ==nil or id==nil then
        response.ret=-102
        return response
    end
    local uobjs = getUserObjs(uid)
    uobjs.load({"userinfo","userexpedition","hero","troops"})
    local mUserExpedition = uobjs.getModel('userexpedition')
    local mUserinfo       = uobjs.getModel('userinfo')
    if moduleIsEnabled('expedition') == 0 or moduleIsEnabled('hero') == 0  then
      response.ret = -13000
      return response
    end
    if type(mUserExpedition.info.r)~='table' then  mUserExpedition.info.r={}   end 
    
    if id>mUserExpedition.eid or id<=0 then
        response.ret=-13005
        return response
    end 

    local flag=table.contains(mUserExpedition.info.r,id)
    if flag then
        response.ret=-13006
        return response
    end

     --  加奖励
    local Reward,point = mUserExpedition.getReward(id)
    if next(Reward) then
        local ret = takeReward(uid,Reward)
        if not ret then
            response.ret = -403
            return response
        end
        response.data.reward = formatReward(Reward)
    end
    if point>0 then
        mUserExpedition.addResource("point",point)
        response.data.p=mUserExpedition.point
    end

    table.insert(mUserExpedition.info.r,id)

    if uobjs.save() then  
        mUserExpedition.binfo=nil
        response.data.expedition=mUserExpedition.toArray(true)
        response.ret = 0
        response.msg = 'Success'
    end

    return response
end