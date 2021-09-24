-- 设置部队

function api_cross_setline(request)
    local response = {
        ret=-1,
        msg='error',
        data = {},
    }

    local uid = request.uid
    local line    =request.params.line 
    if uid == nil then
        response.ret = -102
        return response
    end

    local uobjs = getUserObjs(uid)
    uobjs.load({"userinfo", "techs", "troops", "props","bag","skills","buildings",'useractive','crossinfo'})
    local mCrossinfo = uobjs.getModel('crossinfo')
    local mUserinfo  = uobjs.getModel('userinfo')
    if  type(mCrossinfo.battle.troops)~='table' then 
        response.ret = -102
        return response
    end

    mCrossinfo.battle.line=line
    local aName=mUserinfo.alliancename
    local params=mCrossinfo.getlastdata(aName,mCrossinfo.battle.troops[mCrossinfo.battle.line[1]],mCrossinfo.battle.troops[mCrossinfo.battle.line[2]],mCrossinfo.battle.troops[mCrossinfo.battle.line[3]],mCrossinfo.battle.hero,mCrossinfo.battle.equip,mCrossinfo.battle.plane)
     
    local data={cmd='crossserver.setuser',params={udata={params}}}
    local config = getConfig("config.z"..getZoneId()..".cross")
    local flag = false
    for i=1,5 do
        
        local ret=sendGameserver(config.host,config.port,data)
        if ret.ret==0 then
            flag=true
            break
        end
    end
    local ts=getClientTs()
    if not flag then
        
        writeLog("host=="..config.host..config.host.."params=="..json.encode(params),'setcrosserror')
        response.ret = -20020
        return response
    end
    --ptb:e(params)
    if type(mCrossinfo.battle.ts)~='table' then  mCrossinfo.battle.ts={0,0,0} end
    local ts=getClientTs()
    mCrossinfo.battle.ts[1]=ts
    mCrossinfo.battle.ts[2]=ts
    mCrossinfo.battle.ts[3]=ts
    processEventsBeforeSave()
    if uobjs.save() then    
        processEventsAfterSave()
        response.ret = 0
        response.msg = 'Success'
    end

    return response



end