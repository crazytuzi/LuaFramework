--军团大战的进入集合按着先来后到的数序 来排定先上阵的15人  超过十五人就是待命状态
function api_alliance_joinline(request)
    local response = {
        ret=-1,
        msg='error',
        data = {},
    }
    
    
    local aid = tonumber(request.params.aid) or 0

    local uid = request.uid 

    if uid == nil or aid == 0 then
        response.ret = -102
        return response
    end
   
    if moduleIsEnabled('alliancewar') == 0 then
        response.ret = -4012
        return response
    end
    local uobjs = getUserObjs(uid)
    uobjs.load({"userinfo","task","useralliancewar"})

    local mUserinfo = uobjs.getModel('userinfo')

    if mUserinfo.alliance ~= aid then
        response.ret = -8023
        return response
    end


    local execRet,code = M_alliance.joinline({uid=uid,aid=aid})

    if not execRet then
        response.ret = code
        return response
    end

    -- push -------------------------------------------------

    local mems = M_alliance.getMemberList{uid=uid,aid=aid}
        if mems then
            local cmd = 'alliance.memreadybatte'
            local data = {
                    alliance = {
                        alliance={
                            commander = mUserinfo.name,
                            members = {
                                {uid=uid,batte=execRet.data.battle,q=execRet.data.q}
                            }
                        }
                    }
                }
  
            for _,v in pairs( mems.data.members) do                        
                regSendMsg(v.uid,cmd,data)
            end
    end   
    --push end -----------------------------------------------
    local areaid =tonumber(execRet.data.areaid)
    local mAllianceWar = require "model.alliancewar"
    local opts = mAllianceWar:getWarOpenTs(areaid)
    local mUserAllianceWar = uobjs.getModel('useralliancewar')
    local allianceWarCfg = getConfig('allianceWarCfg')
    mUserAllianceWar.setCdTimeAt(opts.st-allianceWarCfg.cdTime)
    --军团活动收获日设置参战次数
    activity_setopt(uid,'harvestDay',{num=1})
    if uobjs.save() then
        response.data.useralliancewar = mUserAllianceWar.toArray(true)
    end
    response.ret = 0
    response.msg = 'Success'
    response.data.battle=execRet.data.battle
    response.data.q=execRet.data.q
    return response
end 