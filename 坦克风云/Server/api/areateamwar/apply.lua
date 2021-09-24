-- 跨服区域站报名

function api_areateamwar_apply(request)
    local response = {
        ret=-1,
        msg='error',
        data = {},
    }

    local uid = tonumber(request.uid)
    local aid   = tonumber(request.params.aid) or 0
    local uobjs = getUserObjs(uid)
    uobjs.load({"userinfo"})
    local mUserinfo = uobjs.getModel('userinfo')

    if mUserinfo.alliance <=0 then
        response.ret = -8023
        return response
    end
    require "model.serverbattle"
    local mServerbattle = model_serverbattle()
        --缓存跨服军团战的基本信息
    local mMatchinfo= mServerbattle.getserverareabattlecfg()
    if not next(mMatchinfo)  then
        return response
    end
    local ts = getClientTs()
    local st=tonumber(mMatchinfo.st)
    local areaWarCfg = getConfig('serverAreaWarCfg')
    if ts>=(st+areaWarCfg.signuptime*86400) then
        return response
    end
    if areaWarCfg.minRegistrationFee< 0 then
       response.ret = -8042
       return response
    end

    local execRet, code = M_alliance.applyareawar{uid=uid,aid=mUserinfo.alliance,point=areaWarCfg.minRegistrationFee,ts=ts,st=mMatchinfo.st}

    if  code~=nil  and  code ~= -8043 then
        response.ret = code
        return response
    end
    require "model.skyladder"
    local skyladder = model_skyladder()

    local rank,info,skyscore=skyladder.getMyRank(2,mUserinfo.alliance)
    local score=0

    if skyscore~=nil and skyscore>0 then
        score=skyscore
    end
    local data={
        zid=getZoneId(),
        bid=mMatchinfo.bid,
        aid=mUserinfo.alliance,
        name=execRet.data.alliance.name,
        fight=execRet.data.alliance.fight,
        commander=execRet.data.alliance.commander,
        logo=json.encode(execRet.data.alliance.logo),
        score=score,
        apply_at=ts,
        servers=mMatchinfo.servers,
        st=st+areaWarCfg.signuptime*86400,
        et=st+((areaWarCfg.signuptime+areaWarCfg.battleTime)*86400),
    }

    local senddata={cmd='areateamwarserver.apply',params={data=data,action='apply'}}
    local config = getConfig("config.areacrossserver.connect")
    local flag = false
    for i=1,5 do
        local ret=sendGameserver(config.host,config.port,senddata)
        response.ret=-1
        if ret and  ret.ret then
            if ret.ret==0 then
                flag=true
            end
            response.ret=ret.ret
            break
        end 
    end

    if flag==false then
        M_alliance.applyareawar{uid=uid,aid=mUserinfo.alliance,point=areaWarCfg.minRegistrationFee,ts=ts,st=mMatchinfo.st,del=1}
        return response
    end

 -- push -------------------------------------------------
    local mems = M_alliance.getMemberList{uid=uid,aid=aid}
    if mems then
        local cmd = 'alliance.memapplyareawarbattle'
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

    response.ret = 0
    response.msg = 'Success'
    response.data.point =execRet.data.alliance.point
    
    return response
end