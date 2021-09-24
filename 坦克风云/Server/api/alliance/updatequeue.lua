--军团战上阵下阵
function api_alliance_updatequeue(request)

    local response = {
        ret=-1,
        msg='error',
        data = {},
    }

    --type =1 是上阵   =2 下阵

    local aid = tonumber(request.params.aid) or 0
    local method=tonumber(request.params.type)
    local memuid = tonumber(request.params.memuid)
    local q = request.params.q
    local uid = request.uid 

    if uid == nil or aid == 0 or memuid==nil then
        response.ret = -102
        return response
    end
    
    if moduleIsEnabled('alliancewar') == 0 then
        response.ret = -4012
        return response
    end
    local uobjs = getUserObjs(uid)
    uobjs.load({"userinfo","task","troops","useralliancewar"})
    local date  = getWeeTs()
    local mUserinfo = uobjs.getModel('userinfo')

    if mUserinfo.alliance ~= aid then
        response.ret = -8023
        return response
    end

    local mobjs= {}
    if(memuid~=uid) then  
         mobjs = getUserObjs(memuid)
         mobjs.load({"userinfo","task","troops","useralliancewar"})
    end

    --下阵检测下成员是否占领据点
    if(method==2) then

        if(memuid~=uid) then  

           
            local mUTroops = mobjs.getModel('troops')
            if type(mUTroops.alliancewar)=="table" and next(mUTroops.alliancewar) then
                response.ret = -8055
                return response
            end
        end
        
    end


    local execRet,code = M_alliance.updatequeue({uid=uid,aid=aid,type=method,memuid=memuid,q=q})
    local ts = getClientTs()
    local allianceWarCfg = getConfig('allianceWarCfg')
    if not execRet then
        response.ret = code
        return response
    end
    local useralliancewar ={}
    if method ==1 then
        
        if(memuid~=uid) then  
            
            local mUserAllianceWar = mobjs.getModel('useralliancewar')
            -- 更新cd时间
            mUserAllianceWar.setCdTimeAt()
            mobjs.save() 
            useralliancewar = mUserAllianceWar.toArray(true)
        else
            local mUserAllianceWar = uobjs.getModel('useralliancewar')
            -- 更新cd时间
            mUserAllianceWar.setCdTimeAt()
            uobjs.save() 
            useralliancewar = mUserAllianceWar.toArray(true)
        end

    else
         if(memuid~=uid) then  
            local mUserAllianceWar = mobjs.getModel('useralliancewar')
            -- 更新cd时间
            
            mUserAllianceWar.setCdTimeAt(ts-allianceWarCfg.cdTime)
            mobjs.save() 
            useralliancewar = mUserAllianceWar.toArray(true)
        else
            local mUserAllianceWar = uobjs.getModel('useralliancewar')
            -- 更新cd时间
            mUserAllianceWar.setCdTimeAt(ts-allianceWarCfg.cdTime)
            uobjs.save() 
            useralliancewar = mUserAllianceWar.toArray(true)
        end
        local pushCmd = 'alliancewar.battle.push'
        local defenderPushData = {}
        defenderPushData.useralliancewar=useralliancewar
        regSendMsg(memuid,pushCmd,defenderPushData)
        
    end
        -- push -------------------------------------------------

    local mems = M_alliance.getMemberList{uid=uid,aid=aid}
        if mems then
            local cmd = 'alliance.memupqueue'
            local data = {
                    alliance = {
                        alliance={
                            commander =mUserinfo.nickname,
                            members = {
                                {uid=memuid,batte=execRet.data.battle,q=execRet.data.q}
                            }
                        }
                    }
                }
            for _,v in pairs( mems.data.members) do
                local userdata = data
                if (tonumber(v.uid)==memuid) then 
                     userdata.useralliancewar=useralliancewar
                end                       
                regSendMsg(v.uid,cmd,userdata)
            end
    end   
    --push end -----------------------------------------------

    response.ret = 0
    response.msg = 'Success'
    return response

end