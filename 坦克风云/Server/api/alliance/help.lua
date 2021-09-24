-- 帮助一个人


function api_alliance_help(request)
    local response = {
        ret=-1,
        msg='error',
        data = {
        },
    }
    if moduleIsEnabled('alliancehelp') == 0 then
        response.ret = -180
        return response
    end
    local uid = tonumber(request.uid)

    local huobjs = getUserObjs(uid)
    huobjs.load({"userinfo"})
    local hmUserinfo = huobjs.getModel('userinfo')

    local id=request.params.id or 0
    if id<=0 then
        response.ret = 0
        response.msg = 'Success'
        return response
    end

    ALLIANCEHELP = require "lib.alliancehelp"
    local info=ALLIANCEHELP:get(id)
    if not info then
        response.ret=-8200
        return response
    end
    local ts=getClientTs() 
    if ts>=tonumber(info.et)  then
        response.ret=-8200
        return response
    end
    if tonumber(info.cc)>=tonumber(info.mc) then
        response.ret=-8201
        return response
    end
    local users=json.decode(info.list) or {}
    local flag=table.contains(users,tostring(uid))
    if flag then
        response.ret=-8202
        return response
    end
    local taruid=tonumber(info.uid)
    if taruid==uid then
        response.ret = 0
        response.msg = 'Success'
        return response
    end
    local uobjs = getUserObjs(taruid)
    uobjs.load({"userinfo", "techs", "troops", "props","bag","skills","buildings","dailytask","task"})
    local mUserinfo = uobjs.getModel('userinfo')
    local mTechs = uobjs.getModel('techs')
    local mBuildings = uobjs.getModel('buildings')

    local huser=json.decode(info.info)
    if mUserinfo.alliance~=tonumber(info.aid) or mUserinfo.alliance<=0  then
        response.ret=-8200
        return response
    end
    local retflag=true
    local techCfg = getConfig('rankCfg.rank')
    local speedtime=0
    if techCfg[mUserinfo.rank]~=nil then
        speedtime=techCfg[mUserinfo.rank].helpValue
    end
    local aet=info.et
    local techs=nil
    local buildings=nil
    if info.type=="techs" then
        local iSlotKey = mTechs.checkIdInSlots(huser.sid)
        if type(mTechs.queue[iSlotKey]) ~= 'table' then
            ALLIANCEHELP:del(info.id)
            response.ret=-8200
            return response
        end
        local et = tonumber(mTechs.queue[iSlotKey].et) or 0
        local tid = mTechs.queue[iSlotKey].id
        if et<=0  or tid~=huser.tid  then
            ALLIANCEHELP:del(info.id)
            response.ret=-8200
            return response
        end
        aet=et-speedtime
        mTechs.queue[iSlotKey].et=aet
        techs={}
        mTechs.update()
        if type(mTechs.queue[iSlotKey]) ~= 'table' then
            techs[tid]=mTechs[tid]
        end
        techs.queue = mTechs.queue
    elseif info.type=="buildings" then
        local iSlotKey = mBuildings.checkIdInSlots(huser.sid)
        if type(mBuildings.queue[iSlotKey]) ~= 'table' or mBuildings.queue[iSlotKey].type ~= huser.tid  then       
            ALLIANCEHELP:del(info.id)
            response.ret=-8200
            return response
        end
        local et = mBuildings.queue[iSlotKey].et or 0  
        if et<=0 then
            ALLIANCEHELP:del(info.id)
            response.ret=-8200
            return response
        end
        aet=et-speedtime
        mBuildings.queue[iSlotKey].et=aet
        mBuildings.update()
        buildings={}
        if type(mBuildings.queue[iSlotKey]) ~= 'table' then
            buildings[huser.sid]=mBuildings[huser.sid]
        end
        buildings.queue=mBuildings.queue
    end
    aet=math.ceil(tonumber(aet))
    local count=ALLIANCEHELP:addhelpIncr(id,aet)
    if tonumber(count)>tonumber(info.mc) then
        response.ret=-8201
        return response
    end

    -- 团结之力
    local unite = activity_setopt(uid,'unitepower',{id=4,aid=hmUserinfo.alliance,num=1})
    if unite then
        huobjs.save()
    end
    if uobjs.save() then
        regSendMsg(taruid,"msg.event",{help={type=info.type,lvl=tonumber(huser.lvl),n=hmUserinfo.nickname,tid=huser.tid,},newtechs=techs,newbuildings=buildings})
        ALLIANCEHELP:addhelpcount(info.id,count,aet,ts,tonumber(uid))
        local log={
            uid=taruid,
            info=json.encode({type=info.type,lvl=tonumber(huser.lvl),n=hmUserinfo.nickname,tid=huser.tid}),
            updated_at=ts,
        }
        ALLIANCEHELP:addhelplog(log)    
        response.ret = 0
        response.msg = 'Success'
    end
    return response



end