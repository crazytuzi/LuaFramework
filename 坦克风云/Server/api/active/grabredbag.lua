-- 开始抢红包
-- 给代币奥

function api_active_grabredbag(request)
    
    local response = {    
        ret=-1,
        msg='error',
        data = {},
    }

    local uid = request.uid
    local redid = tonumber(request.params.redid) or 1
    if uid == nil then
        response.ret = -102
        return response
    end

    -- 活动名称，抢红包
    local acname = 'grabRed'
        
    local uobjs = getUserObjs(uid)
    uobjs.load({"userinfo", "techs", "troops", "props","bag","skills","buildings",'useractive'})
    local mUseractive = uobjs.getModel('useractive')
    local mUserinfo = uobjs.getModel('userinfo')

    local activStatus = mUseractive.getActiveStatus(acname)
    -- 活动检测
    if activStatus ~= 1 then
        response.ret = activStatus
        return response
    end

    local ts = getClientTs()
    local weeTs = getWeeTs()
    local activeCfg = getConfig("active."..acname.."."..mUseractive.info[acname].cfg)
    if type(mUseractive.info[acname].t)~='table' then mUseractive.info[acname].t={}  end

    local flag = true
    -- 超过最大可抢人数
    response.data.flag=4
    local maxreid =tonumber(getMaxActiveIncrementId(acname..mUseractive.info[acname].st))

    if redid<=0 or redid>maxreid then
        -- 红包不存在
        response.data.flag=3
        flag =false
    end 

    local aflag=table.contains(mUseractive.info[acname].t,redid)
    if(aflag)then
        flag =false
        --已经领取过
        response.data.flag=2
    end

    if flag  then
        local Increment= getActiveIncrementId(acname..mUseractive.info[acname].st.."redid."..redid,mUseractive.getActiveCacheExpireTime(acname,172800))
        --被抢次数小于配置的次数 才给自己加代币

        if Increment<=activeCfg.maxcount then
            setRandSeed()
            response.data.accessory={}
            local randnum = rand(activeCfg.range[1],activeCfg.range[2])
            local log ={mUserinfo.nickname,randnum}
            mUseractive.setlog(getZoneId(),log,acname..redid.."grablog."..mUseractive.info[acname].st,true)
            mUseractive.info[acname].v=mUseractive.info[acname].v+randnum
            
            table.insert(mUseractive.info[acname].t,redid)
            --领取成功
            response.data.flag=1
            response.data.subgems  =randnum
            if not uobjs.save() then
                return response
            end
        end
  
    end
    local redinfo = mUseractive.getlog(getZoneId(),acname)
    if type(redinfo) =='table' then

        if type(redinfo[redid]) ~='table' then
            for k,v in pairs(redinfo) do
                if v[1]==redid then
                    redinfo=v
                    break
                end 
            end
        else
            redinfo=redinfo[redid]
        end
    else
        redinfo={}
    end

    local grablog = mUseractive.getlog(getZoneId(),acname..redid.."grablog."..mUseractive.info[acname].st)

    response.data.grablog=grablog
    response.data.useredbag=redinfo
    response.ret = 0        
    response.msg = 'Success'
    return  response
end
