-- 建筑帮助

function api_building_alliancehelp(request)
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
    local bid = request.params.bid and 'b' .. request.params.bid
    local buildType = request.params.buildType

    if uid == nil or bid == nil or buildType == nil then
        response.ret = -102
        return response
    end
    local uobjs = getUserObjs(uid)
    uobjs.load({"userinfo", "techs", "troops", "props","bag","skills","buildings","dailytask","task"})
    local mUserinfo = uobjs.getModel('userinfo')
    local mBuildings = uobjs.getModel('buildings')
    local mTechs = uobjs.getModel('techs')
    -- 刷新队列
    mBuildings.update()
    if mUserinfo.alliance<=0 then
        response.ret=-4005
        return response
    end
    local iSlotKey = mBuildings.checkIdInSlots(bid)
    
    if type(mBuildings.queue[iSlotKey]) ~= 'table' or mBuildings.queue[iSlotKey].type ~= buildType then       
        response.ret=-102
        return response
    end
   
    local et =tonumber(mBuildings.queue[iSlotKey].et) or 0
    local hid =tonumber(mBuildings.queue[iSlotKey].hid) or 0
    if et<=0 or hid>0 then
        response.ret=-102
        return response
    end
    local currentTs = getClientTs()             
    local remainsecs = et - currentTs
    local freespeedtime = getConfig("player.freespeedtime")
    if moduleIsEnabled('fs') ==1 and remainsecs<(freespeedtime[mUserinfo.vip+1]  or freespeedtime[#freespeedtime]) then
        response.ret=-102
        return response
    end
    local techCfg = getConfig('rankCfg.rank')
    local maxcount=0
    if techCfg[mUserinfo.rank]~=nil then
        maxcount=techCfg[mUserinfo.rank].helpNum
    end
    ALLIANCEHELP = require "lib.alliancehelp"
    local lvl=mBuildings.getLevel(bid)
    local data={
        uid=uid,
        aid=mUserinfo.alliance,
        mc =maxcount,
        et =et,
        type="buildings",
        info=json.encode({n=mUserinfo.nickname,sid=bid,pic=mUserinfo.pic,tid=buildType,lvl=lvl,bpic=mUserinfo.bpic,apic=mUserinfo.apic}),
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

    mBuildings.queue[iSlotKey].hid=hid

    if uobjs.save() then    
        processEventsAfterSave()
        response.data.buildings = mBuildings.toArray(true)
        response.ret = 0
        response.msg = 'Success'
        response.data.newhelp=data
    end
    return response
end