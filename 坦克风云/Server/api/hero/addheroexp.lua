--  增加奖励的经验

function api_hero_addheroexp(request)
    local response = {
        ret=-1,
        msg='error',
        data = {},
    }

    local uid = request.uid
    local hid = request.params.hid 
    local level = request.params.level
    if uid == nil or hid==nil  then
        response.ret = -102
        return response
    end

    if moduleIsEnabled('hero') == 0 then
        response.ret = -11000
        return response
    end
    
    local uobjs = getUserObjs(uid)
    uobjs.load({"userinfo", "techs", "troops", "props","bag","skills","buildings",'useractive',"hero"})
    local mHero = uobjs.getModel('hero')
    local mUserinfo = uobjs.getModel('userinfo')
    if type (mHero.hero[hid]) ~='table' then
        response.ret=-11002
        return response
    end
    local heroCfg = getConfig('heroCfg')
    local point = mHero.hero[hid][2]
    local p = mHero.hero[hid][3]
    local hlevel =mHero.hero[hid][1]
    if hlevel>=level then
        response.ret=-102
        return response
    end
    local herolevel=heroCfg.heroLevel[p]

    local maxpoint =heroCfg.levelUP[p][herolevel+1]

    if point>=maxpoint then
            -- 英雄最大等级
        response.ret=-11013
        return response

    end       
    if level >mUserinfo.level then
        --人物等级不足
        response.ret=-11014
        return response
    end

    local levelpoint=heroCfg.levelUP[p][level]
    local needexp=levelpoint-point+1
    if mHero.exp-needexp<0 then
        response.ret=-102
        return response
    end

    if not mHero.changeExp(-needexp) then
        response.ret =-102
        return response
    end

    local ret= mHero.upgradeheropoint(hid,needexp,maxpoint,mUserinfo.level)
    if not ret then
        return response
    end
    
    -- 春节攀升
    activity_setopt(uid, 'chunjiepansheng', {action='js'})

    regActionLogs(uid,9,{action=903,item=hid,value=mHero.hero[hid][1],params={useexp=needexp,exp=mHero.exp}})  
    regEventBeforeSave(uid,'e1')
    processEventsBeforeSave()
    if uobjs.save()  then 
        processEventsAfterSave()
        response.data.hero =mHero.toArray(true)
        response.ret = 0        
        response.msg = 'Success'
    end
    return response
end
