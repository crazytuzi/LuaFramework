-- 应用包礼包

function api_admin_addrewardbag(request)
    local response = {
        ret=-1,
        msg='error',
        data = {},
    }
    
    local uid = tonumber(request.uid)
    local tid = tonumber(request.params.tid)
    local zid = tonumber(request.zoneid)
    local check= request.params.type
    if uid == nil or tid == nil then
        response.ret = -103
        return response
    end
    
    local uobjs = getUserObjs(uid)
    
    local mUserinfo = uobjs.getModel('userinfo')  

    local reward = getConfig("yybgiftbagCfg."..tid)
    if  reward.l==nil or reward.l>mUserinfo.level    then
        response.ret = -104
        return response
    end

    if check~=nil and check=='check' then

        response.ret = 0
        response.msg = 'Success'
        return response
    end

    local weets      = getWeeTs()
    local redis = getRedis()
    -- 是领取每天的宝箱
    local daykey="z."..zid.."yybgiftbag."..uid.."ts."..weets.."tid."..tid
    local key="z."..zid.."yybgiftbag."..uid
    local dayflag=false
    local tflag   =false
    local data={}
    if reward.day~=nil and reward.day==1 then
        local count=tonumber(redis:get(daykey))
        local addcount=1
        if tid==6510 then
            addcount=9
        end
        if count~=nil and count>=addcount then
            response.ret=-103
            return response
        end
        dayflag=true
    else
        data=json.decode(redis:get(key))

        if type(data)~='table' then data={} end

        local flag=table.contains(data,tid)
        if (flag) then
            response.ret=-103
            return response
        end
        tflag=true
    end



    local item={}
    item.h=reward.serverreward
    item.q=reward.reward
    item.f=reward.f
    local title=reward.tilte
    local content=reward.content
    local ret = MAIL:mailSent(uid,0,uid,'','',title,content,1,0,2,item)
    
    
    if ret then
        if dayflag then
            redis:incr(daykey)
            redis:expire(daykey,24*3600)
        end
        if tflag then
            table.insert(data,tid)
            redis:set(key,json.encode(data))
            redis:expire(key,45*24*3600)
        end
        local statuskey="z."..zid.."yybgiftbagstatus."..tid
        redis:incr(statuskey)
        redis:expire(statuskey,24*3600)

        response.ret = 0
        response.msg = 'Success'
    end

    return response


end