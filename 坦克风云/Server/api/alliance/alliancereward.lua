-- 军团活跃的奖励

function api_alliance_alliancereward(request)
    local response = {
        ret=-1,
        msg='error',
        data = {},
    }

    local uid   = request.uid
    local resource =request.params.res
    if uid == nil then
        response.ret = -102
        return response
    end
    local uobjs = getUserObjs(uid)
    local mUserinfo = uobjs.getModel('userinfo')
    if mUserinfo.alliance <=0 then
        response.ret = -8023
        return response
    end
    local weeTs=getWeeTs()
    local execRet, code = M_alliance.getResourceReward{uid=uid,aid=mUserinfo.alliance,weet=weeTs,res=json.encode(resource)}
    
    if not execRet then
        response.ret = code
        return response
    end


    local addresource={}
    if execRet.data.res then
        local l=tonumber(execRet.data.l)
        if l<=1 then
            return response
        end
        local join_at=tonumber(execRet.data.join_at)
        local join_at = getWeeTs(join_at)
        local weeTs = getWeeTs()
        if join_at>=weeTs then
             return response
        end

        local allianceActiveReward = getConfig("alliance.allianceActiveReward")
        for k,v in pairs (execRet.data.res) do
            if v>0 then
                addresource[k]=math.ceil(v*allianceActiveReward[l])
            end
        end
    end
    mUserinfo.addResource(addresource)
    if uobjs.save() then    
        response.ret = 0
        response.data.res = addresource
        response.msg = 'Success'
    end
    
    return response
end