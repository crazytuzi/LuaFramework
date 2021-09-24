function api_mail_reward(request)
     local response = {
            ret=-1,
            msg='error',
            data = {},
        }

    local uid = request.uid
    local mid = tonumber(request.params.mid)
    
     if uid == nil or mid == nil then
        response.ret = -102
        return response
    end

    local uobjs = getUserObjs(uid)
    uobjs.load({"userinfo", "techs","alien","wcrossinfo","troops","useractive" ,"props","bag","skills","buildings","dailytask","task"})

    local mUserinfo = uobjs.getModel('userinfo')
    local mCrossinfo = uobjs.getModel('wcrossinfo')

    
    local mailInfo = MAIL:mailGet(uid,mid)

    if not mailInfo then
        response.ret = -2011
        return response
    end

    if tonumber(mailInfo.isreward)==1 then
        response.ret = -1976
    end  
    
    local ret,reward 
    if tonumber(mailInfo.gift) == 1 or tonumber(mailInfo.gift)==2 or tonumber(mailInfo.gift)==5 or tonumber(mailInfo.gift)==6 or tonumber(mailInfo.gift)==8 or tonumber(mailInfo.gift)==9 or tonumber(mailInfo.gift)==10 or tonumber(mailInfo.gift)==11 or tonumber(mailInfo.gift)==12 or tonumber(mailInfo.gift)==13 or tonumber(mailInfo.gift)==14 or tonumber(mailInfo.gift)==15 then
        reward = mailInfo.item.h  
        
        ret = takeReward(uid,reward)
        reward = mailInfo.item.q
    end
   
    -- 添加世界大战的商店积分
    if tonumber(mailInfo.gift) == 3 then
        local point =tonumber(mailInfo.item)
        mCrossinfo.addAdminPoint(point)
        ret=true
    end
    


     -- 添加异星科技资源
    if tonumber(mailInfo.gift) == 4 then
        local res =(mailInfo.item.h)
        local mAlien = uobjs.getModel('alien')
        if type(res)=='table' and next(res) then
            
            for k,v in pairs (res) do
                local ret =mAlien.addMineProp(k,v)
                if not ret then
                    return response
                end
            end
        end
        ret=true
    end
    local mret = MAIL:mailReward(uid,mid)

    if ret and  mret  then
        if uobjs.save() then
            response.ret = 0        
            response.msg = 'Success'
        end
        
    end

    return response
end
