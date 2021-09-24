-- 修改军团名字

function api_alliance_setname(request)
    
     -- 军团名称，2-6汉字
    local response = {
        ret=-1,
        msg='error',
        data = {},
    }
    local name = tostring(request.params.name) or ''
    local uid = request.uid
    local nameLen = utfstrlen(name)    
    local maxNameLen = getClientPlat() == 'tank_ar' and 24 or 12

    if uid == nil or nameLen < 3 or nameLen > maxNameLen or utfstrlen(foreignNotice) > 200 then
        response.ret = -102
        return response
    end

    if match(name) then
        response.ret = -8024
        return response
    end

    local useprop = request.params.usep or false

    local uobjs = getUserObjs(uid)
    uobjs.load({"userinfo","buildings"})

    local mUserinfo = uobjs.getModel('userinfo') 
    if mUserinfo.alliance==0 then
        response.ret = -102
        return response
    end 

     -- 使用改名卡
    if useprop then
        local mBag = uobjs.getModel('bag')
        if not mBag.use('p4850',1) then
            response.ret = -1996
            return response
        else
            response.data.bag = mBag.toArray(true)
        end
    else
        -- 除了使用道具改名 其他的是合服之后有@符号才能改名
        local setRet,code=M_alliance.getalliancesname{aids=json.encode({mUserinfo.alliance})}
        if type(setRet['data'])~='table' or not next(setRet['data']) then
            response.ret = -102
            return response
        end 

        local alliancename = setRet['data'][1]['name']
        if not string.find(alliancename,'@') then
            response.ret = -102
            return response
        end 
    end

    -- 领海战期间,军团不让改名
    local mTerritory = getModelObjs("aterritory",mUserinfo.alliance,true)
    if mTerritory.checkTimeOfWar(2) and mTerritory.checkApplyOfWar() then
        response.ret = -8434
        return response
    end

    -- 伟大航线战期间,不能操作军团(退出,解散,加入,踢出,弹劾)
    if getModelObjs("agreatroute",aid,true).allianceCanNotOperate() then
        response.ret = -8494
        return response
    end

    local aData = {} 
    aData.name = name
    aData.uid=uid
    local execRet,code = M_alliance.setname(aData)
    
    if not execRet then
        response.ret = code
        return response
    end
 
    mUserinfo.alliancename=name
    if uobjs.save() then
        processEventsAfterSave()

        if mUserinfo.mapx ~= -1 and mUserinfo.mapy ~= -1 then 
            -- 更新地图中的联盟字段
            local mMap = require "lib.map"
            local mid = getMidByPos(mUserinfo.mapx,mUserinfo.mapy)
            mMap:update(mid,{alliance=name})
        end

        local mTerritory = getModelObjs("aterritory",mUserinfo.alliance,true)
        if mTerritory.isNormal() then
            mTerritory.updateAllianceName(name)
        end

        response.ret = 0
        response.msg = 'Success'
    end
    
    return response
end
