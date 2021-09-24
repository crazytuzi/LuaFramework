-- 区域战报名
function api_areawar_apply(request)
    local response = {
        ret=-1,
        msg='error',
        data = {},
    }

    local uid = tonumber(request.uid)
    local point = tonumber (request.params.point) or 0
    local aid   = tonumber(request.params.aid) or 0
    local date  = getWeeTs()
    if uid == nil or point == 0 or aid == 0 or areaid == 0 then
        response.ret = -102
        return response
    end
     
    if moduleIsEnabled('areawar') == 0 then
        response.ret = -4012
        return response
    end
    local uobjs = getUserObjs(uid)
    uobjs.load({"userinfo"})
    local mUserinfo = uobjs.getModel('userinfo')

    if mUserinfo.alliance ~= aid then
        response.ret = -8023
        return response
    end
    local ts = getClientTs()
    local date  = getWeeTs()
    local weekday=tonumber(getDateByTimeZone(ts,"%w"))

    
    
    local areaWarCfg = getConfig('areaWarCfg')
    local day=areaWarCfg.prepareTime
    if weekday~=day then 
        response.ret = -8053
        return response
        --if weekday>=day then
          --  date=date-(weekday-day)*86400
        --else
          --  date=date+(day-weekday)*86400
        --end
    end
    

    if areaWarCfg.minRegistrationFee> point then
       response.ret = -8042
       return response
    end

    local execRet, code = M_alliance.applyarea{uid=uid,aid=aid,point=point,ts=ts,date=date}
    if not execRet then
        response.ret = code
        return response
    end

 -- push -------------------------------------------------
    local mems = M_alliance.getMemberList{uid=uid,aid=aid}
    if mems then
        local cmd = 'alliance.memapplyareabattle'
        local data = {
                alliance = {
                    alliance={
                        commander = execRet.data.admin and execRet.data.admin.name,
                        members = {
                            
                        }
                    }
                }
            }

        if execRet.data.admin then
            table.insert(data.alliance.alliance.members,{uid=execRet.data.admin.uid,point=execRet.data.alliance.point})
        end
        for _,v in pairs( mems.data.members) do 

            regSendMsg(v.uid,cmd,data)
        end
    end

    local send = execRet.data.send
    if(send ~=nil and send==1) then 
        local cronParams = {cmd ="areawar.sendbattlemsg",params={opents=opts}}
        if not(setGameCron(cronParams,(date+86400+5)-ts)) then
            setGameCron(cronParams,(date+86400+5)-ts) 
        end 
        
    end
    response.ret = 0
    response.msg = 'Success'
    response.data.point =execRet.data.alliance.point
    
    return response


end