-- 区域站排名

function api_areateamwar_applyrank(request)
    local response = {
        ret=-1,
        msg='error',
        data = {},
    }

    local uid   = tonumber(request.uid)
    local aid   = tonumber(request.params.aid) or 0
    local date  = getWeeTs()

    if uid == nil   then
        response.ret = -102
        return response
    end
    
    require "model.serverbattle"
    local mServerbattle = model_serverbattle()
        --缓存跨服军团战的基本信息
    local mMatchinfo= mServerbattle.getserverareabattlecfg()
    if not next(mMatchinfo)  then
        return response
    end

    local flag=false
    local areaWarCfg = getConfig('serverAreaWarCfg')
    local ts = getClientTs()
    local st=tonumber(mMatchinfo.st)
    local redis = getRedis()
    local applykey ="z."..getZoneId().."serverAreaWar.applyrank"..mMatchinfo.bid
    if ts>=(st+areaWarCfg.signuptime*86400) then
        local rankdata = redis:get(applykey)
        if rankdata~=nil then
            response.data.ranklist=json.decode(rankdata)
            flag=true
        end
    end
    
    if flag==false then
        local data={
            bid=mMatchinfo.bid, 
        }
        local senddata={cmd='areateamwarserver.apply',params={data=data,action='applyrank'}}
        local config = getConfig("config.areacrossserver.connect")
        local flag = false
      
        local ret=sendGameserver(config.host,config.port,senddata)
        if ret and  ret.ret then
            if ret.ret==0 then
                if ret.data.ranklist  then
                    response.data.ranklist=ret.data.ranklist
                    redis:set(applykey,json.encode(ret.data.ranklist))
                    redis:expire(applykey,tonumber(mMatchinfo.et))
                end
            end
            
        end
    end    

    response.ret = 0
    response.msg = 'Success'
    
    return response



end