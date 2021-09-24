-- 军团协助 科技加速
function api_tech_alliancehelp(request)
    
    local response = {
        ret=-1,
        msg='error',
        data = {},
    }

    if moduleIsEnabled('alliancehelp') == 0 then
        response.ret = -180
        return response
    end
    local uid = request.uid
    local slotid=request.params.slotid
    local uobjs = getUserObjs(uid)
    uobjs.load({"userinfo", "techs", "troops", "props","bag","skills","buildings","dailytask","task"})
    local mUserinfo = uobjs.getModel('userinfo')
    local mTechs = uobjs.getModel('techs')
    if mUserinfo.alliance<=0 then
        response.ret=-4005
        return response
    end
    local iSlotKey = mTechs.checkIdInSlots(slotid)  
    if type(mTechs.queue[iSlotKey]) ~= 'table' then
        response.ret=-102
        return response
    end
    local et =tonumber(mTechs.queue[iSlotKey].et) or 0
    local hid =tonumber(mTechs.queue[iSlotKey].hid) or 0
    if et<=0 or hid>0 then
        response.ret=-102
        return response
    end
    local currentTs = getClientTs()             
    local remainsecs = et - currentTs
    local freespeedtime = getConfig("player.freespeedtime")
    if moduleIsEnabled('fs') ==1 and   remainsecs<(freespeedtime[mUserinfo.vip+1]  or freespeedtime[#freespeedtime]) then
        response.ret=-102
        return response
    end
    local techCfg = getConfig('rankCfg.rank')
    local maxcount=0
    if techCfg[mUserinfo.rank]~=nil then
        maxcount=techCfg[mUserinfo.rank].helpNum
    end
    ALLIANCEHELP = require "lib.alliancehelp"
    local lvl=mTechs.getTechLevel(mTechs.queue[iSlotKey].id)
    local data={
        uid=uid,
        aid=mUserinfo.alliance,
        mc =maxcount,
        et =et,
        type="techs",
        info=json.encode({n=mUserinfo.nickname,sid=slotid,pic=mUserinfo.pic,tid=mTechs.queue[iSlotKey].id,lvl=lvl}),
        updated_at=currentTs,
    }
    local hid=ALLIANCEHELP:Sent(data)
    if not hid then
        return response
    end
    data.id=hid
    data.cc=0
    data.list={}
    data.info=json.decode(data.info)

    mTechs.queue[iSlotKey].hid=hid

    if uobjs.save() then    
        processEventsAfterSave()
        response.data.techs = mTechs.toArray(true)
        response.ret = 0
        response.msg = 'Success'
        response.data.newhelp=data
    end
    return response
end




