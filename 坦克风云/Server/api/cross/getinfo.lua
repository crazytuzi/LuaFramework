function api_cross_getinfo(request)
    local response = {
        data = {},
        config = {},
        ret = 0,
        msg = 'Success'
    }
    local uid = request.uid

    if uid == nil then
        response.ret = -102
        return response
    end

    local uobjs = getUserObjs(uid)
    uobjs.load({"userinfo", "techs", "troops", "props","bag","skills","buildings",'useractive','crossinfo'})
    local mCrossinfo = uobjs.getModel('crossinfo')
    local mUserinfo = uobjs.getModel('userinfo')
    local st =mCrossinfo.battle.st or 0
    require "model.matches"


    local mMatches = model_matches()

    local info =mMatches.base
    if tonumber(info.st)~=st then
        mCrossinfo.battle.flag={1,1,1}
        mCrossinfo.battle.troops={{},{},{}}
        mCrossinfo.battle.hero={{},{},{}}
        mCrossinfo.battle.equip={0,0,0}
        mCrossinfo.battle.st=tonumber(info.st)
    end

    if uobjs.save() then    
        processEventsAfterSave()
        response.data=mCrossinfo.battle
        response.ret = 0
        response.msg = 'Success'
    end

    return response
end