-- 首次加入军团或者创建军团领取奖励

function api_alliance_oncereward(request)
    
    local response = {
        ret=-1,
        msg='error',
        data = {},
    }

    local uid = request.uid
   
    if uid == nil  then
        response.ret = -102
        return response
    end

    local uobjs = getUserObjs(uid)
    uobjs.load({"userinfo"})
    local mUserinfo = uobjs.getModel('userinfo')

    if mUserinfo.alliance <=0 then
        response.ret = -8012
        return response
    end

   
    local date  = getWeeTs()
    local acceptRet,code = M_alliance.get{aid=aid,uid=uid,date=date}

    if not acceptRet then
        response.ret = code
        return response
    end

    local oc = tonumber(acceptRet.data.user.oc) or 1
    if tonumber(acceptRet.data.alliance.aid) <=0 then
        response.ret = -8012
        return response
    end
    if tonumber(acceptRet.data.alliance.aid) <=0 then
        response.ret = -8012
        return response
    end
    if oc ==1 then
        response.ret = -1976
        return response
    end
    local player = getConfig("player")
    local reward = player.alliancereward
    local ret = takeReward(uid,reward)
    if not ret then
        response.ret = -403
        return response
    end
    --修改领取标识
    local joinAtData,code = M_alliance.admin{uid=uid,aid=mUserinfo.alliance,onecreward=1 }
    if type(joinAtData) ~= 'table' or joinAtData['ret'] ~= 0 then
            return response
    end


    if uobjs.save() then
        response.ret = 0        
        response.msg = 'Success'
        response.data.reward=formatReward(reward)
    end
    return response
end
